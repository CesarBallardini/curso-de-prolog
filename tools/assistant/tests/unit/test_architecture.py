"""The dependency rule of the assistant's JavaScript (docs/javascripts/assistant/).

The domain depends on nothing: its modules import only other modules of domain/ and name none of the
browser's objects. The application depends on the domain only. The adapters and the two composition
roots (panel.js, worker.js) depend on whatever they need. Type-only imports in JSDoc count too.
"""

import re
from typing import TYPE_CHECKING

import pytest
import sections as course

if TYPE_CHECKING:
    from pathlib import Path

ASSISTANT = course.ROOT / 'docs' / 'javascripts' / 'assistant'
LAYERS = {'domain': {'domain'}, 'application': {'domain', 'application'}}
IMPORT = re.compile(r"""(?:\bfrom\s+|\bimport\s*\(\s*|\bimport\s+)['"]([^'"]+)['"]""")
# The browser's objects, as names of their own (not a property: `.document` is someone's field).
# `location` is not listed: a section's location is the domain's own word.
BROWSER = re.compile(
    r'(?<![.\w$])(document|window|self|globalThis|fetch|sessionStorage|localStorage|navigator|'
    r'LanguageModel|Worker|postMessage|XMLHttpRequest|HTMLElement|Element)\b'
)
COMMENTS = re.compile(r'/\*.*?\*/|//[^\n]*', re.S)
STRINGS = re.compile(r"""'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*"|`(?:\\.|[^`\\])*`""", re.S)


def modules(layer: str) -> list[Path]:
    return sorted((ASSISTANT / layer).glob('*.js'))


def imported_layers(module: Path) -> set[str]:
    """The top directories of assistant/ that a module imports from, in code or in JSDoc types."""
    layers: set[str] = set()
    for target in IMPORT.findall(module.read_text(encoding='utf-8')):
        if not target.startswith('.'):
            layers.add(f'outside: {target}')
            continue
        resolved = (module.parent / target).resolve()
        try:
            layers.add(resolved.relative_to(ASSISTANT).parts[0])
        except ValueError:
            layers.add(f'outside: {target}')
    return layers


def browser_names(module: Path) -> set[str]:
    """The browser's objects a module's code names; comments and strings do not count."""
    code = STRINGS.sub('""', COMMENTS.sub('', module.read_text(encoding='utf-8')))
    return set(BROWSER.findall(code))


@pytest.mark.parametrize('layer', sorted(LAYERS))
def test_each_layer_has_modules(layer: str) -> None:
    assert modules(layer)


@pytest.mark.parametrize(('layer', 'module'), [(layer, m) for layer in LAYERS for m in modules(layer)], ids=str)
def test_a_layer_imports_only_what_it_may(layer: str, module: Path) -> None:
    assert imported_layers(module) <= LAYERS[layer]


@pytest.mark.parametrize(('layer', 'module'), [(layer, m) for layer in LAYERS for m in modules(layer)], ids=str)
def test_the_inner_layers_do_not_touch_the_browser(layer: str, module: Path) -> None:
    assert browser_names(module) == set()


def test_the_rule_catches_an_import_from_an_adapter(tmp_path: Path) -> None:
    module = ASSISTANT / 'domain' / 'probe.js'
    probe = tmp_path / 'probe.js'
    probe.write_text("import { x } from '../adapters/session-store.js';\nconst y = fetch('a');\n", encoding='utf-8')
    text = probe.read_text(encoding='utf-8')
    assert {target for target in IMPORT.findall(text)} == {'../adapters/session-store.js'}
    assert (module.parent / '../adapters/session-store.js').resolve().relative_to(ASSISTANT).parts[0] == 'adapters'
    assert browser_names(probe) == {'fetch'}
