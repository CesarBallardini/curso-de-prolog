# 3 Using Data Structures

<!-- page 61 -->
The *Oxford English Dictionary* defines the word "recursion" in the following way: RECURSION [Now rare or *obs.* 1626]. A backward movement, return. This definition is cryptic and perhaps outdated. Recursion is now a very popular and powerful technique in the world of non-numerical programming. The idea of recursion is used in two ways. It can be used to describe structures that have other structures as components. It can also be used to describe programs that need to satisfy a copy of themselves before they themselves can succeed. Sometimes, beginners view recursion with some suspicion, because, how is it possible for some relationship to be defined in terms of itself? In Prolog, recursion is the normal and natural way of viewing data structures and programs. We hope that the theme of this chapter, recursion, will be made explicit in a comfortable and unobtrusive way.

## 3.1 Structures and Trees

**res and Trees**

It is usually easier to understand the form of a complicated structure if we write it as a *tree*, in which each functor is a node, and the components are branches. Each branch may point to another structure, so we can have structures within structures. It is customary to write a tree diagram with the root at the top, and the branches at the bottom. For instance, the structure parents(charles, elizabeth, philip) is written as:

```prolog
          parents
charles
         elizabeth
                    philip
```

<!-- page 62 -->
The structure a+b*c (or equivalently, +(a, *(b,c))) is written as:

+

The structure book(moby_dick, author(herman, melville)) is written as:

```prolog
       book
moby_dick
            author
       herman
                 melville
```

Notice that the last two structures have trees of the same shape, although the roots and leaves are different. Before going further, you should make sure that you can write tree diagrams for each of the structures you have seen in the previous chapters.

Suppose we are given the sentence "John likes Mary", and we need to represent the syntax of the sentence. A very simple syntax for English is that a sentence consists of a noun followed by a verb phrase. Additionally, a verb phrase consists of a verb and another noun. We can represent the structure of any such sentence by a structure of the form:

```prolog
sentence(noun(X), verb_phrase(verb(Y), noun(Z)))
```

<!-- page 63 -->
which has a tree like this: If we take our sentence ("John likes Mary"), and instantiate the variables in the structure with the words of the sentence, we obtain:

```prolog
    sentence
 noun
        verb phrase
  I /\
  X
       verb
               noun
    sentence
noun
         verb phrase
  I /\
john
        verb
               noun
        likes
               mary
```

This shows how we can use Prolog structures and variables to represent the syntax of a class of very simple English sentences. In general, if we know the parts of speech of words in a sentence, it is possible to write a Prolog structure that makes explicit the relationships between different words in a sentence. This is an interesting topic in its own right, and later on we shall return to the question of how we can use Prolog to make the computer "understand" some simple English sentences.

Trees can also give a graphic description of variables inside structures, particularly showing how like-named variables share. For example, we can depict the structure of the term f(X, g(X, a)) by the following tree (more precisely, a directed acyclic graph):

<!-- page 64 -->
^ ^

## 3.2 Lists

The *list* is a very common data structure in non-numeric programming. The list is an ordered sequence of elements that can have any length. "Ordered" means that the order of the elements in the sequence matters. The "elements" of a list may be any terms — constants, variables, structures — which of course includes other lists. These properties are helpful when we cannot predict in advance how big a list should be, and what information it should contain. Furthermore, lists can represent practically any kind of structure that one may wish to use in symbolic computation. Lists are widely used to represent parse trees, grammars, city maps, computer programs, and mathematical entities such as graphs, formulae, and functions. There is a programming language called LISP, in which the only data structures available are the constant and the list. However, in Prolog, the list is simply one particular kind of structure.

Lists can be represented as a special kind of tree. A list is either an *empty list,* having no elements, or it is a structure that has two components: the head and tail. The end of a list is customarily represented as a tail that is set to the empty list. The empty list is written as [], which is an opening square bracket followed by a closing square bracket. The head and tail of a list are components of the functor named ".", which is the dot (called the period or full stop). Thus, the list consisting of one element "a" is ".(a,[])", and its tree looks like this:

Also, the list consisting of the atoms a, b and c is written .(a,.(b,.(c,[]))), and its tree looks like this:

<!-- page 65 -->
a Some people like to write the tree diagram of a list with the tree "growing" from left to right, and with the "branches" hanging down. The above list looks like this in such a "vine" diagram:

**.**

**.**

**.**

**[]**

```prolog
a
           b
                      c
```

In this vine diagram, the head component of the dot functor hangs down, and the tail component grows to the right. The end of the list is clearly marked by the last tail component being the empty list. The main advantage of the vine diagram for lists is that it can be written right-to-left on a piece of paper.

The vine diagram may be suitable for writing lists on paper when we need to see the structure of a list, but such diagrams are not used for writing lists into a Prolog program. As the dot notation is often awkward for writing complicated lists, there is another syntax that can be used for writing lists in a Prolog program. This *list* *notation* consists of the elements of the list separated by commas, and the whole list is enclosed in square brackets. For example, the above lists can be written in the list notation as [a] and [a,b,c].

It is useful for lists to contain other lists and variables. For example, the following lists are legal in Prolog:

[]

[the, men, [like, to, fish]]

[a, VI, b, [X, Y]]

<!-- page 66 -->
Variables within lists are treated the same as variables in any other structure. They can become instantiated at any time, so judicious use of variables can provide a way to put "holes" in lists that can be filled with data at a later time. To show the structure of lists within lists, the vine diagram for the previous list is: It is easy to see from this diagram that each horizontal "level" of the vine is a list having a certain number of elements. The top level is a list having four elements, one of which is a list. The second level, having two elements, is the fourth element of the top level list.

