# 7 More Example Programs

<!-- page 159 -->
More Example Programs

```prolog
Each section of this chapter deals with a particular application of Prolog program-
ming. We suggest that you read all of the sections in this chapter. Do not be concerned
if you do not understand the purpose of a program because you are not acquainted
with the particular application. For example, only those readers who have been in-
troduced to Calculus will appreciate the value of symbolic differentiation. Read it
anyway, because the program for finding symbolic derivatives demonstrates how to
use pattern matching to transform one kind of structure (an arithmetic expression)
into another one. What is important is to gain an understanding of programming
techniques available to the Prolog programmer, regardless of the particular applica-
tion.
    We hope that we have included enough applications to satisfy most tastes. Nat-
urally, all of the applications deal with areas that suit Prolog's way of representing
the world. You will not find how to calculate the flow of heat through a square metal
pipe, for example. It is possible to solve such problems using Prolog, but the ex-
pressiveness and power of Prolog is not shown to advantage on problems that are
essentially repetitious calculations over arrays of numbers. We would like to be able
to discuss large Prolog programs, such as those that are used by Artificial Intelli-
gence researchers for understanding natural language. Unfortunately, the aims of a
book like this one preclude discussion of programs that are longer than a page of text
and which would appeal only to a specialised audience.
```

## 7.1 A Sorted Tree Dictionary

```prolog
Suppose we wish to make associations between items of information, and retrieve
them when required. For example, an ordinary dictionary associates a word with its
definition, and a foreign language dictionary associates a word in one language with
```

<!-- page 160 -->
```prolog
a word in another language. We have already seen one way to make a dictionary:
with facts.
    If we want to make an index of the performance of horses in the British Isles
during the year 1938, we could simply define facts winnings(X, Y) where X is the
name of the horse, and Y is the number of guineas (a unit of currency) won by the
horse. The following database of facts could serve as part of such an index:
    winnings(aban's, 582).
    winnings(careful, 17).
    winnings(jingling_silver, 300).
    winnings(maloja, 356).
If we want to find out how much was won by maloja, we would simply ask the right
question, and Prolog would give us the answer:
    ?- winnings(maloja, X).
```

*X=356*

```prolog
Remember that when Prolog searches through a database to find a matching fact,
it starts at the top of the database and works its way down. This means that if our
dictionary database is arranged in alphabetical order, as is the one above, then Prolog
will take a short amount of time to find the winnings for ablaze, and it will take longer
to find the winnings for zoltan. Although Prolog can look through its database much
faster than you could look through a printed index, it is silly to search the index from
beginning to end if we know that the horse we are looking for is at the end.
    Also, although Prolog has been designed to search its database quickly, it is
not always as fast as we would wish. Depending on how large your index is, and
depending on how much information you have stored about each horse, Prolog might
take an uncomfortably long amount of time to search the index.
    For these reasons and others, computer scientists have devoted much effort to
finding good ways to store information, such as indices and dictionaries. Prolog itself
uses some of these methods to store its own facts and rules, but it is sometimes
helpful to use these methods in our programs. We shall describe one such method for
representing a dictionary, called the sorted tree. The sorted tree is both an efficient
way of using a dictionary, and a demonstration of how lists of structures are helpful.
    A sorted tree consists of some structures called nodes, where there is one node
for each entry in the dictionary. Each node has four components. One of these com-
ponents, called the key, is the one whose name determines its place in the dictionary
(the name of the horse in our example). The other item is used to store any other in-
formation about the object involved (the winnings in our example). In addition, each
node contains a tail (like the tail of a list) to a node containing a key whose name is
```

<!-- page 161 -->
```prolog
alphabetically less than the name of the key in the node itself. Furthermore, the node
contains another tail, to a node whose name is alphabetically greater than the key in
the node.
    Let us use a structure called w(H, W, L, G) (w is an abbreviation of "winnings")
where H is the name of a horse (an atom) used as the key, W is the amount of guineas
won (an integer), L is a structure with a horse whose name is less than H's, and G is
a structure with a horse whose name is greater than H's. If there are no structures for
L and G, we will leave them uninstantiated. Given a small set of horses, the structure
might look like this when written as a tree:
Represented as a structure in Prolog, and indented so as to illustrate the structure and
not to be too wide to fit on the page, this would look like:
    w(massinga,858,
        w(braemar,385,
            w(adela,588,_,_),
        w(panorama,158,
            w(nettleweed,579,_,_),
        J
```

)•

```prolog
Now given a structure like this, we wish to "look up" names of horses in the structure
to find out how many guineas they won during 1938. The structure would have the
format w(H, W, L, G) as above. The boundary condition is when the name of the
horse we are looking for is H. In this case, we have succeeded and need not try
any alternatives. Otherwise, we must use the term comparison built-in predicates
introduced in section 6.12 to decide which "branch" of the tree, L or G, to look up
recursively. We use these principles to define the predicate lookup for which the goal
lookup(H, S, G) means that horse H, when looked up in index S (a w structure), won
G guineas:
```

<!-- page 162 -->
```prolog
    lookup(H, w(H,G
                     ), Gl):- !, G=Gl.
    lookup(H, w(Hl,_,Before,_), G) :-
        H @< HI,
        lookup(H, Before, G).
    lookup(H, w(Hl,
                    ,After), G) :-
        H @> HI,
        lookup(H, After, G).
If we use this predicate to search a sorted tree, in general we examine fewer horses
than if we arrange them in a single list and search the list from start to finish.
    There is a surprising and interesting property of this lookup procedure: if we
look for the name of a horse which is not in the structure, then whatever information
we supply about the horse when we use lookup as a goal will be instantiated in the
structure when lookup returns from its recursion. For example, the interpretation of
lookup in this question
    ?- lookup(ruby_vintage, S, X).
is:
```

*there is a structure, instantiated to* `S` *such that* `ruby_vintage` *is paired with*

```prolog
   X.
So, lookup is inserting new components in a partially specified structure. We can
therefore use lookup repeatedly to create a dictionary. For instance,
    ?- lookup(abaris, X, 582), lookup(maloja, X, 356).
would instantiate X to be a sorted tree with two entries. The actual means by which
lookup functions for both storing and retrieving components takes advantage of what
you should know already about Prolog, so we urge you to work this out by yourself.
Hint: when lookup(H, S, G) is used in a conjunction of goals, the "changes" made to
S only hold over the scope of S.
Exercise 7.1. Experiment with the lookup predicate to determine what difference it
makes to insert items in the dictionary in a different order each time. For example,
what does the dictionary tree look like when entries have been inserted in the order:
massinga, braemar, nettleweed, panorama? In the order: adela, braemar, nettleweed,
massinga?
```

## 7.2 Searching a Maze

```prolog
It is a dark and stormy night. As you drive down a lonely country road, your car
breaks down, and you stop in front of a splendid palace. You go to the door, find
```

<!-- page 163 -->
```prolog
it open, and begin looking for a telephone. How do you search the palace without
getting lost? How do you know that you have searched every room? Also, what is the
shortest path to the telephone? It is for such situations that maze-searching methods
have been devised.
    In many computer programs, such as those for searching mazes, it is useful to
keep lists of information, and search the list if some information is needed at a later
time. For example, if we decide to search the palace for a telephone, we might need to
keep a list of the room numbers visited so far, so we don't go round in circles visiting
the same rooms over and over again. What we do is to write down the room numbers
visited on a piece of paper. Before entering a room, we check to see if its number
is on our piece of paper. If it is, we ignore the room, since we must have been to it
previously. If the room number is not on the paper, we write down the number, and
enter the room. And so on until we find the telephone. There are some refinements
to be made to this method, and we will do so later when we discuss graph searching.
But first, let's write down the steps in order, so we know what problems there are to
solve:
 1. Go to the door of any room.
 2. If the room number is on our list, ignore the room and go to Step 1. If there are no
   rooms in sight, then "backtrack" through the room we went through previously,
    to see if there are any other rooms near it.
 3. Otherwise, add the room number to our list.
 4. Look in the room for a telephone.
 5. If there is no telephone, go to Step 1. Otherwise we stop, and our list has the
   path that we took to come to the correct room.
We shall assume that room numbers are constants, but it does not matter whether
they are numbers or atoms. First, we can solve the problem of how to look up room
numbers on the piece of paper by using the member predicate defined in Section 3.3,
representing the piece of paper as a list. Now we can get on with the problem of
searching the maze. Let us consider a small example, where we are given the floor
plan of a house, with letters labelling the different rooms, as shown in Figure 7.1.
Notice that gaps in the walls are meant to represent doors, and that room a is simply
a representation of the space outside the house. There are doors from rooms a to b,
from c to d, from f to e, and so forth. The facts about where there are doors can be
represented as Prolog facts.
Notice that the information about doors is not redundant. For example, although we
have said that there is a door between room g and room e, we have not said that there
is a door between room e and room g: we have not asserted d(e, g).
```

<!-- page 164 -->
```prolog
d
                    c
```

f

```prolog
                              e
                                              b
                                                              a
       d(a, b).
       d(b, e).
       d(b, c).
       d(d, e).
       d(c, d).
       d(e, f).
       d(g, e).
                          g
              Fig. 7.1. A floor plan and the program that represents it
    To get around this problem of representing two-way doors, we could write a du-
plicate d fact for each door, reversing the arguments. Or, we could make the program
recognise that each door fact can be interpreted in two ways. This is the alternative
we choose in the program that follows.
To go from one room to another, we must recognise one of two cases:
•
   we are in the room we want to go to, or
•
   we have to pass through a door, and recognise these cases again (recursively).
Consider the goal go(X, Y, T), which succeeds if it is possible to go from room X to
room Y. The third argument T is our piece of paper that we carry, that has a "trail" of
the room numbers that we have visited so far.
    The boundary condition for going from room X to room Y is if we are already at
room Y (this is, if X = Y). This is represented as the clause:
    go(X, X, T).
Otherwise we choose some adjoining room, call it Z, and see if we have been to it
before. If we haven't, then we go from Z to Y, adding Z to our list. All of this is
represented as the following clause:
    go(X, Y, T) :- d(X, I), \+ member(Z, T), go(Z, Y, [Z|T]).
In words, this could be interpreted as:
   To "go" from X to Y, not passing though the rooms on T, find a door from X
   to an adjacent room (Z), ensure that Z is not already on the list, and go from
   Z to Y, using the list T with Z added to it.
```

