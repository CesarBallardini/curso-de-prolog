:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(ebg).

regla_taza1(R) :-
    aprender(taza, taza1, taza(taza1), R).

test(taza1, [true(R =@= (taza(A) :- [ peso(A, P), P < 400,
                                      parte(A, B), asa(B),
                                      parte(A, C), concava(C),
                                      abierta_arriba(C),
                                      parte(A, D), base(D),
                                      plana(D) ]))]) :-
    regla_taza1(R).

test(taza2, [true(R =@= (taza(A) :- [ material(A, carton),
                                      parte(A, B), asa(B),
                                      parte(A, C), concava(C),
                                      abierta_arriba(C),
                                      parte(A, D), base(D),
                                      plana(D) ]))]) :-
    aprender(taza, taza2, taza(taza2), R).

test(vaso1, [fail]) :-
    aprender(taza, vaso1, taza(vaso1), _).

% La regla aprendida no tiene constantes del ejemplo.
test(sin_constantes_del_ejemplo, [true]) :-
    regla_taza1(R),
    \+ ( sub_term(X, R),
         atom(X),
         memberchk(X, [taza1, asa1, cuerpo1, base1, loza, blanco]) ).

% La regla reconoce el ejemplo del que sale.
test(reconoce_su_ejemplo, [true]) :-
    regla_taza1(R),
    hechos(taza1, Hs),
    aplicar(taza, R, Hs, taza(taza1)).

test(liviano_operacional, [true(C == liviano(A))]) :-
    operacionales(taza, Ops),
    aprender_con(taza, [liviano/1|Ops], taza1, taza(taza1),
                 (taza(A) :- [C|_])).

test(abuelo, [true(R =@= (abuelo(A, N) :- [varon(A), padre(A, P),
                                             padre(P, N)]))]) :-
    aprender(familia, familia, abuelo(juan, luis), R).

test(abuelo_capitulo_3, [true(R =@= (abuelo(A, N) :- [varon(A),
                                                        progenitor(A, P),
                                                        progenitor(P, N)]))]) :-
    aprender_con(familia, [progenitor/2, varon/1, mujer/1, padre/2, madre/2],
                 familia, abuelo(juan, luis), R).

test(abuela, [true(R =@= (abuela(A, N) :- [mujer(A), madre(A, P),
                                             padre(P, N)]))]) :-
    aprender(familia, familia, abuela(marta, luis), R).

test(reconocidas, [true(T1-T2-T == [o1, o9]-[o9, o25, o41]-
                                   [o1, o9, o25, o41])]) :-
    regla_taza1(R1),
    aprender(taza, taza2, taza(taza2), R2),
    reconocidas(taza, [R1], T1),
    reconocidas(taza, [R2], T2),
    reconocidas(taza, [R1, R2], T).

% Las dos reglas juntas reconocen lo mismo que la teoría, con menos
% inferencias.
test(igual_que_la_teoria, [true(Ts == Rs)]) :-
    regla_taza1(R1),
    aprender(taza, taza2, taza(taza2), R2),
    clasificar_con_teoria(taza, Ts),
    reconocidas(taza, [R1, R2], Rs).

test(mas_barato, [true(NR < NT)]) :-
    regla_taza1(R1),
    aprender(taza, taza2, taza(taza2), R2),
    inferencias(clasificar_con_teoria(taza, _), NT),
    inferencias(reconocidas(taza, [R1, R2], _), NR).

test(mostrar, [true(S == "taza(A) :-\n    material(A, carton),\n")]) :-
    aprender(taza, taza2, taza(taza2), R),
    with_output_to(string(S0), mostrar(R)),
    sub_string(S0, 0, 36, _, S).

test(reconocidas_de, [true(T == [o9, o25, o41])]) :-
    reconocidas_de([taza2], T).

test(costos, [true(( R < T, U < T ))]) :-
    costos(T, R, U).

test(mostrar_aprendida, [true(sub_string(S, 0, _, _, "abuelo(A, B) :-"))]) :-
    with_output_to(string(S),
                   mostrar_aprendida(familia, familia, abuelo(juan, luis))).

% ebg/5 da una regla por cada prueba: liviano por el peso y por el
% material.
test(ebg_dos_pruebas, all(P == [peso, material])) :-
    hechos(taza1, H0),
    operacionales(taza, Ops),
    ebg(taza, Ops, [material(taza1, carton)|H0], taza(taza1),
        (_ :- [C|_])),
    functor(C, P, _).

test(ebg_sin_prueba, [fail]) :-
    hechos(vaso1, Hs),
    operacionales(taza, Ops),
    ebg(taza, Ops, Hs, taza(vaso1), _).

% generalizar//5: la copia general recibe solo lo que impone la regla.
test(generalizar, [nondet, true(G-L =@= liviano(X)-[peso(X, P), P < 400])]) :-
    hechos(taza1, Hs),
    phrase(ebg:generalizar(taza, [peso/2, material/2], Hs, liviano(taza1),
                           G),
           L).

test(mostrar_aprendida_con,
     [true(S == "taza(A) :-\n    se_levanta(A),\n    parte(A, B),\n    concava(B),\n    abierta_arriba(B),\n    parte(A, C),\n    base(C),\n    plana(C).\n")]) :-
    operacionales(taza, Ops),
    with_output_to(string(S),
                   mostrar_aprendida_con(taza, [se_levanta/1|Ops], taza1,
                                         taza(taza1))).

:- end_tests(ebg).
