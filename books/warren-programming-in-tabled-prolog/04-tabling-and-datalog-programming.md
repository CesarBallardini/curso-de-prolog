# Tabling and Datalog Programming
In the previous chapter we saw several limitations of Prolog. When we considered grammars in Prolog, we found that the parser provided by Prolog \`\`for free'' is a recursive descent parser and not one of the better ones that we'd really like to have. When looking at deductive databases, we found that some perfectly reasonable programs go into an infinite loop, for example transitive closure on a cyclic graph. We had to go to some lengths to program around these limitations, and even then the results were not completely satisfying.

XSB implements a feature not (yet) found in any other Prolog system. It is the notion of tabling, also sometimes called memoization or lemmatization. The idea is very simple: never make the same procedure call twice: the first time a call is made, remember all the answers it returns, and if it's ever made again, use those previously computed answers to satisfy the later request. In XSB the programmer indicates what calls should be tabled by using a compiler directive, such as:

```prolog
:- table np/2.
```
This example requests that all calls to the procedure `np` that has two arguments should be tabled. Predicates that have such declarations in a given program are called tabled predicates.

A simple example of a use of tabling is in the case of a definition of transitive closure in a graph. Assume that we have a set of facts that define a predicate `owes`. The fact `owes(andy,bill)` means that Andy owes Bill some money. Then we use `owes` to define a predicate `avoids` as we did in the previous chapter. A person avoids anyone he or she owes money to, as well as avoiding anyone they avoid.

```prolog
:- table avoids/2.
avoids(Source,Target) :- owes(Source,Target).
avoids(Source,Target) :-
    owes(Source,Intermediate),
    avoids(Intermediate,Target).
