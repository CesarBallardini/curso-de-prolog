# 13 Program Development

<!-- page 274 -->
Software engineering considerations are as relevant for programming in logic programming languages as in procedural languages. Prolog is no different from any other language in its need for a methodology to build and maintain large programs A good progranirning style is important, as is a good program development methodology. This chapter discusses programming style and layout and program development, and introduces a method called stepwise enhancement for systematic construction of Prolog programs.

13.1 Programming Style and Layout One basic concern in composing the programs in this book has been to make them as declarative as possible to increase program clarity and readability. A program must be considered as a whole. Its readability is determined by its physical layout and by the choice of names appearing in it. This section discusses the guidelines we use when composing programs.

An important influence in making programs easy to read is the naming of the various objects in the program. The choice of all predicate names, variable names, constants, and structures appearing in the program affect readability. The aim is to emphasize the declarative reading of the program.

<!-- page 275 -->
We choose predicate names to be a word (or several words) that names relations between objects in the program rather than describing what the program is doing. Coining a good declarative name for a procedure does not come easily.

The activity of programming is procedural. It is often easier to name procedurally than declaratively (and programs with procedural names usually run faster :-). Once the program works, however, we often revise the predicate names to be declarative. Composing a program is a cyclic activity in which names are constantly being reworked to reflect our improved understanding of our creation, and to enhance readability by us and others.

Mnemonic variable names also have an effect on program readability. A name can be a meaningful word (or words) or a standard variable form such as Xs for lists.

Variables that appear only once in a clause can be handled separately. They are in effect anonymous, and from an implementation viewpoint need not be named. Standard Prolog supports a special syntactic convention, a single underscore, for referring to anonymous variables. Using this convention, Program 3.12 for `member` would be written

```prolog
member(X, [XI_]).
member(X, 1_lYs])
                      member(X,Ys).
```

The advantage of the convention is to highlight the significant variables for unification. The disadvantage is related; the reading of clauses becomes procedural rather than declarative.

We use different syntactic conventions for separating multiple words in variable names and predicate functors. For variables, composite words are run together, each new word starting with a capital letter. Multiple words in predicate names are linked with underscores. Syntactic conventions are a matter of taste, but it is preferable to have a consistent style.

The layout of individual clauses also has an effect on how easily programs can be understood. We have found the most helpful style to be

```prolog
f oo((Arguments))
    bari((Argumentsi)),
    bar2 ((Arguments2)),
    bar((Arguments)).
```

<!-- page 276 -->
The heads of all clauses are aligned, the goals in the body of a clause are indented and occupy a separate line each. A blank line is inserted between procedures, but there is no space between individual clauses of a procedure.

Layout in a book and the typography used are not entirely consistent with actual programs. If all the goals in the body of a clause are short, then have them ori one line. Occasionally we have tables of facts with more than one fact per line.

A program can be self-documenting if sufficient care is taken with these two factors and the program is sufficiently simple. Given the natural aversion of programmers to comments and documentation, this is very desirable.

