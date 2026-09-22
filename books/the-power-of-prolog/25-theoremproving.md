# Theorem Proving with Prolog

First, I realized that the beautiful theorems of Sturm and Liouville are of no use whatsoever. (Gian-Carlo Rota, [Ten lessons I wish I had learned before I started teaching differential equations](https://web.williams.edu/Mathematics/lg5/Rota.pdf))

Is Prolog a **theorem prover**? Richard O'Keefe said it best:

> Prolog is an efficient programming language because it is a very stupid theorem prover.

Thus, there is a *connection* between Prolog and theorem proving. In fact, execution of a Prolog program can be regarded as a special case of *resolution*, called SLDNF resolution. However, Prolog is *not* a full-fledged theorem prover. In particular, Prolog is logically *incomplete* due to its depth-first search strategy: Prolog may be unable to find a resolution refutation even if one exists. **But**, and that is the critical point, we can of course **implement** theorem provers in Prolog! This is because Prolog is a Turing complete **programming language**, and every theorem prover that can be implemented on a computer can *also* be implemented in Prolog. Theorem provers often require some kind of [*search*](15-sorting.md#searching), such as a search for *proofs* or *counterexamples*. It is very easy to implement various search strategies in Prolog: We *can*, but need not, reuse its built-in depth-first search. Here as an example of a theorem prover written in Prolog, implementing the *resolution calculus* for **propositional logic**:

```prolog
pl_resolution(Clauses0, Chain) :-
        maplist(sort, Clauses0, Clauses), % remove duplicates
        length(Chain, _),
        pl_derive_empty_clause(Chain, Clauses).

pl_derive_empty_clause([], Clauses) :-
        member([], Clauses).
pl_derive_empty_clause([C|Cs], Clauses) :-
        pl_resolvent(C, Clauses, Rs),
        pl_derive_empty_clause(Cs, [Rs|Clauses]).

pl_resolvent((As0-Bs0) --> Rs, Clauses, Rs) :-
        member(As0, Clauses),
        member(Bs0, Clauses),
        select(Q, As0, As),
        select(not(Q), Bs0, Bs),
        append(As, Bs, Rs0),
        sort(Rs0, Rs), % remove duplicates
        maplist(dif(Rs), Clauses).
    
```

The complete file is available from [**`plres.pl`**](/logic/plres.pl). Here is an example query, using `portray_clause/1` to print the resulting refutation chain in such a way that any subsequent program that *verifies* the proof can easily read it with the built-in predicate `read/1`:

```prolog
?- Clauses = [[p,not(q)], [not(p),not(s)], [s,not(q)], [q]],
   pl_resolution(Clauses, Rs),
   maplist(portray_clause, Rs).
    
```

It leads to the following refutation chain:

```prolog
[p, not(q)]-[not(p), not(s)] -->
    [not(q), not(s)].
[s, not(q)]-[not(q), not(s)] -->
    [not(q)].
[q]-[not(q)] -->
    [].
    
```

Note in particular:

- We are *not* using Prolog's built-in search strategy as the search strategy of the prover! In this case, the prover uses **iterative deepening** to guarantee *refutation-completeness*: *If* a refutation exists, *then* it is found. Iterative deepening is easy to implement in Prolog, since `length/2` creates longer and longer lists on backtracking, and they can be used for limiting the search. Iterative deepening may seem like a very inefficient search strategy at first glance, but it is in fact an *optimal* search strategy under very general assumptions.

- We are *not* using Prolog variables to represent variables from the object level! In this case, Prolog *atoms* represent propositional variables. This is called a **ground representation** of variables. If we use Prolog variables instead, then we can use [**Boolean constraints**](/clpb/) as an alternative solution method for showing that the formula is unsatisfiable:

  ```prolog
  ?- sat(P + ~Q), sat(~P + ~S), sat(S + ~Q), sat(Q).
     false.
          
  ```

  The choice of [data representation](04-data.md) can thus significantly influence how we can reason about such formulas.

Therefore, when discussing theorem provers that are implemented using Prolog, we must keep in mind that the way Prolog works internally can differ significantly from the *implemented* behaviour of the prover itself: Its search strategy, its representation of variables, its logical properties, and indeed anything at all can differ from the way Prolog—regarded as a simplistic theorem prover—works internally, since we are using Prolog only as one of many possible implementation languages for theorem provers. That being said, many properties make Prolog an *especially suitable* language for *implementing* theorem provers. For example:

- Prolog's built-in **search** and **backtracking** can be readily used when searching for proofs and counterexamples
- **complete** search strategies, such as iterative deepening, can be easily expressed in Prolog
- Prolog's **logic variables** can often be used to represent variables from the object level, allowing us to *absorb* built-in Prolog features like **unification**
- built-in **constraints** allow for declarative **specifications** that often lead to very elegant and efficient programs.

Other examples of theorem provers implemented in Prolog are:

- [**Presprover**](/presprover/): Proves formulas of *Presburger arithmetic*
- [**TRS**](/trs/): Implements a completion procedure for *Term Rewriting Systems* in Prolog.

New combinatorial theorems that were recently established with the help of Prolog are described in [*You need 27 tickets to guarantee a win on the UK National Lottery*](https://arxiv.org/abs/2307.12430v1) and [*A Prolog assisted search for new simple Lie algebras*](https://arxiv.org/abs/2207.01094). Many [logic puzzles](26-puzzles.md) can be solved by applying some form of theorem proving.
