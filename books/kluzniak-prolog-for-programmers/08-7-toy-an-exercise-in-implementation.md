# 7. Toy: An Exercise in Implementation

<!-- page 194 -->
## 7.1 Introduction

This chapter is a case study of Toy—a simple but fairly complete implementation of Prolog. Only the most important (or least obvious) information is presented here, and it should be read together with the source texts available on the diskette enclosed with this book (some of these are listed in the appendices).

While designing Toy, we attempted to strike a compromise between several conÀicting goals. We wanted to write: —A clean, readable interpreter which you could ¿nd useful for “getting a feel" of what is involved in implementing a “life-size“ Prolog system; —A usable interpreter, which we could use to test all the programming examples in this book (our extant implementations were quite incompatible with Prolog-I0) and which you might use to experiment with Prolog if you have a lot of time but no access to a machine running one of the commercially available Prolog systems; —A large fragment of the implementation in Prolog itself, to provide a sizable example of using the language for solving well-known but not completely trivial programming tasks at a relatively low level; —An interpreter which, though useful, would have little commercial value.

<!-- page 195 -->
We decided to use Pascal, because it is easy to read, well known and generally available. The program is not written to be very ef¿cient: concem for readability and conciseness almost always prevailed. It is not particularly short and elegant either, as we wanted it to support a

fairly complete version of Prolog modelled after the Prolog-I0 dialect.

There are two principal reasons why we call it Toy:

—The user interface is written in Prolog, and this makes it rather slow;

—There is no garbage collector, and moreover, partitioning storage

into several disjoint ¿xed-length areas makes it easier to encounter a

memory overÀow condition.

If you decide to use Toy, you will quickly ¿nd that the time taken to read and write terms requires some patience. We had to rewrite read, write and op in Pascal for our purposes, and it is but a moderately dif¿cult task. A rather straightforward implementation resulted in another I000 lines of code, but a lot of it is dedicated to handling mixed functors (see Section 7.4.3).

We used Toy on two minicomputers: a PDP II/40 look-alike running RSXI IM, and a Polish computer called Mera 400. The PDP has an address space of 64KB; we used it to bring the system up, but it was a tight squeeze. You might do better with a P-code system rather than with a native-code compiler of Pascal, such as the one we had to use. The Mera had a I28KB address space and a fairly good native-code compiler (but with no attempt at global optimisation): we could easily load and execute both the whole Prolog interface and programs such as WARPLAN or Toy-Sequel (see Chapter 8). We tested all our programs and had quite a bit of memory to spare, running in a 104KB space.

The original implementation was subsequently ported (almost painlessly!) into Berkeley Pascal (on the VAX/780 running 4.2 BSD UNIX) and into TURBO Pascal (on the IBM PC running MS-DOS 2.l0). You can ¿nd the TURBO version on the diskette enclosed with this book. Files READ.ME, CONTENTS, INSTALL and TURBO.PAT contain general information about the diskette and the implementation. The latter ¿le summarizes changes introduced into the original Mera Pascal which was listed in the hardcover edition of this book.

Feel free to run Toy and play with it, but remember it is copyrighted. No version of this implementation may be used or distributed for gain, all listings must contain our copyright notice, and the heading produced by status (see Section 5.7.5) must contain the texts “Toy-Prolog” and “IIUW Warszawa". Other than that, you are welcome to modify it, give it to friends, etc. If you have any comment to make, we shall be happy to hear from you.

## 7.2 General Information

<!-- page 196 -->
Toy is a Non-Structure Sharing interpreter (see Chapter 6). The program written in Pascal supports a limited syntax, which we shall call Toy- Prolog, and only a subset of the usual system (built-in) procedures. The full user interface and library is implemented in Prolog (see Section 7.4)this approach was taken in the original Marseilles implementation, and in a number of implementations since. A short program called the “bootstrapper” (see Section 7.4.l), written in Toy-Prolog, is used to translate into Toy-Prolog other parts of the user interface, which are written in a slightly restricted fonn of the usual syntax. Next, various interface programs can be loaded during initialization (see Section 7.3.6).

A Prolog program called the “monitor” supports an interactive programming regime (see Section 7.4.2). Full Prolog-I0 syntax can be used (see sections 7.4.3-7.4.5). A program called the “translator” can be used to convert Prolog-I0 programs into Toy-Prolog (see Section 7.4.6). The translator shares most of the monitor’s routines. lt can be used for large (interactively debugged) programs which are to be loaded quickly, without repeated syntactic analysis by the rather slow parser in the monitor. See Appendix A.4 for a few examples of such programs.

We shall ¿nish this section with an example of Toy-Prolog syntax. There is no point in providing a precise description of this language, as it is very simple and the recursive-descent parser (a fragment called the READER, see ¿le READER.PAS on the diskette) is so straightforward that it can easily be used to resolve all doubts. Our example is

**P(la.lb.¢Ld|X1.Y)=-q(Y.X).r(s(Y).-).**

```prolog
:-p(Z,(t:-u,v)).
```

To make it directly acceptable to the READER, we write

p( a.( b.c.[] ).d.:0, :l ) : q( :l, :0) . r( s( :l ),_ ) . []

