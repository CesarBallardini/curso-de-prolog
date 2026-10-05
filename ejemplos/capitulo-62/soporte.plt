:- encoding(utf8).

:- begin_tests(soporte).

test(socrates, [true(P == [r(1, 3, [-hombre(socrates)]), r(2, 4, [])])]) :-
    refutar_soporte([[-hombre(X), +mortal(X)], [+hombre(socrates)]],
                    [[-mortal(socrates)]], 5, P).

% Ningún paso usa solo hipótesis: la cadena x, y, z no aparece.
test(cadena, [true(P == [ r(4, 9, [-d]), r(3, 10, [-c]), r(2, 11, [-b]),
                          r(1, 12, [-a]), r(5, 13, [])
                        ])]) :-
    hipotesis(H),
    refutar_soporte(H, [[-e]], 8, P).

% Con hipótesis inconsistentes y sin soporte, no hay refutación: la
% estrategia supone que las hipótesis son consistentes.
test(sin_soporte, [fail]) :-
    refutar_soporte([[+p], [-p]], [], 3, _).

test(paso_soporte, all(P == [r(1, 2, [])])) :-
    soporte:paso_soporte(1, [[+p], [-p]], P, _).

test(paso_hipotesis, [fail]) :-
    soporte:paso_soporte(2, [[+p], [-p]], _, _).

test(derivar_soporte, all(P == [[r(1, 3, [-hombre(socrates)]),
                                 r(2, 4, [])]])) :-
    length(P, 2),
    soporte:derivar_soporte(P, 2, [[-hombre(X), +mortal(X)],
                                   [+hombre(socrates)],
                                   [-mortal(socrates)]]).

% El soporte cuesta menos que la estrategia lineal, y esta, menos que la
% general.
test(comparar, [true((S < L, L < G))]) :-
    hipotesis(H),
    comparar_estrategias(H, [[-e]], [general-G, lineal-L, soporte-S]).

hipotesis([ [-a, +b], [-b, +c], [-c, +d], [-d, +e], [+a],
            [-x, +y], [-y, +z], [+x]
          ]).

:- end_tests(soporte).
