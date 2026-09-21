# 17 Interpreters

<!-- page 360 -->
Meta-programs treat other programs as data. They analyze, transform, and interpret other programs. The writing of meta-programs, or metaprogramming, is particularly easy in Prolog because of the equivalence of programs and data: both are Prolog terms. We have already presented some examples of meta-programs, namely, the editor of Program 12.5 and the shell process of Program 12.6. This chapter covers interpreters, an important and useful class of meta-programs, and Chapter 18 discusses program transformation.

17.1 Interpreters for Finite State Machines The sharp distinction between programs and data present in most computer languages is lacking in Prolog. The equivalence of programs and data greatly facilitates the writing of interpreters. We demonstrate the facility in this section by considering the basic computation models of computer science. interpreters for the various classes of automata are very easily written in Prolog.

lt is interesting to observe that the interpreters presented in this section are a good application of nondetermmistic progranmiing The programs that are presented illustrate typical examples of don't-know nondeterminism. The same interpreter can execute both deterministic and nondetermimstic automata because of the nondeterminism of Prolog. Definition A (nondeterministic) finite automaton, abbreviated NDFA, is a 5-tuple (QX,Ö,I,F), where Q is a set of states,

<!-- page 361 -->
is a set of symbols, 6 is a accept(Xs) -

The string represented by the list Xs is accepted by

the NDFA defined by initial/i, delta/3, and final/i.

```prolog
accept(Xs) - initial(Q), accept(Xs,Q).
accept([XIXs],Q) - delta(Q,X,Q1), accept(Xs,Q1)
accept([ ],Q) - final(Q).
```

Program 17.1 An interpreter for a nondeterministic finite automaton (NDFA)

mapping from Q x

to Q, I is an initial state, and F is a set of final states. If the mapping is a function, then an NDFA is deterministic.

A finite automaton can be specified as a Prolog program by three collections of facts. The predicate `initial (Q)` is true if Q is the initial state. The predicate `final (Q)` is true if Q is a final state. The most interesting is `delta(Q,X,Ql),` which is true if the NDFA changes from state Q to state Ql on receipt of symbol X. Note that both the set of states and the set of symbols can be defined implicitly as the constants that appear in the

```prolog
initial, final, and delta predicates.
```

An NDFA accepts a string of symbols from the alphabet

if when started in its initial state, and following the transitions specified by ô, the NDFA ends up in one of the final states. An interpreter for an NDFA must determine whether it accepts given strings of symbols. Program 17.1 is an interpreter. The predicate `accept (Xs)` is true if the NDFA defined by the collection of `initial, final,` and `delta` facts accepts the string represented as the list of symbols `Xs.`

Figure 17.1 shows a deterministic automaton that accepts the language (ab)*. There are two states, qO and ql. If in state qO an a is received, the automaton moves to state ql. The automaton moves back from ql to qO if a b is received. The initial state is qO, and qO is also the single final state.

To use the interpreter, a specific automaton must be given. Program 17.2 is the realization in Prolog of the automaton in Figure 17.1. The combination of Programs 17.1 and 17.2 correctly accepts strings of alternating a's and b's.

<!-- page 362 -->
If an arc from qO to itself labeled a is added to the automaton in Figure 17.1, we get a new automaton that recognizes the language (a(a*)b)*. Figure 17.1 A simple automaton

```prolog
initial(qO)
uinal(qO)
delta (qQ , a, qi)
cielta(ql,b,qO).
```

Program 17.2 An NDFA that accepts the language (ab)*

This automaton is nondeterministic because on receipt of an a in state qO it is not determined which path will be followed. Nondeterminism does not affect the interpreter in Program 17.1. All that is needed to produce the new automaton is to add the fact `delta(qO,a,qO)` and the combined program will behave correctly.

Another simple computation model is a pushdown automaton that accepts the class of context-free languages. Pushdown automata extend NDFAs by providing a single stack for memory in addition to the internal state of the automaton. Formally, a (nondeterministic) pushdown automaton, abbreviated NPDA, is a 7-tuple (Q,G,&LZ,F) where Q,

, I, F are as before, G is the set of symbols that can be pushed onto the stack, Z is the start symbol on the stack, and 6 is changed to take the stack into account.

Specifically, ô is a mapping from Q x

x G* to Q x G*. The mapping controls the change of state of the NPDA and the pushing and popping of elements onto and off the stack by the NPDA. In one operation, the NPDA can pop (push) one symbol off (onto) the stack.

<!-- page 363 -->
Analogously to an NDFA, an NPDA accepts a string of symbols from the alphabet E*, if when started ¡n its initial state and with the starting symbol on the stack, and following the transitions specified by ô, the NPDA ends up in one of the final states with the stack empty An interpreter for an NPDA is given as Program 17.3. The predicate `accept(Xs)` is true if the NDFA defined by the collection of `initial, final,` and `delta` facts accept(Xs) -

The string represented by the list Xs is accepted by

the NPDA defined by initial/I, delta/5, and final/i.

```prolog
accept(Xs) - initial(Q), accept(Xs,Q,[ 1).
accept([XIXs],Q,S) - delta(Q,X,S,Q1,S1), accept(Xs,Q1,S1).
accept([ ],Q,[ 1) -
                   final(Q).
```

Program 17.3 An interpreter for a nondeterministic pushdown automaton (NPDA)

```prolog
initial(qO).
               final(ql).
delta(qO,X,S,qO, [XIS]).
delta(qO,X,S,ql, [XIS]).
delta (qO ,X, S, qi, S)
delta(ql,X, [XIS] ,ql,S).
```

Program 17.4 An NPDA for palindromes over a finite alphabet

accepts the string represented as the list of symbols Xs. The interpreter is very similar to the interpreter of an NDFA given as Program 17.1. The only change is the explicit manipulation of the stack by the `delta` predicate.

A particular example of an NPDA is given as Program 17.4. This automaton accepts palindromes over a finite alphabet. A palindrome is a nonempty string that reads the same backwards as forwards. Example palindromes are noon, madam, and gleneig. Again, the automaton is specified by `initial, final,` and `delta` facts, and the sets of symbols being defined implicitly. The automaton has two states: qO, the initial state when symbols are pushed onto the stack, and qi, a final state when symbols are popped off the stack and compared with the symbols in the input stream. When to stop pushing and start popping is decided nondeterministically. There are two `delta` facts that change the state from qO to ql to allow for palindromes of both odd and even lengths.

<!-- page 364 -->
Programs 17.1 and 17.2 can be combined into a single program for recognizing the language (ab)*. Similarly, Programs 17.3 and 17.4 can be combined into a single program for recognizing palindromes. A program that can achieve this combination is given in Chapter 18.

It is straightforward to build an interpreter for a Turing machine written in a similar style to the interpreters in Programs 17.1 and 17.3. This is posed as Exercise (iii) at the end of this section. Building ari interpreter for Turing machines shows that Prolog has the power of all other known computation models. Exercises for Section 17.1

Define an NDFA that accepts the language ab*c.

Define an NPDA that accepts the language ab1.

Write an interpreter for a Turing machine

17.2 Meta-Interpreters We turn now to a class of especially useful interpreters. A meta-interpreter for a language is an interpreter for the language written in the language itself. Being able to write a meta-interpreter easily is a very powerful feature of a programming language. It gives access to the computation process of the language and enables the building of an integrated programming environment. The examples in the rest of this chapter demonstrate the potential of meta-interpreters arid the ease with which they can be written. In this section, we also examine issues in writing meta-interpreters.

Throughout the remainder of this chapter, the predicate `solve` is used for a meta-interpreter. A suitable relation scheme is as follows. The relation `solve(Goal)` is true if `Goal` is true with respect to the program being interpreted.

The simplest meta-interpreter that can be written in Prolog exploits the meta-variable facility. Et is defined by a single clause: solve(A) - A.

<!-- page 365 -->
This trivial interpreter is only useful as part of a larger program. For example, a version of the trivial interpreter forms the basis for the interactive shell given as Program 12.6 arid the logging facility given as Program 12.7. In general, as we suggest here and see in more detail in solve(Goal) -