<!-- page 165 -->
```prolog
There are three ways that failures can occur in the use of this rule. First, if there is no
door from X to anywhere. Second, if the door we choose is on the list. Third, if we
cannot "go" to Y from the Z we chose because it fails deeper in the recursion. If the
first goal d(X, Z) fails, then it will cause this use of go to fail. At the top level (not a
recursive call), this means that there is no path from X to Y. At lower levels, it simply
means we must backtrack to find a different door.
    The program as stated treats each door as a one-way door. If we assume that
having a door from room a to room b is just the same as having a door from room b
to room a, then we must make this explicit, as indicated above. Instead of supplying
a duplicate fact for each d fact but with the arguments reversed, there are two ways
to put this information in the program. The most obvious way is to add another rule,
giving:
    go(X, X, T).
    go(X, Y, T):- d(X, Z), \+ member(Z, T), go(Z, Y, [Z|T]).
    go(X, Y, T) :- d(Z, X), \+ member(Z, T), go(Z, Y, [Z|T]).
Or, the semicolon predicate (for disjunction) can be used:
    go(X, X, T).
    go(X, Y, T) :-
        (d(X, Z); d(Z, X)),
        \+ member(Z, T),
        go(Z, Y, [Z|T]).
But perhaps the clearest way is to keep the program simple, and augment the d(X,Y)
relation so that it is symmetric:
    d(a, b). d(b, a).
    d(b, e). d(e, b).
    d(b, c). d(c, b).
    d(d, e). d(e, d).
    d(c, d). d(d, c).
    d(e, f). d(f, e).
    d(g, e). d(e, g).
Now for finding the telephone. Consider the goal hasphone(X) which succeeds if
room X has a telephone. If we want to say that room g has a telephone, we simply
write our database with
    hasphone(g).
in it. Supposing we start at room a, one possible question we ask to find the path to
the telephone is:
    ?- go(a, X, []), hasphone(X).
```

<!-- page 166 -->
```prolog
This question is a "generate and test", which finds possible rooms, then checks them
for a telephone. Another way is to satisfy hasphone(X) first, then see whether we can
go from a to X:
    ?- hasphone(X), go(a, X, []).
This method is more efficient, but it implies that we "know" where the telephone is
before we have begun the search.
    Initialising the third argument to the empty list means that we start with a clean
piece of paper. This can be changed to provide variety. The question, "Find the tele-
phone without entering rooms d and f' would be expressed in Prolog as
    ?- hasphone(X), go(a, X, [d,f]).
In Section 7.9 we will describe some general graph searching procedures, including
a program that finds the shortest path through a graph.
Exercise 7.2: Annotate the above program so that it will print messages such as "en-
tering room Y" and "found telephone in room Y" with the appropriate room numbers
filled in.
Exercise 7.3: Can alternate paths be found by this program? If so, where do you put
the "cut" goal to prevent more than one path from being found?
Exercise 7.4: What determines the order in which rooms are searched?
```

## 7.3 The Towers of Hanoi

```prolog
The Towers of Hanoi is a game played with three poles and a set of discs. The discs
are graded in diameter, and fit onto the poles by means of a hole cut through the
centre of each disc. Initially all the discs are on the left-hand pole. The object of the
game is to move all of the discs onto the centre pole. The right-hand pole can be used
as a "spare" pole, a temporary resting place for discs. Each time a disc is moved from
one pole to another, two constraints must be observed: only the top disc on a pole
can be moved, and no disc may be placed on top of a smaller one.
         Left Pole
                           Centre Pole
                                              Right Pole
```

<!-- page 167 -->
```prolog
Many people who play this game never actually discover the quite simple strategy
that will correctly play the Towers of Hanoi game with three poles and N discs. To
save you the effort of finding it, we reveal it here:
• The boundary condition occurs when there are no discs on the source (the left-
   hand) pole.
•
   Move N — 1 discs from the source pole to the spare pole (the right-hand one),
   using the destination as a spare. Notice that this is a recursive move.
•
   Move a single disc from the source pole to the destination pole.
• Finally, move TV — 1 discs from the spare to the destination, using the source as
   the spare.
The Prolog program that implements this strategy is defined as follows. We define
a predicate hanoi having one argument, such that hanoi(N) means to print out the
sequence of moves when N discs are on the source pole. Of the two move clauses,
the first one is the boundary condition as described above, and the second clause
implements the recursive cases. The predicate move has four arguments. The first
argument is the number of discs to be moved. The other three are atoms that name the
poles which are the source, destination and spare for moving the discs. The predicate
inform uses write to print out the names of the poles that are involved in moving a
disc.
    hanoi(N) :- move(N, left, centre, right).
    move(0,
             _, _):-!.
    move(N, A, B, C) :-
        M is N-l,
        move(M, A, C, B), inform(A, B), move(M, C, B, A).
    inform(X, Y) :-
        write([move,a,disc,from, the,X,pole,to,the,Y,pole]),
        nl.
```

## 7.4 Parts Inventory

```prolog
In Chapter 3 we discussed a program for printing a list of parts required in con-
structing an assembly when given an inventory of parts. In the improved program
described in this section, we shall take into account how many of each part is re-
quired, by accumulating the quantities of parts required as we descend from assem-
blies to their constituents. The improved program also handles duplicates properly:
the collect procedure removes duplicates, while summing up the quantities of each
part required, before the answer is printed out.
```

<!-- page 168 -->
```prolog
    The structure of the inventory database is similar to that described in Chapter
3. An assembly is represented as a list of structures of the form quant(X,Y), where X
is the name of some part (a basic part or an assembly), and Y is the quantity of such
parts needed. For example, the list of structures for a bicycle having two wheels and
a frame would look like this:
    [quant(wheel,2), quant(frame,l)] •
This can just as well be used for any list of items, such as a grocery list:
    [quant(apple,12), quant(banana,2), quant(loaf,2)] .
We now list each predicate of the modified program, together with a description of
its purpose.
partlist(A): prints out a list of all of the basic parts required, and the quantities of
each, for the construction of assembly A.
    partlist(T) :-
        partsof(l, T, P),
        collect(P, Q),
        printpartlist(Q).
partsof(N, X, P): P is a list of structures quant(Part,Num) giving the part name Part
and the quantity Num of each required for the construction of N X's. N is an integer
and X is an atom which is the name of some part.
    partsof(N, X, P) :- assembly(X, S), partsoflist(N, S, P).
    partsof(N, X, [quant(X,N)]) :- basicpart(X)
partsoflist(N, S, P): P is a list of quant structures as above, required for the construc-
tion of the sum of all the members of the list S, given that N such lists are required. N
is an integer, S is a list of quant structures.
    partsoflist(_, [], []).
    partsoflist(N, [quant(X,Num)|L], T) :-
        M is N * Num,
        partsof(M, X, Xparts),
        partsoflist(N, L, Restparts),
        append(Xparts, Restparts, T).
collect(P, A): P and A are lists of quant structures. A is a list with the same members
as P except that there are no duplicate parts, and for any duplicates in P, the quantity
of that part in A is the sum of all the corresponding quantities in P. We use collect
to collect several descriptions of collections of like parts. For instance, "3 screws, 4
cushions, and 4 screws" is collected to form "7 screws and 4 cushions".
```

<!-- page 169 -->
```prolog
    collect([], []).
    collect([quant(X,N)|R], [quant(X,Ntotal)|R2]) :-
        collectrest(X, N, R, 0, Ntotal),
        collect(0, R2).
collectrest(X, M, L, 0, N): L and 0 are lists of quant structures. 0 is the list of all the
members of L except for those which have X as their part. X is an atom which is the
name of some part. N is the sum of all the quantities of X in list L, added to M. M is
an integer that is used to accumulate the quantity of X's in L, and is passed down to
each call of collectrest. At the end of the recursion, which is caught by the boundary
condition, M is returned as N.
    collectrest(_,N, [], [], N).
    collectrest(X, N, [quant(X,Num)|Rest], Others, Ntotal) :-
        i
```

• ,

```prolog
        M is N + Num,
        collectrest(X, M, Rest, Others, Ntotal).
    collectrest(X, N, [Other|Rest], [0ther|0thers], Ntotal) :-
        collectrest(X, N, Rest, Others, Ntotal).
printpartlist(P): P is a list of quant structures, printed one structure per line of output.
The put_char('\t') goal prints a horizontal tab motion.
    printpartlist([]).
    printpartlist([quant(X,N)|R]) :-
        write(''), write(N), put_char('\f), write(X), nl,
        printpartlist(R).
Finally, append(A, B, C), which is used in the definition of partsoflist, is the predicate
whose definition we have seen several times before.
```

## 7.5 List Processing

```prolog
In this section we shall describe some basic predicates that are useful for manipulat-
ing lists. Because Prolog makes arbitrary data structures available to you, lists may
not take on the omnipresent r61e that they do in other programming languages such
as LISP and POP-2. Whether or not your programs will make use of lists, it is always
important to understand how the predicates defined in this section work, because they
employ principles that can be applied to manipulating any kind of data structure.
```

