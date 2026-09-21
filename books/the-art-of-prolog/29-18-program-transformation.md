# 18 Program Transformation

<!-- page 398 -->
As stated in the introduction to Chapter 17, meta-prograniming, or the writing of programs that treat other programs as data, is particularly easy in Prolog. This chapter gives examples of programs that transform and manipulate Prolog programs. The first section looks at fold/unfold, the operation that underlies most applications of program transformation for Prolog programs. The transformations given in Chapter 15 for using difference-lists to avoid explicit concatenation of lists can be understood as unfold operations, for example. The second section describes a simple system for controlled unfolding and folding, which is especially good for removing layers of interpretation. The final section gives two examples of source-to-source transformation by code walking

18.1 Unfold/Fold Transformations Logic programming arose from research on resolution theorem proving. The basic step in the logic programming computation model, goal reduction, corresponds to a single resolution between a query and a program clause. Unfold/fold operations correspond to resolution between two Horn clauses. Loosely, unfolding corresponds to replacing a goal in the body of a clause by its definition, while folding corresponds to recognizing that goal(s) in the body of a clause are an instance of a definition. These two operations, being so similar, are often discussed together.

<!-- page 399 -->
We demonstrate unfolding and folding with a running example in the first part of this chapter. The example is specializing the interpreter for nondeterministic pushdown automata (Program 17.3) for the particular pushdown automaton for recognizing palindromes (Program 17.4). In general, specializing interpreters is a good application for unfold/fold operations. Definition Unfolding a goal B in a clause A - B1,.. .,B with respect to a clause B

- C1,. . .,Cm where B and B unify with mgu O, produces a clause (A - B1,.. .,B1,C1,. . .,Cm,Bji.....B)O.

As an example of unfolding, we specialize the clause `accept (Xs) -` `initial(Q), accept(Xs,Q, [ ])` to a particular initial state by unfolding the `initial (Q)` goal with respect to a particular `initial` fact. Specifically, unfolding with respect to the fact `initial (push)` produces the clause `accept(Xs) - accept(Xs,push,` E ]). (Note that in our running example we use the states `push` and `pop` for qQ and qi, respectively, from the NPDA of Program 17.4.)

The effect of the unfolding is to instantiate the initial state for the NPDA to `push.` In general, the effect of unfolding is to propagate variable bindings to the right, as in this example, and also to the left, to goals in the body of the clause and possibly also to the head.

There may be several clauses whose heads unify with a given goal in the body of a clause. We extend the definition of unfolding accordingly. Definition Unfolding a goal B in a clause A - B1,. . .,B with respect to a procedure defining B is to unfold the goal with respect to each clause in the procedure whose head unifies with B.

u

Unfolding the `delta/5` goal in the clause `accept([XIXs],Q,S)` `delta(Q,X,S,Q1,S1), accept(Xs,Q1,S1)` withrespect to the following procedure for `delta` adapted from Program 17.4

```prolog
delta(push,X,S,push, [XIS]).
                                  delta(push,X,S,pop, [XIS]).
delta(push,X,S,pop,S).
                                  delta(pop,X,[XIS],pop,S).
```

produces four clauses, one for each fact.

```prolog
accept([XIXs],push,S) - accept(Xs,push, [XIS]).
accept([XIXs],push,S) - accept(Xs,pop, [XIS]).
accept([XIXs],push,S) - accept(Xs,pop,S).
accept([XIXs] ,pop, [XIS]) - accept(Xs,pop,S).
```

<!-- page 400 -->
palindrome(Xs)

The string represented by the list Xs is a palindrome.

```prolog
palindrome(Xs) - palindrome(Xs,push, E 1).
palindrome([XIXs],push,S) - palïndrome(Xs,push, [XIS]).
palindrome([XIXs] ,push,S)
                           palindrome(Xs,pop, [XIS]).
palindrome([XIXs] ,push,S) - palindrome(Xs,pop,S).
paliridrome([XIXs] pop, [XIS]) - palindrome(Xs,pop,S).
palindrome([ ],pop,[ 1).
```

Program 18.1 A program accepting palindromes

This example shows variable bhidings being propagated both to the right, and to the head of the clause left of the goal being unfolded.

