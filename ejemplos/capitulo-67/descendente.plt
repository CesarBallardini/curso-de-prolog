:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(descendente).

test(refinamientos_de_la_raiz, [true(K == 29)]) :-
    lenguaje(L),
    aggregate_all(count, refinar(L, (abuelo(_, _) :- []), _), K).

test(refinar_no_liga, [true(C0 =@= (abuelo(_, _) :- []))]) :-
    C0 = (abuelo(_, _) :- []),
    lenguaje(L),
    forall(refinar(L, C0, _), true).

% Todo refinamiento es subsumido por la cláusula de la que sale.
test(refinar_especializa, [true]) :-
    lenguaje(L),
    C0 = (abuelo(A, _) :- [padre(A, _)]),
    forall(refinar(L, C0, C), subsume(C0, C)).

test(sin_tautologias, [true]) :-
    forall(refinar([p/2], (p(_, _) :- []), (H :- B)),
           \+ ( member(X, B), X == H )).

test(abuelo, [true(H-N =@= [(abuelo(A, B) :- [padre(A, C), padre(C, B)]),
                            (abuelo(D, E) :- [padre(D, F), madre(F, E)])]
                           -334)]) :-
    aprender_desc(abuelo, H, N).

test(abuela, [true(H =@= [(abuela(A, B) :- [padre(C, B), madre(A, C)])])]) :-
    aprender_desc(abuela, H, _).

% Con tres refinamientos no alcanza: los positivos quedan como hechos.
test(hermano_tres, [true(H-N == [(hermano(luis, eva) :- []),
                                 (hermano(pedro, ana) :- [])]-20078)]) :-
    aprender_desc(hermano, H, N).

test(hermano_cuatro, [true(H-N =@= [(hermano(A, B) :- [varon(A), mujer(B),
                                                      padre(C, A),
                                                      padre(C, B)])]
                                  -8352)]) :-
    ejemplos(hermano, Pos, Negs),
    modelo_fondo(M),
    lenguaje(L),
    descendente(Pos, Negs, M, L, 4, H, N).

test(evaluar_abuelo, [true(R == 3-0-0)]) :-
    aprender_desc(abuelo, H, _),
    modelo_fondo(M),
    evaluar_en(abuelo, H, M, A, FP, FN),
    R = A-FP-FN.

test(extension_general, [true(K == 49)]) :-
    modelo_fondo(M),
    extension_en(abuelo, [(abuelo(_, _) :- [])], M, As),
    length(As, K).

% refinamiento/3: unificar las dos variables o agregar un literal con
% al menos una variable de la cláusula.
test(refinamiento, [true(Cs =@= [(p(X, X) :- []), (p(Y, _) :- [q(Y)]),
                                 (p(_, W) :- [q(W)])])]) :-
    findall(C, descendente:refinamiento([q/1], (p(_, _) :- []), C), Cs).

% Con una sola variable no hay nada que unificar, y q(Y) ya está.
test(refinamiento_no_repite, [true(Cs == [])]) :-
    findall(C, descendente:refinamiento([q/1], (p(Y) :- [q(Y)]), C), Cs).

test(buscar_limite_cero, [true(R-N == ninguna-5)]) :-
    ejemplos(abuelo, _, Negs),
    modelo_fondo(M),
    lenguaje(L),
    descendente:buscar(0, (abuelo(_, _) :- []), abuelo(juan, eva)-Negs-M-L,
                       R, 5, N).

test(buscar, [true(R-N =@= encontrada((abuelo(A, B) :- [padre(A, C),
                                                        padre(C, B)]))-138)]) :-
    ejemplos(abuelo, _, Negs),
    modelo_fondo(M),
    lenguaje(L),
    descendente:buscar(2, (abuelo(_, _) :- []), abuelo(juan, eva)-Negs-M-L,
                       R, 0, N).

% buscar_clausula/8 suma las cláusulas de los niveles 0, 1 y 2: 0 + 29 + 138.
test(buscar_clausula, [true(R-N =@= encontrada((abuelo(A, B) :- [padre(A, C),
                                                padre(C, B)]))-167)]) :-
    ejemplos(abuelo, _, Negs),
    modelo_fondo(M),
    lenguaje(L),
    buscar_clausula(abuelo(juan, eva), Negs, M, L, 3, R, 0, N).

test(buscar_clausula_sin_resultado, [true(R-N == ninguna-29)]) :-
    ejemplos(abuelo, _, Negs),
    modelo_fondo(M),
    lenguaje(L),
    buscar_clausula(abuelo(juan, eva), Negs, M, L, 1, R, 0, N).

:- end_tests(descendente).
