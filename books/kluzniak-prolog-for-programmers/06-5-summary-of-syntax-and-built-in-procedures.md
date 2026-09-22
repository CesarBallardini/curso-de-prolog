# 5. Summary of Syntax and Built-In Procedures

<!-- page 153 -->
_

ittt

This chapter describes Prolog as de¿ned by Toy. the implementation presented in Chapter 7. The supported dialect is very similar to Prolog-I0 (Pereira et al. I978. Bowen I981. Clocksin and Mellish I981); some. but not all. differences are noted. Other “standard” versions will be similar: use the appropriate reference manuals.

The user communicates with Toy through an interactive interface (see Sections I.2.2 and 7.4.2).

## 5.1 Prolog Syntax

A program can be regarded (roughly) as a sequence of clauses. De¿nitions and grammar rules in the sequence are grouped in procedures. There are quite a few principles that govem "consulting"/“reconsulting". and dynamically asserting/retracting clauses (with the rede¿nition switch on or off). Therefore a formal de¿nition of procedures would be unnecessarily involved: it should account for the fact that procedures change in time.

The notation used is extended BNF. Non-terminal symbols will be boldfaced. and some of them subscripted (this is the ¿rst extension). A BNF rule takes the general form

lhsnontenn ::= rhsl

I .... .. I rhs, (lhsnontenn is either rhs, or

or rhs,).

Each rhs is a sequence of non-terminals and terminals. The second extension: zero or more occurrences of a sequence s are denoted as {s}. To avoid confusion. terminal symbols I I} will be boldface. Throughout the description. we assume standard operator declarations are in force.

Many special forms. such as integer expressions to be evaluated by is.

<!-- page 154 -->
I43 =:=. etc., or lists of single characters. will not be described. See Section 5.2 and on for applications of these forms in built-in procedures. Some comments in plain English will be interspersed in the BNF description. See also the notes at the end of this section.

clause :: = de¿nition I grammamlle I directive de¿nition ::= nonunitclause

I unitclause nonunitclause ::= head :- body unitclause ::= head

COMMENT the main functor of head is not a

```prolog
binary :-
```

head ::= nonvarint body ::= bodyalt { ; bodyalt } bodyalt ::= call I . call } call ::= nonvarint I variable I ( body ) nonvarint ::= term

COMMENT not a variable or an integer (a formal

de¿nition would be straightforward but

cumbersome) grammarrule ::= lhside —> rhside

COMMENT the arrow is written as --> lhside ::= nonterminal context I nonterminal nonterminal ::= nonvarint context ::= terminals rhside ::= altematives altematives ::= altemative { ; altemative } altemative ::= ruleitem I . ruleitem } ruleitem ::= nonterminal I terminals I

condition I I I ( altematives ) terminals ::= list I string

COMMENT only closed lists are allowed condition ::= curlyterm directive ::= command I query command ::= :- body query ::= body

COMMENT body's main functor is not a unary :te|1n ::= tennmo termN ::= op¢,._N termN_| I op¢,,_N IBTIIIN

I

**terms-I 0p.t.~ I terms ems I**

WTIIIN-| oPxfx.N IIBITIIN-| I

tenns-I 0p.s.~ terms I

<!-- page 155 -->
terms 0Pm.~ lemma I terms-I

5. I. Prolog Syntax

I45

COMMENT I =< N =< I200; op-r,,,_N is an operator of

type Type and priority N; termN can be

called “term with priority N“ termo ::= variable I integer I string I

IistInoop|

noop( term{ , term } ) I

( term ) I curlyterm curlytenn ::= I term } noop ::= functor op-LN ::= functor

COMMENT T is one of fx, fy, xf. yf, xfx. xfy,

yfx, N is in the range l..l200; see

also note I list=:= lllllermq-»{.l¢rm9-»}lI

Ill!l'llI999I .l¢l'lIl999}|lBl'III]

COMMENT terms with priority 999 can be safely

conjoined by commas which are in¿x

functors with priority I000 functor :: = word I qname I

symbol I soloehar word :: = wordstart { alphanum } wordstart ::= smalletter alphanum ::= srnalletter I bigletter I

**digit I -**

qname ::= ‘I qitem }' qitem ::= " I nonquote

COMMENT nonquote is any character other than ’ symbol :: = symch I syrnch } variable ::= varstart I alphanum } varstart ::= bigletter I integer ::= - digit I digit } I diglt I digit } string ::= "I sitem }”

COMMENT in Toy a string is equivalent to a list of

character names; in Prolog-I0. to a list

of their ASCII codes

tem::=

nondquote

**COMMENT nondquote is any character other than ”**

**smalletter::=aIbIcIdIeIfIgIhI|I**

**JIkIlImInI0IPIqIPI**

**SIIIUIVIWIXIYIZ**

bigletter::=AIBIC

I

**EIFIGI**

