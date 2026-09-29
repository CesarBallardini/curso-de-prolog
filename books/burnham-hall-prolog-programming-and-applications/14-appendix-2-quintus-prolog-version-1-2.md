# Appendix 2: Quintus Prolog (Version 1.2)

<!-- page 119 -->
Quintus Prolog is an advanced implementation of the language. The objectives of its designers (David Warren, Lawrence Byrd, Bill Kornfeld and Fernando Pereira) were to produce a version of the language which would offer fast execution speeds as well as the capability to communicate with other software. The software is available from Artificial Intelligence Ltd and runs under UNIX and VMS operating systems on the VAX-II and SUN-2 hardware systems. All the examples in this book (based as you know on DEC Prolog) will run under Quintus Prolog because DEC Prolog is a compatible subset of Quintus Prolog. This appendix does not attempt to describe the language in fine detail because a complete description is given in the Reference Manual accompanying the software. However, we will point out the following main features of the Quintus software.

*1. The Editor Interface*

An interesting feature is the interface to the EMACS editor, which may be accessed by the commands

prolog +

or prolog + <file-to-be-edited>

in response to the UNIX prompt. These commands cause EMACS to run with two windows: file-to-be-edited if given will appear in the upper window while Prolog will run in the lower window. Thus it is possible to execute code and see code at the same time. It is possible to access Prolog in much the same way as you would without the EMACS editor interface, since the Prolog window is still an edit buffer. Full details of the commands available are contained in the Reference Manual.

A style checker is also supplied with Quintus Prolog which will warn the user of

(1) single occurrences of named variables in a clause (that is, those not

beginning with the underline character)

<!-- page 120 -->
(2) procedures for which all the clauses are not adjacent in the source file.

*2. Entering clauses*

Prolog clauses may be entered from text mes using either the consult or compile predicates. However it should be noted that consult under Quintus Prolog behaves as reconsult would under DEC-IO Prolog. This means that a procedure may not be spread across more than one me unless it is required that clauses of the same name are deleted from the database when a consult is performed. It is also possible to modify the database using assert and retract, as discussed previously.

*3. The debugger*

The Quintus debugger closely resembles that described previously for DEC-IO Prolog. It provides facilities for single step tracing and selective debugging, using spy points placed on both compiled and interpreted procedures.

The following predicates are available for debugging

trace

- sets a state in which the debugger will start creeping on every goal typed in at the top level. debug

- sets a state in which the debugger will leap on every goal typed in at the top level. notrace turns the debugger off. spy

- sets required spy points. nospyall removes all spy points. Note that turning the debugger off will not remove the set spy points.

The debugger options + and - are available to set and remove spy points, respectively. The option =may be used to display the current debugging information.

*Leashing*

It is possible to leash the ports, by specifying the ports to be leashed as a list. For example, the command

leash ([]).

removes all leashing, causing an exhaustive trace upon creeping. The command

leash ([call, redo]).

<!-- page 121 -->
places leashes on the call and redo ports.

*4. Arithmetic*

Quintus Prolog offers both floating point and integer arithmetic. A floating point number is written as a signed decimal fraction with a decimal point, at least one digit before and after the decimal point and an optional base ten exponent. Some examples are given below

**.,.., -1., .,.54 I'''.' 1.t)e6**

12.345678e-12

*Arithmetic operators* Addition, subtraction and multiplication have the operators +, -, and * respectively for both integer and floating point arithmetic. Integer division is performed by the */I* operator, the result being an integer type. Floating point division is performed using the / operator; the result is a floating point number.

*System predicates for testing terms*

The following predicates apply

integer (X) -

Truncates X to an integer, or returns X if X is an integer. float (X)

- Results in X if X is a floating point number, or if X is an integer the result is the floating point equivalent. number (X)- Succeeds if X is instantiated to either an integer or a floating point number; if not it fails.

There are other predicates used for the testing of terms but in the main they are compatible with the DEC-lO system.

*Input/output*

As with the systems discussed before, it is possible to conduct input and output on the USER or the current stream. The predicates for use on these streams are compatible with those described throughout the book. However it is also possible to use the predicates for input and output with reference to a specific stream. This facility includes more advanced file handling predicates as well as input and output predicates which can be related to specific streams. For example, write (X, S) causes output to the stream identified by S.

*The interface to* C

<!-- page 122 -->
This is a feature that is of great importance if Prolog is to be used a component in the production of large and sophisticated systems. We cannot go into detail in this appendix since the appropriate place for such material is within the user specification for Quintus Prolog. However the process of interfacing Prolog with other software facilities is addressed by the provision of simple interfaces under UNIX and VMS. Examples of applications that have been developed using this technique include the following: incorporation of complex mathematical routines within Prolog programs (achieved by interfacing with the C mathematics library), incorporation of graphics displays controlled by Prolog programs, and use of external database management systems to provide mass data driving for Prolog programs.

Applications such as the ones described above are undoubtedly outside the scope of any text-book about the Prolog language *per se* but we mention them in order to offer the reader some perspective on how the language may be used in more advanced processing environments.

*The Quintus interpreter and compiler*

We have already mentioned the EMACS controlled program development environment. Within this environment, the user screen is split into two sections

- one is used for code development, the other for program execution. Movement between the two windows is achieved by the command sequence CTRL X f/J.

Quintus Prolog offers a range of interpreter and compiler options as follows. For both interpreter and compiler level execution, it is possible to select a complete buffer area (that is, all the code in a window), a marked region of the buffer or an individual procedure to interpret/compile. Furthermore, interpreted and compiled code will run quite freely together - thus, if one procedure of a program is faulty it is necessary only to debug that procedure and re-interpret or compile it without having to interpret or compile the whole program again.

Generally speaking, the intention is that the interpreter should be used for program development and the compiler for live running where it is likely that execution speed will be a major priority. The interperter is invoked by the command sequence ESC i and the compiler by the command sequence ESC k followed by the appropriate selection of buffer, region or procedure. Alternatively, they may be invoked by the system predicates consult and compile. For example

consult ('Prog_file1.pro').

causes the named file to be interpreted and

compile ('Prog_file2').

causes the named file to be compiled.

<!-- page 123 -->
It should be noted that although the interpreter offers only the average performance (in terms of code execution speed) associated with program development, the compiler when invoked provides fast execution speeds.

Another interesting feature of this implementation is the provision of a 'break' in program execution - this allows the programmer to alter faulty code during the run of a program. In order to do so, a 'break' can be commanded when an error occurs, the code causing the error being corrected and re-interpreted or recompiled and the program run recommenced with the corrected code incorporated in the program. This feature is particularly useful for debugging large and complex programs.

A comprehensive description of interpreter and compiler facilities appears in the documentation accompanying the software.
