// Adapter for the Language port: the Spanish Snowball stemmer and stopword list that Material ships for
// its own search (lunr-languages), loaded without lunr; both files only need the hooks below.
//
// The files are evaluated with `new Function`, so a Content-Security-Policy without 'unsafe-eval'
// would stop the assistant.

/** @typedef {import('../domain/ports.js').Language} Language */

const DIRECTORY = 'assets/javascripts/lunr/min/';

/**
 * The language, from the source of lunr.stemmer.support.min.js and of lunr.es.min.js.
 * @param {string} supportSource
 * @param {string} spanishSource
 * @returns {Language}
 */
export function languageFromSources(supportSource, spanishSource) {
  /** @type {{ Pipeline: object, generateStopWordFilter: (words: string[]) => () => void, stopWords: string[], es?: { stemmer: (word: string) => string } }} */
  const lunr = {
    Pipeline: { registerFunction() {} },
    generateStopWordFilter(words) {
      lunr.stopWords = words;
      return () => {};
    },
    stopWords: [],
  };
  for (const source of [supportSource, spanishSource]) {
    // Each file is a UMD module: given an `exports` object, it puts its factory in module.exports.
    /** @type {{ exports: object | ((lunr: object) => void) }} */
    const module = { exports: {} };
    new Function('module', 'exports', 'define', source)(module, module.exports, undefined);
    if (typeof module.exports !== 'function') throw new Error('a lunr file did not export its factory');
    module.exports(lunr);
  }
  const stemmer = lunr.es?.stemmer;
  if (!stemmer) throw new Error('lunr.es did not define a stemmer');
  return { stem: (word) => stemmer(word), stopWords: lunr.stopWords };
}

/**
 * The language, downloaded from the site.
 * @param {URL | string} base the site's absolute URL, ending in /
 * @returns {Promise<Language>}
 */
export async function loadSpanish(base) {
  /** @param {string} name */
  const text = async (name) => {
    const response = await fetch(new URL(DIRECTORY + name, base));
    if (!response.ok) throw new Error(`${name}: ${response.status}`);
    return response.text();
  };
  const [support, spanish] = await Promise.all([text('lunr.stemmer.support.min.js'), text('lunr.es.min.js')]);
  return languageFromSources(support, spanish);
}
