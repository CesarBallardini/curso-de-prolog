# 1 Introducing the Language

<!-- page 14 -->
If you are familiar with languages such as Cobol, Pascal or Algol, it may well be that you will find Prolog a little elusive at first. One reason for this is that Prolog does not have to execute a series of procedural steps; it is a declarative language which allows the programmer to make direct statements and assertions about objects and relationships. Furthermore, when writing a Prolog program, the programmer uses the same structure and syntax to create the database which the system will use. Since Prolog is often associated with Expert and Knowledge Based Systems, the database is sometimes referred to as the 'knowledge base'. When a Prolog program has been written, and compiled or interpreted, it is immediately available for questioning - there is an interactive mechanism built into the language which means that no special routines need be programmed to allow the program to be interrogated from the terminal.

Once the initial adjustment to the nature of the language has been made, you will find Prolog to be a powerful and sympathetic language which allows the simple development of systems that would be difficult to program in a procedural language.

The main purpose of this book is to enable the reader to make a successful start with Prolog and to use it in a productive manner. For that reason the philosophical basis of the language and the latest research in its applications are not discussed. However, for those who may be interested in pursuing the matter further, the language is derived from predicate calculus, a discipline of formal logic which in general terms is concerned with the provability of statements, and it is recommended that serious study of the theoretical aspects of the language should begin with an understanding of that discipline.

## 1.1 Writing assertive statements

An assertion (or proposition) is a statement about something which may be true or untrue and as human beings we have the ability to make assertions about anything (the truth of them is a different matter however). Thus, the following are all assertions, some true, some not

John is a programmer

<!-- page 15 -->
Bob and Carol are married to each other W. D. Burnham et al., *Prolog Programming and Applications* © W. D. Burnham and A. R. Hall 1985

The Prime Minister is charming

The Earth is flat

Annageddon is nigh

It is easy to program such assertions in Prolog, and once programmed they form part of the knowledge base of the program. We discuss how the knowledge base can be accessed in section 1.7, but first we will examine how assertions such as the ones above may be programmed.

If we take a very simple example, "John is a programmer", and wish to represent that fact in our knowledge base (perhaps for a personnel registration system), we simply write

programmer Gohn).

Note that the category, programmer, is placed first and the subject of the assertion is bracketed and placed after it. The reason for adopting this convention will become clear as you learn more about the language.

Here are some more simple assertions

boy Gim).

saint (nicholas).

politician Goseph).

traitor Gudas).

prime_minister (wilson).

prime_minister (thatcher).

There is one important point that needs to be emphasised from the outset: the programmer has complete control over the truth and relevance of the assertions made. There is no mechanism that can check for or correct inconsistent statements such as

woman (popejohn).

## 1.2 Syntax requirements

Although the syntax requirements for Prolog are generally straightforward and easy to learn, there are certain rules that need to be observed. Note the following

(i) No capital letters are used. In Prolog, capitals have a special significance

(see section 1.5). When programming assertions at the moment use lower

case letters only. (ii) The two parts of the statement (known as the predicate and the arguments)

<!-- page 16 -->
are separated from each other by brackets. The arguments are bracketed. (iii) Each assertion must terminate with a full stop. Common sense tells us that

Prolog must have some way of knowing when an assertion is complete and

the full stop provides that. (iv) You will notice that where a predicate is composed of more than one word

(for example, prime minister), then when it is written in the assertion the

words are separated by the underline character. The reason for this is that

both obvious ways of separating two words, that is using a hyphen or a

space, are inadmissible in Prolog. Although in general terms spaces are

ignored in Prolog syntax, they are not permitted to appear in predicates

or arguments, which require an unbroken string of characters. The hyphen

command cannot be used as it is reserved for another use (see chapter 3).

Remember, therefore, to separate with the underline character, for example

fJrSCclass

northern_dancer

john_smith

## 1.3 More complex statements

The examples given in section 1.1 are assertions which express the relationship "is" about a single subject. For instance, the assertion programmer (john) can be translated to "john is a programmer". However, it is possible to program assertions about more complex relationships between two or more objects or individuals. Suppose we wish to extend our information about john the programmer to include a reference to his employer, Software pIc. We can make the assertion

employs (software_p_tc,john).

We have now established the relation of employment between two separate entities. Once more, however, it is essential to stress that *the programmer is* *in control of the meaning of the assertion and its accuracy.* We have chosen to represent the assertion "Software pIc employs John" in the most straightforward way, but the relationship could have been expressed just as well by stating

employer (john, software_pJ_c).

that is, "the employer of John is Software pIc" - it depends entirely on how the programmer wishes to represent assertions. Note how the order in which the arguments of the clause are written is flexible and can be altered to give a more precise meaning to the assertion.