**Finding the last element of a list: The goal last(X, L) succeeds if element X is the last**

```prolog
element of list L. The boundary condition is when there is only one element in L. The
first rule checks for this. The usual kind of recursive case forms the second rule.
```

<!-- page 170 -->
```prolog
last(X, [X]).
last(X, [_|Y]) :- last(X, Y).
?- last(X, [talk,of,the,town]).
```

*X = town* *Checking for consecutive elements:* `The goal nextto(X, Y, L) succeeds if elements X`

```prolog
and Y are consecutive elements of list L. Due to the way variables work, either X, or
Y, or both, could be uninstantiated when an attempt is made to satisfy the goal. The
first clause, which checks for the boundary condition, must also assume that there
may be more elements in the list after X and Y. This is why the anonymous variable
appears, holding down the tail of the list.
    nextto(X, Y, [X,Y|J).
    nextto(X, Y, [JZ]) :- nextto(X, Y, Z).
Appending lists: We have seen this example before in Section 3.6. The goal ap-
pend(X, Y, Z) succeeds when Z is a list constructed by appending Y to the end of X.
For example,
    ?- append([a,b,c], [d,e,f], Q).
```

*Q=[a,b,c,d,e,f]*

```prolog
It is defined as follows:
    append([], L, L).
    append([X|Ll], L2, [X|L3]) :- append(Ll, L2, L3).
The boundary condition occurs when the first argument is the empty list. This is
because appending the empty list to a list does not change the list. Furthermore, we
will gradually approach the boundary condition because each recursion of append
removes an element from the head of the first argument.
    Notice that any two of the arguments of append can be instantiated, and append
will instantiate the third argument to the appropriate result. This property is true of
many of the predicates defined in this chapter. Because of the flexibility of append,
we can actually define several other predicates in terms of it:
    last(El, List) :- append(_, [El], List).
    next_to(Ell, E12, List) :- append(_, [Ell,El2|J, List).
    member(El, List) :- append(_, [El|_], List).
Reversing a list: The goal rev(L, M) succeeds if the result of reversing the order of
elements in list L is list M. The program uses a standard technique, where we reverse
a list by appending its head to the reverse of its tail. And, what better way to reverse
the tail than to use rev itself! The boundary condition is when the first argument is
reduced to the empty list, in which case the result is also the empty list.
```

<!-- page 171 -->
```prolog
    rev([], []).
    rev([H|T], L) :- rev(T, Z), append(Z, [H], L).
Notice that we have enclosed H in square brackets in the second argument of append.
This is because H was selected as the head of the first argument, and the head of a
list is not necessarily a list. By convention, the tail of a list is always a list.
    For a more efficient implementation of rev, we can incorporate the appending
into the clauses for rev:
    rev2(Ll, L2) :- revzap(Ll, [], L2).
    revzap([X|L], L2, L3) :-
        revzap(L, [X|L2], L3). revzapQ], L, L).
The second argument of revzap is used to hold "the answer so far", in other words, an
accumulator, as introduced in Section 3.7. Whenever a new piece (X) of the answer is
discovered, the accumulator passed to the rest of the program is the old accumulator
combined with the new piece X. At the end, the last accumulator is passed back to be
the answer in the original goal.
Deleting one element: The goal efface(X, Y, Z) removes the first occurrence of ele-
ment X from list Y, giving a new effaced list Z. If there is no such element X in the
list Y, the goal fails. The boundary condition is when we have found the element.
Otherwise, we recur on the tail of Y.
    efface(A, [A|L], L) :- !.
    efface(A, [B|L], [B|M]) :- efface(A, L, M).
It is easy to add a clause so that the predicate does not fail when the second argument
becomes reduced to the empty list. The new clause, which recognises a new boundary
condition, is
    efface(_, [], []).
```

*Deleting all occurrences of an element:* `The goal delete(X, LI, L2) constructs a list`

```prolog
L2 by deleting all the elements X from list LI. The boundary condition is when LI
is the empty list, meaning that we have recurred down the entire length of the list.
Otherwise, if X is in the list, then the result is the tail of the list, except that we delete
from that as well. The final case is if we have seen something other than X in the
second argument: we simply recur.
    delete(_, [], []).
    delete(X, [X|L], M) :- !, delete(X, L, M).
    delete(X, [Y|L1], [Y|L2]) :- delete(X, LI, L2).
Substitution: This is similar to delete, except instead of deleting a desired element,
we substitute some other element in its place. The goal subst(X, L, A, M) will con-
struct a new list M made up from elements of list L, except that any occurrences of X
```

<!-- page 172 -->
```prolog
will be replaced by A. There are three cases. The first one is the boundary condition,
exactly as for delete. The second one is in case an X is found in the second argument,
and the third is in case something other than X is found.
    SUbst(_, [],
                 []).
    subst(X, [X|L], A, [A|M]) :- !, subst(X, L, A, M).
    subst(X, [Y|L], A, [Y|M]) :- subst(X, L, A, M).
Sublisf. List X is a sublist of list Y if every item in X also appears in Y, consecutively,
and in the same order. The following goal would succeed:
    sublist([of,the,club], [meetings,of,the,club,will,be,held]).
The sublist program requires two predicates: one to find a matching first element, and
one to ensure that the remainder of the first argument matches element-for-element
with the remainder of the second argument:
    sublist([X|L], [X|M]) :- prefix(L, M), !.
    sublist(L, [JM]) :- sublist(L, M).
    prefix([], J .
    prefix([X|L], [X|M]) :- prefix(L, M).
Removing duplicates: The predicate remdup runs through a list of any elements, and
makes a new list. Although duplicate elements may exist in the input, we want the
output list to contain at most one of each element. The goal remdup(L, M) succeeds
if L is the input list, and M is a list of the elements appearing in L without duplication.
The definition uses an auxiliary predicate dupacc in which the accumulator (see Sec-
tion 3.7) is the second argument, initialised to the empty list. We also use predicate
member (from Section 3.3).
    remdup(L, M) :- dupacc(L, [], M).
    dupacc([], A, A).
    dupacc([H|T], A, L) :- member(H, A), !, dupacc(T, A, L).
    dupacc([H|T], A, L) :- dupacc(T, [H|A], L).
Predicate dupacc has three clauses. The boundary condition states that, when the in-
put list is empty, the result will be whatever we have accumulated so far. The second
clause checks whether the next element of the list is a member of the accumulated
list. If it is, we simply recur on the tail, making no change to the accumulator. Other-
wise, using the next clause, we recur on the tail of the input list, with an accumulator
that has the new element (H) added.
Mapping: A powerful technique is the ability to convert one list into another list by
applying some function to each element of the first list, using the successive results
as the successive members of the second list. Our program in Chapter 3 for changing
```

<!-- page 173 -->
```prolog
one sentence into another is an example of mapping. We say that we are "mapping
one sentence into another".
    Mapping is so useful that it justifies a section of its own. Furthermore, because
lists in Prolog are simply special cases of structures, we will postpone discussion of
mapping lists until Section 7.12. Mapping appears in other guises also. Section 7.11,
on symbolic differentiation, describes a way to map arithmetic expression onto other
ones.
```

## 7.6 Representing and Manipulating Sets

```prolog
The set is one of the most important data structures used in Mathematics, and op-
erations with sets find applications in computer programming as well. A set is a
collection of elements, rather like a list, but it does not make sense to ask where or
how many times something is an element of a set. Thus, the set {1,2,3} is the same
as the set {2,3,1}, because all that matters is whether a given item is an element of
the set or not. Sets may also have other sets as members. The most fundamental op-
eration on a set is to determine whether some element is a member of some given
set.
    It should come as no surprise that a convenient representation for sets is as
lists. A list can contain arbitrary elements including other lists, and it is possible to
define a membership predicate over lists. However, when we represent a set as a list,
we will arrange that the list only has one element for each object that belongs to
the set. Dealing with lists without duplicated elements simplifies some operations
such as removing elements. So we will deal only with lists without duplicates. The
predicates described in this section expect and maintain this property.
    It is usual to define the following operations over sets. We shall include the
usual mathematical notation for those who are accustomed to it:
```

*Set membership:* X € Y

```prolog
X is a member of some set Y if X is one of the elements of Y.
Example: a € {c,a,t}
```

*Subset:* X C Y

```prolog
Set X is a subset of set Y if every element of X is also an element of Y. Y may contain
some elements that X does not.
Example: {x,r,u} C {p,q,r,s,t,u,v,w,x,y,z}
```

*Intersection:* X n Y

```prolog
The intersection of sets X and Y is the set containing those elements which are
members of X and which are members of Y.
Example: {r,a,p,i,d} n {p,i,c,t,u,r,e} = {r,i,p}
```

<!-- page 174 -->
```prolog
Union: X U Y
The union of sets X and Y is the set consisting of members from X, or Y, or both.
Example: {a,b,c} U {c,d,e} = {a,b,c,d,e}
These are the basic operations that are normally used to manipulate sets. We can now
write Prolog programs to implement each one. The first basic operation, membership,
is the same member predicate that we have seen several times before. However, the
definition of member that we use does not contain the "cut" goal in the boundary
case so that we can generate successive elements of the list by backtracking.
    member(X, [X|_]).
    member(X, [_|Y]) :- member(X, Y).
Next, a predicate subset for which subset(X, Y) will succeed if X is a subset of Y. The
first clause in the definition embodies the mathematical notion that the empty set is a
subset of every set. In Prolog, this notion turns into a way of checking the boundary
condition on the first argument, since we recur on its tail.
    subset([], Y).
    subset([A|X], Y) :- member(A, Y), subset(X, Y).
Next, the most complicated example, intersection. The goal intersection(X, Y,Z) will
succeed if the intersection of X and Y is Z. Here is where we have to assume that the
lists contain no duplicated elements.
    intersection^], X, []).
    intersection([X|R], Y, [X|Z]) :-
        member(X, Y),
        i
```

