# 10 Meta-Logical Predicates

<!-- page 216 -->
A useful extension to the expressive power of logic programs is provided by the meta-logical predicates. These predicates are outside the scope of first-order logic, because they query the state of the proof, treat variables (rather than the terms they denote) as objects of the language, and allow the conversion of data structures to goals.

Meta-logical predicates allow us to overcome two difficulties involving the use of variables encountered in previous chapters. The first difficulty is the behavior of variables in system predicates. For example, evaluating an arithmetic expression with variables gives an error. So does calling type predicates with variable arguments. A consequence of this behavior is to restrict Prolog programs to have a single use in contrast to the multiple uses of the equivalent logic programs.

The second difficulty is the accidental instantiation of variables during structure inspection. Variables need to be considered as specific objects rather than standing for an arbitrary unspecified term. In Chapter 9 we handled the difficulty by restricting inspection to ground terms only.

<!-- page 217 -->
This chapter has four sections, each for a different class of meta-logical predicates. The first section discusses type predicates that determine whether a term is a variable. The second section discusses term comparison. The next sections describe predicates enabling variables to be manipulated as objects. Finally, a facility is described for converting data into executable goals. 10.1 Meta-Logical Type Predicates The basic meta-logical type predicate is `var (Term),` which tests whether a given term is at present an uninstantiated variable. Its behavior is similar to the type predicates discussed in Section 9.1. The query `var (Term)?` succeeds if `Term` is a variable and fails if `Term` is not a variable. For example, `var(X)?` succeeds, whereas both `var(a)?` and `var([XXs])?` fail.

The predicate `var is` an extension to pure Prolog programs. A table carmot be used to give all the variable names. A fact `var (X)` means that all instances of X are variables rather than that the letter X denotes a variable. Being able to refer to a variable name is outside the scope of first-order logic in general or pure Prolog in particular.

The predicate `nonvar (Term)` has the opposite behavior to `var.` The query `nonvar (Term)?` succeeds if `Term` is not a variable and fails if `Term` is a variable.

The meta-logical type predicates can be used to restore some flexibility to programs using system predicates and also to control goal order. We demonstrate this by revising some programs from earlier chapters.

Consider the relation plus (X,Y,Z). Program 10.1 is a version of plus that can be used for subtraction as well as addition. The idea is to check which arguments are instantiated before calling the arithmetic evaluator. For example, the second rule says that if the first and third arguments, X and Z, are not variables, the second argument, Y, can be determined as their difference. Note that if the arguments are not integers, the evaluation will fail, the desired behavior.

The behavior of Program 10.1 resembles that of Program 3.3, the logic program for plus. Further, it does not generate any errors. Nonetheless, it does not have the full flexibility of the recursive logic program: it cannot be used to partition a number mto two smaller numbers, for

plus(X,Y,Z) -

The sum of the numbers X and Y is Z.

```prolog
                                     is X+Y.
                                     is Z-X.
plus(X,Y,Z) -
plus(X,Y,Z) -
plus(X,Y,Z) -
                                     is Z-Y.
              nonvar(X),
              nonvar(X),
              nonvar(Y),
                        nonvar(Y), Z
                        nonvar(Z), Y
                        nonvar(Z), X
```

Program 10.1

<!-- page 218 -->
Multiple uses for `plus` length(Xs,N) -

The list Xs has length N. length(Xs,N)

```prolog
nonvar(Xs), lengthl(Xs,N).
```

length(Xs,N) - var(Xs), nonvar(N), lerigth2(Xs,N). lengthl(Xs,N)

See Program 8.11. length2(Xs,N) .- See Program 8.10. Program 10.2 A multipurpose length program

example. To partition a number involves generating numbers, for which a different program is needed. This is posed as Exercise (ii) at the end of this section.

Meta-logical goals placed initially in the body of a clause to decide which clause in a procedure should be used are called meta-logical tests. Program 10.1 for plus is controlled by meta-logical tests. These tests refer to the current state of the computation. Knowledge of the operational semantics of Prolog is required to understand them.

Standard Prolog in fact endows the type predicates with a meta-logical ability. For example, if X is a variable the goal `integer(X)` fails, rather than giving an error. This enables the rules from Program 10.1 to be written using the system predicate `integer` rather than `nonvar,` for example,

```prolog
plus(X,Y,Z) - integer(X), integer(Y), Z is X+Y.
```

We feel it is preferable to separate type checking, which is a perfectly legitimate first-order operation, from meta-logical tests, which are a much stronger tool.

