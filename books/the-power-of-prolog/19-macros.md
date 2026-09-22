# Prolog Macros

*Video*: [Term and Goal Expansion](https://www.metalevel.at/prolog/videos/term_and_goal_expansion)

## Introduction

In the Lisp community, *macros* are always a big deal. A Lisp macro *rewrites Lisp code*. Very often, the phrase "code is data" is used in this context. But this also holds for example for C and Java code: C code is *also* data, and you can store and access C code as a plain text file. Therefore, this does not capture the main reason why we should care about Lisp macros especially. In a more limited sense, a C preprocessor *also* supports macros. What, then, *is* the core difference between Lisp and C macros? Clearly, Lisp macros are much more powerful *because they can easily analyze Lisp code*. Why is this? Because Lisp code has a **natural, structure-preserving representation** as a Lisp data structure! This is *not* the case for C or Java. For example, there is no built-in data structure in C that faithfully represents C source code in a *structure-preserving way*. We can represent C source code within C as an array of characters, but that does not preserve the *abstract structure* of the source code, and it makes basic operations extremely hard. For example:

- Which variable names occur in the program?
- How many if-then-else constructs are used in the code?
- Are there tail-recursive functions?

These are questions that are hard to answer in the case of C because it is hard to reason about the structure of C programs in an abstract way, at least much harder than it is in the case of Lisp. The point of this page is to show you that Prolog has a mechanism that works much like **macros** in Lisp. In fact, macros are a lot easier to write in Prolog for several reasons. For example, you do not have to *quote* Prolog code when reasoning about it or generating it, and you cannot accidentally run into name clashes with different variables. This simplicity is the main reason why Prolog programmers are not as hysteric about this feature as several other language communities. In Prolog, this facility is simply available, and easily used when needed.

## Code is more than data

Of course, *code is data*: We write it down, we read it. Prolog code is *more* than simply "data" though: Every Prolog clause is a valid [**Prolog term**](04-data.md). This is *structured* data, which we can analyze and process systematically using [*built-in features*](03-concepts.md#builtin) of Prolog. For example, consider a simple Prolog *rule*:

```prolog
f(X, Y) :- g(X), h(Y).
    
```

This is the following Prolog *term*:

- the [*functor name*](04-data.md#term) is `:-`, and the *arity* is 2
- the first *argument* of the term is the term `f(X, Y)`
- the second argument is the compound term `','(g(X), h(Y))`, which in turn again has two arguments.

If you are ever unsure about what a term "actually" is, use `write_canonical/1` to obtain the term's **canonical form**:

```prolog
?- write_canonical( (f(X, Y) :- g(X), h(Y)) ).
:-(f(A,B),','(g(A),h(B)))
    
```

In the canonical form, all compound terms are output in *functional notation*. Note that we have used parentheses around the term to properly indicate the single argument of `write_canonical/1`.

## Rewriting Prolog code

All widely used Prolog systems provide mechanisms that let us *rewrite Prolog code* **at compilation time**. The advantage is clear: We can perform complex transformations of Prolog code *once* at compilation time, resulting in often faster code at *run time*. In Prolog systems, this facility is typically provided by *extensible* predicates such as `term_expansion/2` and `goal_expansion/2`. These predicates take 2 arguments:

- the first argument is a Prolog term as it occurs in the program that is being compiled
- the second argument denotes the *replacement* of the term.

If a clause of this extensible predicate succeeds, then the replacement term is used *instead* of the original term during compilation. If your Prolog system does not provide this facility, you can easily implement it yourself, using the built-in predicate `read/1` to read Prolog terms from a file. The exact semantics of these predicates differ between Prolog systems, for example regarding questions such as:

- Are the *virtual* read-term `beginning_of_file` and `end_of_file` made available for expansion?
- Are expansions themselves subject to expansion?
- Are *meta-calls* automatically expanded at run-time?
- Are *queries* subject to goal expansion?
- ...

A common standard would be nice.

## Examples

See the [implementation of DCGs](14-dcg.md#implementation) for an example of *term* expansion that is used in almost all widely available Prolog systems. In this case, the expansion mechanism is used to *automatically* equip DCG rules and all DCG nonterminals with 2 additional arguments in a systematic way. In Scryer Prolog, [integer arithmetic](clpfd) serves as an example of *goal* expansion. For instance, consider the following Prolog rule whose body consists of a single goal:

```prolog
integer_successor(I0, I) :- I #= I0 + 1.
    
```

To see how this is automatically expanded, declare the predicate dynamic via the `dynamic/1` directive, and use `listing/1` from `library(format)`:

```prolog
?- listing(integer_successor/2).
integer_successor(A,B) :-
   (  integer(B) ->
      (  integer(A) ->
         B=:=A+1
      ;  C is B,
         clpz:clpz_equal(C,A+1)
      )
   ;  (  integer(A) ->
         (  var(B) ->
            B is A+1
         ;  C is A+1,
            clpz:clpz_equal(B,C)
         )
      ;  clpz:clpz_equal(B,A+1)
      )
   ).
    
```

This example illustrates that low-level integer arithmetic is *automatically* used whenever possible, even if we use higher-level constructs which *also* work in other directions.
