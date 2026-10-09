# Search keywords of the course assistant

## What this is for

The course assistant answers a student's question by ranking the course's sections by their words. A
beginner rarely uses the course's words: they ask "cómo atrapo un error" where the section says
`catch/3`, or "por qué mi programa no termina" where it says "ramas infinitas". To close that gap each
section carries, in advance, the words and questions a student would use to look for it. Those live in
`tools/assistant/keywords.json`, one entry per section, and the index builder adds them to the section
as one more field of the search.

The keywords are written by Claude Code agents, once, and then stored in the repository. Nothing
runs when the site is built in CI or when a student asks a question: the browser reads the stored
words. The skill `assistant-keywords` (in `.claude/skills/assistant-keywords/`) packages the whole
job so that it can be repeated, and `tools/assistant/keywords.py` is the tool it drives.

## When to run it

- **Always build the site first.** The tool reads the site's search index; a stale build gives keywords
  for old text. The first run used a build two days behind the last edits and 312 sections had to be
  redone.

- **After the course changes.** An entry stores a hash of its section; when a section's title or text
  changes, its keywords are out of date and `check` reports it. Refresh only those sections.
- **First run, or a section the assistant misses.** `export` with no options writes everything that
  has no current keywords.
- **A better brief.** To rewrite a scope with different instructions use `export --all --only REGEX`
  (and `--toc` to give every chapter's table of contents to its agent).

## How to use it

In Claude Code, from the repository root:

```text
/assistant-keywords
```

and say what is wanted ("refresh the keywords", "rewrite chapters 1 to 9"). The skill follows these
steps, which can also be run by hand; every command is `uv run --frozen tools/assistant/keywords.py
<command>`:

| Step | Command or action |
| --- | --- |
| 1. Build the site | `make docs` (the tool reads the site's search index) |
| 2. See what is missing | `check`: sections without current keywords, entries whose section is gone |
| 3. Prepare the inputs | `export` (new or changed), `export --all --only REGEX --toc` (rewrite a scope) |
| 4. Write the keywords | agents, one share each, from the briefs in the skill folder; a pilot of two files first |
| 5. Collect them | `merge`: validates, hashes, trims to 20 words and 3 questions, drops stale entries |
| 6. Test them | `blind`: random sections; an agent writes the question a student would ask; `make assistant-evaluate s=<set directory>` scores with and without keywords |
| 7. Commit | the author commits `tools/assistant/keywords.json` |

`--work DIR` changes the work directory (default `.assistant-work/`, git-ignored). `export` refuses to
run while its `out/` holds answers of an earlier export, and `merge` accepts an answer only for the
sections its input file lists, so keywords written for an older text are never stored as current.
`--keywords FILE` changes the file read and written, to try a rewrite in a copy before replacing the
real file.

## Cost and expectations

Agents spend the author's usage limit, so estimate before launching and say so. Measured on this
course (1 762 sections, 4.3 million characters of text):

| Job | Agent tokens |
| --- | --- |
| First run, all sections, text cut at 3 000 characters | 2.5 million |
| Rewrite of Parts I and II with each chapter's table of contents | 1.05 million for 395 sections |
| A refresh after edits | proportional: about 0.8 to 1.5 tokens per character of the sections to redo |

On blind questions (60 sections picked at random, a question written for each by an agent that had not
seen the keywords) the keywords raise recall@5 from 0.62 to 0.77 and the share of questions answered
by the first result from 0.27 to 0.50. They do not reach every question: many questions have several
valid answers and a strict score counts only one. A rewrite with a table of contents per chapter, and
reading beyond 3 000 characters, did not improve the scores measurably, so the plain brief is the
default.

## Rules the work follows

- The briefs avoid examples taken from test questions; a test set is used for one comparison and a new
  one is drawn for the next.
- A hit counts when the result is the target section or the same heading on the sibling page of its
  chapter: a chapter's index page often holds a stub and an extra page the full text.
- Keyword files and work files are not cited from tracked files other than by their role; the work
  directory is scratch space.
- Solutions pages are not indexed and get no keywords.

## Files

| File | Role |
| --- | --- |
| `tools/assistant/keywords.py` | `check`, `export`, `merge`, `blind` |
| `tools/assistant/evaluate.py` | scores the assistant's retrieval on a blind set, in Chromium (`make assistant-evaluate`) |
| `tools/assistant/index_hook.py` | MkDocs hook: writes the assistant's index, with the keywords, when the site is built |
| `tools/assistant/keywords.json` | the stored keywords (versioned) |
| `.claude/skills/assistant-keywords/SKILL.md` | the procedure for Claude Code |
| `.claude/skills/assistant-keywords/brief.md` | brief for the agents that write keywords |
| `.claude/skills/assistant-keywords/brief-contrast.md` | brief for a rewrite with tables of contents |
| `.claude/skills/assistant-keywords/brief-questions.md` | brief for the agent that writes test questions |
