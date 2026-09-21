# 11 Projects in Prolog

<!-- page 273 -->
Projects in Prolog

```prolog
This chapter contains a list of projects that you may wish to undertake in order to
exercise your programming ability. Some of the projects are easy, but some may be
appropriate as "term projects" as a part of a course in Prolog. The easier projects
should be used to supplement the exercises in the previous chapters. The projects are
in no particular order, although those in Section 11.2 are more open ended and am-
bitious, and will require some knowledge or background reading in various areas of
artificial intelligence and computer science. A few of the projects assume knowledge
about some particular field of study, so if you are not a mathematical physicist, do
not feel discouraged if you cannot write a program to differentiate three dimensional
vector fields.
```

## 11.1 Easier Projects

```prolog
1. Define a predicate to "flatten" a list by constructing a list containing no lists as ele-
ments, but containing all of the atoms of the original list. For example, the following
goal would succeed:
    ?- flatten([a,[b,c],[[d],[],e]], [a,b,c,d,e]).
There are at least six distinct ways to write this program.
2. Write a program to calculate the interval in days between two dates expressed in
the form DayMonth, assuming they refer to the same year which is not a leap year.
Notice that"-" is simply the infix form of a 2-ary functor. For example, the following
goal would succeed:
    interval(3-march, 7-april, 35).
```

<!-- page 274 -->
```prolog
3. In Chapter 7 sufficient information is given to construct programs to differentiate
and simplify arithmetic expressions. Extend these programs so they will handle ex-
pressions containing trigonometric functions, and if you desire, differential geometry
operators such as div, grad, and curl.
4. Write a program to produce the negation of a prepositional expression. Preposi-
tional expressions are built up from atoms, the unary functor not, and binary functors
and, or, and implies. Provide suitable operator declarations for the functors, perhaps
using the operator declarations
                             &, #, and ->) in Chapter 10. The negated expres-
sion should be in simplest form, where not is only applied to atoms. For example,
the negation of
    p implies (q and not(r))
should be
    p and (not(q) or r).
5. A concordance is a listing of words that occur in a text, listed in alphabetical order
together with the number of times each word appears in the text. Write a program to
produce a concordance from a list of words represented as Prolog strings. Recall that
strings are lists of ASCII codes.
6. Write a program that understands simple English sentences having the following
forms:
       is a
             .
    A
        is a
              .
    Is _ a _ ?
The program should give an appropriate response (yes, no, ok, unknown), on the
basis of the sentences previously given. For example,
    John is a man.
```

*ok*

```prolog
A man is a person.
```

*ok*

```prolog
Is John a person?
```

*yes*

```prolog
Is Mary a person?
```

*unknown*

```prolog
Each sentence should be translated into a Prolog clause, which is then asserted or
executed as appropriate. Thus, the translations of the preceding examples are:
```

<!-- page 275 -->
```prolog
    man(john).
    person(X) :- man(X).
    ?- person(john).
    ?- person(mary).
Use grammar rules if you find them appropriate. The top clause to control the dia-
logue might be:
    talk :
                repeat,
                read(Sentence),
                parse(Sentence, Clause),
                respond_to(Clause),
                Clause = stop.
7. The alpha-beta (a — /?) algorithm is a method for searching game trees that is
mentioned in many books on artificial intelligence programming. Implement the a —
fi algorithm in Prolog.
8. The AT-queens problem is also widely discussed in programming texts. Implement
a program to find all the ways of placing 4 queens on a 4x4 chessboard so that
no queen attacks another. One way is to write a permutation generator, which then
checks each permutation to ensure that it places the queens correctly.
9. Write a program that rewrites propositional expressions (Problem 4), replacing
all occurrences of and, or, implies, and not by the single connective nand. The
connective nand is defined by the following identity:
                        (a nand 0) = -i(a A /?)
10. One way of representing the positive whole numbers is as Prolog terms involving
the integer 0 and the functor s with one argument. Thus, we represent 0 by itself, 1
by s(0), 2 by s(s(0)), and so on (each number is represented by the functor s applied
to the representation of the number one less). Write definitions of the standard arith-
metic operations addition, multiplication and subtraction, given this representation of
numbers. For instance, you should define a predicate plus that exhibits the following
behaviour:
    ?- plus(s(s(0)), s(s(s(0))), X).
```

*X-s(s( 5 (s(s(0)))))*

```prolog
that is, 2+3=5. For subtraction, you will have to introduce a convention for when
the result of the operation is not a positive whole number. Also define the predicate
```

<!-- page 276 -->
```prolog
"less than". What arguments need to be instantiated for your definitions to work?
What happens in the other cases? How does this compare with the standard Prolog
arithmetic operations? Try defining some more complicated arithmetic operations,
like integer division and square root.
```

## 11.2 Advanced Projects

