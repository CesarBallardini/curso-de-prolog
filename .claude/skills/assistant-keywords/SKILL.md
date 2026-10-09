---
name: assistant-keywords
description: Create, refresh or rewrite tools/assistant/keywords.json, the search keywords of the course assistant (the words and questions a student would use for each section), with Claude Code agents, and test them on blind questions. Use when the course text changed, when the assistant misses questions, or for a similar job that gives each chunk of a large text to an agent.
---

# Search keywords of the course assistant

The assistant ranks the course's sections by their words. A beginner asks with other words ("atrapar
un error" for a section on `catch/3`), so each section gets, once and in advance, the words and
questions a student would use. Agents write them; `tools/assistant/keywords.py` prepares the inputs,
validates and stores the answers; the index builder adds them to each section as one more field.
Nothing runs in CI or in the student's browser: they read `tools/assistant/keywords.json`, which is
versioned (the author commits it).

Read the output of `tools/assistant/keywords.py --help` and its docstring first: they are the
reference of the commands. Python always goes through `uv run --frozen`.

## 0. Before anything

1. `make docs` (the tool reads `site/search/search_index.json`). **Always rebuild first**: the first run was
   made from a build two days older than the last edits, and 312 sections (18%) had to be redone.
2. `uv run --frozen tools/assistant/keywords.py check` tells how many sections lack current keywords
   (a section whose title or text changed counts as lacking) and how many entries have no section.
3. Decide the job:
   - **Refresh** after the course changed: `export` alone writes only the new or changed sections.
   - **Rewrite** a scope with a better brief: `export --all --only REGEX [--toc]`.
   - **First run**: `export` writes everything.

The work directory (`--work`, default `.assistant-work/`, git-ignored) holds `in/`, `out/` and the blind
sets. `export` refuses to run while `out/` holds answers: merge them first, or remove them. `merge`
accepts an answer only for the sections its own input file lists, so answers written for older text
are never stored as current. Tracked files never name a plan file or the repository's scratch notes.

## 1. Export

```bash
uv run --frozen tools/assistant/keywords.py export                     # new/changed, files of ~40 KB, text cut at 3 000 characters
uv run --frozen tools/assistant/keywords.py export --toc --all --only '^capitulo-0[1-9]-'
```

`--toc` writes one file per chapter (all its pages) with the chapter's table of contents first and the
text up to 8 000 characters; use it when neighbouring sections must be told apart. The tool prints a
suggested split among agents (about 150 000 characters each by default; `--agent-chars` changes it).
Sections of the solutions pages are never indexed. Empty entries (Ejercicios, Objetivos, Resumen,
Temas que se retoman, Referencias, tables of links) stay empty on purpose: the ranking weighs them
down.

## 2. Launch the agents

Briefs next to this file; the agent reads one and the input files named in the task:

| Brief | For |
| --- | --- |
| `brief.md` | the first run and refreshes: words and questions from the section's text |
| `brief-contrast.md` | a rewrite with `export --toc`: words that tell a section from its neighbours |
| `brief-questions.md` | the blind question writer (section 4) |

1. **Pilot first**: one agent, two input files. Check the JSON parses, every section is there, and read
   ten entries. Fix the brief, then fan out. The pilot of the first run took about 2 minutes.
2. **Fan out**: one `Agent` per share, `subagent_type: general-purpose`, `model: sonnet`,
   `run_in_background: true`, all in one message. Prompt template (fill the braces):

   > Working directory: {repository root}. Read {brief path} first and follow it exactly. Your input
   > files in {work}/in/ are, in this order: {files}. For each, write the matching .json in
   > {work}/out/ right after finishing that input file. Keep your notes in {work}/notes-{first
   > file}.md (one line per file written; resume after the last one). When all are written, check
   > that each JSON parses and has an entry for every section of its input (a short
   > `uv run --frozen python -c` script). Reply with the number of sections per file and anything you
   > had to guess.

3. Agents report on their own; do not poll. Do not message a running agent.
4. Cost, measured: the first run (1 762 sections, 3.24 M characters, 11 agents) cost **2.5 M agent
   tokens**, about 0.8 token per character of input. Estimate a job before launching it and tell the
   author; they watch their usage limit.

