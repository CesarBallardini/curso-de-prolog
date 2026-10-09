// The course assistant's domain model and the ports it declares: the types the domain works with, and
// the interfaces that the outer layers implement for it (application/, adapters/). Types only: this
// module exports no code, and like every module of domain/ it imports nothing from outside domain/.

/**
 * A word as the search compares it, stemmed and with its accents folded; or a predicate indicator
 * (`findall/3`) or an operator (`\+`), kept whole.
 * @typedef {string} Term
 */

/**
 * Port: the language of the course. The domain needs a stemmer and a list of words that carry no
 * topic; adapters/lunr-spanish.js provides Spanish.
 * @typedef {object} Language
 * @property {(word: string) => string} stem
 * @property {string[]} stopWords
 */

/**
 * A piece of a section of the course, as the index holds it (tools/assistant/index_hook.py), in the
 * order of the site's navigation.
 * @typedef {object} Chunk
 * @property {string} location  `<page>/#<anchor>`, relative to the site; '' is the home page
 * @property {string} title
 * @property {string} text      paragraphs separated by a blank line, code between ``` fences
 * @property {string} [keywords] the words and questions a student would use for the section
 */

/**
 * A section found for a question.
 * @typedef {object} FoundSection
 * @property {string} location  the page with more of its text, when the section is on two pages
 * @property {string} title
 * @property {number} score     relevance; higher is better
 * @property {number} position  place in the course: the order of the site's navigation
 * @property {string[]} members every location of the section (the stub and the full page)
 */

/**
 * The sentence or the code block of a section that best answers a question.
 * @typedef {object} Passage
 * @property {string} location
 * @property {string} title
 * @property {string} text
 * @property {boolean} code
 * @property {number} score
 * @property {Array<[string, boolean]>} [segments] the text in pieces, true for a question's term
 */

/**
 * @typedef {object} Answer
 * @property {FoundSection[]} sections at most five
 * @property {Passage[]} passages      at most three, one per section, from the most relevant sections
 * @property {boolean} covered         whether the course seems to treat the question
 * @property {Term[]} terms            the question's terms
 */

/**
 * Port: searches the course. adapters/worker-search.js runs the search in a Web Worker.
 * @typedef {object} SearchService
 * @property {(question: string) => Promise<Answer>} ask
 */

/**
 * What a writer of answers is asked: its instructions, and the question with the numbered passages.
 * @typedef {object} WrittenAnswerRequest
 * @property {string} instructions
 * @property {string} prompt
 */

/**
 * Port: writes a short answer from the passages. adapters/prompt-api-writer.js uses the language
 * model that Chrome ships, only when it is already on the device.
 * @typedef {object} AnswerWriter
 * @property {() => Promise<boolean>} isAvailable
 * @property {(request: WrittenAnswerRequest, onText: (text: string) => void) => Promise<string>} write
 */

/**
 * A piece of a written answer: plain text, or a citation of the passage with that number (from 1).
 * @typedef {{ text: string, citation?: number }} CitedPart
 */

/**
 * One question of the conversation and what was found and written for it, as it is stored.
 * @typedef {object} ExchangeRecord
 * @property {string} question
 * @property {Answer} [answer]
 * @property {string} [written]
 */

/**
 * Port: keeps the conversation across page loads. adapters/session-store.js uses sessionStorage.
 * @typedef {object} ConversationStore
 * @property {() => ExchangeRecord[]} load
 * @property {(records: ExchangeRecord[]) => void} save
 */

/**
 * Port: shows one exchange to the student. adapters/panel-view.js draws it in the panel.
 * @typedef {object} ExchangeView
 * @property {(answer: Answer) => void} showAnswer
 * @property {(parts: CitedPart[], passages: Passage[]) => void} showWriting
 * @property {() => void} dropWriting
 * @property {() => void} showFailure
 */

export {};
