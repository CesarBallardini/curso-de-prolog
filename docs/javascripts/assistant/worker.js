// Composition root of the Web Worker: downloads the course and answers questions with the domain's
// search. The protocol is described in adapters/worker-search.js, its counterpart on the page.
import { fetchIndex } from './adapters/index-source.js';
import { loadSpanish } from './adapters/lunr-spanish.js';
import { highlight } from './domain/highlight.js';
import { createSearch } from './domain/ranking.js';
import { createTokenizer } from './domain/text.js';

/** @typedef {ReturnType<typeof createSearch>} Search */
/** @typedef {import('./domain/text.js').Tokenizer} Tokenizer */

/** @type {Promise<{ search: Search, tokenizer: Tokenizer }> | null} */
let loading = null;

/** @param {string} base */
async function load(base) {
  const [chunks, language] = await Promise.all([fetchIndex(base), loadSpanish(base)]);
  const tokenizer = createTokenizer(language);
  return { search: createSearch(chunks, tokenizer), tokenizer };
}

self.addEventListener('message', async ({ data }) => {
  if (data.type === 'init') {
    loading ??= load(data.base);
    loading.then(
      () => self.postMessage({ type: 'ready' }),
      (error) => self.postMessage({ type: 'error', message: String(error) }),
    );
    return;
  }
  if (data.type !== 'ask') return;
  try {
    if (!loading) throw new Error('the worker was asked before it was started');
    const { search, tokenizer } = await loading;
    const answer = search.ask(data.question);
    const wanted = new Set(answer.terms);
    for (const passage of answer.passages) passage.segments = highlight(passage.text, wanted, tokenizer);
    self.postMessage({ type: 'answer', id: data.id, answer });
  } catch (error) {
    self.postMessage({ type: 'error', id: data.id, message: String(error) });
  }
});
