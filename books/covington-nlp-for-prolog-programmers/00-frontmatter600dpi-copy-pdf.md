# FrontMatter600dpi - Copy.pdf

<!-- page 1 -->
<!-- page 2 -->
Natural Language Processing for Prolog Programmers Natural Language Processing for Prolog Programmers

**Michael A. Covington**

Institute for Artificial Intelligence The University of Georgia Athens, Georgia, USA

Digital edition released by the author, 2013 www.covingtoninnovations.com

<!-- page 3 -->
This digital edition is protected by copyright law. See next page for terms of use. This book was previously published by: Pearson Education, Inc. (then known as Prentice-Hall, Inc.).

© 1994 by Prentice-Hall, Inc. A Simon & Schuster Company Englewood Cliffs, New Jersey 07632 Rights assigned to author. All rights reserved.

TERMS OF USE FOR THIS ELECTRONIC EDITION

<!-- page 4 -->
<!-- page 5 -->
You are welcome to make copies of this book, printed or electronic, for your own use. If you wish to sell or distribute copies, printed or electronic, or place the book on a web site, you must obtain written permission from the author, his heirs or assigns, and this notice must be included. This applies to partial as well as complete copies. SOLI DEO GLORIA Contents

**PREFACE**

**XV**

**NATURAL LANGUAGE**

1.1 What is NLP?

1

1.2 Language from a scientific viewpoint 2

1.3 Language and the brain 4

**14**

Levels of linguistic analysis

5

1.4.1

Phonology, 5 1.4.2

Morphology, 6 1.4.3

Syntax, 7 1.4.4

Semantics, 9 1.4.5

Pragmatics, 10

1.5 Why use Prolog? 12

1.6 Further reading 12

**TEMPLATES AND KEYWORDS**

**14**

<!-- page 6 -->
2.1 Template matching 14 2.1.1

ELIZA, 14 2.1.2

Other template systems, 15 2.2 DOS commands in English 16

2.2.1

Recipe for a template system, 16 2.2.2

Implementing simplification rules, 19 2.2.3

Implementing translation rules, 20 2.2.4

The rest of the system, 21 2.3 Keyword analysis 24

**2.3.1 A time-honored approach, 24**

2.3.2 Database querying, 25 2.3.3 A database in Prolog, 26 2.3.4

Building a keyword system, 27 2.3.5

Constructing a query, 28 2.3.6 Lambda abstraction, 30 2.3.7 Lambdas in Prolog, 31 2.3.8

The complete system, 32 2.4 Toward more natural input 34

2.4.1

Ellipsis, 34 2.4.2 Anaphora, 34

**DEFINITE-CLAUSE GRAMMARS**

**36**

3.1 Phase structure 36

3.1.1

Trees and PS rules, 36 3.1.2

Phase-structure formalism, 38 3.1.3

Recursion, 40

3.2 Top-down parsing 42

**3.2.1 A parsing algorithm, 42**

3.2.2

Parsing with Prolog rules, 43 3.3 DCG rules 45

**3.3.1 DCG notation, 45**

3.3.2

Loops, 48 3.3.3 Some details of implementation, 50

3.4 Using DCG parsers 51

3.4.1

Building syntactic trees, 51 3.4.2

Agreement, 54 3.4.3

Case marking, 56 3.4.4

Subcategorization, 57 3.4.5

<!-- page 7 -->
Undoing syntactic movements, 59 3.4.6 Separating lexicon from PS rules, 61 3.5 Building semantic representations 63

3.5.1

Semantic composition, 63 3.5.2

Semantic grammars, 66

3.6 Offbeat uses for DCG rules 66

3.7 Excursus: transition-network parsers 68

3.7.1

States and transitions, 68 3.7.2

Recursive transition networks, 71 3.7.3,

Augmented transition networks (ATNs), 72

**4 ENGLISH PHRASE STRUCTURE**

**77**

4.1 Phrase structure 77

4.1.1

Trees revisited, 78 4.1.2

Constituents and categories, 79 4.1.3

Structural ambiguity, 80

4.2 Traditional grammar 82

4.2.1

