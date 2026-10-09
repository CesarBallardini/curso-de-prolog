"""The KaTeX side of the PDF build: the tags to inject and how to wait for them.

Kept apart from `md2pdf.py` so the mermaid and the KaTeX arrangements read as
two independent things, which is what they are: a chapter may have diagrams,
formulas, both or neither.

KaTeX is vendored in docs/vendor/ (tools/vendor.toml pins it), the same files
the site serves, so a PDF never depends on a CDN. The page that becomes the PDF is built
with `set_content()` and has no base URL, so a relative link to those files
would load nothing: the script and the stylesheet are inlined, and the fonts go
into the stylesheet as data: URIs.

The version is pinned in tools/vendor.toml: another release could change the
spacing of every formula in the book between one PDF build and the next.
"""

import base64
import re

import vendor

DIR = vendor.library_directory('katex')
SCRIPT = DIR / 'katex.min.js'


def inline_fonts(css):
    """The stylesheet with each woff2 font embedded; the other formats are fallbacks never loaded."""

    def embed(match):
        data = base64.b64encode((DIR / 'fonts' / match.group(1)).read_bytes()).decode()
        return f'url(data:font/woff2;base64,{data})'

    return re.sub(r'url\(fonts/([^)]+\.woff2)\)', embed, css)


# KaTeX renders synchronously, so unlike mermaid there is nothing to poll for:
# once `renderMathInElement` returns, the formulas are in the page. What does
# have to be waited for is the CSS and its fonts, and `wait_until='networkidle'`
# already covers that. The flag is set all the same, so the wait below can tell
# "typeset" from "the script never ran".
TAGS = f"""<style>{inline_fonts((DIR / 'katex.min.css').read_text(encoding='utf-8'))}</style>
<script>{SCRIPT.read_text(encoding='utf-8')}</script>
<script>{(DIR / 'contrib' / 'auto-render.min.js').read_text(encoding='utf-8')}</script>
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
