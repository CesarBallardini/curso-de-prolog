// Two buttons hide and show the navigation on the left and the table of contents of the page on the
// right, so the text can use the whole width of the window. The choice is kept in localStorage and
// applies to every page. The buttons live in the document root, which instant navigation does not
// replace, so this runs once; the classes on <html> are what the stylesheet reads.

const SIDES = /** @type {const} */ ([
  { key: 'left', hideClass: 'sidebar-left-hidden', hide: 'Ocultar el índice del curso', show: 'Mostrar el índice del curso' },
  { key: 'right', hideClass: 'sidebar-right-hidden', hide: 'Ocultar el índice de la página', show: 'Mostrar el índice de la página' },
]);

/** @param {string} key */
function stored(key) {
  try {
    return localStorage.getItem(`sidebar-${key}`) === 'hidden';
  } catch {
    return false;
  }
}

/** @param {string} key @param {boolean} hidden */
function store(key, hidden) {
  try {
    localStorage.setItem(`sidebar-${key}`, hidden ? 'hidden' : 'shown');
  } catch {
    // Private window or blocked storage: the choice lasts until the page is closed.
  }
}

for (const side of SIDES) {
  const button = document.createElement('button');
  button.type = 'button';
  button.className = `sidebar-toggle sidebar-toggle--${side.key}`;

  /** @param {boolean} hidden */
  const apply = (hidden) => {
    document.documentElement.classList.toggle(side.hideClass, hidden);
    button.setAttribute('aria-pressed', String(hidden));
    const label = hidden ? side.show : side.hide;
    button.title = label;
    button.setAttribute('aria-label', label);
    // The arrow points to the edge the column goes to when hidden, and away from it when shown.
    button.textContent = (side.key === 'left') === hidden ? '»' : '«';
  };

  apply(stored(side.key));
  button.addEventListener('click', () => {
    const hidden = !document.documentElement.classList.contains(side.hideClass);
    apply(hidden);
    store(side.key, hidden);
  });
  document.body.append(button);
}
