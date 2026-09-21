# 23 An Equation Solver

<!-- page 480 -->
A very natural area for Prolog applications is symbolic manipulation. For example, a Prolog program for symbolic differentiation, a typical symbol manipulation task, is just the rules of differentiation in different syntax, as shown in Program 3.30.

In this chapter, we present a program for solving symbolic equations. It is a simplification of PRESS (PRolog Equation Solving System), developed in the mathematical reasoning group of the Department of Artificial Intelligence at the University of Edinburgh. PRESS performs at the level of a mathematics student ni her final year of high school.

The first section gives an overview of equation solving with some example solutions. The remaining four sections cover the four major equationsolving methods implemented in the equation solver.

**23.1 An Overview of Equation Solving**

The task of equation solving can be described syntactically. Given an equation Lhs = Rhs in an unknown X, transform the equation into an equivalent equation X = Rhsl, where Rhsl does not contain X. This final equation is the solution. Two equations are equivalent if one is transformed into the other by a finite number of applications of the axioms and rules of algebra.

<!-- page 481 -->
Successful mathematics students do not solve equations by blindly applying axioms of algebra. Instead they learn, develop, and use various methods and strategies. Our equation solver, modeling this behavior, is accordingly a collection of methods to be applied to an equation to be

```prolog
cos(x)
        (1 2 sin(x)) = O
x2-3x+2=O
```

(lii)

22x - 5

2x+ + 16 = O Figure 23.1

Test equations

solved. Each method transforms the equation by applying identities of algebra expressed as rewrite rules. The methods can and do take widely different forms. They can be a collection of rules for solving the class of equations to which the method is applicable, or algorithms implementing a decision procedure.

Abstractly, a method has two parts: a condition testing whether the method is applicable, and the application of the method itself.

The type of equations our program can handle are indicated by the three examples [n Figure 23.1. They consist of algebraic functions of the unknown, that is +, -, *, /, and exponentiation to an integer power, and also trigonometric and exponential functions. The unknown is x in all three equations.

We briefly show how each equation is solved.

The first step in solving equation (i) in Figure 23.1 is factorization. The problem to be solved is reduced to solving cos(x) = O and i - 2 sin(x) = O. A solution to either of these equations is a solution to the original equation.

Both the equations cos(x) = O and 1 - 2 . sin(x) = O are solved by making x the subject of the equation. This is possible because x occurs once in each equation.

The solution to cos(x) = O is arccos(0). The solution of 1 - 2

sin(x) = O takes the following steps: i - 2

sin(x) = O,

2 . sín(x) = 1,

sin(x) = 1/2,

<!-- page 482 -->
x = arcsin(1/2). In general, equations with a single occurrence of the unknown can be solved by an algorithmic method called isolation. The method repeatedly applies an appropriate inverse function to both sides of the equation until the single occurrence of the unknown is isolated on the left-hand side of the equation. Isolation solves i - 2 sin(x) = O by producing the preceding sequence of equations.

Equation (ii) in Figure 23.1, x2 - 3 x + 2 = O, is a quadratic equation in x. We all learn in high school a formula for solving quadratic equations. The discriminant, b2 4 a

c, is calculated, in this case (_3)2

4 . i

2, which equals 1, and two solutions are given: x = ((-3) + \/T)/2, which equals 2, and x = ((-3) - fÏ)/2, which equals 1.

The key to solving equation (iii) fri Figure 23.1 is to realize that the equation is really a quadratic equation in 2x. The equation 22'x - 5 2i+16=Ocanberewrittenas(2x)2_5.2.2x+16=O.Thiscanbe solved for 2, giving two solutions of the form 2X =Rhs, where Rhs is free of x. Each of these equations are solved for x to give solutions to equation (iii).

PRESS was tested on equations taken from British A-level examinations in mathematics. It seems that examiners liked posing questions such as equation (in), which involved the student's manipulating logarithmic, exponential, or other transcendental functions into fortiis where they could be solved as polynomials A method called homogenization evolved to solve equations of these types.

The aim of homogenization is to transform the equation into a polynomial in some term containing the unknown. (We simplify the more general homogenization of PRESS for didactic purposes.) The method consists of four steps, which we illustrate for equation (ili). The equation is first parsed and all maximal nonpolynomial terms containing the unknown are collected with duplicates removed. This set is called the offenders set. In the example, it is

22), 2x+1}. The second step is finding a term, known as the reduced term. The result of homogenization is a polynomial equation in the reduced term. The reduced term in our example is 2V. The third step of homogenization is finding rewrite rules that express each of the elements of the offenders set as a polynomial in the reduced term. Finding such a set guarantees that homogenization will succeed. In our example the rewrite rules are 22x

