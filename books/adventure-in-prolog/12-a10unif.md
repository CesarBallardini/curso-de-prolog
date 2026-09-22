------------------------------------------------------------------------

# 10. Unification

One of Prolog's most powerful features is its built-in pattern-matching algorithm, unification. For all of the examples we have seen so far, unification has been relatively simple. We will now examine unification more closely.

The full definition of unification is similar to the one given in chapter 3, with the addition of a recursive definition to handle data structures. This following table summarizes the unification process.

[TABLE]

In order to experiment with unification we will introduce the built-in predicate =/2, which succeeds if its two arguments unify and fails if they do not. It can be written in operator syntax as follows.

```prolog
arg1 = arg2
```

which is equivalent to

```prolog
=(arg1, arg2)
```

WARNING: The equal sign (=) does not cause assignment as in most programming languages, nor does it cause arithmetic evaluation. It causes Prolog unification. (Despite this warning, if you are like most mortal programmers, you will be tripped up by this difference more than once.)

Unification between two sides of an equal sign (=) is exactly the same as the unification that occurs when Prolog tries to match goals with the heads of clauses. On backtracking, the variable bindings are undone, just as they are when Prolog backtracks through clauses.

The simplest form of unification occurs between two structures with no variables. In this case, either they are identical and unification succeeds, or they are not, and unification fails.

```prolog
?- a = a.
yes

?- a = b.
no

?- location(apple, kitchen) = 
location(apple, kitchen).
yes

?- location(apple, kitchen) = 
location(pear, kitchen).
no

?- a(b,c(d,e(f,g))) = a(b,c(d,e(f,g))).
yes

?- a(b,c(d,e(f,g))) = a(b,c(d,e(g,f))).
no
```

Another simple form of unification occurs between a variable and a primitive. The variable takes on a value that causes unification to succeed.

```prolog
?- X = a.
X = a 

?- 4 = Y.
Y = 4 

?- location(apple, kitchen) = location(apple, X).
X = kitchen 
```

In other cases multiple variables are simultaneously bound to values.

```prolog
?- location(X,Y) = location(apple, kitchen).
X = apple
Y = kitchen 

?- location(apple, X) = location(Y, kitchen).
X = kitchen
Y = apple 
```

Variables can also unify with each other. Each instance of a variable has a unique internal Prolog value. When two variables are unified to each other, Prolog notes that they must have the same value. In the following example, it is assumed Prolog uses '\_nn,' where 'n' is a digit, to represent unbound variables.

```prolog
?- X = Y.
X = _01
Y = _01 

?- location(X, kitchen) = location(Y, kitchen).
X = _01
Y = _01 
```

Prolog remembers the fact that the variables are bound together and will reflect this if either is later bound.

```prolog
?- X = Y, Y = hello.
X = hello
Y = hello 

?- X = Y, a(Z) = a(Y), X = hello.
X = hello
Y = hello
Z = hello 
```

The last example is critical to a good understanding of Prolog and illustrates a major difference between unification with Prolog variables and assignment with variables found in most other languages. Note carefully the behavior of the following queries.

```prolog
?- X = Y, Y = 3, write(X).
3
X = 3
Y = 3 

?- X = Y, tastes_yucky(X), write(Y).
broccoli
X = broccoli
Y = broccoli 
```

When two structures with variables are unified with each other, the variables take on values that make the two structures identical. Note that a structure bound to a variable can itself contain variables.

```prolog
?- X = a(b,c).
X = a(b,c) 

?- a(b,X) = a(b,c(d,e)).
X = c(d,e) 

?- a(b,X) = a(b,c(Y,e)).
X = c(_01,e)
Y = _01 
```

Even in these more complex examples, the relationships between variables are remembered and updated as new variable bindings occur.

```prolog
?- a(b,X) = a(b,c(Y,e)), Y = hello.
X = c(hello, e)
Y = hello

?- food(X,Y) = Z, write(Z), nl, tastes_yucky(X), edible(Y), write(Z).

food(_01,_02)
food(broccoli, apple)
X = broccoli
Y = apple
Z = food(broccoli, apple) 
```

If a new value assigned to a variable in later goals conflicts with the pattern set earlier, the goal fails.

```prolog
?- a(b,X) = a(b,c(Y,e)), X = hello.
no
```

The second goal failed since there is no value of Y that will allow hello to unify with c(Y,e). The following will succeed.

```prolog
?- a(b,X) = a(b,c(Y,e)), X = c(hello, e).
X = c(hello, e)
Y = hello 
```

If there is no possible value the variable can take on, then unification fails.

```prolog
?- a(X) = a(b,c).
no

?- a(b,c,d) = a(X,X,d).
no
```

The last example failed because the pattern asks that the first two arguments be the same, and they aren't.

```prolog
?- a(c,X,X) = a(Y,Y,b).
no
```

Did you understand why this example fails? Matching the first argument binds Y to c. The second argument causes X and Y to have the same value, in this case c. The third argument asks that X bind to b, but it is already bound to c. No value of X and Y will allow these two structures to unify.

The anonymous variable (\_) is a wild variable, and does not bind to values. Multiple occurrences of it do not imply equal values.

```prolog
?- a(c,X,X) = a(_,_,b).
X = b 
```

Unification occurs explicitly when the equal (=) built-in predicate is used, and implicitly when Prolog searches for the head of a clause that matches a goal pattern.

### Exercises

#### Nonsense Prolog

Predict the results of these unification queries.

```prolog
?- a(b,c) = a(X,Y).

?- a(X,c(d,X)) = a(2,c(d,Y)).

?- a(X,Y) = a(b(c,Y),Z).

?- tree(left, root, Right) = tree(left, root, tree(a, b, tree(c, d, e))).
```