Parts of speech, 82 4.2.2.

Grammatical relations, 84

4.3 The noun phrase and its modifiers 85

4.3.1

Simple NPs, 85 4.3.2

Multiple adjective positions, 87 4.3.3

Adjective phrases, 88 4.3.4

Sentences within NPs, 88

4.4 The verb phrase 90

4.4.1

Verbs and their complements, 90 4.4.2

Particles, 93 4.4.3

The copula, 93

4.5 Other structures 96

4.5.1

Conjunctions, 96 4.5.2

Sentential PPs, 99

4.6 Where PS rules fail

101

4.6.1

Adverbs and ID/LP formalism, 101 4.6.2

Postposing of long constituents, 104 4.6.3

Unbounded movements, 105 4.6.4

Transformational grammar, 108

4.7 Further reading

110

**5 UNIFICATION-BASED GRAMMAR**

**117**

<!-- page 8 -->
5.1 A unification-based formalism 111

Contents

5.1.1

The problem, 111 5.1.2

What is UBG?, 111 5.1.3 How features behave, 112 5.1.4

Features and PS rules, 114 5.1.5

Feature-structure unification, 115

5.2 A sample grammar 117

5.2.1

Overview, 117 5.2.2

Lexical entries, 118 5.2.3

Phrase-structure rules, 119 5.2.4 How the rules fit together, 121

5.3 Formal properties of feature structures

123

5.3.1

Features and values, 123 5.3.2

Re-entrancy, 126 5.3.3

Functions, paths, and equational style, 128

5.4 An extension of Prolog for UBG 130

**5.4.1 A better syntax for features, 130**

5.4.2

Translating a single feature structure, 132 5.4.3

Translating terms of all types, 134 5.4.4

Translating while consulting, 136 5.4.5

Output of feature structures, 138

5.5 UBG in theory and practice

141

**5.5.1 A more complex grammar, 141**

5.5.2

Context-free backbones and subcategorization

lists, 146 5.5.3

Negative and disjunctive features, 149

**PARSING ALGORITHMS**

**151**

6.1 Comparing parsing algorithms

151

6.2 Top-down parsing

151

6.3 Bottom-up parsing

155

6.3.1

The shift-reduce algorithm, 155 6.3.2

Shift-reduce in Prolog, 157

6.4 Left-corner parsing

158

6.4.1

The key idea, 158 6.4.2

The algorithm, 160 6.4.3

<!-- page 9 -->
Links, 162 6.4.4 BUP, 165 6.5 Chart parsing 167 6.5.1

The key idea, 167 6.5.2 A first implementation, 168 6.5.3

Representing positions numerically, 170 6.5.4

Completeness, 171 6.5.5

Subsumption, 174

Earley’s algorithm 176 6.6

6.6.1

The key idea, 176 6.6.2 An implementation, 177 6.6.3

Predictor, 180 6.6.4

Scanner, 182 6.6.5

Completer, 182 6.6.6 How Earley’s algorithm avoids loops, 183 6.6.7 Handling null constituents, 184 6.6.8 Subsumption revisited, 185 6.6.9

Restriction, 186 6.6.10 Improving Earley’s algorithm, 188 6.6.11 Earley’s algorithm as an inference engine, 188

**Which parsing algorithm is really best?**

191 6.7

6.7.1

Disappointing news about performance, 191 6.7.2

Complexity of parsing, 193 6.7.3

Further reading, 195

**7 SEMANTICS, LOGIC, AND MODEL THEORY**

**196**

**The problem of semantics 196**

**71**

**From English to logical formulas**

197 7.2

7.2.1

Logic and model theory, 197 7.2.2

Simple words and phrases, 198 7.2.3

**Semantics of the N constituent, 201**

**Quantifiers (determiners) 203**

**73**

7.3.1

Quantifiers in language, logic, and Prolog, 203 7.3.2

Restrictor and scope, 205 7.3.3

Structural importance of determiners, 207 7.3.4

Building quantified structures, 207 7.3.5

Scope ambiguities, 212

**Question answering 214**

**TA**

7.4.1

Simple yes/no question, 214 7.4.2

