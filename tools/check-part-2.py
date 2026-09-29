#!/usr/bin/env python
"""Check that parts II and III never use a predicate before the chapter that presents it.

The book declares what each chapter teaches in its `## Resumen` table and its section
headings (see `taught.py`). For every written chapter from 13 on, the prolog code blocks
of the chapter and its solutions, and the `.pl` and `.plt` files under
`ejemplos/capitulo-NN/`, are scanned for calls. A call to a name that

  - the chapter itself defines is fine;
  - a chapter up to and including this one presents is fine;
  - a later chapter presents is fine only as an announced forward reference: the page
    links that chapter (`capitulo-NN-`), or the `.pl` file names it («capítulo NN»);
    otherwise it is an error, because the text jumps ahead;
  - no chapter presents, and SWI-Prolog knows as a predicate, is a warning: the book uses
    it without ever presenting it (`--strict` turns the warnings into errors).

Test files (`.plt`) may use what the book has not taught: their forward uses are reported
as warnings, never as errors. A name that no chapter presents and SWI-Prolog does not know
is a data functor (`estado(...)`) or a local helper, and is ignored.

    ./tools/check-part-2.py [--strict] [capitulo-17 ...]
"""

import re
import sys

import examples
import taught

# Vocabulary that is not a predicate call, or that every chapter may use.
IGNORE = {
    # directives and their arguments
    'module', 'use_module', 'ensure_loaded', 'library', 'dynamic', 'discontiguous', 'multifile',
    'initialization', 'encoding', 'set_prolog_flag', 'op', 'table', 'meta_predicate', 'reexport',
    'autoload', 'include', 'if', 'elif', 'else', 'endif',
    # plunit
    'begin_tests', 'end_tests', 'test', 'run_tests', 'load_test_files', 'all', 'set', 'true', 'fail',
    'throws', 'setup', 'cleanup', 'nondet', 'blocked', 'fixme', 'condition', 'forall', 'error',
    'timeout', 'occurs_check',
    # aggregate_all/3 specifications, which look like calls
    'count', 'sum', 'max', 'min', 'bag',
    # error terms and control that part I already uses in transcripts
    'type_error', 'domain_error', 'existence_error', 'instantiation_error', 'permission_error',
    'evaluation_error', 'representation_error', 'resource_error', 'syntax_error', 'context',
    'catch', 'throw', 'call', 'not',
}  # fmt: skip
CODE_BLOCK = re.compile(r'^```prolog\n(?P<code>.*?)^```', re.M | re.S)


def calls(code: str) -> set[tuple[str, int | None]]:
    """(name, number of arguments) of every `name(` in the code; None when it cannot be counted."""
    plain = examples.without_comments(code)
    return {(m.group(1), argument_count(plain, m.end() - 1)) for m in taught.CALL.finditer(plain)}


def argument_count(code: str, open_paren: int) -> int | None:
    """The number of arguments of the compound whose `(` is at open_paren (quotes already blank)."""
    depth, commas = 0, 0
    for i in range(open_paren, len(code)):
        c = code[i]
        if c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
            if depth == 0:
                return 0 if not code[open_paren + 1 : i].strip() else commas + 1
        elif c == ',' and depth == 1:
            commas += 1
    return None


def defined(code: str) -> set[str]:
    return {c.name for c in examples.clauses(code) if c.name}


def chapter_sources(chapter: int, index):
    """(where, code, whole text) for every prolog source of a chapter: pages and files."""
    for page in (index, index.with_name('soluciones.md')):
        if page.exists():
            text = page.read_text(encoding='utf-8')
            for block in CODE_BLOCK.finditer(text):
                yield page, block.group('code'), text
    for path in sorted(examples.EXAMPLES.glob(f'capitulo-{chapter:02d}/**/*.pl*')):
        if path.suffix in ('.pl', '.plt'):
            text = path.read_text(encoding='utf-8')
            yield path, text, text


def announced(text: str, chapter: int) -> bool:
    """Whether a page or a file announces the chapter that presents a name."""
    return f'capitulo-{chapter:02d}-' in text or re.search(rf'[Cc]ap[ií]tulo {chapter}\b', text) is not None


def used_names(code: str, local: set[str], declared_arities: dict[str, set[int]]) -> list[str]:
    """The names the code calls that the check is about: not local, not ignored, and called
    with an arity the book declares for them (another arity is another functor, such as the
    option functor(alumno))."""
    names = set()
    for name, arity in calls(code):
        if name in local or name in IGNORE:
            continue
        if arity is not None and name in declared_arities and arity not in declared_arities[name]:
            continue
        names.add(name)
    return sorted(names)


def main() -> int:
    strict = '--strict' in sys.argv
    wanted = [a for a in sys.argv[1:] if not a.startswith('--')]
    first = taught.taught_by()
    declared_arities = taught.arities()
    errors, warnings = set(), set()
    unknown: dict[int, dict[str, set]] = {}
    for chapter, index in taught.chapter_pages():
        if chapter <= examples.LAST_OF_PART_1:
            continue
        if wanted and not any(w in index.parent.name for w in wanted):
            continue
        sources = list(chapter_sources(chapter, index))
        local = set().union(*(defined(code) for _, code, _ in sources)) if sources else set()
        for where, code, text in sources:
            rel = where.relative_to(examples.ROOT).as_posix()
            for name in used_names(code, local, declared_arities):
                taught_in = first.get(name)
                if taught_in is None:
                    unknown.setdefault(chapter, {}).setdefault(name, set()).add(rel)
                elif taught_in > chapter and not announced(text, taught_in):
                    message = f'{rel}: {name} is presented in chapter {taught_in}, after chapter {chapter}'
                    (warnings if where.suffix == '.plt' else errors).add(message)
    known = taught.in_swi({n for names in unknown.values() for n in names})
    for chapter, names in sorted(unknown.items()):
        for name, files in sorted(names.items()):
            if name in known:
                warnings.add(
                    f'chapter {chapter}: {name} is used ({", ".join(sorted(files))}) and no chapter presents it'
                )
    for line in sorted(errors):
        print(f'error: {line}')
    for line in sorted(warnings):
        print(f'warning: {line}')
    if errors or (strict and warnings):
        return 1
    print(f'Parts II and III use nothing before the chapter that presents it ({len(warnings)} warnings).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
