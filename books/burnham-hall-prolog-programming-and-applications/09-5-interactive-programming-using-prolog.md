# 5 Interactive Programming using Prolog

<!-- page 66 -->
In this chapter we are going to examine some of the features of Prolog that allow you to write interactive programs. An interactive program is one that carries on a dialogue with the user and is capable of responding to requests input by the user. In some ways it is rather like carrying on a conversation with another person, and although most computer programs are somewhat more limited in their responses, one of the objectives of the Fifth Generation programme is to build computer systems that can respond to human users in much the same way as another human being would do.

Although Prolog can be used in a variety of ways, some of which require little or no interactive facilities, there is no doubt that most applications of the language are considerably enhanced by the provision of a 'user friendly' interface. The creation of such an interface depends essentially on the ability to do the following

(i) The program should be able to accept input from the user. (ii) The program should be able to respond in a meaningful manner to that

```prolog
input.
```

(iii) The program should be able to output intelligible responses to the user.

Before proceeding with this chapter we would like to point out that we are going to make a considerable leap forward. Our intention in the first four chapters has been to provide you with the 'raw materials' with which you can construct Prolog programs. By the time you have assimilated the content of this chapter you should be able to write complete working programs and you should be ready to proceed to the more advanced uses of the language described in chapters 6, 7 and 8.

## 5.1 Input of information to the program

<!-- page 67 -->
It is necessary at this stage to introduce you to some of the system predicates of the Prolog language. We have seen how it is possible for the programmer to define his or her own predicates. In addition to that facility, Prolog provides a range of system predicates which do not need to be defined by the programmer, but they can be used in the same way as a user-defined predicate. Several of these systempredicates are of use to us in the development of interactive programs. W. D. Burnham et al., *Prolog Programming and Applications* © W. D. Burnham and A. R. Hall 1985 *5.1.1 The read predicate*

This predicate takes one argument, and causes a term to be read from the user's terminal. Thus the goal read (X) always succeeds and has the effect of causing the program to accept a term input from the user terminal. To take a very simple example, suppose we wish to enter the word password to a Prolog program. Here is a small program that will perform this function

get_pass: - read (X), tesCpass (X).

```prolog
tesCpass (password) :- ok.
test_pass (J :- error.
```

(Notice that we have introduced the concept of defining a predicate with no arguments. This can be useful if we do not wish to know any information about the values of the arguments in the body of the rule. It can also be a useful technique to use predicates with no argument to invoke, or in some cases simply label, a procedure or group of procedures.)

Here is the terminal session that could follow (assume that we have defined the predicates ok and error elsewhere in the knowledge base).

*User*

```prolog
                                  geCpass.
                                  password.
        Prolog
?-
```

I: (this is the prompt symbol)

After the input of the word, Prolog would attempt to execute the tesCpass (X) goal. If the word were password the ok goal would be attempted, if anything else were entered then Prolog would attempt to execute the error goal.

You should have noticed from the above example that, on entering the word password, X became instantiated to password and that value was passed over to the second sub-goal of the geCpass goal, which tests to see that the correct word has been input.

In one simple example we have shown how it is possible to have the program accept input from the user and then to respond to the input in a meaningful way. There are other methods available to us to input information to a program but first we will complete the interactive cycle by demonstrating how output from the program to the user can be generated.

## 5.2 Output of information to the user

<!-- page 68 -->
There are several ways in which this can be achieved, but we will start with the most straightforward, the use of another system predicate. *5.2.1 The write predicate*

This takes one term as its argument and causes that term to be written to the user's terminal. Suppose that we wish to input the name of an animal from the terminaland then to output the name of the natural enemy of that animal to the terminal. The program might look something like this

enemy (frog, snake).

enemy (deer, wolf).

enemy (cat, dog).

find_enemy: - read (X), enemy (X, Y), write (Y).

Here is an example terminal session using the above knowledge base

*User*

```prolog
                    find_enemy.
                    deer.
                    find_enemy.
                    frog.
Prolog
1-
I.I·
wolf
1-
I.I·
snake
                    ... (session ends)
```

The program operates as follows. First the user invokes the procedure by typing in the predicate find_enemy. The first sub-goal is read (X) which is used to tell the system which animal it has to find an enemy for. The prompt symbol: : is then generated and the user replies with the response deer, which instantiates X to deer. The second sub-goal is then attempted and matches with the assertion enemy (deer, wolf), so Y is instantiated to wolf. Finally the value to which Y is instantiated is written to the terminal screen.

