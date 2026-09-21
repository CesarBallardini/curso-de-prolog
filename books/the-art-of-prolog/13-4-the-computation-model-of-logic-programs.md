# 4 The Computation Model of Logic Programs

<!-- page 128 -->
The computation model used in the first three chapters of the book has a severe restriction. All goals appearing in the proof trees are ground. All rule instances used to derive the goals in the proof trees are also ground. The abstract interpreter described assumes that the substitutions giving the desired ground instances can be guessed correctly. In fact, the correct substitutions can be computed rather than guessed.

This chapter presents a general computation model of logic programs. The first section presents a unification algorithm that removes the guesswork in determining instances of terms. The second section presents an appropriately modified abstract interpreter and gives example computations of logic programs.

The computation model of logic programming we present is especially well suited to sequential languages such as Prolog. Our model can be used to describe parallel logic programming languages. However, developers of these languages have often used other models, such as state transitions or dynamic tree creation and destruction (see Section 4.3).

4.1 Unification The heart of our computation model of logic programs is unification. Unification is the basis of most work in automated deduction and of the use of logical inference in artificial intelligence.

<!-- page 129 -->
Necessary terminology for describing the algorithm is repeated from Chapter 1, and new definitions are introduced as needed.

Recall that a term t is a common instance of two terms, t1 and t2, if there exist substitutions 9 and 92 such that t equals t191 and t202. A term s is more general than a term t 1f t is an instance of s but s is not an instance of t. A term s is an alphabetic variant of a term t if both s is an instance of t and t is an instance of s. Alphabetic variants are related by the renaming of variables that occur in the terms. For exam-

```prolog
ple, meinber(X,tree(Left,X,Right)) and member(Y,tree(Left,Y,Z))
```

are alphabetic variants.

A unifier of two terms is a substitution making the terms identical. If two terms have a unifier, we say they unify. There is a close relation between unifiers and common instances. Any unifier determines a common instance, and conversely, any common instance determines a unifier.

```prolog
For example, append([1,2,3] ,[3,4] ,List) and append([XXs] ,Ys,
```

[XIZs]) unify. A unifying substitution is `{X"1,Xs[2,3], Ys=[3,4],` `List=[1Zs] }.` Their common instance, determined by this unifying sub-

```prolog
stitution, is append( [1,2,3] [3,4], [1Zs] ).
```

A most general unifier, or mgu, of two terms is a unifier such that the associated common instance is most general. It can be shown that if two terms unify, all mgus are equivalent. Making that statement precise is beyond the scope of this book, but we give pointers in Section 4.3. We proceed by giving an algorithm that computes a most general unifier of two terms if one exists.

The algorithm for unification presented here is based on solving equations. The input for the algorithm is two terms, T1 and T2. The output of the algorithm is an mgu of the two terms if they unify, or failure if the terms do not unify. The algorithm uses a pushdown stack for storing the equations that need to be solved and a location, O, for collecting the substitution comprising the output.

The location O is initially empty, and the stack is initialized to contain the equation T1 = T2. The algorithm consists of a loop of popping an equation from the stack and processing it. The loop terminates when the stack becomes empty or if failure occurs in processing an invalid equation.

<!-- page 130 -->
We consider the possible actions for dealing with a popped equation S = T. The simplest case is if S and T are identical constants or variables. This equation is correct, and nothing further needs to be done. The computation continues by popping the next equation from the stack.

If S is a variable, and T is a term not containing S, the following happens. The stack is searched for all occurrences of S, which are replaced by T. Similarly, all occurrences of S in O are replaced by T. Then the substitution S = T is added to O. It is significant that S does not occur in T. The test embodied by the phrase "not containing" is known as the occurs check.

If T is a variable, and S is a term not containing T, i.e., T satisfies the occurs check with respect to S, the symmetric sequence of actions happens.

