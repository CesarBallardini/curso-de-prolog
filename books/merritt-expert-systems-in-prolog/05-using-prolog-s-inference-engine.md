# Using Prolog's Inference Engine

<!-- page 19 -->
Prolog has a built-in backward chaining inference engine that can be used to partially implement some expert systems. Prolog rules are used for the knowledge representation, and the Prolog inference engine is used to derive conclusions. Other portions of the system, such as the user interface, must be coded using Prolog as a programming language.

The Prolog inference engine does simple backward chaining. Each rule has a goal and a number of sub-goals. The Prolog inference engine either proves or disproves each goal. There is no uncertainty associated with the results.

This rule structure and inference strategy is adequate for many expert system applications. Only the dialog with the user needs to be improved to create a simple expert system. These features are used in this chapter to build a sample application called "Birds", which identifies birds.

In the later portion of this chapter the Birds system is split into two modules. One contains the knowledge for bird identification, and the other becomes "Native" – the first expert system shell developed in the book. Native can then be used to implement other similar expert systems. 2.1 The Bird Identification System

A system which identifies birds will be used to illustrate a native Prolog expert system. The expertise in the system is a small subset of that contained in *Birds of North America* by Robbins, Bruum, Zim, and Singer. The rules of the system were designed to illustrate how to represent various types of knowledge, rather than to provide accurate identification.

### Rule formats

The rules for expert systems are usually written in the form:

```prolog
first premise, and
second premise, and
...
THEN
conclusion
```

The IF side of the rule is referred to as the left hand side (LHS), and the THEN side is referred to as the right hand side (RHS). This is semantically the same as a Prolog rule:

```prolog
conclusion :-
first_premise,
second_premise,
...
```

Note that this is a bit confusing since the syntax of Prolog is really THEN IF, and the normal RHS and LHS appear on opposite sides.

<!-- page 20 -->
*Building Expert Systems in Prolog* The most fundamental rules in the system identify the various species of birds. We can begin to build the system immediately by writing some rules. Using the normal IF THEN format, a rule for identifying a particular albatross is:

```prolog
IF
family is albatross and
color is white
THEN
bird is laysan_albatross
```

In Prolog the same rule is:

```prolog
bird(laysan_albatross) :-
family(albatross),
color(white).
```

The following rules distinguish between two types of albatross and swan. They are clauses of the predicate bird/1:

```prolog
bird(laysan_albatross):-
family(albatross),
color(white).
bird(black_footed_albatross):-
family(albatross),
color(dark).
bird(whistling_swan) :-
family(swan),
voice(muffled_musical_whistle).
bird(trumpeter_swan) :-
family(swan),
voice(loud_trumpeting).
```

In order for these rules to succeed in distinguishing the two birds, we would have to store facts about a particular bird that needed identification in the program. For example if we added the following facts to the program:

```prolog
family(albatross).
color(dark).
```

then the following query could be used to identify the bird:

```prolog
?- bird(X).
X = black_footed_albatross
```

Note that at this very early stage there is a complete working Prolog program, which functions as an expert system to distinguish between these four birds. The user interface is the Prolog interpreter's interface, and the input data is stored directly in the program.

The next step in building the system would be to represent the natural hierarchy of a bird classification system. These would include rules for identifying the family and the order of a bird. Continuing with the albatross and swan lines, the predicates for order and family are:

```prolog
order(tubenose) :-
nostrils(external_tubular),
```

10

<!-- page 21 -->
*Chapter 2 - Using Prolog's Inference Engine*

```prolog
live(at_sea),
bill(hooked).
order(waterfowl) :-
feet(webbed),
bill(flat).
family(albatross) :-
order(tubenose),
size(large),
wings(long_narrow).
family(swan) :-
order(waterfowl),
neck(long),
color(white),
flight(ponderous).
```

Now the expert system will identify an albatross from more fundamental observations about the bird. In the first version, the predicate for family was implemented as a simple fact. Now family is implemented as a rule. The *facts* in the system can now reflect more primitive data:

```prolog
nostrils(external_tubular).
live(at_sea).
bill(hooked).
size(large).
wings(long_narrow).
color(dark).
```

The same query still identifies the bird:

```prolog
?- bird(X).
X = black_footed_albatross
```

So far the rules for birds just reflect the attributes of various birds, and the hierarchical classification system. This type of organization could also be handled in more conventional languages as well as in Prolog or some other rule-based language. Expert systems begin to give advantages over other approaches when there is no clear hierarchy, and the organization of the information is more chaotic.

### Rules for other relationships

The Canada goose can be used to add some complexity to the system. Since it spends its summers in Canada, and its winters in the United States, its identification includes where it was seen and in what season. Two different rules would be needed to cover these two situations:

```prolog
bird(canada_goose):-
family(goose),
season(winter),
country(united_states),
head(black),
cheek(white).
bird(canada_goose):-
family(goose),
season(summer),
country(canada),
head(black),
cheek(white).
```

<!-- page 22 -->
*Building Expert Systems in Prolog* These goals can refer to other predicates in a different hierarchy:

```prolog
country(united_states):- region(mid_west).
country(united_states):- region(south_west).
country(united_states):- region(north_west).
country(united_states):- region(mid_atlantic).
country(canada):- province(ontario).
country(canada):- province(quebec).
region(new_england):-
state(X),
member(X, [massachusetts, vermont, ....]).
region(south_east):-
state(X),
member(X, [florida, mississippi, ....]).
```

There are other birds that require multiple rules for the different characteristics of the male and female. For example the male mallard has a green head, and the female is mottled brown.

```prolog
bird(mallard):-
family(duck),
voice(quack),
head(green).
bird(mallard):-
family(duck),
voice(quack),
color(mottled_brown).
```

**Figure 2.1 shows some of the relationships between the rules to identify birds.**

bird

(laysun_albatross)

(black_footed_albatross)

(trumpeter_swan)

```prolog
family(albatross)
                    family(albatross)
                                           family(swan)
          color(white)
                              color(dark)
                                                     voice(loud)
      family(albatross)
                                      family(swan)
                             order(waterfowl)
  order(tubenose)
          live(at_sea)
                                       neck(long)
                bill(hooked)
                                             color(white)
                                                 flight(ponderous)
```

**Figure 2.1 Relationships between some of the rules in the Bird identification system**

Basically, any kind of identification situation from a bird book can be easily expressed in Prolog rules. These rules form the knowledge base of an expert system. The only drawback to the program is the user interface, which requires the data to be entered into the system as facts.

**12**

**Chapter 2 - Using Prolog's Inference Engine**

<!-- page 23 -->
**2.2 User Interface**

The system can be dramatically improved by providing a user interface which prompts for information when it is needed, rather than forcing the user to enter it beforehand. The predicate ask will provide this functionality.

### Attribute Value pairs

Before looking at ask, it is necessary to understand the structure of the data which will be asked about. All of the data has been of the form: "attribute-value". For example, a bird is a mallard if it has the following values for these selected bird attributes:

Attribute

Value

family

duck

voice

quack

head

green

This is one of the simplest forms of representing data in an expert system, but is sufficient for many applications. More complex representations can have "object-attribute-value" triples, where the attribute-values are tied to various objects in the system. Still more complex information can be associated with an object and this will be covered in the chapter on frames. For now the simple attribute-value data model will suffice.

This data structure has been represented in Prolog by predicates which use the predicate name to represent the attribute, and a single argument to represent the value. The rules refer to attribute-value pairs as conditions to be tested in the normal Prolog fashion. For example, the rule for mallard had the condition head(green) in the rule.

Of course since we are using Prolog, the full richness of Prolog's data structures could be used, as in fact list membership was used in the rules for region. The final chapter discusses a system which makes full use of Prolog throughout the system. However, the basic attribute-value concept goes a long way for many expert systems, and using it consistantly makes the implementation of features such as the user interface easier.