V

```prolog
        intersection^, Y, Z).
    intersection([X|R], Y, Z) :- intersection^, Y, Z).
Finally, union. The goal union(X, Y, Z) will succeed if the union of X and Y is Z.
Notice that union looks rather like an arranged marriage between intersection and
append:
    union([], X, X).
    union([X|R], Y, Z) :- member(X, Y), !, union(R, Y, Z).
    union([X|R], Y, [X|Z]) :- union(R, Y, Z).
This completes our repertoire of set-processing predicates. Although sets may not
feature in the kind of programming you intend to do, it is worthwhile to study these
examples to obtain a clear understanding of how you can make recursion and back-
tracking work for you.
```

<!-- page 175 -->
## 7.7 Sorting

```prolog
Sometimes it is helpful to sort a list of elements into order. If the elements of the
list are integers, we can use the "<" predicate to decide whether two integers are in
order. The list [1/2,3] is sorted into order because the predicate "<" succeeds for
each consecutive pair of integers in the list. If the elements are atoms, we can use
"@=<" as discussed in Section 7.1. The list [alpha, beta, gamma] is sorted into
order because the predicate "@=<" succeeds for each consecutive pair of atoms in
the list.
    Computer scientists have developed many techniques for sorting a list into order
when given some predicate that tells us whether consecutive elements are in order.
We will show Prolog programs for four such sorting methods: naive sort, insertion
sort, bubble sort, and Quicksort. Each program will use a predicate order which can
be defined by using "<" or "@<" or any other predicate you desire, depending on
what kind of structure you are sorting. We assume that the goal order(X,Y) will suc-
ceed if objects X and Y are in the desired order, that is, if X is less than Y in some
sense.
    One way of sorting objects into ascending order is first to generate some permu-
tation of the objects, and then test to see if the resulting list of objects is in ascending
order. If they are not, then we generate some other permutation of the objects. This
method is known as the naive sort:
    sort(Ll, L2) :- permutation(Ll, L2), sorted(L2), !.
    permutation([], []).
    permutation(L, [H|T]) :-
        append(V, [H|U], L),
        append(V, U, W),
        permutation(W, T).
    sorted([]).
    sorted([X]).
    sorted([X, Y|L]) :- order(X, Y), sorted([Y|L]).
The predicate append is defined numerous times previously in this book. In this
program, the predicates have the following meanings: sort(Ll, L2) means that L2 is
the list which is the sorted version of LI; permutation(Ll, L2) means that L2 is a list
consisting of all the elements of list LI in one of the many possible orders — this
is a generator in the terminology of Section 4.3. Predicate sorted(L) means that the
numbers in the list are sorted into increasing order — this is a tester.
    The goal of finding the sorted version of a list consists of generating a permu-
tation of the elements and testing to see if it is sorted. If it is, we have found the
```

<!-- page 176 -->
```prolog
unique answer. Otherwise we must carry on generating permutations. This is not a
very efficient way to sort a list.
    In the insertion sort method, each item of the list is considered one at a time,
and each item is inserted into a new list in the appropriate position. If you play card
games, then you probably use this method when you sort your hand, picking up one
card at a time. The goal insort(X, Y) succeeds when list Y is a sorted version of list
X. Each element is removed from the head of the list and passed to insortx, which
inserts the element in the list and returns the modified list:
    insort([], []).
    insort([X|L], M) :- insort(L, N), insortx(X, N, M).
    insortx(X, [A|L], [A|M]) :-
        order(A, X), !, insortx(X, L, M).
    insortx(X, L, [X|L]).
A convenient way to obtain a more general-purpose insertion sorting predicate is to
use the ordering predicate as an argument of insort. Here we add a third argument
as the ordering procedure, and use the "=.." predicate as discussed in Chapter 6 to
construct a goal which is then called:
    insort([], [], _).
    insort([X|L], M, 0) :- insort(L, N, 0), insortx(X, N, M, 0).
    insortx(X, [A|L], [A|M], 0) :-
        P=.. [0, A, X],
        call(P), !,
        insortx(X, L, M, 0).
    insortx(X, L, [X|L], 0).
Then we can use goals such as insort(A, B, '<') and insort(A, B, '@<) without
requiring a predicate named order. This technique can be applied to the other sorting
algorithms in this section.
    The bubble sort checks the list to see if two adjacent elements are out of order.
If so, then they are exchanged. This process is repeated until no more exchanges are
necessary. Whereas the insertion sort makes elements "sink" down to the appropri-
ate level, the bubble sort is so named because it makes elements "float" up to the
appropriate level.
    busort(L, S) :-
        append(X, [A,B|Y], L),
        order(B, A), !,
        append(X, [B,A|Y], M),
        busort(M, S).
    busort(L, L).
```

<!-- page 177 -->
```prolog
    append([], L, L).
    append([H|T], L, [H|V]) :- append(T, L, V).
Notice that the append predicate is the same as we have seen before, and that in this
example it must be able to backtrack on each solution found. Hence, a "cut" does not
appear in the first clause of append. This is another example of what some people call
"non-deterministic" programming, because we are using append to select arbitrary
members of list L. It is the responsibility of append to ensure that the set of selections
from L is complete.
    Quicksort is a more sophisticated sorting method due to C.A.R. Hoare. To im-
plement Quicksort in Prolog we first need to split a list consisting of head H and tail
T into two lists L and M such that:
•
   all the elements of L are less than H;
•
   all the elements of M are greater than or equal to H, and
•
   the order of elements within L and M is the same as in [H |T].
Once we have split the list, we Quicksort each list (this is the recursive part), and
append M onto the back of L. The goal split(H, T, L, M) partitions the list [H|T] into L
and M as described above:
    split(H, [A|X], [A|Y], Z) :- order(A, H), split(H, X, Y, Z).
    split(H, [A|X], Y, [A|Z]) :- \+(order(A, H)), split(H, X, Y, I).
    split(_, [], [], []).
The Quicksort program is now:
    quisort([], []).
    quisort([H|T], S) :-
        split(H, T, A, B),
        quisort(A, Al),
        quisort(B, Bl),
        append(Al, [H|B1], S).
It is also possible to build the append into the sorting program, giving the more
efficient program:
    quisortx([], X, X).
    quisortx([H|T], S, X) :-
        split(H, T, A, B),
        quisortx(A, S, [H|Y]>,
        quisortx(B, Y, X).
In this case the third argument is used as a temporary work area, and it is initialised
to the empty list when quisortx is used as a goal.
```

<!-- page 178 -->
```prolog
    More information on sorting can be found in Volume 3 (Sorting and Search-
ing) of The Art of Computer Programming by Donald Knuth, published in 1973 by
Addison-Wesley. Hoare's Quicksort method is described in his paper in Computer
Journal 5 (1962), pages 10 to 15.
Exercise 7.5: Verify that, when given a known list as LI, permutation(Ll,L2) will
generate all the permutations of Ll (once each) as the alternative values of L2. In
what order are the solutions generated?
Exercise 7.6: Quicksort works best on large lists because it converges to a solu-
tion more rapidly. However, the amount of work done at each recurrence of quisort
is more than the other methods, because it must use split. So, perhaps when sorting
small lists, then quisort's recursive calls could be replaced by calls to some other sort-
ing method, say insertion sort. Develop a "hybrid" sorting program that uses Quick-
sort to sort the large partitions (the lists made by the split predicate), but switches to
another sorting method when the size of the partition becomes sufficiently low that
the insertion sort can be used. Hint: since split has to look at every element of the list
anyway, it can be used to compute the length of a list.
```

## 7.8 Using the Database

```prolog
In all of the programs discussed so far, we have used the database only to store facts
and rules that define predicates. It is possible to use the database to store ordinary
structures, such as the structures that are constructed as a program executes. Until
now, we have been passing such structures from one predicate to another by us-
ing arguments. However, one reason for storing information in the database, rather
than passing it around through arguments, is that sometimes a piece of information
may be needed by many parts of a program, and that the alternative would involve
something like one or two extra arguments to most predicates. Another reason is to
retain information over backtracking. In this section we describe three predicates that
take advantage of the database for storing structures that have a lifetime that extends
further than is possible by using variables. The three predicates are random, which
generates a pseudo-randomly chosen integer each time it is called; findall, which
generates a list of all the structures that make a given predicate succeed, and gensym,
which generates atoms with unique names.
```

### 7.8.1 Random

```prolog
The goal random(R, N) instantiates N to a randomly chosen integer between 1 and R.
The method of choosing a random integer is to use a congruential method, using a
```

<!-- page 179 -->
```prolog
"seed" that is initialised to an arbitrary integer. Each time a random integer is desired,
the answer is computed using the existing seed, and a new seed is determined, and
stored until the next time that a random integer is desired. We use the database to
store the seed between calls to random. After the seed is used, we retract the old
information about its value. Then, the new seed is computed, and new information is
asserted. The initial seed is simply a fact in the database, with the dynamic predicate
seed having one argument, the integer value of the seed.
    :- dynamic seed/1.
    seed(13).
    random(R, N) :-
        seed(S),
        N is (S mod R) + 1,
        retract(seed(S)),
        NewSeed is (125 * S + 1) mod 4096,
        asserta(seed(NewSeed)), !.
We can take advantage of the semantics of retract to simplify the definition of random
by getting the seed and retracting it at the same time, in the following way:
    random(R,N) :-
        retract(seed(S)),
        N is (S mod R)+l,
        NewSeed is (125*S+1) mod 4096,
        asserta(seed(NewSeed)), !.
To print out a lot of random numbers between 1 and 10, but stopping when 5 has
been generated, all that is required is:
    ?- repeat, random(10, X), write(X), nl, X = 5.
We should warn that this is not a particularly good algorithm for generating a random
sequence; the purpose here is to demonstrate a problem involving saving the state of
a computation.
```