Obviously, we could achieve a similar result by entering questions in a more rudimentary format, that is enemy (deer, V), and receive the response Y =wolf. However we hope that you will agree that the solution using read and write is more elegant and flexible, not least because it eliminates the rather cumbersome response format of Y = this, that and the other.

*5.2.2 Holding text in the form of a list*

This is useful if we wish to output phrases and sentences to the terminal; it is possible to hold them as list elements and defme a predicate to output the list contents on to the screen. For example, let us defme the predicate screen to perform the above operation.

screen ([]): - !.

```prolog
screen ([HlT]) :- write (H), write ('
                              '), screen (T).
```

<!-- page 69 -->
All that we are saying is that we should output the elements in the list on to the screen, with three spaces between each character.

Here is how we could use it to improve the enemy program (remember from chapter 2 that we can utilise the single quote notation to represent phrases as atoms).

fmd_enemy:- screen ([ 'Please enter the name of an animal.', 'I will then tell you the name of the natural enemy'],

read (X),

enemy (X, V),

write (Y).

Here is how the program would operate.

*Prolog* ?- Please enter the name of an animal

*User*

```prolog
find_enemy.
1will then tell
```

you the name of the natural enemy

```prolog
deer.
```

I.I' wolf

**... (session ends)**

Notice how we have now introduced another dimension to the program in that it now tells the user what he or she has to do to obtain the required information. The only restriction is that it can be awkward to have single quotes as part of the text, so words like don't are problematic.

As our enemy program stands at the moment the answer from the system is a little terse. We get the answer in the form wolf, whereas it would be much more pleasant if the system replied "the natural enemy of the deer is the wolf'. This enhancement poses no problems, we just have to change the find_enemy rule slightly as follows.

find_enemy: - screen (['Please enter the name of the animal.', 'I will then tell you the name of the natural enemy']),

read (X),

enemy (X, V),

screen (['the natural enemy of the 'J),

write (X),

screen ([' is the 'J),

<!-- page 70 -->
write (Y). Here is the program in operation

*Prolog* ?- Please enter the name of an animal.

*User*

```prolog
find_enemy.
```

I will then tell

I.I'

you the name of the natural enemy

```prolog
deer.
```

the natural enemy of the deer is the wolf

**... (session ends)**

## 5.3 Exercise 11

Write a program that will accept the name of a calendar month and tell the user what season of the year the month falls in.

## 5.4 Some more system predicates

*5.4.1 The nl predicate*

This predicate takes no arguments and the name of it is the initial letters of 'new line'. There are often occasions, when writing interactive routines, when it is desirable to be able to space output in order to make it more readable. New line nl causes subsequent output to begin on a new line and can, for example, be used n conjunction with the writepredicate. By way of an example let us see how we could modify our screen predicate to output a user menu on to the screen.

```prolog
screen ([]) :- !.
screen ([H:T]) :- write (H), nl, screen (T).
user_menu :- screen ([
,
```

This is an example of how Prolog can be',

, used to output large quantities of textual information',

, ,,

'The top level user menu is shown below. Please enter your choice and

follow it with a full stop.',

,,

**,,**

USER MENU

ENTER 1 FOR SOMETHING OLD

<!-- page 71 -->
ENTER 2 FOR SOMETHING NEW

ENTER 3 FOR SOMETHING BORROWED

ENTER 4 FOR SOMETHING BLUE

**ENTER YOUR CHOICE ....... .**

,,

**D·**

The screen predicate will now cause each element of the list to be output to the screen, each starting on a new line. To obtain a blank line two new line statements would have to be used, unless a special procedure for spacing such as the one below were to be defined

throw (') :-1.

```prolog
throw (N) :- 01, R is N-l, throw (R).
```

This is a useful spacing procedure in that N is set to the number of space lines required for the text output; for example, throw (3) gives the equivalent of 01 being invoked 3 times.

*5.4.2 The tab predicate*

This can be used in a similar way to nl, to format text output. The predicate takes one argument which must be instantiated to an integer value and it causes the number of space characters specified by the integer to be output. If for example you wanted to place a space either side of a name, tab could be used as follows

tab (1), write (fred), tab (1).

*5.4.3 The get and getD predicates*

These predicates are used to access single characters from the input terminal. The difference between them is that get operates only on printing characters (those that can be made to appear on the screen or printer (ASCII codes 32 or greater», whereas get' can operate on any ASCII character. Both take a single argument. If the argument is instantiated then the goal get (X) (or get., (X» succeeds if the next input character matches that argument and fails if it does not. If the argument is not instantiated, that is get (X) or get' (X), then the argument is instantiated to the value of the next character input.

<!-- page 72 -->
Both get and get., can only succeed once and cannot be resatisfied. Furthermore, they work on the ASCII code of the character, not the character as it appears to the system user. A list of ASCII codes and corresponding characters is given in appendix 3. Here are three examples of these predicates in use

*Prolog*

*User*

```prolog
?-
                             get (X).
I.
                             a
I'
X=97
?-
                             get., (1.,1).
I.
                             a
I'
no
?-
                             get., (98).
I.
                             b
I'
yes
                             ... (session ends)
```

The points to note are as follows. Firstly, the get and get" predicates cause the system to wait for input when the system user is directly interacting with Prolog. In this respect they are similar to the read predicate. Secondly, the predicates deal with ASCII codes, not the characters that they represent. For example the ASCII codes of a and bare 97 and 98 respectively. Also no full stop is required after the character. This is because the full stop is itself a character and the two predicates require only one character for their argument.

There are many ways in which get and get., can be used. As with all Prolog features, the best thing is to experiment with them and adapt their attributes for your own purposes.

*5.4.4 The put predicate*

The put predicate allows the output of a character to the screen. Like get and get." it takes one argument and succeeds only once. The argument (the ASCII code of the character you want to output) must be instantiated before put can succeed. It can be used in conjunction with get to echo characters on to the screen.

```prolog
?-get (X), put (X).
l:a
a
X=97
```

<!-- page 73 -->
In the above example the character a is input in response to the prompt generated by calling get (X). X is then instantiated to 97 (the ASCII code of a) and calling put (97) results in the character a being output. Here is another example which shows how a lower case letter may be echoed to the screen as a capital letter.

*Prolog*

```prolog
?-
                         User
                  get(X), Y is X-
                                32, put(Y).
                  a
I·I'
A
X=97
y= 6S
                  ... (session ends)
```

*5.4.5 The name predicate*

The name predicate can be used to convert ASCII characters to their character equivalents and vice versa. It takes two arguments, the second of which is represented to the system as a list.

There are a variety of uses for the name predicate and here are a few examples of it in operation

```prolog
?-name (a, L).
L= [97]
?- name (X, [97,98,99]).
X= abc
?- name (abc, List).
List = [97,98,99]
```

**As you can see from the above examples it is possible to use the name**

predicate to convert the ASCII representation of characters obtained using get and get~ to their normal character representation.

## 5.5 Exercise 12

Write a program to carry out the following

(i) Read a word from the input terminal, which is not terminated by a full stop

(therefore you cannot use read), but has the end of the word 'signalled by

the input of carriage return. (ii) Output a sentence to the terminal of the format

**"the word just read was ... as you can see"**

<!-- page 74 -->
inserting your word in place of the full stops. *Hints:* Use get4' to read the word character by character (the ASCII code for carriage return is 13), and use the name predicate to convert from ASCII to character format.

## 5.6 Getting Prolog to 'leam'

Although there are many uses for the facilities to be described in this section, they are of great use in the area of interactive programming. An interactive system becomes much more powerful if it can remember what has been said to it. Furthermore, it is necessary on occasions to have the system 'forget' what it has been told. Prolog provides us with the ability to tell the system what it needs to remember and what it needs to forget. Of course, this is a long way removed from the full meaning of the word 'learn' (hence the inverted commas) but it is certainly a necessary part of the learning process and represents an essential building block for intelligent systems.

*5.6.1 The assert predicate*

This predicate takes one argument which must be instantiated to aclause. The effect of assert (X) is to place the clause instantiated to X in the knowledge base. Furthermore, it has two additional formats which provide more control over where the clause is placed in the knowledge base.

asserta (X) - places the clause instantiated to X before any other clauses of the same predicate and number of arguments in the knowledge base.

assertz (X) - places the clause instantiated to X after any other clauses of the same predicate and number of arguments in the knowledge base.

These predicates therefore allow us to add to the knowledge base, in other words to remember additional information. Once an assert goal has been satisfied, the clause remains in the knowledge base until it is removed. Here is a simple example

*User*

asserta (man Gohn».

man (X).

**... (session ends)**

*Prolog*

```prolog
?-
yes ?-
X= john
```

As you can see, the clause man Gohn) has been added to the knowledge base and is immediately available for use thereafter.

Let us take another example. Suppose we wish the system to remember the name of the system user. We could program as follows

introduce:-screen (['Hello what is your name']),

```prolog
          remember.
remember :-read (X), assertz (user_name (X».
```

<!-- page 75 -->
screen ([]): - !

screen ([H T]): - write (H), nl, screen (T).

Here is the program in use

*User*

introduce

```prolog
                              jim.
                              user_name (X).
       Prolog
?-
```

Hello what is your name

I.I'

```prolog
?-
X=jim
```

Although asserta and assertz take only one argument, the clause that represents that argument can be complex. All these are valid assertions

asserta (group (birds, [eagle, finch, canary])).

assertz (worker (surname (jones), initial (p))).

```prolog
assertz «go:- test (X), write (Y))).
```

We will return to the use of assert presently, but first we will discuss the use of the predicate that allows the program to 'forget'.

*5.6.2 The retract predicate*

This also takes one argument, again instantiated to a clausal form, but its effect is to remove clauses from the knowledge base. Once a retract goal has succeeded, the clause referred to is lost from the knowledge base. Here is an example

*Prolog*

*User*

```prolog
?-
                      asserta (man (john)).
yes
?-
                      man (X).
X= john
yes
?-
                      retract (man (john)).
yes
?-
                      man (X).
no
                      ... (session ends)
```

<!-- page 76 -->
In the above example we have retracted a clause which has both the predicate and argument named, that is, man and john. However it is possible to use retract in the situation where only the predicate is named. For example, retract (man (X)). In that situation Prolog will remove the first clause it encounters with the predicate man and one argument. Any further clauses of the same predicate and same number of arguments require retract to be resatisfied before they can be removed. For example

*User*

asserta (man Gohn».

assertz (man (fred».

man (X).

retract (man (X».

man (X).

*Prolog*

1-

yes

1-

yes

1-

X= john

X= fred

yes

1-

X= john

yes

1-

X= fred

no

**... (session ends)**

As you can see, the retract predicate removed only the first assertion of man. You might also care to note that had the second man, fred, been entered using asserta, he would have been placed first in the knowledge base and would have been removed by retract (man (X)).

## 5.7 Generating multiple solutions inside the program

*5.7.1 The fail predicate*

There are many practical programming situations where it is not convenient for alternative solutions to be invoked by typing in the semi-colon; prompt. There is a technique available to us which can allow us to force the program to backtrack even when it has successfully generated a goal solution. This process is based on the system predicate fail, which always fails. Here is an example of the fail predicate in use

```prolog
read_sentence (X) :- read (X), I, entry (W, X), test (W).
test (yes) :- write ('word ''yes'' identified').
test C): - fail.
entry (W, [Wl-1)·
entry (W, LIT) :-entry (W, T).
```

<!-- page 77 -->
In the above example we are reading in a sentence input as a list, identifying each word in it (using entry as defined in chapter 4) and seeing whether the word is yes - if it is we carry out a procedure to write a message to the user, if it is not we want to go back and see whether or not the next word in the sentence is yes. Should the word yes not be present at all we want the procedure to fail. It would be tedious for the user to have to continually prompt for the process to be repeated and so we use fail to ensure that the program is forced to backtrack until it finds the word yes. First let us see the program working and then analyse what is happening

*User*

read_sentence (X).

[please, say, yes] .

*Prolog*

```prolog
?-
I.I·
X = [please, say, yes]
word "yes" identified
                             ... (session ends)
```

This is what has happened to provide the above result:

(1) When the read instruction is encountered, that is, the first sub-goal of read_sentence, the program stops and gives a prompt for the input - that is supplied in the form of the sentence entered as a list.

(2) The second sub-goal of read_sentence is the cut and we will return to that presently; at the moment the cut succeeds and we pass on to the third sub-goal.

(3) The third sub-goal, entry, successfully establishes the word please as a word in the sentence and Wis instantiated to please and passed to the next sub-goal, test.

(4) The first clause of test fails because the word does not have the value yes. Therefore an attempt is made to succeed with the second clause of test and that will succeed for any value of W. Thus the sub-goal fail fails but the effect of fail failing is for read_sentence to fail and backtracking now takes place. Therefore another attempt to succeed with entry takes place which results in Wbeing instantiated to say.

(5) Events (3) and (4) are now repeated until the third word yes is identified. This time fail is not reached and the read_sentence goal has succeeded.

(6) The cut is placed after the read sub-goal in the body of the read_sentence rule to prevent the program running indefmitely should the word yes not be input. The way in which it operates is to prevent an attempt to backtrack to the sub-goal read if the sentence does not contain yes. Were the cut not present the program would prompt for new sentences to be input until the word yes were recognised.

*5.7.2 The true predicate*

We have seen above that it is possible to have a procedure which 'fails' under all conditions. The system predicate true provides the opposite; it succeeds under all conditions.

*5.7.3 The repeat predicate*

<!-- page 78 -->
The predicate repeat always succeeds and can be used to generate an infmite sequence of choices. Once the predicate has succeeded on backtracking, the execution of clauses after repeat in the rule body continues as if they were being executed for the first time, that is, as if no backtracking had taken place.

To make it clear how the repeat predicate works, consider the following knowledge base and terminal session.

tailor Gones).

tailor (smith).

tailor (brown).

```prolog
g (X) :- repeat, tailor (X).
f (X) :- tailor (X).
                                      User
                                      f(X)
                                      g(X).
              Prolog
            ?-
            X= jones
            X= smith
            X= brown
            no ?-
            X= jones
            X= smith
            X=brown
            X = jones
            X = smith
                                       ... (session ends)
```

As you can see, f (X) has three solutions which are elicited by enforcing backtracking using the; prompt. However we can see that when the repeat predicate is encountered on backtracking it succeeds and allows Prolog to start searching the knowledge base from the top again. In so doing it allows an infinite number of solutions to be generated, even though some of them may be duplicated as we have seen here.

*5.7.4 Negation*

During the normal flow of a program, Prolog will only attempt to satisfy a later clause in the body of a rule if the previous goals can be proved true (either directly from assertions in the database or by inference from those assertions). For example, to prove the rule for alpha shown below, the goals b, c, d and e would have to be proved true.

<!-- page 79 -->
a1~ha:-b, c, d, e.

However, it may be more convenient for us to specify a goal in the body of a rule as being true if some assertion or inference from assertions is not true. Referring to the following database

citrus_fruit (X) :-lemon (X).

```prolog
citrus3ruit (X) :- orange (X).
orange (seville)
lemon (lemon).
```

let us now write a rule to specify a sweet fruit, that is, a fruit that is not a citrus fruit. We could write something like

```prolog
sweeCfruit (X) :- citrus3ruit (X), !, fail.
sweet3ruit (J.
```

Here the first rule will fail if X is a citrus fruit and allow no backtracking to find other solutions (the inclusion of the cut prevents this). If X is not a citrus fruit then the second clause will succeed. This is a rather cumbersome way of performing negation and most Prolog implementations will provide a system predicate that performs negation. On the DEC-IO the predicate is \+(X), but on some other versions of Prolog (see the appendixes) the predicate used is not (X), where X in both cases is an assertion in the database or the head of a rule. The goal defined by these negative forms succeeds if the clause which represents the argument to the negation is not provable. So our definition for a sweet fruit may now become

sweeCfruit (X) :-\+ (citrus_fruit (X».

## 5.8 Solutions to exercises

*Exercise 11*

go:-screen ([

'Please enter the name of a calendar month",

'I will tell you which season it falls in']),

read (X), fmd_season (Y, X), output (X, Y).

```prolog
find_season (Y, X) :- season (Y, W), entry (X, W).
output (X, Y) :- screen ([
             ,,
```

, The month of " X,' falls in the season of',

**YD·**

entry (A, [ALD.

```prolog
entry (A, ULD :- entry (A, L).
```

<!-- page 80 -->
screen ([)) :- ! screen ([HIT]) :- write (H), write (' '), screen (T). season (winter, [november, december,january, february)). season (spring, [march, april, may]). season (summer, Uune,july, august)). season (autumn, [september, october)).

The program is invoked by the question go.

*Exercise 12*

go :-go([]). go (Y) :- get., (X),

concatenate (X, Y, Z), !,

(X = 13; go (Z»,

reverse_list (Z, R),

name (y, R),

write (' The word entered was '),

write (Y),

write (' as you can see'), !, fail. reverse_list ([], [)). reverseJist ([HIT] ,P) :- reverseJist (T, Q),

concatenate (Q, [H] ,P). concatenate ([], X, X). concatenate ([HIX], Y, [HIZ)) :- concatenate (X, Y,Z).

The program is started by asking the question go. which causes the recursive definition of go to be entered. The recursion is terminated when carriage return (ASCII code 13) is entered.