Getting a list of solutions, 215 7.4.3,

Who/what/which questions, 217

**75**

**From formula to knowledge base 219**

7.5.1

<!-- page 10 -->
Discourse referents, 219

Contents

7.5.2 Anaphora, 221 7.5.3

Definite reference (the), 224 7.5.4

Plurals, 225 7.5.5

Mass nouns, 227

7.6 Negation 228

7.6.1

Negative knowledge, 228 7.6.2

Negation as a quantifier, 229 7.6.3 Some logical equivalences, 230 77 Further reading 232

**FURTHER TOPICS IN SEMANTICS**

**233**

8.1 Beyond model theory 233 8.2 Language translation 233

8.2.1

Background, 233 8.2.2 A simple technique, 234 8.2.3 Some Latin grammar, 235 8.2.4 A working translator, 237 8.2.5 Why translation is hard, 238 8.3 Word-sense disambiguation 239

8.3.1

The problem, 239 8.3.2

Disambiguation by activating contexts, 240 8.3.3

Finding the best compromise, 244 8.3.4

Spreading activation, 247 8.4 Understanding events 248

8.4.1

Event semantics, 248 6.4.2

Time and tense, 25] 8.4.3

Scripts, 252

8.5 Further reading 256

**MORPHOLOGY AND THE LEXICON**

**257**

9.1 How morphology works 257

9.1.1

The nature of morphology, 257 9.1.2 Morphemes and allomorphs, 258 9.2 English inflection 260

9.2.1

<!-- page 11 -->
The system, 269 9.2.2 Morphographemics (spelling rules), 262 9.3 Implementing English inflection 263 9.3.1

Lexical lookup, 263 9.3.2

Letter trees in Prolog, 264 9.3.3 How to remove a suffix, 268 9.3.4 Morphographemic templates and rules, 268 9.3.5

Controlling overgeneration, 271

**Abstract morphology 272**

9.4

9.4.1

Underlying forms, 272 9.4.2

Morphology as parsing, 275 9.4.3

Two-level morphology, 276 9.4.4

Rules and transducers, 277 9.4.5

Finite-state transducers in Prolog, 279 9.4.6

Critique of two-level morphology, 281

**Further reading 282**

9.5

**Appendices**

**A: REVIEW OF PROLOG**

.

**283**

**Beyond introductory Prolog 283**

A.l

**A.2**

Basic data types 283

A.2.1

Terms, 283 A.2.2 Internal representation of atoms, 284 A.2.3 Compound terms (structures), 285 A.2.4 Internal representation of structures, 286 A.2.5 Lists, 287 A.2.6 Internal representation of lists, 288 A.2.7 Strings, 289 A.2.8 Charlists, 289

A.3 Syntactic issues 290

A.3.1

Operators, 290 A.3.2 The deceptive hyphen, 290 A.3.3 The dual role of parentheses, 291 A.3.4 The triple role of commas, 291 A.3.5 Op declarations, 292

Variables and unification 293 A4

A.4.1

Variables, 293 A.4.2

Unification, 293

A.5 Prolog semantics 294

A.5.1

<!-- page 12 -->
Structure of a Prolog program, 294 A.5.2 Execution, 296

Contents

A.5.3 Backtracking, 297 A.5.4_ Negation as failure, 297 AS5S.5

Cuts, 298 A.5.6 Disjunction, 299 A.5.7 Control structures not used in this book, 300 A5.8 Self-modifying programs, 300 A.5.9 Dynamic declarations, 302 A.6 Input and output 302

A.6.1 The Prolog reader, 302 A.6.2 The writer, 303 A.6.3 Character input-output, 304 A.6.4 File input-output, 305 A.7 Expressing repetitive algorithms 306 A.7.1 repeat loops, 306 A.7.2 Recursion, 307 A.7.3 Traversing a list, 308 A.7.4 Traversing a structure, 309 A.7.5 Arrays in Prolog, 310 A.8 Efficiency issues 311

A.8.1

