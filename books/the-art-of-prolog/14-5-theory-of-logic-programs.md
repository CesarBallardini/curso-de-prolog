# 5 Theory of Logic Programs

<!-- page 142 -->
A major underlying theme of this book, laid out in the introduction, is that logic programming is attractive as a basis for computation because of its basis in mathematical logic, which has a well-understood, welldeveloped theory. In this chapter, we sketch some of the growing theory of logic programming, which merges the theory inherited from mathematical logic with experience from computer science and engineering. Giving a complete account is way beyond the scope of this book. In this chapter, we present some results to direct the reader in important directions. The first section, on semantics, gives definitions and suggests why the model-theoretic and proof-theoretic semantics give the same result. The main issue in the second section, on program correctness, is termination. Complexity of logic programs is discussed in the third section. The most important section for the rest of the book is Section 4, which discusses search trees. Search trees are vital to understanding Prolog's behavior. Finally, we introduce negation in logic programming.

<!-- page 143 -->
5.1 Semantics Semantics assigns meanings to programs. Discussing semantics allows us to describe more formally the relation a program computes. Chapter 1 informally describes the meaning of a logic program P as the set of ground instances that are deducible from P via a finite number of applications of the rule of universal modus ponens. This section considers more formal approaches. parent(terach,abraham).

```prolog
parent(abrahani,isaac).
```

parent(isaac ,jacob).

```prolog
parent(jacob,benjainin).
```

ancestor(X,Y) - parent(X,Y). ancestor(X,Z) - parent(X,Y), ancestor(Y,Z). Program 5.1

Yet another family example

The operational semantics is a way of describing procedurally the meaning of a program. The operational meaning of a logic program P is the set of ground goals that are instances of queries solved by P using the abstract interpreter given in Figure 4.2. This is an alternative formulation of the previous semantics, which defined meaning in terms of logical deduction.

The declarative semantics of logic programs is based on the standard model-theoretic semantics of first-order logic. In order to define it, some new terminology is needed. Definition Let P be a logic program. The Herbrand universe of P, denoted U(P), is the set of all ground terms that can be formed from the constants and function symbols appearing in P.

u

In this section, we use two running examplesyet another family database example, given as Program 5.1; and Program 3.1 defining the natural numbers, repeated here:

```prolog
natural_number (0)
natural_number(s(X)) - natural_number(X).
```

