# 1 Tutorial Introduction

<!-- page 15 -->
## 1.1 Prolog

Prolog is a computer programming language. Since its beginnings around 1970, Prolog has been chosen by many programmers for applications of symbolic computation, including:

- relational databases

- mathematical logic

- abstract problem solving

- understanding natural language

- design automation

- symbolic equation solving

- biochemical structure analysis

- many areas of artificial intelligence

<!-- page 16 -->
Newcomers to Prolog find that the task of writing a Prolog program is not like specifying an algorithm in the same way as in a conventional programming language. Instead, the Prolog programmer asks more about which formal relationships and objects occur in the problem, and which relationships are "true" about the desired solution. So, Prolog can be viewed as a *descriptive* language as well as a *prescriptive* one. The Prolog approach is more about describing known facts and relationships about a problem, and less about prescribing the sequence of steps taken by a computer to solve the problem. When a computer is programmed in Prolog, the actual way the computer carries out the computation is specified partly by the logical declarative semantics of Prolog, partly by what new facts Prolog can "infer" from the given ones, and only partly by explicit control information supplied by the programmer.

## 1.2 Objects and Relationships

Prolog is a computer programming language that is used for solving problems that involve *objects* and the *relationships* between objects. When we say "John owns the book", we are declaring that a relationship, ownership, exists between one object "John" and another individual object "the book". Furthermore, the relationship has a specific order: John owns the book, but the book doesn't own John! When we ask the question, "Does John own the book?" we are trying to find out about a relationship. Many problems can be expressed by specifying objects and their relationships. Solving the problem amounts to asking the computer to find out about objects and relationships that can be derived from our program.

Some relationships don't always mention all the objects that are involved. For example, when we say "The jewel is valuable", we are specifying a relationship, called "being valuable", which involves a jewel. We did not mention who finds the jewel valuable, or why. It all depends on what you want to say. In Prolog, when you will be programming the computer about relationships like these, the amount of detail you provide also depends on what you want the computer to accomplish.

This way of talking about objects should not be confused with another popular programming methodology called object-oriented programming. In object-oriented programming, an object is a data structure that can inherit fields and executable methods from a class hierarchy to which the object belongs. Although the origin of objectoriented programming can be traced back to the middle 1960s, it became popular in the 1980s and 1990s with the introduction of Smalltalk-80, C++, and Java, among other languages.

By contrast, Prolog developed along an independent track from the early 1970s, and was inspired by logic programming research. Prolog should not be compared with object-oriented languages such as C++ and Java, because Prolog does a completely different job, and uses the word "object" in a completely different way. Prolog's flexibility means that it is possible to write a Prolog program that interprets a Prolog-like object-oriented language, but that is a different matter. So in Prolog, the word "object" does not refer to a data structure that can inherit variables and methods from a class, but it refers to things that we can represent using terms.

<!-- page 17 -->
Prolog is a practical and efficient implementation of many aspects of "intelligent" program execution, such as non-determinism, parallelism, and pattern-directed procedure call. Prolog provides a uniform data structure, called the *term,* from which all data, as well as Prolog programs, are constructed. A Prolog program consists of a set of clauses, where each clause is either a fact about the given information or a rule about how the solution may relate to or be inferred from the given facts. Thus, Prolog can be seen as a first step towards the ultimate goal of programming in logic. In this book we shall not be concerned greatly with the wider implications of logic programming nor with why Prolog is not the ultimate logic programming language. Instead, we will be concerned with showing how useful programs can be written using the Standard Prolog systems that exist today.

There is one more point of philosophy to mention, then we shall begin programming. We are all familiar with using rules to describe relationships between objects. For example, the rule, "Two people are sisters if they are both female and have the same parents" tells us something about what it means to be sisters. It also tells us how to find out if two people are sisters: simply check to see if they are both female and have the same parents. What is important to notice about rules is that they are usually oversimplified, but they are acceptable as *definitions.* After all, one cannot expect a definition to tell us everything about something.

For example, most people would agree there is much more to "being sisters" in real life than the above rule implies. However, when we are solving a particular problem, we need to concentrate on just those rules that help to solve the problem. So, we ought to consider an imaginary and simplified definition if it is sufficient for our purposes.

## 1.3 Programming

In this chapter we shall show the essential elements of the Prolog in real programs, but without becoming diverted by details, formal rules, and exceptions. At this point, we are not trying to be complete or precise. We want to bring you quickly to the point where you can write useful programs, so to do that we must concentrate on the basics: facts, questions, variables, conjunctions, and rules. Other features of Prolog, such as lists and recursion, will be treated in later chapters. Computer programming in Prolog consists of:

- specifying some *facts* about objects and their relationships,

- defining some *rules* about objects and their relationships, and

- asking *questions* about objects and their relationships.

