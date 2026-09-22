------------------------------------------------------------------------

# 1. Getting Started

Prolog stands for PROgramming in LOGic. It was developed from a foundation of logical theorem proving and originally used for research in natural language processing. Although its popularity has sprung up mainly in the artificial intelligence (AI) community, where it has been used for applications such as expert systems, natural language, and intelligent databases, it is also useful for more conventional types of applications. It allows for more rapid development and prototyping than most languages because it is semantically close to the logical specification of a program. As such, it approaches the ideal of executable program specifications.

Programming in Prolog is significantly different from conventional procedural programming and requires a readjustment in the way one thinks about programming. Logical relationships are asserted, and Prolog is used to determine whether or not certain statements are true, and if true, what variable bindings make them true. This leads to a very declarative style of programming.

In fact, the term program does not accurately describe a Prolog collection of executable facts, rules and logical relationships, so you will often see term **logicbase** used in this book as well.

While Prolog is a fascinating language from a purely theoretical viewpoint, this book will stress Prolog as a practical tool for application development.

Much of the book will be built around the writing of a short adventure game. The adventure game is a good example since it contains mundane programming constructs, symbolic reasoning, natural language, data, and logic.

Through exercises you will also build a simple expert system, an intelligent genealogical logicbase, and a mundane customer order entry application.

You should create a source file for the game, and enter the examples from the book as you go. You should also create source files for the other three programs covered in the exercises. Sample source code for each of the programs is included in the appendix.

The adventure game is called Nani Search. Your persona as the adventurer is that of a three year old girl. The lost treasure with magical powers is your nani (security blanket). The terrifying obstacle between you and success is a dark room. It is getting late and you're tired, but you can't go to sleep without your nani. Your mission is to find the nani.

Nani Search is composed of

- A read and execute command loop
- A natural language input parser
- Dynamic facts/data describing the current environment
- Commands that manipulate the environment
- Puzzles that must be solved

You control the game by using simple English commands (at the angle bracket (\>) prompt) expressing the action you wish to take. You can go to other rooms, look at your surroundings, look in things, take things, drop things, eat things, inventory the things you have, and turn things on and off.

Figure 1.1 shows a run of a completed version of Nani Search. As you develop your own version you can of course change the game to reflect your own ideas of adventure.

The game will be implemented from the bottom up, because that fits better with the order in which the topics will be introduced. Prolog is equally adept at supporting top-down or inside-out program development.

A Prolog logicbase exists in the listener's workspace as a collection of small modular units, called **predicates**. They are similar to subroutines in conventional languages, but on a smaller scale.

The predicates can be added and tested separately in a Prolog program, which makes it possible to incrementally develop the applications described in the book. Each chapter will call for the addition of more and more predicates to the game. Similarly, the exercises will ask you to add predicates to each of the other applications.

We will start with the Nani Search logicbase and quickly move into the commands that examine that logicbase. Then we will implement the commands that manipulate the logicbase.

Along the way there will be diversions where the same commands are rewritten using a different approach for comparison. Occasionally a topic will be covered that is critical to Prolog but has little application in Nani Search.

One of the final tasks will be putting together the top-level command processor. We will finish with the natural language interface.

[TABLE]

Figure 1.1. A sample run of Nani Search

The goal of this book is to make you feel comfortable with

- The Prolog logicbase of facts and rules
- The built-in theorem prover that allows Prolog to answer questions about the logicbase (backtracking search)
- How logical variables are used (They are different from the variables in most languages.)
- Unification, the built in pattern matcher
- Extra-logical features (like read and write that make the language practical)
- How to control Prolog's execution behavior

### Jumping In

As with any language, the best way to learn Prolog is to use it. This book is designed to be used with a Prolog listener, and will guide you through the building of four applications.

- Adventure game
- Intelligent genealogical logicbase
- Expert system
- Customer order entry business application

The adventure game will be covered in detail in the main body of the text, and the others you will build yourself based on the exercises at the end of each chapter.

There will be two types of example code throughout the book. One is code, meant to be entered in a source file, and the other is interactions with the listener. The listener interactions are distinguished by the presence of the question mark and dash (?-) listener prompt.

Here is a two-line program, meant to help you learn the mechanics of the editor and your listener.

```prolog
mortal(X) :- person(X).
person(socrates).
```

In the Amzi! Eclipse IDE, first create a project for your source files. Select File \| New \| Project on the main menu, then click on 'Prolog' and 'Project', and enter the name of your project, 'adventure'. Next, create a new source file. Select File \| New \| File, and enter the name of your file, 'mortal.pro'. Enter the pro-gram in the edit window, paying careful attention to upper and lowercase letters and punctuation. Then select File \| Save from the menu.

Next, start the Prolog listener by selecting Run \| Run As \| Interpreted Project. Loading the source code in the Listener is called consulting. You should see a message indicating that your source file, 'mortal.pro', was consulted. This message is followed by the typical listener prompt.

```prolog
?-
```

Entering the source code in the Listener is called **consulting**. Select Listener/Consult from the main menu, and select 'mortal.pro' from the file menu. You can also consult a Prolog source file directly from the listener prompt like this.

```prolog
?- consult(mortal).
yes
```

