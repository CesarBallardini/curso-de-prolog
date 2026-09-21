# 16 Second-Order Programming

<!-- page 342 -->
Chapters 14 and 15 demonstrate Prolog programming techniques based directly on logic programming. This chapter, in contrast, shows prograrnming techniques that are missing from the basic logic programming model but can nonetheless be incorporated into Prolog by relying on language features outside of first-order logic. These techniques are called second-order, since they talk about sets and their properties rather than about individuals.

The first section introduces predicates that produce sets as solutions. Computing with predicates that produce sets is particularly powerful when combined with programming techniques presented in earlier chapters. The second section gives some applications. The third section looks at lambda expressions and predicate variables, which allow functions and relations to be treated as "first-class" data objects.

<!-- page 343 -->
16.1 All-Solutions Predicates Solving a Prolog query with a program entails finding an instance of the query that is implied by the program. What is involved in finding all instances of a query that are implied by a program? Declaratively, such a query lies outside the logic programming model presented in Chapter 1. lt is a second-order question, since it asks for the set of elements with a certain property. Operationally, it is also outside the pure Prolog computation model. In pure Prolog, all information about a certain branch of the computation is lost on backtracking. This prevents

```prolog
father(terach,abraham).
                         f ather(haran,lot).
f ather(terach,nachor).
                         f ather(haran,milcah).
f ather(terach,haran).
                         father(haran,yiscah).
f ather(abraham,isaac).
male (abraham).
                 male (haran).
                                 female (yiscah).
male (Isaac)
                 male (nachor).
                                 female (milcah).
male (lot)
```

Program 16.1

Sample data

a simple way of using pure Prolog to find the set of all solutions to a query, or even to find how many solutions there are to a given query.

This section discusses predicates that return all instances of a query. We call such predicates all-solutions predicates. Experience has shown that all-solutions predicates are very useful for programming.

A basic all-solutions predicate is f indall(Terrn,Goal,Bag). The predicate is true if and only if Bag unifies with the list of values to which a variable X not occurring in Term or Goal would be bound by successive resatisfaction of call (Goal), X=Term? after systematic replacement of all variables in X by new variables.

Procedurally, f indall(Term,Goal,Bag) creates an empty list L, renames Goal to a goal G, and executes G. If G succeeds, a copy of Term is appended to L, and G is reexecuted. For each successful reexecution, a copy of Term is appended to the list. Eventually, when G fails, Bag is umfled with L. The success or failure of f Indall depends on the success or failure of the unification.

We demonstrate the use of all-solutions predicates using part of the biblical database of Program 1.1, repeated here as Program 16.1.

Consider the task of finding all the children of a particular father. It is natural to envisage a predicate children(X,Kids), where Kids is a list of children of X. It is immediate to define using f indall, namely, children(X,Kids) - f indall(Kid,father(X,Kid) ,Kids). The query children(terach,Xs)? with respect to Program 16.1 produces the answer `Xs =` [abraham,nachor,haran].

<!-- page 344 -->
The query f indall(F,father(F,K),Fs)? with respect to Program 16.1 produces the answer F = [terach,haran,terach,haran,terach, haran, abraham]. It would be useful to conceive of this query as asking for_all ( Goal,Condition)

For all solutions of Goal, Condition is true.

```prolog
for_all(Goal,Coudition) -
    findall(Condition,Goal,Cases), check(Cases).
check([CaselCases])
                     Case, check(Cases)
check([ 1).
```

Program 16.2

Applying set predicates

who is a father and to receive as solution `[terach,haran,abraham].` This answer can be obtained by removing duplicate solutions.

Another interpretation can be made of the query `f indali(F,father` `(F,K) ,Fs)?.` Instead of having a single solution, all fathers, there could be a solution for each child `K.` Thus one solution would be `K=abrahain,` `Fs = [terach];` another would be `K=lot, Fs = [haran];` and so on.

Standard Prolog provides two predicates that distinguish between these two interpretations. The predicate `bagof (Terni ,Goal ,Bag)` is like `f indall` except that alternative solutions are found for the variables in `Goal.` The predicate

```prolog
setof(Terni,Goal,Bag) is a refinement of bagof
```

where the solutions `in Bag` are sorted corresponding to a standard order of terms and duplicates removed. If we want to emphasize that the solution should be conceived of as a set, we refer to all-solutions predicates as set predicates.