Tail recursion, 31] A.8.2 Indexing, 312 A.8.3 Computing by unification alone, 313 A.8.4 Avoidance of consing, 314 AY Some points of Prolog style 314 A.9.1 Predicate headers, 314 A.9.2 Order of arguments, 315 B: STRING INPUT AND TOKENIZATION

**317**

B.1 The problem 317 B.2 Built-in solutions 318 B.3 Implementing a tokenizer 318 B4 Handling numbers correctly 320 B.5 Creating charlists rather than atoms 322 B.6 Using this code in your program 322

**325**

<!-- page 13 -->
**Preface**

Natural language processing (NLP) presents a serious problem to the would-be student: there is no good way to get into it. Most of the literature presumes extensive knowledge of both linguistics and computer programming, but few people have expertise in both fields.

This book is designed to fill the gap. It is meant for computer science students and working programmers who know Prolog reasonably well but have little or no background in linguistics. I wrote it for my own course at the University of Georgia. Others will, I hope, find it suitable for a one-semester undergraduate or graduate course.

**Throughout the book, I assume that NLP is an area of applied linguistics. Thus an**

**important goal is to present lots of applicable linguistic theory. I also assume that NLP**

is distinct from, though related to, knowledge representation. Both of these assumptions contrast with older approaches, in which NLP was viewed primarily as a knowledgerepresentation problem to which linguistic theory was only marginally relevant.

Judge this book by what it contains, not by what it leaves out. This is first and foremost a book of techniques. It must necessarily concentrate on problems for which there are widely accepted solutions that lend themselves to implementation in Prolog. It is not a comprehensive handbook of NLP. Nonetheless, I have covered a wider range of topics than is usual in books on NLP in Prolog.

<!-- page 14 -->
In a one-semester course it is not necessary to cover the whole book. The core of the material is in Chapters 1, 2, and 3, after which one can proceed to any of the subsequent chapters (except that Chapter 8 depends on Chapter 7). Appendix A presents a review of Prolog that may be needed, in whole or in part, by some classes or some individuals.

As befits an advanced text, many of the exercises are somewhat open-ended. Exercises marked for discussion are those where considerable disagreement about the correct answer is possible; project denotes exercises requiring extended work.

The computer programs in this book should run under any “Edinburgh-compatible” Prolog implementation. They have been tested under Quintus Prolog, ALS Prolog, Arity Prolog, LPA Prolog (marketed in the United States as Quintus DOS Prolog), and Expert Systems Limited Prolog—2 (which requires ‘:- state (token_class,_,dec10) .’ added at the beginning of each program). These programs do not run in Turbo Prolog, which is a radically different language, nor in Colmerauer’s Prolog II or Prolog III languages.

Many people have helped me refine the material presented here. I am particularly indebted to all the students who have ever taken CS 857 at the University of Georgia, especially Martin Volk and Xilong Chen; to Bob Stearns, Donald Nute, and Richard O’ Keefe, who gave me detailed feedback; and to my wife Melody and daughters Cathy and Sharon, who patiently endured lots of busy evenings and weekends. I would also like to thank the reviewers: Stan C. Kwasny, Washington University; Monagur N. Muraldharan, University of lowa; Gordon Novak, University of Texas-Austin; and Douglas Metzler, University of Pittsburgh.

Michael A. Covington

Athens, Georgia

March 1993

To readers of the 2013 digital edition

This digital edition corrects numerous typographical errors and minor errors of fact but makes no attempt to bring the entire book up to date. This is a book from an earlier era, and anyone using it should definitely consult newer books. This book dates from before there were treebanks, taggers, or substantial use of machine learning in NLP. When using it as a textbook, I supplemented it with an ever-growing pile of handouts. Nonetheless, it contains some techniques that are worth remembering, and I am heartened to see a revival of interest in logic-based methods after years of preoccupation with shallower forms of NLP.

The programs from this book are distributed as a file named NLPPP-programs.zip on the same web site as the book itself. SWI Prolog is probably the best compiler to use with them nowadays. There is not, and never has been, an answer key or set of answers to exercises.

I want to thank all my students and colleagues who gave me feedback over the years, and especially I want to thank Dustin Cline and Fred Maier for help preparing the digital edition.

