# 8 Arithmetic

<!-- page 190 -->
The logic programs for performing arithmetic presented in Section 3.1 are very elegant, but they are not practical. Any reasonable computer provides very efficient arithmetic operations directly in hardware, and practical logic programming languages cannot afford to ignore this feature. Computations such as addition take unit time on most computers independent of the size of the addends (as long as they are smaller than some large constant). The recursive logic program for plus (Program 3.3) takes time proportional to the first of the numbers being added. This could be improved by switching to binary or decimal notation but still won't compete with direct execution by dedicated hardware.

Every Prolog implementation reserves some predicate names for system-related procedures. Queries to these predicates, called system predicates, are handled by special code in the implementation in contrast to calls to predicates defined by pure Prolog programs. A Prolog implementor should build system predicates that complement pure Prolog naturally and elegantly. Other names for system predicates are evaluable predicates, builtiri predicates, or bips, the latter two being referred to in the draft for Standard Prolog.

<!-- page 191 -->
8.1 System Predicates for Aiitkmetic The role of the system predicates for arithmetic introduced in Prolog is to provide an interface to the underlying arithmetic capabilities of the computer in a straightforward way. The price paid for this efficiency is that some of the machine-oriented arithmetic operations are not as general as their logical counterparts. The interface provided is an arithmetic evaluator, which uses the underlying arithmetic facilities of the computer. Standard Prolog has a system predicate `is (Value ,Expression)` for arithmetic evaluation. Goals with the predicate is are usually written in binary infix form, taking advantage of the operator facility of Prolog, about which we now digress.

Operators are used in order to make programs more readable. People are very flexible and learn to adjust to strange surroundingsthey can become accustomed to reading Lisp and Fortran programs, for example. We believe nonetheless that syntax is important; the power of a good notation is well known from mathematics. Ari integral part of a good syntax for Prolog is the ability to specify and use operators.

Operators, for example

and <, have already been used in earlier chapters. Standard Prolog provides several operators, which we introduce as they arise. Programmers can also define their own operators using the built-in predicate op/3. An explanation of the mechanism for operator declarations, together with a list of pre-defined operators and their precedences is given in Appendix B.

Queries using the arithmetic evaluator provided by Prolog have the form `Value is Expression?.` Queries to the evaluator are interpreted as follows. The arithmetic expression `Expression` is evaluated and the result is unified with `Value.` Once arithmetic evaluation succeeds, the query succeeds or fails depending on whether unification succeeds or fails.

Here are some examples of simple addition, illustrating the use and behavior of the evaluator. The query (X is 3+5)? has the solution X=8. This is the standard use of the evaluator, instantiating a variable to the value of an arithmetic expression. The query (8 is 3+5)? succeeds. Having both arguments to is instantiated allows checking the value of an arithmetic expression. (3+5 is 3+5)? fails because the left-hand argument, 3+5, does not unify with 8, the result of evaluating the expression.

<!-- page 192 -->
Standard Prolog specifies a range of arithmetic operations that should be supported by Prolog for both integers and reals represented as floating-point numbers. In particular, the evaluator provides for addition, subtraction, multiplication, and division (+, -, *, I) with their usual mathematical precedences. In this book, we restrict ourselves to integer arithmetic.

What happens if the term to be evaluated is not a valid arithmetic expression? An expression can be invalid for one of two reasons, which should be treated differently, at least conceptually. A term such as 3+x for a constant x cannot be evaluated. In contrast, a term 3+Y for a variable Y may or may not be evaluable, depending on the value of Y.

The semantics of any logic program is completely defined, and, in this sense, logic programs cannot have runtime "errors." For example, the goal X is 3+Y has solutions (X=3,Y=O}. However, when interfacing logic programs to a computer, the limitations of the machine should be taken into account. A runtime error occurs when the machine cannot determine the result of the computation because of insufficient information, that is, uninstantiated variables. This is distinct from goals that simply fail. Extensions to Prolog and other logic languages handle such "errors" by suspending until the values of the concerned variables are known. The execution model of Prolog as introduced does not permit suspension. Instead of simply failure, we say an error condition occurs.

