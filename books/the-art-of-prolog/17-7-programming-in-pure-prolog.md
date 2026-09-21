# 7 Programming in Pure Prolog

<!-- page 170 -->
**Prograniming in Pure Prolog**

A major aim of logic programming is to enable the programmer to program at a higher level. Ideally one should write axioms that define the desired relations, maintaining ignorance of the way they are going to be used by the execution mechanism. Current logic programming languages, Prolog in particular, are still far away from allowing this ideal of declarative programming The specific, well-defined choices of how their execution mechanisms approximate the abstract interpreter cannot be ignored. Effective logic programming requires knowing and utilizing these choices.

This chapter discusses the consequences of Prolog's execution model for the logic programmer New aspects of the programming task are introduced. Not only must programmers come up with a correct and complete axiomatization of a relation but they must also consider its execution according to the model.

<!-- page 171 -->
7.1 Rule Order Two syntactic issues, irrelevant for logic programs, are important to consider when composing Prolog programs The rule order, or clause order, of clauses in each procedure must be decided. Also the goal order of goals in the bodies of each clause must be determined The consequences of these decisions can be immense. There can be orders of magnitude of difference in efficiency in the performance of Prolog programs. In extreme though quite common cases, correct logic programs will fail to give solutions because of nontermination. parent(terach,abraham).

```prolog
parent(abraham,isaac).
```

parent(isaac,jacob).

```prolog
parent(jacob,benjaxnin).
```

ancestor(X,Y) - parent(X,Y). ancestor(X,Z) - parent(X,Y), ancestor(Y,Z). Program 7.1

Yet another family example

The rule order determines the order in which solutions are found.

Changing the order of rules in a procedure permutes the branches in any search tree for a goal using that procedure. The search tree is traversed depth-first. So permuting the branches causes a different order of traversal of the search tree, and a different order of finding solutions. The effect is clearly seen when using facts to answer an existential query. With our biblical database and a query such as `father (X, Y)?,` changing the order of facts will change the order of solutions found by Prolog. Deciding how to order facts is not very important.

The order of solutions of queries solved by recursive programs is also determined by the clause order. Consider Program 5.1, a simple biblical database together with a program for the relationship `ancestor,` repeated here as Program 7.1.

For the query `ancestor (terach,X)?` with respect to Program 7.1, the solutions will be given in the order, `X=abraham, X=isaac, X=j acob,` and `X=benjamin.` If the rules defining `ancestor` are swapped, the solutions will appear in a different order, namely, `X=benj amin, X=j acob, X=isaac,`

```prolog
and X=abraham.
```

The different order of `ancestor` clauses changes the order of searching the implicit family tree. In one order, Prolog outputs solutions as it goes along. With the other order, Prolog travels to the end of the family tree and gives solutions on the way back. The desired order of solutions is determined by the application, and the rule order of `ancestor` is chosen accordingly.

<!-- page 172 -->
Changing the order of clauses for the `member` predicate (Program 3.12) also changes the order of search. As written, the program searches the list until the desired element is found. If the order of the clauses is reversed, the program always searches to the end of the list. The order of solutions will also be affected, for example, responding to the query `member(X, [1,2,3])?.` In the standard order, the order of solutions is intuìtive X=1, X=2, X=3. With the rules swapped, the order is X=3, X=2, X=1. The order of Program 3.12 is more intuitive and hence preferable.

When the search tree for a given goal has an infinite branch, the order of clauses can determine if any solutions are given at all. Consider the query append(Xs, [c,d] ,Ys) with respect to append. As can be seen from the search tree in Figure 5.4, no solutions would be given. If, however, the append fact appeared before the append rule, an infinite number of pairs Xs , Ys satisfying the query would be given.

There is no consensus as to how to order the clauses of a Prolog procedure. Clearly, the standard dictated in more conventional languages, of testing for the termination condition before proceeding with the iteration or recursion is not mandatory in Prolog. This is demonstrated in Program 3.15 for append as well as in other programs in this book. The reason is that the recursive or iterative clause tests its applicability by unification. This test is done explicitly and independently of the other clauses in the procedure.

Clause order is more important for general Prolog programs than it is for pure Prolog programs. Other control features, notably the cut to be discussed in Chapter 11, depend significantly on the clause order. When such constructs are used, clauses lose their independence and modularity, and clause order becomes significant.

