# A Answers to Selected Exercises

<!-- page 281 -->
Answers to Selected Exercises

```prolog
We include here suggested answers to some of the exercises that appear in the text.
With most programming exercises, there is rarely a single correct answer, and you
may well have a good answer that looks different from what we suggest. In any case,
you should always try out your program on your local Prolog system, to see whether
it really works. Even if you have written a correct program that is different, it may
still be instructive to spend some time looking at an alternative approach to the same
problem.
Exercise 1.3. Here are possible definitions of the family relationships.
    is_mother(Mum) :- mother(Mum, Child).
    is_father(Dad) :- father(Dad, Child).
    is_son(Son):- parent(Par, Son), male(Son).
    sister_of(Sis, Pers) :-
            parent(Par, Sis), parent(Par, Pers),
            female(Sis), diff(Sis, Pers).
    granpa_of(Gpa, X) :- parent(Par, X), father(Gpa, Par).
    sibling(Sl,S2) :-
            parent(Par, Si), parent(Par, S2), diff(Sl, S2).
Note that we are using the predicate diff in the definition of sister_of and sibling.
This prevents the system concluding that somebody can be a sister or sibling of
themselves. You will not be able to define diff at this stage.
Exercise 5.2. The following program reads in characters (from the current input file)
indefinitely, printing them out again with a's changed to b's.
    go :- repeat, get_char(C), deal_with(C), fail.
    deaLwith(a) :- !, put_char(b).
```

<!-- page 282 -->
```prolog
    deal_with(X) :- put(X).
The "cut" in the first deal_with rule is essential (why?).
Exercise 7.9. Here is a program that generates Pythagorean triples:
    pythag(X, Y, Z) :-
            intriple(X, Y, Z),
            Sumsq is X*X + Y*Y, Sumsq is Z * Z.
    intriple(X, Y, Z) :-
            is_integer(Sum),
            minus(Sum, X, Suml), minus(Suml, Y, Z).
    minus(Sum, Sum, 0).
    minus(Sum, Dl, D2) :-
            Sum > 0, Suml is Sum - 1,
            minus(Suml, Dl, D3), D2 is D3 + 1.
    is_integer(0).
    is_integer(N) :- is_integer(Nl), N is Nl + 1.
The program uses the predicate intriple to generate possible triples of integers X, Y, Z.
It then checks to see whether this triple really is a Pythagorean triple. The definition
of intriple has to guarantee that all triples of integers will eventually be generated.
It first of all generates an integer that is the sum of X, Y and Z. Then it uses a non-
deterministic subtraction predicate, minus, to generate values of X, Y and Z from that.
Exercise 9.1. Here is the program for translating a simple grammar rule into Prolog.
It is assumed here that the rule contains no phrase types with extra arguments, no
goals inside curly brackets and no disjunctions or cuts.
    ?- op(1199,xfx,~>).
    translate((Pl—>P2),(G1:-G2)) :-
            left_hand_side(Pl,SO,S,Gl),
            right_hand_side(P2,S0,S,G2).
    left_hand_side(P0,S0,S,G) :-
            nonvar(PO), tag(P0,S0,S,G).
    right_hand_side((Pl,P2),S0,S,G) :-
            ;
            right_hand_side(Pl,SO,Sl,Gl),
            right_hand_side(P2,Sl,S,G2),
            and(Gl,G2,G).
    right_hand_side(P,SO,S,true) :-
            islist(P),
```

<!-- page 283 -->
Appendix A Answers to Selected Exercises

```prolog
            append(P,S,SO).
    right_hand_side(P,SO,S,G)
                            tag(P,S0,S,G).
    tag(P,S0,S,G) :- atom(P), G =..[P,S0,S].
    and(true,G,G) :-!.
    and(G,true,G) :- !. and(Gl,G2,(Gl,G2)).
    islist([]) :- !. i s l i s t ( L U ) .
    append([A|B],C,[A|D]) :- append(B,C,D).
    append([],X,X).
In this program, variables beginning with P stand for phrase descriptions (atoms, or
lists of words) in grammar rules. Variables beginning with G stand for Prolog goals.
Variables beginning with S stand for arguments of the Prolog goals (which represent
sequences of words). In case you are interested, there follows a program that will
handle the more general cases of grammar rule translation. One way in which a
Prolog system can handle grammar rules is to have a modified version of consult, in
which a clause of the form A --> B is translated before it is added to the database. We
have defined a pair of operators to act as curly brackets "{" and "}", but some Prolog
implementations may have built-in definitions, so that the term {X} is another form
of the structure '{}'(X).
    ?- op(1101,fx,").
    ?- op(1100,xf,").
    ?- op(1199,xfx,-->).
    translate((PO—>Q0),(P:-Q)) :-
            left_hand_side(PO,SO,S,P),
            right_hand_side(QO,SO,S,Ql),
            flatten(Ql,Q).
    left_hand_side((NT,Ts),SO,S,P) :- !,
            nonvar(NT),
            islist(Ts),
            tag(NT,SO,Sl,P),
            append(Ts,S,Sl).
    left_hand_side(NT,SO,S,P) :-
            nonvar(NT), tag(NT,SO,S,P).
    right_hand_side((Xl,X2),S0,S,P):-
                                 !,
            right_hand_side(Xl,SO,Sl,Pl),
            right_hand_side(X2,Sl,S,P2),
            and(Pl,P2,P).
```

<!-- page 284 -->
```prolog
    rightJiand_side((Xl;X2),S0,S,(Pl;P2))
                                    :-
            !, or(Xl,S0,S,Pl), or(X2,S0,S,P2).
    right_hand_side(P,S,S,P):-
                           !.
    right_hand_side(!,S,S,!):-
                           !.
    right_hand_side(Ts,SO,S,true)
                             :-
            islist(Ts),
            i • f
            append(Ts,S,S0).
    right_hand_side(X,SO,S,P):-
                            tag(X,S0,S,P).
    or(X,S0,S,P) :-
            right_hand_side(X,SOa,S,Pa),
            ( var(SOa), SOa = S, !,
                    S0=S0a, P=Pa; P=(S0=S0a,Pa) ).
    tag(X,S0,S,P) :-
            X =.. [F|A], append(A,[SO,S],AX), P =.. [F|AX],
    and(true,P,P):-!.
    and(P,true,P):-!.
    and(P,Q,(P,Q)).
    flatten (A, A) :- var(A), !.
    flatten((A,B),C) :- !, flattenl(A,C,R), flatten(B,R).
    flatten(A,A).
    flattenl(A,(A,R),R) :- var(A), !.
    flattenl((A,B),C,R) :-
            !, flattenl(A,C,Rl), flattenl(B,Rl,R).
    flattenl(A,(A,R),R).
    islist([]) -
              -
    i s l i s t ( L U ) .
    append([A|B],C,[A|D]) :- append(B,C,D).
    append([],X,X).
Exercise 9.2. The definition of the general version of phrase is as follows:
    phrase(Ptype,Words) :-
            Ptype =.. [Pred|Args],
            append(Args, [Words, []],Newargs),
            Goal=.. [Pred|Newargs],
            call(Goal).
where append is defined as in Section 3.6.
```
