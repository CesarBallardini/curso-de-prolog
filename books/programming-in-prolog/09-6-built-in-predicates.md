# 6 Built-in Predicates

<!-- page 133 -->
Built-in Predicates

```prolog
In this chapter we introduce some of the built-in predicates that a Prolog system
might provide. What do we mean when we say that a predicate is built-in? We mean
that the predicate's definition is provided in advance by the Prolog system, instead
of by your own clauses. Built-in predicates may provide facilities that cannot be
obtained by definitions in pure Prolog. Or they may provide convenient facilities just
to save the programmer from having to define them. We have already encountered
some built-in predicates: the predicates for reading and writing discussed in Chapter
5. Also, the "cut" can be regarded as a built-in predicate.
    The input/output predicates illustrate the fact that a built-in predicate may have
"side effects". That is, satisfying a goal involving the predicate may cause changes
apart from the instantiation of the arguments. Another important fact about built-
in predicates is that they may expect particular sorts of arguments. For instance,
consider the predicate "<", defined so that X < Y succeeds if the number X is less than
the number Y. Such a relation cannot be defined in Prolog without some outside help
that knows something about numbers. So "<" is provided as a built-in predicate, and
its definition involves the use of some underlying machine operation for testing the
comparative size of numbers (represented as binary patterns, or whatever).
    What should happen if we introduce a X < Y goal where X is an atom, or even if
both X and Y are uninstantiated? The definition in terms of the machine will simply
not apply. So we must stipulate that X < Y is only a sensible goal if both X and
Y are instantiated to numbers when an attempt is made to satisfy it. What happens
if this condition is not met will depend on the individual Prolog implementation.
One possibility is that the goal will simply fail. The other possibility is that an error
message will be printed out, and the system will take some appropriate action (like
abandoning trying to answer the current question).
```

<!-- page 134 -->
## 6.1 Entering New Clauses

```prolog
When you write a Prolog program, you will want to tell the system what clauses
to use, as well as ask questions about them. Surprisingly, Standard Prolog does not
specify a uniform way to do this, which means that different implementations will
provide different features. In the following, we describe some ways that are com-
monly used in Prolog systems. You may want to type in new clauses at the keyboard,
or to tell Prolog to take clauses from a file that you have prepared in advance. In fact,
these two operations look the same from Prolog's point of view, because the com-
puter keyboard and display is seen as just another file, having the name user. There is
one basic built-in predicate for reading in new clauses: consult. In addition, there is
a convenient notation for when you want to read in clauses from more then one file:
the list notation. If you are interested, a simplified definition in Prolog of consult is
given in Section 7.13.
consult(X)
The built-in predicate consult is meant for those situations when you want the clauses
in some file (or to be typed at the terminal) to replace all existing clauses for the same
predicates. The argument must be an atom giving the name of the file the clauses are
to be taken from. Which atoms constitute a legal file name will, of course, depend on
your particular computer. Examples of possible consult goals for various computers
are:
    ?- consult(myfile).
    ?- consult('/usr/john/pl/chaf).
    ?- consult('\\john\\pl\\chat').
    ?- consult('lib:iorout.pl').
See if you can recognise one of these filename conventions as one you normally use
on your computer. Notice that the character \ has to be doubled when it is typed
inside a Prolog quoted atom.
    If a question is found in the file, this will be treated just like an ordinary ques-
tion. It does not usually make sense to interleave questions with new clauses in a file,
except to do things like declare new operators and print out helpful messages.
    If you read in several files of clauses and then discover that there is a mistake in
one clause, you may be able to correct it without having to read in all the files again.
To do this, you just have to consult a file containing a correct set of clauses for the
predicate in question. You can give the corrected clauses by either typing them at
the keyboard by consult(user) or by editing a file without exiting from Prolog and
then consult-ing that file. Of course, typing in revised clauses at the terminal will
alter what Prolog sees in the database but it will not change the file that the original,
```

<!-- page 135 -->
```prolog
faulty, clauses came from! Section 8.5 shows consult being used in the development
of a program.
    consult, as defined above, does not allow you to spread the definition of a predi-
cate across more than one file. This is usually a reasonable restriction, as it normally
makes sense to keep all the clauses for a predicate in one place. If it is necessary to
distribute the clauses for a predicate over several files, Prolog implementations usu-
ally provide a way for you to announce that this is what you intend, or they provide
several consult-style predicates for different situations.
The List Notation
Prolog implementations often provide a special notation that makes it more conve-
nient to specify consult goals, especially when you want Prolog to look at more than
one file. The notation involves simply putting the file names (as Prolog atoms) into a
list, and giving that list as a goal to be satisfied. Thus the question:
    ?- [filel,file2/fred.l'/bill.2'].
is exactly equivalent to the longer version:
    ?- consult(filel), consult(file2),
      consult('fred.l'), consult('bill.2').
The list notation is purely a notational convenience, and does not offer any extra
facilities over and above those provided by consult.
```

## 6.2 Success and Failure

```prolog
In the normal course of executing a Prolog program, a goal succeeds when it can be
satisfied, and it fails when there is no way to satisfy it. There are two predicates that
make it more convenient to specify when a goal succeeds or fails. These are the true
and the fail predicates.
true
This goal always succeeds. It is not actually necessary, as clauses and goals can be
reordered or recombined to obviate any use of true. However, it exists for conve-
nience.
fail
This goal always fails. There are two places where it is helpful. One place is the "cut
fail" combination, which was described in Section 4.3. A conjunction of goals of the
form
```

