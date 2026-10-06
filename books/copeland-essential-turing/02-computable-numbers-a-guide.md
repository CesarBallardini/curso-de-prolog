# Computable Numbers: A Guide

<!-- page 14 -->
**Jack Copeland**

Part I The Computer

1. Turing Machines

2. Standard Descriptions and Description Numbers 10

3. Subroutines

4. The Universal Computing Machine

5. Turing, von Neumann, and the Computer

6. Turing and Babbage

7. Origins of the Term ‘Computer Programme’

Part II Computability and Uncomputability

8. Circular and Circle-Free Machines

9. Computable and Uncomputable Sequences

10. Computable and Uncomputable Numbers

11. The Satisfactoriness Problem

12. The Printing and Halting Problems

13. The Church-Turing Thesis

14. The Entscheidungsproblem

‘On Computable Numbers, with an Application to the Entscheidungsproblem’ appeared in the Proceedings of the London Mathematical Society in 1936.1 This,

1 Proceedings of the London Mathematical Society, 42 (1936–7), 230–65. The publication date of ‘On Computable Numbers’ is sometimes cited, incorrectly, as 1937. The article was published in two parts, both parts appearing in 1936. The break between the two parts occurred, rather inelegantly, in the middle of Section 5, at the bottom of p. 240 (p. 67 in the present volume). Pages 230–40 appeared in part 3 of volume 42, issued on 30 Nov. 1936, and the remainder of the article appeared in part 4, issued on 23 Dec. 1936. This information is given on the title pages of parts 3 and 4 of volume 42, which show the contents of each part and their dates of issue. (I am grateful to Robert Soare for sending me these pages. See R. I. Soare, ‘Computability and Recursion’, Bulletin of Symbolic Logic, 2 (1996), 284–321.)

<!-- page 15 -->
The article was published bearing the information ‘Received 28 May, 1936.—Read 12 November, 1936.’ However, Turing was in the United States on 12 November, having left England in September 1936 for what was to be a stay of almost two years (see the introductions to Chapters 3 and 4). Although papers were read at the meetings of the London Mathematical Society, many of those published in the Proceedings were ‘taken as read’, the author not necessarily being present at the meeting in question. Mysteriously, the minutes of the meeting held on 18 June 1936 list ‘On Computable Numbers, with an Application to the Entscheidungsproblem’ as one of 22 papers taken as read at that meeting. The minutes of an Annual General Meeting held Turing’s second publication,2 contains his most signiWcant work. Here he pioneered the theory of computation, introducing the famous abstract computing machines soon dubbed ‘Turing machines’ by the American logician Alonzo Church.3 ‘On Computable Numbers’ is regarded as the founding publication of the modern science of computing. It contributed vital ideas to the development, in the 1940s, of the electronic stored-programme digital computer. ‘On Computable Numbers’ is the birthplace of the fundamental principle of the modern computer, the idea of controlling the machine’s operations by means of a programme of coded instructions stored in the computer’s memory.

In addition Turing charted areas of mathematics lying beyond the scope of the Turing machine. He proved that not all precisely stated mathematical problems can be solved by computing machines. One such is the Entscheidungsproblem or ‘decision problem’. This work—together with contemporaneous work by Church4 —initiated the important branch of mathematical logic that investigates and codiWes problems ‘too hard’ to be solvable by Turing machine.

In this one article, Turing ushered in both the modern computer and the mathematical study of the uncomputable.

**Part I The Computer**

**1. Turing Machines**

A Turing machine consists of a scanner and a limitless memory-tape that moves back and forth past the scanner. The tape is divided into squares. Each square may be blank or may bear a single symbol—‘0’ or ‘1’, for example, or some other symbol taken from a Wnite alphabet. The scanner is able to examine only one square of tape at a time (the ‘scanned square’).

The scanner contains mechanisms that enable it to erase the symbol on the scanned square, to print a symbol on the scanned square, and to move the tape to the left or right, one square at a time.

In addition to the operations just mentioned, the scanner is able to alter what Turing calls its ‘m-conWguration’. In modern Turing-machine jargon it is usual to

on 12 Nov. 1936 contain no reference to the paper. (I am grateful to Janet Foster, Archives Consultant to the London Mathematical Society, for information.)

2 The Wrst was ‘Equivalence of Left and Right Almost Periodicity’, Journal of the London Mathematical Society, 10 (1935), 284–5.

3 Church introduced the term ‘Turing machine’ in a review of Turing’s paper in the Journal of Symbolic Logic, 2 (1937), 42–3.

<!-- page 16 -->
4 A. Church, ‘An Unsolvable Problem of Elementary Number Theory’, American Journal of Mathematics, 58 (1936), 345–63, and ‘A Note on the Entscheidungsproblem’, Journal of Symbolic Logic, 1 (1936), 40–1.

**0**

**0**

**1**

**0**

**0**

**1**

SCANNER

use the term ‘state’ in place of ‘m-conWguration’. A device within the scanner is capable of adopting a number of diVerent states (m-conWgurations), and the scanner is able to alter the state of this device whenever necessary. The device may be conceptualized as consisting of a dial with a (Wnite) number of positions, labelled ‘a’, ‘b’, ‘c’, etc. Each of these positions counts as an m-conWguration or state, and changing the m-conWguration or state amounts to shifting the dial’s pointer from one labelled position to another. This device functions as a simple memory. As Turing says, ‘by altering its m-conWguration the machine can eVectively remember some of the symbols which it has ‘‘seen’’ (scanned) previously’ (p. 59). For example, a dial with two positions can be used to keep a record of which binary digit, 0 or 1, is present on the square that the scanner has just vacated. (If a square might also be blank, then a dial with three positions is required.)

The operations just described—erase, print, move, and change state—are the basic (or atomic) operations of the Turing machine. Complexity of operation is achieved by chaining together large numbers of these simple basic actions. Commercially available computers are hard-wired to perform basic operations considerably more sophisticated than those of a Turing machine—add, multiply, decrement, store-at-address, branch, and so forth. The precise list of basic operations varies from manufacturer to manufacturer. It is a remarkable fact, however, that despite the austere simplicity of Turing’s machines, they are capable of computing anything that any computer on the market can compute. Indeed, because they are abstract machines, with unlimited memory, they are capable of computations that no actual computer could perform in practice.

Example of a Turing machine The following simple example is from Section 3 of ‘On Computable Numbers’ (p. 61). The once-fashionable Gothic symbols that Turing used in setting out the example—and also elsewhere in ‘On Computable Numbers’—are not employed in this guide. I also avoid typographical conventions used by Turing that seem likely to hinder understanding (for example, his special symbol ‘@’, which he used to mark the beginning of the tape, is here replaced by ‘!’).

<!-- page 17 -->
The machine in Turing’s example—call it M—starts work with a blank tape. The tape is endless. The problem is to set up the machine so that if the scanner is positioned over any square of the tape and the machine set in motion, the scanner will print alternating binary digits on the tape, 0 1 0 1 0 1 . . . , working to the right from its starting place, and leaving a blank square in between each digit:

**0**

**0**

**1**

**1**

In order to do its work, M makes use of four states or m-conWgurations. These are labelled ‘a’, ‘b’, ‘c’, and ‘d’. (Turing employed less familiar characters.) M is in state a when it starts work.

The operations that M is to perform can be set out by means of a table with four columns (Table 1). ‘R’ abbreviates the instruction ‘reposition the scanner one square to the right’. This is achieved by moving the tape one square to the left. ‘L’ abbreviates ‘reposition the scanner one square to the left’, ‘P[0]’ abbreviates ‘print 0 on the scanned square’, and likewise ‘P[1]’. Thus the top line of Table 1 reads: if you are in state a and the square you are scanning is blank, then print 0 on the scanned square, move the scanner one square to the right, and go into state b.

A machine acting in accordance with this table of instructions—or programme—toils endlessly on, printing the desired sequence of digits while leaving alternate squares blank.

Turing does not explain how it is to be brought about that the machine acts in accordance with the instructions. There is no need. Turing’s machines are abstractions and it is not necessary to propose any speciWc mechanism for causing the machine to act in accordance with the instructions. However, for purposes of visualization, one might imagine the scanner to be accompanied by a bank of switches and plugs resembling an old-fashioned telephone switchboard. Arranging the plugs and setting the switches in a certain way causes the machine to act in accordance with the instructions in Table 1. Other ways of setting up the ‘switchboard’ cause the machine to act in accordance with other tables of instructions. In fact, the earliest electronic digital computers, the British Colossus (1943) and the American ENIAC (1945), were programmed in very much this way. Such machines are described as ‘programme-controlled’, in order to distinguish them from the modern ‘stored-programme’ computer.

Table 1

State

Scanned Square

Operations

Next State

a

blank

P[0], R

b

b

blank

R

c

c

blank

P[1], R

d

d

blank

R

<!-- page 18 -->
a

As everyone who can operate a personal computer knows, the way to set up a stored-programme machine to perform some desired task is to open the appropriate programme of instructions stored in the computer’s memory. The storedprogramme concept originates with Turing’s universal computing machine, described in detail in Section 4 of this guide. By inserting diVerent programmes into the memory of the universal machine, the machine is made to carry out diVerent computations. Turing’s 1945 technical report ‘Proposed Electronic Calculator’ was the Wrst relatively complete speciWcation of an electronic stored-programme digital computer (see Chapter 9).

E-squares and F-squares After describing M and a second example of a computing machine, involving the start-of-tape marker ‘!’ (p. 62), Turing introduces a convention which he makes use of later in the article (p. 63). Since the tape is the machine’s general-purpose storage medium—serving not only as the vehicle for data storage, input, and output, but also as ‘scratchpad’ for use during the computation—it is useful to divide up the tape in some way, so that the squares used as scratchpad are distinguished from those used for the various other functions just mentioned.

Turing’s convention is that every alternate square of the tape serves as scratchpad. These he calls the ‘E-squares’, saying that the ‘symbols on E-squares will be liable to erasure’ (p. 63). The remaining squares he calls ‘F-squares’. (‘E’ and ‘F’ perhaps stand for ‘erasable’ and ‘Wxed’.)

In the example just given, the ‘F-squares’ of M’s tape are the squares bearing the desired sequence of binary digits, 0 1 0 1 0 1 . . . In between each pair of adjacent F-squares lies a blank E-square. The computation in this example is so simple that the E-squares are never used. More complex computations make much use of E-squares.

<!-- page 19 -->
Turing mentions one important use of E-squares at this point (p. 63): any F-square can be ‘marked’ by writing some special symbol, e.g. ‘*’, on the E-square immediately to its right. By this means, the scanner is able to Wnd its way back to a particular string of binary digits—a particular item of data, say. The scanner locates the Wrst digit of the string by Wnding the marker ‘*’. Adjacent blank squares Another useful convention, also introduced on p. 63, is to the eVect that the tape must never contain a run of non-blank squares followed by two or more adjacent blank squares that are themselves followed by one or more non-blank squares. The value of this convention is that it gives the machine an easy way of Wnding the last non-blank square. As soon as the machine Wnds two adjacent blank squares, it knows that it has passed beyond the region of tape that has been written on and has entered the region of blank squares stretching away endlessly. The start-of-tape marker Turing usually considers tapes that are endless in one direction only. For purposes of visualization, these tapes may all be thought of as being endless to the right. By convention, each of the Wrst two squares of the tape bears the symbol ‘!’, mentioned previously. These ‘signposts’ are never erased. The scanner searches for the signposts when required to Wnd the beginning of the tape.

**2. Standard Descriptions and Description Numbers**

In the Wnal analysis, a computer programme is simply a (long) stream, or row, of characters. Combinations of characters encode the instructions. In Section 5 of ‘On Computable Numbers’ Turing explains how an instruction table is to be converted into a row of letters, which he calls a ‘standard description’. He then explains how a standard description can be converted into a single number. He calls these ‘description numbers’.

Each line of an instruction table can be re-expressed as a single ‘word’ of the form qiSjSkMql: qi is the state shown in the left-hand column of the table. Sj is the symbol on the scanned square (a blank is counted as a type of symbol). Sk is the symbol that is to be printed on the scanned square. M is the direction of movement (if any) of the scanner, left or right. ql is the next state. For example, the Wrst line of Table 1 can be written: a-0Rb (using ‘-’ to represent a blank). The third line is: c-1Rd.

The second line of the table, which does not require the contents of the scanned square (a blank) to be changed, is written: b--Rc. That is to say we imagine, for the purposes of this new notation, that the operations column of the instruction table contains the redundant instruction P[-]. This device is employed whenever an instruction calls for no change to the contents of the scanned square, as in the following example:

State

Scanned Square

Operations

Next State

d

x

L

c

It is imagined that the operations column contains the redundant instruction P[x], enabling the line to be expressed: dxxLc.

Sometimes a line may contain no instruction to move. For example:

State

Scanned Square

Operations

Next State

d

*

P[1]

c

The absence of a move is indicated by including ‘N’ in the instruction-word: d*1Nc.

<!-- page 20 -->
Sometimes a line may contain an instruction to erase the symbol on the scanned square. This is denoted by the presence of ‘E’ in the ‘operations’ column:

State

Scanned Square

Operations

Next State

m

*

E, R

n

Turing notes that E is equivalent to P[-]. The corresponding instruction-word is therefore m*-Rn.

Any table of instructions can be rewritten in the form of a stream of instruction-words separated by semicolons.5 Corresponding to Table 1 is the stream:

a-0Rb; b--Rc; c-1Rd; d--Ra;

This stream can be converted into a stream consisting uniformly of the letters A, C, D, L, R, and N (and the semicolon). Turing calls this a standard description of the machine in question. The process of conversion is done in such a way that the individual instructions can be retrieved from the standard description.

The standard description is obtained as follows. First, ‘-’ is replaced by ‘D’, ‘0’ by ‘DC’, and ‘1’ by ‘DCC’. (In general, if we envisage an ordering of all the printable symbols, the nth symbol in the ordering is replaced by a ‘D’ followed by n repetitions of ‘C’.) This produces:

aDDCRb; bDDRc; cDDCCRd; dDDRa;

Next, the lower case state-symbols are replaced by letters. ‘a’ is replaced by ‘DA’, ‘b’ by ‘DAA’, ‘c’ by ‘DAAA’, and so on. An obvious advantage of the new notation is that there is no limit to the number of states that can be named in this way.

The standard description corresponding to Table 1 is:

DADDCRDAA; DAADDRDAAA; DAAADDCCRDAAAA; DAAAADDRDA;

Notice that occurrences of ‘D’ serve to mark out the diVerent segments or regions of each instruction-word. For example, to determine which symbol an instruction-word says to print, Wnd the third ‘D’ to the right from the beginning of the word, and count the number of occurrences of ‘C’ between it and the next D to the right.

The standard description can be converted into a number, called a description number. Again, the process of conversion is carried out in such a way that the individual instructions can be retrieved from the description number. A standard description is converted into a description number by means of replacing each ‘A’ by ‘1’, ‘C’ by ‘2’, ‘D’ by ‘3’, ‘L’ by ‘4’, ‘R’ by ‘5’, ‘N’ by ‘6’, and ‘;’ by 7. In the case of the above example this produces:

31332531173113353111731113322531111731111335317.6

5 There is a subtle issue concerning the placement of the semicolons. See Davies’s ‘Corrections to Turing’s Universal Computing Machine’, Sections 3, 7, 10.

<!-- page 21 -->
6 Properly speaking, the description number is not the string ‘313325311731133531117311133225 31111731111335317’, but is the number denoted by this string of numerals.

Occurrences of ‘7’ mark out the individual instruction-words, and occurrences of ‘3’ mark out the diVerent regions of the instruction-words. For example: to Wnd out which symbol the third instruction-word says to print, Wnd the second ‘7’ (starting from the left), then the third ‘3’ to the right of that ‘7’, and count the numberofoccurrencesof‘2’betweenthat‘3’andthenext‘3’totheright.ToWndout the exit state speciWed by the third instruction-word, Wnd the last ‘3’ in that word and count the number of occurrences of ‘1’ between it and the next ‘7’ to the right.

