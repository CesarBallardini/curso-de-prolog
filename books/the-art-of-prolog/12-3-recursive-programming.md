# 3 Recursive Programming

<!-- page 86 -->
**Recursive Prograniniing**

The programs of the previous chapter essentially retrieve information from, and manipulate, finite data structures. In general, mathematical power is gained by considering infinite or potentially infinite structures. Finite instances then follow as special cases. Logic programs harness this power by using recursive data types.

Logical terms can be classified into types. A type is a (possibly infinite) set of terms. Some types are conveniently defined by unary relations. A relation p/i defines the type p to be the set of X's such that p(X).

For example, the `male/i` and `female/i` predicates used previously define the `male` and `female` types.

More complex types can be defined by recursive logic programs. Such types are called recursive types. Types defined by unary recursive programs are called simple recursive types. A program defining a type is called a type definition.

In this chapter, we show logic programs defining relations over simple recursive types, such as integers, lists, and binary trees, and also programs over more complex types, such as polynomials.

3.1 Arithmetic The simplest recursive data type, natural numbers, arises from the foundations of mathematics. Arithmetic is based on the natural numbers. This section gives logic programs for performing arithmetic.

<!-- page 87 -->
In fact, Prolog programs for performing arithmetic differ considerably from their logical counterparts, as we will see in later chapters. However, it is useful to spend time discussing the logic programs. There are natural_number(X) -

X is a natural number. natural_nuniber(0).

```prolog
natural_number(s(X)) - natural_number(X).
```

Program 3.1

Defining the natural numbers

two main reasons. First, the operations of arithmetic are usually thought of functionally rather than relationally. Presenting examples for such a familiar area emphasizes the change in thinking necessary for composing logic programs. Second, it is more natural to discuss the underlying mathematical issues, such as correctness and completeness of programs.

The natural numbers are built from two constructs, the constant symbol O and the successor function s of arity 1. All the natural numbers are then recursively given as 0, s(0), s(s(0)), s(s(s(0))).....We adopt the convention that s(0) denotes the integer n, that is, n applications of the successor function to O.

As in Chapter 2, we give a relation scheme for each predicate, together with the intended meaning of the predicate. Recall that a program P is correct with respect to an intended meaning M if the meaning of P is a subset of M. It is complete if M is a subset of the meaning of P. It is correct and complete if its meaning is identical to M. Proving correctness establishes that everything deducible from the program is intended. Proving completeness establishes that everything intended is deducible from the program. Two correctness and completeness proofs are given in this section.