Another all-solutions predicate checks whether all solutions to a query satisfy a certain condition. Program 16.2 defines a predicate `f or` `ali (Goal,Condition),` which succeeds when `Condition` is true for all values of `Goal.` It uses the meta-variable facility.

The query `for_all(father(X,C),male(C))?` checks which fathers have only male children. It produces two answers: `X=terach` and X=abra-

```prolog
hain.
```

A simpler, more efficient, but less general version of `for_all` can be written directly using a combination of nondeterminism and negation by failure. The definition is

```prolog
forall(Goal,Condition) - not (Goal, not Condition).
```

It successfully answers a query such as `f orall(father(terach,X),` `male (X))?` but fails to give a solution to the query `f orall(father(X,`

```prolog
C) ,male(C))?.
```

<!-- page 345 -->
find_alLdl (X, Goal,Instances) -

Instances is the multiset of

instances of X for which Goal is true. The multiplicity

of an element is the number of different ways Goal can be

proved with it as an instance of X.

```prolog
f ind_all_di (X ,Goal, Xs) -
    assertaY$instance'('$mark')), Goal,
    asserta('$instance' (X)), fail.
f ind_all_dl (X ,Goal, Xs\Ys) -
    retract('$instance'(X)), reap(X,Xs\Ys),
reap(X,Xs\Ys) -
    X
        '$mark', retract('$instance'(Xl)),
                                         !,
    reap (Xl, Xs\ [X lYs] )
reapY$mark' ,Xs\Xs).
```

Program 16.3

Implementing an all-solutions predicate using difference-

```prolog
lists, assert, and retract
```

We conclude this section by showing how to implement a simple variant of

`f indall.` The discussion serves a dual purpose. It illustrates the style of implementation for all-solutions predicates and gives a utility that will be used in the next section. The predicate `f ind_all_` `dl(X,Goal,Instances)` is true if `Instances` is the bag (multiset) of instances of X, represented as a difference-list, where `Goal` is true.

The definition of `f ind_all_dl` is given as Program 16.3. The program can only be understood operationally. There are two stages to the procedure, as specified by the two clauses for `f ind_all_dl.` The explicit failure in the first clause guarantees that the second will be executed. The first stage finds all solutions to `Goal` using a failure-driven loop, asserting the associated X as it proceeds. The second stage retrieves the solutions.

Asserting `$niark` is essential for nested all-solutions predicates to work correctly, lest one set should "steal" solutions produced by the other allsolutions predicate. Exercise for Section 16.1

(i)

Define the predicate `intersect(Xs,Ys,Zs)` using an all-solutions

<!-- page 346 -->
predicate to compute the intersection Zs of two lists Xs and Ys.

What should happen if the two lists do not intersect? Compare the

code with the recursive definition of intersect.

16.2 Applications of Set Predicates Set predicates are a significant addition to Prolog. Clean solutions are obtained to many problems by using set predicates, especially when other programming techniques, discussed in previous chapters, are incorporated. This section presents three example programs: traversing a graph breadth-first, using the Lee algorithm for finding routes in VLSI circuits, and producing a keyword in context (KWIC) index.

Section 14.2 presents three programs, 14.8, 14.9, and 14.10, for traversing a graph depth-first. We discuss here the equivalent programs for traversing a graph breadth-first.

The basic relation is `comiected(X,Y),` which is true if X and Y are connected. Program 16.4 defines the relation. Breadth-first search is implemented by keeping a queue of nodes waiting to be expanded. The `connected` clause accordingly calls `connected_bfs(Queue,Y),` which is true if Y is in the connected component of the graph represented by the nodes in the `Queue.`

Each call to `connected_bf s` removes the current node from the head of the queue, finds the edges connected to it, and adds them to the tail of the queue. The queue is represented as a difference-list, and the allsolutions predicate `f ind_all_di` is used. The program fails when the queue is empty. Because difference-lists are an incomplete data structure, the test that the queue is empty must be made explicitly. Otherwise the program would not terminate.

Consider the `edge` clauses in Program 16.4, representing the left-hand graph in Figure 14.3. Using them, the query `connected(a,X)?` gives the values `a, b, c, d, e, f, g, j, k, h, i` for X on backtracking, which is a breadthfirst traversal of the graph.