In this chapter, for the most part, the convention that the recursive clauses precede the base clauses is adopted. 7.1.1

Exercises for Section 7.1

Verify the order of solutions for the query ancestor(abraham,X)?

with respect to Program 7.1, and its variant with different rule order

for ancestor, claimed in the text.

What is the order of solutions for the query ancestor(X,benja-

miri)? with respect to Program 7.1? What if the rule order for

ancestor were swapped?

<!-- page 173 -->
7.2 Termination Prolog's depth-first traversal of search trees has a serious problem. If the search tree of a goal with respect to a program contains an infinite branch, the computation will not terminate. Prolog may fail to find a solution to a goal, even though the goal has a finite computation.

Nontermination arises with recursive rules. Consider adding a relationship `marri ed (Male ,Female)` to our database of family relationships. A sample fact from the biblical situation is `married(abraham,sarah).` A user querying the `married` relationship should not care whether males or females are first, as the relationship is commutative. The "obvious" way of overcoming the commutativity is adding a recursive rule `mar-` `ried(X,Y) - married(Y,X).` If this is added to the program, no computation involving `married` would ever terminate. For example, the trace of the query `married(abraham, sarah)?` is given in Figure 7.1.

Recursive rules that have the recursive goal as the first goal in the body are known as left recursive rules. The problematic `married` axiom is an example. Left recursive rules are inherently troublesome in Prolog. They cause nonterminating computations if called with inappropriate arguments.

The best solution to the problem of left recursion is avoidance. The `married` relationship used a left recursive rule to express comrnutativìty. Commutative relationships are best handled differently, by defining a new predicate that has a clause for each permutation of the arguments of the relationship. For the relationship `married,` a new predicate, `are_` `married (Personi , Person2),` say, would be defined using two rules:

```prolog
are_married(X,Y) - married(X,Y).
are_married(X,Y) - married(Y,X).
```

Unfortunately, it is not generally possible to remove all occurrences of left recursion. All the elegant minimal recursive logic programs shown in Chapter 3 are left recursive, and can cause nontermination. However,

married(X,Y) - married(Y,X). married(abrahaxn, sarah). married(abrahain, sarah)

married(sarah, abraham)

```prolog
married(abraham, sarah)
  married(sarah, abraham)
```

Figure 7.1

<!-- page 174 -->
A nonterminating computation the appropriate analysis, using the concepts of domains and complete structures introduced in Section 5.2, can determine which queries will terminate with respect to recursive programs.

Let us consider an example, Program 3.15 for appending two lists. The program for `append` is everywhere terminating for the set of goals whose first and/or last argument is a complete list. Any `append` query whose first argument is a complete list will terminate. Similarly, all queries where the third argument is a complete list will terminate. The program will also terminate if the first and/or third argument is a ground term that is not a list. The behavior of `append` is best summed up by considering the queries that do not terminate, namely, when both the first and third arguments are incomplete lists that are unifiable.

The condition for when a query to Program 3.12 for `member` terminates is also stated in terms of incomplete lists. A query does not terminate if the second argument is an incomplete list. If the second argument of a query to `member` is a complete list, the query terminates.

Another guaranteed means of generating nonterminating computations, easy to overlook, is circular definitions. Consider the pair of rules

```prolog
parent(X,Y) - child(Y,X).
child(X,Y) - parent(Y,X).
```

Any computation involving `parent` or

`child,` for example,

```prolog
parent
```

`(haran,lot)?,` will not terminate. The search tree necessarily contains an infinite branch, because of the circularity. 7.2.1

Exercises for Section 7.2

Discuss the termination behavior of both programs in Program 3.13

determining prefixes and suffixes of lists.

Discuss the termination of Program 3.14c for `sublist.`

<!-- page 175 -->
7.3 Goal Order Goal order is more significant than clause order. lt is the principal means of specifying sequential flow of control in Prolog programs. The programs for sorting lists, e.g., Program 3.22 for `quicksort,` exploit goal order to indicate the sequence of steps in the sorting algorithms.

