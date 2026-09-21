# 11 Cuts and Negation

<!-- page 230 -->
Prolog provides a single system predicate, called cut, for affecting the procedural behavior of programs. Its main function is to reduce the search space of Prolog computations by dynamically pruning the search tree. The cut can be used to prevent Prolog from following fruitless computation paths that the programmer knows could not produce solutions.

The cut can also be used, inadvertently or purposefully, to pi-une computation paths that do contain solutions. By doing so, a weak form of negation can be effected.

The use of cut is controversial. Many of its uses can only be interpreted procedurally, in contrast to the declarative style of programming we encourage. Used sparingly, however, it can improve the efficiency of programs without compromising their clarity.

11.1. Green Cuts: Expressing Determinism Consider the program `merge(Xs,Ys,Zs)` (Program 11.1), which merges two sorted lists of numbers Xs and Ys into the combined sorted list `Zs.`

<!-- page 231 -->
Merging two lists of sorted numbers is a deterministic operation. Only one of the five `merge` clauses applies for each nontrivial goal in a given computation. To be more specific, when comparing two numbers X and Y, for example, only one of the three tests X < Y, X = : = Y, and X > Y can be true. Once a test succeeds, there is no possibility that any other test will succeed. merge(Xs,Ys,Zs) -

Zs is an ordered list of integers obtained from merging

the ordered lists of integers Xs and Ys.

```prolog
merge([XJXs], [YIYs] , [XIZs]) - X < Y, merge(Xs, [YIYs] ,Zs).
merge([XIXs], [YIYs] , [X,YZs]) - X=:=Y, merge(Xs,Ys,Zs).
merge([XXs], [YIYs] , [YIZs]) - X > Y, merge([XIXs] ,Ys,Zs).
merge(Xs, E ] ,Xs).
merge([ ],Ys,Ys).
```

Program 11.1

Merging ordered lists

The cut, denoted !, can be used to express the mutually exclusive nature of the tests. It is placed after the arithmetic tests. For example, the first `merge` clause is written

```prolog
merge([XIXs],[YIYs],[XIZs]) x < Y,
                                        !, merge(Xs,[Y IYs],Zs).
```

Operationally, the cut is handled as follows.

The goal succeeds and commits Prolog to all the choices made since the parent goal was unified with the head of the clause the cut occurs in.

Although this definition is complete and precise, its ramifications and implications are not always intuitively clear or apparent.

Misunderstandings concerning the effects of a cut are a major source for bugs for experienced and inexperienced Prolog programmers alike. The misunderstandings fall into two categories: assuming that the cut prunes computation paths it does not, and assuming that it does not prune solutions where it actually does.

The following implications may help clarify the foregoing terse definition:

First, a cut prunes all clauses below it. A goal p unified with a clause

containing a cut that succeeded would not be able to produce solutions

using clauses that occur below that clause.

Second, a cut prunes all alternative solutions to the conjunction of

goals that appear to its left in the clause. For example, a conjunctive

goal followed by a cut will produce at most one solution.

On the other hand, the cut does not affect the goals to its right in

the clause. They can produce more than one solution in the event of

<!-- page 232 -->
backtracking. However, once this conjunction fails, the search proceeds

i =:2,Imerge([3,5],[3],Xsi

Figure 11.1

The effect of cut

from the last alternative prior to the choice of the clause containing the

cut.

Let us consider a fragment of the search tree of the query merge ([1 3, 5] , [2,3] ,Xs)? with respect to Program 112, a version of merge with cuts added. The fragment is given as Figure 11.1. The query is first reducedtotheconjunctivequeryl

2,!,merge([3,5],[2,3],Xsl)?;the goal i < 2 is successfully solved, reaching the node marked (*) in the search tree. The effect of executing the cut is to prune the branches marked (a) and (b).

Continuing discussion of Program 11.2, the placement of the cuts in the three recursive clauses of merge is after the test.' The two base cases of merge are also deterministic. The correct clause is chosen by unification, and thus a cut is placed as the first goal (and in fact the only goal) in the body of the rule. Note that the cuts eliminate the redundant solution to the goal merge ( [

J

,

L

J , Xs). Previously, this was accomplished more awkwardly, by specifying that Xs (or Ys) had at least one element.

<!-- page 233 -->
1. The cut after the third merge clause is unliecessary in any practica! sense. Procedurally, it will not cause any reduction of search. But it makes the program more symmetric, and like the old joke says about chicken soup, it doesn't hurt. merge(Xs,Ys,Zs) -

Zs is an ordered list of integers obtained from merging

the ordered lists of integers Xs and Ys. merge([XIXs],[YIYs],[XIZs]) -

```prolog
    X
      < Y,
           !, merge(Xs,[YIYs],Zs).
merge([XXs] ,[YIYs] , [X,YIZs]) -
    X=:=Y,
           !, merge(Xs,Ys,Zs).
merge([XIXs] , [Y lYs], [YIZs]) -
    X
      >
        Y,
           !, merge([XIXs],Ys,Zs).
merge(Xs, E ] ,Xs) -
merge([ ],Ys,Ys) - L
```

Program 11.2

Merging with cuts

We restate the effect of a cut in a general clause C = A - B1,. . . ,Bk,!, Bk+2, .