(2x)2 and 2x+1 = 2 . 2X Finally, the rewrite rules are applied to produce the polynomial equation.

<!-- page 483 -->
We complete this section with a brief overview of the equation solver. The basic predicate is `solve_equation(Equation,X,Solution).` The relation is true if `Solution` is a solution to `Equation` in the unknown X. The complete code appears as Program 23.1. solve_equation (Equation, Unknown,Solution) - Solution is a solution to the equation Equation in the unknown Unknown.

```prolog
solve_equation(A*B=O ,X ,Solution) -
    factorize(A*B,X,Factors\[ J),
    remove_duplicates (Factors ,Factorsl),
    solve_factors(Factorsl ,X,Solution).
solve_equation(Equation,X,Solution)
    single_occurrânce (X ,Equation),
    position(X,Equation, [SidelPosition]),
    maneuver_sides(Side ,Equation,Equationl),
    isolate (Position,Equationl ,Solution).
solve_equation(Lhs=Rhs ,X Solution)
    polynomial(Lhs,X),
    polynomial (Rhs , X),
    polynomial_normal_form (Lhs-Rhs , X, PolyForm),
    solve_polynomial_equation(PolyForm,X,Solution).
solve_equation (Equation,X ,Solution) -
    homogenize (Equation,X,Equationl ,X1),
    solve_equation(Equationl Xl ,Solutionl),
    solve_equation(Solutionl ,X,Solution).
```

The factorization method factorize (Expression,Subterm,Factors) - Factors is a difference-list consisting of the factors of the multiplicative term Expression that contain the Subterm.

```prolog
factorize(A*B,X,Factors\Rest) - !
                                ,
                                  factorize(A,X,Factors\Factorsl),
factorize(B,X,Factorsl\Rest).
factorize(C,X, [ClFactors]\Factors) -
    subterm(X,C),
                  !.
factorize(C,X ,Factors\Factors).
```

solve_factors (Factors, Unknown,Solution) - Solution is a solution of the equation Factor = O in the Unknown for some Factor in the list of Factors.

```prolog
solve_factors([FactorlFactors] ,X,Solution) -
    solve_equation (Factor=O ,X,Solution).
solve_factors([FactortFactors] ,X,Solution)
    solve_f actors (Factors ,X,Solution).
```

<!-- page 484 -->
Program 23.1 A program for solving equations The isolation method maneuver_sides(i,Lhs = Rhs,Lhs

**Rhs) -**

maneuver_sides(2,Lhs

Rhs,Rhs

**Lhs) -**

**isolate([NlPosition],Equation,IsolatedEquation) -**

```prolog
isolax(N,Equation,Equationl),
isolate(Positíon,Equationi,IsolatedEquatïon).
```

isolate([ 1 ,Equation,Equatiori). Axioms for isolation

'h Unary minus

'I, Addition

X Addition

X Subtraction

X Subtraction

**'I Multiplication**

X Multiplication isolax(1,-Lhs = Rhs,Lhs

-Rhs). isolax(i,Terml+Term2 = Rhs,Termi = Rhs-Term2). isolax(2,Termi+Term2

Rhs,Term2

Rhs-Teruil). isolax(1,Terml-Term2

Rhs,Tenni

Rhs+Term2). isolax(2,Terml-Term2

Rhs,Term2

Terml-Rhs). isolax(1,Terml*Term2

Rhs,Terml

Rhs/Term2)

Term2

O. isolax(2,Termi'Term2

Rbs,Term2

Rhs/Terml) -

Tenni

O. isolax(1,TermllTerm2 = Rhs,Terml = RhsI(-Term2)).

X Exponentiation isolax(2,TerrniîTerm2

Rhs,Term2

```prolog
                             log(base(Terml),Rhs)).
'h Exponentiation
```

**isolax(l,sin(U) = V,U = arcsin(V)).**

X Sine isolax(1,sin(U)

V,U

Tr-arcsin(V)).

X Sine isolax(1,cos(U)

V,IJ = arccos(V)).

'h Cosine isolax(i,cos(U)

V,tJ = -arccos(V)).

X Cosine The polynomial method polynomial(Term,X)

See Program 11.4. polynomiaL normal_form (Expression, Term ,PolyNormalForrn)

PolyNormalForm is the polynomial normal form of

Expression, which is a polynomial ¡n Term. polynomial_normal_f orm(Polynomial ,X,NormalForm) -

polynomial_f orm(Polynomial , X, PolyForm),

```prolog
remove_zero_terms(PolyForm,NormalForm)
```

polynomial_form(X,X, C(i,i)]). polynomial_form(XIN,X,[(i,N)]). polynomial_f orm(Terml+Term2 ,X,PolyForin) -

polynomial_f orm(Termi ,X ,PolyForml),