Lists are manipulated by splitting them up into a head and a tail. The head of a list is the first component of the "." functor that is used to construct lists. Notice that we speak of the "head" of a rule as well as the "head" of a list. These two things are different, and although they are both called "heads" by historical accident, it is easy enough to understand which "head" one is talking about at a particular time. The tail of a list is the second component of the "." functor. When a list appears in the square bracket notation, the head of the list is the first element of the list. The tail of the list is a list that consists of every element except the first. Here are some lists with their heads and tails:

List

Head

Tail

```prolog
     [a, b, c]
                     a
                              [b, c]
        []
                   (none)
                              (none)
  [[the, cat], sat]
                  [the, cat]
                               [sat]
  [the, [cat, sat]]
                    the
                            [[cat, sat]]
[the, [cat, sat], down]
                    the
                          [[cat, sat], down]
     [X+Y, x+y]
                    X+Y
                               [x+y]
```

`Table 3.1.` Some lists with their head and tail

Notice that the empty list has neither a head nor a tail. In the last example, the "+" operator is used as a functor for the structures +(X, Y) and +(x `,y).`

Because a common operation with lists is to split a list into its head and tail, there is a special notation in Prolog to represent "the list with head X and tail Y". This is written [X|Y], where the symbol separating the X and Y is the vertical bar. Be careful not to confuse the vertical bar with the digit "1", the letter "I" and the letter "I". A pattern of the form [X|Y] will instantiate X to the head of a list, and Y to the tail of the list, as in the following example:

```prolog
p([l,2,3]).
p([the, cat, sat, [on, the, mat]]).
?- p([X|Y]).
X=1
             Y = [2, 3]
X = the
           [Y= cat, sat, [on, the, mat]]
?- P([
          [-IX]]).
X = [the, mat]
```

<!-- page 67 -->
More examples of the list syntax, showing how various lists match, are as follows, in which we attempt to match the two lists shown, obtaining the instantiations (if possible), shown in Table 3.2.

List 1

List 2

Instantiations

```prolog
  [X, Y, Z]
            [john, likes, fish]
                 [X|Y]
   [cat]
           [mary, likes, wine]
  [X, Y|Z]
                           X =john
                           Y = likes
                           Z = fish
                           X = cat
                           Y=[]
                           X = mary
                           Y = likes
                           Z = [wine]
[[the, Y]|Z] [[X, hare], [is, here]] X = the
            [golden, norfolk]
 [golden |T]
[vale, horse]
               [horse, X]
 [white|Q]
               [P| horse]
                           Y = hare
                           Z= [[is,here]]
                           T = [norfolk]
                           (none)
                           P = white
                           Q = horse
```

Table 3.2. Pairs of lists and how they match. If they match, variable instantiations are shown. One example does not match.

As the last example shows, it is possible to use the list notation to create structures that resemble lists, but which do not terminate with the empty list. One such structure, [white|horse], denotes a structure having head white and tail horse. The constant horse is neither a list nor the empty list, and we shall later see that such structures should be treated carefully when used at the tail of a list.

## 3.3 Recursive Search

We frequently need to search inside a Prolog structure to find some desired piece of information. When the structure may have other structures as its components, this results in a *recursive search* task.

```prolog
    Suppose, for example, we have a list of the names of those horses sired by
Coriander who all won horse races in Great Britain in the year 1927:
    [curragh_tip, music_star, park_mill, portland]
```

<!-- page 68 -->
Now suppose we want to find out if a given horse is in the list. The way we do this in Prolog is to find out whether the horse is the same as the head of the list: if it is, we succeed. If it is not, then we check to see if the horse is in the tail of the list. This means checking the head of the *tail* next time. And the head of *that* tail after that. If we come to the end of the list, which will be the empty list, we must fail: the horse is not in the list.

To write this in Prolog, we must first recognise that there is a relationship between an object, and a list it might appear in. This relationship, called *membership,* is a common enough concept in our everyday lives. We talk about people being members of clubs, and so forth. We shall write a predicate member such that the goal member(X,Y) is true if the term that X stands for is a member of the list that Y stands for. There are two conditions to check. First, it is a fact that X will be a member of Y, if X is the same as the head of Y. Although you might be tempted to check whether X and Y are the same by writing X=Y as a subgoal, it is easier simply to check whether they match by writing them using the same variable name. In Prolog, this fact is:

```prolog
member(X, [X|_]).
```

which represents, "X is a member of the list that has X as its head". Notice that we use the anonymous variable "_" to stand for the tail of the list. This is because we do not use the tail for anything in this particular fact. Notice that this rule also could have been written as:

```prolog
member(X, [Y| J ) :- X = Y.
```

By this time you should understand why we can take a shortcut by using X in two places in the shorter version of the rule.

The second, and last, rule says that X is a member of a list providing it is in the tail, say Y, of that list. And, what better way to find out if X is in the tail of the list, than to use member itself! This is the essence of recursion. In Prolog:

```prolog
member(X, [_|Y]) :- member(X, Y).
```

which represents, "X is a member of the list if X is a member of the tail of the list". Notice that we have used the anonymous variable "_", because we do not care to have any named variable standing for the head of the list. The two rules together define the membership predicate, and they tell Prolog how to search a list from beginning to end, looking for an item in the list.

<!-- page 69 -->
The most important point to remember, when encountering a recursively defined predicate, is to look for the *boundary conditions* and the *recursive case.* There are actually two boundary conditions for the member predicate. Either the object we are looking for is in the list, or it isn't in the list. The first boundary condition of member is recognised by the first clause, which will cause the search through the list to be stopped if the first argument of member matches the head of the second argument. The second boundary condition occurs when the second argument of member is the empty list.

How are we assured that the boundary conditions will ever be satisfied? We must look at the recursive case, the second rule of member. Notice that each time member attempts to satisfy itself, the goal is given a *shorter* list. The tail of a list is always a shorter list than the original one. Eventually, one of two things will happen: either the first member rule will match, or member will be given a list of length 0, the empty list, as its second argument. When either of these things happens, the "recurrence" of member goals will come to an end. The first boundary condition is recognised by a fact, which does not cause any further subgoals to be considered. The second boundary condition is not recognised by any member clause, so member will fail. In Prolog:

```prolog
member(X, [X|_]).
member(X, [_|Y]) :- member(X, Y).
?- member(d, [a, b, c, d, e, f, g]).
yes
?- member(2, [3, a, 4, f]).
no
```

Suppose we asked the question

```prolog
?- member(dygate,[curraghjnp,music_star,park_mill,portland]).
```

The second member rule would match, as clygate does not match curragh_tip. Variable Y becomes instantiated to [music_star, park_mill, portland], and the next goal is to see if clygate is a member of that. The second rule matches again, and the tail is taken again. The goal becomes member(clygate ,[park_mill, portland]). The process recurs until we reach the goal where X is clygate, and Y is [portland]. The second rule matches once more, and now Y becomes the tail of [portland], which is the empty list, and the next goal becomes member(clygate, []). No rule in the database matches this, so the goal fails, and the question is false.

It is most important to remember that each time that member uses its second clause to attempt to satisfy member, Prolog treats each recurrence of the member goal as a different "copy". This prevents the variables in one use of a clause from being confused with variables in another use of a clause.

<!-- page 70 -->
As the membership predicate is so useful, we shall use it in many places in the remainder of this book. The member predicate is also important because it is one of the smallest useful examples of a predicate that is recursive: that is, the definition of member contains goals that can only be satisfied by member itself. Recursive definitions are frequently found in Prolog programs, and they are no different than any other type of definition. However, you must be careful that you do not write "circular" definitions, for example:

```prolog
parent(X, Y) :- child(Y, X).
child(A, B) :- parent(B, A).
```

In this example, to satisfy parent, we set up child as a goal. However, the definition for child uses only parent as a goal. You should be able to see that asking a question about parent or child would lead to a loop in which Prolog would never infer anything new, and that the loop would never terminate.

One important problem to look out for in recursive definitions is that of *left* *recursion.* This arises when a rule causes the invocation of a goal that is essentially equivalent to the original goal that caused the rule to be used. Thus if we defined:

```prolog
person(adam).
person(X) :- person(Y), mother(X, Y).
```

and asked

```prolog
?- person(X).
```

Prolog would first use the rule, and generate the subgoal person (Y). In trying to satisfy this, it would again pick the rule first, and generate yet another equivalent goal. And so it would go on and on, until it ran out of memory space. Of course, if it had a chance to backtrack, it would find the fact about Adam and start producing solutions. The trouble is, that in order to backtrack, Prolog has to have failed after trying the first possibility. In this case, the task that it finds is infinitely long, and so it never gets a chance to succeed or fail. So the moral is:

Don't assume that, just because you have provided all the relevant

facts and rules, Prolog will always find them. You must bear in mind

when you write Prolog programs how Prolog searches through the

database and which variables will be instantiated when one of your

rules is used. In this example, the simple solution is just to put the fact before the rule, instead of after it:

```prolog
person(X) :- person(Y), mother(X, Y).
person(adam).
```

In fact, as a general heuristic, it is a good idea to put facts before rules whenever possible. Sometimes putting the rules in a particular order will work if they are used to solve goals of one form but will not if goals of another form are generated. Consider the following definition of islist, in which the goal islist(X) succeeds if X is a list in which the tail "of its last element is the empty list:

```prolog
islist([A|B]) :- islist(B).
islistQ]).
```

<!-- page 71 -->
If we use these rules to answer questions like:

```prolog
?- islist([a, b, c, d]).
```

or

```prolog
?- islist([]).
```

or

```prolog
?- istist(f(l, 2, 3)).
```

then the definition will work fine. But when we ask:

```prolog
?- islist(X).
```

the program will loop. A predicate similar to islist that is not susceptible to loops is provided by the following two facts:

```prolog
weak_islist([]).
weak_islist([_|_]).
```

This version just tests the first part of the list, rather than checking whether the last tail is []. This is not as strong a test as islist, but it will not loop if the argument is a variable.

## 3.4 Mapping

Given a Prolog structure, we frequently wish to construct a new structure that is similar to the old one but changed in some way. We traverse the old structure componentby-component, and construct the components of the new structure. We call this *map-* *ping.* For example, let us consider a Prolog program in which we type an English sentence and Prolog replies with another sentence that is an altered version of the one we typed in. This program for "talking back" to the programmer might produce a dialogue like this:

```prolog
    you are a computer
    / am not a computer
    do you speak french
    no i speak german
Although this dialogue may seem like a forced but sensible conversation, it is very
easy to write a computer program to carry out its "part" of the dialogue simply by
following these steps:
```

<!-- page 72 -->
1. Accept a sentence that is typed in by the user.

2. Change each you in the sentence to the word "i".

3. Likewise, change any are to am not.

```prolog
4. Change french to german.
```

5. Change do to no.

When applied to carefully chosen sentences, such as those in the above dialogue, this scheme will produce a sensible altered sentence. However, it does not work on every sentence, for example:

```prolog
i do like you
i no like i
```

Once a simple program is written, it can be modified later to cope with sentences that produce awkward output.

A Prolog program to change one sentence into another can be written as follows. First, we need to recognise that there is a relationship between the original sentence and the altered sentence. So, we need to define a Prolog predicate, called alter, such that alter(X,Y) means that sentence X can be altered to give sentence Y. It is convenient for X and Y to be lists, with atoms standing for the words, so sentences can be written like this:

```prolog
[this, is, a, sentence]
```

and once alter is defined, we could ask Prolog a question of the form

```prolog
?- alter([do,you,know,french], X).
```

and Prolog would reply

*X= [no,i,know,german].* Don't be concerned yet that the input and output sentences are not tidy, and do not look like normal sentences. In later chapters we will discuss ways of typing in and printing out structures in a way that is easy to read. For the moment we will only worry about changing one list into another.

Because alter deals with lists, the first fact about alter needs to deal with what happens if the list is empty. In this case, we will say that an empty list is altered into an empty list:

```prolog
alter([],[]).
```

<!-- page 73 -->
Or, in words, "it is a fact that altering the empty list gives the empty list". If the reason for treating the empty list is not apparent now, it should be clearer later. Next, we need to recognise that the main job of alter is to:

1. Change the head of the input list into another word, and let the head of the output

list stand for that word.

2. Use alter on the tail of the input list, and let the tail of the output list stand for

the altered tail.

3. If we have reached the end of the input list, then there is nothing more to go onto

the output list, so we can terminate the output list with an empty list [].

Translated into words that are closer to Prolog:

Altering a list with head H and tail T gives a list with head X and tail Y if:

changing word H gives word X, and

altering the list T gives the list Y.

Now we need to say what is meant by "changing" one word into another. This can be done by having a database of facts in which `change(X, Y)` means word `X` can be changed into word `Y.` At the end of the database we need a "catchall" fact, because if a word is not changed into another word it needs to be changed into itself. If the reason for a catchall is not apparent now, it should be clearer after we explain how the program works. The relevant catchall fact is `change(X,X),` which means word `X` is changed into itself. A database to handle the changes listed above is:

```prolog
change(you, i).
change(are, [am,not]).
change(french, german).
change(do, no).
change(X, X).
                   /* this is the "catchall" */
```

Notice that we have treated the phrase "am not" as a list, so that it occupies only one argument of the fact.

Now we can translate the pseudo-Prolog text above into pure Prolog, remembering the notation `[A|B]` for the list with head `A` and tail `B.` We get something like this:

\

```prolog
alter([], []).
alter([H|T], [X|Y]) :- change(H, X), alter(T, Y).
```

The first clause in this procedure checks for an empty list. The same clause also checks for the end of the list as well. Why? Consider this worked example:

```prolog
    ?- alter([you, are, a, computer], Z).
This question would match with the main alter rule, making variable H stand for you,
```

<!-- page 74 -->
and the variable `T` stand for `[are, a, computer].` Next, the goal `change(you, X)` would succeed, setting X to stand for the word "i". As X is the head of the output list (in: the goal of alter), the first word in the output list is "i". Next, the goal alter([are, `a,` computer], Y) would use the same rule. The word are is changed into the list [am, not] by the database, and another alter goal is generated:

```prolog
alter([a, computer], Y).
```

The fact `change(a,` X) is searched for, but as there is no `change` fact with `"a"` as its, first argument, the catchall fact at the bottom of the database succeeds, changing `"a"'` into `"a".` The `alter` rule is called for once again, with computer as the head of the input list, and the empty list [] as the tail of the input list. As previously, `change`(computer,| X) matches against the catchall. Finally, `alter` is called with the empty list, which! matches against the very first `alter` clause. The result is the empty list, which ends' the sentence (remember that a list ends with an empty tail). Finally, Prolog answers' the question by responding

