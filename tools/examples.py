"""What every tool in this book needs to know about `ejemplos/`.

An example is a `.pl` file under `ejemplos/<chapter>/`, with its plunit `.plt`
next to it. The `.pl` file is the source of truth: the chapter text never repeats
that code by hand, it declares it with a marker and `sync-examples.py` copies it
in.

The header of the `.pl` file states, in comments, what the book needs to know.
Those markers are in Spanish because they live in the book's own sources, which
the students read:

    :- encoding(utf8).

    % Capitulo 1 - Hechos y reglas.
    % Un arbol genealogico minimo.
    %?- abuelo(juan, Quien).
    %?- padre(Quien, ana).

    padre(juan, ana).

- `%?- <query>` is one of the example's queries. The first one opens the SWISH
  link; every one of them is checked against the SWISH sandbox.
- `% solo-local: <reason>` marks an example that cannot run in SWISH (files,
  threads, user interfaces, compilation). The text then prints the reason
  instead of the link, and the sandbox check skips it.

The header never reaches the text: it explains the file to whoever opens it on
its own, and the chapter already explains the same thing in its own words.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import quote

ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = ROOT / 'ejemplos'
DOCS = ROOT / 'docs'

# The chapter comes from the directory name, with or without a slug after the
# number: ejemplos/capitulo-07/ and docs/capitulo-07-listas/ are both chapter 7.
CHAPTER_DIR = re.compile(r'^capitulo-(\d+)')
# Part I is chapters 1 to 11: no higher-order and no database predicates there.
LAST_OF_PART_1 = 11

QUERY = re.compile(r'^%\?-\s*(?P<query>.+?)\s*$', re.M)
LOCAL_ONLY = re.compile(r'^%\s*solo-local:\s*(?P<reason>.+?)\s*$', re.M)
ENCODING = re.compile(r'^:-\s*encoding\(utf8\)\.\s*$', re.M)

SWISH = 'https://swish.swi-prolog.org/'


@dataclass(frozen=True)
class Example:
    """A `.pl` file under `ejemplos/`, with its tests and whatever its header declares."""

    path: Path
    source: str
    queries: list[str]
    local_only: str | None

    @property
    def name(self) -> str:
        return self.path.stem

    @property
    def relative(self) -> str:
        """Its path as a marker in the text names it: `capitulo-01/familia.pl`."""
        return self.path.relative_to(EXAMPLES).as_posix()

    @property
    def tests(self) -> Path:
        return self.path.with_suffix('.plt')

    @property
    def chapter(self) -> int | None:
        """Its chapter number, or None for anything not under a `capitulo-NN/`."""
        found = CHAPTER_DIR.match(self.path.parent.name)
        return int(found.group(1)) if found else None

    @property
    def in_part_1(self) -> bool:
        return self.chapter is not None and self.chapter <= LAST_OF_PART_1

    @property
    def swish_link(self) -> str | None:
        """The link that opens this example in SWISH with its first query loaded."""
        if self.local_only:
            return None
        return swish_link(self.source, self.queries[0] if self.queries else None)


def swish_link(source: str, query: str | None = None) -> str:
    """Build the SWISH link with the source inlined: nothing has to be hosted.

    The `:- encoding(utf8).` directive does not travel in the link. The file needs
    it, because the local SWI-Prolog on Windows reads sources in the system
    encoding; SWISH has no file to read, the URL is already UTF-8, and one
    directive fewer is one thing fewer for the sandbox to reject.
    """
    parts = ['code=' + quote(ENCODING.sub('', source).lstrip('\n'), safe='')]
    if query:
        parts.append('q=' + quote(query, safe=''))
    return SWISH + '?' + '&'.join(parts)


def read(path: Path) -> Example:
    source = path.read_text(encoding='utf-8')
    local_only = LOCAL_ONLY.search(source)
    return Example(
        path=path,
        source=source,
        queries=[m.group('query') for m in QUERY.finditer(source)],
        local_only=local_only.group('reason') if local_only else None,
    )


def all_examples(wanted: list[str] | None = None) -> list[Example]:
    """Every example under `ejemplos/`, by chapter and name.

    `wanted` filters by example name or by chapter directory, to run just one.
    Appendix A is left out: those are small Python projects driven by pytest, not
    standalone `.pl` examples, and `make apendice` runs them.
    """
    if not EXAMPLES.is_dir():
        return []
    found = [read(path) for path in sorted(EXAMPLES.rglob('*.pl')) if 'apendice-a' not in path.parts]
    if wanted:
        found = [e for e in found if e.name in wanted or e.path.parent.name in wanted]
    return found


def declares_encoding(source: str) -> bool:
    return bool(ENCODING.search(source))


def without_header(source: str) -> str:
    """The source without its encoding directive and its header comment block.

    The header is the first comment block of the file: which chapter it belongs
    to, what it does, and which queries to try. The text already says all that in
    its own words, and the `%?-` lines are not meant to be read. Every other
    comment documents a predicate, and those do belong in the text.
    """
    lines = source.splitlines()
    i = 0
    while i < len(lines) and (not lines[i].strip() or ENCODING.match(lines[i])):
        i += 1
    while i < len(lines) and lines[i].lstrip().startswith('%'):
        i += 1
    while i < len(lines) and not lines[i].strip():
        i += 1
    return '\n'.join(lines[i:]).strip('\n')


# A Prolog source cannot be cut up with regular expressions: the full stop that
# ends a clause may sit inside a comment, a quoted atom or a character code.
# What follows is the least that recognises clauses, which is all the text asks
# for.

OPENING, CLOSING = '([{', ')]}'
QUOTES = '\'"`'
CHAR_CODE = '0' + "'"


def _end_of_quote(source: str, start: int) -> int | None:
    quote_char = source[start]
    i = start + 1
    while i < len(source):
        if source[i] == '\\':
            i += 2
            continue
        if source[i] == quote_char:
            # Two quotes in a row are a quote inside the atom, not its end.
            if source[i + 1 : i + 2] == quote_char:
                i += 2
                continue
            return i
        i += 1
    return None


def _skip(source: str, i: int) -> int | None:
    """Step over whatever is not code: comments, quoted text, character codes.

    Returns the index of the last character stepped over, or `i` itself when real
    code starts there. None when something was left open at end of file.
    """
    n = len(source)
    if source[i] == '%':
        end = source.find('\n', i)
        return n - 1 if end == -1 else end
    if source.startswith('/*', i):
        end = source.find('*/', i + 2)
        return None if end == -1 else end + 1
    if source[i] in QUOTES:
        return _end_of_quote(source, i)
    if source.startswith(CHAR_CODE, i):
        # In a character code the quote is part of the literal and opens nothing.
        # An escape may follow it, as in the code of a newline.
        return min(i + 3, n - 1) if source[i + 2 : i + 3] == '\\' else min(i + 2, n - 1)
    return i


def _end_of_clause(source: str, start: int) -> int | None:
    """Index of the full stop that ends the clause, or None if the file is cut short."""
    i, n = start, len(source)
    while i < n:
        skipped = _skip(source, i)
        if skipped is None:
            return None
        if skipped != i:
            i = skipped + 1
            continue
        # The full stop ends the clause only when a blank or a comment follows:
        # that keeps it apart from the one in 3.14 and from an operator.
        if source[i] == '.' and (i + 1 >= n or source[i + 1] in ' \t\r\n%'):
            return i
        i += 1
    return None


def _head(clause: str) -> tuple[str, bool]:
    """Whatever comes before the neck, and whether this is a grammar rule."""
    i, n, depth = 0, len(clause), 0
    while i < n:
        skipped = _skip(clause, i)
        if skipped is None:
            break
        if skipped != i:
            i = skipped + 1
            continue
        if clause[i] in OPENING:
            depth += 1
        elif clause[i] in CLOSING:
            depth -= 1
        elif depth == 0:
            if clause.startswith('-->', i):
                return clause[:i], True
            if clause.startswith(':-', i):
                return clause[:i], False
        i += 1
    return clause, False


# An atom is a lowercase name, or anything at all between single quotes, where a
# doubled quote stands for one quote.
ATOM = r"[a-z]\w*|'(?:[^']|'')*'"
NAME_AND_ARGS = re.compile(rf'^(?P<name>{ATOM})\s*\(')
NAME_ALONE = re.compile(rf'^(?P<name>{ATOM})\s*$')


def _name_and_arity(head: str) -> tuple[str | None, int]:
    head = head.strip()
    if not head or head.startswith((':-', '?-')):
        return None, 0  # a directive defines no predicate
    found = NAME_AND_ARGS.match(head)
    if not found:
        alone = NAME_ALONE.match(head)
        return (alone.group('name'), 0) if alone else (None, 0)
    i, n, depth, commas = found.end(), len(head), 1, 0
    while i < n and depth:
        skipped = _skip(head, i)
        if skipped is None:
            break
        if skipped != i:
            i = skipped + 1
            continue
        if head[i] in OPENING:
            depth += 1
        elif head[i] in CLOSING:
            depth -= 1
        elif head[i] == ',' and depth == 1:
            commas += 1
        i += 1
    return found.group('name'), commas + 1


@dataclass(frozen=True)
class Clause:
    """One clause of the source, with the comments stuck to it."""

    text: str
    name: str | None
    arity: int
    is_grammar: bool

    @property
    def indicator(self) -> str | None:
        """`padre/2` for a predicate, `oracion//0` for a grammar rule."""
        if self.name is None:
            return None
        # A grammar rule hides the two difference-list arguments, and the student
        # reads oracion//0, which is also how SWI-Prolog counts it.
        slash = '//' if self.is_grammar else '/'
        arity = self.arity - 2 if self.is_grammar else self.arity
        return f'{self.name}{slash}{arity}'


def clauses(source: str) -> list[Clause]:
    """The clauses of the source, in order, each with its comments."""
    found: list[Clause] = []
    i, n = 0, len(source)
    while i < n:
        while i < n and source[i] in ' \t\r\n':
            i += 1
        if i >= n:
            break
        # Comments stuck right above a clause (no blank line in between)
        # document that predicate, and travel into the text with it.
        start = i
        while source.startswith('%', i):
            end_of_line = source.find('\n', i)
            if end_of_line == -1:
                return found
            i = end_of_line + 1
            while i < n and source[i] in ' \t':
                i += 1
        if i < n and source[i] == '\n':
            continue  # a blank line: those comments belong to no clause
        stop = _end_of_clause(source, i)
        if stop is None:
            break
        head, is_grammar = _head(source[i:stop])
        name, arity = _name_and_arity(head)
        found.append(Clause(source[start : stop + 1].rstrip(), name, arity, is_grammar))
        i = stop + 1
    return found


def predicate(source: str, indicators: str) -> str:
    """Every clause of the predicates asked for, in the order of the file.

    `indicators` is one or more name/arity (or name//arity for a grammar rule)
    separated by spaces, as the marker writes them: `predicado: padre/2 abuelo/2`.
    """
    wanted = indicators.split()
    every = clauses(source)
    known = {c.indicator for c in every if c.indicator}
    missing = [w for w in wanted if w not in known]
    if missing:
        raise KeyError('does not define {} (it defines {})'.format(', '.join(missing), ', '.join(sorted(known))))
    return '\n\n'.join('\n'.join(c.text for c in every if c.indicator == w) for w in wanted)


def excerpt(source: str, span: str) -> str:
    """The lines from the first one containing A to the first one containing B (`A .. B`)."""
    first, _, last = (x.strip() for x in span.partition('..'))
    lines = source.splitlines()
    start = next((i for i, line in enumerate(lines) if first in line), None)
    if start is None:
        raise KeyError(f'no line contains {first!r}')
    stop = next((i for i, line in enumerate(lines[start:], start) if last in line), None)
    if stop is None:
        raise KeyError(f'no line after {first!r} contains {last!r}')
    return '\n'.join(lines[start : stop + 1]).rstrip()


def without_comments(source: str) -> str:
    """The source with comments and quoted text blanked out.

    Length and line breaks are preserved, so line numbers still hold. It is what
    any check needs when it looks for calls to a predicate without tripping over
    the same word written in a comment or inside an atom.
    """
    out = list(source)
    i, n = 0, len(source)
    while i < n:
        skipped = _skip(source, i)
        if skipped is None:
            skipped = n - 1
        if skipped != i:
            for j in range(i, min(skipped + 1, n)):
                if out[j] != '\n':
                    out[j] = ' '
            i = skipped + 1
            continue
        i += 1
    return ''.join(out)


# How the text declares a block of code that comes from an example. The marker is
# in Spanish because it lives in the book's own sources:
#
#     <!-- ejemplo: capitulo-01/familia.pl predicado: abuelo/2 -->
#     ```prolog
#     ...what sync-examples.py writes...
#     ```
#
# sync-examples.py fills the body from the file; the swish_links hook puts the
# SWISH link underneath when the site is built.
MARKER = re.compile(
    r'^<!-- ejemplo: (?P<file>[\w./-]+)(?: (?P<piece>[^>]*?))? -->\n'
    r'```(?P<language>\w*)\n(?P<body>.*?)^```$',
    re.M | re.S,
)


# The tail of a marker, after the file name, carries the piece to copy and up to
# two named fields:
#
#     <!-- ejemplo: capitulo-01/familia.pl predicado: abuelo/2 consulta: abuelo(juan, Q). -->
#
# `consulta:` overrides which query the SWISH link opens with, which matters when
# several sections of a chapter show pieces of the same file and each one wants
# to be tried a different way. Without it the link uses the first `%?-` of the
# example. `aviso:` opens the block with a comment, for code shown to be
# criticised.
MARKER_FIELDS = re.compile(r'\b(consulta|aviso):')


def marker_parts(tail: str | None) -> dict[str, str | None]:
    """The tail of a marker as {'pieza', 'consulta', 'aviso'}."""
    parts: dict[str, str | None] = {'pieza': '', 'consulta': None, 'aviso': None}
    if not tail:
        return parts
    split = MARKER_FIELDS.split(tail)
    parts['pieza'] = split[0].strip()
    for key, value in zip(split[1::2], split[2::2], strict=False):
        parts[key] = value.strip()
    return parts
