:- encoding(utf8).

:- use_module(semantica38).

:- begin_tests(motor).

% caminos(-Cs): el grafo de Nilsson y Małuszyński, con un ciclo.
caminos([ (arco(a, b) :- true), (arco(b, a) :- true),
          (camino(X, Y) :- arco(X, Y)),
          (camino(X, Y) :- camino(X, Z), arco(Z, Y)) ]).

test(base_atomos, [true(As == [p, q(a, 1), q(b, 2)])]) :-
    base([q(b, 2), p, q(a, 1), p], B),
    atomos(B, As).

test(agregar, [true(Ns == [q(c)])]) :-
    base([q(a), q(b)], B0),
    agregar([q(b), q(c), q(c)], B0, B, Ns),
    contiene(B, q(c)).

test(contiene_no, [fail]) :-
    base([q(a)], B),
    contiene(B, q(b)).

% Con el primer argumento ligado, en_base/2 consulta una sola lista.
test(en_base_ligado, [all(Y == [2, 3])]) :-
    base([r(a, 2), r(a, 3), r(b, 4), s(a, 5)], B),
    en_base(r(a, Y), B).

test(en_base_libre, [all(X-Y == [a-2, a-3, b-4])]) :-
    base([r(a, 2), r(a, 3), r(b, 4), s(a, 5)], B),
    en_base(r(X, Y), B).

test(separar, [true(Hs-Rs =@= [p(a)]-[r(q(X), [p(X)])])]) :-
    separar([(p(a) :- true), (q(X) :- p(X))], Hs, Rs).

test(cumplir, [all(X == [3])]) :-
    base([p(1), p(2), p(3), q(2)], B),
    cumplir([p(X), \+ q(X), X > 1], B).

test(cumplir_is, [all(Y == [3])]) :-
    base([n(2)], B),
    cumplir([n(X), Y is X + 1], B).

% Los literales anteriores al elegido van del más cercano al más lejano,
% y la negación al final.
test(variantes,
     [true(Vs =@= [v(c(X), q(X, Z), [p(X)], []),
                   v(c(X1), r(Y1), [s(Y1), p(X1), \+ t(X1)], [])])]) :-
    variantes([ r(c(X), [p(X), q(X, Z)]),
                r(c(X1), [p(X1), \+ t(X1), s(Y1), r(Y1)]) ],
              [q/2, r/1], Vs),
    ignore(Z = Z).

test(bloque, [true(C == costo(3, 6))]) :-
    caminos(Cs),
    separar(Cs, Hs, Rs),
    base(Hs, B0),
    bloque(Rs, [camino/2], B0, _, costo(0, 0), C).

test(iterar_sin_nuevos, [true(C == costo(0, 0))]) :-
    base([p(a)], B),
    iterar([v(q(X), p(X), [], [])], B, B, [], _, costo(0, 0), C).

test(semi_ingenua, [true(M-C == [ arco(a, b), arco(b, a),
                                  camino(a, a), camino(a, b),
                                  camino(b, a), camino(b, b) ]-costo(3, 6))]) :-
    caminos(Cs),
    semi_ingenua(Cs, M, C).

% El mismo modelo que la evaluación semi-ingenua del capítulo 38.
test(como_capitulo38, [true(C == costo(41, 820))]) :-
    clausulas(cadena(40), Cs),
    semi_ingenua(Cs, M, C),
    semi_ingenua_de(Cs, [], M38, _),
    M == M38.

test(con_negacion,
     [error(domain_error(programa_sin_negacion, \+ q(a)))]) :-
    semi_ingenua([(q(b) :- true), (p :- \+ q(a))], _, _).

test(no_seguro, [error(domain_error(datalog_seguro, cabeza_libre(p(_))))]) :-
    semi_ingenua([(p(_) :- true)], _, _).

test(exigir_definido) :-
    exigir_definido([(p :- q), (q :- true)]).

:- end_tests(motor).
