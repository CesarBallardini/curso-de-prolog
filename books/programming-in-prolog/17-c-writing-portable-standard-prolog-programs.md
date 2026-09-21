# C Writing Portable Standard Prolog Programs

<!-- page 291 -->
Writing Portable Standard Prolog Programs

```prolog
This appendix introduces some of the issues involved in writing Prolog programs that
can easily be used by other people (with different hardware and software infrastruc-
ture). It suggests a way of using and working with the Prolog standard to facilitate
this.
```

C.l Standard Prolog for Portability

```prolog
It is a fact of life that nearly every time a new piece of computer hardware or com-
puter operating system is developed, some new piece of programming is required
to make Prolog (or any other high-level programming language) available to users
of that hardware or software. The program that is written to support Prolog (i.e. to
allow users to consult and run programs with the expected results, to provide the re-
quired built-in predicates and generally to allow Prolog programmers to exploit the
facilities available) within some hardware and software infrastructure is what we call
a Prolog implementation. Different Prolog implementations are written by different
people with different interests at different times and often attempting to exploit the
special facilities provided by the hardware and software environment. So they look
different to Prolog programmers. One implementation provides a built-in predicate
foo/1 whereas another calls this predicate baz/1; a third implementation provides a
predicate foo/1 but this does something completely different. The Prolog program
that runs happily on one machine fails unexpectedly on another. This is bad news for
anyone who would like to write portable programs that other people can use (or who
would like to use somebody else's programs).
In an attempt to tackle this problem, after a great deal of work by many different
Prolog implementors and programmers, the Prolog standard (ISO/IEC 13211-1) was
```

<!-- page 292 -->
```prolog
finalised in 1995. The standard precisely specifies what a Prolog program is and how
it is executed. It includes a specification of a set of built-in predicates and what they
should do. It is documented in the book Prolog: The Standard by Pierre Deransart,
AbdeLAli Ed-Dbali and Laurent Cervoni, published by Springer Verlag in 1996. If
every Prolog implementation conformed exactly to the standard then there would
be no problems taking a program written for one implementation and running it on
another.
```

## C.2 Different Prolog Implementations

```prolog
At the time of writing, very few, if any, Prolog implementations are completely com-
patible with Standard Prolog. Fortunately in this book we have restricted our at-
tention to a compact subset of the language and the ideas here are being reflected
rapidly in actual implementations. The standard is also the best statement available
about what a Prolog system should be like and the description is widely respected.
The current best approach to writing portable Prolog programs is to adhere to the
standard, which is why we have kept to it in this book.
The fact that a given implementation is not standard-compliant does not necessarily
mean that it is impossible to use it to write Standard Prolog programs, and anyone
who cares about portability should try to write programs which are as close to the
standard as possible. In particular, programs that make use of built-in predicates not
described in this book may not be portable (unless they are described in the full stan-
dard as given in the book of Deransart et al). This opens up difficulties when Standard
Prolog facilities are only available in a different form in a given implementation.
Fortunately when a Prolog implementation does not provide a predicate described
in the Prolog standard, it will often provide something else in terms of which the
standard predicate could be defined.
•
   If your implementation does not provide a standard predicate but you need it,
   you may be able to define that predicate in terms of other predicates which are
   provided. It is a good strategy to keep such definitions (and only these) in a
   separate file (your "compatibility file") to be consulted with your program by
   people using the same implementation. People using a different implementation
   which is completely compatible with the standard in the relevant respects can
   just consult your program without the compatibility file. People using a different
   implementation which is incompatible with the standard in yet another way will
   have to write their own compatibility file (possible adapting yours), but this is a
   move which will be worth their while anyway if they are wanting to exchange
```

<!-- page 293 -->
Appnd

Writing Portable Standard Prolog Programs

```prolog
   programs with other people. Once you have defined your compatibility file, then
   the rest of your program can use the relevant predicates just as in Standard Prolog.
•
   If your implementation does provide a predicate, but with a different meaning to
   the standard, then you should again attempt to put a standard-conforming def-
   inition of the predicate in your compatibility file. But you will have to rename
   the predicate concerned in your own program and also in the compatibility file
   definition so as to avoid a clash with the predicate provided by the implementa-
   tion. In this case your program will not be standard-compliant, but it is easy to
   document the transformation needed to make it standard-compliant.
In practice, the process of determining which Standard Prolog predicates need to be
added to an implementation can be done once for a given implementation, or perhaps
just once for a given site using a specific implementation.
```