Another relation that can have multiple uses restored is `length (Xs , N)` determining the length N of a list Xs. Separate Prolog programs (8.10 and 8.11) are needed to find the length of a given list and to generate an arbitrary list of a given length, despite the fact that one logic program (3.17) performs both functions. Program 10.2 uses meta-logical tests to define a single `length` relation. The program has an added virtue over Programs 8.10 and 8.11. lt avoids the non-terminating behavior present in both, when both arguments are uninstantiated.

Meta-logical tests can also be used to make the best choice of the goal order of clauses in a program. Section 7.3 discusses the definition of

```prolog
grandparent:
```

<!-- page 219 -->
grandparent(X,Z) -

X is the grandparent of Z.

```prolog
grandparent(X,Z) - nonvar(X), parent(X,Y), parent(Y,Z).
grandparent(X,Z) - nonvar(Z), parent(Y,Z), parent(X,Y).
```

Program 10.3 A more efficient version of `grandparent`

ground(Term) -

Term is a ground term.

```prolog
ground(Term) -
    nonvar (Term), constant(Term).
ground(Term) -
    nonvar (Term),
    compound (Term),
    f unctor (Term , F , N)
    ground (N , Term)
ground(N,Term) -
    N > O,
    arg (N , Term , Arg)
    ground (Arg)
    Nl is N-1,
    ground(Nl ,Term).
ground(O,Term).
```

Program 10.4

Testing if a term is ground

```prolog
grandparent(X,Z) - parent(X,Y), parent(Y,Z).
```

The optimum goal order changes depending on whether you are searching for the grandchildren of a given grandparent or the grandparents of a given grandchild. Program 10.3 is a version of `grandparent` that will search more efficiently.

The basic meta-logical type predicates can be used to define more involved meta-logical procedures. Consider a relation `ground (Term),` which is true if `Term` is ground. Program 10.4 gives a definition.

<!-- page 220 -->
The program is in the style of the programs for structure inspection given in Section 9.2, in particular Program 9.3 for `substitute.` The two clauses for `ground/i` are straightforward. In both cases, a meta-logical test is used to ensure that no error is generated. The first clause says that constant terms are ground. The second clause deals with structures. It calls an auxiliary predicate `ground/2,` which iteratively checks that all the arguments of the structure are ground.

We look at a more elaborate example of using meta-logical type predicates; writing a unification algorithm The necessity of Prolog to support unification for matching goals with clause heads means that explicit unification is readily available. Prolog's underlying unification can be used to give a trivial definition

```prolog
unify (X , X)
```

which is the definition of the system predicate `=12,` namely, X=X.

Note that this definition depends on Prolog's underlying mechanism for unification, and hence does not enforce the occurs check.

A more explicit definition of Prolog's unification is possible using mctalogical type predicates. Although more cumbersome and less efficient, this definition is useful as a basis for more elaborate unification algorithms One example is unification with the occurs check, described in Section 10.2. Another example is unification ni other logic programming languages that can be embedded in Prolog, such as read-only unification of Concurrent Prolog.

Program 10.5 is an explicit definition of unification. The relation `unify(Ternil,Term2)` is true if `Termi` unifies with `Term2.` The clauses of `unify` outline the possible cases. The first clause of the program says that two variables unify The next clause is an encapsulation of the rule for unification that if X is a variable, then X unifies with Y.

The other case bearing discussion in Program 10.5 is unifying two compound terms, as given in the predicate `term_unify(X,Y).` This predicate checks that the two terms X and Y have the same principal functor and arity, and then checks that all the arguments unify, using `uriify_args,` in a way similar to the structure inspection programs shown before. 10.1.1

Exercises for Section 10.1

Write a version of Program 8.12 for `range` that can be used in mul-

tiple ways.

Write a version of Program 10.1 for plus that partitìons a number

as well as performing addition and subtraction. (Hint: Use `between`

<!-- page 221 -->
to generate numbers.) unify(Terml,Term2) -

Termi arLd Term2 are unified, ignoring the occurs check.

```prolog
unify(X,Y) -
    var(X), var(Y), XY.
unify(X,Y) -
    var(X), nonvar(Y), X=Y.
unify(X,Y) -
    var(Y), nonvar(X), YX.
unify(X,Y) -
    nonvar(X), nonvar(Y), constant(X), constant(Y), X=Y.
unify(X,Y) -
    nonvar(X), nonvar(Y), compound(X), compound(Y), term_unify(X,Y).
term_unify(X,Y) -
    functor(X,F,N), functor(Y,F,N), unify_args(N,X,Y).
unify_args(N,X,Y) -
    N > O, unify_arg(N,X,Y), Nl is N-1, unify_args(N1,X,Y).
unify_args(O,X,Y).
unify_arg(N,X,Y) -
    arg(N,X,ArgX), arg(N,Y,ArgY), unify(ArgX,ArgY).
```

