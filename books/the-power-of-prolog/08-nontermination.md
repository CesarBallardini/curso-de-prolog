# Nontermination

## Introduction

There is a huge class of interesting programs, written in Prolog and also in other languages, that *never terminate*. For instance, such programs may *generate* as many objects as possible from a set that is known to be *infinite*. A Prolog program that generates the sequence of prime numbers is an example for this type of programs. Another very important instance are programs that search for objects whose very *existence* is not *a priori* known, such as:

- [*integers*](clpfd) with specific properties
- [*graphs*](20-optimization.md#graph) and other combinatorial objects with a certain structure
- [*proofs*](25-theoremproving.md) of famous conjectures
- *counterexamples* to well-known hypotheses
- etc.

In such cases, if the object does not exist, then the search for it does not—and in fact *must not*—terminate. In practice, such programs are often the most interesting, because we do not know whether there is a solution before it is actually found. The more you work on tough scientific questions, the more you will write and work with this type of programs.

## Terminology

In Prolog, we distinguish between *two kinds* of [termination](07-termination.md): existential and universal. We say a Prolog query `Q` **does not terminate** *iff* it *does not terminate universally*, i.e., if the query:

```prolog
?- Q, false.

```

does *not terminate*. Note that if a query does not terminate *existentially*, then it *also* does not terminate universally, and thus, using our terminology, *does not terminate*.

## Inadvertent nontermination

As already mentioned, many Prolog programs *must not* terminate. For example, the query `?- length(Ls, _)` must *generate* lists of arbitrarily long length, and therefore *cannot* terminate:

```prolog
?- length(Ls, _).
   Ls = []
;  Ls = [_A]
;  Ls = [_A,_B]
;  Ls = [_A,_B,_C]
;  ... .

```

If this query did terminate, the relation would be *incomplete* and thus *incorrect*. However, in some cases, Prolog programmers write a program or query that *inadvertently* does not terminate. For example, consider the query:

```prolog
?- length(_, Ls), Ls = [].
nontermination

```

This query does not terminate, and in fact does not even yield a single solution. As another case, consider the program:

```prolog
adjacent(a, b).
adjacent(e, f).
adjacent(X, Y) :- adjacent(Y, X).

```

Here, a programmer has entered two facts. The final *rule* is meant to turn `adjacent/2` into a *symmetric* relation. From a quick first glance, everything appears to work as intended:

```prolog
?- adjacent(X, Y).
   X = a, Y = b
;  X = e, Y = f
;  X = b, Y = a
;  ... .

```

However, contrary to our expectation about such a finite relation, the query *does not terminate*:

```prolog
?- adjacent(X, Y), false.
nontermination

```

Such cases are common among beginners, and often lead them to perceive Prolog as "slow", when in fact their program does not terminate *at all*.

## Failure slicing

To produce **explanations** for nontermination, we use a powerful declarative debugging method called *failure slicing*. The main idea is to insert calls of `false/0` into your program, in order to obtain smaller *program fragments* that *still* exhibit nontermination. For example, in the case of the query shown above, we can insert `false/0` between the two goals:

```prolog
?- length(_, Ls), false, Ls = [].
nontermination

```

Operationally, we can *ignore* everything *after* the call of `false/0`, and we use ~~strikeout~~ text to indicate parts of the program or query that that we ignore when reasoning about nontermination:

```prolog
?- length(_, Ls), false, Ls = [].
nontermination

```

This fragment *still* does not terminate. Therefore, you either have to *change* the call of `length/2` or *add* additional goals before it in order to make the original query *terminate*. No [pure](11-purity.md) goal that appears *after* the current goal of `length/2` can remove the nontermination! Similarly, consider again the definition of `adjacent/2`, where we again use calls of `false/0` to *explain* the nontermination by showing only relevant program fragments:

```prolog
adjacent(a, b) :- false.
adjacent(e, f) :- false
adjacent(X, Y) :- adjacent(Y, X).

```

Even with only the single remaining clause, we observe nontermination:

```prolog
?- adjacent(X, Y), false.
nontermination

```

Again, no pure clause you add or remove can make this nontermination go away. To make the query terminate, you have to *change* the single remaining clause! For example, we could *separate* the facts from the main predicate to make both predicates terminating:

```prolog
adjacent_(a, b).
adjacent_(e, f).

adjacent(X, Y) :- adjacent_(X, Y).
adjacent(X, Y) :- adjacent_(Y, X).

```

Example query, showing that `adjacent/2` now *terminates*:

```prolog
?- adjacent(X, Y), false.
   false.

```

Failure slicing is a special case of [*program slicing*](05-reading.md#slicing).

## Further reading

See [**Reading Prolog Programs**](05-reading.md) for more information about *program slicing*. To *automatically* generate explanations for nontermination, see [cTI](http://www.cs.unipr.it/cTI/) and especially [**GUPU**](http://www.complang.tuwien.ac.at/ulrich/gupu/). [Tabling](28-memoization.md#tabling) can help to improve termination aspects of Prolog programs.