### Asking the user

The ask predicate will have to determine from the user whether or not a given attributevalue pair is true. The program needs to be modified to specify which attributes are askable. This is easily done by making rules for those attributes that call ask.

```prolog
eats(X):- ask(eats, X).
feet(X):- ask(feet, X).
wings(X):- ask(wings, X).
neck(X):- ask(neck, X).
color(X):- ask(color, X).
```

Now if the system has the goal of finding color(white) it will call ask, rather than look in the program. If ask(color, white) succeeds, color(white) succeeds.

The simplest version of ask prompts the user with the requested attribute and value and seeks confirmation or denial of the proposed information. The code is:

<!-- page 24 -->
*Building Expert Systems in Prolog*

```prolog
ask(Attr, Val):-
write(Attr:Val),
write('? '),
read(yes).
```

The read will succeed if the user answers "yes", and fail if the user types anything else. Now the program can be run without having the data built into the program. The same query to bird starts the program, but now the user is responsible for determining whether some of the attribute-values are true. The following dialog shows how the system runs:

```prolog
?- bird(X).
nostrils : external_tubular? yes.
live : at_sea? yes.
bill : hooked? yes.
size : large? yes.
wings : long_narrow? yes.
color : white? yes.
X = laysan_albatross
```

There is a problem with this approach. If the user answered "no" to the last question, then the rule for bird(laysan_albatross) would have failed and backtracking would have caused the next rule for bird(black_footed_albatross) to be tried. The first subgoal of the new rule causes Prolog to try to prove family(albatross) again, and ask the same questions it already asked. It would be better if the system remembered the answers to questions and did not ask again.

### Remembering the answer

A new predicate, known/3 is used to remember the user's answers to questions. It is not specified directly in the program, but rather is dynamically asserted whenever ask gets new information from the user.

Every time ask is called it first checks to see if the answer is already known to be yes or no. If it is not already known, then ask will assert it after it gets a response from the user. The three arguments to known are: yes/no, attribute, and value. The new version of ask looks like:

```prolog
ask(A, V):-
known(yes, A, V),  % succeed if true
!.  % stop looking
ask(A, V):-
known(_, A, V),  % fail if false
!,
fail.
ask(A, V):-
write(A:V),  % ask user
write('? : '),
read(Y),  % get the answer
asserta(known(Y, A, V)),  % remember it
Y == yes.  % succeed or fail
```

The cuts in the first two rules prevent ask from backtracking after it has already determined the answer.

There is another level of subtlety in the approach to known. The ask predicate now assumes that each particular attribute value pair is either true or false. This means that the user could respond with a "yes" to both color:white and color:black. In effect, we are

14

<!-- page 25 -->
*Chapter 2 - Using Prolog's Inference Engine* letting the attributes be multi-valued. This might make sense for some attributes such as voice but not others such as bill, which only take a single value.

The best way to handle this is to add an additional predicate to the program, which specifies the attributes that are multi-valued:

```prolog
multivalued(voice).
multivalued(feed).
```

A new clause is now added to ask to cover the case where the attribute is not multi-valued (and therefore single-valued) and already has a different value from the one asked for. In this case ask should fail. For example, if the user has already answered yes to size - large then ask should automatically fail a request for size - small without asking the user. The new clause goes before the clause which actually asks the user:

```prolog
ask(A, V):-
not multivalued(A),
known(yes, A, V2),
V \== V2,
!,
fail.
```

### Menus for the user

The user interface can further be improved by adding a menu capability that gives the user a list of possible values for an attribute. It can further enforce that the user enter a value on the menu.

This can be implemented with a new predicate, menuask. It is similar to ask, but has an additional argument which contains a list of possible values for the attribute. It would be used in the program in an analogous fashion to ask:

```prolog
size(X):-
menuask(size, X, [large, plump, medium, small]).
flight(X):-
menuask(flight, X, [ponderous, agile, flap_glide]).
```

