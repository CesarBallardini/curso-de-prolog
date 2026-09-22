# AppendixA_Part2

<!-- page 317 -->
The reader recognizes variables but does not preserve their names. It does notice when two like-named variables occur in the same term. Thus, if you type [X,X] you get a list with two instances of the same variable in it. Notice that a Prolog clause such as

£(X) :- g(X), h(X).

is all one term, which is why all the occurrences of X in it are treated as the same variable.

When the reader tries to read past the end of a file, it behaves as if it has read the atom end_of_file. This is of course also what it reads if it encounters the characters

end_of_file.

which you can insert in the middle of a file to make the reader stop reading there.

Exercise A.6.1.1

What does ‘?- read(yes) .’ do if the user types ‘yes .’? What if the user types ‘no.’

or ‘Yes.’?

Exercise A.6.1.2

In your Prolog, is a/* comment * /b

treated like ab or like a 1b? State how you tested this.

Exercise A.6.1.3

What is printed by the query ‘?- write(f£(X,Y,X)).’? Why? What does the reader

have to do with this?

Exercise A.6.1.4

In the Prolog clauses

which occurrences of X are the same variable? Explain why the reader is responsible for

```prolog
this.
```

A.6.2 The Writer

Corresponding to the reader there is, of course, a WRITER whose job is to produce a written representation of any term. The writer is usually accessed through write/1. Note, however, a possible problem:

?- write(’hello there’). hello there

<!-- page 318 -->
In this case the term ‘hello there’ is written out as hello there, which is not aterm. Thus, in this case, output written by write is not suitable to be read back in by read.

The built-in predicate writ eq remedies this problem. Everything that it writes js ” in legal Prolog syntax:

?- writeq(‘hello there’). ‘hello there’

?- writeq(2+3-4). 2+3-4

But there is still a potential problem. Suppose you have defined likes to be an infix operator. Then you can do the following:

?- writeq(kermit likes piggy). kermit likes piggy

The reader will accept kerm:.t likes piggy if it knows that likes is an infix operator. A subsequent program, reading this term back in from a file, would encounter difficulties if it did not have the same infix operator defined.

A third built-in predicate, display, remedies this problem too: display writes terms so that they can be read back in without relying on any operator declarations at all. For example:

?- display (2+3-4). "=" ('#'(2,3),4)

?- display(kermit likes piggy). likes (kermit, piggy)

Finally, remember that if you are writing out terms to a file so that the reader can subsequently read them, you must put a period after each term.

A.6.3 Character Input-Output

**The built-in predicate put**

/1 outputs the character whose ASCII code is given as its argument. For example, *?- put (65) .’” outputs the letter A.

The built-in predicate get 0/1 accepts a character from the input stream and unifies its argument with the ASCII code of that character. For example, ‘?- get0(X) .’ reads one character and unifies its code with X, and ‘?- get0(65) .’ reads a character and succeeds if that character is ‘A’ or fails otherwise.

**Another built-in predicate, get**

**/1, works like get**

0 except that it skips over any nonprinting characters (blanks, returns, line feeds, etc.) and reads the first nonblank character.

Exercise A.6.3.1

Define a predicate called copy3 that accepts three characters from the keyboard and writes

their ASCII codes (as numbers) on the screen. Experiment with its behavior using both get

<!-- page 319 -->
and get 0. A.6.4 File Input-Output

Prolog normally reads from the keyboard and writes to the screen. These are referred to as STANDARD INPUT and STANDARD OUTPUT, respectively. Standard input and output can be REDIRECTED to files or to anything else that the operating system can treat as a file (such as a printer).

To redirect standard input, use see (filename) ; to redirect standard output, use tell(filename), where filename is a Prolog atom giving the name of the file. To close the files and cancel the redirection, use seen and told, respectively.

Whenever input or output is redirected to a file, the file is opened for reading or writing as the case may be. This means that redirected input always starts at the beginning of the file, and redirected output always starts by creating the file (and destroying any like-named file that already exists). It is, however, possible to have many files open at once. Here is an example:

test :-

```prolog
see(filel),
```