We first discuss goal order from the perspective of database programming. The order of goals can affect the order of solutions. Consider the query `daughter(X,haran)?` with respect to a variant of Program 1.2, where the order of the facts `f emale(milcah)` and `f emale(yiscah)` is interchanged. The two solutions are given in the order `X=milcah,` `X=yiscah.` If the goal order of the `daughter` rule were changed to be

```prolog
daughter(X,Y) - f emale(X) ,father(Y,X)
```

`.,` the order of the solutions to the query, given the same database, would be `X=yiscah, X=milcah.`

The reason that the order of goals in the body of a clause affects the order of solutions to a query is different from the reason that the order of rules in a procedure affects the solution order. Changing rule order does not change the search tree that must be traversed for a given query. The tree is just traversed in a different order. Changing goal order changes the search tree. Goal order determines the search tree.

Goal order affects the amount of searching the program does in solving a query by deternnning which search tree is traversed. Consider the two search trees for the query `son(X,haran)?,` given in Figure 5.2. They represent two different ways of finding a solution. In the first case, solutions are found by searching for children of `haran` and checking if they are male. The second case corresponds to the rule for `son` being written with the order of the goals in its body swapped, namely, `son(X,Y) -` `male (X), parent(Y,X).` Now the query is solved by searching through all the males in the program and checking if they are children of `ha-` `ran.` If there were many `male` facts in the program, more search would be involved. For other queries, for example, `son(sarah,X)?,` the reverse order has advantages. Since `sarah` is not male, the query would fail more quickly.

The optimal goal order of Prolog programs varies with different uses. Consider the definition of `grandparent.` There are two possible rules:

```prolog
grandparent(X,Z) - parent(X,Y), parent(Y,Z).
grandparent(X,Z) - parent(Y,Z), parent(X,Y).
```

<!-- page 176 -->
If you wish to find someone's grandson with the `grandfather` relationship with a query such as `grandparent (abraham, X)?,` the first of the rules searches more directly. If looking for someone's grandparent with a query such as `grandparent (X,isaac)?,` the second rule finds the solution more directly. If efficiency is important, then it is advisable to have two distinct relationships, `grandparent` and `grandchild,` to be used appropnately at the user's discretion.

In contrast to rule order, goal order can determine whether computations terminate. Consider the recursive rule for `ancestor:`

```prolog
a.ncestor(X,Y) - parent(X,Z), ancestor(Z,Y).
```

If the goals in the body are swapped, the `ancestor` program becomes left recursive, and all Prolog computations with `ancestor` are nonterminating.

The goal order is also important in the recursive clause of the quicksort algorithm in Program 322:

```prolog
quicksort([XIXs] ,Ys) -
    partition(Xs,X,Littles,Bigs),
    quicksort(Littles,Ls),
    quicksort(Bigs,Bs),
    append(Ls, [X lBs] ,Ys).
```

The list should be partitioned into its two smaller pieces before recursively sorting the pieces. If, for example, the order of the `partition` goal and the recursive sorting goal is swapped, no computations terminate.

We next consider Program 3.16a for reversing a list:

```prolog
reverse([ ],[ ]).
reverse([XIXs] ,Zs) - reverse(Xs,Ys), append(Ys, [X],Zs).
```

The goal order ìs significant. As written, the program terminates with goals where the first argument is a complete list. Goals where the first argument is an incomplete list give nonterminating computations. If the goals in the recursive rule are swapped, the determining factor of the termination of `reverse` goals is the second argument. Calls to `reverse` with the second argument a complete list terminate. They do not terminate if the second argument is an incomplete list.

A subtler example comes from the definition of the predicate sub- `list` in terms of two `append` goals, specifying the sublist as a suffix of a prefix, as given in Program 3.14e. Consider the query sub- `list ([2,3] , [1 2,3,4])?` with respect to the program. The query is reduced to

```prolog
append(AsXs,Bs, [1,2,3,4]), append(As, [2,3] ,AsXs)?.
```

<!-- page 177 -->
This has a finite search tree, and the initial query succeeds. If Program 3.14e had its goals reversed, the initial query would be reduced to append(As,[2,31,AsXs),append(AsXs,Bs,[1,2,3,4])?. This leads to a nonterminating computation because of the first goal, as illustrated in Figure 5.4.

A useful heuristic for goal order can be given for recursive programs with tests such as arithmetic comparisons, or determining whether two constants are different. The heuristic is to place the tests as early as possible. An example comes in the program for partition, which is part of Program 3.22. The first recursive rule is partition([XIXs] ,Y, EXILs] ,Bs) - X

