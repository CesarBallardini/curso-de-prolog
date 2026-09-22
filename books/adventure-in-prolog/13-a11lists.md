------------------------------------------------------------------------

# 11. Lists

Lists are powerful data structures for holding and manipulating groups of things.

In Prolog, a list is simply a collection of terms. The terms can be any Prolog data types, including structures and other lists. Syntactically, a list is denoted by square brackets with the terms separated by commas. For example, a list of things in the kitchen is represented as

```prolog
 [apple, broccoli, refrigerator]
```

This gives us an alternative way of representing the locations of things. Rather than having separate location predicates for each thing, we can have one location predicate per container, with a list of things in the container.

```prolog
loc_list([apple, broccoli, crackers], kitchen).
loc_list([desk, computer], office).
loc_list([flashlight, envelope], desk).
loc_list([stamp, key], envelope).
loc_list(['washing machine'], cellar).
loc_list([nani], 'washing machine').
```

There is a special list, called the empty list, which is represented by a set of empty brackets (\[\]). It is also referred to as **nil**. It can describe the lack of contents of a place or thing.

```prolog
loc_list([], hall)
```

Unification works on lists just as it works on other data structures. With what we now know about lists we can ask

```prolog
?- loc_list(X, kitchen).
X = [apple, broccoli, crackers] 

?- [_,X,_] = [apples, broccoli, crackers].
X = broccoli 
```

This last example is an impractical method of getting at list elements, since the patterns won't unify unless both lists have the same number of elements.

For lists to be useful, there must be easy ways to access, add, and delete list elements. Moreover, we should not have to concern ourselves about the number of list items, or their order.

Two Prolog features enable us to accomplish this easy access. One is a special notation that allows reference to the first element of a list and the list of remaining elements, and the other is recursion.

These two features allow us to write list utility predicates, such as member/2, which finds members of a list, and append/3, which joins two lists together. List predicates all follow a similar strategy--try something with the first element of a list, then recursively repeat the process on the rest of the list.

First, the special notation for list structures.

```prolog
 [X | Y]
```

When this structure is unified with a list, X is bound to the first element of the list, called the **head**. Y is bound to the list of remaining elements, called the **tail**.

We will now look at some examples of unification using lists. The following example successfully unifies because the two structures are syntactically equivalent. Note that the tail is a list.

```prolog
?- [a|[b,c,d]] = [a,b,c,d].
yes
```

This next example fails because of misuse of the bar (\|) symbol. What follows the bar must be a single term, which for all practical purposes must be a list. The example incorrectly has three terms after the bar.

```prolog
?- [a|b,c,d] = [a,b,c,d].
no
```

Here are some more examples.

```prolog
?- [H|T] = [apple, broccoli, refrigerator].
H = apple
T = [broccoli, refrigerator] 

?- [H|T] = [a, b, c, d, e].
H = a
T = [b, c, d, e] 

?- [H|T] = [apples, bananas].
H = apples
T = [bananas] 
```

In the previous and following examples, the tail is a list with one element.

```prolog
?- [H|T] = [a, [b,c,d]].
H = a
T = [[b, c, d]] 
```

In the next case, the tail is the empty list.

```prolog
?- [H|T] = [apples].
H = apples
T = [] 
```

The empty list does not unify with the standard list syntax because it has no head.

```prolog
?- [H|T] = [].
no
```

NOTE: This last failure is important, because it is often used to test for the boundary condition in a recursive routine. That is, as long as there are elements in the list, a unification with the \[X\|Y\] pattern will succeed. When there are no elements in the list, that unification fails, indicating that the boundary condition applies.

We can specify more than just the first element before the bar (\|). In fact, the only rule is that what follows it should be a list.

```prolog
?- [One, Two | T] = [apple, sprouts, fridge, milk].
One = apple
Two = sprouts
T = [fridge, milk] 
```

Notice in the next examples how each of the variables is bound to a structure that shows the relationships between the variables. The internal variable numbers indicate how the variables are related. In the first example Z, the tail of the right-hand list, is unified with \[Y\|T\]. In the second example T, the tail of the left-hand list is unified with \[Z\]. In both cases, Prolog looks for the most general way to relate or bind the variables.