=1:

**JIKIL**

**SITIU**

K0:

**22., *5**

OIP I

**x|v**

<!-- page 156 -->
**digit::=0I I I2I3I4I5I6I7I8I9**

**symch::=.I:I-I<I=I>I+I/I**

***I?I&I$I(wI#I-aI\**

COMMENT a lone dot followed by white space is not a symch

but a fullstop solochar ::= .

I ;

I ! token ::= functor I variable I integer I

string I hracketbar

COMMENT tokens are listed to explain note 6 below bracketbar::=(I)I[I]I{I}II comment ::= % I nonlineend } lineend

COMMENT lineend is an end-of-line ( linefeed )

character; nonlineend is any other

character. Toy converts line-ends to

single linefeeds

whitespace :: = I layoutchar I

COMMENT layoutchar is blank or tab or lineend

or any nonprintable character ( in

ASCII these are characters with codes

=< 3| )

fullstop ::= . layoutchar

Notes: I. Mixed functors have not been described. but their inclusion is straightforward:

term“ ::= op|,;,_¢,|_N termN_|

and I I other combinations. In Toy. a mixed functor can only have one binary and one unary type. both with the same priority.

2. There are numerous ambiguous combinations of contiguous operators. This grammar does not account for them. See Section 7.4.3 (and Appendix A.3) for a rather detailed description in Prolog.

3. Not all functors can be declared as operators. Quoted names are always taken as “normal” functors.

4. In the de¿nition of body. commas and semicolons need not have been actually singled out. because they are regular in¿x functors. The de¿nition

<!-- page 157 -->
body ::= nonvarint would not. however, emphasize the most common structure of body.

5. The syntax of directives conforms to the convention adopted in Toy.

See Section 7.4.2 for details.

6. Comments and whitespace can be freely inserted before and after a

token. and cannot be inserted in the middle of a token. Remember that

a comment extends till end-of-line.

7. Whitespace must be inserted between an unsigned integer and a minus

which is to be treated as a functor. A minus immediately preceding a

sequence of digits is taken as a part of the integer.

8. If curly brackets are not available. the usual practice is to use “deco-

rated brackets“: %( and %). This requires some care in the treatment

of comments.

9. A term on input must be terminated with a full stop not embedded in a

quoted name. string or comment.

## 5.2 Built-In Procedures: General Information

GENERAL INFORMATION

For the purposes of this chapter. built-in procedures fall into two groups. System procedures are implemented in the interpreter described in Section 7.3. Prede¿ned procedures are written in Prolog; they belong to the user interface described in Section 7.4. Together. these two groups cover the basic set of Prolog-I0 procedures. Differences and extensions are noted where appropriate but this is a description of Toy and is not intended as a replacement for the Prolog-I0 manual. The procedures are roughly classi¿ed according to their purpose.

A system procedure call may fail. succeed or raise an error. Failure or success is equivalent to a failure or success of a normal procedure call. The only difference is that success is usually accompanied by a sideeffect, such as writing a character. setting a switch, etc. A failing system procedure does not usually cause any side-effects (input procedures are a notable exception).

An error is raised when a system procedure detects an incorrect parameter (or parameters). If the description of a procedure mentions the form of expected parameters, parameters of unlisted forms will cause an error to be raised. There is no guarantee that the error will be raised before any actions are performed. though this is usually so.

<!-- page 158 -->
Raising an error consists in invoking procedure error! I . with its single parameter instantiated to the offending system procedure call. In general. error behaves as if its call were present in the program instead of the erroneous system procedure call. An explicit call to error is also possible. error is a Prolog procedure: the standard library contains a simple version which outputs a message and fails. The user can augment this procedure to his liking. possibly providing different clauses as “error handlers" for different system procedures. Rede¿nition of error requires removing it from the standard library (see Section 7.4.5)—in the present version it is protected together with the whole library. Some prede¿ned procedures invoke error. and so can the user‘s programs.

error is not in Prolog-I0.

The following are conventions observed throughout this chapter. (Additional conventions or explanations appear under some group headings.)

Whenever we say that a procedure “tries to unify" we mean that it fails or succeeds depending on the outcome. Success means that uni¿cation is performed.

When we say that a procedure "tests" something. we mean that it fails or succeeds according to the result.

Acceptable parameters are indicated by conventional names listed below:

TERM—any term will do INTEGER—an integer VAR—a variable NONVARINT—a non-variable, non-integer term CALL—same as NONVARINT ATOM—a NONVARINT without arguments NAME—same as ATOM CHAR—a NAME consisting of a single character FILENAME—a NAME conforming to the implementation-dependent

conventions for specifying ¿les CALLIST—a list (possibly empty) of CALLs CHARLIST—a list (possibly empty) of CHARs DIGITLIST—a CHARLIST built of digit characters

In descriptions, PARI , PAR2 etc. stand for actual parameters in the builtin procedure call.