Folding is the reverse of unfolding. The occurrence of a body of a clause is replaced by its head. It is easiest to show with an example. Folding the goal `accept (Xs,push,` L 1) m the clause `accept(Xs) - ac-` `cept(Xs,push, [` J) with respect to the clause `palindrome(Xs,State,` `Stack) - accept(Xs,State,Stack)` produces the clause `accept(Xs)`

```prolog
palindrome(Xs,push,[ J).
```

Note that if we now unfold the goal `palindrome (Xs ,push,` E ]) in `ac-` `cept(Xs) - paliridrome(Xs,push,` L J) with respect to the clause just used for folding, `palindrome(Xs,State,Stack) - accept(Xs,State,` `Stack),` we arrive back at the original clause, `accept (Xs) - accept (Xs,` `push, [` J). Ideally, fold/unfold are inverse operations.

Our example of folding used an iterative clause, i.e., one with a single goal in the body. Folding can be performed on a conjunction of goals, but there are technical difficulties arising from the scope of variables. Here we restrict ourselves to iterative clauses. The reader interested in the more general case should study the references given at the end of the chapter.

Specialization of the interpreter of Program 17.3 is completed by unfolding the `f irial(L)` goal in the third clause of Program 17.3, folding all occurrences of `accept/3,` and folding with respect to the clause `palm-` `drome(Xs) - accept(Xs).` Program 18.1 is then obtained.

Propagating bindings leftward in Prolog will not preserve correctness in general. For example, consider unfolding the goal `r (X)` with respect to the fact `r(3)` in the clause `p(X) - var(X)`

```prolog
,
  r(x). The resulting clause,
```

<!-- page 401 -->
`p (3) - var(3),` clearly always fails, in contrast with the original clause. Unfolding for Prolog can be performed correctly by not propagating bindings leftward, and replacing the unfolded goal by the unifier. For this example, the result would be `p(X) - var(X), X=3.` This will not be an issue in the examples we consider. Exercise for Section 18.1

(i)

Specialize the interpreter of Program 17.1 to the NDFA of Pro-

gram 17.2, or any other NDFA, by unfold/fold operations.

18.2 Partial Reduction In this section we develop a simple system for controlled unfold/fold operations according to prescribed user declarations. Systems for controlled unfolding are known in the logic programming literature as partial evaluators. This name reveals the influence of functional programming, where the basic computation model is evaluation. We prefer to refer to the system in terms of the computation model of logic programming, goal reduction. We thus, nonstandardly, say our system is doing partial reduction, and call it a partial reducer.

Considerable research on applying partial reduction has shown that partial reduction is especially useful for removing levels of interpretation. The sequence of unfold/fold operations given in Section 18.1 typify what is possible. The general NPDA interpreter was specialized to a specific NPDA, removing interpreter overhead. The resulting program, Program 18.1, only recognizes palindromes but does so far more efficiently than the combination of Programs 17.3 and 17.4.

<!-- page 402 -->
Let us see how to build a system that can apply the unfold and fold operations that were needed to produce the `palindrome` program. The main idea is to recursively perform unfold/fold until no more "progress" can be achieved. A relation that replaces a goal by its equivalent under these operations is needed. The resulting equivalent goal is known as a residue. Let us call our basic relation `preduce (Goal ,Residue),` with intended meaning that `Residue` is a residue arising from partially reducing `Goal` by applying unfold and fold operations. preduce(Goal,Residue) -

Partially reduce Goal to leave the residue Residue.

```prolog
preduce(true,true) - L
preduce((A,B),(PA,PB))
                          ,
                           preduce(A,PA), preduce(B,PB).
preduce(A,B) - should_fold(A,B),
preduce(A,Residue)
    should_unfold(A),
                     !
                      ,
                        clause(A,B), preduce(B,Residue)
preduce(A,A).
```

Program 18.2 A meta-interpreter for determining a residue