The Herbrand universe of Program 5.1 is the set of all constants appearing in the program, namely, `{terach, abraham, isaac ,jacob, benj amin}.` If there are no function symbols, the Herbrand universe is finite. In Program 3.1, there is one constant symbol, O, and one unary function symbol, s. The Herbrand universe of Program 3.1 is {O, s (0) , s (s (0)),

.

<!-- page 144 -->
. . If no constants appear in a program, one is arbitrarily chosen. Definition The Herbrand base, denoted B(P), is the set of all ground goals that can be formed from the predicates in P and the terms in the Herbrand universe.

There are two predicates, parent/2 and ancestor/2, in Program 5.1. The Herbrand base of Program 5.1 consists of 25 goals for each predicate, where each constant appears as each argument: {parent(terach,terach), parent(terach,abraham), parerit(terach,isaac), parent(terach,jacob), parent(terach,benjanuin), parent(abraham,terach), parent (abraham, abraham), parent(abraham, isaac), parent(abraham,jacob), parent(abraham,benjanìin), parent(isaac,terach), parent(isaac,abrahain), parent(isaac,isaac), parent(isaac,jacob), parent(isaac,benjaniin), parent(jacob,terach), parent(jacob,abraham), parent(jacob,isaac), parent(jacob,jacob), parent(jacob,berijamin), parent(berijamin,terach), parent(benjainin,abraham), parent (benjamin,isaac), parent(benjamin,jacob), parent(benjamin,benjarniri), ancestor(terach,terach), ancestor(terach,abraham), ancestor(terach,isaac), ancestor(terach,jacob), ancestor(terach,benjamin), ancestor(abrahani,terach), ancestor(abraham,abrahani), ancestor(abraham,isaac), ancestor(abrahain,jacob), ancestor(abraham,benjamin), ancestor(isaac,terach), ancestor(isaac,abrahani),

```prolog
ncestor(isaac,isaac),
```

ancestor(isaac,jacob), ancestor(isaac,benjaxnin), ancestor(jacob,terach), ancestor(jacob,abraham), ancestor(jacob,isaac), ancestor(jacob,jacob), ancestor(jacob,berijainin), ancestor(benjamin,terach), ancestor(benjamin,abrahain), ancestor(benjainin,isaac), ancestor (benjamin, jacob), ancestor (benj amin, benjamin) }. The Herbrand base is infinite if the Herbrand universe is. For Program 3.1, there is one predicate, natural_number. The Herbrand base equals tnatural_nuinber(0) ,natural_riumber(s(0)),

.

.

. L Definition An interpretation for a logic program is a subset of the Herbrand base. u

<!-- page 145 -->
An interpretation assigns truth and falsity to the elements of the Herbrand base. A goal in the Herbrand base is true with respect to an interpretation if it is a member of it, false otherwise. Definition An interpretation I is a model for a logic program if for each ground instance of a clause in the program AB1,. . .,B, A is in I if B1,. . .,B are inI.

Intuitively, models are interpretations that respect the declarative reading of the clauses of a program.

For Program 3.1, `natural_number(0)` must be in every model, and `natural_number(s(X))` is in the model if `natural_number(X)` is. Any model of Program 3.1 thus includes the whole Herbrand base.

```prolog
  For Program 5.1, the facts parent(terach,abraham), parent(abra-
ham,isaac),
              parent(isaac,jacob),
                                      and
                                           parent(jacob,benjamin)
```

must be in every model. A ground instance of the goal `ancestor(X,Y) is` in the model if the corresponding instance of `parent (X, Y)` is, by the first clause. So, for example, `ancestor(terach,abrahain)` is in every model. By the second clause, `ancestor(X,Z)` is in the model if `parent(X,Y)` and

```prolog
ancestor(Y,Z) are.
```

It is easy to see that the intersection of two models for a logic program P is again a model. This property allows the definition of the intersection of all models. Definition The model obtained as the intersection of all models is known as the minimal model and denoted M(P). The minimal model is the declarative meaning of a logic program.

**.**

The declarative meaning of the program for `natural_number,` its minimal model, is the complete Herbrand base `{natural_number(0) ,natu-`

```prolog
ral_number(s(0)),natural_number(s(s(0))), .
                                               ..
```

The declarative meaning of Program 5.1 is `{parent(terach,abrahani),`

```prolog
parent(abrahain,isaac),
                            parent(isaac,jacob),
                                                     parent(jacob,
benjamin), ancestor(terach,abraham), ancestor(abraham,isaac),
ancestor(isaac,jacob),
                            ancestor(jacob,benjamin),
                                                          ancestor
(terach,isaac),
                    ancestor(terach,jacob),
                                                  ancestor(terach,
benjamin),
              ancestor(abraham,jacob),
                                            ancestor(abraham,ben-
jamin), ancestor(isaac,benjamin)}.
```

Let us consider the declarative meaning of `append,` defined as Program 3.15 and repeated here:

```prolog
append([XIXs],Ys,[XIZs]) - append(Xs,Ys,Zs).
append([ ] ,Ys,Ys).
```

<!-- page 146 -->
The Herbrand universe is F 1,1F ]],[[ 1,1 ]],

.

. , namely, all lists that can be built using the constant 1]. The Herbrand base is all combinations of lists with the append predicate. The declarative meaning is all ground instances

of

```prolog
append([ I ,Xs,Xs),
                      that
                           is,
                                append([ i, [ J 1 i)
```

**append( E i , [L i] , [L i]),**

.

.

, together with goals such as append ([E 1] , E i , [E ]]), which are logically implied by application(s) of the rule. This is only a subset of the Herbrand base. For example, append( E

J ,

E

] , [E ]]) is not in the meaning of append but is in the Herbrand base.