```prolog
Although the projects in this section may seem open ended, all of them have been
implemented in Prolog by various programmers around the world. Some of them are
straightforward enhancements to programs discussed earlier, and some of them are
completely new, and depend on knowledge of the artificial intelligence literature or
computer science.
1. Given a map that describes roads that connect towns, write a progam that plans
a route between two towns, giving a timetable of expected travel. The map data
should include mileage, road conditions, estimated amount of other traffic, gradients,
availability of fuel along various roads.
2. Only integer and floating-point arithmetic operations are built into current Prolog
systems. Write a package of programs to support arithmetic over rational numbers,
represented either as fractions or as mantissa and exponent.
3. Write procedures to invert and multiply matrices.
4. Compiling a high-level computer language into a low-level language can be
viewed as the successive transformation of syntax trees. Write such a compiler, first
compiling arithmetic expressions. Then add control syntax (like if... then ... else).
The syntax of the assembly output is not crucial for this purpose. For example, the
arithmetic expression x+1 could be "simplified" into the assembly language state-
ment inc x, where inc is declared as a unary operator. The problem of register allo-
cation can be postponed by assuming that the code compiles into a form suitable for
execution by a stack machine (0-address machine).
5. Devise a representation for complex board games such as Chess or Go, and under-
stand how the pattern matching capabilities of Prolog might be used to implement
strategies for these games.
6. Devise a formalism for expressing sets of axioms, say from Group Theory, Eu-
clidean Geometry, Denotational Semantics, and investigate the problem of writing a
theorem prover for these domains.
7. An interpreter for Prolog clauses can be written in Prolog (see Section 7.13). Write
an interpreter that implements different semantics for Prolog execution, such as more
```

<!-- page 277 -->
```prolog
flexible execution order (instead of left-to-right), perhaps using an "agenda" or other
scheduling mechanism.
8. Consult the artificial intelligence literature on the area of generating plans to solve
problems, and implement a plan generator.
9. Express in Prolog the problem of interpreting a line drawing in terms of some
underlying scene. Features of the picture can be labelled with variables represent-
ing corresponding features of the scene. The picture then corresponds to a set of
constraints these variables must satisfy.
10. Write a program, using Grammar Rules, to parse sentences of the form:
    Fred saw John.
    Mary was seen by John.
    Fred told Mary to see John.
    John was believed to have been seen by Fred.
    Was John believed to have told Mary to see Fred?
11. A production rule system, used in artificial intelligence research, is a sequence
of rules of the form "if situation then action." It has become fashionable within the
artificial intelligence field to write "expert knowledge" in terms of production rules.
For example, the following sentences are typical of those used in actual production
systems that have been implemented:
   Pharmacology: If agent X is a quaternary ammonium salt and an antiarhyth-
   mic, and agent Y is a salicylate, then X and Y will interact to produce in-
   creased absorption by ion pair formation.
   Playing chess: If the black king can move adjacent to the black knight and
   the distance from the white king to the knight is greater than one square,
   then the knight is safe.
   Medicine: If the site of the culture is blood, and the gram stain of the or-
   ganism is negative, and the morphology of the organism is a rod, and the
   patient is a compromised host, then there is a 60% chance that the infecting
```

`organism is` *Pseudomonas aeruginosa.*

```prolog
Write a Prolog program to interpret a set of production rules. Consider some domain
such as identifying plants or animals from identifying characteristics. For example,
a rule from botany would read:
   If a plant has a square stem, paired leaves, twolipped hooded flowers, and
   fruit consisting of four tiny nuts enclosed in the calyx, then it belongs to the
```

<!-- page 278 -->
`family` *Labiatae.*

```prolog
So, if the program asked the question "Does the flower have a square stem?", then
we would rule out the possibility that it belongs to the family Labiatea by answering
"no".
12. Write a program to translate some corpus of English sentences into Predicate
Calculus.
13. Write a program to prove theorems in Predicate Calculus.
14. Write a program to act as a simulated psychiatrist that makes a reply based on
key words in the input, rather like the program in Chapter 3 that changed keywords
in a sentence into other words. A typical dialogue might be (computer replies shown
in boldface):
```

*What is your problem?*

```prolog
This is too much work.
```

*What else do you regard as too much work?*

```prolog
Writing letters.
```

*I see. Please continue.*

```prolog
Also washing my mother's car.
```

*Tell me more about your family.*

```prolog
Why should I?
```

*Why should you what?*

```prolog
Here the appropriate key words were this is, mother, and why. The lack of appropri-
ate keyword evoked the response I see. Please continue.
15. Write a program that parses sentences about happenings in an office building,
such as "Smith will be in his office at 3 pm for a meeting". You might wish to use
Grammar Rules to capture the "business English" language. The program should
then print out a "summary" of the sentence telling who, what, where, and when;
such as follows:
                             who:
                                    smith
                             where: office
                             when: 3 pm
                             what:
                                    meeting
The summary could be represented as assertions in the database, so that questions
could be asked:
    Where is Smith at 3 pm?
```

<!-- page 279 -->
*where: office* *what: meeting*

```prolog
16. Write a natural language interface to the filing system of your computer to answer
questions such as:
    How many files does David own?
    Does Chris share PROG.MAC with David?
    When did Bill change the file VIDEO.C?
The program must be able to interrogate various parts of the filing system such as
ownership and dates.
```