In practice, code is rarely self-documenting and comments are needed. One important part of the documentation is the relation scheme, which can be presented before the clauses defining that relation, augmented with further explanations if necessary. The explanations used in this book define the relation a procedure computes. It is not always easy to come up with a precise, declarative, natural language description of a relation computed by a logic program. However, the inability to do so usually indicates that the programmer does not fu[ly understand the creation, even if the creation actually works. Hence we encourage the use of the declarative documentation conventions adopted in this book. They are a good means of commurncating to others what a program defines as well as a discipline of thought, enabling programmers to think about and reflect on their own creations.

13.2 Reflections on Program Development Smce programming in pure Prolog is as close to writing specifications as any practical programming language has gotten, one might hope that pure Prolog programs would be bug-free. This, of course, is not the case. Even when axiomatizing one's concepts and algorithms, a wide spectrum of bugs, quite similar to ones found in conventional languages, can be encountered.

<!-- page 277 -->
Stating it differently, for any formalism there are sufficiently complex problems for which there are no self-evidently correct formulations of solutions. The difference between low-level and high-level languages, then, is only the threshold after which simple examination of the program is insufficient to determine its correctness.

There are two schools of thought on what to do on such an occasion. The "verification" school suggests that such complex programs be verified by proving that they behave correctly with respect to an abstract specification. It is not clear how to apply this approach to logic programs, since the distance between the abstract specification and the program is much smaller then in other languages. If the Prolog axiomatization is not self-evident, there is very little hope that the specification, no matter in what language it is written, would be.

One might suggest using full first-order logic as a specification formalism for Prolog. It is the authors' experience that very rarely is a specification in full first-order logic shorter, simpler, or more readable then the simplest Prolog program defining the relation.

Given this situation, there are weaker alternatives. One is to prove that one Prolog program, perhaps more efficient though more complex, is equivalent to a simpler Prolog program, which, though less efficient, could serve as a specification for the first. Another is to prove that a program satisfies some constraint, such as a "loop invariant," which, though not guaranteeing the program's correctness, increases our confidence in it.

In some sense, Prolog programs are executable specifications. The alternative to staring at them, trying to convince ourselves that they are correct, is to execute them, and see if they behave in the way we want. This is the standard testing and debugging activity, carried out in program development fri any other progranmiing language. All the classical methods, approaches, and common wisdom concerning program testing and debugging apply equally well to Prolog.

What is the difference, then, between program development in conventional, even symbolic languages and Prolog?

One answer is that although Prolog programming is "just" programming, there is some improvement in ease of expression and speed of debugging compared to other lower-level formalisms - we hope the reader has already had a glimpse of it.

<!-- page 278 -->
Another answer is that declarative programming clears your mind. Said less dramatically, progranmiing one's ideas in general, and programming in a declarative and high-level language in particular, clarifies one's thoughts and concepts. For experienced Prolog programmers, Prolog is not just a formalism for coding a computer, but also a formalism in which ideas can be expressed and evaluated - a tool for thinking.

A third answer is that the properties of the high-level formalism of logic may eventually lead to practical program development tools that are an order of magnitude more powerful then the tools used today. Examples of such tools are automatic program transformers, partialevaluators, type inference programs, and algorithmic debuggers. The latter are addressed in Section 17.3, where program diagnosis algorithms and their implementation in Prolog are described.

Unfortunately, practical Prolog programming environments incorporating these novel ideas are not yet widely available. In the meantime, a simple tracer, such as explained in Section 17.2, is most of what one can expect. Nevertheless, large and sophisticated Prolog programs can be developed even using the current Prolog environments, perhaps with greater ease than ¡n other available languages.

The current tools and systems do not dictate or support a specific program development methodology. However, as with other symbolic programming languages, rapid prototyping is perhaps the most natural development strategy. In this strategy, one has an evolving, usable prototype of the system in most stages of the development. Development proceeds by either rewriting the prototype program or extending it. Another alternative, or complementary, approach to program development is "think top-down, implement bottom-up." Although the design of a system should be top-down and goal-driven, its implementation proceeds best if done bottom-up. In bottom-up programming each piece of code written can be debugged immediately. Global decisions, such as representation, can be tested in practice on small sections of the system, and cleaned up and made more robust before most of the programming has been done. Also, experience with one subsystem may lead to changes in the design of other subsystems.

<!-- page 279 -->
The size of the chunks of code that should be written and debugged as a whole varies and grows as the experience of the programmer grows. Experienced Prolog programmers can write programs consisting of several pages of code, knowing that what is left after writing is done is mostly simple and mundane debugging. Less experienced programmers might find it hard to grasp the functionality and interaction of more then a few procedures at a time.

We would like to conclude this section with a few moralistic statements. For every programming language, no matter how clean, elegant, and high-level, one can find programmers who will use it to write dirty, contorted, and unreadable programs. Prolog is no exception. However, we feel that for most problems that have an elegant solution, there is an elegant expression of that solution in Prolog. It is a goal of this book to convey both this belief and the tools to realize it in concrete cases, by showing that aesthetics and practicality are not necessarily opposed or conflicting goals. Put even more strongly, elegance is not optional.

13.3 Systematizing Program Construction The pedagogic style of this book is to present well-constructed programs illustrating the important Prolog programming techniques. The examples are explained in sufficient detail so that readers can apply the techniques to construct similar programs to meet their own programming needs. Implicitly, we are saying that Prolog programming is a skill that can be learned by observing good examples and abstracting the principles.

Learning by apprenticeship, observing other programs, is not the only way. As experience with programming in Prolog accumulates, more systematic methods of teaching Prolog programming are emerging. The emergence of systematic methods is analogous to the emergence of structured programniing and stepwise refinement in the early 1970s after sufficient experience had accumulated in writing programs in the computer languages of the 19 SOs and 1960s.

In this section, we sketch a method to develop Prolog programs. The reader is invited to reconstruct for herself how this method could be applied to develop the programs in Parts III and IV of this book. Underlying the method is a desire to provide more structure to Prolog programs so that software components can be reused and large applications can be routinely maintained and extended.

<!-- page 280 -->
Central to the method is identifying the essential flow of control of a program. A program embodying a control flow is called a skeleton. Extra goals and arguments can be attached to a skeleton. The extra goals and arguments are entwined around the central flow of control and perform additional computations. The program containing the extra arguments and goals is called an enhancement of the skeleton. Building an enhancement from a skeleton will be called applying a technique.

For example, consider Program 8.6a for summing a list of numbers, reproduced here:

```prolog
sumlist([XIXs],Sum) - sumlist(Xs,XsSum), Sum is X+XsSum.
sumlist([ 1,0).
```

The control flow embodied ni the `suinlist` program is traversing the list of numbers. The skeleton is obtained by dropping the second argument completely, restricting to a predicate with one argument, and removing goals that only pertain to the second argument. This gives the following program, which should be identifiable as Program 3.11 definrng a list.

```prolog
list([XIXs]) - list(Xs).
list([ 1).
```

The extra argument of the

`sunilist` program calculates the sum of the numbers in the list. This form of calculation is very common and appeared in several of the examples in Chapter 8.

Another enhancement of the `list` program is Program 8.11 calculating the length of a list. There is a clear similarity between the programs for `length` and `sumuist.` Both use a similar technique for calculating a number, in one case the sum of the numbers in the list, in the second the length of the list.

```prolog
length([XIXs],N) - length(Xs,N1), N is N1+1.
length([ 1,0).
```

Multiple techniques can be applied to a skeleton. For example, we can apply both sunirning elements and counting elements in one pass to get

```prolog
the program sum_length:
suni_length([XIXs] ,Sum,N) -
    suxnlist(Xs,XsSuni,N1), Sum is X+XsSum, N is N1+1.
sum_length([ 1,0,0).
```

<!-- page 281 -->
Intuitively, it is straightforward to create the `sum_length` program from the programs for `sumuist` and `length.` The arguments are taken directly and combined to give a new program. We call this operation composition. In Chapter 18, a program for composition is presented.

Another example of a technique is adding a pair of arguments as an accumulator and a final result. The technique is informally described in Section 7.5. Applying the appropriate version of the technique to the `list` skeleton can generate Program 8.6b for `sumlist` or the iterative version of `length,` which is the solution to Exercise 8.3(vii).

Identifying control flows of programs may seem contradictory to the ideal of declarative progranmiing espoused in the previous section. However, at some level programming is a procedural activity, and describing well-written chunks of code is fine. It is our belief that recognizing patterns of programs makes it easier for people to develop good style. Declarativeness is preserved by ensuring wherever possible that each enhancement produced be given a declarative reading.

The progranuning method called stepwise enhancement consists of three steps:

Identify the skeleton program constituting the control flow.

Create enhancements using standard programming techniques.

Compose the separate enhancements to give the final program.

We illustrate stepwise enhancement for a simple example - calculating the union and intersection of two lists of elements. For simplicity we assume that there are no duplicate elements in the two lists and that we do not care about the order of elements in the answer.

A skeleton for this program follows. The appropriate control flow is to traverse the first list, checking whether each element is a member or not of the second list. There will be two cases:

```prolog
skel([XIXs],Ys) - mernber(X,Ys), skel(Xs,Ys).
skel([XIXs],Ys) - nonmember(X,Ys), skel(Xs,Ys).
skel([ ],Ys).
```

<!-- page 282 -->
To calculate the union, we need a third argument, which can be built top-down in the style discussed in Section 7.5. We consider each clause in turn. When an element in the first list is a member of the second list, it is not included in the union. When an element in the first list is not a member of the second list, it is included in the union. When the first list is empty, the union is the second list. The enhancement for union is given as Program 13.1. union(Xs,Ys,Us)

Us is the union of the elements ¡n Xs and Ys. union([XIXs] ,Ys,Us) .- member(X,Ys), union(Xs,Ys,Us). union([XIXs],Ys,[XIUs])

```prolog
nonmember(X,Ys), unïon(Xs,Ys,Us).
```

union([ ],Ys,Ys). Program 13.1

Finding the union of two lists

intersect (Xs, Ys,Is) -

Is is the intersection of the elements in Xs and Ys. intersect([XIX$],Ys,[XIIs]) - mernber(X,Ys), intersect(Xs,Ys,Is). intersect([XIXS],Ys,Is) - nonniember(X,Ys), intersect(Xs,Ys,Is). intersect([ 1,Ys,[ 1). Program 13.2

Finding the intersection of two lists

union_intersect (Xs, Ys, Us,Is)

Us and Is are the union and intersection, respectively, of the

elements in Xs and Ys. union_intersect([XIXs] ,Ys,Us, EXils]) -

```prolog
inernber(X,Ys) , union_intersect(Xs,Ys,Us,Is)
```

union_intersect([XIXs] ,Ys, [XIUs] ,Is)

```prolog
nonniember(X,Ys), union_intersect(Xs,Ys,Us,Is)
```

union_intersect([ ],Ys,Ys,[ 1) Program 13.3

Finding the union and intersection of two lists

The intersection, given as Program 13.2, is determined with a similar technique. We again consider each clause in turn. When an element in the first list is a member of the second list, it is included in the intersection. When an element in the first list is not a member of the second list, it is not included in the intersection. When the first list is empty, so is the intersection.

Calculating both the union and the intersection can be determined in a single traversal of the first list by composing the two enhancements. This program is given as Program 13.3.

<!-- page 283 -->
Developing a program is typically straightforward once the skeleton has been decided. Knowing what skeleton to use is less straightforward and is learned by experience. Experience is necessary for any design task. By splitting up the program development into three steps, however, the design process is simplified and given structure.

A motivation behind giving programs structure, as is done by stepwise enhancement, is to facilitate program maintenance. It is easy to extend a program by adding new techniques to a skeleton, and it is possible to improve programs by changing skeletons while maintaining techniques. Further, the structure makes it easy to explain a program.

Skeletons and techniques can be considered as constituting reusable software components. This will be illustrated in Chapter 17, where the same skeleton meta-interpreter is useful both for program debugging and for expert system shells.

Having raised software engineering issues such as maintainability and reusabiity, we conclude this chapter by examining two other issues that must be addressed if Prolog is to be routinely used for large software projects. The place of specifications should be clarified, and modules are necessary if code is to be developed in pieces.

It is clear from the previous section that we do not advocate using first-order logic as a specification language. Still, it is necessary to have a specification, that is, a document explaining the behavior of a program sufficiently so that the program can be used without the code having to be read. We believe that a specification should be the primary form of documentation and be given for each procedure in a program.

A suggested form for a specification is given in Figure 13.1. It consists of a procedure declaration, effectively giving the name and arity of the predicate; a series of type declarations about the arguments; a relation scheme; and other important information such as modes of use of the predicate and multiplicities of solutions in each mode of use. We discuss each component in turn.

Types are emerging as important in Prolog programs. An untyped language facilitates rapid prototyping and interactive development, but for more systematic projects, imposing types is probably worthwhile.

<!-- page 284 -->
The relation scheme is a precise statement in English that explains the relation computed by the program. All the programs in this book have a relation scheme. It should be stressed that relation schemes must be precise statements. We believe that proving properties of programs will proceed in the way of mathematics, where proofs are given by precise statements in an informal language. procedure p(Tj,T2 .....T) Types:

T1: type I

T2: type 2

T: type n Relation scheme: Modes of use: Multiplicities of' solution: Figure 13.1

Template for a specification

Prolog programs inherit from logic programs the possibility of being multi-use. In practice, multi-use is rare. A specification should state which uses are guaranteed to be correct. That is the purpose of the modes of use component in Figure 13.1. Modes of use are specified by the instantiation state of arguments before and after calls to the predicate.

For example, the most common mode of use of Program 3.15 for append(Xs,Ys,Zs) for concatenating two lists Xs and Ys to produce a list Zs is as follows. Xs and Ys are instantiated at the time of call, whereas Zs is not, and all three arguments are instantiated after the goal succeeds. Calling append/3 with all three arguments instantiated is a different mode of use. A common convention, taken from DEC-10 Prolog is to use + for an instantiated argument, - for an uninstantiated argument, and? for either. The modes for the preceding use of append are append(+, +, ) before the call and append(+, +, +) after the call.

More precise statements can be made by combining modes with types. The mode of use of the current example becomes the following: Before the call the first two arguments are complete lists and the third a variable; after the call all three arguments are complete lists.

Multiplicities are the number of solutions of the predicate, and should be specified for each mode of use of the program. lt is useful to give both the minimum and maximum number of solutions of a predicate. The multiplicities can be used to reason about properties of the program.

<!-- page 285 -->
Modules are primarily needed to allow several people to work on a project. Several programmers should be able to develop separate components of a large system without worrying about undesirable interactions such as conflict of predicate names. What is needed is a mechanism for specifying what is local to a module and which predicates are imported and exported.

Current Prolog systems provide primitive facilities for handling modules. The current systems are either atom-based or predicate-based, depending on what is made local to the module. Directives are provided for specifying imports and exports. Experience is growing in using existing module facilities, which will be translated into standards for modules that will ultimately be incorporated into Standard Prolog. The current draft on modules in Standard Prolog is in too much flux to describe here. The user needing modules should consult the relevant Prolog manual. Exercises for Section 13.3

Enhance Program 13.3 to build the list of elements contained in the

first list but not in the second list.

Write a program to solve the following problem. Given a binary tree

T with positive integers as values, build a tree that has the same

structure as T but with every node replaced by the maximum value

in the tree. It can be accomplished with one traversal of the tree.

(Hint: Use Program 3.23 as a skeleton.)

Write a program to calculate the mean and mode of an ordered list

of numbers in one pass of the list.

13.4 Background Commenting on Prolog programming style has become more prevalent in recent Prolog textbooks. There are useful discussions in both Ross (1989) and O'Keefe (1990). The latter book also introduces program schemas, which have parallels with skeletons and techniques.

<!-- page 286 -->
Stepwise enhancement has emerged from ongoing work at Case Western Reserve University, first in the COMPOSERS group and more recently in the ProSE group. Examples of decomposing Prolog programs into skeletons and techniques are given in Sterling and Kirschenbaum (1993) and presented in tutorial form in Deville, Sterling, and Deransart (1991). Underlying theory is given in Power and Sterling (1990) and Kirschenbaum, Sterlmg, and fain (1993). An application of structuring Prolog programs using skeletons and techniques to the inductive inference of Prolog programs can be found in Kirschenbaum and Sterling (1991).

Automatic incorporation of techniques into skeletons via partial evaluation has been described in Lakhotia (1989).

The discussion on specifications for Prolog programs is strongly influenced by Deville (1990).

<!-- page 287 -->
Exercise 13.3(11) was suggested by Giles Kahn. The example is originally due to Bird. Exercise 13.3(iii) emerged through interaction with Marc Kirschenbaum. Solutions to both exercises are given in Deville, Sterling, and Deransart (1991). Leonardo Da Vinci. Study of a Woman 's Hands folded over her Breast. Silverpoint on pink prepared paper, heightened with white. About 1478. Windsor Castle, Royal Library.
