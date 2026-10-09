// Composition root of the course assistant on the page: builds the adapters, gives them to the use
// cases, and connects the panel's events to them. The only module that knows every layer.
//
//   domain/        the search, the order of the course, the written answer's rules, the conversation
//   application/   the use cases: asking a question, forgetting questions
//   adapters/      the panel (DOM), the Web Worker search, Chrome's Prompt API, sessionStorage
import { PanelView } from './adapters/panel-view.js';
import { PromptApiWriter } from './adapters/prompt-api-writer.js';
import { SessionStore } from './adapters/session-store.js';
import { WorkerSearch } from './adapters/worker-search.js';
import { AskQuestion, ForgetQuestions } from './application/use-cases.js';
import { Conversation } from './domain/conversation.js';
import { citedParts } from './domain/written-answer.js';

/** The site's absolute URL, from Material's configuration: it is the same on every page of the site. */
function siteBase() {
  const config = JSON.parse(document.getElementById('__config')?.textContent ?? '{"base": "."}');
  const base = new URL(config.base, location.href);
  base.pathname = base.pathname.replace(/\/?$/, '/');
  return base;
}

const base = siteBase();
const view = new PanelView(base);
const store = new SessionStore();
const conversation = new Conversation(store.load());
const search = new WorkerSearch(new URL('worker.js', import.meta.url), base, {
  onReady: () => view.ready(),
  onUnavailable: () => view.unavailable(),
});
// window.LanguageModel exists only in a browser that ships the Prompt API.
const browser = /** @type {{ LanguageModel?: import('./adapters/prompt-api-writer.js').LanguageModelApi }} */ (
  /** @type {unknown} */ (self)
);
const writer = new PromptApiWriter(browser.LanguageModel);
const askQuestion = new AskQuestion({ conversation, search, writer, store });
const forgetQuestions = new ForgetQuestions({ conversation, store });

/** @param {import('./domain/ports.js').ExchangeRecord} record @param {ReturnType<typeof view.ask>} exchange */
function offerRemoval(record, exchange) {
  exchange.offerRemoval(() => {
    forgetQuestions.one(record);
    view.remove(exchange);
  });
}

view.onOpen(() => {
  search.start();
  for (const record of conversation.records) {
    const exchange = view.restore(record);
    if (record.written && record.answer) {
      exchange.showWriting(citedParts(record.written, record.answer.passages.length), record.answer.passages);
    }
    offerRemoval(record, exchange);
  }
});

view.onQuestion(async (question) => {
  const exchange = view.ask(question);
  const record = await askQuestion.ask(question, exchange);
  if (record) offerRemoval(record, exchange);
});

view.onClear(() => forgetQuestions.all());
