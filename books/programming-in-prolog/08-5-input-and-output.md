# 5 Input and Output

<!-- page 113 -->
Input and Output

```prolog
Thus far, the only means we have seen of providing information to a Prolog program
has been by asking questions of the Prolog system. Also, the only method of finding
out what a variable stands for at some point in the satisfaction of a goal has been
by asking a question in such a way that Prolog will display the answer in the "X =
answer" form. Much of the time, such direct interaction with questions is all that is
required to ensure that a program is working properly. However, for many occasions
it is useful to write a Prolog program that initiates a conversation with you by itself.
    Suppose you have a database of world events in the 16th Century, arranged
as facts containing dates and headlines. To start with, dates can be represented as
integers, and headlines can be represented as lists of atoms. We shall have to enclose
some of the atoms in single quotes because they begin with an upper-case letter, and
we should not want them to be interpreted as variables:
    event(1505, ['Euclid',translated,into/Latin']).
    event(1510, ['Reuchlin-Pfefferkorn',controversy]).
    event(1523, ['Christian','II',flees,from,'Denmark']).
Now if we wish to know about a particular date, we could ask a question as follows:
    ?- event(1505, X).
and Prolog would produce the reply
    X= [Euclid, transla ted, in to, Latin],
Representing the history headlines as lists of atoms confers the advantage that
"searches" can be made to find out the date when certain key events happened. For
example, consider the predicate we shall define, called when. The goal when(X,Y)
succeeds if X is mentioned in year Y according to our history headlines:
```

<!-- page 114 -->
```prolog
when(X, Y) :- event(Y, Z), member(X, Z).
?- when('Denmark', D).
```

*D = 1523*

```prolog
It would be convenient, instead of asking Prolog questions of this form, to write a
program that first asks what date you want to know about, and then displays the
appropriate headline. In order to do these kinds of tasks, Prolog makes available
some built-in predicates that display their arguments on your computer's display.
There are also predicates that wait for you to type in text on the computer's keyboard,
and instantiate a variable to whatever you typed in. In this way, your program can
interact with you, accepting input from you, and producing output to you. When a
program waits for you to type some input from you, we say that it is reading the input.
Likewise, when a program is displaying some output to you, we say it is writing the
output.
    In this chapter we describe various methods for reading and writing. One of
our examples will be displaying headlines from the history database, and we finally
present a program that accepts normal sentences and converts them into a list of
constants that can be processed by other programs. This conversion program, callefi
read_in, can be used to avoid having to type in quotes, brackets and commas in
entering English phrases such as history headlines. It is an important building block
for creating programs that analyse English language. Such analysis programs are
discussed in later chapters, especially Chapter 9.
    One important point to bear in mind is that the input/output predicates specified
by Standard Prolog differ in some ways from the Prolog language that was presented
in previous editions of Programming in Prolog and indeed often also from the pred-
icates offered by particular Prolog implementations. We will indicate by footnotes
some of the main ways in which the new predicates correspond with older versions
that are still commonly used. Appendix C describes ways to make it easier to write
Standard Prolog programs even if your Prolog implementation does not yet conform.
```

## 5.1 Reading and Writing Terms

### 5.1.1 Reading Terms

```prolog
The special predicate read will read the next term that you type in from the computer
terminal's keyboard. The term must be followed by a dot Q (usually called a period
or a full stop) and a non-printing character such as a space or a newline vJj. If X
is uninstantiated, the goal read(X) will cause the next term to be read, and X to be
instantiated to the term.
```

<!-- page 115 -->
```prolog
    If its argument is instantiated at the time it is used as a goal, then the next term
will be read, and matched with the argument given to read. The goal will succeed or
fail, depending on the success of the match. The read predicate cannot be re-satisfied.
It only succeeds at most once, and it fails if an attempt is made to re-satisfy it.
    Using read, we can start to write a more interactive program to display the
historical headlines from the event database as follows:
    hellol(Event) :- read(Date), event(Date, Event).
When we ask the question:
```

?- heUol(X).

```prolog
Prolog will attempt to satisfy the read goal and will wait for a response. Suppose we
type in:
    1523.
Remember to type in the SD and d] after 1523. The read goal will succeed, with
Date instantiated to 1523. An event with date 1523 will be looked up in the database,
and as a result Event will be instantiated to an appropriate list of atoms. Prolog will
respond:
```

