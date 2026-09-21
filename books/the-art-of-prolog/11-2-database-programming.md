# 2 Database Programming

<!-- page 70 -->
There are two basic styles of using logic programs: defining a logical database, and manipulating data structures. This chapter discusses database programming. A logic database contains a set of facts and rules. We show how a set of facts can define relations, as in relational databases. We show how rules can define complex relational queries, as in relational algebra. A logic program composed of a set of facts and rutes of a rather restricted format can express the functionalities associated with relational databases.

2.1 Simple Databases We begin by revising Program 1.1, the biblical database, and its augmentation with rules expressing family relationships. The database itself had four basic predicates, `f ather/2, mother/2, male/i,` and

```prolog
f e-
```

`male/i.` We adopt a convention from database theory and give for each relation a relation scheme that specifies the role that each position in the relation (or argument in the goal) is intended to represent. Relation schemes for the four predicates here are, respectively,

```prolog
f ather(Father,Chilcl), mother(Mother,Child), male(Person), and
```

`female (Person).` The mnemonic names are intended to speak for themselves.

<!-- page 71 -->
Variables are given mnemonic names in rules, but usually X or Y when discussing queries. Multiword names are handled differently for variables and predicates. Each new word ¡n a variable starts with an uppercase letter, for example, `NieceOrNephew,` while words are delimited by underscores for predicate and function names, for example, `schedule_`

```prolog
conf lict.
```

New relations are built from these basic relationships by defining suitable rules. Appropriate relation schemes for the relationships introduced in the previous chapter are

```prolog
                             son(Son,Parent), daughter(Daughter,
Parent),
          parent (Parent ,Child),
                                   and
                                         grandparent(Grandparent,
```

`Grandchild).` From the logical viewpoint, it is unimportant which relationships are defined by facts and which by rules. For example, if the available database consisted of `parent, male` and `female` facts, the rules defining `son` and `grandparent` are still correct. New rules must be written for the relationships no longer defined by facts, namely, `father` and `mother.` Suitable rules are

```prolog
father (Dad, Child) - parent(Dad, Child), male(Dad).
mother (Mum, Child) - parent(Mum, Child), f emale(Mum).
```

Interesting rules can be obtained by making relationships explicit that are present in the database only implicitly. For example, since we know the father and mother of a child, we know which couples produced offspring, or to use a Biblical term, procreated. This is not given explicitly in the database, but a simple rule can be written recovering the information.

```prolog
The relation scheme is procreated(Man,Woman).
procreated(Man,Woman) -
  father (Man,Child), mother(Woman,Child).
```

This reads: `"Man` and `Woman` procreated if there is a `Child` such that `Man` is the father of `Child` and `Woman` is the mother of `Child."`

Another example of information that can be recovered from the simple information present is sibling relationships - brothers and sisters. We

```prolog
give a rule for brother (Brother,Sibling).
brother (Brother ,Sib) -
  parent (Parent ,Brother), parent(Parent ,Sib), male(Brother).
```

This reads: `"Brother` is the brother of `Sib` if `Parent` is a parent of both

```prolog
Brother and Sib, and Brother is male."
```

There is a problem with this definition of brother. The query `brother` `(X,X)?` is satisfied for any male child X, which is not our understanding of the brother relationship.

<!-- page 72 -->
In order to preclude such cases from the meaning of the program,

```prolog
                                         abraham
                                                   lot.
                                         isaac
                                                 liaran.
                    abraham
                              haran.
                    abraham
                              yiscah.
abraham
          isaac.
abraham
          milcah.
isaac
        lot.
                                         isaac
                                                 yiscah.
                                         haran
                                               4 yiscah.
liaran
        lot.
                    isaac
                            milcah.
                    haran
                            milcah.
                                         mïlcah
                                                  yiscah.
                    lot
                          yiscah.
lot
      milcah.
```

Figure 2.1

Defining inequality

```prolog
uncle (Uncle Person)
    brother(Uncle,Parent), parent(Parent,Person).
sibling(Sibl,Sib2) -
    parent(Parent,Sibl), parent(Parent,Sib2), Sibi
                                                  Sib2.
cousin(Cousini ,Cousin2) -
    parent (Parenti ,Cousini),
    parent (Parent2 ,Cousin2),
    sibling(Parentl,Parent2).
```

Program 2.1

Defining family relationships

we introduce a predicate

(Termi , Term2). It is convenient to write this predicate as an infix operator. Thus Termi

