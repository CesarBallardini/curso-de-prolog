# Aggregation
In logic programming it is often the case that one wants to compare the various solutions to a single goal with each other. For example, we may have an employee relation that stores employee names, their departments and salaries, and we want to find, say, the total salary of all the employees. This requires querying the employee relation to retrieve the salaries and then combining all the solutions to find their sum.

Prolog provides several general predicates, the so-called all-solutions predicates, to allow a programmer to do such things. The all-solution predicates accumulate all the solutions to a particular goal into a list. The programmer can then use normal recursive programs to compute the desired function over that list, for example, sum of the elements.

To be concrete, to find the total of the salaries, a prolog programmer could write:

```prolog
:- bagof(Sal,(Name,Dept)^employee(Name,Dept,Sal),Salaries),
   listsum(Salaries,MaxSal).
```
The predicate `listsum/2` simply takes a list of numbers and returns their sum. The all-solutions predicate `bagof/2` takes a template, a goal, and returns a list of instantiations of the template, one for each solution to the goal. In this case, the template is simply the variable `Sal`, so we will get back a list of salaries. The goal is:

```prolog
(Name,Dept)^employee(Name,Dept,Sal)
```
The variables in the term before the `^` symbol indicate the *existential* variables in the goal. The values of `Sal` in successful solutions to the goal are accumulated into a single list, regardless of the values of the existential variables. In this case, we want all salary values, regardless of the employee's name or department. Another possibly interesting alternative query would be:

```prolog
:- bagof(Sal,(Name)^employee(Name,Dept,Sal),Salaries),
   maximum(Salaries,TotalSals).
```
This query, without the variable `Dept` being existentially quantified, groups together solutions that have the same department, and returns nondeterministically, for each department, the list of salaries for employees in that department. So this is what one would get using a \`\`group by'' query in the database language SQL.

The `bagof/3` all-solutions predicate is used here because we don't want to eliminate duplicate salaries. If two employees have the same salary, we want to add both numbers; we want the sum of salaries, not the sum of *different* salaries.

One computational disadvantage of Prolog's all-solutions predicates is that regardless of the function to be computed over the bag (or set) of solutions, that list must still be created. To accumulate the sum of a set of numbers, it certainly seems inefficient to first construct a list of them and then add them up. Clearly one could just accumulate their sum as they are produced. In XSB if the goal is tabled, the situation is exacerbated, in that the set of solutions is in the table already; building another list of them seems a bit redundant.

XSB, being an extension of Prolog, supports its all-solutions predicates, but it also uses tabling to support several other such predicates, which are described in this chapter.

------------------------------------------------------------------------

- <a href="#node50.html" id="node49.html_tex2html737">Min, Max, Sum, Count, Avg</a>
- <a href="#node51.html" id="node49.html_tex2html738">BagReduce and BagPO</a>
- <a href="#node52.html" id="node49.html_tex2html739">Recursive Aggregation</a>
  - <a href="#node53.html" id="node49.html_tex2html740">Shortest Path</a>
  - <a href="#node54.html" id="node49.html_tex2html741">Reasoning with Uncertainty: Annotated Logic</a>
  - <a href="#node55.html" id="node49.html_tex2html742">Longest Path</a>
- <a href="#node56.html" id="node49.html_tex2html743">Scheduling Issues</a>
- <a href="#node57.html" id="node49.html_tex2html744">Stratified Aggregation</a>

------------------------------------------------------------------------

# Min, Max, Sum, Count, Avg
In XSB we use HiLog and tables to support aggregation. In HiLog one can manipulate predicates, or the names of sets. So we can construct a set, or bag really, that contains all the salaries in our example of the simple employee relation:

```prolog
:- hilog salaries.
salaries(Sal) :- employee(\_Name,\_Dept,Sal).
```
The symbol `salaries` is the name of a unary predicate that is true of all salaries, or rather is the name of a *bag* of all salaries. It is a bag since it may contain the same salary multiple times. XSB provides a predicate `bagSum` which can be used to sum up the elements in a named bag. So given the definition of the HiLog predicate `salaries/1` above, we can get the sum of all the salaries with:

```prolog
:- bagSum(salaries,TotalSals).
```
The first argument to `bagSum` is the name of a bag, and the second is bound to the sum of the elements in the bag.

We can also do a \`\`group by'' to get total salaries within departments as follows. We define a parameterized predicate, `sals(Dept)`, to be the bag of salaries of employees in department `Dept`, as follows:

```prolog
sals(Dept)(Sal) :- employee(\_Name,Dept,Sal).
```
This rule says that `Sal` is in the bag named `sals(Dept)` if there is an employee with some name who works in department `Dept` and has salary `Sal`.

Now with this definition, we can define a predicate, `deptPayroll/2`, that associates with each department the sum of all the salaries of employees in that department:

```prolog
deptPayroll(Dept,Payroll) :- bagSum(sals(Dept),Payroll).
```
XSB provides analogous aggregate operators, `bagMin/2`, `bagMax/2`, `bagCount/2`, `bagAvg/2`, to compute the minimum, maximum, count, and average, of a bag, respectively.

As an interesting example of aggregation and recursion, consider the following problem. Say our university is considering instituting a policy that guarantees that no supervisor shall make less than anyone he or she supervises. Since they do not want to lower anyone's salary, to initiate such a policy, they will have to give raises to supervisors who make less than one of their employees. And this may cascade up the chain of command. We want to write a program that will calculate how much they will have to spend initially to start this new program. The following program does this:

% inlcude needed predicates\
```prolog
:- import bagMax/2, bagSum/2 from aggregs.
:- hilog maximum, sum, raise.
maximum(X,Y,Z) :- X\>=Y -\> Z=X; Z=Y.
sum(X,Y,Z) :- Z is X+Y.
```
% The total cost is the sum of the raises.\
```prolog
totcost(Cost) :- bagSum(raise,Cost).
```
% A raise is the max of the posible new salaries (own and\
% subordinates' salaries) minus the old salary.\
```prolog
raise(Raise) :-
    bagMax(possNewSal(Emp),NSal),
    emp(Emp,\_,OSal),
    Raise is NSal-OSal.
