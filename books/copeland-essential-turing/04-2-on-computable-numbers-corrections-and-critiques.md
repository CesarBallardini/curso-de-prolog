# 2. On Computable Numbers: Corrections and Critiques

<!-- page 100 -->
**Alan Turing, Emil Post,**

**and Donald W. Davies**

**Introduction**

Jack Copeland

This chapter contains four items:

2.1 On Computable Numbers, with an Application to the Entscheidungs-

problem. A Correction.

Alan Turing

2.2 On Computable Numbers, with an Application to the Entscheidungs-

problem. A Critique.

Emil Post

2.3 Draft of a Letter from Turing to Alonzo Church Concerning

the Post Critique

2.4 Corrections to Turing’s Universal Computing Machine

Donald W. Davies

As is not uncommon in work of such complexity, there are a number of mistakes in ‘On Computable Numbers’ (Chapter 1). Turing corrected some of these in his short note 2.1, published in the Proceedings of the London Mathematical Society a few months after the original paper had appeared.

The mathematician Emil L. Post’s critique of ‘On Computable Numbers’ was published in 1947 and formed part of Post’s paper ‘Recursive Unsolvability of a Problem of Thue’.1 Post is one of the major Wgures in the development of mathematical logic in the twentieth century, although hisworkdid not gainwide recognition until after his death. (Born in 1897, Post died in the same year as Turing.)

By 1936 Post had arrived independently at an analysis of computability substantially similar to Turing’s.2 Post’s ‘problem solver’ operated in a ‘symbol

1 Journal of Symbolic Logic, 12 (1947), 1–11.

<!-- page 101 -->
2 E. L. Post, ‘Finite Combinatory Processes—Formulation 1’, Journal of Symbolic Logic, 1 (1936), 103–4. space’ consisting of ‘a two way inWnite sequence of spaces or boxes’. A box admitted ‘of but two possible conditions, i.e., being empty or unmarked, and having a single mark in it, say a vertical stroke’. The problem solver worked in accordance with ‘a Wxed unalterable set of directions’ and could perform the following ‘primitive acts’: determine whether the box at present occupied is marked or not; erase any mark in the box that is at present occupied; mark the box that is at present occupied if it is unmarked; move to the box to the right of the present position; move to the box to the left of the present position.

Later, Post considerably extended certain of the ideas in Turing’s ‘Systems of Logic Based on Ordinals’ (Chapter 3), developing the important Weld now called degree theory.

In his draft letter to Church, Turing responded to Post’s remarks concerning ‘Turing convention-machines’.3 It is doubtful whether Turing ever sent the letter. The approximate time of writing can be inferred from Turing’s opening remarks: Kleene’s review appeared in the issue of the Journal of Symbolic Logic dated September 1947 (12: 90–1) and Turing’s ‘Practical Forms of Type Theory’ appeared in the same journal in June 1948.

In his Wnal year at university Donald Davies (1924–2000) heard about Turing’s proposed Automatic Computing Engine and the plans to build it at the National Physical Laboratory in London (see Chapter 9). Davies immediately applied to join the National Physical Laboratory and in September 1947 became a member of the small team surrounding Turing. Davies played a leading role in the development and construction of the pilot model of the Automatic Computing Engine, which ran its Wrst programme in May 1950. From 1966 he was head of the computer science division at the National Physical Laboratory. He originated the important concept of ‘packet switching’ used in the ARPANET, forerunner of the Internet. From 1979 Davies worked on data security and public key cryptosystems.

‘On Computable Numbers’ contained a number of what would nowadays be called programming errors. Davies described Turing’s reaction when he drew Turing’s attention to some of these:

I was working more or less under [Turing’s] supervision . . . I had been reading his famous work on computable numbers . . . and I began to question some of the details of his paper. In fact I . . . found a number of quite bad programming errors, in eVect, in the speciWcation of the machine that he had written down, and I had worked out how to overcome these. I went along to tell him and I was rather cock-a-hoop . . . I thought he would say ‘Oh Wne, I’ll send along an addendum’ [to the London Mathematical Society]. But in fact he was very annoyed, and pointed out furiously that really it

<!-- page 102 -->
3 The draft is among the Turing Papers in the Modern Archive Centre, King’s College Library, Cambridge; catalogue reference D 2. didn’t matter, the thing was right in principle, and altogether I found him extremely touchy on this subject.4

In Section 4 of his ‘Corrections to Turing’s Universal Computing Machine’ Davies mends the errors that he discovered in 1947. He emphasizes that—as Turing said—these programming errors are of no signiWcance for the central arguments of ‘On Computable Numbers’.

Davies’s lucid commentary forms an excellent introduction to ‘On Computable Numbers’.5

4 Davies in interview with Christopher Evans (‘The Pioneers of Computing: An Oral History of Computing’ (London: Science Museum, 1975) ).

<!-- page 103 -->
5 I am grateful to Diane Davies for her permission to publish this article. 2.1 On Computable Numbers, with an Application to the Entscheidungsproblem. A Correction. (1937) Alan Turing

In a paper entitled ‘‘On computable numbers, with an application to the Entscheidungsproblem’’ [Chapter 1] the author gave a proof of the insolubility of the Entscheidungsproblem of the ‘‘engere Funktionenkalku¨l’’. This proof contained some formal errors1 which will be corrected here: there are also some other statements in the same paper which should be modiWed, although they are not actually false as they stand.

The expression for Inst {qiSjSkLql} on p. [85] of the paper quoted should read

(x, y, x0, y0)

RSj(x, y) & I(x, y) & Kqi(x) & F(x, x0) & F(y0, y)







! RS0(x0, z)Þ

! I(x0, y0) & RSk(x0, y) & Kql(x0) & F(y0, z) v

RS0(x, z)

ð½





,

& RS1(x, z) ! RS1(x0, z)

ð

Þ & . . . & RSM(x, z) ! RSM(x0, z)

ð

Þ S0, S1, . . . , SM being the symbols which M can print. The statement on p. [86], [lines 24–25], viz.

‘‘Inst {qaSbSdLqc} & F(nþ1) ! (CCn ! CCnþ1)

is provable’’ is false (even with the new expression for Inst {qaSbSdLqc}): we are unable for example to deduce F(nþ1) ! F(u, u00)

ð

Þ and therefore can never use the term

F(y0, z) v

RS0(x, z) ! RS0(x0, z)

ð

Þ & . . . & RSM(x, z) ! RSM(x0, z)

ð

Þ

½



in Inst {qaSbSdLqc}. To correct this we introduce a new functional variable G [G(x, y) to have the interpretation ‘‘x precedes y’’]. Then, if Q is an abbreviation for

(x)(9w)(y, z) F(x, w) & F(x, y)!G(x, y)

ð

Þ & F(x, z) & G(z, y) ! G(x, y)

ð

Þ

f

& G(z, x) v G(x, y) & F(y, z)

ð

Þ v F(x, y) & F(z, y)

ð

Þ ! F(x, z)

ð

Þ

½

g

the corrected formula Un (M) is to be

This article Wrst appeared in Proceedings of the London Mathematical Society, Series 2, 43 (1937), 544–6. It is reprinted with the permission of the London Mathematical Society and the Estate of Alan Turing.

<!-- page 104 -->
1 The author is indebted to P. Bernays for pointing out these errors.

(9u)A(M) ! (9s)(9t)RS1(s, t), where A(M) is an abbreviation for

Q & (y)RS0(u, y) & I(u, u) & Kq1(u) & Des (M): The statement on page [86] (line [24]) must then read

Inst {qaSbSdLqc} & Q & F(nþ1) ! CCn ! CCnþ1

ð

Þ,

and [lines 19–20] should read

r n, i(n)

ð

Þ ¼ b,

r n þ 1, i(n)

ð

Þ ¼ d,

k(n) ¼ a,

k(n þ 1) ¼ c:

For the words ‘‘logical sum’’ on p. [85], line [13], read ‘‘conjunction’’. With these modiWcations the proof is correct. Un (M) may be put in the form (I) (p. [87]) with n ¼ 4.

Some diYculty arises from the particular manner in which ‘‘computable number’’ was deWned (p. [61]). If the computable numbers are to satisfy intuitive requirements we should have:

If we can give a rule which associates with each positive integer n two rationals an, bn satisfying an < anþ1 < bnþ1 < bn, bn  an < 2n, then there is a computable number a for which an < a < bn each n.

(A)

A proof of this may be given, valid by ordinary mathematical standards, but involving an application of the principle of excluded middle. On the other hand the following is false:

There is a rule whereby, given the rule of formation of the sequences an, bn in (A) we can obtain a D.N. for a machine to compute a.

(B)

That (B) is false, at least if we adopt the convention that the decimals of numbers of the form m=2n shall always terminate with zeros, can be seen in this way. Let N be some machine, and deWne cn as follows: cn ¼ 1

2 if N has not printed a Wgure 0 by the time the n-th complete conWguration is reached cn ¼ 1

