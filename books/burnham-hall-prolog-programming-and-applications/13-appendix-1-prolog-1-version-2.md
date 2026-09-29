# Appendix 1: Prolog-1 (Version 2)

<!-- page 114 -->
This software is available from Expert Systems International Ltd. It is available for machines which run under MS-DOS, CP/M-86, CP/M-80 VMS, RSX-IIM and RT-11 operating systems. In this appendix we outline the operation of the Prolog interpreter on the IBM PC, and point out the major differences and similarities between this version of Prolog and that supplied on the DEC-IO implementation we have used to describe Prolog throughout the book.

This appendix does not represent a complete description of all the facilities of PROLOG-I, nor is it intended that it should. It is hoped that this short section will give the reader a 'flavour' of the language, for possible future investigation. A complete description of the language package is given in the Reference Manual accompanying the software.

*Using the interpreter*

There are two mechanisms for entering PROLOG-I. The first is to invoke the top level interpreter PROLOG86, the second is to use the interpreter with the system clause editor PROLED86.

*PROLOG86*

Invoking this interpreter enables you to read in text fIles using the system predicates consult (X) and reconsult (X) as described previously in the book.

*PROLED86*

<!-- page 115 -->
This interpreter contains a system clause editor. The clause editor provides facilities for saving and loading fIles that are distinct from consult (X) and reconsult (X). For a complete description of the editor facilities and commands the reader is referred to the User Manual. However it is worthwhile noticing that although it is possible to use the predicates consult (X) and reconsult (X), the clauses entered by this method cannot be modified using the clause editor, but you may run the program. To have the option of modifying clauses while in PROLED86 you must have entered, saved and loaded the fIle of clauses while in PROLED86. *PROLOG-] terms*

As we have mentioned earlier a Prolog term may be a constant (atom or number), variable or structure. In PROLOG-l atoms, variables and structures may be written in the way they have been written throughout this text. However numbers are slightly different. Previously we stated that Prolog supported only integers, but PROLOG-} supports both integer and real numbers. An integer is a number in the range f/J to 16383 (notice, positive integers only).

A real number may be a signed or unsigned sequence of digits separated by a decimal point, and optionally followed by an exponent (designated by an E). Some examples are given below.

12E-S

1.9Elf)

1234ES

-4.1f)

I.f)

f).tU

15.8

1.9E+lf)

-4.If)E-It)

*Operators*

The specification of operators is performed as mentioned in chapter 6. However notice that the operator precedence range is 1 to 255.

*System predicates*

The following built in predicates perform as described earlier in the text.

arg (X, Y, Z).

assert (X).

asserta (X).

assertz (X).

atom (X).

atomic (X).

call (X).

consult (X).

```prolog
debugging.
                display (X).
                               fail.
                                              functor (X, Y, Z).
get (X).
                get 0 (X).
                               halt.
                                              integer (X).
name (X, V).
                01.
                               nodebug.
                                              nonvar (X).
nospy(X).
                op(X, Y,Z).
                               print (X).
                                              put (X).
read (X).
                reconsult (X).
                               repeat.
                                              retract (X).
see (X).
                seeing (X).
                               seen (X).
                                              skip (X).
spy (X).
                tab (X).
                               tell (X).
                                              telling (X).
told (X).
                trace.
                               true.
                                              var(X).
write (X).
                writeq (X).
                               X= .. Y.
                                              X=Y.
X==Y.
                X\=Y.
                               X\==Y.
```

The following predicates are not present on the DEC-IO implementation and are listed below together with a brief description of their function. real (X)

- tests to see if X is a real number. numeric (X)

- tests to see if X is a real number or an integer. retractall (X) - removes all predicates from the database with name and

arity X. not (X)

- performs negation. This predicate acts in the same way as

<!-- page 116 -->
\+(X) defined in the chapter on system predicates. *Arithmetic*

The following arithmetic operators perform functions as previously described.

X=:=Y.

X=<Y.

X=\=Y.

X<Y.

X>=Y.

X>Y.

XisY.