Program 10.5

Unification algorithm

10.2 Comparing Nonground Terms Consider the problem of extending the explicit unification program, Program 10.5, to handle the occurs check. Recall that the occurs check is part of the formal definition of unification, which requires that a variable not be unified with a term containing this variable. In order to implement it in Prolog, we need to check whether two variables are identical (not just unifiable, as any two variables are). This is a meta-logical test.

Standard Prolog provides a system predicate, =/2, for this purpose. The query X == Y? succeeds if X and Y are identical constants, identical variables, or both structures whose principal functors have the same name and arity, and recursively X == Y1? succeeds for all corresponding arguments X and Y. of X and Y. The goal fails otherwise. For example, X == 5? fails (in contrast to X = 5?).

<!-- page 222 -->
There is also a system predicate that has the opposite behavior to ==. The query X \== Y? succeeds unless X and Y are identical terms. unify(Terml,Term2) -

Term 1 and Term2 are unified with the occurs check.

```prolog
uriify(X,Y)
    var(X), var(Y), XY.
unify(X,Y)
    var(X), nonvar(Y), not_occurs_in(X,Y), X=Y.
i.mify(X,Y) -
    var(Y), nonvar(X), not_occurs_in(Y,X), YX.
unify(X,Y) -
    nonvar(X), nonvar(Y), constant(X), constant(Y), X=Y.
unify(X,Y)
    nonvar(X), nonvar(Y), compound(X), compound(Y), term_unify(X,Y).
```

noLoccursjn(X,Term) -

The variable X does not occur in Term.

```prolog
not_occurs_in(X,Y) -
    var(Y), X \== Y.
not_occurs_in(X ,Y)
    nonvar(Y), constant(Y).
not_occurs_in(X,Y)
    nonvar(Y), compound(Y), functor(Y,F,N), not_occurs_in(N,X,Y).
not_occurs_in(N,X,Y)
    N>O, arg(N,Y,Arg), not_occurs_in(X,Arg), Nl is N-1,
        uot_occurs_in(N1 ,X ,Y).
not_occurs_in(O,X,Y).
term_unify(X,Y)
               .- See Program 10.5.
```

Program 10.6

Unification with the occurs check

The predicate \== can be used to define a predicate `not_occurs_` `in(Sub,Term),` which is true if `Sub` does not occur in `leIm,` the relation that is needed in the unification algorithm with the occurs check. `not_` `occurs_in (Sub, Term)` is a meta-logical structure inspection predicate. lt is used in Program 10.6, a variant of Program 10.5, to implement unification with the occurs check.

Note that the definition of `not_occurs_in` is not restricted to ground terms. Lifting the restriction on Program 9.2 for `subterm` is not as easy. Consider the query `subterm(X,Y)?.` This would succeed using Program 9.2, instantiating X to Y.

<!-- page 223 -->
We define a meta-logical predicate `occurs_in(Sub,Term)` that has the desired behavior. occurs_in(Sub,Terrn) -

Sub is a subterm of the (possibly nonground) term Term.

Using

==

```prolog
occurs_in(X,Term) -
    subterm(Sub,Term), X == Sub.
```

Using

```prolog
     freeze
occurs_in(X,Terni) -
    freeze(X,Xf), freeze(Term,Termf), subterm(Xf,Termf).
subterm(X,Term) - See Program 9.2.
```

Program 10.7

Occurs in

The predicate == allows a definition of `occurs_in` based on Program 9.2 for `subterm. All` the subterms of the given term are generated on backtracking and tested to see if they are identical to the variable. The code is given in Program 10.7a.

As defined, `subterm` works properly only for ground terms. However, by adding meta-logical type tests, as in the definition of `not_occurs_in` in Program 10.6, this problem is easily rectified.

10.3 Variables as Objects The delicate handling of variables needed to define `occurs_in` in Section 10.2 highlights a deficiency in the expressive power of Prolog. Variables are not easily manipulated. When trying to inspect, create, and reason about terms, variables can be unwittingly instantiated.