. . ,B in a procedure defining A. If the current goal G unifies with the head of C, and B1,. . .,B further succeed, the cut has the following effect. The program is committed to the choice of C for reducing G; any alternative clauses for A that might unify with G are ignored. Further, should B fail for i> k `+` 1, backtracking goes back only as far as the L Other choices remaining in the computation of B, i

k, are pruned from the search tree. If backtracking actually reaches the cut, then the cut fails, and the search proceeds from the last choice made before the choice of G to reduce C.

The cuts used in the merge program express that merge is deterministic. That is, only one of the clauses can be used successfully for proving an applicable goal. The cut commits the computation to a single clause, once the computation has progressed enough to determine that this is the only clause to be used.

The information conveyed by the cut prunes the search tree, and hence shortens the path traversed by Prolog, which reduces the computation time. In practice, using cuts in a program is even more important for saving space. Intuitively, knowing that a computation is deterministic means that less information needs to be kept for use in the event of backtracking. This can be exploited by Prolog implementations with tail recursion optimization, discussed in Section 11.2.

<!-- page 234 -->
Let us consider some other examples. Cuts can be added to the program for computing the minimum of two numbers (Program 3.7) in precisely the same way as for merge. Once an arithmetic test succeeds, there minimum(X,Y,Min) -

Min is the minimum of the numbers X and Y.

```prolog
minimuin(X,Y,X)
               - XY, L
minimuin(X,Y,Y) - X > Y, L
Program 11.3
              minimum with cuts
```

polynomial ( Term,X) -

Term is a poiynornial in `X.`

```prolog
polynomial(X,X) - L
polynomial(Term,X) -
    constant (Term),
polynomial (Terml+Term2 , X)
       polynomial (Terni, X), polynomial(Term2,X).
polynomial (Terml-Term2 , X)
    !, polynomial(Terml,X), polynomial(Term2,X).
polynomial (Terml*Term2 ,X)
       polynomial(Termi,X), polynomial (Term2,X).
polynomial (Terml/Term2 , X)
       polynomial (Terml,X)
                           constant (Term2)
polynomial(TermIN,X) -
    !, integer(N), N > O, polynomial (Term,X).
Program 11.4
              Recog zing polynomials
```

is no possibility for the other test succeeding. Program 11.3 is the appropriately modified version of `minimum.`

A more substantial example where cuts can be added to indicate that a program is deterministic is provided by Program 3.29. The program defines the relation `polynomial(Term,X)` for recognizing if `Term` is a polynomial in X. A typical rule is

```prolog
polynomial (Ternil+Term2 , X) -
    polynomial(Terml,X), polynomial(Term2,X).
```

<!-- page 235 -->
Once the term being tested has been recognized as a sum (by unifying with the head of the rule), it is known that none of the other `polynomial` rules will be applicable. Program 11.4 gives the complete polynomial program with cuts added. The result is a deterministic program that has a mixture of cuts after conditions and cuts after unification.

When discussing the Prolog programs for arithmetic, which use the underlying arithmetic capabilities of the computer rather than a recursive logic program, we argued that the increased efficiency is often achieved at the price of flexibility. The logic programs lost their multiple uses when expressed as Prolog programs. Prolog programs with cuts also have less flexibility than their cut-free equivalents. This is not a problem if the intended use of a program is one-way to begin with, as is often the case.

The examples so far have demonstrated pruning useless alternatives for the parent goal. We give an example where cuts greatly aid efficiency by removing redundant computations of sibling goals. Consider the recursive clause of an interchange sort program:

```prolog
sort(Xs,Ys) -
    append(As, [X,YIBs] ,Xs),
    X > Y,
    append(As, [Y,XIBs] ,Xsl),
    sort (Xsl,Ys).
```

The program searches for a pair of adjacent elements that are out of order, swaps them, and continues until the list is ordered. The base clause is

```prolog
sort(Xs,Xs) - ordered(Xs).
```

Consider a goal `sort([3,2, 1] ,Xs).` This is sorted by swapping `3` and `2,` then `3` and 1, and finally `2` and i to produce the ordered list `[1 ,2,3].` It could also be sorted by first swapping `2` and 1, then swapping `3` and 1, and finally swapping `3` and `2,` to arrive at the same solution. We know there is only one sorted list. Consequently there is no point in searching for another alternative once an interchange is made. This can be indicated by placing the cut after the test X > Y. This is the earliest it is known that an interchange is necessary. The interchange sort program with cut is given as Program 11.5.

<!-- page 236 -->
The addition of cuts to the programs described in this section does not alter their declarative meaning; all solutions to a given query are found. Conversely, removing the cuts should similarly not affect the meaning of the program. Unfortunately, this is not always the case. A distinction has been made in the literature between green cuts and red cuts. Green cuts have been considered in this section. The addition and removal of green cuts from a program do not affect the program's meaning. Green cuts sort(Xs,Ys)

Ys is an ordered permutation of the list of integers Xs.

```prolog
sort(Xs,Ys)
    append(As, [X,YIBs] ,Xs),
    X > Y,
    append(As, [Y,XIBs] ,Xsl),
    sort (Xsl,Ys)
sort(Xs,Xs) -
    ordered(Xs)
ordered(Xs)
              See Program 3.20.
```

Program 11.5

Interchange sort

prune on'y computation paths that do not lead to new solutions. Cuts that are not green are red.