Program 18.2 contains code for `preduce.` There are three possibilities for handling a single goal. It can be folded, unfolded, or left alone. The question immediately arises how to decide between the three possibilities. The easiest for a system is to rely on the user. Program 18.2 assumes that the user gives `should_fold (Goal , FoldedGoal)` declarations that say which goals should be folded and to what they should be folded, and also `should_unfold(Goal)` declarations that say which goals should be unfolded. Unification against the program clauses determines to what they should be unfolded. Goals not covered by either declaration are left alone. The remaining clauses in Program 18.2 handle the empty goal, `true,` and conjunctive goals, which are treated recursively in the obvious way.

Observe that Program 18.2 is essentially a meta-interpreter at the granularity level of vanilla (Program 17.5). The meta-interpreter is enhanced to return the residue. Handling builtins is assigned to the exercises.

```prolog
The query preduce((initial(Q), accept(Xs,Q,[ 1)), Residue)?
```

assuming appropriate `should_fold` and `should_unfold` declarations (to be given shortly) has as solution `Residue = (true,palindromo(Xs,` `push,` E ])). lt would be preferable to remove the superfluous call to `true. This` can be done by modifying the clause handling conjunctive goals to be more careful in computing the conjunctive resolvent. A suitable modification is

```prolog
preduce((A,B) ,Res) -
     !, preduce(A,PA), preduce(B,PB), combine(PA,PB,Res),
```

<!-- page 403 -->
The code for `combine,` removing superfluous empty goals, is given in Program 18.3. process(Program, RedProgram) -

Partially reduce each of the clauses in Program to produce

RedProgram.

```prolog
process(Prog,NewProg) -
    findall(PC1, (member(C1 ,Prog) ,preduce(C1 ,PC1)) ,NewProg).
test (Name ,Program) -
    program(Name,Clauses), process(Clauses,Prograxn).
```

preduce ( Goal,Residue) -

Partially reduce Goal to leave the residue Residue.

```prolog
preduce((A - B),(PA
                      PB))
    !, preduce(B,PB), preduce(A,PA).
preduce(true,true) -
preduce((A,B) ,Res) -
    !, preduce(A,PA), preduce(B,PB), combine(PA,PB,Res).
preduce(A,B) - should_fold(A,B),
preduce(A,Residue) -
    should_unf oid(A) ,
                     !
                      ,
                        ciause(A,B)
                                    preduce(B,Residue).
preduce(A,A).
combine(true,B,B) -
combine(A,true,A) -
combine(A,B,(A,B)).
```

Program 18.3 A simple partial reduction system

To extend Program 18.2 into a partial reducer, clauses must be handled as well as goals. We saw a need in the previous section to partially reduce the head and body of a clause. The only question is in which order. Typically, we will want to fold the head and unfold the body. Since unfolding propagates bindings, unfolding first will allow more specific folding. Thus our proposed rule for handling clauses is

```prolog
preduce((A - B),(PA - PB)) -
     !, preduce(B,PB), preduce(A,PA).
```

This goal order is advantageous for the example of the rule interpreter to be presented later in this section.

<!-- page 404 -->
To partially reduce a program, we need to partially reduce each of its clauses. For each clause, there may be several possibilities because of nondeterrninism. For example, the recursive `accept/3` clause led to four rules because of the four possible ways of unfolding the `delta` goal. The

```prolog
prograin(npda,[(accept(Xsl)
                            initial(Q1), accept(Xsl,Q1,[ 1),
    (accept([X2IXs2],Q2,S2) - delta(Q2,X2,S2,Q12,S12),
    accept(Xs2,Q12,S12)), (accept([ ],Q3,[ J)
                                              true)]).
should_unf old C initial (Q))
should_unfold(final(Q))
should_unfold(delta(A,B,C,D,E)).
should_fold(accept(Q,Xs,Q1),palindrome(Q,Xs,Q1)).
should_fold (accept (Xs) ,palindrome (Xs)).
```

Program 18.4

Specializing an NPDA

cleanest way to get the whole collection of program clauses is to use the all-solutions predicate `f indall.` That gives

```prolog
process (Prog, NewProg) -
     f indall(PC1, (mernber(Cl,Prog), preduce(Cl,PC1)) ,NewProg).
```

Putting all the preceding actions together gives a simple system for partial reduction. The code is presented as Program 18.3. The program also contains a testing clause.