2  2m3 if 0 had Wrst been printed at the m-th complete conWguration (m < n). Put an ¼ cn  2n2, bn ¼ cn þ 2n2. Then the inequalities of (A) are satisWed, and the Wrst Wgure of a is 0 if N ever prints 0 and is 1 otherwise. If (B) were true we should have a means of Wnding the Wrst Wgure of a given the D.N. of N: i.e. we should be able to determine whether N ever prints 0, contrary to the results of §8 of the paper quoted. Thus although (A) shows that there must be machines which compute the Euler constant (for example) we cannot at present describe any such machine, for we do not yet know whether the Euler constant is of the form m=2n.

<!-- page 105 -->
This disagreeable situation can be avoided by modifying the manner in which computable numbers are associated with computable sequences, the totality of computable numbers being left unaltered. It may be done in many ways of which this is an example.2 Suppose that the Wrst Wgure of a computable sequence g is i and that this is followed by 1 repeated n times, then by 0 and Wnally by the sequence whose r-th Wgure is cr; then the sequence g is to correspond to the real number

X

1

(2i  1)n þ

(2cr  1) 2

3

 r:

r¼1 If the machine which computes g is regarded as computing also this real number then (B) holds. The uniqueness of representation of real numbers by sequences of Wgures is now lost, but this is of little theoretical importance, since the D.N.’s are not unique in any case.

The Graduate College, Princeton, N.J., U.S.A.

<!-- page 106 -->
2 This use of overlapping intervals for the deWnition of real numbers is due originally to Brouwer. 2.2 On Computable Numbers, with an Application to the Entscheidungsproblem. A Critique. (1947) Emil Post

The following critique of Turing’s ‘‘computability’’ paper [Chapter 1] concerns only pp. [58–74] thereof. We have checked the work through the construction of the ‘‘universal computing machine’’ in detail, but the proofs of the two theorems in the section following are there given in outline only, and we have not supplied the formal details. We have therefore also left in intuitive form the proofs of the statements on recursiveness, and alternative procedures, we make below.

One major correction is needed. To the instructions for con1(C, a) p. [70], add the line: None PD, R, Pa, R, R, R C. This is needed to introduce the representation D of the blank scanned square when, as at the beginning of the action of the machine, or due to motion right beyond the rightmost previous point, the complete conWguration ends with a q, and thus make the fmp of p. [71] correct. We may also note the following minor slips and misprints in pp. [58–74]. Page [63], to the instructions for f(C, B, a) add the line: None L f(C, B, a); p. [67] and p. [68], the S.D should begin, but not end, with a semicolon; p. [69], omit the Wrst D in (C2); p. [70], last paragraph [above skeleton table], add ‘‘:’’ to the Wrst list of symbols; pp. [71–72], replace g by q; p. [71], in the instruction for mk, mk should be mk1; p. [71], in the second instruction for sim2, replace the Wrst R by L; p. [71], in the Wrst instruction for sh2, replace sh2 by sh3. A reader of the paper will be helped by keeping in mind that the ‘‘examples’’ of pages [63–66] are really parts of the table for the universal computing machine, and accomplish what they are said to accomplish not for all possible printings on the tape, but for certain ones that include printings arising from the action of the universal computing machine. In particular, the tape has @ printed on its Wrst two squares, the occurrence of two consecutive blank squares insures all squares to the right thereof being blank, and, usually,symbolsreferred to areon ‘‘F-squares’’,and obey the convention of p.[63].1

Turing’s deWnition of an arbitrary machine is not completely given in his paper, and, at a number of points, has to be inferred from his development. In the Wrst instance his machine is a ‘‘computing machine’’ for obtaining the successive digits of a real number in dyadic notation, and, in that case, starts operating on a blank tape. Where explicitly stated, however, the machine may

Post’s critique originally formed an untitled appendix occupying pp. 7–11 of ‘Recursive Unsolvability of a Problem of Thue’, Journal of Symbolic Logic, 12 (1947), 1–11. The critique is reprinted here by permission of the Association for Symbolic Logic. All rights reserved. This reproduction is by special permission for this publication only.

<!-- page 107 -->
1 Editor’s note. This paragraph originally formed a footnote (the Wrst) to Post’s appendix. start operating on a tape previously marked. From Turing’s frequent references to the beginning of the tape, and the way his universal computing machine treats motion left, we gather that, unlike our tape, this tape is a one-way inWnite aVair going right from an initial square.

Primarily as a matter of practice, Turing makes his machines satisfy the following convention. Starting with the Wrst square, alternate squares are called F-squares, the rest, E-squares. In its action the machine then never directs motion left when it is scanning the initial square, never orders the erasure, or change, of a symbol on an F-square, never orders the printing of a symbol on a blank F-square if the previous F-square is blank, and, in the case of a computing machine, never orders the printing of 0 or 1 on an E-square. This convention is very useful in practice. However the actual performance, described below, of the universal computing machine, coupled with Turing’s proof of the second of the two theorems referred to above, strongly suggests that Turing makes this convention part of the deWnition of an arbitrary machine. We shall distinguish between a Turing machine and a Turing convention-machine.

By a uniform method of representation, Turing represents the set of instructions, corresponding to our quadruplets,2 which determine the behavior of a machine by a single string on seven letters called the standard description (S.D) of the machine. With the letters replaced by numerals, the S.D of a machine is considered the arabic representation of a positive integer called the description number (D.N) of the machine. If our critique is correct, a machine is said to be circle-free if it is a Turing computing convention-machine which prints an inWnite number of 0’s and 1’s.3 And the two theorems of Turing’s in question are really the following. There is no Turing convention-machine which, when supplied with an arbitrary positive integer n, will determine whether n is the D.N of a Turing computing convention-machine that is circle-free. There is no Turing convention-machine which, when supplied with an arbitrary positive integer n, will determine whether n is the D.N of a Turing computing convention-machine that ever prints a given symbol (0 say).4

2 Our quadruplets are quintuplets in the Turing development. That is, where our standard instruction orders either a printing (overprinting) or motion, left or right, Turing’s standard instruction always orders a printing and a motion, right, left, or none. Turing’s method has certain technical advantages, but complicates theory by introducing an irrelevant ‘‘printing’’ of a symbol each time that symbol is merely passed over.

3 ‘‘Genuinely prints’’, that is, a genuine printing being a printing in an empty square. See the previous footnote.

<!-- page 108 -->
4 Turing in each case refers to the S.D of a machine being supplied. But the proof of the Wrst theorem, and the second theorem depends on the Wrst, shows that it is really a positive integer n that is supplied. Turing’s proof of the second theorem is unusual in that while it uses the unsolvability result of the Wrst theorem, it does not ‘‘reduce’’ [Post (1944)] the problem of the Wrst theorem to that of the second. In fact, the Wrst problem is almost surely of ‘‘higher degree of unsolvability’’ [Post (1944)] than the second, in which case it could not be ‘‘reduced’’ to the second. Despite appearances, that second unsolvability proof, like the Wrst, is a reductio ad absurdum proof based on the deWnition of unsolvability, at the conclusion of which, the Wrst result is used.

In view of [Turing (1937)], these ‘‘no machine’’ results are no doubt equivalent to the recursive unsolvability of the corresponding problems.5 But both of these problems are infected by the spurious Turing convention. Actually, the set of n’s which are D.N’s of Turing computing machines as such is recursive, and hence the condition that n be a D.N oVers no diYculty. But, while the set of n’s which are not D.N’s of convention-machines is recursively enumerable, the complement of that set, that is, the set of n’s which are D.N’s of convention-machines, is not recursively enumerable. As a result, in both of the above problems, neither the set of n’s for which the question posed has the answer yes, nor the set for which the answer is no, is recursively enumerable.

This would remain true for the Wrst problem even apart from the convention condition. But the second would then become that simplest type of unsolvable problem, the decision problem of a non-recursive recursively enumerable set of positive integers [(Post 1944)]. For the set of n’s that are D.N’s of unrestricted Turing computing machines printing 0, say, is recursively enumerable, though its complement is not. The Turing convention therefore prevents the early appearance of this simplest type of unsolvable problem.

It likewise prevents the use of Turing’s second theorem in the . . . unsolvability proof of the problem of Thue.6 For in attempting to reduce the problem of Turing’s second theorem to the problem of Thue, when an n leads to a Thue question for which the answer is yes, we would still have to determine whether n is the D.N of a Turing convention-machine before the answer to the question posed by n can be given, and that determination cannot be made recursively for arbitrary n. If, however, we could replace the Turing convention by a convention that is recursive, the application to the problem of Thue could be made. An analysis of what Turing’s universal computing machine accomplishes when applied to an arbitrary machine reveals that this can be done.

The universal computing machine was designed so that when applied to the S.D of an arbitrary computing machine it would yield the same sequence of 0’s and 1’s as the computing machine as well as, and through the intervention of, the successive ‘‘complete conWgurations’’—representations of the successive states of tape versus machine—yielded by the computing machine. This it does for a Turing convention-machine.7 For an arbitrary machine, we have to interpret a direction of motion left at a time when the initial square of the tape is scanned as

