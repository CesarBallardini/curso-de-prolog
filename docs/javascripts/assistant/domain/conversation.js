// The conversation: the questions asked, and what was found and written for each.

/** @typedef {import('./ports.js').Answer} Answer */
/** @typedef {import('./ports.js').ExchangeRecord} ExchangeRecord */

export class Conversation {
  /** @type {ExchangeRecord[]} */
  #records;

  /** @param {ExchangeRecord[]} [records] a conversation kept from before */
  constructor(records = []) {
    this.#records = records.filter((r) => typeof r.question === 'string' && r.answer);
  }

  /** The exchanges that have an answer, in the order they were asked. */
  get records() {
    return [...this.#records];
  }

  /** @param {string} question @param {Answer} answer @returns {ExchangeRecord} */
  answered(question, answer) {
    /** @type {ExchangeRecord} */
    const record = { question, answer };
    this.#records.push(record);
    return record;
  }

  /** @param {ExchangeRecord} record @param {string} text */
  written(record, text) {
    record.written = text;
  }

  /** Forget one exchange. @param {ExchangeRecord} record */
  remove(record) {
    this.#records = this.#records.filter((r) => r !== record);
  }

  /** Forget every exchange. */
  clear() {
    this.#records = [];
  }
}
