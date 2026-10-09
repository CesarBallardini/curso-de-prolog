#!/usr/bin/env python
"""Draw every mermaid diagram of the built site in headless Chromium and check the result.

    uv run tools/check-mermaid.py                       the site in site/ (make docs first)
    uv run tools/check-mermaid.py capitulo-05           only the pages whose path has that text
    uv run tools/check-mermaid.py --site DIR            another build directory
    uv run tools/check-mermaid.py --shots DIR           also save a PNG of every diagram

The site is served over HTTP from a thread of this script, and each page that has a
```mermaid block is loaded the way a reader loads it: Material draws each diagram, with
the mermaid the site vendors (docs/vendor/), into a shadow root. That root is closed, so an init script
opens it before the page runs; nothing else of the page is touched.

A diagram FAILS when mermaid could not draw it (the block is left as text, or the SVG is
mermaid's error picture), when the SVG has no size, or when a label shows `<br/>` or an
HTML entity literally. It gets a WARNING for the defects that raise no error: a label
wider than its box (clipped), nodes drawn on top of each other, or a diagram scaled down
so far that its text is hard to read. Each diagram is reported as the file:line of its block in docs/, matched
by order on the page. Console errors of a page are reported with the page.

Needs Chromium (`make browser`), not the network. Exits 1 if any diagram fails.
"""

import argparse
import functools
import re
import sys
import threading
import time
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs'
FENCE = re.compile(r'^\s*```mermaid\s*$')

OPEN_SHADOW = """
const attach = Element.prototype.attachShadow;
Element.prototype.attachShadow = function (init) {
  return attach.call(this, Object.assign({}, init, { mode: 'open' }));
};
"""

# One record per diagram, in the order of the page. A block mermaid could not draw is
# still a <pre class="mermaid">; a drawn one is a <div class="mermaid"> whose shadow root
# holds the SVG.
INSPECT = """
() => Array.from(document.querySelectorAll('pre.mermaid, div.mermaid')).map((host) => {
  const r = { drawn: host.tagName === 'DIV', problems: [] };
  if (!r.drawn) return r;
  const svg = host.shadowRoot && host.shadowRoot.querySelector('svg');
  if (!svg) { r.drawn = false; return r; }
  const box = svg.getBoundingClientRect();
  r.width = Math.round(box.width);
  r.height = Math.round(box.height);
  r.error = svg.getAttribute('aria-roledescription') === 'error'
    || /Syntax error in text/.test(svg.textContent);
  const vb = svg.viewBox && svg.viewBox.baseVal;
  if (vb && vb.width) r.scale = box.width / vb.width;
  const labels = svg.querySelectorAll('foreignObject, text');
  const seen = new Set();
  for (const label of labels) {
    const text = label.textContent;
    const raw = text.match(/<br\\s*\\/?>|&(?:[a-z]+|#\\d+);/i);
    if (raw && !seen.has(raw[0])) {
      seen.add(raw[0]);
      r.problems.push('literal ' + raw[0] + ' in «' + text.trim() + '»');
    }
    if (label.tagName.toLowerCase() !== 'foreignobject') continue;
    const inner = label.firstElementChild;
    if (!inner) continue;
    const outer = label.getBoundingClientRect();
    for (const span of inner.querySelectorAll('span, p')) {
      const s = span.getBoundingClientRect();
      const over = Math.max(s.right - outer.right, s.bottom - outer.bottom);
      if (s.width && over > 6) {
        r.problems.push('label clipped by ' + Math.round(over) + ' px: «' + text.trim().slice(0, 60) + '»');
        break;
      }
    }
  }
  const nodes = Array.from(svg.querySelectorAll('g.node')).map((n) => n.getBoundingClientRect())
    .filter((b) => b.width > 0);
  let overlaps = 0;
  for (let i = 0; i < nodes.length; i++) for (let j = i + 1; j < nodes.length; j++) {
    const a = nodes[i], b = nodes[j];
    const w = Math.min(a.right, b.right) - Math.max(a.left, b.left);
    const h = Math.min(a.bottom, b.bottom) - Math.max(a.top, b.top);
    if (w > 4 && h > 4) overlaps++;
  }
  if (overlaps) r.problems.push(overlaps + ' pair(s) of nodes overlap');
  return r;
})
"""

# Failed requests are reported by URL from the responses, so the console's own line for
# them, which has no URL, is left out; and so is the repository widget asking GitHub for
# a latest release the repository does not have.
LOAD_FAILED = 'Failed to load resource'
LATEST = 'api.github.com/repos/'

PENDING = "() => document.querySelectorAll('pre.mermaid').length"


def source_of(page, site):
    """The Markdown file a built page comes from, and the lines of its mermaid blocks."""
    rel = page.parent.relative_to(site)
    for candidate in (DOCS / rel / 'index.md', DOCS / f'{rel}.md'):
        if candidate.exists():
            lines = candidate.read_text(encoding='utf-8').splitlines()
            return candidate.relative_to(ROOT).as_posix(), [n for n, t in enumerate(lines, 1) if FENCE.match(t)]
    return rel.as_posix(), []