Denotational semantics assigns meanings to programs based on associating with the program a function over the domain computed by the program. The meaning of the program is defined as the least fixpoint of the function, if it exists. The domain of computations of logic programs is interpretations. Definition Given a logic program P, there is a natural mapping Tp from interpretations to interpretations, defined as follows: Te(I) = [A in B(P):A B1,B2,.. .,B, n

0, is a ground instance of

a clause in P, and B1,.. .,B are in I}.

**i**

The mapping is monotonic, since whenever an interpretation I is contained in an interpretation J, then Tp(I) is contained in Tp(J).

This mapping gives an alternative way of characterizing models. An interpretation I is a model if and only if Te(I) is contained in I.

Besides being monotonic, the transformation is also continuous, a notion that will not be defined here. These two properties ensure that for every logic program P, the transformation Tp has a least fixpoint, which is the meaning assigned to P by its denotational semantics.

Happily, all the different definitions of semantics are actually describing the same object. The operational, denotational, and declarative semantics have been demonstrated to be equivalent. This allows us to define the meaning of a logic program as its minimal model.

<!-- page 147 -->
5.2 Program Correctness Every logic program has a well-defined meaning, as discussed ¡n Section 5.1. This meaning is neither correct nor incorrect.

The meaning of the program, however, may or may not be what was intended by the programmer. Discussions of correctness must therefore take mto consideration the intended meaning of the program. Our previous discussion of proving correctness and completeness similarly was with respect to an intended meanrng of a program.

We recall the definitions from Chapter 1. An intended meaning of a program P is a set of ground goals. We use intended meanings to denote the set of goals intended by the programmer for the program to compute. A program P is correct with respect to an intended meaning M if M(P) is contained in M. A program P is complete with respect to an intended meaning if M is contained in M(P). A program is thus correct and complete with respect to an intended meaning if the two meanings coincide exactly.

Another important aspect of a logic program is whether it terminates. Definition A domain is a set of goals, not necessarily ground, closed under the instance relation. That is, if A is in D and A' is an instance of A, then A' is in D as well. Definition A termination domain of a program P is a domain D such that every computation of P on every goal in D terminates.

Usually, a useful program should have a termination domain that includes its intended meaning. However, since the computation model of logic programs is liberal in the order in which goals in the resolvent can be reduced, most interesting logic programs will not have interesting termination domains. This situation will improve when we switch to Prolog. The restrictive model of Prolog allows the programmer to compose nontrivial programs that terminate over useful domains.

Consider Program 3.1 defining the natural numbers. This program is terminating over its Herbrand base. However, the program is nonterminating over the domain {natural_number(X)}. This is caused by the possibility of the nonterminating computation depicted in the trace in Figure 5.1.

<!-- page 148 -->
For any logic program, it is useful to find domains over which it is terminating. This is usually difficult for recursive logic programs. We

```prolog
natural_riuinber(X)
                             Xs(X1)
  natural_nuinber(X1)
                             X1s(X2)
    natural_number(X2)
                             X2s(X3)
```

Figure 5.1

A nonterminating computation

need to describe recursive data types in a way that allows us to discuss termination.

Recall that a type, introduced in Chapter 3, is a set of terms. Definition A type is complete if the set is closed under the instance relation. With every complete type T we can associate an incomplete type IT, which is the set of terms that have instances in T and instances not in T.

**.**

We illustrate the use of these definitions to find termination domains for the recursive programs using recursive data types in Chapter 3. Specific instances of the definitions of complete and incomplete types are given for natural numbers and lists. A (complete) natural number is either the constant O, or a term of the form s(X). An incomplete natural number is either a variable, X, or a term of the form s(0), where X is a variable. Program 3.2 for

is terminating for the domain consisting of goals where the first and/or second argument is a complete natural number. Definition A list is complete if every instance satisfies the definition given in Program 3.11. A list is incomplete if there are instances that satisfy this definition and instances that do not.

**.**

