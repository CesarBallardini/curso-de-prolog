# Expert Systems in Prolog

## Introduction

An **expert system** emulates the decision-making ability of a human *expert*. Prolog is very well suited for *implementing* expert systems due to several reasons:

- Prolog itself can be regarded as a simple *inference engine* or [theorem prover](25-theoremproving.md) that derives conclusions from known rules. Very simple expert systems can be implemented by relying on Prolog's built-in [search](15-sorting.md#searching) and backtracking mechanisms.
- Prolog [data structures](04-data.md) let us flexibly and conveniently *represent* rule-based systems that need additional functionality such as probabilistic reasoning.
- We can easily write [**meta-interpreters**](/acomip/) in Prolog to implement custom evaluation strategies of rules.

## Example: Animal identification

Our aim is to write an expert system that helps us *identify animals*. Suppose we have already obtained the following knowledge about animals, which are rules of inference:

- If it has a *fur* and says *woof*, then the animal is a **dog**.
- If it has a *fur* and says *meow*, then the animal is a **cat**.
- If it has *feathers* and says *quack*, then the animal is a **duck**.

These rules are not exhaustive, but they serve as a running example to illustrate a few points about expert systems. The key idea of an expert system is to derive useful new information based on user-provided input. In the following, we see several ways to do this in Prolog.

## Direct Prolog implementation