## C.3 Issues to Look Out For

```prolog
The following summarises some of the issues where Prolog implementations some-
times differ from the standard or where for other reasons the portability-concerned
programmer will need to pay attention. This list is of course not exhaustive, as there
is nothing preventing a new Prolog implementation from diverging from the standard
in a quite unexpected way.
Characters. In Standard Prolog, characters are atoms whose names have length 1
   (see Section 2.1). Some built-in predicates deal with characters and some with
   integer character codes (e.g. using the ASCII code). Implementations may differ
   according to which deal with which. Character codes are implementation depen-
   dent.
Strings. The standard allows for the programmer to select between a fixed set of
   meanings for a Prolog term consisting of characters enclosed in double quotes
   (e.g. "abc"). Implementations may not provide all of these, and so we have
   avoided using this notation in the book.
Unknown predicates. The standard allows for the programmer to select between a
   fixed set of possible actions to be performed if a predicate without a definition is
   invoked. Implementations may not provide all of these, and so it is wise not to
   rely on any particular behaviour.
Database updates. Strange things can happen if clauses for a predicate are retracted
   whilst a goal for the predicate is being satisfied. Although the standard specifies
```

<!-- page 294 -->
```prolog
   what should happen in cases like this, implementations do not always follow,
   and so it is inadvisable to write programs that will cause this to happen.
Names of predicates. Built-in predicates may have different names in different im-
   plementations. For instance, \+ may be called not. It is best to stick to the stan-
   dard names and if necessary create a compatibility file defining these in terms of
   the non-standard names.
Operator precedences. These may differ between implementations. It is best to rely
    on the standard precedences and if necessary (and if this is possible) explicitly
   call op/3 on operators you are using before loading your program.
Term comparison. This may not be provided by an implementation. The results of
   term comparison will probably rely on character codes and so, to some ex-
   tent, will be implementation dependent (though the standard specifies some con-
    straints on what term comparison can do).
Input/output. Prolog systems in the past have differed greatly in how file input/output
   is dealt with, this not always being stream-based. The internal structure of file
   names will be implementation dependent.
Directives. Implementations differ in the directives that are available to influence
   how programs are loaded.
Consulting programs. The standard does not specify what predicates are provided
   for this, and so different implementations will differ.
Arithmetic. In this book, we have not used arithmetic a great deal. The Prolog stan-
   dard specifies a set of functors that can be used in arithmetic expressions (we
   have only used a small subset). Implementations may differ in how they treat
   integer vs floating point numbers, how errors are dealt with, etc.
Occurs check. The standard specifies that Prolog programs should not be able to
   create circular terms (see Section 10.6). Some implementations even provide
   special support for circular terms, but for portability one should not be using
   them.
```

## C.4 Definitions of some Standard Predicates

```prolog
To give you a start towards creating your own compatibility file, in this section we
provide simple definitions of those Standard Prolog built-in predicates that we have
used in this book. Many Prolog implementations support at least the core built-in
```

<!-- page 295 -->
Appnd

Writing Portable Standard Prolog Programs

```prolog
predicates, and so will be able to use definitions of new predicates defined in terms
of them.
Because in the following definitions we have restricted ourselves to the Clocksin and
Mellish core Prolog subset, we have not been able to remain faithful to all aspects of
the standard. In particular, there is no way in the core subset of Prolog to create an
error condition, and so sometimes these definitions will fail when according to the
standard an error condition should arise. The following definitions should support
most correct uses of the predicates, but might behave differently if they are used
incorrectly.
Where subsidiary predicates have been defined in the following, their names begin
with $$ to minimise the chance of clashes with existing predicates.
The following summarises the definitions given here. These programs can be ob-
tained in machine-readable form from http://www.dai.ed.ac.uk/homes/chrism/pinsp.
  Standard predicate:
                           Defined in terms of non-standard:
  atom_chars/2
  number_chars/2
  get_char/l
  put_char/l
  dynamic/1
  close/1
  current_input/l
  current_output/l
  open/1
  setjn put/1
 set_output/l
 write_canonical/l
  \+/l
  number/1
  @=</2, @>/2, @>=/2, @</2
                           name/2
                           name/2
                           getO/1, name/2
                           put/1, name/2
                           (nothing)
                           seeing/1, see/1, seen/0, telling/1, tell/1, told/0
                           seeing/1
                           telling/1
                           seeing/1, see/1, telling/1, tell/1
                           see/1
                           tell/1
                           display/1
                           not/1
                           integer/1
                           name/2
```