5 Our experience with proving that ‘‘normal unsolvability’’ in a sense implicit in [Post (1943)] is equivalent to unsolvability in the sense of Church [(1936)], at least when the set of questions is recursive, suggests that a fair amount of additional labor would here be involved. That is probably our chief reason for making our proof of the recursive unsolvability of the problem of Thue independent of Turing’s development.

6 Editor’s note. Thue’s problem is that of determining, for arbitrary strings of symbols A, B from a given Wnite alphabet, whether or not A and B are interderivable by means of a succession of certain simple substitutions. (See further Chapter 17.)

<!-- page 109 -->
7 Granted the corrections [detailed above]. meaning no motion.8 The universal computing machine will then yield again the correct complete conWgurations generated by the given machine. But the space sequence of 0’s and 1’s printed by the universal computing machine will now be identical with the time sequence of those printings of 0’s and 1’s by the given machine that are made in empty squares. If, now, instead of Turing’s convention we introduce the convention that the instructions deWning the machine never order the printing of a 0 or 1 except when the scanned square is empty, or 0, 1 respectively, and never order the erasure of a 0 or 1, Turing’s arguments again can be carried through. And this ‘‘(0, 1) convention’’, being recursive, allows the application to the problem of Thue to be made.9 Note that if a machine is in fact a Turing convention-machine, we could strike out any direction thereof which contradicts the (0, 1) convention without altering the behavior of the machine, and thus obtain a (0, 1) convention-machine. But a (0, 1) convention-machine need not satisfy the Turing convention. However, by replacing each internal-conWguration qi of a machine by a pair qi, qi0 to correspond to the scanned square being an F- or an E-square respectively, and modifying printing on an F-square to include testing the preceding F-square for being blank, we can obtain a ‘‘(q, q0) convention’’ which is again recursive, and usable both for Turing’s arguments and the problem of Thue, and has the property of, in a sense, being equivalent to the Turing convention. That is, every (q, q0) conventionmachine is a Turing convention-machine, while the directions of every Turing convention-machine can be recursively modiWed to yield a (q, q0) convention-machine whose operation yields the same time sequence and spatial arrangement of printings and erasures as does the given machine, except for reprintings of the same symbol in a given square.

These changes in the Turing convention, while preserving the general outline of Turing’s development and at the same [time] admitting of the application to the problem of Thue, would at least require a complete redoing of the formal work of the proof of the second Turing theorem. On the other hand, very little added formal work would be required if the following changes are made in the Turing argument itself, though there would still remain the need of extending the equivalence proof of [Turing (1937)] to the concept of unsolvability. By using the above result on the performance of the universal computing machine when applied to the S.D of an arbitrary machine, we see that Turing’s proof of his Wrst theorem, whatever the formal counterpart thereof is, yields the following theorem. There is no Turing convention-machine which, when supplied with an

8 This modiWcation of the concept of motion left is assumed throughout the rest of the discussion, with the exception of the last paragraph.

<!-- page 110 -->
9 So far as recursiveness is concerned, the distinction between the Turing convention and the (0, 1) convention is that the former concerns the history of the machine in action, the latter only the instructions deWning the machine. Likewise, despite appearances, the later (q, q0) convention. arbitrary positive integer n, will determine whether n is the D.N of an arbitrary Turing machine that prints 0’s and 1’s in empty squares inWnitely often. Now given an arbitrary positive integer n, if that n is the D.N of a Turing machine M, apply the universal computing machine to the S.D of M to obtain a machine M. Since M satisWes the Turing convention, whatever Turing’s formal proof of his second theorem is, it will be usable intact in the present proof, and, via the new form of his Wrst theorem, will yield the following usable result. There is no machine which, when supplied with an arbitrary positive integer n, will determine whether n is the D.N of an arbitrary Turing machine that ever prints a given symbol (0 say).10

These alternative procedures assume that Turing’s universal computing machine is retained. However, in view of the above discussion, it seems to the writer that Turing’s preoccupation with computable numbers has marred his entire development of the Turing machine. We therefore suggest a redevelopment of the Turing machine based on the formulation given in [‘Recursive Unsolvability of a Problem of Thue’11]. This could easily include computable numbers by deWning a computable sequence of 0’s and 1’s as the time sequence of printings of 0’s and 1’s by an arbitrary Turing machine, provided there are an inWnite number of such printings. By adding to Turing’s complete conWguration a representation of the act last performed, a few changes in Turing’s method would yield a universal computing machine which would transform such a time sequence into a space sequence. Turing’s convention would be followed as a matter of useful practice in setting up this, and other, particular machines. But it would not infect the theory of arbitrary Turing machines.

10 It is here assumed that the suggested extension of [Turing (1937)] includes a proof to the eVect that the existence of an arbitrary Turing machine for solving a given problem is equivalent to the existence of a Turing convention-machine for solving that problem.

11 Editor’s note. See the reference at the foot of p. 97.

**References**

Church, A. 1936. ‘An Unsolvable Problem of Elementary Number Theory’, American

Journal of Mathematics, 58, 345–363. Post, E. L. 1943. ‘Formal Reductions of the General Combinatorial Decision Problem’,

American Journal of Mathematics, 65, 197–215. Post, E. L. 1944. ‘Recursively Enumerable Sets of Positive Integers and their Decision

Problems’, Bulletin of the American Mathematical Society, 50, 284–316. Turing, A. M. 1937. Computability and l-deWnability, Journal of Symbolic Logic, 2,

<!-- page 111 -->
153–163. 2.3 Draft of a Letter from Turing to Alonzo Church Concerning the Post Critique

Dear Professor Church,

I enclose corrected proof of my paper ‘Practical forms of type theory’ and order for reprints.

Seeing Kleene’s review of Post’s paper (on problem of Thue) has reminded me that I feel I ought to say a few words somewhere to clear up the points which Post has raised about ‘Turing machines’ and ‘Turing convention machines’ [see 2.2]. Post observes that my initial description of a machine diVers from the machines which I describe later in that the latter are subjected to a number of conventions (e.g. the use of E and F squares). These conventions are nowhere very clearly enumerated in my paper and cast a fog over the whole concept of a ‘Turing machine’. Post has enumerated the conventions and embodied them in a deWnition of a ‘Turing convention machine’.

My intentions in this connection were clear in my mind at the time the paper was written; they were not expressed explicitly in the paper, but I think it is now necessary to do so. It was intended that the ‘Turing machine’ should always be the machine without attached conventions, and that all general theorems about machines should apply to this deWnition. To the best of my belief this was adhered to. On the other hand when it was a question of describing particular machines a host of conventions became desirable. Clearly it was best to choose conventions which did not restrict the essential generality of the machine, but one was not called upon to establish any results to this eVect. If one could Wnd machines obeying the conventions and able to carry out the desired operations, that was enough. It was also undesirable to keep any Wxed list of conventions. At any moment one might wish to introduce a new one.

<!-- page 112 -->
Published with the permission of the Estate of Alan Turing. 2.4 Corrections to Turing’s Universal Computing Machine Donald W. Davies

**1. Introduction**

In 1947 I was working in a small team at the National Physical Laboratory in London, helping to build one of the Wrst programmed computers. This had been designed by Turing. (See Chapter 9.)

When I Wrst studied Turing’s ‘On Computable Numbers, with an Application to the Entscheidungsproblem’, it soon became evident to me that there were a number of trivial errors, amounting to little more than typographic errors, in the design of his universal computing machine U. A closer look revealed a—nowadays typical—programming error in which a loop led back to the wrong place. Then I became aware of a more fundamental fault relating to the way U describes the blank tape of the machine it is emulating. Perhaps it is ironic, as well as understandable, that the Wrst emulation program for a computer should have been wrong. I realized that, even though the feasibility of the universal computing machine was not in doubt, the mistakes in Turing’s exposition could puzzle future readers and plague anyone who tried to verify Turing’s design by implementing his universal machine in practice.

When I told Turing about this he became impatient and made it clear that I was wasting my time and his by my worthless endeavours. Yet I kept in mind the possibility of testing a corrected form of U in the future. It was to be nearly Wfty years before I Wnally did this.

<!-- page 113 -->
I could not implement exactly Turing’s design because this generates a profusion of states when the ‘skeleton tables’ are substituted by their explicit form (to a depth of 9). Also the way in which U searches for the next relevant instruction involves running from end to end of the tape too many times. Features of Turing’s scheme which greatly simplify the description also cause the explicit machine to have many symbols, a considerable number of states and instructions, and to be extremely slow. Turing would have said that this ineYciency was irrelevant to his purpose, which is true, but it does present a practical problem if one is interested in verifying an actual machine. Some fairly simple changes to the design reduce this problem. The Wnal part of this paper outlines a redesign of the universal machine which was tested by simulation and shown to work. There can be reasonable conWdence that there are no further signiWcant errors in Turing’s design, but a simulation starting directly from Turing’s ‘skeleton tables’ would clinch the matter.

By and large I use Turing’s notation and terminology in what follows. Where my notation diVers from Turing’s the aim has been to make matters clearer. In particular, Turing’s Gothic letters are replaced by roman letters. I sometimes introduce words from modern computer technology where this makes things clearer. (There is no special signiWcance to the use of boldface type—this is used simply for increased clarity.)

