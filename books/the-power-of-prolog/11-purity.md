# Logical Purity

At the heart of each great Prolog program is a property we call **logical purity** or simply **purity**. Informally, this means that the program has the properties we expect from a **relation**. There are two equally justifiable ways to characterize purity of Prolog programs:

1.  *intrinsic definition*, referring to building blocks that guarantee purity by construction
2.  *extrinsic definition*, referring to properties that can be tested without knowing details about the code.

In the following, we discuss these variants in more detail and give reasons why we care about this property.

## Intrinsic definition

One way to characterize logical purity is to refer to *intrinsic* properties of a program. In particular, we can give an *inductive* definition of predicates that are *pure*. For example:

- `true/0` and `false/0` are pure
- `(=)/2` and `dif/2` are pure
- [arithmetic constraints](clpfd) like `(#=)/2` and `(#\=)/2` are pure
- [`call`](10-metapredicates.md#call)`(Goal)` is pure *iff* `Goal` is pure
- [`maplist`](10-metapredicates.md#maplist)`(Goal, Ls)` is pure *iff* `Goal` is pure
- `(A,B)` and `(A;B)` are pure *iff* `A` and `B` are pure
- *more cases omitted*

For a large class of Prolog programs, this approach makes it very easy to determine whether a specific program is pure. That is a clear advantage of the approach. On the other hand, a drawback of this approach is that it does not explain *why* these predicates are pure, and how we can decide which other predicates, if any, are also pure.

## Extrinsic definition

A different approach to characterize logical purity only takes into account program properties that can be observed from the outside, without knowing any implementation details. For example:

- if a goal produces **output** on the terminal, it is *not* pure
- if a goal modifies [**global state**](16-global.md), it is *not* pure
- if, for a goal `G` that contains the subterm `S`, there is a term `T` such that `(G,S=T)` *succeeds unconditionally*, but `(S=T,G)` *fails*, then `G` is not **monotonic** and hence *not* pure
- analogously: if, for a goal `G` that contains the subterm `S`, there is a term `T` such that `(G,S=T)` *fails*, but `(S=T,G)` *succeeds unconditionally*, then `G` is *not* **steadfast** and hence *not* pure
- *more cases omitted*

An advantage of this approach is that we get a clearer idea about the *intention* behind logical purity. With this term, we want to denote programs that satisfy laws and invariants that we know from classical first-order logic. Examples of such laws are commutativity of conjunction and monotonicity of the consequence relation. In addition, we want to rule out programs that leave the realm of logic by producing output, deleting files, opening sockets etc. A disadvantage of this approach is that we are unlikely to come up with an exhaustive list of properties that we would like to see preserved. We can certainly cite very prominent and important ones though. Primary examples of predicates that *break* these properties in general are `!/0`, `(->)/2` and `assertz/1`.

## Practical importance

When programming in Prolog, retaining logical purity as far as possible has immense practical benefits. Here are a few advantages that only apply to logically pure code. **Pure code**...

- ... can be used in **all directions**, allowing for very concise and general specifications that keep our programs short. We can try the [*most general query*](03-concepts.md#toplevel) to see what solutions look like.
- ... can be **changed** more flexibly. We can freely reorder pure goals and clauses without changing the meaning of the program. Reordering goals and clauses can lead to much more efficient programs.
- ... can be **studied** more extensively. Reordering goals and clauses allows us to study operational effects that in many cases cannot even be observed with impure code due to its limited generality.
- ... can be **reasoned about** *declaratively*. Adding a constraint can at most *reduce* the set of solutions. Removing a constraint can at most *extend* it. This helps a lot when [debugging](13-debugging.md) unexpected failure or success.
- ... can be **interpreted flexibly**. We can use depth-first or breadth-first search, bottom-up evaluation, iterative deepening or any other strategy to derive logical consequences from pure code. As long as the inference method is *sound*, everything that can be derived is a semantic consequence of the program.
- ... can be **tested** with built-in features that are themselves pure. [Test cases](12-testing.md) for pure code are simply Prolog queries that must fail or succeed, depending on the desired outcome. Nothing else is needed. In particular, it is not necessary to reason about output that only appears on the terminal.
- ... is **easier to explain** and understand than impure code. This is because the clauses can be read in isolation, and their declarative reading as logical implications is admissible.
- ... is automatically **thread safe**: There are no *destructive* modifications in pure code, and therefore no data races, where a thread reads data that a different thread is modyfing at the same time. This property is becoming increasingly important for [web applications](22-web.md), where a single server handles multiple clients in different threads.

Note especially the following: In really interesting applications, we do not *a priori* know the outcome of computations. The point of using Prolog in such areas is for example to detect *whether* a specification is ambiguous, or *whether* a specific result arises. Since we do not know the outcome before actually running the program, we must not impose any restrictions on the formulation such as *committing* to only one of several possibilities. An example of such an application is David C. Norris's [`precautionary`](https://github.com/dcnorris/precautionary) package for patient-centered safety analysis of phase 1 dose-escalation trials in clinical oncology. Note for example how [`cdd.pl`](https://github.com/dcnorris/precautionary/blob/main/exec/prolog/ccd.pl) uses pure constructs as far as possible in order to derive interesting statements about the trial specification itself. This is an example of an application area where careful consideration of all possible outcomes is especially important: If the program unexpectedly fails to take into account *all* possibilities that can arise in practice, then the derived results are not valid, and medical decisions that are based on these results may have disastrous effects. Logical purity ensures that *all* possible cases are considered. See [*An Executable Specification of Oncology Dose-Escalation Protocols with Prolog*](https://arxiv.org/abs/2402.08334) and [DEDUCTION](https://codeberg.org/dcnorris/DEDUCTION) for more information.

## Applications to teaching Prolog

When teaching and learning Prolog, it is very helpful when goals and clauses can be freely reordered to study operational effects of changes. As already mentioned, this is possible with pure code. If you leave the pure monotonic subset of Prolog, phenomena that can only be explained procedurally will arise. For example, here are a few Prolog queries and a declarative reading of corresponding answers:

[TABLE]

It is clear that several properties we expect from pure logic programs are violated if we use such legacy predicates. For comparison, consider these queries if we use pure predicates *instead*:

[TABLE]

From such examples, we see that using pure predicates allows us to teach and reason about important and desirable properties of logic programs in a uniform and logical way.

## How far can we take this?

To what extent and how can we solve the tasks we want to express with pure code *exclusively*, making the code as elegant and general as possible while retaining acceptable performance? This is an open **research question**, arguably the most important question in declarative language research. It is sometimes argued that impure language constructs are *necessary* to obtain acceptable performance. There is no evidence for this. In fact, there is some indication that supports the opposite conclusion: Many important optimizations may realistically be applicable *only if* sufficiently large program fragments are kept pure. For example, the declarative language [**Mercury**](https://mercurylang.org/) totally omits many impure constructs that are sometimes used in Prolog, yet still remains practical *and* much more efficient than almost all Prolog implementations. [**Haskell**](https://www.haskell.org/) is another example of a programming language that allows aggressive [compiler optimizations](https://wiki.haskell.org/Performance) *due to* its purity. Recent developments in many Prolog implementations are designed to let us describe ever larger subsets of our programs by pure methods. In modern Prolog systems, even reading from files can be described in a pure way under quite general assumptions. See Ulrich Neumerkel's [**library(pio)**](http://www.complang.tuwien.ac.at/ulrich/Prolog-inedit/swi/pio.pl) for more information. An important recent publication showing how to preserve logical purity while retaining acceptable performance in many situations of high practical relevance is [***Indexing dif/2***](https://arxiv.org/abs/1607.01590) by Ulrich Neumerkel and Stefan Kral.
