# Facets of Prolog

*Video*: [A Tour of Prolog](https://www.metalevel.at/prolog/videos/tour)

## Prolog is ...

- ... a very [**simple**](#simple) language
- ... a [**declarative**](#declarative) language
- ... a [**logic programming**](#logic) language
- ... a [**homoiconic**](#homoiconic) language
- ... a very [**dynamic**](#dynamic) language
- ... a very [**versatile**](#versatile) language.

Prolog is a very simple language

It is easy to describe Prolog **syntax** in sufficient detail to start working with Prolog immediately. All [data](04-data.md) are represented by Prolog [**terms**](04-data.md#term). There is a single language element, called a [*clause*](03-concepts.md#clause). A clause is of the form:

**`Head :- Body.`**

This means that **if** `Body` holds, **then** `Head` holds. The infix operator `(:-)/2` represents an arrow from right to left: ←. If `Head` *always* holds, then `:- Body` can be *omitted*. *The above is enough to write useful first Prolog programs.* **You may not believe this**, so witness the evidence: All programs presented in the following consist *only* of such clauses. In fact, *all known computations* can be described in terms of such clauses, making Prolog a [Turing complete](https://en.wikipedia.org/wiki/Turing_completeness) programming language. One way to implement a Turing machine in Prolog is to describe the *relation* between different states of the machine with clauses of the form "*If* the current state is `S0` *and* the symbol under the tape head is `T`, *and* ... *then* the next state is `S`". See [`turing.pl`](showcases/turing.pl) for one implementation, and [*Thinking in States*](/tist/) for more information.

Prolog is a declarative language

Prolog is a *declarative language*. This means that we focus on stating *what* we are interested in. We [express what *holds*](06-writing.md) about solutions we want to find. We are less concerned about *how* the Prolog implementation finds these solutions. This declarative nature often allows for very concise, clear and general specifications. It is unlikely that shorter formalisms that are equally clear and expressive exist. For example, let us describe the *relation* between a [list](04-data.md#list) and its length, using [integer arithmetic](09-clpz.md):

**Note**: In *some* Prolog systems, you currently need to include a dedicated library to use declarative integer arithmetic. [More...](09-clpz.md)

```prolog
list_length([], 0).
list_length([_|Ls], N) :-
        N #> 0,
        N #= N0 + 1,
        list_length(Ls, N0).

```

We can [**read this declaratively**](05-reading.md#declarative) as follows:

1.  The length of the *empty list* `[]` is  0.
2.  **If** the length of the list `Ls` is `N0` **and** `N` is `N0+1`, **then** the length of `[_|Ls]` is `N`. Further, this only holds **if** `N` is *greater than* 0.

When programming in Prolog, think in terms of *relations* between entities. Your programs will become very general with this approach. In the above example, it is tempting to think and say "We are computing the length of a list". And yes, it is true: We can indeed use the above definition to compute the length of a list:

```prolog
?- list_length("abc", L).
   L = 3.

```

However, this *imperative* reading does not do justice to what we have actually implemented, because the definition also covers several additional usage patterns. For example, *given* a specific length, we can ask *whether* there are lists of that length:

```prolog
?- list_length(Ls, 3).
   Ls = [_A,_B,_C]
;  false.

```

Using the **most general query**, we can even ask for all answers that Prolog finds *in general*:

```prolog
?- list_length(Ls, L).
   Ls = [], L = 0
;  Ls = [_A], L = 1
;  Ls = [_A,_B], L = 2
;  Ls = [_A,_B,_C], L = 3
;  ... .

```

We say that the relation is usable in different *modes*. Characteristically, Prolog reports all answers via *backtracking*. The predicate `length/2` is part of the [Prologue for Prolog](https://www.complang.tuwien.ac.at/ulrich/iso-prolog/prologue) draft, and already available as a [built-in](03-concepts.md#builtin) predicate in almost all Prolog implementations with the above semantics.

Prolog is a logic programming language

In the category of *declarative* languages, we find *functional* programming languages and *logic* programming languages. A function is a special case of a relation, and functional programming can be regarded as a restricted form of logic programming. Prolog is firmly rooted in [**logic**](02-logic.md). A [pure](11-purity.md) Prolog program consists of a set of [Horn clauses](https://en.wikipedia.org/wiki/Horn_clause). Its execution can be regarded as a special case of [*resolution*](https://en.wikipedia.org/wiki/Resolution_(logic)). This connection to formal logic allows us to apply powerful [**declarative debugging**](13-debugging.md) techniques that are based on logical properties of the program. For example, adding a *constraint* can at most *reduce* the set of solutions, and adding a *clause* can at most extend it. This property of pure Prolog programs is called [monotonicity](https://en.wikipedia.org/wiki/Monotonicity_of_entailment). *See the [**GUPU system**](https://www.complang.tuwien.ac.at/ulrich/gupu/) by Ulrich Neumerkel for an impressive application of these ideas.*

Prolog is a homoiconic language

*homoiconic*: from ὁμός = "same" and εικών = "image"

Prolog *programs* are also valid Prolog *terms*! This has many great advantages: It is easy to write Prolog programs that analyze, transform and interpret *other* Prolog programs. You can use the built-in predicate `read/1` to read a Prolog term, and thus also a Prolog clause. There is a powerful [mechanism](19-macros.md) to rewrite Prolog programs at compilation time, so that you can easily implement domain-specific languages that help you solve your tasks more naturally. **You may not believe this**, because some goals—such as `list_length(Ls, N)`—look like Prolog terms as defined above, whereas other goals—such as `N #> 0`—look quite different. The reason for this is that Prolog provides prefix, infix and postfix *operators* that let you write Prolog terms in a more readable way. For example, the Prolog term `+(a,b)` can also be written using operator notation as `a+b`. The *abstract syntax* remains completely uniform, and you can read and process all Prolog terms independent of how they are written down. *You can dynamically define custom operators for specific use cases.*

Prolog is a very dynamic language

Prolog programs can be easily created, called and modified *at run time*. This further increases the expressiveness of Prolog and lets you implement [higher-order predicates](10-metapredicates.md) which have other predicates as arguments. It also allows the implementation of very dynamic techniques like *adaptive parsing*. The dynamic nature of Prolog also makes the language ideally suited for writing programs that are *extensible* by custom rules that other programmers and even regular users provide. [**Proloxy**](/proloxy/) and [Gerrit Code Review](https://www.gerritcodereview.com/) are examples of this approach: You configure these programs by supplying Prolog [rules](03-concepts.md#rule) that express your requirements in a very readable and flexible way. See [**A Couple of Meta-interpreters in Prolog**](/acomip/) for more information. *You can define an interpreter for pure Prolog in two lines of Prolog code.*

Prolog is a very versatile language

Prolog is an extremely versatile language. Its relational nature makes Prolog programs very flexible and general. This plays an important role in [language processing](14-dcg.md) and knowledge representation in [databases](24-business.md#database). Modern Prolog systems provide everything that is needed for solving simple [logic puzzles](26-puzzles.md) to building huge applications, ranging from [web hosting](22-web.md) to [verification](25-theoremproving.md) and [optimization](20-optimization.md) tasks. Prolog's versatility and power are rooted in *implicit* mechanisms that include search, unification, argument indexing and constraint propagation. You can use these mechanisms to your advantage, and *delegate* many tasks to the Prolog engine.

*Video*: [Sparrows on Eagles](https://www.metalevel.at/prolog/videos/sparrows_on_eagles)

*This page was sent to you by a [**Prolog HTTPS server**](/letswicrypt/).*
