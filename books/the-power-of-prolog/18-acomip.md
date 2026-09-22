# A Couple of Meta-interpreters in Prolog

## Motivation

Informally, an interpreter is a program that evaluates programs. Interpretation is pervasive in computer science both from a theoretical and practical perspective, and many programs are interpreters for domain-specific languages. For example, a program reading settings from a configuration file and adjusting itself accordingly is interpreting this "configuration language". An interpreter for a language similar or identical to its own implementation language is called *meta-interpreter* (MI). An interpreter that can interpret itself is called *meta-circular*. Prolog is exceptionally well-suited for writing MIs: First and most importantly, Prolog programs can be naturally represented as Prolog [terms](04-data.md#term) and are easily inspected and manipulated using [built-in](03-concepts.md#builtins) mechanisms. Second, Prolog's implicit computation strategy and all-solutions predicates can be used in interpreters, allowing for concise specifications. Third, variables from the object-level (the program to be interpreted) can be treated as variables on the meta-level (the interpreter); therefore, an interpreter can delegate handling of the interpreted program's binding environment to the underlying Prolog engine.

*Video*: [Prolog Meta-interpreters](https://www.metalevel.at/prolog/videos/meta_interpreters)

The following simple Prolog program will serve as a running example throughout this text. I state it here using default Prolog syntax, and we will subsequently consider various different representations for it:

```prolog
natnum(0).
natnum(s(X)) :-
        natnum(X).
    
```

Prolog can evaluate Prolog code dynamically:

```prolog
?- Goal = natnum(X), Goal.
   Goal = natnum(0), X = 0
;  Goal = natnum(s(0)), X = s(0)
;  ... .
    
```

You can make the call explicit using the built-in **[call/1](10-metapredicates.md#call)** predicate, yielding the equivalent query "?- Goal = natnum(X), call(Goal).". The **call/n** (n \> 1) family of predicates lets you append additional arguments to *Goal* before it is called. This mechanism ("*meta-call*") is used in predicates like **[maplist/3](10-metapredicates.md#maplist)**, **include/3**, **if/3** etc., and can be seen as interpretation in its coarsest sense. Implicitly using features of the underlying engine is called *absorption*. Making features explicit is called *reification*. By using **call/1**, we absorb backtracking, unification, handling of conjunctions, the call stack etc. We can make all these features explicit and subsequently adjust and extend them at will.

## Vanilla MIs

### Accessing Prolog code

The definition of **natnum/1** consists of two clauses, the first of which degenerated into a *fact* that is implicitly treated as if it were stated as

```prolog
natnum(0) :- true.
    
```

The Prolog built-in **clause/2** allows inspection of the predicate's definition:

```prolog
?- clause(natnum(Z), Body).
   Z = 0, Body = true
;  Z = s(_A), Body = natnum(_A).
    
```

**Note**: Clause inspection requires the predicate to be *public*. A portable way to declare predicates public is to use the `dynamic/1` directive, because dynamic predicates are automatically public. The two solutions found on backtracking correspond to the two clauses of the predicate's definition. Another example:

```prolog
complicated_clause(A) :-
        goal1(A),
        goal2(A),
        goal3(A).

?- clause(complicated_clause(Z), Body).
Body = (goal1(Z), goal2(Z), goal3(Z)).
    
```

The body of **complicated_clause/1** is represented by a compound term with functor ',' and arity 2, whose arguments are either goals or compound terms of the same structure. Here is a Prolog "type" definition of a clause body in the default representation:

```prolog
body(true).
body((A,B)) :-
        body(A),
        body(B).
body(G) :-          % ambiguous, also matches "true" and "(_,_)"
        goal(G).

goal(_ = _).
goal(call(_)).
% ... etc.
    
```

We can thus define an interpreter for pure Prolog programs:

```prolog
mi1(true).
mi1((A,B)) :-
        mi1(A),
        mi1(B).
mi1(Goal) :-
        Goal \= true,
        Goal \= (_,_),
        clause(Goal, Body),
        mi1(Body).
    
```

This is often called *vanilla MI* because there's nothing special to it. All MIs that add no ability to pure Prolog are sometimes called vanilla MIs. They serve as skeletons for extensions. We can use this MI to run our example program:

```prolog
?- mi1(natnum(X)).
   X = 0
;  X = s(0)
;  X = s(s(0))
;  ... .
    
```

### Using a clean representation

In the preceding MI, we had to guard the third clause from matching **true/0** or conjunctions to prevent run-time errors resulting from calling **clause/2** with these arguments. This is ugly, and we can make it uglier still by using cuts (**!/0**) in the first two clauses. That would at least remove unnecessary choice-points, though typically not prevent their creation. Instead of recognising goals by indication of what they are, we had to introduce a "default" case and specify what they aren't. Such representations are called *"[defaulty](04-data.md#clean)"*. To fix this, we equip goals with the (arbitrary) functor *g*:

```prolog
body(true).
body((A,B)) :-
        body(A),
        body(B).
body(g(G)) :-
        goal(G).
    
```

Such a representation is called *clean*. We rewrite our example according to this specification:

```prolog
natnum_clean(0).
natnum_clean(s(X)) :-
        g(natnum_clean(X)).
    
```

While a query like "`?- natnum_clean(X).`" would yield a runtime error (there is no predicate **g/1**), we can use an MI to interpret the program:

```prolog
mi2(true).
mi2((A,B)) :-
        mi2(A),
        mi2(B).
mi2(g(G)) :-
        clause(G, Body),
        mi2(Body).
    
```

In addition to being shorter and *cleaner*, this version is typically more efficient (no choice-points due to first-argument indexing, and fewer inferences due to fewer tests):

```prolog
?- integer_natnum(10^6, T), time(mi1(natnum(T))).
   % CPU time: 1.950s, 16_000_015 inferences
   T = s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(...)))))))))))))))))))))
;  ... .


?- integer_natnum(10^6, T), time(mi2(g(natnum_clean(T)))).
   % CPU time: 1.442s, 11_000_010 inferences
   T = s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(...)))))))))))))))))))))
;  ... .
    
```

In the following, **mi_clause/2** denotes a predicate that is similar to **clause/2**, except that it supplies us with an "appropriate" (MI-dependent) representation of clause bodies. For the MI at hand:

```prolog
mi_clause(G, Body) :-
        clause(G, B),
        defaulty_better(B, Body).

defaulty_better(true, true).
defaulty_better((A,B), (BA,BB)) :-
        defaulty_better(A, BA),
        defaulty_better(B, BB).
defaulty_better(G, g(G)) :-
        G \= true,
        G \= (_,_).
    
```

This predicate lets us interpret a subset of normal Prolog code with the second MI, and it can also be used for static conversion. Alternatively, **mi_clause/2** can be defined by facts. For this MI:

```prolog
mi_clause(natnum(0), true).
mi_clause(natnum(s(X)), g(natnum(X)).
    
```

### Variants and modifications

The 2 MIs presented so far *reify* conjunction. Through **clause/2**, they *absorb* unification and backtracking. Having made handling of conjunctions explicit, we can reverse the default execution order of goals:

```prolog
mi3(true).
mi3((A,B)) :-
        mi3(B),        % first B, then A
        mi3(A).
mi3(g(G)) :-
        mi_clause(G, Body),
        mi3(Body).
    
```

From a logical point of view, this changes nothing (conjunction is commutative). Procedurally, there's a difference: With minor adjustments to **mi_clause/2** (adding the fact "defaulty_better(false, false)." and guarding *G* against the atom **false/0**), this MI can be used to prove that the query "?- declarative_false." cannot succeed given the predicate's definition:

```prolog
declarative_false :-
        declarative_false,
        false.
    
```

This can't be derived with the standard execution order. We can ask the user before we execute goals (*tracing*), print out the execution history or restrict access to safe goals by adjusting the third clause:

```prolog
mi2_safe(g(G)) :-
        (   safe_goal(G) ->
            mi_clause(G, Body),
            mi2_safe(Body)
        ;   throw(cannot_execute(G))
        ).
    
```

We can obtain a simpler MI by using lists of goals to represent conjunctions. In this representation, **true/0** becomes the empty list:

```prolog
natnum_list(0, []).
natnum_list(s(X), [natnum_list(X)]).
    
```

Again, the conversion between runnable Prolog code and this representation can be performed automatically:

```prolog
mi_clause(G, Ls) :-
        clause(G, Body),
        phrase(body_list(Body), Ls).


body_list(true)  --> [].
body_list((A,B)) -->
        body_list(A),
        body_list(B).
body_list(G) -->
        { G \= true },
        { G \= (_,_) },
        [G].
    
```

An obvious MI for this representation consists of only 2 clauses:

```prolog
mi_list1([]).
mi_list1([G|Gs]) :-
        mi_clause(G, Body),
        mi_list1(Body),
        mi_list1(Gs).
    
```

We can make it tail-recursive:

```prolog
mi_list2([]).
mi_list2([G0|Gs0]) :-
        mi_clause(G0, Body),
        append(Body, Gs0, Gs),
        mi_list2(Gs).
    
```

The difference:

```prolog
always_infinite :-
        always_infinite.

?- mi_list1([always_infinite]).
ERROR: Out of local stack

?- mi_list2([always_infinite]).  % loops, constant stack space
    
```

Using list differences in our clause representation, appending the yet-to-be-proved goals can be fused with expanding a goal:

```prolog
mi_ldclause(natnum(0), Rest, Rest).
mi_ldclause(natnum(s(X)), [natnum(X)|Rest], Rest).


mi_list3([]).
mi_list3([G0|Gs0]) :-
        mi_ldclause(G0, Remaining, Gs0),
        mi_list3(Remaining).

    
```

Example query:

```prolog
?- mi_list3([natnum(X)]).
   X = 0
;  X = s(0)
;  X = s(s(0))
;  ... .
    
```

### A meta-circular MI

Here is an MI that can handle the built-in predicates **clause/2** and **(\\)/2**:

```prolog
mi_circ(true).
mi_circ((A,B)) :-
        mi_circ(A),
        mi_circ(B).
mi_circ(clause(A,B)) :-
        clause(A,B).
mi_circ(A \= B) :-
        A \= B.
mi_circ(G) :-
        G \= true,
        G \= (_,_),
        G \= (_\=_),
        G \= clause(_,_),
        clause(G, Body),
        mi_circ(Body).
    
```

It can interpret its own source code and is thus a *meta-circular* interpreter:

```prolog
?- mi_circ(mi_circ(natnum(X))).
   X = 0
;  X = s(0)
;  X = s(s(0))
;  ... .
    
```

### Reasoning about programs

Let us define a predicate `provable/2` as follows: **provable(Goal, Defs)** is true if *Goal* is *provable* with respect to the definitions *Defs*, which is a list of clauses represented as terms of the form *Head-Body*. In comparison to the other MIs shown so far, the main difference is thus that the clauses are made available *explicitly* as an argument of the predicate. In addition, we generalize the handling of built-in predicates by using **predicate_property/2** to identify them as such for calling them directly:

```prolog
provable(true, _).
provable((A,B), Defs) :-
        provable(A, Defs),
        provable(B, Defs).
provable(g(Goal), Defs) :-
        (   predicate_property(Goal, built_in) ->
            call(Goal)
        ;   member(Def, Defs),
            copy_term(Def, Goal-Body),
            provable(Body, Defs)
        ).
    
```

Note that we need to use `copy_term/2` to replace variables by fresh copies. Also, how the built-in predicate **!/0** is interpreted by this MI does not match its intended meaning, and building an MI that handles cuts correctly requires more work. With the following additional definitions, we can use this MI to identify *redundant facts* in some predicate definitions:

```prolog
redundant(Functor/Arity, Reds) :-
        functor(Term, Functor, Arity),
        findall(Term-Body, mi_clause(Term, Body), Defs),
        setof(Red, Defs^redundant_(Defs, Red), Reds).

redundant_(Defs, Fact) :-
        select(Fact-true, Defs, Rest),
        once(provable(g(Fact), Rest)).
    
```

Given the definitions

```prolog
as([]).
as([a]).   % redundant
as([a,a]). % redundant
as([A|As]) :-
        A = a,           % test built-in (=)/2
        true,            % test built-in true/0
        as(As).
    
```

we can ask for facts which are deducible from all (respective) remaining clauses and hence redundant:

```prolog
?- redundant(as/1, Rs).
Rs = [as([a]), as([a, a])].
    
```

Thus, MIs allow us to determine non-trivial properties of programs in some cases. Importantly, MIs give us the freedom to interpret each language construct *differently* than regular Prolog would do it. For example, using *abstract interpretation*, we can derive type and mode information of predicates. An example taken from Codish and Søndergaard 2002, *Meta-Circular Abstract Interpretation in Prolog* is in the [source file](acomip.pl). By fixpoint computation, we derive non-trivial facts about the Ackermann function over an abstract parity domain:

```prolog
?- ack_fixpoint(As).

As = [ack(odd, odd, odd), ack(odd, even, odd), ack(odd, one, odd), ack(even, odd, odd),
      ack(odd, zero, odd), ack(even, even, odd), ack(even, one, odd), ack(one, odd, odd),
      ack(even, zero, odd), ack(one, even, even), ack(one, one, odd), ack(one, zero, even),
      ack(zero, even, odd), ack(zero, odd, even), ack(zero, zero, one), ack(zero, one, even)].
    
```

Now consider the following query:

```prolog
?- dif(X, one), dif(X, zero), dif(Z, odd), ack_fixpoint(As), member(ack(X,Y,Z), As).
false.
    
```

This shows that `Ackermann(i, j)` is *odd and greater than 1* for all i \> 1.

### Reifying backtracking

Let us reify *backtracking* now. We need to make explicit all alternative clause bodies that are normally found on backtracking, collecting them deterministically using **findall/3**. A single alternative is represented as a list of goals, and the branches of computation that have yet to be explored as a list of alternatives. The interface predicate, **mi_backtrack/1**, takes a goal as its argument and creates the representation of the initial state of computation: A list, consisting of a single alternative, `[G0]`. Actually, the representation is `[G0]-G0`, and `G0` is also passed as the second argument to the worker predicate for reasons that will become clear shortly.

```prolog
mi_backtrack(G0) :- mi_backtrack_([[G0]-G0], G0).
    
```

To perform a single step of the computation, we first collect all clause bodies whose heads unify with the first goal of the first alternative. To all found clause bodies, the remaining goals of that first alternative are appended, thus obtaining new alternatives that we prepend to the other alternatives to give the new state of computation. Using the clause representation that makes use of list differences, and **findall/4** to append existing alternatives, this becomes:

```prolog
resstep_([A|As0], As) :-
        findall(Gs-G, (A = [G0|Rest]-G,mi_ldclause(G0,Gs,Rest)), As, As0).
    
```

Leaves of the computation, i.e., alternatives that we are done with, automatically vanish from the list of alternatives as there is no goal to be proved for them any more. The unification `A = [G0|Rest]-G` thus fails and only the other alternatives remain. The worker predicate:

```prolog
mi_backtrack_([[]-G|_], G).
mi_backtrack_(Alts0, G) :-
        resstep_(Alts0, Alts1),
        mi_backtrack_(Alts1, G).
    
```

If no goals remain to be proved for an alternative, a solution for the initial query is found and we report the bindings to the user. This is why we needed to pass around the user's query. The second clause describes how the computation is carried on: The list of alternatives is transformed as described above, and the process continues. Representing all alternatives explicitly allows us to guide the inference process by reordering alternatives, implement fair execution strategies (by *appending* new alternatives) and so on. Also, the MI shows what is needed to implement Prolog in languages that lack built-in backtracking.

## Extending Prolog

### Showing proofs

If you want a feature that plain Prolog does not provide, you can add it to a vanilla MI. Here is an MI that behaves like standard pure Prolog and builds a *proof-tree* in parallel that makes explicit the inferences that lead to the proof:

```prolog
:- op(750, xfy, =>).

mi_tree(true, true).
mi_tree((A,B), (TA,TB)) :-
        mi_tree(A, TA),
        mi_tree(B, TB).
mi_tree(g(G), TBody => G) :-
        mi_clause(G, Body),
        mi_tree(Body, TBody).
    
```

Example query:

```prolog
?- mi_tree(g(natnum(X)), T).
   T = true=>natnum(0), X = 0
;  T = (true=>natnum(0))=>natnum(s(0)), X = s(0)
;  T = ((true=>natnum(0))=>natnum(s(0)))=>natnum(s(s(0))), X = s(s(0))
;  ... .
    
```

### Changing the search strategy

Another group of extensions aims to improve the incomplete default computation strategy. We start with an MI that limits the depth of the search tree, using [integer arithmetic](/prolog/clpfd):

```prolog
mi_limit(Goal, Max) :-
        mi_limit(Goal, Max, _).

mi_limit(true, N, N).
mi_limit((A,B), N0, N) :-
        mi_limit(A, N0, N1),
        mi_limit(B, N1, N).
mi_limit(g(G), N0, N) :-
        N0 #> 0,
        N1 #= N0 - 1,
        mi_clause(G, Body),
        mi_limit(Body, N1, N).
    
```

Example query:

```prolog
?- mi_limit(g(natnum(X)), 3).
   X = 0
;  X = s(0)
;  X = s(s(0))
;  false.
    
```

As expected, the number of solutions coincides with the maximal depth of the search tree in the case of **natnum/1**. Based on this MI, we can implement a *complete* search strategy, *iterative deepening*:

```prolog
mi_id(Goal) :-
        length(_, N),
        mi_limit(Goal, N).
    
```

Consider the program:

```prolog
edge(a, b).
edge(b, a).
edge(b, c).

path(A, A, []).
path(A, C, [e(A,B)|Es]) :-
        edge(A, B),
        path(B, C, Es).
    
```

And the queries:

```prolog
?- path(a, c, Es).
ERROR: Out of local stack


?- mi_id(g(path(a, c, Es))).
   Es = [e(a,b),e(b,c)]
;  ... .
    
```

In contrast to depth-first search, iterative deepening finds a solution. At first glance, iterative deepening may seem a wasteful search technique because many nodes of the search tree are explored repeatedly. However, one can show that iterative deepening is in fact an *optimal* search strategy under very general assumptions. In a general search tree, the number of nodes at each level grows exponentially with the depth of the tree, and the time it takes to explore all nodes at the final depth is enough to cover the previously expended effort with a *constant* factor.

### Sound unification

Omission of the *occurs check* in the default unification algorithms of common Prolog implementations can lead to unsound inference:

```prolog
occ(X, f(X)).
    
```

Without occurs check, the query

```prolog
?- occ(A, A).
    
```

succeeds. We can use occurs check for unification of clause heads in an MI:

```prolog
mi_occ(true).
mi_occ((A,B)) :-
        mi_occ(A),
        mi_occ(B).
mi_occ(g(G)) :-
        functor(G, F, Arity),
        functor(H, F, Arity),
        mi_clause(H, Body),
        unify_with_occurs_check(G, H),
        mi_occ(Body).
    
```

We get:

```prolog
?- mi_occ(g(occ(A,A))).
   false.
    
```

You can use an MI similar to this one to reify the *binding environment* of variables: Thread the bindings through and add a term of the form `unify(G,H)` to the set of bindings in the third clause. Use **numbervars/3** to get rid of variables if you want to reify unification.

### Parsing with left-recursive grammars

As a consequence of Prolog's computation strategy, parsing with left-recursive grammars is problematic. Let us now define an MI that interprets [**Definite Clause Grammars**](14-dcg.md) in such a way that they can handle left-recursion. Consider a simple grammar:

```prolog
dcgnumber(0).
dcgnumber(1).

expr(N)   --> [N], { dcgnumber(N) }.
expr(A+B) --> expr(A), [(+)], expr(B).
    
```

This grammar can be used to (unfairly) enumerate an arbitrary number of strings it describes:

```prolog
?- phrase(expr(E), Ss).
   E = 0, Ss = [0]
;  E = 1, Ss = [1]
;  E = 0+0, Ss = [0,+,0]
;  ... .
    
```

However, parsing ground strings leads to problems:

```prolog
?- phrase(expr(E), [1,+,1]).
   E = 1+1
;  ERROR: Out of local stack
    
```

We first convert the grammar into a more suitable representation:

```prolog
dcg_clause(expr(N),   [t(N),{dcgnumber(N)}]).
dcg_clause(expr(A+B), [l,nt(expr(A)),t(+),nt(expr(B))]).
    
```

The atom `l` in the body of the second clause is used to capture that for this clause to apply, there must be at least one (therefore, *one* `l`) token left in the string to be parsed. This is used in the MI to prune the search tree if we run out of tokens. The other terms are: `t/1` for terminals, `nt/1` for non-terminals and `{}/1` for goals. The interface to the MI:

```prolog
mi_dcg(NT, String) :-
        length(String, L),
        length(Rest0, L),
        mi_dcg_([nt(NT)], Rest0, _, String, []).
    
```

The worker predicates:

```prolog
mi_dcg(t(T), Rest, Rest, [T|Ts], Ts).
mi_dcg({Goal}, Rest, Rest, Ts, Ts) :-
        call(Goal).
mi_dcg(nt(NT), Rest0, Rest, Ts0, Ts) :-
        dcg_clause(NT, Body),
        mi_dcg_(Body, Rest0, Rest, Ts0, Ts).
mi_dcg(l, [_|Rest], Rest, Ts, Ts).

mi_dcg_([], Rest, Rest, Ts, Ts).
mi_dcg_([G|Gs], Rest0, Rest, Ts0, Ts) :-
        mi_dcg(G, Rest0, Rest1, Ts0, Ts1),
        mi_dcg_(Gs, Rest1, Rest, Ts1, Ts).
    
```

We can now use the left-recursive grammar also for parsing:

```prolog
?- mi_dcg(expr(E), [1,+,1,+,1]).
   E = 1+(1+1)
;  E = 1+1+1
;  false.
    
```

### Further extensions

Other possible extensions are module systems, delayed goals, checking for various kinds of infinite loops, profiling, debugging, type systems, constraint solving etc. The overhead incurred by implementing these things using MIs can be compiled away using partial evaluation techniques. For instance, we can (mechanically) derive the following partially evaluated version of the DCG example:

```prolog
pe_expr(Expr, String) :-
        length(String, L),
        length(Rest0, L),
        pe_expr(Expr, Rest0, _, String, []).

pe_expr(N, Rest, Rest, Ts0, Ts) :-
        Ts0 = [N|Ts],
        dcgnumber(N).
pe_expr(A+B, [_|Rest0], Rest, Ts0, Ts) :-
        pe_expr(A, Rest0, Rest1, Ts0, Ts1),
        Ts1 = [+|Ts2],
        pe_expr(B, Rest1, Rest, Ts2, Ts).
    
```

Speed comparison:

```prolog
?- sum_of_ones(10^4, Ss), time(mi_dcg(expr(Sum), Ss)).
   % CPU time: 7.010s, 50_245_019 inferences
   ... .

?- sum_of_ones(10^4, Ss), time(pe_expr(Sum, Ss)).
   % CPU time: 0.016s, 70_012 inferences
   ... .
    
```

Source file containing all examples: [**acomip.pl**](acomip.pl) Written Sept. 14th 2005