Here are some more assertions which represent relationships between two or more entities

father (john, michael).

<!-- page 17 -->
"the father of John is Michael"

married (jack, mavis).

parents (george, jack, mavis).

pet (tommy, angela, bill).

"Jack and Mavis are a married couple"

"the parents ofGeorge are Jack and Mavis"

"Tommy is the pet of Angela and Bill"

Note that when there are two or more arguments referred to in the assertion they must be separated by a comma. Thus the assertion

father (john michael).

is incorrectly stated because the comma has not been inserted.

## 1.4 Exercise 1

Write these assertions as Prolog statements.

(i) "Joey is a canary" (ii) "the father of Mary is Paul" (iii) "the sire of Nijinsky is Northern Dancer" (iv) "the Father of John is Michael" and "the father of Jane is Michael"

(Here there are two separate statements but their meanings should be

compatible.)

(v) "John, Paul, George and Ringo were the Beatles"

## 1.5 Formulating rules

Although it is essential to be able to state assertions in the way described, the power of Prolog becomes greatly extended when rules are formulated, for it is rules which allow the inference mechanism of the language to operate. We stated earlier that capital letters have a special Significance in Prolog - they are used to express *variables.*

When we move from making assertions to formulating rules we are effectively moving from the specific to the general and we need, therefore, to utilise a notation that allows us to represent variables. There is a Significant difference between the statements "John is a programmer" and "a person who is skilled in one or more computer languages and is employed in that capacity is a programmer". The former establishes an item of information about one person whereas the latter offers us a workable definition of programmer into which we may fit a large number of individuals. Moreover, we know that any individual who is both skilled in a language and employed in that capacity is a programmer according to our requirements. The example is fairly trivial but the underlying concept is most important.

<!-- page 18 -->
Look at a few examples of simple rules. They will allow us to discuss the important ideas associated with each rule formulation.

(i) computer_technician (X):-programmer (X). (ii) programmer (X):-skilled_in_prolog (X), employed (X). (iii) man(X) :- male (X), adult (X). (iv) boy (X) :- male (X), child (X).

(v) married (X, Y) :- wife (X, Y). or

```prolog
married (X, Y) :- husband (Y, X).
```

To an experienced Prolog programmer the above rules are simple and straightforward. Nonetheless, there are a number of very important points that can be learned from examining them. We will take each rule in turn and highlight what can be learned from it.

*Example* (i)

Here we are stating a rule about a sub-category of computer technicians: programmers. Now although all programmers are computer technicians the reverse is not the case, there are many technically skilled people in the computer industry who are not employed as programmers (for example, operators, support engineers, designers, etc.). Programmers therefore represent a subset of computer technicians and our rille states that if we can find an entity that is a programmer then we have also found an entity that is a computer technician. *Note the syntax:*

(a) The variable is enclosed in brackets.

(b) The same variable appears on both sides of the rule.

(c) Although X is used as the variable in this case, anything beginning with a

capital letter could have been used. For example

computer_technician (Someone):-programmer (Someone).

(d) The two parts of the rule are separated by the inference symbol:- which

for the purpose of introducing the basic language structure may be taken to

mean 'if'. You should be aware however that 'if' in this context is used

somewhat differently from its use in a conventional (that is, procedural)

language where it wiU typically be associated with an 'if-then' sequence of

program instructions. We do not need to concern ourselves too much with

this distinction at present but it will become more significant as we intro-

duce advanced Prolog constructs in later chapters. For example

computer_technician (X):-programmer (X).

can be taken to mean

<!-- page 19 -->
"X is a computer technician 'if' X is a programmer"

(e) The rule must terminate with a full stop.

(f) The wider category, that is, computer technician, appears on the left side

of the :- symbol. This is important because if we were to reverse the order,

the rule would be saying that all computer technicians are programmers

and would be untrue.

*Example (ii)*

In the second example we are introducing a definition which features two components on the right-hand side of the rule, that is, a person who is skilled in a language (in this example Prolog) *and* is employed, is a programmer. *Note the* *use of the comma which means 'and' in Prolog rule formulation.*

*Examples (iii) and (iv)*

Here are two rules that define men and boys by finding entities that are males and adults or children respectively.

*Example (v)*

Just as assertions can state relationships between one or more entities, so can rules. Here we have two ways of defining the relationship married between two individuals.

The first rule states that "X and Yare married (to each other) 'if' the wife of X is Y".

The alternative rule states that "X and Y are married (to each other) 'if' the husband of Y is X".