Term2 is true if Terni and Term2 are different. For the present it is restricted to constant terms. lt can be defined, in principle, by a table X

Y for every two different individuals X and Y in the domain of interest. Figure 2.1 gives part of the appropriate table for Program 1.1.

The new brother rule is brother (Brother,Sib)

parent (Parent ,Brother),

parent (Parent ,Sib),

male (Brother)

Brother

Sib.

The more relationships that are present, the easier it is to define complicated

```prolog
relationships.
               Program
                         2.1
                               defines
                                        the
                                             relationships
```

**uncle(Uncle,Person), sibling(Sibl,Sib2), and cousin(Cousinl,**

<!-- page 73 -->
Cousin2). The definition of uncle in Program 2.1 does not define the husband of a sister of a parent to be an uncle. This may or may not be the intended meaning. In general, different cultures define these family relationships differently. In any case, the logic makes clear exactly what the programmer means by these family relationships.

Another relationship implicit in the family database is whether a woman is a mother. This is determined by using the `mother/2` relationship. The new relation scheme is `mother (Woman),` defined by the rule

```prolog
mother(Woman) -
                   mother(Woman,Child).
```

This reads: `"Woman` is a mother if she is the mother of some `Child."` Note that we have used the same predicate name, `mother,` to describe two different `mother` relationships. The `mother` predicate takes a different number of arguments, i.e., has a different arity, in the two cases. In general, the same predicate name denotes a different relation when it has a different arity.

We change examples, lest the example of family relationships become incestuous, and consider describing simple logical circuits. A circuit can be viewed from two perspectives. The first is the topological layout of the physical components usually described in the circuit diagram. The second is the interaction of functional units. Both views are easily accommodated in a logic program. The circuit diagram is represented by a collection of facts, while rules describe the functional components.

Program 2.2 is a database giving a simplified view of the logical andgate drawn in Figure 2.2. The facts are the connections of the particular resistors and transistors comprising the circuit. The relation scheme for resistors is `resistor(Endl,End2)` and for transistors `transis-`

```prolog
tor (Gate ,Source, Drain).
      Power
                               n3o
                               n5o
```

<!-- page 74 -->
Figure 2.2 A logical circuit

```prolog
rosistor(power,nl).
resistor(power,n2).
transistor(n2,ground,nl).
transistor(n3,n4,ri2)
transistor(n5,ground,n4).
```

inverter(Input,Output) -

Output is the inversion of Input.

```prolog
inverter(Input ,Output) -
    transistor(Input ,ground,Uutput),
    resistor (power ,Output).
```

nand_gate(Inputl,Input2,Output) -

Output is the logical nand of Inputi and Input2.

```prolog
nand_gate(Inputl , Input2,Uutput)
    transïstor(Inputl ,X,Output),
    transistor(Input2 ,ground,X),
    resistor (power ,Output).
```

and_gate(Inputl,Iriput2,Output) -

Output is the logical and of Inputi and Iriput2.

```prolog
and_gate(Inputl ,Input2,Output) -
    nand_gate(Inputl ,Iriput2,X),
    inverter (X ,Output).
```

Program 2.2 A circuit for a logical and-gate

The program demonstrates the style of commenting of logic programs we will follow throughout the book. Each interesting procedure is preceded by a relation scheme for the procedure, shown in italic font, and by English text defining the relation. We recommend this style of commenting, which emphasizes the declarative reading of programs, for Prolog programs as well.

Particular configurations of resistors and transistors fulfill roles captured via rules defining the functional components of the circuit. The circuit describes an and-gate, which takes two input signals and produces as output the logical and of these signals. One way of building an and-gate, and how this circuit is composed, is to connect a nand-gate with an inverter. Relation schemes for these three components are `and_`

```prolog
gate(Inputl,Input2,Output),
                                 nand_gate(Inputl,Input2,Output),
and inverter(Input ,Output).
```

<!-- page 75 -->
To appreciate Program 2.2, let us read the inverter rule. This states that an inverter is built up from a transistor with the source connected to the ground, and a resistor with one end connected to the power source. The gate of the transistor is the input to the inverter, while the free end of the resistor must be connected to the dram of the transistor, which forms the output of the inverter. Sharing of variables is used to insist on the common connection.

Consider the query `and_gate(Inl , 1n2 ,Out)?` to Program 2.2. It has the solution `{Ini=n3, 1n2=n5 , Out=nl}.` This solution confirms that the circuit described by the facts is an and-gate, and indicates the inputs and output.

