// Adapter for the ConversationStore port: the conversation lives in sessionStorage, so it outlives a
// reload of the page and is gone when the tab closes. Without storage (a private window that refuses
// it), the conversation lasts until the page is reloaded.

/** @typedef {import('../domain/ports.js').ConversationStore} ConversationStore */
/** @typedef {import('../domain/ports.js').ExchangeRecord} ExchangeRecord */

const KEY = 'assistant-conversation';

/** @implements {ConversationStore} */
export class SessionStore {
  /** @returns {ExchangeRecord[]} */
  load() {
    try {
      const stored = JSON.parse(sessionStorage.getItem(KEY) ?? '[]');
      return Array.isArray(stored) ? stored : [];
    } catch {
      return [];
    }
  }

  /** @param {ExchangeRecord[]} records */
  save(records) {
    try {
      sessionStorage.setItem(KEY, JSON.stringify(records));
    } catch {
      // Without storage the conversation lasts until the page is reloaded.
    }
  }
}