```
Here we are assuming that the edges of a directed graph are stored in a predicate `owes/2`. The rules in this program are the same as those used in Prolog to define ancestor. The difference is that in XSB we can make the table declaration, and this declaration guarantees that this predicate will be correctly computed, even if the graph in `owes/2` *is* cyclic. Intuitively it's clear that any call to `avoids` will terminate because there are only finitely many possible calls for any finite graph, and since tabling guarantees that no call is ever evaluated more than once, eventually all the necessary calls will be made and the computation will terminate. The problem with Prolog was that in a cyclic graph the same call was made and evaluated infinitely many times.

Indeed, executing this program on the graph:

owes(andy,bill).\
owes(bill,carl).\
owes(carl,bill).\

for the query `avoids(andy,X)`, which we saw go into an infinite loop without the table declaration, yields the following under XSB:

warren% xsb\
XSB Version 1.4.2 (95/4/6)\
\[sequential, single word, optimal mode\]\
\| ?- \[graph\].\
\[Compiling ./graph\]\
\[graph compiled, cpu time used: 0.589 seconds\]\
\[graph loaded\]\

yes\
\| ?- avoids(andy,Y).\

Y = bill;\

Y = carl;\

no\
\| ?-\

------------------------------------------------------------------------

- <a href="#node15.html" id="node14.html_tex2html332">XSB tabled execution as the execution of concurrent machines</a>
- <a href="#node16.html" id="node14.html_tex2html333">More on Transitive Closure</a>
- <a href="#node17.html" id="node14.html_tex2html334">Other Datalog Examples</a>
- <a href="#node18.html" id="node14.html_tex2html335">Some Simple Graph Problems</a>
- <a href="#node19.html" id="node14.html_tex2html336">Genome Examples</a>
- <a href="#node20.html" id="node14.html_tex2html337">Inferring When to Table</a>
  - <a href="#node21.html" id="node14.html_tex2html338">On the Complexity of Tabled Datalog Programs</a>
- <a href="#node22.html" id="node14.html_tex2html339">Datalog Optimization in XSB</a>

------------------------------------------------------------------------

### XSB tabled execution as the execution of concurrent machines
We understood a Prolog evaluation as a set of executing deterministic procedural machines, increasing in number as one of them executes a multiply-defined procedure, and decreasing in number as one of them encounters failure. Then we saw how it was implemented by means of a depth-first backtracking search through the tree of SLD computations, or procedure evaluations. To add the concept of tabling, we have to extend our computational model. Tabling execution is best understood as computation in a concurrent programming language. Nontabled predicates are evaluated exactly as in SLD, with the intuition of a procedure call. Evaluating a tabled predicate is understood as sending the goal to a cacheing goal server and then waiting for it to send back the answers. If no server for the goal exists, then one is created and begins (concurrently) to compute and save answers. If a server for this goal already exists, none needs to be started. When answers become available, they can be (and eventually will be) sent back to all waiting requesters. So tabled predicates are processed \`\`asynchronously'', by servers that are created on demand and then stay around forever. On creation, they compute and save their answers (eliminating duplicates), which they then will send to anyone who requests them (including, of course, the initiating requester.)

Now we can see tabled execution as organized around a set of servers. Each server evaluates a nondeterministic procedural program (by a depth-first backtracking search through the alternatives) and interacts with other servers asynchronously by requesting answers and waiting for them to be returned. For each answer returned from a server, computation continues with that alternative.

The abstraction of Prolog computation was the SLD tree, a tree that showed the alternative procedural machines. We can extend that abstraction to tabled Prolog execution by using multiple SLD trees, one for each goal server.

Let's trace the execution of the program for reachability on the simple graph in `owes/2`, given the query `:- avoids(andy,Ya)`. Again, we start with a query and develop the SLD tree for it until we hit a call to a tabled predicate. This is shown in Figure [3.1](#node15.html_slgf-owe1).\



**Figure 3.1:** Tree for avoid(andy,Ya) goal server {width="50%"}

Whereas for SLD trees, we used a pseudo predicate `ans` to collect the answers, for SLD trees for goal servers, we will use the entire goal to save the answer, so the left-hand-side of the root of the SLD tree is the same as the right-hand-side. Computation traces this tree in a left-to-right depth-first manner.

So the initial global machine state, or configuration, is:

```prolog
oids(andy,Ya) :- avoids(andy,Ya).
```
Then rules are found which match the first goal on the right-hand-side of the rule. In this case there are two, which when used to replace the expanded literal, yield two children nodes:

```prolog
oids(andy,Ya) :- owes(andy,Ya).
oids(andy,Ya) :- owes(andy,Intb),avoids(Intb,Ya).
```
Computation continues by taking the first one and expanding it. Its selected goal (the first on the right-hand side) matches one rule (in this case a fact) which, after replacing the selected goal with the (empty) rule body, yields:

```prolog
oids(andy,bill) :-
```
And since the body is empty, this is an answer to the original query, and the system could print out `Y=bill` as an answer.

Then computation continues by using the stack to find that the second child of the root node:

```prolog
oids(andy,Ya) :- owes(andy,Intb),avoids(Intb,Ya).
```
should be expanded next. The selected goal matches with the fact `owes(andy,bill)` and expanding with this results in:

```prolog
oids(andy,Ya) :- avoids(bill,Ya).
```
Now the selected goal for this node is `avoids(bill,Ya)`, and `avoids` is a tabled predicate. Therefore this goal is to be solved by communicating with its server. Since the server for that goal does not exist, the system creates it, and schedules it to compute its answers. This computation is shown in Figure [3.2](#node15.html_slgf-owe2).\



**Figure 3.2:** Tree for avoid(bill,Ya) goal server {width="50%"}

This computation sequence for the goal `avoid(bill,Y)` is very similar to the previous one for `avoid(andy,Y)`. The first clause for `avoids` is matched, followed by the one fact for `owes` that has `bill` as its first field, which generates the left-most leaf of the tree of the figure. This is an answer which this (concurrently executing) server could immediately send back to the requesting node in Figure [3.1](#node15.html_slgf-owe1). Alternatively, computation could continue in this server to finish the tree pictured in Figure [3.2](#node15.html_slgf-owe2), finally generating the right-most leaf:

avoids(bill,Ya) :- avoids(carl,Ya)\

Now since the selected goal here is tabled, the server for it is queried and its response is awaited. Again, there is no server for this goal yet, so the system creates one and has it compute its answers. This computation is shown in Figure [3.3](#node15.html_slgf-owe3).\



**Figure 3.3:** Tree for avoids(carl,Ya) goal server {width="50%"}

This computaton is beginning to look familiar; again the form of the computation tree is the same (because only one clause matches `owes(carl,Y)`). Again an answer, `avoids(carl,bill)`, is produced (and is scheduled to be returned to its requester) and computation continues to the right-most leaf of the tree with the selected goal of `avoids(bill,Ya)`. This is a tabled goal and so will be processed by its server. But now the server *does* exist; it is the one Figure [3.2](#node15.html_slgf-owe2). Now we can continue and see what happens when answers are returned from servers to requesters. Note that exactly *when* these answers are returned is determined by the scheduling strategy of our underlying concurrent language. We have thus far assumed that the scheduler schedules work for new servers before scheduling the returning of answers. Other alternatives are certainly possible.

Now in our computation there are answers computed by servers that need to be sent back to their requesters. The server for `avoids(bill,Ya)` (in Figure [3.2](#node15.html_slgf-owe2)) has computed an answer `avoids(bill,carl)`, which it sends back to the server for `avoids(andy,Ya)` (in Figure [3.1](#node15.html_slgf-owe1)). That adds a child to the rightmost leaf of the server's tree, producing the new tree shown in Figure [3.4](#node15.html_slgf-owe4).\



**Figure 3.4:** Updated tree for avoid(andy,Ya) goal server {width="50%"}

Here the answer (`avoids(bill,carl)`) has been matched with the selected goal (`avoids(bill,Ya)`) giving a value to `Ya`, and generating the child `avoids(andy,carl) :-`. Note that this child is a new answer for this server.

Computation continues with answers being returned from servers to requesters until all answers have been sent back. Then there is nothing left to do, and computation terminates. The trees of the three servers in the final state are shown in Figure [3.5](#node15.html_slgf-owe5).\



**Figure 3.5:** Final state for all goal servers for query avoids(andy,Ya) {width="50%"}

Duplicate answers may be generated (as we see in each server) but each answer is sent only once to each requester. So duplicate answers are eliminated by the servers.

Let's be more precise and look at the operations that are used to construct these server trees. We saw that the SLD trees of Prolog execution could be described by giving a single rule, Program Clause Resolution, and applying it over and over again to an initial node derived from the query. A similar thing can be done to generate sets of server trees that represent the computation of tabled evaluation. For this we need three rules:

**Definition 3.0.1  ** **(Program Clause Resolution)** Given a tree with a node labeled\
 , which is either a root node of a server tree or *A*<sub>1</sub> is not indicated as tabled. Also given a rule in the program of the form  , (with all new variables) and given that *H* and *B*<sub>1</sub> match with matching variable assignment , then add a new node as a child of this one and label it with  , if it does not already have a child so labeled. Note that the matching variable assignment is applied to all the goals in the new label.

**Definition 3.0.2  ** **(Subgoal Call)** Given a nonroot node with label  , where *A*<sub>1</sub> is indicated as tabled, and there is no tree with root  *A*<sub>1</sub> :- *A*<sub>1</sub>, create a new tree with root  *A*<sub>1</sub> :- *A*<sub>1</sub>.

**Definition 3.0.3  ** **(Answer Clause Resolution)** Given a non-root node with label\
 , and an answer of the form *B* :- in the tree for *A*<sub>1</sub>, then add a new node as child of this node labeled by  , where  is the variable assignments obtained from matching *B* and *A*<sub>1</sub> (if there is not already a child with that label.)

So for example the trees in Figure [3.5](#node15.html_slgf-owe5) are constructed by applying these rules to the initial tree (root) for the starting goal. XSB can be understood as efficiently constructing this forest of trees. We have seen that XSB with tabling will terminate on a query and program for which Prolog will loop infinitely. It turns out that this is not just an accident, but happens for many, many programs. For example, here we've written the transitive closure of owes using a right recursive rule, i.e., the recursive call to `avoids` follows the call to `owes` in the second rule defining `avoids`. We could also define `avoids` with a rule that has a call to `avoids` before a call to `owes`. That definition would not terminate in Prolog for any graph, but with tabling, it is easily evaluated correctly.

------------------------------------------------------------------------

# More on Transitive Closure
We saw in the previous section how XSB with tabling will correctly and finitely execute a transitive closure definition even in the presence of cyclic data. Actually, this is only a simple example of the power of tabled evaluation.

We can write another version of transitive closure:

```prolog
:- table avoids/2.
avoids(Source,Target) :- owes(Source,Target).
avoids(Source,Target) :-
    avoids(Source,Intermediate),
    owes(Intermediate,Target).
