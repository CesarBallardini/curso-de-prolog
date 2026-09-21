# 6 Pure Prolog

<!-- page 160 -->
A pure Prolog program is a logic program, in which an order is defined both for clauses in the program and for goals in the body of the clause. The abstract interpreter for logic programs is specialized to take advantage of this ordering information. This chapter discusses the execution model of Prolog programs in contrast to logic programs, and compares Prolog to more conventional languages.

The relation between logic programming and Prolog is reminiscent of the relation between the lambda-calculus and Lisp. Both are concrete realizations of abstract computation models. Logic programs that execute with Prolog's execution mechanism are referred to as pure Prolog. Pure Prolog is an approximate realization of the logic programming computation model on a sequential machine. lt is certainly not the only possible such realization. However, it is a realization with excellent practical choices, which balance preserving the properties of the abstract model with catering for efficient implementation.

<!-- page 161 -->
6.1 The Execution Model of Prolog Two major decisions must be taken to convert the abstract interpreter for logic programs into a form suitable for a concrete programming language. First, the arbitrary choice of which goal in the resolvent to reduce, namely, the scheduling policy, must be specified. Second, the nondeterministic choice of the clause from the program to effect the reduction must be implemented.

Several logic programming languages exist, reflecting different choices. Prolog and its extensions (Prolog-II, IC-Prolog, and MU-Prolog, for example) are based on sequential execution. Other languages, such as PAR- LOG, Concurrent Prolog, GHC, Aurora-Prolog, and Andorra-Prolog, are based on parallel execution. The treatment of nondeternunism distinguishes between sequential and parallel languages. The distinction between Prolog and its extensions is in the choice of goal to reduce. Prolog's execution mechanism is obtained from the abstract interpreter by choosing the leftmost goal instead of an arbitrary one and replacing the nondeterministic choice of a clause by sequential search for a unifiable clause and backtracking.

In other words, Prolog adopts a stack scheduling policy. It maintains the resolvent as a stack: pops the top goal for reduction, and pushes the derived goals onto the resolvent stack.

In addition to the stack policy, Prolog simulates the nondeterministic choice of reducing clause by sequential search and backtracking. When attempting to reduce a goal, the first clause whose head unifies with the goal is chosen. If no unifiable clause is found for the popped goal, the computation is unwound to the last choice made, and the next unifiable clause is chosen.

A computation of a goal G with respect to a Prolog program P is the generation of all solutions of G with respect to P. In terms of logic programming concepts, a Prolog computation of a goal G is a complete depth-first traversal of the particular search tree of G obtained by always choosing the leftmost goal.

Many different Prolog implementations exist with differing syntax and programming facilities. Recently, there has been an attempt to reach a Prolog standard based on the Edinburgh dialect of Prolog. At the time of writing, the standard has not been finalized. However a complete draft exists, which we essentially follow. We refer to the Prolog described in that document as Standard Prolog. The syntax of logic programs that we have been using fits within Standard Prolog except that we use some characters not available on a standard keyboard. We give the standard equivalent of our special characters. Thus :- should be used instead of

- in Prolog programs to separate the head of a clause from its body. All the programs in this book run (possibly with minor changes) in all Edinburgh-compatible Prologs.

<!-- page 162 -->
A trace of a Prolog computation is an extension of the trace of a computation of a logic program under the abstract interpreter as described father(abraharn,isaac).

```prolog
male(isaac).
```

father(haran,lot)

```prolog
male(lot).
```

father (haran,milcah)

female (yiscah) father(haran,yiscah).

female (milcah). son(X,Y)

```prolog
father(Y,X), male(X).
```

daughter(X,Y)

f ather(Y,X), f emale(X). son (X, haran)?

f ather (heran , X)

X=lot

male ( lot)

true

Output:

X=lot

Xmil cah

X=yi scah

father (haran , X)

male (milcah)

f

father (heran, X)

```prolog
male(yiscah)
                 f
              no (more) solutions
```

Figure 6.1

Tracing a simple Prolog computation

in Section 4.2. We revise the computations of Chapters 4 and 5, indicating the similarities and differences. Consider the query son(X,haran)? with respect to Program 1.2, biblical family relationships, repeated at the top of Figure 6.1. The computation is given in the bulk of Figure 6.1. lt corresponds to a depth-first traversal of the first of the search trees in Figure 5.2. It is an extension of the first trace in Figure 4.4, since the whole search tree is searched.

