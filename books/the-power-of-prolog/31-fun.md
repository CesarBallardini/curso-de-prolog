# Fun Facts about Prolog

There is more to say about Prolog than can ever be said. At the same time, you also need to collect your own experiences with the language, and ponder certain aspects for yourself. Here are a few *true* facts about Prolog to help you begin your own observations and reflections.

*Video*: [Pondering Prolog](https://www.metalevel.at/prolog/videos/pondering_prolog)

## Tail recursion often arises naturally

In Prolog, due to the power of *logic variables*, many predicates can be *naturally* written in a tail recursive way. For example, consider again [`list_list_together/3`](05-reading.md#list_list_together3):

```prolog
list_list_together([], Bs, Bs).
list_list_together([A|As], Bs, [A|Cs]) :-
        list_list_together(As, Bs, Cs).
    
```

It is easy to see that `list_list_together(As, Bs, Cs)` is a call in a *tail position*, because *no further goal follows*. Contrast this with a function like `append` in Lisp:

```prolog
(defun append (x y)
  (if x
      (cons (car x) (append (cdr x) y))
    y))
    
```

This version of `append` is *not* tail recursive in Lisp, because the recursive call is wrapped within a call of `cons` and thus *not* the final function call in this branch. It is somewhat remarkable that such a basic function is *not* naturally tail recursive in Lisp, but the corresponding relation *is* tail recursive in Prolog! In Prolog, many more predicates are *naturally* tail recursive.

## Tail recursion is sometimes inefficient

In many cases, tail recursion is good for performance: When the predicate is **deterministic**, a tail call means that the Prolog system can automatically *reuse* the allocated space of the environment on the local stack. In typical cases, this measurably reduces memory consumption of your programs, from O(N) in the number of recursive calls to O(1). Since decreased memory consumption also reduces the stress on memory allocation and garbage collection, writing tail recursive predicates often improves both space and time [efficiency](27-efficiency.md) of your Prolog programs. However, take into account that many Prolog programs are *not* deterministic. As long as choice points remain, the current environment on the local stack *cannot be discarded*, because it may still be needed on backtracking. For example, let us define the relation `list_element_rest/3` between a [list](04-data.md#list), one of its elements, and the list *without* that element:

```prolog
list_element_rest([L|Ls], L, Ls).
list_element_rest([L|Ls0], E, [L|Ls]) :-
        list_element_rest(Ls0, E, Ls).
    
```

[**Declarative reading**](05-reading.md#declarative):

1.  The relation quite obviously holds for the list `[L|Ls]`, its *first* element `L`, and the remainder `Ls`.
2.  *If* the relation holds for the list `Ls0`, one of its elements *E*, and the remainder `Ls`, *then* the relation also holds for `[L|Ls0]` and `E`, and the remainder `[L|Ls]`. This rule is clearly *tail recursive*, because the recursive call is its only goal.

This predicate is quite versatile. Operationally, we can use it to *remove* one element from a list, to *add* an element to a list, and also in several other directions to either generate, complete or test possible solutions. For example:

```prolog
?- list_element_rest("ab", E, Rest).
   E = a, Rest = "b"
;  E = b, Rest = "a"
;  false.
    
```

And also:

```prolog
?- list_element_rest(Ls, c, "ab").
   Ls = "cab"
;  Ls = "acb"
;  Ls = "abc"
;  false.
    
```

In the [Prologue for Prolog](https://www.complang.tuwien.ac.at/ulrich/iso-prolog/prologue) draft and several Prolog systems, an almost identical predicate is available under the name [`select/3`](https://www.complang.tuwien.ac.at/ulrich/iso-prolog/prologue#select). Using `list_element_rest/3` as a building block, we now define `list_permutation1/2` to describe the relation between a list and one of its *permutations*:

```prolog
list_permutation1([], []).
list_permutation1(Ls, [E|Ps]) :-
        list_element_rest(Ls, E, Rs),
        list_permutation1(Rs, Ps).
    
```

Note that that this predicate is *also* tail recursive. Here is an example query:

```prolog
?- list_permutation1("abc", Ps).
   Ps = "abc"
;  Ps = "acb"
;  Ps = "bac"
;  Ps = "bca"
;  Ps = "cab"
;  Ps = "cba"
;  false.
    
```

Let us now run a few benchmarks. We generate *all* solutions for lists of length 9, 10 and 11:

```prolog
?- L in 9..11, indomain(L), portray_clause(L),
   length(Ls, L),
   time((list_permutation1(Ls,_),false)).
9.
   % CPU time: 1.662s
10.
   % CPU time: 16.620s
11.
   % CPU time: 187.939s
    
```

Now consider an alternative definition of this relation, which we call `list_permutation2/2`:

```prolog
list_permutation2([], []).
list_permutation2([L|Ls0], Ps) :-
        list_permutation2(Ls0, Ls),
        list_element_rest(Ps, L, Ls).
    
```

This version is *not* tail recursive. Let us run the same benchmarks with this new version:

```prolog
?- L in 9..11, indomain(L), portray_clause(L),
   length(Ls, L),
   time((list_permutation2(Ls,_),false)).
9.
   % CPU time: 0.344s
10.
   % CPU time: 3.342s
11.
   % CPU time: 36.651s
    
```

Note that this version is *several times faster* in each of the above cases! If you care a lot about performance, try to understand why this is so. Together with the previous section, this example illustrates that tail recursion *does* have its uses, yet you should not overemphasize it. For beginners, it is more important to understand [termination](07-termination.md) and [nontermination](08-nontermination.md), and to focus on clear declarative descriptions.

## Most cuts are red

Almost every time you add a `!/0` to your program, it will be a so-called *red cut*. This means that it will make your program *wrong* in that it incorrectly omits some solutions only in *some* usage modes. This is a tough truth to accept for most Prolog programmers. There always seems hope that we can somehow outsmart the system and get away with *green cuts*, which improve performance and honor all usage patterns. This hope is quite unfounded, because there typically are simply too many cases to consider, and you will almost invariably forget at least one of them. Especially if you are used to imperative programming, it is easy to fall into the trap of *ignoring general cases*. For example, many beginners can correctly write a Prolog predicate that describes a *list*:

```prolog
list([]).
list([_|Ls]) :-
        list(Ls).
    
```

This is a very general relation that works in all directions. For example:

```prolog
    
?- list("abc").
   true.

?- list(Ls).
   Ls = []
;  Ls = [_A]
;  Ls = [_A,_B]
;  ... .

?- list(true).
   false.
    
```

After seeing they can actually affect the control flow of Prolog with `!/0`, many beginners will *incorrectly* apply this construct in cases where it *cuts away solutions*. For example, from a quick first glance, it may appear that the two clauses are *mutually exclusive*. After all, a list is *either* empty or has at least one element, right? And so [*the horror*](30-horror.md) begins when you write:

```prolog
list([]) :- !. % incorrect!
list([_|Ls]) :-
        list(Ls).
    
```

A quick test case "confirms" that *everything* still works:

```prolog
?- list("abc").
   true.
    
```

The *flaw* in this reasoning is that the clauses are in fact *not* mutually exclusive. They are only exclusive if the argument is *sufficiently instantiated*! In Prolog, there are *more general cases* than you may be used to from other programming languages. For example, with the broken definition, we get:

```prolog
?- list(Ls).
   Ls = []. % incompleteness!
    
```

Thus, instead of an *infinite* set of solutions, the predicate now only describes a *single* solution! To truly benefit from declarative programming, stay in the [pure](11-purity.md) subset. Use *pattern matching* or meta-predicates like [`if_/3`](10-metapredicates.md#if_3) to efficiently express logical alternatives while retaining full generality of your relations.

## `flatten/2` is no relation

In some introductory Prolog courses, you will be required to implement a predicate called `flatten/2`. In such cases, consider the following query:

```prolog
?- flatten(Xs, Ys).
    
```

What is a valid answer in such situations? Suppose your predicate answers as follows:

```prolog
Ys = [Xs].
    
```

From a declarative point of view, this answer is **wrong**! The reason is that `Xs` may as well be a list, and in such cases, the result is *not flattened*! Witness the evidence for yourself:

```prolog
?- flatten(Xs, Ys), Xs = "a".
   Xs = "a", Ys = ["a"].
    
```

Thus, `Y` is *not* a flat list, but a *nested* list! In contrast, exchanging the goals yields:

```prolog
?- Xs = "a", flatten(Xs, Ys).
   Xs = Ys, Ys = "a".
    
```

This means that exchanging the order of goals *changes* the set of solutions. Your instructor should be able to understand this fundamental declarative shortcoming if you point it out. In practice, use `append/2` to remove precisely one level of nesting in a sound way.

## Iterative deepening is often a good strategy

Prolog's default search strategy is *incomplete*, and we can often easily make it *complete* by turning it into *iterative deepening*. This means that we search for solutions of depth 0, then for those of depth 1, then for those of depth 2, etc. From a quick first glance, this may seem very inefficient to you, because we are visiting the same solutions over and over, although we need each of them only *once*. Now consider a search tree of depth *k*, with a branching factor of *b*. With iterative deepening up to and including depth *k*, we visit the *root* node *k+1* times, since we start at depth 0, and revisit the root in each iteration, up to *k*. Further, we visit the *b* nodes at depth 1 exactly *k* times. In general, we visit the *b*^(*j*) nodes at depth *j* (0≤*j*≤*k*) exactly *k*+1−*j* times. Let us now sum this up to calculate the total number of visits: *b*⁰(*k*+1) + *b*¹*k* + *b*²(*k*−1) + … +*b*^(*k*). Now the point: This sum is asymptotically *dominated* (**Exercise:** Why?) by the number of visits at the final depth *k*, where we visit *b*^(*k*) nodes, each exactly *once*. This shows that iterative deepening is in fact an asymptotically *optimal* search strategy under very general assumptions, because *every* uninformed search strategy must visit these *b*^(*k*) nodes at least once for completeness. It also shows that people usually *underestimate* what exponential growth really means. If you find yourself in a situation where you really need to traverse such a search tree, iterative deepening is often a very good strategy, combining the memory efficiency of depth-first search with the *completeness* of breadth-first search. In addition, iterative deepening is easy to implement in Prolog via its built-in backtracking. Note that iterative deepening requires *monotonicity*!
