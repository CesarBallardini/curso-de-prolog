:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(soluciones).

test(ej1, [true(R =@= [f(g(A), A), [_, _|_]])]) :-
    lgg(f(g(a), a), f(g(b), b), G1),
    lgg([1, 2, 3], [4, 5], G2),
    R = [G1, G2],
    subsume((p(X) :- [q(X, _)]), (p(a) :- [q(a, a)])),
    \+ subsume((p(a) :- []), (p(_) :- [])).

test(ej2, [true(G =@= pertenece(A, [A|_]))]) :-
    lgg_lista([pertenece(1, [1]), pertenece(z, [z, y]),
               pertenece(b, [b, c, d])], G).

% El orden de la lista no cambia la lgg, salvo el nombre de las variables.
test(ej2_orden, [true]) :-
    Ts = [pertenece(1, [1]), pertenece(z, [z, y]), pertenece(b, [b, c, d])],
    lgg_lista(Ts, G),
    forall(permutation(Ts, Ps),
           ( lgg_lista(Ps, G1),
             G1 =@= G )).

test(ej3, [true(R =@= (p(X) :- [q(X, _)]))]) :-
    lgg_clausula((p(a) :- [q(a, b), q(a, c)]), (p(d) :- [q(d, e)]), C),
    reducida(C, R).

% La cláusula reducida y la original se subsumen mutuamente.
test(ej3_equivalente, [true]) :-
    C = (p(X) :- [q(X, Y), q(X, _), r(Y)]),
    reducida(C, R),
    subsume(C, R),
    subsume(R, C).

test(ej4, [true(H-N =@= [(abuelo(A, B) :- [progenitor(C, B), padre(A, C)])]
                        -3)]) :-
    aprender_asc_corta(abuelo, H, N).

test(ej5, [true(R == [2-0-0, 2-0-0])]) :-
    modelo_fondo(M),
    aprender_asc(abuela, H1, _),
    evaluar_en(abuela, H1, M, A1, F1, N1),
    aprender_desc(abuela, H2, _),
    evaluar_en(abuela, H2, M, A2, F2, N2),
    R = [A1-F1-N1, A2-F2-N2].

test(ej6, [true(Hechos == [(hermano(pedro, tomas) :- []),
                           (hermano(tomas, pedro) :- [])])]) :-
    hermano_con_tomas(_, [_|Hechos], _).

test(ej6_distintos, [true(R == 82-3208)]) :-
    rlgg_con_distintos(Hechos, Literales),
    R = Hechos-Literales.

test(ej7, [true(R == 261-167)]) :-
    ejemplos(abuelo, [E|_], Negs),
    modelo_fondo(M),
    lenguaje(L),
    generadas_sin_poda(E, Negs, M, L, 2, N1),
    descendente([E], Negs, M, L, 2, _, N2),
    R = N1-N2.

test(ej8, [true(R == 0-40)]) :-
    ejemplos(abuelo, Pos, _),
    modelo_fondo(M),
    lenguaje(L),
    inductivo(Pos, [abuelo(pedro, eva)], M, L, 3, H1, _),
    evaluar_en(abuelo, H1, M, _, F1, _),
    inductivo(Pos, [abuelo(juan, ana)], M, L, 3, H2, _),
    evaluar_en(abuelo, H2, M, _, F2, _),
    R = F1-F2.

test(ej9, [true(N == 201669)]) :-
    ejemplos(hermano, Pos, Negs),
    modelo_fondo(M),
    lenguaje(L),
    inductivo(Pos, Negs, M, L, 4, _, N).

test(ej10_mismo_resultado, [true(H1 =@= H2)]) :-
    aprender_asc(hermano, H1, _),
    aprender_asc_con(reducir_ordenado, hermano, H2, _).

test(ej10_verdadero, [true(Xs == [a-b])]) :-
    findall(X-Y, verdadero_ordenado([q(X, Y), p(X)], [p(a), q(a, b), q(c, d)]),
            Xs).

test(ej11, [true(Ns == [139, 272, 676])]) :-
    findall(N, ( member(K, [1, 3, 10]),
                 aprender_haz(K, antepasado, _, N) ),
            Ns).

test(ej11_hermano, [true(H == [(hermano(luis, eva) :- []),
                               (hermano(pedro, ana) :- [])])]) :-
    aprender_haz(3, hermano, H, _).

:- end_tests(soluciones).
