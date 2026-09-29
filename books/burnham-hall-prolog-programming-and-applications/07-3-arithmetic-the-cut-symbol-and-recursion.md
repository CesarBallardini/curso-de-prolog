# 3 Arithmetic, the "Cut" Symbol, and Recursion

<!-- page 44 -->
In this chapter we shall discuss three important features of the Prolog language, none of which merits a whole chapter to itself. Although we have included these in the same chapter, we would not wish to give the reader the impression that these language features are in any way dependent on one another - it is simply convenient to introduce them all at the same stage of learning, and as we shall see the three features may be combined into complex program statements.

## 3.1 Arithmetic

It should be made clear from the outset that Prolog was not a language designed for mathematical applications, and there are other languages (such as APL, Q'NIAL and ALGOL) which are far better for specialist applications. However more recent implementations of Prolog do offer standard facilities for manipulating real numbers (see appendixes I and 2). Edinburgh DEC-IO Prolog supports only integer arithmetic, and the reader should bear that in mind when considering the following material. Furthermore, the other versions of Prolog on which this book is based (see the Preface) have special function sets for integer arithmetic but the operations described in the following sections are applied to real numbers. We recommend that readers familiarise themselves with the arithmetic facilities on their particular version of Prolog. The examples that follow are based on the DEC-lO integer functions, but can easily be applied to other Prolog systems.

*3.1.1 The is operator*

This operator is necessary for the use of arithmetic beyond the most simple level. In many ways it can be seen to take the place of the =sign in standard arithmetic. This is necessary because in Prolog the =sign is used for making a logical check, not for assigning a value. Thus the goals

**man =man**

3=3

<!-- page 45 -->
will always succeed whereas W. D. Burnham et al., *Prolog Programming and Applications* © W. D. Burnham and A. R. Hall 1985

man = woman

3=4

will always fail.

The expression

**AisB-l**

has the effect of instantiating the value of variable A to one less than that of B. Similarly, the statement

instantiates A to the product of B and C and is equivalent to the algebraic statement

let A = Bx C

You will see more examples of the is operator later in the chapter.

*3.1.2 Standard arithmetical operators*

These are the same operators that are to be found in most computer languages

+ addition

- subtraction

*** multiplication**

/ division

Examples of the use of each are given below.

*Addition* The + operator carries out integer addition. Thus the expression

Xis3+6

has the effect of instantiating X to the value of 9. Similarly the expression

XisY+ Z.

causes X to be instantiated to the sum ofY and Z (assuming that Y and Z are instantiated to integer values or expressions). Finally, the expression

<!-- page 46 -->
XisY+Z+2 has the effect of instantiating X to the sum of Y, Z and 2 (assuming that Yand Z are instantiated to integer values or expressions).

*Subtraction* If you have understood how the addition operator works then you will have no difficulty in understanding how the subtraction operator functions. The expression

Xis5-3

causes X to be instantiated to 2. The expression

X is Y +Z - 5.

results in X being instantiated to the sum of Y and Z less 5 (assuming that Y and Z are instantiated to integer values or expressions).

*Multiplication* The * operator causes multiplication to be carried out. Thus

results in X being instantiated to 6. The expression

**Xis Y * 3.**

results in X being instantiated to three times the value of y,

*Division* The / operator is used to carry out *integer* division. Thus the expressions

X is 15/5 and X is 16/5

will both result in X being instantiated to 3. However, you will notice that in the second expression the division is not exact, there is a remainder of one. In order to access the remainder of an inexact division the mod operator is used. Thus the pair of expressions

X is 16/5, Y is 16 mod S.

will result in X being instantiated to 3 and Y to the remainder, 1.

<!-- page 47 -->
*Using more than one operator* We have already seen an example of addition and subtraction being used in the same expression, but all the operators can be used together quite easily. Sometimes brackets are necessary to make the sense of the expression clear, although in general * and *I* take precedence over +and -. Thus the expression

will be evaluated by first multiplying 2 and 3 together and then subtracting 4 from the product (the other obvious possibility would be to multiply 2 by the difference of 3 and 4).

It is recommended that you get into the habit of using brackets for compound expressions of this kind, if only because you can follow your own coding with complete clarity. For example, the proposition that the value of X is the product of A and B divided by C and added to D is best written as

X is «A*B) Ie) + D.

