# B Clausal Form Program Listings

<!-- page 285 -->
Clausal Form Program Listings

```prolog
As promised in Chapter 10, we shall illustrate the process of converting a formula to
clausal form by showing fragments of a Prolog program for doing this. The top level
of the program is as follows:
           translate(X) :-
                    implout(X,Xl),
                                         /* Stage 1 */
                    negin(Xl,X2),
                                         /* Stage 2 */
                    skolem(X2,X3,[]),
                                         /* Stage 3 */
                    univout(X3,X4),
                                         /* Stage 4 */
                    conjn(X4,X5),
                                         /* Stage 5 */
                    clausify(X5,Clauses),
                                         /* Stage 6 */
                    pclauses(Clauses).
                                         /* Print out clauses */
This defines a predicate translate, such that if we give Prolog the goal translate(X),
with X standing for a Predicate Calculus formula, the program will print out the
formula's representation as clauses. In the program, we will represent Predicate Cal-
culus formulae as Prolog structures, as we have indicated before. Remember that
```

*Predicate Calculus variables will be represented by Prolog atoms, as this makes* *certain manipulations easier.* `We can distinguish Predicate Calculus variables from`

```prolog
constants by having some convention for their names. For instance, we could say
that variable names always begin with one of the letters x, y, and z. In fact, in the
program we will not need to know about this convention because variables are al-
ways introduced by quantifiers and hence are easy to detect. Only in reading the
program's output will it be important for the programmer to remember which names
were Predicate Calculus variables and which were constants.
First, we will need the following operator declarations for the connectives:
```

<!-- page 286 -->
```prolog
    ?- op(200,fx,~).
    ?- op(400,xfy,#).
    ?- op(400,xfy,&).
    ?- op(700,xfy,->).
    ?- op(700,xfy,<->).
It is important to note how we have defined these. In particular,
                                                          has a lower
precedence than "#" and "&". To start with, we must make an important assumption.
The assumption is that the variables have been renamed as necessary, so that the
same variable is never introduced by more than one quantifier in the formula at hand.
This is to prevent accidental name clashes in what follows.
    The actual programming technique we use to implement the conversion to
clausal form is tree transformation, as discussed in Sections 7.11 and 7.12. By rep-
resenting the logical connectives as functors, Predicate Calculus formulae become
structures that can be depicted as trees. Each of the six main stages of conversion
into clausal form is a tree transformation that maps an input tree onto an output tree.
```

*Stage 1 — Removing Implications*

```prolog
We define a predicate implout such that implout(X,Y) means that Y is the formula
derived from X by removing implications.
    implout((P <-> Q),((P1 & Ql) # (~P1 & ~Q1))) :-
            !, implout(P,Pl), implout(Q,Ql).
    implout((P -> Q),(~P1 # Ql))
            !, imptout(P,Pl), implout(Q,Ql).
    implout(all(X,P),all(X,Pl)):- !, implout(P,Pl).
    implout(exists(X,P),exists(X,Pl)):-!, implout(P,Pl).
    implout((P & Q),(P1 & Ql)) :-
            !, imptout(P,Pl), implout(Q,Ql).
    imptout((P # Q),(P1 # Ql)) :-
            !, implout(P,Pl), implout(Q,Ql).
    implout((~P),(~Pl)) :- !, implout(P,Pl).
    impk>ut(P,P).
```

*Stage 2 — Moving Negation Inwards*

```prolog
We need to define two predicates here: negin and neg. Goal negin(X,Y) means that
Y is the formula derived by applying the "negation inwards" transformation to the
whole of X. This is the main thing we will ask questions about. Goal neg(X,Y) means
that Y is the formula derived by applying the transformation to the formula ~X. With
both of these, we assume that stage 1 has been carried out, and that we hence do not
need to deal with -> and <->.
```

<!-- page 287 -->
Appendix B Clausal Form Program Listings

```prolog
negin((~P),Pl) :- !, neg(P,Pl).
negin(all(X,P),all(X,Pl)):- !, negin(P,Pl).
negin(exists(X,P),exists(X,Pl)) :-!, negin(P,Pl).
negin((P & Q),(P1 & Ql)) :-
        !, negin(P,Pl), negin(Q,Ql).
negin((P # Q),(P1 # Ql)) :-
        !, negin(P,Pl), negin(Q,Ql).
negin(P,P).
neg((~P),Pl):-!, negin(P,Pl).
neg(all(X,P),exists(X,Pl)):-!, neg(P,Pl).
neg(exists(X,P),all(X,Pl)):- !, neg(P,Pl).
neg((P & Q),(P1 # Ql)) :- !, neg(P.Pl), neg(Q,Ql).
neg((P # Q),(P1 & Ql)) :- !, neg(P,Pl), neg(Q,Ql).
neg(P,(~P)).
```

*Stage 3 — Skolemising*

```prolog
The predicate skolem has three arguments: corresponding to the original formula,
the transformed formula and the list of variables that have been introduced so far by
universal quantifiers.
    skolem(all(X,P),all(X,Pl),Vars) :-
            !, skolem(P,Pl,[X|Vars]).
    skolem(exists(X,P),P2,Vars):-
            *t
            gensym(f,F),
            Sk =..[F|Vars],
            subst(X,Sk,P,Pl),
            skolem(Pl,P2,Vars).
    skolem((P # Q),(P1 it Ql),Vars) :-
            !, skolem(P,Pl,Vars), skolem(Q,Ql,Vars).
    skolem((P & Q),(P1 & Ql),Vars) :-
            !, skolem(P,Pl,Vars), skolem(Q,Ql,Vars).
    skolem(P,P,_).
This definition makes use of two new predicates. Predicate gensym must be defined
such that the goal gensym (X,Y) causes Y to be instantiated to a new atom built up
from the atom X and a number. This is used to generate Skolem constants that have
not been used before. Predicate gensym is defined in Section 7.8. The second new
predicate that is mentioned is subst. We require subst(Vl,V2,Fl,F2) to be true if the
result of substituting V2 for VI every time it appears in the formula F1 is F2. The
```

