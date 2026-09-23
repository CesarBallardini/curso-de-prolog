------------------------------------------------------------------------

# 12. Operators

We have seen that the form of a Prolog data structure is

```prolog
functor(arg1,arg2,...,argN).
```

This is the ONLY data structure in Prolog. However, Prolog allows for other ways to syntactically represent the same data structure. These other representations are sometimes called syntactic sugaring. The equivalence between list syntax and the dot (.) functor is one example. Operator syntax is another.

Chapter 6 introduced arithmetic operators. In this chapter we will equate them to the standard Prolog data structures, and learn how to define any functor to be an operator.

Each arithmetic operator is an ordinary Prolog functor, such as -/2, +/2, and -/1. The display/1 predicate can be used to see the standard syntax.

```prolog
?- display(2 + 2).
+(2,2)

?- display(3 * 4 + 6).
+(*(3,4),6)

?- display(3 * (4 + 6)).
*(3,+(4,6))
```

You can define any functor to be an operator, in which case the Prolog listener will be able to read the structure in a different format. For example, if location/2 was an operator we could write

```prolog
apple location kitchen.
```

instead of

```prolog
location(apple, kitchen).
```

NOTE: The fact that location is an operator is of NO significance to Prolog's pattern matching. It simply means there is an alternative way of writing the same term.

Operators are of three types.

infix
Example: 3 + 4

prefix
Example: -7

postfix
Example: 8 factorial

They have a number representing precedence which runs from 1 to 1200. When a term with multiple operators is converted to pure syntax, the operators with higher precedences are converted first. A high precedence is indicated by a low number.

Operators are defined with the built-in predicate op/3, whose three arguments are precedence, associativity, and the operator name.

Associativity in the second argument is represented by a pattern that defines the type of operator. The first example we will see is the definition of an infix operator which uses the associativity pattern 'xfx.' The 'f' indicates the position of the operator in respect to its arguments. We will see other patterns as we proceed.

For our current purposes, we will again rework the location/2 predicate and rename it is_in/2 to go with its new look, and we will represent rooms in the structure room/1.

```prolog
is_in(apple, room(kitchen)).
```

We will now make is_in/2 an infix operator of arbitrary precedence 35.

```prolog
?- op(35,xfx,is_in).
```

Now we can ask

```prolog
?- apple is_in X.
X = room(kitchen)
```

or

```prolog
?- X is_in room(kitchen).
X = apple
```

We can add facts to the program in operator syntax.

```prolog
banana is_in room(kitchen).
```

To verify that Prolog treats both syntaxes the same we can attempt to unify them.

```prolog
?- is_in(banana, room(kitchen)) = banana is_in room(kitchen).
yes
```

And we can use display/1 to look at the new syntax.

```prolog
?- display(banana is_in room(kitchen)).
is_in(banana, room(kitchen))
```

Let's now make room/1 a prefix operator. Note that in this case the associativity pattern fx is used to indicate the functor comes before the argument. Also we chose a precedence (33) higher (higher precedence has lower number) than that used for is_in (35) in order to nest the room structure inside the is_in structure.

```prolog
?- op(33,fx,room).
```

Now room/1 is displayed in operator syntax.

```prolog
?- room kitchen = room(kitchen).
yes

?- apple is_in X.
X = room kitchen\
```

The operator syntax can be used to add facts to the program.

```prolog
pear is_in room kitchen.

?- is_in(pear, room(kitchen)) = pear is_in room kitchen.
yes

?- display(pear is_in room kitchen).
is_in(pear, room(kitchen))
```

CAUTION: If you mix up the precedence (easy to do) you will get strange bugs. If room/1 had a lower precedence (higher number) than is_in/2, then the structure would be

```prolog
room(is_in(apple, kitchen))
```

Not only doesn't this capture the information as intended, it also will not unify the way we want.

For completeness, an example of a candidate for a postfix operator would be turned_on. Again note that the 'xf' pattern says that the functor comes after the argument.

```prolog
?- op(33,xf,turned_on).
```

We can now say

```prolog
flashlight turned_on.
```

and

```prolog
?- turned_on(flashlight) = flashlight turned_on.
yes
```

Operators are useful for making more readable data structures in a program and for making quick and easy user interfaces.

In our command-driven Nani Search, we use a simple natural language front end, which will be described in the last chapter. We could have alternatively made the commands operators so that

goto(kitchen)
becomes goto kitchen.

turn_on(flashlight)
becomes turn_on flashlight.

take(apple)
becomes take apple.

It's not natural language, but it's a lot better than parentheses and commas.

We have seen how the precedence of operators affects their translation into structures. When operators are of equal precedence, the Prolog reader must decide whether to work from left to right, or right to left. This is the difference between right and left associativity.

