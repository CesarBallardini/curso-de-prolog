:- encoding(utf8).

:- use_module(library(apply)).
:- use_module(library(lists)).

:- begin_tests(teorias).

test(reglas_taza, [true(N == 7)]) :-
    aggregate_all(count, regla(taza, _), N).

% Las reglas de la familia son las del capítulo 3, leídas, no copiadas.
test(reglas_familia, [true(N == 4)]) :-
    aggregate_all(count, regla(familia, _), N).

test(regla_abuelo, [true(R =@= (abuelo(A, N) :- varon(A),
                                  progenitor(A, P),
                                  progenitor(P, N)))]) :-
    once(( regla(familia, R),
           R = (abuelo(_, _) :- _) )).

test(hechos_sin_variables, [true]) :-
    forall(member(E, [taza1, taza2, vaso1, familia]),
           ( hechos(E, Hs),
             ground(Hs) )).

test(hechos_taza1, [true(N == 12)]) :-
    hechos(taza1, Hs),
    length(Hs, N).

test(operacionales_no_son_reglas, [true]) :-
    forall(( member(T, [taza, familia]),
             operacionales(T, Ps),
             member(Nombre/Aridad, Ps) ),
           ( functor(C, Nombre, Aridad),
             \+ regla(T, (C :- _)) )).

test(poblacion, [true(N == 48)]) :-
    poblacion(Os),
    length(Os, N).

test(poblacion_primero, [true(O-Hs == o1-[peso(o1, 150), material(o1, loza),
                                          parte(o1, a1), asa(a1),
                                          parte(o1, c1), concava(c1),
                                          abierta_arriba(c1),
                                          parte(o1, b1), base(b1),
                                          plana(b1)])]) :-
    poblacion([O-Hs|_]).

:- end_tests(teorias).