We now concentrate on how to specify `should_fold` and should_ `unf`old declarations. Consider the NPDA example for recognizing palindromes. The `initial, final,` and `delta` goals should all be unfolded. A declaration is needed for each. The `accept/i` and `accept/3` goals should be folded into palindrome goals with the same argument. The declara-

```prolog
tion for accept/i is should_f old(accept(Xs),palindrome(Xs)). All
```

the necessary declarations are given in Program 18.4. Program 18.4 also contains the test program as data. Note the need to make all the variables in the program distinct. Applying Program 18.3 to Program 18.4 by posing the query `test(npda,P)?` produces Program 18.1, with the only difference being an explicit empty body for the last `palindrome` fact.

<!-- page 405 -->
We now give a more complicated example of applying partial reduction to remove a level of overhead. We consider a simpler variant of the rule interpreter given in Section 17.4. The variant is at the bottom level of the layered interpreter. The interpreter, whose relation is `solve(A,N),` counts the number of reductions used in solving the goal `A.` The code for `solve` and related predicate `solve_body` is given in Program 18.5. The rules that we will consider constitute Program 17.17 for determining Rule interpreter for counting reductions

```prolog
solve(A,1) - fact(A).
solve(A,N) - rule(A,B,Name), solve_body(B,NB), N is NB+1.
solve_body (A&B , N)
    solve_body(A,NA), solve_body(B,NB), N is NA+NB.
solve_body(A is_true,N) - solve(A,N).
```

Sample rule base

```prolog
rule(oven(Dish,top) ,pastry(Dish) is_true
         & size(Dish,small) is_true,placel)
rule(oven(Dish,middle) ,pastry(Dish) is_true
         & size(Dish,big) is_true,place2).
rule (oven(Dish,middle) ,main_meal(Dish) is_true,place3).
rule (oven(Dish,bottom) , slow_cooker(Dish) is_true,place4)
rule(pastry(Dish),type(Dish,cake) is_true,pastryl).
rule (pastry(Dish) ,type(Dish,bread) is_true,pastry2).
rule(main_meal(Dish) ,type(Dish,meat) is_true ,main_meal).
rule(slow_cooker (Dish) ,type(Dish,milk_pudding)
            is_true ,slow_cooker).
should_fold(solve(oven(D,P),N),oven(D,P,N)).
should_fold(solve(pastry(D),N),pastry(D,N)).
should_fold(solve(main_meal(D) ,N) ,main_meal(D,N)).
should_fold(solve(slow_cooker(D),N),slow_cooker(D,N)).
should_fold(solve(type(D,P),N),type(D,P,N)).
should_fold(solve(size(D,P),N),size(D,P,N)).
should_unfold(solve_body(G,N)).
should_unfold(rule(A,B,Name)).
program(rule_interpreter, [(solve(A1,l) - fact(A1)),
    (solve(A2,N) - rule(A2,B,Name), solve_body(B,NB), N is NB+i)]).
```

Program 18.5

<!-- page 406 -->
Specializing a rule interpreter where a dish should be placed in the oven. The rules are repeated in Program 18.5 for convenience.

The effect of partial reduction in this case will be to "compile" the rules into Prolog clauses where the arithmetic calculations are done. The resulting Prolog clauses can in turn be compiled, in contrast to the combination of interpreter plus rules. Rule `place i will` be transformed to

```prolog
oven(Dish,top,N)
    pastry(Dish,N1), size(Dish,small,N2),
     N3 is N1+N2, N is N3+1.
```

The idea is to unfold the calls to `rule` so that each rule can be handled, and also to unfold the component of the interpreter that handles syntactic structure, specifically `solvebody.` What gets folded are the individual calls to `solve,` such as `solve (oven (D,P) ,N),` which gets replaced by a predicate `oven (D , P, N)` The necessary declarations are given in Program 18.5. Program 18.3 applied to Program 18.5 produces the desired effect.

Specifying what goals should be folded and unfolded is in general straightforward in cases similar to what we have shown. Nevertheless, making such declarations is a burden on the programmer. In many cases, the declarations can be derived automatically. Discussing how is beyond the scope of the chapter.

How useful partial reduction is for general Prolog programs is an open issue. As indicated, care must be taken when handling Prolog's impurities not to change the meaning of the program. Further, interaction with Prolog implementations can actually mean that programs that have been partially reduced can perform worse than the original program. lt will be interesting to see how much partial reduction will be applied for Prolog compilation.