<!-- page 347 -->
Like Program 14.8, Program 16.4 correctly traverses a finite tree or a directed acyclic graph (DAG). If there are cycles in the graph, the program will not terminate. Program 16.5 is an improvement over Program 16.4 in which a list of the nodes visited in the graph is kept. Instead of adding all the successor nodes at the end of the queue, each is checked to see if connected(X,Y) -

Node X is connected to node Y in the DAG defined by

edge/2 facts.

```prolog
connected(X,Y) - enqueue(X,Q\Q,Q1), connected_bfs(Q1,Y).
connected_bfs(Q,Y) - empty(Q),
                              !, fail.
connected_bfs(Q,Y) - dequeue(X,Q,Q1), X=Y.
connected_bfs(Q,Y) -
    dequeue(X,Q,Qi), enqueue_edges(X,Q1,Q2), connected_bfs(Q2,Y).
enqueue_edges(X,Xs\Ys,Xs\Zs) - find_all_dl(N,edge(X,N),Ys\Zs),
empty([ ]\[ 1).
enqueue/3, dequeue/3 - See Program 15.11.
f ind_all_dl(Terrn,Goal ,DList) - See Program 16.3.
```

Data

```prolog
edge (a, b)
             edge(a,c).
                          edge(a,d).
                                        edge (a » e)
                                                     edge (f , i)
edge(c,f).
             edge(c,g).
                          edge (f , h)
                                        edge (e , k)
                                                     edge(d,j).
edge(x,y).
             edge (y , z)
                          edge (z , x)
                                        edge (y , u)
                                                     edge (z , y)
```

Program 16.4

Testing connectivity breadth-first in a DAG

it has been visited before. This is performed by the predicate `filter` in Program 16.5.

Program 16.5 in fact is more powerful than its depth-first equivalent, Program 14.10. Not only will it correctly traverse any finite graph but it will also correctly traverse infinite graphs in which every vertex has finite degree as well. It is useful to summarize what extensions to pure Prolog have been necessary to increase the performance in searching graphs. Pure Prolog correctly searches finite trees and DAGs. Adding negation allows correct searching of finite graphs with cycles, while set predicates are necessary for infinite graphs. This is shown in Figure 16.1.

Calculating the path between two nodes is a little more awkward than for depth-first search. It is necessary to keep with each node in the queue a list of the nodes linking it to the original node. The technique is demonstrated in Program 20.6.

<!-- page 348 -->
The next example combines the power of nondeterministic programming with the use of second-order programming. lt is a program for calculating a minimal cost route between two points in a circuit using the Lee algorithm. connected(X,Y) Node X is connected to node Y in the graph defined by edge/2 facts.

```prolog
connected (X Y)
    enqueue(X,q\Q,Q1), connected_bfs(Q1,Y,[X]).
connected_bfs(Q,Y,Visited)
                          '-
                            ernpty(Q) ,
                                       ,
                                        fail.
connected_bfs(Q,Y,Visited)
                          - dequeue(X,Q,Q1), XY.
connected_bfs(Q,Y,Visïted)
    dequeue(X,Q,Q1)
    findall(N,edge(X,N) ,Edges),
    filter(Edges,Vïsited,Visitedl,Q1,Q2)
    connected_bfs(Q2,Y,Visitedl)
filter([NINs] ,Visited,Visitedl,Q,Ql) -
    member(N,Visited),
                      !
                       ,
                        filter(Ns,Visited,Visitedl,Q,Q1).
filter([NINs] ,Visited,Visitedi,Q,Q2)
    not member(N,Visited),
                          !
                           ,
                            enqueue(N,Q,Q1),
    filter(Ns, [NiVisited] ,Visitedl,Q1,Q2).
filter([ I ,Visited,Visited,q,Q)
empty([ ]\[ 1).
enqueue/3, dequeue/3
                      See Program 15.11.
```

Program 16.5

Testing connectivity breadth-first in a graph

Finite trees and DAGs Pure Prolog Finite graphs Pure Prolog + negation Infinite graphs Pure Prolog -- second order + negation Figure 16.1

<!-- page 349 -->
Power of Prolog for various searching tasks Figure 16.2

The problem of Lee routing for VLSI circuits

The problem is formulated as follows. Given a grid that may have obstacles, find a shortest path between two specified points. Figure 16.2 shows a grid with obstacles. The heavy solid line represents a shortest path between the two points A and B. The shaded rectangles represent the obstacles.