Note that ‘I23’ is a name, and I23 an integer. 9 is the integer nine. and '9' is the digit (character). The output procedures do not always distinguish between the two (writeq does).

<!-- page 159 -->
Toy introduces a number of prede¿ned operators. Some of them are used as in¿x or pre¿x procedure names. Table 5.l is the list of prede¿ned operators: TABLE 5.1 Prede¿ned Operators

Name Type

Priority

I 200 xfx

I 2(1)

-->

I 2(1)

I III)

I (D0 fx xfx xfy xfy l'|OI

is

=\= < =< > >= @< fv xfx xfx xfx xfx xfx xfx xfx xfx xfx @=< xfx @> @>

\==

+ xfx = xfx xfx xfx xfx yfx + fx yfx

9%

7(1)

7(1)

7(1)

7(1)

7(1)

7(1)

700

700

700

700

7(1)

7(1)

7(1)

7G3

7(1)

SM

500

500

511]

4-00

4-00

3(1) I mod fx yfx yfx xfx

## 5.3 Convenience

**true**

**always succeeds**

<!-- page 160 -->
fail always fails. not CALL the “not” procedure (but see Section 4.3.2!): succeeds only when the parameter fails. De¿ned in Prolog: not C :- C. !, fail. I101 _. CALL . CALL

the “and” procedure: succeeds only when both arguments succeed.

De¿ned in Prolog:

```prolog
A, B :- A. B.
```

See also the description of the cut. CALL ; CALL

the “or” procedure: succeeds only if either of the parameters suc-

ceeds. De¿ned in Prolog:

```prolog
A;_:- A.
_; B :- B.
```

See also the description of the cut. check(CALL)

succeeds only when the parameter succeeds. but instantiates no vari-

ables—only side-effects of CALL remain. De¿ned in Prolog:

```prolog
    check( Call ) :- not not Call.
Not in Prolog-I0.
```

side_effects(CALL)

exactly equivalent to check(CalI). but used when the parameter is to

be executed for its side-effects rather than to test something. Not in

Prolog-I0. once(CALL)

executes CALL deterministically. De¿ned in Prolog:

```prolog
    once( Call ) :- Call. I.
Not in Prolog-I0.
```

## 5.4 Arithmetic

In the descriptions. div stands for integer division, and mod for taking the remainder of integer division.

The following are correct invocation patterns for sum/3 (not in Prolog-I0).

sum(INTEGER. INTEGER. INTEGER)

succeeds only if PARI + PAR2 = PAR3 sum(INTEGER. INTEGER. VAR)

succeeds after unifying PAR3 with the value of PARI + PAR2 sum(INTEGER, VAR, INTEGER)

<!-- page 161 -->
succeeds after unifying PAR2 with the value of PAR3 — PARI sum(VAR. INTEGER, INTEGER) succeeds after unifying PARI with the value of PAR3 — PAR2

The following are correct invocation patterns for prod/4 (not in Prolog-I0). prod(INTEGER, INTEGER. INTEGER, INTEGER) succeeds only if PARI * PAR2 + PAR3 = PAR4 prod(INTEGER. INTEGER. INTEGER. VAR) succeeds after unifying PAR4 with the value of PARI * PAR2 + PAR3 prod(INTEGER. INTEGER, VAR. INTEGER) succeeds after unifying PAR3 with the value of PAR4 — PARI * PAR2 prod(INTEGER. VAR, VAR, INTEGER) succeeds after unifying PAR2 with the value of PAR4 div PARI and PAR3 with the value of PAR4 mod PARI prod(VAR. INTEGER. VAR. INTEGER) like the previous one. but with PARI and PAR2 exchanged prod(INTEGER. VAR, INTEGER. INTEGER) fails if (PAR4 - PAR3) mod PARI is not zero; otherwise succeeds after unifying PAR2 with the value of (PAR4 - PAR3) div PARI prod(VAR. INTEGER. INTEGER. INTEGER) like the previous one. but with PARI and PAR2 exchanged

TERM is TERM the procedure is assumes PAR2 is an integer expression. i.e. a tenn composed of integers by means of standard arithmetic functors: + (binary and unary). — (binary and unary), 1-. /. mod. The procedure fails if PAR2 is not an integer expression. Otherwise it evaluates the expression and tries to unify the value with PARI. According to Prolog-I0 conventions. is can also evaluate a list

[ INTEGER ] as this INTEGER; e.g. 55 is I55] succeeds. (This is needed in Prolog- I0 mainly for evaluating single character strings to ASCII codes.) De¿ned in Prolog.

## 5.5 Comparing Integers and Names

