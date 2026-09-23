------------------------------------------------------------------------

# 9. Data Structures

So far we have worked with facts, queries, and rules that use simple data structures. The arguments to our predicates have all been atoms or integers, the basic building blocks of Prolog. Examples of atoms we've used are

```prolog
office, apple, flashlight, nani
```

These primitive data types can be combined to form arbitrarily complex data types called structures. A structure is composed of a functor and a fixed number of arguments. Its form is just like that of the goals and facts we've seen already (for good reason, we'll discover).

```prolog
functor(arg1,arg2,...)
```

Each of the structure's arguments can be either a primitive data type or another structure. For example, the things in the game are currently represented using atoms, such as 'desk' or 'apple,' but we can use structures to create a richer representation of these things. The following structures describe the object and its color, size, and weight.

```prolog
object(candle, red, small, 1).
object(apple, red, small, 1).
object(apple, green, small, 1).
object(table, blue, big, 50).
```

These structures could be used directly in the second argument of location/2, but for experimentation we will instead create a new predicate, location_s/2. Note that even though the structures describing the objects in the game are complex, they still take up only one argument in location_s/2.

```prolog
location_s(object(candle, red, small, 1), kitchen).
location_s(object(apple, red, small, 1), kitchen).
location_s(object(apple, green, small, 1), kitchen).
location_s(object(table, blue, big, 50), kitchen).
```

Prolog variables are typeless, and can be bound as easily to structures as to atoms. In fact, an atom is just a simple structure with a functor and no arguments. So we can ask

```prolog
?- location_s(X, kitchen).
X = object(candle, red, small, 1) ;
X = object(apple, red, small, 1) ;
X = object(apple, green, small, 1) ;
X = object(table, blue, big, 50) ;
no
```

We can also pick apart the structure with variables. We can now find all the red things in the kitchen.

```prolog
?- location_s(object(X, red, S, W), kitchen).
X = candle
S = small
W = 1 ;

X = apple
S = small
W = 1 ;
no
```

If we didn't care about the size and weight we could replace the size, S, and weight, W, variables with the anonymous variable (\_).

```prolog
?- location_s(object(X, red, _, _), kitchen).
X = candle ;
X = apple ;
no
```

We can use these structures to add more realism to the game. For example, we can modify our can_take/1 predicate, developed in chapter 7, so that we can only take small objects.

```prolog
can_take_s(Thing) :-
  here(Room),
  location_s(object(Thing, _, small,_), Room).
```

We can also change the error messages to reflect the two reasons why a thing cannot be taken. To ensure that backtracking does not cause both errors to be displayed, we will construct each clause so its message is displayed only when its unique conditions are met. To do this, the built-in predicate not/1 is used. Its argument is a goal, and it succeeds if its argument fails, and fails if its argument succeeds. For example

```prolog
?- not( room(office) ).
no

?- not( location(cabbage, 'living room') )
yes
```

Note that semantically, not in Prolog means the goal cannot be successfully solved with current logicbase of facts and rules. Here is how we use not/1 in our new version, can_take_s/1.

```prolog
can_take_s(Thing) :-<
  here(Room),
  location_s(object(Thing, _, small, _), Room).
can_take_s(Thing) :-
  here(Room),
  location_s(object(Thing, _, big, _), Room),
  write('The '), write(Thing),
  write(' is too big to carry.'), nl,
  fail.
can_take_s(Thing) :-
  here(Room),
  not (location_s(object(Thing, _, _, _), Room)),
  write('There is no '), write(Thing), write(' here.'), nl,
  fail.
```

We can now try it, assuming we are in the kitchen.

```prolog
?- can_take_s(candle).
yes

?- can_take_s(table).
The table is too big to carry.
no

?- can_take_s(desk).
There is no desk here.
no
```

The list_things/1 predicate can be modified to give a description of the things in a room.

```prolog
list_things_s(Place) :-
  location_s(object(Thing, Color, Size, Weight),Place),
  write('A '),write(Size),tab(1),
  write(Color),tab(1),
  write(Thing), write(', weighing '),
  write(Weight), write(' pounds'), nl,
  fail.
list_things_s(_).
```

Requesting it now gives a more detailed list.

```prolog
?- list_things_s(kitchen).
A small red candle, weighing 1 pounds
A small red apple, weighing 1 pounds
A small green apple, weighing 1 pounds
A big blue table, weighing 50 pounds
yes
```

If you are bothered by the grammatically incorrect '1 pounds', you can fix it by adding another rule to write the weight, which would replace the direct 'writes' now used.

```prolog
write_weight(1) :-
  write('1 pound').
write_weight(W) :-
  W > 1,
  write(W), write(' pounds').
```

Testing it shows it works as desired.

```prolog
?- write_weight(4).
4 pounds
yes

?- write_weight(1).
1 pound
yes\
```

Notice that we did not need to put a test, such as 'W = 1,' in the first clause. By putting the 1 directly in the argument at the head of the clause we ensure that that clause will only be fired when the query goal is write_weight(1). All other queries will go to the second clause because the goal pattern will fail to unify with the head of the first clause.

It is important, however, to put the test 'W \> 1' in the second rule. Otherwise both rules would work for a weight of 1. The first time the predicate was called would not be a problem, but on backtracking we would get two answers if we had not included the test.

Structures can be arbitrarily complex, so if we wanted to get fancy about things in the game we could keep their dimensions (length, width, height) instead of their size as part of their description.

```prolog
object(desk, brown, dimension(6,3,3), 90).
```

We can also use embedded structures for clarity.

```prolog
object(desk, color(brown), size(large), weight(90))
```

A query using these structures is more readable.

```prolog
location_s(object(X, _, size(large), _), office).
```

Notice that the position of the arguments is important. The place-holding anonymous variables are essential for getting the correct results.

### Exercises

#### Adventure Game

1- Incorporate the new location into the game. Note that due to data and procedure abstraction, we need only change the low level predicates that deal directly with location. The higher level predicates, such as look/0 and take/1 are unaffected by the change.

#### Customer Order Entry

2- Use structures to enhance the customer order entry application. For example, include a structure for each customers address.
