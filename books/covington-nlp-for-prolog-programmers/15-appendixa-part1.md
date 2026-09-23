# AppendixA_Part1

<!-- page 297 -->
**Review of Prolog**

**A.1 BEYOND INTRODUCTORY PROLOG**

This appendix is not intended to teach you Prolog, but rather to review the language and present some topics that are often skipped in introductory courses. Some knowledge of ~ Prolog is presumed from the beginning.

The emphasis will be on the data-structuring features of Prolog. I won’t say much about how these features are used in natural language processing (that’s what the rest of the book is for). In fact I will use plenty of examples that do not, by themselves, do anything useful at all. This is intentional. To understand what Prolog actually makes the computer do, it helps to look at the features of the language outside their usual context.

An important concern here will be to show that Prolog is simpler than you probably thought. Many details which you probably learned separately will turn out to be instances of just a few systematic principles.

A.2 BASIC DATA TYPES

A.2.1 Terms

<!-- page 298 -->
Prolog is a language for data as much as for procedures. Every data item that can exist in Prolog has a written representation. In this respect Prolog is like Lisp and unlike languages such as Pascal, in which some data types, such as arrays, have no written representations (though their elements do).

Prolog data items are called TERMS. The syntax of terms in Prolog

is modeled on the syntax of expressions in C. Terms are of three kinds: variables, atomic terms (NUMBERS and ATOMS), and compound terms (STRUCTURES).

Notice a difference between Prolog and Lisp terminology. In Lisp, the word atom refers both to symbols such as ABC and to numbers such as 45. In Prolog, atom normally means ‘symbol.’ Numbers are atomic terms, but they are not atoms.

Atoms normally begin with a lowercase letter and contain letters, digits, and/or the character ‘_’. Examples are x, xAB_CDE, and alanda2.

Any series of characters enclosed in single quotes is an atom. Thus:

‘this is a long atom with spaces and @#$!#$ in it’

**A zero-length atom is written ‘’.**

Single quotes occurring within single quotes are written double. In some implementations, backslashes within single quotes are also written double; consult your manual.

**An atom consisting entirely of special characters from the set**

**+- * /\ * c= >7~ 1 .?@#S &**

does not need quotes. Thus :-, -->, and \+ are (or can be) atoms. (See your manual to confirm that your Prolog uses exactly this set of characters.) Exercise A.2.1.1

Which of the following are Prolog atoms (symbols)?

abc123

list_all

list-all

‘ab cd’

"ab cd"

```prolog
                                                            ?-
iene >
           --def-->
                        23
                                     "23"
                                                 "242!
                                                             (2+2)
```

Exercise A.2.1.2

Which of the items in the previous exercise are atomic terms?

Exercise A.2.1.3

Why are there quotes in write (‘One’) but not in write (one)?

Exercise A.2.1.4

Are abc and ‘abc’ the same atom? Use the computer to make sure of your answer, and

state how you did so.

**A.2.2 Internal Representation of Atoms**

<!-- page 299 -->
Atoms are not character strings; they are locations in a symbol table. That is, the computer stores only one copy of each atom, no matter how many times it occurs in the program. All occurrences of the atom in the program are then replaced by pointers to its location in the symbol table.

This means that, during program execution, the comparison

abracadabraabracazam = abracadabraabrashazam

takes no more time than

az=hb

because in each case, the pointers get comparéd rather than the strings of characters. The real comparison—that is, the determination whether the strings were identical—was done once and for all when the atoms were first placed in the symbol table.

Placing atoms in the symbol table is known as INTERNING or TOKENIZING the atoms. At every moment the symbol table contains all the atoms that exist—whether they are part of the program itself, or data being processed by the program, or anything else.

Exercise A.2.2.1

Which of the following built-in Prolog predicates can cause new atoms to be added to the

symbol table? Explain why.

read/1

write/1l

consult/1

reconsult/1

name/2

assert/1

**A.2.3 Compound Terms (Structures)**

**A STRUCTURE consists of a functor with one or more ARGUMENTS, such as £ (a,b,c).**

The arguments can be terms of any type, including other structures. The functor is an atom with a specific number of argument positions; £ with one argument and f with two arguments are not the same functor.