<!-- page 162 -->
less(INTEGER. INTEGER) succeeds only if PARI < PAR2. Not in Prolog-I0. TERM =:= TERM PARI and PAR2 are treated as integer expressions and evaluated. The procedure succeeds only if both parameters are proper integer expressions (see is/2) and their values are equal. De¿ned in Prolog. TERM =\= TERM as above. but tests whether the values are nonequal TERM < TERM as above. but tests whether the value of PARI is less than that of PAR2 TERM =< TERM as above. but tests whether the value of PARI is not greater than that of PAR2 TERM > TERM as above. but tests whether the value of PARI is greater than that of PAR2 TERM >= TERM as above. but tests whether the value of PARI is not less than that of PAR2 NAME @< NAME succeeds only when PARI precedes PAR2 in the lexicographic order (as de¿ned by the underlying ASCII collating sequence). NAME @=< NAME like @<, but tests whether PAR2 does not precede PARI. De¿ned in Prolog. NAME @> NAME like @<, but tests whether PAR2 precedes PARI. De¿ned in Prolog. NAME (w>= NAME like @<, but tests whether PARI does not precede PAR2. De¿ned in Prolog.

## 5.6 Testing Term Equality

TERM = TERM tries to unify PARI and PAR2. De¿ned in Prolog:

<!-- page 163 -->
X=X. eqvar(VAR, VAR) succeeds only when the parameters are two occurrences of the same nondummy variable. Not in Prolog-I0. TERM == TERM

succeeds only when the parameters are two occurrences of the same

term. For example, if A. B are uninstantiated.

P( A ) = = P( B )

fails. even though

**P(A)=P(B)**

succeeds. De¿ned in Prolog. TERM \== TERM

succeeds only when the parameters are not two occurrences of the

same tenn. De¿ned in Prolog.

## 5.7 Input/Output

5.7.1. Switching Streams

This set of procedures can be used to dynamically change the ¿les read or written by the input/output procedures. The user’s terminal is treated like any other ¿le: its name is user (both for input and output); the terminal is read from and written on by default.

Ideally. one should be able to open a ¿le with tell or see. stop using it with another tell or see. start using it from the current position after a second tell or see. and close it with told or seen. There should be no limits on the interleaving introduced by using a ¿le in the middle of using a ¿le in the middle etc.

The procedures are described as if this situation were real. In practice. things are very implementation-dependent. The version of Toy presented in Chapter 7 has only two input and two output streams: one for the terminal and one for a disk ¿le in each direction. Also. Toy has no code for dealing with incorrect ¿le names. nonexistent ¿les and the like. All this is too dependent on the environment in which it is implemented. sec(FILENAME)

the speci¿ed ¿le becomes the current input ¿le; the terminal’s name

is user seeing(TERM)

<!-- page 164 -->
tries to unify the parameter with the name of the current input ¿le seen closes the current input ¿le; user becomes current. Has no effect if the current ¿le is user teIl(FILENAME) the speci¿ed ¿le becomes the current output ¿le; the terminal‘s name is user telling(TERM) tries to unify the parameter with the name of the current output ¿le told closes the current output ¿le; user becomes current. I-Ias no effect if the current ¿le is user

5.7.2. Listing Control

The Toy-Prolog interpreter contains a listing switch. If the switch is on. each line read in from the current input is listed on the user‘s terminal: this is useful when one wants to see what is being read from a disk ¿le. echo succeeds after turning the listing switch on; has no effect if the switch is already on. Not in Prolog-I0. noecho succeeds after turning the listing switch off; has no effect if the switch is already off. Not in Prolog-I0.

5.7.3. Terms

display/(TERM) writes the term onto the current output. The term is written in standard notation (pre¿x with parentheses) and identi¿ers are not quoted even if they normally should be. Variables are written as _n. where n is an address. There is no guarantee that a variable will be printed as the same address in different invocations of display. In Prolog-I0. display is a little different: it always writes on the user's terminal. write(TERM) writes the term onto the current output. The term is written according to operator declarations currently in force. No identi¿ers are quoted. Variables are written as X I . X2 etc. Each invocation of write begins numbering from I. so that e.g. the calls

```prolog
write( X ). write( f( Y. X ) )
```

will produce

<!-- page 165 -->
XIf( XI. X2 ) De¿ned in Prolog. CAUTION: in Toy. write uses numbervars (see Section 5.I5) which binds variables in the term to ‘V‘(N) for N = I.

2. etc. Hence, write cannot output any term 'V’(INTEGER) properly. wr|teq(TERM) same as write. but quotes identi¿ers that are not proper words or symbols. and also those identi¿ers that coincide with operator names; e.g. a 3-parameter is would be quoted. However. a quote within a quoted name will not be doubled (this is a bug. actually). Otherwise. a term written by writeq can be read back by read. read(TERM) reads from the current input a term. terminated with a full stop. Succeeds only when PARI uni¿es with this term. Operator declarations currently in force are taken into account. Recall that a quoted name cannot be an operator. If the text on input is not a correct term. read prints the message

+ ++ Bad term on input. Text skipped:

skips and reprints the input until the ¿rst (still unprocessed) full stop. and tries to unify PARI with ‘e r r‘. (If the erroneous line does not contain a full stop. you should input one before Prolog resumes.) See the next section for behaviour on ¿le end detecting.

De¿ned in Prolog in terms of single-character input (see the next section). op(INTEGER. TERM. ATOM) declares an operator with PAR3—the name. PARI—the priority (I =< PARI =< I200. and PAR2—the type. PARI is usually less than I000. to avoid conÀicts with clause-constructing operators (see the table in Section 5.2); operators with lower priority take precedence over those with a higher priority. PAR2 must be a proper word or symbol. Admissible types of operators are fx. fy (unary. pre¿x); xf. yf (unary. post¿x); xfx. xfy. yfx (binary. in¿x). The types fx. xf. xfx are non-associative; fy, yf. associative; xfy. right-associative; yfx. left-associative. Any other PAR2 causes an error. If an operator declaration with this name but another priority is already in force. the procedure replaces the old declaration with the new one. If a declaration with the same name and priority exists. three possibilities arise:

—both operators are binary or both unary; the old de¿nition is re-

placed; —the old operator is unary (binary). the new—binary (unary); a

<!-- page 166 -->
mixed functor is declared;

—the old operator is mixed. the new—binary (unary); the binary

(unary) type in the mixed functor declaration is replaced with

PAR2.

De¿ned in Prolog. delop(ATOM)

the operator declaration with the name given by PARI is deleted. The

name should be quoted to prevent it from being treated as an (errone-

ous) operator with missing arguments. De¿ned in Prolog. Not in

Prolog- I0.

5.7.4. Single Characters

The Toy interpreter contains a single-character input buffer called the current character. Initially. it contains a blank and is then re¿lled by each reading operation. In the presented version. each line end is treated as if it were a linefeed character (ordinal number I0. see the procedure iseoln). Behaviour upon detection of end-of-¿le depends on the current input. If the input is user (i.e. the terminal). Prolog is terminated; otherwise an automatic seen is performed and the reading operation is restarted.

The operations presented here (except nl) differ from those in Prologl0. In Toy, the arguments of input/output operations are characters, and the internal buffer can be used to rescan the current input character. In Prolog- I0 there is no such buffer and the arguments of the operations are integers. i.e. character codes. These operations could be de¿ned as follows:

```prolog
get0( Ord ) :- rch. lastch( Ch ). ordchr( Ord. Ch ).
get( Ord ) :-
             rch. skipbl. lastch( Ch ).
             ordchr( Ord. Ch ).
skip( X ) :-
             repeat. get0( X ). !.
put( Ord ) :- ordchr( Ord. Ch ). wch( Ch ).
```

This would not assure complete compatibility. however. Erroneous calls would be handled a little differently and so would line ends. See also the description of strings. rch

succeeds after ¿lling current character with the next character from

current input (but see the introductory remarks for effects of line end

or end-of-¿le) skipbl

<!-- page 167 -->
succeeds after ensuring that current character is a printing character with ordinal number greater than 32. Does nothing if it already is such a character; otherwise repeatedly invokes rch. lastch(TERM) tries to unify its parameter with current character wch(CHAR) writes the character on current output (the linefeed character is interpreted as line terminator) nl terminates the current output line. De¿ned in Prolog:

```prolog
:- ordchr( I0. Ch ), assert( ( nl :- wch( Ch ) ) ).
```

rdch(TERM) gets the next character from current input (by invoking rch). Makes a copy of current character. treating a non-printing character (including line end) as a blank; tries to unify the copy with its parameter. De- ¿ned in Prolog. rdchsk(TERM) same as above. but preceded by a call on skipbl

5.7.5. Others

These procedures are not really concemed with input/output. but the only effect of status is to write something. and ordchr is most useful when reading or writing non-printing characters. They all are not in Prolog-I0.

ordchr(INTEGER, CHAR) succeeds only when PARI is the ordinal number (ASCII code) of PAR2 ordchr(VAR. CHAR) succeeds after unifying the variable with the ordinal number of the character ordchr(INTEGER. VAR) succeeds after unifying the variable with the character whose ordinal number is the value of PARI mod I28 iseoln(TERM) tries to unify PARI with the end-of-line character. De¿ned in Prolog:

```prolog
:- ordchr( I0. Ch ). assert( iseoln( Ch ) ).
```

<!-- page 168 -->
status writes memory utilisation information on the current output See also consult/I. reconsult/I. listing/0 and listing/I in Section 5.ll.

## 5.8 Testing Characters

Each of these procedures fails or succeeds depending on whether its parameter is a character belonging to a particular class. They are designed to help the user interface (see Section 7.4) in reading Prolog temts. but some of them are of general utility. The procedures iseoln/I and ordchr/2 (see Section 5.7.5) are also used to test characters. smalletter(TERM) tests whether the parameter is a lower case letter bigletter(TERM) tests whether the parameter is an upper case letter letter(TERM) tests whether the parameter is an upper or lower case letter digit(TERM) tests whether the parameter is a decimal digit alphanum(TERM) tests whether the parameter is a letter. a digit or an underscore character bracket(TERM) tests whether the parameter is one of the following characters:

**()ll{}**

solochar(TERM) tests whether the parameter is one of the following characters:

I

.

~19 symch(TERM) tests whether the parameter is one of the following characters:

**+--/=@#s&=.'.><>—\**

## 5.9 Testing Types

<!-- page 169 -->
These procedures fail or succeed depending on the form of their arguments. var(TERM) tests whether the parameter is an uninstantiated variable integer(TERM) tests whether the parameter is an integer

5.I0. Accessing the Structure of Terms

I59

nonvarint(TERM) tests whether the parameter is a NONVARINT (neither a variable nor an integer); not in Prolog-I0 atom(TERM) tests whether the parameter is an atom (a NONVARINT without arguments)

## 5.10 Accessing the Structure of Terms

The procedures pname and pnamei are not in Prolog-I0. They replace name/2. which is similar. but which uses lists of integers (ASCII codes) in place of our lists of characters (see Section 5.7.4).

pname(NAME. TERM) builds a list of characters fomting the name and tries to unify it with PAR2 pname(VAR. CHARLIST) succeeds after unifying the variable with a NAME formed of the characters on the list. (Note that pname(X. II. 2. 3]) binds X to the name ‘I23’. and not to the integer I23). pnamei(INTEGER. TERM) builds a list of decimal digit characters (constituting the written form of the integer) and tries to unify it with the term; the integer must not be negative. pnamei(VAR, DIGITLIST) succeeds after unifying the variable with an integer whose written form is given by the digit characters on the list. Even when the parameters are formally correct, an error may be raised if the speci- ¿ed integer is too large.

<!-- page 170 -->
functor(VAR. INTEGER. 0) PAR3 is the integer zero; succeeds after unifying the variable with PAR2 (this version is allowed for completeness. see below for sensible uses offunctor) functor(VAR. NAME. INTEGER) succeeds after unifying the variable with a term whose main functor has the name and atity de¿ned by PAR2 and PAR3, and whose arguments are different variables; PAR3 must not be negative functor(INTEGER. TERM. TERM) tries to unify PAR2 with PARI and PAR3 with the integer zero functor(NONVARINT. TERM. TERM)

tries to unify PAR2 and PAR3 with the name and arity of the main

functor in PARI

arg(lNTEGER. NONVARINT. TERM)

fails if the integer is smaller than I or greater than the arity of the

main functor in PAR2. Otherwise tries to unify PAR3 with that argu-

ment of PAR2 whose number is given by PARI.

The following are correct invocation patterns for the procedure =.. (pronounced “univ“). which is de¿ned in Prolog. VAR =.. [INTEGER]

succeeds after unifying the variable with the integer VAR =.. [NAME I TERM]

if the term is not a closed list. an error in the procedure length/2 is

raised (=.. uses length). Otherwise a term with NAME as its name

and TERM as its argument list is created and uni¿ed with VAR. INTEGER =.. TERM

tries to unify the term with [PARI] NONVARINT =.. TERM

constructs a list. with PARI ‘s main functor as the head and the list of

PARl’s arguments as the tail. Tries to unify the list with PAR2.

## 5.11 Accessing Procedures

The Toy-Prolog interpreter supports assert/3, retract/3 and clause/5. These are low-level. but quite powerful procedures (see the editor in Appendix A.4). Parameters representing clause bodies have the form of lists of calls (an empty body is []).

The Prolog library uses these low-level routines to de¿ne Prolog-I0 procedures assert/I. assertal I. assertzl I. retract! I and clause/2. Unlike most other built-in procedures. retract/I and clause/2 are non-deterministic. Parameters representing clause bodies have the form of terms used in the external representation. i.e. sequences built with commas (an empty body is true).

An attempt to apply any of these procedures to system routines de- ¿ned by the interpreter is treated as an erroneous call. So is an attempt to modify protected procedures. (There is a diagnostic printout which cannot be suppressed by rede¿ning errorl I.)

<!-- page 171 -->
Caution: Remember the standard operator declarations listed in Section 5.2. To be safe. always enclose a clause-representing term in paren-

5. I I. Accessing Procedures

I6]

