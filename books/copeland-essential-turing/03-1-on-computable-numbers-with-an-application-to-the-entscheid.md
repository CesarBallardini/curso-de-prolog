# 1. On Computable Numbers, with an Application to the Entscheidungsproblem (1936)

<!-- page 67 -->
**Alan Turing**

The ‘‘computable’’ numbers may be described brieXy as the real numbers whose expressions as a decimal are calculable by Wnite means. Although the subject of this paper is ostensibly the computable numbers, it is almost equally easy to deWne and investigate computable functions of an integral variable or a real or computable variable, computable predicates, and so forth. The fundamental problems involved are, however, the same in each case, and I have chosen the computable numbers for explicit treatment as involving the least cumbrous technique. I hope shortly to give an account of the relations of the computable numbers, functions, and so forth to one another. This will include a development of the theory of functions of a real variable expressed in terms of computable numbers. According to my deWnition, a number is computable if its decimal can be written down by a machine.

In §§ 9, 10 I give some arguments with the intention of showing that the computable numbers include all numbers which could naturally be regarded as computable. In particular, I show that certain large classes of numbers are computable. They include, for instance, the real parts of all algebraic numbers, the real parts of the zeros of the Bessel functions, the numbers p, e, etc. The computable numbers do not, however, include all deWnable numbers, and an example is given of a deWnable number which is not computable.

Although the class of computable numbers is so great, and in many ways similar to the class of real numbers, it is nevertheless enumerable. In § 8 I examine certain arguments which would seem to prove the contrary. By the correct application of one of these arguments, conclusions are reached which are

<!-- page 68 -->
[Received 28 May, 1936.—Read 12 November, 1936.] This article Wrst appeared in Proceedings of the London Mathematical Society, Series 2, 42 (1936–7). It is reprinted with the permission of the London Mathematical Society and the Estate of Alan Turing. superWcially similar to those of Go¨del.1 These results have valuable applications. In particular, it is shown (§ 11) that the Hilbertian Entscheidungsproblem can have no solution.

In a recent paper Alonzo Church has introduced an idea of ‘‘eVective calculability’’, which is equivalent to my ‘‘computability’’, but is very diVerently deWned.2 Church also reaches similar conclusions about the Entscheidungsproblem.3 The proof of equivalence between ‘‘computability’’ and ‘‘eVective calculability’’ is outlined in an appendix to the present paper.

**1. Computing machines**

We have said that the computable numbers are those whose decimals are calculable by Wnite means. This requires rather more explicit deWnition. No real attempt will be made to justify the deWnitions given until we reach § 9. For the present I shall only say that the justiWcation lies in the fact that the human memory is necessarily limited.

We may compare a man in the process of computing a real number to a machine which is only capable of a Wnite number of conditions q1, q2, . . . , qR which will be called ‘‘m-conWgurations’’. The machine is supplied with a ‘‘tape’’ (the analogue of paper) running through it, and divided into sections (called ‘‘squares’’) each capable of bearing a ‘‘symbol’’. At any moment there is just one square, say the r-th, bearing the symbol S(r) which is ‘‘in the machine’’. We may call this square the ‘‘scanned square’’. The symbol on the scanned square may be called the ‘‘scanned symbol’’. The ‘‘scanned symbol’’ is the only one of which the machine is, so to speak, ‘‘directly aware’’. However, by altering its m-conWguration the machine can eVectively remember some of the symbols which it has ‘‘seen’’ (scanned) previously. The possible behaviour of the machine at any moment is determined by the m-conWguration qn and the scanned symbol S(r). This pair qn, S(r) will be called the ‘‘conWguration’’: thus the conWguration determines the possible behaviour of the machine. In some of the conWgurations in which the scanned square is blank (i.e. bears no symbol) the machine writes down a new symbol on the scanned square: in other conWgurations it erases the scanned symbol. The machine may also change the square which is being scanned, but only by shifting it one place to right or left. In addition to any of these operations the m-conWguration may be changed. Some of the symbols written down will form the sequence of Wgures which is the decimal of the real number which is being

1 Go¨del, ‘‘U¨ ber formal unentscheidbare Sa¨tze der Principia Mathematica und verwandter Systeme, I’’, Monatshefte Math. Phys., 38 (1931), 173–198.

2 Alonzo Church, ‘‘An unsolvable problem of elementary number theory’’, American J. of Math., 58 (1936), 345–363.

<!-- page 69 -->
3 Alonzo Church, ‘‘A note on the Entscheidungsproblem’’, J. of Symbolic Logic, 1 (1936), 40–41. computed. The others are just rough notes to ‘‘assist the memory’’. It will only be these rough notes which will be liable to erasure.

It is my contention that these operations include all those which are used in the computation of a number. The defence of this contention will be easier when the theory of the machines is familiar to the reader. In the next section I therefore proceed with the development of the theory and assume that it is understood what is meant by ‘‘machine’’, ‘‘tape’’, ‘‘scanned’’, etc.

**2. Definitions**

Automatic machines If at each stage the motion of a machine (in the sense of § 1) is completely determined by the conWguration, we shall call the machine an ‘‘automatic machine’’ (or a-machine).

For some purposes we might use machines (choice machines or c-machines) whose motion is only partially determined by the conWguration (hence the use of the word ‘‘possible’’ in § 1). When such a machine reaches one of these ambiguous conWgurations, it cannot go on until some arbitrary choice has been made by an external operator. This would be the case if we were using machines to deal with axiomatic systems. In this paper I deal only with automatic machines, and will therefore often omit the preWx a-.

Computing machines If an a-machine prints two kinds of symbols, of which the Wrst kind (called Wgures) consists entirely of 0 and 1 (the others being called symbols of the second kind), then the machine will be called a computing machine. If the machine is supplied with a blank tape and set in motion, starting from the correct initial m-conWguration, the subsequence of the symbols printed by it which are of the Wrst kind will be called the sequence computed by the machine. The real number whose expression as a binary decimal is obtained by prefacing this sequence by a decimal point is called the number computed by the machine.

At any stage of the motion of the machine, the number of the scanned square, the complete sequence of all symbols on the tape, and the m-conWguration will be said to describe the complete conWguration at that stage. The changes of the machine and tape between successive complete conWgurations will be called the moves of the machine.

<!-- page 70 -->
Circular and circle-free machines If a computing machine never writes down more than a Wnite number of symbols of the Wrst kind, it will be called circular. Otherwise it is said to be circle-free.

A machine will be circular if it reaches a conWguration from which there is no possible move, or if it goes on moving, and possibly printing symbols of the second kind, but cannot print any more symbols of the Wrst kind. The signiWcance of the term ‘‘circular’’ will be explained in § 8.

**Computable sequences and numbers**

A sequence is said to be computable if it can be computed by a circle-free machine. A number is computable if it diVers by an integer from the number computed by a circle-free machine.

We shall avoid confusion by speaking more often of computable sequences than of computable numbers.

**3. Examples of computing machines**

I. A machine can be constructed to compute the sequence 010101 . . . . The machine is to have the four m-conWgurations ‘‘b’’, ‘‘c’’, ‘‘k’’, ‘‘e’’ and is capable of printing ‘‘0’’ and ‘‘1’’. The behaviour of the machine is described in the following table in which ‘‘R’’ means ‘‘the machine moves so that it scans the square immediately on the right of the one it was scanning previously’’. Similarly for ‘‘L’’. ‘‘E’’ means ‘‘the scanned symbol is erased’’ and ‘‘P’’ stands for ‘‘prints’’. This table (and all succeeding tables of the same kind) is to be understood to mean that for a conWguration described in the Wrst two columns the operations in the third column are carried out successively, and the machine then goes over into the m-conWguration described in the last column. When the second column is left blank, it is understood that the behaviour of the third and fourth columns applies for any symbol and for no symbol. The machine starts in the m-conWguration b with a blank tape.

ConWguration

Behaviour

m-conWg.

symbol

operations

Wnal m-conWg.

b

None

P0, R

c

c

None

R

e

e

None

P1, R

k

k

None

R

b

If (contrary to the description in § 1) we allow the letters L, R to appear more than once in the operations column we can simplify the table considerably.

m-conWg.

symbol

operations

Wnal m-conWg.

b

None

0

1

