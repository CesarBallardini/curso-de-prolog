------------------------------------------------------------------------

# 7. Managing Data

We have seen that a Prolog program is a logicbase of predicates, and so far we have entered clauses for those predicates directly in our programs. Prolog also allows us to manipulate the logicbase directly and provides built-in predicates to perform this function. The main ones are:

asserta(X)
Adds the clause X as the first clause for its predicate. Like the other I/O predicates, it always fails on backtracking and does not undo its work.

assertz(X)
Same as asserta/1, only it adds the clause X as the last clause for its predicate.

retract(X)
Removes the clause X from the logicbase, again with a permanent effect that is not undone on backtracking.

The ability to manipulate the logicbase is obviously an important feature for Nani Search. With it we can dynamically change the location of the player, as well as the stuff that has been picked up and moved.

We will first develop goto/1, which moves the player from one room to another. It will be developed from the top down, in contrast to look/0 which was developed from the bottom up.

When the player enters the command goto, we first check if they can go to the place and if so move them so they can look around the new place. Starting from this description of goto/1, we can write the main predicate.

```prolog
goto(Place):-
  can_go(Place),
  move(Place),
  look.
```

Next we fill in the details. We can go to a room if it connects to where we are.

```prolog
can_go(Place):-
  here(X),
  connect(X, Place).
```

We can test can_go/1 immediately (assuming we are in the kitchen).

```prolog
?- can_go(office).
yes

?- can_go(hall).
no
```

Now, can_go/1 succeeds and fails as we want it to, but it would be nice if it gave us a message when it failed. By adding a second clause, which is tried if the first one fails, we can cause can_go/1 to write an error message. Since we want can_go/1 to fail in this situation we also need to add a fail to the second clause.

```prolog
can_go(Place):-
  here(X),
  connect(X, Place).
can_go(Place):-
  write('You can''t get there from here.'), nl,
  fail.
```

This version of can_go/1 behaves as we want.

```prolog
?- can_go(hall).
You can't get there from here.
no
```

Next we develop move/1, which does the work of dynamically updating the logicbase to reflect the new location of the player. It retracts the old clause for here/1 and replaces it with a new one. This way there will always be only one here/1 clause representing the current place. Because goto/1 calls can_go/1 before move/1, the new here/1 will always be a legal place in the game.

```prolog
move(Place):-
  retract(here(X)),
  asserta(here(Place)).
```

We can now use goto/1 to explore the game environment. The output it generates is from look/0, which we developed in chapter 5.

```prolog
?- goto(office).
You are in the office
You can see:
  desk
  computer
You can go to:
  hall
  kitchen
yes

?- goto(hall).
You are in the hall
You can see:
You can go to:
  dining room
  office
yes

?- goto(kitchen).
You can't get there from here.
no
```

We will also need 'asserta' and 'retract' to implement 'take' and 'put' commands in the game.

Here is take/1. For it we will define a new predicate, have/1, which has one clause for each thing the game player has. Initially, have/1 is not defined because the player is not carrying anything.

```prolog
take(X):-
  can_take(X),
  take_object(X).
```

can_take/1 is analogous to can_go/1.

```prolog
can_take(Thing) :-
  here(Place),
  location(Thing, Place).
can_take(Thing) :-
  write('There is no '), write(Thing),
  write(' here.'),
  nl, fail.
```

take_object/1 is analogous to move/1. It retracts a location/2 clause and asserts a have/1 clause, reflecting the movement of the object from the place to the player.

```prolog
take_object(X):-
  retract(location(X,_)),
  asserta(have(X)),
  write('taken'), nl.
```

As we have seen, the variables in a clause are local to that clause. There are no global variables in Prolog, as there are in many other languages. The Prolog logicbase serves that purpose. It allows all clauses to share information on a wider basis, replacing the need for global variables. 'asserts' and 'retracts' are the tools used to manipulate this global data.

As with any programming language, global data can be a powerful concept, easily overused. They should be used with care, since they hide the communication of information between clauses. The same code will behave differently if the global data is changed. This can lead to hard-to-find bugs.

Eliminating global data and the 'assert' and 'retract' capabilities of Prolog is a goal of many logic programmers. It is possible to write Prolog programs without dynamically modifying the logicbase, thus eliminating the problem of global variables. This is done by carrying the information as arguments to the predicates. In the case of an adventure game, the complete state of the game could be represented as predicate arguments, with each command called with the current state and returning a new modified state. This approach will be discussed in more detail in chapter 14.

Although the database-like approach presented here may not be the purest method from a logical standpoint, it does allow for a very natural representation of this game application.

Various Prologs provide varying degrees of richness in the area of logicbase manipulation. The built-in versions are usually unaffected by backtracking. That is, like the other I/O predicates, they perform their function when called and do nothing when entered from the redo port.

Sometimes it is desirable to have a predicate retract its assertions when the redo port is entered. It is easy to write versions of 'assert' and 'retract' that undo their work on backtracking.

```prolog
backtracking_assert(X):-
  asserta(X).
backtracking_assert(X):-
  retract(X),fail.
```

The first time through, the first clause is executed. If a later goal fails, backtracking will cause the second clause to be tried. It will undo the work of the first and fail, thus giving the desired effect.

### Exercises

#### Adventure Game

1- Write put/1 which retracts a have/1 clause and asserts a location/2 clause in the current room.

2- Write inventory/0 which lists the have/1 things.

3- Use goto/1, take/1, put/1, look/0, and inventory/0 to move about and examine the game environment so far.

4- Write the predicates turn_on/1 and turn_off/1 for Nani Search. They will be used to turn the flashlight on or off.

5- Add an open/closed status for each of the doors. Write open and closepredicates that do the obvious. Fix can_go/1 to check whether a door is open and write the appropriate error message if its not.

#### Customer Order Entry

6- In the order entry application, write a predicate update_inventory/2 that takes an item name and quantity as input. Have it retract the old inventory amount, perform the necessary arithmetic and assert the new inventory amount.

NOTE: retract(inventory(item_id,Q)) binds Q to the old value, thus alleviating the need for a separate goal to get the old value of the inventory.

7- We can now use the various predicates developed for the customer order entry system to write a predicate that prompts the user for order information and generates the order. The predicate can be simply order/0.

order/0 should first prompt the user for the customer name, the item name and the quantity. For example

```prolog
write('Enter customer name:'),read(C),
```

It should then use the rules for good_customer and valid_order to verify that this is a valid order. If so, it should assert a new type of record, order/3, which records the order information. It can then update_inventory and check whether its time to reorder.

The customer order entry application has been designed from the bottom up, since that is the way the material has been presented for learning. The order predicate should suggest that Prolog is an excellent tool for top-down development as well.

One could start with the concept that processing an order means reading the date, checking the order, updating inventory, and reordering if necessary. The necessary details of implementing these predicates could be left for later.

#### Expert System

8- The expert system currently asks for the same information over and over again. We can use the logicbase to remember the answers to questions so that ask/2 doesn't re-ask something.

When ask/2 gets a yes or no answer to a question about an attribute-value pair, assert a fact in the form

```prolog
known(Attribute, Value, YesNo).
```

Add a first clause to ask/2 that checks whether the answer is already known and, if so, succeeds. Add a second clause that checks if the answer is known to be false and, if so, fails.

The third clause makes sure the answer is not already known, and then asks the user as before. To do this, the built-in predicate not/1 is used. It fails if its argument succeeds.

```prolog
not (known(Attr, Val, Answer))
```
