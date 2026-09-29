# 2 The Structure of the Language

<!-- page 30 -->
In the first chapter we introduced the ideas of stating assertions, formulating rules and interrogating a program containing both assertions and rules. That chapter will have given you the opportunity to tryout those basic language facilities and to gain something of a feel for the language. Our objective in this chapter will be to support that practical experience of Prolog with some of the theory and terminology associated with it. One good reason fordoing this is that we shall be able to introduce more complex language facilities with the aid of a common vocabulary.

## 2.1 Predicates and arguments

Examine the following examples of Prolog clauses

man Gohn).

```prolog
man (X) :- human (X), male (X).
married (X, Y) :- husband (Y, X); wife (X, Y).
family (X, Y, Z) :- married (X, Y), (child (Z, X); child (Z, Y».
```

In each case the *predicate* is saying something about the subject, or subjects. The subject(s) are referred to as the *argument(s)* of the predicate. Thus we have

(i) Predicate man with one argument, in this particular case john. (ii) Predicate man with one argument, defined in terms of two other predicates,

human and male, each having one argument. (iii) Predicate married with two arguments, defined in terms of two predicates,

husband and wife, each having two arguments. (iv) Predicate family with three associated arguments. Note how this is defined

with reference to a previously defined rule, married and the new predicate

child which has two arguments. This method of building up complexity by

using previously defined clauses is a common feature of Prolog programming

and is a theme to which we will return. The number of arguments associated

with a predicate is known as the *arity* of that clause.

<!-- page 31 -->
In general terms we can see that an argument associated with a predicate may be either a constant or a variable. Ultimately, of course, variables need to be W. D. Burnham et al., *Prolog Programming and Applications* © W. D. Burnham and A. R. Hall 1985 *instantiated* to constants in order for a Prolog program to provide usable information. For more advanced programming it can be useful to be able to write predicates with *no* arguments, but we will discuss that idea later; at present we do not need to use it. In addition we can use the same predicate with varying arities. For example

```prolog
family (X, Y) :- husband (X), wife(Y).
family (X, Y, Z) :- husband (X), wife (Y),
               (child (X, Z); child (Y, Z».
```

## 2.2 The idea of goals in Prolog

This is a concept fundamental to the use of Prolog. As a starting point, a convenient way to think of a goal is to see it as that which we actually want to achieve. For instance, if we enter the following question to a Prolog program

```prolog
?- married (X, Y).
```

then our *goal* is to establish that there are values of X and Y which represent two people who are married to each other. If this is the case the goal is said to *succeed,* otherwise it is said to *fail.* If we had in our knowledge base the assertion

married (george, ethel).

then the goal can succeed and the answer be returned (X = george, Y = ethel). The goal succeeds by matching the question against the corresponding assertion and we will examine that process in more detail in section 2.6.

It may be however, that the idea of marriage has been expressed in terms of a rule, perhaps as follows

married (X, Y) :-husband (Y, X).

In this situation, Prolog cannot match directly with an assertion to provide a solution. For the goal in question to succeed it must, as we saw in chapter I, resolve the rule defining married. To do so it needs to resolve

husband (Y, X).

As you can see, the assertion

husband (ethel, george).

<!-- page 32 -->
enables this to be accomplished and the solution, as before, will be

**x = george**

Y = ethel

The clause husband (Y, X) is then said to represent a *sub-goal,* in other words, it must succeed before the *goal* married can succeed. Furthermore

married (X, V).

can be said to constitute the *head* of the rule and

husband (Y, X).

constitutes the *body.*

We can extend the concept of goals succeeding by proving the success of subgoals as follows. Consider the following knowledge base

crime (arson).

crime (robbery).

crime (murder).

tried (smith, robbery).

tried (brown, murder).

tried Gones, arson).

proven (smith, robbery).

```prolog
guilty (X, Y) :- convicted (X, V), crime (Y).
convicted (X, Y) :- tried (X, V), proven (X, V).
```

We will present our goal in the form

```prolog
?- guilty (X, V).
```

"who has been found guilty of what crime?".