Equations are added to the stack if S and T are compound terms with the same principal functor and arity, f(S1,. . .,S,) and f(T1,..

```prolog
say.
```

For the terms to unify, each of the argument pairs must simultaneously unify. This is achieved by pushing the n equations, S = T, onto the stack.

In any other case, failure is reported, and the algorithm terminates. If the stack is emptied, the terms unify, and the unifier can be found in ¿9. The complete algorithm is given as Figure 4.1. The occurs check is embodied in the phrase "that does not occur in."

We do not prove the correctness of this algorithm, nor analyze its complexity. The interested reader is referred to the literature in Section 4.3.

Consider attempting to unify the terms `append([a,b] , [c,d] ,Ls)` and `append([XIXs] ,Ys, [XIZs]).` The stack is initialized to the equation

```prolog
append([a,b] , [c,d] ,Ls)
                            append([XIXs] ,Ys, [XIZs]).
```

These two terms have the same functor, `append,` and arity, 3, so we add the three equations relating the subterms of the two terms. These are

```prolog
{a,b]=[XIXs], [c,d]=Ys, and Ls=[XZs].
```

The next equation,

`[a, b] = [X Xs],` is popped from the stack. These two compound terms have the same functor, ".", and arity, 2, so two equations, `aX` and

`[b] =X,` are added to the stack. Continuing, the equation `a=X` is popped. This is covered by the second case in Figure 4.1. X is a variable not occurring in the constant, `a.` All occurrences of X in the stack are replaced by

`a.` One equation is affected, namely `Ls= [XIZs],` which becomes `Ls= [a Zs].` The equation `X=a` is added to the initially empty substitution, and the algorithm continues.

The next equation to be popped is

<!-- page 131 -->
`Lb] =Xs.` Again this is covered by the second case. `Xs= [b]` is added to the set of substitutions, and the stack is checked for occurrences of Xs. There are none, and the next equation is popped. Input:

Two terms T1 and T2 to be unified Output:

O, the mgu of T1 and T2, or failure Algorithm:

Initialize the substitution O to be empty,

the stack to contam the equation T1 = T2,

and failure to false.

while stack not empty and no failure do

pop X = Y from the stack

case

X is a variable that does not occur in Y:

substitute Y for X in the stack and in O

add X = Y to O

Y is a variable that does not occur in X:

substitute X for Y in the stack and in O

add Y = X to O

X and Y are identical constants or variables:

continue

**Xisf(X1.....X)andYisf(Y1.....Y)**

for some functor f and n> O:

push X, = Y,i = i

n, on the stack

otherwise:

failure is true

If failure, then output failure else output O. Figure 4.1

A unification algorithm

**The second case also covers [c,d]=Ys. Another substitution, Ys=[c,**

**dl, is added to the collection, and the final equation, Ls=[aZs], is**

**popped. This is handled by the symmetric first case.**

**Ls does not**

**occur in**

**[aZs], so the equation is added as is to the unifier, and**

**the algorithm terminates successfully. The unifier is**

```prolog
{X=a,Xs=[b]
```

Ys= Ec , `d], Ls= [aZs] }.` The common instance produced by the unifier is `append([a,bl , [c,d] , [als]).` Note that in this unification, the substitutions were not updated.

**The occurs check is necessary to prevent the unification of terms such**

<!-- page 132 -->
as s (X) and X. There is no finite common instance of these terms. However, most Prolog implementations omit the occurs check from the unification algorithm, for pragmatic reasons.

When implementing this unification algorithm for a particular logic programming language, the explicit substitution in both the equations on the stack and the unifier is avoided. Instead, logical variables and other terms are represented by memory cells with different values, and variable binding is implemented by assigning to the memory cell representing a logical variable a reference to the cell containing the representation of the term the variable is bound to. Therefore, Substitute Y for X in stack and in O. Add X = Y to substitutions. is replaced by Make X a reference to Y. 4.1.1

Exercises for Section 4.1

Use the algorithm in Figure 4.1 to compute an mgu of append([b],

[c,d] ,L) and append([XIXs] ,Ys, [XIZs]).

Use the algorithm in Figure 4.1 to compute anmguofhnoi(s(N),

A,B,C,Ms)andhanoi(s(s(0)),a,b,c,Xs).

**4.2 An Abstract Interpreter for Logic Programs**

We revise the abstract interpreter of Section 1.8 in the light of the unification algorithm. The result is our full computation model of logic programs. Ail the concepts introduced previously, such as goal reductions and computation traces, have their analogues in the full model.

<!-- page 133 -->
A computation of a logic program can be described informally as follows. It starts from some initial (possibly conjunctive) query G and, if it terminates, has one of two results: success or failure. If a computation succeeds, the instance of G proved is conceived of as the output of the computation. A given query can have several successful computations, each resulting in a different output. In addition, it may have nonterminating computations, to which we associate no result.

The computation progresses via goal reduction. At each stage, there is some resolvent, a conjunction of goals to be proved. A goal in the resolvent and clause in the logic program are chosen such that the clause's head unifies with the goal. The computation proceeds with a new resolvent, obtained by replacing the chosen goal by the body of the chosen clause in the resolvent and then applying the most general unifier of the head of the clause and the goal. The computation terminates when the resolvent is empty. In this case, we say the goal is solved by the program.

To describe computations more formally, we introduce some useful concepts. A computation of a goal Q = Qo by a program P is a (possibly infinite) sequence of triples (Q,G1,C1). Q is a (conjunctive) goal, G is a goal occurring in Q, and C is a clause AB1,. . .,B in P renamed so that it contains new variable symbols not occurring in O, O j

i. For all i> O, Q

is the result of replacing G by the body of C in Q, and applying the substitution 0, the most general unifier of G and A, the head of C; or the constant true if G is the only goal in Q and the body of C is empty; or the constant fail if G and the head of C do not unify.

The goals B01 are said to be derived from G1 and C. A goal G

= Bk0, where Bjk occurs in the body of clause C1, is said to be invoked by G and C. G is the parent of any goal it invokes. Two goals with the same parent goal are sibling goals.

A trace of a computation of a logic program (Q,G1,C1) is the sequence of pairs (G1,G), where 0 is the subset of the mgu 0 computed at the ith reduction, restricted to variables in G.

We present an abstract interpreter for logic programs. It is an adaptation of the interpreter for ground goals (Figure 1.1). The restriction to using ground instances of clauses to effect reductions is lifted. Instead, the unification algorithm is applied to the chosen goal and head of the chosen clause to find the correct substitution to apply to the new resolvent.

Care needs to be taken with the variables in rules to avoid name clashes. Variables are local to a clause. Hence variables in different clauses that have the same name are, in fact, different. This is ensured by renaming the variables appearing in a clause each time the clause is chosen to effect a reduction. The new names must not include any of the variable names used previously in the computation.

<!-- page 134 -->
The revised version of the interpreter is given as Figure 4.2. It solves a query G with respect to a program P. The output of the interpreter is an

A goal G and a program P Input: Output:

An instance of G that is a logical consequence of P,

or no otherwise Algorithm:

lnitjalize the resolvent to G.

while the resolvent is not empty do

choose a goal A from the resolvent

choose a (renamed) clause A' B1 ..,B,1 from P

such that A and A' unify with mgu E)

(if no such goal and clause exist, exit the while loop)

replace A by B1 ,...,B ¡n the resolvent

apply O to the resolvent and to G

If the resolvent is empty, then output G, else output rio. Figure 4.2 An abstract interpreter for logic programs

**instance of G if a proof of such an instance is found, or no if a failure**

**has occurred during the computation. Note that the interpreter may also**

fail to terminate.

An instance of a query for which a proof is found is called a solution to the query.

**The policy for adding and removing goals from the resolvent is called**

**the scheduling policy of the interpreter. The abstract interpreter leaves**

the scheduling policy unspecified.

**Consider solving the query append([a,b] , [c,d] ,Ls)? by Program**

**3.15 for append using the abstract interpreter of Figure 4.2. The resol-**

**vent is initialized to be append([a,bJ , [c,d] ,Ls). lt is chosen as the**

**goal to reduce, being the on'y one. The rule chosen from the program is**

```prolog
append([XIXs],Ys,[XIZs]) - append(Xn,Ys,Zs).
```

**The unifier of the goal and the head of the rule is**

```prolog
                                                      {X=a,Xs=[b],
Ys=[c,d]
         ,
```

**Ls[aIZs]}. A detailed calculation of this unifier appeared**

**in the previous section. The new resolvent is the instance of ap-**

`pend(Xn , Ys ,Zn)` under the unifier, namely, `append( [b] , [c , d] ,Zn).` This goal is chosen in the next iteration of the loop. The same clause for `append` is chosen, but variables must be renamed to avoid a clash of variable names. The version chosen is

```prolog
append([X1IXs1],Ysl,[X1IZs1]) - apperid(Xsl,Ysl,Zsl).
```

<!-- page 135 -->
Ls= [aIZs] append([a,b] , [c,d] ,Ls)

append([b] , [c,d] ,Zs)

Zs[bIZsl]

Zsl=[c,d]

```prolog
append([ j, [c,d] ,Zsl)
  true
   Output: Ls= [a, b, c , d]
```

Figure 4.3

Tracing the appending of two lists

The unifier of the head and goal is {X1=b, Xsl=[ ], Ys1[c,d], Zs=[bZs1]}. The new resolvent is append([ ], [c,d] ,Zsl). This time the fact append( [ ] , Zs2 , Zs2) is chosen; we again rename variables as necessary. The unifier this time is {Zs2=[c,d] , Zsl=[c,d]}. The new resolvent is empty and the computation terminates.

To compute the result of the computation, we apply the relevant part of the mgu's calculated during the computation. The first unification instantiated Ls to [aIZs]. Zs was instantiated to [bZs1] in the second unification, and Zs i further became [c , d]. Putting it together, Ls has the value [a[b[c,d]]],ormore simply, [a,b,c,d].

The computation can be represented by a trace. The trace of the foregoing append computation is presented in Figure 4.3. To make the traces clearer, goals are indented according to the indentation of their parent. A goal has an indentation depth of d+1 if its parent has indentation depth d.

As another example, consider solving the query son(S,haran)? by Program 1.2. It is reduced using the clause son(X,Y) - f ather(Y,X), male (X). A most general unifier is {X=S,Y=haran}. Applying the substitution gives the new resolvent f ather(haran,S), male(S). This is a conjunctive goal. There are two choices for the next goal to reduce. Choosing the goal father (haran ,S) leads to the following computation. The goal) unifies with the fact father (haran, lot) in the program, and the computation continues with S instantiated to lot. The new resolvent is male (lot), which is reduced by a fact in the program, and the computation terminates. This is illustrated in the left trace in Figure 4.4.

<!-- page 136 -->
The other possibility for computing S=haran is choosing to reduce the goal male (S) before father (haran,S). This goal is reduced by the fact male(lot) with S instantiated to lot. The new resolvent is f ather (haran, lot), which is reduced to the empty goal by the corresponding fact. This is the right trace in Figure 4.4. son(S,haran)

```prolog
son(S,haran)
```

father(haran,S)

S1ot

```prolog
male(S)
                     S=:]ot
```

male(lot)

```prolog
                            father(haran,lot)
true
                              true
```

Figure 4.4

Different traces of the same solution

Solutions to a query obtained using the abstract interpreter may contain variables. Consider the query `mernber(a,Xs)?` with respect to Program 3.12 for `member.` This can be interpreted as asking what list Xs has the element `a` as a member One solution computed by the abstract interpreter is `Xs= [a lYs],` namely, a list with `a` as its head and an unspecified tail. Solutions that contain variables denote an infinity of solutionsall their ground instances.

There are two choices in the interpreter of Figure 4.2: choosing the goal to reduce, and choosing the clause to effect the reduction. These must be resolved in any realization of the computation model. The nature of the choices is fundamentally different.

The choice of goal to reduce is arbitrary; it does not matter which is chosen for the computation to succeed. If there is a successful computation by choosing a given goal, then there is a successful computation by choosing any other goal. The two traces in Figure 4.4 illustrate two successful computations, where the choice of goal to reduce at the second step of the computation differs.

The choice of the clause to effect the reduction is nondeterministic. Not every choice will lead to a successful computation. For example, in both traces in Figure 4.4, we could have gone wrong. If we had chosen to reduce the goal `father (haran,S)` with the fact `father (haran,yiscah),` we would not have been able to reduce the invoked goal `male (yiscah).` For the second computation, had we chosen to reduce `male(S)` with `male(isaac),` the invoked goal `f ather(haran,isaac)` could not have been reduced.

For some computations, for example, the computation illustrated in Figure 4.3, there is only one clause from the program that can reduce each goal. Such a computation is called deterministic. Deterministic computations mean that we do not have to exercise our nondeterministic imagination.

<!-- page 137 -->
The alternative choices that can be made by the abstract interpreter when trying to prove a goal implicitly define a search tree, as described more fully in Section 5.4. The interpreter "guesses" a successful path in this search tree, corresponding to a proof of the goal, if one exists. However, dumber interpreters, without guessing abilities, can also be built, with the same power as our abstract interpreter. One possibility is to search this tree breadth-first, that is, to explore all possible choices in parallel. This will guarantee that if there is a finite proof of the goal (i.e., a finite successful path in the search tree), it will be found.

Another possibility would be to explore the abstract search tree depthfirst. In contrast to the breadth-first search strategy, the depth-first one does not guarantee finding a proof even if one exists, since the search tree may have infinite paths, corresponding to potentially infinite computations of the nondeterministic interpreter. A depth-first search of the tree might get lost in an infinite path, never finding a finite successful path, even if one exists.

In technical terms, the breadth-first search strategy defines a complete proof procedure for logic programs, whereas the depth-first one is incomplete. In spite of its incompleteness, depth-first search is the one incorporated in Prolog, for practical reasons, as explained in Chapter 6.

Let us give a trace of a longer computation, solving the Towers of Hanoi problem with three disks, using Program 3.31. It is a deterministic computation, given as Figure 4.5. The final append goal is given without unifications. It is straightforward to fill them in.

Computations such as that in Figure 4.5 can be compared to computations in more conventional languages. Unification can be seen to subsume many of the mechanisms of conventional languages: record allocation, assignment of and access to fields in records, parameter passing, and more. We defer the subject until the computation model for Prolog is introduced in Chapter 6.

A computation of G by P terminates if G

= true or fail for some n O. Such a computation is finite and of length n. Successful computations correspond to terminating computations that end in true. Failing computations end in fail. All the traces given so far have been of successful computations.

<!-- page 138 -->
Recursive programs admit the possibility of nonterminating computations. The query append(Xs, [c,d] ,Ys)? with respect to append can be reduced arbitrarily many times using the rule for append. In the process, Xs becomes a list of arbitrary length. This corresponds to solutions of the query appending [c , dl to an arbitrarily long list. The nonterminating computation is illustrated in Figure 4.6. hanoi(s(s(s(0))),a,b,c,Ms) hanoi(s(s(0)),a,c,b,Msl) hanoi(s(0),a,b,c,Msl 1) hanoi(s(0),b,c,a,Ms 12) append([a to bija to c,b to ciMsi) Msll=[a to b] Ms12=[b toc] Msl=[a to bIXsJ Xs=[a to c,b to cl appendU ]ja to c,b to c],Xs) hanoi(s(s(0)),c,b,a,Ms2) hanoi(s(0),c,a,b,Ms2 1) hanoi(s(0),a,b,c,Ms22) append(]c to aJ,fc to b,a to b],Ms2) Ms21=Fc to a] Ms22=[a to bi Ms2=[c to alYs] Ys=[c to b,a to b] appendU ],[c to ba to b],Ys) append([c to a,c to b,a to bila to b,c to a, Ms=Lc to aIZsI c to b,a to b],Ms) append(Lc to b,a to b],[a to b,c to a, Zs=[c to bjZsli c to b,a to bJ,Zs) append([a to biLa to b,c to a, Zsl=[a to bIZs2] c to b,a to biZsl) appendU ]Ja to b,c to a, c to b,a to b],Zs2) Zs2=[a to b,c to a, c to b,a to b] Figure 4.5 Solving the Towers of Hanoi

