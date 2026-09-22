# Reading Prolog Programs

While you may [*write*](06-writing.md) a Prolog [program](03-concepts.md#program) only *once*, and may even *rewrite* it a few times, you and others will typically *read* it many, many, many times. Consequently, it is important to know *how* we can best read Prolog programs: What exactly do they mean?

*Video*: [Reading Prolog Code](https://www.metalevel.at/prolog/videos/reading)

There are several ways to read [**pure**](11-purity.md) Prolog programs, and we explain some of them in this text.

## Declarative reading

Declaratively, Prolog programs state *what holds*. A Prolog program consists of **clauses**, and each clause is either a **fact** or a **rule**. *Facts* state what is *always* true. *Rules* state what is true under certain *conditions*. Declaratively, a rule of the form:

```prolog
Head :- Body.
    
```

is read as: "*If* `Body` is true, *then* `Head` is true." In logical terms, we say that `Body` *implies* `Head`, written as `Body`→`Head`, or equivalently as:

```prolog
Head ← Body.
    
```

Note that `:-` is in fact meant to represent the arrow ←. Since `Body` defines the conditions under which `Head` holds, it can also be regarded as a *constraint* on the set of solutions. This way to read Prolog programs is also called *concluding* reading. A major advantage of this approach is that it is easy to explain, understand and use. You state what holds under what conditions, and the Prolog engine finds solutions for you. A disadvantage of this approach is that it does not explain why logically equivalent program variants may exhibit different performance or termination characteristics.

**Example:** `list_list_together/3`, describing the *concatenation* of two lists:

```prolog
list_list_together([], Bs, Bs).
list_list_together([A|As], Bs, [A|Cs]) :-
        list_list_together(As, Bs, Cs).
      
```

Let us read this definition *declaratively*, that is in terms of *relations* that hold between arguments, as described by the two clauses:

1.  The concatenation of the *empty list* `[]` and *any* list `Bs` is just that list `Bs`.
2.  *If* the concatenation of `As` and `Bs` is `Cs`, *then* the concatenation of `[A|As]` and `Bs` is `[A|Cs]`, for *any* element `A`.

Note how *general* this reading is: It is applicable if any arguments are *instantiated*, and *also* if they are not.

## Procedural reading

To complement the declarative approach of reading Prolog programs, we can also read them *procedurally*. This means that we take into account the actual *computation strategy* of the Prolog engine. Operationally, invocation of a Prolog predicate is similar to a *procedure* or *function* call in other languages. However, two critical differences remain: First, Prolog *variables* are truly **variables** and may be *unbound* or only *partially* instantiated. This cannot happen with variables in most other languages. Second, Prolog provides **backtracking** as a built-in feature, and will exhaustively try alternatives. For these reasons, understanding a Prolog program *procedurally* is significantly *harder* than understanding the control flow of many other programming languages. In particular, when tracing Prolog, you need to take into account:

- **instantiation** of variables
- **aliasing** between variables
- **alternatives** found on backtracking.

The need to keep track of these complexities and their interactions is a major drawback of this approach. An advantage of the approach is its potential to explain different [performance characteristics](27-efficiency.md) and [termination properties](07-termination.md) of program variants. Note also that a procedural reading almost invariably implies a particular *direction* of use, and therefore typically does not do justice to the full generality of logical relations.

**Example:** Let us read [`list_list_together/3`](#list_list_together3) (shown above) *procedurally* for the query `?- list_list_together([x,y], [z], Cs).`

1.  Does the *first* clause apply? **No**, because `[x,y]` does not unify with `[]`.
2.  Does the *second* clause apply? Note that due to the way resolution works, we must introduce *fresh variables* when considering a clause. So, let us use `A'`, `As'`, `Bs'`, and `Cs'` for the variables `A`, `As`, `Bs` and `Cs` that appear in the clause head. The answer is: **Yes**, the second clause applies with the bindings `A'=x`, `As'=[y]`, `Bs'=[z]`, `Cs=[A'|Cs']`. This is already rather cumbersome and error-prone, and it gets even harder to keep track of all bindings as we proceed further.
3.  Carrying on, we consider the goal `list_list_together([y], [z], Cs')`, repeating the same questions for this goal.
4.  Does the *first* clause apply? **No**, because `[y]` does not unify with `[]`.
5.  Does the *second* clause apply? We need to rename the variables again. Let us use `A''`, `As''`, `Bs''` and `Cs''`. **Yes**, the clause applies with `A''=y`, `As''=[]`, `Bs''=[z]` and `Cs'=[A''|Cs'']`.
6.  Now the whole ordeal once more, as we consider the goal `list_list_together([], [z], Cs'')`.
7.  Does the *first* clause apply? **Yes**, at last! Note that we *again* need to introduce fresh variables of course. Let us use `Bs'''` to denote the single variable of the first clause at this step of the computation. So the first clause applies with `Bs'''=[z]` and `Cs''=Bs'''`. This means that at last a *solution* is found and reported as a *binding* for the original variable `Cs` which is the only variable that appears in the query. If you have carefully followed this trace (as I am sure you have, since it is so enjoyable to read), you know that `Cs` was unified with `[A'|Cs']`. Since `A'` was unified with `x`, and `Cs'` was unified with `[A''|Cs'']`, and further `A''` was unified with `y`, this makes `Cs` the same as `[x,y|Cs'']`. As we just mentioned, `Cs''` was unified with `Bs'''`, and `Bs'''` is `[z]`. Thus, the solution we found is `Cs=[x,y,z]`, and this solution is reported by the toplevel.
8.  We still need to consider the *second* clause too though: **No**, it does not apply, because `[]` does not unify with `[_|_]`.

And this was only *one particular case*! Accurately covering all possible modes of invocation with a procedural reading is extremely complex, and typically would take an extremely elaborate explanation. In general, you will not be able to carry this approach through, because there are too many cases to consider.

## Program slicing

Program **slicing** is a simple and powerful technique that uses very general properties of pure Prolog to study the effects of **generalizations** and **specializations** of a program. Examples of such properties are:

- *removing* a **goal** can make the program at most *more general*, never more *specific*
- *removing* a **clause** can make the program at most *more specific*, never more *general*
- *inserting* `false/0` between any two goals in a rule lets us ignore the procedural effects of *all* goals *after* that point.

In a very precise sense, program slices are **explanations** that answer *why* we observe certain phenomena. We illustrate this with a simple example. Suppose a programmer has written `list_length/2`, relating a list to its length as follows:

```prolog
list_length([_|Ls], N) :-
        list_length(Ls, N0),
        N #> 0,
        N #= N0 + 1.
list_length([], 0).
    
```

The predicate works exactly as intended if the list is sufficiently instantiated. For example:

```prolog
?- list_length([], L).
   L = 0.

?- list_length([_,_,_], L).
   L = 3.
    
```

However, the predicate does *not* generate a single answer for the most general query:

```prolog
?- list_length(Ls, L).
    
```

Program slicing helps us to see the reason. ~~Strikeout~~ text is used for parts that are not relevant for the behaviour we observe:

```prolog
list_length([_|Ls], N) :-
        list_length(Ls, N0),
        false,
        N #> 0,
        N #= N0 + 1.
list_length([], 0) :- false.
    
```

The remaining fragment is *by itself* already responsible for the [**nontermination**](08-nontermination.md). *No* change in the ~~strikeout~~ parts can prevent it. Program slices can be generated *automatically* and are a powerful way to [locate the causes](13-debugging.md) of nontermination and other unintended properties in Prolog programs. See for example Stefan Kral et al., *Slicing zur Fehlersuche in Logikprogrammen*, WLP 2000.
