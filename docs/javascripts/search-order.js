// The site search («Búsqueda») lists its results in the order of the course: chapter 1 before
// chapter 2, and the pages outside the chapters in their place in the navigation. Material ranks
// results by relevance and has no option for another order, so this reorders the list as Material
// fills it: each result is one page, and results of the same page keep Material's order.
//
// Material shows the results in batches as the list is scrolled; each batch is sorted into place as
// it arrives. The header, with the search, is not replaced by instant navigation, so this runs once.

/** The place of each page in the navigation, by its path. */
function navigationOrder() {
  /** @type {Map<string, number>} */
  const order = new Map();
  document.querySelectorAll('.md-nav--primary a.md-nav__link[href]').forEach((link, i) => {
    const path = new URL(/** @type {HTMLAnchorElement} */ (link).href).pathname;
    if (!order.has(path)) order.set(path, i);
  });
  return order;
}

const list = document.querySelector('.md-search-result__list');
if (list) {
  const order = navigationOrder();
  /** @param {Element} item */
  const place = (item) => {
    const link = /** @type {HTMLAnchorElement | null} */ (item.querySelector('a[href]'));
    return link ? (order.get(new URL(link.href).pathname) ?? Infinity) : Infinity;
  };
  new MutationObserver(() => {
    const items = [...list.children];
    const sorted = [...items].sort((a, b) => place(a) - place(b));
    // Appending moves the elements, which notifies the observer again: only when the order changed.
    if (sorted.some((item, i) => item !== items[i])) list.append(...sorted);
  }).observe(list, { childList: true });
}