See the documentation and/or online help for details on the Amzi! listener and Eclipse IDE.

In all the listener examples in this book, you enter the text after the prompt (?­), the rest is provided by Prolog. When working with Prolog, it is important to remember to include the final period and to press the 'return' key. If you forget the period (and you probably will), you can enter it on the next line with a 'return.'

Once you've loaded the program, try the following Prolog queries.

```prolog
?- mortal(socrates).
yes
?- mortal(X).
X = socrates.
```

Now let's change the program. First type 'quit.' to end the listener. Go back to the edit window and add the line

```prolog
person(plato).
```

after the person(socrates) line.

Select Run \| Run As \| Interpreted Project to start the listener again with your updated source file. And test it.

```prolog
?- mortal(plato).
yes
```

One more test. Enter this query in the listener.

```prolog
?- write('Hello World').
Hello World
yes
```

You are now ready to learn Prolog.

### Logic Programming

Let's look at the simple example in more detail. In classical logic we might say "All people are mortal," or, rephrased for Prolog, "For all X, X is mortal if X is a person."

```prolog
mortal(X) :- person(X).
```

Similarly, we can assert the simple fact that Socrates is a person.

```prolog
person(socrates).
```

From these two logical assertions, Prolog can now prove whether or not Socrates is mortal.

```prolog
?- mortal(socrates).
```

The listener responds

```prolog
yes
```

We could also ask "Who is mortal?" like this

```prolog
?- mortal(X).
```

and receive the response

```prolog
X = socrates
```

This declarative style of programming is one of Prolog's major strengths. It leads to code that is easier to write and easier to maintain. For the most part, the programmer is freed from having to worry about control structures and transfer of control mechanisms. This is done automatically by Prolog.

By itself, however, a logical theorem prover is not a practical programming tool. A programmer needs to do things that have nothing to do with logic, such as read and write terms. A programmer also needs to manipulate the built-in control structure of Prolog in order for the program to execute as desired.

The following example illustrates a Prolog program that prints a report of all the known mortals. It is a mixture of pure logic from before, extra-logical I/O, and forced control of the Prolog execution behavior. The example is illustrative only, and the concepts involved will be explained in later chapters.

First add some more philosophers to the 'mortal' source in order to make the report more interesting. Place them after 'person(plato).'

```prolog
person(zeno).
person(aristotle).
```

Next add the report-writing code, again being careful with punctuation and upper- and lowercase. Note that the format of this program is the same as that used for the logical assertions.

```prolog
mortal_report:-  
  write('Known mortals are:'),nl,
  mortal(X),
  write(X),nl,
  fail.
```

Figure 1.2 contains the full program, with some optional comments, indicated by the percent sign (%) at the beginning of a line. Load the program in the listener and try it. Note that the syntax of calling the report code is the same as the syntax used for posing the purely logical queries.

```prolog
?- mortal_report.
Known mortals are:
socrates
plato
aristotle
no
```

The final 'no' is from Prolog, and will be explained later.

[TABLE]

Figure 1.2. Sample program

You should now be able to create and edit source files for Prolog, and be able to load and use them from a Prolog listener.

You have had your first glimpse of Prolog and should understand that it is fundamentally different from most languages, but can be used to accomplish the same goals and more.

### Jargon

With any field of knowledge, the critical concepts of the field are embedded in the definitions of its technical terms. Prolog is no exception. When you understand terms such as **predicate**, **clause**, **backtracking**, and **unification** you will have a good grasp of Prolog. This section defines the terms used to describe Prolog programs, such as predicate and clause. Execution-related terms, such as backtracking and unification will be introduced as needed throughout the rest of the text.

Prolog jargon is a mixture of programming terms, database terms, and logic terms. You have probably heard most of the terms before, but in Prolog they don't necessarily mean what you think they mean.

In Prolog the normally clear distinction between data and procedure becomes blurred. This is evident in the vocabulary of Prolog. Almost every concept in Prolog can be referred to by synonymous terms. One of the terms has a procedural flavor, and the other a data flavor.

We can illustrate this at the highest level. A Prolog **program** is a Prolog **logicbase**. As we introduce the vocabulary of Prolog, synonyms (from Prolog or other computer science areas) for a term will follow in parentheses. For example, at the highest level we have a Prolog program (logicbase).

The Prolog program is composed of **predicates** (procedures, record types, relations). Each is defined by its name and a number called **arity**. The arity is the fixed number of **arguments** (attributes, fields) the predicate has. Two predicates with the same name and different arity are considered to be different predicates.

In our sample program we saw three examples of predicates. They are: person/1, mortal_report/0, and mortal/1. Each of these three predicates has a distinctly different flavor.

person/1  
looks like multiple data records with one data field for each.

mortal_report/0  
looks like a procedure with no arguments.

mortal/1  
a logical assertion or rule that is somewhere in between data and procedure.

Each predicate in a program is defined by the existence of one or more **clauses** in the logicbase. In the example program, the predicate person/1 has four clauses. The other predicates have only one clause.

A clause can be either a **fact** or a **rule**. The three clauses of the person/1 predicate are all facts. The single clauses of mortal_report/0 and mortal/1 are both rules.