**2. The Turing Machine T**

Turing required a memory of unlimited extent and a means of access to that memory. Access by an address would not provide unlimited memory. In this respect the Turing machine goes beyond any existing real machine.

His method, of course, was to store data in the form of symbols written on a tape of unlimited length. SpeciWcally, the tape had a beginning, regarded as its left-hand end, marked with a pair of special symbols ‘e e’ that can easily be found. To the right of these symbols there are an unlimited number of symbolpositions or ‘squares’ which can be reached by right and left movements of the machine, shown as ‘R’ and ‘L’ respectively in the machine’s instructions. By repeated R and L movements any square can be accessed.

Let us consider how the machine’s instructions are composed. We are not concerned yet with U, the universal machine, but with a speciWc Turing machine T—the ‘target machine’—which will later be emulated by U.

An instruction for T consists of Wve parts. The purpose of the Wrst two parts is to address the instruction. These give the state of the machine (I shall call this M) and the symbol S that the machine is reading in the scanned square. This statesymbol pair M-S determines the next operation of the machine. Turing called M-S a ‘conWguration’. For each such pair that can occur (Wnitely many, since there is a Wnite number of states and of symbols), the next operation of the machine must be speciWed in the instructions, by notations in the remaining three parts. The Wrst of these is the new symbol to be written in place of the one that has been read, and I call this S0. Then there is an action A, which takes place after the writing of the new symbol, and this can be a right shift R, a left shift L, or N, meaning no movement. Finally the resultant state M0 is given in the last of the Wve parts of the instruction.

<!-- page 114 -->
To summarize: an instruction is of the form MSS0AM0. The current machine conWguration is the pair M-S, which selects an appropriate instruction. The instruction then speciWes S0, A, and M0, meaning that the symbol S0 is written in place of S. The machine then moves according to action A (R, L, or N) and Wnally enters a new state M0. A table of these instructions, each of Wve parts, speciWes the entire behaviour of the target machine T. The table should have instructions for all the M-S pairs that can arise during the operation of the machine.

There are some interesting special cases. One of the options is that S0 ¼ S, meaning that the symbol that was in the scanned square remains in place. In eVect, no writing has occurred. Another is that S0 ¼ blank, meaning that the symbol S which was read has been erased.

As a practical matter, note that the part of the tape which has been used is always Wnite and should have well-deWned ends, so that the machine will not run away down the tape. As already mentioned, Turing speciWes that at the left-hand end the pair of special symbols ‘e e’ is printed. These are never removed or altered. On the extreme right of the used part of the tape there must be a sequence of blank squares. Turing arranges that there will never be two adjacent blanks anywhere in the used part of the tape, so that the right-hand end of the used portion can always be found. This convention is necessary to make U work properly, as is explained in detail later. However, Turing does not necessarily follow this convention in specifying target machines T. This can result in misbehaviour.

The purpose of T is to perform a calculation, therefore T must generate numbers. For this reason the symbols it can print include 0 and 1, which are suYcient to specify a binary result. By convention these two symbols are never erased but remain on the tape as a record of the result of the computation. It happens that they are treated in a special way in the emulation by U, in order to make the result of the calculation more obvious, as I shall explain in due course.

**3. The Basic Plan of U**

The universal machine U must be provided with the table of instructions of the Turing machine T that it is to emulate. The instructions are given at the start of U’s tape, separated by semicolons ‘;’. At the end of these instructions is the symbol ‘::’ (which is a single symbol). Later I shall settle the question of whether a semicolon should be placed before the Wrst instruction or after the last one.

Following ‘::’ is the workspace, in which U must place a complete description, in U’s own symbols, of machine T. This description consists of all the symbols on T’s tape, the position of the machine on that tape, and the state of the machine. I call such a description an image or snapshot of machine T. As T goes through its computational motions, more and more snapshots are written in U’s workspace, so that an entire history of T gradually appears.

In order to make this evolving representation of T’s behaviour possible, U must not change any of the images on its tape. U simply adds each new image to the end of the tape as it computes it.

<!-- page 115 -->
The Wrst action of U is to construct the initial image of T, in the space immediately following the ‘::’ symbol which terminates the set of instructions. Subsequently, U writes new images of T, separated by colons ‘:’, each image representing a successive step in the evolution of T’s computation.

Whenever T is asked to print a 0 or 1, the image in which this happens is followed by the symbols ‘0 :’ or ‘1 :’ respectively. This serves to emphasize the results of the computation. For example, U’s tape might look like this, with the instruction set followed by successive images of T. The ‘output’ character 0 printed in image 3 is highlighted by printing it again after the image, and likewise in the case of the ‘output’ character 1 that is printed in image 5.

e e ; inst 1 ; inst 2 ; . . . inst n :: image 1 : image 2 : image 3 : 0 :

image 4 : image 5 : 1 : etc.

Note that each instruction begins with a semicolon. This diVers from Turing, who has the semicolon after each instruction, so that the instructions end with the pair of characters ‘; ::’. I found this departure from Turing’s presentation necessary, as I shall explain later.

The symbols on the tape up to and including the ‘::’—i.e. T’s instructions—are given to U before it starts operating. When U commences its operations, it writes out the Wrst image and then computes successive images from this, using the instructions, and intersperses the images with ‘outputs’ as required.

To complete this description of the basic plan of U I must specify how the symbols are spaced out in order to allow for marking them with other symbols. Looking in more detail at the start of the tape we would Wnd squares associated in pairs. The left square of each pair contains a symbol from the set:

A C D L R N 0 1 ; :: :

These symbols are never erased by U; they form a permanent record of the instructions and the images of T. Thus the Wrst few squares of a tape might contain these symbols representing an instruction, where ‘’ refers to the blank symbol, meaning an empty square:

e e D  A  D  D  C  R  D  A  A  ;  . . .

(1)

The blank squares leave room for symbols from the set u v w x y z, which are reserved for use as markers and serve to mark the symbol to their immediate left. For example, at one stage of the operation of U the parts of this instruction are marked out as follows:

e e D  A  D  D u C u R u D y A y A y ;  . . .

Here the ‘u’ and ‘y’ mark D C R and D A A respectively.

<!-- page 116 -->
Unlike the symbols A C D L R N 0 1 ; :: : which are never erased, the letters u v w x y z are always temporary markings and are erased when they have done their job.

The positions of the A C D L R N 0 1 ; :: : symbols will be called ‘non-erasing positions’. Note that the left hand ‘e’ occupies such a position also.

**4. Notation for States, Symbols, and Actions in U’s**

**Instructions and in Images of T**

The states, symbols, and actions which U represents on its tape are those of T, which U is emulating. We do not know how many states and symbols have to be emulated, yet the set of symbols of U is limited by its design. For economy in U’s symbols, the nth state of T is represented on U’s tape by DAA . . . A with n occurrences of letter ‘A’. The blank spaces between these letters are not shown here but are important for the operation of U and will always be assumed. The nth symbol of T is shown on U’s tape by the string DCC . . . C with n occurrences of letter ‘C’. It appears from an example in Turing’s text that D by itself (with a marking square to its right, as always) can be one of these ‘symbol images’. In fact I shall choose to make this the ‘blank’ symbol.

Read in accordance with these conventions, the symbols in example (1), above, form the instruction: ‘when in state 1—reading a blank—write symbol 0—move right—change to state 2’.

With the semicolons as spacers we now have a complete notation for instructions on U’s tape. Next we need a notation for an image of machine T, which is also made up from these state and symbol images, DAA . . . and DCC . . . respectively.

The keys to the next action of T are its present state and the symbol it is reading, which have been stored in the instruction table as the pair M-S. So this same combination is used in the image, by listing in correct sequence all the symbols on T’s tape and inserting the state image immediately in front of the symbol which machine T’s emulation is currently reading. The placing of the state image indicates which square is currently scanned. So a tape image might look like this:

symbol 1, symbol 2, symbol 3, state, symbol 4, symbol 5 :

<!-- page 117 -->
The current state is given at the position indicated. This emulated tape of T records that T is scanning symbol 4. The combination ‘state, symbol 4’ which appears in this string is the M-S pair that U must look up, by searching for it in the instruction table. To get the image of the next state of T, state and symbol 4 may have to be changed and the state image, also changed, may have to be moved to the right, or to the left, or not moved. These are the processes which occur in one step of evolution of the machine T. It will be done by building a completely new image to the right of the last ‘:’. (Consequently the tape space is rapidly used up.)

**5. Notation for Machine U**

In principle, machine U should be speciWed in the same formal notation as machine T, but this would be bulky and tedious to read and understand, so Turing used a much more Xexible notation. A compiler could be built to take the ‘higher-level’ notation of machine U’s speciWcation as given by Turing and generate the complete set of instructions for U.