<!-- page 18 -->
For example, suppose we told a Prolog system our rule about sisters. We could then ask the question whether Mary and Jane are sisters. Prolog would search through what we told it about Mary and Jane, and come back with the answer *yes* or *no,* depending on what we told it earlier. So, we can consider Prolog as a storehouse of facts and rules, and it uses the facts and rules to answer questions. Programming in Prolog consists of supplying all these facts and rules. Prolog can do much more than answer yes-or-no questions. The Prolog system enables a computer to be used as a storehouse of facts and rules, and it provides ways to make inferences from one fact to another, finding the values of variables that lead to a logical deduction.

The usual way to use Prolog is interactively, which means that you and the computer cany out a kind of conversation. The computer you use has a *keyboard* and a *display.* You use the keyboard to type characters into the computer, and the computer uses the display to show results to you. Prolog will wait for you to type in the facts and rules that pertain to the problem you want to solve. Then, if you ask the right kind of questions, Prolog will work out the answers and show them on the display.

We shall now introduce each of the fundamentals of Prolog one by one. Don't worry about not having the complete story about each feature of Prolog straight away. There will be complete summaries and more examples worked out in later chapters.

## 1.4 Facts

We first discuss *facts* about objects. Suppose we want to tell Prolog the fact that "John likes Mary". This fact consists of two objects, called "Mary" and "John", and a relationship, called "likes". In Prolog, we need to write facts in a standard form, like this:

```prolog
likes(john, mary).
```

The following things are important:

- The names of all relationships and objects must begin with a lower-case letter. For example, likes, john, mary.

- The relationship is written first, and the objects are written separated by commas, and the objects are enclosed by a pair of round brackets.

- The dot character "." must come at the end of a fact. The dot is what some people also call a "period" or a "full stop".

<!-- page 19 -->
When defining relationships between objects using facts, you should pay attention to what order the objects are written between the round brackets. The order is arbitrary, but you must decide on some; order and be consistent about it. For example, in the above fact, we have put the "liker" in as the first of the two objects in round brackets, and we have but the object/that is liked in the second slot. So, the fact likes(john, `mary)` is not the same thing as `likes(mary,` john). The first fact says that John likes Mary, and the second fact says that Mary likes John, according to our current arbitrary convention. If we want to say that Mary likes John, then we must explicitly say so:

```prolog
likes(mary, john).
```

Look at the following examples of facts, together with possible interpretations in English:

```prolog
valuable(gold).
                         Gold is valuable.
female(jane).
                         Jane is female.
owns(jane, gold).
                         Jane owns gold.
father(john, mary).
```

John is the father of Mary.

```prolog
gives(john, book, mary).
```

John gives the book to Mary.

Each time a name is used, the name refers to a particular individual object. Because of our familiarity with English, it is fairly clear that the names john and jane refer to individuals. But, in some other facts, we have used the names gold and valuable and it is not obvious that they refer to individuals. This sort of name is called a "noncount word" by logicians. When using names, we must decide on how to *interpret* the name.

A name can have several interpretations. For example, the name gold could refer to a particular object. In this case we think of the object as some particular lump of gold that we denote by the name gold. So when we say valuable(gold), we would mean that this particular lump of gold, which we have named gold, is valuable. On the other hand, we could interpret the name gold to be a word standing for the chemical element Gold having atomic number 79, and when we say valuable(gold), we would mean that the chemical element Gold is valuable. So, there is more than one way to interpret a name, and it is you, the programmer, who decides on the interpretation. There should be no problem as long as you interpret names consistently. It is important to think about the distinctions between different interpretations early, so that you are quite certain what the names mean in your program.

<!-- page 20 -->
Now for some terminology. The names of the objects that are enclosed within the round brackets in each fact are called the *arguments.* Note that computer programmers use the word "argument" in a technical sense that bears none of the common connotations of dispute, debate, discussion, theme, or topic. The name of the relationship, which comes just before the round brackets, is called the *predicate.* So, valuable is a predicate having one argument, and likes is a predicate having two arguments. The names of the objects and relationships are completely arbitrary. Instead of a term such as likes(john,mary), we could just as well represent this as a(b,c), and remember that a means *likes,* b means *John,* and c means *Mary.* However, we normally select names that help us to remember what they represent. So, we must decide in advance what our names mean, and what the order of arguments shall be. Thereafter we must remain consistent.

Relationships can have an arbitrary number of arguments. If we want to define a predicate called play, where we mention two players and a game they play with each other, we need three arguments. Here are two examples of this:

```prolog
play(john, mary, football).
play(jane, jim, badminton).
```

Using many arguments is important for representing complicated interactions between relationships, as we shall see later.

We may also declare facts that are not true in the real world. We could write

```prolog
king(john, france).
```

to specify that *John is the present king of France.* In the real world this is obviously false, not least because the French monarchy was suppressed sometime around 1792 and John is an unlikely name for a modern day French king. But Prolog does not know, and does not care. Facts in Prolog simply allow you to express arbitrary relationships between arbitrary objects.

In Prolog, a collection of facts is called a *database.* We shall use the word *database* whenever we have collected together some facts (and later, rules) that are used to solve a particular problem.

## 1.5 Questions

