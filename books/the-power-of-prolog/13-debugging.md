# Debugging Prolog Programs

First, a note on terminology: In the following, the word **mistake** is used *instead* of "bug". The reasons for this are:

- *We* are making these mistakes. They do not occur by themselves.
- Mistakes in software should be taken seriously. We should not trivialize them or find excuses.
- Mistakes should be *corrected*.

We now consider *declarative* ways to *locate* and *correct* mistakes in Prolog programs. The techniques we explain have been invented and popularized by [Ulrich Neumerkel](http://www.complang.tuwien.ac.at/ulrich/) in the Prolog teaching environment [**GUPU**](http://www.complang.tuwien.ac.at/ulrich/papers/PDF/#2002-wlpe).

*Video*: [Debugging Prolog](https://www.metalevel.at/prolog/videos/debugging)

The methods are based on declarative ways of [**reading Prolog programs**](05-reading.md), exploiting logical properties to quickly narrow down mistakes. We call this approach **declarative debugging**.

## Tracing falls short

When you detect a mistake in a Prolog program, and you are used to procedural languages, you may try to think about the Prolog program mostly *procedurally* and attempt to understand its control flow by *tracing* the computation. There are several tools that help you with this: Try

```prolog
?- trace, your_goal.

```

and

```prolog
?- gtrace, your_goal.

```

to trace your programs in textual or graphical tracers that your Prolog system provides. Unfortunately, **tracing falls short** in several critical respects. One important reason is that tracers are *programs* and *also* contain mistakes. Very often, and especially for more complex programs, you will wrestle with mistakes, omissions and shortcomings in the tracer *in addition* to mistakes in your program. Another important reason is that traces quickly get very *complex* and hard to understand. Finally, using tracers only further encourages procedural thinking, which makes it even harder for you to learn more elegant techniques and practices for locating mistakes in declarative programs. For these reasons, we focus on *declarative* approaches in this text. They are easy to apply, let you quickly locate mistakes, and encourage the use of declarative techniques that also make declarative approaches for locating mistakes more widely applicable.

## Mistakes in a Prolog program

There are two main ways in which a pure Prolog program that *terminates* can be wrong. It can be:

- *too general*
- *too specific*.

A Prolog program is too **general** if it yields solutions that are not intended. A Prolog program is too **specific** if intended solutions are not reported. In the former case, *constraints* must be added to rule out unintended solutions. In the latter case, the program must be *generalized*. These cases are *not* mutually exclusive: A Prolog program may be too general *and* too specific. When beginners write their first Prolog programs, they frequently ask: "*Why* does my predicate fail?" This means that their predicate fails *although they intend it to succeed*. It means that their predicate is *too specific* and must be *generalized*. The question itself is perfectly adequate: Notice how natural it is to ask for the *why*. It would be extremely inconvenient and in most cases almost impossible to follow the exact *steps* that Prolog performs, i.e., *how* it fails. We care more about high-level *explanations* than about low-level *traces*. We will thus use Prolog to locate the *reasons* for unintended failures, i.e., those parts of our programs that *cause* unintended failures.

## Example: Length of a list

Let us consider a simple Prolog program that *contains a **mistake***:

```prolog
list_length([], 0).
list_length([_|Ls], N) :-
        N #> 0,
        N #= N0 + 2,
        list_length(Ls, N0).

```

Our intention is to describe the relation between a *list* and its *length*. We can use the methods described in [**Declarative Testing**](12-testing.md) to detect that the program is *too specific* because the following query *incorrectly* **fails**:

```prolog
?- list_length([_], 1).
   false.

```

In fact, the program is also *too general*, because the following query **succeeds** unintentionally:

```prolog
?- list_length([_], 2).
   true.

```

Note that we declaratively reason about the *meaning* of the program, without attempting to understand details of the computation.

## Locating mistakes

How can we find the precise **location** of mistakes in our program? A very nice method, applicable for the the [**pure**](11-purity.md) monotonic subset of Prolog, was described by Ulrich Neumerkel in a posting to the SWI-Prolog mailing list, and we will use his technique here. The idea is to make the following definitions available in your programs:

```prolog
:- op(920,fy, *).

*_.
```

In Scryer Prolog, `(*)/1` is available in [`library(debug)`](https://codeberg.org/mthom/scryer-prolog/raw/master/src/lib/debug.pl). Putting `(*)/1` in front of a goal lets us **generalize away** the goal. This means that the goal is treated as if it were not stated *at all*. We could also "comment out" the goal, but using `(*)/1` is a lot more convenient because it also works for the *last* goal of a clause, whereas "commenting out" the period would lead to syntax errors. In the following, we use ~~strikeout~~ text to denote that the goal is treated as if it did not appear at all. We start by generalizing away *all* explicit goals:

```prolog
list_length([], 0).
list_length([_|Ls], N) :-
        * N #> 0,
        * N #= N0 + 2,
        * list_length(Ls, N0).

```

This makes the program significantly *more general*. Of course it is now much *too* general, but at least it is no longer too specific. In particular, the query that previously unintentionally *failed* now *succeeds*:

```prolog
?- list_length([_], 1).
   true.

```

By systematically removing some of the `(*)/1` we introduced, we can **narrow down** the mistake. In particular, if we use the following definition:

```prolog
list_length([], 0).
list_length([_|Ls], N) :-
        N #> 0,
        * N #= N0 + 2,
        list_length(Ls, N0).

```

then the query still *succeeds*, but if we *include* the single goal that is now still generalized away, then the query *fails* again. Therefore, **check this goal for mistakes**! A bit of reflection quickly leads to the following correction:

```prolog
list_length([], 0).
list_length([_|Ls], N) :-
        N #> 0,
        N #= N0 + 1,
        list_length(Ls, N0).

```

This corrected program passes all tests explained in [**Declarative Testing**](12-testing.md).

## Appreciating the technique

Let us briefly pause and reflect on the approach outlined above. Clearly, the method is based on the following important property:

> **Removing a goal** can make a predicate at most **more general**, *never* more specific.

This property clearly **holds** for pure and monotonic Prolog code. That is a [Turing complete](https://en.wikipedia.org/wiki/Turing_completeness) subset of Prolog and therefore suffices to express all computations that are currently known. However, solely for the sake of argument, suppose that your application ideas are so colossal that they *exceed* the expressiveness of this fragment. Even if that were the case, it would *still* be remarkable that such a strong, general statement can be made about how *changes* to a program affect its meaning. Since that fragment is, in reality, as expressive as the whole language in computational terms, it is all the *more* remarkable! In fact, Prolog is rather unique due to this property alone already. Compare this property to other programming languages: How do comparable changes in a Java, C++ or Haskell program affect its meaning? For example, what changes if you remove a `for` loop in a Java program, an `if-then-else` block in a C++ program, or one of the lines in a `do` block in a Haskell program? Does such a program even *compile* in all cases? Can you make any such statement for *any* fragment of *any* programming language other than Prolog? There are many other interesting properties that *also* hold for pure and monotonic Prolog code, and which can be exploited for locating mistakes in our programs. It is our hope that the availability and usefulness of such declarative methods encourage you to value and retain logical purity of your Prolog programs.

## Further reading

Ehud Shapiro pioneered declarative debugging methods for Prolog in his 1982 PhD thesis, [*Algorithmic Program Debugging*](http://cpsc.yale.edu/sites/default/files/files/tr237.pdf). See [**Nontermination**](08-nontermination.md) for reasoning about programs that inadvertently *don't* terminate. See the [**failure-slice**](http://stackoverflow.com/questions/tagged/failure-slice) tag on stackoverflow, [additional definitions](http://stackoverflow.com/a/30791637/1613573) for reasoning declaratively about programs, and [**library(diadem)**](http://www.complang.tuwien.ac.at/ulrich/Prolog-inedit/diadem.pl).