A similar concern occurs with Program 9.3 for `substitute.` Consider the goal `substitute(a,b,X,Y),` substituting `a` for `b` in a variable X to give Y. There are two plausible behaviors for `substitute` in this case. Logically there is a solution when `X is a` and `Y is b.` This is the solution actually given by Program 9.3, achieved by unification with the base fact

```prolog
substitute (OLd ,New, Old ,New).
```

In practice, another behavior is usually preferred. The two terms X and `a` should be considered different, and Y should be instantiated to X. The other base case from Program 9.3,

```prolog
substitute(Old,New,Term,Term) - constant(Term), Term
                                                              Old.
```

<!-- page 224 -->
covers this behavior. However, the goal would fail because a variable is not a constant.

We can prevent the first (logical) solution by using a meta-logical test to ensure that the term being substituted in is ground. The unification implicit in the head of the clause is then only performed if the test succeeds, and so must be made explicit. The base fact becomes the rule

```prolog
substitute(Old,New,Terni,New) - ground(Terni), Old = Term.
```

Treating a variable as different from a constant is handled by a special rule, again relying on a meta-logical test:

```prolog
substitute(Old,New,Var,Var) - var(Var).
```

Adding the two preceding clauses to Program 9.3 for `substitute` and adding other meta-logical tests allows the program to handle nonground terms. However, the resultant program is inelegant. It is a mixture of procedural and declarative styles, and it demands of the reader an understanding of Prolog's control flow. To make a medical analogy, the symptoms have been treated (undesirable instantiation of variables), but not the disease (inability to refer to variables as objects). Additional metalogical primitives are necessary to cure the problem.

The difficulty of mixing object-level and meta-level manipulation of terms stems from a theoretical problem. Strictly speaking, meta-level programs should view object-level variables as constants and be able to refer to them by name.

We suggest two system predicates, `f reeze(Term,Frozen)` and `melt` `(Frozen, Thawed),` to allow explicit manipulation of variables. Freezing a term `Term` makes a copy of the term, `Frozen,` where all the uninstantiated variables in the term become unique constants. A frozen term looks like, and can be manipulated as, a ground term.

Frozen variables are regarded as ground atoms during unification. Two frozen variables unify if and only if they are identical Similarly, if a frozen term and an uninstantiated variable are unified, they become an identical frozen term. The behavior of frozen variables in system predicates is the behavior of the constants. For example, arithmetic evaluation involving a frozen variable will fail.

<!-- page 225 -->
The predicate `freeze` is meta-logical in a similar sense to `var.` It enables the state of a term during the computation to be manipulated directly.

The predicate `freeze` allows an alternative definition of `occurs_in` from the one given m Section 10.2. The idea is to freeze the term so that variables become ground objects. This makes Program 9.2 for `subterm,` which works correctly for ground terms, applicable. The definition is given as Program 10.7b.

Freezing gives the ability to tell whether two terms are identical. Two frozen terms, X and Y, unify if and only if their unfrozen versions are identical, that is, X == Y. This property is essential to the correct behavior of Program 10.7b.

The difference between a frozen term and a ground term is that the frozen term can be "melted back" into a nonground term. The companion predicate to `freeze` is `melt(Frozen,Thawed).` The goal `melt(X,Y)` produces a copy Y of the term X where frozen variables become regular Prolog variables. Any instantiations to the variables in X during the time when X has been frozen are taken into account when melting Y.

The combination of `freeze` and `melt` allows us to write a variant of `substitute, non_ground_substitute,` where variables are not accidentally instantiated. The procedural view of `non_ground_substitute` is as follows. The term is frozen before substitution; the substitution is performed on the frozen term using the version of `substitute,` which works correctly on ground terms; and then the new term is melted:

```prolog
non_ground_substitute(X,Y,Old,New) -
    freeze(Dld,Oldl), substitute(X,Y,Oldl,01d2),
    melt(01d2,New).
```

The frozen term can also be used as a template for making copies. The system predicate `melt_new (Frozen,Term)` makes a copy `Term` of the term `Frozen,` where frozen variables are replaced by new variables.

One use of `melt_new` is to copy a term. The predicate `copy(Term,Copy)` produces a new copy of a term. It can be defined in a single rule:

```prolog
copy(Term,Copy) - f reeze(Term,Frozen), melt_new(Frozen, Copy).
```

Standard Prolog provides the predicate `copy_term(Terml ,Term2)` for copying terms. It is true if and only if `Term2` unifies with a term T that is a copy of `Termi` except that all the variables of `Termi` have been replaced by fresh variables.