The query (X is 3+x)? fails because the right-hand argument cannot be evaluated as an arithmetic expression. The query (X is 3Y)? is an example of a query that would succeed if Y were instantiated to an arithmetic expression. Here an error condition should be reported.

A common misconception of beginning Prolog programmers is to regard is as taking the place of assignment as in conventional programming languages. It is tempting to write a goal such as (N is N+1). This is meaningless. The goal fails if N is instantiated, or causes an error if N is a variable.

Further system predicates for arithmetic are the comparison operators. Instead of the logically defined <,

(written =<), >,

(written >), Prolog directly calls the underlying arithmetic operations. We describe the behavior of <; the others are virtually identical. To answer the query (A < B)?, A and B are evaluated as arithmetic expressions. The two resultant numbers are compared, and the goal succeeds if the result of evaluating A is less than the result of evaluating B. Again, if A or B is not an arithmetic expression, the goal will fail, and an error condition should result if A or B are not ground.

Here are some simple examples. The query (1

< 2)? succeeds, as does the query (3-2 < 2*3+1)?. On the other hand, (2

<!-- page 193 -->
< 1)? fails, and (N < 1)? generates an error when N is a variable.

Tests for equality and inequality of values of arithmetic expressions are implemented via the builtin predicates =: = and =1=, which evaluate both of their arguments and compare the resulting values.

8.2 Arithmetic Logic Programs Revisited Performing arithmetic via evaluation rather than logic demands a reconsideration of the logic programs for arithmetic presented in Section 3.1. Calculations can certainly be done more efficiently. For example, finding the minimum of two numbers can use the underlying arithmetic comparison. The program syntactically need not change from Program 3.7. Similarly, the greatest common divisor of two integers can be computed efficiently using the usual Euclidean algorithm, given as Program 8.1. Note that the explicit condition .3 > O is necessary to avoid multiple solutions when J equals O and errors from calling mod with a zero argument.

Two features of logic programs for arithmetic are missing from their Prolog counterparts. First, multiple uses of programs are restricted. Suppose we wanted a predicate plus (X,Y,Z) that performed as before, built using is. The obvious definition is plus(X,Y,Z) - Z is X+Y. This works correctly if X and Y are instantiated to integers. However, we cannot use the same program for subtraction with a goal such as plus(3,X,8)?, which raises an error condition. Meta-logical tests are needed if the same program is to be used for both addition and subtraction. We defer this until meta-logical predicates are introduced in Chapter 10.

Programs effectively become specialized for a single use, and it is tricky to understand what happens when the program is used differently.

greatesLconimon_divisor (X, Y,Z) -

Z is the greatest common divisor of the integers X and Y.

```prolog
greatest_common_divisor(I,O,I).
greatest_common_divisor(I , .J,Gcd) -
    J > O,
          B. is I mod J, greatest_common_divisor(J,R,Gcd).
```

Program 8.1

<!-- page 194 -->
Computing the greatest common divisor of two integers factorial(N,F) -

F is the integer N factorial.

```prolog
factorial(N,F) -
    N > 0, Nl is N-1, factorial(N1,F1), F is N*F1.
factorial (0,1).
```

Program 8.2

Computing the factorial of a number

Program 3.7 for minimum, for example, can be used reliably only for finding the minimum of two integers.

The other feature missing from Prolog programs for arithmetic is the recursive structure of numbers. In logic programs, the structure is used to determine which rule applies, and to guarantee termination of computations. Program 8.2 is a Prolog program for computing factorials closely corresponding to Program 3.6. The recursive rule is more clumsy than before. The first argument in the recursive call of factorial must be calculated explicitly rather than emerging as a result of unification. Furthermore, the explicit condition determining the applicability of the recursive rule, N > O, must be given. This is to prevent nonterminating computations with goals such as factorial(-1,N)? or even factorial(3,F)?. Previously, in the logic program, unification with the recursive structure prevented nonterminating computations.

