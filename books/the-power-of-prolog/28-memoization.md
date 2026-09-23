# Memoization

## Introduction

The two best rules for improving [efficiency](27-efficiency.md) of Prolog programs were given by Richard O'Keefe:

1.  Don't do it.
2.  Don't do it again.

To illustrate option 1: If we need to solve a task that is exorbitantly hard, we could look for a different, easier task whose results *approximate* optimality within a sufficient range. In this text, we discuss option 2, that is ways to not do it *again*. The common theme is that we *remember* results of previous computations, which is a technique known as *memoization* in computer science.

## Tabling

**Tabling** is a *built-in* method to apply memoization to Prolog predicates. This means that the underlying Prolog system can *automatically* perform memoization for you, if you request it. Tabling is also known as **SLG resolution**. Different Prolog systems provide tabling in various forms and with different characteristics. [XSB Prolog](http://xsb.sourceforge.net/) is one of the pioneering systems in this area, and some of its techniques are now becoming more widely available also in other systems. Your Prolog system's manual should contain the exact details. For example, to enable tabling in Scryer Prolog, you need to:

1.  Use `library(tabling)` via the directive `:- use_module(library(tabling)).` in your source file.
2.  Enable tabling via the `table/1` directive.

Hence, to enable tabling for [`adjacent/2`](08-nontermination.md), you can write:

```prolog
:- use_module(library(tabling)).

:- table adjacent/2.

adjacent(a, b).
adjacent(e, f).
adjacent(X, Y) :- adjacent(Y, X).

```

In this case, tabling has made the predicate *terminating*:

```prolog
?- adjacent(X, Y), false.
   false.

```

As the second example, let us consider the series of [**Fibonacci numbers**](https://en.wikipedia.org/wiki/Fibonacci_number), which we can describe in Prolog for example as follows:

```prolog
fibonacci(0, 1).
fibonacci(1, 1).
fibonacci(N, F) :-
        N #> 1,
        N1 #= N - 1,
        N2 #= N - 2,
        fibonacci(N1, F1),
        fibonacci(N2, F2),
        F #= F1 + F2.

```

The relation works as intended in the most general case:

```prolog
?- fibonacci(N, F).
   N = 0, F = 1
;  N = 1, F = 1
;  N = 2, F = 2
;  N = 3, F = 3
;  N = 4, F = 5
;  ... .

```

It can also be used for more specific queries:

```prolog
?- fibonacci(17, F).
   F = 2584
;  false.

```

However, the computation runs out of stack or takes too long for larger arguments:

```prolog
?- fibonacci(100, F).
ERROR: Out of local stack

```

We can easily enable tabling by adding the following directives to the file:

```prolog
:- use_module(library(tabling)).

:- table fibonacci/2.

```

Using SLG resolution, the answer to the previous query is now readily found:

```prolog
?- fibonacci(100, F).
   F = 573147844013817084101
;  false.

```

Tabling also allows you to use [left-recursive DCGs](14-dcg.md#leftrecursion) for parsing. For example, you can add the directive:

```prolog
:- table tree_nodes//1.

```

to apply tabling to the DCG nonterminal `tree_nodes//1`. Scryer Prolog implements tabling via *delimited continuations*. See the paper [*Tabling as a Library with Delimited Control*](https://biblio.ugent.be/publication/6880648/file/6885145.pdf) by Benoit Desouter *et al.* for more information.

## Doing it manually

We can *emulate* tabling by *manually* storing results in the global database. Consider for example the following definition of `memo/1`:

```prolog
:- dynamic(memo_/1).

memo(Goal) :-
        (   memo_(Goal)
        ->  true
        ;   once(Goal),
            assertz(memo_(Goal))
        ).

```

As long as `Goal` is semi-deterministic or deterministic, `memo(Goal)` is equivalent to `Goal` and *reuses* results that have already been computed. This leads to a technique known as *dynamic programming* in computer science. Note that this is less powerful than tabling: First, it requires *modifications* of the original program that go beyond adding simple directives. You have to manually wrap the goals for which you want to enable memoization with `memo/1`. Second, this rather *ad hoc* definition does not help to improve termination properties of your programs. On the plus side, the technique can still help to improve performance tremendously when it is applicable, and it is *portable* to all Prolog systems. Applied to `fibonacci/2`, it could look as follows:

```prolog
fibonacci(0, 1).
fibonacci(1, 1).
fibonacci(N, F) :-
        N #> 1,
        N1 #= N - 1,
        N2 #= N - 2,
        memo(fibonacci(N1, F1)),
        memo(fibonacci(N2, F2)),
        F #= F1 + F2.

```

Sample query and answer:

```prolog
?- fibonacci(100, F).
F = 573147844013817084101.

```

## Doing it more explicitly

In many cases, we want more explicit control over what is being stored. For example, we may want to ensure that we do not accidentally clutter the global database or tabling storage. In such cases, we can carry around a custom "database" of existing results as predicate *arguments*. We can use [semicontext notation](14-dcg.md#semicontext) to carry around the state *implicitly* while still retaining full control over the storage. As an example, we present the calculation of the **minimum edit distance** between two lists, using the nonterminals [`state//1`](14-dcg.md#state) and [`state//2`](14-dcg.md#state):

```prolog
min_edit(As, Bs, Min-Es) :-
        empty_assoc(Assoc0),
        phrase(min_dist(As, Bs, Min-Es), [Assoc0], _).

min_dist([], [], 0-[]) --> [].
min_dist(As, Bs, Min-Es) -->
        (   state(S0), { get_assoc(store(As,Bs), S0, Min-Es) } -> []
        ;   { findall(option(Action,Cost,As1,Bs1),
                      edit_option(As, Bs, Action, Cost, As1, Bs1),
                      Options) },
            assess_options(Options, CostOptions),
            state(S0, S),
            { keysort(CostOptions, [Min-Es|_]),
              put_assoc(store(As,Bs), S0, Min-Es, S) }
        ).

assess_options([], []) --> [].
assess_options([option(Action,Cost,As,Bs)|Options], [Min-[Action|Es]|Rest]) -->
        min_dist(As, Bs, Min0-Es),
        { Min #= Min0 + Cost },
        assess_options(Options, Rest).

```

This code is quite flexible, and can be adapted to various use cases by providing a suitable definition of `edit_option/6`, declaratively describing the actions that are allowed to transform one list into another. For example, a typical use case may look like this:

```prolog
edit_option([A|As], Bs, drop(A), 1, As, Bs).
edit_option(As, [B|Bs], insert(B), 1, As, Bs).
edit_option([A|As], [A|Bs], use(A), 0, As, Bs).

```

This means that there are three possible actions (dropping, inserting and using an element), with associated costs of one, one and zero, respectively. Example query and answer:

```prolog
?- min_edit("abcef", "axbdef", Min).
   Min = 3-[use(a),insert(x),use(b),drop(c),insert(d),use(e),use(f)]
;  false.

```

If it were implemented naively, `min_edit/3` would exhibit *exponential* runtime in the length of the lists. Using memoization has reduced this to polynomial runtime.
