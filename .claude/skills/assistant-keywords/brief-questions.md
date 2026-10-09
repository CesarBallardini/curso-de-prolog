# Brief: one search query per course section, as a student would type it

Read ONLY the input file named in your task. Do not read any other file of the repository, do not
use git, do not run `taskkill`. The file holds sections of a Spanish-language SWI-Prolog course for
second-year students. Each section starts with a line `@@@ qNN | style: <style>`, then its title,
then its text.

For each section write ONE query in Spanish that a student who has NOT read the course would type
in the course's search box, and that this section answers. The style on the header line says what
form it takes:

- `question`: a full natural question ("¿cómo hago para ...?", "¿por qué ...?").
- `keywords`: a search-box query of 2 to 5 words, no question marks.
- `problem`: the student describes what they want to do or what went wrong, in one sentence.

Rules:

- The student does not know the course's own terminology. Use everyday words; do not copy the
  section's title or its technical terms when a plainer word exists. A student may know a predicate
  name or an error message from elsewhere and use it, but only occasionally.
- The query must be specific to this section: someone reading it should be able to tell this section
  answers it better than its neighbours. Do not write generic queries ("qué es prolog").
- Do not invent facts: the section must really answer the query. Spanish, natural, without
  quotation marks inside.

Write ONE file, the one named in your task: `{"q00": "the query", ...}` with exactly the ids of the
input. A backslash inside a string is written `\` (valid JSON). When done, check that the JSON
parses and has every id (a short `uv run --frozen python -c` script). Reply with the count and
anything you had to guess.
