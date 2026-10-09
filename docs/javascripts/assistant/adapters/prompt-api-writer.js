// Adapter for the AnswerWriter port: Chrome's Prompt API (window.LanguageModel), the language model the
// browser ships. It is used only when the model is already on the device: the site never starts its
// download, so in every state but 'available' the writer is not available.

/** @typedef {import('../domain/ports.js').AnswerWriter} AnswerWriter */
/** @typedef {import('../domain/ports.js').WrittenAnswerRequest} WrittenAnswerRequest */

const LANGUAGES = [{ type: 'text', languages: ['es'] }];
const MODEL_OPTIONS = { expectedInputs: LANGUAGES, expectedOutputs: LANGUAGES };

/**
 * The part of the Prompt API this adapter uses.
 * @typedef {object} PromptSession
 * @property {(prompt: string) => ReadableStream<string>} promptStreaming
 * @property {() => void} destroy
 * @typedef {object} LanguageModelApi
 * @property {(options: object) => Promise<string>} availability
 * @property {(options: object) => Promise<PromptSession>} create
 */

/** @implements {AnswerWriter} */
export class PromptApiWriter {
  /** @type {LanguageModelApi | undefined} */
  #api;

  /** @param {LanguageModelApi | undefined} api window.LanguageModel, absent in most browsers */
  constructor(api) {
    this.#api = api;
  }

  async isAvailable() {
    return this.#api !== undefined && (await this.#api.availability(MODEL_OPTIONS)) === 'available';
  }

  /**
   * One session per answer, closed when it ends; the text is streamed to `onText` as it grows.
   * @param {WrittenAnswerRequest} request
   * @param {(text: string) => void} onText
   */
  async write({ instructions, prompt }, onText) {
    if (!this.#api) throw new Error('no Prompt API');
    const session = await this.#api.create({ ...MODEL_OPTIONS, initialPrompts: [{ role: 'system', content: instructions }] });
    try {
      // getReader and not `for await`: Firefox has no async iteration of a ReadableStream.
      const reader = session.promptStreaming(prompt).getReader();
      let text = '';
      for (let chunk = await reader.read(); !chunk.done; chunk = await reader.read()) {
        text += chunk.value;
        onText(text);
      }
      return text;
    } finally {
      session.destroy();
    }
  }
}