### C.4.1 Character Processing

```prolog
% atom_chars/2
%
% Translate between atoms and lists of characters
%
% Known problems:
%
    tends to fail rather than produce an error
```

<!-- page 296 -->
```prolog
%
    converts a sequence of characters which happen to be from '0' to '9'
%
     into a number, not an atom
atom_chars(Atom,Chars) :-
  var(Atom), nonvar(Chars), !,
  '$$collect_codes'(Chars,Codes),
  name(Atom, Codes).
atom_chars(Atom,Chars) :-
  name(Atom, Codes),
  '$$cotlect_codes'(Chars,Codes).
  '$$collect_codes'([Ch|Chs],[Co|Cos]) :-
    (nonvar(Chs); nonvar(Cos)), !,
    name(Ch,[Co]),
    '$$collect_codes'(Chs,Cos).
  '$$collect_codes'( [],[]).
% number_chars/2
%
% Translate between numbers and lists of characters
%
% Known problems:
%
    tends to fail rather than produce an error
%
    in fact also produces characters from non-numbers
number_chars(Num,Chars) :-
  var(Num), nonvar(Chars), !,
  '$$collect_codes'(Chars, Codes),
  name(Num,Codes).
number_chars(Num,Chars) :-
  nonvar(Num),
  name(Num,Codes),
  '$$collect_codes'(Chars,Codes).
% get_char/l
%
% Single character input
%
% Known problems:
%
%
    The definition of '$$end_of_file_code' needs to be updated so
```

<!-- page 297 -->
Appendix C Writing Portable Standard Prolog Programs

283

```prolog
%
     that it represents the character code used for "end of file".
get_char(Char) :- getO(Code), ,$$code_to_char'(Code,Char).
  '$$code_to_char/(Code,Char)
    '$$end_of_file_code'(Code), !, Char=end_of_file.
  'SScodeJio.char^Code^harl):- name(Char,[Code]),
    '$$name_to_atom'(Char,Charl).
  % some versions of 'name' create numbers in their first arguments
  % make sure that the result really is an atom
  '$$name_to_atom'(0/0'):-!.
  '$$name_to_atom'(l/l'):-!.
  '$$name_to_atom'(2/2'):- !.
  '$$name_to_atom'(3/3'):-!.
  '$$name_to_atom'(4/4'):- !.
  '$$name_to_atom'(5/5'):-!.
  '$$name_to_atom'(6/6'):-!.
  '$$name_to_atom'(7,'7'):-!.
  '$$name_to_atom'(8/8'):- !.
  '$$name_to_atom'(9,'9'):- !.
  '$$name_to_atom'(X,X).
  '$$end_of_file_code'(-l).
% put_char/l
%
% Single character output
%
% Known problems:
%
%
    will fail if given a non-character atom (rather than produce an error)
put_char(X):- name(X,[C]), put(C).
```

### C.4.2 Directives

```prolog
% dynamic/1
%
% Declare a set of
                     *-
```

<!-- page 298 -->
```prolog
%
% Known problems:
%
%
    Does nothing. This at least means that dynamic directives will not
%
     create errors, but it does not address whatever might be required
%
     to allow a predicate to be dynamic in a given implementation.
?- op(1200,fx,':-').
?- op(1100,fx,dynamic).
dynamic(_).
```

### C.4.3 Stream Input/Output

