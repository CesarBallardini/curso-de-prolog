# Brief 2: search keywords that tell a section apart from its neighbours

You help beginners find the right section of a Spanish-language SWI-Prolog course for second-year
students who have never seen Prolog. A search box matches the words of a question against the words
of the sections. Keywords already exist for these sections; they are too alike between neighbouring
sections and too close to the textbook's own vocabulary. You rewrite them from scratch.

## Input and output

- Your input files are named in your task. Each starts
  with `CHAPTER: <name>` and a TABLE OF CONTENTS: every section of the chapter, as
  `- <location>  |  <title>`. After `SECTIONS TO DESCRIBE:` come the sections you must describe:
  a line `@@@ <location>`, then the title, then the FULL text of the section (very long ones are cut
  at 8 000 characters).
- Read the whole table of contents first; it tells you what the neighbouring sections cover. Then
  read each section completely before writing its entry.
- For each input file write ONE file in the output directory named in your task, with the same name
  and the extension `.json`, right after finishing that input file:

  ```json
  {"<location>": {"words": ["...", "..."], "questions": ["...", "..."]}}
  ```

  The key is the text after `@@@ ` exactly as written. Every section after `SECTIONS TO DESCRIBE:`
  must be there; sections that appear only in the table of contents are not yours. Write valid JSON:
  a backslash is written `\\` (`\+` is `"\\+"`), a double quote inside a string is `\"`.
- Keep the notes file named in your task: one line after each input file written. If it already has
  lines, resume after the last one (skip the files whose output exists).
- Read only your input files, this brief and your notes; do not read the course pages or any other
  file, do not edit anything else, do not run `taskkill`, and do not use git. Keep any helper script in your own scratchpad directory, never in a shared temporary directory.

## What to write

For every section:

- **words**: 8 to 15 entries, each a word or a short phrase (up to 5 words) a student might type.
  In this order of importance:
  1. 3 to 5 phrases in the plain words of a beginner who is trying to do what this section teaches
     or who is stuck on what it explains, not the textbook's words. Think of what the student sees
     on the screen or wants to happen, not of what the concept is called.
  2. 2 to 4 words or phrases that tell this section apart from the other sections of the table of
     contents: what only this section covers. Do not use as a keyword the main subject of a
     neighbouring section; that is how a student gets sent to the wrong one.
  3. Symptoms, answers or error messages the student would meet and that this section explains,
     when it explains one (an unexpected answer, a program that does not stop, a warning's text).
  4. Other names for the same idea: English terms, names from other books or languages.
  5. Predicate names with arity and operators the section teaches or its examples use, as written
     in the text (`catch/3`, `\+`), at most 4.
- **questions**: exactly 3 short questions in Spanish. Each is something a beginner would ask and
  this section answers; at least one phrased as a confusion or a problem ("no entiendo por qué ...").
  Prefer questions that this section answers and its neighbours in the table of contents do not.
- Spanish, lowercase, no explanations, no invented facts: only what the section itself covers. Do
  not repeat the title. Do not start every entry with "prolog" (the whole course is Prolog).
- A section whose heading is "Ejercicios", "Objetivos del capítulo", "Resumen", "Temas que se
  retoman" or "Referencias" gets `{"words": [], "questions": []}` (these are not in your input
  normally; if one is, leave it empty).
- A section that only says "Esta página contiene la sección ..." or is a page index gets a short
  entry: 4 to 6 words and 1 question, describing what the page is about.