<!-- page 172 -->
theses. For example. assert((a :-b.c)) rs okay. but assert( a :- b. c ) rs a call on assert/2. In some versions of Prolog. even assert( a :- b ) rs incorrect. assert(NONVARINT. CALLIST. INTEGER) PARI is treated as a clause’s head. PAR2 as its body. The clause is asserted immediately after the n-th clause of this procedure (where n is PAR3 if a clause with this number exists, and the last clause‘s position if PAR3 is too large; if the procedure is empty or PAR3 < I. the clause is asserted as ¿rst). Not in Prolog-I0. retract(NAME. INTEGER. INTEGER) PAR2 must not be negative. PARI and PAR2 de¿ne the name and arity of a predicate symbol. If the associated procedure does not contain a clause whose number is given by PAR3 (the ¿rst clause has number I). retract fails. If the clause does exist. it is logically removed from the procedure and retract succeeds. A removed clause does not disappear from storage and its active instances can still run to completion. Not in Prolog-I0. clause(NAME. INTEGER, INTEGER. TERM. TERM) PAR2 must not be negative. PARI and PAR2 are treated as the name and arity of a predicate symbol. If the associated procedure has no clause whose number is given by PAR3 (in particular. if it is a system routine) then clause fails. Otherwise it tries to unify PAR4 with the head of the clause and PARS with its body. Not in Prolog-I0. asserta(NONVARINT) treats the parameter as a clause (non-unit if its main functor is :-/2. unit otherwise). An error is raised if the ¿rst argument of a :- is not a NONVARINT. Asserts the clause at the beginning of its procedure. creating the procedure if it does not exist. De¿ned in Prolog. assertz(NON VARINT) same as above. but the assertion is at the end of the procedure. assert(NONVARINT) equivalent to asserta(PAR I ). retract(NONVARINT) the parameter is treated as a clause (non-unit if its main functor is :-/2 and unit otherwise). An error is raised if the ¿rst argument of :- is not I62