def serve(site):
    class Quiet(SimpleHTTPRequestHandler):
        def log_message(self, *args):
            pass

    handler = functools.partial(Quiet, directory=str(site))
    server = ThreadingHTTPServer(('127.0.0.1', 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


def wait_drawn(page, timeout=40.0, settle=6.0):
    """Wait until every block is drawn, or until the count of undrawn ones stops changing."""
    start = last_change = time.monotonic()
    last = page.evaluate(PENDING)
    while last and time.monotonic() - start < timeout:
        time.sleep(0.5)
        now = page.evaluate(PENDING)
        if now != last:
            last, last_change = now, time.monotonic()
        elif time.monotonic() - last_change > settle:
            break


def verdict(d):
    """FAIL reason (or None) and the warnings of one diagram record."""
    if not d['drawn']:
        return 'not drawn: mermaid rejected the block (see the console errors)', []
    if d['error']:
        return 'mermaid drew its «Syntax error» picture', []
    if d['width'] < 20 or d['height'] < 20:
        return f'SVG of {d["width"]}×{d["height"]} px', []
    raw = [p for p in d['problems'] if p.startswith('literal')]
    if raw:
        return '; '.join(raw), []
    warnings = list(d['problems'])
    if d.get('scale') and d['scale'] < 0.45:
        warnings.append(f'scaled to {d["scale"]:.0%}: text hard to read')
    return None, warnings


def check_page(browser, base, site, page_path, shots):
    source, lines = source_of(page_path, site)
    url = base + page_path.relative_to(site).as_posix()
    page = browser.new_page(viewport={'width': 1280, 'height': 900})
    page.add_init_script(OPEN_SHADOW)
    console = []
    page.on('console', lambda m: m.type == 'error' and not m.text.startswith(LOAD_FAILED) and console.append(m.text))
    page.on('pageerror', lambda e: console.append(str(e)))

    def failed_request(response):
        if response.status >= 400 and LATEST not in response.url:
            console.append(f'HTTP {response.status} {response.url}')

    page.on('response', failed_request)
    page.goto(url, wait_until='networkidle')
    wait_drawn(page)
    diagrams = page.evaluate(INSPECT)
    # The header and the tabs stay fixed on top while scrolling and would cover the top
    # of a tall diagram in its picture.
    page.add_style_tag(content='.md-header, .md-tabs { display: none !important; }')
    failures = 0
    if len(diagrams) != len(lines):
        print(f'WARNING {source}: {len(lines)} blocks in the source, {len(diagrams)} on the page')
    hosts = page.locator('pre.mermaid, div.mermaid')
    for k, d in enumerate(diagrams):
        where = f'{source}:{lines[k]}' if k < len(lines) else f'{source} #{k + 1}'
        reason, warnings = verdict(d)
        if shots:
            name = f'{source.removeprefix("docs/").removesuffix(".md").replace("/", "--")}-{k + 1:02d}.png'
            hosts.nth(k).screenshot(path=shots / name)
        if reason:
            failures += 1
            print(f'FAIL    {where}: {reason}')
        else:
            print(f'ok      {where} ({d["width"]}×{d["height"]}, {d.get("scale") or 1:.0%})')
        for w in warnings:
            print(f'WARNING {where}: {w}')
    for message in console:
        print(f'CONSOLE {source}: {message.splitlines()[0][:200]}')
    page.close()
    return len(diagrams), failures


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('filter', nargs='?', default='', help='only pages whose path contains this text')
    parser.add_argument('--site', type=Path, default=ROOT / 'site', help='the built site (default: site/)')
    parser.add_argument('--shots', type=Path, help='save a PNG of every diagram in this directory')
    args = parser.parse_args()
    sys.stdout.reconfigure(encoding='utf-8')
    site = args.site.resolve()
    pages = sorted(
        p
        for p in site.rglob('*.html')
        if args.filter in p.relative_to(site).as_posix() and 'class="mermaid"' in p.read_text(encoding='utf-8')
    )
    if not pages:
        sys.exit(f'no page with a mermaid diagram under {site} (build the site first: make docs)')
    if args.shots:
        args.shots.mkdir(parents=True, exist_ok=True)
    server = serve(site)
    base = f'http://127.0.0.1:{server.server_address[1]}/'
    total = failures = 0
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch()
        for page_path in pages:
            n, f = check_page(browser, base, site, page_path, args.shots)
            total, failures = total + n, failures + f
        browser.close()
    server.shutdown()
    print(f'{total} diagrams in {len(pages)} pages, {failures} failed')
    sys.exit(1 if failures else 0)


if __name__ == '__main__':
    main()