In order to resolve this goal the rule head guilty (X, Y) generates the subgoals convicted (X, Y) and crime (Y). This is already familiar to us. However, this example introduces the important concept that a sub-goal can itself generate further sub-goals, and in this particular case the sub-goal convicted (X, Y) can succeed only if its own sub-goals tried (X, Y) and proven (X, Y) succeed. In fact, the goal/sub-goal hierarchy may be extended to however many levels are necessary to state a programming task. (A detailed analysis of the way in which goals succeed or fail is given in section 2.6.)

## 2.3 Structures within Pr%g clauses

<!-- page 33 -->
As we have seen, a Prolog clause consists, in simple terms, of predicates and associated arguments and the arguments can be either *constants* or *variables.* Constants such as

john

a

northern_dancer

mary

are all known as *atoms.* Integer values, which are dealt with in chapter 3, are also constants, but they are not defined as atoms. Remember, the general syntax rule about atoms is that they begin with a lower case letter and represent instantiated values. However there are exceptions to this rule which will be discussed later.

A useful feature of Prolog which we will find to be valuable to us in the construction of sophisticated programs is the ability to 'transform' phrases into a format which enables Prolog to treat them as atoms. This is achieved by enclosing the phrase or expression in single quotes, for example 'the Prolog programmer'. This feature is exploited fully in chapter 5.

Variables begin with a capital letter in general but, should you need to do so, the underline character *(not* the hyphen) may be used to classify a variable. For example

**-"**

JIlan

A third type of argument exists which we will refer t9 as a structure. Some structures, known as lists, are so important and powerful that we have devoted a separate section to their discussion. Here we are going to introduce the idea of using structures as arguments.

Suppose we wish to build a personnel recording system, a very common commercial application. Within that system we could have a factual assertion of the kind

employee (jones, ss2).

which we would take to mean "There is an employee named jones whose grade is stores superintendent, level 2". By employing a structural form of argument we can widen the scope of our system and make it more sympathetic to human dialogue, as shown below