### 7.8.2 Gensym

```prolog
The predicate gensym provides a way of generating new Prolog atoms. If we have a
program that is assimilating information about the world (perhaps by understanding
English sentences about it), we have the problem of dealing with the situation when a
new object is discovered. A natural way to represent an object is with a Prolog atom.
If the object has not been encounted before, we must ensure that the atom we assign
```

<!-- page 180 -->
```prolog
to it does not accidentally coincide with the one representing some other object.
That is, we require the ability to generate a new atom. We might as well require that
the atom have some mnemonic significance as well, so that we can understand the
program's output. If we were representing students, say, a reasonable solution would
be to name the first student studentl, the second student2, the third student3, and so
on. Then if in addition we had to represent teachers, we could pick atoms teacherl,
teacher2, teacher3 and so on to represent them.
    The purpose of gensym is to generate new atoms from given roots (like student
and teacher). For each root, it remembers what number was last used, so that next
time it is asked to generate an atom from that root it can guarantee that it will be
different from the ones generated before. Thus, the first time the question:
    ?- gensym (student, X).
is asked, the answer is
```

*X = studentl*

```prolog
The next time, the answer will be X = student2 and so on. Note that these different
solutions are not generated on backtracking (gensym (X, Y) can never be resatisfied),
but are generated by subsequent goals involving the predicate.
    The definition of gensym makes use of the subsidiary dynamic predicate cur-
rent_num. It is by putting facts about current_num into the database (and also by
removing facts that are no longer applicable) that gensym keeps track of which num-
ber to use next with a given root. The fact current_num(Root, Num) means that the
last number used with root Root was Num. That is, the last atom generated for this
root had the characters derived from Root followed by those derived from Num. The
normal course of action when Prolog tries to satisfy a gensym goal is that the last
current_num fact about the given root is removed from the database, 1 is added to
the number involved and a new current_num fact is added to replace it. Meanwhile,
the new number is used as the basis for generating an atom. It is very convenient to
keep the current_num information in the database. The only alternative is to have ev-
ery predicate directly or indirectly involved in a gensym carry the information about
current numbers in extra arguments. Here is the program:
    :- dynamic current_num/2.
    gensym(Root, Atom) :-
        get_num(Root, Num),
        atom_chars(Root, Namel),
        number_chars(Num, Name2),
        append(Namel, Name2, Name),
        atom_chars(Atom, Name).
```

<!-- page 181 -->
```prolog
    get_num(Root,Num) :-
        retract(current_num(Root, Numl)), !,
        Num is Numl + 1,
        asserta(current_num(Root, Num)).
    get_num(Root, 1) :- asserta(current_num(Root, 1)).
The predicate get_num is used to retrieve the next number to be used with the given
root. If there is a number already associated with the root (first clause), it returns
the next number and updates the database. If there is no number so far associated
with the root (second clause), it starts off the record with 1. All gensym has to do is
reduce the root and number to characters, using the appropriate built-in predicates,
concatenate the lists and make an atom whose characters are the resulting list.
```

### 7.8.3 Findall

```prolog
In some applications it is helpful to determine all of the terms that satisfy some
predicate. For example, we might want to make a list of all of the children of Adam
and Eve using the parents predicate of Chapter 1 (and assuming we had a database
of parents facts). For this we could use a predicate called findall, which is already
provided in any Prolog implementation conforming to the standard. Standard Prolog
also contains a similar predicate setof. Because findall is a good illustration of using
the database in Prolog, we will show how findall might be defined in Prolog.
    The goal findall(X, 6, L) constructs a list L consisting of all of the objects X such
that the goal G is satisfied. It is assumed that G is instantiated to an ordinary term,
except that findall treats it as a Prolog goal. Also, X will appear somewhere inside G.
So, G can be instantiated to a Prolog goal of arbitrary complexity. Here is how we
could find out all the children of Adam and Eve:
    ?- findall(X, parents(X,eve,adam), L).
The variable L would be instantiated to a list of all of the X's that satisfy par-
ents^,eve,adam). All that findall needs to do is to repeatedly attempt to satisfy its
second argument, and each time it succeeds it should take whatever X is instantiated
to, and put it in the database. When the attempt to satisfy the second argument fi-
nally fails, then we go back and collect all of the X's that we put into the database.
The resulting list is returned as the third argument. If the attempt to satisfy the second
argument never succeeds, then the third argument will be instantiated to the empty
list. To put items into the database, we use the built-in asserta predicate, which in-
serts terms before those that have the same functor. To record that an item X has been
found, we add a fact to the database about the dynamic predicate found. The Prolog
clauses for findall are as follows:
```

<!-- page 182 -->
```prolog
    :- dynamic found/1.
    findall(X, G, J
                 :-
        asserta(found(mark)),
        ca 11(G),
        asserta(found(result(X))),
        fail.
    findall(
               L) :- collect_found([], M), !, L = M.
    collect_found(S, L) :-
        getnext(X),
        i
        collect_found([X|S], L).
    collect_found(L, L).
    getnext(Y) :- retract(found(X)), !, X = result(Y).
The findall predicate first adds a special marker fact for found, in the form of a fact
with argument mark. This special marker serves to mark the place in the database
before which all of the X's satisfying G in this use of findall will be asserted. Every
other argument of found will be of the form result(X), where X is a found value. Next,
an attempt is made to satisfy G, and each time it succeeds, then found(result(X))
is inserted in the database. The fail forces backtracking to occur, attempting to re-
satisfy G (asserta succeeds at most once). When G finally fails, backtracking will
force the first findall clause to fail, and an attempt will be made to satisfy the second
one. The second clause calls collect_found to retract each found structure back out of
the database, inserting its component in a list. The collect_found predicate puts each
element into a variable that holds the "list so far", the trick revealed when explaining
gensym above. As soon as the component mark is encountered (or in fact anything
not of the form result(X)), getnext fails, so the second clause of collect_found is
satisfied, which shares its second argument (the result) with its first (the collected
list).
    Notice that the presence of the found(mark) in the database indicates a particular
use of findall. This means that findall can be used recursively. Any occurrence of
findall used within the second argument of another findall will be treated correctly.
    In Section 7.9 we develop a program that uses findall to construct a list of all of
the descendents of a node in a graph. This is used to implement a breadth-first graph
searching program.
Exercise 7.7: Write a Prolog program that defines the predicate random_pick, for
which the goal random_pick(L, E) instantiates E to a randomly chosen element of list
L. Hint: Use the random number generator and define a predicate that returns the Arth
element of a list.
```

<!-- page 183 -->
```prolog
Exercise 7.8: Given the goal findall(X, G, L), what happens when there are uninstan-
tiated variables not sharing with X in G?
```

## 7.9 Searching Graphs

```prolog
Graphs are networks of nodes connected by arcs. For example, a map can be seen
as a graph, in which the nodes are villages and the arcs are roads connecting the
villages. If you want to find the shortest journey between two villages, you have to
solve the problem of finding the shortest path between nodes of a graph.
    The easiest way to represent a graph is by using a database of facts to represent
the arcs between nodes of a graph. For example, the graph consisting of the following
pattern of nodes and arcs can be represented as facts as shown in Figure 7.2.
   a(g,h).
   a(g.d).
   a(e,d).
   a(h,f).
   a(e,f).
   a(a,e).
   a(a,b).
   a(b,f).
   a(b,c).
    a(f,c).
Notice that the predicate name to represent an arc is a, and there is also a node named
a. There should be no confusion, because the predicate a is always accompanied by
two arguments, while the node named a is a constant. So to go from node a to node
c, we could take the path a,e,f,c, or one of several other possible paths indicated by
the arrowheads on the arcs. Thus the predicate a is interpreted such that a(X,Y) means
that there is an arc from X to Y, which by itself does not imply an arc from Y to X.
    The easiest program for searching a graph represented as above is the following:
    go(X, X).
    go(X, Y) :- a(X, Z), go(Z, Y).
This program is more strict that the one presented in Section 7.2 because paths are
found only in the direction of the arcs. As before, it is possible for this program to
get into a loop. We could simply add the arc
```

<!-- page 184 -->
```prolog
    a(d, a).
to the above definition of the graph, obtaining a cyclic graph. This is why, as before,
we should use list T to keep a "trail" of the nodes we have visited at any particular
recurrence of the predicate:
    go(X, X, T).
    go(X, Y, T) :- a(X, Z), legal(Z, T), go(Z, Y, [Z|T]).
    legal(X, []).
    legal(X, [H|T]) :- \+ X = H, legal(X, T).
Note that the predicate legal is nothing more than a "non-membership" test.
    This program does what is called a "depth first" search, because at first only
one of the neighbours of a node in the graph is considered. The other neighbours are
ignored until later failure causes backtracking to the node so another neighbour can
be considered.
    Now let's assume that the graph is undirected — that is, all arcs are two-way.
Then it is necessary to use the arc information to propose arcs in either direction.
This is the same assumption as we made in Section 7.2 when searching the maze.
This would result in the program:
    go(X, X, T).
    go(X, Y, T) :-
        (a(X, Z) ; a(Z, X)),
        legal(Z, T), go(Z, Y, [Z|T]).
Let's look now at a case of graph searching that we might find useful in practice.
What if we have to plan a route for driving from one town to another? We might
have a database of information about which roads go between which towns in the
North of England, and how long they are:
    a(newcastle, Carlisle, 58).
    a(carlisle, penrith, 23).
    a(darlington, newcastle, 40).
    a(penrith, dartington, 52).
    a(workington, Carlisle, 33).
    a(workington, penrith, 39).
For the moment we can ignore the distances, and define a new predicate a as follows:
    a(X, Y) :- a(X, Y, Z).
The two predicates are not confusable, because each is followed by the number of
arguments that relates to the right one. Given this definition of a, our existing graph
searching procedure go will find possible ways that we can drive from any place in
```