The simple type definition of natural numbers is neatly encapsulated in the logic program, shown as Program 3.1. The relation scheme used is natural_number (X), with intended meaning that X is a natural number. The program consists of one unit clause and one iterative clause (a clause with a single goal in the body). Such a program is called minimal recursive. Proposition Program 3.1 is correct and complete with respect to the set of goals natural_number(s'(0)), for i

O. Proof

<!-- page 88 -->
(1) Completeness. Let n be a natural number. We show that the goal natural_number (n) is deducible from the program by giving an explicit proof tree. Either n is O or of the form sa(0). The proof tree for the goal natural_nuniber(0) is trivial. The proof tree for the goal

```prolog
                             s(s(0),sm(0) ,sn*m(0))
uraI_number(s1 (0)
                        s (0) ,sm(0)
                                            (O
                            js(s(0) ,sm(0),sm+l (0))
                        cpIus(0),sm(0),sm(0)
                        cturaJ_number(sm(O
```

Figure 3.1

Proof trees establishing completeness of programs

natural_number (s (. .s(0)...)) contains n reductions, using the rule in Program 3.1, to reach the fact riatural_number(0), as shown in the left half of Figure 3.1.

(2) Correctness. Suppose that natural_nuniber(X) is deducible from Program 3.1, in n deductions. We prove that natural_riuniber(X) is in the intended meaning of the program by induction on n. If n = O, then the goal must have been proved using a unit clause, which implies that X = O. If n > o, then the goal must be of the form natural_number(s(X')), since it is deducible from the program, and further, natural_nuxnber(X') is deducible in n - i deductions. By the induction hypothesis, X' is in the intended meaning of the program, i e

X'=&c (0) for some k

O.

u

The natural numbers have a natural order. Program 3.2 is a logic program defining the relation less than or equal to according to the order. We denote the relation with a binary infix symbol, or operator, , according to mathematical usage. The goal O

<!-- page 89 -->
< X has predicate symbol < of arity 2, has arguments O and X, and is syntactically identical to '' (O,X). x Y -

X and Y are natural numbers,

such that X is less than or equal to Y.

O

X - natural_number(X). `s(X)` < s(Y) - X

Y. natural_number(X) - See Program 3.1 Program 3.2

The less than or equal relation

The relation scheme is N1

N2. The intended meaning of Program 3.2 is all ground facts X

Y, where X and Y are natural numbers and X is less than or equal to Y. Exercise (ii) at the end of this section is to prove the correctness and completeness of Program 3.2.

The recursive definition of

is not computationally efficient. The proof tree establishing that a particular N is less than a particular M has M + 2 nodes. We usually think of testing whether one number is less than another as a unit operation, independent of the size of the numbers. Indeed, Prolog does not define arithmetic according to the axioms presented in this section but uses the underlying arithmetic capabilities of the computer directly.

Addition is a basic operation defining a relation between two natural numbers and their sum. In Section 1.1, a table of the plus relation was assumed for all relevant natural numbers. A recursive program captures the relation elegantly and more compactly, and is given as Program 3.3. The intended meaning of Program 3.3 is the set of facts plus (X,Y,Z), where X, Y, and Z are natural numbers and X+Y=Z. Proposition Programs 3.1 and 3.3 constitute a correct and complete axiomatization of addition with respect to the standard intended meaning of plus/3. Proof

<!-- page 90 -->
(1) Completeness. Let X, Y, and Z be natural numbers such that X+Y=Z. We give a proof tree for the goal plus (X,Y,Z). If X equals O, then Y equals Z. Since Program 3.1 is a complete axiomatization of the natural numbers, there is a proof tree for natural_number(Y), which is easily extended to a proof tree for plus (O, Y, Y). Otherwise, X equals 5n(Q) for some n. If Y equals m (0), then Z equals sm (0). The proof tree in the right half of Figure 3.1 establishes completeness. plus(X,Y,Z)

X, Y , and Z are natural numbers

such that Z is the sum of X and Y.

```prolog
plus(O,X,X)
              natural_number(X).
plus(s(X),Y,s(Z))
                    plus(X,Y,Z).
natural_number(X) - See Program 3.1
```

Program 3.3

Addition

(2) Correctness. Let plus(X,Y,Z) be in the meaning. A simple inductive argument on the size of X, similar to the one used in the previous proposition, establishes that X+Y=Z.

```prolog
u
```

Addition is usually considered to be a function of two arguments rather than a relation of arity 3. Generally, logic programs corresponding to functions of n arguments define relations of arity n + 1. Computing the value of a function is achieved by posing a query with n arguments instantiated and the argument place corresponding to the value of the function uninstantiated. The solution to the query is the value of the function with the given arguments. To make the analogy clearer, we give a functional definition of addition corresponding to the logic program: o+X = X. s(X)+Y = s(X+Y).

One advantage that relational programs have over functional programs is the multiple uses that can be made of the program. For example, the query plus (s (0) ,s(0) ,s(s(0)))? means checking whether i + i = 2. (We feel free to use the more readable decimal notation when mentioning numbers.) As for

, the program for `plus` is not efficient. The proof tree confirming that the sum of N and M is N + M has N + M + 2 nodes.

Posing the query plus(s(0) ,s(0) ,X)?, an example of the standard use, calculates the sum of 1 and 1. However, the program can just as easily be used for subtraction by posing a query such as plus (s (0) , X, s (s (s(0))))?. The computed value of Xis the difference between 3 and 1, namely, 2. Similarly, asking a query with the first argument uninstantiated, and the second and third instantiated, also performs subtraction.

<!-- page 91 -->
A more novel use exploits the possibility of a query having multiple solutions. Consider the query plus(X,Y,s(s(s(0))))?. It reads: "Do there exist numbers X and Y that add up to 3." In other words, find a partition of the number 3 into the sum of two numbers, X and Y. There are several solutions.

A query with multiple solutions becomes more interesting when the properties of the variables in the query are restricted. There are two forms of restriction: using extra conjuncts in the query, and instantiating variables in the query. We saw examples of this when querying a database. Exercise (ii) at the end of this section requires to define a predicate even(X), which is true if X is an even number. Assuming such a predicate, the query plus (X,Y,N) ,even(X) ,even(Y)? gives a partition of N into two even numbers. The second type of restriction is exemplified by the query plus(s(s(X)),s(s(Y)),N)?, which insists that each of the numbers adding up to N is strictly greater than 1.

Almost all logic programs have multiple uses. Consider Program 3.2 for , for example. The query s (0) s (s (0))? checks whether i is less than or equal to 2. The query X

`s(s(0))?` finds numbers X less than or equal to 2. The query X

Y? computes pairs of numbers less than or equal to each other.

Program 3.3 defining addition is not unique. For example, the logic program

```prolog
plus(X,O,X) - natural_nuniber(X).
plus(X,s(Y),s(Z)) - plus(X,Y,Z).
```

has precisely the same meaning as Program 3.3 for plus. Two programs are to be expected because of the symmetry between the first two arguments. A proof of correctness and completeness given for Program 3.3 applies to this program by reversing the roles of the symmetric arguments.

The meaning of the program for plus would not change even if it consisted of the two programs combined. This composite program is undesirable, however. There are several different proof trees for the same goal. It is important both for runtime efficiency and for textual conciseness that axiomatizations of logic programs be minimal.

We define a type condition to be a call to the predicate defining the type. For natural numbers, a type condition is any goal of the form natural_number (X).

<!-- page 92 -->
In practice, both Programs 3.2 and 3.3 are simplified by omitting the body of the base rule, natural_number (X). Without this test, facts such times(X,Y,Z)

X, Y, arid Z are natural numbers

such that Z is the product of X and Y.

```prolog
times(O,X,O)
times(s(X) ,Y,Z)
                     es(X,Y,XY), plus(XY,Y,Z).
plus(X,Y,Z)
              See Program 3.3
```

Program 3.4

Multiplication as repeated addition

exp(N,X,Y)

N, X, and Y are natural numbers

```prolog
    such that Y equals X raised to the power N.
exp(s(X) 0,0).
exp(0,s(X) ,s(0))
exp(s(N),X,Y) .- exp(N,X,Z), times(Z,X,Y).
times(X,Y,Z) - See Program 3.4
```

Program 3.5

Exponentiation as repeated multiplication

```prolog
as O
```

**a and plus(O,a,a), where a is an arbitrary constant, will be**

in the programs' meanings. Type conditions are necessary for correct programs. However, type conditions distract from the simplicity of the programs arid affect the size of the proof trees. Hence in the following we might omit explicit type conditions from the example programs, Programs 3.4-3.7.

The basic programs shown are the building blocks for more complicated relations. A typical example is defining multiplication as repeated addition. Program 3.4 reflects this relation. The relation scheme is times(X,Y,Z), meaning X times Y equals Z.

Exponentiation is defined as repeated multiplication. Program 3.5 for exp(N,X,Y) expresses the relation that XN=Y. It is analogous to Program 3.4 for times(X,Y,Z), with exp and times replacing times and plus, respectively. The base cases for exponentiation are X0=1 for all positive values of X, and 0N=0 for positive values of N.

<!-- page 93 -->
A definition of the factorial function uses the definition of multiplication.RecallthatN! =NN i .....2 i.Thepredicatefactorial(N,F) relates a number N to its factorial F. Program 3.6 is its axiomatization. factoria!(N,F) -

F equals N factorial. Íactorial(O,s(0)) `factorial(s(N),F) -` factorial(N,F1), times(s(N),F1,F).

```prolog
times(X,Y,Z) - SeeProgram3.4.
```

Program 3.6

Computing factorials

minimum(N1,N2,Min) -

The minimum of the natural numbers Nl and N2

`is` Min.

```prolog
minimum(N1,N2,N1)
                    Nl
                       5
                         N2.
minimum(Nl,N2,N2) - N2
                         Nl.
Nl
     52 - See Program 3.2
```

Program 3.7 The minimum of two numbers

Not all relations concerning natural numbers are defined recursively. Relations can also be defined in the style of programs in Chapter 2. An example is Program 3.7 determining the minimum of two numbers via

```prolog
the relation minimum (Nl , N2 , Mm).
```

Composing a program to determine the remainder after integer division reveals an interesting phenomenondifferent mathematical definitions of the same concept are translated into different logic programs. Programs 3 .8a and 3 .8b give two definitions of the relation mod (X ,Y, Z), which is true if Z is the value of X modulo Y, or in other words, Z is the remainder of X divided by Y. The programs assume a relation < as specified in Exercise (i) at the end of this section.

Program 3.8a illustrates the direct translation of a mathematical definition, which is a logical statement, into a logic program. The program corresponds to an existential definition of the integer remainder: "Z is the value of X mod Y if Z is strictly less than Y, and there exists a number Q such that X = Q . Y + Z. In general, mathematical definitions are easily translated to logic programs.

<!-- page 94 -->
We can relate Program 3.8a to constructive mathematics. Although seemingly an existential definition, it is also constructive, because of the constructive nature of <, plus, and times. The number Q, for example, proposed in the definition will be explicitly computed by times iii any use of mod. mod(X,}Z) -

Z is the remainder of the integer division of X by Y. mod(X,Y,Z) - Z < Y, times(Y,Q,QY), plus(QY,Z,X). Program 3.8a A nonrecursive definition of modulus

mod(X,Y,Z) -

Z is the remainder of the integer division of X by Y. mod(X,Y,X) .- X < Y. mod(X,Y,Z)

```prolog
plus(X1,Y,X), mod(X1,Y,Z).
```

Program 3.8b A recursive definition of modulus

In contrast to Program 3.8a, Program 3.8b is defined recursively. It constitutes an algorithm for finding the integer remainder based on repeated subtraction. The first rule says that X mod Y is X if X is strictly less than Y. The second rule says that the value of X mod Y is the same as X - Y mod Y. The effect of any computation to determine the modulus is to repeatedly subtract Y from X until it becomes less than Y and hence is the correct value.

The mathematical function X mod Y is not defined when Y is zero. Neither Program 3.8a nor Program 3.8b has goal mod(X,O,Z) in its meaning for any values of X or Z. The test of < guarantees that.

The computational model gives a way of distinguishing between the two programs for mod. Given a particular X, Y, and Z satisfying mod, we can compare the sizes of their proof trees. In general, proof trees produced with Program 3.8b will be smaller than those produced with Program 3.8a. In that sense Program 3.8b is more efficient. We defer more rigorous discussions of efficiency till the discussions on lists, where the insights gained will carry over to Prolog programs.

Another example of translating a mathematical definition directly into a logic program is writing a program that defines Ackermann's function. Ackermann's function is the simplest example of a recursive function that is not primitive recursive. It is a function of two arguments, defined by three cases:

```prolog
ackermann(O,N) = N + 1.
ackermann(M, O) = ackerrnann(M - 1, 1).
ackermann(M,N) = ackermann(M - 1,ackermann(M,N - 1)).
```

<!-- page 95 -->
ackermarìn(X,Y,A)

A is the value of Ackermann's

function for the natural numbers X and Y.

```prolog
ackermarm (O ,N , s (N) )
ackermann(s(M) ,O,Val) - ackermann(M,s(0) ,Val).
ackermann(s(M) ,s(N) ,Val)
    ackermann(s(M),N,Vall), ackermann(M,Vall,Val).
```

Program 3.9 Ackermann's function

gcd(X,Y,Z) -

Z is the greatest common divisor of

the natural numbers X and Y.

```prolog
gcd(X,Y,Gcd) - mod(X,Y,Z), gcd(Y,Z,Gcd).
gcd(X,O,X) X > O.
```

Program 3.10 The Euclidean algorithm

Program 3.9 is a translation of the functional definition into a logic pro-

```prolog
gram. The predicate ackermann(M,N,A) denotes that A=ackermann(M,N).
```

The third rule involves two calls to Ackermann's function, one to compute the value of the second argument.

The functional definition of Ackermann's function is clearer than the relational one given in Program 3.9. In general, functional notation is more readable for pure functional definitions, such as Ackermann's function and the factorial function (Program 3.6). Expressing constraints can also be awkward with relational logic programs. For example, Program 3.8a says less directly that X = Q . Y + Z.

The final example in this section is the Euclidean algorithm for finding the greatest common divisor of two natural numbers, recast as a logic program. Like Program 3.8b, it is a recursive program not based on the recursive structure of numbers. The relation scheme is `gcd(X,Y,Z),` with intended meaning that Z is the greatest common divisor (or gcd) of two natural numbers X and Y. It uses either of the two programs, 3.8a or 3.8b,

```prolog
for mod.
```

<!-- page 96 -->
The first rule in Program 3.10 is the logical essence of the Euclidean algorithm. The gcd of X and Y is the same as the gcd of Y and X mod Y. A proof that Program 3.10 is correct depends on the correctness of the above mathematical statement about greatest common divisors. The proof that the Euclidean algorithm is correct similarly rests on this result. The second fact in Program 3.10 is the base fact. It must be specified that Xis greater than Oto preclude gcd(O,O,O) from being in the meaning. The gcd of O and O is not well defined.

3.1.1

Exercises for Section 3.1 Modify Program 3.2 for < to axiomatize the relations <, >, and . Discuss multiple uses of these programs. Prove that Program 3.2 is a correct and complete axiomatization of < Prove that a proof tree for the query s'(0)

<

tm(Q) using Program 3.2 has m + 2 nodes. Define predicates even(X) and odd(X) for determining if a natural number is even or odd. (Hint: Modify Program 3.1 for natural_ nuniber.)

(y) Write a logic program defining the relation f ib(N,F) to determine the Nth Fibonacci number F. The predicate times can be used for computing exact quotients

```prolog
with queries such as times(s(s(0)),X,s(s(s(s(0)))))? to find
```

the result of 4 divided by 2. The query times(s(s(0)),X,s(s(s

**(0))))? to find 3/2 has no solution. Many applications require the**

<!-- page 97 -->
use of integer division that would calculate 3/2 to be 1. Write a program to compute integer quotients. (Hint: Use repeated subtraction.) Modify Program 3.10 for finding the gcd of two integers so that it performs repeated subtraction directly rather than use the mod function. (Hint: The program repeatedly subtracts the smaller number from the larger number until the two numbers are equal.) Rewrite the logic programs in Section 3.1 using a different representation of natural numbers, namely as a sum of l's. For example, the modified version of Program 3.1 would be

```prolog
natural_number (1).
natural_number(1+X) - natural_number(X).
```

Note that + is used as a binary operator, and O is not defined to be

a natural number.

3.2 Lists The basic structure for arithmetic is the unary successor functor. Although complicated recursive functions such as Ackermann's function can be defined, the use of a unary recursive structure is limited. This section discusses the binary structure, the list.

The first argument of a list holds an element, and the second argument is recursively the rest of the list. Lists are sufficient for most computations - attested to by the success of the programming language Lisp, which has lists as its basic compound data structure. Arbitrarily complex structures can be represented with lists, though it is more convenient to use different structures when appropriate.

For lists, as for numbers, a constant symbol is necessary to terminate recursion. This "empty list," referred to as nil, will be denoted here by the symbol [1. We also need a functor of arity 2. Historically, the usual functor for lists is "" (pronounced dot), which overloads the use of the period. It is convenient to define a separate, special syntax. The term

(X,Y) is denoted [XJY]. Its components have special names: X is called the head and Y is called the tail.

The term [XIY] corresponds to a cons pair in Lisp. The corresponding words for head and tail are, respectively, car and cdr.

<!-- page 98 -->
Figure 3.2 illustrates the relation between lists written with different syntaxes. The first colunm writes lists with the dot functor, and is the way lists are considered as terms in logic programs. The second colunm gives the square bracket equivalent of the dot syntax. The third column is an improvement upon the syntax of the second colunm, essentially hiding the recursive structure of lists. In this syntax, lists are written as a sequence of elements enclosed in square brackets and separated by commas. The empty list used to terminate the recursive structure is suppressed. Note the use of "cons pair notation" in the third column when the list has a variable tail. Formal object

Cons pair syntax

Element syntax

(a,] 1)

Fai F]]

