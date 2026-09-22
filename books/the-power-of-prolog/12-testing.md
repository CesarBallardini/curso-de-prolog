# Testing Prolog Programs

We explain several methods of **declarative testing**. "Declarative" means that we reason about what is being *described* by the program: We compare the actual *meaning* of the program with the intended one, and the actual *properties* with those that we *know* will hold if the program is implemented correctly.

## Example: Length of a list

Let us consider a simple Prolog program that *contains a **mistake***:

```prolog
list_length([], 0).
list_length([_|Ls], N) :-
        N #> 0,
        N #= N0 + 2,
        list_length(Ls, N0).
    
```

Our intention is to describe the relation between a *list* and its *length*. From a quick glance, the program at first seems to work as intended in several ways. For example, the query `?- list_length([], 0).` *succeeds* as intended, and we can use the program to *generate* answers:

```prolog
?- list_length(Ls, _).
   Ls = []
;  Ls = [_A]
;  Ls = [_A,_B]
;  ... .
    
```

Nevertheless, the program is ***wrong***!

## Testing nontermination

Our first tests aim to ensure desired [**termination properties**](07-termination.md) of the program. For example, in the case of `list_length/2`, we know that the program *must not* terminate for the *most general* query. This is because we expect the relation to hold for lists of *all* lengths, and there is no way to report this set with a finite number of answers. To study termination of a Prolog query *Q*, we use the query:

```prolog
?- Q, false.
    
```

*Iff* this query terminates, then we say that *Q* **terminates universally**. In our concrete case, we use:

```prolog
?- list_length(Ls, L), false.
    
```

*No* termination can be observed. In this respect, the program behaves as expected. However, testing termination properties is *not sufficient* to detect all mistakes. What else can we do?

## Concrete test cases

We can try *concrete* **test cases** that we *know* should succeed or fail. Prolog makes it very easy to test [pure](11-purity.md) programs in this way: You can simply try queries on the toplevel! In addition, Prolog's built-in backtracking mechanism makes it very easy to express a vast collection of concrete test cases at once. For example, as already stated, we *know* that the relation *should* yield answers for lists of *all* lengths. In particular, it should succeed for lists of the form `[]`, `[a]`, `[a,a]`, ... . Let us see if a **counterexample** exists:

```prolog
?- maplist(=(a), Ls), \+ list_length(Ls, _).
    
```

None is reported. So, also in this respect, the program behaves as intended. We can push this further and *generalize* the test cases for example to:

```prolog
?- maplist(=(_), Ls), \+ list_length(Ls, _).
    
```

Again, no counterexample is reported, even with this massive generalization.

## Testing against a reference implementation

What else can we do? We can for example test against a *reference* implementation. In our concrete case, this is easily possible, because almost all Prolog implementations ship with a predicate called `length/2` which is *exactly* the relation we are trying to describe. Testing against the reference implementation immediately reveals a mistake in our program:

```prolog
?- A #\= B, length(Ls, A), list_length(Ls, B).
   A = 1, B = 2, Ls = [_A]
;  A = 2, B = 4, Ls = [_A,_B]
;  A = 3, B = 6, Ls = [_A,_B,_C]
;  ... .
    
```

Of course, in most cases we do *not* have a reference implementation!

## Testing declarative properties

We can test the relation by using further **properties** that we *know* must hold if the relation is implemented correctly. For example, in our case, we know that if the length of a list `Ls` is *N*, then the length of `[_|Ls]` is *N*+1. Let us again try to find a **counterexample** of this:

```prolog
?- list_length(Ls, N), list_length([_|Ls], N1), N1 #\= N + 1.
   Ls = [], N = 0, N1 = 2
;  ... .
    
```

So there it is: From this solution, we *know* that either the length of `[]` or the length of `[_]` is *not* described correctly. In this case, it is clear that the length of `[_]` *should be* 1, but is *incorrectly* 2. In particular, the following query *incorrectly* fails:

```prolog
?- list_length([_], 1).
   false.
    
```

Continue with **[Declarative Debugging](13-debugging.md)** to see how we can locate and correct the mistake.

## Further reading

The approaches we describe above are by no means exhaustive. There are several other declarative ways to test Prolog programs. One very promising approach is *concolic testing*, as explained for example by Mesnard et al. in [***Concolic Testing in Logic Programming***](https://personales.upv.es/gvidal/german/iclp15/paper_CORR.pdf) and the included references.
