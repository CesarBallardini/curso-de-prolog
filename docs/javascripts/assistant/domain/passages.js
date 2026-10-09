// Passages: the sentence or the code block of a section that best answers a question.

/** @typedef {import('./ports.js').Passage} Passage */
/** @typedef {import('./ports.js').FoundSection} FoundSection */
/** @typedef {import('./ports.js').Term} Term */
/** @typedef {{ location: string, title: string, text: string }} PassageSource */

// The first sentence of a section states its subject; long units count less; a short sentence is
// shown with the next one; a section whose best unit is much weaker than the first passage's gives
// none.
const FIRST_UNIT_BONUS = 1.15;
const UNIT_LENGTH_SCALE = 600;
const SHORT_SENTENCE = 140;
const WEAK_PASSAGE = 0.3;
export const MAX_PASSAGES = 3;

/** Sentences and code blocks of a text: the units a passage is made of. @param {string} text */
function units(text) {
  /** @type {{ text: string, code: boolean }[]} */
  const out = [];
  for (const block of text.split(/\n\n(?=```|[^`])/)) {
    if (block.startsWith('```')) out.push({ text: block.replace(/^```\n?|\n?```$/g, ''), code: true });
    else for (const sentence of block.split(/(?<=[.:;?!])\s+(?=[\p{Lu}¿¡`(])/u)) out.push({ text: sentence, code: false });
  }
  return out;
}

/**
 * Picks passages for the sections of an answer.
 * @param {(text: string) => Term[]} terms  the tokenizer's terms
 * @param {(term: Term) => number} idf      how rare a term is in the course
 */
export function createPassageFinder(terms, idf) {
  /** The best unit of a chunk, or null. @param {PassageSource} chunk @param {Set<Term>} wanted */
  function bestUnit(chunk, wanted) {
    /** @type {Passage | null} */
    let best = null;
    units(chunk.text).forEach((unit, i, all) => {
      let score = 0;
      for (const term of new Set(terms(unit.text).filter((t) => wanted.has(t)))) score += idf(term);
      if (!score) return;
      score *= (i === 0 ? FIRST_UNIT_BONUS : 1) / (1 + unit.text.length / UNIT_LENGTH_SCALE);
      if (best && best.score >= score) return;
      const next = all[i + 1];
      const text = !unit.code && unit.text.length < SHORT_SENTENCE && next && !next.code ? `${unit.text} ${next.text}` : unit.text;
      best = { location: chunk.location, title: chunk.title, text, code: unit.code, score };
    });
    return best;
  }

  /**
   * One passage from each of the most relevant sections, so that every passage sits next to its link.
   * @param {FoundSection[]} sections   in order of relevance
   * @param {PassageSource[]} matched   the chunks that matched, in order of relevance
   * @param {Set<Term>} wanted          the question's terms
   * @returns {Passage[]}
   */
  return function findPassages(sections, matched, wanted) {
    /** @type {Passage[]} */
    const passages = [];
    for (const section of sections) {
      if (passages.length === MAX_PASSAGES) break;
      const candidates = matched.filter((c) => section.members.includes(c.location)).map((c) => bestUnit(c, wanted));
      const best = candidates.filter((p) => p !== null).sort((a, b) => b.score - a.score)[0];
      if (best && (!passages.length || best.score >= WEAK_PASSAGE * passages[0].score)) {
        passages.push({ ...best, location: section.location, title: section.title });
      }
    }
    return passages;
  };
}