Lessons that cost time:

- Agents shortcut: one read only the first 450 characters of each section, several trimmed their lists
  to the word limit by cutting the tail (the predicate names), several padded short entries.
  The briefs say "read the whole text"; still compare agents' entries before merging.
- The brief's examples leak into the evaluation. Never take an example from a question you will test
  with; use topics outside every test set.
- Agents write helper scripts to the shared temporary directory and overwrite each other's: tell them to
  use their own scratchpad (the tool message of the harness names it).
- A JSON string needs `\\` for a backslash (`"\\+"`); the briefs say so. In Git Bash a heredoc
  collapses doubled backslashes: write scripts with the Write/Edit tools, not with `cat <<EOF`.
- A local model was tried and dropped (Ollama `gpt-oss:20b`, about 22 s per section on the author's
  CPU: 11 hours). If a background job is ever stopped with `TaskStop`, check that its Python child
  died too (list processes, stop by PID); one kept running and overwrote the keywords file.

## 3. Merge

```bash
uv run --frozen tools/assistant/keywords.py merge
```

It validates every `out/*.json` (valid JSON, known sections, lists `words` and `questions`), stores
the entries with the hash of their section, trims to 20 words and 3 questions, drops entries of
sections that no longer exist, and prints how many sections still lack keywords. Exit 1 on problems:
fix the file or ask the agent again. To try a rewrite without touching the real file, copy it and
merge into the copy: `merge --work <dir> --keywords <copy>`.

## 4. Test on blind questions

A change to keywords is kept only if it wins on questions nobody tuned for.

```bash
uv run --frozen tools/assistant/keywords.py blind --count 60 --seed 7 --only '^capitulo-' --exclude <earlier truth.json>
```

It writes `in.txt` (id, style, title, text of random sections) and `truth.json` (id to location) in a
subdirectory of the work directory. Give `in.txt` to **one agent that has seen neither the keywords nor
any brief but `brief-questions.md`**, which writes `out.json` (id to query). Rules that make the
numbers mean something:

- Each set is used once to compare; do not read its misses and then edit the brief for them. If you
  must look at misses, draw a new set for the next comparison (new seed, `--exclude` the old ones).
- Score with and without keywords, and with a few keyword weights fixed beforehand; choose the weight
  by the whole set, not the best of many tries.
- A hit is the target section **or the same heading on the sibling page** of its chapter (the index
  page holds a stub, an extra page the full text; same chapter, same heading slug without its number
  and without a trailing `_N`). Report recall@1, @3, @5 and MRR, by part of the course.
- Questions written from a text cut at 3 000 characters cannot test the part beyond the cut.
- 60 questions give about plus or minus 0.1 on a rate: do not read differences smaller than that.
- Score with `make assistant-evaluate s=<set directory> [k=<keywords file>]` (`tools/assistant/evaluate.py`):
  it runs the production retrieval module in headless Chromium over the site's index, so the numbers are
  the widget's. `k=` tries another keywords file (a rewrite) without touching the real one; it needs
  the site built (`make docs`) and `out.json` written by the question writer.

Results so far (first run, 60-question blind set): recall@5 0.62 and MRR 0.42 without keywords,
0.77 and 0.61 with them (weight 2); Parts I-II about 0.80. Three things that did not help
measurably: reading beyond 3 000 characters (an 18-question trial), a heading bonus in the ranking,
and rewriting Parts I-II with `brief-contrast.md` (395 sections, 1.05 M agent tokens; pooled 83
questions: recall@1 0.53 to 0.58, recall@5 0.80 to 0.78, MRR 0.63 to 0.67). The plain `brief.md` is
the default.

## 5. Finish

1. `make docs` rebuilds the assistant's index (a MkDocs hook embeds the keywords; the build log says how
   many sections have outdated ones), then `make assistant-test` runs the assistant's tests.
2. `make lint` after touching `tools/*.py`.
3. Hand the author the commit commands (`tools/assistant/keywords.json`, and the tool if it changed);
   they perform every git command. Report counts, cost in tokens and the blind-set numbers, in
   descriptive language.
