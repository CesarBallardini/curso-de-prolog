# Sorting and Searching with Prolog

Indeed, I believe that virtually *every* important aspect of programming arises somewhere in the context of sorting or searching! ([Donald Knuth](http://www-cs-faculty.stanford.edu/~uno/), *The Art of Computer Programming*, Volume 3, "Sorting and Searching")

## Standard order of terms

The **standard order of terms** imposes the following *order* on Prolog [terms](04-data.md#term):

variables ≺ numbers ≺ atoms ≺ compound terms

It is subject to the following additional rules:

1.  Numbers are compared by value.
2.  All floating point numbers precede all integers.
3.  Atoms are compared alphabetically.
4.  Compound terms are first sorted by their arity, then alphabetically by their functor name, and finally recursively by their arguments, leftmost argument first.

To compare arbitrary terms according to the standard order, use the predicates `(@<)/2`, `(@=<)/2`, `compare/3` and others. A major drawback of these predicates is that they are not true relations. For example:

```prolog
?- a @< b.
   true.
    
```

Yet the *more general* query *fails*:

```prolog
?- a @< X.
   false.
    
```

This violates properties we expect from [pure](11-purity.md) predicates and prevents [declarative debugging](13-debugging.md). Therefore, it is good practice to use dedicated comparison predicates with more declarative properties for specific domains. For example, in the case of *integers*, use the CLP(FD) [constraints](clpfd#constraint) `(#<)/2`, `(#=<)/2` and `zcompare/3` instead, in addition to other relations that are provided by your Prolog system.

## Sorting Prolog terms

The ISO predicates `sort/2` and `keysort/2` are the most important predicates for *sorting* arbitrary Prolog terms. Both predicates refer to the [standard order](#order) of terms. In particular:

- `sort(Ls0, Ls)` is true iff the [list](04-data.md#list) `Ls` holds the elements of the list `Ls0`, sorted according to the standard order of terms. `Ls` contains *no duplicates*.
- `keysort(Pairs0, Pairs)`: `Pairs0` and `Pairs` are lists of `Key-Value` [pairs](04-data.md#pair). True iff `Pairs0` sorted by `Key` according to the standard order of terms is `Pairs`, where duplicates are *retained*, and the order of multiple elements with the same key is *also* retained. A sorting algorithm where the relative positions of equal elements are retained is called *stable*.

`keysort/2` in particular is much more useful than it may look at first. For example, let us sort the following lists by their *lengths*:

```prolog
lists(["abcd",
       "abc",
       "abcde",
       "a",
       "ab"]).
    
```

To solve this task, let us first define a relation between a single list and a [pair](04-data.md#pair) of the form `Length-List`, which is simply infix notation for the Prolog term `-(Length, List)`. We define this relation by using the predicate [list_length/2](clpfd#list_length) that we defined earlier:

```prolog
list_pair(Ls, L-Ls) :-
        list_length(Ls, L).      
    
```

Using [`maplist/3`](10-metapredicates.md#maplist), we can *lift* this relation to *lists* of lists and pairs:

```prolog
?- lists(Lists),
   maplist(list_pair, Lists, Pairs0).
   Lists = ["abcd","abc","abcde","a","ab"],
   Pairs0 = [4-"abcd",3-"abc",5-"abcde",1-"a",2-"ab"].
    
```

This representation makes `keysort/2` applicable to sort the lists according to their *lengths*:

```prolog
?- lists(Lists),
   maplist(list_pair, Lists, Pairs0),
   keysort(Pairs0, Pairs).
   Lists = ["abcd","abc","abcde","a","ab"],
   Pairs0 = [4-"abcd",3-"abc",5-"abcde",1-"a",2-"ab"],
   Pairs = [1-"a",2-"ab",3-"abc",4-"abcd",5-"abcde"].
    
```

Thus, to obtain a list `Ls` with *minimum* length, we can simply write `Pairs = [_-Ls|_]`. To obtain a list with *maximum* length, we have the following options: Either we define the relation between a list and its *last* element, *or* we modify `list_pair/2` to use the *negated* length as the *key* of each pair, and again take the *first* element of the keysorted list. Negating the length ensures that a list with *maximum* length appears as part of the first pair. In general, by constructing *pairs* with suitable *keys*, you can delegate sorting to `keysort/2` in a way that suits your application.

## Implementing sorting algorithms in Prolog

Sometimes, you want to implement your *own* version of a [sorting algorithm](https://en.wikipedia.org/wiki/Sorting_algorithm) in Prolog. Prolog implementations of the following sorting algorithms are available in [**`sorting.pl`**](/misc/sorting.pl):

- bubble sort
- quicksort
- merge sort.

A few benchmarks and comments are also included. In particular, consider how naturally *quicksort* can be described in Prolog with a [DCG](14-dcg.md):

```prolog
quicksort([])   --> [].
quicksort([L|Ls]) -->
        { partition(Ls, L, Smallers, Biggers) },
        quicksort(Smallers),
        [L],
        quicksort(Biggers).
    
```

This definition assumes the existence of `partition/4`, relating a list `Ls` to its elements that are, respectively, smaller and greater than the *pivot element* `L`. In general, it is often better to simply use the built-in predicates `sort/2` and `keysort/2` for sorting.

## Searching with Prolog

There is an intimate connection between Prolog and *searching*. First, Prolog's execution strategy is already a form of *search*. It is called *depth-first search* with chronological backtracking and can be regarded as a special case of *resolution*. Prolog is eminently well-suited for solving search tasks already due to this efficient built-in implementation of backtracking. Second, other search strategies can be readily implemented *on top* of the built-in strategy. For example, it is easy to obtain *iterative deepening* by restricting some aspects of the search. Many Prolog programs *search* for something, such as [proofs](25-theoremproving.md) and counterexamples, or solutions of [optimization tasks](20-optimization.md) or [logic puzzles](26-puzzles.md). Still, it is often better to think about these programs as—first and foremost—*describing* the desired properties of a solution. This leads to a more declarative view that lets you use these programs also in *other* directions. For example, suppose we want to *find* the minimum of a list of [integers](clpfd). This is an *imperative* view that expresses only one aspect of the following more general task: Let us *describe the relation* between a list of integers and its minimum. In Prolog, we can define this relation as:

```prolog
list_minimum([L|Ls], Min) :- foldl(minimum_, Ls, L, Min).

minimum_(A, B, Min) :- Min #= min(A, B).
    
```

This works in several directions:

```prolog
?- list_minimum([3,1,2], M).
   M = 1.

?- list_minimum([A,B], 0).
   clpz:(B in 0..sup),
   clpz:(0#=min(B,A)),
   clpz:(A in 0..sup).
    
```

Thus, when working on search tasks, do not get carried away with an imperative view. Instead, focus on a clear general description of all relations you want to define. In some cases, searching *naively* is not efficient enough. Not in Prolog *and also* not in other languages. Here is an example: Let us consider the *complete [graph](20-optimization.md#graph)* of order *n*, which is abbreviated as K_(*n*). Its *adjacency list* can be defined as:

```prolog
k_n(N, Adjs) :-
        list_length(Nodes, N),
        Nodes ins 1..N,
        all_distinct(Nodes),
        once(label(Nodes)),
        maplist(adjs(Nodes), Nodes, Adjs).

adjs(Nodes, Node, Node-As) :-
        tfilter(dif(Node), Nodes, As).
    
```

In particular, we obtain for K₃:

```prolog
?- k_n(3, Adjs).
   Adjs = [1-[2,3],2-[1,3],3-[1,2]]
;  ... .
    
```

As another example, K₆ looks like this:

Let us now solve the following task: *Which nodes are reachable from a particular node, in a reflexive and transitive way?* Or slightly more generally, what is the *reflexive transitive closure* of a set of nodes? In Prolog, we can write this as:

```prolog
reachable(_, _, From, From).
reachable(Adjs, Visited, From, To) :-
        maplist(dif(Next), Visited),
        member(From-As, Adjs),
        member(Next, As),
        reachable(Adjs, [From|Visited], Next, To).
    
```

To compute the *set* of solutions, we can use [`setof/3`](10-metapredicates.md#solutions). For example, all nodes that are reachable from node 1:

```prolog
?- k_n(3, Adjs),
   setof(To, reachable(Adjs, [], 1, To), Tos).
   Adjs = [1-[2,3],2-[1,3],3-[1,2]], Tos = [1,2,3]
;  false.
    
```

The major drawback of this approach is that it *doesn't scale well*. In particular, we have:

```prolog
?- list_length(_, N), portray_clause(N),
   k_n(N, Adjs),
   time(setof(To, reachable(Adjs, [], 1, To), Tos)),
   false.
...
6.
   % CPU time: 0.171s
7.
   % CPU time: 1.454s
8.
   % CPU time: 13.628s
9.
    
```

This is because the number of *paths* in this graph increases *super-exponentially* in the number of *nodes*, and the naive solution traverses *all paths*. This approach quickly becomes too slow, no matter which language you use to implement it. In this concrete case, we can solve the task in a much more efficient way. For example, we can use Warshall's algorithm for computing the transitive closure, with code similar to:

```prolog
warshall(Adjs, Nodes0, Nodes) :-
        phrase(reachables(Nodes0, Adjs), Nodes1, Nodes0),
        sort(Nodes1, Nodes2),
        if_(Nodes2 = Nodes0,
            Nodes = Nodes2,
            warshall(Adjs, Nodes2, Nodes)).

reachables([], _) --> [].
reachables([Node|Nodes], Adjs) -->
        { member(Node-Rs, Adjs) },
        Rs,
        reachables(Nodes, Adjs).
    
```

Note how [`sort/2`](#sort) is used to *remove duplicates* from a list, and to obtain a canonical representation of the *set* of nodes that have already been found. Sample query:

```prolog
?- k_n(9, Adjs),
   time(warshall(Adjs, [1], Tos)).
   % CPU time: 0.000s
   ...,
   Tos = [1,2,3,4,5,6,7,8,9]
;  ... .
    
```

This is clearly much more efficient. By implementing intelligent strategies, you can obtain elegant and efficient Prolog solutions for many search tasks.

## Pruning the search

Let us consider the special case of sorting a list of *integers* without duplicates. In Prolog, we can implement this as a *relation* between two lists. Let us call the relation `integers_ascending/2`, to make clear that it can ideally not only be used to *sort*, but also to *check* and *generate* solutions. Declaratively, the conditions that must hold for `integers_ascending(Is0, Is)` are:

1.  `Is0` contains no duplicates
2.  `Is` is a *permutation* of `Is0`
3.  the elements of `Is` are in *ascending* order.

We start with part (3), by defining what we mean by a list of *ascending* integers:

```prolog
ascending([]).
ascending([I|Is]) :-
        foldl(ascending_, Is, I, _).

ascending_(I, Prev, I) :- Prev #< I.
    
```

For (2), we assume the availability of a predicate `permutation/2`, relating a list to all its permutations on backtracking. Implementing it is left as an exercise. Using these building blocks, we are ready to define `integers_ascending/2`:

```prolog
integers_ascending(Is0, Is) :-
        all_distinct(Is0),
        permutation(Is0, Is),
        ascending(Is).
    
```

This predicate implements a very naive sorting method called *permutation sort*: Operationally, it *generates* a permutation, and succeeds *iff* the elements of the permutation are in *ascending* order. This approach is called *generate and test*. It works well for small examples, such as:

```prolog
?- integers_ascending([3,1,2], Is).
   Is = [1,2,3]
;  false.
    
```

However, this method is *extremely* inefficient for longer lists: A list of length N has N! permutations, and so the worst-case running time increases *super-exponentially* in the length of the list. For example:

```prolog
?- time(integers_ascending([10,9,8,7,6,5,4,3,2,1], Ls)).
   % CPU time: 10.109s
   Ls = [1,2,3,4,5,6,7,8,9,10]
;  ... .
    
```

We can *massively* improve the running time by reordering the goals:

```prolog
integers_ascending(Is0, Is) :-
        all_distinct(Is0),
        ascending(Is),
        permutation(Is0, Is).
    
```

With this simple change, we obtain:

```prolog
?- time(integers_ascending([10,9,8,7,6,5,4,3,2,1], Ls)).
   % CPU time: 0.184s
   Ls = [1,2,3,4,5,6,7,8,9,10]
;  ... .
    
```

By first stating the requirement that the list elements be in *ascending* order, the subsequent search for permutations is automatically *pruned* as soon as the system can deduce that any partially completed permutation can no longer lead to a full solution because it violates the posted constraints. Note that even though combining search with early pruning can lead to tremendous performance improvements over generating all possibilities, dedicated algorithms that are carefully tailored to the task at hand are typically even more efficient. For example, in the concrete case of sorting a list of integers, you can simply use [`sort/2`](#sort) for a solution with asymptotically optimal performance for a comparison-based search. On the other hand, the *price* of using a specialized algorithm is often *generality*. For example, in the following case, `sort/2` omits one of the two possible solutions:

```prolog
?- sort([X,Y], [1,2]).
   X = 1, Y = 2.
    
```

In contrast, `integers_ascending/2` yields *all* solutions:

```prolog
?- integers_ascending([X,Y], [1,2]).
   X = 1, Y = 2
;  X = 2, Y = 1
;  false.
    
```

*Ceteris paribus*, it is good practice to keep your programs as general as you can.
