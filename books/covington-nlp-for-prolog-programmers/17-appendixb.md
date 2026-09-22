# AppendixB

<!-- page 331 -->
**String Input and Tokenization**

**B.1 THE PROBLEM**

Prolog does not provide the kind of input routine that a natural-language system needs. The Prolog reader expects all its input to be expressed in Prolog syntax, but the users of NLP systems do not necessarily know Prolog. A user should be able to type

How many employees do we have?

and have Prolog process it as the list of atoms

[how,many,employees,do,we,have,'?’]

or something similar. This chapter will present two predicates that solve the problem:

e read_atomics/1, which converts a line of input into a list of atomic terms

[like,this], and

e read_charlists/1, which renders each word as a list of one-character atoms

[{1,1,k,e],[t,h,1i,s]] so that morphological analysis can be performed.

<!-- page 332 -->
Both predicates convert all capital letters to lower case. B.2 BUILT-IN SOLUTIONS

**A few Prologs already provide solutions to this problem. For example, LPA Prolog 0**

the Macintosh has a built-in predicate that puts up a window, prompts the user to type a sentence, accepts the sentence, removes the window, and delivers the result to the Prolog program as a list of atomic terms.

The Quintus Prolog library predicate read_in/1 converts sentences into lists of. atomic terms. Unlike read_atomics, read_in can accept more than one sentence at a time; it doesn’t stop until a sentence ends at the end of the line. For example:

?- read_in(X). This is an example. Notice that reading does not stop until the end of a sentence occurs at the end of a line.

X = [this,is,an,example,.,notice,that,reading,does,not,stop,

until,the,end,of,a,sentence,occurs,at,the,end,of,a,line,’.‘’]

To use read_in in your program, include the directive

:- ensure_loaded(library (read_in)).

at the beginning. Also look at read_sent/1, which is similar to read_in but more customizable.

**B.3 IMPLEMENTING A TOKENIZER**

**A routine that breaks a string into words or other meaningful units (TOKENS) is called a**

TOKENIZER. Fig. B.1 shows a tokenizing input routine that works well in most Prologs.! The tokenizer classifies characters into four types:

e END characters, which mark end of line;

e BLANK characters, which separate words;

@ ALPHANUMERIC characters (letters and digits), which can be part of words; and

e SPECIAL characters (punctuation marks), which are treated as words by themselves.

The predicate char_type/3 performs this classification and also translates capital letters to lower case. It does all its work by examining and manipulating ASCII codes; even the translation to lower case is simply a matter of adding 32 to the code.

The tokenizer itself is a kind of parser; it is deterministic (does not backtrack) and relies on one character of lookahead (because it must see the next character in or-

<!-- page 333 -->
But not Arity Prolog, in which get and get0 receive every keystroke the moment the user types it and do not allow backspacing for corrections. Tokenizers for Arity Prolog are provided on the program disk that goes with this book. They are based on the built-in predicates read_line(FileHandle,T), which reads a line of input into an Arity compact string, and list_text(S,T), which converts a compact string into a list of ASCII codes. The rest of the tokenizer then processes the list. % read_atomics (-Atomics) % Reads a line of text, breaking it into a % list of atomic terms: [this,is,an,example].

read_atomics(Atomics) :read_char(FirstC,FirstT), complete_line(FirstC,FirstT,Atomics).

**% read_char(-Char,**

-Type) % Reads a character and runs it through char_type/3.

read_char(Char,Type) :get0(C), char_type(C,Type,Char).

% complete_line(+FirstC,+FirstT,-Atomics) % Given FirstC (the first character) and FirstT (its type), reads % and tokenizes the rest of the line into atoms and numbers.

complete_line(_,end,[]) :- !.

|

% stop at end

complete_line(_,blank,Atomics) :-

```prolog
% skip blanks
```

read_atomics (Atomics).

complete_line(FirstC,special, [A|Atomics]) :-

```prolog
% special char
```

name (A, [FirstC]), read_atomics (Atomics).

complete_line(FirstC,alpha, [AlAtomics]) :-

```prolog
% begin word
```

complete_word(FirstC,alpha,Word,NextC,NextT), name(A,Word),

% may not handle numbers correctly - see text complete_line(NextC,NextT,

Atomics).

% complete_word(+FirstC,+FirstT,-List,-FollC,-FollT) % Given FirstC (the first character) and FirstT (its type), % reads the rest of a word, putting its characters into List.

complete_word(FirstC,alpha, [FirstC|List],FollC,FollT) :- ! “4 read_char (NextC,NextT), complete_word(NextC,NextT,List,FollC,FollT).

<!-- page 334 -->
Figure B.1 Tokenizing input routine for most Prologs. (Continues on page 320.) complete_word(FirstC,FirstT,[],FirstC,FirstT).

% where FirstT is not alpha

ode

**char_type**

(+Code, ?Type, -NewCode)

Given an ASCII code, classifies the character as de dP oe

‘end’ (of line/file), ‘blank’, ‘alpha’ (numeric), or ‘special’,

and changes it to a potentially different character (NewCode).

oe

UNIX end of line mark

DOS end of line mark

getO end of file code char_type(10,end,10) :- !. char_type(13,end,13) :- !. char_type(-l1,end,-1) :- !.

oe

oe

oe char_type(Code,blank,32) :-

blanks, other ctrl codes

Code =< 32,

\

oe char_type(Code,alpha,Code) :-

digits

48 =< Code, Code =< 57,

char_type(Code,alpha,Code) :-

lower-case letters

oe

97 =< Code, Code =< 122,

Ly

oe char_type(Code,alpha,NewCode) :-

upper-case letters

65 =< Code, Code =< 90,

(translate to lower case)

oe

1 7

NewCode is Code + 32.

30 char_type (Code, special, Code).

$ all others

Figure B.1_

```prolog
cont.
```

der to decide whether the current character is the last one in the word). Accordingly, read_atomics/1 reads the first character and passes it to complete_line. Then complete_line looks at the type of the current character and does one of four things: stops if it is an end character, skips it if it is a blank, calls complete_word if it is alphanumeric, or makes it into a word by itself if it is a special character.

**B.4 HANDLING NUMBERS CORRECTLY**

**We want read_atomics to recognize numbers as numbers; if the user types 253 we**

<!-- page 335 -->
want to get the number 253, not the atom ‘253’. This is important, because sentences typed by the user can contain numeric data (Whose income is over 2500Q?*and the like).

Whether numbers are recognized depends on the behavior of the built-in predicate name/2. In Quintus, Arity, and LPA Prolog, the query

?- name (What,"253").

**does indeed produce the number 253, and all is well. But in ALS Prolog and Expert**

**Systems Limited Prolog-2, name (What ,253) creates the atom ’253’. This is not**

satisfactory.

The solution is to change the last clause of complete_line, so that instead of calling name, it calls our own number-interpreting routine, name_num/2, defined in Fig. B.2.

**% name_num(-AtomOrNumber,**

+String) %

Used in place of name/2 in last clause of complete _line/3 %

in versions of Prolog where name/2 does not recognize numbers.

name_num(Number,String) :-

nonvar (String),

string_number (String,Number) ,

!

name_num(Atom,String) :-

name (Atom, String).

% string_number (+S,-N) %

Converts string to corresponding number, e.g. "234" to 234. %

Fails if S does not represent a nonnegative integer.

string_number(S,N) :-

```prolog
string_number_aux(S,0,N).
```

string_number_aux([D|Digits],Total,Result) :-

```prolog
digit_value(D,V),
NewTotal is 10*Total + V,
string_number_aux(Digits,NewTotal,Result).
```

string_number_aux([],Result,Result).

% digit_value (+Code, -Value) %

Maps ASCII code for a digit ("0"..."9") onto value (0...9).

digit_value(Code,Value) :-

48 =< Code, Code =< 57,

Value is Code - 48.

<!-- page 336 -->
Figure B.2 Substitute for name for Prologs in which name does not recognize numbers.

The algorithm in name_num is very simple: keep a running total (initially 0) accept digits one by one, and each time, multiply the running total by 10 and then add_. the value of the current digit. Thus:

Digit

Total (start)

0

2

**(0x 10)+2 =**

2

5

**(2x10)+5 =**

25

3

**(25x10)+3 =**

253

The first clause of name_num tries to convert every string to a number this way. If the conversion fails, control drops to the second clause, which calls name in the usual way. Thus name_num can handle both numbers and words.

Thus modified, the tokenizer still does not handle numbers that contain a decimal point. Making it do so would require two changes:

e Modifying name_num to accept the decimal point and properly interpret the digits

after it;

e Modifying complete_word to keep the whole number together (right now it

splits "23.4" into [23,’.',4]).

The second of these is the larger change, because it requires two characters of lookahead. Consider the string "2. " (where ,, denotes a blank). The tokenizer cannot decide whether 2 is the last character of a token until it has read not only the period, but also the blank following it. Accordingly, decimal numbers are not implemented here.

More sophisticated tokenizers first gather all the characters of a line into a list, and then use any appropriate parsing algorithm (such as DCGs) to parse the characters into words. This allows as much lookahead as necessary.

**B.5 CREATING CHARLISTS RATHER THAN ATOMS**

For morphological analysis, we want words to appear as lists of characters [{1,i,k,e], [t,h,i,s]] rather than atoms. Fig. B.3 shows a tokenizer that packages them this way. It is similar to the original tokenizer but with minor changes throughout. No attempt is made to handle numbers.

**B.6 USING THIS CODE IN YOUR PROGRAM**

<!-- page 337 -->
The most foolproof way to incorporate any of these predicates into your program is to actually copy the predicate definitions into your file. % read_charlists(-Charlists) %

Reads a line of text, breaking it into a list of lists %

of one-character atoms, [[1,i,k,e],[t,h,i,s]]. % Makes no attempt to recognize numbers.

read_charlists(Charlists) :-

```prolog
read_char(FirstC,FirsttT),
complete_line(FirstC,FirstT,Charlists).
```

% read_char(-Char, -Type) %

Reads a character and runs it through char_type/3.

read_char(Char,Type) :-

```prolog
geto(c),
char_type(C, Type, Char) .
```

% complete_line(+FirstC,+FirstT,-Charlists) % Given FirstC (the first character) and FirstT (its type), %

reads and tokenizes the rest of the line into charlists.

complete_line(_,end,[]) :- !.

°

% stop at end

complete_line(_,blank,Charlists) :-

```prolog
                                                 % skip blanks
! “fF
read_charlists(Charlists).
```

complete_line(FirstC,special, [[A]|Rest]) :-

```prolog
                                                 % special char
! ve
name(A, [FirstC]),
read_charlists(Rest).
```

complete_line(FirstC,alpha, [Word|]Rest]) :-

```prolog
                                                 % begin word
complete_word(FirstC,alpha,Word,NextC,NextT),
complete_line(NextC,NextT,Rest).
```

% complete_word(+FirstC,+FirstT,-List,-Follc,-FollT) %

Given FirstC (the first character) and FirstT (its type), %$

reads the rest of a word, putting its characters into List %

as one-character atoms.

complete_word(FirstC,alpha, [C|List],FollC,FollT) :-

!

```prolog
name(C, [FirstC]),
read_char (NextC,NextT),
complete_word(NextC,NextT,List,FollC,FollT).
```

<!-- page 338 -->
Figure B.3 Tokenizer that produces charlists. (Continues on page 324.) complete_word(FirstC,FirstT,[],FirstC,FirstT).

2 % where FirstT is not alpha

oe

**char_type**

(+Code, ?Type, -NewCode)

Given an ASCII code, classifies the character as

‘end’ (of line/file), ‘blank’, ‘alpha’ (numeric), or ‘special’,

and changes it to a potentially different character (NewCode). ae oe oe

|

ae

t

UNIX end of line mark

DOS end of line mark

getO end of file code

oP

oe char_type(10,end,10) char_type(13,end,13)

!, char_type(-1,end,-1) :- !.

char_type(Code,blank,32) :-

% blanks, other ctrl codes

Code =< 32,

if

digits

oe char_type(Code,alpha,Code) :-

48 =< Code, Code =< 57,

!

.

oe char_type(Code,alpha,Code) :-

lower-case letters

97 =< Code, Code =< 122,

i

upper-case letters

oe char_type(Code,alpha,NewCode) :-

65 =< Code, Code =< 90,

(translate to lower case)

oe

] oe

NewCode is Code + 32.

char_type (Code, special, Code).

```prolog
        % all others
Figure B.3_
         cont.
```

The second most foolproof way is to include, at the beginning of your program file, the goal

:- reconsult (‘filename’)

.

This makes the Prolog system reconsult the specified file every time it consults or reconsults your program. This technique is generally reliable, but it takes time and can get into a loop if you inadvertently create two files that reconsult each other.

_ In Quintus Prolog and in the draft ISO standard, the directive

:- ensure_loaded (‘filename’) .

reconsults the specified file only if it has not already been reconsulted (thus saving time) and does not loop if two files ask for each other.