```prolog
?- [X,Y|T] = [a|Z].
X = a
Y = _01
T = _03
Z = [_01 | _03] 

?- [H|T] = [apple, Z].
H = apple
T = [_01]
Z = _01 
```

Study these last two examples carefully, because list unification is critical in building list utility predicates.

A list can be thought of as a head and a tail list, whose head is the second element and whose tail is a list whose head is the third element, and so on.

```prolog
?- [a|[b|[c|[d|[]]]]] = [a,b,c,d].
yes
```

We have said a list is a special kind of structure. In a sense it is, but in another sense it is just like any other Prolog term. The last example gives us some insight into the true nature of the list. It is really an ordinary two-argument predicate. The first argument is the head and the second is the tail. If we called it dot/2, then the list \[a,b,c,d\] would be

```prolog
dot(a,dot(b,dot(c,dot(d,[]))))
```

In fact, the predicate does exist, at least conceptually, and it is called dot, but it is represented by a period (.) instead of dot.

To see the dot notation, we use the built-in predicate display/1, which is similar to write/1, except it always uses the dot syntax for lists when it writes to the console.

```prolog
?- X = [a,b,c,d], write(X), nl, display(X), nl.
 [a,b,c,d]
.(a,.(b,.(c,.d(,[]))))

?- X = [Head|Tail], write(X), nl, display(X), nl.
 [_01, _02]
.(_01,_02)

?- X = [a,b,[c,d],e], write(X), nl, display(X), nl.
 [a,b,[c,d],e]
.(a,.(b,.(.(c,.(d,[])),.(e,[]))))
```

From these examples it should be clear why there is a different syntax for lists. The easier syntax makes for easier reading, but sometimes obscures the behavior of the predicate. It helps to keep this "real" structure of lists in mind when working with predicates that manipulate lists.

This structure of lists is well-suited for the writing of recursive routines. The first one we will look at is member/2, which determines whether or not a term is a member of a list.

As with most recursive predicates, we will start with the boundary condition, or the simple case. An element is a member of a list if it is the head of the list.

```prolog
member(H,[H|T]).
```

This clause also illustrates how a fact with variable arguments acts as a rule.

The second clause of member/2 is the recursive rule. It says an element is a member of a list if it is a member of the tail of the list.

```prolog
member(X,[H|T]) :- member(X,T).
```

The full predicate is

```prolog
member(H,[H|T]).
member(X,[H|T]) :- member(X,T).
```

Note that both clauses of member/2 expect a list as the second argument. Since T in \[H\|T\] in the second clause is itself a list, the recursive call to member/2 works.

```prolog
?- member(apple, [apple, broccoli, crackers]).
yes

?- member(broccoli, [apple, broccoli, crackers]).
yes

?- member(banana, [apple, broccoli, crackers]).
no
```

Figure 11.1 has a full annotated trace of member/2.

[TABLE]

Figure 11.1. Trace of member/2

As with many Prolog predicates, member/2 can be used in multiple ways. If the first argument is a variable, member/2 will, on backtracking, generate all of the terms in a given list.

```prolog
?- member(X, [apple, broccoli, crackers]).
X = apple ;
X = broccoli ;
X = crackers ;
no
```

We will now trace this use of member/2 using the internal variables. Remember that each level has its own unique variables, but that they are tied together based on the unification patterns between the goal at one level and the head of the clause on the next level.

In this case the pattern is simple in the recursive clause of member. The head of the clause unifies X with the first argument of the original goal, represented by \_0 in the following trace. The body has a call to member/2 in which the first argument is also X, therefore causing the next level to unify with the same \_0.

Figure 11.2 has the trace.

[TABLE]

Figure 11.2. Trace of member/2 generating elements of a list

Another very useful list predicate builds lists from other lists or alternatively splits lists into separate pieces. This predicate is usually called append/3. In this predicate the second argument is appended to the first argument to yield the third argument. For example