**:p( :0. ’=-‘( t. '.’( u. v ) ) ) - ll#**

See Appendix A.2 for further examples. The syntax is not nice, but is very close to the intemal representation of clauses.

## 7.3 The Toy-Prolog Interpreter

7.3.1. The Principal Storage Areas

Toy uses several disjoint areas of memory for its data structures (see Fig. 7.I). They are listed below. —CT (character table), used to store strings: print names of Prolog func-

tors and predicate symbols; —AT (atom table), used to store atoms. In this chapter “atom” does not

<!-- page 197 -->
denote a functor with no arguments. It is the generic name of a record

HTPBH

CTHIGH

ATl'¿H

"'°“'

fÀliÀ | 7'"

Àop

prototypes

‘--

=1""9I-

.-_"9b°t

prototypes

cttow

mow

"N c1

AT Ii FÀ-¿t-|

BTHIGH

‘I'll-IIGH

ground

pt0‘IOI)1>IS |

FROTLOW tree

I ree

cop’

STACKHG-I

**l.2**

```prolog
                               %-
I
                                         stildt
```

.____.__._...l 4- “PT

‘

‘__csbot

hadnraclt

M,

stacks "an

reep='d‘s

I

‘Two’ |__i. FTLOW

BTIDN

TTLOW

variable

ack Ft

B1’

It

st

MTLDW

MT

FIG. 7.l

The main data areas.

containing useful information about a symbol (a functor or predicate

symbol in our case); —MT (main table), used to store term instances and prototypes. There

are two subareas here:

—Prototype storage, which is further divided into disjoint storage

areas for ground (variable-free) prototypes and for those that con-

tain variables. The classi¿cation is important because a ground

prototype can be used to represent all its instances, and need not

be copied onto the copy stack;

—Stack storage, which is further divided into disjoint areas for the

copy stack and the variable stack (the variable stack holds varia-

bles from activation records: Pascal's type mechanism made it

more convenient to keep control information from activation re-

cords in a separate table FT); —FT (frame table), used as the activation record stack (but variables are

stacked in MT); —BT (backtrack table), used as the fail-point stack (here called back-

track-point stack—we just needed a different letter to label the table); —'l'I‘ (trail table), used as the trail stack; —Pascal's heap, used to store procedure descriptors; —Pascal's stack, used for recursion in uni¿cation and tenn-copying oper-

ations.

<!-- page 198 -->
In what follows, we shall use the word pointer, or address, to denote both Pascal pointers and indices into the tables. 7.3.2. The Dictionary: Atoms and Procedure Descriptions

The character and atom tables fonn the dictionary: a data structure used primarily as an aid in translating between the extemal and intemal forms of Prolog terms and clauses. lt also supports access to procedures, making it easier to implement variable calls and clause manipulation.

An atom is a record containing infonnation about a functor and/or a predicate symbol. The difference between a tenn and a procedure depends only on context and is not always recognized. Predicate symbols are denoted by functors when clauses are treated as terms (e.g. in assert); conversely, a functor may be used to invoke a procedure (as in call).

The attributes of an atom are

—Its print name (a pointer to a string in CT); —Its arity; —The procedure of this name and arity (a pointer to a procedure descrip-

tor, or nil).

Atoms are accessed through direct pointers or through a hashing procedure. Direct pointers are present in the representation of terms (including clauses; see the next section). The pointers are used for

—Printing a functor, —Determining arity, —Finding a procedure.

In particular, the representation of a call contains a pointer to an atom as the only handle on its procedure. Addition and deletion of clauses in the procedure does not therefore require modi¿cation of its calls.

Hashing is used to locate appropriate atoms during conversion from extemal representation. Such conversion takes place when tenns are read in or when they are created by functor and pname. For simplicity, linear rehash is used in the current version: you might wish to improve it.

<!-- page 199 -->
Print names are represented in CT by contiguous sequences of characters terminated with EOS characters (zero bytes). As a name is created by pname or the READER, its characters are pushed on top of the string area in CT (procedure buildname). On termination of the string, wrapname is invoked to locate an atom with the same printname. If such an atom is found, the string is obliterated; otherwise a new atom is created and retumed. Since this atom’s arity is unknown, the arity ¿eld is set to the special value of noarity (procedure ¿ndname).

Atoms are located by the READER in a two-phase process. First, buildname and wrapname are used to ¿nd the ¿rst atom with this name; then a single scan through the (virtual) hash chain ¿nds an atom with the correct arity, or detects its absence and creates it (procedure ¿ndatom). Conversion between atoms of different priorities, needed to implement functor, requires invocation of the hash algorithm to locate the beginning of the appropriate hash chain (procedure samename).

Procedure descriptors are allocated in the Pascal heap. Descriptors are formed of lists of records, each of them with: —a pointer to the next element in the list; —the number of variables in an activation record; —either the number of a system procedure, or pointers to the prototypes

of a clause's head and body.

A system procedure descriptor is formed of a single such record. The descriptor of a Prolog procedure is a list of records, one for each clause. The head predicate's atom always points at the ¿rst element of this list.

A clause body is represented by the prototype of a Prolog list containing its calls. Figure 7.2a illustrates the layout (recall that the binary dot is the Prolog list constructor).

7.3.3. Prototypes and Term Instances

The main table, MT, holds a variety of objects which are distinguished partly by their addresses and partly by their contents. Addresses are used to distinguish between prototypes and term instances (¿elds denoting variables contain variable offsets in prototypes, and variable bindings in term instances). Prototypes of ground terms, which contain no variables, are also used as instances: this helps keep down the size of the copy stack.

Instances of non-ground terms are kept in the stack area. It is divided into the copy stack and the variable stack. The variable stack holds activation-record variables and is separated from the copy stack because it can shrink on procedure return and not only upon backtracking (see Chapter 6).

Object contents are used to distinguish between integers, variables, and “normal” terms with functors. —Integers are two-word objects. The second word holds the integer and

the ¿rst—a special marker INT, which prevents the interpreter from

<!-- page 200 -->
treating integers as pointers. —Variables hold values less or equal to VARLIM (both INT and pointers to MT or AT objects have values greater than VARLIM). VARLIM is kept only inside the dummy variable (-) Prototype, whose address is DUMVAR)(—this

prototype

is

treated

as

```prolog
ground.
         The
              value
```

FREEVAR (equal to VARLIM — I) ¿lls free variable instances. Values below FREEVAR are negative: in prototypes their absolute values denote offsets in variable frames, and in instances their absolute values

Io)

member\

**[ 1**

**'-IIEID**

**GIEID**

**_**

**M}**

**.../\.. 6**

**NW**

FIG. 7.2

The intemal representation of member:

member( :0, :0._ ) : I]

member( :0, _.:l ):member( :0, :l ). []

(a) The abstract form. (b) The data structures (variable o¿sets adjusted by offoff; []/0,

<!-- page 201 -->
J2, J0, memberl2 denote addresses). (continued) '

I (bl ' e

merrtler/2

punot¿-uou

I

: 5 ./0 IIEiÀilll an aaunuijij nu:anru heap NI EI 1I E I

5

H Iii! I Hill Hv_i._..|

CT AT

PUITO

NILPROTX w

DUMVARX

MT I prototypes) FIG. 7.2 (Continued)