*Z = [i, [am,not],a,computer]* Notice that the phrase [am, not] appears in the list exactly as it was inserted. This `is;` an example of a list that is a member of another list.

The reasons for adding the fact `alter([],` []) and the catchall fact `change(X,;` X) should now be clear. Facts like these are often included in a program when it is! desirable to check for boundary conditions. It should be clear from the explanation^ above that boundary conditions occur when the input list becomes the empty list, andwhen all of the `change` facts have been searched through. In both of these boundary conditions, we wish certain actions to be performed. When the input list becomes the; empty list, we wish to terminate the output list (by putting an empty list at its end).! When all the `change` facts have been searched through without the given word being changed into another word, we wish to keep the word unchanged (by changing it into itself).

## 3.5 Recursive Comparison

As we saw in Chapter 2, Prolog provides predicates to compare integers. Comparing structures is generally more complicated, because it is necessary to consider all the individual components. When the components may themselves be structures, the comparison may have to be recursive. This happens, for instance, when we wish to compare lists that may have any length.

<!-- page 75 -->
Imagine that you are trying to assess the relative fuel economy of a set of different cars. To do this, you drive the cars around particular routes and measure the fuel consumption. With each car, you associate a list of numbers that records the number of litres of fuel consumed on the different routes. Of course, to compare two given cars you have to look at the same sequence of routes and it only makes sense to compare consumption on the same route. So we can assume that the lists will all have the same length and that they will be ordered in the same way, so that the first route comes first, the second route second, etc. We can define the predicate fueLconsumed so that the goal fuel_consumed(C,R) succeeds for a model of car C and a list of routes R. So we may have something like:

```prolog
fuel_consumed(waster, [3.1, 10.4, 15.9, 10.3]).
fuel_consumed(guzzler, [3.2, 9.9, 13.0, 11.6]).
fuel_consumed(prodigal, [2.8, 9.8, 13.1, 10.4]).
```

Here we have four test routes. If we tested the cars on more routes, we could make the lists longer. We would like to compare these cars in a way that works regardless of the exact length of the lists.

First of all, we have to decide when to count one amount of fuel consumed as better than another. Since there is a certain randomness in how much fuel is needed for a journey, we will take a generous approach which says that one consumption is "equal or better" than another if it is less than 5 percent more than the average of the two. In Prolog, we can use arithmetic to calculate the threshold (1/20 of the average, which is the same as 1/40 of the sum) and the number that the better consumption must fall below; the actual comparison can be made using <.

```prolog
equaLor_better_consumption(Good, Bad) :-
        Threshold is (Good + Bad) / 40,
        Worst is Bad + Threshold,
        Good < Worst.
```

Thus we have:

```prolog
?- equal_or_better_consumption(10.5,10.7).
yes
?- equal_
            etter_consumption(10.7,10.5).
yes
?- equal_or_better_consumption(10.1,10.7).
no
?- equal_or_better_consumption(10.7,10.1).
yes
```