Notice that diVerent standard descriptions can describe the behaviour of one and the same machine. For example, interchanging the Wrst and second lines of Table 1 does not in any way aVect the behaviour of the machine operating in accordance with the table, but a diVerent standard description—and therefore a diVerent description number—will ensue if the table is modiWed in this way.

This process of converting a table of instructions into a standard description or a description number is analogous to the process of compiling a computer programme into ‘machine code’. Programmers generally prefer to work in socalled high-level languages, such as Pascal, Prolog, and C. Programmes written in a high-level language are, like Table 1, reasonably easy for a trained human being to follow. Before a programme can be executed, the instructions must be translated, or compiled, into the form required by the computer (machine code).

The importance of standard descriptions and description numbers is explained in what follows.

**3. Subroutines**

Subroutines are programmes that are used as components of other programmes. A subroutine may itself have subroutines as components. Programmers usually have access to a ‘library’ of commonly used subroutines—the programmer takes ready-made subroutines ‘oV the shelf’ whenever necessary.

Turing’s term for a subroutine was ‘subsidiary table’. He emphasized the importance of subroutines in a lecture given in 1947 concerning the Automatic Computing Engine or ACE, the electronic stored-programme computer that he began designing in 1945 (see Chapter 9 and the introduction to Chapter 10):

Probably the most important idea involved in instruction tables is that of standard subsidiary tables. Certain processes are used repeatedly in all sorts of diVerent connections, and we wish to use the same instructions . . . every time . . . We have only to think out how [a process] is to be done once, and forget then how it is done.7

In ‘On Computable Numbers’—eVectively the Wrst programming manual of the computer age—Turing introduced a library of subroutines for Turing machines (in Sections 4 and 7), saying (p. 63):

<!-- page 22 -->
7 The quotation is from p. 389 below. There are certain types of process used by nearly all machines, and these, in some machines, are used in many connections. These processes include copying down sequences of symbols, comparing sequences, erasing all symbols of a given form, etc.

Some examples of subroutines are:

cpe(A, B, x, y) (p. 66):

‘cpe’ may be read ‘compare for equality’. This subroutine compares the string of

symbols marked with an x to the string of symbols marked with a y. The subrou-

tine places the machine in state B if the two strings are the same, and in state A if

they are diVerent. Note: throughout these examples, ‘A’ and ‘B’ are variables

representing any states; ‘x’ and ‘y’ are variables representing any symbols. f(A, B, x) (p. 63):

‘f’ stands for ‘Wnd’. This subroutine Wnds the leftmost occurrence of x. f(A, B,

x) moves the scanner left until the start of the tape is encountered. Then the

scanner is moved to the right, looking for the Wrst x. As soon as an x is found,

the subroutine places the machine in state A, leaving the scanner resting on the

x. If no x is found anywhere on the portion of tape that has so far been written

on, the subroutine places the machine in state B, leaving the scanner resting on

a blank square to the right of the used portion of the tape. e(A, B, x) (p. 64):

‘e’ stands for ‘erase’. The subroutine e(A, B, x) contains the subroutine f(A,

B, x). e(A, B, x) Wnds the leftmost occurrence of symbol x and erases it, placing

the machine in state A and leaving the scanner resting on the square that has just

been erased. If no x is found the subroutine places the machine in state B, leaving

the scanner resting on a blank square to the right of the used portion of the tape.

The subroutine f(A, B, x) It is a useful exercise to construct f(A, B, x) explicitly, i.e. in the form of a table of instructions. Suppose we wish the machine to enter the subroutine f(A, B, x) when placed in state n, say. Then the table of instructions is as shown in Table 2. (Remember that by the convention mentioned earlier, if ever the scanner encounterstwoadjacentblanksquares,ithaspassedbeyondtheregionoftapethathasbeen written on and has entered the region of blanksquares stretching away to the right.)

<!-- page 23 -->
As Turing explains, f(A, B, x) is in eVect built out of two further subroutines, which he writes f1(A, B, x) and f2(A, B, x). The three rows of Table 2 with an ‘m’ in the Wrst column form the subroutine f1(A, B, x), and the three rows with ‘o’ in the Wrst column form f2(A, B, x). Skeleton tables For ease of deWning subroutines Turing introduces an abbreviated form of instruction table, in which one is allowed to write expressions referring to Table 2

State Scanned Square Operations Next State Comments

n does not contain! L n Search for the Wrst square. n ! L m Found right-hand member of the pair ‘!!’; move left to Wrst square of tape; go into state m. (Notice that x might be ‘!’.) m x none A Found x; go into state A; subroutine ends. m neither x nor blank R m Keep moving right looking for x or a blank. m blank R o Blank square encountered; go into state o and examine next square to the right. o x none A Found x; go into state A; subroutine ends. o neither x nor blank R m Found a blank followed by a non-blank square but no x; switch to state m and keep looking for x. o blank R B Two adjacent blank squares encountered; go into state B; subroutine ends.