In Prolog, a functor is merely a data-structuring device; it does not refer to a procedure that is to be applied to the arguments. It is just a kind of label. A structure such as f (g (h, i) ,

j (k, 1) ) represents a treelike data object that could be diagrammed as:

h

i

k

1

The arity of a functor is the number of arguments it takes. To refer to a functor, instead of saying “f, with 3 arguments” or “f£, with arity 3” you can say f/3.

<!-- page 300 -->
When a structure contains other structures, such as f (a, b(c,d),e), the outermost functor (£/3, in this case) is called the PRINCIPAL FUNCTOR of the structure. Exercise A.2.3.1

Draw tree diagrams of the following structures:

pred(al,a2,a3,a4)

```prolog
g(x(y,Z,w),a(p,xr(e(f£))))
                              24+3*4
```

(Hint: Recall that + and * are functors that are written between their arguments.)

Exercise A.2.3.2 Suppose you are creating a Prolog knowledge base about a family tree. Would it make sense to use both parent /2 and parent /1 in the same program? What would each of them mean?

A.2.4 Internal Representation of Structures

In the computer, a structure is a linked tree made of pointers to its substructures and to entries in the symbol table. For example, the structure £ (a (b,c) ,a,d) is represented as:

—

£

Symbol

table

a

————>] e

q

e

e

e

e

°

b

Cc

d

That is, each structure is represented by a CELL containing pointers to the functor and the arguments. The functor is always represented by an atom, i.e., an entry in the symbol table; the arguments can be terms of any type. The cell also contains other information not shown in the diagram, such as the arity of the functor. [If you are not familiar with this type of diagram, consult a data structures textbook. See also Covington, Nute, and Vellino (1988, ch. 7), and O’Keefe (1990, ch. 3).]

Exercise A.2.4.1 Draw both a tree diagram, and a cell-and-pointer diagram like the diagram above, for each of the following terms:

£(a,b)+g(c,d)

E(£(£(£(£(£(g))))))

<!-- page 301 -->
24+3*4 Note that to represent a number, Prolog does not use a pointer; instead it stores the number itself in the cell. Note also that, unlike the symbol table, the tree diagram of £ (f(a) ) contains £ in two different places.

Exercise A.2.4.2 Which structure takes more memory, f(a,b,c,d,e) or f (abcde, abcde, abcde)? Explain how you can answer this question without knowing the amount of memory needed for a character, a pointer, or a cell on any particular computer.

A.2.5 Lists

**A very useful kind of structure takes the form**

**; UY**

c

C] This structure consists of a, b, and c strung together; it is called a LisT. Here [] (pronounced “nil”) is a special atom that denotes the end of the list. By itself, [] denotes an EMPTY LIST (a list with no elements). Notice that the first argument of each dot functor (.) is an element, and the second argument is another list. That is: every list consists of an element plus another list or []. If the whole thing does not end in [] it is called an IMPROPER LIST (like a dotted pair in Lisp). There is a shorthand notation for lists, illustrated on the right below:

(a, [])

=

{a] w(a,.(b,.(c,[])))

=

[a,b,c]

-(a,b)

=

[alb]

% an improper list (a,.(b,.(c,d)))

=

[a,b,cld]

% another improper list

Every nonempty list has the dot (.) as its principal functor. The big advantage of lists over multiargument structures is that you can process a list without knowing how many elements it has. Any nonempty list will unify with . (X,¥) (more commonly written [X|Y]), regardless of the number of elements.

Exercise A.2.5.1 What is the most concise way of writing [x,y1[]]?

Exercise A.2.5.2 Write .(.(a,.(b,[])),-(c,{]))

<!-- page 302 -->
in ordinary list notation (with square brackets and commas) and draw a tree diagram of it.

Ap

A.2.6 Internal Representation of Lists Assuming the dot functor works as just described, the internal representation of the Ij

[a,b,c] should be:

[]

But lists are very common in Prolog, and all those pointers to the dot functor waste space. Accordingly, almost all Prologs use a more compact representation of lists in which [a,b,c] would be represented instead as”

C]

which is like the internal representation used in Lisp. That is, the dot functor is, internally, no functor at all.