<!-- page 185 -->
```prolog
the graph to any other. However, go has a deficiency: it does not tell us which route it
has found when it finally succeeds. At the very least we might expect go to build up
a list of the places to be visited in the correct order. Moreover, the program already
has at hand the "trail", but in the reverse order to what we expect. We can use rev,
defined in Section 7.5, to turn it the right way round again. Here is a new definition
of go, which returns successful routes by means of a third argument:
    go(Start, Dest, Route) :-
        goO(Start, Dest, [], R),
        rev(R, Route).
    goO(X, X, T, [X|T]).
    goO(Place, Y, T, R) :-
        legalnode(Place, T, Next),
        goO(Next, Y, [Place|T], R).
    legalnode(X, Trail, Y) :-
        (a(X, Y) ; a(Y, X)), legal(Y, Trail).
Notice that we have used legalnode to represent the notion of what is a legal node to
proceed to from another node, and that legal is defined as before. Here is an example
of this program at work, finding a route from Darlington to Workington:
    ?- go(darlington, Workington, X).
```

*X=[darlington,newcastle,Carlisle,penrith,*

*workington]*

```prolog
Not the best route, perhaps, but it will find other routes if we ask for alternatives by
backtracking.
    This program has various deficiencies. The program is not fully in control of
which path it should investigate next, because it is never in a position to survey the
complete set of possibilities. The options that still remain to be considered are im-
plicit in the backtracking structure of Prolog, rather than being explicit in a structure
that the program can examine. Here is a revised version, which is more general-
purpose. We shall see that simple modifications to this program can result in a variety
of search behaviours.
    go(Start, Dest, Route) :-
        gol([[Start]], Dest, R),
        rev(R, Route).
    gol([First|Rest], Dest, First) :- First = [Dest|J.
    gol([[Last|Trail]|Others], Dest, Route) :-
        findall([Z, Last[Trail], legalnode(Last, Trail, Z), List),
        append(List, Others, NewRoutes),
        gol(NewRoutes, Dest, Route).
```

<!-- page 186 -->
```prolog
Predicate legalnode is defined as before. Predicate gol is given a list of routes under
consideration together with the destination, and it returns the successful route in its
last argument. The list of routes under consideration is simply all the paths that we
have followed so far from the starting place. We hope we can extend one of these to
make a path that gets to the destination. The paths are represented as lists of places
in reverse order, so they function as "trails" as well.
    When we start off, there is only one possible path we might want to extend. This
is simply the path that starts at the starting place and doesn't go any further. If we
start at Darlington, it will be [darlington]. If we now investigate paths going from
Darlington to adjacent towns, there are two possible paths: [newcastle, darlington],
and [penrith, darlington]. Since Workington is not on any of these, we must now
decide which of these to extend. If we decide to look at the first one, we find that
there is only one legal node adjacent to Newcastle (the last town on that path). So now
we have a new path in addition to the Darlington-Penrith path: [Carlisle, newcastle,
darlington].
    Our searcher, gol, keeps track of a whole list of paths that might be worth
following. How does it decide which one to look at first? It simply chooses the first
one. It then finds all possible ways to extend that path by one town at a time (using
findall to build a list of all such extended paths) and puts them on the front of the list,
to be considered next time around.
    The resulting behaviour is that gol will try all possible ways of extending the
first path before it ever considers an alternative. This makes the strategy a version
of depth first search. Incidentally, gol considers routes in exactly the same order as
goO. You might like to work out exactly why this is.
    If we are interested in the shortest route from Darlington to Workington, the
existing program does not seem to be much good. The first solution it finds is not the
shortest one: indeed it is the longest one (in this case). We must alter the program so
that it generates routes in order of length. If we change it so that it always extends
shorter paths before considering longer paths, then it is bound to find the shortest
path first (if we measure the length of a path by the number of towns on it). The
resulting program will then perform a breadth first search. All we need to do is to
put new alternatives on the end of the overall list of possibilities, instead of at the
beginning as in the last example. We simply amend the second clause of gol to read:
    gol([[Last|TraiI] |Others], Dest, Route) :-
        findall([Z,Last|Trail], legalnode(Last, Trail, Z), List),
        append(Others, List, NewRoutes),
        gol(NewRoutes, Dest, Route).
The amended program now finds possible routes from Darlington to Workington in
the following order:
    [darlington,penrith, workington]
```

<!-- page 187 -->
```prolog
    [darlington, newcastle,Carlisle, workington]
    [darlington,penrith,Carlisle, workington]
    [darlington,newcastle,Carlisle,penrith, workington]
We can simplify this program considerably if we are certain that there is always an
answer to a query, and if we want only the first solution. Under such circumstances,
we no longer need to check for loops in legalnode. See if you can work out why this
is.
    Unfortunately, the route that involves the smallest number of towns may not
necessarily be the route with the least mileage. We have so far ignored the mileage
information in our graph. If we add a few fictitious towns to our graph to obtain:
    a(newcastle, Carlisle, 58).
    a(carlisle, penrith, 23).
    a(smallville, metropolis, 15).
    a(penrith, darlington, 52).
    a(smallville, ambridge, 10).
    a(workington, Carlisle, 33).
    a(workington, ambridge, 5).
    a(workington, penrith, 39).
    a(darlington, metropolis, 25).
then the route of shortest mileage is actually generated last, because it involves travel
through so many towns. What we need to do is to keep, with each path that may be
extended, a record of how long that path is so far. We then always extend the path
with the shortest mileage. This is called a best first search.
    We shall now represent a path on the list of alternative paths as a structure of
the form r(M, P), where M is the total length of the path in miles, and P is the list of
places visited. Our modified predicate go3 now finds the shortest of the paths on its
list of alternatives. The predicate shortest returns the shortest path on the list, and
also returns the remaining paths on the list. Given the shortest path so far, predicate
proceed finds all the legal extensions to the path, and adds them to the list. This in
turn needs a new version of legalnode, which adds the distance to the next town to
the distance computed so far. The entire program is:
    go3(Routes, Dest, Route) :-
        shortest(Routes, Shortest, RestRoutes),
        proceed (Shortest, Dest, RestRoutes, Route).
    proceed(r(Dist, Route), Dest,Route) :-
        Route = [Dest|J.
    proceed(r(Dist, [Last|Trail]), Dest, Routes, Route) :-
        findall(
            r(Dl, [Z,Last|Trail]),
```

<!-- page 188 -->
```prolog
            legalnode(Last, Trail, Z, Dist, Dl),
            List),
        append(List, Routes, NewRoutes),
        go3(NewRoutes, Dest, Route).
    shortest([Route|Routes], Shortest, [Route|Rest])
        shortest(Routes, Shortest, Rest),
        shorter(Shortest, Route),
    shortest([Route|Rest], Route, Rest).
    shorter(r(Ml,_), r(M2,J) :- Ml < M2.
    legalnode(X, Trail, Y, Dist, NewDist) :-
        (a(X, Y, Z) ; a(Y, X, Z)),
        legal(Y, Trail),
        NewDist is Dist + Z.
To use this program, we attempt to satisfy predicate go, defined as
    go(Start, Dest, Route) :-
        go3([r(0,[Start])]/ Dest, R),
        rev(R, Route).
This new program successfully generates possible routes in the order of their actual
mileage. You might like to alter it to tell how long the various routes are when it
gives the answers.
    We have hardly begun to look at the possible ways of organising graph search-
ing. Information about how to search graphs using more effective heuristics than
"best first" is available in books on Artificial Intelligence. For example: Principles of
Artificial Intelligence, by Nils Nilsson, published in 1982 by Springer-Verlag; Artifi-
cial Intelligence, (second edition) by Patrick Winston, published in 1984 by Addison-
```

`Wesley and` *Artificial Intelligence: A Modern Approach* `by Stuart Russell and Peter`

```prolog
Norvig, published in 1995 by Prentice-Hall.
```

## 7.10 Sift the Two's and Sift the Three's

*Sift the Two's and sift the Three's:* *The Sieve of Erastosthenes.* *When the multiples sublime,* *The numbers that remain are Prime.*

```prolog
Anon.
```

<!-- page 189 -->
```prolog
A prime number is a number that has no whole number divisors except 1 and itself.
For instance, the number 5 is prime, but the number 15 is not, because it has the
whole number 3 as a divisor. One method for generating prime numbers is called the
Sieve of Erastosthenes. This method for sifting for primes up to the integer N works
as follows:
 1. Put all the numbers between 2 and N into the "sieve".
 2. Select and remove the smallest number remaining in the sieve.
 3. Include this number in the primes.
 4. Step though the sieve, removing all multiples of this number.
 5. If the sieve is not empty, repeat steps 2 through 5.
To translate these rules into Prolog, we define a predicate integers to generate a list
of integers, a predicate sift to examine each element of the sieve, and a predicate
remove to create a new sieve by removing multiples of the selected number from the
sieve. This new sieve is passed back to sift. The predicate primes is defined such that
the goal primes(N,L) instantiates L to the list of primes lying in the range from 2 to N
inclusive:
    primes(Limit, Ps) :-
        integers(2, Limit, Is),
        sift(Is, Ps).
    integers(Low, High, [Low|Rest]) :-
        Low =< High,
        i •,
        M is Low + 1,
        integers(M, High, Rest).
    integers(_, _,[]).
```