Y, partition(Xs,Y,Ls,Bs). The test X

< Y should go before the recursive call. This leads to a smaller search tree.

In Prolog progranmiing (in contrast, perhaps, to life in general) our goal is to fail as quickly as possible. Failing early prunes the search tree and brings us to the right solution sooner. 7.3.1

Exercises for Section 7.3

Consider the goal order for Program 3.14e defining a sublist of

a list as a suffix of a prefix. Why is the order of the append

goals in Program 3.14e preferable? (Hint: Consider the query sub-

```prolog
list(Xs, [a,b,c])?.)
```

Discuss the clause order, goal order, and termination behavior for

substitute, posed as Exercise 3.3(i).

**7.4 Redundant Solutions**

<!-- page 178 -->
An important issue when composing Prolog programs, irrelevant for logic programs, is the redundancy of solutions to queries. The meaning of a logic program is the set of ground goals deducible from it. No distinction is made between whether a goal in the meaning could be deduced uniquely from the program, or whether it could be deduced in several distinct ways. This distinction is important for Prolog when considering the efficiency of searching for solutions. Each possible deduction means an extra branch in the search tree. The bigger the search tree, the longer a computation will take. It is desirable in general to keep the size of the search tree as small as possible.

Having a redundant program may cause, in an extreme case, exponential increase in runtime, in the event of backtracking. If a conjunction of n goals is solved, and each goal has one redundant solution, then in the event of backtracking, the conjunction may generate 2" solutions, thus possibly changing a polynomial-time program (or even a linear one) to be exponential.

One way for redundancy to occur in Prolog programs is by covering the same case with several rules. Consider the following two clauses defining the relation minimum.

```prolog
minimum(X,Y,X) - X
                      <
                        Y.
minimum(X,Y,Y) - Y
                        X.
```

The query minimuni(2,2,M)? with respect to these two clauses has a unique solution M=2, which is given twice; one is redundant.

Careful specification of the cases can avoid the problem. The second clause can be changed to

```prolog
minimuni(X,Y,Y) -
                   Y
                      <
                        X.
```

Now only the first rule covers the case when the two numbers have equal values.

Similar care is necessary with the definition of partition as part of Program 3.22 for quicksort. The programmer must ensure that only one of the recursive clauses for partition covers the case when the number being compared is the same as the number being used to split the list.

Another way redundancy appears in programs is by having too many special cases. Some of these can be motivated by efficiency. An extra fact can be added to Program 3.15 for append, namely, append(Xs, E J ,Xs), to save recursive computations when the second argument is an empty list. In order to remove redundancy, each of the other clauses for append would have to cover only lists with at least one element as their second argument.

<!-- page 179 -->
We illustrate these points when composing Program 7.2 for the relation merge (Xs , `Ys ,` Ze), which is true if Xs and Ys are lists of integers sorted in ascending order and Zs is the ordered list resulting from merging them. merge(Xs,Ys,Zs) -

Zs is an ordered list of integers obtained from

merging the ordered lists of integers Xs and Ys.

```prolog
merge([XIXs],[YIYs],[XIZs]) -
    X < Y, merge(Xs,[YIYs],Zs).
merge([XIXs] ,[YIYs] , [X,XIZs]) -
    X
         Y, merge(Xs,Ys,Zs).
merge([XIXs],[YIYs],[YIZs]) -
    X > Y, merge([XIXs],Ys,Zs).
merge([ I, [XIXs] , [XIXs]).
merge(Xs, E I ,Xs).
```

Program 7.2

Merging ordered lists

There are three separate recursive clauses. They cover the three possible cases: when the head of the first list is less than, equal to, or greater than the head of the second list. We discuss the predicates <, =:=, and> in Chapter 8. Two cases are needed when the elements iii either list have been exhausted. Note that we have been careful that the goal merge ( [

I , [ I , [ ]) is covered by only one fact, the bottom one.

Redundant computations occur when using member to find whether a particular element occurs in a particular list, and there are multiple occurrences of the particular element being checked for in the list. For example, the search tree for the query member (a, [a, b, a, c]) would have two success nodes.

The redundancy of previous programs was removed by a careful consideration of the logic. In this case, the member program is correct. If we want a different behavior, the solution is to compose a modified version of member.

<!-- page 180 -->
Program 7.3 defines the relation member_check(X,Xs) which checks whether an element X is a member of a list Xs. The program is a variant of Program 3.12 for member that adds a test to the recursive clause. It has the same meaning but, as a Prolog program, it behaves differently. Figure 7.2 shows the difference between the search trees for the identical query to the two programs. The left tree is for the goal member(a, [a,b,a,c]) with respect to Program 3.12. Note there are two success nodes. The right tree is for the goal member_check(a, [a,b,a,c]) with respect to Program 7.3. It has only one success node. member_check (X,Xs)

X is a member of the list Xs.

```prolog
rnember_check(X, [XIXs]).
member_check(X,[YIYs]) -
                        X
                             Y,
                               member_check(X,Ys).
```

Program 7.3

Checking for list membership

member check(aja,b,a,c

aa, member_check(a,[b,a,c

Figure 7.2

Variant search trees

We restrict use of Program 7.3 to queries where both arguments are ground. This is because of the way

is implemented in Prolog, discussed in Section 11.3.

<!-- page 181 -->
7.5 Recursive Programming in Pure Prolog Lists are a very useful data structure for many applications written in Prolog. In this section, we revise several logic programs of Sections 3.2 and 3.3 concerned with list processing. The chosen clause and goal orders are explained, and their termination behavior presented. The section also discusses some new examples. Their properties are analyzed, and a reconstruction offered of how they are composed. select_first (X,Xs, Ys)

Ys is the list obtained by removing the

first occurrence of X from the list Xs.

```prolog
selectfirst(X, [XIXs] ,Xs)
select_first(X, [YIYs] , [YIZs])
    X
        Y, select_first(X,Ys,Zs).
```

Program 7.4

Selecting the first occurrence of an element from a list

Programs 3.12 and 3.15 for member and append, respectively, are correct Prolog programs as written. They are both minimal recursive programs, so there is no issue of goal order. They are in their preferred clause order, the reasons for which have been discussed earlier in this chapter. The termination of the programs was discussed in Section 7.2.

Program 3.19 for select is analogous to the program for member: select (X, [XIXs] ,Xs). select(X,[YIYs],[YIZs]) - select(X,Ys,Zs). The analysis of select is similar to the analysis of member. There is no issue of goal order because the program is minimal recursive. The clause order is chosen to reflect the intuitive order of solutions to queries such as select(X,[a,b,c],Xs), namely, {X=a,Xs=[b,c]},{X=b,Xs=[a,c]}, {X=c,Xs=[a,b]}. The first solution is the result of choosing the first element, and so forth. The program terminates unless both the second and third arguments are incomplete lists.

A variant of select is obtained by adding the test X

Y in the recursive clause. As before, we assume that

is only defined for ground arguments. The variant is given as Program 7.4 defining the relation select_ f irst(X,Xs,Ys). Programs 3.12 and 7.3 defining member and mnember_ check have the same meaning. Program 7.4, in contrast, has a different meaningfromProgram3.19.Thegoalselect(a,[a,b,a,c],[a,b,c]) is in the meaning of select, whereas select_f irst (a, [a,b,a,c] , [a,b, c]) is not in the meaning of select_first.

The next program considered is Program 3.20 for permutation. The order of clauses, analogously to the clause order for append, reflects the more likely mode of use: permutation(XsJXÌYs]) - select(X,Xs,Zs), permnutation(Zs,Ys). permutation( E

<!-- page 182 -->
J , E ]). nonmember(X,Xs) -

X is not a member of the list Xs.

```prolog
nonmember(X,[YIYs]) - X
                          Y, nonmernber(X,Ys).
nonmember(X,[ I).
```

Program 7.5

Nonmembership of a list

The goal order and the termination behavior of `permutation` are closely related. Computations of `permutation` goals where the first argument is a complete list will terminate. The query calls `select` with its second argument a complete list, which terminates generating a complete list as its third argument. Thus there is a complete list for the recursive `permutation` goal. If the first argument is an incomplete list, the `permutation` query will not terminate, because it calls a `select` goal that will not terminate. 1f the order of the goals in the recursive rule for `permutation` is swapped, the second argument of a `permutation` query becomes the significant one for determining termination. If it is an incomplete list, the computation will not terminate; otherwise it will.

A useful predicate using

is `nonmember(X,Ys)` which is true if Xis not a member of a list Ys. Declaratively the definition is straightforward: An element is a norimember of a list if it is not the head and is a nonmember of the tail. The base case is that any element is a nonmember of the empty list. This program is given as Program 7.5.

Because of the use of

, `nonmember` is restricted to ground instances. This is sensible intuitively. There are arbitrarily many elements that are not elements of a given list, and also arbitrarily many lists not containing a given element. Thus the behavior of Program 7.5 with respect to these queries is largely irrelevant.

The clause order of `nonmember` follows the convention of the recursive clause preceding the fact. The goal order uses the heuristic of putting the test before the recursive goal.

<!-- page 183 -->
We reconstruct the composition of two programs concerned with the subset relation. Program 7.6 defines a relation based on Program 3.12 for `member,` and Program 7.7 defines a relation based on Program 3.19 for `select.` Both consider the occurrences of the elements of one list in a second list. members(Xs,Ys)

Each element of the list Xs is a member of the list Ys.

```prolog
members([XIXs] ,Ys) - member(X,Ys), members(Xs,Ys).
members([ ],Ys).
```

Program 7.6 Testing for a subset

selects(Xs,Ys) -

The list Xs is a subset of the list Ys.

```prolog
                                     selects(Xs,Ysl)
selects([XIXs],Ys) - select(X,Ys,Ysl),
selects([ I ,Ys)
select(X,Ys,Zs) - See Program 3.19.
```

Program 7.7 Testing for a subset

Program 7.6 defining `members (Xs,Ys)` ignores the multiplicity of elements in the lists. For example, `members ([b, b] , [a, b, cl)` is in the meaning of the program. There are two occurrences of `b` in the first list, but only one in the second.

Program 7.6 is also restrictive with respect to termination. If either the first or the second argument of a `members` query is an incomplete list, the program will not terminate. The second argument must be a complete list because of the call to `member,` while the first argument must also be complete, since that is providing the recursive control. The query `members (Xs, [1 ,2,3])?` asking for subsets of a given set does not terminate. Since multiple copies of elements are allowed in Xs, there are an infinite number of solutions, and hence the query should not terminate.

Both these limitations are avoided by Program 7.7. The revised relation `is selects (Xs,Ys).` Goals in the meaning of Program 7.7 have at most as many copies of an element in the first list as appear in the second. Related to this property, Program 7.7 terminates whenever the second argument is a complete list. A query such as `selects(Xs, [a,b,c])` has as solution all the subsets of a given set.

<!-- page 184 -->
We now consider a different example: translating a list of English words, word for word, into a list of French words. The relation is `trans-` `late(Words,Mots),` where `Words` is a list of English words and `Mots` the corresponding list of French words. Program 7.8 performs the transtranslate(Words,Mots) -

Mots is a list of French words that is the

translation of the list of English words Words.

```prolog
tx-anslate([WordlWords] [Mot Mots]) -
    dict(Word,Mot), translate(Words,Mots)
translate([ ],[ J).
dïct(the,le)
                       dict(dog,chien)
dïct(chases,chasso)
                       dict(cat,chat)
```

Program 7.8

Translating word for word

lation. It assumes a dictionary of pairs of corresponding English and French words, the relation scheme being `dict(Word,Mot).` The translation is very naive, ignoring issues of number, gender, subject-verb agreement, and so on. Its range is solving a query such as trans-

```prolog
late([the,dog,chases,the,cat]),X)? with solution
                                                      X=[le,chien,
```

`chasse , le , chat].` This program can be used in multiple ways. English sentences can be translated to French, French ones to English, or two sentences can be checked to see if they are correct mutual translations.

Program 7.8 is a typical program performing mapping, that is, converting one list to another by applying some function to each element of the list. The clause order has the recursive rule(s) first, and the goal order calls `dict` first, so as not to be left recursive.

We conclude this section with `a` discussion of the use of data structures in Prolog programs. Data structures are handled somewhat differently in Prolog than in conventional programming languages. Rather than having a global structure, all parts of which are accessible, the programmer specifies logical relations between various substructures of the data.

Taking a more procedural view, in order to build and modify structures, the Prolog programmer must pass the necessary fields of the structure to subprocedures. These fields are used and/or acquire values during the computation. Assignment of values to the structures happens via unification.

<!-- page 185 -->
Let us look more closely at a generic example - producing a single output from some given input. Examples are the standard use of `ap-` `pend,` joining two lists together to get a third, and using Program 7.8 to translate a list of English words into French. The computation proceeds recursively. The initial call instantiates the output to be an incomplete list [X I Xs]. The head X is instantiated by the call to the procedure, often in unification with the head of the clause. The tail Xs is progressively instantiated while solving the recursive call. The structure becomes fully instantiated with the solution of the base case and the termination of the computation.

Consider appending the list Ic, `d]` to the list

`[a, b],` as illustrated in Figure 4.3. The output `Ls=[a,b,c,d]` is constructed in stages, as `Ls=[alZs], Zs=[bZs1],` and finally `Zsl=[c,d],` when the base fact of `append` is used. Each recursive call partially instantiates the originally incomplete list. Note that the recursive calls to `append` do not have access to the list being computed. This is a top-down construction of recursive structures and is typical of programming in Prolog.

The top-down construction of recursive data structures has one limitation. Pieces of the global data structure cannot be referred to deeper in the computation. This is illustrated in a program for the relation `no_` `doubles (XXs,Xs),` which is true if Xs is a list of all the elements appearing in the list `XXs` with all duplicates removed.

Consider trying to compose `no_doubles` top-down. The head of the recursive clause will be

```prolog
no_doubles([XIXs],
                     .
                      . .) -
```

where we need to fill iii the blank. The blank is filled by calling `no_` `doubles` recursively on Xs with output `Ys` and integrating Ys with X. If X has not appeared in the output so far, then it should be added, and the blank will be [XYs]. If X has appeared, then it should not be added and the blank is Ys. This cannot be easily said. There is no way of knowing what the output is so far.

A program for `no_doubles` can be composed by thinking differently about the problem. Instead of deternrniing whether an element has already appeared in the output, we can determine whether it will appear. Each element X is checked to see if it appears again in the tail of the list Xs. If X appears, then the result is Ys, the output of the recursive call to `no_doubles.` If X does not appear, then it is added to the recursive result. This version of `no_doubles` is given as Program 7.9. It uses Program 7.5

```prolog
for nonmember.
```

<!-- page 186 -->
A problem with Program 7.9 is that the list without duplicates may not have the elements in the desired order. For example, `no_doubles ([a, b,` `c , b] , Xs)?` has the solution `Xs= [a, c , b],` where the solution `Xs= [a, b, c]` no_doubles (Xs, Ys)

Ys is the list obtained by removing

duplicate elements from the list Xs.

```prolog
no_doubles([XIXs] ,Ys) -
    mernber(X,Xs), no_doubles(Xs,Ys).
no_doubles([XIXs] ,[XIYs]) -
    nomnember(X,Xs), rio_doubles(Xs,Ys)
no_doubles([ 1,1 J).
nonmember(X,Xs) - See Program 7.5.
```

Program 7.9

Removing duplicates from a list

may be preferred. This latter result is possible if the program is rewritten. Each element is deleted from the remainder of the list as it is found. In terms of Program 7.9, this is done by replacing the two recursive calls by a rule

```prolog
no_doubles([XIXs] , [XIYs]) -
    delete(X,Xs,Xsl), no_doubles(Xsl,Ys).
```

The new program builds the output top-down. However, it is inefficient for large lists, as will be discussed in Chapter 13. Briefly, each call to delete rebuilds the whole structure of the list.

The alternative to building structures top-down is building them bottom-up. A simple example of bottom-up construction of data structures is Program 3.16b for reversing a list:

```prolog
reverse(Xs,Ys) '- reverse(Xs,[ ],Ys).
reverse([XIXs] ,Revs,Ys) - reverse(Xs, [XIRevs] ,Ys).
reverse([ I ,Ys,Ys).
```

An extra argument is added to `reverse/2` and used to accumulate the values of the reversed list as the computation proceeds. This procedure for `reverse` builds the output list bottom-up rather than top-down. In the trace in Figure 7.3 solving the goal `reverse([a,b,c] ,Xs),` the successive values of the middle argument of the calls to `reverse/3`

E ], [a],

```prolog
[b, a], and
```

`[c , b, a]` represent the structure being built.

<!-- page 187 -->
A bottom-up construction of structures allows access to the partial results of the structure during the computation. Consider a relation `nd_` `reverse(Xs ,Ys)` combining the effects of `no.doubles` and `reverse.` The

```prolog
reverse([a,b,c] ,Xs)
  reverse([a,b,c] , E I ,Xs)
    reverse([b,c] , [a] ,Xs)
      reverse([c] , [b,a] ,Xs)
                                  Xs[c,b,a]
        reverse([ I, [c,b,a] ,Xs)
          true
```

Figure 7.3

Tracing a `reverse` computation

nd_reverse(Xs, Ys)

Ys is the reversal of the list obtained by

removing duplicate elements from the list Xs.

```prolog
nd_reverse(Xs ,Ys) - nd_reverse(Xs, [ I ,Ys).
nd_reverse([XIXs] ,Revs,Ys) -
    member(X,Revs), nd_reverse(Xs,Revs,Ys).
nd_reverse([XIXs] ,Revs,Ys) -
    nonmember(X,Revs), nd_reverse(Xs, [XlRevs] ,Ys).
n&reverse([ I ,Ys,Ys).
nonmember(X,Xs) - See Program 7.5.
```

Program 7.10

Reversing with no duplicates

meaning of `nd_reverse` is that `Ys` is a list of elements in Xs in reverse order and with duplicates removed. Analogously to `reverse, nd_reverse` calls `nd_reverse/3` with an extra argument that builds the result bottomup. This argument is checked to see whether a particular element appears, rather than checking the tail of the list as in Program 7.9 for `no_doubles.` The program is given as Program 7.10.

We emphasize the characteristics of bottom-up construction illustrated here. One argument behaves as an accumulator of the final data structure. It is augmented in the recursive call, so that the more complex version is in the body of the clause rather than in its head. This contrasts with top-down construction, where the more complex version of the data structure being built is in the head of the clause. Another argument is used solely for returning the output, namely, the final value of the accumulator. It is instantiated with the satisfaction of the base fact. The argument is explicitly carried unchanged in the recursive call.

<!-- page 188 -->
The tecimique of adding an accumulator to a program can be generalized. It is used in Chapter 8 discussing Prolog programs for arithmetic. Accumulators cari also be viewed as a special case of incomplete data structures, as is discussed in Chapter 15. 7.5.1

Exercise for Section 7.5

(i)

Write Program 7.9 for no_doubles, building the structure bottom-

up

**7.6 Background**

Prolog was envisaged as a first approximation to logic programming, which would be superseded by further research. Its control has always been acknowledged as being limited and naive. An oft-cited slogan, credited to Kowaiski (1979b), is "Algorithm

Logic + Control." The particular control provided in pure Prolog was intended as just one solution on the path to declarative prograniming and intelligent control. Time has shown otherwise. The control of Prolog has proven adequate for a large range of applications, and the language has not only endured but has blossomed.

Nonetheless, logic programming researchers have investigated other forms of control. For example, LOGLISP (Robinson and Sibert, 1982) has breadth-first traversal of the search tree, and IC-Prolog (Clark and Mc- Cabe, 1979) has co-routining. MU-Prolog (Naish, 1986) allows suspension to provide a correct implementation of negation and to prevent the computation from searching infinite branches in certain cases. Wait declarations are generated (Naish, 1985b) that are related to the conditions on termination of Prolog programs given in Section 7.2.

A methodology for systematically constructing simple Prolog programs is given in Deville (1990). Essential to Deville's methods are specifications, a subject touched upon in Section 13.3.

Analysis of Prolog programs, and logic programs more generally, has become a hot topic of research. Most analyses are based on some form of abstract interpretation, a topic beyond the scope of this book. The initial work in Prolog can be found in Mellish (1985), and a view of leading research groups can be found in a special issue of the Journal of Logic Programming (1993).

Extensive work has also appeared recently on analyzing termination of Prolog programs. A starting place for this topic is PlUmer (1990).