Fa] .(a,(b,F J))

[aIFbIF J]]

Fa,b] .(a,.(b,.(c,F 1)))

]aiFbI]c I] J]]]

Fa,b,c] (aX)

Faix]

Faix]

Fai]biXl]

Fa,biX] Figure 3.2

Equivalent forms of lists

!ist(Xs)

Xs is a list. list([ ]). list([XiXs]) - list(Xs). Program 3.11

Defining a list

Terms built with the dot functor are more general than lists. Program 3.11 defines a list precisely. Declaratively it reads: "A list is either the empty list or a cons pair whose tail is a list." The program is analogous to Program 3.1 defining natural numbers, and is the simple type definition of lists.

Figure 3.3 gives a proof tree for the goal list ([a, b, cl). Implicit in the proof tree are ground instances of rules in Program 3.11, for example, list( [a,b , c]) - list( [b, c]). We specify the particular instance here explicitly, as instances of lists in cons pair notation can be confusing. [a, b, c] is an instance of [XIXs] under the substitution {X=a, Xs= [b, c]).

Because lists are richer data structures than numbers, a great variety of interesting relations can be specified with them. Perhaps the most basic operation with lists is determining whether a particular element is in a list. The predicate expressing this relation is member (Element,List). Program 3.12 is a recursive definition of member/2.

<!-- page 99 -->
Declaratively, the reading of Program 3.12 is straightforward. X is an element of a list if it is the head of the list by the first clause, or if it is a member of the tail of the list by the second clause. The meaning of the program is the set of all ground instances member (X,Xs), where Figure 3.3

Proof tree verifying a list

member(Element,List) -

Element is an element of the list List. member(X, [XIXs]). member(X,[YIYs]) - member(X,Ys). Program 3.12

Membership of a list

X is an element of Xs. We omit the type condition in the first clause. Alternatively, it would be written rnember(X,[XIXs]) - list(Xs).

**This program has many interesting applications, to be revealed**

throughout the book. Its basic uses are checking whether an element is in a list with a query such as member(b, [a,b,c])?, finding an element of a list with a query such as member (X, [a, b, c])?, and finding a list containing an element with a query such as member(b,X)?. This last query may seem strange, but there are programs that are based on this use of member.

<!-- page 100 -->
We use the following conventions wherever possible when naming variables in programs involving lists. If X is used to denote the head of a list, then Xs will denote its tail. More generally, plural variable names will denote lists of elements, and singular names will denote individual elements. Numerical suffixes will denote variants of lists. Relation schemes will still contain nmemonic names. prefix(Prefix,List) -

Prefix is a prefix of List.

```prolog
prefix([ ],Ys).
prefix([XIXs],[XJYs]) - prefix(Xs,Ys).
```

suffix(Suffix,List)

Suffix is a suffix of List.

```prolog
suffix(Xs,Xs)
suffix(Xs,[YIYs]) - suffix(Xs,Ys)
```

Program 3.13

Prefixes and suffixes of a list

Our next example is a predicate `sublist(Sub,List)` for determining whether `Sub` is a sublist of `List.` A sublist needs the elements to be consecutive:

`[b, c]` is a sublist of

```prolog
[a, b, c , d], whereas
                   [a, c] is not.
```

It is convenient to define two special cases of sublists to make the definition of `sublist` easier. lt is good style when composing logic programs to define meaningful relations as auxiliary predicates. The two cases considered are initial sublists, or prefixes, of a list, and terminal sublists, or suffixes, of a list. The programs are interesting in their own right.

The predicate `prefix(Prefix,List)` is true if `Prefix` is an initial sublist of `List,` for example, `prefix([a,b] , [a,b,c])` is true. The companion predicate to `prefix is suffix(Suffix,List),` determining if `Suffix` is a terminal sublist of `List.` For example,

```prolog
suffix( [b, c] , [a,b, ci) is
```

true. Both predicates are defined

`in` Program 3.13. A type condition expressing that the variables in the base facts are lists should be added to the base fact in each predicate to give the correct meaning.

An arbitrary sublist can be specified in terms of prefixes and suffixes: namely, as a suffix of a prefix, or as a prefix of a suffix. Program 3.14a expresses the logical rule that Xs is a sublist of Ys if there exists Ps such that Ps is a prefix of Ys and Xs is a suffix of Ps. Program 3.14b is the dual definition of a sublist as a prefix of a suffix.

The predicate `prefix` can also be used as the basis of a recursive definition of `sublist.` Thìs is given as Program 3.14c. The base rule reads that a prefix of a list is a sublist of a list. The recursive rule reads that the sublist of a tail of a list is a sublist of the list itself.

The predicate `member` can be viewed as a special case of `sublist` defined by the rule

```prolog
member(X,Xs) - sublist([X],Xs).
```

<!-- page 101 -->
sublist (Sub,List) -

Sub is a sublist of List.

Suffix of a prefix

```prolog
 sublist(Xs,Ys) - prefix(Ps,Ys), suffix(Xs,Ps).
Prefixofasuffix
 sublist(Xs,Ys) - prefix(Xs,Ss), suffix(Ss,Ys).
```

`C:` Recursive definition of a sublist

```prolog
 sublist(Xs,Ys) - prefix(Xs,Ys).
 sublist(Xs, [YIYs]) - sublist(Xs,Ys).
Prefix of a suffix, using
                     append
 sublist (Xs , AsXsBs) -
     append(As,XsBs,AsXsBs), append(Xs,Bs,XsBs).
```

Suffix of a prefix, using

```prolog
                    append
sublist (Xs , AsXsBs) -
    append(AsXs,Bs,AsXsBs), append(As,Xs,AsXs).
```

Program 3.14

Determining sublists of lists

append (Xs, Ys,XsYs) -

XsYs is the result of concatenating

the lists Xs and Ys.

```prolog
append([ ],Ys,Ys).
append([XIXs],Ys,[XIZs]) - append(Xs,Ys,Zs).
```

Program 3.15 Appending two lists

The basic operation with lists is concatenating two lists to give a third list. This defines a relation, append(Xs,Ys,Zs), between two lists Xs, Ys and the result Zs of joining them together. The code for append, Program 3.15, is identical in structure to the basic program for combining two numbers, Program 3.3 for plus.

Figure 3.4 gives a proof tree for the goal append([a,b] , [c,d] , [a,b, c , d]). The tree structure suggests that its size is linear in the size of the first list. In general, if Xs is a list of n elements, the proof tree for append(Xs,Ys,Zs) has n + 1 nodes.

<!-- page 102 -->
There are multiple uses for append similar to the multiple uses for plus. The basic use is to concatenate two lists by posing a query such

**[a,b],[c,dr**

cpend([b],[c,d],[b,c,d]

```prolog
ppend([ ],[c,d],[c,d])
```

Ftgure 3.4

Proof tree for appending two lists

```prolog
as append([a,b,c] , [d,e] ,Xs)? with answer Xs=[a,b,c,d,e]. A query
```

such as `append(Xs,[c,d],[a,b,c,d])?` finds the difference `Xs=[a,b]` between the lists [c,d] and `[a,b,c,d].` Unlike `plus, append is` not symmetric in its first two arguments, and thus there are two distinct versions of finding the difference between two lists.

The analogous process to partitioning a number is splitting a list. The query `append(As,Bs, [a,b,c,d])?,` for example, asks for lists `As` andBs such that appending `Bs` to `As` gives the list

`[a,b,c,d].` Queries about splitting lists are made more interesting by partially specifying the nature of the split lists. The predicates `member, sublist, prefix,` and `suf-` `fix,` introduced previously, can all be defined in terms of `append` by viewing the process as splitting a list.

The most straightforward definitions are for `prefix` and `suffix,` which just specify which of the two split pieces are of interest:

```prolog
prefix(Xs,Ys) - append(Xs,As,Ys).
suffix(Xs,Ys) - append(As,Xs,Ys).
```

`Sublist` can be written using two `append` goals. There are two distinct variants, given as Programs 3.14d and 314e. These two programs are obtained from Programs 3.14a and 3.14b, respectively, where `prefix` and `suffix` are replaced by `append` goals.

`Member` can be defined using `append,` as follows:

```prolog
member(X,Ys) - append(As, [XIXs] ,Ys).
```

<!-- page 103 -->
This says that X is a member of Ys if Ys can be split into two lists where X is the head of the second list. reverse(List, Tsil) -

Tsil is the result of reversing the list List.

Naive reverse

```prolog
 reverse(f 1,1 1).
 reverse([XIXs] ,Zs)
                      reverse(Xs,Ys), append(Ys, [X] ,Zs).
Reverse-accumulate
 reverse(Xs,Ys) - reverse(Xs,[ ],Ys).
 reverse([XIXs],Acc,Ys) - reverse(Xs,[XIAcc],Ys).
 reverse([ ],Ys,Ys).
```

Program 3.16 Reversing a list

A similar rule can be written to express the relation `adj acent (X, Y, Zs)` that two elements X and Y are adjacent in a list `Zs:`

```prolog
adjacent(X,Y,Zs) - append(As, [X,YIYs] ,Zs).
```

Another relation easily expressed through `append` is determining the last element of a list. The desired pattern of the second argument to `append,` a list with one element, is built into the rule:

```prolog
last(X,Xs)
               append(As,[X],Xs).
```

Repeated applications of `append` can be used to define a predicate `reverse (Li st ,Tsil).` The intended meaning of `reverse` is that `Tsil is` a list containing the elements in the list `List` in reverse order to how they appear m `List.` An example of a goal in the meaning of the program is `reverse ([a, b, c] , [c , b, a]).` The naive version, given as Program 3.1 6a, is the logical equivalent of the recursive formulation in any language: recursively reverse the tail of the list, and then add the first element at the back of the reversed tail.

There is an alternative way of defining `reverse` without calling `append` directly. We define an auxiliary predicate `reverse (Xs,Ys,Zs),` which is true if Zs is the result of appending Ys to the elements of Xs reversed. It is defined in Program 3.16b. The predicate `reverse/3` is related to `reverse/2` by the first clause in Program 3.16b.

Program 3.16b is more efficient than Program 3.16a. Consider Figure 3.5, showing proof trees for the goal `reverse( [a,b, cl`

```prolog
, [c ,b
      , a]) us-
```

<!-- page 104 -->
ing both programs. In general, the size of the proof tree of Program 3.16a

```prolog
           reverse([b,c],[c,b])
                                  append([c,b],[a],[c,b,a])
                                           append([b],[a] [ba])
                                                 append([ ],[a],[a])
reverse([ LE 1)
               append([ ],[c],[c])
                                append([ 1,[b],[b])
                 cZTIerse([a,b,c],[c,b,aj
                  crse([a,b,c],[ ],[c,b,i
                        erse([c],[b,a],[c,b,a])
                     reverse([ ],[c,b,a],[c,b,a]
```

Figure 3.5

<!-- page 105 -->
Proof trees for reversing a list !ength(Xs,N) -

The list Xs has N elements. length([ 1,0). length([XIXs],s(N)) - length(Xs,N). Program 3.17 Determining the length of a list

is quadratic in the number of elements in the list to be reversed, while that of Program 3.16b is linear.

The insight in Program 3.16b is the use of a better data structure for representing the sequence of elements, which we discuss in more detail in Chapters 7 and 15.

The final program in this section, Program 3.17, expresses a relation between numbers and lists, using the recursive structure of each. The predicate length(Xs,N) is true if Xs is a list of length N, that is, contains N elements, where N is a natural number. For example, length([a,b] ,s(s(0))), indicating that [a,b] has two elements, is in the program's meaning.

Let us consider the multiple uses of Program 3.17. The query length ([a,b] ,X)? computes the length, 2, of a list [a,b]. In this way, length is regarded as a function of a list, with the functional definition length([ 1) = O length([XIXs]) = s(length(Xs)).

The querylength([a,b] ,s(s(0)))? checks whetherthelist [a,b] has length 2. The query length(Xs,s(s(0)))? generates a list of length 2 with variables for elements. 3.2.1

Exercises for Section 3.2

(i)

A variant of Program 3.14 for sublist is defined by the following

three rules:

```prolog
subsequence([XIXs] , [XIYs]) - subsequence(Xs,Ys).
subsequence(Xs, [Y lYs]) - subsequence(Xs,Ys).
subsequence([ ] ,Ys).
```

Explain why this program has a different meaning from Pro-

<!-- page 106 -->
gram 3.14.

Write recursive programs for `adjacent` and `last` that have the

same meaning as the predicates defined in the text in terms of

```prolog
append.
```

Write a program for `double (List,ListList),` where every element

`[ri List` appears twice in `ListList, e.g., double([1,2,3] [1,1,2,`

`2,3,3])` is true.

Compute the size of the proof tree as a function of the size of the

input list for Programs 3.16a and 3.1Gb defining `reverse.`

(y)

Define the relation `suin(Listoflntegers,Sum),` which holds if `Sum`

is the sum of the `ListOf Integers,`

```prolog
Using plus/3;
```

Without using any auxiliary predicate.

(Hint: Three axioms are enough.)

3.3 Composing Recursive Programs No explanation has been given so far about how the example logic programs have been composed. The composition of logic programs is a skill that can be learned by apprenticeship or osmosis, and most definitely by practice. For simple relations, the best axiomatizations have an aesthetic elegance that look obviously correct when written down. Through solving the exercises, the reader may find, however, that there is a difference between recognizing and constructing elegant logic programs

This section gives more example programs involving lists. Their presentation, however, places more emphasis on how the programs might be composed. Two principles are illustrated: how to blend procedural and declarative thinking, and how to develop a program top-down.

<!-- page 107 -->
We have shown the dual reading of clauses: declarative and procedural. How do they interrelate when composing logic programs? Pragmatically, one thinks procedurally when programming. However, one thinks declaratively when considering issues of truth and meaning. One way to blend them in logic programming is to compose procedurally and then niterpret the result as a declarative statement. Construct a program with a given use in mind; then consider if the alternative uses make declarative sense. We apply this to a program for deleting elements from a list.

The first, and most important, step is to specify the intended meaning of the relation. Clearly, three arguments are involved when deleting elements from a list: an element X to be deleted, a list Li that might have occurrences of X, and a list L2 with all occurrences of X deleted. An appropriate relation scheme is delete (Li , X, L2). The natural meaning is all ground instances where L2 is the list Li with all occurrences of X removed.

When composing the program, it is easiest to think of one specific use. Consider the query delete([a,b,c,b] ,b,X)?, a typical example of finding the result of deleting an element from a list. The answer here is X= [a, c]. The program will be recursive on the first argument. Let's don our procedural thinking caps.

We begin with the recursive part. The usual form of the recursive argument for lists is [XXs]. There are two possibilities to consider, one where X is the element to be deleted, and one where it is not. In the first case, the result of recursively deleting X from Xs is the desired answer to the query. The appropriate rule is delete([XIXs],X,Ys) - delete(Xs,X,Ys).

Switching hats, the declarative reading of this rule is: "The deletion of X from [XXs] is Ys if the deletion of X from Xs is Ys." The condition that the head of the list and the element to be deleted are the same is specified by the shared variable in the head of the rule.

The second case where the element to be deleted is different from X, the head of the list, is similar. The result required is a list whose head is X and whose tail is the result of recursively deleting the element. The rule is delete([XIXs],Z,[XIYs]) - X

Z, delete(Xs,Z,Ys).

The rule's declarative reading is: "The deletion of Z from [XIXs] is [XYs] if Z is different from X and the deletion of Z from Xs is Ys." In contrast to the previous rule, the condition that the head of the list and the element to be deleted are different is made explicit in the body of the rule.

<!-- page 108 -->
The base case is straightforward. No elements can be deleted from the empty list, and the required result is also the empty list. This gives the delete(List,X,HasNoXs) -

The list HasNoXs is the result of removing all

occurrences of X from the list List.

```prolog
delete([XIXs],X,Ys) - delete(Xs,X,Ys).
delete([XIXs],Z,[XIYs])
                         XZ, delete(Xs,Z,Ys).
delete([ ] ,X, E 1).
```

Program 3.18

Deleting all occurrences of an element from a list

select (X,HasXs,OneLessXs) -

The list OneLessXs is the result of removing

one occurrence of X from the list HasXs.

```prolog
select (X, [XIXs] ,Xs)
select(X,[YIYs],[YIZs])
                         select(X,Ys,Zs).
```

Program 3.19

Selecting an element from a list

fact delete([ ] ,X, E J). The complete program is collected together as Program 3.18.

Let us review the program we have written, and consider alternative formulations. Omitting the condition XZ from the second rule in Program 3.18 gives a variant of delete. This variant has a less natural meaning, since any number of occurrences of an element may be deleted. For example,

```prolog
delete([a,b,c,b],b,[a,c]),
                              delete([a,b,c,b],b,[a,c,
```

**b]), delete([a,b,c,b],b,[a,b,c]), and delete([a,b,c,b],b,[a,b,**

c , b]) are all in the meaning of the variant.

Both Program 3.18 and the variant include in their meaning instances where the element to be deleted does not appear in either list, for example, delete([a] ,b, [a]) is true. There are applications where this is not desired. Program 3.19 defines select`(X,L1,L2),` a relation that has a different approach to elements not appearing in the list. The meaning of select `(X,L1,L2)` is all ground instances where `L2` is the list `Li` where exactly one occurrence of X has been removed. The declarative reading of Program 3.19 is: "X is selected from [XXs] to give Xs; or X is selected from [YYs] to give [YZs] if X is selected from Ys to give Zs,"

<!-- page 109 -->
A major thrust in programming has been the emphasis on a top-down design methodology, together with stepwise refinement. Loosely, the methodology is to state the general problem, break it down into subproblems, and then solve the pieces. A top-down programming style is one natural way for composing logic programs. Our description of programs throughout the book will be mostly top-down. The rest of this section describes the composition of two programs for sorting a list: permutation sort and quicksort. Their top-down development is stressed.

A logical specification of sorting a list is finding an ordered permutation of a list. This can be written down immediately as a logic program. The basic relation scheme is sort (Xs,Ys), where Ys is a list containing the elements in Xs sorted in ascending order: sort(Xs,Ys) - permutation(Xs,Ys), ordered(Ys). The top-level goal of sorting has been decomposed. We must now define permutation and ordered.

Testing whether a list is ordered ascendingly can be expressed in the two clauses that follow. The fact says that a list with a single element is necessarily ordered. The rule says that a list is ordered if the first element is less than or equal to the second, and if the rest of the list, beginning from the second element, is ordered:

```prolog
ordered([X]).
ordered([X,YIYs]) -
                       X
                           Y, ordered([YJYs]).
```

A program for permutation is more delicate. One view of the process of permuting a list is selecting an element nondeterrniriistically to be the first element of the permuted list, then recursively permuting the rest of the list. We translate this view into a logic program for permutation, using Program 3.19 for select. The base fact says that the empty list is its own unique permutation:

```prolog
permutation(Xs, [ZIZs]) - select(Z,Xs,Ys), permutation(Ys,Zs).
permutation([ ],[ 1).
Another procedural view of generating permutations of lists is recur-
```

sively permuting the tail of the list and inserting the head in an arbitrary position. This view also can be encoded immediately. The base part is identical to the previous version:

```prolog
permutation([XIXsI ,Zs) - permutation(Xs,Ys), insert(X,Ys,Zs).
permutation([ ],[ ]).
```

<!-- page 110 -->
sort(Xs,Ys) -

The list Ys is an ordered permutation of the list Xs.

```prolog
sort(Xs,Ys) - permutation(Xs,Ys), ordered(Ys).
permutation(Xs, [ZIZs]) - select(Z,Xs,Ys), permutation(Ys,Zs).
perrnutation([ ],[ 1).
ordered([ ]).
ordered([X])
ordered([X,YIYs])
                    X
                        Y, ordered([YIYs]).
```

Program 3.20

Permutation sort

The predicate insert can be defined in terms of Program 3.19 for select:

```prolog
insert(X,Ys,Zs)
                  '- select(X,Zs,Ys).
```

Both procedural versions of permutation have clear declarative readings.

The "naive" sorting program, which we call permutation sort, is collected together as Program 3.20. It is an example of the generate-and-test paradigm, discussed fully in Chapter 14. Note the addition of the extra base case for ordered so that the program behaves correctly for empty lists.

The problem of sorting lists is well studied. Permutation sort is not a good method for sorting lists in practice. Much better algorithms come from applying a "divide and conquer" strategy to the task of sorting. The insight is to sort a list by dividing it into two pieces, recursively sorting the pieces, and then joining the two pieces together to give the sorted list. The methods for dividing and joining the lists must be specified. There are two extreme positions. The first is to make the dividing hard, and the joining easy. This approach is taken by the quicksort algorithm The second position is making the joining hard, but the dividing easy. This is the approach of merge sort, which is posed as Exercise

`(y)` at the end of this section, and insertion sort, shown in Program 3.21.

In insertion sort, one element (typically the first) is removed from the list. The rest of the list is sorted recursively; then the element is inserted, preserving the orderedness of the list.

<!-- page 111 -->
The insight in quicksort is to divide the list by choosing an arbitrary element in it, and then to split the list into the elements smaller than the sort(Xs,Ys) -

The list Ys is an ordered permutation of the list Xs.

```prolog
sort([XIXs],Ys) - sort(Xs,Zs), insert(X,Zs,Ys).
sort([ ],[ ]).
insert(X,[ ],[X]).
insert(X,[YIYs],[YIZs]) - X> Y, insert(X,Ys,Zs).
insert(X, [YIYs] , [X,YIYs]) - X
                               y.
```

Program 3.21

Insertion sort

quicksort (Xs, Ys) -

The list Ys is an ordered permutation of the list Xs.

```prolog
quicksort([XIXs] ,Ys) -
    partition(Xs,X,Littles,Bigs),
    quicksort(Littles,Ls),
    quicksort(Bigs,Bs),
    append(Ls, [X lBs] ,Ys).
quicksort([ ],[ 1).
partition([XIXs] ,Y, [XILs] ,Bs)
                               X
                                   Y, partition(Xs,Y,Ls,Bs).
partition([XIXs] ,Y,Ls, [XIBs]) - X >
                                   Y, partition(Xs,Y,Ls,Bs).
partition( E ] ,Y,
                E J , E i)
```

Program 3.22

Quicksort

chosen element and the elements larger than the chosen element. The sorted list is composed of the smaller elements, followed by the chosen element, and then the larger elements. The program we describe chooses the first element of the list as the basis of partition.

Program 3.22 defines the quicksort algorithm. The recursive rule for quicksort reads: "Ys is a sorted version of [XIXs] if Littles and Bigs are a result of partitioning Xs according to X; Ls and Bs are the result of sorting Littles and Bigs recursively; and Ys is the result of appending [XBs] to Ls."

<!-- page 112 -->
Partitioning a list is straightforward, and is similar to the program for deleting elements. There are two cases to consider: when the current head of the list is smaller than the element being used for the partitioning, and when the head is larger than the partitioning element. The declarative reading of the first partition clause is: "Partitioning a list whose head is X and whose tail is Xs according to an element Y gives the lists [XLitt1es] and Bigs if X is less than or equal to Y, and partitioning Xs according to Y gives the lists Littles and Bigs." The second clause for partition has a similar reading. The base case is that the empty list is partitioned into two empty lists.

3.3.1

Exercises for Section 3.3 Write a program for substitute(X,Y,Li,L2), where L2 is the result of substituting Y for all occurrences of X in Li, e.g., substitute(a,x,[a,b,a,c],[x,b,x,c])

is true, whereas substitute (a, x, [a,b, a, cl , [a,b ,x, c] ) is false. What is the meaning of the variant of select: select (X, [XIXs] ,Xs). select(X, [YIYs] , [YIZs]) '- X

Y, select(X,Ys,Zs). Write a program for no_doubles(L1 ,L2), where L2 is the result of removing all duplicate elements from Li, e.g., no_doubles ([a, b, c, b], [a,c,b]) is true. (Hint: Use member.) Write programs for evenpermutation(Xs ,Ys) and oddpermutation(Xs,Ys) that find Ys, the even and odd permutations, respectively, of a list Xs. For example, even_permutation([i »2,3]

» [2,3, i]) andoddpeimutation([i,2,3],[2,i,3]) aretrue.

<!-- page 113 -->
(y) Write a program for merge sort. (vi) Write a logic program for kthlargest (Xs , K) that implements the linear algorithm for finding the kth largest element K of a list Xs. The algorithm has the following steps: Break the list into groups of five elements. Efficiently find the median of each of the groups, which can be done with a fixed number of comparisons. Recursively find the median of the medians. Partition the original list with respect to the median of medians. Recursively find the kth largest element in the appropriate smaller list. (vii) Write a program for the relation

```prolog
better_poker_hand(Handl,
```

`Hand2,Hand)` that succeeds if `Hand` is the better poker hand between `Handi` and `Hand2.` For those unfamiliar with this card game, here are some rules of poker necessary for answering this exercise:

The order of cards is 2, 3, 4, 5, 6, 7, 8, 9, 10, jack, queen, king,

```prolog
ace.
```

Each hand consists of five cards.

The rank of hands in ascending order is no pairs < one pair <

two pairs < three of a kind < flush < straight < full house <

four of a kind < straight flush.

Where two cards have the same rank, the higher denomination

wins, for example, a pair of kings beats a pair of 7's. (Hints:

(1) Represent a poker hand by a list of terms of the form `card(Suit,Value).` For example a hand consisting of the 2 of clubs, the 5 of spades, the queen of hearts, the queen of diamonds, and the 7 of spades would be represented by the list `[card`

```prolog
(clubs,2),card(spades,5),card(hearts,queen),card(diamonds,
```

`queen),card(spades,7)1.` (2)It maybe helpful to define relations such as `has_f lush (Hand),` which is true if all the cards in `Hand` are of the same suit; `has_full_house (Hand),` which is true if `Hand` has three cards with the same value but in different suits, and the other two cards have the same different value; and `has_straight (Hand),` which is true if `Hand` has cards with consecutive values. (3) The number of cases to consider is reduced if the hand is first sorted.)

<!-- page 114 -->
3.4 Binary Trees We next consider binary trees, another recursive data type. These structures have an important place in many algorithms. Binary trees are represented by the ternary functor `tree (Element,` `Leí t,Right),` where `Element` is the element at the node, and `Left` and `Right` are the left and right subtrees respectively. The empty tree is represented by the atom `void.` For example, the tree

```prolog
  a
b
     C
```

would be represented as

```prolog
tree(a,tree(b,void,void),tree(c,void,void)).
```

Logic programs manipulating binary trees are similar to those manipulating lists. As with natural numbers and lists, we start with the type definition of binary trees. lt is given as Program 3.23. Note that the program is doubly recursive; that is, there are two goals in the body of the recursive rule with the same predicate as the head of the rule. This resuits from the doubly recursive nature of binary trees and will be seen also in the rest of the programs of this section.

Let us write some tree-processing programs. Our first example tests whether an element appears in a tree. The relation scheme is `tree_` `member(Element,Tree).` The relation is true if `Element` is one of the nodes in the tree. Program 3.24 contains the definition. The declarative reading of the program is: "X is a member of a tree if it is the element at the node (by the fact) or if it is a member of the left or right subtree (by the two recursive rules)."

The two branches of a binary tree are distinguishable, but for many applications the distinction is not relevant. Consequently, a useful concept

binary_tree( Tree) -

Tree is a binary tree.

```prolog
binary_tree (void).
binary_tree (tree(Element ,Lef t ,Right)) -
    binary_tree(Left), binarytree(Right).
```

Program 3.23

Defining binary trees

tree_member(Element,Tree) -

Element is an element of the binary tree Tree.

```prolog
tree_momber(X,tree(X,Left,Right)).
tree_member(X,tree(Y,Left ,Right)) - tree_rnember(X,Left).
tree_membor(X,tree(Y,Left ,Right)) '- tree_member(X ,Rïght).
```

Program 3.24

<!-- page 115 -->
Testing tree membership a

b

Figure 3.6

Comparing trees for isomorphism

isotree(Treel,Tree2) -

Tree I and Tree2 are isomorphic binary trees.

```prolog
isotree(void,void).
isotree(tree(X,Leftl,Rightl),tree(X,Left2,Right2))
    isotree(Leftl,Left2), isotree(Rightl,Right2)
isotree(tree(X,Leftl,Rightl),tree(X,Left2,Right2))
    isotree(Leftl ,Right2), isotree(Rightl ,Left2).
```

Program 3.25

Determining when trees are isomorphic

is isomorphism, which defines when unordered trees are essentially the same. Two binary trees Ti and T2 are isomorphic if T2 can be obtained by reordering the branches of the subtrees of Ti. Figure 3.6 shows three simple binary trees. The first two are isomorphic; the first and third are not.

Isomorphism is an equivalence relation with a simple recursive definition. Two empty trees are isomorphic. Otherwise, two trees are isomorphic if they have identical elements at the node and either both the left subtrees and the right subtrees are isomorphic; or the left subtree of one is isomorphic with the right subtree of the other and the two other subtrees are isomorphic.

Program 3.25 defines a predicate isotree(Treel,Tree2), which is true if Tree i and Tree2 are isomorphic. The predicate is symmetric in its arguments.

<!-- page 116 -->
Programs related to binary trees involve double recursion, one for each branch of the tree. The double recursion can be manifest in two ways. Programs can have two separate cases to consider, as in Program 3.24 for tree_member. In contrast, Program 3.12 testing membership of a list has only one recursive case. Alternatively, the body of the recursive clause has two recursive calls, as in each of the recursive rules for isotree in Program 3.25. substitute (X, Y,TreeX,TreeY) -

The binary tree Tree Y is the result of replacing all

occurrences of X in the binary tree TreeX by Y.

```prolog
substïtute(X,Y,void,void)
substitute(X,Y,tree(Node,Left,Right),tree(Nodel,Leftl,Rightl))
    replace (X,Y,Node,Nodel)
    substitute (X,Y,Left,Leftl)
    substitute(X,Y,Rigbt,Rightl).
replace(X,Y,X,Y).
replace(X,Y,Z,Z) - X
                       Z.
```

Program 3.26 Substituting for a term in a tree

The task in Exercise 3.3(i) is to write a program for substituting for elements in lists. An analogous program can be written for substituting elements in binary trees. The predicate

```prolog
substitute(X,Y,OldTree,
```

`NewTree)` is true if `NewTree` is the result of replacing all occurrences of X by Y in `OldTree.` An axiomatization of `substitute/4` is given as Program 3.26.

Many applications involving trees require access to the elements appearing as nodes. Central is the idea of a tree traversal, which is a sequence of the nodes of the tree in some predefined order. There are three possibilities for the linear order of traversal: preorder, where the value of the node is first, then the nodes in the left subtree, followed by the nodes in the right subtree; morder, where the left nodes come first followed by the node itself and then the right nodes; and postorder, where the node comes after the left arid right subtrees.

A definition of each of the three traversals is given in Program 3.27. The recursive structure is identical; the ordy difference between the programs is the order in which the elements are composed by the various

```prolog
append goals.
```

The final example in this section shows interesting manipulation of trees. A binary tree satisfies the heap property if the value at each node is at least as large as the value at its children (if they exist). Heaps, a class of binary trees that satisfy the heap property, are a useful data structure and can be used to implement priority queues efficiently.

<!-- page 117 -->
lt is possible to heapify any binary tree containing values for which an ordering exists. That is, the values in the tree are moved around so that preorder ( Tree,Pre) -

Pre is a preorder traversal of the binary tree Tree.

```prolog
preorder(tree(X,L,R) ,Xs)
    preorder(L,Ls), preorder(R,Rs), append([XJLsJ,Rs,Xs).
preorder(void, E 1).
```

morder ( Tree,In) -

In is an morder traversal of the binary tree Tree.

```prolog
inorder(tree(X,L,R) ,Xs) -
    inorder(L,Ls), inorder(R,Rs), append(Ls,EXIRs],Xs).
inorder(void, E 1).
```

postorder ( Tree,Post) -

Post is a postorder traversal of the binary tree Tree.

```prolog
postorder(tree(X,L,R) ,Xs) -
    postorder(L,Ls),
    postorder(R,Rs),
    append(Rs, [X] ,Rsl),
    append(Ls,Rsl,Xs).
postorder(void, E 1).
```

Program 3.27 Traversals of a binary tree

the shape of the tree is preserved and the heap property is satisfied. An example tree and its heapified equivalent are shown in Figure 3.7.

An algorithm for heapifying the elements of a binary tree so that the heap property is satisfied is easily stated recursively. Heapify the left and right subtrees so that they both satisfy the heap property and then adjust the element at the root appropriately. Program 3.28 embodies this algorithm. The relation `heapify/2` lays out the doubly recursive program structure, and `adjust(X,HeapL,HeapR,Heap)` produces the final tree `Heap` satisfying the heap property from the root value X and the left and right subtrees `HeapL` and `HeapR` satisfying the heap property.

<!-- page 118 -->
There are three cases for `adj ust/4` depending on the values. If the root value is larger than the root values of the left and right subtrees, then the heap is `tree(X,HeapL,HeapR).` This is indicated in the first `adjust` clause in Program 3.28. The second clause handles the case where the root node in the left heap is larger than the root node and the root of the right heap. In that case, the adjustment proceeds recursively on the left heap. The third clause handles the symmetric case where the root node of the right heap is the largest. The code is simplified by relegating the concern whether the subtree is empty to the predicate `greater/2.` Figure 3.7 A binary tree and a heap that preserves the tree's shape

heapify ( Tree,Heap)

The elements of the complete binary tree Tree have been adjusted

to form the binary tree Heap, which has the same shape as Tree and

satisfies the heap property that the value of each parent node is

greater than or equal to the values of its children. heapify(void,void).

```prolog
heapify(tree(X,L,R) Heap)
    heapify(L,HeapL), heapify(R,HeapR), adjust(X,HeapL,HeapR,Heap).
adj ust (X , HeapL , HeapR , tree (X , HeapL , HeapR)
    greater(X,HeapL), greater(X,HeapR).
```

adj ust(X,tree(X1,L,R),HeapR,tree(X1,HeapL,HeapR))

X

< Xl,

```prolog
           greater(X1,HeapR), adjust(X,L,R,HeapL).
adjust(X,HeapL,tree(Xl,L,R),tree(Xl,HeapL,HeapR)) -
    X
      < Xl, greater(Xl,HeapL), adjust(X,L,R,HeapR).
greater(X,void).
greater(X,tree(X1,L,R)) -
                         X
                             Xl.
```

Program 3.28

Adjusting a binary tree to satisfy the heap property

3.4.1

Exercises for Section 3.4

(i)

Define a program for subtree(S ,T), where S is a subtree of T. (II)

Define the relation sum_tree(Treeoflntegers,Sum), which holds

if Sum is the sum of the integer elements in TreeOflntegers. (IIi)

Define the relation ordered(Treeof Integers), which holds if Tree

is an ordered tree of integers, that is, for each node in the tree

<!-- page 119 -->
the elements in the left subtree are smaller than the element in

the node, and the elements in the right subtree are larger than

the element in the node. (Hint:

Define two auxiliary relations,

```prolog
ordered_left(X,Tree) and ordered_right(X,Tree), which hold
```

if both `Tree` is ordered and X is larger (respectively, smaller) than

the largest (smallest) node of `Tree.)` (iv)

Define the relation `tree_insert(X,Tree,Treel),` which holds if

`Treel` is an ordered tree resulting from inserting X into the ordered

tree `Tree.` If X already occurs in `Tree,` then `Tree` and `Tree i` are iden-

tical. (Hint: Four axioms suffice.)

(y)

Write a logic program for the relation `path(X,Tree,Path),` where

`Path` is the path from the root of the tree `Tree` to X.

3.5 Manipulating Symbolic Expressions The logic programs illustrated so far in this chapter have manipulated natural numbers, lists, and binary trees. The programming style is applicable more generally. This section gives four examples of recursive programming - a program for defining polynomials, a program for symbolic differentiation, a program for solving the Towers of Hanoi problem, and a program for testing the satisfiability of Boolean formulae.

The first example is a program for recognizing polynomials in some term X. Polynomials are defined inductively. X itself is a polynomial in X, as is any constant. Sums, differences, and products of polynomials in X are polynomials in X. So too are polynomials raised to the power of a natural number, and the quotient of a polynomial by a constant.

An example of a polynomial in the term x is x2 - 3x + 2. This follows from its being the sum of the polynomials, x2 - 3x and 2, where x2 - 3x is recognized recursively.

A logic program for recognizing polynomials is obtained by expressing the preceding informal rules in the correct form. Program 3.29 defines the relation `polynomial (Expression,X),` which is true if `Expression is` a polynomial in X. We give a declarative reading of two rules from the program.

<!-- page 120 -->
The fact `polynomial(X,X)` says that a term X is a polynomial in itself. The rule polynomial (Expression,X) -

Expression is a polynomial ¡n X.

```prolog
polynomial (X , X)
polynomial (Term, X) -
    constant (Term)
polynomial (Termi +Term2 , X) -
    polynomial (Terml,X), polynomial(Torm2,X).
polynomial (TermlTorm2 ,X)
    polynomial(Terml,X), polynomial(Term2,X).
polynomial (Terml *Term2 , X)
    polynomïal(Terml,X), polynomial(Term2,X).
polynomial (Terml/Term2 , X)
    polynomial(Terml,X), constant(Term2).
polynomial(TermtN,X)
    natural_number(N), polynomial(Term,X).
```

Program 3.29

Recognizing polynomials

polynomial(Terml+Terin2,X) -

```prolog
polyrioinial(Termi,X), polynomial(Term2,X).
```

says that the sum Terml+Term2 is a polynomial in X if both Tenni and Term2 are polynomials in X.

Other conventions used in Program 3.29 are the use of the unary predicate `constant` for recognizing constants, and the binary functor

T to denote exponentiation. The term XTY denotes x".

The next example is a program for taking derivatives. The relation scheme

is

```prolog
derivative(Expression,X,DifferentiatedExpression).
```

The intended meaning of derivative is that DifferentiatedExpression is the derivative of Expression with respect to X.

<!-- page 121 -->
As for Program 3.29 for recognizing polynomials, a logic program for differentiation is just a collection of the relevant differentiation rules, written in the correct syntax. For example, the fact derivative(X,X,s(0)). expresses that the derivative of X with respect to itself is 1. The fact derivative(sin(X) ,X,cos(X)). derivative (Expression,X,DifferentiatedEx pression)

DifferentiatedEx pression is the derivative of

Expression with respect to X.

```prolog
derivative(X,X,s(0)).
derivative(XIs(N) ,X,s(N)*XIN)
derivative(sin(X) ,X,cos(X))
derivative(cos(X) ,X,-sin(X)).
derivative(elX,X,eX).
derivative(log(X),X,1/X).
derivat ive (F+G ,X ,DF+DG) -
    derivative(F,X,DF), derivative(G,X,DG).
derivat ive (F-G ,X ,DF-DG) -
    derivative(F,X,DF), derivative(G,X,DG).
derivat ive (F*G ,X ,F*DG+DF*G)
    derivative(F,X,DF), derivative(G,X,DG).
derivative(1/F,X,-DF/(F*F)) -
    derivative(F,X,DF).
derivative(F/G,X, (G*DF-F*DG)/(G*G)) -
    derivative(F,X,DF), derivative(G,X,DG).
```

Program 3.30

Derivative rules

reads: "The derivative of `sin(X)` with respect to `X is cos(X)."` Natural mathematical notation can be used. A representative sample of functions and their derivatives is given in Program 3.30.

Sums and products of terms are differentiated using the sum rule and product rule, respectively. The sum rule states that the derivative of a sum is the sum of derivatives. The appropriate clause is

```prolog
derivative(F+G,X,DF+DG) -
    derivative(F,X,DF), derivative(G,X,DG).
```

The product rule is a little more complicated, but the logical clause is just the mathematical definition:

```prolog
derivative(F*G,X,F*DG+DF*G) -
    derivative(F,X,DF), derivative(G,X,DG).
```

Program 3.30 also contains the reciprocal and quotient rules.

<!-- page 122 -->
The chain rule is a little more delicate. It states that the derivative of f(g(x)) with respect to x is the derivative of f(g(x)) with respect to g(x) times the derivative of g(x) with respect to x. As stated, it involves quantification over functions, and is outside the scope of the logic programs we have presented.

Nonetheless, a version of the chain rule is possible for each particular function. For example, we give the rule for differentiating XN and `sin(X):`

```prolog
derivative(Uls(N) ,X,s(N)*UTN*DU) -
derivative (U,X,DU).
derivative(sin(U),X,cos(U)*DU) - derivative(U,X,DU).
```

The difficulty of expressing the chain rule for differentiation arises from our choice of representation of terms. Both Programs 3.29 and 3.30 use the 'natural" representation from mathematics where terms represent themselves. A term such as `sin(X)` is represented using a unary structure `sin.` If a different representation were used, for example, `unary_term(sin,X)` where the name of the structure is made accessible, then the problem with the chain rule disappears. The chain rule can then be formulated as

```prolog
derivative (unary_term(F,U) ,X,DF*DU) -
    derivative(unary_term(F,U),U,DF), derivative(IJ,X,DU).
```

Note that all the rules in Program 3.30 would have to be reformulated in terms of this new representation and would appear less natural.

People take for granted the automatic simplification of expressions when differentiating expressions. Simplification is missing from Program 3.30. The answer to the query `derivative (3*x+2,x,D)?` is `D(3*1+O*`

`x)+O.` We would immediately simplify `D` to 3, but it is not specified in the logic program.

The next example is a solution to the Towers of Hanoi problem, a standard introductory example in the use of recursion. The problem is to move a tower of n disks from one peg to another with the help of an auxiliary peg. There are two rules. Only one disk can be moved at a time, and a larger disk can never be placed on top of a smaller disk.

<!-- page 123 -->
There is a legend associated with the game. Somewhere hidden in the surroundings of Hanoi, an obscure Far Eastern village when the legend was first told, is a monastery. The monks there are performing a task assigned to them by God when the world was created - solving the preceding problem with three golden pegs and 64 golden disks. At the moment they complete their task, the world will collapse into dust. Since the optimal solution to the problem with n disks takes 2 - i moves, we hanoi (N,A,B,C,Moves) -

Moves is a sequence of moves for solving the Towers of

Hanoi puzzle with N disks and three pegs, A, B, and C. hanoi(s(0),A,B,C,[A to B]). hanoi(s(N),A,B,C,Moves) -

```prolog
hanoi(N,A,C,B,Msl),
hanoi(N,C,B,A,Ms2)
append(Msl,[A to BIMs2],Moves).
```

Program 3.31

Towers of Hanoi

need not lose any sleep over this possibility. The number 264 is comfortingly big.

**The relation scheme for solving the problem is hanoi(N,A,B,C,**

`Moves).` It is true if `Moves` is the sequence of moves for moving a tower of N disks from peg `A` to peg `B` using peg C as the auxiliary peg. This is an extension to usual solutions that do not calculate the sequence of moves but rather perform them. The representation of the moves uses a binary functor to, written as an infix operator. The term X to Y denotes that the top disk on peg X is moved to peg Y. The program for solving the problem is given in Program3.31.

The declarative reading of the heart of the solution, the recursive rule in Program 3.31, is: `"Move s` is the sequence of moves of `s` (N) disks from peg A to peg `B` using peg C as an auxiliary, if `Msi` is the solution for moving N disks from `A` to C using `B, Ms2` is the solution for moving N disks from C to `B` using `A,` and `Moves` is the result of appending `[A to BIMs2]`

```prolog
to Msi."
```

The recursion terminates with moving one disk. A slightly neater, but less intuitive, base for the recursion is moving no disks. The appropriate fact is

```prolog
hanoi(O,A,B,C,[ ]).
```

The final example concerns Boolean formulae.

A Boolean formula is a term defined as follows: The constants true and false are Boolean formulae; if X and Y are Boolean formulae, so are Xv Y, XA Y, and -X, where y and A are binary infix operators for disjunction and conjunction, respectively, and

<!-- page 124 -->
is a unary prefix operator for negation. saris fiable(Formula)

There is a true instance of the Boolean formula Formula.

```prolog
satisfiabie(true)
satisfiable(XAY) - satisfiable(X), satisfiable(Y).
satisfiabie(XVY)
                   satisfïable(X).
satisfiable(XVY) - satisfiable(Y).
satisfiable(-X) - invalid(X).
```

invalid(Formula)

There is a false instance of the Boolean formula Formula.

```prolog
invalid (f aise)
invaiid(XVY) - invaiìd(X), invalid(Y).
invaiid(XAY)
               invaiid(X).
invalid(XAY) - invalid(Y).
invalid(-'-Y) - satisf jable (Y)
```

Program 3.32

Satisfiability of Boolean formulae

A Boolean formula F is true if

F

'true', F = XAY, and both X and Y are true. F = XvY, and either X or Y (or both) are true. F =

X, and X is false.

A Boolean formula F is false if

F = 'false'. F = XAY, and either X or Y (or both) are false. F = XvY, and both X and Y are false. F = =X, and X is true.

<!-- page 125 -->
Program 3.32 is a logic program for determining the truth or falsity of a Boolean formula. Since it can be applied to Boolean formulae with variables, it is actually more powerful than it seems. A Boolean formula with variables is `satisfiable` if it has a true instance. It is `invalid` if it has a false instance. These are the relations computed by the program. 3.5.1

Exercises for Section 3.5 Write a program to recognize if an arithmetic sum is normalized, that is, has the form A + B, where A is a constant and B is a normalized sum. Write a type definition for Boolean formulae. Write a program for recognizing whether a logical formula is in conjunctive normal form, namely, is a conjunction of disjunctions of literals, where a literal is an atomic formula or its negation. Write a program for the relation `negation_inwards (Fi ,F2),` which is true if `F2` is the logical formula resulting from moving all negation operators occurring in the formula `Fi` inside conjunctions and disjunctions.

(y) Write a program for converting a logical formula into conjunctive normal form, that is, a conjunction of disjunctions. (vi) Consider the following representation of a bag, that is, a list of elements with multiplicities. The function symbol `bag(Element,` `Multiplicity,RestûfBag)` should be used. The atom `void` can be used as an empty bag. For example, the term `bag (a, 3, bag (b, 2,` `void))` represents a list of three copies of an element

`a,` and two copies of an element `b.` Write logic programs to

Take the union of two bags;

Take the intersection of two bags;

Substitute for an element in a bag;

Convert a list into a bag;

Convert a binary tree into a bag.

**3.6 Background**

<!-- page 126 -->
Many of the programs in this chapter have been floating around the logic programming community, and their origins have become obscure. For example, several appear in Clocksm and Mellish (1984) and in the uneven collection of short Prolog programs, How to Solve It in Prolog by Coelho et al. (1980).

The latter book has been updated as Coelho and Cotta (1988) and is a source for other simple examples. The exercise on describing poker hands is due to Ken Bowen.

The classic reference for binary trees is Knuth (1968) and for sorting Knuth (1973).

A discussion of the linear algorithm for the kth largest algorithms can be found in most textbooks on algorithms, for example, Horowitz and Sahni (1978). The discussion of the heap property is taken from Horowitz and Sahni (1978).

Many of the basic programs for arithmetic and list processing have a simple structure that allows many correctness theorems to be proved automatically, see, for example, Boyer and Moore (1979) and Sterling and Bundy (1982).

Ackermann's function is discussed by Peter (1967).
