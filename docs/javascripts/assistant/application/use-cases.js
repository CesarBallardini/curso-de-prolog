// Use cases of the course assistant: asking a question, and forgetting questions asked before.
// They work through the domain's ports only, and import nothing but the domain.
import { inCourseOrder } from '../domain/course-order.js';
import { canBeWritten, citedParts, writtenAnswerRequest } from '../domain/written-answer.js';

/** @typedef {import('../domain/conversation.js').Conversation} Conversation */
/** @typedef {import('../domain/ports.js').AnswerWriter} AnswerWriter */
/** @typedef {import('../domain/ports.js').ConversationStore} ConversationStore */
/** @typedef {import('../domain/ports.js').ExchangeRecord} ExchangeRecord */
/** @typedef {import('../domain/ports.js').ExchangeView} ExchangeView */
/** @typedef {import('../domain/ports.js').SearchService} SearchService */

/**
 * Asks the course a question: searches it, shows what was found in the order of the course, keeps it,
 * and adds a written answer when a writer is available and there are passages to write from.
 */
export class AskQuestion {
  #conversation;
  #search;
  #writer;
  #store;

  /**
   * @param {{ conversation: Conversation, search: SearchService, writer: AnswerWriter, store: ConversationStore }} ports
   */
  constructor({ conversation, search, writer, store }) {
    this.#conversation = conversation;
    this.#search = search;
    this.#writer = writer;
    this.#store = store;
  }

  /**
   * @param {string} question
   * @param {ExchangeView} view
   * @returns {Promise<ExchangeRecord | null>} the exchange kept, or null when nothing could be found
   */
  async ask(question, view) {
    let answer;
    try {
      answer = inCourseOrder(await this.#search.ask(question));
    } catch {
      view.showFailure();
      return null;
    }
    const record = this.#conversation.answered(question, answer);
    this.#store.save(this.#conversation.records);
    view.showAnswer(answer);
    if (canBeWritten(answer) && (await this.#writer.isAvailable())) await this.#write(record, view);
    return record;
  }

  /** @param {ExchangeRecord} record @param {ExchangeView} view */
  async #write(record, view) {
    const answer = /** @type {import('../domain/ports.js').Answer} */ (record.answer);
    const count = answer.passages.length;
    try {
      const text = await this.#writer.write(writtenAnswerRequest(record.question, answer.passages), (partial) =>
        view.showWriting(citedParts(partial, count), answer.passages),
      );
      this.#conversation.written(record, text);
      this.#store.save(this.#conversation.records);
    } catch {
      view.dropWriting();
    }
  }
}

/** Forgets questions asked before: one, or all of them. */
export class ForgetQuestions {
  #conversation;
  #store;

  /** @param {{ conversation: Conversation, store: ConversationStore }} ports */
  constructor({ conversation, store }) {
    this.#conversation = conversation;
    this.#store = store;
  }

  /** @param {ExchangeRecord} record */
  one(record) {
    this.#conversation.remove(record);
    this.#store.save(this.#conversation.records);
  }

  all() {
    this.#conversation.clear();
    this.#store.save(this.#conversation.records);
  }
}