```
% A possible new salary is either one's old salary or the max of the\
% possible new salaries of one's immediate subordinates.\
```prolog
possNewSal(Emp)(Sal) :- emp(Emp,\_,Sal).
possNewSal(Emp)(Sal) :-
    dept(Dept,Emp), emp(Sub,Dept,\_),
    bagMax(possNewSal(Sub),Sal).
```
% dept(Dept,Mgr): department data\
```prolog
dept(univ,provost).
dept(ceas,deanCEAS).
dept(cs,chairCS).
dept(ee,chairEE).
```
% emp(Name,Dept,Salary):\
```prolog
emp(provost,univ,87000).
emp(deanCEAS,univ,91000).
emp(chairCS,ceas,95000).
emp(chairEE,ceas,93000).
emp(prof1CS,cs,65000).
emp(prof2CS,cs,97000).
emp(prof1EE,ee,90000).
emp(prof2EE,ee,94000).
```
Here is the execution of this program for this data:

\| ?- \[raises\].\
\[Compiling ./raises\]\
% Specialising partially instantiated calls to apply/3\
% Specialising partially instantiated calls to apply/2\
\[raises compiled, cpu time used: 1.669 seconds\]\
\[raises loaded\]\

yes\
\| ?- totcost(C).\

C = 19000;\

no\
\| ?-\

And indeed, it would cost \$19,000 to upgrade everyone's salary appropriately.

We can combine aggregation with dynamic programming (which is actually what is happening to some extent in the previous example) to nice effect.

A variation on the knapsack problem discussed above in the section on dynamic programming uses aggregation to find an optimal knapsack packing. (This example taken most recently from JLP 12(4) 92, Clocksin, Logic Programming specification and exectuion of dynamic-programming problems. He refers to Sedgewick, Algorithms A-W 88.) Recall that in the earlier knapsack problem we were given a set of integers and we try to see if, given a target integer, we can choose a subset of the given integers that sum to the target integer. The version we consider here is a bit more complicated, and perhaps more realistic. Here we have a set of kinds of items; each item has a value and a size (both are integers.) We are given a knapsack of a given capacity and we want to pack the knapsack with the items that maximize the value of the total. We assume that there is an unlimited supply of items of each kind.

This problem can be formulated as follows:

:- import bagMax/2 from aggregs.\
:- hilog maximum.\
maximum(X,Y,Z) :- X\>=Y -\> Z=X; Z=Y.\

:- table cap/2.\
% cap(Size,Cap) if capacity of knapsick of size Size is Cap.\
cap(I,Cap) :- I \>= 0, bagMax(small_cap(I),Cap).\

% small_cap(BigSize)(BigCap) if there is some item with ISize and IVal\
% such that the capacity of a knapsack of size (BigSize-ISize) has\
% capacity (BigCap-Ival).\
small_cap(BigSize)(BigCap) :- \
```prolog
    item(ISize,IVal),
    SmallSize is BigSize-ISize,
    cap(SmallSize,SmallCap),
    BigCap is IVal+SmallCap.