Regardless of which representation your Prolog uses, lists will behave as if they were held together by the dot functor in the originally described way. But the compact representation saves memory. In particular, it makes [a,b,c] take up less space than a listlike structure held together by some functor other than the dot, such as f(a, f(b, f(c,[]))).

Exercise A.2.6.1

Assuming that each pointer occupies 4 bytes, how much space is saved by representing

<!-- page 303 -->
[a,b,c,d,e,£,g,h,i,3j] the compact way instead of the original way? A.2.7 Strings

**A string such as "abc" is simply another way of writing a list of the ASCII codes of the**

characters, in this case [97, 98,99]. Do not be deceived; a string is a list of numbers, not characters. Like a list, a string can have zero length (written "").

**The built-in predicate name/2 interconverts atoms and strings. Some examples:**

?- name(abc,What). What = [97,98,99]

```prolog
% that is, "abc"
```

?- name(What,"abc"). What = abc

This gives you a way to retrieve the character representation of an atom, or to construct a new atom out of characters strung together. (In C-Prolog and Quintus Prolog, a string that validly represents a number, such as "-234.5", will be converted into a Prolog number, not an atom. In ALS Prolog, ESL Prolog-2, and LPA Prolog, name/2 always converts strings into atoms, not numbers.) Exercise A.2.7.1

What is displayed by the Prolog query ‘?- write("abc") .’? Why?

Exercise A.2.7.2

In what situation does name/2 produce a zero-length atom?

Exercise A.2.7.3

Show how to use name/2 to convert "abracadabra" into an atom.

Exercise A.2.7.4

Show how to use name/2 to find out the ASCII code of the letter q.

A.2.8 Charlists