The notation previously used for traces must be extended to handle failure and backtracking. An f after a goal denotes that a goal fails, that is there is no clause whose head unifies with the goal. The next goal after a failed goal is where the computation continues on backtracking. It already appears as a previous goal in the trace at the same depth of indentation and can be identified by the variable names. We adopt the Edinburgh Prolog convention that a ";" typed after a solution denotes a continuation of the computation to search for more solutions. Unifications are indicated as previously.

<!-- page 163 -->
Trace facilities and answers provided by particular Prolog implementations vary from our description. For example, some Prolog implementations always give all solutions, while others wait for a user response after each solution.

```prolog
append([XIXs] ,Ys, [XIZs])
                          append(Xs,Ys,Zs).
append([ I ,Ys,Ys).
append(Xs,Ys, [a,b,c])
                                             Xs=[aIXsl]
                                             Xsl= [bi Xs2]
    append(Xsl,Ys, [b,c])
       append(Xs2,Ys, [cl)
                                             Xs2= [cl Xs3]
                                             Xs3=[ ],Ys=[ I
           append(Xs3,Ys, E I)
                   true
               Output:
                       (Xs=[a,b,c],Ys=[ ])
       append(Xs2,Ys, [cl)
                                             Xs2=[ ] ,Ys[c]
               true
           Output:
                   (Xs=[a,b] ,Ys=[c]
    append(Xsl,Ys, [b,c])
                                             Xsl=[ ],Ys=[b,c]
           true
        Output:
               (Xs= [a] , Ys= [b, c])
append(Xs,Ys, [a,b,c])
                                             Xs=[ ],Ys=[a,b,c]
        true
    Output:
            (Xs=[ ],Ys=[a,b,c])
                    no (more) solutions
```

Figure 6.2

Multiple solutions for splitting a list

The trace of `append([a,b], [c,d] ,Ls)?` giving the answer `Ls=[a,b,c,` `dl is` precisely the trace given in Figure 4.3. Figure 4.5, giving the trace for solving the Towers of Hanoi with three disks, is also a trace of the `hanoi` program considered as a Prolog program solving the query `hanoi(s(s(s(0))) ,a,b,c,Ms)?.` The trace of a deterministic computation is the same when considered as a logic program or a Prolog program, provided the order of goals is preserved.

The next example is answering the query `append (Xs , Ys, [a, b, c])?` with respect to Program 3.15 for `append.` There are several solutions of the query. The search tree for this goal was given as Figure 5.3. Figure 6.2 gives the Prolog trace.

<!-- page 164 -->
Tracing computations is a good way to gain understanding of the execution model of Prolog. We give a slightly larger example, sorting a list with the quicksort program (Program 3.22, reproduced at the top of Figure 6.3). Computations using quicksort are essentially deterministic and show the algorithmic behavior of a Prolog program. Figure 6.3 gives a trace of the query qui cksort ([2, 1,3] , Xs)?. Arithmetic comparisons

```prolog
quicksort([XIXS] ,Ys) -
    partition(Xs,X,Littles,Bigs),
    quicksort(Littles,Ls),
    quicksort(Bigs,Bs),
    append(Ls, [X lBs] ,Ys).
quïcksort([ ],C ]).
partition([XIXs] ,Y, EXILs] ,Bs)
    X
        Y, partition(Xs,Y,Ls,Bs).
partitïon([XIXs] ,Y,Ls, [XIBs])
    X
      > Y, partition(Xs,Y,Ls,Bs).
partition([ ],Y,[ LE J).
quicksort([2,1,3] ,qs)
                                      Ls= [1
                                           I Lsi]
    partition([1,3] ,2,Ls,Bs)
        12
                                      Lsi[3 Ls2]
        partition([3] ,2,Lsl,Bs)
           32
                    f
                                      Bs
                                         [31 Bsl]
        partition([3] ,2,Lsl,Bs)
           3>2
           partition([
                       I ,2,Lsl,Bsl)
                                      Ls1[ ]Bsl
    quicksort(E1] ,qsl)
        partition([ ] ,1,Ls2,Bs2)
                                      Ls2=[ ]Bs2
        quicksort([ ] ,Qs2)
        quicksort([ ] ,Qs3)
                                      Qs2=[
```