We first formulate the problem in a suitable form for programming. The VLSI circuit is modeled by a grid of points, conveniently assumed to be the upper quadrant of the Cartesian plane. A route is a path between two points in the grid, along horizontal and vertical lines only, subject to the constraints of remaining in the grid and not passing through any obstacles.

<!-- page 350 -->
Points in the plane are represented by their Cartesian coordinates and denoted X-Y. In Figure 16.2, A is 1-1 and B is 5-5. This representation is chosen for readability and utilizes the definition of - as an infix binary operator. Paths are calculated by the program as a list of points from B to A, including both endpoints. In Figure 16.2 the route calculated is [5-5,5-4,5-3,5-2,4-2,3-2,2-2,1-2,1-11, and is marked by the heavy solid line.

The top-level relation computed by the program is `lee_route (A, B,` `Obstacles,Path),` where `Path` is a route (of minimal distance) from point `A` to point `B` in the circuit. `Obstacles` are the obstacles in the grid. The program has two stages. First, successive waves of neighboring grid points are generated, starting from the initial point, until the final point is reached. Second, the path is extracted from the accumulated waves. Let us examine the various components of Program 16.6, the overall program for Lee routing.

Waves are defined inductively. The initial wave is the list [A]. Successive waves are sets of points that neighbor a point in the previous wave and that do not already appear in previous waves. They are illustrated by the lighter solid lines in Figure 16.2.

Wave generation is performed by `waves (B, WavesSoFar ,Obstacles,` `Waves).` The predicate `waves/4` is true if `Waves` is a list of waves to the destination `B` avoiding the obstacles represented by `Obstacles` and `WavesSoFar` is an accumulator containing the waves generated so far in traveling from the source. The predicate terminates when the destination is in the current wave. The recursive clause calls `next _wave/4,` which finds all the appropriate grid points constituting the next wave using the all-solutions predicate `f indal 1.`

Obstacles are assumed to be rectangular blocks. They are represented by the term `obstacle(L,R),` where `L` is the coordinates of the lower left-hand corner and `R` the coordinates of the upper right-hand corner. Exercise (i) at the end of this section requires modifying the program to handle other obstacles.

The predicate `path (A,B,Waves,Path)` finds the path `Path` back from `B` to A through the `Waves` generated in the process. `Path` is built downward, which means the order of the points is from B to A. This order can be changed by using an accumulator in `path.`

Program 16.6 produces no output while computing the Lee route. In practice, the user may like to see the computation in progress. This can be easily done by adding appropriate `write` statements to the procedures

```prolog
next_wave and path.
```

<!-- page 351 -->
lee_route ( Source,Destination, Obstacles,Path) Path is a minimal length path from Source to Destination that does not cross Obstacles.

```prolog
lee_route (A, B ,Obstacles, Path)
    waves(B,[[A] 1 ]] ,Obstacles,Waves),
    path (A ,B , Waves , Path)
```

waves (Destination, WavesSoFar, Obstacles, Waves) - Waves is a list of waves including WavesSoFar (except, perhaps, its last wave) that leads to Destination without crossing Obstacles. waves(B, [Wave Waves] ,Obstacles,Waves) - member(B,Wave),

!. `waves(B,` [Wave ,LastWavelLastWaves] ,Obstacles,Waves) next_wave (Wave, LastWave ,Obstacles, NextWave),

```prolog
waves(B, [NextWave,Wave ,LastWave ILastWaves] ,Obstacles,Waves).
```

next_ wave ( Wave,Last Wave, Obstacles,NextWave) - Next Wave is the set of admissible points from Wave, that is, excluding points from Last Wave, Wave and points under Obstacles.

```prolog
next_wave(Wave ,LastWave ,Obstacles ,NextWave) -
    findall(X,admissible(X,Wave ,LastWave,Obstacles) ,NextWave).
admissible (X ,Wave, LastWave ,Obstacles) -
    adjacent(X,Wave,Obstacles),
    not member(X,LastWave),
    not member(X,Wave).
adjacent (X,Wave ,Obstacles) -
```

member (Xl, Wave)