The statements which make up Turing’s speciWcation of U are similar to procedures with parameters (more correctly they are like macros) and they have four parts. As with the instructions of T, a state and symbol select which statement is to apply, except that the symbol can now be a logical expression such as ‘not C’, which in the explicit speciWcation would require as many instructions as there are symbols other than ‘C’. There are also statements that copy symbols from one part of the (real) tape to another, and this requires one instruction for each allowed symbol variety. The actions, which in the explicit notation can only write a symbol and optionally move one place left or right, are expanded here to allow multiple operations such as ‘L, Pu, R, R, R’, specifying that symbol ‘u’ is being printed to the left of the starting point and the machine ends up two places to the right of that point. Turing requires that these speciWcations be ‘compiled’ into the standard Wve-part instructions. I will call these procedures ‘routines’. Their parameters are of two kinds, the states that the operations lead to, which are shown as capital letters, and symbol values, which are shown in lower case.

The speciWcation of machine U consists of a collection of ‘subroutines’ which are then used in a ‘program’ of nine routines that together perform the evolution of T. We shall Wrst describe the subroutines, then the main program.

**6. Subroutines**

In principle, the action of a routine depends on the position of the machine when the routine is invoked, i.e. the square on the tape which is being scanned. Also, the position of the scanned square at the end of a routine’s operation could be signiWcant for the next operation to come. But Turing’s design avoids too much interaction of this kind. It can be assumed that the positions are not signiWcant for the use of the subroutines in U unless the signiWcance is described here. Certain subroutines which are designed to Wnd a particular symbol on the tape (such as f(A, B, a) and q(A, a) and others) leave the machine in a signiWcant position. Con(A, a) has signiWcant starting and Wnishing positions.

<!-- page 118 -->
Where a routine uses other routines, these are listed (for convenience in tracing side-eVects). Also listed are those routines that use the routine in question. It would be possible to make several of the routines much more eYcient, greatly reducing the amount of machine movement, but I have not made such changes here. (For eYciency, routines could be tailored for each of their uses and states and symbols could easily be coded in binary. But this would be a redesign.)

f(A, B, a) The machine moves left until it Wnds the start of the tape at an ‘e’ symbol. Then it moves right, looking for a symbol ‘a’. If one is found it rests on that symbol and changes state to A. If there is no symbol ‘a’ on the whole tape it stops on the Wrst blank non-erasing square to the right of the used portion of tape, going into state B. In general terms, this routine is looking for the leftmost occurrence of the symbol ‘a’. The special case f(A, B, e) will Wnd the leftmost occurrence of ‘e’, which is in a non-erasing position. Uses no routines. Used by b, e(A, B, a), f0(A, B, a), cp(A, B, E, a, b), sh, and pe(A, b). f 0(A, B, a) As for f(A, B, a) except that if a symbol ‘a’ is found, the machine stops one square to the left, over the square which is marked by the ‘a’. Uses f(A, B, a) and 1(A). Used by cp(A, B, E, a, b), sim, and c(A, b, a).

1(A) Simply shifts one square to the left. Uses none. Used by f0(A, B, a), mk, and inst.

e(A) The marks are erased from all marked symbols, leaving the machine in state A. Uses none. Used by ov.

e(A, B, a) The machine Wnds the leftmost occurrence of symbol ‘a’, using routine f(A, B, a), then erases it, resting on the blank symbol and changing to state A. If there is no such symbol to erase, it stops on the non-erasing square to the right of the used portion of tape in state B, as for f(A, B, a). Uses f(A, B, a). Used by kmp, cpe(A, B, E, a, b), and e(B, a).

e(B, a) Erases all occurrences of the symbol ‘a’ on the tape, leaving the machine in state B. Uses e(A, B, a). Used by sim.

<!-- page 119 -->
pe(A, b) Prints the symbol ‘b’ in the Wrst blank non-erasing position at the end of the sequence of symbols. Uses f(A, B, a). Used by pe2(A, a, b) and c(A, B, a). pe2(A, a, b) Prints the symbol ‘a’ and then ‘b’ in the Wrst blank non-erasing positions. Uses pe(A, b). Used by sh.

q(A) Moves to the next non-erasing position after the used portion of tape and goes to state A. Uses none. Used by q(A, a).

q(A, a) Finds the last occurrence of symbol ‘a’ and stops there in state A. Uses q(A). Used by anf, mk, and inst. If the symbol does not exist, the machine will run oV the tape to the left. However, in its use in anf, mk, and inst, it will Wnd a colon or ‘u’ on which to stop.

c(A, B, a) Finds the leftmost symbol marked with ‘a’ and copies it at the end of the tape in the Wrst non-erasing square available, then goes to state A. If no symbol ‘a’ is found goes to state B. The symbols which this routine (and those that use it) will be required to copy are ‘D’, ‘C’, and ‘A’. This means that each invocation needs three diVerent states. Uses f0(A, B, a) and pe(A, b). Used by ce(A, B, a).

ce(A, B, a) Copies at the end of the tape in the Wrst non-erasing square the leftmost symbol marked by ‘a’, then goes to state A with the single (leftmost) marking ‘a’ erased. If there is no symbol ‘a’ on the tape, goes to state B. Uses c(A, B, a) and e(A, B, a). Used by ce(B, a).

ce(B, a) Copies in the correct sequence, at the end of the tape in non-erasing squares, all the symbols on the tape that are marked with ‘a’, at the same time erasing each ‘a’, and then goes to state B. If there are no symbols marked with ‘a’ it goes straight to B. Uses ce(A, B, a). Used by ce2(B, a, b), ce3(B, a, b, c), ce4(B, a, b, c,

d), and ce5(B, a, b, c, d, e).

<!-- page 120 -->
ce5(B, a, b, c, d, e) Copies in the sequence given, at the end of the tape in non-erasing squares, all the symbols marked with ‘a’, then those marked with ‘b’, then ‘c’, ‘d’, and ‘e’ in turn, ending in state B. Uses ce4(B, a, b, c, d) and ce(B, a) and ce4 uses ce3 which uses ce2 and all of these use ce(B, a). Only ce5(B, a, b, c, d, e) is used elsewhere, by inst. cp(A, B, E, a, b) Compares the leftmost symbols marked by ‘a’ and ‘b’. First it Wnds the symbol marked ‘a’, by using the routine f0(A, B, a). It enters a diVerent state cp2(A, B, x) according to the symbol ‘x’ it Wnds there. There are three possible symbols: ‘D’, ‘C’, and ‘A’. Then it Wnds the symbol marked ‘b’ in the same way. If they are the same, the resultant state is A, if not the state becomes B. If one of these marked symbols is found, but not the other, the outcome is state B. If neither is found, the outcome is E. Uses f(A, B, a) and f0(A, B, a). Used by cpe(A, B, E, a, b). (I have changed Turing’s state-symbol ‘U’ to ‘B’ to avoid confusion.)

cpe(A, B, E, a, b) Action as for cp(A, B, E, a, b) followed by, if the marked symbols are the same, the erasure of both the markings ‘a’ and ‘b’. Uses cp(A, B, E, a, b) and e(A, B, a). Used by cpe(B, E, a, b).

cpe(B, E, a, b) Comparison of two marked sequences. First it compares the leftmost symbols marked with ‘a’ and ‘b’. If they diVer the state B is reached and the process stops. If they are both absent, state E. Otherwise both marked symbols are erased and the process is repeated with the next leftmost marked symbols. So, if the whole sequence of symbols marked with ‘a’ equals the sequence marked with ‘b’ (or both are absent) the result is state E and all markings ‘a’ and ‘b’ have been removed. If the sequences diVer, state B is reached and some of the markings have been removed. Uses cpe(A, B, E, a, b). Used by kmp.

con(A, a) This routine’s action depends on where it starts on the tape. It leaves the machine in a signiWcant position after its action is completed. The purpose is to mark with symbol ‘a’ the M-S pair next on the right of the start position. The routine must start on a non-erasing square. It seeks a pattern such as:

D  A  A  . . . A  D  C  C  . . . C 

<!-- page 121 -->
and will replace all the blanks (or any other symbols in these places) by the symbol ‘a’. There may be as few as one ‘A’ after the Wrst ‘D’, representing the state, and optionally no ‘C’ following the second ‘D’, representing the symbol. The starting point can be on the Wrst ‘D’ of this pattern, or earlier if no other ‘A’ symbols intervene. For example, in an image there is only one state, so the Wrst ‘A’ symbol can be sought from anywhere to its left in the image string. The Wnal state is A and the position is two non-erasable squares to the right of the last marked symbol. (Turing refers to this as ‘the last square of C’ but his own example shows a symbol image with no Cs. Turing’s comment ‘C is left unmarked’ does not seem to make sense.) Uses none. Used by anf, kom, sim, and mk. The use of con(A, a) in sim and mk employs the Wnal position it reaches.

**7. Operation of the Universal Machine U**

The routines which comprise the operation of U are entered in succession, except for the process of searching for the relevant instruction, which has its own loop. The initial state of the machine is b, remembering that the instruction table for the Turing machine which U is emulating must already be on the tape. The starting position is immaterial.

