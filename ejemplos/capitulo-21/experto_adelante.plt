:- encoding(utf8).

:- begin_tests(experto_adelante, [ setup(reiniciar), cleanup(reiniciar) ]).

test(hechos_iniciales, [ setup(reiniciar), true(N == 7) ]) :-
    aggregate_all(count, hecho(_), N).

test(punto_fijo, [ setup(reiniciar), true(N == 34) ]) :-
    encadenar,
    aggregate_all(count, hecho(_), N).

test(abuelos, [ setup((reiniciar, encadenar)),
                all(N == [sofia, luis, eva]) ]) :-
    hecho(abuelo(juan, N)).

test(hermanos, [ setup((reiniciar, encadenar)),
                 all(A-B == [ana-pedro, pedro-ana, luis-eva, eva-luis]) ]) :-
    hecho(hermanos(A, B)).

test(antepasados_de_sofia, [ setup((reiniciar, encadenar)),
                             true(L == [ana, juan, marta]) ]) :-
    setof(A, hecho(antepasado(A, sofia)), L).

test(explicacion, [ setup((reiniciar, encadenar)),
                    true(R-C == abuelo-[padre(juan, ana),
                                        progenitor(ana, sofia)]) ]) :-
    derivado(abuelo(juan, sofia), R, C).

% Una segunda pasada no agrega nada: la base ya está en su punto fijo.
test(segunda_pasada, [ setup((reiniciar, encadenar)), true(N == 34) ]) :-
    encadenar,
    aggregate_all(count, hecho(_), N).

:- end_tests(experto_adelante).
