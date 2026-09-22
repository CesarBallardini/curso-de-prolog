<!-- page 1 -->
**Artificial Intelligence through Prolog by Neil C. Rowe**

Title

Artificial Intelligence through Prolog by Neil C. Rowe

Item Type

Book

Authors

Rowe, Neil C.

URI

https://hdl.handle.net/10945/36984

Publisher

Prentice-Hall

Date Issued

1988

Download date

2026-09-20 19:16:07

Link to Item

https://hdl.handle.net/10945/36984

<!-- page 2 -->
Downloaded from NPS Archive: Calhoun

10/15/13 11:27 AM

Errata for Neil Rowe, Artificial Intelligence Through Prolog February 24, 1989 Please send any other errata you find to the author at code CS/Rp, Naval Postgraduate School, Monterey CA 93943; or send email to rowe@cs.nps.navy.mil.

(* = Prentice-Hall not yet informed)

*Errata for book itself:*

Page xvi, end of last sentence: change "nps-cs.arpa" to "cs.nps.navy.mil".

Page 12, second paragraph of section 2.7: change "circle" to "oval" everywhere it occurs.

Page 13, 5th line from bottom: replace "Here 'to be' is used" with "Here forms of the verb "to be" are used"

Page 31, figure 3-3: arrow missing from "X = tom, Y = dick" to "Z = harry"

Page 44, 19th line: change "part_of" to "a_kind_of" so the whole line should read "color_enterprise(C) :a_kind_of(enterprise,X), color(X,C)."

Page 77, first line: change "1" (numeral one) to "0" (numeral zero).

Page 87, section 5.7, sixth line: change the second right bracket to a right parenthesis, so it reads:

```prolog
subset([X|L1],L2) :- member(X,L2), subset(L1,L2).
```

Page 103, seventh and sixth lines from the end of section 6.2: change "old" to "new", and change "new" to "old" in the sentence "It is redundant if the old rule always succeeds whenever the new rule succeeds."

Page 105, figure 6-2, step 7, end of line: replace "c." with "c(2)." (note the period must remain on the end)

(*) Page 107, Figure 6-4: "R6" column should read top to bottom in order: "fails, -, -, -, -" rather than "fails, fails, fails, fails, -".

Page 129, 7th line from bottom: insert an apostrophe just before "Are"

Page 132, 3rd line, fourth word: "emdry" should be just "dry"

(*) Page 140, insert before 9th line sentence beginning "When forward chaining..." : "This program does not delete redundant rules like the algorithm in section 6.2."

(*) Page 149, indented material starting "forward :- done.": replace all but the first three lines, by the following:

```prolog
pursuit(F) :- rules(F,Rlist), append(RlistF,[[L,R]|RlistB],Rlist),
rule_pursuit(F,L,R,RlistF,RlistB).
rule_pursuit(F,L,R,RlistF,RlistB) :- member(F,R), delete(F,R,Rnew),
retract(rules(F,Oldrules)), append(RlistF,RlistB,NewRlist),
new_rule(F,L,Rnew,NewRlist).
                                                                                                          Page 1 of 3
```

<!-- page 3 -->
http://faculty.nps.edu/ncrowe/book/errata.html

10/15/13 11:27 AM

```prolog
new_rule(F,L,[],Rlist) :- asserta(rules(F,Rlist)), not(fact(L)),
asserta(fact(L)).
new_rule(F,L,R,Rlist) :- not(empty_list(R)), asserta(rules(F,[[L,R]|Rlist])).
empty_list([]).
append([],L,L).
append([X|L],L2,[X|L3]) :- append(L,L2,L3).
```

Page 188, 6th line from bottom: "battery" should be "lottery"

Page 196, Figure 9-3: the "remove screws" in the lower left should be "remove cables"

(*) Page 203, 19th line from bottom: change "certain" to "restricted"

Page 203, 11th line from bottom: change "A to S" to "S to A"

Page 203, 11th line from bottom: change "3" in "A to 3" to "A to E"

Page 221, second of the three groups of three indented lines: in all three cases the period must occur after the right parentheses, not before it; in the hyphen in "data-point" should be an underscore symbol.

(*) Page 265, Figure 11-1, 5th column of table: delete "?" after "visit"

Page 277, Figure 11-7, "Level 2" box on left, sixth line: delete right bracket on the end, just after the comma

Page 289, Figure 12-1: the "frame_name: memos to Ann" box should have a separate line with an arrow on it going to the box labeled "frame_name: memo", and this arrow cannot be combined with the one from frame_name: budget memos" to "frame_name: memo", which must have its own line with an arrow on it.

Page 321, line 14: insert "P and" before "all the expressions to the left".

Page 362, Figure 14-4: the small upper center triangle-like region that is cross-hatched should not be; it should be just have lines crossing it northwest to southeast, like the region to the left of it.

Page 363, problem 14-8: in fourth line, put parentheses around X and 1; in sixth line, put parentheses around N. In all cases, no space after the "p".

Page 383, 12th line from the bottom: delete "the" from "an included variable X, then that the expression".

Page 388, item 6, second line: delete "unbound" (so same word won't occur twice in succession)

Page 390, sixth line from the bottom: change "*lattice* or *directed acycylic graph*" to "*directed acyclic graph* and usually also a *lattice*".

Page 407, problem 2-6, 10th line: ship should be ship_info

Page 409, fifth line: the "4-5" is on the wrong line: it should be on the left side of the sixth line in front of the word "No". The rest of the fifth line is correct, however; the "(b)" should be the first thing on the line.

Page 409, problem 4-7, part (e), second line: change "Dick" to "Sue"

<!-- page 4 -->
Page 2 of 3 http://faculty.nps.edu/ncrowe/book/errata.html

10/15/13 11:27 AM

Page 415, 10th line of text from bottom: "L" should be "Z", so the line should read "?- mystery([a,b,c,d],Z)." now.

Page 416, problem 5-22, 6th line: change "not(member(X,L),L)" to "not(member(X,L))".

Page 417, problem 6-1(a), 6th and 7th line from top: change the sentence "This in turn matches an expression in R2." to "This doesn't match anything (R2 is being ignored)."

Page 417, problem 6-5(b), item "1": replace by: "1. The first and third rules fail because they mention at least one thing that doesn't match a fact, and the second rule is skipped."

Page 418, problem 6-5(b), item "5": replace by: "5. The first rule again fails, and the second rule is again skipped."

*Errata for Instructors' Manual*

Page 22: Add another arrow from "C" circle to the left side of the left most "R" box.

Page 26: The "part_of" arrows are backwards.

Page 96, line 3: delete duplicate "extra"

Page 96, line 9: change "rule" to "ruling"

Page 103: The point at (.3, .8) should be at (.2, .8).

Page 110: This figure is for Problem 12-7.

Go to book index

Page 3 of 3 http://faculty.nps.edu/ncrowe/book/errata.html