Goal is true given the pure Prolog program defined by clause/2.

```prolog
solve (true)
solve((A,B)) - solve(A), solve(B).
salve(A) - clause(A,B), solve(B).
```

Program 17.5 A meta-interpreter for pure Prolog

Sections 17.3 and 17.4, meta-interpreters are useful and important because of the easily constructed enhancements.

The best known and most widely used meta-interpreter models the computation model of logic programs as goal reduction. The three clauses of Program 17.5 interpret pure Prolog programs. This metainterpreter, called vanilla, together with its enhancements, is the basis of the rest of this section and Section 17.3.

The interpreter in Program 17.5 can be given a declarative reading. The `solve` fact states that the empty goal, represented by the constant `true,` is true. The first `solve` rule states that a conjunction (A,B) is true if `A` is true and `B` is true. The second `solve` rule states that a goal `A` is true if there is a clause `A - B` in the interpreted program such that `B` is true.

We also give a procedural reading of the three clauses in Program 17.5. The `solve` fact states that the empty goal, represented in Prolog by the atom `true,` is solved. The next clause concerns conjunctive goals. It reads: "To solve a conjunction (A,B), solve `A` and solve `B."` The general case of goal reduction is covered by the final clause. To solve a goal, choose a clause from the program whose head unifies with the goal, and recursively solve the body of the clause.

The procedural reading of Prolog clauses is necessary to demonstrate that the meta-interpreter of Program 17.5 indeed reflects Prolog's choices of implementing the abstract computation model of logic programming. The two choices are the selection of the leftmost goal as the goal to reduce, and sequential search and backtracking for the nondeterministic choice of the clause to use to reduce the goal. The goal order of the body of the `solve` clause handling conjunctions guarantees that the leftmost goal in the conjunction is solved first. Sequential search and backtracking comes from Prolog's behavior in satisfying the `clause` goal.

<!-- page 366 -->
The hard work of the interpreter is borne by the third clause of Program 17.5. The call to `clause` performs the unification with the heads solve(rnember(X, [a,b,c]))

{Xa, 13=true

```prolog
clause(inember(X, [a,b,c]) ,B)
solve (true)
    true
               Output:
                       X=a
solve (true)
                                          tBmember(X, [b,c])}
    clause(true,T)
                     f