J

```prolog
Qs3=[ ]
Qsi=[1]
```

`append([` I ji] ,Qsi)

```prolog
quicksort([3] ,Qs4)
                                  Ls3=[ ]=Bs3
    partition([ I ,3,Ls3,Bs3)
    quicksort([
               J ,Qs5)
                                   s5=[ I
                                  Qs6[ ]
                                  Qs4 [3]
    quicksort([ ] ,Qs6)
    appendU ]
              , [3] ,Qs4)
appendUl] ,[2,3] ,Qs)
                                  Qs=EljYs]
                                  Ys[2,3]
    appendU I ,[2,3] ,Ys)
```

true Output:

```prolog
(Qsti,2,3])
```

<!-- page 165 -->
Figure 6.3 Tracing a quicksort computation are assumed to be unit operations, and the standard program for `append` is used.

We introduce a distinction between shallow and deep backtracking. Shallow backtracking occurs when the unification of a goal and a clause fails, and an alternative clause is tried. Deep backtracking occurs when the unification of the last clause of a procedure with a goal fails, and control returns to another goal in the computation tree.

It is sometimes convenient to include, for the purpose of this definition, test predicates that occur first in the body of the clause as part of unification, and to classify the backtracking that occurs as a result of their failure as shallow. An example in Figure 6.3 is the choice of a new clause for the goal `partition([3] ,2,Lsl,Bs).`

6.1.1

Exercises for Section 6.1

Trace the execution of `daughter(X,haran)?` with respect to Pro-

gram 1.2.

Trace the execution of `sort([3, 1,2] ,Xs)?` with respect to Pro-

gram 3.21.

Trace the execution of `sort([3, 1,2] ,Xs)?` with respect to Pro-

gram 3.20.

6.2 Comparison to Conventional Programming Languages A programming language is characterized by its control and data manipulation mechanisms. Prolog, as a general-purpose progranmiing language, can be discussed in these terms, as are conventional languages. In this section, we compare the control flow and data manipulation of Prolog to that of Algol-like languages.

The control in Prolog programs is like that in conventional procedural languages as long as the computation progresses forward. Goal invocation corresponds to procedure invocation, and the ordering of goals in the body of clauses corresponds to sequencing of statements. Specifically, the clause A B1,. . .,B

<!-- page 166 -->
can be viewed as the definition of a procedure A as follows: procedure A

call B1,

call B2,

call B, end.

Recursive goal invocation in Prolog is similar in behavior and implementation to that of conventional recursive languages. The differences show when backtracking occurs. In a conventional language, if a computation cannot proceed (e.g., all branches of a case statement are false), a runtime error occurs. In Prolog, the computation is simply undone to the last choice made, and a different computation path is attempted.

The data structures manipulated by logic programs, terms, correspond to general record structures in conventional programming languages. The handling of data structures is very flexible in Prolog. Like Lisp, Prolog is a declaration-free, typeless language.

The major differences between Prolog and conventional languages in the use of data structures arise from the nature of logical variables. Logical variables refer to individuals rather than to memory locations. Consequently, having once beed specified to refer to a particular individual, a variable cannot be made to refer to another individual. In other words, logic programming does not support destructive assignment where the contents of an initialized variable can change.

Data manipulation in logic programs is achieved entirely via the unification algorithm. Unification subsumes

Single assignment

Parameter passing

Record allocation

Read/write-once field-access in records

We discuss the trace of the quicksort program in Figure 6.3, pointing out the various uses of unification. The unification of the initial

```prolog
goal quicksort ([2, 1 3] ,
```

<!-- page 167 -->
`s)` with the head of the procedure definition `quicksort ([XI Xs] , Ys)` illustrates several features. The unification of `[2, 1 3]` with the term [X I Xs] achieves record access to the list and also selection of its two fields, the head and tail.

The unification of [1 3] with Xs achieves parameter passing to the `partition` procedure, because of the sharing of the variables. This gives the first argument of `partition.` Similarly, the unification of 2 with X passes the value of the second parameter to `partition.`

Record creation can be seen with the unification of the goal `parti-` `tion( [1,3]` .2, `Ls ,Bs)` with the head of the partition procedure `parti-`