An operator can also be non-associative, which means an error is generated if you try to string two together.

The same pattern used for precedence is used for associativity with the additional character y. The options are

Infix:
xfx non-associative

xfy right to left

yfx left to right

Prefix
fx non-associative

fy left to right

Postfix:
xf non-associative

yf right to left

The is_in/2 predicate is currently non-associative so this gets an error.

```prolog
key is_in desk is_in office.
```

To represent nesting, we would want this to be evaluated from right to left.

```prolog
?- op(35,xfy,is_in).
yes

?- display(key is_in desk is_in office).
is_in(key, is_in(desk, office))
```

If we set it left to right the arguments would be different.

```prolog
?- op(35,yfx,is_in).
yes

?- display(key is_in desk is_in office).
is_in(is_in(key, desk), office)
```

We can override operator associativity and precedence with parentheses. Thus we can get our left to right is_in to behave right to left like so.

```prolog
?- display(key is_in (desk is_in office)).
is_in(key, is_in(desk, office))
```

Many built-in predicates are actually defined as infix operators. That means that rather than following the standard predicate(arg1,arg2) format, the predicate can appear between the arguments as

```prolog
arg1 predicate arg2.
```

The arithmetic operators we have seen already illustrate this. For example +, -, \*, and / are used as you would expect. However, it is important to understand that these arithmetic structures are just structures like any others, and do not imply arithmetic evaluation. 3 + 4 is not the same as 7 any more than plus(3,4) is or likes(3,4). It is just +(3,4).

Only special built-in predicates, like is/2, actually perform an arithmetic evaluation of an arithmetic expression. As we have seen, is/2 causes the right side to be evaluated and the left side is unified with the evaluated result.

This is in contrast to the unification (=) predicate, which just unifies terms without evaluating them.

```prolog
?- X is 3 + 4.
X = 7

?- X = 3 + 4.
X = 3 + 4

?- 10 is 5 * 2.
yes

?- 10 = 5 * 2.
no
```

Arithmetic expressions can be as arbitrarily complex as other structures.

```prolog
?- X is 3 * 4 + (6 / 2).
X = 15
```

Even if they are not evaluated.

```prolog
?- X = 3 * 4 + (6 / 2).
X = 3 * 4 + (6 / 2)
```

The operator predicates can also be written in standard notation.

```prolog
?- X is +(*(3,4) , /(6,2)).
X = 15

?- 3 * 4 + (6 / 2) = +(*(3,4),/(6,2)).
yes
```

To underscore that these arithmetic operators are really ordinary predicates with no special meaning unless being evaluated by is/2, consider

```prolog
?- X = 3 * 4 + likes(john, 6/2).
X = 3 * 4 + likes(john, 6/2).

?- X is 3 * 4 + likes(john, 6/2).
error
```

We have seen that Prolog programs are composed of clauses. These clauses are simply Prolog data structures written with operator syntax. The functor is the neck (:-) which is defined as an infix operator. There are two arguments.

```prolog
:-(Head, Body).
```

The body is a data structure with the functor 'and' represented by a comma (,). The body looks like

```prolog
,(goal1, ,(goal2,,goal3))
```

Note the ambiguous use of the comma (,) as a conjunctive operator and as a separator of arguments in a Prolog structure. This can cause confusion in Prolog programs that manipulate Prolog clauses. It might have been clearer if an ampersand (&) was used instead of a comma for separating goals. Then the above pattern would be

```prolog
&(goal1, &(goal2, & goal3))
```

and the following would be equivalent.

```prolog
head :- goal1 & goal2 & goal3.
:-(head, &(goal1, &(goal2, & goal3))).
```

But that is not how it was done, so the two forms are

```prolog
head :- goal1 , goal2 , goal3.
:-(head, ,(goal1, ,(goal2, , goal3))).
```

Every other comma has a different meaning.

The arithmetic operators are often used by Prolog programmers to syntactically join related terms. For example, the write/1 predicate takes only one argument, but operators give an easy way around this restriction.

```prolog
?- X = one, Y = two, write(X-Y).
one - two
```

The slash (/) can be used the same way. In addition, some Prologs define the colon (:) as an operator just for this purpose. It can improve readability by removing some parentheses. For example, the complex structures for defining things in the game can be syntactically represented with the colon as well.

```prolog
object(apple, size:small, color:red, weight:1).
```

A query looking for small things would be expressed

```prolog
?- object(X, size:small, color:C, weight:W).
X = apple
C = red
W = 1
```

The pattern matching is the same as always, but instead of size(small) we use the pattern size:small, which is really :(size,small).

### Exercises

#### Adventure Game

1- Define all of the Nani Search commands as operators so the current version of the game can be played without parentheses or commas.

#### Genealogical Logicbase

2- Define the various relationships in the genealogical logicbase as operators.
