------------------------------------------------------------------------

# 8. Recursion

Recursion in any language is the ability for a unit of code to call itself, repeatedly, if necessary. Recursion is often a very powerful and convenient way of representing certain programming constructs.

In Prolog, recursion occurs when a predicate contains a goal that refers to itself.

As we have seen in earlier chapters, every time a rule is called, Prolog uses the body of the rule to create a new query with new variables. Since the query is a new copy each time, it makes no difference whether a rule calls another rule or itself.

A recursive definition (in any language, not just Prolog) always has at least two parts, a boundary condition and a recursive case.

The boundary condition defines a simple case that we know to be true. The recursive case simplifies the problem by first removing a layer of complexity, and then calling itself. At each level, the boundary condition is checked. If it is reached the recursion ends. If not, the recursion continues.

We will illustrate recursion by writing a predicate that can detect things which are nested within other things.

Currently our location/2 predicate tells us the flashlight is in the desk and the desk is in the office, but it does not indicate that the flashlight is in the office.

```prolog
?- location(flashlight, office).
no
```

Using recursion, we will write a new predicate, is_contained_in/2, which will dig through layers of nested things, so that it will answer 'yes' if asked if the flashlight is in the office.

To make the problem more interesting, we will first add some more nested items to the game. We will continue to use the location predicate to put things in the desk, which in turn can have other things inside them.

```prolog
location(envelope, desk).
location(stamp, envelope).
location(key, envelope).
```

To list all of things in the office, we would first have to list those things that are directly in the office, like the desk. We would then list the things in the desk, and the things inside the things in the desk.

If we generalize a room into being just another thing, we can state a two-part rule which can be used to deduce whether something is contained in (nested in) something else.

- A thing, T1, is contained in another thing, T2, if T1 is directly located in T2. (This is the boundary condition.)
- A thing, T1, is contained in another thing, T2, if some intermediate thing, X, is located in T2 and T1 is contained in X. (This is where we simplify and recurse.)

We will now express this in Prolog. The first rule translates into Prolog in a straightforward manner.

```prolog
is_contained_in(T1,T2) :-  
  location(T1,T2).
```

The recursive rule is also straightforward. Notice that it refers to itself.

```prolog
is_contained_in(T1,T2) :-
  location(X,T2),
  is_contained_in(T1,X).
```

Now we are ready to try it.

```prolog
?- is_contained_in(X, office).
X = desk ;
X = computer ;
X = flashlight ;
X = envelope ;
X = stamp ;
X = key ;
no

?- is_contained_in(envelope, office).
yes

?- is_contained_in(apple, office).
no
```

### How Recursion Works

As in all calls to rules, the variables in a rule are unique, or scoped, to the rule. In the recursive case, this means each call to the rule, at each level, has its own unique set of variables. So the values of X, T1, and T2 at the first level of recursion are different from those at the second level.

However, unification between a goal and the head of a clause forces a relationship between the variables of different levels. Using subscripts to distinguish the variables, and internal Prolog variables, we can trace the relationships for a couple of levels of recursion.

First, the query goal is

```prolog
?- is_contained_in(XQ, office).
```

The clause with variables for the first level of recursion is

```prolog
is_contained_in(T11, T21) :-
  location(X1, T21),
  is_contained_in(T11, X1).
```

When the query is unified with the head of the clause, the variables become bound. The bindings are

```prolog
XQ = _01
T11 = _01
T21 = office
X1 = _02
```

Note particularly that XQ in the query becomes bound to T11 in the clause, so when a value of \_01 is found, both variables are found.

With these bindings, the clause can be rewritten as

```prolog
is_contained_in(_01, office) :-
  location(_02, office),
  is_contained_in(_01, _02).
```

When the location/2 goal is satisfied, with \_02 = desk, the recursive call becomes

```prolog
is_contained_in(_01, desk)
```

That goal unifies with the head of a new copy of the clause, at the next level of the recursion. After that unification the variables are

```prolog
XQ = _01        T11 = _01       T12 = _01
                T21 = office    T22 = desk
                X1 = desk       X2 = _03
```

When the recursion finds a solution, such as 'envelope,' all of the T1s and X0 immediately take on that value. Figure 8.1 contains a full annotated trace of the query.

[TABLE]

Figure 8.1. Trace of a recursive query

When writing a recursive predicate, it is essential to ensure that the boundary condition is checked at each level . Otherwise, the program might recurse forever.

The simplest way to do this is by always defining the boundary condition first, ensuring that it is always tried first and that the recursive case is only tried if the boundary condition fails.

### Pragmatics

We now come to some of the pragmatics of Prolog programming. First consider that the goal location(X,Y) will be satisfied by every clause of location/2. On the other hand, the goals location(X, office) or location(envelope, X) will be satisfied by fewer clauses.

Let's look again at the second rule for is_contained_in/2, and an equally valid alternate coding.

```prolog
is_contained_in(T1,T2):-
  location(X,T2),
  is_contained_in(T1,X).

is_contained_in(T1,T2):-
  location(T1,X),
  is_contained_in(X,T2).
```

Both will give correct answers, but the performance of each will depend on the query. The query is_contained_in(X, office) will execute faster with the first version. That is because T2 is bound, making the search for location(X, T2) easier than if both variables were unbound. Similarly, the second version is faster for queries such as is_contained_in(key, X).

### Exercises

#### Adventure Game

1- Trace the two versions of is_contained_in/2 presented at the end of the chapter to understand the performance differences between them.

2- Currently, the can_take/1 predicate only allows the player to take things which are directly located in a room. Modify it so it uses the recursive is_contained_in/2 so that a player can take anything in a room.

#### Genealogical Logicbase

3- Use recursion to write an ancestor/2 predicate. Then trace it to understand its behavior. It is possible to write endless loops with recursive predicates. The trace facility will help you debug ancestor/2 if it is not working correctly.

4- Use ancestor/2 for finding all of a person's ancestors and all of a person's descendants. Based on your experience with grandparent/2 and grandchild/2, write a descendant/2 predicate optimized for descendants, as opposed to ancestor/2, which is optimized for ancestors.
