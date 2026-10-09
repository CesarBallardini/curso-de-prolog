// The search: ranks the course's sections for a question and picks the passages that answer it.
//
// A chunk is scored with BM25 (bm25.js) over its text, its title, its chapter's title and the keywords
// generated for it, each with its weight. A section whose title holds every word of a short query
// («árbol de derivación» in «5.2 El árbol de derivación») is about it, and counts double. The same
// heading on a chapter's index page and on its extra page is one section. The answer lists sections in order of relevance; course-order.js puts
// it in the order of the course for the student.
import { bm25Document, createBm25 } from './bm25.js';
import { createPassageFinder } from './passages.js';
import { sectionKey } from './section-key.js';

/** @typedef {import('./ports.js').Answer} Answer */
/** @typedef {import('./ports.js').Chunk} Chunk */
/** @typedef {import('./ports.js').FoundSection} FoundSection */
/** @typedef {import('./ports.js').Term} Term */
/** @typedef {import('./text.js').Tokenizer} Tokenizer */
/** @typedef {{ useKeywords?: boolean, keywordBoost?: number, titleMatch?: number, minShare?: number }} SearchOptions */

const TITLE_BOOST = 3;
const CHAPTER_BOOST = 2;
// The words a student would use for the section, generated in advance (tools/assistant/keywords.py).
const KEYWORD_BOOST = 2;
// A section whose title holds every word of the query, two words at least: the expression it is about.
// Measured on blind question sets: 2, 3 and 5 gave the same ranks, and none lost an ordinary question.
const TITLE_MATCH = 2;
// Sections scoring less than this share of the best are not listed: beside a section about the
// expression asked for, they are incidental mentions. No target of the blind sets is ever below it.
const MIN_SHARE = 0.5;
// Sections that list or summarise rather than explain: poor places to send a student.
const META = /#(ejercicios|objetivos-del-capitulo|resumen|temas-que-se-retoman|referencias)(_\d+)?$/;
const META_WEIGHT = 0.6;
// Words that carry no topic in a question. Prolog is the topic of every page.
const QUESTION_WORDS = ['sirve', 'sirven', 'hace', 'hacen', 'hago', 'hacer', 'puedo', 'puede', 'pueden', 'existe', 'prolog'];
// The question is covered when the best chunk holds this share of its terms, weighted by rarity.
const COVERED_SHARE = 0.5;
const KEYWORD_SEPARATOR = ' · ';
export const MAX_SECTIONS = 5;

/** @param {string} location */
const chapterOf = (location) => location.split('/')[0] + '/';

/**
 * @param {Chunk[]} chunks        the index, in the order of the site's navigation
 * @param {Tokenizer} tokenizer
 * @param {SearchOptions} [options] the production settings when left out
 */
export function createSearch(
  chunks,
  tokenizer,
  { useKeywords = true, keywordBoost = KEYWORD_BOOST, titleMatch = TITLE_MATCH, minShare = MIN_SHARE } = {},
) {
  const { terms } = tokenizer;
  // The chapter's title counts in every one of its sections: the topic of a chapter is spread over all
  // of them, so no single section stands out by it.
  /** @type {Map<string, Term[]>} */
  const chapterTitles = new Map();
  for (const chunk of chunks) if (chunk.location === chapterOf(chunk.location)) chapterTitles.set(chunk.location, terms(chunk.title));

  const words = chunks.map(() => bm25Document());
  chunks.forEach((chunk, position) => {
    const keywordEntries = useKeywords && chunk.keywords ? chunk.keywords.split(KEYWORD_SEPARATOR).map(terms) : [];
    /** @type {Array<[Term[], number]>} */
    const fields = [
      [terms(chunk.text), 1],
      [terms(chunk.title), TITLE_BOOST],
      [chapterTitles.get(chapterOf(chunk.location)) ?? [], CHAPTER_BOOST],
    ];
    for (const [list, weight] of fields) words[position].add(list, weight);
    // A keyword counts once, however many entries repeat it.
    words[position].add([...new Set(keywordEntries.flat())], keywordBoost);
  });
  const byWord = createBm25(words);
  const weights = chunks.map((chunk) => (META.test(chunk.location) ? META_WEIGHT : 1));
  const titleTerms = chunks.map((chunk) => new Set(terms(chunk.title)));

  /** @type {Map<string, number>} total text and first position of each location */
  const textLength = new Map();
  /** @type {Map<string, number>} */
  const firstPosition = new Map();
  chunks.forEach((chunk, position) => {
    textLength.set(chunk.location, (textLength.get(chunk.location) ?? 0) + chunk.text.length);
    if (!firstPosition.has(chunk.location)) firstPosition.set(chunk.location, position);
  });
  const questionWords = new Set(QUESTION_WORDS.flatMap((w) => terms(w)));
  const findPassages = createPassageFinder(terms, byWord.idf);

  /**
   * One entry per section, in order of relevance: the same heading on a chapter's index page and on
   * its extra page is one section, shown with the page that has more text.
   * @param {{ chunk: Chunk, score: number }[]} ranked
   * @param {number} limit
   * @returns {FoundSection[]}
   */
  function sectionsOf(ranked, limit) {
    /** @type {Map<string, { score: number, members: string[], titles: Map<string, string> }>} */
    const byKey = new Map();
    for (const { chunk, score } of ranked) {
      const key = sectionKey(chunk.location);
      const group = byKey.get(key);
      if (!group) byKey.set(key, { score, members: [chunk.location], titles: new Map([[chunk.location, chunk.title]]) });
      else if (!group.members.includes(chunk.location)) {
        group.members.push(chunk.location);
        group.titles.set(chunk.location, chunk.title);
      }
    }
    return [...byKey.values()].slice(0, limit).map((group) => {
      const location = group.members.reduce((a, b) => ((textLength.get(b) ?? 0) > (textLength.get(a) ?? 0) ? b : a));
      const position = Math.min(...group.members.map((m) => firstPosition.get(m) ?? Infinity));
      return { location, title: group.titles.get(location) ?? '', score: group.score, position, members: group.members };
    });
  }

  /**
   * @param {string} question
   * @param {{ sections?: number }} [limits]
   * @returns {Answer}
   */
  function ask(question, { sections: limit = MAX_SECTIONS } = {}) {
    const wanted = new Set(terms(question).filter((t) => !questionWords.has(t)));
    /** @param {number} position */
    const inTitle = (position) => wanted.size >= 2 && [...wanted].every((t) => titleTerms[position].has(t));
    const ranked = chunks
      .map((chunk, position) => ({
        chunk,
        position,
        score: byWord.score(position, wanted) * weights[position] * (inTitle(position) ? titleMatch : 1),
      }))
      .filter((r) => r.score > 0)
      .sort((a, b) => b.score - a.score);
    const best = ranked[0]?.score ?? 0;
    const strong = ranked.filter((r) => r.score >= minShare * best);
    const sections = sectionsOf(strong, limit);
    const mass = [...wanted].reduce((sum, t) => sum + byWord.idf(t), 0);
    const top = ranked[0];
    const found = top
      ? [...wanted].filter((t) => words[top.position].frequencies.has(t)).reduce((sum, t) => sum + byWord.idf(t), 0)
      : 0;
    const covered = mass > 0 && found / mass >= COVERED_SHARE;
    const passages = covered ? findPassages(sections, ranked.map((r) => r.chunk), wanted) : [];
    return { sections, passages, covered, terms: [...wanted] };
  }

  return { ask };
}