```prolog
% The following predicates have to be used together
% NB the following predicates all make the assumption that the predicate
%
%
    '$$open'(Filename,Mode)
%
% (Filename an atom naming a file and Mode being 'read' or'write') is
% updated dynamically to reflect the files that are currently open for
% input and output.
%
% A stream is represented by a term '$$stream'(F) where F is the atom
% file name. The same structure is used for the streams userjnput and
% user_output, with F = userjnput or user_output.
%
% Known problems with this group of definitions:
%
%
    uses the file name inside the stream name - this convention cannot
%
     be relied on in Standard Prolog
%
    can only have one stream open at a time for a given file for input
%
     or output
%
   can't open a file called userjnput or user_output
:- dynamic('$$open'/2).
% close/1
%
% Close a currently open stream
```

<!-- page 299 -->
Appnd

Writing Portable Standard Prolog Programs

```prolog
%
% Known problems:
%
%
   Fails if the stream is not open (rather than producing an error)
%
   Closes the file for both input and output (for whichever it is
%
     open for)
close(userjnput):-!.
close(user_output):- !.
close('$$stream'(user_input)):- !.
close('$$stream'(user_output)):- !.
close('$$stream'(File)) :-
  '$$open'(File,Mode), !,
  '$$closefiles'(File).
  '$$closefiles'(File) :-
    retract('$$open'(File,Mode)),
    '$$closefile(File,Mode),
    fail.
  '$$closefiles'(_).
  '$$closefile'(File,read) :- !,
    seeing(Current),
    see(File), seen,
    see(Current).
  '$$closefile'(File,write) :-
    telling(Current),
    tell(File), told,
    tell(Current).
% current_input/l
%
% Test what the current input stream is
current_input('$$stream'(F)) :- seeing(F).
% current_output/l
%
% Test what the current output stream is
current_output('$$stream'(F)) :- telling(F).
```

<!-- page 300 -->
```prolog
% open/3
%
```

*% Open a file for input or output*

```prolog
%
% Known problems:
%
open(File,read/$$stream'(File)) :- !,
  '$$closeJf_open'(File,read), % close file if already open
  seeing(Old),
                       % remember the current input
  see(File),
                     % open again from the start
  assert('$$open'(File,read)),
  see(Old).
                      % but don't change the current input
open(File,write,'$$stream'( File)) :-
  '$$close_if_open'(File,write), % close file if already open
  telling(Old),
                       % remember the current output
  tell(File),
                     % open again from the start
  assert('$$open'(File,write)),
  tell(Old).
                      % but don't change the current input
  '$$close_if_open'(File,Mode) :-
    retract('$$open'(File,Mode)), !,
    '$$closefile'(File,Mode).
  '$$closeJf_open'(File,_).
% set_input/l
%
% Change current input
set_input(user_input):- !,
  see(user).
setjnput('$$stream'(user_input)):-!,
  see(user).
set_input('$$stream'(F)) :-
  '$$open'(F,read), !,
  see(F).
% set_output/l
%
% Change current output
```

<!-- page 301 -->
Appnd

Writing Portable Standard Prolog Programs

```prolog
set_output(user_output):- !,
  tell(user).
set_output('$$stream'(user_output)) :- !,
  tell(user).
set_output('$$stream'(F)) :-
  '$$open'(F,write), !,
  tell(F).
```

### C.4.4 Miscellaneous

```prolog
% write_canonical/l
%
% Write a term, ignoring operator declarations
write_canonical(X) :- display(X).
% V / l
%
% Negation as failure
?- op(900,fy,\+).
\+ X :- not(X).
% number/1
%
% Test for whether something is a number.
% Limitations: only succeeds for integers
number(X) :- integer(X).
% @<, @>, @=<, @>=
%
% Term comparison
%
% Limitations: only succeeds for atoms, assumes the Ascii character set
?- op(700,xfx,@<).
?- op(700,xfx,@>).
?- op(700,xfx,@=<).
```

<!-- page 302 -->
```prolog
?- op(700,xfx,@>=).
X @=< Y :- atom(X), atom(Y), X=Y, !.
X @=< Y :- X @< Y.
X @> Y :- Y @< X.
X @>= Y :- Y @=< X.
X @< Y :- atom(X), atom(Y), name(X,XC), name(Y,YC), '$$aless'(XC,YC).
'$$aless'([],[_|J):- !•
'$$aless'([C|_],[Cl |_]):- C<C1, !.
'$$aless'([C|Cs],[C|Csl])
                      '$$aless'(Cs,Csl).
```
