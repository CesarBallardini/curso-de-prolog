# Handling Large Fact Files

------------------------------------------------------------------------

- <a href="#node70.html" id="node69.html_tex2html967">Compiling Fact Files</a>
- <a href="#node71.html" id="node69.html_tex2html968">Dynamically Loaded Fact Files</a>
- <a href="#node72.html" id="node69.html_tex2html969">Indexing Static Program Clauses</a>
- <a href="#node73.html" id="node69.html_tex2html970">Bibliographic Notes</a>

------------------------------------------------------------------------

# Compiling Fact Files
Certain applications of XSB require the use of large predicates defined exclusively by ground facts. These can be thought of as \`\`database'' relations. Predicates defined by a few hundreds of facts can simply be compiled and used like all other predicates. XSB, by default, indexes all compiled predicates on the first argument, using the main functor symbol. This means that a call to a predicate which is bound on the first argument will quickly select only those facts that match on that first argument. This entirely avoids looking at any clause that doesn't match. This can have a large effect on execution times. For example, assume that p(X,Y) is a predicate defined by facts and true of all pairs \<X,Y\> such that  1 \<= *X* \<= 20, 1 \<= *Y* \<= 20. Assume it is compiled (using defaults). Then the goal:

```prolog
    \| ?- p(1,X),p(X,Y).
```
will make 20 indexed lookups (for the second call to p/2). The goal

```prolog
    \| ?- p(1,X),p(Y,X).
```
will, for each of the 20 values for X, backtrack through all 400 tuples to find the 20 that match. This is because p/2 by default is indexed on the first argument, and not the second. The first query is, in this case, about 5 times faster than the second, and this performance difference is entirely due to indexing.

XSB allows the user to declare that the index is to be constructed for some argument position other than the first. One can add to the program file an index declaration. For example:

:- index p/2-2.\

p(1,1).\
p(1,2).\
p(1,3).\
p(1,4).\
...\

When this file is compiled, the first line declares that the p/2 predicate should be compiled with its index on the second argument. Compiled data can be indexed on only one argument (unless a more sophisticated indexing strategy is chosen.)

------------------------------------------------------------------------

# Dynamically Loaded Fact Files
The above strategy of compiling fact-defined predicates works fine for relations that aren't too large. For predicates defined by thousands of facts, compilation becomes cumbersome (or impossible). Such predicates should be dynamically loaded. This means that the facts defining them are read from a file and asserted into XSB's program space. There are two advantages to dynamically loading a predicate: 1) handling of much larger files, and 2) more flexible indexing. Assume that the file qdata.P contains 10,000 facts defining a predicate q(X,Y), true for  1\<=*X*\<=100, 1\<=*Y*\<=100. It could be loaded with the following command:

```prolog
    \| ?- load_dyn(qdata).
```
XSB adds the \`\`.P'' suffix, and reads the file in, asserting all clauses found there. Asserted clauses are by default indexed on the first argument (just as compiled files are.)

Asserted clauses have more powerful indexing capabilities than do compiled clauses. One can ask for them to be indexed on any argument, just as compiled clauses. For dynamic clauses, one uses the executable predicate *index*/3. The first argument is the predicate to index; the second is the field argument on which to index, and the third is the size of hash table to use. For example,

```prolog
    \| ?- index(q/2,2,10001).
```
```prolog
    yes
    \| ?- load_dyn(qdata).
    \[./qdata.P dynamically loaded, cpu time used: 22.869 seconds\]
```
```prolog
    yes
    \| ?-
```
The index command set it so that the predicate *q*/2 would be indexed on the second argument, and would use a hash table of size 10,001. It's generally a good idea to use a hash table size that is an odd number that is near the expected size of the relation. Then the next command, the *load*<sub>*d*</sub>*yn*, loads in the data file of 10,000 facts, and indexes them on the second argument.

It is also possible to put the *index* command in the file itself, so that it will be used when the file is dynamically loaded. For example, in this case the file woulstart with:

:- index(q/2,2,10001).\

q(1,1).\
q(1,2).\
q(1,3).\
...\

Unlike compiled cclauses, asserted clauses can be indexed on more than one argument. To index on the second argument if it is bound on call, or on the first argument if the second is not bound and the first is, one can use the index command:

:- index(q/2,\[2,1\],10001).\

This declares that two indexes should be build on *q*/2, and index on the second argument and an index on the first argument. If the first index listed cannot be used (since that argument in a call is not bound), then the next index will be used. Any (reasonable) number of indexes may be specified. (It should be noted that currently an idex takes 16 bytes per clause.)

Managing large extensional relations load_dyn, load_dync, cvt_canonical. Database interface, heterogeneous databases (defining views to merge DB's)

------------------------------------------------------------------------

Indexing Static Program Clauses
======================================================================================================

For static (or compiled) user predicates, the compiler accepts a directive that performs a variant of  *unification factoring* \[#!DRRSSSW94!#\].

....

------------------------------------------------------------------------

# Bibliographic Notes
The idea of using program transformations as a general method to index program clauses was presented in a rough form by \[#!HM89!#\] \[#!DRRSSSW94!#\] extented these ideas to factor unifications ...\

------------------------------------------------------------------------