<!-- page 136 -->
```prolog
    ...,!, fail.
is used to say, "if execution proceeds to this point, then one can abandon attempting
to satisfy this goal". The conjunction fails due to the fail, and the parent goal fails
because of the cut.
    Another place to use fail is where you explicitly want another goal to backtrack
through all solutions. You may want to print out all the solutions. For instance,
    ?- event(X, Y), phh(Y), fail.
would print out all the events in the database of Section 5.1.2, using event and phh
(and would then fail). See the definition of retractall in Section 7.13 for another use
of fail.
```

## 6.3 Classifying Terms

```prolog
If we wish to define predicates which will be used with a wide variety of argument
types, it is useful to be able to distinguish in the definition what should be done for
each possible type. At the crudest level, we might wish a different clause to apply
if an argument is an integer than if the argument is an atom. Or we might want one
clause to apply if the argument is instantiated and another if it is not. The following
predicates allow the programmer to put these extra conditions in his clauses.
var(X)
The goal var(X) succeeds if X is currently an uninstantiated variable. Thus we would
expect the following behaviour:
    ?- var(X).
```

*yes*

```prolog
?- var(23).
```

*no*

```prolog
?- X = Y, Y = 23, var(X).
```

*no*

```prolog
An uninstantiated variable can represent part of a structure that has not yet been
filled in. An example is the unfilled parts of the sorted tree dictionary in Section
7.1. When such structures are being examined, the predicate var can be essential to
determine whether some part has already been filled in. This can prevent the variable
from being "accidentally" instantiated to something when the intent was to examine
it. For example, in the sorted tree dictionary, one might wish to know whether there
is already an entry for some key without creating one.
```

<!-- page 137 -->
```prolog
nonvar(X)
The goal nonvar(X) succeeds if X is not currently an uninstantiated variable. The
predicate nonvar is therefore the opposite of var. Indeed, it could be defined in Prolog
by:
    nonvar(X):- var(X), !, fail.
    nonvar(_).
atom(X)
The goal atom(X) succeeds if X currently stands for a Prolog atom. As a result, the
following behaviour takes place:
    ?- atom(23).
```

*no*

```prolog
?- atom (apples).
```

*yes*

```prolog
?- atom('/us/chris/pi. 123').
```

*yes*

```prolog
?- atom(X).
```

*no*

```prolog
?- atom(book(bronte, w_h,X)).
```

*no*

```prolog
number (X)
The goal number(X) succeeds if X currently stands for a number. For example, Section
7.12 shows how we can use this predicate in the definition of a simplifier for arith-
metic expressions, where we need to know whether the expression is just a number.
atomic(X)
The goal atomic(X) succeeds if X currently stands for either a number or an atom.
Predicate atomic can be defined in terms of atom and number by
    atomic(X) :- atom(X).
    atomic(X) :- number(X).
```

## 6.4 Treating Clauses as Terms

```prolog
Prolog allows the programmer to examine and alter the program (the clauses that
are used to satisfy the goals). This is particularly straightforward, because a clause
```

<!-- page 138 -->
```prolog
can be seen as just an ordinary Prolog structure. Therefore Prolog provides built-in
predicates to allow the programmer to:
•
   Construct a structure representing a clause in the database,
•
   Add a clause, represented by a given structure, to the database,
•
   Remove a clause, represented by a given structure, from the database.
Most operations on the database can be performed by the use of these predicates,
together with the normal Prolog operations of constructing and decomposing struc-
tures. In addition to the examples given here, Section 7.8 shows some of the uses one
can make of predicates to add and remove clauses.
    Before we look at the relevant built-in predicates, it is important to see just how
a Prolog clause can be seen as a structure. For a simple fact, the structure is just the
predicate with the arguments. That is, something like
    likes(john, X)
can be seen as an ordinary structure, with functor likes, and two arguments john and
X. A rule, on the other hand, can be seen as a structure whose main functor is ":-",
with two arguments. This functor is declared as an infix operator. The first argument
is the head of the clause, and the second is the body. Thus
    likes(john, X) :- likes(X, wine)
is really just the same as
    ':-'(likes(john, X),likes(X, wine))
which is a perfectly normal structure. Finally, when there is more than one goal in a
rule, the goals are considered bound together by the functor "," (with two arguments).
This is also declared as an infix operator. Thus
    grandparent(X, Z) :- parent(X, Y), parent(Y, Z)
is really just
    ':-'(grandparent(X, Z), '/(parent(X, Y), parent(Y, Z))
    It is important to note that in Standard Prolog the following built-in predicates
do not necessarily work with all the predicates used in a program:
•
   clause (and also facilities such as listing) will only be able to find clauses for
   predicates which are "public" (quite what this means will depend on the Prolog
   implementation, but the intention is that, for instance, clauses for built-in pred-
   icates cannot be inspected; it may be possible to influence which of your own
   predicates are considered "public").
```

<!-- page 139 -->
```prolog
•
   asserta, assertz and retract will only work on the definitions of predicates which
   have been declared "dynamic" . The intention again is to prevent accidental un-
   planned changing of definitions. A predicate foo/4 can be declared as "dynamic"
   by including the following in the relevant program file (before the definition of
   foo/4 or, if there is no definition, before the code that uses asserta etc.):
       :- dynamic foo/4.
   Several predicates can be declared as dynamic on one line by separating them
   with commas, e.g:
       :- dynamic foo/4, baz/3.
    Here now are the predicates that enable the programmer to examine and alter
clauses.
listing(A)
Most Prolog systems allow you to inspect the clauses that you currently have loaded,
but the Standard does not specify how this should be done. A common approach is for
there to be a built-in predicate listing, where satisfying a goal of the form listing(A),
where A is instantiated to an atom, causes all the clauses with the atom as predicate
to be written out, as Prolog terms, on the current output file. This is how you can
check up on what clauses you currently have for some predicate. The exact format
of the output will depend on your Prolog implementation. Notice that you will see
all the clauses with that atom as predicate, regardless of how many arguments it has.
Using listing can help you discover a mistake in your program. For instance, in the
following example session, the programmer discovers that he has not defined reverse
properly.
    ?- [test].
```