clause(member(X, [a,b,c] 6)
solve(member(X, [b,c]))
                                          {x=b ,B1=true
    clause(member(X, [b,c]) ,Bl)
    solve (true)
    true
               Output: Xb
    solve (true)
                                          (B1member(X, [c])}
        clause(true,T)
                         f
    clause(member(X, [b,c]),B1)
    solve (member(X, [cl))
                                          {X=c ,B2=true}
        clause (member(X, [cl ,B2)
        solve (true)
        true
                   Output:
                           X=c
        solve (true)
                                          {B2=member(X, C
           clause(true,T)
                            f
        clause(rnember(X, [cl ,B2))
        solve(member(X, C i))
           clause(member(X, E ]),B3)
             no (more) solutions
```

Figure 17.2

Tracing the meta-interpreter

of the clauses appearing in the program. It is also responsible for giving different solutions on backtracking. Backtracking also occurs in the conjunctive rule reverting from B to `A.`

Tracing the meta-interpreter of Program 17.5 solving a goal is instructive. The trace of answering the query `solve (member (X, [a, b, c]))` with respect to Program 3.12 for `member` is given in Figure 17.2.

The vanilla meta-interpreter inherits Prolog's representation of clauses using the system predicate

`clause.` Alternative representations of clauses are certainly possible, and indeed have been used by alternative Prologs. lists are one possible representation. The clause A - B1,B2,...,B

<!-- page 367 -->
can be represented by the clause `rule(A, [B1,...,Bn]).` In solve(Goal) -

Goal is true given the pure Prolog program defined by clause/2.

```prolog
solve(Goal)
              solve(Goal,[ J).
solve([ ],[ 1).
solve([ ],[GIGoals])
                      solve(G,Goals).
solve([AIB] ,Goals)
                    append(B,Goals,Goalsl), solve(A,Goalsl).
solve(A,Goals) - rule(A,B), solve(B,Goals).
```

Program 17.6 A meta-interpreter for pure Prolog in continuation style

this representation, the empty list represents the empty goal and list construction represents conjunction. This representation is used in Program 17.6.

A different representation imposes a different form on the metainterpreter, as illustrated in Program 17.6. Unlike Program 17.5, this version of the vanilla meta-interpreter makes explicit the remaining goals in the resolvent. Enhancements can be written to exploit the fact that the resolvent is accessible during the computation, for example, allowing a more sophisticated computation rule. The behavior of Program 17.6 can be considered as being in continuation style promoted by languages such as Scheme.

Differences in meta-interpreters can be characterized in terms of their granularity, that is the chunks of the computation that are made accessible to the programmer. The granularity of the trivial one-clause metainterpreter is too coarse. Consequently there is little scope for applying the meta-interpreter. It is possible, though not as easy, to write a metainterpreter that models unification and backtracking. The granularity of such a meta-interpreter is very fine. Working at this fine level is usually not worthwhile. The efficiency loss is too great to warrant the extra applications. The meta-interpreter in Program 17.5, at the clause reduction level, has the granularity most suited for the widest range of applications.

<!-- page 368 -->
The vanilla meta-interpreter must be extended to handle language features outside pure Prolog. Builtin predicates are not defined by clauses in the program and need different treatment. The easiest way to incorporate builtin predicates is to use the meta-variable facility to call them directly. A table of builtin predicates is necessary. In this chapter, we assume a table of facts of the form builtin(Predicate) for each builtin

```prolog
builtin(A is
             )
                        builtin(A > B)
builtin(read(X))
                        buìltin(write(X)).
builtin(integer(X)).
                        builtin(functor(T,F,N)).
builtin(clause(A,B))
                        builtin(builtin(X)).
```

Figure 17.3

Fragment of a table of builtin predicates

predicate. Figure 17.3 gives part of that table. A table of builtin predicates is provided in some Prologs by another name but is not present in Standard Prolog.

The clause `solve(A)`

`builtin(A), A.` can be added to the metainterpreter in Program 17.5 to correctly handle builtin predicates. The resulting program handles four disjoint cases, one per clause, for solving goals: the empty goal, conjunctive goals, builtin goals, and user-defined goals. For compatibility with a number of Prolog systems, the metainterpreters in the rest of this section contain cuts to indicate that the clauses are mutually exclusive.

The extra `solve` clause makes the behavior of the builtin predicates invisible to the meta-interpreter. User-defined predicates that one wants to make invisible can be handled similarly with a single clause. Conversely, there are occasions when builtin predicates for negation and secondorder programming should be made visible.

The vanilla meta-interpreter needs to be extended to handle cuts correctly. A naive incorporation of cuts treats them as a builtin predicate, effectively adding a clause `solve (!) !.` This clause does not achieve the correct behavior of cut. The cut in the clause commits to the current `solve` clause rather than pruning the search tree.

<!-- page 369 -->
To achieve correct behavior of cut in a meta-interpreter, one needs to understand scope, that is to which clause the cut commits. The scope of cut, as described in Chapter 11, is the clause in which the cut is a goal in the body. The scope of cut when it is contained within a meta-logical builtin predicate such as conjunction and disjunction is less distinct and varies in different Prologs. If a cut is part of a disjunction, should execution of the cut commit to the current disjunct or to the clause in which the disjunction is embedded? Handling cut correctly in a mctainterpreter is tricky and usually relies on technical details of the scope of cut in a particular implementation of Prolog. Incorporating cuts within solve_trace( Goal) -

Goal is true given the Prolog program defined by clause/2.

The program traces the proof by side effects.

```prolog
solve_trace(Goal) - solve_trace(Goal,O).
solve_trace(true,Depth) -
solve_trace((A,B) ,Depth) -
       solve_trace(A,Depth), solve_trace(B,Depth).
solve_trace (A ,Depth) -
    builtin(A),
               !, A, display(A,Depth), nl.
solve_trace (A ,Depth)
    clause(A,B), display(A,Depth), nl, Depthl is Depth + 1,
    solve_trace (B ,Depthl).
display(A,Depth) -
    Spacing is 3*Depth, put_spaces(Spacing), write(A).
put_spaces(N) -
    between(1,N,I), put_charY '), fail.
put_spaces (N)
between(i,N,I) - SeeProgram8.5.
```

Program 17.7 A tracer for Prolog

meta-interpreters has been widely studied, and references to solutions are given in Section 17.5.

We apply meta-mterpreters to develop a simple tracer. Program 17.7 handles success branches of computations and does not display failure nodes in the search tree. It is capable of generating the traces presented in Chapter 6.

The basic predicate is

```prolog
solve_trace(Goal,Depth), where
                                  Goal is
```

solved at some depth. The starting depth is assumed to be O. The first `solve_trace/2` clause in Program 17.7 states that the empty goal is solved at any depth. The second clause indicates that each goal in a conjunct is solved at the same depth. The third clause handles builtins. The final `solve_trace/2` clause matches the goal with the head of a program clause, displays the goal, increments the depth, and solves the body of the program clause at the new depth.

<!-- page 370 -->
The predicate `display(Goal,Depth)` is an interface for printing the traced goal. The second argument, `Depth,` controls the amount of indentation of the first argument, `Goal.` Level of indentation correlates with depth in the proof tree. solve(Goal,Tree) -

Tree is a proof tree for Goal given the program defined

by c!ause/2.

```prolog
solve(true,true)
solve((A,B) , (ProofA,ProofB)) -
       solve(A,ProoÍA), solve(B,ProofB)
solve(A,(Abuiltin)) - builtin(A),
                                   1,
                                     A.
solve(A,(AProof))
                     clause(A,fl), solve(B,Proof).
```

Program 17.8 A meta-interpreter for building a proof tree

There is subtlety in the goal order of the clause

```prolog
solve_trace (A ,Depth) -
     clause(A,B), display(A,Depth), nl, Depthl is Depth + 1,
     solve_trace(B,Depthl).
```

The `display` goal is between calls to `clause` and `solve_trace,` ensuring that the goal is displayed each time Prolog backtracks to choose another clause. If the `clause` and `display` goals are swapped, only the initial call of the goal is displayed.

Using Program 17.7 for the query `solve_trace (append(Xs,Ys, [a,b,` `c]))?` with Program 3.15 for `append` generates a trace like the one presented in Section 6.1. The output messages and semicolons for alternative solutions are provided by the underlying Prolog. There is only one difference from the trace in Figure 6.2. The unifications are already performed. Separating out unifications requires explicit representation of unification and is considerably harder.

A simple application of meta-interpreters constructs a proof tree while solving a goal. The proof tree is built top-down. A proof tree is essential for the applications of debugging and explanation in the next two sections.

The basic relation is `solve(Goal,Tree),` where `Tree` is a proof tree for the goal `Goal,` Proof trees are represented by the structure `Goal -` `Proof.` Program 17.8 implements `solve/2` and is a straightforward enhancement of the vanilla meta-interpreter. We leave as an exercise for the reader giving a declarative reading of the program.

<!-- page 371 -->
Here is an example of using Program 17.8 with Program 1.2. The query `solve(son(lot,haran) ,Proof)?` has the solution solve( Goal,Certainty)

Certainty is our confidence that Goal is true.

```prolog
solve(true,1) -
solve((A,B),C) -
    !, solve(A,C1), solve(B,C2), minimum(C1,C2,C).
solve(A,1) - builtin(A),
                         !, A.
solve(A,C) - clause_cf(A,B,C1), solve(B,C2), C is Cl * C2.
```

`minimum(X,Y,Z) -` See Program 11.3. Program 17.9 A meta-interpreter for reasoning with uncertainty

```prolog
Proof = (son(lot,haran) -
         ((f ather(haran,lot)true),
         (male(lot)true))).
```

The query `solve (son (X,haran) ,Proof)?` has the solution X=lot and the same value for `Proof.`

Our next enhancement of the vanilla meta-interpreter incorporates a mechanism for uncertainty reasoning. Associated with each clause is a certainty factor, which is a positive real number less than or equal to 1. A logic program with certainties is a set of ordered pairs (Clause,Factor), where Clause is a clause and Factor is a certainty factor.

The simple meta-interpreter in Program 17.9 implements the uncertainty reasoning mechanism. The program is a straightforward enhancement of the vanilla meta-interpreter. The top-level relation is `solve (Goal,Certainty),` which is true when `Goal` is satisfied with cer-

```prolog
tainty Certainty.
```

The meta-interpreter computes the combination of certainty factors in a conjunction as the minimum of the certainty factors of the conjuncts. Other combining strategies could be accommodated just as easily. Program 17.9 assumes that clauses with certainty factors are represented

```prolog
using a predicate clause_cf (A, B ,CF).
```

Program 17.9 can be enhanced to prune computations that do not meet a desired certainty threshold. An extra argument constituting the value of the cutoff threshold needs to be added. The enhanced program is given as Program 17.10. The new relation is `solve (Goal,Certainty,`

```prolog
Threshold).
```

<!-- page 372 -->
The threshold is used in the fourth clause in Program 17.10. The certainty of any goal must exceed the current threshold. If the threshold is solve (Goal, Certainty, Threshold) -

Certainty is our confidence, greater than Threshold, that Goal is true.

```prolog
solve(true,1,T) -
solve( (A , B) ,C , T)
    I, solve(A,Cl,T), solve(B,C2,T), minimuin(Ci,C2,C).
solve(A,1,T) .- builtin(A),
                           !,
                             A.
solve(A,C,T) -
    clause_cf(A,B,C1), Cl > T, Ti is T/Cl,
    solve(B,C2,Tl), C is Cl * C2.
minimuin(X,Y,Z)
                 See Program 11.3.
```

Program 17.10

Reasoning with uncertainty with threshold cutoff

exceeded, the computation continues. The new threshold is the quotient of the previous threshold by the certainty of the clause. Exercises for Section 17.2

Write a meta-interpreter to count the number of times a procedure

is called in a successful computation.

Write a meta-interpreter to find the maximum depth reached in a

```prolog
computation.
```

Extend Program 17.6 to give a tracer and build a proof tree.

Extend Program 17.7 for solve_trace/2 to print out failed goals.

(y)

Modify Program 17.8 to use a different representation for a proof

```prolog
tree.
```

<!-- page 373 -->
17.3 Enhanced Meta-Interpreters for Debugging Debugging is an essential aspect of programming, even in Prolog. The promise of high-level programming languages is not so much iii the prospect for writing bug-free programs but in the power of the computerized tools for supportmg the process of program development. For reasons of bootstrapping and elegance, these tools are best implemented in the language itself. Such tools are programs for manipulating, analyzing, and simulating other programs, or in other words, meta-programs.

This section shows meta-programs for supporting the debugging process of pure Prolog programs. The reason for restricting ourselves to the pure part is clear: the difficulties in handling the impure parts of the language.

To debug a program, we must assume that the programmer has some intended behavior of the program in mind, and an intended domain of application on which the program should exhibit this behavior. Given those, debugging consists of finding discrepancies between the program's actual behavior and the behavior the programmer intended. Recall the definitions of an intended meaning and a domain from Section 5.2. An intended meaning M of a pure Prolog program is the set of ground goals on which the program should succeed. The intended domain D of a program is a domain on which the program should terminate. We require the intended meaning of a program to be a subset of the intended domain.

We say that A1 is a solution to a goal A if the program returns on a goal A its instance A1. We say that a solution A is true in an intended meaning M if every instance of A is in M. Otherwise it is false in M.

A pure Prolog program can exhibit only three types of bugs, given an intended meaning and an intended domain. When invoked on a goal A in the intended domain, the program may do one of three things:

Fail to terminate

Return some false solution AO

Fail to return some true solution AO We describe algorithms for supporting the detection and identification of each of these three types of bugs.

<!-- page 374 -->
In general, it is not possible to detect if a Prolog program is nonterminating; the question is undecidable. Second best is to assign some a priori bound on the running time or depth of recursion of the program, and abort the computation if the bound is exceeded. It is desirable to save part of the computation to support the analysis of the reasons for nontermination. The enhanced meta-interpreter shown in Program 17.11 achieves this. It is invoked with a call solve(A,D,Overf low), where A is an initial goal, and D an upper bound on the depth of recursion. The call solve(A,D,Overflow) -

A has a proof tree of depth less than D and

Overflow equals no_overflow, or A has a

branch in the computation tree longer than D, and

Overflow contains a list of its first D elements.

```prolog
solve(true,D,no_overflow)
                           L
solve(A,0,overflow([ J)) - L
solve((A,B) ,D,Overf low)
    D >0, !,
    solve (A,D,Overf iowA)
    solve_conjunction(OverflowA,B,D,Overflow).
solve(A,D,no_overflow) -
    D > 0,
    builtiri(A),
               !,
                  A.
solve(A,D,Overflow)
    D > 0,
    clause (A ,B)
    Dl is D-1,
    soive(B,D1,OverflowB)
    return_overflow(QverflowB ,A ,Overf low).
solve_conjunction(overfiow(S) ,B,D,overflow(S))
solveconjunctïon(nooverflow,B,D,Overfiow) -
    solve (B,D,Overflow)
returnoverflow(no_overflow,A ,no_overf low).
return_overflow(overflow(S),A,overfiow([AIS])).
```

Program 17.11 A meta-interpreter detecting a stack overflow

succeeds if a solution is found without exceeding the predefined depth of recursion, with `Overflow` instantiated to `no_overflow.` The call also succeeds if the depth of recursion is exceeded, but in this case `Over-` flow contains the stack of goals, i.e., the branch of the computation tree, which exceeded the depth-bound D.

Note that as soon as a stack overflow is detected, the computation returns, without completing the proof. This is achieved by `solve_`

```prolog
conjunction and return_overflow.
```

<!-- page 375 -->
For example, consider Program 17.12 for insertion sort. When called with the goal `solve(isort([2,2],Xs),6,Overf low),` the solution returned is isort(Xs,Ys) -

Ys is an ordered permutation of Xs. Nontermination program.

```prolog
isort([XIXs],Ys) - isort(Xs,Zs), insert(X,Zs,Ys).
isort([ ],[ 1).
insert(X,[YIYs],[X,YIYs]) -
    X
      < Y.
insert(X,[YIYs],[YIZs]) -
    X
        Y, insert(Y,[XIYs],Zs).
insert(X,[ ],[X]).
```

Program 17.12 A nonterminating insertion sort

Xs = [2,2, 2,2,2,2], `Overflow` = overflow( [

```prolog
isort( [2,2] [2,2,2,2,2,2]),
insert (2, [2] ,[2,2,2,2,2,2]),
insert (2,[2] [2,2,2,2,2]),
insert (2,[2] ,[2,2,2,2]),
insert (2, [2] ,[2,2,2]),
insert (2, [2] ,[2,2])])
```

The overflowed stack can be further analyzed, upon return, to diagnose the reason for nontermination. This can be caused, for example, by a loop, i.e., by a sequence of goals G1,G2,. . .,G, on the stack, where G1 and G are called with the same input, or by a sequence of goals that calls each goal with increasingly larger inputs. The first situation occurs in the preceding example. It is clearly a bug that should be fixed in the program. The second situation is not necessarily a bug, and knowing whether the program should be fixed or whether a larger machine should be bought in order to execute it requires further program-dependent information.

The second type of bug is returning a false solution. A program can return a false solution only if it has a false clause. A clause C is false with respect to an intended meaning M if it has an instance whose body is true in M and whose head is false in M. Such an instance is called a counterexam pie to C.

Consider, for example, Program 17.13 for insertion sort. On the goal

```prolog
isort([3,2,1] ,Xs) it returns the solution isort([3,2,1] [3,2,1])
```

<!-- page 376 -->
which is clearly false. isort(Xs,Ys) -

Buggy insertion sort.

```prolog
isort(EXIXs],Ys)
                   isort(Xs,Zs), irisert(X,Zs,Ys).
isort([ I,[ I).
inert(X, [YIY] , [X,YIYs]) -
    X
        Y.
insert (X, [YIYsJ , [Y IZs]
    X >
        Y,
          insert(X,Ys,Zs).
insert(X,[ I,EX]).
```

Program 17.13 An incorrect and incomplete insertion sort

The false clause in the program is

```prolog
insert(X, [YIYs], [X,YIYs]) - X
                                    Y.
and a counterexample to it is
insert(2, [1] [2,1]) .- 2
                              1.
```

Given a ground proof tree corresponding to a false solution, one can find a false instance of a clause as follows: Traverse the proof tree in postorder. Check whether each node in the proof tree is true. If a false node is found, the clause whose head is the false node and whose body is the conjunction of its sons is a counterexample to a clause in the program. That clause is false and should be removed or modified.

The correctness of this algorithm follows from a simple inductive proof. The algorithm is embedded in an enhanced meta-interpreter, shown as Program 17.14.

<!-- page 377 -->
The algorithm and its implementation assume an oracle that can answer queries concerning the intended meaning of the program. The oracle is some entity external to the diagnosis algorithm. It can be the programmer, who can respond to queries concerning the intended meaning of the program, or another program that has been shown to have the same meaning as the intended meaning of the program under debugging. The second situation may occur in developing a new version of a program while using the older version as an oracle. lt can also occur when developing an efficient program (e.g., quicksort), given an inefficient executable specification of it (i.e., permutation sort), and using the specification as an oracle. false_solution (A,Clause) - If A is a provable false instance, then Clause is a false clause in the program. Bottom-up algorithm.

```prolog
false_solution(A,Clause)
    solve(A,Proof)
    false_clause (Proof ,Clause)
solve(Goal,Proof) - See Program 17.8.
false_clause(true,ok)
faise_clause((A,B) ,Clause) -
    f aise_clause (A , ClauseA)
    check_conjunction(CiauseA ,B ,Clause).
false_clause((AB) ,Clause) -
    f aise_clause (B , ClauseB)
    check_clause (ClauseB , A, B ,Clause).
check_conjunction(ok ,B ,Clause)
    f aise_clause (B , Clause)
check_conjunction((AB1) ,B, (ABl)).
check_clause(ok,A,B,Clause) -
    query_goal (A ,Answer),
    check_answer (Answer, A, B ,Clause).
check_clause((AlBl) ,A,B, (AlBl)).
check_answer(true,A,B,ok).
check_answer(false,A,B, (ABl)) -
    extract_body (B,Bl).
extract_body (true , true)
extract_body((AB) ,A).
extract_body(((AB) ,Bs) , (A,As)) -
    extract_body(Bs,As).
query_goal(A,true) -
    built in (A)
query_goal (Goal ,Answer) -
    not builtin(Goal),
    writeln(['Is the goal ',Goal,' true?']),
    read (Answer).
```

<!-- page 378 -->
Program 17.14 Bottom-up diagnosis of a false solution

```prolog
When invoked with the goal false_solution(isort([3,2,1] ,X) ,C)
```

the algorithm exhibits the following interactive behavior:

```prolog
false_solution(isort([3,2,1],X),C)?
```

Is the goal isort([ ],[ ]) true? true. Is the goal insert(1, [

] , [1]) true? true. Is the goal isort ([1] , [1] ) true? true. Is the goal insert (2, [1] , [2,1]) true? false. `X` = [3,2,1], C

```prolog
= insert(2,[1],[2,1]) - 2
                                1.
```

This returns a counterexample to the false clause.

The proof tree returned by solve/2 is not guaranteed to be ground, in contrast to the assumption of the algorithm. However, a ground proof tree can be generated by either instantiating variables left in the proof tree to arbitrary constants before activating the algorithm, or by requesting the oracle to instantiate the queried goal when it contains variables. Different instances might imply different answers. Since the goal of this algorithm is to find a counterexample as soon as possible, the oracle should instantiate the goal to a false instance if it can.

One of the main concerns with diagnosis algorithms is improving their query complexity, i.e., reducing the number of queries they require to diagnose the bug. Given that the human programmer may have to answer the queries, this desire is understandable. The query complexity of the preceding diagnosis algorithm is linear in the size of the proof tree. There is a better strategy, whose query complexity is linear in the depth of the proof tree, not its size. In contrast to the previous algorithm, which is bottom-up, the second algorithm traverses the proof tree topdown. At each node it tries to find a false son. The algorithm recurses with any false son found. If there is no false son, then the current node constitutes a counterexample, as the goal at the node is false, and all its Sons are true.

<!-- page 379 -->
The implementation of the algorithm is shown in Program 17.15. Note the use of cut to implement ¡mplicit negation in the first clause of f alse_ goal/2 and the use of query_goal/2 as a test predicate. false_solution (A, Clause)

If A is a provable false instance, then Clause

is a false clause in the program. Top-down algorithm.

```prolog
false_solution(A ,Clause) -
    solve (A,Proof),
    false_goal (Proof ,Clause).
solve(Goal,Proof) - See Program 17.8.
false_goal((A'B) ,Clause) -
    f alse_conjunction (B, Clause)
false_goal((AB) ,(ABl)) -
    extract_body(B,Bl).
false_conjunction(((AB) ,Bs) ,Clause)
    query_goal (A,false),
    false_goal((AB) ,Clause).
false_conjunction((AB) ,Clause)
    query_goal (A,false),
    false_goal((AB) ,Clause).
false_conjunction((A,As) ,Clause)
    false_conjunction(As ,Clause).
extract_body(Tree,Body) - See Program 17.14.
query_goal(A,Answer) - See Program 17.14.
```

Program 17.15 Top-down diagnosis of a false solution

Compare the behavior of the bottom-up algorithm with the following

```prolog
trace of the interactive behavior of Program 17.15:
false_solution(isort([3,2,1] ,X),C)?
Is the goal isort([2, 11,12,1]) true?
```

false. Is the goal isort ([1] , [11) true? true. Is the goal insert (2, [1] [2,1]) true? false. X = [3,2,1], C = insert(2, [11,12,1]) - 2

```prolog
1.
```

<!-- page 380 -->
There is a diagnosis algorithm for false solutions with an even better query complexity, called divide-and-query. The algorithm progresses by splitting the proof tree into two approximately equal parts and querying the node at the splitting point. 1f the node is false, the algorithm is applied recursively to the subtree rooted by this node. If the node is true, its subtree is removed from the tree and replaced by true, and a new middle point is computed. The algorithm can be shown to require a number of queries logarithmic in the size of the proof tree. In case of close-to-linear proof trees, this constitutes an exponential improvement over both the top-down and the bottom-up diagnosis algorithms.

The third possible type of bug is a missing solution. Diagnosing a missing solution is more difficult than fixing the previous bugs. We say that a clause covers a goal A with respect to an intended meaning M if it has an instance whose head is an instance of A and whose body is in M.

For example, consider the goal insert (2, [1,3] ,Xs). lt is covered by the clause

```prolog
insert(X, [YIYs] , [X,YJYs])
                               X
                                    Y.
```

of Program 17.13 with respect to the intended meaning M of the program, since in the following instance of the clause

```prolog
insert(2,[1,3],[1,2,3]) - 2
                                  1.
```

the head is ari instance of A and the body is in M.

It can be shown that if a program P has a missing solution with respect to an intended meaning M, then there is a goal A in M that is not covered by any clause in P. The proof of this claim is beyond the scope of the book. lt is embedded in the diagnosis algorithm that follows.

Diagnosing a missing solution imposes a heavier burden on the oracle. Not only does it have to know whether a goal has a solution but it must also provide a solution, if it exists. Using such an oracle, an uncovered goal can be found as follows.

<!-- page 381 -->
The algorithm is given a missing solution, i.e., a goal in the intended meaning M of the program P, for which P fails. The algorithm starts with the initial missing solution. For every clause that unifies with it, it checks, using the oracle, if the body of the clause has an instance in M. If there is no such clause, the goal is uncovered, and the algorithm terminates. Otherwise the algorithm finds a goal in the body that fails. At least one of them should fail, or else the program would have solved the body, and hence the goal, in contrast to our assumption. The algorithm is applied recursively to this goal. missing_solution (A,Goal) -

If A is a nonprovable true ground goal, then Goal is a

true ground goal that is uncovered by the program.

```prolog
missing_solution((A,B),Goal) -
    (not A, missing_solution(A,Goal)
    A, missing_solution(B,Goal))
inissing_solution(A,Goal) -
    clause (A, B)
    query_clause((AB)),
    missing_solution (B , Goal)
missing_solution(A,A) -
    not system(A)
query_clause(Clause) -
    writeln(['Enter a true ground instance of ',Clause,
    'if there is such,
                       or
                          no' otherwise']),
    read (Answer)
       check_answer (Answer , Clause)
check_answer(no,Clause) - !, fail.
check_answer(Clause,Clause)
check_answer (Answer ,Clause) -
    write ('Illegal answer'),
       query_clause (Clause)
```

Program 17.16

Diagnosing missing solution

An implementation of this algorithm is shown in Program 17.16. The program attempts to trace the failing path of the computation and to find a true goal which is uncovered. Following is a session with the program:

```prolog
missing_solution(isort([2,1,3],[1,2,3]),C)?
```

Enter a true ground instance of

```prolog
(isort([2,1,3],[1,2,3]) -
    isort([1,3],Xs),insert(2,Xs,[1,2,3]))
```

if there is such, or "no" otherwise

```prolog
(isort([2,1,3],[1,2,3]) -
    isort([1,3] ,[1,3]) ,insert(2, [1,3] [1,2,3])).
```

Enter a true ground instance of

```prolog
(isort([1,3] [1,3]) - isort([3] ,Ys) ,insert(1,Ys, [1,3]))
```

<!-- page 382 -->
if there is such, or 'no' otherwise

```prolog
(isort([1,3],[1,3]) - isort([3],[3]),insert(1,[3],[1,3])).
```

Enter a true ground instance of (insert(1, [3] ,[1,3]) - 1

```prolog
3)
```

if there is such, or no' otherwise no.

```prolog
C
     insert(1, [3] [1,3])
```

The reader can verify that the goal insert(1, [3] [1,3]) is not covered by Program 17.13.

The three algorithms shown can be incorporated in a high-quality interactive program development environment for Prolog.

17.4 An Explanation Shell for Rule-Based Systems The final section of this chapter presents an application of interpreters to rule-based systems. An explanation shell is built that is capable of explaining why goals succeed and fail and that allows interaction with the user during a computation. The shell is developed with the methodology of stepwise enhancement introduced in Section 13.3.

The skeleton interpreter in this section is written in the same style as the vanilla meta-interpreter and has the same granularity. It differs in two important respects. First, it interprets a rule language rather than Prolog clauses. Second, the interpreter has two levels to allow explanation of failed goals.

Before describing the interpreter, we give an example of a toy rulebased system written in the rule language. Program 17.17 contains some rules for placing a dish on the correct rack in an oven for baking. Facts have the form fact (Goal), For example, the first fact in Program 17.17 states that dishl is of type bread.

<!-- page 383 -->
Rules have the form rule(Head,Body,Naine), where Head is a goal, Body is (possibly) a conjunction of goals, and Naine is the name of the rule. Individual goals in the body are placed inside a unary postfix functor is_true, for reasons to be explained shortly. Conjunctions in the body are denoted by the binary infix operator `&,` which differs from Prolog syntax. Operator declarations for & and is_true are given in Program 17.17. To paraphrase a sample rule, rule place i in Program 17.17 states: Rule base for a simple expert system for placing dishes in an oven. The predicates used in the rules are place_in_oven (Dish,Rack) -

Dish should be placed in the oven at level Rack for baking. pastry(Dish) - Dish is a pastry. main_meal(Dish)

Dish is a main meal. slow_cooker(Dish) - Dish is a slow cooker. type(Dish,Type) - Dish is best described as Type. size(Dish,Size) - The size of Dish is Size. The rules have the form `rule(Head,Body,Name).`

```prolog
:- op(40,xfy,&).
   op(30,xf,is_true).
rule (place_in_oven (Dish , top)
    pastry(Dish) is_true & size(Dish,small) is_true,placei).
rule (place_in_oven (Dish ,middle)
    pastry(Dish) is_true & size(Dish,big) is_true,place2).
rule (place_in_oven(Dish,middle) ,main_meal(Dish) is_true,place3).
rule(place_in_oven(Dish,bottom) ,slow_cooker(Dish) is_true ,place4)
rule(pastry(Dish) ,type(Dish, cake) is_true,pastryi).
rule (pastry(Dish) ,type(Dish,bread) is_true,pastry2).
rule(main_meal(Dish) ,type(Dish,meat) is_true,main_meal).
rule(slow_cooker(Dish) ,type(Dish,milk_pudding) is_true,slow_cooker).
fact (type (dishl ,bread)).
fact(size(dishi,big)).
```

Program 17.17 Oven placement rule-based system

"A dish should be placed on the top rack of the oven if it is a pastry and its size is small."

Why use a separate rule language when the syntax is so close to Prolog? The first rule, place 1, could be written as follows. place_in_oven(Dish,top) - pastry(Dish), size(Dish,sxnall).

<!-- page 384 -->
There are two main reasons for the rule language. The first is pedagogical. The rule interpreter is neater, avoiding complicated details associated with Prolog's impurities such as the behavior of builtin predicates when called by clause. Avoiding Prolog's impurities also makes it easier to partially evaluate the interpreter, as described in Chapter 18. monitor(Goal) -

Succeeds if a result of yes is returned from solving Goal

at the solve level, or when the end of the computation is reached.

```prolog
monitor(Goal) - solve(Goal,Result) ,
                                   filter(Result)
monitor (Goal)
fïlter(yes)
```

0/,

```prolog
filter(no)
           .- fail.
```

solve(Goal,Result) -

Given a set of rules of the form rule(A,B,Name), Goal has

Result yes if it follows from the rules and no if it does not.

```prolog
solve(A,yes)
               fact(A).
solve(A,Result)
               '- rule(A,B,Naxne), solve_body(B,Result).
solve (A na)
solve_body(A&B,Result)
    solve(A,ResultA), solve_and(ItesultA,B,Result)
solve_body(A ïs_true,Result) - salve(A,Result).
solve_and(no,A,no).
solve_and(yes,B,Result)
                         solve(B,Result).
```

Program 17.18 A skeleton two-level rule interpreter

The second reason is to show by example that the best way to develop a rule-based application in Prolog is to design a rule language on top of Prolog. Although the rule language is largely syntactic sugar, experience has shown that users of a rule-based system are happier working in a customized rule language than in Prolog. Rule languages are straightforward to provide on top of Prolog.

We now start our presentation of the explanation shell. According to the method of stepwise enhancement, the skeleton constituting the basic control flow of the final program is presented first. Program 17.18 contains the skeleton of the rule ìnterpreter. The principal requirement that shaped the skeleton is the desire to handle both successful and failed computations in one interpreter.

<!-- page 385 -->
The rule interpreter presented in Program 17.18 has two levels. The top level, or monitor level, consists of the predicates `monitor` and `filter.` The bottom level, or solve level, consists of the predicates `solve, solve_` `body,` and `solve_and.` Two levels are needed to correctly handle failed computations.

Let us consider the bottom level first. The three predicates constitute an interpreter at the same level of granularity as the vanilla metainterpreter. There is one major difference. There is a result variable that says whether a goal succeeds or fails. A goal that succeeds, with the result variable indicating failure, instead of failing gives rise to a different control flow, compensated for by the top level.

The predicate `solve(Goal,Result)` solves a single goal. There are three cases. The result is `yes` if the goal is a fact in the rule base. The result is `no` if no fact or head of a rule matches the goal. If there is a rule that matches the goal, the result will be returned by the predicate `solve_body(Goal,Result).` The order of the third clause is significant because we only want to report `no` for an individual goal if there is no suitable fact or rule. Effectively, `solve` succeeds for each branch of the search tree, the result being `yes` for successful branches and `no` for failed branches.

`solve_body/2` has two clauses handling conjunctive goals and goals of the form `A is_true.` The functor `is_true` is a wrapper that allows unification to distinguish between the two cases. A Prolog implementation with indexing would produce efficient code. The clause handling conjunctions calls a predicate `solve_and/3,` which uses the result of solving the first conjunct to decide whether to continue. The code for `solve_` `and` results in behavior similar to the behavior of `solve_conjunction` in Program 17.11.

The monitor level is essentially a generate-and-test program. The solve level generates a branch of the search tree, and the test procedure `fil-` `ter` accepts successful branches of the search tree, indicated by the result being `yes.` Failed branches, i.e., ones with result `no,` are rejected. Note that the second clause for `filter` could simply be omitted. We leave it in the program, albeit commented out, to make clear the later enhancement step for adding a proof tree.

The first enhancement of the rule interpreter makes it interactive. The interactive interpreter is given as Program 17.19. The user is given the opportunity to supply information at runtime for designated predicates. The designated predicates are given as a table of `askable` facts. For

```prolog
example, a fact askable(type(Dish,Type)).
```

appearing in the table would indicate that the user could ask the type of the dish.

<!-- page 386 -->
Interaction with the user is achieved by adding a new clause to the solve level: solve(Goal,Result) -

Given a set of rules of the form rule(A,B,Narne), Goal has

Result yes if it follows from the rules and no if it does not.

The user is prompted for missing information.

```prolog
solve(A,yes)
               fact(A).
solve(A,Result) - rule(A,B,Name), solve_body(B,Result).
solve(A,Result) - askable(A), solve_askable(A,Result).
solve (Ano)
solve_body(A&B,Result)
    solve_body(A,ResultA) ,
                         solve_and(ResultA,B,Result)
solve_body(A is_true,Result)
                              solve(A,Result).
solve_and(no,A,no)
solve_and(yes,B,Result) - solve(B,Result)
solve_askable(A,Result) -
    not known(A), ask(A,Response), respond(Response,A,Result).
```

The following predicates facilitate interaction with the user.

```prolog
ask(A,Response) - display_query(A)
                                   read(Response).
respond(yes,A,yes) - assert(known_to_be_true(A)).
respond(no,A,no) - assert(known_to_be_false(A)).
known(A)
           known_to_be_true(A).
known(A)
           known.to_be_false(A).
display_query(A) - write(A), write('? ').
```

Program 17.19 An interactive rule interpreter

```prolog
solve(A,Result) - askable(A), solve_askable(A,Result).
```

An alternative method of making the rule interpreter interactive is to define a new class of goals in the body. An additional `solve_body` clause could be added, for example,

```prolog
solve_body(A is_askable,Result) - solve_askable(A,Result).
```

We prefer adding a `solve` clause and having a table of `askable` facts to embedding in the rules the information about whether a predicate is askable. The rules become more uniform. Furthermore, the askable information is explicit meta-knowledge, which can be manipulated as needed.

<!-- page 387 -->
To complete the interactive component of the rule interpreter, code for `solve_askable` needs to be specified. The essential components are displaying a query and accepting a response. Experience with users of rule-based systems shows that it is essential not to ask the same question twice. Users get very irritated telling the computer information they feel it should know. Thus answers to queries are recorded using `assert.` Program 17.19 contains appropriate code. Only the solve level is given. The monitor level would be identical to Program 17.18.

Program 17.19 queries the user. The interaction can be extended to allow the user also to query the program. The user may want to know why a particular question is being asked. A facility for giving a why explanation is common in rule-based systems, the answer being the rule containing the queried goal in its body. In order to give this why explanation, we need to extend the rule interpreter to carry the rules that have been used so far.

Program 17.20 is an enhancement of Program 17.18 that carries the list of rules that have been used in solving the query. All the predicates carry the rules as an extra argument. The rule list is initialized to be empty in the first `monitor` clause. The rule list is updated in the second `solve` clause when a new rule is invoked.

We now describe how the list of rules can be used to provide a why explanation. A new `respond` clause needs to be added to Program 17.19. The appropriate behavior is to display the rule, then prompt the user again for the answer to the query.

```prolog
respond(why,A, [Rule Rules]) - display_rule(Rule),
     ask(A,Answer), respond(Answer,A,Rules).
```

Repeated responses of why can be handled by giving the rule that invoked the current rule. The correct behavior is achieved by having the recursive `respond` goal use the rest of the rules. Finally, when there are no more rules to display, an appropriate response must be given. A suitable `respond` clause is

```prolog
respond(cthy,A,[ ]) -
    writeln(['No more explanation possible']), ask(A,Answer),
    respond(Answer,A, E ]).
```

<!-- page 388 -->
Now let us consider generating explanations of goals that have succeeded or failed. The explanations will be based on the proof tree for successful goals and the search tree for failed goals. Note that a search monitor(Goal) -

Succeeds if a result of yes is returned from solving Goal

at the solve level, or when the end of the computation is reached.

```prolog
monitor(Goal) - solve(Goal,Result, [ 1),
                                       filter(Result).
monitor (Goal)
filter(yes)
V0 filter(no) - fail.
```

so!ve(Goal,Result,Rules) -

Given a set of rules of the form rule(A,B,Name), Goal has

Result yes if it follows from the rules and no if it does not.

Rules is the current list of rules that have been used.

```prolog
solve(A,yes,Rules) - fact(A).
solve(A,Result,Rules) -
    rule(A,B,Name), RulesB
                            [Name Rules],
    solve_body(B,Result ,RulesB).
solve(A,no,Rules).
solve_body(A&B,Result ,Rules) -
    solve_body(A,ResultA,Rules),
    solve_and(ResultA,B,Result ,Rules)
solve_body(A is_true,Result,Rules) - solve(A,Result,Rules)
solve_and(no,A,no,Rules)
solve_and(yes,B,Result,Rules) - solve(B,Result,Rules).
```

Program 17.20 A two-level rule interpreter carrying rules

tree is a sequence of branches. Each branch is either a proof tree or a failure branch that is like a proof tree. Program 17.18 can be enhanced to incorporate both cases. The enhanced program is given as Program 17.21. The solve level returns a branch of the search tree, and the monitor level keeps track of the failure branches since the last proof tree. The relation between the predicate `solve/3` in Program 17.21 and `solve/2` in Program 17.18 is analogous to the relation between Programs 17.8 and 17.5.

Four predicates are added to the monitor level to record and remove branches of the search tree. The fact

```prolog
C search tree' (Proof) records
```

<!-- page 389 -->
the current sequence of branches of the search tree since the last suc cess. The predicate `set_search_tree,` called by the top-level `monitor` goal, initializes the sequence of branches to the empty list. Similarly, monitor(Goal,Proof) - Succeeds if a result of yes is returned from solving Goal at the solve level, in which case Proof is a proof tree representing the successful computation, or when the end of the computation is reached, in which case Proof is a list of failure branches since the last success.

```prolog
monitor (Goal ,Proof) -
    set_search_tree, solve(Goal,Result,Proof),
    filter(Result ,Proof).
monitor (Goal ,Proof) -
    collect_proof (P), reverse(P,
                              E ] ,P1),
    Proof = failed(Goal,P1).
filter(yes,Proof) - reset_search_tree.
filter(no ,Proof) - store_proof (Proof), fail.
```

solve( Goal,Result,Proof) - Given a set of rules of the form rule(A,B,Name), Goal has Result yes if it follows from the rules and no if it does not. Proof is a proof tree if the result is yes and a failure branch of the search tree if the result is no.

```prolog
:- op(40,xfy,because).
   op(30,xfy,with).
solve(A,yes,Tree) - fact(A), Tree = fact(A).
solve(A,Result,Tree) -
    rule(A,B,Name), solve_body(B,Result ,Proof),
    Tree = A because B with Proof.
solve(A,no,Tree) -
    not fact(A), not rule(A,B,Name), Tree = no_match(A).
solve_body(A&B,Result ,Proof) -
    solve_body (A, ResultA, ProofA),
    solve_and (ResultA, B ,Result, ProofB),
    Proof = Proof A & ProofB.
solve_body(A is_true,Result ,Proof) - solve(A,Result ,Proof).
solve_and (no, A ,no, unsearched).
solve_and(yes,B,Result,Tree) - solve(B,Result,Tree).
```

<!-- page 390 -->
Program 17.21 A two-level rule interpreter with proof trees The following predicates use side effects to record and remove branches of the search tree.

```prolog
collect_proof(Proof) - retractY search tree' (Proof)).
store_proof (Proof) -
    retract ('search tree'(Tree)),
    assert('search tree'([ProofTreeJ))
set_search_tree
                  assertYsearch tree'([ D).
reset_search_tree
    retract('search tree' (Proof)),
    assert('search tree'([ 1)).
reverse(Xs,Ys)
                 SeeProgram3.16.
```

Program 17.21

(Continued)

`reset_search_tree` initializes the search tree but first removes the current set of branches. It is invoked by `filter` when a successful computation is detected. The predicate `store_proof` updates the search tree, while `collect_proof` removes the search tree. The failure branches are reordered in the second clause for `monitor/2.`

Having generated an explanation, we now consider how to print it. The proof tree is a recursive data structure that must be traversed to be explained. Traversing a recursive data structure is a straightforward exercise. Appropriate code is given in Program 17.22, and a trace of a computation given in Figure 17.4.

The explanation shell is obtained by combining the enhancements of Programs 17.19, 17.20, and 17.21. The final program is given as Program 17.23. Understanding the program is greatly facilitated by viewing it as a sum of the three components. Exercises for Section 17.4

Add the ability to explain askable goals to the proof explainer in

Program 17.22.

Add the ability to execute Prolog builtin predicates to the explana-

tion shell.

Write a two-level meta-interpreter to find the maximum depth

<!-- page 391 -->
reached in any computation of a goal. explain(Goal) -

Explains how the goal Goal was proved.

```prolog
explain(Goal) - monitor(Goal ,Proof), interpret(Proof).
monitor(Goal,Proof) - See Program 17.21.
interpret (Proof A&ProofB)
    interpret(ProofA), interpret(ProofB).
interpret(failed(A,Branches))
    nl, writeln([A,' has failed with the following failure
                                          branches: ']),
    interpret (Branches).
interpret ([Fail
               I Fails]) -
    interpret(Fail), nl, write('NEW BRANCH'), nl,
    interpret (Fails).
interpret([ J).
interpret(fact(A)) -
    nl, writeln([A,' is a fact in the database.']).
interpret(A because B with Proof)
    nl, writeln([A,' is proved using the rule']),
    display_rule(rule(A,B)), interpret(Proof).
interpret (no_match (A))
    nl, writeln([A,' has no matching fact or rule in the rule base.']).
interpret (unsearched) -
    nl, writeln(['The rest of the conjunct is unsearched.']).
display_rule (rule (A, B)) -
    write('IF '), write_conjunction(B), writeln(['THEN ',A ]).
write_conjunction(A&B)
    write_conjunction(A), write(' AND '),
    write_conjunction(B).
write_conjunction(A is_true) - write(A).
```

`writeln(Xs) -` See Program 12.1. Program 17.22

<!-- page 392 -->
Explaining a proof 35J Interpreters

`place_in_oven(dishl ,middle)` is proved using the rule

```prolog
IF pastry(dishl) AND size(dishl,big)
THEN place_in_oven(dishl ,rniddle)
```

`pastry(dishl)` is proved using the rule

```prolog
IF type(dishl ,bread)
THEN pastry(dïshl)
```

`type (dishi ,bread)` is a fact in the database. `size(dìshl,big)` is a fact in the database.

```prolog
Xmidd1e
```

`place_in_oven(dishl` ,x) has failed with the following failure branches: `pltace_in_oven(dishl ,middle)` is proved using the rule

```prolog
IF maiu_rneal(dishl)
THEN place_iu_oven(dishl,middle)
```

`main_meal(dishl)` is proved using the rule

```prolog
IF type(dishl,meat)
THEN maïn_meal(dishl)
```

`type(dishl,meat)` has no matching fact or rule in the rule base. NEW BRANCH `place_in_oven(dïshl,lov)` is proved using the rule

```prolog
1F slow_cooker(djshl)
THEN place_in_oven(dishl ,low)
```

`slow_cooker(dishl)` is proved using the rule

```prolog
IF type(dishl ,milk_pudding)
THEN slow_cooker(dishl)
```

`type(dishl,milk_pudding)` has no matching fact or rule in the rule base. Figure 17.4

<!-- page 393 -->
Explaining a computation monitor ( Goal,Proof) -

Succeeds if a result of yes is returned from solving Goal at the

solve level, in which case Proof is a proof tree representing the

successful computation, or when the end of the computation is reached,

in which case Proof is a list of failure branches since the last success. monitor (Goal ,Proof) -

set_search_tree, solve(Goal,Result, E ] ,Proof),

```prolog
filter(Result,Proof).
```

monitor (Goal ,Proof) -

collect_proof (P), reverse(P, E ] ,P1)

Proof = failed(Goal,P1). filter(yes,Proof) - reset_search_tree. filter(no,Proof)

store_proof (Proof), fail. solve( Goal,Result,Rules,Proof) -

Given a set of rules of the form rule(A,B,Name), Goal has

Result yes if it follows from the rules and no if it does not.

Rules is the current list of rules that have been used.

Proof is a proof tree if the result is yes and a failure branch

of the search tree if the result is no. :- op(40,xfy,because). :

```prolog
op(30,xfy,with).
```

solve(A,yes,Rules,Tree) - fact(A), Tree = fact(A). solve(A,Result,Rules,Tree) -

rule(A,B,Name), RulesB = [Naine IRules]

```prolog
solve_body(B,Result,RulesB,Proof),
Tree = A because B with Proof.
```

solve(A,Result,Rules,Tree) -

```prolog
askable(A), solve_askable(A,Result,Rules), Tree = user(A).
```

solve(A,no,Rules,Tree)

not fact(A), not rule(A,B,Narne), Tree = no_match(A). solve_body(A&B,Result,Rules,Proof) -

```prolog
solve_body(A,ResultA,Rules,ProofA),
solve_and (ResultA, B ,Result, Rules, ProofB),
Proof = ProofA & ProofB.
```

solve_body(A is_true ,Result ,Rules ,Proof) -

```prolog
solve(A,Result,Rules,Proof).
```

solve_and (no, A ,no, Rules, unsearched). solve_and(yes,B,Result,Rules,Tree)

<!-- page 394 -->
solve (B ,Result, Rules ,Tree). Program 17.23 An explanation shell The following predicates use side effects to record and remove branches of the search tree.

```prolog
collect_proof(Proof) - retract('search tree' (Proof)).
store_proof (Proof)
    retract ('search tree'(Tree)),
    assert('search tree' ([Proof ITree]))
set_search_tree
                  assert('search tree'([ 1)).
reset_search_tree
    retract('search tree'(Proof)) ,
                                 assertYsearch tree' ([ 1))
reverse(Xs,Ys)
                 SeeProgram3.16.
```

The followrng predicates facilitate interaction with the user.

```prolog
ask(A,Response) - display_query(A), read(Response).
respond(yes,A,yes) '- assert(known_to_be_true(A))
respond(no,A,no) - assert(known_to_be_false(A)).
respond(why,A, [Rule Rules]) -
    display_rule(Rule), ask(A,Answer), respond(Answer,A,Rules).
respond(why,A,[ J)
    writeln( ['No more explanation possible']), ask(A,Answer)
    respond(Answer,A, [ 1).
known(A) - known_to_be_true(A).
known(A)
           known_to_be_f aise (A)
display_query(A)
                   write(A), write('? ').
display_rule(rule(A,B)) -
    writeYlF '), write_conjunction(B), nl, writeln(['THEN
                                                        ' ,A]).
write_conjunction(A&B) -
    write_conjunction(A), write(' AND '), write_conjunction(B).
write_conjunction(A is_true) - write(A).
```

<!-- page 395 -->
`writein(Xs) -` See Program 12.1. Program 1723 (Continued) 17.5 Background Our notation for automata follows Hoperoft and Uliman (1979).

There is considerable confusion in the literature about the term metainterpreterwhether it differs from the term meta-level interpreter, for example. The lack of clarity extends further to the topic of metaprogramming. A good discussion of meta-programming can be found in Yalçinalp (1991).

One dimension of the discussion is whether the interpreter is capable of interpreting itself. An ìnterpreter with that capability is also called meta-circular or self-applicable. An important early discussion of metacircular interpreters can be found in Steele and Sussman (1978). That paper claims that the ability of a language to specify itself is a fundamental criterion for language design.

The vanilla meta-interpreter is rooted in Prolog folklore. A version was in the suite of programs attached to the first Prolog interpreter developed by Colmerauer and colleagues, and was given in the early collection of Prolog programs (Coelho et al., 1980). Subsequently, metainterpreters, and more generally meta-programs, have been written to affect the control flow of Prolog programs. References are Gallaire and Lasserre (1982), Pereira (1982), and Dincbas and Le Pape (1984). Using enhanced meta-interpreters for handling uncertainties is described by Shapiro (1983c).

There have been several papers on handling cuts in meta-interpreters. A variant of the vanilla meta-interpreter handling cuts correctly is described in Coelho et al. (1980) and attributed to Luis Pereira. One easy method to treat cuts is via ancestor cut, which is only present in a few Prologs like Waterloo Prolog on the IBM and Wisdom Prolog, described in the first edition of this book. There is a good discussion of metainterpreters in general, and cuts in particular, in O'Keefe (1990).

Shapiro suggested that enhanced meta-interpreters should be the basis of a progranmiing environment. The argument, along with the debugging algorithms of Section 17.3, can be found in Shapiro (1983a). Shapiro's debugging work has been extended by Dershowitz and Lee (1987) and Drabent et al. (1989).

<!-- page 396 -->
Prolog is a natural language for building rule-based systems. The basic statements are rules, and the Prolog interpreter can be viewed as a backward chaining inference engine. Early advocates of Prolog for expert systems were Clark and McCabe (1982), who discussed how explanation facilities and uncertainty can be added to simple expert systems expressed as Prolog clauses by adding extra arguments to the predicates. Incorporating interaction with the user in Prolog was proposed by Sergot (1983). An explanation facility incorporating Sergot's query_the_user was part of the APES expert system shell, described in Hammond (1984).

Using meta-interpreters as a basis for explanation facilities was proposed by Sterling (1984). Incorporating failure in a meta-interpreter has been discussed by several researchers, including Hammond (1984), Sterling and Latee (1986), and Bruffaerts and Henin (1989). The first description of ari integrated meta-interpreter for both success and failure is in Yalçinalp and Sterling (1989). The rute interpreter given in Section 17.4 is an adaptation of the last paper. The layered approach can be used to explain cuts clearly, as in Sterling and Yalçinalp (1989), and also for uncertainty reasoning, as in Yalçinalp and Sterling (1991) and more completely in Yalçinalp (1991).
