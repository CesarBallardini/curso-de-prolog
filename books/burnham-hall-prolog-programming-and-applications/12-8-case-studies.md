# 8 Case Studies

<!-- page 103 -->
In this chapter we present two case studies. They are designed to expand upon some of the techniques we have used throughout the book. The examples are relatively simple but could be expanded if desired.

*Case study 1*

This case study is a package that acts as an insurance quote advice system, and was developed using PROLOG-! running on an IBM PC. The program is designee to provide the USER with all possible quotes that match his specification. The

'DATA.PRO' - Contains all the output responses, insurance company details,

and car details. 'UTIL.PRO'

- Contains a number of utility procedures used by the main pro-

gram 'CONT.PRO.' 'CONT.PRO' - The controlling program. It is used to calculate the quote from

the user speCification.

The listings for the ftles are given below. Notice that anything enclosed as shown below is treated as a comment. Thus

**/* This is a comment! */**

is treated as a comment.

*'DATA.PRO'*

**/*USER PROMPTS */**

**/* The lists contained in the argument of the predicate 'resp' are output to**

**the screen using the screen predicate defined in the file UTIL.PRO */**

resp (f), [ ,

INSURANCE ADVICE PACKAGE

**version 1..,**

<!-- page 104 -->
This package will give insurance quotes W. D. Burnham et al., *Prolog Programming and Applications* © W. D. Burnham and A. R. Hall 1985

for cars to be insured in the U.K. only

Before the clients insurance premiumcan

be calculated some details are required.

PLEASE ANSWER IN THE MANNER INDICATED ]).