**are pointers to variable bindings. (Actually, the situation is slightly**

**different: INT = I, VARLIM = 0 and FREEVAR = —I. All negative**

**entries denote non-dummy variables. MT's lower index is 2, but van**

**able frame offsets start from 0 and are therefore adjusted by the con**

**stant OFFOFF = 2; -2 stands for offset 0, -3 for offset I, etc.)**

<!-- page 202 -->
**IIIIII**

an mtegr; -5

a variable instance:

a vanatle |:lototy|:e;

hotnd totheobject

ottset3 IadjtstedbydloÀl

at address 5 qLLr..1..1.' atom ot pl3

an instance ot

atom ot qlt

|=lqtX),_.'H.

X is tree

FIG. 7.3

intemal representation of terms.

—“NormaI” tenns are contiguous sequences of words. The ¿rst word

holds a pointer to the main functor’s atom (its arity ¿eld de¿nes the

length of the sequence). Other words represent arguments. For variable

arguments see above; other arguments are represented by pointers to

appropriate objects (see procedures getarity and getarg in the listing).

Figure 7.3 illustrates these conventions. Figure 7.2b shows the complete intemal representation of a procedure.

As explained in Chapter 6, tenn instances are pushed onto the copy stack only when absolutely necessary (when they become variable bindings) and are otherwise represented as in Structure Sharing. It is therefore convenient to represent all instances by a pair of pointers. If the ¿rst pointer addresses a prototype, the second (which we shall call the prototype‘s environment) is a pointer to an area in the variable stack. If the ¿rst pointer addresses a term instance, the second is disregarded. Note thatunlike in Structure Sharing implementations—the environment need never change as term arguments are accessed: variable bindings are never nonground prototypes and require no environment.

The normal mechanisms of object recognition and creation are circumvented in two major cases (see procedure loadsyslcernel). —To avoid creation in the copy stack of too many integer objects repre-

senting intermediate results, a range of the most frequently used inte-

gers (— I.. I0 in this version) is maintained in the form of unique ground

prototypes. —To avoid the overhead of locating character atoms, checking whether

functors represent characters, and duplicating character prototypes or

<!-- page 203 -->
instances, ground prototypes of ASCII characters are kept in a contigu-

ous area of MT. Accessing a character prototype requires only the

addition of its ordinal number to this area's address.

Certain other objects also have representations at addresses known to the interpreter. Apart from "popular" integers, characters and the dummy variable, there is also a prototype of the atom I] (see the beginning of the global variable declarations for a listing ofall these addresses). Addresses of atoms requiring special treatment are kept in the table STD (see the de¿nition of type stdatomld). There is also the prototype of a dummy clause, whose body consists of a single call to errorl I , located at address errcallseq.

Procedures for handling term representations are quite straightforward. Only prototype creation might not be immediately obvious. The method is quite similar to that used for creating entries in the dictionary. A prototype is allocated by invoking initprot with information about the main functor. Arguments are then ¿lled in by newparg and newpvararg, and the process is tenninated by wrapprot. This procedure checks if all the arguments are ground—when this is the case, the prototype is moved to the ground prototype area. Note that the process is inherently recursive, as argument prototypes may be created before their parent term‘s prototype is wrapped up. This is why initprot must be used: piecemeal allocation would not preserve contiguity.

A short comment about terminst, the procedure usually used to create terms on the copy stack. Non-variable arguments are represented not by direct pointers, but by negative values, as if they were all fonned by instantiating pre-existing variables. This is necessary because the procedure argument (which follows chains of variable bindings to locate the ¿nal instantiation) expects variable arguments directly inside the representation of their parent tenns. A recursive call on terminst can retum a variable and treating the variable as a nonnal argument—by inserting a positive pointer to it—would break the chain of references. (Such things are not easily seen, and the erroneous situations are rather infrequent: this bug was the hardest to locate!)

7.3.4. Control

In Toy, clause bodies are represented as prototypes of lists. The list elements are prototypes of calls, and none of them is an integer or a variable. While not directly related to the extemal form of clauses in Prolog-I0, this representation is very regular and easy to handle.

<!-- page 204 -->
The method of representing control state is almost exactly like that described in Chapter 6. The principal difference is that the variable part of ?-

.

