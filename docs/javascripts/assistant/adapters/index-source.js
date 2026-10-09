// Adapter: downloads the course's index, assistant/index.json, that tools/assistant/index_hook.py writes
// when the site is built.

/** @typedef {import('../domain/ports.js').Chunk} Chunk */

// The version of assistant/index.json this code reads (INDEX_VERSION in tools/assistant/index_hook.py).
export const INDEX_VERSION = 1;

/**
 * @param {URL | string} base the site's absolute URL, ending in /
 * @returns {Promise<Chunk[]>} the chunks, in the order of the site's navigation
 */
export async function fetchIndex(base) {
  const response = await fetch(new URL('assistant/index.json', base));
  if (!response.ok) throw new Error(`assistant/index.json: ${response.status}`);
  /** @type {{ version: number, chunks: Chunk[] }} */
  const index = await response.json();
  if (index.version !== INDEX_VERSION) throw new Error(`index version ${index.version}, expected ${INDEX_VERSION}`);
  return index.chunks;
}