Xs=[XIXs1], Ys=LXYs1l append(Xs,[c,dJ,Ys) append(Xsl ,]c,d],Ysl) append(Xs2,[c,dI,Ys2) append(Xs 3 ,[c,d],Ys3) Xsl=[X1 Xs2], Ysl=[X1 IYs2l Xs2=[X2IXs3], Ys2=LX2JYs3] Xs3=[X3IXs4I, Ys3=[X3IYs4]

**Figure 4.6 A nonterminating computation**

<!-- page 139 -->
All the traces presented so far have an important feature in common. If two goals G and G1 are invoked from the same parent, and G appears before G in the trace, then all goals invoked by G will appear before G in the trace. This scheduling policy makes traces easier to follow, by solving queries depth-first.

The scheduling policy has another important effect: instantiating variables before their values are needed for other parts of the computation. A good ordering can mean the difference between a computation being deterministic or not.

Consider the computation traced in Figure 4.5. The goal

```prolog
hanoi(s(s(s(0))) ,a,b,c,Ms)
```

is reduced to the following conjunction

```prolog
hanoi(s(s(0)) ,a,c,b,Msl),
     hanoi(s(s(0)) ,c,b,a,Ms2)
     append(Msl, [a to bIMs2] ,Ms).
```

If the `append` goal is now chosen, the `append` fact could be used (incorrectly) to reduce the goal. By reducing the two `hanoi` goals first, and all the goals they invoke, the append goal has the correct values for `Ms` i and

```prolog
Ms2.
```

4.2.1

Exercises for Section 4.2

Trace the query `sort([3,1,2] ,Xs)?` using the permutation sort

(3.20), insertion sort (3.21), and quicksort (3.22) programs in turn.

Give a trace for the goal `derivative(3*sin(x)-4*cos(x),x,D)`

using Program 3.30 for `derivative.`

Practice tracing your favorite computations.

<!-- page 140 -->
4.3 Background Unification plays a central role in automated deduction and in the use of logical inference in artificial intelligence. It was first described in the landmark paper of Robinson (1965). Algorithms for unification have been the subject of much investigation: see, for example, Martelli and Montanari (1982), Paterson and Wegman (1978), and Dwork et al. (1984). Typical textbook descriptions appear in Bundy (1983) and Niisson (1980).

The definition of unification presented here is nonstandard. Readers wishing to learn more about unifiers are referred to the definitive discussion on unification in Lassez, Maher, and Marriott (1988). This paper points out inconsistencies of the various definitions of unifiers that have been proposed in the literature, including the version in this book. Essentially, we have explained unifiers based on terms to avoid technical issues of composition of substitutions, which are not needed for our description of logic progranmiing computations.

The computation model we have presented has a sequential bias and is influenced by the computation model for Prolog given in Chapter 6. Nonetheless, the model has potential for parallelism by selecting several goals or several rules at a time, and for elaborate control by selecting complicated computation rules. References for reading about different computation models for logic programming are given in Section 6.3.

Another bias of our computation model is the central place of unification. An exciting development within logic programming has been the realization that unification is just one instance of constraint solving. New computation models have been presented where the solution of equalfly constraints, i.e., unification, in the abstract interpreter of Figure 4.2 is replaced by solving other constraints. Good starting places to read about the new constraint-based models are Colmerauer (1990), Jaffar and Lassez (1987), and Lassez (1991).

A proof that the choice of goal to reduce from the resolvent is arbitrary can be found in Apt and van Emden (1982) or in the text of Lloyd (1987).

A method for replacing the runtime occurs check with compile-time analysis was suggested by Plaisted (1984).

Attempts have been made to make unification without the occurs check more than a necessary expedient for practical implementations of Prolog. In particular, Colmerauer (1982b) proposes a theoretical model for such unifications that incorporates computing with infinite terms.

A novel use of unification without the occurs check appears in Eggert and Chow (1983), where Escher-like drawings that gracefully tend to infinity are constructed.