% start at beginning of filel

```prolog
read(T1),
                     % read a term
see(file2),
```

% start at beginning of file2

```prolog
read(T2),
                     % read a term
see(filel),
```

% switch back to filel

```prolog
read(T3),
```

% read second term on filel

write([{T1,T2,T3]), % write results on the screen

```prolog
seen.
```

% close all files

Use see (user) or tell (user) to redirect input or output to the keyboard or screen without closing files. Use seeing(F) or telling(F) to find out the name of the file that input or output is currently using. Thus, the following code writes a message on the screen, then switches subsequent output back to wherever it had been redirected:

telling(F), tell (user), write(’This is a message’), tell (F),

Redirection can be dangerous, because if the program crashes while input or output is redirected, you may be unable to see the error messages or type any further input to the Prolog system. Almost all Prologs provide a way to read and write files without redirecting standard input or output. Unfortunately, such methods are not standardized and therefore cannot be used in this book.

<!-- page 320 -->
All the built-in input-output predicates are DETERMINISTIC; that is, they do not yield alternative solutions upon backtracking. Exercise A.6.4.1

Under what conditions must a file name be given in quotes?

Exercise A.6.4.2

Write a short program that accepts three terms (each followed by a period) from the keyboard,

writes them out to a file named ECHO.DAT, and then reads them back

in and displays them

on the screen.

Exercise A.6.4.3

What does ‘?- read(X), fail.’ do?

**A.7 EXPRESSING REPETITIVE ALGORITHMS**

**A.7.1 repeat loops**

**The built-in predicate repeat is considered to have an infinite number of different**

**solutions, so that execution can backtrack to it and go forward again an infinite number**

of times:

?- repeat,

```prolog
   write(’I run forever...'’),
fail.
```

**More commonly, of course, the repetition is stopped by executing a cut after some test**

**is passed. Here is a predicate that copies terms from standard input to standard output,**

**up to and including end_of_file:**

copy_terms :-

repeat,

```prolog
   read(X),
   write(X), nl,
   X == end_of_file,
                       % the test
|
```

**Without the cut, repetition would still stop when X == end_of_file succeeds (be-**

cause Prolog only backtracks from failures, not successes), but a subsequent failure might cause repetition to resume, as in a query like ‘?- copy_terms, 2.’ if z fails.

**repeat loops are not as useful as you might think, because there is no way to**

**carry information along from one pass to the next. All variable instantiations are undone**

**as you backtrack through them. Also, execution will backtrack from any query that**

**fails—not just the one you think of as the test.**

**In fact, the main use of repeat loops is to sift through input. There is a good**

**reason for this. Something external has to change, from one repetition to the next, in**

<!-- page 321 -->
order to ensure that the looping will terminate. So a repeat loop that does not look at something external, such as a file, will rarely be useful.

Exercise A.7.1.1 The following predicate is supposed to copy characters from standard input to standard output until a blank is encountered. After copying the blank it should stop.

copy_until_blank :-

```prolog
                                  % Contains error!
repeat,
   get0 (Char),
   put (Char),
[Char] == "
             “.
```

What did the programmer do wrong? Show how to demonstrate that the program does not work entirely as desired.

Exercise A.7.1.2 Define a predicate get_lower_case_letter/1 that is like get except that, instead of just skipping nonprinting characters, it skips everything that is not a lower-case letter.

For example, ‘?- get_lower_case_letter(X)’ should find the first lowercase letter on the input stream and instantiate X to the ASCII code of that letter. Likewise, ‘2- get_lower_case_letter(100)’ should read the first lower-case letter on the input stream and succeed if that letter was code 100 (‘d’) or fail otherwise.

A.7.2 Recursion To do something repeatedly and carry information along from one pass to the next, use RECURSION—that is, make a procedure call itself. This is just like induction in logic. (Formal logic does not allow you to just “repeat” a line in a proof; instead, you must define one thing in terms of another so that you get the repetition you need.) Here’s how to print the integers from 1 to 100:

count_from(X) :- X > 100.

% succeed with no further action

count_from(X) :xX =< 100,

% print this number, compute next one write(X), nl, NewxX is X+l1, count_from(NewX) .

?- count_from(1).

<!-- page 322 -->
Here X is called a STATE VARIABLE because it passes along information about the state of the computation. (State variables are also called ACCUMULATORS because they accumulate information.) Note that there’s no way to change the value of X once it’s instantiated, so instead of X the recursive call has NewX.

Often, in addition to the arguments that pass information into and out of a proc dure, you will need other arguments for state variables. In such a case it is convenie to define a second predicate (traditionally named something-aux and called an AUX- ILIARY PREDICATE). The first predicate has only the arguments that are meaningful to: the user, and it calls the aux predicate, which has the full set of arguments. For example:

reverse(Listl,List2) :- reverse_aux(List1,{],List2).

reverse_aux([H|T],Stack,Result) :-

```prolog
reverse_aux(T, [H|Stack],Result).
```

reverse_aux([],Result,Result).

This is a classic list-reversal algorithm.

Exercise A.7.2.1

In reverse_aux/3 above, how does Result come to be instantiated?

Exercise A.7.2.2

Define a predicate add_up(X,Y,2Z) which unifies Z with the sum of the integers from X

to Y inclusive. Do this by actually adding the integers, not by using a formula.

A.7.3 Traversing a List

Here’s an example of how to work through a list (“CDR down it,” in Lisp parlance). The task, in this case, is to make a copy of the list in which every occurrence of a is replaced with b. The program logic will be very similar no matter what you are looking for in the list, and whether or not you are making an altered copy.

ved rewrite(a,b) :- !.

a rewrites as b rewrite(X,X).

%® anything else rewrites as itself

rewrite_list([],[]).

rewrite_list([First|Rest], [NewFirst |NewRest]) :-

rewrite (First,NewFirst),

rewrite_list (Rest,NewRest).

An example of its use:

?- rewrite_list ([a,b,r,a,c,a,d,a,b,r,a],What) . What = [b,b,r,b,c,b,d,b,b,r,b]

<!-- page 323 -->
The logic here is: To do something to a whole list, do it to the first element, then do it to the list of remaining elements. Exercise A.7.3.1

Define a recursive predicate maximum(List,N) which unifies N with the largest integer

contained in List. Assume that all the elements of List are integers.

Exercise A.7.3.2

Define a recursive predicate depth(List,N) which unifies N with the depth of a list,

defined as follows:

e Any term that is not a list has depth 0.

e The depth of any list is 1 + the depth of its deepest element.

Thus the depth of a is 0; the depth of [a,b] is 1; the depth of [a, [b,c]] and of

[{a,b],c] is 2; and so on.

A.7.4 Traversing a Structure

Often, instead of just lists, you’ll need to process arbitrary terms, examining and possibly changing everything that is inside them. For example, if you implement an extension to Prolog (as was done in Chapter 5), you’

ll want to read every term in a program, searching for your special symbols and converting them into something else, while leaving the rest alone.

Here’s how to generalize rewrite_list/2 so it works for any term:

rewrite_term(+Terml1, ?Term2)

Copies Terml changing every atom or functor ‘a’ to ‘b’

(using rewrite/2 from previous section). ade oP ae

rewrite_term(X,X) :-

var (X),

% don’t alter uninstantiated variables

!

rewrite _term(X,Y) :-

2

```prolog
atomic(X),
```

% ‘atomic’ means atom or number

1 a

```prolog
rewrite(X,Y).
```

rewrite _term(X,Y) :-

X =.. XList,

% convert structures to lists

```prolog
rewrite_aux(XList,YList),
                              % process them
y=... YList.
```

% convert back to structures

rewrite_aux([],[]).

rewrite_aux([First|Rest], [NewFirst|NewRest]) :-

```prolog
rewrite_term(First,NewFirst),
```

% note recursion here

```prolog
rewrite_aux(Rest,NewRest).
```

<!-- page 324 -->
Review of Prolog

App. This procedure uses ‘=. .’ (pronounced “univ,” which was its name in Colmerauer’ early Prolog) to convert structures into lists and back; for example, f(a,b,c) =

[£,a,b,c]. Either of the arguments of =. . can be instantiated, and the other one will be given the appropriate value.

Even lists can be converted this way. For example,

{a,b,c] =.. ['’.',a,[b,c]]

because the principal functor of every list is the dot. Thus, lists are a special case of structures and do not require a clause of their own in rewrite_term/2.

Notice that rewrite_aux (used by rewrite_term) is like rewrite_list, which we defined earlier, except that it uses rewrite _term recursively on the first element of each list. This ensures that structures within structures are all processed. Exercise A.7.4.1

Define depth (Structure,N) such that N will be unified with the depth of Structure.

This time depth is defined as follows:

e An atomic term has depth 0.

e The depth of a structure is 1 + the depth of its deepest argument.

For example, the depth of £(a,b(c,d(e),£),g) is 3.

Exercise A.7.4.2

What is the depth of a ten-element list according to the definition just given?

A.7.5 Arrays in Prolog

Prolog has no arrays. However, it has two reasonable substitutes. First, if an array is to be used as a lookup table, replace it with a set of facts. For example:

nthprime (1,2) nthprime(2,3). nthprime(3,5). nthprime (4,7)

This is a table for looking up the nth prime number. You can build it by executing a program that finds primes and uses assertz.

Second, a multi-argument structure acts like an array of Prolog terms or variables. For example,

£(A,B,C,D,E,F,G,H,I,3,K,L,M,N,0,P,Q,R,S,T,U,V,W,X,

<!-- page 325 -->
Y) is like a 25-element array of variables; you can pass it around and instantiate or test the variables one by one.

To get to the nth argument without unifying the whole structure with anything, use the built-in predicate arg (N, Structure, Arg), which unifies Arg with the Nth argument of Structure. For example,

?- arg(15,f£(a,b,c,d,e,f,g,h,i,j,k,1,m,n,0,p,q,r,s,t,u,v,w,x,y),W).

**unifies W with o. This is much faster than putting the whole structure through the**

unification process.

Exercise A.7.5.1

In C, a two-dimensional array is simply a one-dimensional array of one-dimensional arrays.

What does this suggest about how to represent a two-dimensional array in Prolog? Give an

example of a 3 x 3 matrix implemented this way.

Exercise A.7.5.2

Prolog implementations put a limit on the number of arguments in a structure—typically

256. What is the limit in the Prolog that you use? How did you find out?

**A.8 EFFICIENCY ISSUES**

A.8.1 Tail Recursion

Recursion eats up memory because, whenever one procedure invokes another, a record has to be kept of where to come back to when the second procedure finishes.

There is an exception: suppose the first procedure calls the second as its very last step, with no further actions to be performed and no backtrack points to be remembered. Then execution can simply jump into the second procedure without setting up a way for control to return to the first one. (At the end, control will instead end up wherever it was to have gone at the end of the first procedure.)

**Recursion that satisfies this condition is called TAIL RECURSION. An example:**

£(X) :- KX < 100.

```prolog
% Tail recursive example
```

£(X) :- X >= 100, Y is X-1, £(Y).

If the recursive call isn’t last, the procedure isn’t tail recursive:

g(X) :- X >= 100, Y is X-1, g(Y), Zz.

```prolog
% Not tail recursive
```

Nor is it tail recursive if there’s still an untried alternative at the time the recursive call takes place. This is the case if the clauses in the example are in the opposite order:

h(X) :- X >= 100, Y is X-1, h(Y).

```prolog
% Not tail recursive
```

<!-- page 326 -->
h(X) :- X < 100.

Review of Prolog

App. A When the first rule calls itself, the second rule hasn’t yet been tried, so a backtrack point has to be stored on the stack. As the first rule calls itself over and over, the stack can — eventually fill up. Try a query like ‘?~ h(10000) .” to see what happens. In almost all Prologs, a cut will make such a procedure tail recursive after all, by eliminating the untried alternative:°

j(X) :- X >= 100, !, Y is X-1, j(y).

```prolog
% Tail recursive
```

j(X) :- X < 100.

% because of cut

Place the cut so that it will be executed as soon as it is certain that execution has entered the right clause.

Exercise A.8.1.1 Rearrange the clauses in the following predicate definition and add cuts so that the predicate is tail recursive and never leaves behind an unnecessary backtrack point.

**% contains_list**

(+L) %

succeeds if L is a list that contains another list

contains_list([[]!_]). contains_list([_IX]) :- contains_list (x). contains_list([{[_I_J!_]).

A.8.2 Indexing

Almost all Prologs can eliminate unnecessary backtrack points by looking ahead to see which clauses the query can match. For example, given the knowledge base

f(a(X),¥) :- £(X,yY). £(b(X),Y) :- g(X,¥).

and the query *?- f(a(something),something) .’ the Prolog system will look ahead and see that the second clause cannot possibly match this query, so when it enters the first clause, it will not leave behind a backtrack point. As a result, this predicate becomes tail recursive even though it does not appear to be. This feature is called indexing. Obviously, the Prolog system cannot predict with complete certainty which clauses will succeed; all it can do is rule out some obvious mismatches in advance. Indexing normally looks only at the principal functor of the first argument. Thus indexing will distinguish f(a(X),Y) from f(b(X),Y), but it will not distinguish

<!-- page 327 -->
3Exceptions include Arity Prolog Interpreter 4.0 and ESL Public Domain Prolog-2 version 2.3.5. In these implementations, the cut keeps the backtrack point from being used, but doesn’t prevent it from being stored on the stack. £(¥,a(X)) from £ (Y,b(X) ). This means that in order to take advantage of indexing, you should design your predicates so that the first argument has a variety of principal functors and is usually instantiated when the predicate is called.

Exercise A.8.2.1

Is the predicate

```prolog
print_list([H!|T]) :- write(H), put(32), print list (T).
print_list([]).
```

tail recursive in a system with indexing? Why or why not? (And what does put (32)

accomplish?)

Exercise A.8.2.2

By changing only the order of arguments, make the predicate

```prolog
p(Y,£(Z)) :- ply,Z).
tail recursive, assuming first-argument indexing.
```

**A.8.3 Computing by Unification Alone**

Sometimes unification, by itself, can do the computation you need. Here’s a predicate that tests whether its argument is a three-element list, and succeeds if so:

has_three_elements([_,_,_]).

Note that there is no call to Length/2 or anything like that. Unification does all the work.

Likewise, here’s a predicate that takes any list and creates another list just like it with the first two elements swapped:

swap_first_two([A,B|Rest],[B,AlRest]).

For example, the query ‘?- swap_first_two([x,y,z],What) .’ will instantiate What to [y,x,zZ].

Exercise A.8.3.1

Define a predicate which, using unification alone, will convert 2+3 to

2-3, or (3+4) +£ (x)

to (3+4)-f£(x), or, generally, any structure with principal functor + to the corresponding

<!-- page 328 -->
structure with principal functor -. A.8.4 Avoidance of Consing

Programs run more efficiently if they can avoid creating new structures and lists (an. activity known to Lisp programmers as “consing”).

It is much faster to instantiate a previously uninstantiated part of a structure, than’ to make a new copy of the whole structure in order to add information.

For example, if you want to build the list [a,b, c,d], it is much faster to start with [a,b,c|X] and instantiate X to [d], rather than starting with [a,b,c] and appending [d] to it.

**A list with an uninstantiated tail, such as [a,b,c!X], is called an OPEN LIST.**

Often you’ll want to keep, outside the list, a pointer to the uninstantiated tail, so that you can get to the tail without searching through all the elements. This is called a DIFFERENCE LIST; an example is f ([a,b,c|X],X). Here £ has no particular meaning; you could use any functor. Many people use the infix operator ‘-’ or ‘/’.

The traditional predicate append/3 can be a time waster; whenever you find yourself using it, see if the same work can be done more quickly with open lists or difference lists.

Another time waster is =. . (“univ”), which builds a list from a structure. If you only need to retrieve part of the structure, it is much quicker to use arg (N, Structure, Arg).

Exercise A.8.4.1

Define a predicate open_list_length(OpenList,N) which will unify N with the

length of OpenList and will not instantiate any part of OpenList that was previously

uninstantiated. For example, the length of [a,b,c|X] should be 3.

Exercise A.8.4.2

Define a predicate which, when given two difference lists such as [a| X]-X or [a,b,c,

a|Y]-Y, will append them. For example, starting with [a,b,c|X]-X and [d,e,f]Y]

-Y, the predicate that you define should create [a,b,c,d,e, £|Y]-Y.

Exercise A.8.4.3

Rewrite the following predicate to make it run faster.

```prolog
second_argument_is_zero(X) :- X =.. [_,_,0|_].
```

**A.9 SOME POINTS OF PROLOG STYLE**

A.9.1 Predicate Headers

Every nontrivial Prolog predicate in this book begins with a comment (called the HEADER) that describes what it does. For example:

oe

member (?X, ?Y) oe

<!-- page 329 -->
X is an element of list Y. member (X, [X|_]). member (X, [_lY¥]) :- member (X,Y).

The header must say succinctly:

e what the predicate does;

e what each argument is for;

e what type of term each argument should be, if it matters (in this case, Y is a list

but X could be anything).

Auxiliary predicates do not require headers. Recall that an auxiliary predicate exists only to complete a recursive loop that starts in the main predicate; in this book auxiliary predicates have names ending in _aux.

Notice that the names of the arguments are not the same in the header as in the various clauses. (Nor are they the same from clause to clause.) In the header, the arguments are given whatever names will best explain how they work. Here I used X and Y because more meaningful names did not seem appropriate; perhaps I should have used Element and List or E and L.

The question marks on ?X and ?Y¥ mean “This argument may or may not be instantiated when this predicate is called.” A plus sign, as in +X, denotes an argument that must be instantiated at time of call; a minus, as in -X, means that the argument is normally uninstantiated. Note that in most situations where you write -X you could actually write ?X, because if X does happen to be instantiated, nothing goes wrong; the query succeeds if X has the right value and fails otherwise. It is rare indeed for a Prolog predicate to require an argument to be uninstantiated.

Exercise A.9.1.1

Write headers, in this format, for the built-in predicates write, read, and name.

**A.9.2 Order of Arguments**

When defining a predicate with multiple arguments, it is generally best to put the known (instantiated) arguments first and the arguments that return results last. Thus, if widget/2 computes Y from X, it should be defined as widget (+X,-Y), not widget (-Y,+X). In addition to helping the human user remember where things go, this helps take advantage of first argument indexing.

O’Keefe (1990:14-15) takes this idea further and puts arguments in the following order:

e First, the input (the arguments that are always known, if any);

e Second, any intermediate data that the predicate passes along from one recursive

call to the next;

e Third, any “leftovers” or partly processed input;

<!-- page 330 -->
e Last, the output (the result desired by the user). Some predicates, of course, are REVERSIBLE (they can compute either argument from. the other one); an example is name/2. In this case the order of arguments should be whatever seems most natural to the human user.

Exercise A.9.2.1 Define a predicate find_max_min/3 that finds the largest and smallest numbers in a list. Include a standard header and put the arguments in an order consistent with the above principles.

Exercise A.9.2.2 (project)

**Implement, in any programming language, a “lint checker” for Prolog. A lint checker is a’**

program that reads another program and identifies statements which, although they may be» syntactically correct, usually indicate mistakes on the part of the programmer. Examples of “lint” in Prolog might include:

e Hyphen (minus sign) between atoms (the programmer may have thought names could

include hyphens);

e Operator : - inside a comment (a clause may have been commented out accidentally);

e End-of-line occurring within a quoted atom or quoted string (the closing quote may

have been left out);

e Clause that does not begin at the beginning of a line (the programmer may have put

a period instead of a comma between subgoals in the previous clause);

e Variable used only once in a clause (either it’s misspelled, or an anonymous variable

should have been used);

e Functor or atom used only once in entire program (it’s probably misspelled).

This is an open-ended project, and your lint checker is probably something you’ll keep adding to.

