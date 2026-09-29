# Negation in XSB
Negation in the context of logic programming has received a lot of attention. Prolog implements a kind of negation-as-failure inference rule, succeeding the negation of a goal if the goal itself cannot be successfully proven. This implements a kind of closed-world assumption, in that a proposition is assumed to be false if it cannot be proven to be true. This is a useful operator, which can be used to represent (and program) interesting situations.

Consider the standard example of defining the predicate `bachelor` using the predicates `married` and `male`:

bachelor(X) :- male(X), \\ married(X).\

male(bill).\
male(jim).\

married(bill).\
married(mary).\

The rule says that an individual is a bachelor if it is male and it is not married. (`\+` is the negation-as-failure operator in Prolog.) The facts indicate who is married and who is male. We can interrogate this program with various queries and we get the following:

\| ?- \[negation\].\
\[Compiling ./negation\]\
\[negation compiled, cpu time used: 0.1 seconds\]\
\[negation loaded\]\

yes\
\| ?- bachelor(bill).\

no\
\| ?- bachelor(jim).\

yes\
\| ?- bachelor(mary).\

no\
\| ?- bachelor(X).\

X = jim;\

no\
\| ?-\

as expected. The closed-world assumption is applied here: for example, when there is no fact that says that jim is married, we assume that he is not married. Also when there is no fact saying that mary is male, we assume she is not.

Before we get completely carried away with using negation, we need to look at situations in which there are problems. There are two sources of problems: floundering and nonstratification. Let's first consider a floundering query and program. Say we wrote the bachelor rule as:

bachelor(X) :- \\ married(X), male(X).\

This looks to be an equivalent definition, since after all, the comma is conjunction so the order of literals in the body of a program (as simple as this one) shouldn't matter. But now consider the results of the same queries as above when they are submitted to this program:

\| ?- bachelor(bill).\

no\
\| ?- bachelor(jim).\

yes\
\| ?- bachelor(mary).\

no\
\| ?- bachelor(X).\

no\
\| ?-\

The answers are fine for the specific queries concerning bill, jim and mary, but the general query asking for all bachelors fails, whereas we would expect it to generate the answer jim. The reason is that the generated subquery of `\+ married(X)` is able to prove `married(X)` is true (for X=bill (and X=mary as well)), and so `\+ married(X)` fails. The problem is that the implementation of the operator `\+` only works when applied to a literal containing no variables, i.e., a ground literal. It is not able to generate bindings for variables, but only test whether subgoals succeed or fail. So to guarantee reasonable answers to queries to programs containing negation, the negation operator must be allowed to apply only to ground literals. If it is applied to a nonground literal, the program is said to *flounder*. Prolog systems in general allow the `\+` operator to be applied to nonground literals and so the programmer may get unexpected results. Often another operator, `not`, is provided which acts just like `\+` except that it gives an error message when applied to a nonground literal. (In XSB `not` and `\+` give the same, unsafe, results.)

The other problem that may arise in programs with negation, that of nonstratification, is a bit more subtle. !!!Instead of this example, use shave/2 and say the barber shaves everyone who doesn not shave himself. Who shaves the barber?

shave(john,john). shave(bill,bill). shave(barber,X) :- not shaves(X,X).

:- shaves(barber,barber).

!!! Say we want to define a predicate, `normal`, that is true of all reasonable sets. A set is normal if it doesn't contain itself as a member. (A set containing itself is rather wierd; think about it.) So we give the rule:

normal(S) :- \\ in(S,S).\

where the predicate `in` denotes membership. Now we want to have the constant `n` denote the set of all normal sets. So `X` is in `n` just in case `X` is a normal set. The following rule reflects this:

in(X,n) :- normal(X).\

Now consider what happens if we ask this program whether `n` is a normal set: `normal(n)`, which reduces to `\+ in(n,n)`, which reduces to `\+ normal(n)`. So to show that `n` is normal, we have to show that `n` is not normal. Clearly there is something a little odd here, and you may recognize a similarity to Russell's well-known paradox. The oddity is that the predicate `normal` is defined in terms of its own negation. Normally we consider rules to define predicates and this is an odd kind of cyclicity which we often want to avoid. Programs that avoid such cycles through negation in their definitions are called *stratified* programs. Notice that Prolog would go into an infinite loop whan asked queries that involve a cycle through negation.

XSB does not improve over Prolog in handling floundering queries; all calls to negative subgoals must be ground in XSB for the closed-world interpretation of negation to be computed. XSB does extend Prolog in allowing nonstratified programs to be evaluated, and we will discuss how it does that later in the chapter. However, first we will explore how we can use tabling with stratified programs to compute some interesting results.

