// Highlighting: a passage in pieces, the question's terms marked.

/** @typedef {import('./ports.js').Term} Term */
/** @typedef {import('./text.js').Tokenizer} Tokenizer */

/**
 * @param {string} text
 * @param {Set<Term>} wanted   the question's terms
 * @param {Tokenizer} tokenizer
 * @returns {Array<[string, boolean]>} the text in order, true for the pieces to mark
 */
export function highlight(text, wanted, tokenizer) {
  /** @type {Array<[string, boolean]>} */
  const pieces = [];
  let position = 0;
  for (const { term, start, end } of tokenizer.positions(text)) {
    if (!wanted.has(term) || start < position) continue;
    if (start > position) pieces.push([text.slice(position, start), false]);
    pieces.push([text.slice(start, end), true]);
    position = end;
  }
  if (position < text.length) pieces.push([text.slice(position), false]);
  return pieces;
}