2.1.1

Exercises for Section 2.1

Modify the rule for `brother` on page 21 to give a rule for `sister,`

the rule for `uncle` in Program 2.1 to give a rule for `niece,` and

the rule for `sibling` in Program 2.1 so that it only recognizes full

siblings, i.e., those that have the same mother and father.

Using a predicate `married_couple(Wife,Husband),` define the rela-

```prolog
tionships mother_in_law, brother_in_law, and son_in_law.
```

Describe the layout of objects in Figiire 2.3 with facts using the

predicates

```prolog
           left_of(Objectl,Object2)
                                       and above(Objecti3Ob-
ject2). Define predicates right_of (Objectl,Object2) and below
```

`(Obj ect 1. .Obj ect2)` in terms of `left_of` and `above,` respectively.

Figure 2.3

<!-- page 76 -->
Still-life objects 22 Structured Data and Data Abstraction A limitation of Program 2.2 for describing the and-gate is the treatment of the circuit as a black box. There is no indication of the structure of the circuit in the answer to the `and_gate` query, even though the structure has been implicitly used in finding the answer. The rules tell us that the circuit represents an and-gate, but the structure of the and-gate is present only implicitly. We remedy this by adding an extra argument to each of the goals in the database. For uniformity, the extra argument becomes the first argument. The base facts simply acquire an identifier. Proceeding from left to right in the diagram of Figure 2.2, we label the resistors `rl` and `r2,` and the transistors `ti, t2,` and `t3.`

Names of the functional components should reflect their structure. An inverter is composed of a transistor and a resistor. To represent this, we need structured data. The technique is to use a compound term, `inv(T,R),` where T and `R` are the respective names of the inverter's component transistor and resistor. Analogously, the name of a nand-gate will be `nand(T1,T2,R),` where `Ti, T2,` and `R` name the two transistors and resistor that comprise a nand-gate. Finally, an and-gate can be named in terms of an inverter and a nand-gate. The modified code containing the names appears in Program 2.3.

```prolog
  The query and_gate(G,Inl,1n2,Out)? has solution {G=and(nand(t2,
t3,r2) ,inv(ti,rl)) ,In1=n3,In2n5,Out=n1}. Ini, 1n2, and Out have
```

their previous values. The complicated structure for `G` reflects accurately the functional composition of the and-gate.

Structuring data is important in progranmìing in general and in logic programming in particular. It is used to organize data in a meaningful way. Rules can be written more abstractly, ignoring irrelevant details. More modular programs can be achieved this way, because a change of data representation need not mean a change in the whole program, as shown by the following example.

Consider the following two ways of representing a fact about a lecture course on complexity given on Monday from 9 to 11 by David Harel in the Feinberg building, room A:

```prolog
course(complexity,monday,9,li,david,harel,feinberg,a).
```

<!-- page 77 -->
and resistor (R,Nodel,Node2) -

R is a resistor between Nodel and Node2.

```prolog
resistor(rl,power,nl).
resistor(r2,power,n2).
```

transistor ( T,Gate,Source,D rain) *

T is a transistor whose gate is Gate,

source is Source, and drain is Drain.

```prolog
transistor(tl,n2,ground,ni).
transistor(t2,n3,n4,n2).
transistor(t3,n5,ground,n4).
```

inverter(I,Input,Output) -

I is an inverter that inverts In put to Output.

```prolog
inverter(inv(T,R) ,Input,Output) -
    transistor(T, Input ,ground,Output),
    resistor(R,power,Output).
```

nand_g ate (Nand,Inputl ,Input2, Output) -

Nand is a gate forming the logical nand, Output,

of Inputi and Input2.

```prolog
nand_gate(nand(Tl ,T2 ,R) ,Inputl ,Input2,Output) -
    transistor(T1 ,Inputl,X,Output),
    transistor (T2 , Input2 ,ground, X),
    resistor(R,power,Output).
```

and_gate(And,Inputl,Input2,Output)

And is a gate forming the logical and, Output,

of Inputi and Input2.

```prolog
and_gate(and(N,I),Inputi,Input2,Output) -
    nan&gate(N, Input i, Input2 ,X),
    inverter(I ,X,Output).
```

Program 2.3

<!-- page 78 -->
The circuit database with names

```prolog
course(complexity,time(monday,9,11) ,lecturer(david,harel),
    location(feinberg,a)).
```