A very important point to be noted is that if the two rules about marriage are to be compatible, then the order in which the variables are written is Significant. Although it would be syntactically correct to write the two rules about marriage shown below, they are in fact mutually exclusive in that both rules cannot be applied to the same couple

married (X, Y) :-wife (X, V).

```prolog
married (X, Y) :- husband (X, V).
```

That is, the statements "the wife of X is Y" and "the husband of X is Y" cannot possibly apply to the same couple because both X and Y would each have to represent the wife and the husband.

## 1.6 Exercise 2

<!-- page 20 -->
Formulate rules to express the following

(i) A defInition of a dog as a domesticated animal. (ii) All lizards are reptiles. (iii) Separate definitions of woman and girl which have part of the definition

in common. (iv) Two compatible rules which express the concept of one person owing

money to another, using the relationships 'debtor' and 'creditor'.

## 1.7 Building and questioning a knowledge base

By programming a combination of assertions and rules it is possible to create a knowledge base which is then immediately available for questioning. (At this point you will need to consult appendix I or 2 or your User Reference Manual to commence running Prolog on your system.)

One of the most attractive features of Prolog is that you do not need to program the interactive mechanism that allows the knowledge base to be questioned - it is an intrinsic part of the language. In order to demonstrate how to question a knowledge base we will construct several simple examples.

First take an example that consists solely of assertions.

lizard (iguana).

snake (adder).

mammal (rabbit).

marsupial (kangaroo).

fish (shark),

As you can see, we have some very simple assertions about living creatures. Once the appropriate action (which as we have indicated varies slightly for different systems) has been taken to enter the above program it forms the knowledge base which can then be questioned. In order to show how this is done the outputs from the Prolog system are shown on the left, and the inputs to the system by the user are shown on the right. The first interaction is a question prompt from Prolog

*Prolog*

*User*

```prolog
?-
                  lizard (iguana).
yes
?-
                  lizard (toad),
no
?-
                  marsupial (kangaroo).
yes
?-
                  .,, (session ends)
```

<!-- page 21 -->
*Points to note*

(a) The questions posed by the user are written in the same format as the coded assertions, that is, in lower case letters terminating with a full stop.

(b) The questions posed in the first session are asking Prolog to confirm or deny (yes or no) the truth of those statements. As you can see, the user asks in turn "is it true that an iguana is a lizard"?, "is it true·that a toad is a lizard"?, and "is it true that a kangaroo is a marsupial"? The answers from Prolog are "yes", "no" and "yes" respectively. They are, of course, the responses that we would expect to get by inspecting the knowledge base.

Using the same small knowledge base, we will now use a different questioning technique.

*Prolog*

*User*

lizard (X).

(enter carriage return)

mammal (Mammal).

primate (X).

**... (session ends)**

```prolog
?-
X= iguana
yes
?-
Mammal = rabbit
yes
?-
no
?-
```

*Points to note*

(a) Once again, the question formats resemble the Prolog statements, but this time we have used a variable as the argument inside the brackets.

(b) We are now widening the scope of our system by asking it not to confirm or deny something, but to find some information for us. The questions asked this time are of the format "give me an example of a lizard", "give me an example of a mammal" and "give me an example of a primate". The reason why the variable has to be used is that we do not have a specific solution in mind when we ask the question; we are asking the system to provide that answer. In other words, we are asking it to find a value for the variable that makes the statement true. In this case it 'knows' of only one lizard, hence the answer X =iguana. Similarly, it 'knows' of only one mammal, and it 'knows' of no primates.

When questioning in this format any variable may be used. Thus we could have asked any of the following questions and received the same answer.

<!-- page 22 -->
lizard (X). lizard (Lizard). lizard (A). You will have noted from the examples so far that the knowledge base as we have written it could provide only a single answer to the questions posed. For example, the question

```prolog
?-make (X).
```

has only one possible response, that is X = adder, from the knowledge base provided.

However, another great strength of Prolog is the ability of the language to find all possible solutions to a given question. For instance, if we were to increase our knowledge base by adding one more assertion

make (cobra).

you can see that there are now two values that can provide an answer to the question

snake (X).

The next example session shows how the user may try to extract multiple answers to the questions.

*User*

snake (X).

**... (session ends)**

*Prolog*

```prolog
?-
X= adder
X= cobra
no
?-
```

*Point to note* After the question "give me an example of a snake", the user enters a semicolon. In this situation it means, in effect, "find another solution". In the example, the system finds two solutions, adder and cobra, but when asked for a third solution it cannot find one and it therefore returns the answer, no.

So far, we have only questioned assertions which express very simple concepts, such as, "an adder is a snake", "a rabbit is a mammal" and so on. Now we shall add some further assertions to the knowledge base, which express the concept that some living creatures prey on others.