Program 8.2 corresponds to the standard recursive definition of the factorial function. Unlike Program 3.6, the program can be used only to calculate the factorial of a given number. A factorial query where the first argument is a variable will cause an error condition.

We must modify the concept of correctness of a Prolog program to accommodate behavior with respect to arithmetic tests. Other system predicates that generate runtime "errors" are handled similarly. A Prolog program is totally correct over a domani D of goals if for all goals in D the computation terminates, does not produce a runtime error, and has the correct meaning. Program 8.2 is totally correct over the domain of goals where the first argument is an integer. 8.2.1

Exercises for Section 8.2

(i)

The Nth triangular number is the sum of the numbers up to and in-

cluding N. Write a program for the relation triangle(N,T), where

<!-- page 195 -->
T is the Nth triangular number. (Hint: Adapt Program 8.2.) (ii)

Write a Prolog program for `power(X,N,V),` where V equals

```prolog
XN.
```

Which way can it be used? (Hint: Model it on Program 3.5 for `exp.)` (ill)

Write Prolog programs for other logic programs for arithmetic given

in the text and exercises in Section 3.1. (iv)

Write a Prolog program to generate a Huifman encoding tree from a

list of symbols and their relative frequencies.

8.3 Transforming Recursion into Iteration In Prolog there are no iterative constructs as such, and a more general concept, namely recursion, is used to specify both recursive and iterative algorithms. The main advantage of iteration over recursion is efficiency, mostly space efficiency. In the implementation of recursion, a data structure (called a stack frame) has to be maintained for every recursive call that has not terminated yet. A recursive computation involving n recursive procedure calls would require, therefore, space linear in n. On the other hand, an iterative program typically uses only a constant amount of memory, independent of the number of iterations.

Nevertheless, there is a restricted class of recursive programs that corresponds quite closely to conventional iterative programs. Under some conditions, explained further in Section 11.2 on tail recursion optimization, such Prolog programs can be implemented with almost the same efficiency as iterative programs in conventional languages. For this reason, it is preferable to express a relation using an iterative program, if possible. In this section, we show how recursive programs can be made iterative using accumulators.

Recall that a pure Prolog clause is iterative if it has one recursive call in the body. We extend this notion to full Prolog, and allow zero or more calls to Prolog system predicates before the recursive call. A Prolog procedure is iterative if it contains only unit clauses and iterative clauses.

Most simple arithmetic calculations can be implemented by iterative programs.

<!-- page 196 -->
Factorials can be computed, for example, in a loop where the numbers up to the desired factorial are multiplied together. A procedure in a

```prolog
factorial(N);
    I is O; T is 1;
    while I < N do
        I is I + 1; T is T
                          * I
                               end;
    return T.
```

Figure 8.1

Computing factorials iteratively

factorial(N,F)

F is the integer N factorial.

```prolog
factorïal(N,F) - factorial(0,N,i,F).
factorial(I,N,T,F)
    I < N, Ii is 1+1, Ti is T*I1, factorial(I1,N,T1,F).
factorial(N,N,F,F).
```

Program 8.3 An iterative factorial

Pascal-like language using a while loop is given in Figure 8.1. Its iterative behavior can be encoded directly in Prolog with an iterative program.

Prolog does not have storage variables, which can hold intermediate results of the computation and be modified as the computation progresses. Therefore, to implement iterative algorithms, which require the storage of intermediate results, Prolog procedures are augmented with additional arguments, called accumWators. Typically, one of the intermediate values constitutes the result of the computation upon termination of the iteration. This value is unified with the result variable using the unit clause of the procedure.

This technique is demonstrated by Program 8.3, which is a Prolog delinitìon of `factorial` that mirrors the behavior of the while ioop in Figure 8.1. It uses `factorial(I ,N,T,F),` which is true if F is the value of `N` factorial, and I and T are the values of the corresponding loop variables before the (i+1)th iteration of the loop.

<!-- page 197 -->
The basic iterative loop is performed by the iterative procedure `f acto-` `rial/4.` Each reduction of a goal using `Íactorial/4` corresponds to an iteration of the while loop. The call of `f actorial/4` by `factorìal/2` corresponds to the initialization stage. The first argument of `factorial/4,` the loop counter, is set to O. factorial(N,F) -

F is the integer N factorial.

```prolog
factorial(N,F) - factorial(N,1,F).
factorial(N,T,F) -
    N > O, Ti is T*N, Nl is N-1, factorial(Nl,Ti,F).
factorial(O,F,F).
```

Program 8.4

Another iterative factorial

The third argument of `f actorial/4` is used as an accumulator of the running value of the product. It is initialized to 1 in the call to `f ac-` `torial/4` by `factorial/2.` The handling of both accumulators in Program 8.3 is a typical programming technique in Prolog. It is closely related to the use of accumulators in Programs 3.16b and 7.10 for collecting elements in a list.

Accumulators are logical variables rather than locations in memory. The value is passed between iterations, not an address. Since logical variables are "write-once," the updated value, a new logical variable, is passed each time. Stylistically, we use variable names with the suffix 1, for example, Ti and Il, to indicate updated values.

The computation terminates when the counter `I` equals `N.` The rule for `f actorial/4` in Program 8.3 no longer applies, and the fact succeeds. With this successful reduction, the value of the factorial is returned. This happens as a result of the unification with the accumulator in the base clause. Note that the logical variable representing the solution, the final argument of `f actorial/4,` had to be carried throughout the whole computation to be set on the final call of `factorial.` This passing of values in arguments is characteristic of Prolog programs and might seem strange to the newcomer.

Program 8.3 exactly mirrors the while loop for factorial given in Figure 8.1. Another iterative version of `factorial` can be written by counting down from N to 0, rather than up from O to N. The basic program structure remains the same and is given as Program 8.4. There is an initialization call that sets the value of the accumulator, and recursive and base clauses implementing the while loop.

<!-- page 198 -->
Program 8.4 is marginally more efficient than Program 8.3. In general, the fewer arguments a procedure has, the more readable it becomes, and the faster it runs. between(I,J,K) -

K is an integer between the integers I and J inclusive. betwoen(I,J,I) - I < J. between(I,J,K)

I < J, Il is 1+1, between(I1,J,K). Program 8.5

Generating a range of integers

sumlist(Is,Sum)

Sum is the sum of the list of integers Is. sunilist([IIIs],Sum)

sun1list(Is,IsSum), Sum is I+IsSuni. sumlist([ ],O). Program 8.6a Summing a list of integers

sumlist(Is,Sum) -

Sum

is the sum of the list of integers Is. sumlist(Is,Sum) - sumlist(Is,O,Suin). sujnlist([IIIs] ,Temp,Suin) -

Tempi is Temp+I, sumlist(Is,Templ,Sum). suinlist([ ] ,Suxn,Suni). Program 8.6b

Iterative version of summing a list of integers using an accumulator

A useful iterative predicate is `between (I , .3 , K),` which is true if K is an integer between I and J inclusive. lt can be used to generate nondeterministically integer values within a range (see Program 8.5). This is useful in generate-and-test programs, explained in Section 14.1, and in failuredriven loops, explained in Section 12.5.

<!-- page 199 -->
Iterative programs can be written for calculations over lists of integers as well. Consider the relation `sumlist(IntegerList,Sum),` where Sum is the sum of the integers in the list `IntegerList.` We present two programs for the relation. Program 8.6a is a recursive formulation. To sum a list of integers, sum the tail, and then add the head. Program 8.6b uses an accumulator to compute the progressive sum precisely as Program 8.3 for `factorial` uses an accumulator to compute a progressive product. An auxiliary predicate, sunilist/3, is introduced with an extra argument for the accumulator, whose starting value, O, is set in the initial call to inner_product (Xs, Ys, Value) -

Value is the inner product of the vectors

represented by the lists of integers Xs and Ys.

```prolog
inner_product ([XI Xs] , [Y
                      I Ys] ,IP) -
    inner_product(Xs,Ys,IP1), IP is X*Y+IP1.
inner_product([ ],[ ],O).
```

Program 8.7a Computing inner products of vectors

inner_product (Xs, Ys,Value) -

Value is the limer product of the vectors

represented by the lists of integers Xs and Ys.

```prolog
inner_product (XS,YS, IP) - inner_product(Xs ,Ys,O, IP)
inner_product([XIXs] , [Y lYs] ,Temp, IP) -
    Tempi is X*Y+Temp, inner_product(Xs,Ys,Templ ,IP).
inner_product([ ],[ ],IP,IP).
```

Program 8.7b Computing inner products of vectors iteratively

`sumlist/3.` The sum is passed out in the final call by unification with the base fact. The only difference between Program 8.6b and the iterative versions of `factorial` is that the recursive structure of the list rather than a counter is used to control the iteration.

Let us consider another example. The inner product of two vectors

is the sum X1

Y1 +

+ X

Y. If we represent vectors as lists, it is straightforward to write a program for the relation `inner_` `product (Xs,Ys,IP),` where IP is the inner product of Xs and `Ys.` Programs 8.7a and 8.7b are recursive and iterative versions, respectively. The iterative version of `inner_product` bears the same relation to the recursive `inner_product` that Program 8.6b for `suinlist` bears to Program 8.6a.

Both Programs 8.7a and 8.7b are correct for goals `inner_product (Xs,` Ys , Zs), where `Xs` and `Ys` are lists of integers of the same length. There is a built-in check that the vectors are of the same length. The programs fail if Xs and Ys are of different lengths.