[1

?_..._._._[] 1

,,,l,_

|

I

**....M--==m**

til

c

o

utm_‘g

N

- @

,,,,.,

=

|

**8""?**

**-43...**

**8**

2

T$'IIr=£ an III!

__..-.,

imI|va=t.

=-»='='

=.

**main**

**H**

“'95:” 0

l"°I=°

¥_

0

**E 2**

I'r:env=2

**nu**

**so%**

**IE!if‘III**

**III**

‘IT

BI

Ft

m

Ieteetul

FIG. 7.4

A more detailed form of Fig. 6.6d.

an activation record is kept on a separate stack. Figure 7.4 is a detailed version of Fig. 6.6d. We shall comment only on the variables used as “control registers".

The crucial variables are: —topf, a pointer to the current control frame (i.e. activation record),

which is always on top of the stack in FT; —topb, a pointer to the current backtrack point (i.e. fail point) record,

which is always on top of the stack in BT;

-csbot, a pointer to the ¿rst free location below the copy stack in MT

<!-- page 205 -->
(this stack grows downwards); —vtop, a pointer to the ¿rst free location above the variable stack in MT; —ttop, a pointer to the ¿rst free location above the trail stack in TI‘. Five auxiliary variables contain copies of infonnation available elsewhere. They are used for ef¿ciency: —ancf is a pointer to the current control frame‘s parent frame; —ropenv is a pointer to the current variable frame (associated with topf); —ancenv is a pointer to the variable frame associated with ancf; —frozenheap is a pointer to the ¿rst free location below the frozen part of

the copy stack; —frozenvars is a pointer to the ¿rst free location above the frozen part of

the variable stack.

Execution of a Prolog program is driven by the procedure resolve. Each tum of its loop is an attempt to match a call against a clause head, or to execute a system procedure. At the beginning of this step the situation is as shown in Fig. 7.4: a control frame for the current call is on top of the stack, but the clause is not yet invoked and the associated variable frame is empty. If the call was an erroneous system procedure call, the error handler is activated (see below).

If the step is unsuccessful (the head did not match the call, or the system procedure failed), the interpreter backtracks. Otherwise it enters the procedure or—if it was a system procedure or a unit clause—exits it. Entering a procedure consists in setting up the control state so that the next call to be executed will be the ¿rst call in the freshly activated clause. Exiting is the process of ¿nding the next pending call: either the one immediately following the successful current call, or (if this was the last in its clause) a call following the nearest ancestor which is not the last call in its clause.

To stop the execution, the Àag stop must be set. This is done either by the system procedure halt, or by backtrack when there are no fail points left (i.e. when the directive failed) or by exitt when it cannot ¿nd a pending call (i.e. when the directive succeeded).

Two auxiliary variables play the role of a program counter: —ccall contains a pointer to the prototype of the current call (it is the

prototype of the ¿rst element in the list indicated by the current control

frame’s calls ¿eld, unless that element is an invocation of call or tag:

ccall is then the outermost argument which is neither of these); —cproc contains a pointer to the descriptor of the procedure invoked by

ccall (for Prolog procedures, this is the ¿rst clause‘s descriptor when in

forward execution, and a pointer recovered from a backtrack point

record's resume ¿eld when immediately after a failure). Notice that a fail point‘s resume ¿eld points at the predecessor of the clause which is to be retried. This is so to make retract correct.

The algorithm

used for tail

recursion optimisation

<!-- page 206 -->
(procedure trooverlay) merits some explanation. We employ the naive method suggested by Fig. 6.7. After uni¿cation is over, procedure candotro checks whether the current call is an untagged tail call and whether the ancestor frame is not frozen. If so, neither the call nor the variable frame associated with the ancestor frame will ever be needed again. The current variable frame is shifted to replace the ancestor variable frame, and the control stack is popped so that the ancestor control frame becomes topmost (the most recently activated clause is still accessible through cproc). The algorithm is made a little complicated by the fact that the shifted variables may be instantiated to one another or to the destroyed (overlaid) variables. Both cases are illustrated in Fig. 7.5.

The cut procedure simply removes as many backtrack point records as necessary (possibly none) to ensure that the call invoking the procedure containing the cut—and all subsequent calls—will not be retried. (There are exceptions to this rule: notice that ,/2, ;/2 and call/I are transparent to the cut.) After popping off backtrack points, the interpreter must purge the topmost section of the trail to remove references to variables which are no longer frozen. This is necessary, because such variables can be popped off, or shifted, during TRO. Notice that the method ofTRO applied

Io)

- vtcp=80

I

$

3!‘-'5E

**8IIIII**

**Q**

**-—--—~**

**F»**

**-1**

H T

(variable stacltl

FIG. 7.5

<!-- page 207 -->
Tail recursion optimisation: merging two frames. (a) The initial situation. Both frames are not frozen, the call is tail recursive. The variables at 57 and $8 are instantiated to the same free variable, the variable at 59 is instantiated to the variable at 44. (b) Adjustment pass. (i) The ¿rst variable (at 57) points at an overlaid free variable (at 56). The direction of the pointer is reversed. (ii) The second variable (at 58) is dereferenced to that at $7 through that at $6. The reference is remapp-ed: the second variable points at 5$—the future location of the variable now at S7. (iii) The third variable (at $9) is dereferenced to that at 44 through that at $5. (c) Shifting pass overlays the parent's variable frame with the current variable frame; the parent's control frame becomes current. (continued) I bl

\'T°P=5O

vtop= 50

vtQ=G0

**-~**

**5»1**

- 5°- 51 51

**I**

51

msavaa

**iB**

ss

ss

ss

**56**

- —1 ti38

**iE**

**it**

**S23**

**a**

Ii)

Iiil

Iiii)

**Icl**

vtop:5l

**illI**

**- =41**

I-I he

1| €

P

HT

(variable stack)

FIG. 7.5

(Continued)

**here makes it fairly easy to perform delayed frame merging after things**

**are made detenninistic by the cut. We shall not enter into the details of**

**this and of tagcut: this is a simple exercise.**

**The last thing worth mentioning is the handling of erroneous calls to**

<!-- page 208 -->
system procedures. This involves pushing a dummy variable frame, with a single variable instantiated to the erroneous call. The current control frame (in which the call was invoked) is associated with this variable frame and becomes the ancestor of errorlI. As a result, the parameter of error/I is the rigl1t instance of the erroneous call. The process is illustrated in Fig. 7.6.

The program maintains several important invariants, such as “there are no outside references to non-frozen variable frames except from variables higher in the variable stack". We decided to let you have the fun of discovering them for yourself (after all, these are the real trade secrets).

7.3.5. System Procedures

We shall not give a detailed description of the system routines. There are too many of them, and the listing is more or less self-explanatory. The general principles are as follows: —All system procedures are invoked through procedure sysroutcall; —sysroutcall sets up pointers to their parameters in table SPAR (the

values of integer parameters are also passed through table SPARV); —System procedures that can fail or succeed indicate the result by setting

a Boolean parameter (success) passed by sysroutcall; —Whenever a system procedure detects an error, it sets the global Àag

syserror, which forces the interpreter to invoke errorl I (see the end of

the previous section).

There are no tricks, except in the procedure concemed with creating new clauses. It is important that several occurrences of a variable be represented by occurrences of the same offset when a tenn is translated into a prototype. To achieve this, addresses of variables appearing in an asserted clause are stacked in the free area above the topmost variable frame. With each variable occurrence, this temporary variable dictionary is searched linearly and, possibly, augmented. The position of a variable in this dictionary is treated as its offset.

To add a new system procedure, one must: —Write its code; —Insert its identi¿er in type sysroutid (its place there de¿nes its position); —Insert its call in procedure sysroutcall (in the same position); —Insert its name and arity in the kemel ¿le (in the same position)—see

<!-- page 209 -->
the next section. '

**to)**

|

I I Ii

**Gill**

**st-**

**_...:._._-______..I r r**

**_.l---_..-...-3.8**

**——*.**

MT Ietacke)

I'_"-_'_":

I (bl

e——-II] '1

**ElHi)**