```
This one is left recursive. A Prolog programmer would not consider writing such a definition, since in Prolog it is guaranteed to be nonfinite. But with tabling, this definition works fine. As a matter of fact, it is generally a more efficient way to express transitive closure than is right recursion. In this section we will look at various versions of transitive closure and compare their efficiency.

Let's consider the evaluation of the same `avoids` query on the same `owes` data as above, but using the left-recursive definition of avoids.

Figure [3.6](#node16.html_slgf-owel1) shows the state of the initial server when it first encounters a request to a server.\



**Figure 3.6:** Beginning of evaluation of avoids(andy,Ya) for left-recursive transitive closure definition {width="50%"}

Note that this time the request to a server is to the server for `avoids(andy,Ya)`, and this is the server itself. (The names of the variables don't matter when finding a server; they are just \`\`placeholders'', so any server with the same arguments with the same pattern of variables works.) The server does have an answer already computed, so it can send it back to the requester (itself), and that results in the tree of Figure [3.7](#node16.html_slgf-owel2).\



**Figure 3.7:** More of the evaluation of avoids(andy,Ya) for left-recursive transitive closure definition {width="50%"}

Now the new leaf, created by the returned answer, can be expanded (by Program Clause Resolution) yielding a new answer, `avoids(andy,carl)`. This answer can be returned to the (only) requester for this server, and that generates a second child for the requester node; this state is shown in Figure [3.8](#node16.html_slgf-owel3).\



**Figure 3.8:** More of the evaluation of avoids(andy,Ya) for left-recursive transitive closure definition {width="50%"}

Now this node can be expanded (by *Program Clause Resolution*) to obtain the tree of Figure [3.9](#node16.html_slgf-owel4)\



**Figure 3.9:** Final forest for avoids(andy,Ya) for left-recursive transitive closure definition {width="50%"}

Here we have generated another answer, but it is the same as one we've already generated, so returning it to the requester node will *not* generate any new children. All operations have been applied and no more are applicable, so we have reached the final forest of trees, a forest consisting of only one tree. Note that we have the correct two (distinct) answers: that andy avoids bill and andy avoids carl.

The right-recursive definition and the left-recursive definition of avoids both give us the correct answers, but the left-recursive definition (for this query) generates only one tree, whereas the right recursive definition generates several. It seems as though the left-recrsive definition would compute such queries more efficiently, and this is indeed the case.

Consider transitive closure over an `owes` relation that defines a cycle. E.g.,

owes(1,2).\
owes(2,3).\
owes(3,4).\
...\
owes(99,100).\
owes(100,1).\

defines a graph with a cycle of length 100. How would the trees in the forest look after evaluation of a query to `avoids(1,X)` using the right-recursive transitive closure definition? For each *n* between 1 and 100, there is a tree with root: `avoids(`*n*`,Y)`. And each such tree will have 100 leaf answer nodes. So the forest will have at least 100<sup>2</sup> nodes, and for a cycle of length *n* the forest would be of size O(*n*<sup>2</sup>).

What does the forest look like if we use the left-recursive definition? It has one tree with root, `avoids(1,Y)`, and that tree has 100 answer leaves. Generalizing from the tree of Figure [3.9](#node16.html_slgf-owel4), we see that it is a very flat tree, and so for a cycle of length *n*, the tree (forest) would be of size O(*n*). The left-recursive definition is indeed the more efficient to compute with. Indeed the complexity of a single-source query to the left-recursive version of transitive closure is linear in the number of edges in the graph reachable from the source node.

------------------------------------------------------------------------

# Other Datalog Examples
In the previous section we saw how tabling can finitely process certain programs and queries for which Prolog would go into an infinite loop. Tabling can also drastically improve the efficiency of some terminating Prolog programs. Consider reachability in a DAG. Prolog will terminate, but it may retraverse the same subgraph over and over again.

Let's reconsider the mostly linear `owes` graph at the end of the previous chapter (shown in Figure [2.2](#node12.html_expgraph)) on which Prolog had exponential complexity. Consider evaluating the query `avoids(andy,X)` with the left-recursive tabled definition of transitive closure. The forest for this evaluation will again consist of a single tree, and that tree will be very flat, similar in form to the one of Figure [3.9](#node16.html_slgf-owel4). Thus tabled evaluation will take linear time. So this is an example in which Prolog (with its right recursive definition) will terminate, but take exponential time; XSB with the left-recursive definition and tabling will terminate in linear time.

The \`\`doubly-connected linear'' graph used here may seem unusual and specially chosen, but the characteristics of the graph that cause Prolog to be exponential are not that unusual. Many naturally occurring directed graphs have multiple paths to the same node, and this is what casues the problem for Prolog. \[For example, consider a graph (generated by graph-base \[#!graphbase!#\]) that places 5-letter English words in a graph with an edge between two words if one can be obtained from the other by changing a single letter.... (get example from Juliana, and see how it works.)

Transitive closure is perhaps the most common example of a recursive query in Datalog, but other query forms can be encountered. Consider the definition of `same_generation`. Given binary relations `up` and `down` on nodes, define a binary relation on nodes that associates two nodes if one can be reached from the other by going *n* steps up and then *n* steps down, for some *n*. The program is:

same_generation(X,X).\
same_generation(X,Y) :- \
```prolog
up(X,Z1),
same_generation(Z1,Z2),
down(Z2,Y).
```
The name of the predicate arises from the fact that if we let `up` be defined by a \`\`parent_of'' relation and `down` be defined by the \`\`child_of'' relation, then `same_generation/2` defines people in the same generation.

\[to be continued...\]

------------------------------------------------------------------------

# Some Simple Graph Problems
Consider the problem of finding connected components in a directed graph. Assume we have a node and we want to find all the nodes that are in the same connected component as the given node.

The first thought that comes to mind is: given a node X, find those nodes Y that are reachable from X and from which you can get back to X. So we will assume that edges are given by an `edge/2` relation:

sameSCC(X,Y) :- reach(X,Z), reach(Z,Y).\

:- table reach/2.\
reach(X,X).\
reach(X,Y) :- reach(X,Z), edge(Z,Y).\

Indeed given a node X, this will find all nodes in the same strongly connected component as X, however it will in general take *O*(*n*\**e*) time, where *n* is the number of nodes and *e* is the number of edges. The reason is that given an X, there are *n* possible Z values and for each of them, we will find everything reachable from them, and each search can take *O*(*e*) time.

However, we can do better. It is known that this problem can be solved in *O*(*e*) time. The idea is, given a node X, to find all nodes reachable from X following edges forward. Then find all nodes reachable from X following edges backward (i.e., follow edges against the arrow.) Then intersect the two sets. That will be the set of nodes in X's SCC, because if Y is in both these sets, you can follow the edges forward from X to Y and then since there is also a backwards path from X to Y, there is forward path from Y to X, so you can get from X to Y and back to X following edges forward. So the program that does this is:

% sameSCC(+X,-Y)\
sameSCC(X,Y) :- reachfor(X,Y), reachback(X,Y).\

:- table reachfor/2, reachback/2.\
reachfor(X,X).\
reachfor(X,Y) :- reachfor(X,Z),edge(Z,Y).\

reachback(X,X).\
reachback(X,Y) :- reachback(X,Z),edge(Y,Z).\

Let's now consider its complexity to see why it is *O*(*e*). For a fixed value X, the computation of the query `reachfor(X,Y)` takes *O*(*e*) time. Then we may have *O*(*n*) calls to `reachback(X,Y)` (one for each Y) but they all use one underlying call to `reachback(X,_)` which takes *O*(*e*) and is done only once. So when we add all that up (assuming a connected graph), we get *O*(*e*) time.

------------------------------------------------------------------------

# Genome Examples
\[We need to get the semantics of the genome queries from Tony. Does anybody remember?\]

------------------------------------------------------------------------

# Inferring When to Table
Up to now whenever we wanted calls to a predicate to be tabled, we explicitly coded a table directive to indicate the specific predicate to table. There is a facility in XSB for the programmer to direct the system to choose what predicates to table, in which case the system will generate table directives automatically. There are two directives that control this process: `auto_table/0` and `suppl_table/1`. When such a directive is placed in a source file, it applies to all predicates in that file when it is compiled.

`auto_table/0` causes the compiler to table enough predicates to avoid infinite loops due to redundant procedure calls. The current implementation of `auto_table` uses the call graph of the program. There is a node in the call graph of a program for each predicate, `P/N`, that appears in the program. There is an edge from node for predicate `P/N` to the node for predicate `Q/M` if there is a rule in the program with an atom with predicate `P/N` in the head and a literal with predicate `Q/M` in the body. The algorithm constructs the call graph and then chooses enough predicates to table to ensure that all loops in the call graph are broken. The algorithm, as currently implemented in XSB, finds a minimal set of nodes that breaks all cycles. The algorithm can be exponential in the number of predicates in the worst case<a href="#footnode.html_foot918" id="node20.html_tex2html13"><sup>3.1</sup></a>. If the program is a Datalog program, i.e., it has no recursive data structures, then `auto_table` *is* guaranteed to make all queries to it terminate finitely. Termination of general programs is, of course, undecidable, and `auto_table` may or may not improve their termination characteristics.

The goal of `auto_table` is to guarantee termination of Datalog programs, but there are other uses tabling. Tabling can have a great effect on the efficiency of terminating programs. Example [3.5.1](#node20.html_multi-join) illustrates how a multiway join predicate can use tabling to eliminate redundant subcomputations.

**Example 3.5.1**   Consider the following set of relations describing a student database for a college:

1\.
student(StdId,StdName,Yr): Student with ID `StdId` and name `StdName` is in year `Yr`, where year is 1 for freshman, 2 for sophomores, etc.

2\.
enroll(StdId,CrsId): Student with ID `StdId` is enrolled in the course with number `CrsId`.

3\.
course(CrsId,CrsName): Course with number `CrsId` has name `CrsName`.

We define a predicate `yrCourse/2`, which, given a year, finds all the courses taken by some student who is in that year:

yrCourse(Yr,CrsName) :- \
```prolog
student(StdId,\_,Yr), enroll(StdId,CrsId), course(CrsId,CrsName).
```
Note that it will most likely be the case that if one student of a given year takes a course then many students in the same year will take that same course. Evaluated directly, this definition will result in the course name being looked up for every student that takes a given course, not just for every course taken by some student. By introducing an intermediate predicate, and tabling it, we can elminate this redundancy:

yrCourse(Yr,CrsName) :- \
```prolog
yrCrsId(Yr,CrsId), course(CrsId,CrsName).
```
:- table yrCrsId/2.\
yrCrsId(Yr,CrsId) :-\
```prolog
student(StdId,\_,Yr), enroll(StdId,CrsId).
```
The intermediate predicate `yrCrsId` is tabled and so will eliminate duplicates. Thus `course` will only be accessed once for each course, instead of once for each student. This can make a very large difference in evaluation time.

In this example a table has been used to eliminate duplicates that arise from the database operations of a join and a projection. Tables may also be used to eliminate duplicates arising from unions.

The `suppl_table/1` directive is a means by which the programmer can ask the XSB system to perform such factoring automatically. The program:

:- edb student/3, enroll/2, course/2.\
:- suppl_table(2).\
yrCourse(Yr,CrsName) :- \
```prolog
student(StdId,\_,Yr), enroll(StdId,CrsId), course(CrsId,CrsName).
```
will automatically generate a program equivalent to the one above with the new intermediate predicate and the table declaration.

To understand precisely how `suppl_table` works, we need to understand some distinctions and definitions of deductive databases. Predicates that are defined by sets of ground facts can be designated as *extensional predicates*. The extensional predicates make up the extensional database (EDB). The remaining predicates are called *intensional predicates*, which make up the intensional database (IDB), and they usually have definitions that depend on the extensional predicates. In XSB the declaration:

```prolog
       :- edb student/3, enroll/2, course/2.
