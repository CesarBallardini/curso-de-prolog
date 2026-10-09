// The written answer: what a writer is asked, and which of its citations stand.

/** @typedef {import('./ports.js').Answer} Answer */
/** @typedef {import('./ports.js').CitedPart} CitedPart */
/** @typedef {import('./ports.js').Passage} Passage */
/** @typedef {import('./ports.js').WrittenAnswerRequest} WrittenAnswerRequest */

const INSTRUCTIONS =
  'You answer questions about a Prolog course using only the numbered fragments given. ' +
  'Write a short answer in Spanish, in an impersonal register (never address the reader directly). ' +
  'After each claim, cite the fragment that supports it like [1]. ' +
  'If the fragments do not answer the question, say so instead of guessing.';

/** Only an answer with passages can be written about: the writer may use nothing else. @param {Answer} answer */
export const canBeWritten = (answer) => answer.passages.length > 0;

/**
 * The request for a written answer: the passages numbered from 1, in the order they are shown.
 * @param {string} question
 * @param {Passage[]} passages
 * @returns {WrittenAnswerRequest}
 */
export function writtenAnswerRequest(question, passages) {
  const fragments = passages.map((p, i) => `[${i + 1}] ${p.title}\n${p.text}`).join('\n\n');
  return { instructions: INSTRUCTIONS, prompt: `Pregunta: ${question}\n\nFragmentos:\n${fragments}` };
}

/**
 * A written text in pieces: each citation `[n]` of a passage that exists, and the text between them.
 * A citation of no passage is dropped: the student must never be sent to nothing.
 * @param {string} text
 * @param {number} passageCount
 * @returns {CitedPart[]}
 */
export function citedParts(text, passageCount) {
  /** @type {CitedPart[]} */
  const parts = [];
  text.split(/(\[\d+\])/).forEach((piece, i) => {
    if (i % 2 === 0) {
      if (piece) parts.push({ text: piece });
      return;
    }
    const number = Number(piece.slice(1, -1));
    if (number >= 1 && number <= passageCount) parts.push({ text: piece, citation: number });
  });
  return parts;
}