csho topt

**liflltil**

MT

**htldol**

**FIG. 7.6**

**Handling erroneous calls to system routines. (a) wch detects an incorrect**

**argument: a(V). (b) a call to error/I is set up.**

<!-- page 210 -->
7.4. Interpretation of Prolog-I0 in Toy-Prolog

ZUI

7.3.6. Inltlalisation

initialisation is done in three phases. First, most of the variables are set by procedure lrritvars. Then two portions of data are read from the socalled “kemel ¿le”. One portion de¿nes the names and arities of standard atoms whose addresses must be known to the interpreter. They are created and their addresses are stored in table STD. The other portion de- ¿nes the names and arities of system procedures: as the atoms are created, they are associated with system procedure descriptors. The number and order of all these atoms is known to the interpreter. Arities are important, but printnames are arbitrary and can be changed at will.

The last phase of initialisation consists in creating a number of standard objects. Their addresses are known to the interpreter but they cannot be created before the addresses of standard atoms are ¿xed. The objects are: —The prototype of [ ]; —The prototypes of characters; —The prototypes of the integers — I, 0,

I0; —The dummy clause body used to invoke error (it is the prototype of

[err0r(X)]); —The prototype of user, needed by the stream switching procedures (see

Section 5.7.I).

After initialisation, the interpreter begins normal execution, reading the current ¿le. This is normally the kemel ¿le, containing some useful library procedures. One can also append the bootstrapper or the translated monitor (see below).

## 7.4 Interpretation of Prolog-10 in Toy-Prolog

IN TOY-PROLOG

7.4.1. Intennediate Language

<!-- page 211 -->
Even a modest program in Toy-Prolog can be unmanageable. To write the monitor, we use a subset of full Prolog, without operators and grammar rule notation. Commas and the symbol :- are treated as separators. List notation is allowed, with one restriction: an X in I.... .. | X] must be a variable. This subset is translated into Toy-Prolog by a "bootstrapper" written in Toy-Prolog. Debugging and testing the monitor required frequent retranslations of its small pieces, but the gain in readability was worth this extra effort. Of course, once the monitor works, the bootstrapper is no longer needed.

The bootstrapper is listed in Appendix A.2. Comments starting with %% associate mnemonics with variable numbers. The main procedure is translate (lines 2-I3), with two parameters—the names of the source and output ¿les. The unit processed with each tum of the failure-driven loop is a single clause or a comment. The loop stops upon encountering a @ in place of the ¿rst non-blank character of a unit. The translation of a clause is a string which is built “on the Ày“ on a difference list of characters; the list is represented by the two parameters christened termrepr and rest. of_termrepr. Here is how the clause in lines 54-55 would look after rewriting it into full Prolog and combining those parameters:

ctailaux( Fterm_¿rstch, Termrepr -- Rest_of_termrepr,

```prolog
                  Sym_tab ) :-
fterm( Fterm_¿rstch, Fterms_¿rstch,
      Termrepr -- [' ",
                        | Middletermrepr ], Sym_tab ),
fterms( Fterms_¿rstch, Middletermrepr -- ResLof_termrepr,
                     Sym_tab ).
```

Fterms_¿rstch is the ¿rst non-blank following a functor-term; in a correct clause, it can only be a dot, or a comma (see lines 58-66).

Comments embedded in a clause are copied at once (lines 50-53). Moreover, the string contains end-of-line and blank characters which improve the appearance of the translation.

Error in a clause causes a message to be printed and the input up to the nearest dot to be reprinted and skipped (see lines I5-21). The program assumes the data are correct, and protests upon encountering the ¿rst unexpected character.

Output for each clause with variables is followed by a comment that associates variable numbers with source names taken from a symbol table for this clause (lines 2I9-226). The table is an open list of names. Their positions are used as variable numbers in the translation. Up to 99 variables can occur in a clause. The number-name pairs are written six in a line (line 224).

<!-- page 212 -->
There are some other minor points worth noticing. For example, the output string gets closed eventually due to the [] in the initial call on clause (line II); translations of lists within lists are parethesized, see the ¿fth parameter of term (lines I31, I36, I37); identi¿ers are enclosed in quotes by fterm (lines 69-70); etc. etc. However, the rest of the program should be self-explanatory. A hint: it can be viewed as a metamorphosis grammar used for synthesis, driven by input data, with the two components of a difference list serving as an input and output parameter (see Section 3.I).

7.4.2. Overview of the Monitor

The core of the monitor is an implementation of the built-in procedure read that is used in user programs (see Section 7.4.3). The user communicaes with Prolog via an interactive "driver" which operates in a loop terminated by executing the procedure stop. In each cycle the driver prompts the user with

```prolog
?-
```

and then reads and executes a directive. The symbol table (retumed by the two-parameter read; see the end of the next section) pairs source names of variables with variables proper. After successful execution, the symbol table is used to display ¿nal instances of these variables, and the driver awaits a pI'Il'lI€lbIC character. If it is a semicolon, execution resumes with forced failure, else processing of this directive terminates.

A directive can be pre¿xed with :- (we call such a directive a command, and that without the pre¿x a query). It will then be executed deterministically, and variable instances will not be printed. However, neither a non-unit clause nor a grammar rule make sense when read directly by the driver: a two-parameter procedure :- or --> (presumably unde¿ned) would be called. User procedures can be de¿ned by calling the built-in procedure consult or reconsult; both are implemented in the driver. In “consult mode", term L --> R is treated as a grammar rule and translated by the procedure transl_rule (see Section 7.4.4). A one-parameter term :-C is treated as a command and executed. Other terms are treated as program clauses.

The monitor is listed in Appendix A.3.

7.4.3. Reader

The syntax of Prolog-I0 is only deceptively simple, so the reader is rather involved. One wonders whether a simpler syntax would necessarily be less user-friendly.

<!-- page 213 -->
The main component of the reader is a parser which produces intemal representations of tenns on input (Appendix A.3, lines 90-332). Translation of an internal representation into a term proper is quite straightforward (look at the listing of the procedure malceterm, lines 334-357, after reaching the end of this section).

The parser is a classic operator precedence parser; those parsers belong to the “shift-reduce" class—they are bottom-up and deterministic (Gries I97I, Aho and Ullman I977).

Recall that, roughly, an operator precedence grammar has no production with two consecutive non-terminals, and all its productions are such that a shift-reduce parser can determine the handle by comparing neighbouring terminals in a sentential form. This is possible when each pair of terminals is in at most one of the three relations denoted by <, =, >. The relations are de¿ned as follows (p, q are terminals, U, V, W nonterminals):

—p = q

if there exists a production of the fonn

[H

eee

ooo

or

Uaoelpvqool

**-p < q**

if there exists a production of the form

U _,,

p V

where q

or W q--- can be derived from V _p > q

if there exists a production of the form

U ,__)

...... v q ---

where

p or

p W can be derived from V

A parser shifts (i.e. scans a sentential form from left to right) until it detects a pair of terminals related by >. It then scans backwards until the nearest pair of terminals related by <. The < and > are assumed to be brackets delimiting the handle in a canonic parse: the handle is reduced and the process continues.

Note that <, = and > have nothing to do with the common numberordering relations. However, if terminals are operators as in arithmetic expressions, these relations reÀect operator priority: the grammar is structured so that higher priority operators (with operands) are reduced ¿rst. The situation is similar in the case of Prolog "operators" (even though in Prolog-I0 weaker operators are given the higher priority). We shall say—very informally—that f is weaker than g if f < g or g > f. But note that, for example, + < (, ( = ), and + > ).

We shall now return to our program. We assume that the input is delimited by two additional operators. The rightmost delimiter is weaker than any operator to its left; the leftmost is weaker than any operator to its right (except the other delimiter). Notice that an empty input is erroneous.

<!-- page 214 -->
The parser maintains a stack of symbols. Initially the stack contains

7.4. Interpretation of Prolog-I0 in Toy-Prolog

20$

only the leftmost delimiter. The ¿rst true terminal becomes the current input tenninal. In each step, the current input tenninal is compared to the topmost terminal on the stack. Three situations are possible:

I. The input is erroneous—the parser stops “with error";

2. The topmost terminal is stronger—there must be a production with the

righthand side consisting of a number of topmost symbols on the stack;

we reduce the stack by replacing all these symbols with a correspond-

ing lefthand side;

3. The topmost terminal is not stronger, i.e. no righthand side has been

completed—we shift the current input terminal onto the stack and

make the next tenninal current.

Our operator grammar of Prolog-I0 terms assumes seven classes of terminals and one class of nonterrninals, t (for terms). Parameters of symbols are used to build the intemal representation of a given term.

Terminal symbols are read by a scanner (see Appendix A.3, lines 36l-480). The procedure absorbtolren (lines 379-409) reads and constructs a “raw” token:

—id(NameString)

from words, symbols, and solo-characters; —qid(NameString)

from quoted names;

-var(NameString)

from variables; —num(NumberString)

from integers; —str(String)

from strings; —br(LeftRight, Type)

from brackets (LeftRight is I or r,

**Type is '0‘. ll. or ‘{}"):**

-—bar

from |; —dot

from a full stop. Next, the procedure maketolren (lines 457-480) constructs a terminal symbol:

-vns(Variable)

from var(NameString); —vns(Number)

from num(NumberString); —vns(String)

from str(String); —ff(Name, Types, Priority)

from id(NarneString) (when this functor

is an operator); —id(Name)

from id(NameString) (when this functor

is not an operator) and from qid(Name-

String) (i.e. a quoted name never de-

notes an operator); —br(LR, T)

<!-- page 215 -->
from br(LR, T); —bar

from bar; —dot

from dot. The terminal symbol dot is used as the rightmost delimiter of the input. The leftmost delimiter (and the seventh terminal) is bottom. It is never retumed by the scanner: the parser's main procedure, gettr, pushes it onto the initially empty stack. Both delimiters never appear in productions.

**The Types argument of ff is a list of functor types: [Binary], or**

[Unary], or [Binary, Unary] (see the de¿nition of the built-in procedure op lines 656-718)).

A symbol table in an open list is used to relate a variable’s name to a Prolog variable.

The grammar underlying the parser is given in the listing (lines 99- I07). The de¿nition of intemal representation can be read off the reduce procedure (lines I58-I79). Incidentally, the procedure can be paraphrased as a metamorphosis grammar. For example, the ¿fth and sixth clause would be rewritten as

```prolog
t(tr(TyP¢.X))->lbr(l.Tyr>¢)l.t(X).
                  lbr(r.TyP<=)1-
t(bar(X.Y))—>lbr(l.ll)l.t(X).lbarl.
                  t(Y).Ibr(r.ll)1.
```

Notice, however, that top-down analysis based on such a grammar would not be deterministic.

There are ¿ve types of intemal representations: —arg0(X)

for X a variable, name, string, or nullary functor; —trI(Narne, X)

for a pre¿x or post¿x term (X is the representa-

tion of the argument); —tr2(Name, X, Y)

for an in¿x term-(X, Y are the representations of

the arguments; in particular, the comma is an in-

¿x functor, so “comma-lists" of terms are repre-

sented with tr2—for example, the representation

of

a, b, c

is

1r2(

```prolog
ars0( a ).
tr2(
       ars0( b ). ars0( c ) ) );
```

—bar(X, Y)

for a list with front X and tail Y; X is often the

<!-- page 216 -->
representation of a comma-list; —tr(Name, X)

for all other valid situations:

tr(‘()', X) is equivalent to X;

tr([], X) represents a list (of de¿nite length), X

usually represents a comma-term

tr('{}’, X) represents the term {(Cond)} where

Cond is the term represented by X (this is

used in grammar rules);

tr(Narne, X) with Name other than a bracket

type (and X—usually the representation of a

comma-term) represents a nonnal term; for

example, the term

foo( rapes,

is represented by

```prolog
tr(f00.tr2(‘.’.Àrs0(lPl).ars0(5)))
```

The parser's entry point is the procedure gettr (lines I25-I27), and the main loop is implemented as the procedure parse (lines I29-I38). The loop tenninates successfully when the original input (bottom and dot included) reduces to the sequence

bottom

```prolog
t( IntemaIRepresentation )
                            dot
```

The parser fails in two situations:

—when the procedure establish_precedence fails, i.e. when the topmost

tenninal on the stack and the current input terminal do not compare;

-when the procedure reduce fails, i.e. the top segment of the stack does

not match any production.

The procedure topterminal (lines I40-I43) retums Top, the topmost stack terminal, and its position: I means Top is the top item, 2 means it is covered by a t(_).

The precedence relations are summarized in Table 7.I. We treat all operatorsjointly with respect to other terminals. Empty slots signify erroneous combinations of contiguous tenninals.

<!-- page 217 -->
A functor-functor relationship is the only potentially conÀicting one: to establish the precedence relation for a given Top and Input, we must consider their priorities and types (sometimes even some broader context should be considered but this might require changes in the otherwise deterministic algorithm). If the priorities differ, the functor with lower priority is taken as stronger, according to the conventions of Prolog-I0. (Notice, however, that when Top is stronger, Input cannot be a TABLE 7.1 Precedence Relations for the Operator Grammar of Terms Q

vns

id

I

bottom

dot mrmll ~

**IIH**

**< nu**

**»**

**>-liar**

**I**

**-=<**

**<IIHl**

»

**-<**

**<IIHl**

]

>*

>

{

**=<**

**VIV**

**runn-**

**vs»VIII-**

**1¿VVvu-**

>3 }

I

**._.__|_.**

-'3!

AAAA

AI

A

W

<e

>3

**IIV-VvIII—**

bottom

**<<<<<<<<<<**

>

dot

**.**

**I**

**' Top can be any pre¿x or in¿x functor, i.e. Types = [xf] and Types = Iyfl are ex-**

cluded. ’ Input can be any in¿x or post¿x functor, i.e. Types = [fx] and Types = [fy] are excluded. pre¿x functor, and when Input is stronger, Top cannot be post¿x.) If Top and Input have equal priorities, their types must be examined (see below). Mixed‘ functors require special treatment. In most contexts, their inherent ambiguity is apparent: only one of a functor’s types can be properly attributed to it. For example, let Input be &, an [xfy, fy] functor, and Top a left parenthesis not covered by a non-terminal: .... .. ( & Surely, & can only be a pre¿x variation of this mixed functor—an in¿x variation is excluded. Likewise, if Top is $, an [xfx, xfl functor, covered

<!-- page 218 -->
' Recall that our version of Prolog allows a mixed functor to have only one binary and one unary type, both with the same priority. by a non-terminal, and Input a right bracket:

.... .. $ Term ]

then $ certainly cannot be a post¿x functor. In such situations, we can “disambiguate” the mixed functor by removing the incompatible type from its representation. For example, we replace ff(‘&', [xfy, fy], Priority) with ff(‘&', [fy], Priority).

The relation in Table 7.I is implemented by the procedure establish_precedence (lines I95-204), which takes the two terminals and the position of Top. It fails given an incorrect combination, otherwise it succeeds with the fourth parameter instantiated as gt (Top is stronger) or lseq (Top is not stronger). When both tenninals are mixed functors, the procedure tries to disambiguate their types. The last two parameters are instantiated as the new top and new input tenninal, to be used in the next step (usually they remain unchanged).

**The real job is done by the procedure p which retums gt or lseq, or-**

when functors are involved—gt(NewTop. Newlnput) or lseq(NewTop, Newlnput). It fails given an erroneous pair of tenninals.

Table 7.l has 80-odd nonempty entries, but it can be easily simpli¿ed. First of all, we can treat bottom and dot separately; see the last two clauses ofp (lines 240-241). Next, we consider slots with “="—the ¿rst four clauses (lines 206-209) take care of this, and the remainder of p can operate with the six slots cleared. Now we are left with a I0 x I0 table with three different rows and three columns. Table 7.2 depicts the situation after combining identical rows and columns.

TABLE 7.2

Slrnpllletl Precedence Relations

vnsid

I.’

**:t|I-I**

' Top and Input cannot be separated by a non-

```prolog
terminal.
    ‘ Input cannot be a pre¿x functor.
    ‘ Top cannot be a post¿x functor.
```

<!-- page 219 -->
The next six clauses of p (lines 2I I-222) take care of the six noncon- Àicting slots in Table 7.2. The procedure restrict (lines 265-271) is used to test and possibly disambiguate the type of a functor. The procedure perfonns set subtraction for sets given as lists; it will fail if the difference is an empty set.

Now we must try to resolve a conÀict in the remaining slot. A closer look at the grammar allows a re¿nement of this slot (see Table 7.3). The l2th and l3th clauses of p (lines 229-238) are responsible for situations when the priorities differ. Again, we also attempt a disambiguation of types.

The Ilth clause (lines 225-227) applies to functors with equal priorities. Table 7.4 shows the precedence relation in this case. We allow all combinations that can be disarnbiguated without analysing broader context to the left or to the right of the two functors. For example, an xfy functor f is weaker than an xfx functor g because the tenn

**AfBgC**

cannot be interpreted as

( A f B ) g C —g’s left argument would have, incorrectly, the same priority as g.

**The relation of Table 7.4 is implemented by the procedureÀip (lines**

3I9-332), which returns lseq, gt or err. ConÀict resolution is performed by the procedure res_conÀ (lines 273-291), which also returns lseq, gt or err (err is later rejected by do_rels called in p). It also retums disambiguated—sometimes unchanged—functors.

If only one of the terminals is a mixed functor, we choose a nonconÀicting interpretation by comparing slots in Table 7.4. This is done by

TABLE 7.3

A Re¿nement for Two Operators

**3**

**H**

pre¿x

III x

st¿x

pre¿x

in¿x

vnVA

<!-- page 220 -->
post¿x

7.4. Interpretation of Prolog-I0 in Toy-Prolog

ZI I

TABLE 7.4

Precedence Relations for Operators with Eqnal Priorities

**5-**

*5.

::=

re

lnput’s

.

lYP¢

Top's

I

type

xfy

xfx

xf

**»»**

**>- II**

**»~**

**II**

**I»**

**>~**

**>- II**

I

AI

A

A

yf

>*

>*

I.

- ......

I‘

**H**

**>»**

**>» --**

**' Top and Input must be separated by a non-tenninal.**

’ Top and Input must not be separated by a non-tenninal.

**the procedure match_rels (lines 297-300). For two mixed functors we**

**extract a subtable of relations for each possible pair of interpretations; see**

**Table 7.5 (and lines 286-289). The situation is clear if all four slots are the**

**same. Otherwise there are only four pattems which can be correct: when**

**one of the rows or one of the columns contains two err slots. Details—in**

**the procedure res_mixed (lines 302-3l7).**

**The procedure read(Term, SymbolTable) perfonns the two phases of**

**the reader—see lines 65-69. It retums the symbol table with variables**

**from this tenn. The table is used by the interactive driver (see Section**

TABLE 7.5

The Snbtable Template for Two Mixed Fnnctore:

tbeBInaryandUnary'I"ypesAreCo|||paredIrIth

**EachOther-**

**-...,...**

**-...,...**

TTopBin

RelBB

**"M @**

**R-"=8**

<!-- page 221 -->
7.4.2). If data are incorrect, the parser will stop on the ¿rst bad symbol and read/2 will skip characters up to the nearest full stop after this symbol (which may also be a full stop). The built-in procedure read/I simply encapsulates read/2.

7.4.4. Grammar. Preproeessor

The grammar rule preprocessor (lines 482-583 in Appendix A.3) operates according to the principles presented in Chapter 3. The list of lefthand side terminals (usually empty) is connected to the output variable of the lefthand side non-terminal. Calls on the procedure terminal (Section 3.1) are “preexecuted" for eÀiciency. By way of explanation, here are two examples. The rule

**a—>lPl.b.lq.rl.¢-**

is translated into

```prolog
a(lPlXl.Z)=-b(X.lq.r|Yl).¢(Y.Z).
```

Therule

a—+b,[q,r],c,[s]. is translated into

**a(X.Z)=-b(X.lq.flYl).¢(Y.l$|Zl)-**

(The translation of a list of terminals is true, absorbed by the next item's translation; see combine, lines 540-542).

Conditions/actions (other than a single cut) are passed to the preprocessor as ‘{}‘(C); see the procedure malreterm in the reader, lines 345- 346). The functor ‘{}‘ is stripped off by the procedure transl_item, line 550.

Righthand sides separated by semicolons are preceded by a nonterminal de¿ned as

‘

dummy‘ —> []. This is necessary when altematives start with different terminals. For example, the rules

a—>[p],b.

and

a—>[q],c. would be translated with

**À(lP|Y].Z)**

and

```prolog
a(lq|Yl.Z)
```

<!-- page 222 -->
7.4. Interpretation of Prolog-I0 in Toy-Prolog

ZI3

as a lefthand side. Consequently the rule

**a—>[Pl.b:lql.¢.**

must be translated as

**3(X.Z-)2-'dummy‘(X,[p|Y]),b(Y,Z);**

**‘dummy'(X,l¢llV]),c(V,Z).**

For simplicity, this has been applied to all rules with altematives.

1.4.5. Library

The library (Appendix A.3, lines 585-1002) contains de¿nitions of about 20 built-in procedures (note that several simple procedures are also de¿ned in the

kernel

¿le,

appendix A.l). Their de¿nitions in

Chapter

5

can be treated as design documentation. Their implementation is largely straightforward. We shall comment on a few not quite obvious passages.

The procedures clause(Head, Body) and retract(Clause) are “backtrackable”, i.e. can be used in failure-driven loops that generate or remove all matching clauses. Here is a description of the generator (the other procedure is programmed similarly). We are going to visit all clauses of a procedure and suspend execution each time we get to a matching one. This is achieved by setting up a recursive loop with its step distributed between two clauses (see the procedure remcls/7, lines 814- 822). The ¿rst clause does the matching. Upon mismatch, we immediately proceed with the second clause, i.e. conclude the step. If the matching succeeds, the generator succeeds, too, but with a pending altemative. A failure later on resumes the second half of the step.

The procedures write and writeq both encapsulate the procedure outterm(Tenn, With_or_withouLquotes) which ¿rst uses numbervars (lines 623-632) to bind all variables in Term, and next calls

```prolog
outt( TernLafter_numbervars, Context, With_or_withouLquotes ).
```

<!-- page 223 -->
Context speci¿es the essential features of a functor whose argument is Term. If it is not an operator, or there is no extemal functor, then Context is fd(_, _). Otherwise, Context is fd(ff(Priority, Associativity), Dir). Term may be to the left (Dir = I) or to the right (Dir = r) of the functor. Associativity may be a(l) or a(r) for left- and right-associative functors, and na(l), na(r), or na(_) for non-associative functors. Context is tested by the procedure out)fl5 (lines 933-935) to decide whether Term should be parenthesized to avoid ambiguity in the case of equal priorities. Actually, the test—performed by agree (lines 939-943)—is rather crude (see the previous section!): sometimes we overparenthesize. The parameter of na has only been added for homogeneity, but it could be used in a more subtle detection of non-ambiguous cases.

7.4.6. Translator

The translator of Prolog-I0 into Toy-Prolog (Appendix A.3, lines I004l088) is invoked by the call

```prolog
translate( SourceFileName, OutputFileName ).
```

Commands are translated and also executed (detenninistically), so that, for example, a declaration of an in¿x functor affects subsequent parts of the input program. The translator terminates (and succeeds) after reading in the unary clause

```prolog
end.
```

The program is quite easy to understand. Only the procedure lookup may require an explanation. The table pairs variables of the clause with consecutive integers, starting from 0. A variable is a key, so we must use the built-in procedure eqvar to locate variables already present in the table. The third parameter of the procedure loolcup indicates the last number encountered (initially, -1), so that only a new variable requires one addition. A more simple-minded solution would be to keep only variables in the table, and count them during lookup. This would require at least (n — I) * nl2 additions for a clause with n variables. (In Toy, integers are implemented in a particularly simple way, so this might ¿ll the copy stack with many dead integers). Another possibility is to apply the procedure numbervars—inside put—to Head and Body jointly.

The translator outputs bare translations. It would be helpful to have source comments transferred to the translation, and to get source variable names paired with numbers (see Section 7.4.1). Try this exercise for yourself.

