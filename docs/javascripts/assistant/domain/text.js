// The words of the course and of a question, as the search compares them.

/** @typedef {import('./ports.js').Language} Language */
/** @typedef {import('./ports.js').Term} Term */
/** @typedef {{ term: Term, start: number, end: number }} PositionedTerm */

// Prolog operators kept as terms. Longest first, so `\==` is not read as `\=`.
const OPERATORS = ['=\\=', '\\==', '=:=', '=@=', '=..', '*->', '\\+', '\\=', '==', '=<', '>=', '->', ':-', '?-', '@<', '@>', '!'];
/** @param {string} s */
const escape = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const TOKEN = new RegExp(
  [
    '([a-z_][A-Za-z0-9_]*/\\d+)', // a predicate indicator, name/arity
    '(' + OPERATORS.map(escape).join('|') + ')',
    '([\\p{L}\\p{N}_]+)', // a word or an identifier
  ].join('|'),
  'gu',
);
/** @param {string} s */
const fold = (s) => s.normalize('NFD').replace(/[̀-ͯ]/g, '');

/**
 * The terms of a text: lower case, accents folded, stopwords dropped, words stemmed; a predicate
 * indicator counts whole and as its bare name; operators are kept as they are written.
 * @param {Language} language
 */
export function createTokenizer({ stem, stopWords }) {
  const stops = new Set(stopWords.map(fold));
  /** @type {Map<string, Term>} */
  const stems = new Map();
  /** @param {string} word */
  const stemmed = (word) => {
    let term = stems.get(word);
    if (term === undefined) {
      term = fold(/[\d_]/.test(word) ? word : stem(word));
      stems.set(word, term);
    }
    return term;
  };

  /** Each term with the place of the text it comes from, for highlighting. @param {string} text */
  function positions(text) {
    /** @type {PositionedTerm[]} */
    const out = [];
    for (const match of text.matchAll(TOKEN)) {
      const [whole, indicator, operator, word] = match;
      const start = match.index;
      const end = start + whole.length;
      if (indicator) {
        const lower = indicator.toLowerCase();
        out.push({ term: lower, start, end }, { term: stemmed(lower.split('/')[0]), start, end });
      } else if (operator) {
        out.push({ term: operator, start, end });
      } else {
        const lower = word.toLowerCase();
        if (!stops.has(fold(lower)) && lower.length >= 2) out.push({ term: stemmed(lower), start, end });
      }
    }
    return out;
  }

  return {
    positions,
    /** @param {string} text @returns {Term[]} */
    terms: (text) => positions(text).map((p) => p.term),
  };
}

/** @typedef {ReturnType<typeof createTokenizer>} Tokenizer */