*3.1.3 Comparing integers and integer expressions*

*Equality* The system operator =:= is used to test equality. For example, the goal

X+Y -Z=:=3.

will succeed providing that the instantiated values of X, Y and Z cause the expression to evaluate to 3 (for example, X = I, Y = 4, Z = 2).

*Inequality* The operator *=1=* succeeds if integer expressions are not equal, thus the goal

*X=I=3+S.*

will succeed providing that X does not have the value B.

*Comparative size of expressions* If we wish to test whether an integer or integer expression is greater than another, then we may use the familiar mathematical symbol for 'greatter than",>. Thus the goal

6>X.

will succeed providing that X takes an instantiated value of 5 or less. Furthermore, the symbol>= represents "greater than or equal to". Thus the goals

**7 >=6. and 7 >=7.**

<!-- page 48 -->
will both succeed.

Similarly, there are provisions made for the tests "less than" and 'less than or equal to", the respective symbols being < and =<.

## 3.2 Exercise 6

(i) Write a Prolog program to output the result of dividing one integer by

another in the form X remainder Y. (ii) Write a Prolog program to calculate the average value of two numbers.

## 3.3 The "cut" symbol

This is represented in Prolog by the exclamation mark! and is in fact like a predicate that is built into the language. It is unlike other predicates you have encountered in that it is represented by a symbol rather than a word or or expression and that it has no arguments. The effect of the cut is to restrict the working of the search mechanism in Prolog and its action is somewhat like passing through a one-way street in a car; you go through it one way to achieve a goal but you cannot return in the reverse direction.

As you will have seen from reading chapter 2, Prolog attempts to prove the success of goals (generate solutions) in a particular manner which frequently involves, particularly when sub-goals need to be satisfied, the backtracking process. When the cut is included as part of a goal defmition it inhibits the 'route' that Prolog takes to satisfy a goal because although it is possible to pass the cut to try to satisfy a goal, it is not possible to pass it on backtracking, hence the one-way street analogy.

Let us look at a simple example of the cutin use. Consider the following knowledge base

parent Gohn).

parent (fred).

parent Gean).

male Gohn).

male (fred).

female Gean).

```prolog
father (X) :- parent (X), male (X), !.
```

If you look at the rule defining father you will see that the cut symbol appears as a sub-goa1. Were the cut not present and we asked the question

```prolog
?- father (X).
```

<!-- page 49 -->
the solutions X = john and X = fred would be returned; the second in response to a semi-colon prompt.

However with the cut included in the defmition of father only one answer will be generated, X =john, and the ; prompt will elicit the response no. This is because, first Prolog will evaluate the sub-goals parent and male - instantiating X to john in both cases - and thereafter it cannot pass backwards past the cut to resatisfy for another value (which would normally result in X being instantiated to fred) and therefore cannot generate a second solution.

*3.3.1 Tree structure with "cut"*

As we have seen, the cut is used to prevent backtracking. It may therefore be thought of as pruning the search tree that would normally be generated as a result of backtracking. Suppose we return to the knowledge base given in section 2.6 andadd the rule

```prolog
find _a_supervisor (X, Y) :- supervises (X, Y), !.
```

which is saying "find one supervisor X who supervises Y". If we now ask the question

then the search tree will be as shown. Notice how the cut prevents the search returning to node 3 and hence effectively prunes the tree that would be produced were the cut not present (the pruned portion is shown by broken lines).