b The beginning of U’s operation. It writes the symbols ‘: D A’ in the non-erasing squares after the symbol :: that signiWes the end of the instructions which are already on the tape. This is the image of the initial state of the emulated machine T and consists of the coding for ‘state 1’ with no following symbol images, meaning that the initial tape of T is blank.

This operation uses f(A, B, a).

anf Presumably this is from the German Anfang, or beginning. It is the start of the process of generating the next image of T. The process will return to anf when one new image has been appended on U’s tape, so that building of successive images continues. Its action is q(anf1, : ) which Wnds the last ‘:’ and then anf1 uses con(kom, y) to mark the last M-S pair on the tape with ‘y’ and go to state kom. Thus the machine state and scanned symbol of the last image on the tape have been marked. Initially this results in marking just the ‘D’ ‘A’, but there is an error in this design because absence of a symbol image means that con will fail, since it looks only for symbols ‘A’ or ‘D’ when in its internal state con1. This is easily corrected: see Section 8.

This operation uses con(A, a) and q(A, a).

<!-- page 122 -->
kom From its position in the image region, the machine moves left, looking for either ‘;’ or ‘z’. It will Wnd ‘;’ at the start of the last instruction, provided that the termination of the instruction area is shown as just ‘::’ and not ‘; ::’ (the latter is implied by Turing). Also, if all instructions are to be available, the Wrst instruction must begin with ‘;’. The correct designation of a single instruction should be ‘;’ followed by the Wve parts, and not as shown on p. 68 of Turing’s treatment. With these changes, kom will ignore any ‘;’ which is marked with ‘z’. ‘z’ signiWes that the instruction which follows has already been tried. The rightmost unmarked ‘;’ having been found, this symbol is marked with ‘z’ and the routine con(kmp, x) is used to mark the following M-S pair with ‘x’. Each time that kom is used, the next instruction to the left will be processed.

If no instruction matches the current state and symbol of T, meaning that the machine is badly deWned, the search for a colon will run oV the left end of the tape. This bug is Wxed in Section 9.

This operation uses con(A, a).

kmp The action of kmp is shown by Turing as cpe(e(kom, x, y), sim, x, y). This will compare the sequences marked by ‘x’ and ‘y’ to discover if the marked instruction actually applies to the M-S pair shown in the current image of T. If it does, the state becomes sim, which is the start of building the next image. If not, there is a problem with partial erasure of the markings, so these are erased by the e(kom, x, y) operation and we try again, this time trying the next instruction to the left of those tried so far, which have the ‘z ’ marking. However, there is a bug, explained and corrected in Section 8.

This operation uses cpe(B, E, a, b) and e(A, B, a).

sim This routine marks the parts of the leftmost instruction marked with ‘z’, which now applies to the next of T’s operations to be performed. The leftmost marked colon is located by f 0(sim1, sim1, z) and then sim1 is con(sim2, ), which marks the M-S pair with blanks, since this is not required again in this round. The routine con leaves the machine scanning the next non-erasing square to the right of the ‘D’ in the coding for the new symbol to be written by T. The ‘D’ is marked with ‘u’ as are any Cs which follow, so that the new symbol image is marked. The marking with ‘u’ continues, marking to the left of each square being examined until an ‘A’ is found, when the marking is changed to ‘y’. Consequently, both the new symbol image and the action (L, R, or N) have been marked with ‘u’ and the new state image has been marked with ‘y’, which continues until the ‘;’ or ‘::’ terminating the instruction has been reached. Then the ‘z’ markings are all removed, since the relevant parts of the instruction for the next stage of T’s operation have been marked. The line on p. 71 for state sim2 and symbol ‘not A’ has an error; see Section 10.

This operation uses e(B, a), con(A, a), and f 0(A, B, a).

<!-- page 123 -->
mk The last ‘:’ is found by means of an operation which should read q(mk1, :) (see Section 10). Moving right from there, the Wrst ‘A’ is found, which is at the start of the state image, then two non-erasable squares to the left of this point is the end of the preceding symbol image. The start of the whole image might have been found (‘:’), if this was the initial state, which Wnishes this part of the marking. If a ‘C’ is found, this is marked with ‘x’ and so are previous Cs moving backwards until a ‘D’ is found and marked. From this point backward, symbols in non-erasable squares are marked with ‘v’ until the ‘:’ that begins the image is found. In this way the symbol image preceding the one currently scanned (if any) has been marked with ‘x’ and all the earlier symbols in the image (if any) are marked with ‘v’.

In the second stage of marking, the con(A, a) routine is used to Wnd the M-S pair, marking it with a blank and ending two non-erasable squares beyond the last marked ‘D’ or ‘C’ of the symbol image. Two left shifts leave the machine at the start of the symbol image which immediately follows the scanned symbol. From there, all symbols are marked with ‘w’ until the end is reached and Wnally a ‘:’ is placed at the end of the old image, ready for copying out the new image later.

It may be useful to summarize the marking which is now ready for copying out the new image. The instruction has been marked with ‘u’ for both the new symbol and the action (R, L, or N) then with ‘y’ for the new state. The image has been marked in three places. Starting from the left, its symbol images are marked with ‘v’ until the one before the scanned symbol, which is marked with ‘x’. Then the state and symbol scanned, the current M-S pair, are unmarked, because they will be superseded. To the right of the scanned symbol, all symbol images are marked with ‘w’.

This operation uses con(A, a), 1(A), and q(A, ).

sh Before the copying of these marked regions to make a new image, the output of machine T is made visible on the tape. The part marked with ‘u’ begins with the new symbol (S’) to be written on T’s tape, which may be 0, coded as D C, or 1, coded as D C C. It is immediately preceded in the instruction by the old symbol that is being overwritten (S). The 0 or 1 is considered as being written if it replaces a space, which is coded as D, so sh looks for D–DuCu or D–DuCuCu, using the ‘u’ marking to locate this combination. According to which it Wnds, it writes either ‘:0’ or ‘:1’ at the end of the tape.

The convention that 0 or 1 is output if it replaces a space implies that the target machine T conforms to the same convention as U, which is not to overwrite most symbols, only treating special markers in this way. This is in fact an unnecessary restriction on the programming of T. The restriction means that U is not really universal. On the other hand, the use of 0 and 1 as special symbols indicating output goes beyond the fundamental deWnition of a Turing machine. We must assume that the sh operation is designed for use in the special case of a target Turing machine with output, the output action consisting of writing 0 or 1 in a square which previously held a space.

<!-- page 124 -->
This operation uses f(A, B, a) and pe2(A, a, b). inst This routine creates the new image of T’s machine and tape and writes it at the end of U’s tape, after the Wnal colon. The operation q(1(inst1), u) Wnds the last ‘u’ on the tape and the square that it marks, which contains L, R, or N. This single ‘u’ is deleted because the action symbol L, R, or N must not be copied into the new image. According to the action symbol found, the parts are assembled in one of these sequences, where the machine state ‘y’ is shown in bold.

R

v

x

u

y

w

N

v

x

y

u

w

L

v

y

x

u

w In each case the symbols preceding the active part are marked ‘v’ and are copied Wrst (they may not exist). The symbols following the previously scanned symbol are marked ‘w’ and are copied last. Without a movement of machine T, the new state, marked ‘y’, is followed by the new symbol, marked ‘u’; and the previous symbol, marked ‘x’, stays in its place. With left movement, the new state is placed before the previous symbol. With right movement, the new state is placed after the new symbol, marked ‘u’.

The tape image should always end with a ‘blank’ symbol, which is simply D. Any rewritten symbols within the used portion of T’s tape which are deleted will have been overwritten with ‘D’, but at the end, if the section marked with ws was empty, the action R may leave the state image at the end of the tape. This will cause a matching failure during the next cycle of the emulation if comparison occurs with the M-S pair of an instruction that has a symbol value of ‘blank’, represented by D. Repairs are made in Section 8.

This operation uses 1(A), q(A, a), f(A, B, a), and ce5(B, a, b, c, d, e). ov This Wnal operation e(anf) clears all markings and returns to anf to begin once again the process of generating a new tape image. Since the ‘z’ markings were cleared by sim and the ce5 operation clears all its markings, there seems no need for ov, but it does no harm.

This operation uses e(A).

**8. The Interesting Errors**

<!-- page 125 -->
The Wrst phase of an evolution of T is to Wnd the relevant instruction. This is done by marking the current state-symbol pair of Twith ‘y’ and the state-symbol pair of an instruction with ‘x’, then using the cpe operation to compare the marked strings. The process of cpe deletes some of the ‘x’ and ‘y’ markings. When comparison fails on one instruction the machine moves on to the next. This comparing process is shown in the table for U on p. 71 of Turing’s paper as

kmp

```prolog
cpe(e(kom, x, y), sim, x, y)
```

The e operation is intended to delete all the remaining ‘x’ and ‘y’ markings. In fact this is not quite how erasure works as deWned on p. 64 and the correct form would be e(e(kom, x), y). But there is a more serious error in returning to kom, since the essential ‘y’ marking will not be restored. Returning to anf will repair this error. The correct deWnition of kmp should be

kmp

```prolog
cpe(e(e(anf, x), y), sim, x, y)
```