```prolog
    neighbor(Xl ,X),
    not obstructed(X,Obstacles).
neighbor(Xl-Y,X2-Y) - next_to(X1,X2).
neighbor(X-Yi,X-Y2) - next_to(Yl,Y2).
next_to(X,X1) - Xl is X+l.
next_to(X,X1) - X > O, Xl is Xl.
obstructed (Point ,Obstacles) -
    menber(Obstacle,Obstacles), obstructs(Point,Obstacle).
obstructs(X-Y,obstacle(X-Yl,X2-Y2)) - Yl
                                          Y, Y
                                                 Y2.
obstructs(X-Y,obstacle(XlYl,X-Y2)) - Yl
                                          Y, Y
                                                 Y2.
obstructs(X-Y,obstacle(X1-Y,X2-Y2)) '- Xl
                                          X, X
                                                 X2.
obstructs(X-Y,obstacle(Xl-Yl,X2-Y))
                                     Xl
                                          X, X
                                                 X2.
```

<!-- page 352 -->
Program 16.6 Lee routing path ( Source,Destination, Waves,Path)

Path is a path from Source to Destination going through Waves.

```prolog
path(A,A,Waves,[A]) - L
path(A,B, [Wave IWaves] , [BiPath]) -
    member(Bi ,Wave),
    neighbor (B , Bi)
    !, path(A,B1,Waves,Path).
```

Testing and data

```prolog
test_lee (Naine , Path)
    data(Name,A,B,Dbstacles), lee_route(A,B4Obstacles,Path).
data(test,i-1,5-5, [obstacle(2-3,4-5),obstacle(6-6,8-8)]).
```

Program 16.6

(Continued)

Our final example in this section concerns the keyword in context (KWIC) problem. Again, a simple Prolog program, combining nondeterministic and second-order programming, suffices to solve a complex task.

Finding keywords in context involves searching text for all occurrences of a set of keywords, extracting the contexts in which they appear. We consider here the following variant of the general problem: "Given a list of titles, produce a sorted list of all occurrences of a set of keywords in the titles, together with their context."

Sample input to a program is given in Figure 16.3 together with the expected output. The context is described as a rotation of the title with the end of the title indicated by -. In the example, the keywords are algorithmic, debugging, logic, problem, program, programming, prolog, and solving, all the nontrivial words.

The relation we want to compute is `kwic(Titles,Kwiclitles)` where `Titles` is the list of titles whose keywords are to be extracted, and Kwic- `Titles` is the sorted list of keywords in their contexts. Both the input and output titles are assumed to be given as lists of words. A more general program, as a preliminary step, would convert freer-form input into lists of words and produce prettier output.

<!-- page 353 -->
The program is presented in stages. The basis is a nondeterministic specification of a rotation of a list of words. It has an elegant definition in terms of `append:`

```prolog
Input:
```

**progranmiïng m prolog**

logic for problem solving logic programming algorithmic program debugging

```prolog
Output:
```

algorithmic program debugging -, debuggrrg - algorithmic program, logic for problem solving -, logic programming -, problem solving - logic for, program debugging - algorithmic, programming in prolog -, programming - logic, prolog - prograinnhing in, solving - logic for problem Figure 16.3

Input and output for keyword in context (KWIC) problem

```prolog
rotate(Xs,Ys) - append(As,Bs,Xs), append(Bs,As,Ys).
```

Declaratively, Ys is a rotation of Xs if Xs is composed of `As` followed by

```prolog
Bs, and Ys is Bs followed by As.
```

**The next stage of development involves identifying single words as**

**potential keywords. This is done by isolating the word in the first call**

**to append. Note that the new rule is an instance of the previous one:**

```prolog
rotate(Xs,Ys) -
    append(As,[KeyIBsJ,Xs), append([KeyIBs],As,Ys).
```

**This definition also improves the previous attempt by removing the du-**

**plicate solution when one of the split lists is empty and the other is the**

entire list. The next improvement involves examining a potential keyword more closely. Suppose each keyword `Word` is identified by a fact of the form `keyword (Word).` The solutions to the `rotate` procedure can be filtered so that only words identified as keywords are accepted. The appropriate version is

```prolog
rotate_and_f ilter(Xs,Ys) - append(As, [KeyIBs] ,Xs),
    keyword(Key), append(rKeylBs] ,As,Ys).
```

<!-- page 354 -->
kwìc (Titles,KWTitles) -

KWTitles is a KWIC index of the list of titles Titles. kwic(Titles,KWTitles) -

```prolog
setof(Ys,XsI(rnember(Xs,Tit].es),
rotate_and_f ilter(Xs,Ys)) ,KWTitles).
```

rot ate_and_fiiter(Xs, Ys) -

Ys is a rotation of the list Xs such that

the first word of Ys is significant and -

is inserted after the last word of Xs. rotate_and_filter(Xs,Ys) -