S Summary of Syntax and Built-in Procedures

<!-- page 173 -->
a NONVARINT. The ¿rst matching clause is retracted. and a fail point created (see Section 5.12). On failure. the next matching clause will be retracted. Note: if PARI has the form nonvarint:-var then it matches only clauses with a single call in their bodies. De¿ned in Prolog. clause(NONVARlNT. TERM) tries to locate the ¿rst procedure whose head matches PARI and whose body matches PAR2; the body of a unit clause is the term true. After successful uni¿cation. establishes a fail point and succeeds; the next matching clause is sought on failure. De¿ned in Prolog. Not in Prolog-I0. rede¿ne this procedure is needed to implement reconsult and should not be used directly. It modi¿es the effects of assert: if the procedure to which a clause is added is different from that affected by the last assertion. an automatic abolish is invoked before the assert. The next invocation of rede¿ne restores the original situation. protect succeeds after ensuring that all procedures already de¿ned. except those whose heads are single characters with no arguments (this restriction is imposed by a minor technical dif¿culty). are protected. An attempt to modify a protected procedure (by means of assert, retract. abolish. consult. reconsult) is treated as an erroneous invocation of the system procedure in question. (The user interface in Toy protects all its procedures.) Not in Prolog-I0. abolish(NAME. INTEGER) PAR2 must not be negative. PARI and PAR2 are treated as the name and arity of a predicate symbol. All the clauses of this procedure are logically removed (retracted) and abolish succeeds. prede¿ned(NAME. INTEGER) PAR2 must not be negative. PARI and PAR2 are treated as the name and arity of a predicate symbol. If the procedure associated with this symbol is a system procedure. prede¿ned succeeds; otherwise it fails. Not in Prolog-I0. consuIt(FILENAME) sees the named ¿le and enters program de¿nition mode: successive terms are read-in and stored via assertz (see the convention for asserta’s parameters) and asserted (but see protect). There are two exceptions: the term end causes the ¿le to be closed and de¿nition mode to be exited: terms with the unary :- as a main functor are treated as commands. and immediately executed. De¿ned in Prolog. reconsult(FILENAME) as above. but rede¿ne is called at the beginning and at the end of