```
declares three predicates to be extensional predicates. (Their definitions will have to be given elsewhere.) We define the data dependency count of an IDB clause to be the number of tabled IDB predicate it depends on plus the number of EDB predicates it depends on (*not* through a tabled IDB predicate.) The command:

```prolog
   :- suppl_table(2).
```
instructs XSB to factor any clause which has a data dependency count of greater than two. In Example [3.5.1](#node20.html_multi-join) the data dependency count of the original form of `join/2` is three, while after undergoing supplementary tabling, its count is two. Choosing a higher number for `suppl_table` results in less factoring and fewer implied table declarations.

The next subsection describes somewhat more formally how these transformations affect the worst-case complexity of query evaluation.

------------------------------------------------------------------------

- <a href="#node21.html" id="node20.html_tex2html404">On the Complexity of Tabled Datalog Programs</a>

------------------------------------------------------------------------

### On the Complexity of Tabled Datalog Programs
The worst-case complexity of a Datalog program (with every predicate tabled) is:\



where *k* is the number of constants in the Herbrand base (i.e., in the program). One can see how this can be achieved by making all base relations to be cross products of the set of constants in the program. Assume the call is completely open. Then if there are *v*<sub>1</sub> variables in the first subgoal, there will be *k*<sup>*v*<sub>1</sub></sup> tuples. Each of theses tuples will be extended through the second subgoal, and consider how many tuples from the second subgoal there can be: *k*<sup>*v*<sub>2</sub></sup> where *v*<sub>2</sub> is the number of variables appearing in the second subgoal and not appearing in the first. So to get through the second subgoal will take time  *k*<sup>*v*<sub>1</sub></sup>\**k*<sup>*v*<sub>2</sub></sup>. And similarly through the entire body of the clause. Each subgoal multiplies by a factor *k*<sup>*v*</sup> where *v* is the number of new variables. And every variable in the body of the clause is new once and only once. This is the reason for the second component in the summation above. The first component is just in case there are no variables in the clause. For an entire program one can see that the complexity (for a nonpropositional) datalog program is *O*(*k*<sup>*v*</sup>) where *v* is the maximum number of variables in the body of any clause.

We can use folding to try to improve the worst-case efficiency of a Datalog program. Consider the query:

(7) :- p(A,B,C,D),q(B,F,G,A),r(A,C,F,D),s(D,G,A,E),t(A,D,F,G).\

It has 7 variables (as indicated by the number in parentheses that precedes the query), so its worst-case efficiency is *O*(*n*<sup>7</sup>). However, we can fold the first two subgoals by introducing a new predicate, obtaining the following program:

(6) :- f1(A,C,D,F,G),r(A,C,F,D),s(D,G,A,E),t(A,D,F,G).\
(6) f1(A,C,D,F,G) :- p(A,B,C,D),q(B,F,G,A).\

This one has a maximum of 6 variables in the query or in the right-hand-side of any rule, and so has a worst-case complexity of *O*(*n*<sup>6</sup>).

We can do a couple of more folding operations as follows:

(5) :- f2(A,D,F,G),s(D,G,A,E),t(A,D,F,G).\
(5) f2(A,D,F,G) :- f1(A,C,D,F,G),r(A,C,F,D).\
(6) f1(A,C,D,F,G) :- p(A,B,C,D),q(B,F,G,A).\

(4) :- f2(A,D,F,G),f3(D,G,A),t(A,D,F,G).\
(4) f3(D,G,A) :- s(D,G,A,E).\
(5) f2(A,D,F,G) :- f1(A,C,D,F,G),r(A,C,F,D).\
(6) f1(A,C,D,F,G) :- p(A,B,C,D),q(B,F,G,A).\

Thus far, we have maintained the order of the subgoals. If we allow re-ordering, we could do the following. For each variable, find all the variables that appear in some subgoal that it appears in. Choose the variable so associated with the fewest number of other variables. Factor those subgoals, which removes that variable (at least). Continue until all variables have the same number of associated variables.

Let's apply this algorithm to the initial query above. First we give each variable and the variables that appear in subgoals it appears in.

A:BCDEFG\
B:ACDFG\
C:ABDF\
D:BCDEFG\
E:ADG\
F:ABGCD\
G:ABFDE\

Now E is the variable associated with the fewest number of other variables, so we fold all the literals (here only one) containing E, and obtain the program:

(6) :- p(A,B,C,D),q(B,F,G,A),r(A,C,F,D),f1(D,G,A),t(A,D,F,G).\
(4) f1(D,G,A) :- s(D,G,A,E).\

Now computing the new associated variables for the first clause, and then choosing to eliminate C, we get:

A:BCDFG\
B:ACDFG\
C:ABDF\
D:ABCFG\
F:ABGCD\
G:ABFD\

(5) :- f2(A,B,D,F),q(B,F,G,A),f1(D,G,A),t(A,D,F,G).\
(4) f1(D,G,A) :- s(D,G,A,E).\
(5) f2(A,B,D,F) :- p(A,B,C,D),r(A,C,F,D).\

Now computing the associated variables for the query, we get:

a:bdfg\
b:adfg\
d:abfg\
f:abdg\
g:abfd\

All variables are associated with all other variables, so no factoring can help the worst-case complexity, and the complexity is *O*(*k*<sup>5</sup>).

However, there is still some factoring that will eliminate variables, and so might improve some queries, even though it doesn't guarantee to reduce the worst-case complexity.

(4) :- f3(A,D,F,G),f1(D,G,A),t(A,D,F,G).\
(5) f3(A,D,F,G) :- f2(A,B,D,F),q(B,F,G,A).\
(4) f1(D,G,A) :- s(D,G,A,E).\
(5) f2(A,B,D,F) :- p(A,B,C,D),r(A,C,F,D),\

(3) :- f4(A,D,G),f1(D,G,A).\
(4) f4(A,D,G) :- f3(A,D,F,G),t(A,D,F,G).\
(5) f3(A,D,F,G) :- f2(A,B,D,F),q(B,F,G,A).\
(4) f1(D,G,A) :- s(D,G,A,E).\
(5) f2(A,B,D,F) :- p(A,B,C,D),r(A,C,F,D).\

The general problem of finding an optimal factoring is conjectured to be NP hard. (Steve Skiena has the sketch of a proof.)

------------------------------------------------------------------------

# Datalog Optimization in XSB
\[Do we want to do it at all, and if so, here?\] I think we do want it, but I don't know about here.

------------------------------------------------------------------------