Table 3  f(A, B, x) not ! L f(A, B, x) ! L f1(A, B, x) ( f1(A, B, x) x A neither x nor blank R f1(A, B, x) blank R f2(A, B, x) ( f2(A, B, x) x A neither x nor blank R f1(A, B, x) blank R B

<!-- page 24 -->
subroutines in the Wrst and fourth columns (the state columns). Turing calls these abbreviated tables ‘skeleton tables’ (p. 63). For example, the skeleton table corresponding to Table 2 is as in Table 3. Turing’s notation for subroutines is explained further in the appendix to this guide (‘Subroutines and m-functions’).

**4. The Universal Computing Machine**

In Section 7 of ‘On Computable Numbers’ Turing introduces his ‘universal computing machine’, now known simply as the universal Turing machine. The universal Turing machine is the stored-programme digital computer in abstract conceptual form.

The universal computing machine has a single, Wxed table of instructions (which we may imagine to have been set into the machine, once and for all, by way of the switchboard-like arrangement mentioned earlier). Operating in accordance with this table of instructions, the universal machine is able to carry out any task for which an instruction table can be written. The trick is to put an instruction table—programme—for carrying out the desired task onto the tape of the universal machine.

The instructions are placed on the tape in the form of a standard description—i.e. in the form of a string of letters that encodes the instruction table. The universal machine reads the instructions and carries them out on its tape.

The universal Turing machine and the modern computer Turing’s greatest contributions to the development of the modern computer were:

• The idea of controlling the function of a computing machine by storing a

programme of symbolically encoded instructions in the machine’s memory.

• His demonstration (in Section 7 of ‘On Computable Numbers’) that, by this

means, a single machine of Wxed structure is able to carry out every compu-

tation that can be carried out by any Turing machine whatsoever, i.e. is

```prolog
universal.
```

Turing’s teacher and friend Max Newman has testiWed that Turing’s interest in building a stored-programme computing machine dates from the time of ‘On Computable Numbers’. In a tape-recorded interview Newman stated, ‘Turing himself, right from the start, said it would be interesting to try and make such a machine’.8 (It was Newman who, in a lecture on the foundations of mathematics and logic given in Cambridge in 1935, launched Turing on the research that led to the universal Turing machine; see the introduction to Chapter 4.9) In his obituary of Turing, Newman wrote:

The description that [Turing] gave of a ‘universal’ computing machine was entirely theoretical in purpose, but Turing’s strong interest in all kinds of practical experiment

8 Newman in interview with Christopher Evans (‘The Pioneers of Computing: An Oral History of Computing’, London, Science Museum).

<!-- page 25 -->
9 Ibid. made him even then interested in the possibility of actually constructing a machine on these lines.10

Turing laterdescribed theconnectionbetweentheuniversal computingmachine and the stored-programme digital computer in the following way (Chapter 9, pp. 378 and 383):

Some years ago I was researching on what might now be described as an investigation of the theoreticalpossibilities andlimitations of digital computing machines. Iconsideredatypeof machine which had a central mechanism, and an inWnite memory which was contained on an inWnite tape . . . It can be shown that a single special machine of that type can be made to dothe workofall . . . Thespecialmachine maybecalledthe universal machine;itworksinthe following quite simple manner. When we have decided what machine we wish to imitate we punchadescriptionof itonthetapeoftheuniversalmachine. Thisdescriptionexplainswhat the machine would do in every conWguration in which it might Wnd itself. The universal machine has only to keep looking at this description in order to Wnd out what it should do at each stage. Thus the complexityof the machine to be imitated is concentrated in the tape and does not appear in the universal machine proper in any way. . . [D]igital computing machines such as the ACE . . . are in fact practical versions of the universal machine. There is a certain central pool of electronic equipment, and a large memory. When any particular problem has to be handled the appropriate instructions for the computing process involved are stored in the memory of the ACE and it is then ‘set up’ for carrying out that process.

Turing’s idea of a universal stored-programme computing machine was promulgated in the USA by von Neumann and in the UK by Newman, the two mathematicians who, along with Turing himself, were by and large responsible for placing Turing’s abstract universal machine into the hands of electronic engineers.

By 1946 several groups in both countries had embarked on creating a universal Turing machine in hardware. The race to get the Wrst electronic stored-programme computer up and running was won by Manchester University where, in Newman’s Computing Machine Laboratory, the ‘Manchester Baby’ ran its Wrst programme on 21 June 1948. Soon after, Turing designed the input/output facilities and the programming system of an expanded machine known as the Manchester Mark I.11 (There is more information about the Manchester computer in the introductions to Chapters 4, 9, and 10, and in ‘ArtiWcial Life’.) A small pilot version of Turing’s Automatic Computing Engine Wrst ran in 1950, at the National Physical Laboratory in London (see the introductions to Chapters 9 and 10).

10 ‘Dr. A. M. Turing’, The Times, 16 June 1954, p. 10.

<!-- page 26 -->
11 F. C. Williams described some of Turing’s contributions to the Manchester machine in a letter written in 1972 to Brian Randell (parts of which are quoted in B. Randell, ‘On Alan Turing and the Origins of Digital Computers’, in B. Meltzer and D. Michie (eds.), Machine Intelligence 7 (Edinburgh: Edinburgh University Press, 1972) ); see the introduction to Chapter 9 below. A digital facsimile of Turing’s Programmers’ Handbook for Manchester Electronic Computer (University of Manchester Computing Machine Laboratory, 1950) is in The Turing Archive for the History of Computing <www.AlanTuring.net/ programmers_handbook>.

By 1951 electronic stored-programme computers had begun to arrive in the market place. The Wrst model to go on sale was the Ferranti Mark I, the production version of the Manchester Mark I (built by the Manchester Wrm Ferranti Ltd.). Nine of the Ferranti machines were sold, in Britain, Canada, the Netherlands, and Italy, the Wrst being installed at Manchester University in February 1951.12 In the United States the Wrst UNIVAC (built by the Eckert- Mauchly Computer Corporation) was installed later the same year. The LEO computer also made its debut in 1951. LEO was a commercial version of the prototype EDSAC machine, which at Cambridge University in 1949 had become the second stored-programme electronic computer to function.13 1953 saw the IBM 701, the company’s Wrst mass-produced stored-programme electronic computer. A new era had begun.

How the universal machine works The details of Turing’s universal machine, given on pp. 69–72, are moderately complicated. However, the basic principles of the universal machine are, as Turing says, simple.

Let us consider the Turing machine M whose instructions are set out in Table 1. (Recall that M’s scanner is positioned initially over any square of M’s endless tape, the tape being completely blank.) If a standard description of M is placed on the universal machine’s tape, the universal machine will simulate or mimic the actions of M, and will produce, on specially marked squares of its tape, the output sequence that M produces, namely:

0 1 0 1 0 1 0 1 0 1 . . .

The universal machine does this by reading the instructions that the standard description contains and carrying them out on its own tape.

In order to start work, the universal machine requires on its tape not only the standard description but also a record of M’s intial state (a) and the symbol that M is initially scanning (a blank). The universal machine’s own tape is initially blank except for this record and M’s standard description (and some ancillary punctuation symbols mentioned below). As the simulation of M progresses, the universal machine prints a record on its tape of:

• the symbols that M prints

• the position of M’s scanner at each step of the computation

• the symbol ‘in’ the scanner

• M’s state at each step of the computation.

12 S. Lavington, ‘Computer Development at Manchester University’, in N. Metropolis, J. Howlett, and G. C. Rota (eds.), A History of Computing in the Twentieth Century (New York: Academic Press, 1980).

<!-- page 27 -->
13 See M. V. Wilkes, Memoirs of a Computer Pioneer (Cambridge, Mass.: MIT Press, 1985).

When the universal machine is started up, it reads from its tape M’s initial state and initial symbol, and then searches through M’s standard description for the instruction beginning: ‘when in state a and scanning a blank . . .’ The relevant instruction from Table 1 is:

a

blank

P[0], R

b The universal machine accordingly prints ‘0’. It then creates a record on its tape of M’s new state, b, and the new position of M’s scanner (i.e. immediately to the right of the ‘0’ that has just been printed on M’s otherwise blank tape). Next, the universal machine searches through the standard description for the instruction beginning ‘when in state b and scanning a blank . . .’. And so on.

How does the universal machine do its record-keeping? After M executes its Wrst instruction, the relevant portion of M’s tape would look like this—using ‘b’ both to record M’s state and to indicate the position of the scanner. All the other squares of M’s tape to the left and right are blank.

0

b

The universal machine keeps a record of this state of aVairs by employing three squares of tape (pp. 62, 68):

0

b

The symbol ‘b’ has the double function of recording M’s state and indicating the position of M’s scanner. The square immediately to the right of the state-symbol displays the symbol ‘in’ M’s scanner (a blank).

What does the universal machine’s tape look like before the computation starts? The standard description corresponding to Table 1 is:

DADDCRDAA; DAADDRDAAA; DAAADDCCRDAAAA; DAAAADDRDA;

The operator places this programme on the universal machine’s tape, writing only on F-squares and beginning on the second F-square of the tape. The Wrst F-square and the Wrst E-square are marked with the start-of-tape symbol ‘!’. The E-squares (shaded in the diagram) remain blank (except for the Wrst).

!

!

D

D

D

D

D

C

R

A

A

A

A

A

;

```prolog
etc.
```

<!-- page 28 -->
On the F-square following the Wnal semicolon of the programme, the operator writes the end-of-programme symbol ‘::’. On the next F-square to the right of this symbol, the operator places a record of M’s initial state, a, and leaves the following F-square blank in order to indicate that M is initially scanning a blank. The next F-square to the right is then marked with the punctuation symbol ‘:’. This completes the setting-up of the tape:

!

!

p

r

r

a m m e

o

g

:

a

::

**What does the universal machine’s tape look like as the computation progresses?**

**In response to the Wrst instruction in the standard description, the universal**

**machine createsthe record ‘0b-:’ (in describing the tape, ‘-’ will be used to represent**

**a blank) on the next four F-squares to the right of the Wrst ‘:’. Depicting only the**

**portion of tape to the right of the end-of-programme marker ‘::’ (and ignoring any**

**symbols which the universal machine may have written on the E-squares in the**

**course of dealing with the Wrst instruction), the tape now looks like this:**

0

a

b

:

::

:

**Next the universal machine searches for the instruction beginning ‘when in**

**state b and scanning a blank . . .’. The relevant instruction from Table 1 is**

**blank**

**This instruction would put M into the condition:**

0

c

**So the universal machine creates the record ‘0-c-:’ on its tape:**

::

:

:

:

0

b

0

c

a

**Each pair of punctuation marks frames a representation (on the F-squares)**

**of M’s tape extending from the square that was in the scanner at start-up to the**

**furthest square to the right to have been scanned at that stage of the computation.**

**The next instruction is:**

**blank**

**P[1], R**

**This causes the universal machine to create the record ‘0-1d-:’. (The diagram**

**represents a single continuous strip of tape.)**

::

:

:

0

c

a

:

0

b

0

1

d

<!-- page 29 -->
: And so on. Record by record, the outputs produced by the instructions in Table 1 appear on the universal machine’s tape.

**Turing also introduces a variation on this method of record-keeping, whereby**

**the universal machine additionally prints on the tape a second record of the**

**binary digits printed by M. The universal machine does this by printing in front**

**of each record shown in the above diagram a record of any digit newly printed by**

**M (plus an extra colon):**

a

:

:

:

0

0

0

c

b

::

:

:

:

1

1

d

0

**These single digits bookended by colons form a representation of what has been**

**printed by M on the F-squares of its tape.**

**Notice that the record-keeping scheme employed so far requires the universal**

**machine to be able to print each type of symbol that the machine being**

**simulated is able to print. In the case of M this requirement is modest, since**

**M prints only ‘0’, ‘1’, and the blank. However, if the universal machine is to be**

**able to simulate each of the inWnitely many Turing machines, then this record-**

**keeping scheme requires that the universal machine have the capacity to print an**

**endless variety of types of discrete symbol. This can be avoided by allowing the**

**universal machine to keep its record of M’s tape in the same notation that is used**

**in forming standard descriptions, namely with ‘D’ replacing the blank, ‘DC’**

**replacing ‘0’, ‘DCC’ replacing ‘1’, ‘DA’ replacing ‘a’, ‘DAA’ replacing ‘b’, and so on.**

**The universal machine’s tape then looks like this (to the right of the end-of-**

**programme symbol ‘::’ and not including the second record of digits printed**

**by M):**

D

D

:

D

D

D

D

D

C

:

A

A

C

A

etc ::

**In this elegant notation of Turing’s, ‘D’ serves to indicate the start of each new**

**term on the universal machine’s tape. The letters ‘A’ and ‘C’ serve to distinguish**

**terms representing M’s states from terms representing symbols on M’s tape.**

**The E-squares and the instruction table**

**The universal machine uses the E-squares of its tape to mark up each instruction**

**in the standard description. This facilitates the copying that the universal**

**machine must do in order to produce its records of M’s activity. For example,**

**the machine temporarily marks the portion of the current instruction specifying**

**M’s next state with ‘y’ and subsequently the material marked ‘y’ is copied to the**

**appropriate place in the record that is being created. The universal machine’s**

**records of M’s tape are also temporarily marked in various ways.**

<!-- page 30 -->
In Section 7 Turing introduces various subroutines for placing and erasing markers on the E-squares. He sets out the table of instructions for the universal machine in terms of these subroutines. The table contains the detailed instructions for carrying out the record-keeping described above.

In Section 2.4 of Chapter 2 Turing’s sometime colleague Donald Davies gives an introduction to these subroutines and to Turing’s detailed table of instructions for the universal machine (and additionally corrects some errors in Turing’s own formulation).

**5. Turing, von Neumann, and the Computer**

In the years immediately following the Second World War, the Hungarian- American logician and mathematician John von Neumann—one of the most important and inXuential Wgures of twentieth-century mathematics—made the concept of the stored-programme digital computer widely known, through his writings and his charismatic public addresses. In the secondary literature, von Neumann is often said to have himself invented the stored-programme computer. This is an unfortunate myth.

From 1933 von Neumann was on the faculty of the prestigious Institute for Advanced Study at Princeton University. He and Turing became well acquainted while Turing was studying at Princeton from 1936 to 1938 (see the introduction to Chapter 3). In 1938 von Neumann oVered Turing a position as his assistant, which Turing declined. (Turing wrote to his mother on 17 May 1938: ‘I had an oVer of a job here as von Neumann’s assistant at $1500 a year but decided not to take it.’14 His father had advised him to Wnd a job in America,15 but on 12 April of the same year Turing had written: ‘I have just been to see the Dean [Luther Eisenhart] and ask him about possible jobs over here; mostly for Daddy’s information, as I think it unlikely I shall take one unless you are actually at war before July. He didn’t know of one at present, but said he would bear it all in mind.’)

It was during Turing’s time at Princeton that von Neumann became familiar with the ideas in ‘On Computable Numbers’. He was to become intrigued with Turing’s concept of a universal computing machine.16 It is clear that von

14 Turing’s letters to his mother are among the Turing Papers in the Modern Archive Centre, King’s College Library, Cambridge (catalogue reference K 1).

15 S. Turing, Alan M. Turing (Cambridge: HeVer, 1959), 55.

<!-- page 31 -->
16 ‘I know that von Neumann was inXuenced by Turing . . . during his Princeton stay before the war,’ said von Neumann’s friend and colleague Stanislaw Ulam (in an interview with Christopher Evans in 1976; ‘The Pioneers of Computing: An Oral History of Computing’, Science Museum, London). When Ulam and von Neumann were touring in Europe during the summer of 1938, von Neumann devised a mathematical game involving Turing-machine-like descriptions of numbers (Ulam reported by W. Aspray on pp. 178, 313 of his John von Neumann and the Origins of Modern Computing (Cambridge, Mass.: MIT Press, 1990) ). The word Neumann held Turing’s work in the highest regard.17 One measure of his esteem is that the only names to receive mention in his pioneering volume The Computer and the Brain are those of Turing and the renowned originator of information theory, Claude Shannon.18

The Los Alamos physicist Stanley Frankel—responsible with von Neumann and others for mechanizing the large-scale calculations involved in the design of the atomic and hydrogen bombs—has recorded von Neumann’s view of the importance of ‘On Computable Numbers’:

I know that in or about 1943 or ’44 von Neumann was well aware of the fundamental importance of Turing’s paper of 1936 ‘On computable numbers . . .’, which describes in principle the ‘Universal Computer’ of which every modern computer (perhaps not ENIAC as Wrst completed but certainly all later ones) is a realization. Von Neumann introduced me to that paper and at his urging I studied it with care. Many people have acclaimed von Neumann as the ‘father of the computer’ (in a modern sense of the term) but I am sure that he would never have made that mistake himself. He might well be called the midwife, perhaps, but he Wrmly emphasized to me, and to others I am sure, that the fundamental conception is owing to Turing—insofar as not anticipated by Babbage, Lovelace, and others. In my view von Neumann’s essential role was in making the world aware of these fundamental concepts introduced by Turing and of the development work carried out in the Moore school and elsewhere.19

In 1944 von Neumann joined the ENIAC group, led by Presper Eckert and John Mauchly at the Moore School of Electrical Engineering (part of the University of Pennsylvania).20 At this time von Neumann was involved in the Manhattan Project at Los Alamos, where roomfuls of clerks armed with desk calculating machines were struggling to carry out the massive calculations required by the physicists. Hearing about the Moore School’s planned computer during a chance encounter on a railway station (with Herman Goldstine), von Neumann immediately saw to it that he was appointed as consultant to the project.21 ENIAC— under construction since 1943—was, as previously mentioned, a programmecontrolled (i.e. not stored-programme) computer: programming consisted of

‘intrigued’ is used in this connection by von Neumann’s colleague Herman Goldstine on p. 275 of his The Computer from Pascal to von Neumann (Princeton: Princeton University Press, 1972).)

17 Turing’s universal machine was crucial to von Neumann’s construction of a self-reproducing automaton; see the chapter ‘ArtiWcial Life’, below.

18 J. von Neumann, The Computer and the Brain (New Haven: Yale University Press, 1958).

19 Letter from Frankel to Brain Randell, 1972 (Wrst published in B. Randell, ‘On Alan Turing and the Origins of Digital Computers’, in Meltzer and Michie (eds.), Machine Intelligence 7. I am grateful to Randell for giving me a copy of this letter.

20 John Mauchly recalled that 7 September 1944 ‘was the Wrst day that von Neumann had security clearance to see the ENIAC and talk with Eckert and me’ (J. Mauchly, ‘Amending the ENIAC Story’, Datamation, 25/11 (1979), 217–20 (217) ). Goldstine (The Computer from Pascal to von Neumann, 185) suggests that the date of von Neumann’s Wrst visit may have been a month earlier: ‘I probably took von Neumann for a Wrst visit to the ENIAC on or about 7 August’.

<!-- page 32 -->
21 Goldstine, The Computer from Pascal to von Neumann, 182. rerouting cables and setting switches. Moreover, the ENIAC was designed with only one very speciWc type of task in mind, the calculation of trajectories of artillery shells. Von Neumann brought his knowledge of ‘On Computable Numbers’ to the practical arena of the Moore School. Thanks to Turing’s abstract logical work, von Neumann knew that by making use of coded instructions stored in memory, a single machine of Wxed structure could in principle carry out any task for which an instruction table can be written.

Von Neumann gave his engineers ‘On Computable Numbers’ to read when, in 1946, he established his own project to build a stored-programme computer at the Institute for Advanced Study.22 Julian Bigelow, von Neumann’s chief engineer, recollected: The person who really. . . pushed the whole Weld ahead was von Neumann, because he understood logically what [the stored-programme concept] meant in a deeper way than anybody else . . . The reason he understood it is because, among other things, he understood a good deal of the mathematical logic which was implied by the idea, due to the work of A. M. Turing . . . in 1936–1937. . . . Turing’s [universal] machine does not sound much like a modern computer today, but nevertheless it was. It was the germinal idea . . . So. . . [von Neumann] saw. . . that [ENIAC] was just the Wrst step, and that great improvement would come.23

Von Neumann repeatedly emphasized the fundamental importance of ‘On Computable Numbers’ in lectures and in correspondence. In 1946 von Neumann wrote to the mathematician Norbert Wiener of ‘the great positive contribution of Turing’, Turing’s mathematical demonstration that ‘one, deWnite mechanism can be ‘‘universal’’’.24 In 1948, in a lecture entitled ‘The General and Logical Theory of Automata’, von Neumann said:

The English logician, Turing, about twelve years ago attacked the following problem. He wanted to give a general deWnition of what is meant by a computing automaton . . . Turing carried out a careful analysis of what mathematical processes can be eVected by automata of this type . . . He . . . also introduce[d] and analyse[d] the concept of a ‘universal automaton’. . . An automaton is ‘universal’ if any sequence that can be produced by any automaton at all can also be solved by this particular automaton. It will, of course, require in general a diVerent instruction for this purpose. The Main Result of the Turing Theory. We might expect a priori that this is impossible. How can there be an automaton which is

22 Letter from Julian Bigelow to Copeland (12 Apr. 2002). See also Aspray, John von Neumann, 178.

23 Bigelow in a tape-recorded interview made in 1971 by the Smithsonian Institution and released in

2002. I am grateful to Bigelow for sending me a transcript of excerpts from the interview.

<!-- page 33 -->
24 The letter, dated 29 Nov. 1946, is in the von Neumann Archive at the Library of Congress, Washington, DC. In the letter von Neumann also remarked that Turing had ‘demonstrated in absolute . . . generality that anything and everything Brouwerian can be done by an appropriate mechanism’ (a Turing machine). He made a related remark in a lecture: ‘It has been pointed out by A. M. Turing [in ‘‘On Computable Numbers’’] . . . that eVectively constructive logics, that is, intuitionistic logics, can be best studied in terms of automata’ (‘Probabilistic Logics and the Synthesis of Reliable Organisms from Unreliable Components’, in vol. v of von Neumann’s Collected Works, ed. A. H. Taub (Oxford: Pergamon Press, 1963), 329). at least as eVective as any conceivable automaton, including, for example, one of twice its size and complexity? Turing, nevertheless, proved that this is possible.25

The following year, in a lecture delivered at the University of Illinois entitled ‘Rigorous Theories of Control and Information’, von Neumann said:

The importance of Turing’s research is just this: that if you construct an automaton right, then any additional requirements about the automaton can be handled by suYciently elaborate instructions. This is only true if [the automaton] is suYciently complicated, if it has reached a certain minimal level of complexity. In other words . . . there is a very deWnite Wnite point where an automaton of this complexity can, when given suitable instructions, do anything that can be done by automata at all.26

Von Neumann placed Turing’s abstract ‘universal automaton’ into the hands of American engineers. Yet many books on the history of computing in the United States make no mention of Turing. No doubt this is in part explained by the absence of any explicit reference to Turing’s work in the series of technical reports in which von Neumann, with various co-authors, set out a logical design for an electronic stored-programme digital computer.27 Nevertheless there is evidence in these documents of von Neumann’s knowledge of ‘On Computable Numbers’. For example, in the report entitled ‘Preliminary Discussion of the Logical Design of an Electronic Computing Instrument’ (1946), von Neumann and his co-authors, Burks and Goldstine—both former members of the ENIAC group, who had joined von Neumann at the Institute for Advanced Study—wrote the following:

3.0. First Remarks on the Control and Code: It is easy to see by formal-logical methods, that there exist codes that are in abstracto adequate to control and cause the execution of any sequence of operations which are individually available in the machine and which are, in their entirety, conceivable by the problem planner. The really decisive considerations from the present point of view, in selecting a code, are more of a practical nature: Simplicity of the equipment demanded by the code, and the clarity of its application to the actually important problems together with the speed of its handling of those problems.28

Burks has conWrmed that the Wrst sentence of this passage is a reference to Turing’s universal computing machine.29

25 The text of ‘The General and Logical Theory of Automata’ is in vol. v of von Neumann, Collected Works; see pp. 313–14.

26 The text of ‘Rigorous Theories of Control and Information’ is printed in J. von Neumann, Theory of Self-Reproducing Automata, ed. A. W. Burks (Urbana: University of Illinois Press, 1966); see p. 50.

27 The Wrst papers in the series were the ‘First Draft of a Report on the EDVAC’ (1945, von Neumann; see n. 31), and ‘Preliminary Discussion of the Logical Design of an Electronic Computing Instrument’ (1946, Burks, Goldstine, von Neumann; see n. 28).

28 A. W. Burks, H. H. Goldstine, and J. von Neumann, ‘Preliminary Discussion of the Logical Design of an Electronic Computing Instrument’, 28 June 1946, Institute for Advanced Study, Princeton University, Section 3.1 (p. 37); reprinted in vol. v of von Neumann, Collected Works.

<!-- page 34 -->
29 Letter from Burks to Copeland (22 Apr. 1998). See also Goldstine, The Computer from Pascal to von Neumann, 258. The situation in 1945–1946 The passage just quoted is an excellent summary of the situation at that time. In ‘On Computable Numbers’ Turing had shown in abstracto that, by means of instructions expressed in the programming code of standard descriptions, a single machine of Wxed structure is able to carry out any task that a ‘problem planner’ is able to analyse into eVective steps. By 1945, considerations in abstracto had given way to the practical problem of devising an equivalent programming code that could be implemented eYciently by means of thermionic valves (vacuum tubes).

A machine-level programming code in eVect speciWes the basic operations that are available in the machine. In the case of Turing’s universal machine these are move left one square, scan one symbol, write one symbol, and so on. These operations are altogether too laborious to form the basis of eYcient electronic computation. A practical programming code should not only be universal, in the sense of being adequate in principle for the programming of any task that can be carried out by a Turing machine, but must in addition:

• employ basic operations that can be realized simply, reliably, and eYciently

by electronic means;

• enable the ‘actually important problems’ to be solved on the machine as

rapidly as the electronic hardware permits;

• be as easy as possible for the human ‘problem planner’ to work with.

The challenge of designing a practical code, and the underlying mechanism required for its implementation, was tackled in diVerent ways by Turing and the several American groups.

Events at the Moore School The ‘Preliminary Discussion of the Logical Design of an Electronic Computing Instrument’ was not intended for formal publication and no attempt was made to indicate those places where reference was being made to the work of others. (Von Neumann’s biographer Norman Macrae remarked: ‘Johnny borrowed (we must not say plagiarized) anything from anybody.’30 The situation was the same in the case of von Neumann’s 1945 paper ‘First Draft of a Report on the EDVAC’.31

This

described

the

Moore

School

group’s

proposed

storedprogramme computer, the EDVAC. The ‘First Draft’ was distributed (by Goldstine and a Moore School administrator) before references had been added—and indeed without consideration of whether the names of Eckert and Mauchly

30 N. Macrae, John von Neumann (New York: Pantheon Books, 1992), 23.

<!-- page 35 -->
31 J. von Neumann, ‘First Draft of a Report on the EDVAC’, Moore School of Electrical Engineering, University of Pennsylvania, 1945; reprinted in full in N. Stern, From ENIAC to UNIVAC: An Appraisal of the Eckert-Mauchly Computers (Bedford, Mass.: Digital Press, 1981). should appear alongside von Neumann’s as co-authors.32 Eckert and Mauchly were outraged, knowing that von Neumann would be given credit for everything in the report—their ideas as well as his own. There was a storm of controversy and von Neumann left the Moore School group to establish his own computer project at Princeton. Harry Huskey, a member of the Moore School group from the spring of 1944, emphasizes that the ‘First Draft’ should have contained acknowledgement of the considerable extent to which the design of the proposed EDVAC was the work of other members of the group, especially Eckert.33

In 1944, before von Neumann came to the Moore School, Eckert and Mauchly had rediscovered the idea of using a single memory for data and programme.34 (They were far, however, from rediscovering Turing’s concept of a universal machine.) Even before the ENIAC was completed, Eckert and Mauchly were thinking about a successor machine, the EDVAC, in which the ENIAC’s most glaring deWciencies would be remedied. Paramount among these, of course, was the crude wire’n’plugs method of setting up the machine for each new task. Yet if pluggable connections were not to be used, how was the machine to be controlled without a sacriWce in speed? If the computation were controlled by means of existing, relatively slow, technology—e.g. an electro-mechanical punched-card reader feeding instructions to the machine—then the high-speed electronic hardware would spend much of its time idle, awaiting the next instruction. Eckert explained to Huskey his idea of using a mercury ‘delay line’: Eckert described a mercury delay line to me, a Wve foot pipe Wlled with mercury which could be used to store a train of acoustic pulses . . . [O]ne recirculating mercury line would store more than 30 [32 bit binary] numbers . . . My Wrst question to Eckert: thinking about the pluggable connections to control the ENIAC, ‘How do you control the operations?’ ‘Instructions are stored in the mercury lines just like numbers,’ he said. Of course! Once he said it, it was so obvious, and the only way that instructions could come available at rates comparable to the data rates. That was the stored program computer.35

32 See N. Stern, ‘John von Neumann’s InXuence on Electronic Digital Computing, 1944–1946’, Annals of the History of Computing, 2 (1980), 349–62.

33 Huskey in interview with Copeland (Feb. 1998). (Huskey was oVered the directorship of the EDVAC project in 1946 but other commitments prevented him from accepting.)

34 Mauchly, ‘Amending the ENIAC Story’; J. P. Eckert, ‘The ENIAC’, in Metropolis, Howlett, and Rota, A History of Computing in the Twentieth Century; letter from Burks to Copeland (16 Aug. 2003): ‘before von Neumann came’ to the Moore School, Eckert and Mauchly were ‘saying that they would build a mercury memory large enough to store the program for a problem as well as the arithmetic data’. Burks points out that von Neumann was however the Wrst of the Moore School group to note the possibility, implict in the stored-programme concept, of allowing the computer to modify the addresses of selected instructions in a programme while it runs (A. W. Burks, ‘From ENIAC to the Stored-Program Computer: Two Revolutions in Computers’, in Metropolis, Howlett, and Rota, A History of Computing in the Twentieth Century, 340–1). Turing employed a more general form of the idea of instruction modiWcation in his 1945 technical report ‘Proposed Electronic Calculator’ (in order to carry out conditional branching), and the idea of instruction modiWcation lay at the foundation of his theory of machine learning (see Chapter 9).

<!-- page 36 -->
35 H. D. Huskey, ‘The Early Days’, Annals of the History of Computing, 13 (1991), 290–306 (292–3). The date of the conversation was ‘perhaps the spring of 1945’ (letter from Huskey to Copeland (5 Aug. 2003) ).

Following his Wrst visit to the ENIAC in 1944, von Neumann went regularly to the Moore School for meetings with Eckert, Mauchly, Burks, Goldstine, and others.36 Goldstine reports that ‘these meetings were scenes of greatest intellectual activity’ and that ‘Eckert was delighted that von Neumann was so keenly interested’ in the idea of the high-speed delay line memory. It was, says Goldstine, ‘fortunate that just as this idea emerged von Neumann should have appeared on the scene’.37

Eckert had produced the means to make the abstract universal computing machine of ‘On Computable Numbers’ concrete! Von Neumann threw himself at the key problem of devising a practical code. In 1945, Eckert and Mauchly reported that von Neumann ‘has contributed to many discussions on the logical controls of the EDVAC, has prepared certain instruction codes, and has tested these proposed systems by writing out the coded instructions for speciWc problems’.38 Burks summarized matters:

Pres [Eckert] and John [Mauchly] invented the circulating mercury delay line store, with enough capacity to store program information as well as data. Von Neumann created the Wrst modern order code and worked out the logical design of an electronic computer to execute it.39

Von Neumann’s embryonic programming code appeared in May 1945 in the ‘First Draft of a Report on the EDVAC’.

So it was that von Neumann became the Wrst to outline a ‘practical version of the universal machine’ (the quoted phrase is Turing’s; see p. 16). The ‘First Draft’ contained little engineering detail, however, in particular concerning electronics. Turing’s own practical version of the universal machine followed later the same year. His ‘Proposed Electronic Calculator’ set out a detailed programming code—very diVerent from von Neumann’s—together with a detailed design for the underlying hardware of the machine (see Chapter 9).

**6. Turing and Babbage**

Charles Babbage,

Lucasian

Professor of Mathematics

at the

University of Cambridge from 1828 to 1839, was one of the Wrst to appreciate the enormous potential of computing machinery. In about 1820, Babbage proposed an

36 Goldstine, The Computer from Pascal to von Neumann, 186.

37 Ibid.

38 J. P. Eckert and J. W. Mauchly, ‘Automatic High Speed Computing: A Progress Report on the EDVAC’, Moore School of Electrical Engineering, University of Pennsylvania (Sept. 1945), Section 1; this section of the report is reproduced on pp. 184–6 of L. R. Johnson, System Structure in Data, Programs, and Computers (Englewood CliVs, NJ: Prentice-Hall, 1970).

<!-- page 37 -->
39 Burks, ‘From ENIAC to the Stored-Program Computer: Two Revolutions in Computers’, 312. ‘Engine’ for the automatic production of mathematical tables (such as logarithm tables, tide tables, and astronomical tables).40 He called it the ‘DiVerence Engine’. This was the age of the steam engine, and Babbage’s Engine was to consist of more accurately machined forms of components found in railway locomotives and the like—brass gear wheels, rods, ratchets, pinions, and so forth.

Decimal numbers were represented by the positions of ten-toothed metal wheels mounted in columns. Babbage exhibited a small working model of the Engine in 1822. He never built the full-scale machine that he had designed, but did complete several parts of it. The largest of these—roughly 10 per cent of the planned machine—is on display in the London Science Museum. Babbage used it to calculate various mathematical tables. In 1990 his ‘DiVerence Engine No. 2’ was Wnally built from the original design and this is also on display at the London Science Museum—a glorious machine of gleaming brass.

In 1843 the Swedes Georg and Edvard Scheutz (father and son) built a simpliWed version of the DiVerence Engine. After making a prototype they built two commercial models. One was sold to an observatory in Albany, New York, and the other to the Registrar-General’s oYce in London, where it calculated and printed actuarial tables.

Babbage also proposed the ‘Analytical Engine’, considerably more ambitious than the DiVerence Engine.41 Had it been completed, the Analytical Engine would have been an all-purpose mechanical digital computer. A large model of the Analytical Engine was under construction at the time of Babbage’s death in 1871, but a full-scale version was never built.

The Analytical Engine was to have a memory, or ‘store’ as Babbage called it, and a central processing unit, or ‘mill’. The behaviour of the Analytical Engine would have been controlled by a programme of instructions contained on punched cards, connected together by ribbons (an idea Babbage adopted from the Jacquard weaving loom). The Analytical Engine would have been able to select from alternative actions on the basis of outcomes of previous actions—a facility now called ‘conditional branching’.

Babbage’s long-time collaborator was Ada, Countess of Lovelace (daughter of the poet Byron), after whom the modern programming language ada is named. Her vision of the potential of computing machines was in some respects perhaps more far-reaching even than Babbage’s own. Lovelace envisaged computing that

40 C. Babbage, Passages from the Life of a Philosopher, vol. xi of The Works of Charles Babbage, ed. M. Campbell-Kelly (London: William Pickering, 1989); see also B. Randell (ed.), The Origins of Digital Computers: Selected Papers (Berlin: Springer-Verlag, 3rd edn. 1982), ch. 1.

<!-- page 38 -->
41 See Babbage, Passages from the Life of a Philosopher; A. A. Lovelace and L. F. Menabrea, ‘Sketch of the Analytical Engine Invented by Charles Babbage, Esq.’ (1843), in B. V. Bowden (ed.), Faster than Thought (London: Pitman, 1953); Randell, The Origins of Digital Computers: Selected Papers, ch. 2; A. Bromley, ‘Charles Babbage’s Analytical Engine, 1838’, Annals of the History of Computing, 4 (1982), 196–217. went beyond pure number-crunching, suggesting that the Analytical Engine might compose elaborate pieces of music.42

Babbage’s idea of a general-purpose calculating engine was well known to some of the modern pioneers of automatic calculation. In 1936 Vannevar Bush, inventor of the DiVerential Analyser (an analogue computer), spoke in a lecture of the possibility of machinery that ‘would be a close approach to Babbage’s large conception’.43 The following year Howard Aiken, who was soon to build the digital—but not stored-programme and not electronic—Harvard Automatic Sequence Controlled Calculator, wrote: Hollerith . . . returned to the punched card Wrst employed in calculating machinery by Babbage and with it laid the groundwork for the development of . . . machines as manufactured by the International Business Machines Company, until today many of the things Babbage wished to accomplish are being done daily in the accounting oYces of industrial enterprises all over the world.44

Babbage’s ideas were remembered in Britain also, and his proposed computing machinery was on occasion a topic of lively mealtime discussion at Bletchley Park, the wartime headquarters of the Government Code and Cypher School and birthplace of the electronic digital computer (see ‘Enigma’ and the introductions to Chapters 4 and 9).45

It is not known when Turing Wrst learned of Babbage’s ideas.46 There is certainly no trace of Babbage’s inXuence to be found in ‘On Computable Numbers’. Much later, Turing generously wrote (Chapter 11, p. 446):

The idea of a digital computer is an old one. Charles Babbage . . . planned such a machine, called the Analytical Engine, but it was never completed. Although Babbage had all the essential ideas, his machine was not at that time such a very attractive prospect.

Babbage had emphasized the generality of the Analytical Engine, claiming that ‘the conditions which enable a Wnite machine to make calculations of unlimited extent are fulWlled in the Analytical Engine’.47 Turing states (Chapter 11, p. 455) that the Analytical Engine was universal—a judgement possible only from the vantage point of ‘On Computable Numbers’. The Analytical Engine was not, however, a stored-programme computer. The programme resided externally on

42 Lovelace and Menabrea, ‘Sketch of the Analytical Engine’, 365.

43 V. Bush, ‘Instrumental Analysis’, Bulletin of the American Mathematical Society, 42 (1936), 649–69 (654) (the text of Bush’s 1936 Josiah Willard Gibbs Lecture).

44 H. Aiken, ‘Proposed Automatic Calculating Machine’ (1937), in Randell, The Origins of Digital Computers: Selected Papers, 196.

45 Thomas H. Flowers in interview with Copeland (July 1996).

46 Dennis Babbage, chief cryptanalyst in Hut 6, the section at Bletchley Park responsible for Army, Airforce, and Railway Enigma, is sometimes said to have been a descendant of Charles Babbage. This was not in fact so. (Dennis Babbage in interview with Ralph Erskine.)

<!-- page 39 -->
47 Babbage, Passages from the Life of a Philosopher, 97. punched cards, and as each card entered the Engine, the instruction marked on that card would be obeyed.

Someone might wonder what diVerence there is between the Analytical Engine and the universal Turing machine in that respect. After all, Babbage’s cards strung together with ribbon would in eVect form a tape upon which the programme is marked. The diVerence is that in the universal Turing machine, but not the Analytical Engine, there is no fundamental distinction between programme and data. It is the absence of such a distinction that marks oV a stored-programme computer from a programme-controlled computer. As Gandy put the point, Turing’s ‘universal machine is a stored-program machine [in that], unlike Babbage’s all-purpose machine, the mechanisms used in reading a program are of the same kind as those used in executing it’.48

**7. Origins of the Term ‘Computer Programme’**

As previously mentioned, Turing’s tables of instructions for Turing machines are examplesofwhatarenowcalledcomputerprogrammes.Whenheturnedtodesigning an electronic computer in 1945 (the ACE), Turing continued to use his term ‘instruction table’ where a modern writer would use ‘programme’ or ‘program’.49 Later material Wnds Turing referring to the actual process of writing instruction tables for the electronic computer as ‘programming’ but still using ‘instruction table’ to refer to the programme itself (see Chapter 9, pp. 388, 390–91).50

In an essay published in 1950 Turing explained the emerging terminology to the layman (Chapter 11, p. 445): ‘Constructing instruction tables is usually described as ‘‘programming’’. To ‘‘programme a machine to carry out the operation A’’ means to put the appropriate instruction table into the machine so that it will do A.’

Turing seems to have inherited the term ‘programming’ from the milieu of punched-card plug-board calculators. (These calculators were electromechanical, not electronic. Electro-mechanical equipment was based on the relay—a small electrically driven mechanical switch. Relays operated much more slowly than the thermionic valves (vacuum tubes) on which the Wrst electronic computers were based; valves owe their speed to the fact that they

48 R. Gandy, ‘The ConXuence of Ideas in 1936’, in R. Herken (ed.), The Universal Turing Machine: A Half- Century Survey (Oxford: Oxford University Press, 1998), 90. Emphasis added.

49 ‘Program’ is the original English spelling, in conformity with ‘anagram’, ‘diagram’, etc. The spelling ‘programme’ was introduced into Britain from France in approximately 1800 (Oxford English Dictionary). The earlier spelling persisted in the United States. Turing’s spelling is followed in this volume (except in quotations from other authors and in the section by Davies).

<!-- page 40 -->
50 See also ‘The Turing-Wilkinson Lecture Series on the Automatic Computing Engine’ (ed. Copeland), in K. Furukawa, D. Michie, and S. Muggleton (eds.), Machine Intelligence 15 (Oxford: Oxford University Press, 1999). have no moving parts save a beam of electrons—hence the term ‘electronic’.) Plug-board calculators were set up to perform a desired sequence of arithmetical operations by means of plugging wires into appropriate sockets in a board resembling a telephone switchboard. Data was fed into the calculator from punched cards, and a card-punching device or printer recorded the results of the calculation. An early example of a punched-card machine was constructed in the USA by Herman Hollerith for use in processing statistical data gathered in the 1890 census. By the mid-twentieth century most of the world’s computing was being done by punched-card calculators. Gradually the technology was displaced by the electronic computer.

When Turing joined the National Physical Laboratory in 1945 there was a large room Wlled with punched-card calulating equipment. David Clayden, one of the engineers who built the ACE, describes the punched-card equipment and the terminology in use at that time:

When I started at NPL in 1947 there was a well established punched card department, mainly Hollerith. The workhorse of punched card equipment is the ‘Reproducer’, which has a broadside card reader and a broadside card punch. By taking a stack of cards from the punch and putting them into the reader, it is possible to do iterative calculations. All functions are controlled by a plugboard on which there are two sets of 12  80 sockets, one for the reader and one for the punch. In addition there is a relay store [i.e. memory]. The plugboard can be connected in many ways (using short plugleads) in order to perform many functions, including addition, subtraction, and multiplication. The plugboards are removable. NPL had a stack of them and called them ‘programme’ boards.51

Turing’s own preference for ‘instruction table’ over the noun ‘programme’ was not shared by all his colleagues at the NPL. Mike Woodger, Turing’s assistant from 1946, says: ‘‘‘Programme’’ of course was an ordinary English word meaning a planned sequence of events. We adopted it naturally for any instruction table that would give rise to a desired sequence of events.’52 The noun ‘programme’ was in use in its modern sense from the earliest days of the ACE project. A report (probably written by Turing’s immediate superior, Womersley) describing work done by Turing and his assistants during 1946 stated: ‘It is intended to prepare the instructions to the machine [the ACE] on Hollerith cards, and it is proposed to maintain a library of these cards with programmes for standard operations.’53 By the early 1950s specially printed ruled sheets used at the NPL for writing out programmes bore the printed heading ‘ACE Pilot Model Programme’.54

51 Letter from Clayden to Copeland (3 Oct. 2000).

52 Letter from Woodger to Copeland (6 Oct. 2000).

53 ‘Draft Report of the Executive Committee for the Year 1946’, National Physical Laboratory, paper E.910, section Ma. 1, anon., but probably by Womersley (NPL Library; a digital facsimile is in The Turing Archive for the History of Computing <www.AlanTuring.net/annual_report_1946>).

<!-- page 41 -->
54 J. G. Hayes, ‘The Place of Pilot Programming’, MS, 2000.

A document written by Woodger in 1947 used the single ‘m’ spelling: ‘A Program for Version H’.55 Woodger recalls: ‘We used both spellings carelessly for some years until Goodwin (Superintendent of Mathematics Division from 1951) laid down the rule that the ‘‘American’’ spelling should be used.’56 It is possible that the single ‘m’ spelling Wrst came to the NPL via the American engineer Huskey, who spent 1947 with the ACE group. Huskey was responsible for ‘Version H’, a scaled-down form of Turing’s design for the ACE (see Chapter 10).

Like Turing, Eckert and Mauchly, the chief architects of ENIAC, probably inherited the terms ‘programming’ and ‘program’ from the plug-board calculator. In 1942, while setting out the idea of a high-speed electronic calculator, Mauchly used the term ‘programming device’ (which he sometimes shortened to ‘program device’) to refer to a mechanism whose function was to determine how and when the various component units of a calculator shall perform.57 In the summer of 1946 the Moore School organized a series of inXuential lectures entitled ‘Theory and Techniques for Design of Electronic Digital Computers’. In the course of these, Eckert used the term ‘programming’ in a similar sense when describing the new idea of storing instructions in high-speed memory: ‘We . . . feed those pieces of information which relate to programming from the memory.’58 Also in 1946, Burks, Goldstine, and von Neumann (all ex-members of the Moore School group) were using the verb-form ‘program the machine’, and were speaking of ‘program orders’ being stored in memory.59 The modern nominalized form appears not to have been adopted in the USA until a little later. Huskey says, ‘I am pretty certain that no one had written a ‘‘program’’ by the time I left Philadelphia in June 1946.’60

**Part II Computability and Uncomputability**

**8. Circular and Circle-Free Machines**

Turing calls the binary digits ‘0’ and ‘1’ symbols ‘of the Wrst kind’. Any symbols that a computing machine is able to print apart from the binary digits—such as

55 M. Woodger, ‘A Program for Version H’, handwritten MS, 1947 (in the Woodger Papers, National Museum of Science and Industry, Kensington, London (catalogue reference N30/37) ).

56 Letter from Woodger to Copeland (6 Oct. 2000).

57 J. W. Mauchly, ‘The Use of High Speed Vacuum Tube Devices for Calculating’ (1942), in Randell, The Origins of Digital Computers: Selected Papers.

58 J. P. Eckert, ‘A Preview of a Digital Computing Machine’ (15 July 1946), in M. Campbell-Kelly and M. R. Williams (eds.), The Moore School Lectures (Cambridge, Mass.: MIT Press, 1985), 114.

59 Sections 1.2, 5.3 of Burks, Goldstine, and von Neumann, ‘Preliminary Discussion of the Logical Design of an Electronic Computing Instrument’ (von Neumann, Collected Works, vol. v, 15, 43).

<!-- page 42 -->
60 Letter from Huskey to Copeland (3 Feb. 2002). ‘2’, ‘*’, ‘x’, and blank—Turing calls ‘symbols of the second kind’ (p. 60). He also uses the term ‘Wgures’ for symbols of the Wrst kind.

A computing machine is said by Turing to be circular if it never prints more than a Wnite number of symbols of the Wrst kind. A computing machine that will print an inWnite number of symbols of the Wrst kind is said to be circle-free (p. 60). For example, a machine operating in accordance with Table 1 is circlefree. (The terms ‘circular’ and ‘circle-free’ were perhaps poor choices in this connection, and the terminology has not been followed by others.)

A simple example of a circular machine is one set up to perform a single calculation whose result is an integer. Once the machine has printed the result (in binary notation), it prints nothing more.

A circular machine’s scanner need not come to a halt. The scanner may continue moving along the tape, printing nothing further. Or, after printing a Wnite number of binary digits, a circular machine may work on forever, printing only symbols of the second kind.

Many real-life computing systems are circle-free, for example automated teller machine networks, air traYc control systems, and nuclear reactor control systems. Such systems never terminate by design and, barring hardware failures, power outages, and the like, would continue producing binary digits forever.

In Section 8 of ‘On Computable Numbers’ Turing makes use of the circular/ circle-free distinction in order to formulate a mathematical problem that cannot be solved by computing machines.

**9. Computable and Uncomputable Sequences**

The sequence of binary digits printed by a given computing machine on the F-squares of its tape, starting with a blank tape, is called the sequence computed by the machine. Where the given machine is circular, the sequence computed by the machine is Wnite. The sequence computed by a circle-free machine is inWnite.

A sequence of binary digits is said to be a computable sequence if it is the sequence computed by some circle-free computing machine. For example, the inWnite sequence 010101 . . . is a computable sequence.

<!-- page 43 -->
Notice that although the Wnite sequence 010, for example, is the sequence computed by some machine, this sequence is not a computable sequence, according to Turing’s deWnition. This is because, being Wnite, 010 is not the sequence computed by any circle-free machine. According to Turing’s deWnition, no Wnite sequence is a computable sequence. Modern writers usually deWne ‘computable’ in such a way that every Wnite sequence is a computable sequence, since each of them can be computed (e.g. by means of an instruction table that simply prints the desired sequence). Turing, however, was not much interested in Wnite sequences.

The focus of Turing’s discussion is his discovery that not every inWnite sequence of binary digits is a computable sequence. That this is so is shown by what mathematicians call a diagonal argument.

The diagonal argument Imagine that all the computable sequences are listed one under another. (The order in which they are listed does not matter.) The list stretches away to inWnity both downwards and to the right. The top left-hand corner might look like this:

01100101011000100101101001000111101 . . .

01011101001110001111111111111110111 . . .

11010000011011010100000110010000011 . . .







Let’s say that this list was drawn up in the following way (by an infinite deity, perhaps). The Wrst sequence on the list is the sequence computed by the machine with a description number that is smaller than any description number of any other circle-free machine. The second sequence on the list is the one computed by the circle-free machine with the next smallest description number, and so on. Every computable sequence appears somewhere on this list. (Some will in fact be listed twice, since sometimes diVerent description numbers correspond to the same sequence.)

To prove that not all inWnite binary sequences are computable, it is enough to describe one that does not appear on this list. To this end, consider the inWnite binary sequence formed by moving diagonally down and across the list, starting at the top left:

01100 . . .

01011 . . .

11010 . . .





<!-- page 44 -->
 The twist is to transform this sequence into a diVerent one by switching each ‘0’ lying on the diagonal to ‘1’ and each ‘1’ to ‘0’. So the Wrst digit of this new sequence is formed by switching the Wrst digit of the Wrst sequence on the list (producing 1); the second digit of the sequence is formed by switching the second digit of the second sequence on the list (producing 0); the third digit is formed by switching the third digit of the third sequence on the list (producing 1); and so on. Turing calls this sequence ‘b’ (p. 72).

A moment’s reXection shows that b cannot itself be one of the listed sequences, since it has been constructed in such a way that it diVers from each of these. It diVers from the Wrst sequence on the list at the Wrst digit. It diVers from the second sequence on the list at the second digit. And so on. Therefore, since every computable sequence appears somewhere on this list, b is not among the computable sequences.

Why the computable sequences are listable A sceptic might challenge this reasoning, saying: ‘Perhaps the computable sequences cannot be listed. In assuming that the computable sequences can be listed, one, two, three, and so on, you are assuming in eVect that each computable sequence can be paired oV with an integer (no two sequences being paired with the same integer). But what if the computable sequences cannot be paired oV like this with the integers? Suppose that there are just too many computable sequences for this to be possible.’ If this challenge were successful, it would pull the rug out from under the diagonal argument.

The response to the challenge is this. Each circle-free Turing machine produces just one computable sequence. So there cannot be more computable sequences than there are circle-free Turing machines. But there certainly cannot be more circle-free Turing machines than there are integers. This is because every Turing machine has a description number, which is an integer, and this number is not shared by any other Turing machine.

This reasoning shows that each computable sequence can be paired oV with an integer, one sequence per integer. As Turing puts this, the computable sequences are ‘enumerable’ (p. 68).

The totality of inWnite binary sequences, however, is non-enumerable. Not all the sequences can be paired oV with integers in such a way that no integer is allocated more than one sequence. This is because, once every integer has had an inWnite binary sequence allocated to it, one can ‘diagonalize’ in the above way and produce an extra sequence.

Starting with a blank tape Incidentally, notice the signiWcance, in Turing’s deWnition of sequence computed by the machine, of the qualiWcation ‘starting with a blank tape’. If the computing machine were allowed to make use of a tape that had already had an inWnite sequence of Wgures printed on it by some means, then the concept of a computable sequence would be trivialized. Every inWnite binary sequence would become computable, simply because any sequence of digits whatever— e.g. b—could be present on the tape before the computing machine starts printing.

<!-- page 45 -->
The following trivial programme causes a machine to run along the tape printing the Wgures that are already there!

a

1

P[1], R

a

a

0

P[0], R

a

a

- P[-], R

a

(The third line is required to deal with blank E-squares, if any.)

**10. Computable and Uncomputable Numbers**

Prefacing a binary sequence by ‘0’ produces a real number expressed in the form of a binary decimal. For example, prefacing the binary sequence 010101 . . . produces 0.010101 . . . (the binary form of the ordinary decimal 0.363636 . . . ). If B is the sequence of binary digits printed by a given computing machine, then 0.B is called the number computed by the machine.

Where the given machine is circular, the number computed by the machine is always a rational number. A circle-free machine may compute an irrational number (p, for example).

A number computed by a circle-free machine is said to be a computable number. Turing also allows that any number ‘that diVers by an integer’ from a number computed by a circle-free machine is a computable number (p. 61). So if B is the inWnite sequence of binary digits printed by some circle-free machine, then the number computed by the machine, 0.B, is a computable number, as are all the numbers that diVer from 0.B by an integer: 1.B, 10.B, etc.

In Section 10 of ‘On Computable Numbers’, Turing gives examples of large classes of numbers that are computable. In particular, he proves that the important numbers p and e are computable.

Not all real numbers are computable, however. This follows immediately from the above proof that not all inWnite binary sequences are computable. If S is an inWnite binary sequence that is uncomputable, then 0.S is an uncomputable number.

**11. The Satisfactoriness Problem**

In Section 8 of ‘On Computable Numbers’ Turing describes two mathematical problems that cannot be solved by computing machines. The Wrst will be referred to as the satisfactoriness problem.

<!-- page 46 -->
Satisfactory descriptions and numbers A standard description is said to be satisfactory if the machine it describes is circle-free. (Turing’s choice of terminology might be considered awkward, since there need be nothing at all unsatisfactory, in the usual sense of the word, about a circular machine.)

A number is satisfactory if it is a description number of a circle-free machine. A number is unsatisfactory if either it is a description number of a circular machine, or it is not a description number at all.

The satisfactoriness problem is this: decide, of any arbitrarily selected standard description—or, equivalently, any arbitrarily selected description number— whether or not it is satisfactory. The decision must be arrived at in a Wnite number of steps.

The diagonal argument revisited Turing approaches the satisfactoriness problem by reconsidering the above proof that not every binary sequence is computable.

Imagine someone objecting to the diagonal argument: ‘Look, there must be something wrong with your argument, because b evidently is computable. In the course of the argument, you have in eVect given instructions for computing each digit of b, in terms of counting out digits and switching the relevant ones. Let me try to describe how a Turing machine could compute b. I’ll call this Turing machine BETA. BETA is similar to the universal machine in that it is able to simulate the activity of any Turing machine that one wishes. First, BETA simulates the circle-free machine with the smallest description number. BETA keeps up the simulation just as far as is necessary in order to discover the Wrst digit of the sequence computed by this machine. BETA then switches this digit, producing the Wrst digit of b. Next, BETA simulates the circlefree machine with the next smallest description number, keeping up the simulation until it Wnds the second digit of the sequence computed by this machine. And so on.’

<!-- page 47 -->
The objector continues: ‘I can make my description of BETA speciWc. BETA uses only the E-squares of its tape to do its simulations, erasing its rough work each time it begins a new simulation. It prints out the digits of b on successive Fsquares. I need to take account of the restriction that, in order for it to be said that b is the sequence computed by BETA, BETA must produce the digits of bstarting from a blank tape. What BETA will do Wrst of all, starting from a blank tape, is Wnd the smallest description number that corresponds to a circle-free machine. It does this by checking through the integers, one by one, starting at 1. As BETA generates the integers one by one, it checks each to see whether it is a description number. If the integer is not a description number, then BETA moves on to the next. If the integer is a description number, then BETA checks whether the number is satisfactory. Once BETA Wnds the Wrst integer to describe a circlefree machine, it uses the instructions contained in the description number in order to simulate the machine. This is how BETA Wnds the Wrst digit of b. Then BETA continues its search through the integers, until it Wnds the next smallest description number that is satisfactory. This enables BETA to calculate the second digit of b. And so on.’

Turing tackles this objection head on, proving that no computing machine can possibly do what BETA is supposed to do. It suYces for this proof to consider a slightly simpliWed version of BETA, which Turing calls H. H is just like BETA except that H does not switch the digits of the list’s ‘diagonal’ sequence. H is supposed to write out (on the F-squares) the successive digits not of b but of the ‘diagonal’ sequence itself: the sequence whose Wrst digit is the Wrst digit of the Wrst sequence on the list, whose second digit is the second digit of the second sequence on the list, and so on. Turing calls this sequence b0. If no computing machine can compute b0, then there is no such computing machine as BETA— because if there were, a machine that computes b0 could be obtained from it, simply by deleting the instructions to switch each of the digits of the diagonal sequence.

What happens when H meets itself? Turing asks: what happens when, as H searches through the integers one by one, it encounters a number describing H itself? Call this description number K.

H must Wrst check whether K is a description number. Having ascertained that it is, H must test whether K is satisfactory. Since H is supposed to be computing the endless binary sequence b0, H itself must be circle-free. So H must pronounce K to be satisfactory.

In order to Wnd the next digit of b0, H must now simulate the behaviour of the machine described by K. Since H is that machine, H must simulate its own behaviour, starting with its very Wrst action. There is nothing wrong with the idea of a machine starting to simulate its own previous behaviour (just as a person might act out some episode from their own past). H Wrst simulates (on its E-squares) the series of actions that it performed up to and including writing down the Wrst digit of b0, then its actions up to and including writing down the second digit of b0, and so on.

Eventually, however, H’s simulation of its own past reaches the point where H began to simulate the behaviour of the machine described by K. What must H do now? H must simulate the series of actions that it performed when simulating the series of actions that culminated in its writing down the Wrst digit of b0, and then simulate the series of actions that it performed when simulating the series of actions that culminated in its writing down the second digit of b0, and so on! H is doomed to relive its past forever.

From the point when it began simulating itself, H writes only on the E-squares of its tape and never adds another digit to the sequence on its F-squares. Therefore, H does not compute b0. H computes some Wnite number of digits of b0 and then sticks.

<!-- page 48 -->
The problem lies with the glib assumption that H and BETA are able to determine whether each description number is satisfactory. No computing machine can solve the satisfactoriness problem Since, as has just been shown, no computing machine can possibly do what H was introduced to do, one of the various tasks that H is supposed to carry out must be impossible for a computing machine. But all the things that H is supposed to do apart from checking for satisfactoriness—decide whether a number is a description number, extract instructions from a description number, simulate a machine that follows those instructions, and so on—are demonstrably things that can be done by the universal machine.

By a process of elimination, then, the task that it is impossible for a computing machine to carry out must be that of determining whether each description number is satisfactory or not.

**12. The Printing and Halting Problems**

The printing problem Some Turing-machine programmes print ‘0’ at some stage in their computation; all the remaining programmes never print ‘0’. Consider the problem of deciding, given any arbitrarily selected programme, into which of these two categories it falls. This is an example of the printing problem.

The printing problem (p. 73) is the problem of determining whether or not the machine described by any arbitrarily selected standard description (or, equivalently, any arbitrarily selected description number) ever prints a certain symbol (‘0’, for example). Turing proves that if the printing problem were solvable by some computing machine, then the satisfactoriness problem would be too. Therefore neither is.

The halting problem Another example of a problem that cannot be solved by computing machines, and a close relative of the printing problem, is the halting problem. This is the problem of determining whether or not the machine described by any arbitrarily selected standard description eventually halts—i.e. ceases moving altogether— when started on a given tape (e.g. a blank tape).

<!-- page 49 -->
The machine shown in Table 1 is rather obviously one of those that never halt—but in other cases it is not at all obvious from a machine’s table whether or not it halts. Simply watching the machine run (or a simulation of the machine) is of little help, for what can be concluded if after a week or a year the machine has not halted? If the machine does eventually halt, a watching human—or Turing machine—will sooner or later Wnd this out; but in the case of a machine that has not yet halted, there is no systematic method for deciding whether or not it is going to halt.

The halting problem was so named (and, it appears, Wrst stated) by Martin Davis.61 The proposition that the halting problem cannot be solved by computing machine is known as the ‘halting theorem’.62 (It is often said that Turing stated and proved the halting theorem in ‘On Computable Numbers’, but strictly this is not true.)

**13. The Church–Turing Thesis**

Human computers When Turing wrote ‘On Computable Numbers’, a computer was not a machine at all, but a human being. A computer—sometimes also spelt ‘computor’—was a mathematical assistant who calculated by rote, in accordance with a systematic method. The method was supplied by an overseer prior to the calculation. Many thousands of human computers were employed in business, government, and research establishments, doing some of the sorts of calculating work that nowadays is performed by electronic computers. Like Wling clerks, computers might have little detailed knowledge of the end to which their work was directed.

The term ‘computing machine’ was used to refer to small calculating machines that mechanized elements of the human computer’s work. These were somewhat like today’s non-programmable hand-calculators: they were not automatic, and each step—each addition, division, and so on—was initiated manually by the human operator. A computing machine was in eVect a homunculus, calculating more quickly than an unassisted human computer, but doing nothing that could not in principle be done by a human clerk working by rote. For a complex calculation, several dozen human computers might be required, each equipped with a desk-top computing machine.

In the late 1940s and early 1950s, with the advent of electronic computing machines, the phrase ‘computing machine’ gave way gradually to ‘computer’. During the brief period in which the old and new meanings of ‘computer’ coexisted, the preWx ‘electronic’ or ‘digital’ would usually be used in order to distinguish machine from human. As Turing stated, the new electronic machines were ‘intended to carry out any deWnite rule of thumb process which could have been done by a human operator working in a disciplined but unintelligent manner’.63 Main-frames, laptops, pocket calculators, palm-pilots—all carry out

61 See M. Davis, Computability and Unsolvability (New York: McGraw-Hill, 1958), 70. Davis thinks it likely that he Wrst used the term ‘halting problem’ in a series of lectures that he gave at the Control Systems Laboratory at the University of Illinois in 1952 (letter from Davis to Copeland, 12 Dec. 2001).

62 It is interesting that if one lifts the restriction that the determination must be carried out in a Wnite number of steps, then Turing machines are able to solve the halting and printing problems, and moreover in a Wnite time. See B. J. Copeland, ‘Super Turing-Machines’, Complexity, 4 (1998), 30–2, and ‘Accelerating Turing Machines’, Minds and Machines, 12 (2002), 281–301.

<!-- page 50 -->
63 Turing’s Programmers’ Handbook for Manchester Electronic Computer, 1. work that a human rote-worker could do, if he or she worked long enough, and had a plentiful enough supply of paper and pencils.

It must be borne in mind when reading ‘On Computable Numbers’ that Turing there used the word ‘computer’ in this now archaic sense. Thus he says, for example, ‘Computing is normally done by writing certain symbols on paper’ (p. 75) and ‘The behaviour of the computer at any moment is determined by the symbols which he is observing, and his ‘‘state of mind’’’ (p. 75).

The Turing machine is an idealization of the human computer (p. 59): ‘We may compare a man in the process of computing a real number to a machine which is only capable of a Wnite number of conditions . . . called ‘‘m-conWgurations’’. The machine is supplied with a ‘‘tape’’ . . .’ Wittgenstein put the point in a striking way: ‘Turing’s ‘‘Machines’’. These machines are humans who calculate.’64

In the primary sense, a computable number is a real number that can be calculated by a human computer—or in other words, a real number that a human being can calculate by means of a systematic method. When Turing asserts that ‘the ‘‘computable’’ numbers include all numbers which would naturally be regarded as computable’ (p. 74), he means that each number that is computable in this primary sense is also computable in the technical sense deWned in Section 2 of ‘On Computable Numbers’ (see Section 10 of this introduction).

The thesis Turing’s thesis, that

the ‘computable’ numbers include all numbers which would naturally be

regarded as computable, is now known as the Church–Turing thesis.

Some other ways of expressing the thesis are:

1. The universal Turing machine can perform any calculation that any human

computer can carry out.

2. Any systematic method can be carried out by the universal Turing machine.

The Church–Turing thesis is sometimes heard in the strengthened form:

Anything that can be made completely precise can be programmed for a

universal digital computer. However, this strengthened form of the thesis is false.65 The printing, halting, and satisfactoriness problems are completely precise, but of course cannot be programmed for a universal computing machine.

64 L. Wittgenstein, Remarks on the Philosophy of Psychology, vol. i (Oxford: Blackwell, 1980), § 1096.

<!-- page 51 -->
65 As Martin Davis emphasized long ago in his Computability and Unsolvability, p. vii. Systematic methods A systematic method—sometimes also called an eVective method and a mechanical method—is any mathematical method of which all the following are true:

• the method can, in practice or in principle, be carried out by a human

computer working with paper and pencil;

• the method can be given to the human computer in the form of a Wnite

number of instructions;

• the method demands neither insight nor ingenuity on the part of the human

being carrying it out;

• the method will deWnitely work if carried out without error;

• the method produces the desired result in a Wnite number of steps; or, if the

desired result is some inWnite sequence of symbols (e.g. the decimal expan-

sion of p), then the method produces each individual symbol in the

sequence in some Wnite number of steps.

The term ‘systematic’ and its synonyms ‘eVective’ and ‘mechanical’ are terms of art in mathematics and logic. They do not carry their everyday meanings. For example: if some type of machine were able to solve the satisfactoriness problem, the method it used would not be systematic or mechanical in this sense. (Turing is sometimes said to have proved that no machine can solve the satisfactoriness problem. This is not so. He demonstrates only that his idealized human computers—Turing machines—cannot solve the satisfactoriness problem. This does not in itself rule out the possibility that some other type of machine might be able to solve the problem.66)

Turingsometimesusedtheexpressionruleofthumbinplaceof‘systematic’.Ifthis expression is employed, the Church–Turing thesis becomes (Chapter 10, p. 414):

LCMs can do anything that could be described as ‘rule of thumb’ or ‘purely

mechanical’. ‘LCM’ stands for ‘logical computing machine’, a term that Turing seems to have preferred to the (then current) ‘Turing machine’.

Section 9 of ‘On Computable Numbers’ contains a bouquet of arguments for Turing’s thesis. The arguments are persuasive, but do not oVer the certainty of mathematical proof. As Turing says wryly of a related thesis in Chapter 17 (p. 588): ‘The statement is . . . one which one does not attempt to prove. Propaganda is more appropriate to it than proof.’

Additional arguments and other forms of evidence for the thesis amassed. These, too, left matters short of absolute certainty. Nevertheless, before long it was, as Turing put it, ‘agreed amongst logicians’ that his proposal gives the

<!-- page 52 -->
66 See R. Gandy, ‘Church’s Thesis and Principles for Mechanisms’, in J. Barwise, H. J. Keisler, and K. Kunen (eds.), The Kleene Symposium (Amsterdam: North-Holland, 1980). ‘correct accurate rendering’ of talk about systematic methods (Chapter 10, p. 414).67 There have, however, been occasional dissenting voices over the years (for example, Kalma´r and Pe´ter).68

The converse of the thesis The converse of the Church–Turing thesis is:

Any number, or binary sequence, that can be computed by the universal

Turing machine can be calculated by means of a systematic method. This is self-evidently true—the instruction table on the universal machine’s tape is itself a speciWcation of a systematic method for calculating the number or sequence in question. In principle, a human being equipped with paper and pencil could work through the instructions in the table and write out the digits of the number, or sequence, without at any time exercising ingenuity or insight (‘in principle’ because we have to assume that the human does not throw in the towel from boredom, die of old age, or use up every sheet of paper in the universe).

Application of the thesis The concept of a systematic method is an informal one. Attempts—such as the above—to explain what counts as a systematic method are not rigorous, since the requirement that the method demand neither insight nor ingenuity is left unexplicated.

One of the most signiWcant achievements of ‘On Computable Numbers’—and this was a large step in the development of the mathematical theory of computation—was to propose a rigorously deWned expression with which the informal expression ‘by means of a systematic method’ might be replaced. The rigorously deWned expression is, of course, ‘by means of a Turing machine’.

The importance of Turing’s proposal is this. If the proposal is correct—i.e. if the Church–Turing thesis is true—then talk about the existence or non-existence of systematic methods can be replaced throughout mathematics and logic by talk about the existence or non-existence of Turing-machine programmes. For instance, one can establish that there is no systematic method at all for doing suchand-such a thing by proving that no Turing machine can do the thing in question. This is precisely Turing’s strategy with the Entscheidungsproblem, as explained in the next section.

67 There is a survey of the evidence in chapters 12 and 13 of S. C. Kleene, Introduction to Metamathematics (Amsterdam: North-Holland, 1952).

<!-- page 53 -->
68 L. Kalma´r, ‘An Argument against the Plausibility of Church’s Thesis’, R. Pe´ter, ‘Rekursivita¨t und Konstruktivita¨t’; both in A. Heyting (ed.), Constructivity in Mathematics (Amsterdam: North-Holland, 1959). Church’s contribution In 1935, on the other side of the Atlantic, Church had independently proposed a diVerent way of replacing talk about systematic methods with formally precise language (in a lecture given in April of that year and published in 1936).69 Turing learned of Church’s work in the spring of 1936, just as ‘On Computable Numbers’ was nearing completion (see the introduction to Chapter 4).

Where Turing spoke of numbers and sequences, Church spoke of mathematical functions. (x2 and x þ y are examples of mathematical functions. 4 is said to be the value of the function x2 for x ¼ 2.) Corresponding to each computable sequence S is a computable function fx (and vice versa). The value of fx for x ¼ 1 is the Wrst digit of S, for x ¼ 2, the second digit of S, and so on. In ‘On Computable Numbers’ Turing said (p. 58): ‘Although the subject of this paper is ostensibly the computable numbers, it is almost equally easy to deWne and investigate computable functions . . . I have chosen the computable numbers for explicit treatment as involving the least cumbrous technique.’

Church’s analysis was in terms of his and Stephen Kleene’s concept of a lambda-deWnable function. A function of positive integers is said to be lambdadeWnable if the values of the function can be calculated by a process of repeated substitution.

Thus we have alongside Turing’s thesis

Church’s thesis: every function of positive integers whose values can be calcu-

lated by a systematic method is lambda-deWnable.

Although Turing’s and Church’s approaches are diVerent, they are nevertheless equivalent, in the sense that every lambda-deWnable function is computable by the universal machine and every function (or sequence) computable by the universal machine is lambda-deWnable.70 Turing proved this in the Appendix to ‘On Computable Numbers’ (added in August 1936).

The name ‘Church–Turing thesis’, now standard, seems to have been introduced by Kleene, with a Xourish of bias in favour of his mentor Church: ‘So Turing’s and Church’s theses are equivalent. We shall usually refer to them both as Church’s thesis, or in connection with that one of its . . . versions which deals with ‘‘Turing machines’’ as the Church-Turing thesis.’71

Although Turing’s and Church’s theses are equivalent in the logical sense, there is nevertheless good reason to prefer Turing’s formulation. As Turing wrote in 1937: ‘The identiWcation of ‘‘eVectively calculable’’ functions with computable

69 Church, ‘An Unsolvable Problem of Elementary Number Theory’.

70 Equivalent, that is, if the computable functions are restricted to functions of positive integers. Turing’s concerns were rather more general than Church’s, in that whereas Church considered only functions of positive integers, Turing described his work as encompassing ‘computable functions of an integral variable or a real or computable variable, computable predicates, and so forth’ (p. 58, below). Turing intended to pursue the theory of computable functions of a real variable in a subsequent paper, but in fact did not do so.

<!-- page 54 -->
71 S. C. Kleene, Mathematical Logic (New York: Wiley, 1967), 232. functions is possibly more convincing than an identiWcation with the l-deWnable [lambda-deWnable] or general recursive functions.’72 Church acknowledged the point: As a matter of fact, there is . . . equivalence of three diVerent notions: computability by a Turing machine, general recursiveness in the sense of Herbrand–Go¨del–Kleene, and l-deWnability in the sense of Kleene and [myself]. Of these, the Wrst has the advantage of making the identiWcation with eVectiveness in the ordinary (not explicitly deWned) sense evident immediately. . . The second and third have the advantage of suitability for embodiment in a system of symbolic logic.73

The great Kurt Go¨del, it seems, was unpersuaded by Church’s thesis until he saw Turing’s formulation. Kleene wrote:

According to a November 29, 1935, letter from Church to me, Go¨del ‘regarded as thoroughly unsatisfactory’ Church’s proposal to use l-deWnability as a deWnition of eVective calculability. . . It seems that only after Turing’s formulation appeared did Go¨del accept Church’s thesis.74

Hao Wang reports Go¨del as saying: ‘We had not perceived the sharp concept of mechanical procedures sharply before Turing, who brought us to the right perspective.’75

Go¨del described Turing’s analysis of computability as ‘most satisfactory’ and ‘correct . . . beyond any doubt’.76 He also said: ‘the great importance of . . . Turing’s computability. . . seems to me . . . largely due to the fact that with this concept one has for the Wrst time succeeded in giving an absolute deWnition of an interesting epistemological notion.’77

**14. The Entscheidungsproblem**

In Section 11 of ‘On Computable Numbers’, Turing turns to the Entscheidungsproblem, or decision problem. Church gave the following deWnition of the Entscheidungsproblem:

By the Entscheidungsproblem of a system of symbolic logic is here understood the problem to Wnd an eVective method by which, given any expression Q in the notation of the system, it can be determined whether or not Q is provable in the system.78

72 Turing, ‘Computability and l-DeWnability’, Journal of Symbolic Logic, 2 (1937), 153–63 (153).

73 Church’s review of ‘On Computable Numbers’ in Journal of Symbolic Logic, 43.

74 S. C. Kleene, ‘Origins of Recursive Function Theory’, Annals of the History of Computing, 3 (1981), 52–67 (59, 61).

75 H. Wang, From Mathematics to Philosophy (New York: Humanities Press, 1974), 85.

76 K. Go¨del, Collected Works, ed. S. Feferman et al., vol. iii (Oxford: Oxford University Press, 1995), 304, 168.

77 Ibid., vol. ii. (Oxford: Oxford University Press, 1990), 150.

<!-- page 55 -->
78 Church, ‘A Note on the Entscheidungsproblem’, 41.

The decision problem was brought to the fore of mathematics by the German mathematician David Hilbert (who in a lecture given in Paris in 1900 set the agenda for much of twentieth-century mathematics). In 1928 Hilbert described the decision problem as ‘the main problem of mathematical logic’, saying that ‘the discovery of a general decision procedure is a very diYcult problem which is as yet unsolved’, and that the ‘solution of the decision problem is of fundamental importance’.79

The Hilbert programme Hilbert and his followers held that mathematicians should seek to express mathematics in the form of a complete, consistent, decidable formal system—a system expressing ‘the whole thought content of mathematics in a uniform way’.80 Hilbert drew an analogy between such a system and ‘a court of arbitration, a supreme tribunal to decide fundamental questions—on a concrete basis on which everyone can agree and where every statement can be controlled’.81 Such a system would banish ignorance from mathematics: given any mathematical statement, one would be able to tell whether the statement is true or false by determining whether or not it is provable in the system. As Hilbert famously declared in his Paris lecture: ‘in mathematics there is no ignorabimus’ (there is no we shall not know).82

It is important that the system expressing the ‘whole thought content of mathematics’ be consistent. An inconsistent system—a system containing contradictions—is worthless, since any statement whatsoever, true or false, can be derived from a contradiction by simple logical steps.83 So in an inconsistent

79 D. Hilbert and W. Ackermann, Grundzu¨ge der Theoretischen Logik [Principles of Mathematical Logic] (Berlin: Julius Springer, 1928), 73, 77.

80 D. Hilbert, ‘The Foundations of Mathematics’ (English translation of a lecture given in Hamburg in 1927, entitled ‘Die Grundlagen der Mathematik’), in J. van Heijenoort (ed.), From Frege to Go¨del: A Source Book in Mathematical Logic, 1879–1931 (Cambridge, Mass.: Harvard University Press, 1967), 475.

81 D. Hilbert, ‘U¨ ber das Unendliche’ [On the InWnite], Mathematische Annalen, 95 (1926), 161–90 (180); EnglishtranslationbyE.PutnamandG.MasseyinR.L.EpsteinandW.A.Carnielli,Computability:Computable Functions, Logic, and the Foundations of Mathematics (2nd edn. Belmont, Calif.: Wadsworth, 2000).

82 D. Hilbert, ‘Mathematical Problems: Lecture Delivered before the International Congress of Mathematicians at Paris in 1900’, Bulletin of the American Mathematical Society, 8 (1902), 437–79 (445).

83 To prove an arbitrary statement from a contradiction P & not P, one may use the following rules of inference (see further pp. 49–52, below):

(a) not P ‘ not (P & X)

(b) P & not (P & X) ‘ not X.

<!-- page 56 -->
Rule (a) says: from the statement that it is not the case that P, it can be inferred that not both P and X are the case—i.e. inferred that one at least of P and X is not the case—where X is any statement that you please. Rule (b) says: given that P is the case and that not both P and X are the case, it can be inferred that X is not the case. Via (a), the contradiction ‘P & not P’ leads to ‘not (P & X)’; and since the contradiction also oVers us P, we may then move, via (b), to ‘not X’. So we have deduced an arbitrary statement, ‘not X’, from the contradiction. (To deduce simply X, replace X in (a) and (b) by ‘not X’, and at the last step use the rule saying that two negations ‘cancel out’: not not X ‘ X.) system, absurdities such as 0 ¼ 1 and 6 6¼ 6 are provable. An inconsistent system would indeed contain all true mathematical statements—would be complete, in other words—but would in addition also contain all false mathematical statements!

Hilbert’s requirement that the system expressing the whole content of mathematics be decidable amounts to this: there must be a systematic method for telling, of each mathematical statement, whether or not the statement is provable in the system. If the system is to banish ignorance totally from mathematics then it must be decidable. Only then could we be conWdent of always being able to tell whether or not any given statement is provable. An undecidable system might sometimes leave us in ignorance.

The project of expressing mathematics in the form of a complete, consistent, decidable formal system became known as ‘proof theory’ and as the ‘Hilbert programme’. In 1928, in a lecture delivered in the Italian city of Bologna, Hilbert said:

In a series of presentations in the course of the last years I have . . . embarked upon a new way of dealing with fundamental questions. With this new foundation of mathematics, which one can conveniently call proof theory, I believe the fundamental questions in mathematics are Wnally eliminated, by making every mathematical statement a concretely demonstrable and strictly derivable formula . . .

[I]n mathematics there is no ignorabimus, rather we are always able to answer meaningful questions; and it is established, as Aristotle perhaps anticipated, that our reason involves no mysterious arts of any kind: rather it proceeds according to formulable rules that are completely deWnite—and are as well the guarantee of the absolute objectivity of its judgement.84

Unfortunately for the Hilbert programme, however, it was soon to become clear that most interesting mathematical systems are, if consistent, incomplete and undecidable.

In 1931, Go¨del showed that Hilbert’s ideal is impossible to satisfy, even in the case of simple arithmetic.85 He proved that the formal system of arithmetic set out by Whitehead and Russell in their seminal Principia Mathematica86 is, if consistent, incomplete. That is to say: if the system is consistent, there are true

84 D. Hilbert, ‘Probleme der Grundlegung der Mathematik’ [Problems Concerning the Foundation of Mathematics], Mathematische Annalen, 102 (1930), 1–9 (3, 9). Translation by Elisabeth NorcliVe.

85 K. Go¨del, ‘U¨ ber formal unentscheidbare Sa¨tze der Principia Mathematica und verwandter Systeme I.’ [On Formally Undecidable Propositions of Principia Mathematica and Related Systems I], Monatshefte fu¨r Mathematik und Physik, 38 (1931), 173–98. English translation in M. Davis (ed.), The Undecidable: Basic Papers on Undecidable Propositions, Unsolvable Problems and Computable Functions (New York: Raven, 1965), 5–38.

<!-- page 57 -->
86 A. N. Whitehead and B. Russell, Principia Mathematica, vols. i–iii (Cambridge: Cambridge University Press, 1910–13). statements of arithmetic that are not provable in the system—the formal system fails to capture the ‘whole thought content’ of arithmetic. This is known as Go¨del’s Wrst incompleteness theorem.

Go¨del later generalized this result, pointing out that ‘due to A. M. Turing’s work, a precise and unquestionably adequate deWnition of the general concept of formal system can now be given’, with the consequence that incompleteness can ‘be proved rigorously for every consistent formal system containing a certain amount of Wnitary number theory’.87 The deWnition made possible by Turing’s work is this (in Go¨del’s words): ‘A formal system can simply be deWned to be any mechanical procedure for producing formulas, called provable formulas.’88

In his incompleteness theorem, Go¨del had shown that no matter how hard mathematicians

might

try

to

construct

the

all-encompassing

formal system envisaged by Hilbert, the product of their labours would, if consistent, inevitably be incomplete. As Hermann Weyl—one of Hilbert’s greatest pupils— observed, this was nothing less than ‘a catastrophe’ for the Hilbert programme.89

Decidability Go¨del’s theorem left the question of decidability open. As Newman summarized matters:

The Hilbert decision-programme of the 1920’s and 30’s had for its objective the discovery of a general process . . . for deciding . . . truth or falsehood . . . A Wrst blow was dealt at the prospects of Wnding this new philosopher’s stone by Go¨del’s incompleteness theorem (1931), which made it clear that truth or falsehood of A could not be equated to provability of A or not-A in any Wnitely based logic, chosen once for all; but there still remained in principle the possibility of Wnding a mechanical process for deciding whether A, or not-A, or neither, was formally provable in a given system.90

The question of decidability was tackled head on by Turing and, independently, by Church.

On p. 84 of ‘On Computable Numbers’ Turing pointed out—by way of a preliminary—a fact that Hilbertians appear to have overlooked: if a system is complete then it follows that it is also decidable. Bernays, Hilbert’s close collaborator, had said: ‘One observes that [the] requirement of deductive completeness

87 Go¨del, ‘Postscriptum’, in Davis, The Undecidable: Basic Papers on Undecidable Propositions, Unsolvable Problems and Computable Functions, 71–3 (71); the Postscriptum, dated 1964, is to Go¨del’s 1934 paper ‘On Undecidable Propositions of Formal Mathematical Systems’ (ibid. 41–71).

88 Ibid. 72.

89 H. Weyl, ‘David Hilbert and his Mathematical Work’, Bulletin of the American Mathematical Society, 50 (1944), 612–54 (644).

<!-- page 58 -->
90 M. H. A. Newman, ‘Alan Mathison Turing, 1912–1954’, Biographical Memoirs of Fellows of the Royal Society, 1 (1955), 253–63 (256). does not go as far as the requirement of decidability.’91 Turing’s simple argument on p. 84 shows that there is no conceptual room for the distinction that Bernays is claiming.

Nevertheless, the crucial question was still open: given that in fact simple arithmetic is (if consistent) incomplete, is it or is it not decidable? Turing and Church both showed that no consistent formal system of arithmetic is decidable. They showed this by proving that not even the functional calculus—the weaker, purely logical system presupposed by any formal system of arithmetic—is decidable. The Hilbertian dream of a completely mechanized mathematics now lay in total ruin.

A tutorial on first-order predicate calculus What Turing called the functional calculus (and Church, following Hilbert, the engere Funktionenkalku¨l) is today known as Wrst-order predicate calculus (FOPC). FOPC is a formalization of deductive logical reasoning.

There are various diVerent but equivalent ways of formulating FOPC. One formulation presents FOPC as consisting of about a dozen formal rules of inference. (This formulation, which is more accessible than the Hilbert–Ackermann formulation mentioned by Turing on p. 84, is due to Gerhard Gentzen.92)

The following are examples of formal rules of inference. The symbol ‘‘’ indicates that the statement following it can be concluded from the statements (or statement) displayed to its left, the premisses.

(i) X, if X then Y ‘Y

(ii) X and Y ‘ X

(iii) X, Y ‘ X and Y

So if, for example, ‘X’ represents ‘It is sunny’ and ‘Y’ represents ‘We will go for a picnic’, (i) says:

‘We will go for a picnic’ can be concluded from the premisses ‘It is sunny’ and

‘If it is sunny then we will go for a picnic’. (ii) says:

‘It is sunny’ can be concluded from the conjunctive premiss ‘It is sunny and we

will go for a picnic’.

Turing uses the symbol ‘!’ to abbreviate ‘if then’ and the symbol ‘&’ to abbreviate ‘and’. Using this notation, (i)–(iii) are written:

91 P. Bernays, ‘Die Philosophie der Mathematik und die Hilbertsche Beweistheorie’ [The Philosophy of Mathematics and Hilbert’s Proof Theory], Bla¨tter fu¨r Deutsche Philosophie, 4 (1930/1931), 326–67. See also H. Wang, ReXections on Kurt Go¨del (Cambridge, Mass.: MIT Press, 1987), 87–8.

<!-- page 59 -->
92 G. Gentzen, ‘Investigations into Logical Deduction’ (1934), in The Collected Papers of Gerhard Gentzen, ed. M. E. Szabo (Amsterdam: North-Holland, 1969).

(i) X, X ! Y ‘ Y

(ii) X & Y ‘ X

(iii) X, Y ‘ X & Y

Some more rules of the formal calculus are as follows. a represents any object, F represents any property:

(iv) a has property F ‘ there is an object that has property F

(v) each object has property F ‘ a has property F

In Turing’s notation, in which ‘a has property F’ is abbreviated ‘F(a)’, these are written:

(iv) F(a) ‘ (9x)F(x)

(v) (x)F(x) ‘ F(a) ‘(9x)’ is read: ‘there is an object (call it x) which . . .’. So ‘(9x)F(x)’ says ‘there is an object, call it x, which has property F ’. ‘(x)’ is read: ‘each object, x, is such that . . .’. So ‘(x)F(x)’ says ‘each object, x, is such that x has property F ’.

Set out in full, FOPC contains not only rules like (i)–(v) but also several rules leading from statements containing ‘‘’ to other statements containing ‘‘’. One such rule is the so-called ‘cut rule’, used in moving from lines (2) and (3) to (4) in the proof below.

Turing calls ‘(9x)’ and ‘(x)’ quantors; the modern term is quantiWers. A symbol, such as ‘F’, that denotes a property is called a predicate. Symbols denoting relationships, for example ‘<’ (less than) and ‘¼’ (identity), are also classed as predicates. The symbol ‘x’ is called a variable.

(FOPC is Wrst-order in the sense that the quantiWers of the calculus always involve variables that refer to individual objects. In second-order predicate calculus, on the other hand, the quantiWers can contain predicates, as in ‘(9F)’. The following are examples of second-order quantiWcation: ‘Jules and Jim have some properties in common,’ ‘Each relationship that holds between a and b also holds between c and d.’)

Using the dozen or so basic rules of FOPC, more complicated rules of inference can be proved as theorems (‘provable formulas’) of FOPC. For example:

Theorem

(x)(G(x) ! H(x)), G(a) ‘ (9x)H(x) This theorem says: ‘There is an object that has property H’ can be concluded from the premisses ‘Each object that has property G also has property H ’ and ‘a has property G’.

The proof of the theorem is as follows:

(1) (x)(G(x) ! H(x)) ‘ G(a) ! H(a)

(rule (v))

(2) G(a), (G(a) ! H(a)) ‘ H(a)

(rule (i))

(3) H(a) ‘ (9x)H(x)

(rule (iv))

(4) G(a), (G(a) ! H(a)) ‘ (9x)H(x)

<!-- page 60 -->
(from (2) and (3) by the cut rule)

(5) (x)(G(x) ! H(x)), G(a) ‘ (9x)H(x)

(from (1) and (4) by the cut rule)

The cut rule (or rule of transitivity) says in eVect that whatever can be concluded from a statement Y (possibly in conjunction with additional premisses P) can be concluded from any premiss(es) from which Y can be concluded (together with the additional premisses P, if any). For example, if Y ‘ Z and X ‘ Y, then X ‘ Z. In the transition from (1) and (4) to (5), the additional premiss G(a) in (4) is gathered up and placed among the premisses of (5).

So far we have seen how to prove further inference rules in FOPC. Often logicians are interested in proving not inference rules but single statements unbroken by commas and ‘‘’. An example is the complex statement

not (F(a) & not (9x)F(x)), which says ‘It is not the case that both F(a) and the denial of (9x)F(x) aretrue’; or in other words, you are not going to Wnd F(a) true without Wnding (9x)F(x) true.

To say that a single statement, as opposed to an inference rule, is provable in FOPC is simply to say that the result of preWxing that statement by ‘‘’ can be derived by using the rules of the calculus. Think of a ‘‘’ with no statements on its left as indicating that the statement on its right is to be concluded as a matter of ‘pure logic’—no premisses are required.

For example, the theorem

‘ not (F(a) & not (9x)F(x)) can be derived using rule (iv) and the following new rule.93

X ‘ Y

‘ not (X & not Y) This rule is read:

If Y can be concluded from X, then it can be concluded that not both X and the

denial of Y are true.

Much of mathematics and science can be formulated within the framework of FOPC. For example, a formal system of arithmetic can be constructed by adding a number of arithmetical axioms to FOPC. The axioms consist of very basic arithmetical statements, such as:

(x)(x þ 0 ¼ x) and

(x)(y)(Sx ¼ Sy ! x ¼ y),

<!-- page 61 -->
93 In Gentzen’s system this rule can itself be derived from the basic rules. It should be mentioned that in the full system it is permissible to write any finite number of statements (including zero) on the right hand side of ‘‘’. where ‘S’ means ‘the successor of’—the successor of 1 is 2, and so on. (In these axioms the range of the variables ‘x’ and ‘y’ is restricted to numbers.) Other arithmetical statements can be derived from these axioms by means of the rules of FOPC. For example, rule (v) tells us that the statement

1 þ 0 ¼ 1 can be concluded from the Wrst of the above axioms.

If FOPC is undecidable then it follows that arithmetic is undecidable. Indeed, if FOPC is undecidable, then so are very many important mathematical systems. To Wnd decidable logics one must search among systems that are in a certain sense weaker than FOPC. One example of a decidable logic is the system that results if all the quantiWer rules—rules such as (iv) and (v)—are elided from FOPC. This system is known as the propositional calculus.

The proof of the undecidability of FOPC Turing and Church showed that there is no systematic method by which, given any formula Q in the notation of FOPC, it can be determined whether or not Q is provable in the system (i.e. whether or not ‘ Q). To put this another way, Church andTuringshowedthattheEntscheidungsproblemisunsolvableinthecaseofFOPC.

Both published this result in 1936.94 Church’s demonstration of undecidability proceeded via his lambda calculus and his thesis that to each eVective method there corresponds a lambda-deWnable function. There is general agreement that Turing was correct in his view, mentioned above (p. 45), that his own way of showing undecidability is ‘more convincing’ than Church’s.

Turing’s method makes use of his proof that no computing machine can solve the printing problem. He showed that if a Turing machine could tell, of any given statement, whether or not the statement is provable in FOPC, then a Turing machine could tell, of any given Turing machine, whether or not it ever prints ‘0’. Since, as he had already established, no Turing machine can do the latter, it follows that no Turing machine can do the former. The Wnal step of the argument is to apply Turing’s thesis: if no Turing machine can perform the task in question, then there is no systematic method for performing it.

<!-- page 62 -->
94 In a lecture given in April 1935—the text of which was printed the following year as ‘An Unsolvable Problem of Elementary Number Theory’ (a short ‘Preliminary report’ dated 22 Mar. 1935 having appeared in the Bulletin of the American Mathematical Society (41 (1935), 332–3) )—Church proved the undecidability of a system that includes FOPC asa part. This system isknown asPrincipia Mathematica,or PM, after the treatise in which it was Wrst set out (see n. 86). PM is obtained by adding mathematical axioms to FOPC. Church established the conditional result that if PM is omega-consistent, then PM is undecidable. Omega-consistency (Wrst deWned by Go¨del) is a stronger property than consistency, in the sense that a consistent system is not necessarily omega-consistent. As explained above, a system is consistent when there is no statement S such that both S and not-S are provable in the system. A system is omega-consistent when there is no predicate F of integers such that all the following are provable in the system: (9x)F(x), not-F(1), not-F(2), not-F(3), and so on, for every integer. In his later paper ‘A Note on the Entscheidungsproblem’ (completed in April 1936) Church improved on this earlier result, showing unconditionally that FOPC is undecidable. In detail, Turing’s demonstration contains the following steps.

1. Turing shows how to construct, for any computing machine m, a complicated statement of FOPC that says ‘at some point, machine m prints 0’. He calls this formula ‘Un(m)’. (The letters ‘Un’ probably come from ‘undecidable’ or the German equivalent ‘unentscheidbare’.)

2. Turing proves the following:

(a) If Un(m) is provable in FOPC, then at some point m prints 0.

(b) If at some point m prints 0, then Un(m) is provable in FOPC.

3. Imagine a computing machine which, when given any statement Q in the notation of FOPC, is able to determine (in some Wnite number of steps) whether or not Q is provable in FOPC. Let’s call this machine hilbert’s dream. 2(a) and 2(b) tell us that hilbert’s dream would solve the printing problem. Because if the machine were to indicate that Un(m) is provable then, in view of 2(a), it would in eVect be indicating that m does print 0; and if the machine were to indicate that the statement Un(m) is not provable then, in view of 2(b), it would in eVect be indicating that m does not print 0. Since no computing machine can solve the printing problem, it follows that hilbert’s dream is a Wgment. No computing machine is able to determine in some Wnite number of steps, of each statement Q, whether or not Q is provable in FOPC.

4. If there were a systematic method by which, given any statement Q, it can be determined whether or not Q is provable in FOPC, then it would follow, by Turing’s thesis, that there is such a computing machine as hilbert’s dream. Therefore there is no such systematic method.

The significance of undecidability Poor news though the unsolvability of the Entscheidungsproblem was for the Hilbert school, it was very welcome news in other quarters, for a reason that Hilbert’s illustrious pupil von Neumann had given in 1927:

If undecidability were to fail then mathematics, in today’s sense, would cease to exist; its place would be taken by a completely mechanical rule, with the aid of which any man would be able to decide, of any given statement, whether the statement can be proven or not.95

As the Cambridge mathematician G. H. Hardy said in a lecture in 1928: ‘if there were . . . a mechanical set of rules for the solution of all mathematical problems . . . our activities as mathematicians would come to an end.’96

<!-- page 63 -->
95 J. von Neumann, ‘Zur Hilbertschen Beweistheorie’ [On Hilbert’s Proof Theory], Mathematische Zeitschrift, 26 (1927), 1–46 (12); reprinted in vol. i of von Neumann’s Collected Works, ed. A. H. Taub (Oxford: Pergamon Press, 1961). 96 G. H. Hardy, ‘Mathematical Proof’, Mind, 38 (1929), 1–25 (16) (the text of Hardy’s 1928 Rouse Ball Lecture). Further reading

Barwise, J., and Etchemendy, J., Turing’s World: An Introduction to Computability Theory

(Stanford, Calif.: CSLI, 1993). (Includes software for building and displaying Turing

machines.) Boolos, G. S., and JeVrey, R. C., Computability and Logic (Cambridge: Cambridge Univer-

sity Press, 2nd edn. 1980). Copeland, B. J., ‘Colossus and the Dawning of the Computer Age’, in R. Erskine and

M. Smith (eds.), Action This Day (London: Bantam, 2001). Epstein, R. L., and Carnielli, W. A., Computability: Computable Functions, Logic, and the

Foundations of Mathematics (Belmont, Calif.: Wadsworth, 2nd edn. 2000). Hopcroft, J. E., and Ullman, J. D., Introduction to Automata Theory, Languages, and Comput-

ation (Reading, Mass.: Addison-Wesley, 1979). Minsky, M. L., Computation: Finite and InWnite Machines (Englewood CliVs, NJ: Prentice-

Hall, 1967). Sieg, W., ‘Hilbert’s Programs: 1917–1922’, Bulletin of Symbolic Logic, 5 (1999), 1–44. Sipser, M., Introduction to the Theory of Computation (Boston: PWS, 1997).

**Appendix**

**Subroutines and M-Functions97**

Section 3 of this guide gave a brief introduction to the concept of a skeleton table, where names of subroutines are employed in place of letters referring to states of the machine. This appendix explains the associated idea of an m-function, introduced by Turing on p. 63. m-functions are subroutines with parameters—values that are plugged into the subroutine before it is used.

The example of the ‘Wnd’ subroutine f makes this idea clear. The subroutine f(A, B, x) is deWned in Section 3 (Tables 2 and 3). Recall that f(A, B, x) Wnds the leftmost x on the tape and places the machine in A, leaving the scanner resting on the x; or if no x is found, places the machine in B and leaves the scanner resting on a blank square to the right of the used portion of the tape. ‘A’, ‘B’, and ‘x’ are the parameters of the subroutine. Parameter ‘x’ may be replaced by any symbol (of the Turing machine in question). Parameters ‘A’ and ‘B’ may be replaced by names of states of the machine. Alternatively, Turing permits ‘A’ and ‘B’ (one or both) to be replaced by a name of a subroutine. For example, replacing ‘A’ by the subroutine name ‘e1(C)’ produces:

```prolog
f(e1(C), B, x)
```

This says: Wnd the leftmost x, let the scanner rest on it, and go into subroutine e1(C); or, if there is no x, go into B (leaving the scanner resting on a blank square to the right of the used portion of the tape).

The subroutine e1(C) simply erases the scanned square and places the machine in C, leaving the scanner resting on the square that has just been erased. (‘C’ is another parameter of the same type as ‘A’ and ‘B’.) Thus the subroutine f(e1(C), B, x) Wnds

<!-- page 64 -->
97 By Andre´s Sicard and Jack Copeland. the leftmost occurrence of the symbol x and erases it, placing the machine in C and leaving the scanner resting on the square that has just been erased (or if no x is found, leaves the scanner resting on a blank square to the right of the used portion of the tape and places the machine in B). Since in this case nothing turns on the choice of letter, the name of the subroutine may also be written ‘f(e1(A), B, x)’.

The subroutine f(e1(A), B, x) is one and the same as the subroutine e(A, B, x) (Section

3). The new notation exhibits the structure of the subroutine.

More examples of m-functions are given below. While the use of m-functions is not strictly necessary for the description of any Turing machine, m-functions are very useful in describing large or complex Turing machines. This is because of the possibilities they oVer for generalization, reusability, simpliWcation, and modularization. Generalization is achieved because tasks of a similar nature can be done by a single m-function, and modularization because a complex task can be divided into several simpler m-functions. SimpliWcation is obtained because the language of m-functions submerges some of the detail of the language of instruction-words—i.e. words of the form qiSjSkMq1—so producing transparent descriptions of Turing machines. Reusability arises simply because we can employ the same m-function in diVerent Turing machines.

Although it is diYcult (if not impossible) to indicate the exact role that Turing’s concept of an m-function played in the development of today’s programming languages, it is worth emphasizing that some characteristics of m-functions are present in the subroutines of almost all modern languages. Full use was made of the idea of parametrized subroutines by Turing and his group at the National Physical Laboratory as they pioneered the science of computer programming during 1946. A contemporary report (by Huskey) outlining Turing’s approach to programming said the following:

The fact that repetition of subroutines require[s] large numbers of orders has led to the abbreviated code methods whereby not only standard orders are used but special words containing parameters are converted into orders by an interpretation table. The general idea is that these describe the entries to subroutines, the values of certain parameters in the subroutine, how many times the subroutine is to be used, and where to go after the subroutine is Wnished.98

Rather than give a formal deWnition of an m-function we present a series of illustrative examples.

First, some preliminaries. An alphabet A is some set of symbols, for example {-, 0, 1, 2}, and a word of alphabet A is a Wnite sequence of non-blank symbols of A. The blank symbol, represented ‘-’, is used to separate diVerent words on the tape and is part of the alphabet, but never occurs within words. The following examples all assume that, at the start of operation, there is a single word w of the alphabet on an otherwise blank tape, with the scanner positioned over any symbol of w. The symbols of w are written on adjacent squares, using both E-squares and F-squares, and w is surrounded by blanks (some of the examples require there to be at least one blank in front of w and at least three following w).

<!-- page 65 -->
98 H. D. Huskey, untitled typescript, National Physical Laboratory, n.d. but c. Mar. 1947 (in the Woodger Papers, National Museum of Science and Industry, Kensington, London (catalogue reference M12/105); a digital facsimile is in The Turing Archive for the History of Computing <www.AlanTuring.net/ huskey_1947>).

Let M be a Turing machine with alphabet A ¼ {-, 0, 1, 2}. The following instructions result in M printing the symbol ‘1’ at the end of w, replacing the Wrst blank to the right of w:

q100Rq1, q111Rq1, q122Rq1, q1-1Nq2 The Wrst three instructions move the scanner past the symbols ‘0’, ‘1’, and ‘2’, and once the scanner arrives at the Wrst blank square to the right of w, the fourth instruction prints ‘1’ (leaving M in state q2).

If the symbols ‘3’, ‘4’, . . . , ‘9’ are added to the alphabet, so A ¼ f-, 0, 1, :::, 9g, then the necessary instructions for printing ‘1’ at the end of w are lengthier:

q100Rq1, q111Rq1, . . . , q199Rq1, q1-1Nq2

The m-function add(S, a) deWned by Table 4 carries out the task of printing one symbol ‘a’ at the end of any word w of any alphabet (assuming as before that the machine starts operating with the scanner positioned over one or another symbol of w and that w is surrounded by blanks).

Table 4 is the skeleton table for the m-function add(S, a). (Skeleton tables are like tables of instructions but with some parameters to be replaced by concrete values.) Table 4 has two parameters, ‘a’ and ‘S’. The second parameter ‘S’ is to be replaced by the state or m-function into which the machine is to go once add(S, a) completes its operation, and the Wrst parameter ‘a’ is to be replaced by whatever symbol it is that we wish to be printed at the end of the word.

Both sets of instruction-words shown above can now be replaced by a simple call to the m-function add(S, a), where S ¼ q2 and a ¼ 1.

If instead of adding ‘1’ at the end of a word from alphabet A ¼ {-, 0, 1, . . . , 9}, we wanted to add a pair of symbols ‘5’ and ‘4’, then the instruction-words would be:

q100Rq1, q111Rq1, . . . , q199Rq1, q1-5Rq2, q2-4Nq3 These instruction-words can be replaced by the m-function add(add(q3, 4), 5). This mfunction Wnds the end of the word and writes ‘5’, going into m-function add(q3, 4), which writes ‘4’ and ends in state q3.

Another example: suppose that ‘5’ and ‘4’ are to be printed as just described, and then each occurrence of the symbol ‘3’ is to be replaced by ‘4’. The m-function add(add(change(qn, 3, 4), 4), 5) carries out the required task, where the m-function change(S, a, b) is deWned by Table 5. The m-function change1(S, a, b) is a subroutine inside the m-function change(S, a, b).

m-functions can employ internal variables. Although internal variables are not strictly necessary, they simplify an m-function’s description. Internal variables are not parameters of the m-function—we do not need to replace them with concrete values before the mfunction is used. In the following example, the internal variable ‘d’refers to whatever symbol is present on the scanned square when the machine enters the m-function repeat1(S).

Suppose we wish to print a repetition of the Wrst symbol of w at the end of w. This can be achieved by the m-function repeat(S) deWned by Table 5. (The m-function add(S, d) is as given by Table 4.)

Every

m-function

has

the

form:

```prolog
name(S1, S2, . . . , Sn, a1, a2, . . . , am),
                              where
```

<!-- page 66 -->
S1, S2, . . . , Sn refer either to states or to m-functions, and a1, a2, . . . , am denote symbols. Each m-function is a Turing machine with parameters. To convert an m-function’s

Table 4

State

Scanned Square

Operations

Next State

```prolog
      add(S, a)
                not -
                               R
                                          add(S, a)
      add(S, a)
                -
                               P[a]
                                          S
Table 5
State
                Scanned Square
                               Operations
                                          Next State
change(S, a, b)
                not -
                               L
                                          change(S, a, b)
change(S, a, b)
                 -
                               R
                                          change1(S, a, b)
change1(S, a, b)
                a
                               P[b], R
                                          change1(S, a, b)
change1(S, a, b)
                not a
                               R
                                          change1(S, a, b)
change1(S, a, b)
                -
                               L
                                          S
 Table 6
 State
               Scanned Square
                                Operations
                                              Next State
 repeat(S)
               not -
                                L
                                              repeat(S)
 repeat(S)
               -
                                R
                                              repeat1(S)
 repeat1(S)
               d
                                              add(S, d)
```

skeleton table to a Turing-machine instruction table, where each row is an instructionword of the form qiSjSkMq1, it is necessary to know the context in which the m-function is to be used, namely, the underlying Turing machine’s alphabet and states. It is necessary to know the alphabet because of the use in skeleton tables of expressions such as ‘does not contain !’, ‘not a’, ‘neither a nor -’, ‘any’. Knowledge of the underlying machine’s states is necessary to ensure that the m-function begins and ends in the correct state.

The economy eVected by m-functions is illustrated by the fact that if the m-functions are eliminated from Turing’s description of his universal machine, nearly 4,000 instruction-words are required in their place.99

99 A. Sicard, ‘Ma´quinas de Turing dina´micas: historia y desarrollo de una idea’ [Dynamic Turing Machines: Story and Development of an Idea], appendix 3 (Master’s thesis, Universidad EAFIT, 1998); ‘Ma´quina universal de Turing: algunas indicaciones para su construccio´n’ [The Universal Turing Machine: Some Directions for its Construction], Revista Universidad EAFIT, vol. 108 (1998), pp. 61–106.