You will notice that the above operators are the set of comparison and assignment terms discussed previously. As already mentioned, the PROLOG-l language supports both real and integer numbers. There are therefore several systempredicates provided for, dealing with real numbers as listed below.

float (X)

- gives a floating point version of the integer X. fix (X)

- returns an integer equivalent to X truncated toward 0. real_round (X) - rounds X to a real number, away from 0. truncate (X)

**- returns a real number equivalent to X truncated toward 0.**

*Addition, multiplication and subtraction*

These operations are indicated by the same operators mentioned in the chapter on arithmetic. However the number type of the result depends on the operands. Consider the following

XopY where X and Yare the operands and op is an operator from the set +, -, *.

Then if X and Yare both integer expressions the result will be an integer expression, otherwise the result will be a real number.

*Division*

Two operators are used for division The *I* operator performs real division. The *II* operator performs integer divison. Notice that the operands for this eperator must be integer types.

The remainder of the integer division of X by Y is given by the expression Y mod Y. Again both X and Yare integer.

*The PROLOG-l debug facilities*

<!-- page 117 -->
The tracing facility is enabled and disabled using the predicates trace and notrace respectively. The tracing messages output are Goal when trying to satisy a goal, and Proved when that goal has been proved. No messages are output if the goal fails or if an attempt is made to resatisfy the goal. However a message is output if the attempt to resatisfy the goal is successful. Spy points are set and removed from clauses using the predicates spy (X) and nospy (X). The variable X must be a predicate name or a predicate name followed by an arity enclosed in round brackets. For example, given the following database

nam(a, b). nam (c,d). nam (b, h,j).

then a call spy (nam) will place spy points on all three clauses in the database, whereas a call spy (nam(3» will placea spy point on the final clause only. The predicates debugging and nodebug perform the same function as discussed in chapter 7. An example session using the debug facility is outlined below.

/*Database*/ fruit (granny_smith). shape (victoria_plum, round). shape (granny_smith, round). colour (victoria_plum, purple). colour (granny_smith, green). apple (X) :- fruit (X),

shape (X, round),

colour (X, green).

?-debugging. There are no spy-points set.

yes ?- spy (colour). Spy-point placed on colour (2).

yes ?-apple (X). Spy Goal colour (granny_smith, green) Spy proved colour (granny_smith, green) X = granny_smith More (y/n)? n

<!-- page 118 -->
yes ?- trace. yes ?-apple (X).

Goal apple <-44)

Goal fruit <-44)

Proved fruit (granny_smith)

Goal shape (granny_smith, round)

Proved shape (granny_smith, green)

Spy Goal colour (granny_smith, green)

Spy Proved colour (granny_smith, green)

Proved colour (granny_smith, green)

Proved apple (granny_smith, green)

Proved apple (granny_smith)

**X =granny_smith**

More *(yIn)?* n

*Input output*

The input output facilities provided are an enhanced version of those discussed earlier in the book. As mentioned in the chapter on system predicates, the predicates read, write, tell etc. are all included, as well as the predicate getbyte(x) which succeeds if X matches with the next byte on the current input stream.

*Random file access*

PROLOG-! also permits random file access rather than the serial type access provided by read, write, get, and put. Random access may be performed on any disc file; the pointer to the file is positioned using the predicates seek_read (X) and seek_write (X), where X represents the file pointer position in terms of a block number and an offset. Thus a call to seek_read (1 + 2) sets the pOinter to the second byte of the first block (that is, the 130th byte), of the current input stream. The start of a file is specified by 0 + O. The reader is referred to the section on random file access in the User Manual for further information.

*Calling external procedures*

External procedures may be called using the external_code predicate. The predicate has three arguments: an operation number in the range f/J to 255, an input parameter list and an output list. The input and output parameter lists may contain up to 8 parameters. An example is given below

```prolog
status (A, B, C) :- external_code (1, [A], [B, C)).
```

The call to status (A, B, C) now corresponds to a call to the external section of machine code, passing the parameter assigned to the variable A, and receiving the parameters Band C.

The User Manual contains full details on setting up calls to external code.