(

P0

b

R, R, P1

b

R, R, P0

<!-- page 71 -->
b

II. As a slightly more diYcult example we can construct a machine to compute the sequence 001011011101111011111 . . . . The machine is to be capable of Wve m-conWgurations, viz. ‘‘o’’, ‘‘q’’, ‘‘p’’, ‘‘f’’, ‘‘b’’ and of printing ‘‘@’’, ‘‘x’’, ‘‘0’’, ‘‘1’’. The Wrst three symbols on the tape will be ‘‘@@0’’; the other Wgures follow on alternate squares. On the intermediate squares we never print anything but ‘‘x’’. These letters serve to ‘‘keep the place’’ for us and are erased when we have Wnished with them. We also arrange that in the sequence of Wgures on alternate squares there shall be no blanks.

ConWguration

Behaviour m-conWg.

symbol

operations

Wnal m-conWg. b

P@, R, P@, R, P0, R, R, P0, L, L

o



R, Px, L, L, L

o

q o

1

0



R, R

P1, L

q

p q

Any (0 or 1)

None

(

E, R p

R

L, L

q

f

p

x

@

None



R, R

P0, L, L f

Any

None

f

o

To illustrate the working of this machine a table is given below of the Wrst few complete conWgurations. These complete conWgurations are described by writing down the sequence of symbols which are on the tape, with the m-conWguration written below the scanned symbol. The successive complete conWgurations are separated by colons.

This table could also be written in the form

: @ @ o 0

0

: @ @ q 0

0

: . . . ,

<!-- page 72 -->
in which a space has been made on the left of the scanned symbol and the m-conWguration written in this space. This form is less easy to follow, but we shall make use of it later for theoretical purposes.

The convention of writing the Wgures only on alternate squares is very useful: I shall always make use of it. I shall call the one sequence of alternate squares F-squares and the other sequence E-squares. The symbols on E-squares will be liable to erasure. The symbols on F-squares form a continuous sequence. There are no blanks until the end is reached. There is no need to have more than one E-square between each pair of F-squares: an apparent need of more E-squares can be satisWed by having a suYciently rich variety of symbols capable of being printed on E-squares. If a symbol b is on an F-square S and a symbol a is on the E-square next on the right of S, then S and b will be said to be marked with a. The process of printing this a will be called marking b (or S) with a.

**4. Abbreviated tables**

There are certain types of process used by nearly all machines, and these, in some machines, are used in many connections. These processes include copying down sequences of symbols, comparing sequences, erasing all symbols of a given form, etc. Where such processes are concerned we can abbreviate the tables for the m-conWgurations considerably by the use of ‘‘skeleton tables’’. In skeleton tables there appear capital German letters and small Greek letters. These are of the nature of ‘‘variables’’. By replacing each capital German letter throughout by an m-conWguration and each small Greek letter by a symbol, we obtain the table for an m-conWguration.

The skeleton tables are to be regarded as nothing but abbreviations: they are not essential. So long as the reader understands how to obtain the complete tables from the skeleton tables, there is no need to give any exact deWnitions in this connection.

Let us consider an example:

m-conWg.

Symbol

Behaviour

Final m-conWg.

f(C, B, a)

@

not @

```prolog
                   f1(C, B, a)
                   f(C, B, a)

          L
          L
  a
8
<
                   C
                   f1(C, B, a)
```

f1(C, B, a)

:

R

not a

None

R

```prolog
                   f2(C, B, a)
8
<
```

f2(C, B, a)

From

the

m-conWguration

f(C, B, a) the machine Wnds

the symbol of form a which

is farthest to the left (the

‘‘Wrst a’’) and the

m-conWguration then

becomes C. If there is no a

then the m-conWguration

becomes B.

a

not a

None

:

R

R

C

```prolog
f1(C, B, a)
B
```

<!-- page 73 -->
If we were to replace C throughout by q (say), B by r, and a by x, we should have a complete table for the m-conWguration f(q; r; x). f is called an ‘‘m-conWguration function’’ or ‘‘m-function’’.

The only expressions which are admissible for substitution in an m-function are the m-conWgurations and symbols of the machine. These have to be enumerated more or less explicitly: they may include expressions such as p(e, x); indeed they must if there are any m-functions used at all. If we did not insist on this explicit enumeration, but simply stated that the machine had certain m-conWgurations (enumerated) and all m-conWgurations obtainable by substitution of m-conWgurations in certain m-functions, we should usually get an inWnity of m-conWgurations; e.g., we might say that the machine was to have the m-conWguration q and all m-conWgurations obtainable by substituting an m-conWguration for C in p(C). Then it would have q, p(q), p p(q)

ð

Þ, p p p(q)

ð

) ð

Þ, . . . as m-conWgurations.

Our interpretation rule then is this. We are given the names of the m-conWgurations of the machine, mostly expressed in terms of m-functions. We are also given skeleton tables. All we want is the complete table for the m-conWgurations of the machine. This is obtained by repeated substitution in the skeleton tables.

Further examples (In the explanations the symbol ‘‘!’’ is used to signify ‘‘the machine goes into the m-conWguration. . . .’’)

```prolog
e(C, B, a)
               f(e1(C, B, a), B, a)
                                 From e(C, B, a) the Wrst a is erased
```

and ! C. If there is no a ! B.

```prolog
e1(C, B, a)
           E
               C
e(B, a)
               e(e(B, a), B, a)
                                 From e(B, a) all letters a are erased
                                 and ! B.
```

The last example seems somewhat more diYcult to interpret than most. Let us suppose that in the list of m-conWgurations of some machine there appears e(b, x) ( ¼ q, say). The table is

```prolog
e(b, x)
                         e(e(b, x), b, x)
```

or

q

```prolog
e(q, b, x).
```

Or, in greater detail:

q

```prolog
                           e(q, b, x)
e(q, b, x)
                           f(e1(q, b, x), b, x)
e1(q, b, x)
                 E
                           q.
```

<!-- page 74 -->
In this we could replace e1(q, b, x) by q0 and then give the table for f (with the right substitutions) and eventually reach a table in which no m-functions appeared.

 pe(C, b)

```prolog
f(pe1(C, b), C, @)
                   From pe(C, b) the machine
```

prints b at the end of the

sequence of symbols and ! C. pe1(C, b)

Any

R, R

None

Pb

```prolog
pe1(C, b)
C
```

l(C)

L

C

From f0(C, B, a) it does the

same as for f(C, B, a) but

moves to the left before ! C. r(C)

R

C f0(C, B, a)

```prolog
f(l(C), B, a)
```

f00(C, B, a)

```prolog
f(r(C), B, a)
```

c(C, B, a)

```prolog
f0(c1(C), B, a)
                   c(C, B, a). The machine
```

writes at the end the Wrst

symbol marked a and ! C. c1(C)

b

```prolog
pe(C, b)
```

The last line stands for the totality of lines obtainable from it by replacing b by any symbol which may occur on the tape of the machine concerned.

ce(B, a)

```prolog
ce(ce(B, a), B, a)
```

ce(C, B, a)

```prolog
c(e(C, B, a), B, a)
                      ce(B, a). The machine
```

copies down in order

at the end all symbols

marked a and erases

the letters a; ! B. re(C, B, a, b)

```prolog
f(re1(C, B, a, b), B, a)
                      re(C, B, a, b). The machine
                      replaces the Wrst a by b and
```

! C ! B if there is no a. re1(C, B, a, b) E; Pb

C

re(B, a, b)

```prolog
re(re(B, a, b), B, a, b)
                      re(B, a, b). The machine
```

replaces all letters a by

b; ! B.

cr(B, a)

```prolog
cr(cr(B, a), re(B, a, a), a)
```

cr(C, B, a)

```prolog
c(re(C, B, a, a), B, a)
                      cr(B, a) diVers from
```

ce(B, a) only in that the

letters a are not erased. The

m-conWguration cr(B, a) is

taken up when no letters ‘‘a’’

are on the tape.

cp(C, A, E, a, b)

```prolog
f0(cp1(C, A, b), f(A, E, b), a)
```

cp1(C, A, b)

g

```prolog
f0(cp2(C, A, g), A, b)
```

cp2(C, A, g)

g

not g

n

C

<!-- page 75 -->
A:

The Wrst symbol marked a and the Wrst marked b are compared. If there is neither a nor b, ! E. If there are both and the symbols are alike, ! C. Otherwise ! A. cpe(C, A, E, a, b)

```prolog
cp(e(e(C, C, b), C, a), A, E, a, b)
```

cpe(C, A, E, a, b) diVers from cp(C, A, E, a, b) in that in the case when there is similarity the Wrst a and b are erased. cpe(A, E, a, b)

```prolog
cpe(cpe(A, E, a, b), A, E, a, b).
```

cpe(A, E, a, b). The sequence of symbols marked a is compared with the sequence marked b. ! E if they are similar. Otherwise ! A. Some of the symbols a and b are erased.

q(C)

Any

R

None

R

n

```prolog
q(C)
q1(C)
              q(C, a). The machine Wnds
              the
                  last
                      symbol
                            of
                               form
              a: ! C.
```

q1(C)

Any

R

None

n

```prolog
q(C)
C
```

q(C, a)

```prolog
q(q1(C, a))
```

q1(C, a)

a

Not a

L

n

C

```prolog
q1(C, a)
```

pe2(C, a, b)

```prolog
pe(pe(C, b), a)
              pe2(C, a, b). The machine
```

prints a b at the end.

ce3(B, a, b, g)

```prolog
ce(ce2(B, b, g),
a)
```

ce2(B, a, b)

```prolog
ce(ce(B, b), a)
              ce3(B, a, b, g). The
```

machine copies down at the

end Wrst the symbols marked

a, then those marked b, and

Wnally

those marked g; it

erases the symbols a, b, g.

e(C)

@

R

Not @

L

n

```prolog
               e1(C)
               e(C)
n
               e1(C)
```

From e(C) the marks are

erased

from

all

marked

symbols. ! C. e1(C)

Any

R, E, R

None

C

**5. Enumeration of computable sequences**

A computable sequence g is determined by a description of a machine which computes g. Thus the sequence 001011011101111 . . . is determined by the table on p. [62], and, in fact, any computable sequence is capable of being described in terms of such a table.

<!-- page 76 -->
It will be useful to put these tables into a kind of standard form. In the Wrst place let us suppose that the table is given in the same form as the Wrst table, for example, I on p. [61]. That is to say, that the entry in the operations column is always of one of the forms E : E, R : E, L : P a : P a, R : P a, L : R : L : or no entry at all. The table can always be put into this form by introducing more mconWgurations. Now let us give numbers to the m-conWgurations, calling them q1, . . . , qR, as in § 1. The initial m-conWguration is always to be called q1. We also give numbers to the symbols S1, . . . , Sm and, in particular, blank ¼ S0, 0 ¼ S1, 1 ¼ S2. The lines of the table are now of form

m-conWg.

Symbol

Operations

Final m-conWg.

qi

Sj

PSk, L

qm

(N1)

qi

Sj

PSk, R

qm

(N2)

qi

Sj

PSk

qm

(N3)

Lines such as

qi

Sj

E, R

qm

are to be written as

qi

Sj

PS0, R

qm

and lines such as

qi

Sj

R

qm

to be written as

qi

Sj

PSj, R

qm

In this way we reduce each line of the table to a line of one of the forms (N1), (N2), (N3).

From each line of form (N1) let us form an expression qiSjSkLqm; from each line of form (N2) we form an expression qiSjSkRqm; and from each line of form (N3) we form an expression qiSjSkNqm.

Let us write down all expressions so formed from the table for the machine and separate them by semi-colons. In this way we obtain a complete description of the machine. In this description we shall replace qi by the letter ‘‘D’’ followed by the letter ‘‘A’’ repeated i times, and Sj by ‘‘D’’ followed by ‘‘C’’ repeated j times. This new description of the machine may be called the standard description (S.D). It is made up entirely from the letters ‘‘A’’, ‘‘C’’, ‘‘D’’, ‘‘L’’, ‘‘R’’, ‘‘N’’, and from ‘‘;’’.

<!-- page 77 -->
If Wnally we replace ‘‘A’’ by ‘‘1’’, ‘‘C’’ by ‘‘2’’, ‘‘D’’ by ‘‘3’’, ‘‘L’’ by ‘‘4’’, ‘‘R’’ by ‘‘5’’, ‘‘N’’ by ‘‘6’’, and ‘‘;’’ by ‘‘7’’ we shall have a description of the machine in the form of an arabic numeral. The integer represented by this numeral may be called a description number (D.N) of the machine. The D.N determine the S.D and the structure of the machine uniquely. The machine whose D.N is n may be described as M(n).

To each computable sequence there corresponds at least one description number, while to no description number does there correspond more than one computable sequence. The computable sequences and numbers are therefore enumerable.

Let us Wnd a description number for the machine I of § 3. When we rename the m-conWgurations its table becomes:

q1

S0

PS1, R

q2

q2

S0

PS0, R

q3

q3

S0

PS2, R

q4

q4

S0

PS0, R

q1

Other tables could be obtained by adding irrelevant lines such as

q1

S1

PS1, R

q2 Our Wrst standard form would be

q1S0S1Rq2;

q2S0S0Rq3;

q3S0S2Rq4;

q4S0S0Rq1;

The standard description is

DADDCRDAA ;DAADDRDAAA ;DAAADDCCRDAAAA ;DAAAADDRDA ;

A description number is

31332531173113353111731113322531111731111335317 and so is

3133253117311335311173111332253111173111133531731323253117

A number which is a description number of a circle-free machine will be called a satisfactory number. In § 8 it is shown that there can be no general process for determining whether a given number is satisfactory or not.

**6. The universal computing machine**

It is possible to invent a single machine which can be used to compute any computable sequence. If this machine U is supplied with a tape on the beginning of which is written the S.D of some computing machine M, then U will compute the same sequence as M. In this section I explain in outline the behaviour of the machine. The next section is devoted to giving the complete table for U.

<!-- page 78 -->
Let us Wrst suppose that we have a machine M0 which will write down on the F-squares the successive complete conWgurations of M. These might be expressed in the same form as on p. [62], using the second description, (C), with all symbols on one line. Or, better, we could transform this description (as in § 5) by replacing each m-conWguration by ‘‘D’’ followed by ‘‘A’’ repeated the appropriate number of times, and by replacing each symbol by ‘‘D’’ followed by ‘‘C’’ repeated the appropriate number of times. The numbers of letters ‘‘A’’ and ‘‘C’’ are to agree with the numbers chosen in § 5, so that, in particular, ‘‘0’’ is replaced by ‘‘DC’’, ‘‘1’’ by ‘‘DCC’’, and the blanks by ‘‘D’’. These substitutions are to be made after the complete conWgurations have been put together, as in (C). DiYculties arise if we do the substitution Wrst. In each complete conWguration the blanks would all have to be replaced by ‘‘D’’, so that the complete conWguration would not be expressed as a Wnite sequence of symbols.

If in the description of the machine II of § 3 we replace ‘‘o’’ by ‘‘DAA’’, ‘‘@’’ by ‘‘DCCC’’, ‘‘q’’ by ‘‘DAAA’’, then the sequence (C) becomes:

DA : DCCCDCCCDAADCDDC : DCCCDCCCDAAADCDDC : . . .

(C1) (This is the sequence of symbols on F-squares.)

It is not diYcult to see that if M can be constructed, then so can M0. The manner of operation of M0 could be made to depend on having the rules of operation (i.e. the S.D) of M written somewhere within itself (i.e. within M0); each step could be carried out by referring to these rules. We have only to regard the rules as being capable of being taken out and exchanged for others and we have something very akin to the universal machine.

One thing is lacking: at present the machine M0 prints no Wgures. We may correct this by printing between each successive pair of complete conWgurations the Wgures which appear in the new conWguration but not in the old. Then (C1) becomes

DDA : 0 : 0 : DCCCDCCCDAADCDDC : DCCC: . . .

(C2)

It is not altogether obvious that the E-squares leave enough room for the necessary ‘‘rough work’’, but this is, in fact, the case.

The sequences of letters between the colons in expressions such as (C1) may be used as standard descriptions of the complete conWgurations. When the letters are replaced by Wgures, as in § 5, we shall have a numerical description of the complete conWguration, which may be called its description number.

**7. Detailed description of the universal machine**

<!-- page 79 -->
A table is given below of the behaviour of this universal machine. The m-conWgurations of which the machine is capable are all those occurring in the Wrst and last columns of the table, together with all those which occur when we write out the unabbreviated tables of those which appear in the table in the form of m-functions. E.g., e(anf) appears in the table and is an m-function. Its unabbreviated table is (see p. [66]) e(anf) @ R not @ L n e1(anf) e(anf)

e1(anf) Any R, E, R None n e1(anf) anf Consequently e1(anf) is an m-conWguration of U. When U is ready to start work the tape running through it bears on it the symbol @ on an F-square and again @ on the next E-square; after this, on F-squares only, comes the S.D of the machine followed by a double colon ‘‘: :’’ (a single symbol, on an F-square). The S.D consists of a number of instructions, separated by semi-colons. Each instruction consists of Wve consecutive parts

(i) ‘‘D’’ followed by a sequence of letters ‘‘A’’. This describes the relevant m-conWguration. (ii) ‘‘D’’ followed by a sequence of letters ‘‘C’’. This describes the scanned symbol. (iii) ‘‘D’’ followed by another sequence of letters ‘‘C’’. This describes the symbol into which the scanned symbol is to be changed. (iv) ‘‘L’’, ‘‘R’’, or ‘‘N’’, describing whether the machine is to move to left, right, or not at all.

(v) ‘‘D’’ followed by a sequence of letters ‘‘A’’. This describes the Wnal mconWguration. The machine U is to be capable of printing ‘‘A’’, ‘‘C’’, ‘‘D’’, ‘‘0’’, ‘‘1’’, ‘‘u’’, ‘‘v’’, ‘‘w’’, ‘‘x’’, ‘‘y’’, ‘‘z’’. The S.D is formed from ‘‘;’’, ‘‘A’’, ‘‘C’’, ‘‘D’’, ‘‘L’’, ‘‘R’’, ‘‘N’’. Subsidiary skeleton table

con(C, a) Not A R, R A L, Pa, R  con(C, a) con1(C, a)  con1(C, a) con2(C, a) con(C, a).

Starting

from

an F-square, S say, the sequence C of symbols describing a conWguration closest on the right of S is marked out with letters a: ! C. con1(C, a) A R, Pa, R D R, Pa, R  con2(C, a) C con2(C, a) C R, Pa, R Not C R, R con(C, ). In the Wnal conWguration the machine is scanning the square which is four squares to the right of the last square of C. C is left unmarked. The table for U b f(b1, b1, : : ) b.

The machine prints : DA on the F-squares after : : ! anf. b1 R, R, P :, R, R, PD, R, R, PA anf

anf g(anf1, :) anf.

<!-- page 80 -->
The machine marks the conWguration in the last complete conWguration with y. ! kom. anf1 con(kom, y) 8 < kom : ; R, Pz, L z L, L not z nor ; L con(kmp, x) kom kom kom.

The machine Wnds the last

semi-colon

not

marked with z. It marks this semi-colon with z and the conWguration following it with x.

kmp cpe(e(kom, x, y), sim, x, y) kmp.

The machine compares the sequences marked x and y. It erases all letters x and y. ! sim if they are alike. Otherwise ! kom.

anf. Taking the long view, the last instruction relevant to the last conWguration is found. It can be recognised afterwards as the instruction following the last semi-colon marked z. ! sim.

sim1 con(sim2, )

sim2 A not A R, Pu, R, R, R  sim3 sim2

sim3 not A L, Py A L, Py, R, R, R  e(mk, z) sim3 sim f0(sim1, sim1, z) sim.

The machine marks out the instructions. That part of the instructions which refers to operations to be carried out is marked with u, and the Wnal m-conWguration with y. The letters z are erased.

mk1 not A R, R A L, L, L, L  mk1 mk2 8 < mk2 : C R, Px, L, L, L : D R, Px, L, L, L mk2 mk4 mk3 not : R, Pv, L, L, L mk3 :  mk3 mk4 mk4 con l l(mk5) ð Þ, ð Þ mk g(mk, :) mk.

The

last

complete conWguration is marked out into

four

```prolog
sections.
         The
```

conWguration is left unmarked. The symbol directly preceding it

is

marked

with

```prolog
x.
   The
```

remainder

of

the

complete conWguration is divided into two parts, of which the Wrst is marked with v and the last with w. A colon is printed after the whole. ! sh. Any R, Pw, R mk5  mk5 sh None P:

sh1 L, L, L sh2 D R, R, R, R sh2  sh2 inst not D sh f(sh1, inst, u) sh. The instructions (marked

<!-- page 81 -->
u) are examined. If it is found that they involve ‘‘Print 0’’ or ‘‘Print 1’’, then 0 : or 1 : is printed at the end. sh3  sh4 inst C R, R not C

C

R, R sh4



sh5

```prolog
                  pe2(inst, 0, : )
not C
```

sh5

C

not C

n

inst

```prolog
pe2(inst, 1, : )
```

inst

g l(inst1), u

ð

Þ

```prolog
inst.
      The
           next
                complete
```

conWguration is written down,

carrying

out

the

marked

instructions. The letters u, v, w,

x,

y

are

```prolog
erased.
       !anf.
```

inst1

a

R, E

```prolog
inst1(a)
```

inst1(L)

```prolog
ce5(ov, v, y, x, u, w)
```

inst1(R)

```prolog
ce5(ov, v, x, u, y, w)
```

inst1(N)

```prolog
ec5(ov, v, x, y, u, w)
```

ov

```prolog
e(anf)
```

**8. Application of the diagonal process**

It may be thought that arguments which prove that the real numbers are not enumerable would also prove that the computable numbers and sequences cannot be enumerable.4 It might, for instance, be thought that the limit of a sequence of computable numbers must be computable. This is clearly only true if the sequence of computable numbers is deWned by some rule.

Or we might apply the diagonal process. ‘‘If the computable sequences are enumerable, let an be the n-th computable sequence, and let fn(m) be the m-th Wgure in an. Let b be the sequence with 1  fn(n) as its n-th Wgure. Since b is computable, there exists a number K such that 1  fn(n) ¼ fK(n) all n. Putting n ¼ K, we have 1 ¼ 2fK(K), i.e. 1 is even. This is impossible. The computable sequences are therefore not enumerable.’’

The fallacy in this argument lies in the assumption that b is computable. It would be true if we could enumerate the computable sequences by Wnite means, but the problem of enumerating computable sequences is equivalent to the problem of Wnding out whether a given number is the D.N of a circle-free machine, and we have no general process for doing this in a Wnite number of steps. In fact, by applying the diagonal process argument correctly, we can show that there cannot be any such general process.

The simplest and most direct proof of this is by showing that, if this general process exists, then there is a machine which computes b. This proof, although perfectly sound, has the disadvantage that it may leave the reader with a feeling that ‘‘there must be something wrong’’. The proof which I shall give has not this disadvantage, and gives a certain insight into the signiWcance of the idea ‘‘circlefree’’. It depends not on constructing b, but on constructing b0, whose n-th Wgure is fn(n).

Let us suppose that there is such a process; that is to say, that we can invent a machine D which, when supplied with the S.D of any computing machine M

<!-- page 82 -->
4 Cf. Hobson, Theory of functions of a real variable (2nd ed., 1921), 87, 88. will test this S.D and if M is circular will mark the S.D with the symbol ‘‘u’’ and if it is circle-free will mark it with ‘‘s’’. By combining the machines D and U we could construct a machine H to compute the sequence b0. The machine D may require a tape. We may suppose that it uses the E-squares beyond all symbols on F-squares, and that when it has reached its verdict all the rough work done by D is erased.

The machine H has its motion divided into sections. In the Wrst N  1 sections, among other things, the integers 1, 2, . . . , N  1 have been written down and tested by the machine D. A certain number, say R(N  1), of them have been found to be the D.N’s of circle-free machines. In the N-th section the machine D tests the number N. If N is satisfactory, i.e., if it is the D.N of a circlefree machine, then R(N) ¼ 1 þ R(N  1) and the Wrst R(N) Wgures of the sequence of which a D.N is N are calculated. The R(N)-th Wgure of this sequence is written down as one of the Wgures of the sequence b0 computed by H. If N is not satisfactory, then R(N) ¼ R(N  1) and the machine goes on to the (N þ 1)-th section of its motion.

From the construction of H we can see that H is circle-free. Each section of the motion of H comes to an end after a Wnite number of steps. For, by our assumption about D, the decision as to whether N is satisfactory is reached in a Wnite number of steps. If N is not satisfactory, then the N-th section is Wnished. If N is satisfactory, this means that the machine M(N) whose D.N is N is circlefree, and therefore its R(N)-th Wgure can be calculated in a Wnite number of steps. When this Wgure has been calculated and written down as the R(N)-th Wgure of b0, the N-th section is Wnished. Hence H is circle-free.

Now let K be the D.N of H. What does H do in the K-th section of its motion? It must test whether K is satisfactory, giving a verdict ‘‘s’’ or ‘‘u’’. Since K is the D.N of H and since H is circle-free, the verdict cannot be ‘‘u’’. On the other hand the verdict cannot be ‘‘s’’. For if it were, then in the K-th section of its motion H would be bound to compute the Wrst R(K  1) þ 1 ¼ R(K) Wgures of the sequence computed by the machine with K as its D.N and to write down the R(K)-th as a Wgure of the sequence computed by H. The computation of the Wrst R(K)  1 Wgures would be carried out all right, but the instructions for calculating the R(K)-th would amount to ‘‘calculate the Wrst R(K) Wgures computed by H and write down the R(K)-th’’. This R(K)-th Wgure would never be found. I.e., H is circular, contrary both to what we have found in the last paragraph and to the verdict ‘‘s’’. Thus both verdicts are impossible and we conclude that there can be no machine D.

We can show further that there can be no machine E which, when supplied with the S.D of an arbitrary machine M, will determine whether M ever prints a given symbol (0 say).

<!-- page 83 -->
We will Wrst show that, if there is a machine E, then there is a general process for determining whether a given machine M prints 0 inWnitely often. Let M1 be a machine which prints the same sequence as M, except that in the position where the Wrst 0 printed by M stands, M1 prints 0. M2 is to have the Wrst two symbols 0 replaced by 0, and so on. Thus, if M were to print

A B A 0 1 A A B 0 0 1 0 A B . . . , then M1 would print

A B A 0 1 A A B 0 0 1 0 A B . . . and M2 would print

A B A 0 1 A A B 0 0 1 0 A B . . . :

Now let F be a machine which, when supplied with the S.D of M, will write down successively the S.D of M, of M1, of M2, . . . (there is such a machine). We combine F with E and obtain a new machine, G. In the motion of G Wrst F is used to write down the S.D of M, and then E tests it, : 0 : is written if it is found that M never prints 0; then F writes the S.D of M1, and this is tested, : 0 : being printed if and only if M1 never prints 0, and so on. Now let us test G with E. If it is found that G never prints 0, then M prints 0 inWnitely often; if G prints 0 sometimes, then M does not print 0 inWnitely often.

Similarly there is a general process for determining whether M prints 1 inWnitely often. By a combination of these processes we have a process for determining whether M prints an inWnity of Wgures, i.e. we have a process for determining whether M is circle-free. There can therefore be no machine E.

The expression ‘‘there is a general process for determining . . .’’ has been used throughout this section as equivalent to ‘‘there is a machine which will determine . . .’’. This usage can be justiWed if and only if we can justify our deWnition of ‘‘computable’’. For each of these ‘‘general process’’ problems can be expressed as a problem concerning a general process for determining whether a given integer n has a property G(n) [e.g. G(n) might mean ‘‘n is satisfactory’’ or ‘‘n is the Go¨del representation of a provable formula’’], and this is equivalent to computing a number whose n-th Wgure is 1 if G(n) is true and 0 if it is false.

**9. The extent of the computable numbers**

No attempt has yet been made to show that the ‘‘computable’’ numbers include all numbers which would naturally be regarded as computable. All arguments which can be given are bound to be, fundamentally, appeals to intuition, and for this reason rather unsatisfactory mathematically. The real question at issue is ‘‘What are the possible processes which can be carried out in computing a number?’’

<!-- page 84 -->
The arguments which I shall use are of three kinds.

(a) A direct appeal to intuition.

(b) A proof of the equivalence of two deWnitions (in case the new deWnition

has a greater intuitive appeal).

(c) Giving examples of large classes of numbers which are computable.

Once it is granted that computable numbers are all ‘‘computable’’, several other propositions of the same character follow. In particular, it follows that, if there is a general process for determining whether a formula of the Hilbert function calculus is provable, then the determination can be carried out by a machine.

I. [Type (a)].

This argument is only an elaboration of the ideas of § 1. Computing is normally done by writing certain symbols on paper. We may suppose this paper is divided into squares like a child’s arithmetic book. In elementary arithmetic the two-dimensional character of the paper is sometimes used. But such a use is always avoidable, and I think that it will be agreed that the two-dimensional character of paper is no essential of computation. I assume then that the computation is carried out on one-dimensional paper, i.e. on a tape divided into squares. I shall also suppose that the number of symbols which may be printed is Wnite. If we were to allow an inWnity of symbols, then there would be symbols diVering to an arbitrarily small extent.5 The eVect of this restriction of the number of symbols is not very serious. It is always possible to use sequences of symbols in the place of single symbols. Thus an Arabic numeral such as 17 or 999999999999999 is normally treated as a single symbol. Similarly in any European language words are treated as single symbols (Chinese, however, attempts to have an enumerable inWnity of symbols). The diVerences from our point of view between the single and compound symbols is that the compound symbols, if they are too lengthy, cannot be observed at one glance. This is in accordance with experience. We cannot tell at a glance whether 9999999999999999 and 999999999999999 are the same.

The behaviour of the computer at any moment is determined by the symbols which he is observing, and his ‘‘state of mind’’ at that moment. We may suppose that there is a bound B to the number of symbols or squares which the computer can observe at one moment. If he wishes to observe more, he must use successive observations. We will also suppose that the number of states of mind which need be taken into account is Wnite. The reasons for this are of the same character as

<!-- page 85 -->
5 If we regard a symbol as literally printed on a square we may suppose that the square is 0<x<1, 0<y<1. The symbol is deWned as a set of points in this square, viz. the set occupied by printer’s ink. If these sets are restricted to be measurable, we can deWne the ‘‘distance’’ between two symbols as the cost of transforming one symbol into the other if the cost of moving unit area of printer’s ink unit distance is unity, and there is an inWnite supply of ink at x ¼ 2, y ¼ 0. With this topology the symbols form a conditionally compact space. those which restrict the number of symbols. If we admitted an inWnity of states of mind, some of them will be ‘‘arbitrarily close’’ and will be confused. Again, the restriction is not one which seriously aVects computation, since the use of more complicated states of mind can be avoided by writing more symbols on the tape.

Let us imagine the operations performed by the computer to be split up into ‘‘simple operations’’ which are so elementary that it is not easy to imagine them further divided. Every such operation consists of some change of the physical system consisting of the computer and his tape. We know the state of the system if we know the sequence of symbols on the tape, which of these are observed by the computer (possibly with a special order), and the state of mind of the computer. We may suppose that in a simple operation not more than one symbol is altered. Any other changes can be split up into simple changes of this kind. The situation in regard to the squares whose symbols may be altered in this way is the same as in regard to the observed squares. We may, therefore, without loss of generality, assume that the squares whose symbols are changed are always ‘‘observed’’ squares.

Besides these changes of symbols, the simple operations must include changes of distribution of observed squares. The new observed squares must be immediately recognisable by the computer. I think it is reasonable to suppose that they can only be squares whose distance from the closest of the immediately previously observed squares does not exceed a certain Wxed amount. Let us say that each of the new observed squares is within L squares of an immediately previously observed square.

<!-- page 86 -->
In connection with ‘‘immediate recognisability’’, it may be thought that there are other kinds of square which are immediately recognisable. In particular, squares marked by special symbols might be taken as immediately recognisable. Now if these squares are marked only by single symbols there can be only a Wnite number of them, and we should not upset our theory by adjoining these marked squares to the observed squares. If, on the other hand, they are marked by a sequence of symbols, we cannot regard the process of recognition as a simple process. This is a fundamental point and should be illustrated. In most mathematical papers the equations and theorems are numbered. Normally the numbers do not go beyond (say) 1000. It is, therefore, possible to recognise a theorem at a glance by its number. But if the paper was very long, we might reach Theorem 157767733443477; then, further on in the paper, we might Wnd ‘‘. . . hence (applying Theorem 157767733443477) we have . . .’’. In order to make sure which was the relevant theorem we should have to compare the two numbers Wgure by Wgure, possibly ticking the Wgures oV in pencil to make sure of their not being counted twice. If in spite of this it is still thought that there are other ‘‘immediately recognisable’’ squares, it does not upset my contention so long as these squares can be found by some process of which my type of machine is capable. This idea is developed in III below.

The simple operations must therefore include:

(a) Changes of the symbol on one of the observed squares.

(b) Changes of one of the squares observed to another square within L squares

of one of the previously observed squares.

It may be that some of these changes necessarily involve a change of state of mind. The most general single operation must therefore be taken to be one of the following:

(A) A possible change (a) of symbol together with a possible change of state

of mind.

(B) A possible change (b) of observed squares, together with a possible change

of state of mind.

The operation actually performed is determined, as has been suggested on p. [75], by the state of mind of the computer and the observed symbols. In particular, they determine the state of mind of the computer after the operation is carried out.

We may now construct a machine to do the work of this computer. To each state of mind of the computer corresponds an ‘‘m-conWguration’’ of the machine. The machine scans B squares corresponding to the B squares observed by the computer. In any move the machine can change a symbol on a scanned square or can change any one of the scanned squares to another square distant not more than L squares from one of the other scanned squares. The move which is done, and the succeeding conWguration, are determined by the scanned symbol and the m-conWguration. The machines just described do not diVer very essentially from computing machines as deWned in § 2, and corresponding to any machine of this type a computing machine can be constructed to compute the same sequence, that is to say the sequence computed by the computer.

II. [Type (b)]. If the notation of the Hilbert functional calculus6 is modiWed so as to be systematic, and so as to involve only a Wnite number of symbols, it becomes possible to construct an automatic7 machine K, which will Wnd all the provable formulae of the calculus.8

6 The expression ‘‘the functional calculus’’ is used throughout to mean the restricted Hilbert functional calculus.

7 It is most natural to construct Wrst a choice machine (§2) to do this. But it is then easy to construct the required automatic machine. We can suppose that the choices are always choices between two possibilities 0 and 1. Each proof will then be determined by a sequence of choices i1, i2, . . . , in (i1 ¼ 0 or 1, i2 ¼ 0 or 1, . . . , in ¼ 0 or 1), and hence the number 2n þ i12n1 þ i22n2 þ . . . þ in completely determines the proof. The automatic machine carries out successively proof 1, proof 2, proof 3, . . . .

<!-- page 87 -->
8 The author has found a description of such a machine.

Now let a be a sequence, and let us denote by Ga(x) the proposition ‘‘The x-th Wgure of a is 1’’, so that Ga(x) means ‘‘The x-th Wgure of a is 0’’.9 Suppose further that we can Wnd a set of properties which deWne the sequence a and which can be expressed in terms of Ga(x) and of the propositional functions N(x) meaning ‘‘x is a non-negative integer’’ and F(x, y) meaning ‘‘y ¼ x þ 1’’. When we join all these formulae together conjunctively, we shall have a formula, A say, which deWnes a. The terms of A must include the necessary parts of the Peano axioms, viz.,

(9u)N(u) & (x) N(x) ! (9y)F(x, y)

ð

Þ & F(x, y) ! N(y)

ð

Þ,

which we will abbreviate to P.

When we say ‘‘A deWnes a’’, we mean that A is not a provable formula, and also that, for each n, one of the following formulae (An) or (Bn) is provable.10

,

(An)

A & F(n) ! Ga u(n)









A & F(n) ! Ga(u(n))

,

(Bn), where F(n) stands for F(u, u0) & F(u0, u00) & . . . F(u(n1), u(n)).

I say that a is then a computable sequence: a machine Ka to compute a can be obtained by a fairly simple modiWcation of K.

We divide the motion of Ka into sections. The n-th section is devoted to Wnding the n-th Wgure of a. After the (n  1)-th section is Wnished a double colon : : is printed after all the symbols, and the succeeding work is done wholly on the squares to the right of this double colon. The Wrst step is to write the letter ‘‘A’’ followed by the formula (An) and then ‘‘B’’ followed by (Bn). The machine Ka then starts to do the work of K, but whenever a provable formula is found, this formula is compared with (An) and with (Bn). If it is the same formula as (An), then the Wgure ‘‘1’’ is printed, and the n-th section is Wnished. If it is (Bn), then ‘‘0’’ is printed and the section is Wnished. If it is diVerent from both, then the work of K is continued from the point at which it had been abandoned. Sooner or later one of the formulae (An) or (Bn) is reached; this follows from our hypotheses about a and A, and the known nature of K. Hence the n-th section will eventually be Wnished. Ka is circle-free; a is computable.

It can also be shown that the numbers a deWnable in this way by the use of axioms include all the computable numbers. This is done by describing computing machines in terms of the function calculus.

It must be remembered that we have attached rather a special meaning to the phrase ‘‘A deWnes a’’. The computable numbers do not include all (in the ordinary sense) deWnable numbers. Let d be a sequence whose n-th Wgure is

9 The negation sign is written before an expression and not over it.

<!-- page 88 -->
10 A sequence of r primes is denoted by (r). 1 or 0 according as n is or is not satisfactory. It is an immediate consequence of the theorem of § 8 that d is not computable. It is (so far as we know at present) possible that any assigned number of Wgures of d can be calculated, but not by a uniform process. When suYciently many Wgures of d have been calculated, an essentially new method is necessary in order to obtain more Wgures.

III. This may be regarded as a modiWcation of I or as a corollary of II. We suppose, as in I, that the computation is carried out on a tape; but we avoid introducing the ‘‘state of mind’’ by considering a more physical and deWnite counterpart of it. It is always possible for the computer to break oV from his work, to go away and forget all about it, and later to come back and go on with it. If he does this he must leave a note of instructions (written in some standard form) explaining how the work is to be continued. This note is the counterpart of the ‘‘state of mind’’. We will suppose that the computer works in such a desultory manner that he never does more than one step at a sitting. The note of instructions must enable him to carry out one step and write the next note. Thus the state of progress of the computation at any stage is completely determined by the note of instructions and the symbols on the tape. That is, the state of the system may be described by a single expression (sequence of symbols), consisting of the symbols on the tape followed by D (which we suppose not to appear elsewhere) and then by the note of instructions. This expression may be called the ‘‘state formula’’. We know that the state formula at any given stage is determined by the state formula before the last step was made, and we assume that the relation of these two formulae is expressible in the functional calculus. In other words, we assume that there is an axiom A which expresses the rules governing the behaviour of the computer, in terms of the relation of the state formula at any stage to the state formula at the preceding stage. If this is so, we can construct a machine to write down the successive state formulae, and hence to compute the required number.

**10. Examples of large classes of numbers which**

**are computable**

It will be useful to begin with deWnitions of a computable function of an integral variable and of a computable variable, etc. There are many equivalent ways of deWning a computable function of an integral variable. The simplest is, possibly, as follows. If g is a computable sequence in which 0 appears inWnitely11 often, and n is an integer, then let us deWne x(g, n) to be the number of Wgures

<!-- page 89 -->
11 If M computes g, then the problem whether M prints 0 inWnitely often is of the same character as the problem whether M is circle-free. 1 between the n-th and the (n þ 1)-th Wgure 0 in g. Then f(n) is computable if, for all n and some g, f(n) ¼ x(g, n). An equivalent deWnition is this. Let H(x, y) mean f(x) ¼ y. Then, if we can Wnd a contradiction-free axiom Af, such that Af ! P, and if for each integer n there exists an integer N, such that

,

Af & F(N) ! H u(n), u(f(n) )





and such that, if m 6¼ f(n), then, for some N0,

,

Af & F(N0) ! H(u(n), u(m)





then f may be said to be a computable function.

We cannot deWne general computable functions of a real variable, since there is no general method of describing a real number, but we can deWne a computable function of a computable variable. If n is satisfactory, let gn be the number computed by M(n), and let

,

an ¼ tan p gn  1

2









unless gn ¼ 0 or gn ¼ 1, in either of which cases an ¼ 0. Then, as n runs through the satisfactory numbers, an runs through the computable numbers.12 Now let f(n) be a computable function which can be shown to be such that for any satisfactory argument its value is satisfactory.13 Then the function f, deWned by f an ð

Þ ¼ af(n), is a computable function and all computable functions of a computable variable are expressible in this form.

Similar deWnitions may be given of computable functions of several variables, computable-valued functions of an integral variable, etc.

I shall enunciate a number of theorems about computability, but I shall prove only (ii) and a theorem similar to (iii).

(i) A computable function of a computable function of an integral or

computable variable is computable.

(ii) Any function of an integral variable deWned recursively in terms of

computable functions is computable. I.e. if f(m, n) is computable, and

r is some integer, then Z(n) is computable, where

Z(0) ¼ r,

Z(n) ¼ f(n, Z(n  1)):

(iii) If f(m, n) is a computable function of two integral variables, then f(n, n)

is a computable function of n.

12 A function an may be deWned in many other ways so as to run through the computable numbers.

<!-- page 90 -->
13 Although it is not possible to Wnd a general process for determining whether a given number is satisfactory, it is often possible to show that certain classes of numbers are satisfactory.

(iv) If f(n) is a computable function whose value is always 0 or 1, then the

sequence whose n-th Wgure is f(n) is computable.

Dedekind’s theorem does not hold in the ordinary form if we replace ‘‘real’’ throughout by ‘‘computable’’. But it holds in the following form:

(v) If G(a) is a propositional function of the computable numbers and

(a) (9 a)(9b){G(a) & G(b)

ð

Þ},

(b) G(a) & G(b)

ð

Þ ! (a < b),

and there is a general process for determining the truth value of G(a), then there is a computable number x such that

G(a) ! a < x,

G(a) ! a > x:

In other words, the theorem holds for any section of the computables such that there is a general process for determining to which class a given number belongs.

Owing to this restriction of Dedekind’s theorem, we cannot say that a computable bounded increasing sequence of computable numbers has a computable limit. This may possibly be understood by considering a sequence such as

1,  1

2 ,  1

4 ,  1

8 ,  1

16 , 1

2 , . . . :

On the other hand, (v) enables us to prove

(vi) If a and b are computable and a < b and f(a) < 0 < f(b), where

f(a) is a computable increasing continuous function, then there is a

unique computable number g, satisfying a < g < b and f(g) ¼ 0.

Computable convergence We shall say that a sequence bn of computable numbers converges computably if there is a computable integral valued function N(") of the computable variable ", such that we can show that, if " > 0 and n > N(") and m > N("), then jbn  bmj < ".

We can then show that

(vii) A power series whose coeYcients form a computable sequence of comp-

utable numbers is computably convergent at all computable points in

the interior of its interval of convergence.

(viii) The limit of a computably convergent sequence is computable.

And with the obvious deWnition of ‘‘uniformly computably convergent’’:

(ix) The limit of a uniformly computably convergent computable sequence

<!-- page 91 -->
of computable functions is a computable function. Hence

(x) The sum of a power series whose coeYcients form a computable sequence

is a computable function in the interior of its interval of convergence.

From (viii) and p ¼ 4 1 1

3 þ 1

5  . . .





we deduce that p is computable.

From e ¼ 1þ1þ 1

2! þ 1

3! þ . . . we deduce that e is computable.

From (vi) we deduce that all real algebraic numbers are computable.

From (vi) and (x) we deduce that the real zeros of the Bessel functions are computable.

Proof of (ii) Let H(x, y) mean ‘‘Z(x) ¼ y’’, and let K(x, y, z) mean ‘‘f(x, y) ¼ z’’. Af is the axiom for f(x, y). We take AZ to be









F(x, y) ! G(x, y)

&

G(x, y) & G(y, z) ! G(x, z) Af & P &









&

F(v, w) & H(v, x) & K(w, x, z) ! H(w, z)

& F(r) !H(u, u(r))









:

& H(w, z) & G(z, t) v G(t, z) !

H(w, t)

I shall not give the proof of consistency of AZ. Such a proof may be constructed by the methods used in Hilbert and Bernays, Grundlagen der Mathematik (Berlin, 1934), p. 209 et seq. The consistency is also clear from the meaning.

Suppose that, for some n, N, we have shown

,

AZ & F(N) ! H u(n1), u(Z(n1) )





then, for some M,

,

Af & F(M) ! K u(n), u(Z(n1) ), u(Z(n) )





& H u(n1), u(Z(n1) )





AZ & F(M) ! F u(n1), u(n)





,

& K u(n), u(Z(n1) ), u(Z(n) )





and

& H u(n1), u(Z(n1) )







AZ & F(M) ! F u(n1), u(n)





:

& K u(n), u(Z(n1) ), u(Z(n) )





! H u(n), u(Z(n) )





: Hence

AZ & F(M) ! H u(n), u(Z(n) )





: Also

AZ & F(r) ! H u, u(Z(0) )





Hence for each n some formula of the form

AZ & F(M) ! H u(n), u(Z(n) )





is provable. Also, if M0 > M and M0 > m and m 6¼ Z(u), then

v G u(m), u(Z(n) )





AZ & F(M0) ! G uZ( (n) ), u(m)





<!-- page 92 -->
and

G u(m), u(Z(n))







v



AZ & F(M0) !

G u(Z(n) ), u(m)





:

& H u(n), u(Z(n) )





! H u(n), u(m)









: Hence

AZ & F(M0) ! H u(n), u(m)









The conditions of our second deWnition of a computable function are therefore satisWed. Consequently Z is a computable function.

Proof of a modified form of (iii) Suppose that we are given a machine N, which, starting with a tape bearing on it @ @ followed by a sequence of any number of letters ‘‘F’’ on F-squares and in the m-conWguration b, will compute a sequence gn depending on the number n of letters ‘‘F’’. If fn(m) is the m-th Wgure of gn, then the sequence b whose n-th Wgure is fn(n) is computable.

We suppose that the table for N has been written out in such a way that in each line only one operation appears in the operations column. We also suppose that X, Q, 0, and 1 do not occur in the table, and we replace @ throughout by Q, 0 by 0, and 1 by 1. Further substitutions are then made. Any line of form

A

a

P0

B

we replace by

A

a

P0

```prolog
re(B, u, h, k)
```

and any line of the form

A

a

P1

B by

A

a

P1

```prolog
re(B, v, h, k)
```

and we add to the table the following lines:

u

pe u1, 0

ð

Þ

u1

R, Pk, R, PQ, R, PQ

u2

u2

re u3, u3, k, h

ð

Þ

u3

pe u2, F

ð

Þ

and similar lines with v for u and 1 for 0 together with the following line

c

R, PX, R, Ph

b:

<!-- page 93 -->
We then have the table for the machine N0 which computes b. The initial m-conWguration is c, and the initial scanned symbol is the second @.

**11. Application to the Entscheidungsproblem**

The results of § 8 have some important applications. In particular, they can be used to show that the Hilbert Entscheidungsproblem can have no solution. For the present I shall conWne myself to proving this particular theorem. For the formulation of this problem I must refer the reader to Hilbert and Ackermann’s Grundzu¨ge der Theoretischen Logik (Berlin, 1931), chapter 3.

I propose, therefore, to show that there can be no general process for determining whether a given formula A of the functional calculus K is provable, i.e. that there can be no machine which, supplied with any one A of these formulae, will eventually say whether A is provable.

It should perhaps be remarked that what I shall prove is quite diVerent from the well-known results of Go¨del.14 Go¨del has shown that (in the formalism of Principia Mathematica) there are propositions A such that neither A nor A is provable. As a consequence of this, it is shown that no proof of consistency of Principia Mathematica (or of K) can be given within that formalism. On the other hand, I shall show that there is no general method which tells whether a given formula A is provable in K, or, what comes to the same, whether the system consisting of K with A adjoined as an extra axiom is consistent.

If the negation of what Go¨del has shown had been proved, i.e. if, for each A, either A or A is provable, then we should have an immediate solution of the Entscheidungsproblem. For we can invent a machine K which will prove consecutively all provable formulae. Sooner or later K will reach either A or A. If it reaches A, then we know that A is provable. If it reaches A, then, since K is consistent (Hilbert and Ackermann, p. 65), we know that A is not provable.

Owing to the absence of integers in K the proofs appear somewhat lengthy. The underlying ideas are quite straightforward.

Corresponding to each computing machine M we construct a formula Un (M) and we show that, if there is a general method for determining whether Un (M) is provable, then there is a general method for determining whether M ever prints 0.

The interpretations of the propositional functions involved are as follows:

RSl(x, y) is to be interpreted as ‘‘in the complete conWguration x (of M ) the symbol on the square y is S’’.

I(x, y) is to be interpreted as ‘‘in the complete conWguration x the square y is scanned’’.

<!-- page 94 -->
14 Loc. cit.

Kqm(x) is to be interpreted as ‘‘in the complete conWguration x the m-con- Wguration is qm.

F(x, y) is to be interpreted as ‘‘y is the immediate successor of x’’.

Inst {qiSjSkLql} is to be an abbreviation for

(x, y, x0, y0)

RSj(x, y) & I(x, y) & Kqi(x) & F(x, x0) & F(y0, y)









! I(x0, y0) & RSk(x0, y) & Kql(x0)









:

& (z) F(y0, z) v RSj(x, z) ! RSk(x0, z)

Inst {qiSjSkRql} and Inst {qiSjSkNql}

are to be abbreviations for other similarly constructed expressions.

Let us put the description of M into the Wrst standard form of § 6. This description consists of a number of expressions such as ‘‘qiSjSkLql’’ (or with R or N substituted for L). Let us form all the corresponding expressions such as Inst {qiSjSkLql} and take their logical sum. This we call Des (M).

The formula Un (M) is to be

(9u) N(u) & (x) N(x) ! (9x0)F(x, x0)

ð

½

Þ

& (y, z) F(y, z) ! N(y) & N(z)

ð

Þ

& (y)RS0(u, y) & I(u, u) & Kq1(u) & Des (M)

! (9s)(9t)[N(s) & N(t) & RS1(s, t)]: [N(u) & . . . & Des (M)] may be abbreviated to A(M).

When we substitute the meanings suggested on [pp. 84–85] we Wnd that Un (M) has the interpretation ‘‘in some complete conWguration of M, S1 (i.e.

0) appears on the tape’’. Corresponding to this I prove that

(a) If S1 appears on the tape in some complete conWguration of M, then

Un (M) is provable.

(b) If Un (M) is provable, then S1 appears on the tape in some complete

conWguration of M.

When this has been done, the remainder of the theorem is trivial.

Lemma 1. If S1appears on the tape in some complete conWguration of M, then Un (M) is provable.

<!-- page 95 -->
We have to show how to prove Un (M). Let us suppose that in the n-th complete conWguration the sequence of symbols on the tape is Sr(n, 0), Sr(n, 1), . . . , Sr(n, n), followed by nothing but blanks, and that the scanned symbol is the i(n)-th, and that the m-conWguration is qk(n). Then we may form the proposition

RSr(n; 0)(u(n), u) & RSr(n; 1)(u(n), u0) & . . . & RSr(n; n)(u(n), u(n))

& I(u(n), u(i(n) )) & Kqk(n)(u(n))

& (y)F (y, u0) v F(u, y)

ð

v F(u0, y) v . . . v F(u(n1), y) v RS0(u(n), y)Þ, which we may abbreviate to CCn.

As before, F(u, u0) & F(u0, u00) & . . . & F(u(r1), u(r)) is abbreviated to F(r).

I shall show that all formulae of the form A(M) & F(n) ! CCn (abbreviated to CFn) are provable. The meaning of CFn is ‘‘The n-th complete conWguration of M

is so and so’’, where ‘‘so and so’’ stands for the actual n-th complete conWguration of M. That CFn should be provable is therefore to be expected.

CF0 is certainly provable, for in the complete conWguration the symbols are all blanks, the m-conWguration is q1, and the scanned square is u, i.e. CC0 is

(y)RS0(u, y) & I(u, u) & Kq1(u): A(M) ! CC0 is then trivial.

We next show that CFn ! CFnþ1 is provable for each n. There are three cases to consider, according as in the move from the n-th to the (n þ 1)-th conWguration the machine moves to left or to right or remains stationary. We suppose that the Wrst case applies, i.e. the machine moves to the left. A similar argument applies

in

the

other

```prolog
cases.
       If
          r n, i(n)
           ð
                 Þ ¼ a, r n þ 1, i(n þ 1)
                        ð
                                     Þ ¼ c,
```

k i(n) ð

Þ ¼ b, and k i(n þ 1)

ð

Þ ¼ d, then Des (M) must include Inst {qaSbSdLqc} as one of its terms, i.e.

Des (M) ! Inst {qaSbSdLqc}:

Hence

A(M) & F(nþ1) ! Inst {qaSbSdLqc} & F(nþ1):

But

Inst {qaSbSdLqc} & F(nþ1) ! (CCn ! CCnþ1) is provable, and so therefore is

A(M) & F(nþ1) ! (CCn ! CCnþ1) and





,

A(M) & F(n) ! CCn





! A(M) & F(nþ1) ! CCnþ1

i:e:

CFn ! CFnþ1:

<!-- page 96 -->
CFn isprovableforeach n.NowitistheassumptionofthislemmathatS1 appears somewhere,in some completeconWguration, in thesequenceofsymbolsprinted by M; that is, for some integers N, K, CCN has RS1(u(N), u(K)) as one of its terms, and therefore CCN ! RS1(u(N), u(K)) is provable. We have then

CCN ! RS1(u(N), u(K)) and

A(M) & F(N) ! CCN:

We also have

,

(9u)A(M) ! (9u)(9u0) . . . (9u(N 0)) A(M) & F(N)





where N0 ¼ max (N, K): And so

(9u)A(M) ! (9u)(9u0) . . . (9u(N 0))RS1(u(N), u(K)),

(9u)A(M) ! (9u(N))(9u(K))RS1(u(N), u(K)),

(9u)A(M) ! (9s)(9t)RS1(s, t), i.e. Un (M) is provable.

This completes the proof of Lemma 1.

Lemma 2. If Un (M) is provable, then S1 appears on the tape in some complete conWguration of M.

If we substitute any propositional functions for function variables in a provable formula, we obtain a true proposition. In particular, if we substitute the meanings tabulated on pp. [84–85] in Un (M), we obtain a true proposition with the meaning ‘‘S1 appears somewhere on the tape in some complete con- Wguration of M ’’.

We are now in a position to show that the Entscheidungsproblem cannot be solved. Let us suppose the contrary. Then there is a general (mechanical) process for determining whether Un (M) is provable. By Lemmas 1 and 2, this implies that there is a process for determining whether M ever prints 0, and this is impossible, by § 8. Hence the Entscheidungsproblem cannot be solved.

In view of the large number of particular cases of solutions of the Entscheidungsproblem for formulae with restricted systems of quantors, it is interesting to express Un (M) in a form in which all quantors are at the beginning. Un (M) is, in fact, expressible in the form

(u)(9x)(w)(9u1) . . . (9un)B,

<!-- page 97 -->
(I) where B contains no quantors, and n ¼ 6. By unimportant modiWcations we can obtain a formula, with all essential properties of Un (M), which is of form (I) with n ¼ 5.

Added 28 August, 1936.15

**Appendix**

**Computability and effective calculability**

The theorem that all eVectively calculable (l-deWnable) sequences are computable and its converse are proved below in outline. It is assumed that the terms ‘‘well-formed formula’’ (W.F.F.) and ‘‘conversion’’ as used by Church and Kleene are understood. In the second of these proofs the existence of several formulae is assumed without proof; these formulae may be constructed straightforwardly with the help of, e.g., the results of Kleene in ‘‘A theory of positive integers in formal logic’’, American Journal of Math, 57 (1935), 153–173, 219–244.

The W.F.F. representing an integer n will be denoted by Nn. We shall say that a sequence g whose n-th Wgure is fg(n) is l-deWnable or eVectively calculable if 1 þ fg(u) is a l-deWnable function of n, i.e. if there is a W.F.F. Mg such that, for all integers n,

Mg





Nn

ð

Þ conv Nfg(n)þ1,

i.e.

Mg





Nn

ð

Þ is convertible into lxy : x(x(y)) or into lxy : x(y) according as the n-th Wgure of l is 1 or 0.

To show that every l-deWnable sequence g is computable, we have to show how to construct a machine to compute g. For use with machines it is convenient to make a trivial modiWcation in the calculus of conversion. This alteration consists in using x, x0, x00, . . . as variables instead of a, b, c, . . . . We now construct a machine L which, when supplied with the formula Mg, writes down the sequence g. The construction of L is somewhat similar to that of the machine K which proves all provable formulae of the functional calculus. We Wrst construct a choice machine L1, which, if supplied with a W.F.F., M say, and suitably manipulated, obtains any formula into which M is convertible. L1 can then be modiWed so as to yield an automatic machine L2 which obtains successively all the formulae into which M is convertible (cf. foot-note p. [77]). The machine L includes L2 as a part. The motion of the machine L when supplied with the formula Mg is divided into sections of which the n-th is devoted to Wnding the n-th Wgure of g. The Wrst stage in this n-th section is the formation of {Mg}(Nn). This formula is then supplied to the machine L2, which converts it successively into various other formulae. Each formula into which it is convertible eventually appears, and each, as it is found, is compared with

lx lx0[{x} {x}(x0)

ð

Þ]

½

, i:e: N2, and with

lx lx0[{x}(x0)]

½

, i:e: N1: If it is identical with the Wrst of these, then the machine prints the Wgure 1 and the n-th section is Wnished. If it is identical with the second, then 0 is printed and the section is Wnished. If it is diVerent from both, then the work of L2 is resumed.

<!-- page 98 -->
15 The Graduate College, Princeton University, New Jersey, USA. By hypothesis, {Mg}(Nn) is convertible into one of the formulae N2 or N1; consequently the n-th section will eventually be Wnished, i.e. the n-th Wgure of g will eventually be written down. To prove that every computable sequence g is l-deWnable, we must show how to Wnd a formula Mg such that, for all integers n,

{Mg}(Nn) conv N1þfg(n): Let M be a machine which computes g and let us take some description of the complete conWgurations of M by means of numbers, e.g. we may take the D.N of the complete conWguration as described in § 6. Let x(n) be the D.N of the n-th complete conWguration of M. The table for the machine M gives us a relation between x(n þ 1) and x(n) of the form

```prolog
x(n þ 1) ¼ rg x(n)
          ð
              Þ,
```

where rg is a function of very restricted, although not usually very simple, form: it is determined by the table for M. rg is l-deWnable (I omit the proof of this), i.e. there is a W.F.F. Ag such that, for all integers n,

{Ag}(Nx(n)) conv Nx(nþ1): Let U stand for

,

lu

{u}(Ag)





(Nr)





where r ¼ x(0); then, for all integers n,

{Ug}(Nn) conv Nx(n): It may be proved that there is a formula V such that 8 > > > > > > <

conv N1

if, in going from the n-th to

the (n þ 1)-th complete configuration, the

figure 0 is printed: {V}(Nx(nþ1)) f g(Nx(n))

conv N2

if the figure 1 is printed. > > > > > > :

conv N3

```prolog
otherwise.
```

Let Wg stand for













, lu

{V} {Ag} {Ug}(u)

{Ug}(u)



 



so that, for each integer n,

{V}(Nx(nþ1))

```prolog
g(Nx(n)) conv {Wg}(Nn),
```

and let Q be a formula such that

{Q}(Wg)





<!-- page 99 -->
(Ns) conv Nr(z), where r(s) is the s-th integer q for which {Wg}(Nq) is convertible into either N1 or N2. Then, if Mg stands for

****

****

****

****

**,**

**lw {Wg}**

**{Q}(Wg)**

****

****

**it will have the required property.16**

16 In a complete proof of the l-deWnability of computable sequences it would be best to modify this method by replacing the numerical description of the complete conWgurations by a description which can be handled more easily with our apparatus. Let us choose certain integers to represent the symbols and the m-conWgurations of the machine. Suppose that in a certain complete conWguration the numbers representing the successive symbols on the tape are s1s2 . . . sn, that the m-th symbol is scanned, and that the m-conWguration has the number t; then we may represent this complete conWguration by the formula

[Ns1, Ns2, . . . , Nsm1], [Nt, Nsm], [Nsmþ1, . . . , Nsn]

½

,

where

[a, b] stands for lu {u}(a)

f

```prolog
     g(b)
½
        ,
```

[a, b, c] stands for lu {{u}(a)}(b)

f

```prolog
        g(c)
½
          ,
```

etc.