```prolog
append(As, [Key lBs] ,Xs),
not insignificant(Key),
append([KeylBs] [''lAs] ,Ys).
```

Vocabulary of insignificant words insignificant(a).

insignif ïcant (the). insignificant(iri) .

insigriif icant (for). Testing arid data test_kwic(Books,Kwic) -

```prolog
titles(Books,Titles) , kwic(Titles,Kwic)
```

titles(lp, [[logic,for,problem,solving]

[logic, programming]

[algorithmic, program ,debugging],

[programming, in prolog]]).

```prolog
Program 16.7
              Producing a keyword in context (KWIC) index
```

Operationally `rotate_and_filter` considers all keys, filtering out the unwanted alternatives. The goal order is important here to maximize program efficiency.

In Program 16.7, the final version, a complementary view to recognizing keywords is taken. Any word `Word` is a keyword unless otherwise specified by a fact of the form `insignificant(Word).` Further the procedure is augmented to insert the end-of-title mark -, providing the context information. This is done by adding the extra symbol in the second `append` call. Incorporating this discussion yields the clause for `rotate_` `and_f ilter` ni Program 16.7.

<!-- page 355 -->
Finally, a set predicate is used to get all the solutions. Quantification is necessary over all the possible titles. Advantage is derived from the behavior of `setof` in sorting the answers. The complete program is given as Program 16.7, and is an elegant example of the expressive power of Prolog. The test predicate is `test_kwic/2.` Exercises for Section 162

Modify Program 16.6 to handle other obstacles than rectangles.

Adapt Program 16.7 for KWIC so that it extracts keywords from

lines of text.

Modify rotation of a list so that it uses difference-lists.

Write a program to find a minimal spanning tree for a graph.

(y)

Write a program to find the maximum flow in a network design

using the Ford-Fulkerson algorithm.

16.3 Other Second-Order Predicates First-order logic allows quantification over individuals. Second-order logic further allows quantification over predicates. Incorporating this extension into logic programming entails using rules with goals whose predicate names are variables. Predicate names become "first-class" data objects to be manipulated and modified.

A simple example of a second-order relation is the determination of whether all members of a list have a certain property. For simplicity the property is assumed to be described as a unary predicate. Let us define `has_property(Xs,P),` which is true if each element of Xs has some property P. Extending Prolog syntax to allow variable predicate names enables us to define `has_property` as in Figure 16.4. Because `has_` `property` allows variable properties, it is a second-order predicate. An example of its use is testing whether a list of people Xs is all male with a

```prolog
query has_property(Xs,male)?.
```

<!-- page 356 -->
Another second-order predicate is `rnap_list(Xs,P,Ys). Ys is` the map of the list Xs under the predicate P. That is, for each element X of `Xs` there is a corresponding element Y of `Ys` such that P (X , Y) is true. The

```prolog
has_property([XIXsI,P)
                        P(X), has_property(Xs,P).
has_property([ ] ,P).
map_1it([XIXs] ,P, [YIYsI) -
                           P(X,Y) ,
                                   map_list(Xs,P,Ys).
rnap_list(
         E
           I ,P, E I).
```

Figure 16.4 Second-order predicates

order of the elements in Xs is preserved in Ys. We can use `map_list` to rewrite some of the programs of earlier chapters. For example, Program 7.8 mapping English to French words can be expressed as `map_` `list(Words,dict,Mots).` Uke `has_property, map_list` is easily defined using a variable predicate name. The definition is given in Figure 16.4.

Operationally, allowing variable predicate names implies dynamic construction of goals while answering a query. The relation to be computed is not fixed statically when the query is posed but is determined dynamically during the computation.

Some Prologs allow the programmer to use variables for predicate names, and allow the syntax of Figure 16.4. lt is unnecessary to complicate the syntax however. The tools already exist for implementing second-order predicates. One basic relation is necessary, which we call `apply;` it constructs the goal with a variable functor. The predicate `apply` is defined by a set of clauses, one for each functor name and arity. For example, for functor `foo` of ariry `n,` the clause is

```prolog
apply(foo,X1,
               .
                . . ,Xn) - foo(X1, .
                                    . . ,Xn).
```

The two predicates in Figure 16.4 are transformed into Standard Prolog in Program 16.8. Sample definitions of `apply` clauses are given for the examples mentioned in the text.