prey (adder, frog).

prey (cobra, frog).

prey (cobra, rat).

<!-- page 23 -->
prey (cobra, adder). Using the previous examples as a basis for understanding, we will conduct an example session involving the new assertions listed above.

*Prolog*

*User*

prey (cobra, rat).

prey (cobra, Prey). ?yes ?-

prey (Predator, Prey).

prey (predator, frog).

**... (session ends)**

Prey = frog Prey = rat Prey = adder no ?- Predator = adder, Prey =frog Predator =cobra, Prey = frog Predator =cobra, Prey = rat Predator = cobra, Prey = adder no ?- Predator=adder Predator = cobra no ?-

*Points to note*

(a) The first question is in the confirm/deny format and this time uses two arguments inside the brackets in the question "is it true that cobras prey on rats"?, to which the answer is yes.

(b) The second question prey (cobra, Prey), which admittedly reads like an exhortation to a doomed sinner - is in effect saying "what do cobras prey on?" As you can see, their diet includes frogs, rats and other snakes. Note the use of the semi-colon to elicit those answers.

(c) The third question format uses two variables and is asking the system "what preys on what?" or in paraphrase "tell me about a predator and its prey". Once again the semi-colon prompts all available answers, four of them, which are given with both parts of the question answered, that is both predator and prey are identified.

<!-- page 24 -->
(d) Finally, we reverse the earlier question format and instead of asking what cobras and adders prey on, we ask in effect ''what preys on frogs?" or to put it another way ''what do frogs need to watch out for?". Both types of

snake are partial to the odd frog and so both adder and cobra are returned

as answers.

## 1.8 Introducing rules to the know/edge base

The examples in the previous section were all concerned with questioning a program comprising only assertions. All the information contained was *explicit,* in other words there was no deduction or inference involved in reaching the answers given. However, Prolog is able to carry out more sophisticated processes which do require the use of inference in order to reach conclusions. To activate the inference mechanism of the language it is necessary to introduce rules to the knowledge base. We will now add a new rule to the small knowledge base already used

```prolog
carnivore (X) :- prey (X, V).
```

The above rule states that for X to be a carnivorous creature, X must prey on Y. In this instance the identity of Y is not important, any creature that preys on another must be a carnivore. At present, the above rule is the only one in our knowledge base but we can use it to illustrate how the inference mechanism works.

*User*

carnivore (X).

**... (session ends)**

*Prolog*

```prolog
?-
X= adder
yes
?-
```

*Points to note* Until the last question was posed, every question that has been asked was related directly to an assertion. However, there is no assertion of the type

carnivore (..)

in the knowledge base.

However there is a rule which states that any creature that preys on another is a carnivore. Using that rule, it is then possible to see if there are any creatures that prey on others. Of course, in this case the assertion

prey (adder, frog).

<!-- page 25 -->
gives that information. With the assertion *and* the rule it is possible to *infer* that, since a carnivore preys on another creature, and since an adder preys on a frog, then an adder is a carnivore. Just as we are able to match a rule with an assertion to infer a conclusion, so also is Prolog.

Although the example that has been used to illustrate this idea is a simple one, it is apparent that the mechanism is a powerful one. It is possible to build complex systems based on the ability of Prolog to infer conclusions from assertions and rules. Note also that by doing so we are taking a first step towards representing human reasoning within a computer system.

In chapter 2 there is an analysis of how Prolog goes about answering questions, and the operation of the inference mechanism. For now, we suggest that you familiarise yourself with the ideas we have discussed by doing some programming and then questioning your system. There are some exercises to help you do so.

## 1.9 Exercise 3

**Sid-- (married)-- Doris**

**I**

**(child)/\**

Mike

**Jane-- (married)-- Ron**

**I**

(child)

**/1""**

Percy

Debbie

Justin

(i) Using the relationships married, child, male and female, program the family

tree using assertions only. (li) Based on the assertions programmed in (i), add rules to the knowledge

base which can derme son, daughter, mother and father.

## 1.10 Summary of syntax rules

Using Prolog at a simple level, most of the errors that you make are likely to be because of faulty syntax. In the event of such errors Prolog will 'refuse' to use your program. Here are the main points of syntax to look out for.

(1) Incorrect use of capital letters. Remember that capitals are reserved for

use as *variables* and that anything starting with a capital is taken to be a

variable. For example X, Y, A, What, Something, AI, Xf are all taken to

be variables.

<!-- page 26 -->
(2) Check the use of brackets in assertions and rules. The subject of an assertion must be bracketed as must the variable(s) associated with a rule; for example, cat (tommy). and father (X).