```prolog
?- append([a,b,c],[d,e,f],X).
X = [a,b,c,d,e,f]
```

It is a little more difficult to follow, since the basic strategy of working from the head of the list does not fit nicely with the problem of adding something to the end of a list. append/3 solves this problem by reducing the first list recursively.

The boundary condition states that if a list X is appended to the empty list, the resulting list is also X.

```prolog
append([],X,X).
```

The recursive condition states that if list X is appended to list \[H\|T1\], then the head of the new list is also H, and the tail of the new list is the result of appending X to the tail of the first list.

```prolog
append([H|T1],X,[H|T2]) :-
  append(T1,X,T2).
```

The full predicate is

```prolog
append([],X,X).
append([H|T1],X,[H|T2]) :-
  append(T1,X,T2).
```

Real Prolog magic is at work here, which the trace alone does not reveal. At each level, new variable bindings are built, that are unified with the variables of the previous level. Specifically, the third argument in the recursive call to append/3 is the tail of the third argument in the head of the clause. These variable relationships are included at each step in the annotated trace shown in Figure 11.3.

[TABLE]

Figure 11.3. Trace of append/3

Like member/2, append/3 can also be used in other ways, for example, to break lists apart as follows.

```prolog
?- append(X,Y,[a,b,c]).
X = []
Y = [a,b,c] ;

X = [a]
Y = [b,c] ;

X = [a,b]
Y = [c] ;

X = [a,b,c]
Y = [] ;
no
```

### Using the List Utilities

Now that we have tools for manipulating lists, we can use them. For example, if we choose to use loc_list/2 instead of location/2 for storing things, we can write a new location/2 that behaves exactly like the old one, except that it computes the answer rather than looking it up. This illustrates the sometimes fuzzy line between data and procedure. The rest of the program cannot tell how location/2 gets its results, whether as data or by computation. In either case it behaves the same, even on backtracking.

```prolog
location(X,Y):-  
  loc_list(List, Y),
  member(X, List).
```

In the game, it will be necessary to add things to the loc_lists whenever something is put down in a room. We can write add_thing/3 which uses append/3. If we call it with NewThing and Container, it will provide us with the NewList.

```prolog
add_thing(NewThing, Container, NewList):-  
  loc_list(OldList, Container),
  append([NewThing],OldList, NewList).
```

Testing it gives

```prolog
?- add_thing(plum, kitchen, X).
X = [plum, apple, broccoli, crackers]
```

However, this is a case where the same effect can be achieved through unification and the \[Head\|Tail\] list notation.

```prolog
add_thing2(NewThing, Container, NewList):- 
  loc_list(OldList, Container),
  NewList = [NewThing | OldList].
```

It works the same as the other one.

```prolog
?- add_thing2(plum, kitchen, X).
X = [plum, apple, broccoli, crackers]
```

We can simplify it one step further by removing the explicit unification, and using the implicit unification that occurs at the head of a clause, which is the preferred form for this type of predicate.

```prolog
add_thing3(NewTh, Container,[NewTh|OldList]) :-
  loc_list(OldList, Container).
```

It also works the same.

```prolog
?- add_thing3(plum, kitchen, X).
X = [plum, apple, broccoli, crackers]
```

In practice, we might write put_thing/2 directly without using the separate add_thing/3 predicate to build a new list for us.

```prolog
put_thing(Thing,Place) :-
  retract(loc_list(List, Place)),
  asserta(loc_list([Thing|List],Place)).
```

Whether you use multiple logicbase entries or lists for situations, such as we have with locations of things, is largely a matter of style. Your experience will lead you to one or the other in different situations. Sometimes backtracking over multiple predicates is a more natural solution to a problem and sometimes recursively dealing with a list is more natural.

You might find that some parts of a particular application fit better with multiple facts in the logicbase and other parts fit better with lists. In these cases it is useful to know how to go from one format to the other.

Going from a list to multiple facts is simple. You write a recursive routine that continually asserts the head of the list. In this example we create individual facts in the predicate stuff/1.