*test consulted* *yes*

```prolog
?- reverse([a, b, c, d], X).
```

*no*

```prolog
?- listing(reverse).
```

*reversed], []).* *reverse ([_441 45], _38)*

```prolog
reverse(jb5, _47),
appenD(_47, [_44], _38).
```

<!-- page 140 -->
*yes*

```prolog
The listing of the reverse clauses reveals that the atom append was mis-spelled in the
program (as appenD).
clause(X,Y)
Satisfying a goal of the form clause(X, Y) causes X and Y to be matched with the head
and body of an existing clause (for a "public" predicate) in the database. When an
attempt is made to satisfy the goal, X must be instantiated enough so that the main
predicate of the clause is known. If there are no clauses for the predicate, the goal just
fails. If there is more than one clause that matches, Prolog will choose the first one.
In this case, if an attempt is made to re-satisfy the goal, the other matching clauses
will be chosen, one at a time.
    Notice that, although clause always has an argument for the body of a clause, not
every clause actually has a body. If a clause does not have a body, it is considered to
have the dummy body true. We have been calling such clauses "facts". By providing
X's and Y's that are more or less instantiated, you can look for either all the clauses for
a given predicate and number of arguments, or all the ones that match some pattern.
Thus, for instance:
    append([], X, X).
    append([A|B], C, [A|D]) :- append(B, C, D).
    ?- clause(append(A, B, C), Y).
```

*A = [], B = _3, C = _3, Y = true* *A = [_3\_4], B = _5, C = [_3\_6], Y = append(_4, _5, _6)*

*;* *no*

```prolog
The predicate clause is very important if we wish to construct programs that examine
or execute other programs (see Section 7.13).
asserta(X), assertz(X) The two built-in predicates asserta and assertz allow one to
add new clauses (for "dynamic" predicates) to the database. The two predicates act
in exactly the same way, except that asserta adds a clause at the beginning of the
database, whereas assertz adds a clause at the end. This convention can be remem-
bered because a is the first letter of the alphabet, and z is the last. In a goal asserta(X),
X must be already instantiated to something representing a clause; indeed, as for
clause, it must be sufficiently instantiated that the main predicate is known.
    It is important to stress that the action of adding a clause to the database is
not undone when backtracking takes place. Therefore, once we have used asserta or
assertz to add a new clause, that clause will only be removed if we explicitly say so
(using retract). See Section 7.8 for examples of asserta in use.
```

<!-- page 141 -->
```prolog
retract(X)
The built-in predicate retract enables a program to remove clauses (for a "dynamic"
predicate) from the database. The predicate takes a single argument, representing
a term that the clause is to match. The term must be sufficiently instantiated that
the predicate of the clause can be determined (as for asserta, clause, etc.). When an
attempt is made to satisfy a goal retract(X), X is matched with the first clause in the
database that it can be matched with, and that clause is removed. When an attempt is
made to re-satisfy the goal, Prolog searches on from that clause, looking for another
one that will match. If it finds one, the same thing happens as before. If an attempt is
made to re-satisfy it again, the search continues for another appropriate clause. And
so on. Note that, once a clause has been removed it is never reinstated, even when
backtracking tries to re-satisfy the retract goal. If at any time the search cannot find
any more matching clauses, the goal fails.
    Because the argument X is matched with a clause as it is removed, it is possible
to see exactly which clause has been removed, even if X originally stood for some-
thing with lots of uninstantiated variables in it. So one can use retract to duplicate
the function of clause, in the case that one wants to remove the clause after finding
it. This is how it is used in the definition of gensym (Section 7.8).
```

## 6.5 Constructing and Accessing Components of Structures

```prolog
Normally when we want to access a structure of a certain kind in a Prolog program,
we do so by just "mentioning" such a structure. That is, if a predicate needs to han-
dle a variety of different kinds of structures appearing in an argument position, we
normally just provide a separate clause for each kind of structure. A good example
of this is the definition of symbolic differentiation in Section 7.11. There are separate
clauses for the functors +,-,*, and so on. We have anticipated all the structures that
might appear, and have provided clauses for each one.
    In some programs we cannot anticipate all the structures that may appear. For
instance, we might want to write a "pretty print" program that can print out any
Prolog structure, using multiple lines and indentation (see Section 5.1 for a version
of such a program that only handles lists). So, for instance, we might want the term
    book(b29, author(bronte, emily), wh)
to "pretty print" as
    book
        b29
        author
```

<!-- page 142 -->
```prolog
            bronte
            emily
        wh
The important point is that we want this program to work whatever kind of structure
we give it. One possibility, of course, is to provide a clause for every functor we
can possibly think of. But this is a task that we will never finish, because in some
programs there might be infinitely many of them! The way to write this kind of
program is to use built-in predicates that perform operations on arbitrary structures.
We will now describe some of these the predicates functor, arg, and "=..". We will
also describe a predicate that works on atoms, the predicate atom_chars.
functor(T, F, N)
The predicate functor is defined in such a way that functor(T,F,N) means, "T is a
structure with functor F and arity (number of arguments) N". It can be used in basi-
cally two ways. In the first way, T is already instantiated. The goal fails if T is not an
atom or a structure. If T is an atom or structure, F is matched with the functor and N is
matched with the integer giving the arity (number of arguments) of the functor. Note
that in this context, an atom is considered to be like a structure with arity 0. Here are
some examples of goals involving functor:
    ?- functor(f(a, b, g(Z)), F, N).
```