The first fact represents course as a relation between eight items - a course name, a day, a starting hour, a finishing hour, a lecturer's first name, a lecturer's surname, a building, and a room. The second fact makes course a relation between four items - a name, a time, a lecturer, and a location with further qualification. The time is composed of a day, a starting time, and a finishing time; lecturers have a first name and a surname; and locations are specified by a building and a room. The second fact reflects more elegantly the relations that hold.

The four-argument version of course enables more concise rules to be written by abstracting the details that are irrelevant to the query. Program 2.4 contains examples. The occupied rule assumes a predicate less than or equal, represented as a binary infix operator

.

Rules not using the particular values of a structured argument need not "know" how the argument is structured. For example, the rules for `duration` and teaches represent time explicitly as time (Day »Start, `Finish) because the Day or` Start or Finish times of the course are desired. In contrast, the rule for lecturer does not. This leads to greater modularity, because the representation of time can be changed without affecting the rules that do not inspect it.

We offer no definitive advice on when to use structured data. Not using structured data allows a uniform representation where all the data are simple. The advantages of structured data are compactness of representation, which more accurately reflects our perspective of a situation, and

```prolog
lecturer (Lecturer ,Course)
    course (Course,Time,Lecturer,Location)
duration(Courso ,Length) -
    course(Course,time(Day,Start,Finish),Lecturer,Location),
    plus (Start, Length ,Finish).
teaches (Lecturer ,Day) -
    course(Course,time(Day,Start,Finish) ,Lecturer,Locatïon).
occupied(Room,Day,Time) -
    course(Course,time(Day,Start,Finish),Lecturer,Room),
    Start
            Time, Time
                         Finish.
```

Program 2.4

<!-- page 79 -->
Course rules modularity. We can relate the discussion to conventional programming languages. Facts are the counterpart of tables, while structured data correspond to records with aggregate fields.

We believe that the appearance of a program is important, particularly when attempting difficult problems. A good structuring of data can make a difference when programming complex problems.

Some of the rules in Program 2.4 are recovering relations between two individuals, binai-y relations, from the single, more complicated one. All the course information could have been written in terms of binary relations as follows:

```prolog
day (complexity, monday).
start_time (complexity, 9).
f inish_time(cornplexity, 11).
lecturer(complexity,harel).
building(complexity,feinberg).
room(complexity, a).
```

Rules would then be expressed differently, reverting to the previous style of making implicit connections explicit. For example,

```prolog
teaches(Lecturer,Day) -
     lecturer (Course ,Lecturer), day(Course ,Day).
```

2.2.1

Exercises for Section 2.2

Add rules defining the relations

```prolog
                                  location(Course,Building),
busy (Lecturer ,Time), and cannot_meet (Lecturerl ,Lecturer2).
```

Test with your own course facts.

Possibly using relations from Exercise (i), define the relation sched-

```prolog
ule_conflict (Time ,Place ,Coursel ,Course2).
```

Write a program to check if a student has met the requirements for

a college degree. Facts will be used to represent the courses that the

student has taken and the grades obtained, and rules will be used

to enforce the college requirements.

Design a small database for an application of your own choice. Use

a single predicate to express the information, and invent suitable

```prolog
rules.
```

<!-- page 80 -->
2.3 Recursive Rules The rules described so far define new relationships in terms of existing ones. An interesting extension is recursive definitions of relationships that define relationships in terms of themselves. One way of viewing recursive rules is as generalization of a set of nonrecursive rules.

Consider a series of rules defining ancestors - grandparents, greatgrandparents, etc:

```prolog
grandparent (Ancestor, Descendant) -
    parent (Ancestor,Person), parent(Person,Descendant).
greatgrandparent (Ancestor, Descendant) -
    parent (Ancestor,Person), grandparent(Person,Descendant).
greatgreatgrandparent (Ancestor ,Descendant) -
    parent (Ancestor,Person), greatgrandparent(Person,
                                                   Descendant).
```

A clear pattern can be seen, which can be expressed in a rule defining the

```prolog
relationship ancestor (Ancestor ,Descendant):
ancestor (Ancestor, Descendant) -
    parent (Ancestor,Person), ancestor(Person,Descendant).
```

This rule is a generalization of the previous rules.

A logic program for `ancestor` also requires a nonrecursive rule, the choice of which affects the meaning of the program. If the fact `ances-` `tor (X, X)` is used, defining the `ancestor` relationship to be reflexive, people will be considered to be their own ancestors. This is not the intuitive meaning of ancestor. Program 2.5 is a logic program defining the `ances-` `tor` relationship, where parents are considered ancestors.

ancestor(Ancestor,Descendant)

Ancestor is an ancestor of Descendant. ancestor(Ancestor,Descendaxit) -

parent (Ancestor , Descendant) ancestor(Ancestor,Descendant) -

```prolog
parent(Ancestor,Person), ancestor(Person,Descendant).
```

Program 2.5

<!-- page 81 -->
The `ancestor` relationship

The `ancestor` relationship is the transitive closure of the `parent` relationship. In general, finìding the transitive closure of a relationship is easily done in a logic program by using a recursive rule.

Program 2.5 defining `ancestor` is an example of a linear recursive program. A program is linear recursive if there is only one recursive goal in the body of the recursive clause. The linearity can be easily seen from considering the complexity of proof trees solving `ancestor` queries. A proof tree establishing that two individuals are n generations apart given Program 2.5 and a collection of `parent` facts has 2 . n nodes.

There are many alternative ways of defining ancestors. The declarative content of the recursive rule in Program 2.5 is that `Ancestor` is an ancestor of `Descendant` if `Ancestor` is a parent of an ancestor of `Descendant.` Another way of expressing the recursion is by observing that `Ancestor` would be an ancestor of `Descendant` if `Ancestor` is an ancestor of a parent of `Descendant.` The relevant rule is

```prolog
ancestor(Ancestor,Descendant) -
    ancestor(Ancestor,Person), parent(Person,Descendant).
```

Another version of defining ancestors is not linear recursive. A program identical in meaning to Program 2.5 but with two recursive goals in the recursive clause is

```prolog
ancestor(Ancestor,Descendant) -
    parent (Ancestor,Descendant).
ancestor(Ancestor,Descendant) -
    ancestor(Ancestor,Person), ancestor(Person,Descendant).
```

Consider the problem of testing connectivity in a directed graph. A directed graph can be represented as a logic program by a collection of facts. A fact `edge(Nodel,Node2)` is present in the program if there is an edge from `Nodel` to `Node2` in the graph. Figure 2.4 shows a graph; Program 2.6 is its description as a logic program.

<!-- page 82 -->
Two nodes are connected if there is a series of edges that can be traversed to get from the first node to the second. That is, the relation `con-` `nected(Nodel,Node2),` which is true if `Nodel` and `Node2` are connected, is the transitive closure of the `edge` relation. For example, a and e are connected in the graph in Figure 2.4, but b and f are not. Program 2.7 defines the relation. The meaning of the program is the set of goals con- Figure 2.4 A simple graph

```prolog
edge(a,b).
             edge(a,c),
                          edge(b,d).
edge(c,d).
             edge(d,e).
                          edge(f,g).
```

Program 2.6 A directed graph

connected(Nodel,Node2) -

Nodel is connected to Node2 in the

graph defined by the edge/2 relation.

```prolog
                                          connected(Link,Node2)
cormected(Node,Node).
connected(Nodel,Node2) -
                         edge(Nodel,Link),
```

Program 2.7 The transitive closure of the `edge` relation

`nected(X,Y),` where X and Y are connected. Note that `connected` is a transitive reflexive relation because of the choice of base fact.

2.3.1

Exercises for Section 2.3

(i)

A stack of blocks can be described by a collection of facts `on`

`(Blockl,Block2),` which is true if `Blocki` is on `Block2.` Define a

**predicate above(Blockl,Block2) that is true if Blocki is above**

<!-- page 83 -->
`Block2` in the stack. (Hint: `above` is the transitive closure of `on.)`

Add recursive rules for left_of and above from Exercise 2.1(iii) on

p. 34. Define higher(Objectl,Object2),whichis true if Objecti is

on a line higher than Object2 in Figure 2.3. For example, the bicycle

is higher than the fish in the figure.

How many nodes are there in the proof tree for connected(a,e)

using Programs 2.6 and 2.7? In general, using Program 2.6 and a

collection of edge/2 facts, how many nodes are there in a proof tree

establishing that two nodes are connected by a path containing n

intermediate nodes?

2.4 Logic Programs and the Relational Database Model Logic programs can be viewed as a powerful extension to the relational database model, the extra power coming from the ability to specify rules. Many of the concepts mtroduced have meaningful analogues in terms of databases. The converse is also true. The basic operations of the relational algebra are easily expressed within logic programming.

Procedures composed solely of facts correspond to relations, the arity of the relation being the arity of the procedure. Five basic operations define the relational algebra: union, set difference, Cartesian product, projection, and selection. We show how each is translated into a logic program.

The union operation creates a relation of arity n from two relations r and s, both of arity n. The new relation, denoted here r_union_s, is the union of r and s. It is defined directly as a logic program by two rules: r_union_s(X1,

. .

**. ,X) -**

r(Xi, .

. . r_union_s(X1,

**. . . ,X) -**

s(Xi,

.

**. . ,X).**

Set difference involves negation. We assume a predicate not. Intuitively, a goal not G is true with respect to a program P if G is not a logical consequence of P. Negation in logic programs is discussed in Chapter 5, where limitations of the intuitive definition are indicated. The definition is correct, however, if we deal only with ground facts, as is the case with relational databases.

<!-- page 84 -->
The definition of r_diff_s of arity n, where r and s are of arity n, is

```prolog
r_diff_s(Xi,
              .
               . ,X) -
                         r(Xi, .
                                . . ,X,), not
                                              s(Xi,
                                                   .
                                                     .
                                                       ,X,).
```

Cartesian product can be defined in a single rule. If r is a relation of arity m, and s is a relation of arity n, then r_x_s is a relation of arity m + n defined by

```prolog
r_x_s(Xi,
          .
            .
              ,X,Xji, .
                          .
                           . ,Xm)
      r(Xi,
           .
             .
              .
                      s(Xm+i,
                              .
                               .
                                . ,Xmn).
```

Projection involves forming a new relation comprising'only some of the attributes of an existing relation. This is straightforward for any particular case. For example, the projection r13 selecting the first and third arguments of a relation r of arity 3 is

```prolog
r13(Xi,X3) -
                r(Xì1X2,X3).
```

Selection is similarly straightforward for any particular case. Consider a relation consisting of tuples whose third components are greater than their second, and a relation where the first component is Smith or Jones. In both cases a relation r of arity 3 is used to illustrate. The first example creates a relation rl:

```prolog
rl(X1,X2,X3) -
                  r(Xj,X2,X3) ,X3
                                 >
                                   X2.
```

The second example creates a relation r2, which requires a disjunctive relationship, smith_or_j ones: r2(Xi,X2,X3) -

```prolog
                r(Xj,X2,X3), smith_or_jones(Xj).
smith_or_j ones (smith).
smith_or_j ones (jones).
```

Some of the derived operations of the relational algebra are more closely related to the constructs of logic programming We mention two, intersection and the natural join. If r and s are relations of arity n, the intersection, r_meet_s is also of arity n and is defined in a single rule.

```prolog
r_meet_s(Xi,
              .
               .
                . ,X) -
                         r(X1,
                               .
                                .
                                 . ,X), s(Xi,
                                               .
                                                .
                                                 . ,X).
```

<!-- page 85 -->
A natural join is precisely a conjunctive query with shared variables. 2.5 Background Readers interested in pursuing the connection between logic programming and database theory are referred to the many papers that have been written on the subject. A good starting place is the review paper by Gallaire et al. (1984). There are earlier papers on logic and databases in Gallaire and Minker (1978). Another interesting book is about the implementation of a database query language in Prolog (Li, 1984). Our discussion of relational databases follows Uliman (1982). Another good account of relational databases can be found in Maier (1983).

In the seven years between the appearance of the first edition and the second edition of this book, the database community has accepted logic programs as extensions of relational databases. The term used for a database extended with logical rules is logic database or deductive database. There is now a wealth of material about logic databases. The rewritten version of Ullman's text (1989) discusses logic databases and gives pointers to the important literature.

Perhaps the major difference between logic databases as taught from a database perspective and the view presented here is the way of evaluating queries. Here we implicitly assume that the interpreter from Figure 4.2 will be used, a top-down approach. The database community prefers a bottom-up evaluation mechanism. Various bottom-up strategies for answering a query with respect to a logic database are given in Uliman (1989).

In general, an n-ary relation can be replaced by n + i binary relations, as shown by Kowalski (1979a). If one of the arguments forms a key for the relation, as does the course name in the example in Section 2.2, n binary relations suffice.

The addition of an extra argument to each predicate in the circuit, as discussed at the beginning of Section 2.2, is an example of an enhancement of a logic program. The technique of developing programs by enhancement is of growing importance. More will be said about this in Chapter 13.