For example, the list [a,b,c] is complete (proved in Figure 3.3), while the variable X is incomplete. Two more interesting examples: [a, X, c] is a complete list, although not ground, whereas [a,bXs] is incomplete.

<!-- page 149 -->
A termination domain for append is the set of goals where the first and/or the third argument is a complete list. We discuss domains for other list-processing programs in Section 7.2, on termination of Prolog programs. 5.2.1

Exercises for Section 5.2

Give a domain over which Program 3.3 for plus is terminating.

Define complete and incomplete binary trees by analogy with the

definitions for complete and incomplete lists.

5.3 Complexity We have analyzed informally the complexity of several logic programs, for example,

and plus (Programs 3.2 and 3.3) in the section on arithmetic, and append and the two versions of reverse in the section on lists (Programs 3.15 and 3.16). In this section, we briefly describe more formal complexity measures.

The multiple uses of logic programs slightly change the nature of complexity measures. Instead of looking at a particular use and specifying complexity in terms of the sizes of the inputs, we look at goals in the meaning and see how they were derived. A natural measure of the complexity of a logic program is the length of the proofs it generates for goals in its meaning. Definition The size of a term is the number of symbols in its textual representation..

Constants and variables, consisting of a single symbol, have size 1. The size of a compound term is i more than the sum of the sizes of its arguments. For example, the list [b] has size 3, [a,b] has size 5, and the goal append([a,b] , [c,d] ,Xs) has size 12. In general, a list of n elements has size 2 . n + 1. Definition A program P is of length complexity L(n) if for any goal G in the meaning of P of size n there is a proof of G with respect to P of length less than equal to L(n).

<!-- page 150 -->
Length complexity is related to the usual complexity measures in computer science. For sequential realizations of the computation model, it corresponds to time complexity. Program 3.15 for append has linear length complexity. This is demonstrated in Exercise (i) at the end of this section.

The applicability of this measure to Prolog programs, as opposed to logic programs, depends on using a unification algorithm without an occurs check. Consider the runtime of the straightforward program for appending two lists. Appending two lists, as shown in Figure 4.3, involves several unifications of append goals with the head of the append rule append([XXs] ,Ys, [XIZs]). At least three unifications, matching variables against (possibly incomplete) lists, will be necessary. If the occurs check must be performed for each, the argument lists must be searched. This is directly proportional to the size of the input goal. However, if the occurs check is omitted, the unification time will be bounded by a constant. The overall complexity of append becomes quadratic in the size of the input lists with the occurs check, but only linear without it.

We introduce other useful measures related to proofs. Let R be a proof. We define the depth of R to be the deepest invocation of a goal in the associated reduction. The goal-size of R is the maximum size of any goal reduced. Definition A logic program P is of goal-size complexity G(n) if for any goal A in the meaning of P of size n, there is a proof of A with respect to P of goal-size less than or equal to G(n).

**.**

Definition A logic program P is of depth-complexity D(n) if for any goal A in the mearnng of P of size n, there is a proof of G with respect to P of depth D(n).

Goal-size complexity relates to space. Depth-complexity relates to space of what needs to be remembered for sequential realizations, and to space and time complexity for parallel realizations.

5.3.1

Exercises for Section 5.3

(i)

Show that the size of a goal in the meaning of append joining a

list of length n to one of length ni to give a list of length n + m

**is 4 . n + 4 m + 4. Show that a proof tree has rn + i nodes. Hence**

<!-- page 151 -->
show that `append` has linear complexity. Would the complexity be

altered if the type condition were added?

Show that Program 3.3 for plus has linear complexity.

Discuss the complexity of other logic programs.

5.4 Search Trees Computations of logic programs given so far resolve the issue of nondeterminism by always making the correct choice. For example, the complexity measures, based on proof trees, assume that the correct clause can be chosen from the program to effect the reduction. Another way of computationally modeling nondetermrnism is by developing all possible reductions in parallel. In this section, we discuss search trees, a formalism for considering all possible computation paths. Definition A search tree of a goal G with respect to a program P is defined as follows. The root of the tree is G. Nodes of the tree are (possibly conjunctive) goals with one goal selected. There is an edge leading from a node N for each clause in the program whose head unifies with the selected goal. Each branch in the tree from the root is a computation of G by P. Leaves of the tree are success nodes, where the empty goal has been reached, or failure nodes, where the selected goal at the node cannot be further reduced. Success nodes correspond to solutions of the root of the tree.