Once we have some facts, we can ask some *questions* about them. In Prolog, a question looks just like a fact, except that we put a special symbol before it. The special symbol is written as a question mark followed by a hyphen. Consider the question:

```prolog
?- owns(mary, book).
```

If we interpret mary to be *a person called Mary,* and book to be some particular book, this question is asking *Does Mary own the book?,* or *Is it a fact that Mary owns the* *book?* We are not asking whether she owns all books, or books in general.

<!-- page 21 -->
When a question is asked of a Prolog system, it will search through the database. It looks for facts that *unify* the fact in the question. Two facts *unify if* their predicates are the same (spelled the saijne way), and if their corresponding arguments each are the same. If Prolog finds a fact that unifies with the question, Prolog will respond *yes.* If no such fact exists in the database, Prolog will respond *no.* The response from Prolog appears on the display of your computer terminal on the line just below your question. Consider the following database:

```prolog
likes(joe, fish).
likes(joe, mary).
likes(mary, book).
likes(john, book).
likes(john, france).
```

If we typed in all those facts to the Prolog system, we could ask the following questions, and Prolog would give the answers (shown from now on in bold italic type) on the line just after the question:

```prolog
?- Likes(joe, money).
no
?- likes(mary, joe).
no
?- likes(mary, book).
yes
```

The answers to the first three questions should be clear to you. In Prolog, the answer *no* is used to mean *nothing unifies with the question.* It is important to remember that *no* is not the same as *false.* For example, suppose a database about some famous Greeks contains only the following three facts:

```prolog
human(socrates).
human(aristotle).
athenian(socrates).
```

We can ask some questions:

```prolog
?- athenian(socrates).
yes
?- athenian(aristotle).
no
```

Although it may be true in real history that Aristotle once lived in Athens, we cannot *prove* it simply from the facts shown in the database. Now what happens if we ask a question about a relationship that is not in the database? Suppose we are using the above database about `likes,` and ask the perfectly sensible question:

```prolog
?- king(john, france).
```

<!-- page 22 -->
The database says nothing about kings, even though john and france are in the database. In most versions of Prolog, the answer *no* will be given, because nothing about kings can be proved from the database. However, Standard Prolog now provides a choice of behaviours if the relationship is not in the database. The question can simply say *no* as in many Prolog systems, or a warning can be given before saying *no,* or an error message can be printed. For example, using the above database about Greeks, suppose we ask

```prolog
?- greek(socrates).
```

Although it is shown in the database that Socrates is an Athenian, this does not *prove* he is a Greek unless more information is in the database. Nothing about Greeks is given in the database. So, a Standard Prolog system can say:

*Existence error: procedure greek*

*no*

Precisely what behaviour will take place depends on how your Standard Prolog system is set up, so we will not be concerned with these details for now.

The facts and questions we have discussed so far are not particularly interesting. All we can do is get back the same information we put in. It would be more useful to ask question such as, *What objects does Mary like?* and *Who lives in Athens?* This is what *variables* are for.

## 1.6 Variables

If you want to find out what things John likes, it is tiresome to ask *Does John like* *books?, Does John like Mary?,* and so forth, with Prolog giving a *yes -or -no* answer each time. It is more sensible to ask Prolog to tell you something that John likes. We could phrase a question of this form as, *Does John like X?.* When we ask a question, we do not know what the object is that X could *stand for.* We would like Prolog to tell us what the possibilities are. In Prolog we can not only name particular objects, but we can also use terms like X to stand for objects that we are unwilling or unable to name. Terms of this second kind are called *variables.*

<!-- page 23 -->
When Prolog uses a variable, the variable can be either *instantiated* or *not in-* *stantiated.* A variable is instantiated when there is an object that the variable stands for. A variable is not instantiated when what the variable stands for is not yet known. Prolog can distinguish variables from names of particular objects because *any* name beginning with a capital letter is taken to be a variable.

When Prolog is asked a question containing a variable, Prolog searches through all its facts to find an object that the variable could stand for. So when we ask *Does* *John like X?,* Prolog searches through all its facts to find things that John likes.

A variable, such as X, does not name a particular object in itself, but it can be used to stand for objects that we cannot name. For example, we cannot name *something that John likes* as an object, so Prolog adopts a way of saying this. Instead of asking a question like:

```prolog
?- likes(john, something that John likes).
```

Prolog lets us use variables, like this:

```prolog
?- Iikes0ohn, X).
```

Variables can have longer names if we wish. This question is acceptable to Prolog:

```prolog
?- likes(john, SomethingThatJohnLikes).
```

Why? Because a variable can be any word that begins with a capital letter. Consider the following database of facts, about what John likes followed by a question:

```prolog
likes(john, flowers).
likes(john, mary).
likes(paul, mary).
?- likesO'ohn, X).
```

The question asks, *Is there anything that John likes?* When asked the question, Prolog will respond:

<!-- page 24 -->
*X = flowers* and then wait for further instructions, which we will talk about shortly. How does this work? When Prolog is asked this question, the variable X is initially not instantiated. Prolog searches though the database, looking for a fact that *unifies* with the question. Now if an uninstantiated variable appears as an argument, Prolog will allow that argument to unify with *any* other argument in the same position in the fact. What happens here is that Prolog searches for any fact where the predicate is likes, and the first argument is john. The second argument in this case may be anything, because the question was asked with an uninstantiated variable as the second argument. When such a fact is found, then the variable X now stands for the second argument in the fact, whatever it may be. Prolog searches through the database in the order it was typed in (or top-to-bottom of the page) so the fact likes(john, flowers) is found first. Variable X now stands for the object flowers. We say that X is *instantiated* to flowers. Prolog now *marks the place* in the database where a unifier is found. The placemarker is used for reasons we discuss shortly.

Once Prolog finds a fact that unifies with a question, it displays the objects that the variables now stand for. In this case, the only variable was X, and it unified with the object flowers, so Prolog replies *X=flowers.* Now Prolog waits for further instructions, as we said above. If you press the ENTER key

(sometimes called the RETURN key), meaning you are satisfied with just one answer, then Prolog will stop searching for more. If instead you press the semicolon key CO (followed by the ENTER key tO), Prolog will resume its search through the database as before, *starting* *from where it left the place-marker,* to find another possible answer to the question. When Prolog begins searching from a place-marker instead of from the beginning of the database, we say that Prolog is attempting to *re-satisfy* the question.

Suppose in response to Prolog's first answer (*X=flowers*) we asked it to carry on (by typing ED [J]). This means we want to satisfy the question in another way; we want to find another object that X could stand for. This means that Prolog must forget that X stands for flowers, and resume searching with X uninstantiated again. Because we are searching for an alternative solution, the search is continued from the place-marker. The next unifying fact found is likes(john, `mary).` The variable X is now *instantiated* to `mary,` and Prolog puts a place-marker at the fact likes(john, `mary).` Prolog will reply *X=mary* and wait for further commands. If we type another semicolon, Prolog will continue the search. In this example there is nothing more that John likes. So, Prolog will stop its search, and allow us to ask more questions or declare more facts. What happens if, given the same facts above, we ask the question:

```prolog
?-likes(X, mary).
```

This question asks, *Is there an object that likes Mary?* By now you should see that the objects in the example that like Mary are john and paul. Again, if we wanted to see all of them, we would type El d=D after Prolog displays each one of the answers:

```prolog
?-likes(X, mary). our question.
X = john ;
            first
```