*Z = _23, F = f, N = 3*

```prolog
?- functor(a + b, F, N).
```

*F = +, N = 2*

```prolog
?- functor([a, b, c], F, N).
```

*F =., N = 2*

```prolog
?- functor(apple, F, N).
```

*F = apple, N = 0*

```prolog
?- functor([a, b, c],'.', 3).
```

*no*

```prolog
?- functor([a, b, c], a, Z).
```

*no*

```prolog
Before we go on to look at arg, we should consider the second possible use for
functor. This occurs when the first argument of the goal (T) is uninstantiated. In this
case, both of the others must be instantiated: specifying a functor and a number of
arguments respectively. A goal of this form will always succeed, and as a result T
will become instantiated to a structure with the functor and number of arguments
provided. So this is a way of constructing arbitrary structures, given a specification
in terms of a functor and its number of arguments. The arguments of such a structure
```

<!-- page 143 -->
```prolog
constructed by functor are uninstantiated variables. Hence the structure will match
any other structure with the same functor and number of arguments.
    A common use of functor to create a structure is when we wish to make a "copy"
of an existing structure with new variables as the arguments of the principal functor.
We can encapsulate this use in the definition of a predicate copy, as follows:
    copy(0ld, New) :- functor(0ld, F, N), functor(New, F, N).
Here, two functor goals occur adjacently. If the copy goal has the first argument
instantiated and the second uninstantiated, then the following will happen. The first
functor goal will involve the first possible use of the predicate (because the first
argument will be instantiated). Hence F and N will become instantiated to the functor
and number of arguments of this existing structure. The second functor goal uses
the predicate in the second way. This time the first argument is uninstantiated, and
the information in F and N is used to construct the structure New. This is a structure
involving the same functor and number of arguments as Old, but with variables as its
components. Thus we would get interactions like:
    ?- copy(sentence(np(n(john)), v(eats)), X).
```

*X = sentence(_23, _24)*

```prolog
We shall use a combination of functor goals in this way in the definition of consult
in Section 7.13.
arg(N,T,A)
The predicate arg must always be used with its first two arguments instantiated. It is
used to access a particular argument of a structure. The first argument of arg specifies
which argument is required. The second specifies the structure that the argument is
to be found inside. Prolog finds the appropriate argument and then tries to match it
with the third argument. Thus arg(N, T, A) succeeds if the Nth argument of T is A. Let
us look at some goals involving arg.
    ?- arg(2, related(john, mother(jane)), X).
```

*X = mother (jane)*

```prolog
?- arg(l, a+(b+c), X).
```

*X = a*

```prolog
?- arg(2, [a,b,c], X).
```

*X=[b,c]*

```prolog
?- arg(l, a+(b+c), b).
```

<!-- page 144 -->
*no*

```prolog
Sometimes we will want to use functor and arg when the possible structures are
known. This is because there may be so many arguments that it is inconvenient to
specify them every time. Consider an example where we use structures to represent
books. We might have a component for the title, the author, the publisher, the date of
publication, and so on. Let us say that the resulting structures have fourteen compo-
nents. We might write the following useful definitions:
    is_a_book(book(_,
                                        )).
    title(book(T,_,_,_,_,_,_,_,_,_,_,_,
                                   ), T).
    author(book(_,A,_,_,_,_,_,_,_,_,_,
                                   ,_), A).
In fact, we can write these much more compactly as:
    is_a_book(X):- functor(X, book, 14).
    title(X, T) :- is_a_book(X), arg(l, X, T).
    author(X, A) :- is_a_book(X), arg(2, X, T).
X=.. L
The predicates functor and arg provide one way of creating and accessing arguments
of arbitrary structures. The predicate "=.." (pronounced "univ" for historical reasons)
provides an alternative way, which is useful if you want to obtain the arguments of a
structure all together, or if you want to construct a structure, given a list of arguments.
The goal X =.. L means, "L is the list consisting of the functor of X followed by the
arguments of X." Such a goal can be used in two ways, in the same way that a functor
goal can. If X is instantiated, Prolog constructs the appropriate list and tries to match
it with L. Alternatively, if X is uninstantiated, the list will be used to construct an
appropriate structure for X to stand for. In this case, the head of L must be an atom (it
will become the functor of X). Here are some examples of =.. goals:
    ?- foo(a,b,c) =.. X.
```

*X = [foo,a,b,c]*

```prolog
?- append([A|B], C, [A|D])=.. L.
```

*A = _2, B = 3, C = _4, D = _5,L = [append, [_2\_3], _4, [_2\__5]]*

```prolog
?- [a,b,c,d] =.. L.
```

*L = [V,a,[b,c,d]].*

```prolog
?- (a+b) =.. L.
```

*L = [+,a,b].*

```prolog
?- (a+b) =.. [+,X,Y],
```

*X = a, Y = b.*

```prolog
?- [a,b,c,d] =.. [X|Y],
```

