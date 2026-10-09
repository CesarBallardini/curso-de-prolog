// The order an answer is shown in: the order of the course. Relevance decides which sections and
// passages an answer has; the student reads them as the course presents them, chapter by chapter and
// section by section (the order of the site's navigation).

/** @typedef {import('./ports.js').Answer} Answer */

/**
 * The same answer, its sections and passages in the order of the course.
 * @param {Answer} answer
 * @returns {Answer}
 */
export function inCourseOrder(answer) {
  const sections = [...answer.sections].sort((a, b) => a.position - b.position);
  /** @param {string} location */
  const place = (location) => sections.findIndex((s) => s.location === location);
  const passages = [...answer.passages].sort((a, b) => place(a.location) - place(b.location));
  return { ...answer, sections, passages };
}
