// Adapter for the ExchangeView port, and the panel around it: a launcher button and a modal dialog
// where questions are asked and answered. The elements hang from <body>, which Material's instant
// navigation does not replace, so the conversation outlives page changes. Everything the student
// reads is Spanish, in the course's impersonal register.

/** @typedef {import('../domain/ports.js').Answer} Answer */
/** @typedef {import('../domain/ports.js').CitedPart} CitedPart */
/** @typedef {import('../domain/ports.js').ExchangeRecord} ExchangeRecord */
/** @typedef {import('../domain/ports.js').ExchangeView} ExchangeView */
/** @typedef {import('../domain/ports.js').Passage} Passage */
/** @typedef {Record<string, string>} Attributes */

export const PANEL_NAME = 'Preguntar al curso';
const NOT_COVERED = 'El curso no parece tratar esta pregunta. Las secciones más cercanas son:';
const WRITTEN_NOTE = 'Texto generado por el modelo del navegador; puede equivocarse. La sección enlazada es la fuente.';

/**
 * @param {string} tag
 * @param {Attributes} [attributes]
 * @param {...(Node | string)} children
 */
function element(tag, attributes = {}, ...children) {
  const node = document.createElement(tag);
  for (const [name, value] of Object.entries(attributes)) node.setAttribute(name, value);
  node.append(...children);
  return node;
}

/** @implements {ExchangeView} */
class ExchangeArticle {
  #links;
  /** @type {HTMLElement} */
  article;
  /** @type {HTMLElement | null} */
  #writing = null;

  /** @param {string} question @param {(location: string, text: string) => HTMLElement} links */
  constructor(question, links) {
    this.#links = links;
    this.article = element('article', {}, element('p', { class: 'assistant-question' }, question));
  }

  waiting() {
    this.article.append(element('p', { class: 'assistant-waiting' }, 'Buscando…'));
  }