```prolog
break_out([]).
break_out([Head | Tail]):-
  assertz(stuff(Head)),
  break_out(Tail).
```

Here's how it works.

```prolog
?- break_out([pencil, cookie, snow]).
yes

?- stuff(X).
X = pencil ;
X = cookie ;
X = snow ;
no
```

Transforming multiple facts into a list is more difficult. For this reason most Prologs provide built-in predicates that do the job. The most common one is findall/3. The arguments are

arg1  
A pattern for the terms in the resulting list

arg2  
A goal pattern

arg3  
The resulting list

findall/3 automatically does a full backtracking search of the goal pattern and stores each result in the list. It can recover our stuff/1 back into a list.

```prolog
?- findall(X, stuff(X), L).
L = [pencil, cookie, snow]
```

Fancier patterns are available. This is how to get a list of all the rooms connecting to the kitchen.

```prolog
?- findall(X, connect(kitchen, X), L).
L = [office, cellar, 'dining room']
```

The pattern in the first argument can be even fancier and the second argument can be a conjunction of goals. Parentheses are used to group the conjunction of goals in the second argument, thus avoiding the potential ambiguity. Here findall/3 builds a list of structures that locates the edible things.

```prolog
?- findall(foodat(X,Y), (location(X,Y) , edible(X)), L).
L = [foodat(apple, kitchen), foodat(crackers, kitchen)]
```

### Exercises

#### List Utilities

1- Write list utilities that perform the following functions.

- Remove a given element from a list
- Find the element after a given element
- Split a list into two lists at a given element (Hint - append/3 is close.)
- Get the last element of a list
- Count the elements in a list (Hint - the length of the empty list is 0, the length a non-empty list is 1 + the length of its tail.)

2- Because write/1 only takes a single argument, multiple 'writes' are necessary for writing a mixed string of text and variables. Write a list utility respond/1 which takes as its single argument a list of terms to be written. This can be used in the game to communicate with the player. For example

```prolog
respond(['You can''t get to the', Room, 'from here'])
```

3- Lists with a variable tail are called open lists. They have some interesting properties. For example, member/2 can be used to add items to an open list. Experiment with and trace the following queries.

```prolog
?- member(a,X).
?- member(b, [a,b,c|X]).
?- member(d, [a,b,c|X]).
?- OpenL = [a,b,c|X], member(d, OpenL), write(OpenL).
```

#### Nonsense Prolog

4- Predict the results of the following queries.

```prolog
?- [a,b,c,d] = [H|T].
?- [a,[b,c,d]] = [H|T].
?- [] = [H|T].
?- [a] = [H|T].
?- [apple,3,X,'What?'] = [A,B|Z].
?- [[a,b,c],[d,e,f],[g,h,i]] = [H|T].
?- [a(X,c(d,Y)), b(2,3), c(d,Y)] = [H|T].
```

#### Genealogical Logicbase

5- Consider the following Prolog program

```prolog
parent(p1,p2).
parent(p2,p3).
parent(p3,p4).
parent(p4,p5).

ancestor(A,D,[A]) :- parent(A,D).
ancestor(A,D,[X|Z]) :-
        parent(X,D),
        ancestor(A,X,Z).
```

6- What is the purpose of the third argument to ancestor?

7- Predict the response to the following queries. Check by tracing in Prolog.

```prolog
?- ancestor(a2,a3,X).
?- ancestor(a1,a5,X).
?- ancestor(a5,a1,X).
?- ancestor(X,a5,Z).
```

#### Expert System

8- Lists provide a convenient way to provide a simple menu capability to our expert system. We can replace the 'ask' predicate with menuask/3 where appropriate. menuask/3 will ask the player to select an item from a menu. The format is

```prolog
menuask(Attribute, Value, List_of_Choices).
```

For example

```prolog
size(X):- menuask(size, X, [large, medium, small]).
```

This requires two intermediate predicates, menu_display/2 and menu_select/2. The first writes each choice on a separate line preceded by a unique number. The second uses a number entered by the user to return the "nth" element of the list.