```
% every knapsack (\>=0) has capacity of 0.\
small_cap(BigSize)(0) :- BigSize \>= 0.\

Here the tabling of `cap/2` is not necessary, since the call to `bagMax/2` is tabled automatically.

A simple example of executing this program is:

%Data:\
item(10,18).\
item(8,14).\
item(6,10).\
item(4,6).\
item(2,2).\

\| ?- \[aggreg\].\
\[Compiling ./aggreg\]\
\[aggreg compiled, cpu time used: 0.861 seconds\]\
\[aggreg loaded\]\

yes\
\| ?- cap(48,C).\

C = 86;\

no\
\| ?- cap(49,C).\

C = 86;\

no\
\| ?-\

And we can see that indeed to fill a knapsack of size 48, one should take four of item 10 (for total value 72), and one of item 8 (with value 14), giving us a total value of 86.

Another problem that combines dynamic programming and aggregation is the problem of finding the way to associate a matrix chain product to minimize the cost of computing the product.

:- import bagMin/2 from aggregs.\
:- hilog minimum.\
minimum(X,Y,Z) :- X=\<Y -\> Z=X; Z=Y.\

% mult_costI,J,C) if C is the cost of the cheapest way to compute the\
% product M_I x M\_{I+1} x ... x M_J.\
mult_cost(I,I,0).\
mult_cost(I,J,C) :- I\<J, bagMin(factor(I,J),C).\

% factor(I,J) is true of costs obtained by computing the product of\
% matrices between I and J by factoring the chain at any point between\
% I and J and assuming optimal costs for the two factors.\
factor(I,J)(C) :- \
```prolog
    I1 is I-1,
    J1 is J-1,
    between(I,K,J1),
    mult_cost(I,K,C1),
    K1 is K+1,
    mult_cost(K1,J,C2),
    r(I1,Ri1), r(K,Rk), r(J,Rj),
    C is C1+C2+Ri1\*Rk\*Rj.
```
between(X,X,\_).\
between(X,Y,Z) :- X \< Z, X1 is X+1, between(X1,Y,Z).\

% r(I,N) if N is the number of rows in the I-1st matrix.  (The last is\
% the number of columns in the last matrix.)\
r(0,5).\
r(1,3).\
r(2,6).\
r(3,9).\
r(4,7).\
r(5,2).\

------------------------------------------------------------------------

# BagReduce and BagPO
Actually, XSB provides two basic aggregation operators, `bagReduce/4` and `bagPO/3`, which are used to define all those predicates described in the previous section. We can also use the basic operators to define our own aggregation operators to do specialized things.

The `bagReduce/4` predicate takes a bag name, an operator and its identity, and composes the elements of the bag using the operator. For example, we can use `bagReduce/4` to define `bagSum/2`. First we define the sum operator, which must be a 3-ary HiLog operator:

```prolog
:- hilog sum.
sum(X,Y,Z) :- Z is X + Y.
```
Then we can use this operator in `bagReduce/4` to define `bagSum/2`:

```prolog
bagSum(Bag,Res) :- bagReduce(Bag,Res,sum,0).
```
The `bagReduce/4` predicate intuitively works as follows: It finds the first element of the bag, applies the operator to the identity and that element and stores the result in the table. It then finds the second element in the bag, applies the operator to the element in the table and that second element, and replaces the current element in the table by this new result. It continues this way: for each new element the operator is applied to the current value and the new element and the result replaces the current value. The final value in the table is returned as the result.

As another simple example, we can define `bagMin/2` by:

```prolog
:- hilog minimum.
minimum(X,Y,Min) :- X =\< Y -\> Min = X ; Min = Y.
```
```prolog
bagMin(Bag,Res) :- bagReduce(Bag,Res,minimum,1.0e+38).
```
(assuming that 1.0e+38 is the maximum representable number.)

A slightly more complicated example is the definition of `bagAvg/2`, which requires a more complex operator that must both sum and count the elements of the bag. It can be defined as follows:

```prolog
:- hilog sumcount.
sumcount(\[S\|C\],X,\[S1\|C1\]) :- S1 is S+X, C1 is C+1.
```
```prolog
bagAvg(Bag,Avg) :-
    bagReduce(Bag,\[Sum\|Count\],sumcount,\[0\|0\]),
    Avg is Sum/Count.