We now consider an implementation that uses [**Prolog rules**](03-concepts.md#rule) *directly* to implement the mentioned inference rules. This is straight-forward, using `is_true/1` to emit a question and only proceeding with the current clause if the user input is the atom `yes`:

```prolog
animal(dog)  :- is_true("has fur"), is_true("says woof").
animal(cat)  :- is_true("has fur"), is_true("says meow").
animal(duck) :- is_true("has feathers"), is_true("says quack").

is_true(Q) :-
        format("~s?\n", [Q]),
        read(yes).

```

There is a clear drawback of this approach, which is shown in the following sample interaction:

```prolog
?- animal(A).
has fur?
|: yes.
says woof?
|: no.
has fur?
|: yes.
says meow?
|: yes.

A = cat .

```

The system has asked a question *redundantly*: Ideally, the fact that the animal *does* have a fur would have to be stated at most *once* by the user. How can we best implement this? It is tempting to mess with the global database somehow to store user input over backtracking. However, changing a global state destroys many elementary properties we expect from [pure](11-purity.md) logical relations and is generally a very bad idea, so we don't do it this way.

Using a domain-specific language

To solve the shortcoming explained above, we will now *change* the representation of our rules from Prolog clauses to a custom language that we write and interpret a bit differently than plain Prolog. A language that is tailored for a specific application domain is aptly called a *domain-specific language* (DSL). We shall use the following representation to represent the knowledge:

```prolog
animals([animal(dog, [is_true("has fur"), is_true("says woof")]),
         animal(cat, [is_true("has fur"), is_true("says meow")]),
         animal(duck, [is_true("has feathers"), is_true("says quack")])]).

```

The inference rules are now represented by terms of the form `animal(A, Conditions)`, by which we mean that `A` is identified if all `Conditions` are true. Note especially that using a *list* is a [**clean**](04-data.md#clean) representation of conditions. It is a straight-forward exercise to implement an *interpreter* for this new representation. For example, the following snippet behaves like the expert system we saw in the previous section, assuming `is_true/1` is defined as before:

```prolog
animal(A) :-
        animals(As),
        member(animal(A,Cs), As),
        maplist(call, Cs).

```

Notably, this of course also shares the mentioned disadvantage:

```prolog
?- animal(A).
has fur?
|: yes.
says woof?
|: no.
has fur?

```

Now the point: We can interpret these rules *differently* by simply changing the interpreter, while leaving the rules unchanged. For example, let us equip this expert system with a *memory* that records the facts that are already *known* because they were already entered by the user at some point during the interaction. We implement this memory in a [pure](11-purity.md) way, by threading through additional arguments that describe the *relation* between [states](/tist/) of the memory before and after the user is queried for additional facts. For convenience, we are using [**DCG notation**](14-dcg.md) to carry around the state *implicitly*. Here is an implementation that does this:

```prolog
animal(A) :-
        animals(Animals),
        Known0 = [],
        phrase(any_animal(Animals, A), [Known0], _).

any_animal([Animal|Animals], A) -->
        any_animal_(Animal, Animals, A).

any_animal_(animal(A0, []), Animals, A) -->
        (   { A0 = A }
        ;   any_animal(Animals, A)
        ).
any_animal_(animal(A0, [C|Cs]), Animals, A) -->
        state0_state(Known0, Known),
        { condition_truth(C, T, Known0, Known) },
        next_animal(T, animal(A0,Cs), Animals, A).

next_animal(yes, Animal, Animals, A)  --> any_animal([Animal|Animals], A).
next_animal(no, _, Animals, A)        --> any_animal(Animals, A).

state0_state(S0, S), [S] --> [S0].

```

It is only left to define `condition_truth/4`: Depending on what is already *known*, this predicate either uses the existing knowledge *or* queries the user for more information. To distinguish these two cases in pure way, we use the meta-predicate [**`if_/3`**](10-metapredicates.md#if_3):

```prolog
condition_truth(is_true(Q), Answer, Known0, Known) :-
        if_(known_(Q,Answer,Known0),
            Known0 = Known,
            ( format("~s?\n", [Q]),
              read(Answer),
              Known = [known(Q,Answer)|Known0])).

known_(What, Answer, Known, Truth) :-
        if_(memberd_t(known(What,yes), Known),
            ( Answer = yes, Truth = true ),
            if_(memberd_t(known(What,no), Known),
                ( Answer = no, Truth = true),
                Truth = false)).

```

And thus, at last, the question no longer appears redundantly:

```prolog
?- animal(A).
has fur?
|: yes.
says woof?
|: no.
says meow?
|: yes.

A = cat .

```

Separating the knowledge base from the way it is interpreted has allowed us to add features while leaving the inference rules unchanged.

Using a different DSL

Consider now yet another way to solve the exact same problem. Let us view the animal identification task as interpreting the following **decision diagram**, where dotted lines indicate *no*, and plain lines indicate *yes*:

In this case, the diagram is in fact a full *binary tree* which can be represented naturally using Prolog terms. For example, let us represent the decision tree as follows, using a term of the form `if_then_else/3` for each inner node, and `animal/1` and `false/0` for leaves:

```prolog
tree(if_then_else("has fur",
                  if_then_else("says woof",
                               animal(dog),
                               if_then_else("says meow",
                                            animal(cat),
                                            false)),
                  if_then_else("has feathers",
                               if_then_else("says quack",
                                            animal(duck),
                                            false),
                               false))).

```

Other kinds of decision diagrams can also be represented efficiently with Prolog terms. Such trees can be interpreted in a straight-forward way, using again the definition of `is_true/1` to query the user:

```prolog
animal(A) :-
        tree(T),
        tree_animal(T, A).

tree_animal(animal(A), A).
tree_animal(if_then_else(Cond,Then,Else), A) :-
        (   is_true(Cond) ->
            tree_animal(Then, A)
        ;   tree_animal(Else, A)
        ).

```

> **Note**: This fragment uses the *impure* if-then-else construct. This is logically sound only if the condition is sufficiently instantiated, so that its truth can be safely determined without prematurely committing to one branch.

Since each question appears at most once on every path from the root to a leaf, it is *not* necessary to keep track of which questions have already been answered:

```prolog
?- animal(A).
has fur?
|: yes.
says woof?
|: no.
says meow?
|: yes.

A = cat.

```

## Comparison of approaches

We have now seen three different ways to implement an expert system in Prolog:

- direct Prolog implementation
- devising and interpreting a domain-specific language
- using a completely different domain-specific language.

Each of these approaches was rather easy to implement in Prolog, and there are several other DSLs that would also be suitable. The question thus arises: Which DSL, if any, should we choose to implement expert systems in Prolog? Let us briefly consider the main points we have seen:

1.  Using Prolog *directly* is straight-forward. However, a naive implementation has a few drawbacks. In our case, the same question was unnecessarily asked repeatedly.
2.  Using a *domain-specific language* lets us cleanly separate the main logic of the expert system from additional features, such as keeping track of already answered questions.
3.  A DSL based on decision diagrams is very easy to interpret and automatically avoids redundant questions.

From these points alone, option (3) seems very attractive. However, it also raises a few important questions: First, how was the decision diagram even *obtained*, and does it faithfully model the conditions we want to express? It is rather easy to do it by hand in this example, but how would you do it in more complex cases? Second, how *costly* is the transformation from a rather straight-forward fact base as in option (2) to using decision diagrams instead? Third, is this really a *good* diagram, and what do we even mean by *good*? Are there orderings of nodes that let us *reduce* the number of questions? In the worst case, on average, in the best case? Fourth, how extensible is the language of decision diagrams? For example, can *all* animal identification tasks be modeled in this way? etc. These questions show that the best choice depends on many factors.