<!-- page 200 -->
The similarity of the relations between Programs 8.6a and 8.6b, and Programs 8.7a and 8.7b, suggests that one may be automatically transformed to the other. The transformation of recursive programs to equivarea(Chain,A rea)

Area is the area of the polygon enclosed by the list of points

Chain, where the coordinates of each point are represented by

a pair (X,Y) of integers.

```prolog
area( [Tuple] 0).
area([(Xl,Yl),(X2,Y2)IXYs],Area)
    area([(X2,Y2)IXYs] Areal),
    Area is (Xl*Y2-Yl*X2)/2 + Areal.
```

Program 8.8

Computing the area of polygons

aient iterative programs is an interesting research question. Certainly it can be done for the simple examples shown here.

The sophistication of a Prolog program depends on the underlying logical relation it axiomatizes. Here is a very elegant example of a simple Prolog program solving a complicated problem.

Consider the following problem: Given a closed planar polygon chain {P1,P2.....P}, compute the area of the enclosed polygon and the orientation of the chain. The area is computed by the line integral 1/2 Jxdy-ydx, where the integral is over the polygon chain.

The solution is given in Program 8.8, which defines the relation `area(Chain,Area). Chain` is given as a list of tuples, for example, [(4,6),(4,2), (0,8), (4,6)]. The magnitude of `Area` is the area of the polygon bounded by the chain. The sign of `Area` is positive if the orientation of the polygon is counterclockwise, and negative if it is clockwise.