sift([], [])•

```prolog
sift([I|Is], [I|Ps]) :-
    remove(I, Is, New),
    sift(New, Ps).
remove(P, [], []).
remove(P, [I|Is], [I|Nis]) :-
    \+ 0 is I mod P,
    i
    remove(P, Is, Nis).
remove(P, [I|Is], Nis) :-
    0 is I mod P,
```

<!-- page 190 -->
```prolog
        i • ,
        remove(P, Is, Nis).
Sometimes a better program can result from not translating the recipe too literally.
There is actually a more direct way to find primes as follows. Goal primes(I, L, P)
will scan the list of integers I to produce the primes P, using L as an accumulator of
the "primes so far". Each element of I needs to be checked to see if it is divided by
any element of L. If it is not, then it can be added to L. When the end of the list is
encountered, the primes become the accumulated list.
    primes([], P, P).
    primes([H|T], P, Z) :-
        legal(H, P),
        I
        primes(T, [H|P],Z).
    primes([H|T], P, Z) :- primes(T, P, Z).
    /* X is legal in L if X is not divided by any member of L */
    legal(X, []).
    legal(X, [H|J) :-
        0 is X mod H,
        1
```

• ,

```prolog
        fail.
    legal(X, [JL]) :- legal(X, L).
Continuing in this arithmetical vein, here are Prolog programs for the recursive for-
mulation of Euclid's algorithms for finding the greatest common divisor and the least
common multiple of a pair of integers. The goal gcd(I, J, K) succeeds when the great-
est common divisor of I and J is K. The goal lcm(I, J, K) succeeds when the least
common multiple of I and J is K:
    gcd(I, 0,1) :- !.
    gcd(I, J, K) :- R is I mod J, gcd(J, R, K).
    lcm(I, J, K) :- gcd(I, J, R), K is (I * J) // R.
Notice that due to the way of computing remainders, these predicates are not "re-
versible". Variables I and J must be instantiated in order for the predicates to work.
Exercise 7.9: The three numbers x, y, and 2 are said to form a Pythagorean triple if
the square of 2 is equal to the sum of the squares of x and y (that is, if z2 = x2 + y2).
Write a program to generate Pythagorean triples. Define a predicate pythag such that
asking
    ?- pythag(X, Y, Z).
```

<!-- page 191 -->
```prolog
and asking for alternative solutions gives us as many different Pythagorean triples as
we dare. Hint: Make use of predicates such as isjnteger of Chapter 4.
```

## 7.11 Symbolic Differentiation

```prolog
In Mathematics, symbolic differentiation is an operation that converts a given arith-
metic expression into another arithmetic expression called the derivative. Suppose U
stands for an arithmetic expression which may contain a variable x. The derivative
of U with respect to x is written as
                                and is defined recursively by applying some
conversion rules to the expression U. Two boundary conditions appear first, and the
arrow is read "is converted to"; U and V stand for expressions, and c stands for a
constant:
                    ?
                          o
```

*dx* *dx* *dx* *d(-U)*

*fdU*

*dx*

*\ dx* *d(U + V)*

*<EL + dV*

*dx*

*dx*

*dx* *d(U - V)*

*<W_dV_*

*dx*

*dx*

*dx* *d(cU)*