<!-- page 288 -->
```prolog
definition of this is left as an exercise for the reader, but it is similar to predicates
defined in Sections 7.5 and 6.5.
```

*Stage 4 — Moving Universal Quantifiers Outwards*

```prolog
After this point, of course, it will be necessary to be able to tell which Prolog atoms
represent Predicate Calculus variables and which represent Predicate Calculus con-
stants. We will no longer have the convenient rule that the variables are precisely
those symbols introduced by quantifiers. Here is the program for moving out and
removing the universal quantifiers:
    univout(all(X,P),Pl):- !, univout(P,Pl).
    univout((P & Q),(P1 & Ql)) :-
            !, univout(P,Pl), univout(Q,Ql).
    univout((P # Q),(P1 # Ql)) :-
            !, univout(P,Pl), univout(Q,Ql). univout(P,P).
These rules define the predicate univout so that univout(X,Y) means that the version
of X with universal quantifiers moved out is Y.
    It should be noted that our definition of univout assumes that this operation will
only be applied after the first three stages are already complete. Hence it makes no
allowance for implications or existential quantifiers in the formula.
```

*Stage 5 — Distributing & over #*

```prolog
The actual program to put a formula into conjunctive normal form is rather more
complicated than the last one. When it comes across something like (P#Q), where
P and Q are any formulas, it must first of all put P and Q into conjunctive normal
forms, PI and Ql say, and only then look to see if the formula as a whole is suitable
for translation by one of the equivalences. The process must happen in this order,
because it may happen that neither of P and Q has & at the top level, but one of PI
and Ql does. Here is the program:
    conjn((P # Q),R) :-
            i • t
            conjn(P,Pl), conjn(Q,Ql),
            conjnl((Pl # Ql),R).
    conjn((P & Q),(P1 & Ql)) :-
                                       !, conjn(P,Pl), conjn(Q,Ql).
    conjn(P,P).
    conjnl(((P & Q) # R),(P1 & Ql)) :-
            !, conjn((P # R),P1), conjn((Q # R),Ql).
    conjnl((P # (Q & R)),(P1 & Ql)) :-
            !, conjn((P # Q),P1), conjn((P # R),Q1).
    conjnl(P,P).
```

<!-- page 289 -->
Appendix B

Clausal Form Program Listings

*Stage 6 — Putting into Clauses*

```prolog
Here, now, is the last part of our program to put a formula in clausal form. We define
first of all the predicate clausify, which involves building up an internal represen-
tation of a collection of clauses. The collection is represented as a list, where each
clause is represented as a structure cl(A,B). In such a structure, A is the list of literals
that are not negated, and B is the list of literals that are negated (but written without
their ~'s). Predicate clausify has three arguments. The first is for the formula, as de-
livered by Stage 5. The second and third are for defining the list of clauses. Predicate
clausify builds a list terminating in a variable, instead of the usual [], and returns this
variable through the third argument. It is then possible for other rules to add things
to the end of the list by instantiating the variable. One feature built into the program
checks that the same atomic formula does not appear both negated and unnegated
within the same clause. If this happens, the clause is not added to the list, because
such a clause is trivially true and contributes nothing. Also, it is checked that the
same literal does not appear twice within a clause.
    clausify((P & Q),C1,C2) :-
            !, clausify(P,Cl,C3), clausify(Q,C3,C2).
    clausify(P,[cl(A,B)|Cs],Cs) :-
            inclause(P,A,[],B,[]),!.
    clausify(_,C,C).
    inclause((P # Q),A,A1,B,B1)
            I
            inclause(P,A2,Al,B2,Bl), inclause(Q,A,A2,B,B2).
    inclause((~P),A,A,Bl,B) :-
            !, notin(P,A), putin(P,B,Bl).
    inclause(P,Al,A,B,B) :- notin(P,B), putin(P,A,Al).
    notin(X,[X|J) :-!, fail.
    notin(X,[jL]):-!, notin(X,L).
    notin(X,[]).
    putin(X,[],[X]):- !.
    putin(X,[X|L],[X[L]):- !.
    putin(X,[Y|L]r[Y|Ll]):- putin(X,L,Ll).
```

*Printing out Clauses*

```prolog
We will now define a predicate pclauses which causes a formula represented in this
way to be displayed according to our notation.
```

<!-- page 290 -->
```prolog
pclauses([]) :- !, nl, nl.
pclauses([cl(A,B) |Cs]) :-
        pclause(A,B), nl, pclauses(Cs).
pclause(L,[]) :-
        !, pdisj(L), write('.').
pclause([],L) :-
        !, write(':-'), pconj(L), write('.').
pclause(Ll,L2) :-
        pdisj(Ll),
        write(':-'), pconj(L2), write('.').
pdisj([L]) :- !, write(L).
pdisj([L|Ls]) :- write(L), write(';'), pdisj(Ls).
pconj([L]) :- !, write(L).
pconj([L|Ls]) :- write(L), write(', '), pconj(Ls).
```