```prolog
              ?- find _a_ supervisor (X,V).
   ,....-_____...J/!""'~_m,
                         I
                                       I
                         I
                                       I
                         I
                                       I
                        *
                                       *
                        / \
                                      I
                                        \
                       I
                         \
                                      I
                                        \
                      I
                          \
                                     /
                                         \
                      I
                                    I
                                         \
                     *
                           *
                                   *
                                         *
                     I
                            I
                                    I
                                          I
                     I
                            I
                                    I
                                          I
                     I
                            I
                                    I
                                          I
                     I
                            I
                                    I
                                          I
*
      *
                     *
                           *
                                    •
```

<!-- page 50 -->
At this stage we have introduced the cut symbol and applied it to a simple example in order to demonstrate the concept of using the cut to restrict backtracking. In fact the value of the cut becomes more apparent when applied to complex program structures and in later chaptersthere will be more examples of the cut in use.

## 3.4 Exercise 7

parent (john).

parent (fred).

parent (jean).

male (john).

male (fred).

female (jean).

```prolog
father (X) :- parent (X), male (X), !.
mother (X) :- parent (X),!, female (X).
```

Using the above knowledge base, what effect will the inclusion of the cut symbol have on the way in which the questions

```prolog
?- father (X). and ?- mother (X).
```

are answered?

## 3.5 Recursion in Prolog

One of the more powerful techniques in programming is that of recursion, wherein we define a procedure that can 'go back into itself until a programming task is completed. For those of you not familiar with advanced programming terminology the technique of iteration utilises the 'if, then, else' structure for directing program logic whereas when a rule or process features a restatement of that rule or process as part of its definition it is said to be recursive - a lighthearted version of this appears in the spoof definition "recursion - (see recursion)".

The structure and syntax of Prolog, as we shall see, lend themselves particularly well to the elegant and concise statement of recursive procedures and rules. Once mastered, the technique of programming recursively extends the problem solving power of the language.

*3.5.1 Defining a procedure in terms of itself*

As we have already said, the essence of generating a successful recursion in Prolog is the ability to define a predicate in terms of itself. However, certain limitations, all of which are quite logical, have to be kept in mind. Let us start with a simple example of a recursive definition: the problem of defining the ancestry of a human or animal. Since the question of descent is so important to breeders of thoroughbred racehorses, we will choose that as our example.

<!-- page 51 -->
Taking the 1984 Derby winner, Secreto, as our subject we have the following blood line

Secreto sired by Northern Dancer sired by Neartic sired by Nearco

sired by Nasrullah.

In order to use a Prolog program to give the ancestry of Secreto we might proceed in the most obvious (that is, non-recursive) manner and program as follows

sire (secreto, northern_dancer).

grandsire (secreto, neartic).

great..,grandsire (secreto, nearco).

greaCgreaCgrandsire (secreto, nasrullah).

```prolog
ancestor (X, Y) :- sire (X, V).
ancestor (X, Y) :- grandsire (X, Y).
ancestor (X, Y) :- greaCgrandsire (X, V).
ancestor (X, Y) :- great..,great..,grandsire (X, Y).
```

and when we ask the question

```prolog
?- ancestor (secreto, V).
```

we obtain the correct solutions, northern_dancer, neartic, nearco and nasrullah.

Now, although this method does work (incidentally you may be able to think of several similar ways of obtaining the same solution), it does have several disadvantages, as follows.

(1) It is a rather cumbersome method which you can clearly see would involve

the programming of vast numbers of similar assertions and rules if the

system were to accommodate a substantial number of horses.

(2) Ifwe wished to extend it to take in another generation, an assertion

of the rather tedious great..great..,great..grandfather format would be

needed, as would another rule establishing the relation as an ancestor.

(3) If we introduce Secreto's half brother, Nijinsky, to the system we would

have to reprogram the system despite the fact that all male ancestors belong

to both Secreto and Nijinsky.

It would clearly be much better if we could accomplish the whole thing by simply asserting the relationship sire and using our knowledge to defme an ancestor of the sire as also being an ancestor of the son. We can do precisely that by using recursion as follows

sire (secreto, northern_dancer).