With this in place, we can start to say when one car, Carl, is preferred to another, Car2:

```prolog
prefer(Carl, Car2) :-
        fuel_consumed(Carl, Conl),
        fuel_consumed(Car2, Con2),
```

<!-- page 76 -->
```prolog
always_better(Conl, Con2).
```

The remaining thing is to define always_better, which tests whether one list of consumptions is better than another. We would expect this to call equal_or_better_consumption to test how the elements of those lists compare, somehow. As is suggested by its name, always_better is given two lists of consumptions and succeeds if each element in the first list is "equal or better" than the corresponding element of the second. Here is how it could be defined:

```prolog
always_better([], []).
always_better([Conl|Tl], [Con2|T2]) :-
        equal_or_better_consumption(Conl, Con2),
        always_better(Tl, T2).
```

Consider the recursive clause first. It says that one list is always better than another if its head, Conl, is an equal or better consumption than the other head, Con2, and if in addition the tail of the first list is always better than the tail of the other (T1 is always better than T2). The latter is tested by a recursive call of the same predicate. So when we originally invoke always_better, it will peel off the head elements, test the first for being equal or better than the second and recur with the tails of the lists. In the recursive call, the second elements of the original lists will be tested and then another recursive goal will be invoked, with the tails of the tails of the original lists. Thus the program works its way down the lists in a methodical way. The program will terminate when it gets to the ends of both lists (which, if they are of' the same length, should happen simultaneously). Then the first clause will match (the boundary condition), and the original goal will succeed. If during this process any of the equal_or_better_consumption tests fails, of course the original always_better goal will do so also.

This is not the only criterion we could use for comparing lists of consumptions. Another thing we could look for is whether in two lists one consumption is sometimes equal or better than the corresponding one.

```prolog
sometimes_better([Conl|_], [Con2|_]) :-
        equal_or_better_consumption(Conl, Con2).
sometimes_better([_|Conl], [JCon2]) :-
        sometimes_better(Conl, Con2).
```

<!-- page 77 -->
This definition is subtly different from the last one. As before, we use recursion to work our way down the lists. Now the boundary condition occurs when an element of the first list is a better consumption than the corresponding element of the second list. In this case; we can succeed without going any further down the list. If we got all the way down to the ends of the lists then we would not have found evidence of one being sometimes better than the other. Notice that in this case the predicate would correctly fail, because both clauses require non-empty lists in both arguments. The recursive clause indicates that one way of establishing that a list is sometimes better than another is to look for better things in the tails of the lists, regardless of what relationship there may be between the heads. Exercise 3.1: Using the sometimes_better definition, almost every car will be preferred to each other. Change the program so that it prefers a car to another if at least one of the test results is significantly better (where you will have to decide what you mean by "significant").

## 3.6 Joining Structures Together

The list processing predicate append is used to join two lists together to form another, new, list. For example, it is true that

```prolog
append([a, b, c], [3, 2, 1], [a, b, c, 3, 2, 1]).
```

The predicate append is most often used to create a new list from concatenating two others, like this:

```prolog
?- append([alpha, beta], [gamma, delta], X).
X = [alpha, beta, gamma, delta]
```

But it can also be used in other ways:

```prolog
?- append(X, [b,c,d], [a,b,c,d]).
X=[a]
```

The predicate append is defined as follows:

```prolog
append([], L, L).
append([X|Ll], L2, [X|L3]) :- append(Ll, L2, L3).
```

The boundary condition is when the first list is the empty list. In this case, any list appended to the empty list is the same list. Otherwise, the following points show the principles of the second rule:

1. The first element of the first list (X) will always be the first element of the third

```prolog
list.
```

2. The tail of the first list (LI) will always have the second argument (L2) appended

to it to form the tail (L3) of the third argument.

<!-- page 78 -->
3. You actually have to use append to do the appending mentioned in point (2).

4. As we are continually taking the head from the remainder of the first argument, it

will gradually be reduced to the empty list, so the boundary condition will occur.

We will refer to append in later examples, with further explanation. In later chapters we will discuss various properties and applications of the append predicate. But first, let us put it to work in another simple example of recursion.

Suppose we work in a bicycle factory, where it is necessary to keep an inventory of bicycle parts'. If we want to build a bicycle, we need to know which parts to draw from the supplies. Each part of the bicycle may have sub-parts, for example each wheel has some spokes, a rim, and a hub. Furthermore, the hub can consist of an axle and gears. Here is an illustration of these parts:

```prolog
                   handles
fork
                                     hub
                                      spoke
```

Let us consider a tree-structured database that will enable us to ask questions about which parts are required to build a part of a bicycle. In a subsequent section we shall improve this basic program to calculate how many of each part are required.

There are two kinds of parts that we use to build our bicycle. These are assem-: blies and basic parts. Each assembly consists of a quantity of basic parts, such as the wheel, which consists of several spokes, a rim, and a hub. Basic parts are not made up of any smaller parts; they simply combine with other basic parts to form assemblies.

We can represent basic parts simply as facts, as follows:

```prolog
basicpart(rim).
basicpart(spoke).
basicpart(rearframe).
basicpart(handles).
basicpart(gears).
basicpart(bolt).
basicpart(nut).
basicpart(fork).
```

<!-- page 79 -->
Naturally, this is not a complete list of the basic parts required for a bicycle but it shows the general idea. Next, an assembly can be represented as the name of the assembly followed by a list of the basic parts, and the quantity of parts required. For example, the following fact represents that a bike is an assembly made up of two wheels and a frame:

```prolog
assembly(bike, [wheel, wheel, frame]).
```

The database of assemblies required for our simplified bicycle is:

```prolog
assembly(bike, [wheel, wheel, frame]).
assembly(wheel, [spoke, rim, hub]).
assembly(frame, [rearframe, frontframe]).
assembly(fTontframe, [fork, handles]).
assembly(hub, [gears, axle]).
assembly(axle, [bolt, nut]).
```

Notice that this particular set of clauses does not perfectly describe a bicycle. We have not distinguished between the front hub and the rear hub: both have gears! The chain and pedals are missing, and there is no place for the rider to sit. Also, there is no indication of how to fit the parts together. This simply lists a few of the parts required, organised into a hierarchy that looks like this:

```prolog
                            bike
                                         frame
     hub
              spoke
                        rim
                                frontframe
                                              rearframe
gears
          axle
                              fork
                                       handle
      bolt
              nut
```

Remember that this hierarchy does not reflect the actual shape of the data structure, but only of what we know about the structure of bicycles.

<!-- page 80 -->
Now we are ready to write the program that, given a part, will list all the basic parts required to construct it. If the part we want to construct is a basic part, then nothing more is required. However, if we want to construct an assembly, then we need to apply the same process to each part making up the assembly. Let us define a predicate partsof, to be used in goals of the form partsof(X, Y), where X is the name of a part, and Y is the list of basic parts that are required to construct X. In our first version of this program, we shall ignore how many of each kind of part are required to form assemblies, but multiple parts will be listed in the answer each time they occur. A better program will be presented in Chapter 7.

The boundary condition occurs when X is a basic part. In this case, we simply return X in a list:

```prolog
partsof(X, [X]) :- basicpart(X).
```

The next condition is if X is an assembly. In this case, we need to find out if there is a matching assembly fact in the database, and if so, to use partsof on each member of the list of sub-parts. We shall use a predicate called partsoflist to handle this second task.

```prolog
partsof(X, P) :-
        assembly(X, Subparts),
        partsoflist(Subparts, P).
```

Now partsoflist takes a list of parts (from the second argument of the assembly database above), and finds the partsof of each part. After calling itself to get the partsof for the tail of the list, partsoflist must glue the lists together with append:

```prolog
partsoflist([], []).
partsoflist([P|Tail], Total) :-
        partsof(P, Headparts),
        partsoflist(Tail, Tailparts),
        append(Headparts, Tailparts, Total).
```

The list which is constructed by partsof will not contain information about how many parts are required, and duplicate parts may appear in the list. In Chapter 7, we shall present an improved version of this program that handles these deficiencies.

There are two insights that indicate how partsof can be used to generate English sentences. First, sentences can be decomposed into hierarchical structures: a sentence has parts noun_phrase and verb_phrase; a noun_phrase has parts determiner and noun, and so forth. So, any simple grammar can be expressed in terms of "parts". Second, partsoflist always looks at the elements of its first argument from left to right, and its result is appended together in left-to-right order. These two properties of partsof show that we can use the same framework to generate sentences from a grammar. Part of a typical "assembly" for a grammar might look like this:

```prolog
assembly(sentence,[noun_phrase, verb_phrase]).
assembly(noun_phrase, [determiner, noun]).
```

<!-- page 81 -->
```prolog
assembly(determiner, [the]).
assembly(noun, [apple]).
assembly(noun, [fruit]).
```

and the words in the lexicon would be defined as basic parts:

```prolog
basicpart(apples).
basicpart(fruit).
```

At this point you may wish to experiment with generating sentences such as "The apple is a fruit". You should provide a reasonable grammar and a vocabulary. Satisfy yourself that this modified program will produce all possible grammatical sentences from the grammar and vocabulary you provide. As always, Prolog will stop at each solution, and wait for you to type a semicolon to tell it to backtrack to the next solution.

This is certainly not the last word on processing English language in this book. The whole of Chapter 9 is devoted to a more sophisticated treatment of analysing English language in Prolog.

## 3.7 Accumulators

Frequently we need to traverse a Prolog structure and calculate a result that depends on what was found in the structure. At intermediate stages of the traversal, we will have an interim value for the result. A common technique is to use an argument of the predicate to represent "the answer so far". This argument is called an *accumulator.*

In the following example, we show a definition of the predicate listlen without using an accumulator, and then a definition using an accumulator. The goal listlen(L, N) succeeds if the length of list L is N. Some Prolog systems may have the builtin predicate length for this purpose. First, a listlen without using an accumulator. There are two clauses, the boundary condition and the recursive case. The boundary condition is a fact stating that the empty list has length 0. The recursive case is a rule saying that the length of a non-empty list can be calculated by adding one to the length of the tail of the list:

```prolog
listlen ([], 0).
listlen([H|T], N) :- listlen(T, Nl), N is N1 + 1.
```

<!-- page 82 -->
The alternative way to write this uses the same recursive principle, but the answer is accumulated at each recurrence in an extra argument used for this purpose. We use an auxiliary predicate lenacc, which is a generalisation of listlen. The goal lenacc(L, A, N) means that the length of list L, when added to the number A, is the number N. Thus to use lenacc to find the length of a list, we need to give it the second argument 0 (zero). This is done in an introductory clause which gives the relation between tistlen and lenacc.

```prolog
listlen(L, N) :- lenacc(L, 0, N).
lenacc([], A, A).
lenacc([H|T], A, N)
                  A1 is A + 1, lenacc(T, Al, N).
```

Predicate lenacc also has two clauses. First, for the empty list, the length of the list will be whatever has been accumulated so far (A). In the second clause, we add 1 to the accumulated amount given by A, and recur on the tail of the list with a new accumulator value Al.

Note that the final argument of the recursive subgoal (N) is the same as the final argument in the head of the clause. This means that the length returned for the whole list will be the number that the recursive subgoal calculates. That is, the production of the final result is being delegated entirely to the recursive subgoal. All the extra information that is needed to construct this overall result is provided by the accumulator. If the second clause is used again for the recursive subgoal, once again the production of the final result is delegated to a recursive subgoal (with a modified accumulator). Thus we get a sequence of lenacc goals, all sharing the same last argument, each having the tail of the input list of the previous one and an accumulator that is one greater than the previous one. Here is what the sequence of subgoals would look like for finding the length of the list [a, b, c, d, e]:

```prolog
lenacc([a, b, c, d, e], 0, N)
lenacc([b, c, d, e], 1, N)
lenacc([c, d, e], 2, N)
lenacc([d, e], 3, N)
lenacc([e], 4, N)
lenacc([], 5, N)
```

where all the N's share (or co-refer). The last goal has now met the boundary condition (the end of the input list has been reached), and so the first lenacc clause is now applicable. This instantiates the final argument to whatever the accumulator is at that point. Since the initial accumulator was 0 and each time we found an element in the list we passed on an accumulator 1 greater than the previous one, this value is the length of the list (5). Also since all the lenacc goals — including the very first one introduced by listlen — share their final argument, all these goals immediately get their final arguments instantiated to the length of the list. In particular, this means here that N in the listlen clause is instantiated to 5.

<!-- page 83 -->
Accumulators needn't be integers. If we are producing a list as a result, an accumulator will hold the list built so far. This may be useful if we need to inspect our interim results (for example, to avoid adding duplicate elements to the list). Using an accumulator in this situation can also avoid much wasteful joining of structures. In general, for efficiency we may wish to avoid joining structures together too often because these operations are expensive. For instance, if we use append to join two lists together, we make our way down the first list until it is empty. At each stage, we construct a new piece of list structure in the third argument. When we finally reach the end of the list, we fill in the final part of the output list with the second input list. In order to produce an output list that ends with the second input list, we essentially have to make a copy of the first input list. If the first input list is long, this can be a lot of work. Consider what happens in our parts inventory if we wish to find the parts that make up a bicycle. A bicycle assembly is given by the following:

```prolog
assembly(bike, [wheel, wheel,frame]).
```

To find the parts of a bicycle, we use partsoflist to find the parts coming from the list [wheel, wheel, frame]. Because of the way partsoflist is defined, this involves:

• finding the parts of a frame,

- appending these to the empty list to give the parts of [frame],

• finding the parts of a wheel,

- appending these to the parts of [frame] to get the parts of [wheel ,frame],

• finding the parts of a wheel (for the second wheel),

- appending these to the parts of [wheel,frame] to get the parts of [wheel, wheel, frame]. This sequence of operations is wasteful because each list of parts for a subpart of a bicycle has to be built twice. It is built once when it is first worked out, and once when it is appended to the list of parts obtained so far. Because some of the subparts of a bicycle are themselves assemblies, this wastefulness will be repeated in deriving their parts as well. We can avoid this unnecessary extra work by using accumulators. As with the listlen example, we introduce auxiliary predicates with extra accumulator arguments and have a starting clause that calls one of these with an appropriately initialised accumulator. Here is a program for the parts inventory which uses accumulators. The clauses for basicpart and assembly are unchanged, so are not listed here. Notice that append is no longer used.

```prolog
partsof(X, P) :- partsacc(X, [], P).
partsacc(X, A, [X|A]) :- basicpart(X).
partsacc(X, A, P) :-
        assembly(X, Subparts),
```

<!-- page 84 -->
```prolog
        partsacclist(Subparts, A, P).
partsacclist([], A, A).
partsacclist([P|Tail], A, Total) :-
        partsacc(P, A, Hp),
        partsacclist(Tail, Hp, Total).
```

The predicates partsacc and partsacclist are defined very similarly to the previous versions of partsof and partsoflist, except that they each have an accumulator as their second argument. This argument represents the list of (basic) parts that have been found so far. So partsacc(X,A,P) means that the parts of object X, when added to the list A, give the list P. Notice the similarity with the meaning of lenacc. If we wish to use partsacc to find the parts of an object, we must provide it with the empty list as its second argument; hence the partsof clause.

The first clause of partsacc simply constructs a new list whose head is the object given in the first argument, and whose tail is the accumulated list of parts, and this will succeed if the object is a basic part. The second clause, which applies when the object is an assembly, first finds the list of subparts, and then uses partsacclist to find the subparts of each part in the list. Note that the accumulator (A) has been passed to partsacclist.

The first clause of partsacclist is the boundary case, in which the result is the accumulated list of subparts (A). The recursive case calls partsacc to find the subparts of the next part on the given list, and the recursive goal deals with the remainder of the list. Note that the second argument of the second clause (A) is used as the accumulator for the partsacc goal, and that the result of the partsacc goal (Hp) is used as the accumulator for the recursive goal.

We make further use of accumulators throughout the book. In particular, we draw your attention to Sections 7.2,7.5, and 7.8, as well as the next section.

## 3.8 Difference Structures

In the previous section, we used an accumulator to avoid unnecessary joining of structures. One unmentioned effect of this was to produce a resulting list in which the elements were in the *reverse* order to that in which they were produced from the original list. Sometimes, however, we may wish to generate elements in the *same* order as the original list. *Difference*

*structures* (here difference *lists)* allow us to do this.

<!-- page 85 -->
If we use the parts inventory program to find the parts of a bicycle, the version using accumulators works just as well as the original version, and indeed runs faster. However, if we use it for generating English sentences as suggested before, we encounter a problem: the words come out in reverse order! This did not matter for the bicycles, because the order of the parts is not important, but obviously with English sentences it matters what order the words come in. If we think about the way in which the list of "parts" is built, it is not surprising that it ends up in the reverse order to that in which the parts are originally discovered. For every time we come to a basic part, we create a new accumulator which has this part *before* all the parts found so far.

With accumulators, we use two arguments to organise the building of some output structure. One is for "the result so far" and one is for the "final result". With difference lists, we also use two arguments, but with a different interpretation. The first argument is for the "final result", and the second argument is for a "hole in the final result where further information can be put". The way we represent a "hole" in a structure is by a Prolog variable which shares with a component somewhere in the structure. Thus the following two terms represent a list together with a named "hole variable" where further information could be put:

[a, b, c|X] X If we have a list with a "hole" in it, we can further instantiate the list by passing the "hole variable" as an argument to a Prolog goal which instantiates this argument. In general, we will be interested in where further information can be inserted after this goal has succeeded. Thus we will require the goal to pass back a *new* hole through another argument. So here is a conjunction of goals that would create a list with a hole, add some elements to the list using predicate p and then fill in the hole that remains with the list [z]:

```prolog
?- Res = [a, b, c|X], p(X, NewHole), NewHole - [z].
```

We can allow for the p goal not instantiating the list further by providing a clause that causes the original hole to be returned as the new hole:

```prolog
p(Hole, Hole).
```

If this clause is chosen, the variable Res will have the value [a, b, c, z] when the question succeeds. Better, we can provide a clause that causes the original hole to be instantiated to a structure containing a new variable and this variable to be passed back as the new hole:

```prolog
p([d|NewHole], NewHole).
```

<!-- page 86 -->
In general, a clause like this will, of course, obtain these results partly through the effects of subgoals that it invokes. If this clause is chosen, the variable Res will have the value [a, b, c, d, z] when the question succeeds. Here is a version of the parts inventory program that uses the difference lists technique:

```prolog
partsof(X, P) :- partsacc(X, P, Hole), Hole= f].
partsacc(X, [X|Hole], Hole) :- basicpart(X).
partsacc(X, P, Hole) :-
        assembly(X, Subparts),
        partsacclist(Subparts, P, Hole).
partsacclist([], Hole, Hole).
partsacclist([P|T], Total, Hole) :-
        partsacc(P, Total, Holel),
        partsacclist(T, Holel, Hole).
```

First consider the partsof clause. When partsacc is initially called from the partsof clause, it will build its result in the second argument P and will instantiate Hole to a variable. Because partsof calls partsacc only once, it is necessary to terminate the difference list by instantiating Hole with []. Note that a perfectly valid alternative definition of partsof is:

```prolog
partsof(X, P) :- partsacc(X, P, []).
```

This more succinct version ensures that the very last hole is filled with [] even before the list contents are known.

The first clause of partsacc returns a difference list containing the object in the first argument, and this applies if the object is a basic part. The second clause, for assemblies, finds the list of subparts and delegates the traversal of the list to partsacclist, passing the two arguments making up the difference list (P and Hole). The second clause uses partsacc to list the subparts using the difference list with Total and Holel. The recursive goal then returns the portion of the difference list starting at Holel and ending at Hole. The entire result, the list between Total and Hole, is the result of the second partsacclist clause. The way that the list is constructed by "weaving" together partial results can be conveyed with the aid of this illustration:

```prolog
partsacclist([P|Tail],Total,Hole) :-
          partsacclist(Tai I, H olel, H ole).
```

We make use of difference lists again in the definition of quisortx in Section 7.7.
