------------------------------------------------------------------------

# 6. Arithmetic

Prolog must be able to handle arithmetic in order to be a useful general purpose programming language. However, arithmetic does not fit nicely into the logical scheme of things.

That is, the concept of evaluating an arithmetic expression is in contrast to the straight pattern matching we have seen so far. For this reason, Prolog provides the built-in predicate 'is' that evaluates arithmetic expressions. Its syntax calls for the use of operators, which will be described in more detail in chapter 12.

```prolog
X is <arithmetic expression>
```

The variable X is set to the value of the arithmetic expression. On backtracking it is unassigned.

The arithmetic expression looks like an arithmetic expression in any other programming language.

Here is how to use Prolog as a calculator.

```prolog
?- X is 2 + 2.
X = 4

?- X is 3 * 4 + 2.
X = 14
```

Parentheses clarify precedence.

```prolog
?- X is 3 * (4 + 2).
X = 18

?- X is (8 / 4) / 2.
X = 1
```

In addition to 'is,' Prolog provides a number of operators that compare two numbers. These include 'greater than', 'less than', 'greater or equal than', and 'less or equal than.' They behave more logically, and succeed or fail according to whether the comparison is true or false. Notice the order of the symbols in the greater or equal than and less than or equal operators. They are specifically constructed not to look like an arrow, so that you can use arrow symbols in your programs without confusion.

```prolog
X > Y
X < Y
X >= Y
X =< Y
```

Here are a few examples of their use.

```prolog
?- 4 > 3.
yes

?- 4 < 3.
no

?- X is 2 + 2, X > 3.
X = 4

?- X is 2 + 2, 3 >= X.
no

?- 3+4 > 3*2.
yes
```

They can be used in rules as well. Here are two example predicates. One converts centigrade temperatures to Fahrenheit, the other checks if a temperature is below freezing.

```prolog
c_to_f(C,F) :-
  F is C * 9 / 5 + 32.

freezing(F) :-
  F =< 32.
```

Here are some examples of their use.

```prolog
?- c_to_f(100,X).
X = 212
yes

?- freezing(15).
yes

?- freezing(45).
no
```

### Exercises

#### Customer Order Entry

1- Write a predicate valid_order/3 that checks whether a customer order is valid. The arguments should be customer, item, and quantity. The predicate should succeed only if the customer is a valid customer with a good credit rating, the item is in stock, and the quantity ordered is less than the quantity in stock.

2- Write a reorder/1 predicate which checks inventory levels in the inventory record against the reorder quantity in the item record. It should write a message indicating whether or not it's time to reorder.