```prolog
tion([XIXs] ,Z, [XILs1] ,Bsl).
                               As
                                    a
                                       result,
                                                Ls
                                                    is
                                                        instantiated
```

**to [li Ls 1]. Specifically, Ls is made into a list and its head is assigned**

the value 1, namely, record creation and field assignment via unification.

The recursive algorithm embodied by the `quicksort` program can be easily coded in a conventional programming language using linked lists and pointer manipulation. As discussed, unification is achieving the effect of the necessary pointer manipulations. Indeed, the manipulation of logical variables via unification can be viewed as an abstraction of low-level manipulation of pointers to complex data structures.

These analogies may provide hints on how to implement Prolog efficiently on a von Neumann machine. Indeed, the basic idea of compilation of Prolog is to translate special cases of unification to conventional memory manipulation operations, as specified previously.

Conventional languages typically incorporate error-handling or exception-handling mechanisms of various degrees of sophistication. Pure Prolog does not have an error or exception mechanism built into its definition. The pure Prolog counterparts of nonfatal errors in conventional programs, e.g., a missing case in a case statement, or dividing by zero, cause failure in pure Prolog.

Full Prolog, introduced in the following chapters, includes system predicates, such as arithmetic and I/O, which may cause errors. Current Prolog implementations do not have sophisticated errorhandling mechanisms. Typically, on an error condition, a system predicate prints an error message and either fails or aborts the computation.

<!-- page 168 -->
This brief discussion of Prolog's different way of manipulating data does not help with the more interesting question: How does programming in Prolog compare with programming in conventional programming languages? That is the major underlying topic of the rest of this book. 6.3 Background The origins of Prolog are shrouded in mystery. All that is known is that the two founders, Robert Kowaiski, then at Edinburgh, and Alain Colmerauer at Marseilles worked on similar ideas during the early 1970s, and even worked together one summer The results were the formulation of the logic programming philosophy and computation model by Kowaiski (1974), and the design and implementation of the first logic programming language Prolog, by Colmerauer and his colleagues (1973). Three recent articles giving many more details about the beginnings of Prolog and logic programming are Cohen (1988), Kowalski (1988), and Colmerauer and Roussel (1993).

A major force behind the realization that logic can be the basis of a practical programming language has been the development of efficient implementation techniques, as pioneered by Warren (1977). Warren's compiler identified special cases of unification and translated them into efficient sequences of conventional memory operations. Good accounts of techniques for Prolog implementation, both interpretation and compilation, can be found in Maier and Warren (1988) and Ait-Kaci (1991).

Variations of Prolog with extra control features, such as IC-Prolog (Clark and McCabe, 1979), have been developed but have proved too costly in runtirne overhead to be seriously considered as alternatives to Prolog. We will refer to particular interesting variations that have been proposed in the appropriate sections.

Another breed of logic programming languages, which indirectly emerged from IC-Prolog, was concurrent logic languages. The first was the Relational Language (Clark and Gregory, 1981), followed by Concurrent Prolog (Shapiro, 1983b), PARLOG (Clark and Gregory, 1984), GHC (Ueda, 1985), and a few other proposals.

References for the variations mentioned in the text are, for Prolog- Il (van Caneghem, 1982), IC-Prolog (Clark et al., 1982), and MU-Prolog (Naish, 1986). Aurora-Prolog is described in Disz et al. (1987), while a starting place for reading about AKL, a language emerging from Andorra- Prolog is Janson and Haridi (1991).

The syntax of Prolog stems from the clausal form of logic due to Kowaiski (1974). The original Marseilles interpreter used the terminology of positive and negative literais from resolution theory. The clause AB1,...,Bwaswritten +AB1.. .

<!-- page 169 -->
.

David H. D. Warren adapted Marseilles Prolog for the DEC-10 at the University of Edinburgh, with help from Fernando Pereira. Their decisions have been very influential. Many systems adopted most of the conventions of Prolog-10 (Warren et al., 1979), which has become known more generically as Edinburgh Prolog. Its essential features are described in the widespread primer on Prolog (Clocksin and Mellish, 1984). This book follows the description of Standard Prolog existing as Scowen (1991).

A paper by Cohen (1985) delves further into the relation between Prolog and conventional languages.
