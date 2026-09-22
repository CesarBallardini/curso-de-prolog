# Termination

In Prolog, there are *two kinds* of **termination**:

- **existential** termination
- **universal** termination.

Although both properties are [*undecidable*](https://en.wikipedia.org/wiki/Undecidable_problem) in general, we can often derive interesting insights already by observation alone. In the following, we assume that *no exceptions* arise during the computation.

## Existential termination

A Prolog query `Q` **terminates existentially** *iff* we receive an *answer* when posting `Q`. For example, the following query *terminates existentially*, because an answer is reported:

```prolog
?- length(Ls, L).
Ls = [],
L = 0 .
    
```

If Prolog were a functional programming language, this would be the end of the story, because a (partial) function returns at most *one* result. However, Prolog is a *relational* programming language, and relations can hold between *multiple* entities that are reported on backtracking. Therefore, *existential* termination does not fully characterize the procedural behaviour of a Prolog query.

## Universal termination

A Prolog query `Q` **terminates universally** *iff* the query

```prolog
?- Q, false.
    
```

terminates *existentially*. Declaratively, the query `?- Q, false.` is always *false*. For this reason, *if* an answer is eventually reported, then the answer is necessarily `false`.

## More about termination

Consider again the definition of [`list_list_together/3`](05-reading.md#list_list_together3), which is true if the third argument is the *concatenation* of the lists in the first and second argument:

```prolog
list_list_together([], Bs, Bs).
list_list_together([A|As], Bs, [A|Cs]) :-
        list_list_together(As, Bs, Cs).
    
```

Notice that the simpler of the two cases, i.e., the *fact* that occurs in this definition, has *no influence* on the universal termination properties of this predicate. It is therefore **wrong** to call this fact a "termination condition", "stopping criterion" or anything related. The following fragment alone already makes the most general query *nonterminating* in this case:

```prolog
list_list_together([], Bs, Bs) :- false.
list_list_together([A|As], Bs, [A|Cs]) :-
        list_list_together(As, Bs, Cs).
    
```

Adding further [**pure**](11-purity.md) clauses can never prevent nontermination. See [**Reading Prolog Programs**](05-reading.md) and [**Nontermination**](08-nontermination.md) for more information about this technique, which is called *program slicing*. Importantly, program slices can be generated *automatically* to help you find the reason for nontermination. See [cTI](http://www.cs.unipr.it/cTI/) and especially [**GUPU**](http://www.complang.tuwien.ac.at/ulrich/gupu/). [Tabling](28-memoization.md#tabling) can help to improve termination aspects of Prolog programs.