Exercises for Section 182

Extend Program 18.3 to handle builtins.

Apply Program 18.3 to the two-level rule interpreter with rules

<!-- page 407 -->
given as Program 17.20. 18.3 Code Walking The examples of meta-prograrnniing given so far in Chapters 17 and 18 are dynamic in the sense that they "execute" Prolog programs by performing reductions. Prolog is also a useful language for writing static meta-programs that perform syntactic transformations of Prolog programs. In this section, we give two nontrivial examples in which programs are explicitly manipulated syntactically.

The first example of explicit program manipulation is program composition. In Section 13.3, stepwise enhancement for systematic construction of Prolog programs was introduced. The third and final step in the method is composition of separate enhancements of a common skeleton. We now present a program to achieve composition that is capable of composing Programs 13.1 and 13.2 to produce Program 13.3.

The running example we use to illustrate the program is a variant of the example in Chapter 13. The skeleton is the same, namely, skel([XIXs],Ys) - member(X,Ys), skel(Xs,Ys). skel([XIXs],Ys) - nonmember(X,Ys), skel(Xs,Ys). skel([ ],Ys). The union program, Program 13.1, is also the same, namely, union([XIXs],Ys,Us) - member(X,Ys), union(Xs,Ys,Us). union([XIXs] ,Ys, [XIUs]) - nonmember(X,Ys), union(Xs,Ys,Us). union([ ],Ys,Ys). The second program to be composed is different and represents when added goals are present. The relation to be used is common(Xs,Ys,N), which counts the number of common elements N in two lists Xs and Ys. The code is coinmon([XIXs],Ys,N) -

