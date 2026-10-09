// BM25: how well a document matches a set of terms, given how often each term occurs in it, how long
// it is, and how rare the term is in the whole collection.

/** @typedef {import('./ports.js').Term} Term */
/** @typedef {{ frequencies: Map<Term, number>, length: number }} Bm25Document */

const K1 = 1.2;
const B = 0.75;

/**
 * Counts terms into a document, each with a weight (a title's term counts more than a text's).
 * @returns {Bm25Document & { add: (terms: Term[], weight: number) => void }}
 */
export function bm25Document() {
  /** @type {Map<Term, number>} */
  const frequencies = new Map();
  const doc = {
    frequencies,
    length: 0,
    /** @param {Term[]} terms @param {number} weight */
    add(terms, weight) {
      for (const term of terms) frequencies.set(term, (frequencies.get(term) ?? 0) + weight);
      doc.length += terms.length * weight;
    },
  };
  return doc;
}

/** @param {Bm25Document[]} documents a collection, scored by position */
export function createBm25(documents) {
  /** @type {Map<Term, number>} */
  const documentFrequency = new Map();
  for (const doc of documents) {
    for (const term of doc.frequencies.keys()) documentFrequency.set(term, (documentFrequency.get(term) ?? 0) + 1);
  }
  const total = documents.length;
  const averageLength = documents.reduce((sum, d) => sum + d.length, 0) / total || 1;

  /** How rare a term is in the collection. @param {Term} term */
  const idf = (term) => {
    const n = documentFrequency.get(term) ?? 0;
    return Math.log(1 + (total - n + 0.5) / (n + 0.5));
  };

  /** @param {number} position @param {Iterable<Term>} wanted */
  const score = (position, wanted) => {
    const doc = documents[position];
    let sum = 0;
    for (const term of wanted) {
      const f = doc.frequencies.get(term);
      if (f) sum += idf(term) * ((f * (K1 + 1)) / (f + K1 * (1 - B + (B * doc.length) / averageLength)));
    }
    return sum;
  };

  return { idf, score };
}