The menuask predicate can be implemented using either a sophisticated windowing interface, or by simply listing the menu choices on the screen for the user. When the user returns a value it can be verified, and the user reprompted if it is not a legal value.

A simple implementation would have initial clauses as in ask, and have a slightly different clause for actually asking the user. That last clause of menuask might look like:

```prolog
menuask(A, V, MenuList) :-
write('What is the value for'), write(A), write('?'), nl,
write(MenuList), nl,
read(X),
check_val(X, A, V, MenuList),
asserta( known(yes, A, X) ),
X == V.
check_val(X, A, V, MenuList) :-
member(X, MenuList),
!.
check_val(X, A, V, MenuList) :-
write(X), write(' is not a legal value, try again.'), nl,
menuask(A, V, MenuList).
```

<!-- page 26 -->
*Building Expert Systems in Prolog* The check_val predicate validates the user's input. In this case the test ensures the user entered a value on the list. If not, it retries the menuask predicate.

### Other enhancements

Other enhancements can also be made to allow for more detailed prompts to the user, and other types of input validation. These can be included as other arguments to ask, or embodied in other versions of the ask predicate. Chapter 10 gives other examples along these lines. 2.3 A Simple Shell

The bird identification program has two distinct parts: the knowledge base, which contains the specific information about bird identification; and the predicates that control the user interface.

By separating the two parts, a shell can be created, which can be used with any other knowledge base. For example, a new expert system could be written that identifies fish. It could be used with the same user interface code developed for the bird identification system.

The minimal change needed to break the two parts into two modules is a high level predicate that starts the identification process. Since in general it is not known what is being identified, the shell will seek to solve a generic predicate called top_goal. Each knowledge base will have to have a top_goal, which calls the goal to be satisfied. For example:

```prolog
top_goal(X) :- bird(X).
```

This is now the first predicate in the knowledge base about birds.

The shell has a predicate called solve, which does some housekeeping and then solves for the top_goal. It looks like:

```prolog
solve :-
abolish(known, 3),
define(known, 3),
top_goal(X),
write('The answer is '), write(X), nl.
solve :-
write('No answer found.'), nl.
```

The built-in abolish predicate is used to remove any previous knowns from the system when a new consultation is started. This allows the user to call solve multiple times in a single session.

The abolish and define predicates are built-in predicates that respectively remove previous knowns for a new consultation, and ensure that known is defined to the system so no error condition is raised the first time it is referenced. Different dialects of Prolog might require different built-in predicate calls.

In summary, the predicates of the bird identification system have been divided into two modules. The predicates in the shell, called *Native*, are:

- solve – starts the consultation;

- ask – poses simple questions to the users and remembers the answers;

16

<!-- page 27 -->
*Chapter 2 - Using Prolog's Inference Engine*

- menuask – presents the user with a menu of choices;

- supporting predicates for the above three predicates.

The predicates in the knowledge base are:

- top_goal – specifies the top goal in the knowledge base;

- rules for identifying or selecting whatever it is the knowledge base was built for (for example bird, order, family, and region);

- rules for attributes that must be user supplied (for example size, color, eats, and wings);

- multivalued – defines which attributes might have multiple values.

To use this shell with a Prolog interpreter, both the shell and the birds knowledge base must be consulted. Then the query for solve is started.

```prolog
?- consult(native).
yes
?- consult('birds.kb').
yes
?- solve.
nostrils : external_tubular?
...
```

### Command loop

The shell can be further enhanced to have a top level command loop called go. To begin with, go should recognize three commands:

- load – Load a knowledge base.

- consult – Consult the knowledge base by satisfying the top goal of the knowledge

```prolog
base.
```

- quit – Exit from the shell.

The go predicate will also display a greeting and give the user a prompt for a command. After reading a command, do is called to execute the command. This allows the command names to be different from the actual Prolog predicates that execute the command. For example, the common command for starting an inference is consult; however, consult is the name of a built-in predicate in Prolog. This is the code:

```prolog
go :-
greeting,
repeat,
write('> '),
read(X),
do(X),
X == quit.
greeting :-
write('This is the Native Prolog shell.'), nl,
write('Enter load, consult, or quit at the prompt.'), nl.
do(load) :-
load_kb,
!.
do(consult) :-
solve,
!.
```

<!-- page 28 -->
*Building Expert Systems in Prolog*

```prolog
do(quit).
do(X) :-
write(X),
write('is not a legal command.'), nl,
fail.
```

The go predicate uses a repeat fail loop to continue until the user enters the command quit. The do predicate provides an easy mechanism for linking the user's commands to the predicates that do the work in the program. The only new predicate is load_kb, which reconsults a knowledge base. It looks like:

```prolog
load_kb :-
write('Enter file name: '),
read(F),
reconsult(F).
```

Two other commands that could be added at this point are:

- help – provide a list of legal commands;

- list – list all of the knowns derived during the consultation (useful for debugging).

This new version of the shell can either be run from the interpreter as before, or compiled and executed. The load command is used to load the knowledge base for use with the compiled shell. The exact interaction between compiled and interpreted Prolog varies from implementation to implementation. Figure 2.2 shows the architecture of the *Native* shell.

User Interface

go

ask

menuask

Inference Engine

solve

load

Knowledge Base

Working Storage

known

top_goal

rules

multi_valued

askable

*Figure 2.2 Major predicates of Native Prolog shell*

Using an interpreter the system would run as follows:

```prolog
?- consult(native).
yes
?- go.
This is the native Prolog shell.
Enter load, consult, or quit at the prompt.
>load.
Enter file name: 'birds.kb'.
```

18

<!-- page 29 -->
*Chapter 2 - Using Prolog's Inference Engine*

```prolog
>consult.
nostrils : external_tubular ? yes.
...
The answer is black_footed_albatross
>quit.
?-
```

### A tool for non-programmers

There are really two levels of Prolog, one which is very easy to work with, and one which is a little more complex.

The first level is Prolog as a purely declarative rule based language. This level of Prolog is easy to learn and use. The rules for bird identification are all formulated with this simple level of understanding of Prolog.

The second level of Prolog requires a deeper understanding of backtracking, unification, and built-in predicates. This level of understanding is needed for the shell.

By breaking the shell apart from the knowledge base, the code has also been divided along these two levels. Even though the knowledge base is in Prolog, it only requires the high level understanding of Prolog. The more difficult parts are hidden in the shell.

This means the knowledge base can be understood with only a little training by an individual who is not a Prolog programmer. In other words, once the shell is hidden from the user, this becomes an expert system tool that can be used with very little training. 2.4 Summary

The example shows that Prolog's native syntax can be used as a declarative language for the knowledge representation of an expert system. The rules lend themselves to solving identification and other types of selection problems that do not require dealing with uncertainty.

The example has also shown that Prolog can be used as a development language for building the user interface of an expert system shell. In this case Prolog is being used as a full programming language.

## Exercises

2.1

In *Native*, implement commands to provide help and to list the current "known"s. 2.2

Have menuask print a numbered list of items and let the user just enter the number

of the chosen item. 2.3

Modify both ask and menuask to recognize input from the user which is a

command, execute the command, and then re-ask the question. 2.4

Add a prompt field to ask which allows for a longer question for an attribute. 2.5

Modify the system to handle attribute-object-value triples as well as attribute-value

pairs. For example, rules might have goals such as color(head, green), color(body,

green), length(wings, long), and length(tail, short). Now ask will prompt with

both the object and the attribute as in "head color?". This change will lead to a more

natural representation of some of the knowledge in a system as well as reducing the

number of attributes. 2.6

Use the *Native* shell to build a different expert system. Note any difficulties in

implementing the system and features that would have made it easier.

*Building Expert Systems in Prolog*