The query `area([(4,6),(4,2),(O,8),(4,6)],Area)?` has the solution `Area = -8.` The polygon gains opposite orientation by reversing the order of the tuples. The solution of the query `area([(4,6),(0,8),`

```prolog
(4,2) ,(4,6)] ,Area)? is Area = 8.
```

The program shown is not iterative. Converting it to be iterative is the subject of Exercise (y) at the end of the section.

<!-- page 201 -->
An iterative program can be written to find the maximum of a list of integers. The relation scheme is `maxlist(Xs,Max),` and the program is given as Program 8.9. An auxiliary predicate `maxlist(Xs,X,Max)` is used for the relation that `Max` is the maximum of X and the elements in the list Xs. The second argument of `maxlist/3` is initialized to be the first maxlist(Xs,N) -

N is the maximum of the list of integers Xs.

```prolog
maxlist([XIXs3,M) - maxlist(Xs,X,M).
rnaxlist([XIXs],Y,M) - maximuin(X,Y,Y1), rnaxlist(Xs,Y1,M).
maxlist([ ],M,M).
maximuni(X,Y,Y) - X
                     Y.
maximum(X,Y,X) - X
                   >
                     Y.
```

Program 8.9

Finding the maximum of a list of integers

length(Xs,N) -

Xs is a list of length N.