The predicate `apply` performs structure inspection. The whole collection of `apply` clauses can be generalized by using the structure inspection primitive, `univ.` The general predicate `apply(P,Xs)` applies predicate P to a list of arguments Xs:

```prolog
apply(F,Xs) - Goal =..
                          [FIXs], Goal.
```

<!-- page 357 -->
We can generalize the function to be applied from a predicate name, i.e., an atom, to a term parameterized by variables. An example is substituting for a value in a list. The relation `substitute/4` from Program 9.3 has_property (Xs,P)

Each element in the list Xs has property P.

```prolog
has_property([XIXs] ,P) -
    apply(P,X), has_property(Xs,P).
has_property( E I ,P).
apply(male,X)
                male(X).
```

maplist (Xs,P, Ys)

Each element in the list Xs stands in relation

P to its corresponding element in the list Ys.

```prolog
map_list([XIXs],P,[YIYs]) -
    apply(P,X,Y), map_list(Xs,P,Ys).
map_list([ ],P,[ J).
apply(dict,X,Y) - dict(X,Y).
```

Program 16.8

Second-order predicates in Prolog

can be viewed as an instance of `map_ list` if parameterization is allowed. Namely, `map_list(Xs,substitute(Old,New) ,Ys)` has the same effect in substituting the element `New` for the element `Old` in Xs to get `Ys -` exactly the relation computed by Program 9.3. In order to handle this correctly, the definition of `apply` must be extended a little:

```prolog
apply(P,Xs) -
    P =.. Li, append(Li,Xs,L2), Goal
                                          .. L2, Goal.
```

Using `apply` as part of `map_list` leads to inefficient programs. For example, using `substitute` directly rather than through `map_list` results in far fewer intermediate structures being created, and eases the task of compilation. Hence these second-order predicates are better used in conjunction with a program transformation system that can translate second-order calls to first-order calls at compile-time.

The predicate `apply` can also be used to implement lambda expressions. A lambda expression is one of the form lambda(X1,.. .,X).Expression. If the set of lambda expressions to be used is known in advance, they can be named. For example, the above expression would be replaced by some unique identifier, `f 00` say, and defined by an `apply` clause:

```prolog
apply(foo,X1,
               .
                .
                 - ,Xn)
                        - Expression.
```

<!-- page 358 -->
Although possible both theoretically and pragmatically, the use of lambda expressions and second-order constructs such as `has_property` and `map_list` is not as widespread in Prolog as in functional programming languages like Lisp. We conjecture that this is a combination of cultural bias and the availability of a host of alternative programming techniques. It is possible that the ongoing work on extending the logic prograniniing model with higher-order constructs and integrating it with functional programming will change the picture.

In the meantime, all-solutions predicates seem to be the main and most useful higher-order construct in Prolog.

Exercise for Section 16.3

(i)

Write a program performing beta reduction for lambda expressions.

**16.4 Background**

The discussion of f `indall` uses the description contained in the Standard Prolog document (Scowen, 1991). An excellent discussion of the all-solutions predicates `bagof` and `setof` in Edinburgh Prolog are given in Warren (1982a). Discussions of "rolling your own" set predicates can be found in both O'Keefe (1990) and Ross (1989).

Set predicates are a powerful extension to Prolog. They can be used (inefficiently) to implement negation as failure and meta-logical type predicates (Kahn, 1984). If a goal G has no solutions, which is determined by a predicate such as `f indall,` then `not` G is true. The predicate `var(X)` is implemented by testing whether the goal X=1 ; X=2 has two solutions. Further discussion of such behavior of set predicates and a survey of different implementations of set predicates can be found in Naish (1985a).

<!-- page 359 -->
Further description of the Lee algorithm and the general routing problem for VLSI circuits can be found in textbooks on VLSI, for example, Breuer and Carter (1983). A neat graphic version of Program 16.6 has been written by Dave Broderick.

Recent logic programming research has focused somewhat more on higher-order logic programming. Approaches of note are Lambda-Prolog (Miller and Nadathur, 1986) and HiLog (Chen et al., 1989).

KWIC was posed as a benchmark for high-level programming languages by Penis, and was used to compare several languages. We find the Prolog implementation of it perhaps the most elegant of all.

Our description of lambda expressions is modeled after Warren (1982a). Predicates such as apply and map_list were part of the utilities package at the University of Edinburgh. They were fashionable for a while but fell out of favor because they were not compiled efficiently, and no source-to-source transformation tools were available.