polynomial_f ors (Term2,X,PolyForm2),

add_polynomials (PolyFormi , PolyForm2 , PolyForm). Program 23.1

<!-- page 485 -->
(Continued) polynomial_f orm(Terml-Term2 ,X,PolyForm) polynomial_f orm(Termt ,X,PolyForml), polynomial_form (Term2 , X, PolyForm2), subtract_polynomials (PolyFormi , PolyForm2 , PolyForm). polynomial_form(Terml*Term2,X PolyForm) polynomial_f orn (Termi ,X,PolyForml), polynomial_f orni(Term2 ,X,PolyForm2), multiply_polynomials(PolyForml ,PolyForm2,PolyForm). polynomial_form(TermtN,X,PolyForm) polynomial_f orm(Term,X ,PolyForml), binomial (PolyFormi , N, PolyForm). polynomial_f orin(Tern,X, [(Term,O)]) free_of (X,Term), remove_zero_terms([(O,N)IPoly] Polyl) - !, remove_zero_terms(Poly,Polyi). remove_zero_terms([(C,N)IPoly] , [(C,N)JPolyl]) - C

O,

, remove_zero_terms(Poly,Polyl). remove_zero_terms([ il,[ ]). Polynomial manipulation routines add_polynomials (Polyl,Poly2,Poly) Poly is the sum of Polyl and Po!y2, where Polyl, PoIy2, and Poly are all in polynomial form. add_polynomials([ ],Poly,Poly) add_polynoinials(Poly, [ ] ,Poly) add_polynomials([(Ai,Ni)lPolyl] , [(Aj ,Nj)Poly2] ,[(Ai,Ni)IPoly]) - Ni > Nj, !, add_polynomials(Polyl, [(Aj,Nj)IPoly2l,Poly). add_polynomials([(Ai,Ni)tPolyl],[(Aj,Nj)jPoly2] ,[(A,Ni)IPolyl) - Ni =:= Nj, !, A is Ai+Aj, add_polynomials(Polyl,Poly2,Poly). add_polynomials([(Ai,Ni)IPolyl] ,f(Aj ,Nj)Poly2],[(Aj,Nj)IPoly]) Ni < Nj,

! , add_polynomials([(Ai,Ni)IPolyl] ,Poly2,Poly). subtract_polynomials (Polyl,Poly2,Poly) - Po/y is the difference of Polyl and Poly2, where Polyl, Poly2, and Poly are all in polynomial form. subtract_polynomials (Polyl , Poly2 , Poly) multiply_single (Poly2, (1,O) ,Poly3), add_polynomials(Polyl,Poly3,Poly), multiply_single(Polyl,Monomial,Poly) - Poly is the product of Po/yl and Monomial, where Polyl and Po/y are in polynomial form, and Monomial has the form (C,N) denoting the monomial C1XN. multiply_single([(C1,N1)IPolyl],(C,N),[(C2,N2)IPoly]) - C2 is C1*C, N2 is N1+N, multiply_single(Polyl,(C,N),Poly). multiply_single([ ],Factor,[ 1). Program 23.1

<!-- page 486 -->
(Continued) multiply_polynomials (Polyl,Poly2,Poly) -

Poly is the product of Polyl and Poly2, where Polyl,

Poly2, and Poly are all in polynomial form. multiply_polynomials([(C,N)lPolyl],Poly2,Poly) -

```prolog
multiply_single(Poly2, (C,N) ,Poly3),
multiply_polynomials (Polyl , Poly2 , Poly4),
add_polynomials (Poly3, Poly4 , Poly).
```

multiply_polynomials([ ],P,[ 1). binornial(Poly, i ,Poly). Polynomial equation solver solve_polynomial_equation (Equation, Unknown,Solution) -

Solution is a solution to the polynomial Equation in the unknown

Unknown. solve_polynomial_equation(PolyEquation,X,X =

- linear(PolyEquat ion), !,

```prolog
pad(PolyEquation, [(A,i) , (B4O)1).
```

solve_polyriomial_equation(PolyEquation,X, Solution) -

quadratic(PolyEquation), !,

```prolog
pad(PolyEquation, [(A,2) , (B,1) , (C,O)])
discrimïnarit(A,B,C,Discriminant),
root(X,A,B,C,Discriminant,Solution).
```

discriminant(A,fl,C,D)

D is B*B - 4*A*C. root(X,A,B,C,O,X= -B/(2*A)). root(X,A,B,C,D,X

(-B+sqrt(D))/(2*A)) .- D > O. root(X,A,B,C,D,X

(-B-sqrt(D))/(2*A)) - D > O. pad([(C,N) IPoly] , [(C,N) IPolyl])

```prolog
pad(Poly,Polyl).
```

pad(Poly,[(O,N)lPolylI)

```prolog
pad(Poly,Polyl).
```

**pad([ J,[ 1).**

linear([(Coeff 1) IPoly]) quadratic( [(Coeff 2)1 Poly]) The homogenization method homogenize (Equation,X,Equation 1,X1) -

The Equation in X is transfoi iiied to the polynomial

Equation i in Xl where Xi contains X. homogenïze(Equation,X,Equationl Xl) -

offenders (Equation,X,Dffenders),

```prolog
reduced_term(X,Dffenders,Type Xl),
rewrite(Offenders,Type,Xi ,Substitutions),
substitute(Equation,Substitutions ,Equationl)
```

Program 23.1

<!-- page 487 -->
(Continued) offenders(Equation, Unknown,Offenders)

Offenders is the set of offenders of the Equation in the Unknown.

```prolog
offenders(Equation,X,Offenders) -
    parse(Equation,X,Offendersl\[ 1),
    remove_duplicates(Offendersl ,Offenders),
    multiple(Offenders).
reduced_term(X,Offenders,Type,X1) -
    classify(Offenders,X,Type),
    candidate(Type,Dffenders,X,X1).
```

Heuristics for exponential equations

```prolog
classify(Offenders,X,exponential) -
    exponential_offenders(Offenders ,X).
exponential_offenders([AIBIOffs] ,X) -
    free_of(X,A), subterm(X,B), exponential_offenders(Offs ,X).
exponential_offenders([ ],X).
candidate(exponential,Offenders,X,AIX) -
    base (Offenders,A), polynomial_exponents(Offenders,X).
base([AIBlOffs] ,A) - base(Offs,A)
base([ ],A).
polynomial_exponents([AIBIOffs] ,X) -
    polynomial(B,X), polynomial_exponents(Dffs,X).
polynomial_exponents( E ] ,X).
```

Parsing the equation and making substitutions parse (Expression, Term, Offenders) -

Expression is traversed to produce the set of Offenders in Term,

that is, the nonalgebraic subterms of Expression containing Term.

```prolog
parse(A+B,X,L1\L2) -
    1, parse(A,X,L1\L3), parse(B,X,L3\L2).
parse(A*B,X,Li\L2)
    !, parse(A,X,L1\L3), parse(B,X,L3\L2).
parse(A-B,X,Li\L2) -
    !, parse(A,X,L1\L3), parse(B,X,L3\L2).
parse(A=B,X,L1\L2) -
       parse(A,X,L1\L3), parse(B,X,L3\L2).
parse(AIB,X,L) -
    integer(B),
                !, parse(A,X,L).
parse(A,X,L\L) -
    freeof(X,A),
                 !.
parse(A,X,EAIL]\L) -
    subterm(X,A),
                 !.
```

Program 23.1

<!-- page 488 -->
(Continued) substitute (Expression,Substitutions,Expressionl) -

The list of Substitutions is applied to Expression to produce

Expression 1. substitute (A+B ,Subs, NewA+NewB)

', substitute(A,Subs,NewA), substitute(B,Subs,NewB). substitute (A*B ,Subs, NewA*New) -

```prolog
substitute(A,Subs,NewA), substitute(B,Subs,NewB).
```

substitute (-B,Subs, NewA-NewB) -

```prolog
substitute(A,Subs,NewA), substitute(B,Subs,NewB).
```

substitute (A=B ,Subs, NewA=NewB) -

```prolog
substitute(A,Subs,NevA), substitute(B,Subs,NewB).
```

substituto(AIB,Subs,NewAIB) -

```prolog
iuteger(B),
            ! , substitute(A,Subs,NewA).
```

substitute(A,Subs,B) -

member(A=B,Subs), L substitute(A,Subs,A). Finding homogenization rewrite rules rewrite([DffIOffs] ,Type,X1, [Off=TermlRewrites]) *

```prolog
homogenize_axiom(Type,Off ,X1 ,Terin),
rewrite (Offs,Type,X1 ,Rewrites).
```

rewrite([ 1,Type,X,[ ]). Homogenization axioms homogenize_axiom(exponential,A1(N*X) ,AIX, (AIX) TN) homogenize_axioin(exponeritial,At(-X),AIX,1/(AIX)). homogenize_axiom(exponential,A1(X+B),AIX,ATB*AIX). Utilities subterm(Sub,Term)

See Program 9.2. position(Term,Term,[ 1) - L position(Sub,Term,Path) -

```prolog
compound(Term), functor(Term,F,N), position(N,Sub,Term,Path),
```

positïon(N,Sub,Term, [NiPath]) -

```prolog
arg(N,Terrn,Arg), position(Sub,Arg,Path)
```

position(N,Sub,Terin,Path) -

N > 1, Nl is N-1, position(N1,Sub,Term,Path). free_of(Subterm,Term) - occurrence(Subterm,Terrn,O). single_occurrerice(Subterm,Term) - occurrence(Subterm,Term,l). occurrence(Terin,Term,l) occurrence(Sub,Term,N) -

```prolog
cornpound(Terrn),
               ! , functor(Term,F,M), occurrence(M,Sub,Term,O,N).
```

occurrence(Sub,Term,O) - Term

Sub. Program 23.1

<!-- page 489 -->
(Continued)

```prolog
occurrence(M,Sub,Term,N1,N2) -
    M > O,
           !, arg(M,Term,Arg), occurrence(Sub,Arg,N), N3 is N+N1,
    Ml is M-1, occurrence(M1,Sub,Term,N3,N2).
occurrence (O , Sub , Term ,N, N)
remove_duplicates(Xs,Ys)
                          no_doubles(Xs,Ys).
no_doubles(Xs,Ys) - SeeProgram7.9.
multiple([X1,X2IXs]).
```

Testing and data

```prolog
test_press(X,Y) - equation(X,E,U), solve_equation(E,U,Y).
equation(1,cos(x)*(l-2*sin(x))=O,x).
equation(2,x12-3*x+20,x).
equation(3,21(2*x)-5*21(x+1)+16=O,x).
```

Program 23.1

(Continued)

Program 23.1 has four clauses for `solve_equation,` one for each of the four methods needed to solve the equations in Figure 23.1. More generally, there is a clause for each equation-solving method. The full PRESS system has several more methods.

Our equation solver ignores several features that might be expected. There is no simplification of expressions, no rational arithmetic, no record of the last equation solved, no help facility, and so forth. PRESS does contain many of these facilities as discussed briefly in Section 23.6.

23.2 Factorization Factorization is the first method attempted by the equation solver. Note that the test whether factorization is applicable is trivial, being unification with the equation A * B = O. If the test succeeds, the simpler equations are recursively solved. The top-level clause implementing factorization is

```prolog
solve_equation(A*B=O,X,Solution) -
    factorize(A*B,X,Factors\[ 1),
    remove_duplicates (Factors ,Factorsl),
    solve_factors (Factors 1, X, Solution).
```

<!-- page 490 -->
The top-level clause in Program 23.1 has a cut as the first goal in the body. This is a green cut: none of the other methods depend on the success or failure of factorization. In general, we omit green cuts from clauses we describe in the text.

23.3 Isolation A useful concept to locate and manipulate the single occurrence of the unknown is its position. The position of a subterm in a term is a list of argument numbers specifying where it appears. Consider the equation cos(x) = O. The term cos(x) containing x is the first argument of the equation, and x is the first (and only) argument of cos(x). The position of x in cos(x) = O is therefore [1,1]. This is indicated in the diagram in Figure 23.2. The figure also shows the position of x in i - 2 . sin(x) = O which is 11,2,2,1].

The clause defining the method of isolation is

```prolog
solve_equation(Equation,X,Solution) -
    single_occurrence (X, Equation)
    position(X,Equation, [Side Position]),
    maneuver_sides (Side , Equation, Equationi)
    isolate (Position,Equationl ,Solution).
   ZN
```

**cos**

O

Figure 23.2

<!-- page 491 -->
Position of subterms in terms The condition characterizing when isolation is applicable is that there be a single occurrence of the unknown X in the equation, checked by `single_occurrence.` The method calculates the position of X with the predicate `position.` The isolation of X then proceeds in two stages. First, `maneuver_sides` ensures that X appears on the left-hand side of the equation, and second, `isolate` makes it the subject of the formula.

It is useful to define `single_occurrence` in terms of the more general predicate `occurrence(Subterm,Term,N),` which counts the number of times `N` that `Subterm` occurs in the term `Term.` Both `occurrence` and `position` are typical structure inspection predicates. Both are posed as exercises at the end of Section 9.2. Code for them appears in the utilities section of Program 23.1.

```prolog
The predicate maneuver_sides (N ,Equation, Equationi) consists of
```

two facts:

```prolog
maneuver_sides(1,Lhs = Rhs,Lhs = Rhs).
maneuver_sides(2,Lhs = Rhs,Rhs = Lhs).
```

Its effect is to ensure that the unknown appears on the left-hand side of `Equationi.` The first argument

`N,` the head of the position list, indicates the side of the equation in which the unknown appears. A i means the left-hand side, and the equation is left intact. A 2 means the right-hand side, and so the sides of the equation are swapped.

The transformation of the equation is done by `isolate/3.` It repeatedly applies rewrite rules until the position list is exhausted:

```prolog
isolate([NlPosition] ,Equation,IsolatedEquation) -
    isolax(N,Equation,Equationl),
    isolate (Position,Equationl , IsolatedEquation).
isolate( [
           J ,Equation,Equation).
```

The rewrite rules, or isolation axioms, are specified by the predicate `isolax(N,Equation,Equationl).` Let us consider an example used in solving i - 2 . sin(x) = O. An equivalence transformation on equations is adding the same quantity to both sides of an equation. We show its translation into an `isolax` axiom for manipulating equations of the form u - y = w. Note that rules need only simplify the left-hand side of equations, since the unknown is guaranteed to be on that side.

<!-- page 492 -->
Two rules are necessary to cover the two cases whether the first or second argument of u - y contains the unknown. The term u - y = w can be rewritten to either u = w + i' or y = u - w. The first argument of isolax specifies which argument of the sum contains the unknown. The Prolog equivalent of the two rewrite rules is then isolax(1,Terinl-Term2 = Rhs,Terml

Rhs+Term2). isolax(2,Terml-Term2 = Rhs,Term2 = Terml-Rhs). Other isolation axioms are more complicated. Consider simplifying a product on the left-hand side of an equation. One of the expected rules would be isolax(1,Terml*Term2 = Rhs,Terml = Rhs/Term2). If Teiui2 equals zero, however, the rewriting is invalid. A test is therefore added that prevents the axioms for multiplication being applied if the term by which it divides is O. For example, isolax(1,Terinl*Term2 = Rhs,Terml = Rhs/Term2) - Terin2

O.

Isolation axioms for trigonometric functions illustrate another possibility that must be catered for - multiple solutions. An equation such as sin(x) = 1/2 that is reached in our example has two solutions between O and 2 . Tr. The alternative solutions are handled by having separate isolax axioms: isolax(1,sin(U) = V,U = arcsin(V)). isolax(1,sin(U)

V,U = Tr - arcsin(V)).

In fact, the equation has a more general solution. Integers of the form 2 n

iT can be added to either solution for arbitrary values of n. The decision whether a particular or general solution is desired depends on context and on semantic information independent of the equation solver.

Further examples of isolation axioms are given in the complete equation solver, Program 23.1.

The code described so far is sufficient to solve the first equation in Figure 23.1, cos(x) . (1 - 2 . sin(x)) = O. There are four answers arccos(0),

- arccos(0), arcsin((1 - 0)/2), rr - arcsin((1 - 0)/2). Each can be simpiifled, for example, arcsin((1 - O)/2) to rr/6, but will not be unless the expression is explicitly evaluated.

<!-- page 493 -->
The usefulness of an equation solver depends on how well it can perform such simplification, even though simplification is not strictly part of the equation-solving task. Writing an expression simplifier is nontrivial, however. It is undecidable whether two expressions are equivalent in general. Some simple identities of algebra can be easily incorporated, for example, rewriting O + u to u. Choosing between other preferred forms, e.g., (1 + x)3 and i + 3

x + 3 x2 + x3, depends on context.

23.4 Polynomial Polynomial equations are solved by a polynomial equation solver, applying various polynomial methods. Both sides of the equation are checked as to whether they are polynomials in the unknown. If the checks are successful, the equation is converted to a polynomial normal form by `polynomial_normal_form,` and the polynomial equation solver `solve_`

```prolog
polynomial_equat ion is invoked:
solve_equation(Lhs=Rhs , X ,Solution)
    polynomial(Lhs,X),
    polynomial(Rhs,X),
    polynomial_normal_form (Lhs-Rhs , X, PolyForm),
     solve_polynomial_equation (PolyForm,X, Solution).
```

The polynomial normal form is a list of tuples of the form (A,N1), where A is the coefficient of

which is necessarily nonzero. The tuples are sorted into strictly decreasing order of N; for each degree there is at most one tuple. For example, the list [(1,2), (-3, 1),(2,O)] is the normal form for x2 - 3 . x + 2. The leading term of the polynomial is the head of the list. The classic algorithms for handling polynomials are applicable to equations in normal form. Reduction to polynomial normal form occurs in two stages:

```prolog
polynomial_normal_form (Polynomial , X, NormalForm) -
    polynomial_f orm (Polynomial, X, PolyForm),
     remove_zero_terms (PolyForm NormalForm).
```

The predicate

```prolog
polynornial_form(X,Polynomial PolyForm)
                                           decom-
```

poses the polynomial. `PolyForm` is a sorted list of coefficient-degree tuples, where tuples with zero coefficients may occur.

<!-- page 494 -->
It is convenient for many of the polynomial methods to assume that all the terms in the polynomial form have nonzero coefficients. Therefore the final step of `polynomial_normal_form` is removing those ternis whose coefficients are zero. This is achieved by a simple recursive proce-

```prolog
dure remove_zero_terms.
```

The code for `polynomial_form` directly echoes the code for `polyno-` `mial.` For each clause used in the parsing process, there is a corresponding clause giving the resultant polynomial. For example, the polynomial form of a term x1 is [(1,n)], which is expressed in the clause

```prolog
polynomial_form(XIN,X, [(1,N)J).
```

The recursive clauses for `polynomial_form` manipulate the polynomials in order to preserve the polynomial form. Consider the clause

```prolog
polynomial_form(Polyl+Poly2,X,PolyForm) -
    polynomial_f orm(Polyl ,X,PolyForml),
    polynomial_f orm(Poly2 , X, PolyForm2),
    add_polynomials (PolyFormi , PolyForm2 , PolyForm).
```

The procedure `add_polynomials` contains an algorithm for adding polynomials in normal form. The code is a straightforward list of the possibilities that can arise:

```prolog
add_polynomials([ I ,Poly,Poly).
add_polynomials (Poly,
                       E
                         I ,Poly).
add_polynomials([(Ai,Ni) IPolyl] , [(Aj,Nj)IPoly2], [(Ai,Ni)IPoly])
    Ni > Nj, add_polynomials(Polyl, E(Aj , Nj) IPoly2] , Poly).
add_polynomials([(Ai,Ni)IPolyl] ,[(Aj,Nj)IPoly2] , [(A,Ni)Poly]) -
    Ni =:= Nj, A is Ai+Aj, add_polynomials(Polyl,Poly2,Poly).
add_polynomials([(Ai,Ni)IPolyl],[(Aj,Nj)IPoly2],[(Aj,Nj)IPoly]) -
    Ni < Nj, add_polynomials([(Ai,Ni)IPolyl] ,Poly2,Poly).
  Similarly, the procedures subtract_polynomials, mult iply_polyno-
```

`mials,` and `binomial` are algorithms for subtracting, multiplying, and binomially expanding polynomials in normal form to produce results in normal form. The subsidiary predicate `multiply_single(Polyl,Mono-` `mial,Poly2)` multiplies a polynomial by a monomial (C,N) to produce a new polynomial.

<!-- page 495 -->
Once the polynomial is in normal form, the polynomial equation solver is invoked. The structure of the polynomial solver follows the structure of the overall equation solver. The solver is a collection of methods that are tried in order to see which is applicable and can be used to solve the equation. The predicate `solve_polynomial_equation` is the analogous

```prolog
relation to solve_equation.
```

The second equation in Figure 23.1 is quadratic and can be solved with the standard formula. The equation solver mirrors the human method. The polynomial is identified as being suitable for the quadratic method by checking (with `quadratic)` if the leading term in the polynomial is of second degree. Since zero terms have been removed in putting the polynomial into its normal form, `pad` puts them back if necessary. The next two steps are familiar: calculating the discriminant, and returning the roots according to the value of the discriminant. Again multiple solutions are indicated by having multiple possibilities:

```prolog
solve_polynomial_equation(Poly,X,Solution) -
    quadratic(Poly),
    pad(Poly, [(A,2) , (B,1) , (C,O)])
    discriminant(A,B,C,Discriminant),
    root(X,A,B,C,Discriminant,Solution).
discriminant(A,B,C,D) - D is (B*B - 4*A*C).
root(X,A,B,C,O,X= -B/(2*A)).
root(X,A,B,C,D,X= (-B+sqrt(D))/(2*A)) - D > O.
root(X,A,B,C,D,X= (-B-sqrt(D))/(2*A)) - D > O.
```

Other clauses for `solve_polynomial_equation` constitute separate methods for solving different polynomial equations. Linear equations are solved with a simple formula. In PRESS, cubic equations are handled by guessing a root and then factoring, reducing the equation to a quadratic. Other tricks recognize obvious factors, or that quartic equations missing a cubic and a linear term are really disguised quadratics.

<!-- page 496 -->
23.5 Homogenization The top-level clause for homogenization reflects the transformation of the original equation into a new equation in a new unknown, which is recursively solved; its solution is obtained for the original unknown: solve_equation(Equation,X,Solution) -

```prolog
hornogenize(Equation,X,Equationl,X1),
solve_equation(Equationl ,X1 ,Solutionl),
solve_equation(Solutionl ,X, Solution).
```

The code for homogenize/4 implements the four stages of homogenization, described in Section 23.1. The offenders set is calculated by offenders/3, which checks that there are multiple offenders. If there is oily a single offender, homogenization will not be useful: hornbgenize(Equation,X,Equationl ,X1) -

offenders (Equation, X,Offenders),

```prolog
reduced_terni(X,Offenders Type ,X1)
rewrite(Offenders,Type,X1,Substitutions),
substitute (Equation,Substitutions, Equatìonl).
```

The predicate reduced_term/4 finds a reduced term, that ìs, a candidate for the new unknown. In order to structure the search for the reduced term, the equation is classified into a type. This type is used in the next stage to find rewrite rules expressing each element of the offenders set as an appropriate function of the reduced term. The type of the example equation is exponential. PRESS encodes a lot of heuristic knowledge about finding a suitable reduced term. The heuristics depend on the type of the terms appearing in the offenders set. To aid the structuring (and retrieval) of knowledge, finding a reduced term proceeds in two stages classifying the type of the offenders set, and finding a reduced term of that type: reduced_terni(X ,Offenders, Type ,Xl) -

```prolog
classify(Offenders,X,Type),
candidate(Type,Offenders,X,X1).
```

We look at the set of rules appropriate to our particular equation. The offenders set is of exponential type because all the elements in the offenders set have the form A, where A does not contain the unknown but B does. Standard recursive procedures check that this is true.

<!-- page 497 -->
The heuristic used to select the reduced term in this example is that if all the bases are the same, A, and each exponent is a polynomial in the unknown, X, then a suitable reduced term is Ax:

```prolog
candidate (exponential ,Offenders, X ,AIX) -
    base(Offenders,A), polynomial_exponents(Offenders,X).
```

The straightforward code for `base` and `polynomial_exponents` is in the complete program. The heuristics in PRESS are better developed than the ones shown here. For example, the greatest common divisor of all the leading terms of the polynomials is calculated and used to choose the reduced term.

The next step is checking whether each member of the offenders set can be rewritten in terms of the reduced term candidate. This involves finding an appropriate rule. The collection of clauses for `homogenize_` `axiom` constitute the possibly applicable rewrite rules. In other words, relevant rules must be specified in advance. The applicable rules in this case are

```prolog
homogenize_axiom(exponential,AI (N*X) ,AIX, (AIX) IN).
homogenize_axiom(exponential,AI(X+B) ,AIX,AIB*AIX).
```

Substituting the term in the equation echoes the parsing process used by `offenders` as each part of the equation is checked to see whether it is the appropriate term to rewrite. Exercises for Chapter 23

Add isolation axioms to Program 23.1 to handle quotients on the

left-hand side of the equation. Solve the equation x/2 = 5.

Add to the polynomial equation solver the ability to solve disguised

linear and disguised quadratic equations. Solve the equations 2

**x3-8=x3, andx4**

5

2 +6=0.

The equation cos(2 . x) - sin(x) = O can be solved as a quadratic

equation in sin(x) by applying the rewrite rule cos(2 . X) = i - 2

sin2(x). Add clauses to Program 23.1 to solve this equation. You

will need to add rules for identifying terms of type trigonometric,

heuristics for finding trigonometric reduced terms, and appropriate

homogenization axioms. (iv)

Rewrite the predicate `free_of (Term,X)` so that it fails as soon as it

<!-- page 498 -->
finds an occurrence of X in `Term.` (V)

Modify Program 23.1 so that it solves simple simultaneous equa-

```prolog
tions.
```

**23.6 Background**

Symbolic manipulation was an early application area for Prolog. Early examples are programs for symbolic integration (Bergman and Kanoui, 1973) and for proving theorems in geometry (Welham, 1976).

The PRESS program, from which Program 23.1 is adapted, owes a debt to many people. The original version was written by Bob Weiham Many of the researchers in the mathematical reasoning group working with Alan Bundy at the University of Edinburgh subsequently tinkered with the code. Published descriptions of the program appear in Bundy and Weiham (1981), Sterling et al. (1982), and Silver (1986). The last reference has a detailed discussion of homogenization.

PRESS includes various modules, not discussed in this chapter, that are interesting ¡n their own right: for example, a package for interval arithmetic (Bundy, 1984), an infinite precision rational arithmetic package developed by Richard O'Keefe, and an expression simplifier based on difference-structures as described in Section 15.2, developed by Lawrence Byrd. The successful integration of all these modules is strong evidence for the practicality of Prolog for large programming projects.

The development of PRESS showed up classic points of software engineering. For example, at one stage the program was being tuned prior to publishing some statistics. Profiling was done on the program, which showed that the predicate most commonly called was free_of. Rewriting it as suggested in Exercise 23(iv) resulted in a speedup of 35 percent in the performance of PRESS.

Program 23.1 is a considerably cleaned-up version of PRESS. Tidying the code enabled further research. Program 23.1 was easily translated to other logic programming laliguages, Concurrent Prolog and FCP (Sterling and Codish, 1986). Making the conditions when methods were used more explicit enabled the writing of a program to learn new equation-solving methods from examples (Silver, 1986).