5.|2. Control

I63

processing. Contiguous sequences of clauses with the same predicate symbol in their heads are treated as complete de¿nitions of procedures and supersede previous de¿nitions. listing(NONVARINT) PARI must be an ATOM. or a term of the form ATOM!INTEGER or a list of such terms (possibly multi-level). Each atom is treated as a procedure's name, each integer as a procedure’s arity. All relevant procedures are listed on the current output. De¿ned in Prolog. listing as above, but for all de¿ned procedures (including procedures de- ¿ned in the monitor and library, but excluding built-in system procedures).

## 5.12 Control

Whenever a procedure call activates a clause which is not the last clause in its procedure, we say that a fail point is associated with the call. A fail point is something to backtrack to: it saves information necessary for reestablishing the state of the computation and proceeding with the next clause. The immediate descendants of a call C are the calls in the procedure which C activated. The immediate ancestor of a call C is the call which activated the procedure containing C. An ancestor is the immediate ancestor or an ancestor of the immediate ancestor. A descendant is de¿ned similarly.

! the cut procedure; succeeds after ¿nding the nearest ancestor which is not a call/I, tag/2, ,/2 or ;/2 and removing all existing fail points associated with this ancestor and all its descendants. repeat an endless “generator of successes“ (see Section 4.3.2). De¿ned in Prolog:

```prolog
repeat.
repeat :- repeat.
```

<!-- page 174 -->
calI(CALL) behaves exactly as if its parameter were in its place, with the exception that an incorrect parameter (an integer or uninstantiated variable) is detected at run time rather than at clause-de¿nition time. In top-level syntax, one can use a variable instead of a predicate—this is converted to an invocation of call. I64

S Summary of Syntax and Built-in Procedures

halt(ATOM) stops the interpreter after writing the atom. Not in Prolog-I0. stop stops the interpreter. Not in Prolog-I0. De¿ned in Prolog. The following procedures are not in Prolog-I0. They are useful for error handling, but are “dirty”. and should be used sparingly. tag(CALL) this is a form of call/I which can be referred to by tagfail/I . tagexit/2, tagcut/2 and ancestor/2. The parameter of tag is called a “tagged ancestor“ of its descendants; it is never removed from the stack as a result of tail recursion optimisation (see Sections 6.4 and 7. I). NOTE: a tag is recognized only when explicitly written in its clause. In particular call(tag(C)) is equivalent to call(call(C)). ancestor(TERM) searches for the nearest tagged ancestor uni¿able with the parameter; fails if no such ancestor is found. otherwise uni¿es and succeeds. tagcut(TERM) searches for the nearest tagged ancestor uni¿able with the parameter. Fails if no such ancestor is found: otherwise uni¿es. removes all existing fail points associated with the ancestor and its decendants and succeeds. tagfail(TERM) equivalent to

tagcut( PARI ), fail i.e. if the appropriate tagged ancestor is found. the ancestor fails immediately; otherwise tagcut fails. tagexit(TERM) searches for the nearest tagged ancestor uni¿able with the parameter; fails if no such ancestor is found. otherwise uni¿es and passes control to the ancestor, which succeeds immediately.

## 5.13 Debugging

<!-- page 175 -->
The built-in debugging facilities of Toy are very primitive. There is only a wall-paper trace which displays all calls with a plus or a minus to indicate success or failure respectively (e.g. if a call fails to match two clauses and activates the third, it is shown twice with a minus and once with a plus).

5.l5. Miscellaneous

I65

A more useful—selective—tracer is listed in Appendix A.5. There is also a switch which may cause the interpreter to output warning messages upon encountering calls on non-existent procedures. It is good practice to turn it on when debugging a program. All these procedures are not in Prolog-I0, which has a more sophisticated set of debugging aids. debug succeeds after turning tracing on (no effect if already on) nodebug succeeds after turning tracing off (no effect if already off) nonexistent succeeds after turning on warning about calls on nonexistent procedures (no effect if already on) nononexistent succeeds after turning off warning about calls on nonexistent procedures (no effect if already off)

## 5.14 Grammar Processing

phrase(CALL, TERM) treats CALL as a nonterminal symbol of a grammar rule. schematically

```prolog
nt( ARGI, ..., ARGn ).
```

and initiates grammar processing—-with this initial symbol—by calling nt( TERM, []. ARGI,

ARGn) De¿ned in Prolog (see Section 4.2.6).

## 5.15 Miscellaneous

<!-- page 176 -->
length(NONVARINT. TERM) PARI must be a closed list. Computes the length of this list and tries to unify the resulting integer with PAR2. De¿ned in Prolog. isclosedlist(TERM) succeeds only when the term is a closed list. De¿ned in Prolog. Not in Prolog-I0. numbervars(TERM, INTEGER, TERM) instantiates PAR I ‘s variables as ’V’(i), ’V’(i + I), ..., ’V’(j) where i, i+ I, ...,j are consecutive integers, and i is the value ofPAR2. Variables bound together are of course instantiated as the same ’V’(k). As a result, PARI becomes ground (obviously, this is undone upon backtracking). Then the procedure tries to unify PAR3 with j+ I. For example, the call

```prolog
numbervars( [ X, Y, X ], 6, Next )
```

where Next is uninstantiated, will instantiate

X<—'V'(6), Y<—'V'(7), Next 4-3 The call

```prolog
numbervars( [ X, Y, X ], 6, not_a_number)
```

will fail. member(TERM. TERM) establishes the relationship: PARI is a member of the list PAR2. De¿ned in Prolog:

```prolog
member( X. I X I Y ] ).
member( X, [ _ I Y ] ) :- member( X, Y ).
```

bagof(TERM, CALL, TERM) tries to unify PAR3 with the list of PARI’s instantiations after all possible computations of PAR2 (see Section 4.2.4 for details). Prolog-I0 has a more sophisticated version of this procedure. De¿ned in Prolog.