u

There are in general many search trees for a given goal with respect to a program. Figure 5.2 shows two search trees for the query `son(S,haran)?` with respect to Program 1.2. The two possibilities correspond to the two choices of goal to reduce from the resolvent `f a-` `ther(haran,S) ,male(S).` The trees are quite distinct, but both have a single success branch corresponding to the solution of the query `S=lot.` The respective success branches are given as traces in Figure 4.4.

<!-- page 152 -->
We adopt some conventions when drawing search trees. The leftmost goal of a node is always the selected one. This implies that the goals in derived goals may be permuted so that the new goal to be selected for Figure 5.2

Two search trees

reduction is the first goal. The edges are labeled with substitutions that are applied to the variables in the leftmost goal. These substitutions are computed as part of the unification algorithm.

Search trees correspond closely to traces for deterministic computations. The traces for the `append` query and `hanoi` query given, respectively, in Figures 4.3 and 4.5 can be easily made into search trees. This is Exercise (i) at the end of this section.

Search trees contain multiple success nodes if the query has multiple solutions. Figure 5.3 contains the search tree for the query ap- `pend(As , Bs, [a, b, ci)?` with respect to Program 3.15 for `append,` asking to split the list

`[a, b, ci` into two. The solutions for `As` and `Bs` are found by collecting the labels of the edges in the branch leading to the success node. For example, in the figure, following the leftmost branch gives the

```prolog
solution {As=[a,b,c] ,Bs=[ J).
```

The number of success nodes is the same for any search tree of a given goal with respect to a program.

<!-- page 153 -->
Search trees can have infinite branches, which correspond to nonterminating computations. Consider the goal `append(Xs, [c,di ,Ys)` with respect to the standard program for `append.` The search tree is given in Figure 5.4. The infinite branch is the nonterminating computation given in Figure 4.6.

],Bsa,c]}

{Asl =[ ],Bs=[b,c]}

**C**

{As2=[ },Bs=lcJ}

Figure 5.3

Search tree with multiple success nodes

Complexity measures can also be defined in terms of search trees. Prolog programs perform a depth-first traversal of the search tree. Therefore, measures based on the size of the search tree will be a more realistic measure of the complexity of Prolog programs than those based on the complexity of the proof tree. However, the complexity of the search tree is much harder to analyze.

There is a deeper point lurking. The relation between proof trees and search trees is the relation between nondeterministic computations and deterministic computations. Whether the complexity classes defined via proof trees are equivalent to complexity classes defined via search trees is a reformulation of the classic P=NP question in terms of logic programming.

5.4.1

Exercises for Section 5.4

Transform the traces of Figure 4.3 and 4.5 into search trees.

Draw a search tree for the query sort([2,4, 1] ,Xs)? using permu-

<!-- page 154 -->
tation sort.

{Xs=[X1 jXsl ],Ys=[X1 IYsl]}

aspen

{Xsl =[X2IXs2],Ysl =[X2IYs2J}

aspen lXs2=[X3IXs3J,Ys2=[X3IYs3]}

4

```prolog
 .
 4
s
```

Figure 5.4

Search tree with an infinite branch

5.5 Negation in Logic Programming Logic programs are collections of rules and facts describing what is true. Untrue facts are not expressed explicitly; they are omitted. When writing rules, it is often natural to include negative conditions. For example, defining a bachelor as an unmarried male could be written as

```prolog
bachelor(X) - male(X), not married(X).
```

if negation were allowed. In this section, we describe an extension to the logic programming computation model that allows a limited form of negation.

Researchers have investigated other extensions to logic programming to allow disjunction, and indeed, arbitrary first-order formulae. Discussing them is beyond the scope of this book. The most useful of the extensions is definitely negation.

<!-- page 155 -->
We define a relation `not G` and give a semantics. The essence of logic progranmiing is that there is an efficient procedural semantics. There is a natural way to adapt the procedural semantics to negation, namely by negation as failure. A goal `G` fails, `(not G` succeeds), if `G` cannot be derived by the procedural semantics.

