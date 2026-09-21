# Preface to the Fifth Edition

<!-- page 5 -->
Since the previous edition of *Programming in Prolog,* the Prolog language has been standardised by the International Organization for Standardization (ISO). Although not all Prolog systems conform to the new standard, we felt it was necessary to take the opportunity to update this book in accordance with the standard. We have also introduced some new material, clarified some explanations, corrected a number of minor errors, and removed appendices about Prolog systems that are now obsolete.

This book can serve several purposes. The aim of this book is not to teach the art of programming as such. We feel that programming cannot be learned simply by reading a book or by listening to a lecturer. You've got to do programming to learn it. We hope that beginners without a mathematical background can learn Prolog from this book, although in this case we would recommend that the beginner is taught by a programmer who knows Prolog, as part of a course that introduces the student to programming as such. It is assumed that beginners can obtain the use of a computer that has a Prolog system installed, and that they have been instructed in the use of the computer. Experienced programmers should not require extra assistance, but we hope they will not be dismayed at our intention to restrain mathematical elaboration.

In our experience, novice programmers find that Prolog programs seem to be more comprehensible than equivalent programs in conventional languages. However, the same people tend not to appreciate the limitations that conventional languages place on their use of computing resources. On the other hand, programmers experienced in conventional languages are better prepared to deal with abstract concepts such as variables and control flow. But, in spite of this prior experience, they may find Prolog difficult to adapt to, and they may need a lot of convincing before they consider Prolog a useful programming tool. Of course, we know of many highly experienced programmers who have taken up Prolog with much enthusiasm. However, the aim of this book is not to convert, but to teach.

<!-- page 6 -->
*Programming in Prolog* can be a useful companion to two other books. The beginner might use *Programming in Prolog* as a tutorial preliminary to the more concise and advanced text *Clause and Effect.*

The more experienced programmer might start with *Clause and Effect*

and be writing useful programs within a few hours, returning to *Programming in Prolog* to fill in any gaps in understanding. *Clause and* *Effect*

also conforms to ISO Standard Prolog, and it may be beneficial to use the reference manual *Prolog: The Standard* in conjunction with this book. Details of these books are:

*Clause and Effect,*

by W.F. Clocksin.

Springer-Verlag, 1997. ISBN 3-540-62971-8.

*Prolog: The Standard,* by P. Deransart, A. Ed-Dbali, and L. Cervoni.

Springer-Verlag, 1996. ISBN 3-540-59304-7.

Provided that the reader is equipped with a Prolog implementation that conforms to the ISO standard, the book *Prolog: The Standard* almost obviates the need for an implementation-specific reference manual, although the latter would be useful for documenting implementation-defined parameters and limits.

Like most other programming languages, Prolog exists in a number of different implementations, each with its own semantic and syntactic peculiarities. In this book we have adopted a core Prolog based on ISO Standard Prolog. Previous editions conformed to a de facto standard that became known as Edinburgh Prolog. In turn, Edinburgh Prolog was the main influence on the specification of ISO Standard Prolog. The table shown below summarises the main changes that have been made in the use of particular syntactic forms, special atoms and built-in predicates since earlier versions of this book in order to conform to the Standard or otherwise reflect more recent practice. Most of the differences between the Edinburgh and ISO core versions are of a purely cosmetic nature, though ISO Standard Prolog has gone in new directions in the way that input/output is handled.

This book was designed to be read sequentially, although it will prove helpful to read Chap. 8 when the reader begins to write Prolog programs consisting of more than about ten clauses. It shouldn't hurt to browse through the book, but do take care not to skip over the earlier chapters.

<!-- page 7 -->
Each chapter is divided into several sections, and we advise the reader to attempt the exercises that are at the end of many sections. The solutions to some of the exercises appear at the end of the book. Chapter 1 is a tutorial introduction that is intended to give the reader a feel for what is required to program in Prolog. The fundamental ideas of Prolog are introduced, and the reader is advised to study them carefully. Chapter 2 presents a more complete discussion of points that are introduced in Chapter 1. Chapter 3 deals with data structures and derives some small example programs. Chapter 4 treats the subject of backtracking in more detail, and introduces the cut symbol, which is used to control backtracking. Chapter 5 intro-

*Edinburgh Editions*

*ISO Edition*

"..." (string) notation

Not used (can mean different things)

ASCII codes for characters

Single element atoms as characters

get, getO, put

get_char, put_char

see, seeing, seen

open, setjnput, currentjnput

tell, telling, told

open, set_output, current_output

user

userjnput and user_output

integer

number (floating-point numbers are handled)

reconsult

consult (though not in the Standard)

not

**V**

tab, skip

not used

display

write_canonical

assert

asserta, assertz

/ arithmetic operator

/ and / / operators

name

atom_chars, number_chars

@<, @=< etc. introduced

=:= and =\= introduced

Table of differences between previous editions, which used the Edinburgh Prolog standard, and the present edition, which uses the ISO standard.

duces the facilities that are available for input and output. Chapter 6 describes each built-in predicate in the standard core of Prolog. Chapter 7 is a potpourri of example programs collected from many sources, together with an explanation of how they are written. Chapter 8 offers some advice on debugging Prolog programs. Chapter 9 introduces the Grammar Rule syntax, and examines the design decisions for some aspects of analysing natural language by using Grammar Rules. Chapter 10 describes the relation of Prolog to its origins in mathematical theorem proving and logic programming. Chapter 11 specifies a number of projects on which interested readers may wish to practise their programming ability. During the past twenty years that previous editions of this book have been in use, individuals too numerous to list by name have given us help, support, encouragement, suggestions, and comments about this book. We are grateful to our readers, students, teachers, colleagues, correspondents, editors, friends and family who have contributed in various and manifold ways. Of course, responsibility for the errors and omissions that remain in this edition rests entirely with us.

*William Clocksin* Oxford and Edinburgh June 2003

*Chris Mellish*