```prolog
length([XIXs],N) - N
                    > 0, Ni is N-1, length(Xs,N1).
length([ 1,0).
```

Program 8.10

Checking the length of a list

element of the list. Note that the maximum of an empty list is not defined by this program.

The standard recursive program for finding the maximum of a list of integers constitutes a slightly different algorithm. The recursive formulation finds the maximum of the tail of the list and compares it to the head of the list to find the maximum element. In contrast, Program 8.9 keeps track of the rurming maximum as the list is traversed.

Program 3.17 for finding the length of a list is interesting, affording several ways of translating a logic program into Prolog, each of which has its separate features. One possibility is Program 8.10, which is iterative. Queries length (Xs , N)? are handled correctly if N is a natural number, testing if the length of a list is N, generating a list of N uninstantiated elements, or failing. The program is unsuitable, however, for finding the length of a list with a call such as length([1,2,3 ,N)?. This query generates an error.

<!-- page 202 -->
The length of a list can be found using Program 8.11. This program cannot be used, however, to generate a list of N elements. In contrast to Program 8.10, the computation does not terminate if the first argument is an incomplete list. Different programs for length are needed for the different uses. iength(Xs,N)

N is the length of the list Xs.

```prolog
length([XIXs],N) - length(Xs,N1), N is Ni-4-i.
length([ 1,0)
```

Program 8.11

Finding the length of a list

range(M,N,Ns) -

Ns is the list of integers between M and N inclusive.

```prolog
range(M,N,[MINs])
                    M < N, Ml is M+1, range(M1,N,Ns).
range(N,N, [N]).
```

Program 8.12

Generating a list of integers in a given range

Similar considerations about the intended use of a program occur when trying to define the relation `range(M,N,Ns),` where `Ns` is the list of integers between N and `N` inclusive. Program 8.12 has a specific use: generating a list of numbers in a desired range. The program is totally correct over all goals `rarige(M,N,Ns)` where `M` and `N` are instantiated. The program cannot be used, however, to find the upper and lower limits of a range of integers, because of the test `M < N.` Removing this test would allow the program to answer a query `range(M,N, [1,2,3])?,` but then it would not terminate for the intended use, solving queries such as

```prolog
range (1,3, Ns) ?.
```

8.3.1

Exercises for Section 8.3

Write an iterative version for

```prolog
                               triangle(N,T), posed as Exer-
cise 8.2(i).
```

Write an iterative version for `power(X,N,V),` posed as Exercise

8.2(u).

Rewrite Program 8.5 so that the successive integers are generated

in descending order.

Write an iterative program for the relation `timeslist (Integer-`

`List,Product)` computing the product of a list of integers, anal-

<!-- page 203 -->
ogous to Program 8.6b for `sumlist.`

(y)

Rewrite Program 8.8 for finding the area enclosed by a polygon so

that it is iterative.

Write a program to find the minimum of a list of integers.

Rewrite Program 8.11 for finding the length of a list so that it is

iterative. (Hint: Use a counter, as in Program 8.3.)

Rewrite Program 8.12 so that the range of integers is built bottom-

up rather than top-down.

**8.4 Background**

The examples given in this chapter are small and do not especially exploit Prolog's features. Algorithms that are fundamentally recursive are more interesting in Prolog. A good example of such a program is the Fast Fourier Transform, for which efficient versions have been written in Prolog.

A good place for reading about Huifman encoding trees for Exercise 8.2(iv) is Abelson and Sussman (1985).

A program for transforming recursive programs to iterative ones, which handles the examples in the text, is described in Bloch (1984).

Program 8.8, computing the area of a polygon, was shown to us by Martin Nils son.