sire (nijinsky, northern_dancer).

<!-- page 52 -->
sire (northern_dancer, neartic).

sire (neartic, nearco).

sire (nearco, nasrullah).

ancestor (X, Y) :-sire (X, V).

ancestor (X, Y) :-sire (X, Z), ancestor (Z, V).

The first rule in the knowledge base establishes the essential relationship that a sire is an ancestor. "If the sire of X is Y then Y is the ancestor of X". The second rule introduces recursion whereby the ancestor of the sire is also the ancestor of the son. "If the sire of X is Z and the ancestor of Z is Y then Y is the ancestor of X". Work out the above rules and satisfy yourself that they are logically consistent.

You can, we hope, see that it is a much more convenient and flexible format than the first example and note that it allows us to introduce Nijinsky to the knowledge base by programming the additional assertion

sire (nijinsky, northern_dancer).

To demonstrate how the example program would work, here is a dialogue between the system and the user.

*User*

ancestor (secreto, V).

ancestor (nijinsky, V).

**... (session ends)**

*Prolog*

1-

Y = northern_dancer

Y = neartic

Y = nearco

Y = nasrullah

no

1-

**Y =northern_dancer**

*3.5.2 How does it work?*

Using the same example, this is what happenswhen the user asks the program about the ancestors of secreto.

(l) The first time through, X is instantiated by the question to secreto, and a match is made on the fust rule in the knowledge base. There is an assertion sire(secreto, northern_dancer) in the knowledge base and therefore Y can be instantiated to northern_dancer without the second rule being used.

<!-- page 53 -->
(2) When the semi-colon is typed to seek another solution, the first rule alone cannot provide the solution because there is only one assertion that gives information about the sire of secreto in the knowledge base, and that soluion has already been given. Therefore, the second rule is used, with X instantiated to secreto as before. The assertion sire (secreto, northern_dancer) causes Z to be instantiated to northern_dancer in the body of the second rule. The second sub-goal in the body of the second rule therefore becomes

ancestor (northern_dancer, V).

To evaluate this sub-goal Prolog goes back to the first rule, which in turn causes the goal

sire (northern_dancer, V).

to be attempted. This sub-goal can match with the assertion

sire (northern_dancer, neartic).

which causes Y to become instantiated to neartic. The solution is therefore generated (Y =neartic). The other solutions (Y =nearco) and (Y =nasrullah) are generated in the same manner.

*3.5.3 Recursion in arithmetic*

It can be particularly useful to program recursive routines for arithmetic. As a simple example take the case of calculating the value of a factorial of a number. (If you are unfamiliar with the definition of the factorial of a number, it is the product of the number multiplied by all the numbers below it, and applies to positive integers only. Thus, the factorial of 5 is 120, that is

5 x 4 x 3 x 2 x 1 = 120

By definition the factorial of zero is 1.) Here is the routine to perform the calculation

fac 0',1).

```prolog
fac (X, Xf) :- Y is X-I,
            fac (Y, Yf),
            Xfis Yf * X.
```

The routine relies on the fact that the factorial of any number can be derived by multiplying that number by the factorial of the number immediately below it. Reverting to the first example for Clarity - the factorial of five is derived by multiplying 5 by the factorial of 4.

<!-- page 54 -->
The first statement, fac (t), 1), is known as the 'boundary condition' and it is necessary for two reasons. Firstly to allow the factorial of ~ to be calculated, but secondly, and more importantly, to prevent the routine recursing into negative numbers and continuing indefinitely.

The main part of the rule could be stated as follows "The factorial Xf of an integer X is calculated as follows: let Y =X-I and let Yfbe the factorial of Y. The factorial of Xf is then the product of X and Yf".

As you can see, the routine will proceed recursively by reducing the value of the number to be operated on until the boundary condition f/J is reached. The factorial of f/J is given in the first assertion which then allows the factorial value required to be calculated. As you can see, the definition of fac actually allows for a multiple solution to be generated for the factorial of f/J (that is, by using both the fac clauses). To make the routine more elegant we could introduce the cut in order to tell Prolog not to use any other assertions or rules of the form fac(~, 1) once it has used our boundary condition assertion. The modified definition now becomes