To introduce the second of these interesting errors, it is instructive to look at the penultimate step in the copying out of the evolved new snapshot of T. This has been reduced, by Turing’s clever scheme of skeleton tables, to a choice of one of three copy instructions on p. 72, such as, for example

```prolog
inst1(R)
         ce5(ov, v, x, u, y, w)
```

This copies Wve marked areas from the current instruction and the last image of T in the sequence to create the new image, for the case where the machine moves right. The part marked ‘y’ is the new machine state, ‘v’ and ‘x’ form the string of T-symbols to the left, ‘u’ is the newly printed symbol, and ‘w’ the string of T-symbols to the right. Because ‘u’ replaces an existing symbol, the number of symbols (including blanks) on T’s conceptual tape has not changed! The same is true for left and null movement. There must be something wrong in an emulation in which the emulated machine can never change the number of symbols on its tape.

The image shows just the occupied part of T’s tape, and this is conceptually followed by an unlimited set of blank symbols, which are the tape as yet unused. The number of symbols in the image of T will increase by moving right from the last occupied square and writing on the blank square. After a move right onto blank tape, there will be no string marked ‘w’, so machine state ‘y’ will be the last thing in the image.

This will lead to a failure of the emulation at the next evolution because the state-symbol pair of the image, due to be marked with ‘y’ during the search for the relevant instruction, is incomplete.

The remedy is to print a new blank symbol for Tat the end of the image, when the move has been to the right and there is no T-symbol there. The necessary corrections, on p. 72, to the table for U are:

inst1 (R)

```prolog
                            ce5(q(inst2, A), v, x, u, y, w)
inst2
                    R, R
                             inst3
           n
inst3
             none
                    PD
                            ov
             D
                            ov
```

<!-- page 126 -->
In the case of a move right, after copying the parts of the previous image, the operation q Wnds the last ‘A’ on the tape, which is the end of the state-symbol copied from markings y. If there is a T-symbol to its right, there is no problem. After two right moves of U, if a ‘D’ is found there is a T-symbol but, if not, by printing ‘D’, a new blank tape square is added to the image of T. In this way T’s conceptual tape is extended and the state-symbol pair is made complete.

The error perhaps arose because the endless string of blank symbols on U’s tape was taken as suYcient for the purpose of T. But for the emulation a blank square is shown as D. Machines U and T represent a blank tape diVerently.

There is a corresponding error in the way the initial state of T is placed on U’s tape. It should contain the U-symbols: DAD with suitable spaces between them, representing T’s initial state DA followed by the scanned symbol D, a blank. The correction on p. 70 is:

b1

R, R, P:, R, R, PD, R, R, PA, R, R, PD

anf

**9. Diagnostics**

With experience of writing programs it is second nature to build in diagnostics. Whether they are needed in U is arguable. Since U is a conceptual tool, its requirements are determined by its use in the argument of Turing’s paper. For testing the design of U, diagnostics are certainly needed.

There may be a need for two kinds of failure indication in the program of U.

Suppose that T has a deWcient set of instructions, meaning that its latest image has a state-symbol pair which does not appear among the instructions. I believe that Turing would class this as a circular machine. The eVect on the operation of U is that the search for the relevant instruction fails with U moving left beyond the left-hand end of its tape, and continuing to move left indeWnitely. Perhaps this is acceptable for the purpose for which U was intended, but it seems anomalous that a deWciency in T should cause U to misbehave. It can be avoided by adding a line to the deWnition of kom on p. 71:

kom

e

fail1

(deficient T instructions)

then changing the next line to respond to symbols not z nor ; nor e.

If T moves right without limit, this will be emulated correctly, but moving left beyond the limits of its tape is a problem. The way U works will cause the next image of T to appear as if no shift had occurred. There is no way to represent Tas scanning a square to the left of its starting position. This means that the subsequent behaviour of T will diVer from what its instructions imply. I think this might aVect the use that Turing made of the machine in the main part of the paper.

The changes to deal with this problem are:

```prolog
inst1(L)
           f(inst4, fail2, x)
```

(machine T has run off left)

inst4

```prolog
ce5(ov, v, y, x, u, w)
```

<!-- page 127 -->
**10. Trivial Errors and Corrections**

1. There is potential confusion in the use of the symbol q for diVerent states in two places, and it is also confused with state g. The best resolution is as follows.

We can treat the use of q in the example on p. 62 as casual, without permanent signiWcance. The same might be said of its use on p. 64, which is unrelated. But from there onwards the examples will form part of the deWnition of U, so the symbols have global signiWcance.

On p. 66, the states q and q1 appear but, in their subsequent uses in U, they have been replaced by g, for example in the deWnitions of anf, mk, and inst. I have retained the notation q, while remembering that previous uses of this symbol are unrelated.

2. The skeleton tables for re and cr on p. 65, which comprise Wve diVerent states, are redundant, serving no illustrative purpose and not being used again.

3. On p. 68, the format of the instruction table of T, as written on the tape of U, is described. Instructions are separated by semicolons. An example DADDCRDDA;DAA . . . DDRDA; is given. As already explained, this is misleading, because each instruction should be preceded by a semicolon. The example should begin with a semicolon, not end with one.

4. In the explanation of the skeleton table for con (p. 70), ‘C’ is one of the symbols being read and marked. But the words refer to ‘the sequence C of symbols describing a conWguration’. The Wnal remarks ‘. . . to the right of the last square of C. C is left unmarked.’ use ‘C’ in the second sense. It would otherwise seem as if the Wnal symbol ‘C’ was left unmarked, but this is not so. To clarify, replace by ‘the sequence S’ and ‘. . . last square of S. ConWguration S is left unmarked.’

5. On p. 71, a line for sim2 should read:

sim2

not A

L, Pu, R, R, R

sim2

6. On p. 71, the line for mk should read:

mk

```prolog
q(mk1, :)
```

7. On p. 72, the line for inst1(N) should read:

```prolog
inst1(N)
                 ce5(ov, v, x, y, u, w)
```

**11. A Redesign of the Universal Machine**

<!-- page 128 -->
To verify, as far as this is possible, that there are no remaining errors in the amended version of Turing’s program for U, it would be best to generate the explicit machine instruction table by substitutions and repetitions, then run this machine with one or more examples of a machine T and Wnd if the emulations behaved as they should. But the complexity and slowness of the explicit form of Turing’s U makes this diYcult.

Therefore I made some changes to the design of U before constructing a simulation of a Turing machine, loading the instructions for U, producing a tape image for a machine T and running the program. After some corrections to my version of U, the simulation behaved correctly. In this section the main features of the redesign are described.

The new version of U follows Turing’s methods quite closely. The substitution process introduced with the skeleton tables had been nested to a depth of 9, causing a proliferation of states and instructions in the explicit machine. To avoid this, no skeleton tables were used in the new version and this allowed the procedures to be optimized for each application. The downside is that the ‘lowlevel’ description of U which results takes up more space than the original and is harder to understand and check for accuracy. There are 147 states and 295 instructions in the new version, an enormous reduction.

The representation of T’s states and symbols in a monadic notation such as DAAAA was replaced by a binary notation. This was an easy change that reduced the length of the workspace used. Because nearly all the time is used moving from end to end of the workspace, this is worthwhile. The small cost of the change is that there are four U-symbols to represent states and symbols instead of three.

The classic Turing machine can move right or left or stay put in each operation. To simplify U a little, the third option was removed, so that a left or right movement became mandatory. For consistency, U was also run on a machine T with this characteristic. In the whole of U’s program, a compensating movement became necessary only a few times, so it is not a signiWcant restriction.

Turing’s skeleton tables show, for the scanned symbol, such words as any, or not A. When translated into a list of discrete symbols for the explicit machine these generate many instructions. By introducing a ‘wild card’ notation and searching instructions in a deWnite sequence, this proliferation can be avoided. A form of instruction was added which, in its written form, had an asterisk for both the scanned symbol and the written symbol. This acted on any scanned symbol and did not overwrite it. The way that U worked would have made it possible to read a wild card (i.e. any) scanned symbol and write over it or to read a speciWc symbol and leave it unchanged, but these were never needed in practice. The wild card scanned symbol should only be actioned after all other possibilities (for this particular state) have been tested. Therefore instructions now have a deWned sequence and must be tested accordingly. U always did test instructions in sequence but never made use of that fact.

<!-- page 129 -->
Testing all instructions in sequence to Wnd a match is very time-consuming because it requires marking, then comparing square by square, running from instruction space to work space. It was largely avoided by writing in U’s instruction table an oVset which indicated where the next instruction could be found. This indication led to a section of instructions dealing with a given state; after this, sequential testing took place. This was a shortcut to speed up U and was not envisaged as a feature of all Turing machines, since it would greatly complicate U. Technically it was a little more complex than I have described, but it has no eVect on the design of U, being merely a chore for the programmer and a detail of the computer program which interprets those instructions.

