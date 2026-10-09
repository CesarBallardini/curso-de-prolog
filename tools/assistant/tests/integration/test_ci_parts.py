"""Integration test of tools/ci-parts.py: a change to the course assistant selects no chapter."""

import importlib.util
from typing import Protocol, cast

import pytest
import sections as course

CHAPTERS = set(range(1, 88))


class CiParts(Protocol):
    """The part of tools/ci-parts.py this test uses."""

    def select(self, files: list[str] | None, known: set[int]) -> tuple[set[int], str]: ...


@pytest.fixture(scope='module')
def ci_parts() -> CiParts:
    """tools/ci-parts.py, loaded from its file: its name has a hyphen, so it cannot be imported."""
    spec = importlib.util.spec_from_file_location('ci_parts', course.ROOT / 'tools' / 'ci-parts.py')
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return cast('CiParts', module)


@pytest.mark.parametrize(
    'path',
    [
        'tools/assistant/keywords.py',
        'tools/assistant/keywords.json',
        'tools/assistant/tests/acceptance/features/asking.feature',
        'docs/javascripts/assistant/panel.js',
        'docs/asistente.md',
    ],
)
def test_a_change_to_the_assistant_selects_no_chapter(ci_parts: CiParts, path: str) -> None:
    chapters, _ = ci_parts.select([path], CHAPTERS)
    assert chapters == set()


def test_a_change_to_another_tool_selects_every_chapter(ci_parts: CiParts) -> None:
    chapters, _ = ci_parts.select(['tools/md2pdf.py'], CHAPTERS)
    assert chapters == CHAPTERS
