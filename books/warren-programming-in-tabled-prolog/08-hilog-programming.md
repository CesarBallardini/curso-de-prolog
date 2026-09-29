# HiLog Programming
XSB includes a capapbility to process programs which have complex terms in predicate of functor position. This allows programmers to program in a higher-order syntax, and so this extension of Prolog is called HiLog. Programmers can think of programming with parameterized predicates or with predicate variables. HiLog also supports a new way of programming with sets. We will explore these issues in this chapter.

HiLog is actually a very simple extension to Prolog. The definition of a basic term in Prolog is as follows:

- A term is a atomic symbol or a variable, or
- A term is of the form:  *s*(*t*<sub>1</sub>,*t*<sub>2</sub>,...,*t*<sub>*n*</sub>) where *s* is an atomic symbol and the *t*<sub>*i*</sub> are terms.

Note that the symbol in functor (or predicate) position must be a symbol. HiLog generalizes this to allow an arbitrary term itself. So the definition of a term in HiLog is:

- A term is a atomic symbol or a variable, or
- A term is of the form:  *t*<sub>0</sub>(*t*<sub>1</sub>,*t*<sub>2</sub>,...,*t*<sub>*n*</sub>) where the *t*<sub>*i*</sub> are terms.

Computationally these terms are matched just as Prolog terms, so intuitively HiLog programs work very similarly to Prolog programs. However, they encourage different ways of thinking about programs and support different programming paradigms.

------------------------------------------------------------------------

- <a href="#node46.html" id="node45.html_tex2html693">Generic Programs</a>
- <a href="#node47.html" id="node45.html_tex2html694">Object Centered Programming in XSB with HiLog</a>

------------------------------------------------------------------------

# Generic Programs
Because one can use a complex term as a predicate in HiLog, one can program \`\`generic predicates.'' For example, consider a predicate function, i.e., a function that takes a predicate and returns another predicate. An interesting such predicate function might be `closure`. `closure` takes a binary predicate and returns a predicate for the transitive closure of the corresponding binary relation. So for example, `closure(parent)` would be the transitive closure of the `parent` relation, i.e., the ancestor relation, and `closure(child)` would be the descendent relation. We can define this `closure` predicate function in HiLog as follows:

closure(R)(X,Y) :- R(X,Y).\
closure(R)(X,Y) :- R(X,Z), closure(R)(Z,Y).\

Now given any binary relation, one can use use this definition to compute its closure. For example, we can define a binary predicate, `parent` as follows:

:- hilog parent.\
parent(able,adam).\
parent(able,eve).\
parent(cain,adam).\
parent(cain,eve).\
etc\

and then we can use the generic definition of closure to find anscestors:

\| ?- closure(parent)(cain,X).\
```prolog
c.
```
Notice that we must declare the symbol `parent` to be a hilog symbol using the directive:

:- hilog parent.\

This is necessary because the XSB system allows a mixture of HiLog programming and Prolog programming, and the system distinguishes between HiLog symbols and Prolog symbols in how it represents them. The HiLog term  *t*<sub>0</sub>(*t*<sub>1</sub>,*t*<sub>2</sub>,...,*t*<sub>*n*</sub>) is represented as the Prolog term  *apply*(*t*<sub>0</sub>,*t*<sub>1</sub>,*t*<sub>2</sub>,...,*t*<sub>*n*</sub>). Thus the system must know, for example, that `parent` is a hilog symbol so it knows to represent `parent(cain,adam) as the Prolog term \verb`apply(parent,cain,adam)\|.

Another useful generic predicate is `map`. `map` takes a binary function and returns a function that when given a list, returns the list that results from applying that function to each element of the given list. Again, we can write a natural definition for it:

map(F)(\[\],\[\]).\
map(F)(\[X\|Xs\],\[Y\|Ys\]) :- F(X,Y), map(F)(Xs,Ys).\

So, for example, we can use this generic function to add one to every element of a list, double every element of a list, or square every element of a list. Given the definitions:

:- hilog successor,double,square.\
successor(X,Y) :- Y is X+1.\
double(X,Y) :- Y is X+X.\
square(X,Y) :- Y is X\*X.\

we can do

\| ?- \[(hilog)\].\
\[Compiling ./hilog\]\
% Specialising partially instantiated calls to apply/3\
\[hilog compiled, cpu time used: 0.59 seconds\]\
\[hilog loaded\]\

yes\
\| ?- map(successor)(\[2,4,6,8,10\],L).\

L = \[3,5,7,9,11\];\

no\
\| ?- map(double)(\[2,4,6,8,10\],L).\

L = \[4,8,12,16,20\];\

no\
\| ?-\

This definition of `map` is a bit more general than the one normally found in functional languages, which is not surprising since Prolog is a relational language and this is really a relational definition. For example, `map(successor)` is relation a relation over pairs of lists. If we give to `map` a nonfunctional relation, then the map of that relation is also nonfunctional.

(Think of an interesting example.)

Another interesting example is the generic function `twice`. `twice` takes an input function (or relation) and returns a function that applies the input function twice. (From DHDWarren and MVanEmden.) In standard mathematical notation:  *twice*(*f*)(*x*) = *f*(*f*(*x*)). By turning `twice` into a relation and essentially writing down this definition, we get:

twice(F)(X,R) :- F(X,U), F(U,R).\

And we can run it:

\| ?- \[twice\].\
\[Compiling ./twice\]\
\[twice compiled, cpu time used: 0.659 seconds\]\
\[twice loaded\]\

yes\
\| ?- twice(successor)(1,X).\

X = 3;\

no\
\| ?- twice(twice(successor))(1,X).\

X = 5;\

no\
\| ?- twice(twice(square))(2,X).\

X = 65536;\

no\
\| ?- twice(twice(twice(double)))(1,X).\

X = 256;\

no\
\| ?-\

This interesting thing here is that `twice(f)` for a function `f` produces a function similar to `f`, so we can apply `twice` to a result of `twice` and get a quadrupling (or octupling, ...) effect.

We can add another rule for `twice` (and make it a hilog symbol):

:- hilog twice.\
twice(X,twice(X)).\

This rule says that applying `twice` itself to a function argument gives a term representing the resulting function. So now we can even apply twice to itself to produce a function that we can then apply to one of basic functions to produce a function to apply to a number (that lives in the house that Jack built), as follows:

\| ?- twice(twice)(double,Fun),Fun(1,X).\

Fun = twice(twice(double))\
X = 16;\

no\
\| ?- twice(twice(twice))(double,Fun),Fun(1,X).\

Fun = twice(twice(twice(twice(double))))\
X = 65536;\

no\
\| ?- twice(twice(twice))(successor,Fun),Fun(1,X).\

Fun = twice(twice(twice(twice(successor))))\
X = 17;\

no\
\| ?-\

DHDWarren (and a followup paper by Martin vanEmden et al.) explore issues around using Prolog to implement higher-order aspects of functional languages. This example is taken from there, but is expressed in HiLog's syntax, rather than Prolog's. HiLog's syntax makes the development more perspicuous.

(Do we(I) want to develop a bit more of lambda calculus, and show how to do more general higher-order programming?)

------------------------------------------------------------------------

# Object Centered Programming in XSB with HiLog
HiLog can also be used to program in an object-centered way.

Object oriented programming: C-logic and variants.

(Dealing with pragmatics of HiLog in XSB? and modules and recompilation? Interactions with tabling.)

------------------------------------------------------------------------