------------------------------------------------------------------------

- <a href="#node59.html" id="node58.html_tex2html843">Stratified Negation</a>
- <a href="#node60.html" id="node58.html_tex2html844">Approximate Reasoning</a>
- <a href="#node61.html" id="node58.html_tex2html845">General Negation</a>

------------------------------------------------------------------------

# Stratified Negation
As an example of stratified negation, consider the situation in which we have a set of terms and a nondeterministic reduction operation over them. Then given a term, we want to reduce it until further operations don't simplify it any more. We will allow there to be cycles in the reduction operation and assume that terms that reduce to each other are equivalently fully reduced.

This situation can be abstractly modeled by considering the terms to be nodes of a directed graph with an edge from N1 to N2 if the term at N1 directly reduces to the term at N2. Now consider the strongly connected components (SCCs) of this graph, i.e. two nodes are in the same SCC if each can be reached from the other. We will call an SCC a final SCC if the only nodes reachable from nodes in that SCC are others in that SCC. Now given a node, we want to find all nodes reachable from that node that are in final SCCs.

So first we define reachable:

:- table reachable/2.\
reachable(X,Y) :- reduce(X,Y).\
reachable(X,Y) :- reachable(X,Z), reduce(Z,Y).\

Next we can define `reducible` to be true of nodes that can be further reduced, i.e., those nodes from which we can reach other nodes that cannot reach back:

reducible(X) :- reachable(X,Y), tnot(reachable(Y,X)).\

`tnot` is the negation operator for tabled goals. It checks to see that the call doesn't flounder, giving an error message if it does. It can be applied only to a single goal, and that goal must be a tabled predicate. With this predicate we can next define the predicate `fullyReduce` that is true of pairs of nodes such that the first can be reduced to the second and the second is not further reducible:

:- table reducible/1.\
fullyReduce(X,Y) :- reachable(X,Y),tnot(reducible(Y)).\

Note that we must table `reducible` because `tnot` can only be applied to predicates that are tabled.

So with these definitions and the following graph for reduce:

reduce(a,b).\
reduce(b,c).\
reduce(c,d).\
reduce(d,e).\
reduce(e,c).\
reduce(a,f).\
reduce(f,g).\
reduce(g,f).\
reduce(g,k).\
reduce(f,h).\
reduce(h,i).\
reduce(i,h).\

we can ask queries such as:

\| ?- fullyReduce(a,X).\

X = c;\

X = h;\

X = d;\

X = k;\

X = i;\

X = e;\

no\
\| ?-\

which returns all nodes in final SCCs reachable from node `a`.

However, we may now wish to generate just one representative from each final SCC, say the smallest. We can do that with the following program:

fullyReduceRep(X,Y) :- fullyReduce(X,Y), tnot(smallerequiv(Y)).\

smallerequiv(X) :- reachable(X,Y), Y@\<X, reachable(Y,X).\

Now we get:

\| ?- fullyReduceRep(a,X).\

X = c;\

X = h;\

X = k;\

no\
\| ?-\

Note that this is an example of a stratified program. The predicate `reachable` is in the lowest stratum; then `reducible` is defined in terms of the negation of `reachable` so it is in the next stratum; then `fullyReduce` is defined in terms of the negation of `reducible`, so it is in the third stratum. `smallerequiv` is in the first stratum with `reachable`; and `fullyReduceRep` is in the same stratum as `fullyReduce`.

\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*

Issues of safety.

------------------------------------------------------------------------

# Approximate Reasoning
Use course prerequisites example. Introduce undefined truth value. Add undetermined facts for courses currently being taken. Then requests for whether have satisfied requirements will give: true if satisfied without any current course false if not satisfied even if all current courses are passed undetermined if satisfaction depends on outcome of current courses.

Categorization examples? Propositional Horn clauses for bird identification. Allow negation as failure, explicit negation.

cardinal :- red, crested.\
bluejay :- blue, crested.\
robin :- red_breasted, ~crested.\

Use undef as a kind of null value?:\
binarize relation\
undef :- ~undef.\
%emp(Name,Sal,Age) -\> empsal/2 and empage/2\
emp(david,50000,\_\|\_) is represented as \`\`facts'':\

empsal(david,50000).\
empage(david,\_X) :- undef.\

or empage(david,X) :- between(45,X,55),undef.\
(so can fail if not between 45 and 55.)\

------------------------------------------------------------------------

# General Negation
Well-founded semantics of non-stratified negation.

We need examples! Planning? Use for-all type problems, e.g. to find if all nodes reachable from a given node are red, find if it is not the case that there exists a node reachable from the given node that is not red.

------------------------------------------------------------------------