```
The `bagPO/3` operator is also a metapredicate in that it takes a predicate as a parameter. It takes a HiLog binary predicate that defines a partial order. Given a bag, it returns nondeterministically all the maximal elements in the bag under the given partial order.

Consider the following example in which we try to find nice ways to explore a park while going from one point to another in it. Say the park has various interesting things to see and paths between them. We'll represent the paths in the park as a directed acyclic graph, with the points of interest as the nodes. (Both the acyclicity and the directedness of the graph might be somewhat unrealistic, but they can both be relaxed.) The goal now is, given a source and a destination node, find all \`\`maximal'' paths from the source to the destination. The idea is that we want to take a more-or-less direct route to our target, but we'd like to see as many points of interest as is reasonable along the way.

The following program will compute the set of such maximal paths.

```prolog
:- import bagPO/3 from aggregs.
:- import member/2,append/3 from basics.
```
% stroll(X,Y,Path) if Path is a way to go from X to Y seeing many things.\
```prolog
stroll(X,Y,Path) :- bagPO(walk(X,Y),BPath,subset), reverse(BPath,Path).
```
% subset(L1,L2) if L1 is a subset of L2.\
```prolog
:- hilog subset.
subset(\[\],\_L).
subset(\[X\|L1\],L2) :- member(X,L2), subset(L1,L2).
```
% L is in walk(X,Y) if L is a (reversed) path from X to Y.\
% (must be tabled because of left-recursion.)\
```prolog
:- table walk(\_,\_)(\_).
walk(X,Y)(\[Y,X\]) :- edge(X,Y).
walk(X,Y)(\[Y\|P\]) :- walk(X,Z)(P), edge(Z,Y).
```
Here `walk(X,Y)` is a parameterized predicate name which represents the set of paths that go from node `X` to node `Y`. Each path is represented as a list of nodes (in reverse order of traversal.) The `bagPO` aggregation takes just the maximal paths, since we want the alternatives that allow us to see as many points of interest as possible. Here is the execution of the program on the data shown.

```prolog
edge(a,b).
edge(b,c).
edge(b,d).
edge(c,d).
edge(d,e).
edge(a,f).
edge(f,g).
edge(g,e).
```
\| ?- \[aggreg\].\
\[aggreg loaded\]\

yes\
\| ?- stroll(a,e,P).\

P = \[a,b,c,d,e\];\

P = \[a,f,g,e\];\

no\
\| ?-\

Some aggregate operations can be implemented using either `bagReduce/4` or `bagPO/3`. `bagMax/2` is a good example. Both of the following definitions are correct:

```prolog
:- hilog maximum.
maximum(X,Y,Z) :- X \>= Y -\> Z = X ; Z = Y.
bagMax(Bag,Max) :- bagReduce(Bag,Max,maximum,-1.0e38).
```

```prolog
:- hilog lt.
lt(X,Y) :- X \< Y.
bagMax(Bag,Max) :- bagPO(Bag,Max,lt).
```
In such cases it is more efficient to use `BagReduce/4` because it can take advantage of the fact that at any point in time, there will be at most one value in the table.

------------------------------------------------------------------------

# Recursive Aggregation
Aggregation interacts in an interesting way with tabling. We've already seen that we can use them both: in the scenic-path example, we needed tabling to compute the paths using left recursion. We also saw an interesting recursive application of aggregation in the salary-raising example. We continue to explore the interaction of tabling, aggregation and recursion in this section by developing a program to compute the shortest paths between nodes in a (positive) weighted graph.

------------------------------------------------------------------------

- <a href="#node53.html" id="node52.html_tex2html778">Shortest Path</a>
- <a href="#node54.html" id="node52.html_tex2html779">Reasoning with Uncertainty: Annotated Logic</a>
- <a href="#node55.html" id="node52.html_tex2html780">Longest Path</a>

------------------------------------------------------------------------

## Shortest Path
To compute the shortest path between two points in a graph, we first define a HiLog predicate `short_path(Source,Target)`, that given two nodes returns short paths from the first to the second. There may be several short paths between two nodes, but we will be sure that one of them must be the shortest path:

```prolog
% There's a short path if there's an edge,
short_path(X,Y)(D) :- edge(X,Y,D).
% or if there is a short path to a predecessor and then an edge.
short_path(X,Y)(D) :-
    bagMin(short_path(X,Z),D1),
    edge(Z,Y,D2),
    D is D1 + D2.
