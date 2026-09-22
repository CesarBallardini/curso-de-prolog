// KaTeX typesets the logic formulas of chapter 11. Material re-renders the page
// body on every navigation, so this subscribes instead of running once on load;
// otherwise the formulas would only appear after a full page reload.
//
// The delimiters are the ones arithmatex emits with `generic: true`. Note the
// doubled backslashes: in a JavaScript string "\\[" is the two characters \[,
// which is what has to be matched. Writing "\[" would leave a bare [ and make
// KaTeX typeset every bracket and parenthesis on the page, including the ones
// in the navigation menu.
document$.subscribe(({ body }) => {
  renderMathInElement(body, {
    delimiters: [
      { left: "$$", right: "$$", display: true },
      { left: "$", right: "$", display: false },
      { left: "\\[", right: "\\]", display: true },
      { left: "\\(", right: "\\)", display: false },
    ],
    // Only the article: the navigation and the table of contents hold chapter
    // titles with parentheses, and there is no math in them.
    ignoredClasses: ["md-nav", "md-header", "md-footer"],
    // A formula that fails to parse is shown as its source in red rather than
    // silently disappearing, so the mistake is visible while writing.
    throwOnError: false,
  });
});