<!-- page 226 -->
Unfortunately, the predicates `freeze/2, melt/2,` and `melt_new/2` as described here are not present in existing Prolog implementations. They numbervars(Term,N1,N2)

The variables in Term are numbered from Nl to N2 -

1. nuinbervars('$VAR' (N) ,N,N1) -

Nl is N+1. nunibervars (Term, N, N) -

```prolog
norivar(Term), constant(Temm).
```

nunibervars(Term,N1 ,N2) -

```prolog
norivar(Term), compound(Temm),
f unctor (Term , Name , N)
nuxnbervars (O ,N , Term , Nl, N2)
```

nuinbervars (N ,N Term, Nl, Nl) nuinbervars(I,N,Term,N1,N3)

I <N

Il is 1+1,

```prolog
arg(Il,Term,Arg),
nuinbervars(Arg,N1 ,N2),
nuinbervars(I1,N,Term,N2,N3).
```

Program 10.8 Numbering the variables in a term

will be useful nonetheless in expressing and explaining the behavior of extra-logical predicates, discussed in Chapter 12.

A useful approximation to `freeze` is the predicate `nunbervars (Term,` Nl ,N2), which is provided in many Edinburgh Prolog libraries. A call to the predicate is true if the variables appearing in `Term` can be numbered from `Nl` to `N2-1.` The effect of the call is to replace each variable in the term by a term of the foriii '$VAR' (N) where N lies between Nl and N2.

```prolog
For example, the goal numbervars(append([XIXs] ,Ys, [XIZs] ,1,N) suc-
```

ceeds with the substitution `{X='$VAR(l)', Xs'$VAR' (2), Ys='$VAR'`

`(3), Zs='$VAR' (4),` N=5}. Code implementing `numbervars` is given as Program 10.8. lt is in the same style as the structure inspection utilities given in Chapter 9.

<!-- page 227 -->
10.4 The Meta-Variable Facility A feature of Prolog is the equivalence of programs and data - both can be represented as logical terms. In order for this to be exploited, programs need to be treated as data, and data must be transformed into programs. In this section, we mention a facility that allows a term to be X;Y -

X or Y. X

Y - X. X

Y - Y. Program 10.9

Logical disjunction

converted into a goal. The predicate call(X) calls the goal X for Prolog to solve.

In practice, most Prolog implementations relax the restriction we have imposed on logic programs, that the goals in the body of a clause must be nonvariable terms. The me ta-variable facility allows a variable to appear as a goal in a conjunctive goal or in the body of the clause. During the computation, by the time it is called, the variable must be instantiated to a term. It will then be treated as usual. If the variable is not instantiated when it comes to be called, an error is reported. The metavariable facility is a syntactic convenience for the system predicate call.

The meta-variable facility greatly facilitates meta-prograrnrning, in particular the construction of meta-interpreters and shells. Two important examples to be discussed in later chapters are Program 12.6, a simple shell, and Program 17.5, a meta-interpreter. It is also essential for defining negation (Program 11.6) and allowing the definition of higher-order predicates to be described in Section 16.3.

We give an example of using the meta-variable facility with a definition of logical disjunction, denoted by the binary infix operator "; ". The goal (X;Y) is true if X or Y is true. The definition is given as Program 10.9.

10.5 Background An excellent discussion of meta-logical system predicates in DEC-10 Prolog, and how they are used, can be found in O'Keefe (1983).

The unification procedure for Concurrent Prolog, written in Prolog, is in Shapiro (1983b).

<!-- page 228 -->
The difficulty in correctly manipulating object-level variables in Prolog at the meta-level has been raised by several people. The discussion first extensive discussion is in Nakashima et al. (1984), where the predicates freeze, melt, and melt_new are introduced. The name freeze was a little unfortunate, as it has been suggested for other additions to pure Prolog. Most notable is Colmerauer's geler (Colmerauer, 1982a), which allows the suspension of a goal and gives the programmer more control over goal order. This predicate is provided by Sicstus Prolog as freeze. The discussion of Nakashima and colleagues, although publicized in the first editon of this book, was largely ignored, to be revived by Barklund (1989) musing over "What is a variable in Prolog?" and by attempts to do metaprogramming in constraint logic programming languages, for example, Heintze et aI. (1989) and [im and Stuckey (1990).

The Gödel project (Hill and Uoyd, 1993) has advocated replacing Prolog by a language that facilitates explicit manipulation of variables at a meta-level. In Lloyd and Hill (1989), the terms ground and nonground representation are used. Prolog uses a nonground representation, and adding freeze and nuinbervars allows a ground representation.