(3) Assertions and rules *must* terminate with a full stop. Failure to add one accounts for a high percentage of errors when the language is first being used.

(4) Inversion of logical meaning is a common error and it is understandable why such mistakes are made. Because the programmer controls the meaning of statements, you need to be clear about what it is you are trying to say. For example, an assertion such as person Gohn). relies on a sensible interpretation based, ultimately, on familiarity with the English language - that is, "John is a person". If on the other hand, you, the programmer, choose that statement to represent "John is a nun whose real name is Sister Margaret", then Prolog cannot stop you doing so but your potential for producing systems that others can use may be rather questionable. Similarly, there is nothing to stop you programming john (person). , as long as the rather inane answer you get when you question the system is acceptable to you.

Much the same applies to formulating rules. As a starting point bear in mind that the dominant part of the rule appears on the *left side.* Thus the rule

dog (X) :- carnivore (X).

is not logically correct; there are many meat-eating animals that are not dogs and you are excluding them. Also be careful of incorrectly mixing variables. The rule

carnivore (X) :- dog (X).

is a correct logical statement because anything that is a dog must also be a carnivore. If however, you program

carnivore (X) :- dog (Y).

achieves nothing because Prolog assumes that two different entities are being referred to. This consistency of variables applies however only within the limits of one statement. If, for instance, you program

parent (X, Y) :- father (X), son (Y).

and then enter the question

<!-- page 27 -->
?- parent (A, B). then the problem does not arise since A matches with X and B matches with Y, so answers can be found to the question (if any exist).

(5) The comma is an importantpart of the language and to summarise: used inside a bracket it separates two or more subjects or variables, for example married (fred, Y). Used outside the brackets it means 'and', for example

parent (X, Y) :- father (X), son (Y).

or

"X is the parent of Y if X is the father 'and' Y is the son".

(6) Here are two syntax elements that you will find useful

(a) *The semi-colon;* has already been encountered as a prompt to ask Prolog to generate an alternative answer to a question (see section 1.7). However, it may also be used in rule formulation to represent 'or'. Take a simple example. Here are two alternative definitions of parenthood

parent (X, Y) :- father (X), child (Y). parent (X, Y) :- mother (X), child (Y).

By using 'or' we can collapse the two statements into one

parent (X, Y) :- (father (X); mother (X», child (Y).

The 'or' statement is bracketed to ensure a complete clarity of meaning. The statement reads "X is the parent of Y if X is the father 'or' X is the mother of Y 'and' Y is a child".

(b) *The underline character* _ is used when a subject requires more than one word to describe it. You cannot use a hyphen or a space, otherwise an error will occur (as discussed earlier). It can also be used to indicate variables - see chapter 2.

## 1.11 Solutions to exercises

*Exercise 1*

(i) canary Goey). (ii) father (mary, paul). (iii) sire (nijinsky, northern_dancer). (iv) father Gohn,michael). father Gane, michael).

<!-- page 28 -->
(v) beatles Gohn, paul, george, ringo). *Note:* The answers to the exercise are just suggestions. Yours may be slightly different since you control the meaning of your assertions.

*Exercise 2*

(i) dog (X) :- canine (X), domesticated (X). (ii) reptile (X) :-lizard (X). (iii) woman (X) :- female (X), adult (X). girl (X) :- female (X), child (X). (iv) owes (Debtor, Creditor) :- debtor (Debtor, Creditor). owes (Debtor, Creditor) :- creditor (Creditor, Debtor).

*Exercise 3*

(i) married (sid, doris). married (ron, jane). child (mike, sid). child (jane, sid). child (percy, ron). child (debbie, ron). child (justin, ron). male (sid). male (ron). male (mike). male (percy). male (justin). female (doris). female (jane). female (debbie).

(ii) You will notice that the assertions programmed above establish the relationship child between the male parent and the child. It is possible to establish the female parent using the simple rule

child (X, Y) :- married (Z, Y), child (X, Z).

Further rules are added to establish other relationships

<!-- page 29 -->
son (X, Y) :- male (X), child (X, Y). daughter (X, Y) :- female (X), child (X, Y). mother (y, X) :- female (X), child (Y, X). father (Y, X) :- male (X), child (Y, X).

Incidentally, there are some more family relationships that can be established by the addition of further rules, and you may care to adapt this example for practical project (i) - see section 1.12.

## 1.12 Practical projects

(i) Program your family tree for the previous three generations. (ii) Design and program a small knowledge base to record details about something of interest to you. For example, if you are interested in horse racing, you could program a knowledge base recording details of the winners of classic races.