The cut interacts with system predicates such as `call` and ;, introduced in Chapter 10, and with predicates such as `riot,` introduced later in this chapter. The question is what scope should cut have, that is, which choice points should be affected. Since such tricky uses of cut are not presented or advocated in this book, we defer discussion of the scope of cut until Chapter 17 on interpreters,

Exercises for Section 11.1

Add cuts to the partition program from `quicksort,` Program 3.22.

Add cuts to the differentiation program, Program 3.30. (il)

Add cuts to the insertion sort program, Program 3.21.

<!-- page 237 -->
11.2 Tail Recursion Optimization As noted in Section 8.3, the main difference from a performance point of view between recursion and iteration is that recursion requires, in general, space linear in the number of recursive calls to execute, whereas iteration can be executed in constant space, independent of the number of iterations performed.

Recursive programs defined free of side effects might be considered more elegant and pleasing than their iterative counterparts defined in terms of iteration and local variables. However, an order of magnitude in space complexity seems an unacceptable price for such aesthetic pleasures. Fortunately, there is a class of recursive programs, precisely those that can be translated directly into iterative ones, that can be executed in constant space.

The implementation technique that achieves this space saving is called tail recursion optimization, or more precisely, last call optimization. Intuitively, the idea of tail recursion optimization is to execute a recursive program as if it were an iterative one.

Consider the reduction of a goal A using the clause A' - B1,B2,

.

. . ,B. with most general unifier 9. The optimization is potentially applicable to the last call in the body of a clause, B. It reuses the area allocated for the parent goal A for the new goal B.

The key precondition for this optimization to apply is that there be no choice points left from the time the parent goal A reduced to this clause to the time the last goal B is reduced. In other words, A has no alternative clauses for reduction left, and there are no choice points left in the computation of goals to the left of B, namely, the computation of the conjunctive goal (B1,B2,. . .,B1)O, was deterministic.

Most implementations of tail recursion optimization can recognize to a limited extent at runtime whether this condition occurs, by comparing backtracking-related information associated with the goals B and A. Another implementation technique, clause indexing, also interacts closely with tail recursion optimization and enhances the ability of the implementation to detect that this precondition occurs. Indexing performs some analysis of the goal, to detect which clauses are applicable for reduction, before actually attempting to do the unifications. Typically, indexing is done on the type and value of the first argument of the goal.

Consider the `append` program:

```prolog
append([XIXs] ,Ys, [XIZs]) - append(Xs,Ys,Zs).
append( [
          J ,Ys ,Ys).
```