answer. We type U [jj in reply.

*X = paul*;

second answer. Again we type 03 [J]-

*no*

no more answers.

## 1.7 Conjunctions

<!-- page 25 -->
Suppose we wish to answer questions about more complicated relationships such as, *Do John and Mary like each other?* One way to do this would be first to ask if John likes Mary, and if Prolog tells us *yes,* then we ask if Mary likes John. So, this problem consists of two separate *goals* that the Prolog system must try to satisfy. Because a combination like this is frequently used by Prolog programmers, there is a special notation for it. Suppose we have the following database:

```prolog
likes(mary, chocolate).
likes(mary, wine).
likes(john, wine).
likes(john, mary).
```

We want to ask if John and Mary like each other. To do this, we ask, *Does John like* *Mary?* and *does Mary like John?* The and expresses the idea that we are interested in the *conjunction* of the two goals: we want to satisfy them both one after the other. We represent this by putting a comma between the goals:

```prolog
?- likes(john, mary), likes(mary, john).
```

The comma is pronounced "and", and it serves to separate any number of different goals that have to be satisfied in order to answer a question. When a sequence of goals (separated by commas) is given to Prolog, Prolog attempts to satisfy each goal in turn by searching for a unifying goal in the database. All goals have to be satisfied in order for the sequence to be satisfied. Using the above list of facts, what should Prolog display when given the above question? The answer is *no.* Why? It is a fact that John likes Mary, so the first goal is true. However, the second goal cannot be proved, since there is nowhere in the list of facts where likes(mary, john) occurs. Since we wanted to know if they *both* like each other, the whole question is answered *no.*

Conjunctions and the use of variables can be combined to ask quite interesting questions. Now that we know that it cannot be shown that John and Mary like each other, we ask: *Is there anything that John and Mary both like?* This question also consists of two goals:

- First, find out if there is some X that Mary likes.

- Then, find out if John likes whatever X is. In Prolog the two goals would be written as a conjunction like this:

```prolog
?- likes(mary, X), likes(john, X).
```

Prolog answers the question by attempting to satisfy the first goal. If the first goal is in the database, then Prolog will mark the place in the database, and attempt to satisfy the second goal. If the second goal is satisfied, then Prolog marks *that goal's* place in the database, and we have found a solution that satisfies both goals. It is most important to remember that each goal keeps its own place-marker.

<!-- page 26 -->
If the second goal of a conjunction is not satisfied, then Prolog will attempt to re-satisfy the previous goal (in this case the first goal). Remember that Prolog searches the database completely for each goal. If a fact in the database happens to unify, satisfying the goal, then Prolog will mark the place in the database in case it has to re-satisfy the goal at a later time. But when a goal needs to be re-satisfied, Prolog will begin the search from the goal's own place-marker, rather than from the start of the database. Our above question *is anything liked by Mary also liked by* *John?* illustrates an example of this "backtracking" behaviour in the following way:

1. The database is searched for the first goal. As the second argument (X) is uninstantiated, it may unify with anything. The first such unifying fact in our above database is likes(mary, chocolate). So, now X is instantiated to chocolate *every-* *where* in the question where X appears. Prolog marks the place in the database where it found the fact, so it can return to this point in case it needs to re-satisfy the goal. Furthermore, Prolog needs to remember that X became instantiated here, so Prolog can "forget" X if it needs to re-satisfy this goal.

2. Now, the database is searched for likes(john, chocolate). This is because the next goal is likes(john, X), and X currently stands for chocolate. As you can see, no such fact exists, so the goal fails. Now when a goal fails, we must try to resatisfy the previous goal, so Prolog attempts to re-satisfy likes(mary, X), but this time starting from the place that was marked in the database. But first Prolog needs to make X uninstantiated once more, so X may unify with anything.

3. The marked place is likes(mary, chocolate), so Prolog begins searching from after that fact. Because we have not reached the end of the database yet, we have not exhausted the possibilities of what Mary likes, and the next unifying fact is likes(mary, wine). The variable X is now instantiated to wine, and Prolog marks the place in case it must re-satisfy what mary likes.

4. As before, Prolog now tries the second goal, searching this time for likes(john, wine). Prolog is not trying to re-satisfy this goal. It is entering the goal again (from the left-hand side, as it were), so it must start searching from the beginning of the database. After not too much searching, the unifying fact is found, and Prolog notifies you. Since this goal was satisfied, Prolog also marks *its* place in the database, in case you want to re-satisfy the goal. There is a place-marker in the database for each goal that Prolog is attempting to satisfy.

<!-- page 27 -->
5. At this point, both goals have been satisfied. Variable X stands for the name wine. The first goal has a place-marker in the database at the fact likes(mary, wine), and the second goal has a place-marker in the database at the fact likes(john, wine). As with any other question, as soon as Prolog finds one answer, it stops and waits for further instructions. If we type CD OJ Prolog will search for more things that both John and Mary like. We know now that this amounts to re-satisfying both goals starting from the place-markers they left behind.

To sum up, we can imagine a conjunction of goals to be arranged from left to right, separated by commas. Each goal may have a left-hand neighbour and a righthand neighbour. Clearly, the left-most goal does not have a left-hand neighbour, and the right-most goal does not have a right-hand neighbour. When handling a conjunction of goals, Prolog attempts to satisfy each goal in turn, working from left to right. If a goal becomes satisfied, Prolog leaves a place-marker in the database that is associated with the goal. Think of this as drawing an arrow from the goal to the place in the database where the solution is. Furthermore, any variables previously uninstantiated might now be instantiated. This happened above at Step 1. If a variable becomes instantiated, all occurrences of the variable in the question become instantiated. Prolog then attempts to satisfy the goal's right-hand neighbour, starting from the top of the database.

As each goal in turn becomes satisfied, it leaves behind a place-marker in the database (draws another arrow from the goal to the unifying fact), in case the goal needs to be re-satisfied at a later time. Any time a goal fails (cannot find a unifying fact), Prolog goes back and attempts to satisfy its left-hand neighbour, starting from its place-marker. Furthermore, Prolog must "uninstantiate" any variables that became instantiated at this goal. In other words, Prolog must "undo" all the variables when it re-satisfies a goal. If each goal, upon being entered from its right, cannot be resatisfied, then the failures will cause Prolog to gradually creep to the left as each goal fails. If the first goal (the left-most goal) fails, then it does not have a lefthand neighbour it can attempt to re-satisfy. In this case, the entire conjunction fails. This behaviour, where Prolog repeatedly attempts to satisfy and re-satisfy goals in a conjunction, is called *backtracking.* Backtracking is summarised in the next chapter, and is given a more complete and sophisticated treatment in Chapter 4.

<!-- page 28 -->
When following the examples, you may find it helpful to write, below each variable in a goal, the object that has been instantiated by the success of the goal. You should also write in an arrow from the goal to its place-marker in the database. An example of this pencil-and-paper aid is shown below at four "snapshots" during the evaluation of the above example. In each snapshot, the complete database and question is shown, together with a numbered commentary. Goals which have been satisfied are outlined in their own little box:

```prolog
likes(mary,food).
likes(mary,wine).
likes(john,wine).
likes(john,mary).
```

1. The first goal succeeds, instantiating X to food.

2. Next, attempt to satisfy the second goal:

```prolog
likes(mary,food).
likes(mary,wine).
likes(john,wine).
likes(john,mary).
```

3. The second goal fails.

<!-- page 29 -->
4. Next, backtrack: forget the previous X, and attempt to re-satisfy the first goal.

<!-- page 30 -->
*X = wine* Throughout this book we will endeavour to show where backtracking occurs in the examples, and what effect it has on solving the problems. Backtracking is so important that the whole of Chapter 4 is devoted to it. Exercise 1.1: Continue the pencil-and-paper simulation of the example given above, assuming that you have just typed a semicolon to initiate backtracking in order to find out if John and Mary both like anything else.

## 1.8 Rules

Suppose we wanted to state the fact that John likes all people. One way to do this would be to write down separate facts, like this:

```prolog
tikes(john, alfred).
likes(john, bertrand).
likes(john, charles).
likes(john, david).
```

for every person in our database. This could become tedious, especially if there are hundreds of people in our Prolog program. Another way to say that John likes all people is to say, *John likes any object provided it is a person.* This fact is in the form of a *rule* about what John likes, instead of listing all the people John likes. In a world where John could like every person, the rule is much more compact than a list of facts.

In Prolog, rules are used when you want to say that a fact *depends* on a group of other facts. In English, we use the word "if" to express a rule. For example,

*I use an umbrella if there is rain.*

*John buys the wine if it is less expensive than the beer.* Rules are also used to express definitions, for example:

*X is a bird if:*

*X is an animal, and*

*X has feathers.* or

*X is a sister of Y if:*

*X is female, and*

<!-- page 31 -->
*X and Y have the same parents.* In the above English definitions, we have used variables *X* and *Y.* It is important to remember that a variable stands for the same object wherever it occurs in a rule. Otherwise we would be violating the spirit of the definition. For example, in the bird rule above, we could not show that Fred is a bird because Fido is an animal and Mary has feathers. The same principle of consistent interpretation of variables is true also for rules in Prolog. If one *X* stands for Fred, then all the X's in the same rule must stand for Fred.

A rule is a *general statement about objects and their relationships.* For example, we can say that Fred is a bird if Fred is an animal and Fred has feathers, and we can also say that Bertram is a bird if Bertram is an animal and Bertram has feathers. So, we can allow a variable to stand for a different object in each different *use* of the rule. Within a use of a rule, of course, variables are interpreted consistently as pointed out above. Let us consider several examples, beginning with a rule using one variable and a conjunction.

*John likes anyone who likes wine,* or, in other words,

*John likes anything if it likes wine,* or, with variables,

*John likes X ifX likes wine.* In Prolog, a rule consists of a *head* and a *body.* The head and body are connected by the symbol ":-", which is made up of a colon and a hyphen. The ":-" is pronounced *if.* The above example is written in Prolog as:

```prolog
likes(john, X) :- likes(X, wine).
```

Notice that rules also end with a dot (actually a "period" or "full stop" character). The head of this rule is likes(john, X). The head of the rule describes what fact the rule is intended to define. The body, in this case likes(X, wine), describes the conjunction of goals that must be satisfied, one after the other, for the head to be true. For example, we can make John more choosy about whom he likes, simply by adding more goals onto the body, separated by commas:

```prolog
likes(john, X) :- likes(X, wine), likes(X, food).
```

or, in words, *John likes anyone who likes wine and food.* Or, suppose John likes any female who likes wine:

```prolog
likes(john, X) :- female(X), likes(X, wine).
```

<!-- page 32 -->
Whenever we look at a Prolog rule, we should take notice of where the variables are. In the above rule, the variable X is used three times. Whenever X becomes instantiated to some object, all X's are instantiated *within the scope of* X. For some particular use of a rule, the scope of X is the whole rule, including the head, and extending to the dot"." at the end of the rule. So, in the above rule, if X happens to be instantiated to mary, then Prolog will try to satisfy the goals female(mary) and likes(mary, wine).

Next, as an example of a rule that uses more than one variable, consider a database consisting of facts about some of the family of Queen Victoria. We shall use the predicate parents having three arguments such that: parents(X ,Y, Z) means *The parents ofX are Y and Z.* The second argument is for the mother, and the third argument is for the father. We shall also use the predicates female and male in the obvious way. One part of the database might look like this:

```prolog
male(albert).
male(edward).
female(alice).
female(victoria).
parents(edward, victoria, albert).
parents(alice, victoria, albert).
```

Now w^shall

the rule about *sister of* described earlier. The rule defines the predicate sister_of, having two arguments such that sister_of(X, Y) is a fact if X is a sister of Y. Notice that we have used the underscore character "_" in the predicate name. Although we have not yet given the complete rules for how to construct names, it is permitted to include underscores in a name, and we shall summarise the rules in the next chapter. Now X is a sister of Y if:

- X is female,

- X has mother M and father F, and

- Y has the same mother and father as X does.

This can be written as the following Prolog rule:

```prolog
sister_of(X, Y) :-
    female(X),
    parents(X, M, F),
    parents(Y, M, F).
```

Or if you prefer, you can write it out on one line like this:

```prolog
sister_of(X, Y) :- female(X), parents(X, M, F), parents(Y, M, F).
```

<!-- page 33 -->
We use the variable names M and F to indicate mother and father, although we could have used Mother and Father had we been so inclined. Notice that we are using variables that do not appear in the head of the rule. These variables, M and F, are treated in the same way as any other variable. When Prolog uses the rule, variables M and F will initially be uninstantiated, so they will unify with anything when it becomes time to satisfy the goal parents(X,M,F). However, as soon as they are instantiated, then *all* the M's and F's in this use of the rule will become instantiated. The following example should help to explain how these variables are used. Let us ask the question:

```prolog
?- sister_of(alice, edward).
```

When asked this question given the above database and rule for sister_of, Prolog proceeds as follows:

1. First, the question unifies with the head of the only sister_of rule above, so X in the rule becomes instantiated to alice, and Y becomes instantiated to edward. The place marker for the question is put against this rule. Now Prolog attempts to satisfy the three goals in the body, one by one.

2. The first goal is female(alice) because X was instantiated to alice in the previous step. This goal is true from the list of facts, so the goal succeeds. As it succeeds, Prolog marks the goal's place in the database (the third entry in the database). No new variables were instantiated, so no other note is made. Prolog now attempts to satisfy the next goal.

3. Now Prolog searches for parents(alice, M, F), where M and F will unify with any arguments because they are uninstantiated. A unifying fact is parents(alice, victoria, albert), so the goal succeeds. Prolog marks the place in the database (sixth down from the top) and records that M became instantiated to victoria, and F to albert. (You may write these under the goal in the rule if you want to keep track of them on paper). Prolog now attempts to satisfy the next goal.

4. Now Prolog searches for parents(edward, victoria, albert) because Y is known as edward from the question, and M and F were known to stand for victoria and albert from the previous goal. The goal succeeds, because a unifying fact is found (fifth down from the top). Since it is the last goal in the conjunction, the entire goal succeeds, and the fact sister_of(alice, edward) is established as true. Prolog answers *yes.* Suppose we want to know if Alice is the sister of anyone. The appropriate question in Prolog is ?- sister_of(alice, X). For this question, Prolog proceeds as follows:

<!-- page 34 -->
1. The question unifies with the head of the only sister_of rule. Variable X in the rule becomes instantiated to alice. As variable X in the question is uninstantiated, then variable Y in the question will also be uninstantiated. However, these

variables now become *shared.* We can also say that these variables are *confer-*

*ences,* because each one references the other. As soon as one of the variables

becomes instantiated to an object, the other variable becomes instantiated to the

same object. At the moment, as we said, they are not instantiated. Coreferencing

variables are explained more in the next chapter.

2. The first goal is female(alice), which succeeds as before.

3. The second goal is parents(alice, `M, F),` and it unifies with parents(alice, victo-

ria, albert). Variables `M` and `F` are now known.

4. As Y is not yet known, the third goal is therefore parents(Y, victoria, albert).

This goal unifies with the fact parents(edward, victoria, albert). Variable Y is

now known to be edward.

5. Since all goals succeed, the entire rule succeeds, with X known to be alice (given

in the question), and Y as edward. Since Y (in the rule) is shared with X (in

the question), then X is also instantiated to edward. Prolog displays the reply

*X=edward.*

As usual, Prolog waits for you to tell it if you want to find all the solutions to the question. As it turns out, this question has more than one solution. How Prolog finds the remaining solutionfs] is set as an exercise at the end of this chapter.

As we have seen thus far, there are two ways to provide information about a given predicate such as likes. We can provide both facts and rules. In general, a predicate is defined by a mixture of facts and rules. These are called the *clauses* for a predicate. We shall use the word *clause* whenever we refer to either a fact or a rule.

As a further example, this time not dealing with monarchs, consider the rule: A *person may steal something if the person is a thief and the person likes the thing.* In Prolog, this is written:

```prolog
may_steal(P, T) :- thief(P), likes(P, T).
```

<!-- page 35 -->
Here we use the predicate may_steal, which has two arguments P and T to represent the idea that some person P may steal thing T. This rule depends on clauses for thief and likes. These could be represented as a mixture of facts and rules, whatever is most appropriate. For example, consider the following Prolog database, which has been made up from clauses discussed earlier. We have added some clause numbers enclosed between /*. . .*/ brackets. This is how we write a *comment.* Comments are ignored by Prolog, but we may add them to our programs for convenience. In the discussion that follows, we shall refer to the clause number comments. / * ! * /

```prolog
         thief(john).
/*2*/
         likes(mary, chocolate).
/*3*/
         likes(mary, wine).
```

/ * 4 * /

```prolog
          likes(john, X) :- likes(X, wine).
/*5*/
          may_steal(X, Y) :- thief(X), likes(X, Y)
```

Notice that the definition of likes has three separate clauses: two facts and a rule. Let us follow what happens when the question *What may John steal?* is asked. First, this question translates into Prolog as: ?- may_steal(john, X). To answer this question, Prolog searches as follows:

1. First, Prolog searches in the database for a clause about may_steal, and finds one in the form of a rule at clause number 5. Prolog marks the place in the database. Since it is a rule, its body must be satisfied to establish whether the head is true. So the X in the rule is instantiated to john from the question. Again we find that we have to unify two uninstantiated variables (X in the question and Y in the rule), so they will share. The goals of a rule must succeed for the rule to succeed: the first goal, thief(john) is now searched for.

2. The goal succeeds, since thief(john) is in the database (clause 1). Prolog marks the place in the database, and no variables have become newly instantiated. Prolog then attempts to satisfy the second goal using clause 5. Since X still stands for john, Prolog now searches for likes(john, Y). Notice that Y is still instantiated at this point.

3. The goal likes(john, Y) unifies with the head of the rule (at clause 4). The Y in the goal shares with the X in the head, and both remain uninstantiated. To satisfy this rule, likes(X, wine) is now searched for.

4. The goal succeeds, because it unifies with likes(mary, wine), the fact at clause

3. So, X now stands for mary. Since the goal in clause 4 succeeds, the whole rule succeeds. The fact likes(john, mary) is established from clause 4 because Y in clause 5 shares with X; it is also instantiated to mary.

5. Clause 5 now succeeds, with Y instantiated to mary. As Y was shared with the second argument of the original question, X in the question is now instantiated to mary.

<!-- page 36 -->
We chose this example to show how easy it is to generate strange and unexpected answers, such as "John may steal Mary". This conclusion is a logical deduction from the program, but it might not make much sense to us. Sometimes this can indicate a problem with the program. The reasoning behind establishing that John may steal Mary is:

*In order to steal something, first John must be a thief. From clause 1, this is*

*a fact. Next John must like the thing. From clause 4, we see that John likes*

*anything that likes wine. From clause 3, we see that Mary likes wine. There-*

*fore, John likes Mary. Therefore, both conditions for stealing something can*

*be satisfied, so John may steal Mary.*

Notice that the fact (clause 2) that Mary likes chocolate, is irrelevant to this particular question.

In this example we have repeatedly used the variables X and Y in different clauses. For example, in the may_steal rule, X stands for the object that can steal something. But in the likes rule, X stands for the object that is liked. In order for this program to make sense, Prolog must be able to tell that X can stand for two different things in two different uses of the clauses. Remember that knowing the scope of a variable can resolve any confusion. We could have used more mnemonic names to attempt to prevent any confusion, but we use *simple names* such as X *to demonstrate* the scoping principle.

## 1.9 Summary and Exercises

At this point we have covered most of the basic core of Prolog. In particular, we have looked at

- Asserting facts about objects.

- Asking questions about the facts.

- Using variables and what their scopes are.

- Conjunction as a way of saying "and".

- Representing relationships in the form of rules.

- An introduction to backtracking.

<!-- page 37 -->
With this small number of building blocks, it is possible to write useful programs for manipulating simple databases, and it would probably be a good idea if you did so by working out the exercises below.

When you begin to write programs for a Prolog system that is available to you, you should consult its reference manual to see how to begin a programming session. You will also find some practical tips in Chapter 8.

After you have this much of Prolog under your control, you should carry on into the next chapter, which makes clear some of the points we did not mention in this chapter. Also, we shall show how to work with numbers in Prolog. The features covered in the next few chapters are where the expressiveness and convenience of Prolog become apparent.

Exercise 1.2 When the sister_of rule is applied to the database of part of Queen Victoria's family discussed previously, more than one answer can be obtained. Explain how all the answers can be obtained, and what they are.

Exercise 1.3 This exercise has been inspired by one in Robert Kowalski's book *Logic* *for Problem Solving,* published by North Holland in 1979. Suppose someone has already written Prolog clauses that define the following relationships:

```prolog
father(X, Y)
```

/* X is the father of Y */

```prolog
mother(X, Y)
```

/* X is the mother of Y */

```prolog
male(X)
               /* X is male */
female(X)
               /* X is female */
parent(X, Y)
               /* X is a parent of Y */
diff(X, Y)
               /* X and Y are different */
```

The exercise is to write Prolog clauses to define the following relationships:

```prolog
is_mother(X)
is_father(X)
is_son(X)
                  /* X is a mother */
                  /* X is a father */
                  /* X is a son */
                  /*X is a sister ofY*/
                  /* X is a grandfather ofY */
                  /* X is a sibling ofY*/
sister_of(X, Y)
grandpa_of(X, Y)
sibling(X, Y)
```

For example, we could write a rule for aunt, provided we were supplied with (or wrote) rules for female, sibling, and parent.

```prolog
aunt(X, Y) :- female(X), sibling(X, Z), parent(Z, Y).
```

This could also be written:

```prolog
aunt(X, Y) :- sister_of(X, I), parent(Z, Y).
```

<!-- page 38 -->
provided that we wrote the sisterof rule. Exercise 1.4 Using the sister_of rule defined in the text, explain why it is possible for some object to be her own sister. How would you change the rule if you did not want this property? Hint: assume that the predicate diff of Exercise 1.3 is already defined.