meinber(X,Ys), conimon(Xs,Ys,M), N is M+1. coinmon([XIXs],Ys,N) - nonmember(X,Ys), coinmon(Xs,Ys,N). comnion([ J,Ys,O).

<!-- page 408 -->
The program for composition makes some key assumptions that can be justified by theory underlying stepwise enhancement. Describing the theory is beyond the scope of this book. The most important assumption is that there is a one-to-one correspondence between the clauses of the two programs being composed, and one-to-one correspondences between the clauses of each of the programs and the common skeleton.

Programs are represented as lists of clauses. The first clause in the first program corresponds to the first clause in the second program and to the first clause in the skeleton. Our assumption implies that the lists of clauses of programs being composed have the same length. The three programs have been written with corresponding clauses in the same order. (That the lists of clauses do have the same length is not checked explicitly.)

In order to perform composition, a composition specification is needed. It states how the arguments of the final program relate to the two extensions. The relation that we will assume is `composition_`

```prolog
specification(Programl,Program2,Skeleton,FinalProgram). An ex-
```

ample of the specification for our running example is `composition_`

```prolog
specification(union(Xs,Ys,Us), conunon(Xs,Ys,N), skel(Xs,Ys),
```

`uc(Xs,Ys,Us,N).` The composition specification is given as part of Program 18.6.

The program for composition is given as Program 18.6. The top-level relation is `compose/4,` which composes the first two programs assumed to be enhancements of the third argument to produce the composite program, which is the fourth argument.

The program proceeds clause by clause in the top ioop of Program 18.6, where `compose_clause/4` does the clause composition. The arguments correspond exactly to the arguments for `compose. To` compose two clauses, we have to compose the heads and the bodies. Composition of the heads of clauses happens through unification with the composition specification. The predicate `compose_bodies/4 is` used to compose the bodies. Note that the order of arguments has been changed so that we systematically traverse the skeleton. Each goal in the skeleton must be represented in each of the enhancements so that it can be used as a reference to align the goals in each of the enhancements.

<!-- page 409 -->
The essence of `compose_bodies` is to traverse the body of the skeleton goal by goal and construct the appropriate output goal as we proceed. In order to produce tidy output and avoid superfluous empty goals, a difference-structure is used to build the output body. The first clause for `compose_bodies` covers the case when the body of the skeleton is nonempty. The predicates `first` and `rest,` which access the body of the skeleton, are a good example of data abstraction. compose (Program 1 ,Program2,Skeleton,FinalProgram) -

FinaiProgram is the result of composing Program i and

Program2, which are both enhancements of Skeleton.

```prolog
compose([CllIClsl] , [Cl2ICis2] , [CiSkellCisSkei] ,[Cl
                                                Cisl) -
    compose_clause(Cll ,C12 ,ClSkel ,Cl),
    compose (Cisl ,Cls2,CisSkei,Cls)
compose([ ]j ],[ ],[ 1).
compose_clause((AlBl) , (A2B2) , (ASkelBSkel) ,(AB)) -
    composition_specification(Al ,A2 ,ASkel ,A)
    compose_bodies(BSkei,Bl ,B2,B\true).
compose_bodíes(SkeiBody,Bodyl ,Body2,B\BRest) -
    first (SkelBody,G),
    align(G,Bodyl Cl ,RestBodyl ,B\Bl),
    align(G,Body2,G2,RestBody2,Bl\(Goal,B2)),
    compose_goal(Gl ,G2,Goai),
    rest(SkeiBody,Gs)
    compose_bodies(Gs,RestBodyl ,RestBody2,B2\BRest).
compose_bodies (true, Bodyl , Body2 , B\BRest) -
    rest_goals (Bodyl,B\Bl), rest_goals(Body2,Bl\BRest).
align(Goal,Body,G,RestBody,B\B) -
    first(Body,G), correspond(G,Goai),
                                      ,
                                       rest(Body,RestBody).
align(Goal,(G,Body),CorrespondingG,RestBody,(G,B)\Bl) -
    align (Goal ,Body, CorrespondingG , RestBody , B\Bl).
first((G,Gs) ,G)
first(G,G) - G
                 (A,B), G
                            true.
rest((G,Gs) ,Gs)
rest(G,true) - G
                   (A,B).
correspond (G , G)
correspond(G,B)
                  map(G,B).
compose_goai(G,G,G) -
                      !
compose_goai(Al ,A2,A) -
       composition_specification(Al,A2,ASkei,A).
rest_goals(true,B\B) -
                       !
rest_goals(Body, (G,B)\BRest) -
    first(Body,G),
                   ,
                     rest(Body,Bodyl), rest_goais(Bodyl,B\BRest).
```

Program 18.6

<!-- page 410 -->
Composing two enhancements of a skeleton

An important assumption made by Program 18.6 concerns finding the goals in the bodies of the program that correspond to the goals in the skeleton. The assumption made, embedded in the predicate `correspond,` is that a mapping will be given from goals in the enhancement to goals in the skeleton. In our running example, the predicates `member` and `non-` `member` map onto themselves, while both `union` and `common` map onto `skel.` This information, provided by the predicate `map/2,` is needed to correctly align goals from the skeleton with goals of the program being composed. The code for `align` as presented allows for additional goals to be present between goals in the skeleton. The only extra goal in our running example is the arithmetic calculation in `common,` which is after the goals corresponding to the skeleton goals.

The second clause for `compose_bodies` covers the case when the body is empty, either from dealing with a fact or because the skeleton has been traversed. In this case, any additional goals need to be included in the result. This is the function of `rest_goals.`

Program 18.7 contains a testing clause for Program 18.6, along with the specific data for our running example. As with Program 18.4, variables in the programs being composed must be named differently. Automatic generation of composition specifications for more complicated examples is possible.

The second example of explicit manipulation of programs is the conversion of context-free grammar rules to equivalent Prolog clauses. Context-free grammars are defined over a language of symbols, divided into nonterminal symbols and terminal symbols. A context-free grammar is a set of rules of the form (head) - (body) where head is a nonterminal symbol and body is a sequence of one or more items separated by commas. Each item can be a terminal or nonterminal symbol. Associated with each grammar is a starting symbol and a language that is the set of sequences of terminal symbols obtained by repeated (nondeterministic) application of the grammar rules starting from the starting symbol. For compatibility with Chapter 19, nonterminal symbols are denoted as Prolog atoms, terminal symbols are enclosed within lists, and II denotes the empty operation.

<!-- page 411 -->
The language a(bc)* can be defined by the following context-free grammar consisting of four rules: test_compose (X, Prog) -

```prolog
programl(X,Progl), program2(X,Prog2),
skeleton(X,Skeleton), compose(Progl ,Prog2 ,Skeleton,Prog).
```

programi (test,

(union([X1IXs1] ,Ysl,Zsl) -

```prolog
    member(X1,Ysi), union(Xsl,Ysi,Zsl)),
(union([X2IXs2] ,Ys2, [X2IZs2]) -
    nonmember(X2,Ys2), union(Xs2,Ys2,Zs2)),
(union([ ],Ys3,Ys3) - true)]).
```

program2(test, E

(common([X1IXs1] ,Ysl,Ni)

```prolog
    member(Xi,Ysl), comxnon(Xsl,Ysl,M1), Nl is M1+l),
(common([X2IXs2] ,Ys2,N2) -
   nonmember(X2,Ys2), common(Xs2,Ys2,N2)),
(cominon([ ],Ys3,O) - true)]).
```

**skeleton(test, I**

(skel([X1IXs1],Ysl) - member(Xl,Ysl), skel(Xsl,Ysl)),

(skel([X2IXs2] ,Ys2) - nonmember(X2,Ys2), skel(Xs2,Ys2)),

**(skel([ ],Ys3) - true)]).**

composition_specification(union(Xs,Ys,Us), common(Xs,Ys,N)

```prolog
skel(Xs,Ys) ,uc(Xs,Ys,Us,N))
```

rnap(union(Xs,Ys,Zs), skel(Xs,Ys)) map(common(Xs,Ys,N), skel(Xs,Ys)). Program 18.7

Testing program composition

```prolog
s -
      [a], b.
b - [b], c.
b -
      [
       ].
c -
      [c], b.
```

**Another example of a context-free grammar is given in Figure 18.1.**

This grammar recognizes the language a*b*c*.

**A context-free grammar can be immediately written as a Prolog pro-**

**gram. Each nonterminal symbol becomes a unary predicate whose argu-**

**ment is the sentence or phrase it identifies. The naive choice for repre-**

**senting each phrase is as a list of terminal symbols. The first grammar**

rule in Figure 18.1 becomes

```prolog
s(Xs) - a(As), b(Bs),
     c(Cs), append(Bs,Cs,BsCs), append(As,BsCs,Xs).
```

<!-- page 412 -->
**s -' a, b, c.**

**a - [a], a.**

a -. [ ]. b

[b], b. b

**[J.**

c -. [c], c. C

£ J. Figure 18.1 A context-free grammar for the language a*b*c*

s(As\Xs) '- a(As\Bs), b(Bs\Cs), c(Cs\Xs). a(Xs\Ys) - connect([a] ,Xs\Xsl), a(Xsl\Ys). a(Xs\Ys) - connect([ ] ,Xs\Ys) b(Xs\Ys) '- connect([b] ,Xs\Xsl), b(Xsl\Ys). b(Xs\Ys) - connect([ ],Xs\Ys). c(Xs\Ys) - cormect([c],Xs\Xsl), c(Xsl\Ys). c(Xs\Ys) - cormect([ ],Xs\Ys). connect([ ] ,Xs\Xs). connect([WIWs] , [WIXs]\Ys)

```prolog
connect(Ws,Xs\Ys).
```

Program 18.8 A Prolog program parsing the language a*b*c*

Completing the grammar of Figure 18.1 in the style of the previous rule leads to a correct program for parsing, albeit an inefficient one. The calls to append suggest, correctly, that a difference-list might be a more appropriate structure for representing the sequence of terminals in the context of parsing. Program 18.8 is a translation of Figure 18.1 to a Prolog program where difference-lists represent the phrases. The basic relation scheme is s(Xs), which is true if Xs is a sequence of symbols accepted by the grammar.

The predicate connect (Xs,Ws) is true if the list Xs represents the same sequence of elements as Ws. The predicate is used to make explicit the translation of terminal symbols to Prolog programs.

<!-- page 413 -->
As a parsing program, Program 18.8 is a top-down, left-to-right recursive parser that backtracks when it needs an alternative solution. Although easy to construct, backtracking parsers are in general inefficient. However, the efficiency of the underlying Prolog implementation in general more than compensates. translate( Grammar,Program) -

Program is the Prolog equivalent of the context-free

grammar Grammar.

```prolog
translate ([Rule Rules] , [Clause
                             I Clauses]) -
    translate_rule(Rule ,Clause),
    translate (Rules , Clauses)
translate([ ],[ J).
```

translate_rule ( GrammarRule,PrologClause) -

Prolog Clause is the Prolog equivalent of the grammar

rule GrammarRule.

```prolog
translate_rule((Lhs - Rhs),(Head - Body)) -
    translate_head(Lhs,Head,Xs\Ys),
    translate_body (Rhs ,Body, Xs\Ys).
translate_head(A,Al ,Xs) -
    translate_goal(A,Al ,Xs).
translate_body(A,B) , (Al ,B1) ,Xs\Ys) -
       translate_body(A,Al,Xs\Xsl), translate_body(B,Bl,Xsl\Ys).
translate_body (A,Al ,Xs)
    translate_goal(A,Al ,Xs).
translate_goal (A,Al ,DList) -
    nonterminal(A), functor(Al,A,l), arg(l,Al,DList).
translate_goal(Terms,coirnect(Terms,S) ,S)
    terminals (Terms).
nonterminal(A)
                 atom(A).
terminals(Xs) - list(Xs).
```

`list(Xs) -` seeProgram3.11. Program 18.9

Translating grammar rules to Prolog clauses

We now present Program 18.9, which translates Figure 18.1 to Program 18.8. As for Program 18.6, the translation proceeds clause by clause. There is a one-to-one correspondence between grammar rules and Prolog clauses. The basic relation is `translate(Rules,Clauses).` Individual clauses are translated by `translate.rule/2.` To translate a rule, both the head and body must be translated, with the appropriate correspondence of difference-lists, which will be added as additional arguments.

<!-- page 414 -->
Adding an argument is handled by the predicate `translate_goal.` If the goal to be translated is a nonterminal symbol, a unary predicate with the same functor is created. If the goal is a list of terminal symbols, the appropriate connect goal is created. When executed, the connect goal connects the two difference-lists. Code for connect is in Program 18.8.

Program 18.9 can be extended for automatic translation of definite clause grammar rules. Definite clause grammars are the subject of Chapter 19. Most versions of Edinburgh Prolog provide such a translator. Exercise for Section 18.3

(i)

Apply Program 18.6 to one of the exercises posed at the end of

Section 13.3.

**18.4 Background**

Often research in logic programming has followed in the steps of related research in functional programming. This is true for unfold/fold and partial evaluation. Burstall and Darlington (1977) wrote the seminal paper on unfold/fold in the functional programming literature. Their work was adapted for logic programming by Tamaki and Sato (1984).

<!-- page 415 -->
The term partial evaluation may have been used first in a paper by Lombardi and Raphael (1964), where a simple partial evaluator for Lisp was described. A seminal paper introducing partial evaluation to computer science is due to Futamura in 1971, who noted the possibility of compiling away levels of interpretation. Komorowski described the first partial evaluator for pure Prolog in his thesis in 1981. He has since preferred the term partial deduction. Gallagher in 1983 was the first to advocate using partial evaluation in Prolog for removing interpretation overhead (Gallagher, 1986). Venken (1984) was the first to list some of the problems of extending partial evaluation to full Prolog. The paper that sparked the most interest in partial evaluation in Prolog is due to Takeuchi and Furukawa (1986). They discussed using partial evaluation for removing runtime overhead and showed an order of magnitude speedup. Sterling and Beer (1989) particularize the work for expert systems. Their paper introduces the issue of pushing down meta-arguments, which is subsumed in this chapter by should_fold declarations. Specific Prolog partial evaluation systems to read for more details are ProMiX (Lakhotia and Sterling, 1990) and Mixtus (Sahlin, 1991). An interesting application of partial evaluation is given by Smith (1991), where efficient string-matching programs were developed.

Composition was first discussed in the context of Prolog meta-interpreters in Sterling and Beer (1989) and an informal algorithm was given in Sterling and Lakhotia (1988). A theory is found in Kirschenbaum, Sterling, and Jam (1993).
