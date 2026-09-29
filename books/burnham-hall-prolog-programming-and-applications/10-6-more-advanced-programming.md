# 6 More Advanced Programming

<!-- page 81 -->
**Tools**

In the first five chapters, we have described the features of Prolog which are necessary to allow us to produce working interactive programs. The language has been used only to provide direct interaction between user and terminal. In fact, Prolog provides comprehensive stream and file handling facilities and for serious system development these will almost always be utilised in one way or another.

In addition to that, there are other language features which we have not yet mentioned which allow the programming of more complex processes. Our intention is to use chapters 6, 7 and 8 to introduce the more sophisticated facilities ofthe language in as straightforward a manner as possible. As with any programming language, there is no better way to learn than to experiment with the language features and learn about them in a practical manner. If that involves making a few mistakes it is no great tragedy!

As we have already seen, Prolog implementations contain a selection of system predicates, which handle operations such as input/output, arithmetic and program control. In this chapter we will look at some more system predicates, as well as revisiting some familiar predicates and discussing them in more detail.

## 6.1 Predicates for input and output

<!-- page 82 -->
We have seen that for a Prolog program to communicate with the outside world it must have input and output capabilities. You should already be familiar with the input and output of information between the program and your terminal. This is a special case of the input and output mechanisms that Prolog supports. Prolog communicates with your terminal by treating it as if it were a file, which it is able to write to and read from. Your terminal is designated as the 'USER' file and if no other file is specified all input and output will take place with this file. In general, Prolog will always read from the *current* input stream and write to the *current* output stream. On the DEC-lO Prolog (version 3.47) a total of fourteen I/O streams may be open at anyone time, but input and output will take place only on the current stream, which is not the same as an open stream. W. D. Burnham et al., *Prolog Programming and Applications* © W. D. Burnham and A. R. Hall 1985

To open a me for reading or writing we must first inform the Prolog system that the me is about to become the current input or output stream. We can do this using the clauses see (X) and tell (X) respectively. If the system predicate see is used we are saying that we want to treat the contents of me X as input, Thus if a see instruction is followed by a read instruction the first term in the me referenced by see is read. If X is not instantiated or is instantiated to a mename that does not exist an error will occur. Similarly if we use tell (X) we are saying that we want to treat ftle X as the current output stream. As with the system predicate see, the argument must be instantiated. However if the argument is instantiated to a ftlename that does not exist a me of that name is created. If the argument is instantiated to a ftlename that already exists then the contents of the original ftle will be destroyed. For example if we wish to read from the ftle 'Fred. txt' we would use the predicate see (X) with X instantiated to 'Fred. txt', thus

see ('Fred. txt').

Notice that X must be atomic, so the ftlename is enclosed in quotes.

We have seen how it is possible to open new input and output streams and alter the current output streams using the clauses see (X) and tell (X). To close the current input and output streams the predicates seen and told are used respectively. The clause close (X) may also be used, which closes the ftle X for both input and output. So a simple example using these predicates would be

open_and_c1ose (X, Y) :-see (X), tell (Y), process, seen, told.

where process is a predicate that defines some operation using ftles X and Y.

If at any time we wish to know which file is on the current input or output stream, the clauses seeing (X) and telling (X) may be used respectively. The variable X will be instantiated to the ftle name in both cases.

Now that we can control the assignment of the current input and output streams we are ready to begin reading and writing characters and terms (an atom, integer, variable or structure) on these data streams.

*6.1.1 Character input output* The system predicates used for character input output can be split into two groups, those for use on the current stream and those for use on the user stream. Notice that the predicates used for writing to the current stream can be used for writing to the terminal providing the terminal is the current stream (that is, the user stream). This is in fact how we have used the current stream predicates in previous chapters.

<!-- page 83 -->
*Cu"ent stream predicates* The clauses getf) (X), get (X), put (X), tab (X) and nl all act in the same way as they did in chapter 5, however we know that they now operate on the current stream. (In chapter 5 the user stream was the current stream.)

Another useful predicate is the skip predicate which takes one argument and reads and skips over characters on the current input stream until a character on the stream matches with its argument. It succeeds only once and cannot be resatisfied.

*Terminal (USER) stream predicates* All of the predicates listed below have the same effect as the more general predicates described previously which are not preceded by tty, except that they refer only to the user stream no matter what the current stream is set to. For example, ttynl writes a new line to the user stream, whereas nl writes a new line to the current output stream, which may of course be the user stream. The predicates are used as follows

ttygetf) (X)

ttyput (X)

ttyget (X)

