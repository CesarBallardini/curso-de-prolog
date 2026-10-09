// Adapter for the SearchService port: the search runs in a Web Worker (worker.js), so that loading the
// course and ranking it never block the page. The worker starts when the first question needs it.
//
// Messages to the worker:   { type: 'init', base } | { type: 'ask', id, question }
// Messages from the worker: { type: 'ready' } | { type: 'error', id?, message } | { type: 'answer', id, answer }

/** @typedef {import('../domain/ports.js').Answer} Answer */
/** @typedef {import('../domain/ports.js').SearchService} SearchService */
/** @typedef {{ resolve: (answer: Answer) => void, reject: (error: Error) => void }} Pending */
/** @typedef {{ onReady: () => void, onUnavailable: () => void }} StatusListener */

/** @implements {SearchService} */
export class WorkerSearch {
  #workerUrl;
  #base;
  #status;
  /** @type {Worker | null} */
  #worker = null;
  #failed = false;
  #nextId = 0;
  /** @type {Map<number, Pending>} */
  #pending = new Map();

  /**
   * @param {URL} workerUrl
   * @param {URL} base  the site's absolute URL, ending in /
   * @param {StatusListener} status
   */
  constructor(workerUrl, base, status) {
    this.#workerUrl = workerUrl;
    this.#base = base;
    this.#status = status;
  }

  /** Start the worker, which downloads the course; nothing happens on a second call. */
  start() {
    if (this.#worker) return;
    const worker = new Worker(this.#workerUrl, { type: 'module' });
    worker.addEventListener('message', ({ data }) => this.#receive(data));
    // The worker's own script failed (it could not be loaded, or threw while starting).
    worker.addEventListener('error', () => this.#fail(new Error('the search worker failed')));
    worker.postMessage({ type: 'init', base: this.#base.href });
    this.#worker = worker;
  }

  /** @param {string} question @returns {Promise<Answer>} */
  ask(question) {
    this.start();
    if (this.#failed) return Promise.reject(new Error('the course could not be loaded'));
    const id = this.#nextId++;
    return new Promise((resolve, reject) => {
      this.#pending.set(id, { resolve, reject });
      this.#worker?.postMessage({ type: 'ask', id, question });
    });
  }

  /** @param {{ type: string, id?: number, answer?: Answer, message?: string }} data */
  #receive(data) {
    if (data.type === 'ready') {
      this.#status.onReady();
      return;
    }
    if (data.id === undefined) {
      this.#fail(new Error(data.message ?? 'the course could not be loaded'));
      return;
    }
    const pending = this.#pending.get(data.id);
    this.#pending.delete(data.id);
    if (data.type === 'answer' && data.answer) pending?.resolve(data.answer);
    else pending?.reject(new Error(data.message ?? 'no answer'));
  }

  /** @param {Error} error */
  #fail(error) {
    this.#failed = true;
    this.#status.onUnavailable();
    for (const pending of this.#pending.values()) pending.reject(error);
    this.#pending.clear();
  }
}