  /** @param {Answer} answer */
  showAnswer(answer) {
    this.article.querySelector('.assistant-waiting')?.remove();
    if (!answer.covered) this.article.append(element('p', {}, NOT_COVERED));
    const items = answer.sections.map((s) => element('li', {}, this.#links(s.location, s.title)));
    this.article.append(element('ul', { 'aria-label': 'Dónde leerlo' }, ...items), ...answer.passages.map((p) => this.#passage(p)));
  }

  /** @param {CitedPart[]} parts @param {Passage[]} passages */
  showWriting(parts, passages) {
    const pieces = parts.map((part) =>
      part.citation === undefined ? part.text : this.#links(passages[part.citation - 1].location, part.text),
    );
    const region = element(
      'section',
      { 'aria-label': 'Respuesta escrita' },
      element('p', {}, ...pieces),
      element('p', { class: 'assistant-note' }, WRITTEN_NOTE),
    );
    if (this.#writing) this.#writing.replaceWith(region);
    else this.article.querySelector('.assistant-question')?.after(region);
    this.#writing = region;
  }

  dropWriting() {
    this.#writing?.remove();
    this.#writing = null;
  }

  showFailure() {
    this.article.querySelector('.assistant-waiting')?.remove();
    this.article.append(element('p', {}, 'No se pudo responder esta pregunta.'));
  }

  /** Let the student remove this exchange. @param {() => void} onRemove */
  offerRemoval(onRemove) {
    const button = element('button', { type: 'button', class: 'assistant-remove' }, 'Quitar');
    button.addEventListener('click', onRemove);
    this.article.querySelector('.assistant-question')?.append(' ', button);
  }

  /** @param {Passage} passage */
  #passage(passage) {
    const segments = passage.segments ?? [[passage.text, false]];
    const body = passage.code ? element('pre', {}, element('code')) : element('p');
    const target = /** @type {HTMLElement} */ (passage.code ? body.firstChild : body);
    for (const [text, isMatch] of segments) target.append(isMatch ? element('mark', {}, text) : text);
    return element('blockquote', {}, body, element('footer', {}, this.#links(passage.location, `Leer «${passage.title}»`)));
  }
}

export class PanelView {
  #base;
  #launcher = element('button', { type: 'button', class: 'assistant-launcher' }, PANEL_NAME);
  #question = element('input', { id: 'assistant-question', type: 'text', autocomplete: 'off' });
  #status = element('p', { class: 'assistant-status', role: 'status' }, 'Cargando el curso…');
  #log = element('div', { role: 'log', 'aria-label': 'Conversación', 'aria-live': 'polite' });
  #clear = element('button', { type: 'button' }, 'Borrar la conversación');
  #close = element('button', { type: 'button' }, 'Cerrar');
  #form = element(
    'form',
    {},
    element('label', { for: 'assistant-question' }, 'Pregunta'),
    this.#question,
    element('button', { type: 'submit' }, 'Preguntar'),
  );
  #dialog = /** @type {HTMLDialogElement} */ (
    element(
      'dialog',
      { class: 'assistant-dialog', 'aria-labelledby': 'assistant-title' },
      element('header', {}, element('h2', { id: 'assistant-title' }, PANEL_NAME), this.#clear, this.#close),
      this.#status,
      this.#log,
      this.#form,
    )
  );

  /** @param {URL} base the site's absolute URL, ending in /: links are resolved against it */
  constructor(base) {
    this.#base = base;
    document.body.append(this.#launcher, this.#dialog);
    this.#close.addEventListener('click', () => this.#dialog.close());
    this.#dialog.addEventListener('close', () => this.#launcher.focus());
    // A click on the backdrop or on a link closes the panel; the link then does its navigation.
    this.#dialog.addEventListener('click', (event) => {
      const target = /** @type {Element} */ (event.target);
      if (target === this.#dialog || target.closest('a')) this.#dialog.close();
    });
    this.#dialog.addEventListener('keydown', (event) => this.#keepFocusInside(event));
  }

  /** @param {() => void} onFirstOpen called once, the first time the panel opens */
  onOpen(onFirstOpen) {
    let opened = false;
    this.#launcher.addEventListener('click', () => {
      if (!opened) onFirstOpen();
      opened = true;
      this.#dialog.showModal();
      this.#question.focus();
    });
  }

  /** @param {(question: string) => void} onQuestion called with each question that is not blank */
  onQuestion(onQuestion) {
    this.#form.addEventListener('submit', (event) => {
      event.preventDefault();
      const question = /** @type {HTMLInputElement} */ (this.#question).value.trim();
      if (!question) return;
      /** @type {HTMLInputElement} */ (this.#question).value = '';
      onQuestion(question);
    });
  }

  /** @param {() => void} onClear */
  onClear(onClear) {
    this.#clear.addEventListener('click', () => {
      onClear();
      this.#log.replaceChildren();
      this.#question.focus();
    });
  }

  ready() {
    this.#status.hidden = true;
  }

  unavailable() {
    this.#status.hidden = false;
    this.#status.textContent = 'No se pudo cargar el curso. Recargar la página puede resolverlo.';
  }

  /** A new exchange, waiting for its answer. @param {string} question */
  ask(question) {
    const exchange = new ExchangeArticle(question, (location, text) => this.#link(location, text));
    exchange.waiting();
    this.#log.append(exchange.article);
    return exchange;
  }

  /** An exchange kept from before. @param {ExchangeRecord} record */
  restore(record) {
    const exchange = new ExchangeArticle(record.question, (location, text) => this.#link(location, text));
    if (record.answer) exchange.showAnswer(record.answer);
    this.#log.append(exchange.article);
    return exchange;
  }

  /** Remove an exchange from the panel. @param {ExchangeArticle} exchange */
  remove(exchange) {
    exchange.article.remove();
    this.#question.focus();
  }

  /** @param {string} location @param {string} text */
  #link(location, text) {
    return element('a', { href: new URL(location, this.#base).href }, text);
  }

  /** @param {KeyboardEvent} event */
  #keepFocusInside(event) {
    if (event.key !== 'Tab') return;
    const focusable = /** @type {HTMLElement[]} */ ([...this.#dialog.querySelectorAll('a[href], button, input')]);
    const [from, to] = event.shiftKey ? [focusable[0], focusable.at(-1)] : [focusable.at(-1), focusable[0]];
    if (document.activeElement === from) {
      event.preventDefault();
      to?.focus();
    }
  }
}