fac (~, 1) :-!.

```prolog
fac (X, Xf) :- Y is X-I,
           fac (Y, Yf),
           Xfis Yf * X.
```

Chapter 4 and subsequent chapters contain other examples of recursion.

## 3.6 Exercise 8

(i) Given the following knowledge base, add the necessary rules in order to

allow ancestors to be defined, using a recursive definition.

parents (jim, john, ellen).

parents (john, bill, doris).

parents (ellen,jack, mavis).

parents (bill,joe, flossie).

parents (doris, bert, mabel).

parents (jack, crispin, samantha).

parents (mavis,jock, alison).

All the above assertions are of the form parents (X, Y, Z) and read "the

parents of X are Y and Z". (ii) The mathematical expression NcR is derived as follows; divide the

factorial of N by the product of the factorial of R and the factorial of

(N-R). Program a procedure to calculate NcR. (iii) Write a program to calculate the value of an integer X to the power of an

<!-- page 55 -->
integer N.

## 3.7 Solutions to exercises

*Exercise 6*

(i) There are two ways of approaching this, depending on whether the arithmetic is carried out on an integer basis (DEC-I0) or a real number basis (Quintus Prolog, Prolog l). *For integer based arithmetic:* Use A and B to represent the integers (A to be divided by B); X is to be the quotient and Y the remainder

division (A, B, X, Y) :- X is A/B,

Y is A mod B.

If you were to question the system about, for example, the division of 17 by 5, it would be a good idea to put the question like this

division (17,5, Quotient, Remainder).

which would generate the solution

Quotient = 3

Remainder = 2

*For real number based arithmetic*

division (A, B, X, Y) :- X is A//B,

VisA mod B.

Note the / symbol which is used to declare integer division. (ii)

average (X, Y, A) :- A is (X + Y)/2

(Note that the integer based system - that is, DEC-lO - will produce a different result in some cases than will the real number based systems. For example

?- average (3, 4, A).

<!-- page 56 -->
will produce A = 3 (DEC-lO) or A =3.5 (Quintus, Prolog-I) *Exercise 7*

In the definition of the rule for father, the position of the cut symbol will allow one solution to be generated, X = john. After that, no further solutions can be generated by backtracking and a semi-colon prompt (which without the cut would result in X = fred being generated) will elicit the answer no.

The cut in the rule defining mother prevents any solutions being generated. This is because Prolog first attempts to prove the sub-goal parent, and instantiates X to john. The cut then succeeds and the third sub-goal female (X) then fails because X is instantiated to john. However, because of the cut no attempt can be made to backtrack to parent (X) and hence the goal mother (X) fails.

*Exercise 8*

(i) In this example it is necessary to define an ancestor as a parent or the

ancestor of a parent. However, no predicate for parent exists (although

there is one for parents), therefore we must first defme

```prolog
parent (X, Y) :- parents (X, Y, J.
parent (X, Y) :- parents (X, _, Y).
```

Now for the recursive rule to define ancestor

```prolog
ancestor (X, Y) :- parent (X, Y).
ancestor (X, Y) :- parent (X, Z), ancestor (Z, Y).
```

(ii) First, define the rule for factorial as before

```prolog
factorial 0', 1) :- !.
factorial (N, Nf) :- R is N-
                        1,
                factorial (R, Rf),
                NfisN*Rf.
```

Now we can use the above definition to build the more complex rules

```prolog
combine (N, R, C) :- factorial (N, Nf),
                 factorial (R, Rf),
                 XisN -R,
                 factorial (X, Xf),
                 C is Nfl (Xf*Rf).
```

<!-- page 57 -->
(iii) exp (X, _, 1) :- !. exp (X, N, E) :- R is N-

1,

exp (X, R, Er),

E is Er*X.