ttytab (X)

ttynl

ttyskip (X)

An additional predicate"that may be used on the user stream is ttyflush. Output to the terminal using either ttyput (X) or put (X) usually goes into an output buffer until a new line is output. Calling this predicate causes any characters in the buffer to be output immediately.

You have now been introduced to the system predicates Prologhas for dealing with characters on both the current and user streams. Let us look at a simple example of some of the above predicates at work.

*Example* Suppose that we have a problem where it is necessary to create two separate files, merge them together into a single file and then output the merged me to the user's terminal. We could proceed using the following program.

```prolog
process (X, Y, Z) :- createJile (X, Y),
                merge (X, Y, Z),
                read_write (Z).
createJile (X, Y) :- writeftle (X), writefile (Y).
writefile (X) :- tell (X), repeat, getf) (N),
            (eof (N) ; put (N», eof (N), told.
eof(26).
eof(36).
merge (X, Y, Z) :- teU (Z), read_write (X), read_write (Y), told.
read_write (X) :- see (X), repeat, getf) (N),
              (eof (N) ; put (N», eof (N), seen.
```

<!-- page 84 -->
The predicate process forms the general description of our problem. That is we create the two files, merge them and output the result to the user stream. The files X and Yare the names of the two files we create which are then merged to form the file Z. The end of file input for the files Sand Y is signified by detecting the $ character on the current input stream (ASCII 36), using the clause eof (N). The end of file when reading files is signified by the"'Z character (ASCII 26). Here is a terminal session using the program.

*Prolog*

*User*