```
The first clause says that there is a short path from `X` to `Y` of length `D` if there is an edge from `X` to `Y` with weight `D`. The second clause says there is a short path from `X` to `Y` of length `D` if we take the minimum of the short paths from `X` to a predecessor (`Z`) of `Y` and we get `D` by adding the distance along the edge to `Y` from the predecessor.

Now to get the shortest path, we simply take the shortest of the short paths:

```prolog
% The shortest path is the minimum of the short paths
shortest_path(X,Y,D) :- bagMin(short_path(X,Y),D).
```
This program in fact works for cyclic graphs, as long as all loops have nonnegative distance. To see why it works, we must look at it more closely. Normally we think of computing an aggregation by creating all the elements in the bag, and then performing the aggregation on the entire set. However, doing that here, with a cyclic graph, would result in a bag with infinitely many elements, since there are infinitely many different paths through a cyclic graph. It is clear that we can't construct and test every element in a bag of infinitely many elements. `bagMin` must return an answer before it has seen all the elements. Notice that if a graph has a self-loop, say from node `a` to node `a`, then a `D` such that `short_path(X,a)(D)` is defined in terms of the minimum of a bag that contains `D` itself. This turns out to be well-defined, because the minimum operator is monotonic. It works computationally because in the case of recursive definitions, the `bagMin` may return an answer before it has seen all the answers. At any point it returns the best one it has seen so far: if another one comes along that is better, it returns that one; if another comes along that is no better, it just ignores it, and fails back to find another.

So the order in which answers are generated can effect how much computation is done. If poor answers are returned first and many paths are computed using those poor answers, then all that work is unnecessary and will have to be done again with improved answers. Whereas if the best answer is returned first, then much less total computation will have to be done. So the complexity of this routine is dependent on the scheduling strategy of the underlying engine. We will look at these issues more later.

------------------------------------------------------------------------

## Reasoning with Uncertainty: Annotated Logic
We will look at examples including computing with annotated logic and Fitting's LP over bilattices.

:- import bagMin/2 from aggregs.\
:- hilog minimum.\
minimum(X,Y,Z) :- X =\< Y -\> Z=X ; Z=Y.\

sumlist(\[\],0).\
sumlist(\[X\|L\],S) :- sumlist(L,S1), S is S1+X.\

:- op(500,xfx,@).\

G:D :- orFun(G,D).\
orFun(G,D) :- bagMin(andFun(G),D).\

andFun(G)(D) :- G@L,sumlist(L,D).\

p(X,Y)@\[D\] :- edge(X,Y):D.\
p(X,Y)@\[D1,D2\] :- p(X,Z):D1,edge(Z,Y):D2.\

edge(a,b)@\[5\].\
edge(b,d)@\[6\].\
edge(b,c)@\[1\].\
edge(c,e)@\[3\].\
edge(e,d)@\[1\].\
edge(a,c)@\[7\].\
edge(c,d)@\[2\].\

------------------------------------------------------------------------

## Longest Path
longest path.

% longest path (without loops)\
:- import bagMax/2 from aggregs.\
:- import member/2 from basics.\

longpath(X,Y,P)(D) :- edge(X,Y,D), P=\[F\|R\], \\member(F,R).\
longpath(X,Y,P)(D) :- \
```prolog
    bagMax(longpath(X,Z,\[Z\|P\]),D), edge(Z,Y,D), Y\\=Z, \\member(Y,P).
```
:- hilog maximum.  maximum(X,Y,Z) :- X @\< Y -\> Z=Y ; Z=X.\

edge(a,b,5).\
edge(a,b,6).\
edge(a,d,4).\
edge(d,b,5).\
edge(b,c,3).\
edge(b,c,4).\

------------------------------------------------------------------------

# Scheduling Issues
Discuss breadth-first-like scheduling. Give example of graph that has exponential shortest-path with depth-first scheduling. Give benches on both depth-first and breadth-first scheduler. (For benches, maybe just give relative times, so as not to date it.)

(ts) I agree, Ive been using relative times.

------------------------------------------------------------------------

# Stratified Aggregation
Issues of stratified findall here, stratified aggregation?

------------------------------------------------------------------------