<!-- page 238 -->
If it is used to append two complete lists, then by the time the recursive append goal is executed, the preconditions for tail recursion optimization hold. No other clause is applicable to the parent goal (if the first argument unifies with [XXs], it certainly won't unify with L], since we assumed that the first argument is a complete list). There are no other goals in the body besides append, so the second precondition holds vacuously.

However, for the implementation to know that the optimization applies, it needs to know that the second clause, although not tried yet, is not applicable. Here indexing comes into play. By analyzing the first argument of append, it is possible to know that the second clause would fail even before trying it, and to apply the optimization in the recursive call to append.

Not all implementations provide indexing, and not all cases of determinism can be detected by the indexing mechanisms available. Therefore it is in the interest of the programmer to help an implementation that supports tail recursion optimization to recognize that the preconditions for applying it hold.

There is a sledgehammer technique for doing so: Add a cut before the last goal of a clause, in which tail recursion optimization should always apply, as in A1 - B1,B2, .

. . ,!,B. This cut prunes both alternative clauses left for the parent goal A, and any alternatives left for the computation of (B1,B2,. .

In general, it is not possible to answer if such a cut is green or red, and the programmer's judgment should be applied.

<!-- page 239 -->
It should be noted that the effect of tail recursion optimization is enhanced greatly when accompanied with a good garbage collector. Stated negatively, the optimization is not very significant without garbage collection. The reason is that most tail recursive programs generate some data structures on each iteration. Most of these structures are temporary and can be reclaimed (see, for instance, the editor in Program 12.5). Together with a garbage collector, such programs can run, in principle, forever. Without it, although the stack space they consume would remain constant, the space allocated to the uncollected temporary data structures would overflow.

```prolog
notX -
```

X is not provable. not X - X, !, fail. not X. Program 11.6

Negation as failure

11.3 Negation The cut can be used to implement a version of negation as failure. Program 11.6 defines a predicate not `(Goal),` which succeeds if `Goal` fails. As well as using cut, the program uses the meta-variable facility described in Chapter 10, and a system predicate `fail` that always fails.

Standard Prolog provides a predicate `fail_if (Goal),` which has the same behavior as not/i. Other Prologs provide the same predicate under the name \+/i. The rationale for not calling the system predicate not is that the predicate does not implement true logical negation, and it is misleading to label it as such. We believe that the user easily learns how the predicate differs from true negation, as we will explain, and programmers are helped rather than misled by the name.

Let us consider the behavior of Program 11.6 in answering the query not

`G?` The first rule applies, and G is called using the meta-variable facility. If G succeeds, the cut is encountered. The computation is then committed to the first rule, and not G fails. If the call to G fails, then the second rule of Program 11.6 is used, which succeeds. Thus not

`G` fails if `G` succeeds and succeeds if `G` fails.

The rule order is essential for Program 11.6 to behave as intended. This introduces a new, not entirely desirable, dimension to Prolog programs. Previously, changing the rule order only changed the order of solutions. Now the meaning of the program can change. Procedures where the rule order is critical in this sense must be considered as a single unit rather than as a collection of individual clauses.

The termination of a goal not

`G` depends on the termination of `G.` If `G` terminates, so does not G. If `G` does not terminate, then not

<!-- page 240 -->
`G` may or may not terminate depending on whether a success node is found in the search tree before an infinite branch. Consider the following nonterminating program:

```prolog
married(abraham, sarah).
married(X,Y)
                 married(Y,X).
```

The query `not married(abrahaxn,sarah)?` terminates (with failure) even though `married (abraham, sarah)?` does not termrnate.

Program 11.6 is incomplete as an implementation of negation by failure. The incompleteness arises from Prolog's incompleteness in realizing the computation model of logic programs. The definition of negation as failure for logic programs is in terms of a finitely failed search tree. A Prolog computation is not guaranteed to find one, even if it exists. There are goals that could fail by negation as failure, that do not terminate under Prolog's computation rule. For example, the query `not (p (X) ,q(X))?` does not terminate with respect to the program p(s(X))

```prolog
p(X).
```

q(a). The query would succeed if the `q(X)` goal were selected first, since that gives a finitely failed search tree.

The incorrectness of Program 11.6 stems from the order of traversal of the search tree and arises when `not` is used in conjunction with other goals. Consider using `not` to define a relationship `unniarried_` `student(X)` for someone who is both not married and a student, as in the following program:

```prolog
unmarried_student(X)
                          not married(X), student(X).
student (bill).
married(joe).
```

The query `unmarried_student (X)?` fails with respect to the preceding data, ignoring that `X=bill` is a solution logically implied by the rule and two facts. The failure occurs in the goal `not married(X),` since there is a solution `X=j 0e.` The problem can be avoided here by swapping the order of the goals in the body of the rule.

A similar example is the query `not (X=1), X=2?,` which fails although there is a solution `X=2.`

<!-- page 241 -->
The implementation of negation as failure is not guaranteed to work correctly for nonground goals, as the foregoing examples demonstrate. In most implementations of Prolog, it is the responsibility of the programmer to ensure that negated goals are ground before they are solved. variants ( Termi , Term2) -

Tenni and Term2 are variants.

```prolog
variants(Terxnl ,Term2) -
    verify ( (numbervars (Termi 0, N),
    numbervars (Term2 0, N),
    Term 1=Term2)).
```

verify(Goal) -

Goal has a true instance. Verifying this is not done

constructively, so variables are not instantiated in the process.

```prolog
verify(Goal) - not(not Goal).
numbervars(Term,N,N1) - See Program 10.8.
```

Program 11.7

Testing if terms are variants

This can be done either by a static analysis of the program or by a runtime check, using the predicate `ground` defined in Program 10.4.

The predicate `not` is very useful. It allows us to define interesting concepts. For example, consider a predicate `disjoint(Xs,Ys),` true if two lists Xs and Ys have no elements in common. It can be defined as

```prolog
disjoint(Xs,Ys)
                    not (meniber(Z,Xs), member(Z,Ys)).
```

Many other examples of using `not` will appear in the programs throughout this book.

An interesting property of `not (Goal)` is that it never instantiates the arguments in `Goal.` This is because of the explicit failure after the call to `Goal` succeeds, which undoes any bindings made. This property can be exploited to define a procedure `verify(Goal),` given as part of Program 11.7, which determines whether a goal is true without affecting the current state of the variable bindings. Double negation provides the means.

We note in passing that negation as implemented in Prolog shares a feature with negation in natural language. A doubly negated statement is not the same as the equivalent affirmative statement.

<!-- page 242 -->
The program for `verify` can be used in conjunction with Program 10.8 for `numbervars` to define a notion of equality intermediate between unitiability provided by =/2 and syntactic equality provided by ==/2. The predicate `variants(X,Y)` defined in Program 11.7 is true if two terms X and Y are variants. Recall from Chapter 4 that two terms are variants x

**y -**

X and Y are not unifiable.

```prolog
X
    X - ', fail.
X
    Y.
```

Program 11.8

Implementing

if they are instances of each other. This can be achieved with the following trick, implemented in Program 11.7. Instantiate the variables using `numbervars,` test whether the terms unify, and undo the instantiation.

The three forms of comparison `=12, variant/2,` arid `==/2` are progressively stronger, with unifiability being the weakest and most general. Identical terms are variants, and variant terms are unifiable The distinction between the different comparisons vanishes for ground terms; for ground terms all three comparisons return the same results.

The conjunction of cut and fail used in the first clause of `not` in Program 11.6 is known as the cut-fail combination. The cut-fail combination is a technique that can be used more generally. It allows early failure. A clause with a cut-fail combination says that the search need not (and will not) proceed.

Some cuts in a cut-fail combination are green cuts. That is, the program has the same meaning if the clause containing the cut-fail combination is removed. For example, consider Program 10.4 defining the predicate `ground.` An extra clause can be added, which can reduce the search without affecting the meaning:

```prolog
ground(Term) - var(Term),
                              !, fail.
```

The use of cut in Program 11.6 implementing `not` is riot green, but red. The program does not behave as intended if the cut is removed.

The cut-fail combination is used to implement other system predicates involving negation. For example, the predicate

(written as \= in Standard Prolog) can be simply implemented via unification and cut-fail, rather than via an infinite table, with Program 11.8. This program is also only guaranteed to work correctly for ground goals.

<!-- page 243 -->
With ingenuity, and a good understanding of unification and the execution mechanism of Prolog, interesting definitions can be found for many meta-logical predicates. A sense of the necessary contortions can be found in the program for same_var(X,Y), which succeeds if X and Y are the same variable and otherwise fails:

```prolog
same_var(foo,Y)
                    var(Y),
                               ,
                                fail.
same_var(X,Y)
                  var(X), var(Y).
```

The argument for its correctness follows: "If the arguments to samevar are the same variable, binding X to f oo will bind the second argument as well, so the first clause will fail, and the second clause will succeed. If either of the arguments is not a variable, both clauses will fail. If the arguments are different variables, the first clause will fail, but the cut stops the second clause from being considered." Exercises for Section 1L3

Define the system predicate \== using == and the cut-fail combina-

```prolog
tion.
```

Define nonvar using var and the cut-fail combination.

11.4 Red Cuts: Omitting Explicit Conditions Prolog's sequential choice of rules and its behavior in executmg cut are the key features necessary to compose the program for not. The programmer can take into account that Prolog will only execute a part of the procedure if certain conditions hold. This suggests a new, and misguided, style of programming in Prolog, where the explicit conditions governing the use of a rule are omitted.

The prototypical (bad) example in the literature is a modified version of Program 11.3 for minimum. The comparison in the second clause of the program can be discarded to give the program

```prolog
minimum(X,Y,X)
                   XY,
minimum(X,Y,Y).
```

<!-- page 244 -->
The reasoning offered to justify the program is as follows: "If X is less than or equal to Y, then the minimum is X. Otherwise the minimum is Y, and another comparison between X and Y is unnecessary." Such a comparison is performed, however, by Program 11.3.

There is a severe flaw with this reasoning. The modified program has a different meaning from the standard program for minimum. It succeeds on the goal miriimuxn(2,5,5). The modified program is a false logic program.

The incorrect minimum goal implied by the modified program can be avoided. It is necessary to make explicit the unification between the first and third arguments, which is implicit in the first rule. The modified rule is

```prolog
minimum(X,Y,Z) - XY, !, Z=X.
```

This technique of using the cut to cornniit to a clause after part of the unification has been done is quite general. But for minimum the resultant code is contrived. lt is far better to simply write the correct logic program, adding cuts if efficiency is important, as done in Program 11.3.

Using cut with the operational behavior of Prolog in mind is problematic. lt allows the writing of Prolog programs that are false when read as logic programs, that is, have false conclusions but behave correctly because Prolog is unable to prove the false conclusions. For example, if minimum goals are of the form minimum (X, Y, Z), where X and Y are instantiated, but Z is not, the modified program behaves correctly.

The only effect of the green cuts presented in Section 11.1 is to prune from the search tree branches that are known to be useless. Cuts whose presence in a program changes the meaning of that program are called red cuts. The removal of a red cut from a program changes its meaning, i.e., the set of goals it can prove.

A standard Prolog programming technique using red cuts is the omission of explicit conditions. Knowledge of the behavior of Prolog, specifically the order in which rules are used in a program, is relied on to omit conditions that could be inferred to be true. This is sometimes essential in practical Prolog programming, since explicit conditions, especially negative ones, are cumbersome to specify and inefficient to run. But making such omissions is error-prone.

Omitting an explicit condition is possible if the failure of the previous clauses implies the condition. For example, the failure of the comparison XY in the minimum code implies that X is greater than Y. Thus the test X

<!-- page 245 -->
> Y can be omitted. In general, the explicit condition is effectively the negation of the previous conditions. By using red cuts to omit conditions, negation is being expressed implicitly. delete(Xs,X,Ys) -

Ys is the result of deleting all occurrences of X from the list Xs.

```prolog
delete([XIXs],X,Ys) - !, delete(Xs,X,Ys).
delete([XIXs],Z,[XIYs]) - X
                              Z,
                                 !, delete(Xs,Z,Ys).
delete([ ],X,[ 3).
```

Program 11.9a

Deleting elements from a list

delete(Xs,X,Ys) -

Ys is the result of deleting all occurrences of X from the list Xs.

```prolog
delete([XIXs],X,Ys)
                       ,
                        delete(Xs,X,Ys).
delete([XIXs],Z,[XIYs]) -
                            delete(Xs,Z,Ys).
delete([ ],X,[ 3).
```

Program 11.9b

Deleting elements from a list

Consider Program 11.5 for interchange sort. The first (recursive) rule applies whenever there is an adjacent pair of elements in the list that are out of order. When the second `sort` rule is used, there are no such pairs and the list must be sorted. Thus the condition `ordered(Xs)` can be omitted, leaving the second rule as the fact `sort(Xs,Xs). As` with `minimum,` this is an incorrect logical statement.

Once the `ordered` condition is removed from the program, the cut changes from green to red. Removing the cut from the variant without the `ordered` condition leaves a program that gives false solutions.

Let us consider another example of omitting an explicit condition. Consider Program 3.18 for deleting elements in a list. The two recursive clauses cover distinct cases, corresponding to whether or not the head of the list is the element to be deleted. The distinct nature of the cases can be indicated with cuts, as shown in Program 11.9a.

By reasoning that the failure of the first clause implies that the head of the list is not the same as the element to be deleted, the explicit inequality test can be omitted from the second clause. The modified program is given as Program 11.9b. The cuts in Program 11.9a are green in comparison to the red cut in the first clause of Program 11 .9b.

<!-- page 246 -->
In general, omitting simple tests as in Program 11.9b is inadvisable. The efficiency gain by their omission is minimal compared to the loss of readability and modifiability of the code. if_then_e!se(P,QR)

Either P and Q or not P and R. if_then_else(P,Q,R)

P,

,

Q. if_then_else(P,Q,R) - R. Program 11.10

If-then-else statement

Let us investigate the use of cut to express the if-then-else control structure. Program 11.10 defines the relation `if _then_else(P,Q,R).` Declaratively, the relation is true if P and Q are true, or `not P` and `R` are true. Operationally, we prove P and, if successful, prove Q, else prove `R.`

The utility of a red cut to implement this solution is self-evident. The alternative to using a cut is to make explicit the condition under which R is run. The second clause would read

```prolog
if_then_else(P,Q,R) - not P, R.
```

This could be expensive computationally. The goal P will have to be computed a second time in the determination of `not.`

We have seen so far two kinds of red cuts. One küid is built into the program, as m the definitions of `not` and

. A second kind was a green cut that became red when conditions in the programs were removed. However, there is a third kind of red cut. A cut that is introduced into a program as a green cut that just improves efficiency can turn out to be a red cut that changes the program's meaning.

For example, consider trying to write an efficient version of `member` that does not succeed several times when there are multiple copies of an element in a list. Taking a procedural view, one might use a cut to avoid backtracking once an element is found to be a member of a list. The corresponding code is

```prolog
member(X,[XIXs]) - I.
member(X,[YIYs]) - member(X,Ys).
```

<!-- page 247 -->
Adding the cut indeed changes the behavior of the program. However, it is now not an efficient variant of `member,` since, for example, the query `member(X, [1,2,3])?` gives only one solution, X=1. It is a variant of `member_check,` given as Program 7.3, with the explicit condition X Y omitted, and hence the cut is red. Exercises for Section 11.4

Discuss where cuts could be placed in Program 9.3 for `substi-`

`tute.` Consider whether a cut-fail combination would be useful, and

whether explicit conditions can be omitted.

Analyze the relation between Program 3.19 for `select` and the pro-

gram obtained by adding a single cut:

```prolog
select(X,[XIXs],Xs) - !.
select(X, [YIYs], [YIZs]) - select(X,Ys,Zs)
(Hint: Consider variants of select.)
```

**115 Default Rules**

Logic programs with red cuts essentially consist of a series of special cases and a default rule. For example, Program 11.6 for `not` had a special case when the goal `G` succeeded and a default fact `not G` used otherwise. The second rule for `if_then_else` in Program 11.10 is

```prolog
if_then_else(P,Q,R) - R.
```

It is used by default if P fails.

Using cuts to achieve default behavior is in the logic progranmiing folklore. We argue, using a simple example, that often it is better to compose an alternative logical formulation than to use cuts for default behavior.

Program 11.11 a is a naive program for determining social welfare payments. The relation `pension(Person,Pension)` determines which pension, `Pension,` a person, `Person,` is entitled to. The first `pension` rule says that a person is entitled to an invalid's pension if he is an invalid. The second rule states that people over the age of 65 are entitled to an old age pension if they have contributed to a suitable pension scheme long enough, that is, they must be paid_up. People who are not paid up are still entitled to supplementary benefit if they are over 65.

<!-- page 248 -->
Consider extending Program 11.11 a to include the rule that people receive nothing if they do not qualify for one of the pensions. The procedural "solution" is to add cuts after each of the three rules, and an extra default fact pension (X, nothing). This version is given as Program 11.11b.

Program liJib behaves correctly on queries to determine the pension to which people are entitled, for example, `pension(mc_tavish,X)?.` The program is not correct, though. The query `pension(mc_tavish,noth-` `ing)?` succeeds, which `mc_tavish` wouldn't be too happy about, and `pension(X,old_age_perision)?` has the erroneous unique answer `X=mc_` `tavish.` The cuts prevent alternatives being found. Program 11.IIb only works correctly to determine the pension to which a given person is entitled.

A better solution is to introduce a new relation `erititlement(X,Y),` which is true if X is entitled to Y. lt is defined with two rules and uses Program lilla for `pension:`

```prolog
entitlement(X,Y) - pension(X,Y).
entitlement(X,nothing) - not pension(X,Y).
```

This program has all the advantages of Program 11.11b and neither of the disadvantages mentioned before. It shows that making a person

pension(Person,Pension)

Pension is the type of pension received by Person.

```prolog
pension(X,invalid_pension)
                            invalid(X).
pensiou(X,old_age_pension)
                            over_65(X), paid_up(X).
pension(X,supplementary_benef it)
                                  over_65(X).
invalid(mc_tavish).
over_65(mc.tavish) .
                    over_65(mc_donald) .
                                        over_65(mc_duff)
paid_up(mc_tavish).
                    paid_up(mc.donald).
```

Program 11.11a

Determining welfare payments

pension(Person,Pension) -

Pension is the type of pension receìved by Person.

```prolog
pension(X,invalid_pension)
                            invalid(X),
pension(X,old_age_perision)
                            over_65(X) ,
                                       paid_up(X)
pension(X,supplementary_benefït) - over_65(X) ,
                                             !
pension (X , nothing)
```

<!-- page 249 -->
Program hub Determining welfare payments entitled to nothing as the default rule is really a new concept and should be presented as such.

11.6 Cuts for Efficiency Earlier in this chapter, we claimed that the efficiency of some Prolog programs could be improved through sparing use of the cut. This section explores the claim. Two issues are addressed. The first is the meaning of efficiency in the context of Prolog. The second is appropriate uses of cut.

Efficiency relates to utilization of resources. The resources used by computations are space and time. To understand Prolog's use of space and time, we need to consider Prolog implementation technology.

The two major areas of memory manipulated during a Prolog computation are the stack and the heap. The stack, called the local stack in many Edinburgh Prolog implementations, is used to govern control flow. The heap, called the global stack in many Edinburgh Prolog implementations, is used to construct data structures that are needed throughout the computation.

Let us relate stack management to the computation model of Prolog. Each time a goal is chosen for reduction, a stack frame is placed on the stack. Pointers are used to specify subsequent flow of control once the goal succeeds or fails. The pointers depend on whether other clauses can be used to reduce the chosen goal. Handling the stack frame is simplified considerably if it is known that only one clause is applicable. Technically, a choice point needs to be put on the stack if more than one clause is applicable.

Experience has shown that avoiding placing choice points on the stack has a large impact on efficiency. Indeed, Prolog implementation technology has advanced to the stage that deterministic code, i.e., without choice points, can be made to run almost as efficiently as conventional languages.

<!-- page 250 -->
Cuts are one way that Prolog implementations know that only one clause is applicable. Another way is by the effective use of indexing. Whether a cut is needed to tell a particular Prolog implementation that only one clause is applicable depends on the particular indexing scheme. In this book, we often use the first argument to differentiate between clauses. Indexing on the first argument is the most common among Prolog implementations. For effective use, consult your Prolog manual.

Efficient use of space is determined primarily by controlling the growth of the stack. Already we have discussed the advantages of iterative code and last call optimization. Too many frames placed on the stack can cause computations to abort. In practice this is a major concern. Running out of stack space is a common symptom of an infinite loop or running a highly recursive program. For example, Program 3.9 implementing Ackermann's function, when adapted for Prolog arithmetic, quickly exhausts an implementation's capacity.

Time complexity is approximated by number of reductions. Thus efficient use of time can be determined by analyzing the number of reductions a program makes. In Part I, we analyzed different logic programs by the size of proof trees. In Prolog, size of search tree is a better measure, but it becomes difficult to incorporate Prolog's nondeterminism.

Probably the most important approach to improving time performance is better algorithms Although Prolog is a declarative language, the notion of an algorithm applies equally well to Prolog as to other languages. Examples of good and bad algorithms for the same problem, together with their Prolog implementations, have been given in previous chapters. Linear reverse using accumulators (Program 3.16b) is clearly more efficient than naive reverse (Program 3.16a). Quicksort (Program 3.22) is better than permutation sort (Program 3.20).

Besides coming up with better algorithms, several things can be done to influence the performance of Prolog programs One is to choose a better implementation. An efficient implementation is characterized by its raw speed, its indexing capabilities, support for tail recursion optimization, and garbage collection. The speed of logic programniing languages is usually measured in LIPS, or logical inferences per second. A logical inference corresponds to a reduction in a computation. Most Prolog implementations claim a LIPS rating. The standard benchmark, by no means ideal, is to time Program 3.16a, naive reverse, reversing a list. There are 496 reductions for a list of 30 elements.

<!-- page 251 -->
Once the implementation is fixed, the programs themselves can be tuned by u Good goal ordering, where the rule is "fail as early as possible"

Exploitation of the indexing facility, by ordering arguments appropri-

ately

Elimination of nondeterminism using explicit conditions and cuts

Let us elaborate on the third item and discuss guidelines for using cut. As discussed, Prolog implementations will perform more efficiently if they know a predicate is deterministic. The appropriate sparing use of cut is primarily for saying that predicates are deterministic, not for controlling backtracking.

The two basic principles for using a cut are

Make cuts as local as possible.

Place a cut as soon as it is known that the correct clause has been

chosen.

Let us illustrate the principles with the quicksort program, Program 3.22. The recursive clause is as follows

```prolog
quicksort([XIXsI ,Ys) -
    partition(Xs,X,Littles,Bigs), quicksort(Littles,Ls),
    quicksort(Bigs,Bs), append(Ls, [XIBs] ,Ys).
```

We know there is only one solution for the partition of the list. Rather than place a cut in the clause for quicksort, the partition predicate should be made deterministic. This is in accordance with the first principle.

One of the partition clauses is

```prolog
partition([XIXs] ,Y, EXILs] ,Bs) -
    X
         Y, partition(Xs,Y,Ls,Bs).
1f the clause succeeds, then no other will be applicable. But the cut
```

should be placed before the recursive call to partition rather than after, according to the second principle.

Where and whether to place cuts can depend on the Prolog implementation being used. Cuts are needed only if Prolog does not know the determinism of a predicate. If, for example, indexing can determine that only one predicate is applicable, no cuts are needed. In a system without indexing, cuts would be needed for the same program.

<!-- page 252 -->
Having discussed appropriate use of cuts, we stress that adding cuts to a program should typically be done after the program runs correctly. A common misconception is that a program can be fixed from giving extraneous answers and behaving incorrectly by adding cuts. This is not so. Prolog code should be debugged as declaratively as possible, a topic we discuss in Chapter 13. Only when the logic is correct should efficiency be addressed.

The final factor that we consider in evaluating the efficiency of Prolog programs is the creation of intermediate data structures, which primarily affects use of the heap. Minimizing the number of data structures being generated is a subject that has not received much attention in the Prolog literature. We analyze two versions of the predicate `sublist(Xs,Ys)` to illustrate the type of reasoning possible.

The two versions of `sublist` that we consider involve Program 3.13 for calculating prefixes and suffixes of lists. We must also specify the comparison with respect to a particular use. The one chosen for the analysis is whether a given list is a sublist of a second given list. The first clause that follows denotes a sublìst as a prefix of a suffix, and the second clause defines a sublist as a suffix of a prefix:

```prolog
sublist(Xs,AsXsBs) - suffix(XsBs,AsXsBs), prefix(Xs,XsBs)
sublist(Xs,AsXsBs) - prefix(AsXs,AsXsBs), suffix(Xs,AsXs)
```

Although both programs have the same meaning, there is a difference in the performance of the two programs. If the two arguments to sub- `list` are complete lists, the first clause simply goes down the second list, returning a suffix, then goes down the first list, checking if the suffix is a prefix of the first list. This execution does not generate any new intermediate data structures. On the other hand, the second clause creates a new list, which is a prefix of the second list, then checks ifthis list is a suffix of the first list. If the check fails, backtracking occurs, and a new prefix of the first list is created.

<!-- page 253 -->
Even though, on the average, the number of reductions performed by the two clauses is the same, they are different in their efficiency. The first clause does not generate new structures (does not cons, in Lisp jargon). The second clause does. When analyzing Lisp programs, it is common to examine the consing performance in great detail, and whether a program conses or not is an important efficiency consideration. We feel that the issue is important for Prolog programs, but perhaps the state of the art of studying the performance of large Prolog programs has not matured enough to dictate such analyses. 11.7 Background The cut was introduced in Marseilles Prolog (Colmerauer et al., 1973) and was perhaps one of the most influential design decisions in Prolog. Colmerauer experimented with several other constructs, which corresponded to special cases of the cut, before coming up with its full definition.

The terminology green cuts and red cuts was introduced by van Emden (1982), in order to try to distinguish between legitimate and illegitimate uses of cuts. Alternative control structures, which are more structured then the cut, are constantly being proposed, but the cut still remains the workhorse of the Prolog programmer. Some of the extensions are if-thenelse constructs (O'Keefe, 1985) and notations for declaring that a relation is functional, or deterministic, as well as "weak-cuts," "snips," remotecuts (Chikayama, 1984), and not itself, which, as currently implemented, can be viewed as a structured application of the cut.

The controversial nature of cut has not been emphasized in this book. A good starting place to read about some of cut's problems, and the variation in its implementation, is Moss (1986). Many of the difficulties arise from the scope of the cut, and how cuts interact with the system predicates for control such as conjunction, disjunction, and the metavariable facility. For example, two versions of call have been suggested, one that blocks the cut and one that does not. Further discussion of cut can be found in O'Keefe (1990), including an exposition on when cut should be used.

Some Prologs provide if_then_else(P,Q,R) under the syntax P - Q; R and an abridged if-then form P -

Q. Whether to include if-then-else in Standard Prolog has been a controversial issue. The trade-off is convenience for some programming tasks versus thorny semantic anomalies. This issue has been raised several times on the USENET newsgroup comp.lang.prolog. Relevant comments were collected in the May 1991 issue of the Newsletter of the Association for Logic Progranmiing, Volume 4, No. 2.

<!-- page 254 -->
The cut is also the ancestor of the commit operator of concurrent logic languages, which was first introduced by Clark and Gregory (1981) in their Relational Language. The commit cleans up one of the major drawbacks of the cut, which is destroying the modularity of clauses. The cut is asymmetric, because it eliminates alternative clauses below the clause in which it appears, but not above. Hence a cut in one clause affects the meaning of other clauses. The commit, on the other hand, is symmetric and therefore cannot implement negation as failure; it does not destroy the modularity of clauses.

The pioneering work on Prolog implementation technology was in D.H.D. Warren's Ph.D. thesis (1977). Warren later added tail recursion optimization to his original DEC-10 compiler (1986). Tail recursion optimization was implemented concurrently by Bruynooghe (1982) in his Prolog system. A motley collection of papers on Prolog implementations can be found in Campbell (1984).

Most current compilers and implementation technology are based on the WAM (Warren Abstract Machine), published as a somewhat cryptic technical report (Warren, 1983). Readers seriously interested in program efficiency need to understand the WAM. The best places to start reading about the WAM are Maier and Warren (1988) and AIt-Kaci (1991).

References to negation in logic programming can be found in Section 5.6. Implementations of a sound negation as failure rule in dialects of Prolog can be found in Prolog-II (van Caneghem, 1982) and MU-Prolog (Naish, 1985a).

The program for same_var and its argument for correctness are due to O'Keefe (1983).

Program hub for pension is a variant of an example due to Sam Steel for a Prolog course at the University of Edinburgh - hence the Scottish flavor. Needless to say, this is not intended as, nor is it an accurate expression, of the Scottish or British social welfare system.