**resp(l,[ ",**

'Please enter the model of the clients car', , Enclose your answer in single quotes.

']).

resp (2, [ " 'Please enter the engine size in c.c. ']).

resp (3, [ " , Please enter the date of manufacture ']).

resp(4,[ " , Give the clients surname and initials', 'Enclose your answer in single quotes']).

resp(5,[ " 'Give the clients address " , Enclose your answer in single quotes']).

**resp (6, [ ",**

, List any convictions according to the codes given " , ,, , Drink Driving ................... d', ,, , , Dangerous driving ...............

dd', , , 'Speeding .......................s', , Enter as a list']).

**resp (7, [ ",**

, What is the clients age ']).

<!-- page 105 -->
resp (8, [ " , What type of insurance', ,, , 'Third party fire and theft ......... tpft',

,

**, Full comprehensive ............. .fcomp']).**

**resp (9, [ ",**

, Please enter any extras according to the "

, following codes',

,, ,

**, Protected Policy (fcomp only) ..... p "**

,, ,

**, Windscreen Insurance ............w "**

, ,,

**, Radio/Cassette insurance ......... r "**

, ,,

, Enter as a list ']).

resp (1~,[ , What is the clients no claims bonus in %']).

/*Car Data: All the clauses are of the form

car_grp (CAR TYPE, ENGINE SIZE, INS GROUP)*/ car_grp ('ford cortina', 2~00, 5). car_grp ('mini metro', 1300, 3). car...grp ('mini metro', 110~, 2). car_grp ('M.G. metro', 130*,,4).

/* Basic premium data : All clauses take the form

bas_prem (GROUP, COST, COMPANY, TYPE) */ bas_prem (2,1*,~, 'Cheap Insurance P.L.C.', tpft). bas_prem (2,250, 'Pricey Insurance', fcomp). bas_prem (2,15*" 'Cheap Insurance P.L.C.', fcomp). bas_prem (3,349, 'Cheap Insurance P.L.C.', fcomp). bas_prem (3,245, 'Cheap Insurance P.L.C.', tpft). bas_prem (3,4~, 'Pricey Insurance', fcomp). bas_prem (3,275), 'Pricey Insurance', tpft). /* Company loadings: All clauses are of the form

**loading (COMPANY, TYPE' [[CODES, LOADINGS]]) */**

**loading ('Pricey Insurance', tpft, [[d, 300], [s,45], [dd,50] D.**

**loading ('Pricey Insurance', fcomp, [[d, 350], [s, 45] , [dd, 50] D.**

loading ('Cheap Insurance P.L.C.', tpft, [[d, 400] , [s, 30] ,

**[dd, 80] D.**

/* Costs forExtras*/ extras (,Pricey Insurance', fcomp, [[p,25], [w,25], [r,30] D. extras ('Pricey Insurance', tpft, [[r,30], [w,35] D. extras ('Cheap Insurance P.L.C.', fcomp, [[p,25], [w,35],

**Cr,20] D.**

<!-- page 106 -->
extras (,Cheap Insurance P.L.C.', tpft, [[r,2S], [w,3S]]).

*'UTIL.PRO'* *1 FIND LOADINGS AND EXTRAS 1* calcJoad (Options, Data, Results) :-

calcJoad (Options, Data,', Result). calcJoad ([] ,_, N, N). calcJoad ([OptioniRest], Data, N, Total) :-

entry (Option, Data, Value),

Sum is N +Value,

calcJoad (Rest, Data, Sum, Total). entry (H, [[H, Y]U, Y) :-!. entry (H, UT], P) :- entry (H, T, P). *1 FIND THE LENGTH OF A LIST 1* length (X, J) :- flen (X, J, '), flen ([], Y, Y). flen ([HlT], Y, Z) :- Pis Z + 1,

flen (T, Y, P). *1 INPUT OUTPUT PROCEDURE 1* ipout (resp (R, X), Y):-call (resp (R, X»,

screen (X),

nl,

write (' I:'),

read (Y). screen ([]): -!. screen ([HIT]) :- write (H),

nl,

screen (T).

*'CaNT. PRO* , *1 READ IN DATA FILE AND UTILITY PROCEDURES 1* *I*To* begin the program the user must type go. which causes Prolog to consult the data and utility files 1* go:- consult ('data.pro'),

consult ('until.pro'),

```prolog
start.
```

<!-- page 107 -->
*1 OUTPUT TITLE AND GET USER SPECIFICATION FOR QUOTES 1* start:- resp (', X), screen (X), geCcar (Data), comput (Data).

!* GET CAR DETAILS*! geCear (data_struc (A, B» :- find_ear_det (A),

find_driver_det (B). find_ear_det (ear_det (Car, Eng, Cage» :-

ipout (resp (1, X), Car),

ipout (resp (2, Xl), Eng),

ipout (resp (3, X2), Cage).

!* GET DRNER DETAILS*! find_driver_det (driver_det (Driver, Addr, Conv, Age» :-

ipout (resp (4, X), Driver),

ipout (resp (5, Xl), Addr),

ipout (resp (6, X2), Conv),

ipout (resp (7, X3), Age).

!* COMPUTE INSURANCE QUOTE *! !* The information input by the user is obtained using ear_det and details. The insurance group of the ear specifIed is then found by ear..grp. The type of insurance, any extras and the current no claims bonus are then obtained. The cut prevents any of the information being requested again, and the cost of the insurance is computed using the details given and the information on the wrious policies contained in the database. Note that fIX is a system predicate to truncate a real number to an integer.*!

<!-- page 108 -->
compute (data_struc (A, B» :arg (I, A, Car), arg (2, A, Eng), ear..grp (Car, Eng, Group), ipout (resp (8, X), Type), ipout (resp (9, Xl), Extr), ipout (resp (1', X2), Ncb). ,., base_prem (Group, Prem, Comp, Type), C =ins_det (Group, Prem, Comp, Type), D =extrad.et (Extr, Ncb), prices (A, B, C, D), write (' Another Quote y!n : '), read (Res), Res =n. !* CALCULATE PRICES OF AVAILABLE POLICIES *! prices (A, B, C, D) :-

**A =car_det (Car, Eng, Cage),**

**B=driver_det (Driver, Addr, Conv, Age),**

C = ins_det (Group, Prem, Comp, Type),

**D =extradet (Extr, Ncb),**

loading (Comp, Type, Load),

calcJoad (Conv, Load, V),

length (Conv, J), Loading is fix (prem*(Y!(J*Ht,))), find~tra (Extra_cost, Type, Comp, Prem, Extr), discounts (Dis, Cage, Age, E), cdis (Dis, Prem, E, N), outp (Driver, Addr, Car, Eng, Cage, Age, Group,

Comp, Type, Prem, Loading, Extra_cost, N, Ncb), nI, nI, I. !* FIND EXTRAS REQUIRED AND THEIR COST*! find~tra (B, Type, Comp, Prem, Ext):-

extras (Comp, Type, Xtra),

calcJoad (Ext, Xtra, y),

length (Ext, H),

B is fIX (prem*(y!(H*I"))).

!* CALCULATE DISCOUNTS *!

discounts (Dis, Cage, Age, E) :-

```prolog
disc(Cage, V, S),
disca (Age, U, P),
DisisU+V,
QisS+P,
«Q =" E=1, !);E=Q)
```

!*Discount due to car age*! disc (Cage, 10, 1) :- 1985-Cage> =1~,

!. disc C, " ,). !*Discount due to age of the driver*! disca(Age, 25,1) :- Age> =25,

<!-- page 109 -->
!. disca C, " ,). !*Calculate the reduction in costs due to the discounts*! edis (Dis, Prem, E, N) :- N is fIX (prem* (Dis/(E*IH»). *1 OUTPUT FORMATTING 1* outp (Driver, Addr, Car, Eng, Cage, Age, Group, Type, Prem, Loading, B,N,Ncb) :write ('

Insurance Quotation'), nl, write (' Drivers Name ............. .'), write (Driver), nl, write (' Drivers Age ...............'), write (Age), nl, write (' Address .................. '), write (Addr), nl, write (' Insurance Company ........ '), write (Comp), nl, write (' Insurance Type ........... .'), write (Type), nl, write (' Vehicle Type ............. '), write (Car), tab (2), write (Eng), nl, write (' Date of Manufacture ....... '), write (Cage), nl, write (' Insurance Group ........... '), wrige (Group), nl, write (' Basic Premium ............ '), write (prem), nl, write (' Extras Requested .......... '), write (B), nl,[ write (' Loadings ................. '), write (Loading), nl, write (' Discounts ................ '), write (N), nl, write (' No Claims Bonus .......... '), write (Ncb), write (' %'), nl, Cost is fIx «Prem + B + Loading -

N*(Ncb/l~~»), write (' Amount Payable is ......

..

'), write (Cost), nl. *Case study 2*

This is a case study that demonstrates how the grammar rule notation of Prolog can be used to construct a small system designed to classify different types of sentences. The program is written as two files, converse. pi and vocab. pI.

*'CONVERSE. PL'* *1 This program uses the high level grammar syntax of Prolog to build a natural language processor*/ /* The program was written using Quintus Prolog */ /* 1. Read a sentence and transform it into a list of words */ read_sentence (S) :- tab (10),

write (':'),

get (C),

words (C, S). words (C, [PIPs]) :- letter (C),

word (C, ct, L),

name (P,L),

<!-- page 110 -->
words (Cl, Ps). words (44, [',' Ps]) :- get (C1),

words (C1, Ps). words (45, L'-' PsJ) :- get (Cl),

words (C1, Ps). words (59, [';' Ps]) :- get (C1),

words (C1, Ps). words (63, ['?']). words (46, ['.']). words C,P) :- get (C),

words (C, P). words (C, C1, [C:Cs]) :- get~(C2),

(letter (C2), word (C2, C1, Cs); C1=C2, Cs=[]). letter (32) :- !,fail.

/* space

*/ letter (39) :- !,fail.

/* quote'

*/ letter (34) :- !,fail.

/* quote"

*/ letter (63) :- !,fail.

/*

?

*/ letter (59) :- !,fail.

**/***

*/ letter (45) :- !,fail.

/* hyphen

*/ letter (46) :- !,fail.

**/* stop**

*/ letter (33) :- !,fail.

**/***

!

*/ letter (44) :- !,fail.

/* comma

*/ letter (1~) :- !,fail.

/* line feed

*/ letter (13) :- !,fail.

**/* carriage return**

*/ letter U.

/* default

*/

[Authors' note 1. The above section of code is taken from *How to solve it with* *Prolog* (Helder Coelho, Jose Carlos Cotta and Luis Moniz Pereira, Laboratorio Nacional de Engenharia Civil, Lisboa, Portugal). The book contains many practical case studies of Prolog applications and is highly recommended. The effect of the code is to allow a sentence to be input in normal prose and to be transformed into the much more convenient data structure of a list. For example

read_sentence (S).

:the man and the woman understand

prolog

S = [the, man, and, the, woman, understand, prolog,'.']

As an interesting exercise you might care to attempt to write your own routine to accomplish the same thing.] /* 2. Definition of sentence and phrase structure */ sentence ~

<!-- page 111 -->
noun_phrase, verb_phrase, terminator. sentence _

```prolog
question.
```

sentence _

```prolog
imperative.
```

noun_phrase _

determiner, noun, extension. extension _

conjunction, noun_phrase. extension _

disjunction, noun.,phrase. extension -

[] . verb_phrase -

verb, noun_phrase. verb.,phrase -

verb, adverb. question _

interrogative, noun_phrase, verb_phrase, ['1']. imperative _

**noun, separator, verb_phrase, ['!'].**

[Authors' note 2. Here the grammar syntax is used in a straightforward way to describe the general structure of the types of statements that the program will recognise. For instance, the basic form of a sentence is declared to be a noun phrase followed by a verb phrase and ending with a terminator (full stop, question mark or exclamation). As you can see, components of the sentence are then further broken down. The empty list signifies that a grammar component is not essential to the sentence.] /* 3. The interactive program */ start_up :- consult ('vocab. pl'). talk :- tab (2'),

**write (,enter sentence for validation'), nI,nI,**

read_sentence (S),!,

phrase (sentence, S),

**nI,nI, tab (2'),**

write ('I understand the sentence:'),

**nI, nI, tabl (2,), write ("")**

relay_sentence (S),

write (""),

classify (S).

classify (S):- phrase (question, S),

**nI,nI, tab (2'), write ('it is a question').**

classify (S):- phrase (imperative, S),

**nl, nI, tab (2'),**

write Cit is an imperative instruction').

**classity (S):- nI, nI, tab (2'),**

write ('it is an instructive sentence').

<!-- page 112 -->
relay_sentence (S) :- word_in (W, S), write (W), write (' '), fail. relay_sentence U. wordjn (W, [W -1). wordjn (W, L T]) :- word_in (W, T).

[Authors' note 3. The interactive program works as follows. First the system is invoked by the talkinstruction which produces a prompt and then requires a sentence to be input. Valid sentences (according to the grammar and vocabulary rules defined by the program) are then further classified and an appropriate text message is generated to confirm that the program recognises the sentence.]

*VOCAB.PL*

separator ~

[' , '] . separator ~

[' - '] . separator -+ [' ; '] .

terminator -+ [' . ']. terminator -+ [' ? '] . terminator -+ [' ! '].

determiner -+ [a] . determiner -+ [an] . determiner -+ [the] . determiner -+ [] .

conjunction -+ [and] .

disjunction ~

[or] .

noun -+ [man]. noun -+ [woman] . noun -+ [child] . noun ~

[boy] . noun ~

[girl]. noun ~

[word]. noun ~

[sentence] . noun ~

[computer] . noun ~

[system] . noun ~

[program]. noun ~

[prolog].

interrogative ~

[does] . interrogative ~

[can] . interrogative ~

<!-- page 113 -->
[will] . interrogative -+ [should] . interrogative -+ [could] .

verb -+ [says] . verb -+ [speaks] . verb -+ [speaks, to] . verb -+ [speak] . verb -+ [speak, to] . verb -+ [say]. verb -+ [tell] . verb -+ [read] . verb -+ [recognise] . verb -+ [respond, to] . verb -+ [understand] . verb -+ [repeat] .

adverb -+ [well] . adverb -+ [badly] .

[Authors' note 4. A very small vocabulary is defmed to the system, adequate only to demonstrate that the program does in fact work as it should. There are better and more sophisticated ways of using the grammar syntax which would need to be employed in the development of a more powerful system. However this small example should give an idea of how Prolog can be used for this type of application. A suggested case study is to take an area wherein the 'domain of knowledge' is small and easily stated and to write a natural language system which can recognise statements and answer simple questions about the domain. By dOing so it is possible not only to learn more about the use of Prolog but also about some of the problems associated with interactive and expert system development.]
