:- encoding(utf8).

:- begin_tests(intervalos).

test(division, [true(V == i(-10, 10))]) :-
    dom_operar(intervalos, /, i(1, 10), i(-2, 3), V).

test(division_infinita, [true(V == i(0, sup))]) :-
    dom_operar(intervalos, /, i(0, sup), i(1, sup), V).

test(producto, [true(V == i(inf, sup))]) :-
    dom_operar(intervalos, *, i(inf, sup), i(inf, sup), V).

test(resta, [true(V == i(-9, sup))]) :-
    dom_operar(intervalos, -, i(1, sup), i(0, 10), V).

test(ensanchar, [true(Vs == [i(0, 5), i(inf, 5), i(0, sup)])]) :-
    dom_ensanchar(intervalos, i(3, 5), i(2, 5), V1),
    dom_ensanchar(intervalos, i(0, 5), i(-1, 5), V2),
    dom_ensanchar(intervalos, i(0, 5), i(0, 6), V3),
    Vs = [V1, V2, V3].

test(refinar, [true(V == i(0, 9))]) :-
    dom_refinar(intervalos, <, i(0, sup), i(10, 10), V).

test(refinar_vacio, [fail]) :-
    dom_refinar(intervalos, >, i(inf, 0), i(0, 0), _).

test(cuenta, [true(F-Os == estado(intervalos, [n-i(1, sup), x-i(0, 0)])-
                  [escribe(bin(/, num(100), bin(+, id(x), num(1))),
                           i(100, 100))])]) :-
    programa_caso(cuenta, P, Es),
    analisis(intervalos, P, Es, F, Os).

% El ensanchamiento pierde la cota superior del bucle.
test(diez, [true(F == estado(intervalos, [i-i(10, sup)]))]) :-
    programa_caso(diez, P, Es),
    analisis(intervalos, P, Es, F, _).

test(siempre, [true(Os == [siempre(rel(>, id(n), num(0))),
                           escribe(id(n), i(1, 3))])]) :-
    programa_ejemplo(cuenta, P),
    analisis(intervalos, P, [], _, Os).

% Bucles anidados: j vuelve a 0 en cada vuelta de afuera, y el
% ensanchamiento de la cabeza de afuera lleva j a i(0, sup).
test(anidados, [true(F == estado(intervalos, [i-i(3, sup), j-i(0, sup),
                                             s-i(0, sup)]))]) :-
    analizar("mientras i < 3 hacer j := 0;
                mientras j < 2 hacer s := s + 1; j := j + 1 fin;
                i := i + 1 fin", P),
    analisis(intervalos, P, [], F, _).

test(cubre, [forall(caso(N, _, _))]) :-
    programa_caso(N, P, Es),
    analisis(intervalos, P, Es, F, Os),
    muestra(N, Cs),
    forall(member(C, Cs), cubre(F, Os, C)).

:- end_tests(intervalos).