The relation `not G` is only a partial form of negation from first-order logic. The relation not uses the negation as failure rule. A goal `not G will` be assumed to be a consequence of a program P if `G` is not a consequence of P.

Negation as failure can be characterized in terms of search trees.

Definition A search tree of a goal G with respect to a program P is finitely failed if it has no success nodes or infinite branches. The finite failure set of a logic program P is the set of goals G such that G has a finitely failed search tree with respect to P.

A goal not G is implied by a program P by the "negation as failure" rule if G is in the finite failure set of P.

Let us see a simple example. Consider the program consisting of two facts:

```prolog
likes (abrahain,poinegranates).
likes(isaac,pomegranates).
```

The goal `not likes (sarah, pomegranates)` follows from the program by negation as failure. The search tree for the goal `likes (sarah, pomegran-` `ates)` has a single failure node.

Using negation as failure allows easy definition of many relations. For example, a declarative definition of the relation `disjoint(Xs,Ys)` that two lists, `Xs` and `Ys,` have no elements in common is possible as follows.

```prolog
disjoint(Xs,Ys) - not (member(X,Xs), member(X,Ys)).
```

This reads: "Xs is disjoint from Ys if there is no element X that is a member of both Xs and Ys."

<!-- page 156 -->
An intuitive understanding of negation as failure is fine for the programs in this book using negation. There are semantic problems, however, especially when integrated with other issues such as completeness and termination. Pointers to the literature are given in Section 5.6, and Prolog's implementation of negation as failure is discussed in Chapter 11. 5.6 Background The classic paper on the semantics of logic programs is of van Emden and Kowaiski (1976). Important extensions were given by Apt and van Emden (1982). In particular, they showed that the choice of goal to reduce from the resolvent is arbitrary by showing that the number of success nodes is an invariant for the search trees. Textbook accounts of the theory of logic programming discussing the equivalence between the declarative and procedural semantics can be found in Apt (1990), Deville (1990), and Lloyd (1987).

In Shapiro (1984), complexity measures for logic programs are compared with the complexity of computations of alternating Turing machines. It is shown that goal-size is linearly related to alternating space, the product of length and goal-size is linearly related to alternating treesize, and the product of depth and goal-size is linearly related to alternating time.

The classic name for search trees in the literature is SLD trees. The name SLD was coined by research in automatic theorem proving, which preceded the birth of logic programming. SLD resolution is a particular refinement of the resolution principle introduced in Robinson (1965). Computations of logic programs can be interpreted as a series of resolution steps, and in fact, SLD resolution steps, and are still commonly described thus in the literature. The acronym SLD stands for Selecting a literal, using a Linear strategy, restricted to Definite clauses.

The first proof of the correctness and completeness of SLD resolution, albeit under the name LUSH-resolution, was given by Hill (1974).

The subject of negation has received a large amount of attention and interest since the inception of logic programming. The fundamental work on the semantics of negation as failure is by Clark (1978). Clark's results, establishing soundness, were extended by Jaffar et al. (1983), who proved the completeness of the rule.

<!-- page 157 -->
The concept of negation as failure is a restricted version of the closed world assumption as discussed in the database world. For more information see Reiter (1978). There has been extensive research on characterizing negation in logic programming that has not stabilized at this time. The reader should look up the latest logic programming conference proceedings to find current thinking. A good place to start reading to understand the issue is Kunen (1989). Leonardo Da Vinci. Portrait of the Florentine poet Bernardo Bellincioni, engaged at the Court of Ludovico Sforza. Woodcut, based on a drawing by Leonardo. From Bellincioni's Rime. Milan 1493.