U spends some of its time searching for a region on the tape where it will begin work. To make this easier, additional markers were introduced, for the action symbol (L or R) and for the start of the current snapshot. Also, the end of the workspace was marked, and this marking was placed in one of the squares normally reserved for permanent symbols. Since it had to be overwritten when the workspace extended, this broke one of Turing’s conventions.

Finally the two failure-indications described earlier were incorporated, one for a deWcient T-instruction set and the other for T running its machine left, beyond the usable tape.

11.1 Testing the redesigned machine A computer program, which I shall call T, was written which would simulate the underlying Turing machine, using a set of instructions in its own special code, which had one byte per symbol or state. This code was chosen for convenience of writing U’s instructions. It incorporated the wild card feature and the oVset associated with each instruction, but the oVset did not alter the way it responded to its instructions, only making it faster. When the design of U is complete and its instructions have been loaded, T will behave as the universal machine U.

A simple editor was written to help the user write and amend the instruction tables for T and prepare a starting tape for T which holds the coded instructions for the emulated Turing machine T.

For T, the example given by Turing on p. 62 was used. It prints a sequence of increasing strings of ones, such as 001011011101111011111 . . . This program in its explicit form would have 23 instructions and 18 states. To make it simpler, it was rewritten without the ‘alternate squares’ principle and it then had 12 instructions and 6 states. It may be interesting to see how the wild card feature operates by studying this example, shown below.

As a Wrst step, the example was loaded into the program space of T and run, thus testing the mechanism of T as well as the example in the table below.

<!-- page 130 -->
Then the example was coded for the initial part of the tape of T, so that it would cause U to emulate it as the target T. The program of U was loaded in many stages, debugging each by testing its part in the whole operation of U. Two serious program errors were found. One was in the operation sh which prints the output of T between the snapshots of T’s evolution. The other was in the correction to Turing’s scheme which wrote a blank symbol (D) at the end of the tape. It had been inserted at the wrong place. With these and several minor errors corrected the redesigned U performed as expected and the evolution of T agreed with expectation and with its earlier running, directly on T. Only this one example of T was tried, but it probably does test the universal machine fully. The full results are given below.

Because of the diVerences between the version of U that was tested and Turing’s design with my corrections, the testing must be regarded as incomplete. A compiler could be written to take the design in the form of skeleton tables and generate the explicit machine, which could then be run to emulate examples of the target machine. This would be extraordinarily slow.

**12. The Program for T**

The instructions for T are given in the standard Wve-part form: state, scanned symbol, written symbol, movement, and resultant state. The images are shown for the Wrst eleven moves, in the standard form with the state-symbol (a to e, printed bold) preceding the scanned symbol.

The blank space symbol is a hyphen and the other symbols are 0, 1, x, and y.

The program writes a block of xs followed by a y, then converts the xs successively to 1s and the y to a 0, while writing the next block of xs and a y, increasing the number of xs by one.

s



0

R

a

print 0

: 0 a 

a



y

R

b

print y at end

: 0 y b 

: 0 0 x a  a

*

*

R

a

: 0 0 x y b 

b



x

L

c

print x at end

: 0 c y x

: 0 0 x c y x b

*

*

R

b

c

y

y

L

d

run back to y

: d 0 y x

: 0 0 d x y x c

*

*

L

c

d

x

1

R

b

change x to 1

: 0 0 1 b y x d

0

0

R

e

none left

: 0 e y x d

*

*

L

d

e

y

0

R

a

change y to 0

: 0 0 a x e

*

*

R

e

**13. Results of the Test**

<!-- page 131 -->
Here is a copy of the symbols on the tape of T after 22 evolutions of U. The part up to the symbol % represents the 12 instructions for T. Then follow the 23 images, separated by colons. Whenever U prints a 0 or 1, this is also an output of T. To make this explicit (following Turing’s practice) the strings ‘1 :’ or ‘0 :’ are inserted into the tape (bold in our table). So the whole set of evolutions shown has printed ‘0 0 1 0’. The tape shown is printed on alternate spaces, except for the initial ‘e e’. The Wnal F is a device of my own to make it easy to Wnd the end of the written area of tape.

e e; M C S S C R M D ; M D S S C D R M C C ; M D S E S E R M D ; M C C S S C C L M C D ; M C C S E S E R M C C ; M C D S C D S C D L M D C ; M C D S E S E L M C D ; M D C S C C S D R M C C ; M D C S C S C R M D D ; M D C S E S E L M D C ; M D D S C D S C R M D ; M D D S E S E R M D D % : M C S : 0 : S C M D S : S C S C D M C C S : S C M C D S C D S C C : M D C S C S C D S C C : S C M D D S C D S C C : 0 : S C S C M D S C C : S C S C S C C M D S : S C S C S C C S C D M C C S : S C S C S C C M C D S C D S C C : S C S C M D C S C C S C D S C C : 1 : S C S C S D M C C S C D S C C : S C S C S D S C D M C C S C C : S C S C S D S C D S C C M C C S : S C S C S D S C D M C D S C C S C C : S C S C S D M C D S C D S C C S C C : S C S C M D C S D S C D S C C S C C : S C M D C S C S D S C D S C C S C C : S C S C M D D S D S C D S C C S C C : S C S C S D M D D S C D S C C S C C : 0 : S C S C S D S C M D S C C S C C : S C S C S D S C S C C M D S C C : S C S C S D S C S C C S C C M D S F

As an aid to understanding this tape, here are the symbols and states of T in U’s notation:

- S

s

MC 0

SC

a

MD 1

SD

b

MCC x

SCC

c

MCD y

SCD

d

MDC *

SE

e

MDD The Wrst few snapshots therefore read: s  : 0 : 0 a  : 0 y b  : 0 c y x : d 0 y x : 0 e y x : 0 : 0 0 a x : 0 0 a x  : 0 0 x y b  : 0 0 x c y x : 0 0 d x y x : 1 : 0 0 1 b y x : 0 0 1 y b x : 0 0 1 y x b  : 0 0 1 y c x x : 0 0 1 c y x x : The Wnal conWguration of the above tape is 0 0 1 0 x x a  :

**14. The Corrected Tables for U: Summary**

The table for f(A, B, a) is unchanged on p. 63.

<!-- page 132 -->
On p. 64, e(A, B, a) and e(B, a) are unchanged, but note that the state q used in the explanation of e(B, a) is a local notation, unrelated to the states of that name on p. 66.

On p. 65, pe(A, b), l(A), f0(A, B, a), and c(A, B, a) are unchanged, but r(A) and f00(A, B, a), deWned on that page, are not used again.

On pp. 65–66, ce(A, B, a), ce(B, a), cp(A, B, C, a, b), cpe(A, B, C, a, b), and cpe(A, B, a, b) are unchanged but re(A, B, a, b), re(B, a, b), cr(A, B, a), and cr(B, a) are not used again.

On p. 66, q(A), pe2(A, a, b), and e(A) are unchanged. Also, ce2(B, a, b) and ce3(B, a, b, c) are deWned, but it is ce5(B, a, b, c, d, e), derived in an analogous way, which is actually used, in the inst function.

On p. 70, con(A, a) is unchanged, but the remark that ‘C is left unmarked’ is confusing and is best ignored.

In the table for U, which begins on p. 70, the state b1 should have the following action: R, R, P :, R, R, PD, R, R, PA, R, R, PD, in order to print ‘: D A D’ on the F squares, so that a blank symbol D is available for matching with an instruction.

On p. 70 the table for anf should lead to q(anf1, : ).

If the set of instructions for the target machine T is deWcient, so that a state-symbol pair is created which has no matching instruction, machine U will attempt to search beyond the left-hand end of its tape. What happens then is undeWned. To make it deWnite, kom (p. 71) can be augmented by the line:

kom

e

fail1, which indicates the failure, and the last line will be:

kom

not z nor ; nor e

kom

The table for kmp (p. 71) should read:

kmp

```prolog
cpe(e(e(anf, x), y), sim, x, y),
```

since e(A, B, a) should return to anf, to restore the markings deleted by cpe.

On p. 71, sim2 with scanned symbol ‘not A’should have the action L, Pu, R, R, R.

The Wrst line of mk (p. 71) should lead to q(mk1, : ). On this same page, sh is unchanged.

On p. 72, inst should lead to q(l(inst1), u) and the line for inst1(N) should read

inst1(N)

```prolog
ce5(ov, v, x, y, u, w)
```

The instruction for inst1(L) (p. 72) could try to move the target machine left beyond its end of tape, but there is no way for U to represent this condition, so T will seem not to move. To make this kind of error explicit, these changes can be made:

inst1(L)

```prolog
f(inst4, fail2, x)
```

<!-- page 133 -->
inst4 ce5(ov, v, y, x, u, w) To correct the fundamental Xaw that a right movement inst1(R) (p. 72) could move the state-symbol to the right of all other symbols, making a future match with an instruction impossible, the following change is needed:

inst1 (R) ce5(q(inst2, A), v, x, u, y, w) Wnds the last A on the tape inst2 R, R inst3 move to start of scanned symbol inst3 none PD ov D ov n if blank space, print D but not if a symbol follows

Finally, ov (p. 72) is unchanged.
