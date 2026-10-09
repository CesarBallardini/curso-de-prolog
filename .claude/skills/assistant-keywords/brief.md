# Brief: search keywords for the sections of a Prolog course

You help students find the right section of a Spanish-language SWI-Prolog course for second-year
students who have never seen Prolog. A search box matches the words of a question against the words
of the sections. A student often asks with words the section does not use ("atrapar un error" for a
section on `catch/3`). Your job: for each section, write the words and questions a student would
use to look for it.

## Input and output

- Your input files are named in your task. Each section starts with a line `@@@ <location>`, then its
  title, then its text (cut at 3 000 characters). The location of the home page is `<home>`.
- For each input file write ONE file in the output directory named in your task, with the same name
  and the extension `.json`, right after finishing that input file:

  ```json
  {"<location>": {"words": ["...", "..."], "questions": ["...", "..."]}}
  ```

  The key is the text after `@@@ ` exactly as written. Every section of the input file must be
  there. Write valid JSON: a backslash is written `\\` (the operator `\+` is `"\\+"`), a double
  quote inside a string is `\"`.
- Keep the notes file named in your task: one line after each input file written. If it already has
  lines, resume after the last one (skip the files whose output exists).
- Read only your input files, this brief and your notes; do not read the course pages, do not edit
  anything else, do not run `taskkill`, and do not use git. Keep any helper script in your own
  scratchpad directory, never in a shared temporary directory.

## What to write for each section

- **words**: 6 to 15 entries. Each is a word or a short phrase (up to 5 words) a student might
  type. Include, in this order of importance:
  1. the section's main concepts in the plain words of a student (not the textbook's): "atrapar un
     error", "imprimir con decimales", "guardar datos en un archivo";
  2. synonyms and the names the same idea has in other books, courses, languages or in English:
     "excepción", "exception", "try catch";
  3. predicate names with arity and operators the section teaches or uses in its examples:
     `catch/3`, `format/2`, `\+`, `=..` (lowercase, as written in the text);
  4. typical error messages or symptoms a student would search for, when the section explains one.
- **questions**: 2 or 3 short questions in Spanish that this section answers, as a student would
  ask them ("¿cómo hago para que el programa no se detenga ante un error?").
- Spanish, lowercase. Do not repeat the section title; do not start every entry with "prolog" (the
  whole course is Prolog). No explanations, no invented facts: only what the section covers.
- Read the whole text of each section: a short beginning is not the section.
- Sections that only list or summarise (titles "Ejercicios", "Objetivos del capítulo", "Resumen",
  "Temas que se retoman", "Referencias", "Soluciones"): write `{"words": [], "questions": []}` —
  the search ranks them low on purpose.
- A section that is a project, a pattern, a template or a general page gets the same treatment:
  describe what a student would be trying to do when this is the right answer.
- Only what the section itself covers. Do not add the names of tasks, puzzles or algorithms the text
  does not mention. A keyword that sends a student to the wrong section is worse than a missing one.
  Words from other languages ("try catch", "hash map", "while") are fine as search words; they are
  never shown to the student.