<!-- page 145 -->
='.', Y = [a,[b,c,dj]*

```prolog
?- X =.. [a,b,c,d].
```

*X = a(b,c,d).*

```prolog
?- X =.. [append,[a,b],[c],[a(b,c]].
```

*X = append ([a,b],[c],[a,b,c])*

```prolog
Examples of the use of =.. are given in Section 7.12.
atom_chars(A,L)
Whereas functor, arg, and =.. are used for constructing and accessing arbitrary
structures, the predicate atom_chars is for dealing with arbitrary atoms1. Predicate
atom_chars relates an atom to the list of characters (atoms with one element) that
make it up. This can be used either to find the characters for a given atom, or to find
the atom that has some given characters. The goal atom_chars(A,L) means that "the
characters for the atom A are the members of the list L". If the argument A is instan-
tiated, Prolog creates the list of characters and tries to match them with L. Otherwise
Prolog uses the list L to make an atom for A to stand for. Example uses of atom_chars
are as follows:
    ?- atom_chars(apple, X).
```

*X = [a,p,p,l,e]*

```prolog
?- atom_chars(X, [a,p,p,l,e]).
```

*X = apple*

```prolog
In Section 9.5, we use atom_chars to access the internal structure of English words
represented as Prolog atoms.
number_chars(A,L)
This predicate is just like atom_chars except that it works with numbers, rather than
atoms. Notice that in:
     ?- atom_chars(X, ['1' ,'2', '3']).
the variable X will be instantiated to the atom '123'. If we want it to be a number
instead, we need to use number_chars. Here are some uses of number_chars:
    ?- number_chars(123.5, X).
```

*X = [T, '2% '3\*

'57

```prolog
?- number_chars(X, [T, '2', '3']).
```

<!-- page 146 -->
*X = 123* ' Some Prolog implementations that do not provide `atom_chars` provide a built-in predicate `name` which gives roughly the same functionality as `atom_chars` and `number_chars` combined.

```prolog
The actual sequence of characters produced for a number may depend on the imple-
mentation (e.g. 23 could come out as ['2'/3'/.','0']).
                                           The predicate is probably more
often used the other way around and in this use should accept a list of characters
corresponding to any way that the Prolog system would normally be able to read a
number. We use number_chars in the definition of gensym in Section 7.8.2.
```

## 6.6 Affecting Backtracking

```prolog
There are two built-in predicates that affect the normal sequence of events that hap-
pens during backtracking. Basically, "!" removes possibilities for the re-satisfaction
of goals, and repeat makes new alternatives where there were none before.
I
The "cut" symbol can be viewed as a built-in predicate that commits the Prolog
execution procedure to certain choices it has made. For more details about the "cut"
see Chapter 4.
repeat
The built-in predicate repeat is provided as an extra way to generate multiple solu-
tions through backtracking. Although it is built-in, it can be thought of as behaving
as though defined as follows:
    repeat.
    repeat:- repeat.
What is the effect of this if we put repeat as a goal in one of our rules? First of all, the
goal will succeed, because of the fact which is the first clause of repeat. Secondly,
if backtracking reaches this point again, Prolog will be able to try an alternative: the
rule that is provided as the second clause of repeat. When it uses this rule, another
goal repeat is generated. Since this matches the first fact, we have succeeded again.
If backtracking reaches here again, Prolog will again use the rule where it used the
fact before. To satisfy the extra goal generated, it will again pick the fact as the first
option. And so on. In fact, the goal repeat will be able to succeed infinitely many
times on backtracking. Note the importance of the order of the clauses here. (What
would happen if the fact appeared after the rule?).
    Why is it useful to generate goals that will always succeed again on backtrack-
ing? The reason is that they allow one to build — from rules that have no choices in
them — rules that do have choices. And we can make them generate different values
each time.
```

<!-- page 147 -->
```prolog
    Consider the built-in predicate get_char, which is described in Chapter 5. If
Prolog attempts to satisfy a goal get_char(X), it takes this as an instruction to look at
the next character (letter, digit, space or whatever) that has been input to the system
and to try to match the atom representation of this character with whatever value X
has. If it will match, the goal succeeds; otherwise it fails. There is no choice involved.
Predicate get_char always only considers the character which comes next at the time
it is invoked. The next time a goal involving get_char is invoked, it will find the
character after this, but again there will be no choice. We can define a new predicate
new_get as follows:
    nevv_get(X) :- repeat, get_char(X).
The predicate new_get has the property that it generates the values of all the
next characters (in the right order) one by one as its alternative solutions. Why is
this? When we first call new_get(X), the subgoal repeat succeeds and the subgoal
get_char(X) succeeds with the value of the next character associated with X. When
backtracking happens, the last place where there was a choice is in the satisfaction
of repeat. So Prolog forgets everything it has done since then and succeeds in estab-
lishing repeat in another way. It now has to look at the subgoal get_char(X) again.
By now, the "next character" is the one after what we last saw, and so X ends up with
the second character as its value.
    We can use our definition of new_get to define another useful predicate which
skips through an input until a non-space character is found. When Prolog finds a
goal get_non_space(X), it treats this as an instruction to read characters until it finds
the next proper printing character (not a space). It then tries to match the atom
representation of this character with X. We can write an approximate definition of
get_non_space as follows:
    get_non_space(X) :- new_get(X), \+ X = ".
What happens when we try to satisfy get_non_space(X)? First of all, new_get(X)
matches X against the next character coming in. If the value is '
                                                        the next goal
will fail, and new_get will have to generate the next character as the next possible
solution. This will then be compared to ' ', and so on. Eventually, new_get will find
a non-space character, the comparison will succeed, and the value of this character
will be returned as the result of get_non_space.
Exercise 6.1 The above definition of get_non_space will not necessarily work if we
invoke the goal get_non_space(X) when X is already instantiated. Why is this?
    One trouble with repeat is that it always has a choice to redo when backtracking
reconsiders it. So backtracking will never be able to reconsider choices made earlier
than the last call of repeat unless we manage to cut out the choice in some way.
Because of this, the above definitions should be rewritten as:
```

<!-- page 148 -->
```prolog
    new_get(X) :- repeat, get_char(X).
    get_non_space(X) :- new_get(X), \+ X = ", !.
Note that this definition will still only work if we attempt to satisfy get(X) with X
uninstantiated. Because of the problem of backtracking over repeat choices, every-
thing using new_get should be responsible for cutting out the choice as soon as the
character generated is satisfactory for its purposes.
```

## 6.7 Constructing Compound Goals

```prolog
In rules and questions of the form X :- Y or ?- Y, the term appearing as Y may consist
of a single goal, or a conjunction of goals, or a disjunction of goals. Furthermore,
it is possible to have variables as goals, and to satisfy a goal when the goal actually
fails by using \+. The predicates described in this section provide ways to specify
these complicated ways of expressing goals.
X , Y
The "," operator specifies a conjunction of goals. This operator was introduced in
Chapter 1. Where X and Y are goals, the goal X,Y succeeds if X succeeds and if Y
succeeds. If X succeeds and then Y fails, then an attempt is made to re-satisfy X. If X
fails, then the entire conjunction fails. This is the essence of backtracking. The "," has
a built-in declaration as a right associative infix operator, so that X,Y,Z is equivalent
to X,(Y,Z).
X; Y
The ";" operator specifies a disjunction (meaning or) of goals. When X and Y are
goals, the goal X;Y succeeds if X succeeds or if Y succeeds. If X fails, then an attempt
is made to satisfy Y. If Y then fails, the entire disjunction fails. We can use the ";"
```

`operator to express alternatives` *within the same clause.* `For instance, let us say that`

```prolog
something is a person if it is either Adam or Eve, or if it has a mother. We can express
this in a single rule as follows:
    person(X) :- (X=adam; X=eve; mother(X, Y)).
In this rule, we have actually specified three alternatives. However, as far as Prolog
is concerned, this breaks down into two alternatives, one of which itself introduces
two alternatives. Because ";" has a built-in declaration as a right" associative infix
operator, the clause is actually the same as:
    person(X) :-';'( X=adam, ';'(X=eve, mother(X, Y)))
```

<!-- page 149 -->
```prolog
So the first possibility is that X is adam. The second possibility involves the two
alternatives that X is eve or X has a mother.
    We can put disjunctions anywhere where we can put any other kind of goal in
Prolog. However, it is advisable to add extra brackets to avoid confusion about how
the operators ";" and "," interact. We can usually replace a use of disjunction with a
use of several facts and rules, possibly involving the definition of an extra predicate.
For instance, the above example is exactly equivalent to:
    person(adam).
    person(eve).
    person(X) :- mother(X, Y).
This version is more conventional and perhaps easier to read. In general you are
not recommended to use ";" excessively. Refer to Chapter 8 for warnings on how
injudicious use of ";" may lead to programs that are difficult to understand.
call(X)
It is assumed that X is instantiated to a term that can be interpreted as a goal. The
call(X) goal succeeds if an attempt to satisfy X succeeds. The call(X) goal fails if an
attempt to satisfy X fails. At first sight, this predicate may seem redundant, because
one might ask why the argument of call shouldn't simply appear by itself as a goal?
For instance, the goal
    ... , call(member(a, X)), ...
can always be replaced by
    ... , member(a, X), ...
However, if we are constructing goals by using the "=.." predicate or functor and
arg, then it is possible to call goals that have a functor that is unknown at the time
you type in your program. In the definition of consult in Section 7.13, for instance,
we want to be able to treat any term read after a "?-" as a goal. Assuming that P, X,
and Y are instantiated to a functor and arguments appropriately, call can be used as
follows:
    . . Z =.. [P,X,Y], call(Z), ...
The above line can be thought of as a way of expressing the following sort of call,
```

`which is` *not correct syntax* `in the standard version of Prolog we are using in this`

```prolog
book:
      ., P(X, Y),
```

<!-- page 150 -->
1

```prolog
y x
The
      predicate (pronounced "not") is declared as a prefix operator. It is assumed
that X is instantiated to a term that can be interpreted as a goal. The \+ X goal succeeds
if an attempt to satisfy X fails. The \+ X goal fails if an attempt to satisfy X succeeds.
In this way, \+ is rather like call, except that the success or failure of the argument,
interpreted as a goal, is reversed. What is the difference between the following two
questions?
    ?- member(X, [a,b,c]), write(X).
    ?- \+ \+ member(X, [a,b,c]), write(X).
One might be tempted to say that there is no difference, because in the second ques-
tion,
         member(X, [a,b,c]) succeeds, so
       \+ member(X, [a,b,c]) fails, and so
    \+ \+ member(X, [a,b,c]) succeeds.
This is partly right. However, the first question would cause the atom "a" to be writ-
ten, and the second goal would cause an uninstantiated variable to be written. This is
what happens when an attempt is made to satisfy the first goal of the second question
above:
 1. The member goal succeeds, instantiating X to a.
 2. An attempt is made to satisfy the first \+ goal, and it fails because the member
   goal, its argument, succeeded. Now remember that when a goal fails, any vari-
   ables that became instantiated, such as X in the example, must now "forget" what
   they stood for. Hence X becomes uninstantiated.
 3. An attempt is made to satisfy the second \+ goal, and it succeeds, because its
   argument, \+ member(. . .), failed. X is still uninstantiated.
 4. An attempt is made to satisfy the write goal, with X uninstantiated. The uninstan-
   tiated variable, as described in Section 6.9, is printed in a special way.
```

## 6.8 Equality

```prolog
This section deals briefly with the various built-in predicates for testing and making
things equal in Prolog.
X = Y
When Prolog encounters a goal X = Y, it attempts to make X and Y equal by matching
them together. If it can match them, the goal succeeds (and X and Y may have become
```

<!-- page 151 -->
```prolog
more instantiated). Otherwise the goal fails. A fuller discussion of this predicate is
given in Section 2.4. The equality predicate is defined as though by
    X = X.
See if you can understand how this definition works.
X — Y
The predicate "==" represents a much stricter equality test than "=". That is, if X == Y
ever succeeds then X = Y does as well. On the other hand, this is not so the other way
round. The way that " = " is more strict is by the way it considers variables. The "="
predicate will consider an uninstantiated variable to be equal to anything, because
it will match anything. On the other hand, "==" will only consider an uninstantiated
variable to be equal to another uninstantiated variable that is already sharing with it.
Otherwise the test will fail. So we get the following behaviour:
    ?- X == Y.
```

*no*

```prolog
?- X = X.
```

*X = _23*

```prolog
?- X=Y, X==Y.
```

*X = _23, Y = 23*

```prolog
?- append([A|B], C) = append(X, Y).
```

*no*

```prolog
?- append([A|B], C) == append([A|B], C).
```

*A = _23, B = _24, C = _25*

## 6.9 Input and Output

```prolog
The predicates made available for reading and writing characters and terms were
descibed in Chapter 5. Here we summarise each one.
get_char(X)
This goal succeeds if X can be matched with the next character encountered on the
current input stream. get_char succeeds only once (it cannot be re-satisfied). The
operation of moving to the next character is not undone on backtracking, because
there is no way to put a character back onto the current input stream.
read(X)
This goal reads the next term from the current input stream and matches it with X.
A read succeeds only once. The term must be followed by a dot ".", which does not
```

<!-- page 152 -->
```prolog
become a part of the term, and at least one non-printing character. The dot is removed
from the current input stream.
put_char(X)
This goal writes the character X on the current output stream. put_char succeeds only
once. An error occurs if X is not instantiated.
```

nl

```prolog
Writes a control sequence to the current output stream that causes a "new line". On
a computer display, all characters after the use of nl appear on the next line of the
page, nl succeeds only once.
write(X)
This goal writes the term X to the current output stream, write succeeds only once.
Any uninstantiated variables in X are written as uniquely numbered variables be-
ginning with an underscore, such as "_239". Co-referring variables within the same
argument to write have the same number when they are printed out. The predicate
write takes account of current operator declarations when it prints a term. Thus an
infix operator will be printed out between its arguments, for instance.
write_canonical(X)
The predicate write_canonical works in exactly the same way as write, except that
it ignores any operator declarations. When write_canonical is used, any structure is
printed out with the functor first and the arguments in brackets afterwards.
op(X, Y, Z)
This goal declares an operator having precedence class X, position and associativity Y,
and name Z. The position and associativity specification is taken from the following
set of atoms:
    fx fy xf yf xfx xfy yfx yfy
If the operator declaration is legal, then op will succeed. See Section 5.5 for more
details.
```

## 6.10 Handling Files

```prolog
The predicates that Prolog makes available for altering the current input and current
output streams were introduced in Chapter 5. Here we summarise each one.
```

<!-- page 153 -->
```prolog
open(X, Y, Z)
This goal opens a file whose name is X (an atom). If Y is read then the file is opened
for reading; otherwise if Y is write then the file is opened for writing. Z is instantiated
to a special term naming the stream that must be referred to when the file is accessed
later. An error occurs if X is not instantiated, or if X names a file that does not exist.
close(X)
This is used when X is a term naming a stream. The stream is closed and can no
longer be used.
set_input(X)
Sets the current input to the stream whose name is provided by X. X will be a term
returned in the third argument of open, or the atom user_input, which specifies that
input is to come from the keyboard.
set_output(X)
Sets the current output to the stream whose name is provided by X. X will be a term
returned in the third argument of open, or the atom user_output, which specifies that
output is to go to the computer display.
current_input(X)
This goal succeeds if the name of the current input stream matches with X, and fails
otherwise.
current_output(X)
This goal succeeds if X matches with the name of the current output stream, and fails
otherwise.
```

## 6.11 Evaluating Arithmetic Expressions

```prolog
Arithmetic was first discussed in Section 2.5. Here we summarise the use of the "is"
predicate, and what functors are available for constructing arithmetic expressions.
X is Y
Y must be instantiated to a structure that can be interpreted as an arithmetic expres-
sion as described in Section 2.4. First, the structure instantiated for Y is evaluated
to give a number, called the result. The result is matched with X, and the is goal
succeeds or fails based on the match. The functors that can be used to make up the
structure on the right-hand side of an is are as follows:
```

<!-- page 154 -->
```prolog
X + Y
The addition operator. When evaluated by is its result is the numerical sum of its
two arguments. The arguments must be instantiated to numbers or to structures that
evaluate to numbers.
X - Y
The subtraction operator. When evaluated by is, its result is the numerical difference
of its two arguments. The arguments must be instantiated to numbers or to structures
that evaluate to numbers.
X * Y
The multiplication operator. When evaluated by is, its result is the numerical product
of its two arguments. The arguments must be instantiated to numbers or to structures
that evaluate to numbers.
X / Y
The floating point division operator. When evaluated by is, its result is the quotient
of its two arguments (in general, not a whole number). The arguments must be in-
stantiated to numbers or to structures that evaluate to numbers.
X//Y
The integer division operator. When evaluated by is, its result is the integer (whole
number) quotient of its two arguments (the largest whole number less than X/Y). The
arguments must be instantiated to numbers or to structures that evaluate to numbers.
X mod Y
The integer remainder operator. When evaluated by is, its result is the integer (whole
number) remainder that is generated when X is divided by Y. The arguments must be
instantiated to numbers or structures that evaluate to numbers.
    Particular Prolog implementations may include more arithmetic operations such
as exponentiation and trigonometric functions. The examples shown in this book
only require the ones listed here.
```

## 6.12 Comparing Terms

```prolog
Seven predicates are provided for comparing numbers. These predicates were first
presented in Section 2.5 when we discussed arithmetic. Each predicate is written as
an infix operator having two arguments.
```

<!-- page 155 -->
```prolog
X = Y
The equality predicate, described in Section 6.8, also succeeds when two number
arguments are the same. However, if one of the arguments is a variable, the equal-
ity predicate will cause the variable to be instantiated because the equality predicate
performs a unification of its two arguments. In many numeric calculations, this is
not desirable. Instead, Prolog makes available predicates specifically for comparing
equality and inequality of numbers. In all of the following predicates, both argu-
ments must be instantiated, or an error occurs. Using these predicates for numeric
calculation can also cause the program to be executed more efficiently.
X =:= Y
The numeric equality predicate succeeds when the left-hand number argument is
equal to the right-hand number argument.
X-VY
The numeric inequality predicate succeeds when the left-hand number argument is
not equal to the right-hand number argument.
X < Y
The less than predicate succeeds when the left-hand number argument is less than
the right-hand number argument.
X > Y
The greater than predicate succeeds when the left-hand number argument is greater
than the right-hand number argument.
X >= Y
The greater than or equal to predicate succeeds when the left-hand number argument
is greater than or equal to the right-hand number argument.
X =< Y
The less than or equal to predicate succeeds when the left-hand argument is less than
or equal to the right-hand argument. Notice that the predicate is spelled as =< rather
than <=, so that <= is free to be used as an operator that looks like an arrow.
    In addition, Standard Prolog provides predicates for comparing two arbitrary
terms. What does it mean for one term to be less than another (e.g. is f(X) less than
123)? Usually the term comparison operators are used just for comparing two terms
of the same kind (e.g. two atoms, as in the sorted tree dictionary of Section 7.1). But
sometimes one might want to compare other combinations. Here are the principles
that determine whether one term is considered less than another:
```

<!-- page 156 -->
```prolog
•
   All uninstantiated variables are less than all floating-point numbers, which are
   less than all integers, which are less than all atoms, which are less than all struc-
   tures.
•
   For two non-sharing uninstantiated variables, one will be less than the other
   (which one is less may be different in different Prolog implementations).
•
   Floating point numbers are less than floating point numbers and integers are less
   than integers in the way one would expect.
•
   One atom is less than another if it would come earlier than it in the normal dic-
   tionary ordering. To be precise, the ordering depends on the character codes, but
   these are usually ordered as one would expect, at least for alphabetic characters.
•
   One structure is less than another if its functor has a lower arity. If two structures
   have the same arity, one is less than the other if its functor is less than the other
   (using the ordering for atoms). If two structures have the same arity and functor,
   they are ordered by considering the arguments in turn - for the first correspond-
   ing arguments that differ, the order of the structures is the order of the relevant
   arguments.
So for instance all of the following succeed:
     ?- g(X) @< f(X, Y).
     ?- f(Z,b) @< f(a, A).
     ?- 123 @< 124.
     ?- 123.5 @< 2.
X @< Y
The term less than predicate succeeds when the left-hand term argument is less than
the right-hand term argument according to the above ordering.
X @> Y
The term greater than predicate succeeds when the left-hand term argument is greater
than the right-hand term argument according to the above ordering.
X @>= Y
The term greater than or equal predicate succeeds when the left-hand term argument
is greater than the right-hand term argument, according to the above ordering, or if
the two arguments are the same.
```

<!-- page 157 -->
```prolog
X @=< Y
The term less than or equal predicate succeeds when the left-hand term argument is
less than the right-hand term argument, according to the above ordering, or if the two
arguments are the same.
```

## 6.13 Watching Prolog at Work

```prolog
This section describes some built-in predicates that enable you to watch your pro-
gram as it runs. Since Standard Prolog does not specify a fixed set of such predicates,
the ones presented here are intended to be indicative of the sorts of facilities that may
be available, rather than authoritative. We will only describe the built-in predicates
here, and refer you to Chapter 8 for a more detailed discussion of debugging and
tracing.
trace
The effect of satisfying the goal trace is to turn on exhaustive tracing. This means
that afterwards you will get to see every goal that your program generates at each of
the four main ports.
notrace
The effect of the goal notrace is to stop exhaustive tracing from now on. However,
any tracing due to the presence of spy points will continue.
spy P
The predicate spy is used when you want to pay special attention to goals involving
some specific predicates. You do this by setting spy points on them. The predicate
is defined as a prefix operator, and so you do not need to put brackets round the
argument. The argument can be any of the following:
•
   An atom. In this case, a spy point is put on all predicates with this atom, however
   many arguments are used. So if we had clauses for sort with both two and three
   arguments, the goal spy sort would cause spy points to be set on both sets of
   clauses.
• A structure of the form Name/Arity, where Name is an atom and Arity is an inte-
   ger. This specifies a predicate with functor Name and arity Arity. Thus spy sort/2
   would cause spy points to be set on goals for the predicate sort with two argu-
   ments.
```

<!-- page 158 -->
```prolog
•
   A list. In this case, the list must be terminated with "[]", and each element of
   the list must itself be an allowable argument to spy. Prolog will put spy points in
   all the places specified in the list. Thus spy [sort/2,append/3] would cause spy
   points to be set on sort with two arguments and append with three.
debugging
The built-in predicate debugging allows you to see which spy points you currently
have set. The list of spy points is printed out as a side-effect of the goal debugging
being satisfied.
nodebug
The goal nodebug causes all your current spy points to be removed.
nospy
Like spy, nospy is a prefix operator, nospy is more selective than nodebug, because
you can specify exactly which spy points you wish to have removed. You do this
by providing an argument in exactly the same form as for spy. Thus the goal nospy
[reverse/2,append/3] will remove any spy points on reverse with two arguments and
append with three arguments.
```
