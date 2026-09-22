<!-- page 1 -->
**Artificial Intelligence through Prolog by Neil C. Rowe**

Title

Artificial Intelligence through Prolog by Neil C. Rowe

Item Type

Book

Authors

Rowe, Neil C.

URI

https://hdl.handle.net/10945/36984

Publisher

Prentice-Hall

Date Issued

1988

Download date

2026-09-20 19:15:57

Link to Item

https://hdl.handle.net/10945/36984

<!-- page 2 -->
Downloaded from NPS Archive: Calhoun

10/15/13 11:24 AM

**Appendix E: Using this book with Micro-Prolog**

Micro-Prolog is a dialect of Prolog designed to run in a small amount of memory on small computers. It looks considerably different, but its execution (semantics) is very similar. Micro-Prolog is designed primarily for non-programmers, people who aren't computer experts. So it is less elegant than standard Prolog, and doesn't have some of the advanced features, but it's easier to learn to use.

In Micro-Prolog, querying is not the default mode, so you must indicate a query by a "?" on the front of the line. You must use parentheses to group things, a lot like the language Lisp. You must surround the query with parentheses. The predicate name goes inside the parentheses used in standard Prolog to group arguments, and spaces are used instead of commas to separate the arguments and the predicate name from the first argument. So the standard Prolog query

```prolog
?- a, b(X), c(X,Y).
```

becomes in Micro-Prolog

```prolog
? ((a) (b X) (c X Y))
```

Note a period is not used.

The symbol table is limited in Micro-Prolog, so variable names can only be X, Y, Z, X1, Y1, Z1, X2, Y2, Z2, and so on. Micro-Prolog will not print out variable bindings unless you force it with the equivalent of the standard-Prolog write, the "P" predicate. So to print out X and Y for the preceding query you must say

```prolog
? ((a) (b X) (c X Y) (P X) (P Y))
```

Predicate names in Micro-Prolog can be capitalized or uncapitalized, just as long as they aren't a possible variable name. (Built-in predicates are usually all capitals.)

Rules in Micro-Prolog look just like queries without the question mark. But the first predicate is interpreted as the left side ("then" part), and the other predicates as the right side ("if" part). So the standard-Prolog rule

```prolog
a(X) :- b(X), c(X,3), d(Y,X).
```

becomes in Micro-Prolog

```prolog
((a X) (b X) (c X 3) (d Y X))
```

Figure E-1 gives a table of approximate equivalents between standard Prolog and Micro-Prolog. Micro- Prolog manuals provide further information.

Go to book index

Page 1 of 1 http://faculty.nps.edu/ncrowe/book/ae.html