*X = ['Christian', II', flees, from, 'DenmarkJ ?*

```prolog
If we prompt for more solutions, we may get alternative events that took place in
1523. But read will fail when it is reached on backtracking and so we will not be
asked for other possible dates.
    The hello 1 predicate represents a start towards making our program easier to
use, but the major problem now is the ugly format of the way the events are displayed.
What is needed is a way of directing Prolog to produce output in a format that we
like.
```

### 5.1.2 Writing Terms

```prolog
Perhaps the most useful way to display a term on the computer terminal's display is
to use the built-in predicate write. If X is instantiated to a term, then the goal write(X)
will cause the term to be displayed. If X is not instantiated, a uniquely numbered
variable (such as '_253') will be displayed. As with read, write only succeeds once.
    It would not be a good idea to use write to write out the historical headline in
our example above because write will display the headline in the standard format for
a Prolog list, with brackets and commas. On the other hand, if we use write to display
the individual components of the list then we may be able to achieve something more
readable.
```

<!-- page 116 -->
```prolog
    There is one more predicate to introduce, and then we will see our first example
using write. The built-in predicate nl is used to force all succeeding output to appear
on the next line of the display. The name "nl" means "new line". Like write, nl
succeeds only once.
    When displaying lists, it is helpful for the items of a list to be displayed in a
way that is easy to understand. Lists that contain other lists are especially difficult to
read, especially when there are structures inside as well. We shall define a predicate
pp such that the goal pp(X,Y) displays the list (to which X is instantiated) in a helpful
way. The name "pp" means "pretty print". The second argument of pp is explained
later.
    Each author of a pretty-print program has his or her own style of making lists
more legible. Just for simplicity, we shall adopt a method where the elements of
a list are displayed in a vertical column. If the element is itself a list, its elements
are displayed in a column which is shifted over to the right. This is essentially a
"vine diagram" (Chapter 3) on its side. For example, the list [1,2,3] is pretty-printed
as
```

*1* *2* *3*

```prolog
and the list [1,2,[3,4],5,6] is shown as
```

*1* *2*

*3*

*4* *5* *6*

```prolog
Notice that we have decided to remove the separating commas and the square
brackets. If the element of a list is a structure, we will treat it as though it is an
atom. This way we do not have to "get inside" structures to pretty-print their con-
tents.
    First we need a way to display the indentation for embedded lists. If we keep
track of the "depth" of the list element being displayed, we should just display a cer-
tain number of spaces depending on the depth before displaying the element. We can
define the predicate spaces, which displays a certain number of spaces by displaying
the "space" character as many times as given by the argument of spaces:
    spaces(O) :- !.
    spaces(N) :- write(''), Nl is N - 1, spaces(Nl).
```

<!-- page 117 -->
```prolog
The following program implements the pretty-print method we have specified:
    pp([H|T], I) :- !, J is I + 3, pp(H, J), ppx(T, J), nl.
    pp(X, I) :- spaces(I), write(X), nl.
    PPX([L_)-
    ppx([H|T],I) :- pp(H, I), ppx(T, I).
Here we see the second argument of pp revealed as a column counter. The top level
goal for displaying a list might look like
    • • pp(L, 0), ...
which initialises the column counter to 0. The first clause of pp handles the special
case: if the first argument is a list. If so, we have to set up a new column by increasing
the column counter by some amount (3 here). Next, we need to "pretty print" the head
of the list, because it might be a list itself. Next, we need to display each element of
the tail of the list all in the same column. This is what ppx does. And, ppx needs to
pp each element in case it is a list. The second clause of pp matches if we wish to
pretty-print something that is not a list. We simply indent to the specified column,
use write to display the term, and move to a new line. The first clause of pp also
needs to terminate each list with a new line, hence the nl there.
    Let us consider the event facts from the beginning of this chapter. Given one
of the history headlines represented as a list of atoms, we can use write to display
each atom, with a space in between each atom. Consider the predicate phh (for "print
history headline"):
    phh([]) :- nl.
    phh([H|T]):- write(H), spaces(O), phh(T).
So, the following question, if we prompt for all alternative solutions, would display
any history headline that mentions "England":
    ?- event(_, L), member('England', L), phh(L).
Notice the use of backtracking to search the database. Every time the member goal
fails, an attempt is made to re-satisfy event, which causes the entire database to be
searched top-to-bottom for events that mention the atom England.
    The predicate write is clever about how it displays a term, because it takes
into account which operator declarations have been made. For instance, if we have
declared an atom as an infix operator, then a term with this atom as functor and
two arguments will be displayed with the atom between the two arguments. There
is another predicate that behaves in exactly the same way as write, except that
```

<!-- page 118 -->
```prolog
it ignores any operator declarations that have been made. This predicate is called
write_canonical].
    The difference between write and write_canonical is illustrated by the follow-
ing:
    ?- write(a+b*c*c), nl, write_canonical(a+b*c*c), nl.
```

*a+b*c*c* *+(a,*(*(b,c),c))* *yes*

```prolog
Notice how write_canonical has treated the atoms + and * just like any other atoms.
We do not usually want to see our structures displayed out in this way, because having
operators usually helps us to read program output as well as prepare program input.
However, using write_canonical can be quite helpful if we are not quite sure about
the precedences of our operators.
    Now that we have seen the use of read and defined phh, we can put them to-
gether into an improved program for displaying history headlines:
    hello2 :-
            phh(['What', date, do, you, 'desire? ']),
            read(D),
            event(D, S),
            phh(S).
Here we have defined a predicate hello2 with no arguments. When it is called, phh
will cause a question to be displayed, then read will read in our date (as with hellol)
and finally phh will be used again to display the retrieved headline. Notice that the
first clause of the body of hello2 uses phh, even though it is not intended to print
a history headline. This simply shows that phh suffices also to display any list of
atoms, no matter where that list came from.
```

## 5.2 Reading and Writing Characters

```prolog
The character is the smallest entity that can be written or read. In Standard Prolog,
characters are identified with the atoms that have exactly one element in their name.
Thus 'a', '\n' and ' ' are examples of characters, but 'abc' is not2.
```

<!-- page 119 -->
1 Many Prolog systems provide a similar predicate called `display.` 2 In fact, efficient low-level character operations generally make use of small integers and there is associated with each character an integer character code that may be different on different machines. Standard Prolog does provide facilities for manipulating character

```prolog
    Standard Prolog has built-in predicates for reading and writing characters,
which are useful for programs which take input that is not already in the form of
Prolog terms or which seek to have fine control over their output.
```

### 5.2.1 Reading Characters

```prolog
A character X may be read from the keyboard by using the goal get_char(X).3 Such a
goal always succeeds if its argument is uninstantiated, and also cannot be re-satisfied.
Satisfying such a goal makes the computer wait until some characters have been
typed by you. Depending on the characteristics of your machine, the characters you
type may however not be made available to the Prolog system until you have entered
a complete line followed by EO- If X is already instantiated, then get_char(X) com-
pares the next character for equality, and succeeds or fails depending on the outcome
of the equality test.
    The following simple program uses get_char in a simple typing checker.
    checkJine(OK) :-
            get_char(X),
            rest_line('\n', X, OK).
    rest_line(_, '\n', yes) :- !.
    rest_line(Last, Current, no) :-
            typing_error(Last, Current), !,
            get_char(New),
            rest_line(Current, New, _).
    rest_line(_, Current, OK) :-
            get_char(New),
            rest_line(Current, New, OK).
    typing_error('q', V ) .
    typing_error('c', V).
When check_line(X) is called, it reads all the characters typed until the newline char-
acter '\n' is encountered. As this line is read, each consecutive pair of characters is
compared against a list of known "typing errors". For instance, "qw" and "cv" must
both represent errors, since these pairs of characters would never arise together in
```

<!-- page 120 -->
codes, but we will not cover them here. Many old Prolog systems only provide operations on character codes, not on characters, but the Appendix shows that it is straightforward to define character operations in terms of character code operations. 3 Older Prologs use getO(X), but instantiate X to a character code.

```prolog
English text. check_line instantiates X to either 'yes' or 'no', according to whether
the text is correct by this criterion:
    ?- check_line(X).
    Please could you enter your cvomments on the proposal
```

*X = no*

```prolog
The basic idea behind this program is to read the characters of the line one by one
and keep a record of the current character (the one just read) and the one before. The
predicate rest_line is always called just after a character is read, with the previous
character in the first argument and the current character in the second argument. It
returns either yes or no in the third argument, according to whether the rest of the
line (starting with these two characters) is error-free. Initially, the previous character
is assumed to be '\n' and the current character is the first one read. Each time a
character is read, the current character becomes the previous character and the new
character becomes the current character. When rest_line calls itself recursively the
first two arguments are changed to reflect the new situation. The clauses of rest_line
account for three different situations:
 1. The end of the line has been reached. In that case, this part of the line (the end
   bit) is error-free.
 2. The previous and current characters match a known typing error. In that case,
   this part of the line is not error-free. The program continues checking to the end
   of the line, but the answer is always no.
 3. No known typing error is spotted at this point. In that case, the next character is
   read and the program keeps checking.
```

### 5.2.2 Writing Characters

```prolog
If X is instantiated to a character it will be displayed when Prolog encounters the goal
put_char(X)4
    The predicate put_char always succeeds, and it cannot be re-satisfied (it fails
when an attempt is made to re-satisfy it). As a "side effect", put_char displays its
argument as a character on your computer's display. For example, we can display the
word hello in a rather awkward way by:
    ?- put_char('h'), put_char('e'); put_char(T), put_char(T), put_char('o').
```

<!-- page 121 -->
*hello* 4 Previous Prolog systems used put(X), where X had to be a character code.

```prolog
The result of this conjunction of goals is that Prolog displays the characters h, e, I,
I, o, displaying them after the question as shown above.
    We have already seen that it is possible to start the display at the beginning of
the next line by using the nl predicate, which has no arguments. What nl actually
does is to emit some control codes that cause the cursor on your computer's display
to move to the beginning of the next line. The question:
    ?- put_char('h'), put_char('i'), nl, put_char('f),
    put_char('h'), put_char('e'), put_char(Y), put_char('e').
causes the following to be output:
```

*hi* *there*

```prolog
We can use character output to enhance our typing checker to make it actually cor-
rect the errors. In the following revised version of check_line, called correct_line,
whenever a known typing error is detected it is corrected.
    Characters not involved in typing errors are copied out unchanged. The ap-
proach here is quite limited, because it assumes that each typing error involves two
adjacent characters and that the correction for the two is simply a single charac-
ter that should replace the pair. This information is recorded in the predicate typ-
ing_correction, where the first two arguments represent the incorrect pair (as in
typing_error above) and the third argument represents the correction. It would be
relatively easy to make this representation more general.
    correct_line :-
            get_char(X),
            correct_rest_line('\n', X).
    correct_rest_line(C, '\n') :- !,
            put_char(C), nl.
    correct_rest_line(Last, Current) :-
            typing_correction(Last, Current, Corr), !,
            get_char(New),
            correct_rest_line(Corr, New).
    eorrect_rest_line(Last, Current) :-
            put_char(Last),
            get_char(New),
            correct_rest_line(Current, New).
    typing_correction('q', 'w', 'q').
    typing_correction('c', V, 'c').
```

<!-- page 122 -->
```prolog
The correctjine procedure has the same basic organisation as check_line, except
that correct_rest_line has no third argument. Instead of returning a yes/no result,
correct_rest_line is in charge of producing as its output the corrected text for the part
of the line starting with the character in its first argument.
    As before, this first argument is the previous character and the second argument
is the current character. Of course, a character can only be echoed unchanged to
the output if the subsequent character has been read and the two don't represent a
known typing error. That means that correct_rest_line only ever outputs the previous
character before moving on.
```

## 5.3 Reading English Sentences

```prolog
We shall now present the program that reads in a sentence typed at the terminal and
converts it to a list of Prolog atoms. The program defines the predicate read_in with
one argument. The program must know when one word of the input ends and the
next begins. In order to know this, it assumes that a word consists of any number of
letters, digits, and special characters.
    Letters and digits are the same as those discussed in Section 2.1, and we will
consider the single quote ""5 and the hyphen '-' to be special characters. Also, the
following characters',''.'';'':''?''!' are taken to form words on their own. Any other
characters just mark space between words. The sentence is deemed to have finished
when one of the words '.', '?', or '!' appears. Upper-case letters are automatically
converted to lower-case, so that the same word always gives rise to the same atom. As
a result of this definition, the program will produce question and answer sequences
like:
    ?- read_in(S).
    The man, who is old, saw Joe's hat.
    S = [the,man//,who,is,old//,saw/joe"s',hat/.']
We have actually inserted extra single-quote characters in this to make it clear that
the punctuation marks are atoms.
    The program uses the predicate get char to read in characters from the terminal.
The trouble with get_char is that, once a character has been read from the terminal
by it, that character has "gone for ever", and no other get_char goal or attempt to re-
satisfy a get_char goal will ever get hold of that character again. So we must avoid
ever backtracking over a use of get_char if we want to avoid losing the character it
```

<!-- page 123 -->
5 Remember that the single quote character is doubled inside the normal quotes for atoms.

```prolog
reads in. For instance, the following program to read in characters and write them
out again, converting a's to b's will not work:
    go :- do_a_character, go.
    do_a_character:- get_char(X), X='a', !, put_char('b').
    do_a_character:- get_char(X), put_char(X).
This is not a particularly good program anyway, because it will run forever. How-
ever, consider the effect of attempting to satisfy the do_a_character goal. If the first
do_a_character rule reads in an X which is not a, backtracking then causes the second
rule to be tried instead.
    However, the get_char(X) goal in the second rule will cause X to be instantiated
to the next character after the one already found. This is because the satisfaction
of the original get_char goal was an irreversible process. So this program would
actually fail to display all the characters. It would even sometimes write out a's.
    How does our read_in program cope with the problem of backtracking over
input? The answer is that we must design it in such a way that it always reads one
character ahead, and makes tests on a character inside a different rule to the one
where it was read. When a character is found somewhere and cannot be used at that
point, it is passed back to the rules that will be able to use it. Hence, our predicate
to do with reading a single word, readword, actually has three arguments. The first is
for the character that was found by whichever rule last satisfied a get_char goal but
could not find a use for the character. The second is for the Prolog atom that will be
constructed for the word. The last argument is for the first character that is read after
the word.
    In order to see where a word ends, it is necessary to read up to the next character
after it. This character must be passed back, because it might provide the valuable
first character of another word. Here then is the program:
    /* Read in a sentence */
    read_in([W|Ws]) :- get_char(C), readword(C, W, CI), restsent(W, Cl, Ws).
    /* Given a word and the character after it, read in the rest of the sentence */
    restsent(W,
                []) :- lastword(W), !.
    restsent(W, C, [Wl|Ws]) :- readword(C, Wl, Cl), restsent(Wl, Cl, Ws).
```

/*

```prolog
 Read in a single word, given an initial character, and
 remembering which character came after the word.
7
readword(C, C, Cl) :- single_character(C), !, get_char(Cl).
```

<!-- page 124 -->
```prolog
readword(C, W, C2) :-
        in_word(C, NewC),
        i
        get_char(Cl),
        restword(Cl, Cs, C2),
        atom_chars(W, [NewC|Cs]).
readword(C, W, C2) :- get_char(Cl), readword(Cl, W, C2).
restword(C,[NewC(Cs], C2) :-
        in_word(C, NewC),
        i •,
        get_char(Cl), restword(Cl, Cs, C2).
restword(C, [], C).
/* These characters can appear within a word. The second
in_word clause converts letters to lower-case */
in_word(C, C) :- letter(C, J . /* a b...z */
in_word(C, L) :- letter(L, C). /* A B...Z */
in_word(C, C) :- digit(C). /* 1 2...9 */
in_word(C, C) :- special_character(C). /* '.' */
/* Special characters */
speciaLcharacter('-').
speciaLcharacter("").
/* These characters form words on their own */
single_character(',').
                         single_character(':').
single_character(7).
                         single_character('?').
single_character(';').
                         single_character('!').
/* Upper and lower case letters */
letter(a, 'A').
                   letter(n, 'N').
letter(b, 'B').
                   letter(o, '0').
letter{c, 'C').
                  letter(p, 'P').
letter(d, 'D').
                   letter(q, 'Q').
letter(e, 'E').
                  letter(r, 'R').
letter(f, 'F).
                  letter(s, 'S').
letter(g, 'G').
                   letter(t, T).
letter(h, 'H').
                   letter(u, 'U').
letter(i, T).
                  letter(v, 'V').
letterQ, 'J).
                  letter(w, 'W').
letter(k, 'K').
                  letter(x, 'X').
```

<!-- page 125 -->
```prolog
    letter(l, 'L').
                      letter(y, T).
    letter(m, 'M').
                       letter(z, T).
    /* Digits */
    digit('O').
                    digit('5').
    digit('l').
                    digit('6').
    digit('2').
                    digit('7').
    digit('3').
                    digit('8').
    digit('4').
                    digit('9').
    /* These words terminate a sentence */
    lastword('.').
    lastword(T).
    lastword('?').
The built-in predicate atom_chars is used here to create an atom from a list of char-
acters (see Section 6.5).
Exercise 5.1: Explain what each variable in the above program is used for.
Exercise 5.2: Write a program to read in characters indefinitely, displaying them
again with a's changed to b's.
```

## 5.4 Reading and Writing Files

```prolog
The predicates previously discussed in this chapter were used only for reading from
or writing to your computer's display, but they are actually more general than that. In
general, a Standard Prolog system will be able to read from and write to streams. A
stream may correspond to your computer keyboard or display or it may correspond
to a file, which is a sequence of characters on a secondary storage medium. The par-
ticular medium depends on your particular computer installation, but nowadays we
usually read and write files that are stored on magnetic discs. It is assumed that each
file has a filename that we use to identify it. In order for this section to be under-
standable, you should be familiar with the conventions for organising and naming
files on your computer. In Prolog, filenames are represented as atoms, but we cannot
rule out the possibility of further installation-dependent restrictions on the syntax of
filenames.
    Files have a certain length. That is, they contain a certain number of characters.
```

`At the end of a file, there is a special marker, called the` *end of file marker.* `We did not`

```prolog
discuss the end of file marker previously, because it is more usual to encounter the
```

<!-- page 126 -->
```prolog
end of file marker on a file than on a computer display. If a program is reading from
a file, the end of file marker can be detected whether the program is reading terms or
characters.
    If a get_char(X) or read(X) encounters the end of a file, X will be instantiated to
the special atom 'end_of_file'6. If an attempt is made to read beyond the end of a
file, an error is generated.
    There is a built-in input stream called userjnput and a built in output stream
called user_output. Setting the current input to be userjnput (the default) causes
input to come from your computer's keyboard, and setting the current output to
user_output (the default) will cause characters to be written on the display. This
is the normal mode of operation. When input is from the computer's keyboard, an
end of file can be generated by typing the end-of-file control character, which will
depend on your computer installation. This will make get_char and read behave as
though the end of a file has been encountered.
```

### 5.4.1 Opening and closing streams

•i `A Standard Prolog` *system recognises a current input stream,* `from which all input is`

```prolog
read. Input returned from get_char and read is taken from the current input stream.
```

`There is also a` *current output stream* `and output produced by put_char and write is`

```prolog
directed to the current output stream.
    The computer terminal's keyboard is normally the current input stream, and the
computer's display is normally the current output stream, but it is possible to change
both of these temporarily whilst your program is running.
    Before a file can be accessed, it is necessary to open a new stream associated
with it. The built-in predicate open is used for this, open is provided with the name
of a file and an atom indicating whether it is to be used for reading or writing in its
first two arguments. It instantiates its third argument to a special term naming the
stream that has been opened. So, for instance,
    ?- open('myfile.pl', read, X).
instantiates X to a term naming a stream which can be used for reading from the file
'myfite.pl'. On the other hand,
    ?- open('output', write, X).
instantiates X to the name of a stream that can be used for writing to the file named
'output'.
```

6 Prolog implementations not following the standard may return other values, but in general

<!-- page 127 -->
there will be some special value indicating the end of a file.

```prolog
    Note that every time you open a new stream associated with a given file, that
new stream starts at the beginning of the file. You can in principle have several
streams open for a single file, but the different streams will be at different places
in the file and it is very unusual to want to achieve this effect. In general you should
ensure that you only have a single stream open at any one time for a given file, which
means that you only call open once, shortly before the very first time you want to
use the file. When a stream is no longer required, either because enough of an in-
put stream has been read or an output stream is complete, the predicate close should
be called to finish everything off nicely. Predicate close is given a single argument,
which is the name of the stream, as was obtained by the original call to open. Thus
the general form of a program that reads from a file would be something like the
following (this will be refined below):
    program :-
            open('myfile.pl', read, X),
            code_reading_from(X),
            close(X).
where code_reading_from(X) is the predicate during whose satisfaction input needs
to be taken from the stream X. Similarly, the general form of a program that writes to
a file is:
    program :-
            open('outpuf, write, X),
            code_writing_to(X),
            close(X).
where code_writing_to(X) is the predicate that does the real work. Notice that
code_reading_from and code_writing_to should not fail, because then their streams
will never be closed. If your definitions for these predicates could possibly fail, then
this should be changed, for instance by adding extra catch-all clauses. In general,
predicates that are reading and writing to files are difficult to debug and so it is a
good idea to test them thoroughly reading and writing from the computer terminal
before using them with files.
```

### 5.4.2 Changing the current input and output

```prolog
The form of the name used for a stream will depend on your Prolog implementation
and for portable programs you should not make any assumptions about its form. In
general, a program that opens a new stream, receiving the name for the stream in X,
will only need to do the following things with X:
```

<!-- page 128 -->
```prolog
 1. Set the current input or output to X for some part of the execution.
 2. Call close with it at the end.
 3. Pass it (through predicate arguments) to any other parts of the program that need
    to do these two things.
Changing the current input and output is done by the built-in predicates setjnput
and set_output. Each of these expects a single argument naming a stream (or it
could be the atom userjnput or user_output). The effect of satisfying such a goal
is to switch the current input to the named stream until the same predicate is called
again. It is important to realise that the current input/output is not switched back if
an attempt is made to resatisfy the goal - such an attempt simply fails.
    Because setjnput and set_output produce irreversible effects, a good program
will take explicit charge of the current input and output at all times and make sure
that they are set appropriately whatever happens (e.g. even if some important goal
fails). In particular, if a program changes the current input or output then it should
reinstate the previous one when it finishes. To do this, it needs to determine what the
current input/output is when it starts.
    The built-in predicates currentjnput and current_output enable this to be
tested. These predicates instantiate their single argument to the name of the current
input/output stream.
    Now that setjnput and currentjnput have been described, it is possible to
show the general form of a program reading from a file in more detail:
    program :-
            open('myfile.pl', read, X),
            currentJnput(Stream),
            setJnput(X),
            code_reading,
            close(X),
            setJnput(Stream).
Notice how code_reading now does not need to depend on X. Since the current input
has been set to X before code_reading is called, it just needs to use get_char and read,
and both of these will produce input from the file. Thus the program implemented by
code_reading can be used at different times to do things with different files.
    Notice also how the pair of goals involving Stream ensure that the current input
is restored afterwards. The general format for a program producing output to a file is
similar:
```

<!-- page 129 -->
```prolog
program :-
        open('outpuf, write, X),
        current_output(Stream),
        set_output(X),
        code_writing,
        close(X),
        set_output(Stream).
```

### 5.4.3 Consulting

```prolog
Reading and writing files is most helpful when our programs deal with more terms
than we care to type in by hand each time we want to put them in the database. In
Prolog, files can be used to store programs. If we have the text of a Prolog program
in a file, reading all of the clauses in the file and putting them into the database is
called "consulting" the file. The Prolog standard leaves it open to individual imple-
mentations to provide convenient ways to "consult" files. In this section, we describe
facilities that will often be available, though this cannot necessarily be relied on. In
Section 7.13 we show how some of these could be defined in Standard Prolog if an
implementation did not provide them.
    Many Prolog systems provide a built-in predicate consult. When X is instanti-
ated to the name of a file, the goal consult(X) will read Prolog clauses and goals from
the file. Most implementations of Prolog also have a special notation for consult,
which allows a list of files to be consulted, one after another. If a list of atoms is
given as a Prolog question, then Prolog will consult each file in the list. An example
of this notation is:
    ?- [filel, mapper, expert].
This behaves as though Prolog were executing a goal consultall(X), where X is the
list that we give the question, and where consultall might be defined as follows:
    consultall([]).
    consultall([H|T]):- consult(H), consultall(T).
However, the shorthand list notation reduces effort, and this is especially important
when one considers that the very first act that the practising Prolog programmer
does is to consult a list of files to make available his or her favourite predicates. The
predicate automatically stops reading clauses when the end of the file is encountered.
Section 6.1 describes consult in more detail.
```

<!-- page 130 -->
## 5.5 Declaring Operators

```prolog
Operators are considered in this "input and output" chapter because operators pro-
vide syntactic convenience when reading or writing terms. There is no other reason
for having operators. Let us first briefly review Section 2.3, and then tell how opera-
tors are declared.
    The Prolog syntax provides for operators, each having three properties: a posi-
tion, precedence class, and associativity. The position can be infix, postfix, or prefix
(an operator with two arguments can go between them; an operator with one argu-
ment can go after or before it). The precedence class is an integer whose range in
Standard Prolog is from 1 to 1200. The precedence class is used to disambiguate
expressions where the syntax of the terms is not made explicit through the use of
brackets. The associativity is to disambiguate expressions in which there are two
operators in the expression that have the same precedence. In Prolog, we associate
a special atom with an operator, which specifies its position and associativity. The
possible specifiers for infix operators are:
    xfx xfy yfx yfy.
To understand these specifiers, it helps to see them as "pictures" of possible uses of
the operators. In the pictures, the letter f represents the operator, and x and y represent
arguments. So in all of the above, the operator must appear between two arguments
that is, it is an infix operator. In accordance with this convention,
    fx fy
are two specifiers for prefix operators (the operator comes before its one argument).
Also,
    xfyf
are possible specifiers for postfix operators. You may be wondering why there are
two letters available for indicating arguments. The choice of x's and y's in these po-
sitions enables associativity information to be conveyed. Assuming that there are no
brackets, a y means that the argument can contain operators of the same or lower
precedence class than this operator. On the other hand, an x means that any opera-
tors in the argument must have a strictly lower precedence class than this operator.
Consider what this means for the operator +, declared as yfx. If we look at
    a + b + c
there are two possible interpretations:
    (a + b) + c or
                   a + (b + c)
```

<!-- page 131 -->
```prolog
The second of these is ruled out, because it requires the argument after the first + to
contain an operator of the same precedence (another +, for example). This contradicts
the presence of an x after the f of the specifier.
    Thus, in particular, an operator declared yfx is left associative. Similarly, an
operator declared xfy is right associative. If we know the desired associativity of an
infix operator we are declaring, this means that the specifier is uniquely determined.
    Note that the meanings of x and y (in terms of what other operators can appear
unbracketed in the relevant position) are the same in all the other cases as well. This
means that, for instance, the sequence
    not not a
is legal syntactically if not is declared as fy, but is illegal if it is declared fx.
    In Prolog, if we wish to declare that an operator with a given position, prece-
dence class, and associativity is to be recognised when terms are read and written,
we use the built-in predicate op. If Name is the desired operator (the atom that we
want to be an operator), Prec the precedence class (an integer within the appropriate
range), and Spec the position/associativity specifier (one of the above atoms), then
the operator is declared by providing the following goal:
    ?- op(Prec, Spec, Name).
If the operator declaration is legal, then the goal will succeed.
    As an example of declaring operators, the following is a list of the most impor-
tant operators that are already defined in Standard Prolog:
    ?- op( 1200, xfx,':-').
    ?- op( 1200, fx,'?-').
    ?- op( 1200, fx,':-').
    ?- op( 1100, xfy,';').
    ?- op( 1000, xfy,',').
    ?- op( 900, fy, V )•
    ?- op( 700, xfx, '=').
    ?- op( 700, xfx,\=).
    ?- op( 700, xfx, '==').
    ?- op( 700, xfx, \== ).
    ?- op( 700, xfx, '=..').
    ?- op( 700, xfx, '<').
    ?- op( 700, xfx, V ).
    ?- op( 700, xfx, '=<').
    ?- op( 700, xfx, W
                     ).
    ?- op( 700, xfx, '@< ).
    ?- op( 700, xfx, '@=<').
```

<!-- page 132 -->
```prolog
?- op( 700, xfx, '@>').
?- op( 700, xfx, '@>=').
?- op( 700, xfx, 'is').
?- op( 500, yfx, V ).
?- op( 500, yfx,'-').
?- op( 400, yfx, '*').
?- op( 400, yfx,'//').
?- op( 400, yfx,'/').
?- op( 400, yfx, 'mod').
?- op( 200, fy, '-')•
```
