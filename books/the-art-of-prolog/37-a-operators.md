# A Operators

<!-- page 520 -->
An operator is defined by its name, specifier, and priority. The name is usually an atom. The priority is an integer between i and 1200 inclusive. The specifier is a mnemonic that defines two things, class and associativity. There are three classes of operators: prefix, infix, and postfix. Associativity, which determines how to associate terms containing multiple operators, can be one of three possibilities: left-associative, rightassociative, and non-associative.

There are seven possible operator types, which are given in Table AJ. A left-associative prefix operator is not possible, nor is a right-associative postfix operator. An operator specifier yfy does not make sense as it would lead to ambiguity. Consequently Standard Prolog does not allow such a specifier.

To explain the associativity, consider a term a :: b :: c. If the infix operator :: was left-associative, the term would be read as (a :: b) :: c. If the operator :: was right-associative, the term would be read as a :: (b :: c). If the operator :: was non-associative, the term would be illegal.

If uncertain about priorities when using operators, terms can always be bracketed. If you prefer not to bracket terms, you must take into account the associativity of the operator(s) involved and the priorities of terms. For example, the following three rules apply.

An operand with the same priority as a non-associative operator

must be bracketed to avoid a syntax error by the Prolog reader.

An operator with the same (or smaller) priority as a right-associative

operator that follows that operator need not be bracketed.

An operator with smaller priority than a left-associative operator

<!-- page 521 -->
that precedes that operator need not be bracketed. Table A. i Types of Operators in Standard Prolog Specifier

Class

Associativity fx

prefix

non-associative fy

prefix

right-associative xfx

infix

non-associative xfy

infix

right-associative yfx

infix

left-associative xf

postfix

non-associative yf

postfix

left-associative

Table A.2 Predefined Operators in Standard Prolog Priority

Specifier

Operator(s) 1200

xfx

```prolog
(:- -->)
```

1200

fx 1100

xfy 1000

xfy 700

xfx

**= \=**

700

xfx

== \== 700

xfx 700

xfx 500

yfx

**+-**

400

yfx 200

xfy 200

fy

**Standard Prolog specifies some predefined operators. The priorities**

**and specifiers of the operators which have been used in the text are given**

**in Table A.2.**

**New operators are added with the directive**

<!-- page 522 -->
op (X ,Y, Z) where X is the priority, Y is the operator specifier, and Z is the operator name. These were used in Chapter 17 when defining a new rule language.

The system of operator declarations in Prolog is straightforward and can be used effectively for applications. The reader should be aware, however, that there are some subtle semantic anomalies in how operators are defined and handled. The anomalies, best discovered by trial and error, should not cause problems and can be "programmed around"