process (,Filet', 'File2', 'File3').

hello $

there !$ 1- I.I' I.I'

**... (session ends)**

hello there! 1-

*6.1.2 Input and output of terms*

In this section we describe the predicates that may be used to input and output Prolog terms. You should already be familiar with the predicates read and write but we will mention them again to reinforce the material we covered using them in chapter 5.

<!-- page 85 -->
write (X) The term instantiated to X is written to the current output stream. read (X) The next term on the current input stream is read in and assigned to X. Note that the term must be delimited by a full stop followed by a space or control character. The delimiting full stop does not become part of the term and is removed from the current input stream. (You may remember from the previous chapter that when you were inputting terms using read you had to follow each term with a full stop and carriage return.) If an invocation of read (X) causes the end of file character to be reached, then X will be instantiated to the term end_oCfile. If a further invocation of read (X) is attempted then an error will occur. display (X) The term to which X is instantiated is displayed on the terminal (user stream), ignoring any operator declarations (see section 6.5). If X is a structure then its predicate is printed first followed by its arguments in parentheses. Note that the user stream does not have to be the current stream. writeq (X) The term that X is instantiated to is written to the current output stream according to the current operator declarations. However the names of the atoms are quoted where necessary to make the result

acceptable to the system predicate read discussed earlier. Thus for

example writeq ('KKK') will result in 'KKK' being output to

the current output stream whereas write ('KKK') will result in KKK

being output on the current output stream. This is important if

you are writing data to a file.

## 6.2 Modifying the database

When you are using Prolog you will probably find that situations will arise where you will want to alter the contents of the database. We have already used the predicates assert, asserta, assertz and retract to modify the database. If we have a large number of clauses to add or remove from the database, using the predicates listed above can become rather cumbersome.

*6.2.1 The abolish predicate*

If you wish to retract all the clauses for a particular predicate you could use retract on all the clauses of that name in the database. However an easier method is to use the clause abolish (X, y), which removes all the clauses with predicate X and arity Y from the database. For example supposing we have the following knowledge base

finance (john, manager, senior).

finance (fred, clerk).

then the goal

abolish (finance, 3).

will remove the assertion finance (john, manager, senior). Correspondingly if the goal abolish (fmance, 2) was set, the clause finance (fred, clerk) would be removed from the knowledge base.

Here is a user-defined predicate retracta11 which performs a similar function.

```prolog
retractall (X) :- retract (X), fail.
retracta11 C).
```

*6.2.2 Altering the database using files*

<!-- page 86 -->
There are two predicates provided to handle the modification of the database using files. These are consult and reconsult, taking a single argument which is the name of a text file containing Prolog clauses. The clause consult (X) causes the Prolog interpreter to read in clauses from the file X (you will probably remember this because it is used to input your program). However it is worth noting that if you already have clauses in the knowledge base, the effect of consult (X) is to insert clauses from the file X into the knowledge base such that clauses with a name identical to clauses already in the knowledge base will appear at the end of the set of clauses with that procedure name. The predicate reconsult works in a similar manner to the consult predicate, except that it removes from the original knowledge base any clauses that have the same name and arity as those being added. To clarify the operation of consult and reconsult consider the following example.

*Example* Suppose that we have two files 'pre.pro' and 'post.pro' containing the clauses shown below.

*file: 'pre.pro'*

make (ford).

make (vauxhall).

make (britishJeyland).

engine ('2 litre').

engine *(,3.5* litre').

engine ('1.6 litre').

```prolog
model (escort) :- engine ('1.6 litre'),
              make (ford).
model (rover) :- engine ('3.5 litre'),
             make (britishJeyland).
```

*file: 'post.pro'*

make (ford).

engine ('2 litre').

```prolog
model (sierra) :- engine ('2 litre'),
              model (ford).
```

If we load in the file 'pre.pro' as our initial knowledge base using consult ('pre. pro'), the effect of consulting or reconsulting the file 'post.pro' is shown below. Notice that the filename is quoted in order to make it atomic.

Using consult ('post.pro') the knowledge base would become

make (ford).

make (vauxhall).

make (britishJeyland).

make (ford).

engine ('2 litre').

engine *(,3.5* litre').

engine ('1.6 litre').

<!-- page 87 -->
engine ('2 litre').

```prolog
model (escort) :- engine ('1.6 litre'),
              make (ford).
model (rover) :- engine ('3.S litre,),
              make (britishJeyland).
model (sierra) :- engine ('2 litre'),
              make (ford).
```

If reconsult ('post.pro') were used then the knowledge base would become

make (ford).

engine ('2 litre').

```prolog
model (sierra) :- engine (,2 litre'),
              make (ford).
```

The predicates consult and reconsult may be used as part of aclause, such that new files can be input while the program is running. Alternatively the predicates can be used at the top level of the Prolog interpreter, that is when the system prompt is showing.

## 6.3 Meta logical predicates

The meta logical predicates provided are a set of system predicates that are concerned with Prolog terms in the knowledge base. They are used to test for certain characteristics and to manipulate the terms. Some of the predicates provided are given below, along with a brief description of their operation.

ancestors

This predicate takes a single argument and instantiates it

to a list which contains all the ancestor goals for the current

clause. The ancestors of a goal are those goals by which it

is called as a sub-goal. For example, suppose we have the

following knowledge base

size (14).

```prolog
find_size (X) :- try_size (X).
try_size (X) :- size (X),
            ancestors (Y),
            write (Y).
```

Then the question find_size (X) will instantiate Y to the list [try_size (14), find_size (14)] and X to 14. The current clause in this case is size (X); it is the clause previous to the call to ancestors (Y).

Succeeds if X is a variable. For example var(X)

```prolog
?-var L12S).
yes
```

<!-- page 88 -->
?-var (alan). no

Succeeds if X is not a variable. nonvar (X)

atom (X)

Succeeds if X is an atom (a non-variable term of arity

zero). For example

?-atom (alan). yes ?-atom (male(alan». no

Succeeds if X is instantiated to an integer. integer (X)

Succeeds if X is instantiated to an atom or an integer. atomic (X) arg (X, Y,Z)

The system predicate arg is one of a group of predicates that

allow the structure and content of Prolog clauses to be

examined. As you can see it takes three arguments. The

first represents the particular argument of a clause in

which we are interested, the second represents the clause

and the third represents the value of the argument so

defined. For example

?-arg (1, married Gohn,jane),john). yes ?-arg (2, append ([], a, [a]), X). X=a yes ?-read (X), arg (1, X, A). ::'controls (security, system_a, condition_red),. X= controls (security, system_a, condition_red) A=security.

functor (X, Y, A)

This system predicate takes three arguments and is also

useful for analysing the structure of Prolog clauses. The

first argument represents the clause, the second the

predicate or operator representing the functor of the clause

and the third the arity of the clause. For example

?-functor (supervises (smith, brown), X, 2). X=supervises ?-functor (is_a (hall, lecturer), is_a, 2). yes

**T=..L**

<!-- page 89 -->
This is a useful Prolog feature which enables us to transform a clause into a list or vice versa. In the example below it is used to tum a statement in English into a Prolog goal

buUd...goal (L, T) :-read (L), entry (V, L), verb (V), entry (Nt, L), noun (Nt), entry (N2, L), \+ (N2=Nt), append ([], V.Lt), append (Lt, Nt, L2), append (L2, N2, L3), T= ..L3. entry (E, [EU). entry (E, UT]) :- entry (E, T). append ([] ,E, [E]). append ([HIX] , E, [HIY]) :- append (X, E, Y). verb (knows). noun (alison). noun (prolog). ?-buUd...goal (L, T). I: [alison, knows, prolog] . L=[alison, knows, prolog] T = knows (alison, prolog)

length (L, N) This predicate instantiates the variable N to the number of elements in the list L.

call (X) This predicate executes the goal X. It has the same function as asking the question X of the knowledge base. For example call (man (Y».

## 6.4 Performing logical tests

The following predicates (operators) are used to perform comparative tests on Prolog terms, in much the same way as the comparative operators used in arithmetic in Prolog.

X == Y The == operator tests to see if the terms X and Yare identical (including the names of variables). For example the test

<!-- page 90 -->
apple (X) == apple (X)

will succeed, whereas the test

apple (X) == apple (Y)

will fail because the variable names are not identical.

X \== Y Tests to see that the terms X and Yare not identical. Thus the test

apple (X) \== apple (Y)

will succeed, and the test

apple (X) \== apple (X)

will fail. X = Y

Tests to see that the terms instantiated to X and Yare equal. If

either X or Yare uninstantiated then the one is instantiated to the

**other. Notice the difference between the =operator and the ==**

**operator. The goal X =Y will succeed, whereas the goal X == Y will**

```prolog
fail.
```

X \= Y Tests to see that the terms X and Yare not equal.

## 6.5 Operators

Imagine that you wish to write down an expression that represents the addition of the integers 2 and 3. You would probably write down 2 + 3. This is the shorthand way of writing the expression described above. What you have actually done is defined an operator + that represents the addition of the integers 2 and 3. You now know what an operator is and the function it performs. However, there are several different categories of operator that may be defined. These are prefix, postfix and infix operators. A prefix operator is placed before its argument, a postfix operator is placed after its argument and an infix operator is placed between its arguments. Some examples are given below.

*Prefix operators*

**-3**

+4

$7

*Infix operators* 2+3

A&B

*Postfix operators* 3!

3j

4%

<!-- page 91 -->
Although we have considered the position of an operator in relation to its arguments this is not enough to completely specify it. We must also consider the question of *associativity* between the operator and its arguments as well as the *precedence* of the operator.

*6.5.1 Operator precedence*

The precedence of an operator tells us which operations to perform first. For example, given the expression

2 + 3/5

you would probably obtain the answer of 2.6. This is because when you were taught mathematics you were told that the operations of multiplication and division have to be performedbefore those of addition and subtraction. In order to ensure that the operations of multiplication and division are performed before those of addition and subtraction they are assigned a lower precedence number. You may however decide to defme your arithmetical functions such that addition is performed before multiplication by assigning the operator for addition a lower precedence number than that for multiplication. Clearly, when we assign the precedence of an operator we have to think carefully of the order in which the operations are to occur. The precedence of an operator is defined by assigning it an integer number. The range will depend on the implementation you are using (for the DEC-lO the range is 1 to 1200). The higher the integer assigned to an operator the greater the precedence of that operator.

*6.5.2 Operator associativity*

There are several possibilities for specifying the associativity of the operators.

The possible specifications for infix operators are

xfx

xfy

yfx

and those for prefix and postfix operators are

xf

yf

fx

fy

where

f is the operator.

x specifies that any operator in the argument x must have a lower

precedence number than the operator f.

y specifies that the argument y can contain operators which have equal

<!-- page 92 -->
or lower precedence numbers than the operator f. *Example*

Suppose we define the multiplication operator *, and division operator / as having associativity yfx and equal precedence, then the expression

is evaluated as

not

**3 * (4/5)**

Notice that the x specifier is the one which allows the meaning of a possibly ambiguous expression to be resolved, since the x terms must always have a lower precedence than the operator f.

*6.5.3 Defining operators*

The system predicate op (X, Y, Z) is used to derme the operator Z, where Y is the associativity of the operator Z, and X is the precedence. For example, the following operator definition could be used to derme the addition operator +

Ifyou should wish to define several operators of the same precedence and associativity, Z may be a list containing those operators. For example

```prolog
:-op (2,." yfx, [+, -, &]).
```

Let us now look at a simple example using an operator to define the factorial operation

```prolog
:-op (3,." xf, 'I').
N! :- factorial (N, y), screen (N, V).
factorial 0',1).
factorial (N, Y) :-M is N-l, factorial (M, G), Y is N*G.
screen (N, Y) :-write (N), write (' ! is'), write 00.
```

<!-- page 93 -->
An example of the above program in use is given below

*User*

4!.

**... (session ends).**

*Prolog*

```prolog
?-
4!is24
?-
```

## 6.6 The Prolog high-level grammor syntax

This syntax is an interesting and useful addition to the Prolog language because it facilitates one of the applications to which Prolog is best suited, that is, natural language processing. Case study 2 given in chapter 8 presents an example of the high-level syntax at work, where it is used in conjunction with a sentence-reading routine {based on a program presented in *How to solve it with* *Prolog* by Helder Coelho, Jose Carlos Cotta and Luis Moniz Pereizo (Laboratoria Nactional de Engenhasia Civil, Lisboa, Portugal» to read sentences in English into the system and classify them. Although the program has no direct application it does form the basis of a much larger system which uses natural language to interface to an Expert Resource Management System (the system is considered much too complex to present as a case study).

The high-level grammar syntax is translated by the Prolog system into Prolog rules and assertions, but it is more convenient to work at the higher level. You should note that not all Prolog implementations support this feature (those that do may vary slightly in their method of implementation, you should consult your User Manual for further details). The examples and discussion used here and in the case study are consistent with the grammar syntax present on the Quintus Prolog implementation.

*6.6.1 Defininga grammor*

If you look at case study 2 you will find specific examples of the grammar syntax at work. However we will start at a fairly simple level by examining the sentence

"the lecturer bores the students"

As you can see this is a very simple sentence, but we could break it down into a noun phrase

"the lecturer"

followed by a verb phrase

<!-- page 94 -->
''bores the students"

The noun phrase then breaks down into a determiner "the" and a noun "man". The verb phrase parses as a verb "eats" and a noun phrase "the meal".

Using sentences with the above simple structure as a basis, we can construct a grammar that can deal with them as follows

sentence -+ np, vp.

np --+ det, noun.

vp --+ verb, np.

Having constructed our simple grammar we must now provide a simple vocabulary, in this instance an extremely small one.

det --+ [the] .

noun --+ [lecturer] .

noun -+ [students]

verb --+ [bores] .

We have now constructed a system that will recognise any valid sentence constructed from the words in the vocabulary. The --+ operator means consists of, and the, operator means followed by. Thus taking the first grammar rule we can see that a sentence consists of a noun phrase followed by a verb phrase. Case study 2 take this idea a little further.

*6.6.2 The phrase predicate*

This is an extremely useful predicate for checking the validity of a given phrase according to the grammar. For example if we set the goal

phrase (sentence, [the, lecturer, bores, the, students]).

the goal will succeed using the above grammar and vocabulary. Similarly,the goals

phrase (np, [the, lecturer] ).

phrase (vp, [bores, the, students]).

willalso succeed, but the goals

phrase (np, [bores, students]).

phrase (vp, [plays, the, piano]).

<!-- page 95 -->
will both fail, in the first instance because the structure conflicts with the grammar rules and in the second because, although the statement is in fact a verb phrase, the words "plays" and "piano" are not in the programmed vocabulary. An interesting experiment you can try is to defme a simple grammar and a small vocabulary and set the goal

phrase (sentence, X).

The system will generate all possible combinations of words in the vocabulary that constitute sentences according to the defined grammar. Be warned however; keep the vocabulary small because immense numbers of valid sentences may be generated from comparatively few words.

You will probably have noticed by now that the grammar handles language structures in the form of lists. This makes a lot of sense because data structures such as "the lecturer bores the students" are unsuitable for all applications other than unintelligent "string handling" operations. Clearly, for serious processing we need a structure that lends itself to the identification and analysis of significant language elements. Lists are excellent for this purpose. Firstly because they allow us to handle the whole sentence as a single argument, and secondly because we can address individual list elements, by means of list manipulation predicates such as those described in chapter 4.

Although the case study uses the grammar syntax to process English sentences, there is no reason why it should be restricted to that context. An interesting idea is to use the grammar to interpret digital signals. Here is an example program written to do this.

signal ~

word, separator, extension.

word --+ digit, word_extension.

extension ~

```prolog
           signal.
extension ~
            [] .
word_extension ~
                word.
word_extension ~
                [] .
separator ~
           [s] .
separator ~
           [t] .
digit ~
       ['1 '].
digit ~ ['tn.
```

Using such a grammar, goals like

phrase (signal, [1, 1,~, 1,1,1, s, 1, 1, 1, s,~,~, 1,~, tn.

phrase (signal, [1, 1,~,~, 1, J', 1,1, tn.

will succeed. This type of idea has some interesting practical applications and a grammar of this type is currently being used in a robotics research project.