employee (surname (jones), initial (h), grade (manager), level (1».

employee (surname (jones), initial (p), grade (clerk), level (5».

employee (surname (jones), initial (c), grade (stores_super), level (5».

<!-- page 34 -->
To access the information contained in this type of statement we use variables as before. There are two basic methods

(i) either we can address the whole structure by a variable as in

employee (W, X, Y, Z).

(ii) or we can address the arguments of the structures which themselves serve as

arguments to the employee predicate, for example

employee (surname (W), initial (X), grade (Y),level (Z)).

By using the employee record

employee (surname (smith), initial 0), grade (programmer), level (7)).

we can illustrate the previous point. First set the goal.

```prolog
?-employee (W,X, Y,Z).
```

Here we see that the variables are instantiated to full clauses and the solution returned will be

W = surname (smith)

**X =initial (j)**

Y = grade (programmer)

Z = level (7)

If we now specify the goal as

```prolog
?- employee (surname (W), initial (X), grade (Y), level (Z)).
```

then the variables will be instantiated to the arguments of the four structures which themselves serve as arguments to the employee predicate. The answers returned using this form of questioning will be

**W=smith**

X=j

Y = programmer

Z=7

<!-- page 35 -->
If we wished to make the results particularly intelligible or the program easier to read we could take advantage of the fact that anything beginning with a capita1letter is a variable, and phrase our question as

1-

employee (surname (Surname), initial (Initial), grade (Grade), level (Level».

and we would receive the solution

**Surname =smith**

**Initial =j**

Grade = programmer

Level = 7

## 2.4 Exercise 4

Using the idea of structures, program a small personnel registration system. You could take students on a course, employees of a firm or members of aclub as the people to be registered by the system.

## 2.5 The 'blank' variable

We have already seen that a variable can begin with a capital letter or the underline character. Furthermore we have seen how the underline character offers us a simple and convenient way of writing constants which need more than one word to describe them. There is, however, a third use for this symbol, which is perhaps more important than either of the other two - that is when it is used to represent the blank variable.

The blank variable is used in the situation where one needs to recognise the existence of an argument, but does not wish to instantiate it to a constant value. Once more, an example is probably the best way to demonstrate the idea.

Suppose we have the rule

```prolog
husband (X) :- married (X, _).
```

What we are saying is that X is a husband if X is married to *anyone,* whose identity we do not need to know. All we require to know is that there is such a person.

Let us place this example in the context of a knowledge base.

married Goe, elsie).

married (fred, doris).

married (darren, tracey).

child Goe. elsie, em).

child ".._ten, tracey,justin).

boy (em).

boy Gustin).

```prolog
son (X) :- child C, _, X), boy (X).
husband (X) :- married (X,..).
wife (X) :- married LX).
```

<!-- page 36 -->
You will notice that the rules are all designed to focus attention on one particular attribute of a certain individual. A most important point to note is that the first sub-goal of son (X) is child C, _, X) which, because of the way that the assertions about child are stated (for example, child (joe, elsie, em», requires three arguments. Similarly, the first (and only) sub-goals of husband (x) and wife (X) are married (X,J and married C, X) respectively, both of which require two arguments. Similarly, the first (and only) sub-goals of husband (X) and wife (X) are describing the parents or the argument describing the marriage partner; *they* *cannot be dispensed with.* Neither

son (X) :- child (X).

nor

husband (X) :- married (X).

would work in this example. The blank variable must be supplied to 'fill the gap', as it were. Let us simulate a question and answer session using the example program

*User*

husband (X).

son (em).

son (X).

child L

_, X).

**married C, elsie).**

**married LX).**

**married L-,J.**

**... (session ends)**

<!-- page 37 -->
*Prolog* 1- X= joe X= fred X= darren no 1yes 1- X=em yes 1- X=em X= darren yes 1yes 1- X= elsie X= doris X = tracy no 1yes 1- If you study the above example carefully, it will give you a good idea of how the blank variable is used. There will be plenty of further opportunities to examine this piece of syntax.

*2.6 Search and pattern 1IUltching*

We have introduced the way in which Prolog generates solutions by proving the success of goals in numerous examples. In this section we will attempt to summarise the way in which the all important searching mechanism works.

As we already know, there are two fundamental question formats. The first is when we ask Prolog to confirm or deny an assertion, for example

```prolog
?- married Gack, mavis).
```

and the second is when we ask Prolog to produce a solution, for example

```prolog
?- married Gack, X).
```

The first format utilises constants and the blank variable only, the second variables or a mixture of constants and variables.

We also know by now that a question can be resolved by matching with factual assertions or by the resolution of rules accompanied, finally, by matching with facts. At the end of the process we must always have factual assertions which allow solutions to be generated. A knowledge base consisting of only rules and variables cannot provide answers. Furthermore, to review the useful knowledge already gained, we know that some questions will have more than one set of answers which can be elicited by the use of the ; prompt symbol.

Essentially, there are three principles that should be understood.

(i) Solutions are identified by 'pattern matching' and a pattern match can take

place only if both predicate and argument(s) match completely. Here are a

few examples of this idea.

married (X, Y) pattern matches completely with the assertion married Goe,

elsie) because the predicate 'married' is the same and the correct number of

valid arguments is present in both. Notice that the variables X and Yare

instantiated (assigned) to the constants joe and elsie respectively, as part of

the pattern matching process.

owner (angela, Y) pattern matches with the head of the rule

```prolog
owner (X, Y) :- human (X), cat (Y).
```

<!-- page 38 -->
and, assuming we have pattern matches for human (angela) and cat (Y) we can generate a solution, which will assign the name of the cat to the variable Y in the question. The variable X in the rule head matches with the atomic constant angela in the question, the variable Y in the question is instantiated to Y in the rule head and subsequently to the cat's name, if one exists. married (X) does *not* pattern match with married (joe, elsie) because the number of arguments differs.

married (X, Y) does *not* pattern match with couple (joe, elsie) because, even though the idea of married and couple may be similar, the predicates mismatch.

(ii) As a general principle the knowledge base is searched from 'top to bottom'

- in other words the order in which the programmer writes statements into a serial file. Consider the following example which illustrates the idea that the order in which clauses are written is highly significant.

mother (mary,jesus). mother (jean, iain).

If we put the following question

?- mother (X, V).

Then the first solution returned will be the one suggested by the first assertion in the knowledge base, that is

X= mary

Y =jesus

The other solution is obtained by the; prompt, in other words the search will continue 'downwards'. (iii) Rules are resolved from left to right; thus the head is examined first and the sub-goals in the body of the rule are examined from left to right. Let us look at a simple example

clerk (jones).

clerk (smith).

typist (brown).

manager (patel).

manager (lee).

supervises (X, Y) :- manager (X), clerk (Y).

supervises (X, Y) :- clerk (X), typist (Y).

<!-- page 39 -->
supervises (X, Y) :- manager (X), typist (Y). Now we will analyse how some questions are resolved

(a) ?- clerk (jones). Prolog goes to the 'top' of the knowledge base and pattern matches clerk. In this question the argument is instantiated to jones and a full match can now take place with the very fIrst statement with the predicate clerk in the knowledge base. The answer yes is returned and the question prompt reappears.

(b) ?- clerk (X). Again the fust statement is examined. Once more a pattern match can take place on clerk. Since the question format contained the variable X, this can now be instantiated to jones and the answer X =jones is returned. However, Prolog has 'marked the place' where a solution was found. If the prompt ;is now entered the solution already given is ignored because Prolog continues to look for solutions below the marker in the knowledge base. The solution X =smith is therefore the next solution found.

(c) ?- supervises (jones, Y) or "who does jones supervise"? Here, Prolog will go to the 'top' of the knowledge base and search for the fIrst clause that matches. There is no assertion that matches with supervises, but there is a rule head which has the predicate supervises and two arguments and therefore a match is possible. The fIrst rule to be examined is therefore

```prolog
supervises (X, Y) :- manager (X), clerk (Y).
```

and Prolog will attempt to use that rule. Notice that X is instantiated to jones in the question, and the sub.goals are to be examined from left to right. For the above rule to succeed it is necessary to obtain a match on

manager (jones).

As you can see, that is not possible and therefore the attempt to satisfy the rule fails, without the second sub.goal clerk being examined. The fust rule gives no solution and so Prolog moves 'down' the knowledge base to attempt to try and fmd another matching assertion or rule, and encounters the rule

```prolog
supervises (X, Y) :- clerk (X), typist (Y).
```

The variable X remains instantiated to jones (we are still asking the same question), and the sub.goals are examined from left to right. For the rule to succeed, it is necessary to pattern match on an assertion or rule head of the form

<!-- page 40 -->
clerk (jones). and Prolog succeeds using the first assertion in the knowledge base. The second sub-goal is then examined, and as you can see a match is possible on the third assertion

typist (brown).

The variable Y is therefore instantiated to the constant brown and the correct solution Y =brown is obtained.

(d) ?- supervises (X, Y). or "who supervises who"? This is a slightly more complex example, so we will number the steps which are taken to generate solutions.

(1) The predicate is supervises and the first clause to match with the correct predicate and the correct number of arguments is the rule

```prolog
supervises (X, Y) :- manager (X), clerk (Y).
```

The first sub-goal

manager (X).

then needs to be evaluated in order to establish the truth or otherwise of the goal.

(2) Prolog now attempts to find the first clause that matches with manager (X). The match is possible on the fourth assertion and on making the match the variable X is instantiated to patel.

(3) The second sub-goal, clerk (Y), now needs to succeed. Prolog now attempts to find the first clause to match the predicate clerk. The first statement matches and allows Y to be instantiated to jones.

(4) The first possible pair of answers is now returned, that is

**X =patel**

**Y =jones**

At this point the user can terminate the question. However, as you can see by inspection there are other solutions that could be returned. The next pair of names may be obtained by typing in a semi-colon.

<!-- page 41 -->
(5) Prolog is now asked to find other solutions to the question. Prolog has remembered the first solution and has marked the database, and X has remained instantiated to patel. Further solutions for the sub-goal clerk (Y) will now be searched for, starting with the first clause in the knowledge base after clerk (jones). As it happens, a further match succeeds with the assertion clerk (smith) and Y will therefore be instantiated to smith. However it is interesting to consider what happens when there are no other matches on clerk. Prolog will now *backtrack* in an attempt to try and find another solution for the sub-goal manager (X), starting from the clauses below manager (patel) in the knowledge base. As you can see, it will fmd the solution X = lee. The knowledge base is then searched from the *top* again in order to satisfy the sub-goal, clerk (Y). We are searching from the top again because we are attempting to find all the clerks who are supervised by the manager (X). The process of attempting to rematch a clause if the one immediately on its right fails is known as *backtracking.*

(6) If further solutions were requested, they would be generated in the order

**x**

*y*

lee

jones

lee

smith

jones

brown

smith

brown

patel

brown

lee

brown

By now, we can see whythe solutions would be given in that order; *it is* *because of the order of the assertions and rules in the knowledge base.* For simple programs like this example the order is usually unimportant; however, in advanced applications of Prolog, the order in which rules and assertions with the same number of predicates and arguments are written can be of crucial importance. It is therefore essential to understand how the search and pattern matching mechanism operates in the generation of solutions.

## 2.7 Exercise 5

Describe the processes whereby Prolog would resolve the goal president (X, V), from the knowledge base below:

member (jones, wentworth).

member (smith, wentworth).

member (brown, sunningdale).

member (thomson, wentworth).

candidate (smith, wentworth).

candidate (thomson, wentworth).

elected (smith).

elected (brown).

```prolog
president (X, Y) :- member (X, V),
                 candidate (X, Y),
                 elected (X).
```

## 2.8 Diagrammatic representation of backtracking

<!-- page 42 -->
It is interesting to note that the search mechanism of Prolog is a type of search known as a depth first search. If we analyse how the solutions to the question supervises (X, y) (section 2.6) are elicited, we fmd that we are searching a tree of the form shown below.

GOAL NODE

Node 1 =

supervises (X,V):-manager (X), clerk (V).

Node 2 =

```prolog
        supervises (X,V):- clerk (X), typist (V).
Node 3 =
        supervises (X,V):-manager (X), typist (VM.
Node 4 =
        manager (patel).
Node 5 =
        clerk (jones).
Node 6 =
        clerk (smith).
```

**A node is shown by the * symbol. A branch of the tree structure shown above**

is indicated by the lines joining the nodes. Each node represents a goal or subgoal, as indicated above. The search always begins with the left-most branch which is attached to the node whose goal appears first in the knowledge base. You can see this from nodes 1, 2 and 3. The rules assigned to each of these appear in the same order as they do in the knowledge base. The dotted line shows how the solutions are obtained in traversing the tree. The graphic representation shows how the backtracking mechanism works. You can see that after the first solution is obtained (X=patel, Y =jones) at node 5, Prolog returns to node 4 in an attempt to resatisfy clerk (Y) which it may do by going to node 6. After this solution no more can be found, since there are no more assertions of the form clerk (Y) which implies no more branches from node 4. The backtracking mechanism therefore returns to node I and continues its search from there as shown.

## 2.9 Solutions to exercises

<!-- page 43 -->
If you have understood the first two chapters, you will have realised that Prolog is flexible in the way it allows problems to be solved by programming. Therefore the solutions to exercises 4 and 5 are suggested solutions only, you may well have found a different and better approach.

*Exercise 4*

This example registers members of a golf club:

member (name (ash), initial (a), subscription (full), h_cap (12).

member (name (brown), initial (b), subscription (half), h_cap (20».

member (name (cooper), initial (h), subscriptfon (full, h_cap (18».

member (name (day), initial (p), subscription (junior), h_cap (9».

```prolog
weekdaYJDember (X) :- member (name (Xk, subscription (half),J.
weekday_member (X) :- member (name (X),_, subscription (junior),_).
full_member (X) :- member (name (X),_, subscription (full),_).
```

As you can see, the system registers name, initial, class of subscription and handicap. There are also some simple rules which defme the status of the members - those who may play only from Monday to Friday and those who may play on any day of the week. The rules utilise the blank variable because the classification does not require the initial or handicap of the member to be considered, only the name and type of subscription are necessary. You may care to code this example and see for yourself how it works, and then expand it to take account of good players and other relevant factors.

*Exercise 5*

The following steps are taken to generate a solution.

(1) For the goal president (X, Y) to succeed, a match is made on the rule head

president (X, Y). and then the sub-goals member (X, Y), candidate

(X, Y), and elected (X) must succeed from left to right in the usual manner.

First the sub-goal member (X, Y) allows X to become instantiated to

jones and Y to wentworth. However that requires the goal candiate (jones,

wentworth) to succeed, which is not possible.

(2) Prolog now tries to re-establish member (X, Y) using the built in back-

tracking mechanism and succeeds with X instantiated to smith and Y

instantiated to wentworth. The sub-goal candidate (smith, wentworth) is

then attempted and succeeds. The final sub-goal elected (smith) succeeds and

the answers

X= smith

Y = wentworth

are returned. Note that brown is not a president of sunningdale because he is

not a candidate.