The draft ISO standard (Scowen 1992) does not contain strings. Instead, programmers are encouraged to use lists of one-character atoms, [1,i,k,e,’ ‘',t,h,i,s], which I call charlists. The obvious advantages of charlists is that they are always output in readable form, and they do not rely on ASCII numeric codes.

The proposed standard calls for a built-in predicate atom_chars/2 that interconverts atoms and charlists:

?- atom_chars(abc,What). What = [a,b,c]

<!-- page 304 -->
?- atom_chars (What, [a,b,c]). What = abc Quintus Prolog presently has a built-in predicate called at om_chars, but it doesn’t q what the standard calls for; instead, it interconverts atoms and strings. Exercise A.2.8.1

Define a recursive procedure string_chars/2 that will interconvert strings and charlists.

(Its first argument should be a string, and its second argument, a charlist; either argumeni

can be uninstantiated.) (Hint: only two clauses are needed.)

:

Exercise A.2.8.2

Using string_chars/2, implement atom_chars/2. Don’t worry about correct han-"

dling of numbers (e.g., "23").

**A.3 SYNTACTIC ISSUES**

A.3.1 Operators

Some functors such as + can be written between their arguments, in which case no parentheses are needed. Thus 2+3 is equivalent to + (2,3). Such functors are called INFIX OPERATORS.

|

In Prolog, operators need not stand for operations. Thus 2+3 does not mean ‘add 2 and 3’—it’s just a data structure with functor + and arguments 2 and 3. The built-in predicate is, and some others, can be used to evaluate the structure 2+3, giving the number 5. Apart from this, 2+3 has nothing to do with 5. Here Prolog differs from most other programming languages, which evaluate ‘2+3”’ as ‘5’ immediately wherever it occurs.

‘

There are also PREFIX operators, which come before their arguments, and POSTFIX operators, which come after their arguments. An infix operator has two arguments; a prefix or postfix operator has only one.

The built-in predicate display/1 displays any structure in ordinary (non-infix) notation, treating any operators within it as if they were ordinary functors. Exercise A.3.1.1

What is displayed by the query ‘?- display (2+[a,b]).’? Try it on the computer and

explain your results.

Exercise A.3.1.2

Consult the manual for the Prolog system that you are using, and give examples of predefined

prefix and postfix operators (if any).

**A.3.2 The Deceptive Hyphen**

<!-- page 305 -->
Unlike the underscore mark, the hyphen (‘-’) cannot occur in an atom or variable name. If you try to put it there, you will get a structure in which the hyphen is an infix operator. That is, abc-def is not an atom; it’s the structure - (abc , def)

Because structures can occur in most of the places where atoms can occur, the compiler will not notice that you have made a mistake, but you will eventually get unexpected results.

Exercise A.3.2.1

Draw a tree diagram of this-functor(a,b).

Exercise A.3.2.2

Consider the following knowledge base, in which the programmer has put hyphens in func-

tors even though Prolog does not permit them there.

```prolog
in-usa(X) :- in-texas(X).
                                        % Caution: risky syntax!
in-usa(X) :- in-georgia(X).
in-texas (amarillo).
in-georgia(macon) .
```

In spite of the syntax error, the knowledge base answers queries correctly. Why?

**A.3.3 The Dual Role of Parentheses**

Parentheses serve two purposes in Prolog: to enclose the arguments of a functor, and to show how a term is to be divided up. The parentheses in a+ (b+c) show that b+c is a term. Otherwise it wouldn’t be; the first + would join a to b and the second + would join a+b toc!

You are free to write parentheses around any term at any time. For example, (((a))) is the same term as a. The extra parentheses in

?- display( (b,c) ).

show that ‘b,c’ is to be treated as a single term even though it contains a comma. Otherwise display would be taken as having two arguments.

Exercise A.3.3.1

Demonstrate, using the computer, that ( ((a))) is equivalent to a.

**A.3.4 The Triple Role of Commas**

This, of course, begs the question of what that comma is doing if it isn’t separating arguments. The comma is, in fact, a right-associative infix operator. The term (a,b,c,d,e,f) is really a, (b, (c, (d, (e,£))) (analogous to a+ (b+ (c+ (d+ (e+f£))), but with commas instead of pluses). The Prolog rule

a:i- b, c, d.

<!-- page 306 -->
Mn early versions of Arity Prolog, at+(b+c) has to be written as at (b+c), because if any functor is written immediately before ‘(’, Arity Prolog assumes that it is a functor of the ordinary kind (not an operator) with its arguments following in parentheses. This problem has been corrected in version 5.0. is really

a:- (b, c, a).

or rather:

Knowing this structure is crucial if you want to write a Prolog program that processes other Prolog programs.

The comma has yet a third role in lists. In [a,b,c] the comma is neither an argument separator nor an infix operator; it is a list-element separator. Whenever a Prolog compiler encounters a comma, it has to figure out which of these three roles the comma is playing.

Some nonstandard versions of Prolog use the comma only as the argument separator; they use & as the infix operator, and something else as the list element separator. Exercise A.3.4.1

```prolog
Doesa :- b, c, dunify with x :- y?
```

Exercise A.3.4.2

Give an example of a Prolog term in which there are all three kinds of commas.

Exercise A.3.4.3

If a comma is in a position where it can be either an argument separator or an infix operator,

which does your computer take it to be? How do you know?

A.3.5 Op Declarations

You can define operators for yourself by specifying the functor you wish to make into an operator, its associativity, and its precedence.

For example, a+b+c+d is interpreted as ( (a+b) +c) +d, so + is said to be LEFT- ASSOCIATIVE. And a+b*c is interpreted as a+(b*c), so + is said to have higher PRECEDENCE than * (the operator with higher precedence has larger parts of the term as arguments).

To make & into a right-associative infix operator with precedence 500, execute the query:

<!-- page 307 -->
:- op(500,xfy,’&’). Here ‘:-’ is what you write at the beginning of a query that is to be executed—not stored in the knowledge base—as the program is read in. See your Prolog manual for further details.

Note that by itself this op declaration does not give any meaning to ‘&’; it merely allows it to be written between its arguments.

Exercise A.3.5.1

Which has higher precedence, - or / ?

Exercise A.3.5.2

Which has higher precedence, : - or the comma?

Exercise A.3.5.3

We said earlier that (a,b,c) = (a, (b,c)). Is the comma left-associative or right-

associative?

**A.4 VARIABLES AND UNIFICATION**

A.4.1 Variables

6° Prolog variable names begin with upper-case letters or

Examples are X, Y, WhatEver, 123.

Like-named variables occurring in the same term are considered to be the same variable. (Recall that a rule or a fact is one term.) Apart from this, variable names have no significance. In fact, in memory, variables have no names, only locations. This explains why, if you ask Prolog to output a term containing variables, the variables will have arbitrary names such as __0123.

The anonymous variable, written ‘_’, is considered unique wherever it occurs; successive anonymous variables are not the same variable even if they occur in the same term.

Exercise A.4.1.1

Of the three terms £ (X,Y, Y),

£(..3,_qg,_q), and £ (X,Y, _), which two are equivalent?

A.4.2 Unification

Two terms can be UNIFIED (matched) if they are alike or cari be made alike by INSTAN- TIATING (giving values to) variables. (Here instantiation includes the ability to make one variable the same as another.) For example:

f (X,Y) unifies with £ (a,b) instantiating X=a, Y=b.

£ (X,Y) unifies with £(Z,Z) by making X, Y, and Z become the same variable.

£(X,X) does not unify with £ (a,b) because X cannot have two different values

<!-- page 308 -->
at the same time in the same term. Unification is order-independent; if you unify a set of terms, you get the same Tesu regardless of the order in which the terms are encountered. Much of the power o; Prolog, particularly for natural language processing, comes from the order-independence of unification. a Exercise A.4.2.1 Unify the following pairs of terms, or show why the unification cannot be performed:

£(X,Y)

with £ (a,b) £(X,Y)

with g(X,Y) f(a,b,c) with £(a,xX) f(a,b,c) with £(’a’,x) f(a,b,c)

with £(’a

*,X) f(a,b,c)

with £(((’a‘)),X) [a,b,c,d] with [0]_234] [a,b,c,d] with [X,Y|Z] [a,X,b,Y] with [Z,a,B,b] [a,X,Y,Y¥] with [Z,a,b,c] [a,b,c,d] with [X,Y,Z] (2+3)+X

with Q+R (24+3)+X

with 2+(3+4)

**A.5 PROLOG SEMANTICS**

A.5.1 Structure of a Prolog Program

**A Prolog program is a file containing clauses and/or queries in the appropriate format**

for the Prolog reader. CLAUSES contain information to be stored in the knowledge base. Clauses are of two kinds. Facts are atoms or structures whose principal functor is not ‘:-’ or ‘?-’:

green(kermit). ready_to_go. kermit likes piggy.

(assuming likes is an infix operator)

RULEs consist of a term, then the symbol ‘: -’, then one or more terms joined by commas:

green(X) :- wet(X). piggy likes X :- handsome(X), amphibian (X).

For some purposes the fact green (kermit) is equivalent to the rule green (kermit)

a :- true, where true is a built-in predicate that succeeds with no other action.

4 The HEAD of a rule is the term to the left of ‘:-’; the Bopy is the term on the

<!-- page 309 -->
| right (which can be a series of terms joined by commas). The body of a fact is true.

**A PREDICATE is defined by a set of one or more clauses whose heads have the same**

**principal functor. A predicate or one of its clauses is often referred to as a PROCEDURE.**

Unlike other languages, Prolog lets the same procedure have more than one definition; each clause is one of its definitions. Sometimes the clauses give ways of handling different arguments; sometimes they give alternative ways of handling the same argument.

**A QUERY is a request for the computer to do something. When a query occurs in**

the program file, it is preceded by ‘:-’ (with nothing else on the left) thus:

:- write(’Program

is loading...’).

The Prolog system loads (CONSULTS) a file by reading clauses and queries from it one by one. The clauses get stored in memory; the queries get executed immediately, the moment they are encountered.

The draft ISO standard does not specify how to consult a file. Traditionally, Prolog has had three built-in predicates:

e consult (filename) reads the file into memory for the first time;

e reconsult (filename) reads the file again after it has been edited; it discards

previously existing predicates from memory when it encounters new definitions of

the same predicates;

:

e compile (filename), if available, is like reconsult except that the code is

compiled rather than interpreted, and thus will run faster.

In most Prologs, if you consult the same file twice, you will end up with two copies of each clause in memory. This does not happen with reconsult, but in some older Prologs (such as Arity 4.0), reconsul1t requires all the clauses for each predicate to be contiguous, and if they aren’t, it will discard all but the last contiguous group. In Quintus Prolog, consult and reconsult are exactly alike; neither of them will produce duplicates if done repeatedly, and neither of them requires clauses to be contiguous (but if style checking is turned on, you will get warnings about discontiguous predicates).

Exercise A.5.1.1

What is the head of each of the following clauses?

```prolog
green(kermit).
green(X) :- wet(X).
```

kermit likes piggy.

Exercise A.5.1.2

Explain what happens when the following file is consulted. Assume that the knowledge

base is initially empty.

```prolog
:- write(’Starting’), nl.
```

:- green(kermit), write(’Succeeded the first time’), nl.

```prolog
green(kermit).
```

<!-- page 310 -->
:- green(kermit), write(’Succeeded the second time’), nl. A.5.2 Execution

Here is how Prolog executes a query.

e If the query is a series of terms joined by commas, the individual terms are treated. as queries (SUBGOALS) and executed one by one, in sequence. That is, to execute a

?- green(X), write(X).

the Prolog system executes green (X) and then write (X). Notice that the whole query is itself a term, and hence the two X’s here are the same variable. e If the principal functor of the query is a built-in predicate, the system performs the appropriate system-defined action:

?- write(hello).

e Otherwise, the system finds the first clause whose head can unify with the query and performs the unification. If the clause is a fact, no other action is performed. If the clause is a rule, its right-hand side is treated as a new query. Thus the rule

a(X) :- b(X), c(X).

transforms the query

?- a(zzz).

into the query

?- b(zzz), c(zzz).

A fact by itself can do useful work. The query ‘?- green(X) .’ can be answered by the fact green (kermit), which instantiates X to kermit.

Exercise A.5.2.1

Show how the query ‘?- amphibian(kermit) .’ is transformed into other queries, and ultimately solved, in the following knowledge base:

amphibian(X) :-

‘Latin name’ (X,Genus, Species),

```prolog
class(’Amphibia’,Genus).
```

‘Latin name’ (kermit,’Rana’,catesbiana).

<!-- page 311 -->
class(‘Amphibia’,’Rana’). Exercise A.5.2.2

2

**Do the same for the query ‘?- amphibian (Who) .**

**A.5.3 Backtracking**

If at any point there is no clause to match the current query, that query is said to FAIL. Execution then backs up to the nearest BACKTRACK POINT (untried alternative), undoing any unifications that took place subsequent to that point, and proceeds forward again along an alternative path.

**Alternatives exist because more than one clause can match the same query. When-**

**ever execution enters a clause and there is another clause (as yet untried) that would**

**have matched the same query, the Prolog system records a backtrack point.**

Exercise A.5.3.1

Given the knowledge base

```prolog
a(X)
       - b(X).
a(X)
       - c(X).
b(Z) :- da(Z).
b(Z) :- e(Z).
c(Y)
       :- h(Y).
e(f).
```

show exactly what goals are tried, in what order, to solve the query ‘?- a(f) .’ (You may

find it convenient to draw a treelike diagram.) Which backtrack points are left untried?

**A.5.4 Negation as Failure**

**If the query ‘?- p.’ succeeds then the query ‘?- \+ p.”’ fails, and vice versa. The**

**symbol ‘\+’ is pronounced ‘not’ and was written not in older Prologs.**

**A query that fails does not leave a variable instantiated. By definition, either**

**\+ p(X) fails or p(X) fails. Therefore the query ‘?- \+ p(X) .’ leaves X uninstan-**

tiated.

**A double \+ is a handy way of finding out whether a query would succeed, without**

**instantiating the variables in it. Thus ‘?- \+ \+ p(X) .’ succeeds if and only if p (X)**

would succeed, but does not leave X instantiated.

**To force a clause to fail, put ‘!, fail’ at the end of it. This is rarely necessary.**

**Usually, rather than write a clause that will fail in a particular situation, you simply**

**refrain from writing a clause that will succeed in that situation.**

Exercise A.5.4.1

```prolog
Is the clause £(X) :- \+ \+ \+ g(X).
```

**of any practical use? Why or why not?**

<!-- page 312 -->
Exercise A.5.4.2

What do the following clauses do? Suggest a more obvious way of doing the same thing

```prolog
not_a_list([_l_]) :- !, fail.
not_a_list(_).
```

A.5.5 Cuts

The CUT predicate, written ‘!’, tells the Prolog system to forget about some of the backtrack points. Specifically, it discards all backtrack points that have been recorded since execution entered the current clause. This means that, after executing a cut,

e. it is no longer possible to try other clauses as alternatives to the current clause;

e it is no longer possible to try alternative solutions to subgoals preceding the cut in

the current clause.

This applies, of course, only to the goal that caused execution to enter the current clause — in the first place; it does not permanently change the knowledge base.

**An example will make this clearer. Consider the program:**

/* Clause 1 */

```prolog
a(X) :- b(X)
```

/* Clause 2 */

```prolog
a(w).
```

/* Clause 3 */

```prolog
b(X) :- c(X), !, d(X)
```

/* Clause 4 */

bly). /* Clause 5 */

```prolog
b(w).
```

/* Clause 6 */

```prolog
c(w).
```

/* Clause 7 */

```prolog
d(z).
```

The query ‘?- b(y).’ succeeds. It first matches clause 3, but c(y) fails and execution backs out of clause 3 before the cut is executed, and then tries clause 4, successfully.

The query ‘?- b(w) .’ fails. Execution enters clause 3, c (w) succeeds, the cut is executed, and then d(w) fails. But because of the cut, it is impossible to try any other clauses for c or b, so the fact b(w) is ignored.

The query ‘?- a(w) .’ however succeeds. Clause 1 invokes clause 3, which fails just as before. However, the cut in clause 3 does not impair backtracking out of clause 1, so execution backtracks from clause 1 to clause 2 and then succeeds. Exercise A.5.5.1

Given the knowledge base

(X)

(X)

:

(a).

(a).

U4. Qi Fh kh

<!-- page 313 -->
what is the result of executing the query ‘?- f(a) .’? Sec. A.5

Prolog Semantics

**299**

Exercise A.5.5.2

Given the knowledge base:

what is the effect of each of the following queries?

?- X(aa). ?- x(cc). ?- x(What), write(What), nl, fail.

Exercise A.5.5.3

Consider the knowledge base:

**a:- b, my_cut, c(1).**

**a:-d.**

b. c(0) d. my_cut

```prolog
:-
  !
```

What happens when the user types the query ‘?- a.’? What if my_cut in the first line is changed to ‘!’?

**A.5.6 Disjunction**

If two subgoals are joined by a semicolon (; ) rather than a comma, they are alternatives. The Prolog system executes the first subgoal and remembers the second subgoal as an untried alternative. Thus

**In this book the semicolon is rarely used. It is usually preferable to use alternative**

<!-- page 314 -->
clauses. A.5.7 Control Structures Not Used in This Book

Most Prologs (including the draft ISO standard, but not Arity) have an “if-then” structure of the form (p -> q ;

r) (pronounced “if p then g else r”’). To execute this structure, the computer first tries to execute p. If p succeeds, it then executes q; otherwise executes r. In either case it does not leave a backtrack point.

The “if-then” is not used in this book. Instead of

f:- (p -> q;nr).

this book uses

**f:-p, !, q.**

fo:- 4.

Arity Prolog has limited-scope cuts called “snips,” written [!

!]. Once execution has progressed through the closing snip !], it is no longer possible to backtrack to any alternatives within the snips. To implement essentially the same thing in other Prologs, we can define a metapredicate once:?

once(Goal) :- Goal, !.

Here Goal can be a compound goal (a set of goals joined by infix commas). So the equivalent of [!, p, gq, r,

!] is once((p,q,r)), but once can be used in practically any Prolog, not just Arity. In the draft ISO standard, once is a built-in predicate.

**A.5.8 Self-Modifying Programs**

Prolog programs can modify themselves. The built-in predicate asserta/1 inserts a clause before the preexisting clauses for its predicate (if any). For example,

?- asserta( (£(X) :- g(X)) ).

inserts the rule

£(X)

:- g(X) in front of the first preexisting clause for

£/1. (Notice the extra parentheses that are necessary whenever the argument of asserta contains ‘:-’.) The predicate assertz/1 does the same thing, except that it would put £(X) :- g(X) after the preexisting clauses for f /1.

**The built-in predicate retract /1 removes a clause from the knowledge base.**

Specifically, it removes the first clause that matches its argument, or fails if there is no

| such clause. For example,

|

?- retract (green(X)).

<!-- page 315 -->
2Some older Prologs require Goal on the right-hand side to be written as call (Goal). removes the first clause that matches green (X), simultaneously unifying X with whatever was in the argument position. Because of this unification, retract can be used to retrieve information while deleting it from the knowledge base. Like asserta, assertz, and all other Prolog functors, retract requires extra parentheses if its argument contains ‘:-’ or a comma. To retract all the clauses of £/2, you can use

?- abolish(f/2).

**(or in ALS Prolog, abolish(f,2)).**

One extremely important point must not be forgotten:

**asserta, assertz, and retract are not a general-purpose way of stor-**

ing temporary data.

Their use is justified only in situations that reflect a genuine, permanent change to the knowledge contained in the program. The normal way to hold information temporarily (analogous to storing it in a Pascal or C variable) is to pass it along in the arguments of procedures (see the section on repetitive algorithms below).

Exercise A.5.8.1

What would be in the knowledge base after execution of the following four queries? Assume that beforehand, there were no clauses for green.

?- assertz(green(kermit)). ?- asserta(green(eggs+ham)). ?- assertz(green(cheese)). ?- asserta(green(grass)).

Exercise A.5.8.2

Which of the following queries will successfully retract the clause ‘£(X) :- g(X), h(X) .’? Explain why.

<!-- page 316 -->
?- retract (f£(X)). ?- retract((f(W) :- g(W), H(W))). ?- retract ((f(WXYZ) :- g(WXYZ), h(Q))). ?- retract (f(X) :- Y). ?- retract ((f£(X) :- Y)). ?- abolish(f/1). ?- abolish(f/3). A.5.9 Dynamic Declarations

In Quintus Prolog and in the draft ISO standard, if any of the clauses for a predicate are to be asserted or retracted, the program must contain a declaration such as

:- dynamic £/2.

(where f /2 stands for predicate £ taking 2 arguments) before the clauses for the predicate’ (if any). This tells the compiler not to compile the clauses into a form that cannot be © recognized at run time. In fact Quintus does not compile them at all; it runs them” interpretively.

The only exception is that if a predicate is created entirely by asserting, it is automatically dynamic and need not be declared.

Dynamic declarations are not required by abolish; you can abolish any predicate, even a compiled one.

**A.6 INPUT AND OUTPUT**

The input-output system described here is the traditional one from Edinburgh (DEC- 10) Prolog. Virtually all present-day Prolog implementations support it, but the draft ISO standard introduces a different input-output system only partly compatible with the” original one. When in doubt, check your manual.

A.6.1 The Prolog Reader

Built into Prolog is a procedure for reading terms from input devices (files, the keyboard, etc.) and converting them into their internal representations. This procedure is called the READER and you can access it through the built-in predicate read/1. The reader is also used by consult and reconsult and by the routine that accepts queries that you type on the keyboard.

read/1 reads, from the standard input file, exactly one Prolog term followed by a period, then unifies its argument with this term. The term can be of any kind whatsoever.

The reason for ending with a period is that a term can occupy more than one line. After the period there must be a blank, or a comment, or the end of the line; thus the period in the middle of the term 3.2 does not denote end of term.

The character % (not in quotes) makes the reader ignore everything until the beginning of the next line. The sequence /* makes it skip everything until after the following */. Thus both

% and / / provide ways to delimit COMMENTS. Comments are permitted not only

in programs, but

in everything that the reader reads. Generally, however, you cannot put a comment within another comment.

Extra blanks and comments are permitted anywhere, so long as they do not interrupt a number, atom, functor, or quoted string, nor come between a functor and the parenthesis that introduces its arguments. Thus f (a) can be written

£(

a ) but notas f (a).
