// A stand-in for Chrome's Prompt API (window.LanguageModel), injected before
// the page's own scripts by the end-to-end tests. The real model is not in a
// headless browser, and its answers would not be the same twice; this one
// answers with a fixed text and records every call, so the tests check what the
// widget does with an answer and what it sends, not what Gemini Nano writes.
//
// configure({availability, answer, fail}) sets what availability() returns
// ("available", "downloadable", "downloading" or "unavailable"), the text of
// every answer, and whether answering fails. The calls are in window.__promptApi.calls.
(() => {
  const state = { availability: 'available', answer: '', fail: false, calls: [] };

  const session = {
    async prompt(input) {
      state.calls.push({ method: 'prompt', input: String(input) });
      if (state.fail) throw new DOMException('The model failed', 'UnknownError');
      return state.answer;
    },
    promptStreaming(input) {
      state.calls.push({ method: 'promptStreaming', input: String(input) });
      const words = state.answer.split(/(?<= )/);
      let sent = 0;
      return new ReadableStream({
        pull(controller) {
          // Fails after the first words, as a model that breaks mid-answer would.
          if (state.fail && sent === 2) {
            controller.error(new DOMException('The model failed', 'UnknownError'));
            return;
          }
          if (words.length) {
            controller.enqueue(words.shift());
            sent += 1;
          } else {
            controller.close();
          }
        },
      });
    },
    destroy() {},
  };

  window.LanguageModel = {
    async availability(options) {
      state.calls.push({ method: 'availability', options });
      return state.availability;
    },
    async create(options) {
      state.calls.push({ method: 'create', options: { ...options, monitor: undefined } });
      if (state.availability !== 'available') throw new DOMException('Model not on the device', 'NotAllowedError');
      return session;
    },
  };

  window.__promptApi = {
    configure(settings) {
      Object.assign(state, settings);
    },
    get calls() {
      return state.calls;
    },
  };
})();
