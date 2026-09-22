"""The KaTeX side of the PDF build: the tags to inject and how to wait for them.

Kept apart from `md2pdf.py` so the mermaid and the KaTeX arrangements read as
two independent things, which is what they are: a chapter may have diagrams,
formulas, both or neither.

The version is pinned. An unpinned `katex@0` would let a future release change
the spacing of every formula in the book between one PDF build and the next.
"""

VERSION = '0.16.11'
BASE = f'https://cdn.jsdelivr.net/npm/katex@{VERSION}/dist'

# KaTeX renders synchronously, so unlike mermaid there is nothing to poll for:
# once `renderMathInElement` returns, the formulas are in the page. What does
# have to be waited for is the CSS and its fonts, and `wait_until='networkidle'`
# already covers that. The flag is set all the same, so the wait below can tell
# "typeset" from "the script never arrived".
TAGS = f"""<link rel="stylesheet" href="{BASE}/katex.min.css">
<script defer src="{BASE}/katex.min.js"></script>
<script defer src="{BASE}/contrib/auto-render.min.js"></script>
<script>
  window.addEventListener('DOMContentLoaded', () => {{
    renderMathInElement(document.body, {{
      delimiters: [
        {{ left: '$$', right: '$$', display: true }},
        {{ left: '$', right: '$', display: false }},
        {{ left: '\\\\[', right: '\\\\]', display: true }},
        {{ left: '\\\\(', right: '\\\\)', display: false }},
      ],
      throwOnError: false,
    }});
    window.__katexDone = true;
  }});
</script>"""

TYPESET = '() => window.__katexDone === true'


def has_formulas(body):
    """True when the rendered body carries math for KaTeX to typeset."""
    return r'\(' in body or r'\[' in body