*(dU s*

*dx*

*\ dx* *d{UV)*

*t*

*u (dV\ +v fdU*

*dx*

*\dx J*

*\dx* *d(U/V)*

```prolog
d(UV~l)
```

*dx*

*dx*

*dx*

*\dx J* *d(\og e U)*

*v _ t fdU*

*dx*

*\ dx*

```prolog
This set of conversion rules is easily translated to Prolog, because we can represent
arithmetic expressions as structures, and use operators as the functors of the struc-
tures. We can also take advantage of the pattern-matching that occurs when a goal
matches against the head of a rule.
    Let us consider a goal d(E, X, F) which succeeds when the derivative of ex-
pression E with respect to constant X is the expression F. Although the +, -, *, and /
```

<!-- page 192 -->
```prolog
operators have built-in declarations, we shall have to declare a " A" operator, where
XAY means xy. Operator declarations are used simply to make the syntax of expres-
sions easier to read. For example, the following questions might be asked of d after
it is defined:
    ?- d(x+l, x, X).
```

*X = 1+0*

```prolog
    ?- d(x*x-2, x, X).
    X =
         x*l+l*x-0
Notice that simply transforming one expression into another using the rules does not
necessarily render the result in a simplified form, but a simplifier can be written as a
separate procedure (Section 7.12). The differentiation program consists of the extra
operator declarations plus a line-by-line translation of the above conversion rules
into Prolog clauses:
```

*?- op(300,yfxS).*

```prolog
    d(X, X, 1) :- !.
    d(C, X, 0) :- atomic(C).
    d(-U, X, -A) :- d(U, X, A).
    d(U+V, X, A+B) :- d(U, X, A), d(V, X, B).
    d(U-V, X, A-B) :- d(U, X, A), d(V, X, B).
    d(C*U, X, C*A) :- atomic(C), \+ C = X, d(U, X, A), !.
    d(U*V, X, B*U+A*V) :- d(U, X, A), d(V, X, B).
    d(U/V, X, A) :- d(U*VA(-l), X, A).
    d(UAC, X, C*UA(C-1)*W) :- atomic(C), \+ C = X, d(U, X, W).
    d(log(U), X, A*UA(-1)) :- d(U, X, A).
Notice the two places where the cuts occur. The first cut ensures that the derivative of
a variable with respect to itself matches only the first clause, eliminating the second
clause as a possibility. Secondly, there are two clauses for multiplication, the first
one dealing with a special case. If the special case succeeds, the general case must
be eliminated as a possibility.
    As pointed out above, the solutions generated by this program are far from
simplified. For example, any occurrence of x*l may as well be written as x and any
occurrence of, for example x* 1+1 *x-0 may as well be written as 2 *x. The next section
describes an algebraic simplifier that can be used to simplify arithmetic expressions
in very much the same way as the derivatives were derived above.
```

<!-- page 193 -->
## 7.12 Mapping Structures and Transforming Trees

```prolog
If we copy a structure component-by-component to form a new structure, we say that
we are mapping one structure into another. It is usual to make a slight modification
to each component as we copy it, as was done when we changed one sentence into
another sentence in Chapter 3. In that example, sometimes we wanted to copy a
word in the sentence exactly as it appeared in the original sentence, and sometimes
we wanted the new copy to be a changed word. We used the following program to
map the first argument of alter into its second argument:
    alter([], []).
    alter([A|B], [C|D]):- change(A, C), alter(B, D).
Since mapping is such a general-purpose operation, we can define a predicate maplist
such that the goal maplist(P, L, M) succeeds by applying the predicate P to each
element of a list L to form a new list M. We assume that P has two arguments, such
that the first argument is the "input" element, and the second argument is the modified
element to be inserted into M:
    maplist(_, []. []).
    maplist(P, [X|L], [Y|M]) :-
        Q =.. [P,X,Y], call(Q), maplist(P, L, M).
There are several points to note about this definition. First, the definition consists of a
boundary condition (the first clause) and a general recursive case (the second clause).
The second clause uses the "=.." operator, pronounced "univ", to form a goal from
the given predicate (P), the input element (X), and the variable that P is assumed to
instantiate to form the modified element (Y). Next, an attempt is made to satisfy Q,
which will result in Y being instantiated, forming the head of the second argument to
this call of maplist. Finally, the recursive call maps the tail into the tail.
    The predicate alter can be replaced by using maplist. Assuming that change is
defined as in Chapter 3, maplist would be used as follows:
    ?- maplist(change, [you,are,a,computer], Z).
    Z= [i, [am, not], a, computer]
A simplification of maplist results in applist, which simply applies some predicate,
assumed to have one argument, to each member of a list. No new list is created:
    applist(_, []).
    applist(P, [X|L]) :-
        Q =.. [P,X], call(Q), applist(P, L).
An example of the use of this predicate would be the following alternative definition
of the phh predicate of Chapter 5:
```

<!-- page 194 -->
```prolog
    phh(List) :- applist(write_space, List).
    write_space(X) :- write(X), spaces(l).
Mapping is not restricted to lists, but can be defined for any kind of structure. For
example, consider arithmetic expressions made up of functors such as * and +, each
having two arguments. Suppose we wanted to map one expression into another, re-
moving all multiplications by 1 in the process. One way to describe this algebraic
simplification would be to define a predicate s such that s(0p, La, Ra, Ans) means
that for an expression consisting of an operator Op with a left argument La and right
argument Ra, a simplified form is the expression Ans. The facts for removing multi-
plications by 1 would look like this, with two facts accounting for the commutativity
of multiplication:
    s(*, X, 1, X).
    s(*, 1, X, X).
So, given an expression of the form 1*X, this table of simplifications could tell us to
map it into whatever X is. Let us see how we can use this in a program.
    To simplify an expression E using such a table of simplification rules, we need
to first simplify the left-hand argument of E, then simplify the right-hand argument
of E, and then see if the simplified result is in our table. If it is, we make the new
expression whatever the table indicates. At the "leaves" of the expression tree there
are integers or atoms, so we should use the built-in predicate atomic as a boundary
condition to simplify leaves into themselves. As above, we can use "=.." to separate
E into its functor and components:
    simp(E, E) :- atomic(E), !.
    simp(E, F) :-
        E =.. [Op, La, Ra],
        simp(La, X),
        simp(Ra, V),
        s(0p, X, Y, F).
So, simp maps expression E into expression F, using the facts found in a simplification
table s. What happens if simp is presented with an operation for which no simplifica-
tion can be made? To prevent s(0p, X, Y, F) failing, we must have a "catchall" rule at
the end of each operator's part of the simplification table. The following simplifica-
tion table includes rules for addition and multiplication, and shows the catchall rule
for each operator included:
    s(+, X, 0, X).
    s(+, 0, X, X).
    s(+, X, Y, X+Y). /* catchall for + */
    s(*,
          0, 0).
```

<!-- page 195 -->
s(\ 0,

0).

```prolog
    s(*, 1, X, X).
    s(*, X, 1, X).
    s(*, X, Y, X*Y). /* catchall for * */
With the "catchall" rules present, there is now a choice of how to simplify some ex-
pressions. For instance, given 3+0, we can either use the first fact, or we can employ
the "catchall" for +. Because of the way the facts are ordered, Prolog will always try
the special case rules before the catchalls. Thus the first solution to simp will always
be a true simplification (if there is one). However, alternative solutions will not be in
the simplest possible form.
    Another simplification used in computer-aided algebra is known as constant
folding. The expression 3*4+a can have the constants 3 and 4 "folded" to form the
expression 12+a. The folding rules can be added to the appropriate parts of the sim-
plification table above. The rule for addition is
    s(+, X, Y, Z) :- number(X), number(Y), Z is X+Y.
The rules for the other arithmetic operations are similar.
    In commutative operations such as multiplication and addition, the simplifi-
cations described above may have different effects on expressions that are written
differently but are algebraically equivalent. For example, if a folding rule is available
for multiplication, then the simp predicate will faithfully map 2*3*a into 6*a, but
a*2*3 or 2*a*3 will be mapped into themselves. To see why this is, think about what
the expressions look like as trees:
The first tree can have its bottom-most multiplication folded from 2*3 into 6,
but the second tree has no sub-tree that can be folded. Because multiplication is
commutative, adding the following rule to the table will suffice for this particular
case:
    s(\ X*Y, W, X*Z) :- number(Y), number(W), Z is Y*W.
A more general algebra system can be constructed simply be adding more s clauses,
instead of adding more programming to simp. Techniques for simplification, together
```

<!-- page 196 -->
```prolog
with the more general problem of expression manipulation, are covered more com-
prehensively in the book Clause and Effect
                                     (see end of this chapter for details).
```

## 7.13 Manipulating Programs

```prolog
Many of the built-in predicates discussed in this book can in fact be defined in Prolog
using simpler built-in predicates. In this section we give a few such definitions. These
may be of use to the programmer whose Prolog system is lacking in certain respects,
but they are in any case of interest as examples of Prolog programming. Perhaps they
may inspire you to develop rather different versions of these predicates for your own
use.1
```

*listing*

```prolog
We can use clause to define a version of the listing predicate. Let us define listl such
that satisfying the goal listl (X) will print out the clauses in the database whose heads
match X. Because the definition of listl will involve using clause with X as its first
argument, we will have to require that X is sufficiently instantiated that the principal
functor is known. Here is the definition of listl:
    listl (X) :-
        clause(X, Y),
        output_clause(X, Y), write('.'), nl, fail,
    listl (X).
    output_clause(X, true) :- !, write(X).
    output_clause(X, Y) :- write((X :- Y)).
When an attempt is made to satisfy a goal listl(X), the first clause causes a search
for a clause whose head matches X. If one is found, that clause is printed out and
then a failure is generated. Backtracking will reach the clause goal and find another
clause, if there is one. And so on. When there are no more clauses to be found, the
clause goal will be unable to be resatisfied, and so will fail. At this point, the second
clause for listl will be chosen, and so the goal will succeed. As a "side effect", all
the appropriate clauses will have been printed out. The definition of output_clause
specifies how the clauses will be printed. It looks for the special case of the body
true and in this case just writes out the head. Otherwise, it writes out the head and
the body, constructed with the functor ":-". Notice the use of the "cut" here to say
that the first rule is the only valid possibility if the body is true. Because this example
relies on backtracking, the cut is essential here.
```

' B e warned, however, that some Prolog implementations not conforming to the standard

<!-- page 197 -->
may only allow the built-in predicate `clause` to operate on dynamic predicates. *A Prolog interpreter*

```prolog
The built-in predicate clause can also be used to write a Prolog interpreter in Prolog.
That is, we can define what it is to run a Prolog program by something which is
itself a Prolog program. Here is the definition of a predicate interpret, such that
interpret(X) succeeds as a goal exactly when X succeeds as a goal. Predicate interpret
is similar to the built-in call, but is more restricted because it does not deal with cuts
or built-in predicates.
    interpret(true) :- !.
    interpret((Gl, G2)) :- !, interpret(Gl), interpret(G2).
    interpret(Goal) :-
        clause(Goal, MoreGoals), interpret(MoreGoals).
The first two clauses deal with the special cases of the goal true, and a goal which is
a conjunction. The last clause covers a simple goal. The procedure is to find a clause
whose head matches the goal, and then interpret the goals in the body of that clause.
Note that the above definition will not cope with programs using built-in predicates,
because such predicates do not have clauses in the usual sense.
```

*retractall*

```prolog
As an example of the use of retract, here is the definition of a useful predicate called
retractall. When the goal retractall(X) is satisfied, all the clauses whose heads match
X are removed from the database. Because the definition uses retract, X cannot be
uninstantiated, for otherwise the predicate of the clause could not be determined. In
the definition we must deal with the two cases of a clause whose head matches X: a
fact and a rule. We provide different arguments to retract to access the two types of
clauses. The definition exploits the property that retract backtracks until all clauses
matching its argument are removed from the database.
    retractall(X) :- retract(X), fail.
    retractall(X) :- retract((X :- Y)), fail.
    retractall(_).
```

*consult*

```prolog
As an example of the predicate retractall in use, here is a definition in Prolog of the
predicate consult, as discussed in section 6.1, which reads in the clauses in a file and
erases any existing clauses for predicates defined in that file. Of course, consult (or
similar facilities) are provided as built-in predicates in most Prolog systems, but it is
interesting to see how it can be defined in Prolog. In fact, the following definition is
only partial, in that it does not handle directives2 in the file properly and in any case
```

2 A directive is a special built-in predicate that is usually invoked when a file of code is

loaded (to somehow affect that loading), rather than during the execution of a program.

<!-- page 198 -->
A directive can be invoked by a goal of the form :- G„ rather than the usual ?- G. - the

```prolog
it may disagree with some Standard Prolog implementations because it uses assertz
on the clauses of the file without the relevant predicates being declared dynamic in
advance.
    consult(File) :-
        retractall(done(_)),
        current_input(Old),
        open(File, read, Stream),
        repeat,
        read (Term),
        try(Term),
        close(Stream),
        set_input(Old),
    try(end_of_file) :- !. % End of file marker read
    try((?- Goals)) :- !, call(Goals), !, fail.
    try((:- Goals)) :- !. % ignore directives
    try(Clause) :-
        head(Clause, Head),
        record_done(Head),
        assertz(Clause),
        fail.
    :- dynamic done/1.
    record_done(Head) :- done(Head), !.
    record_done(Head) :-
        functor(Head, Func, Arity),
        functor(Proc, Func, Arity),
        asserta(done(Proc)),
        retractall (Proc),
    head((A :- B), A) :- !.
    head(A, A).
There are several interesting points about this definition. The goal current_input(Old)
and its partner set_input(Old) are there to ensure that the current input file will not
be changed after the consult from what it was before. The point of the definition of
try is to cause an appropriate action to be taken for each term read from the input
```

only difference in practice is that the former creates no `yes/no` output or querying about multiple solutions. The only directives that we discuss in this book are the predicates `op/3`

```prolog
and dynamic/1.
```

<!-- page 199 -->
```prolog
file. A try goal only succeeds when its argument is the end of file mark. Otherwise, a
failure occurs after the appropriate action, and backtracking goes back to the repeat
goal. Notice the importance of the "cut" at the end of the consult definition. This cuts
out the choice introduced by the repeat.
    Some final points about try: if a term read from the file represents a question
(second clause), an attempt is made to satisfy the appropriate goal immediately using
the call predicate (Section 6.7). If a call to a directive is read, it is ignored. Since
directives must be called directly from the text of the program they refer to (and not
indirectly, via try), we can't replicate their effects in our own programs.
    When the first clause for a given predicate appears in a file, all the clauses in the
database for that predicate must be removed before the new one is added. We must
not remove clauses when later ones for that predicate appear, because then we will
be removing clauses that have just been read in. How can we determine whether a
clause is the first one in the file for its predicate? The answer is that we keep a record
in the database of the predicates for which we have found clauses in the file. This is
done though the dynamic predicate done. When the first clause for a predicate, for
instance foo with two arguments is read from the database, the existing clauses are
removed, and the new clause is added to the database. In addition, the fact
    done(foo(_,_)).
is added. When a later clause for predicate foo is read from the file, we will be able
to see that the old clauses have already been removed, and so we avoid removing
new clauses. It is important for the definition that we do not add something like
done(foo(a,X)).
because then the argument of done will not necessarily match the head of a clause
for foo. The pair of goals
    ..., functor(Head, Func, Arity), functor(Proc, Func, Arity), ...
instantiates Proc to a structure having the same functor as the head Head, but with
variables as its arguments (see Section 6.5).
```

## 7.14 Bibliographic Notes

```prolog
Some larger Prolog programs with commentary are presented in:
The Practice of Prolog, edited by Leon Sterling, published by the MIT Press in 1994.
Also, the following book contains some case studies, some of which use Prolog for
unlikely applications such as the Fast Fourier Transform:
```

*Clause and Effect*

```prolog
by William Clocksin, published by Springer Verlag in 1997.
```
