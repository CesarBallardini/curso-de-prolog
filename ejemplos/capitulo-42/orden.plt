:- encoding(utf8).

:- begin_tests(orden).

test(vacio, [true(V == 0)]) :-
    inicial(tateti(3), P),
    evaluar(tateti(3), P, V).

% x en el centro: 8 líneas abiertas para x y 4 para o.
test(centro, [true(V == 4)]) :-
    evaluar(tateti(3), pos([v, v, v, v, x, v, v, v, v], o), V).

test(esquina, [true(V == 3)]) :-
    evaluar(tateti(3), pos([x, v, v, v, v, v, v, v, v], o), V).

test(ordenar, [true(Js == [5, 1, 3, 7, 9, 2, 4, 6, 8])]) :-
    inicial(tateti(3), P),
    findall(J-P1, jugada(tateti(3), P, J, P1), Hijos0),
    ordenar(mejores, tateti(3), max, Hijos0, Hijos),
    pairs_keys(Hijos, Js).

test(ordenar_peores, [true(Js == [2, 4, 6, 8, 1, 3, 7, 9, 5])]) :-
    inicial(tateti(3), P),
    findall(J-P1, jugada(tateti(3), P, J, P1), Hijos0),
    ordenar(peores, tateti(3), max, Hijos0, Hijos),
    pairs_keys(Hijos, Js).

% El orden cambia la cantidad de nodos, no el valor.
test(completo, [true(R == [natural-1-0-20866, mejores-5-0-6010,
                           peores-2-0-34178])]) :-
    inicial(tateti(3), P),
    findall(O-J-V-N, ( member(O, [natural, mejores, peores]),
                       alfabeta(O, tateti(3), P, 9, J, V, N) ), R).

% Con la evaluación, la búsqueda limitada elige el centro.
test(limitada, [true(Js == [5, 5, 5, 5])]) :-
    inicial(tateti(3), P),
    findall(J, ( between(1, 4, D),
                 alfabeta(natural, tateti(3), P, D, J, _, _) ), Js).

% Una de cada cuatro posiciones después de dos jugadas.
test(mismo_valor, [true(Distintas == [])]) :-
    inicial(tateti(3), P0),
    findall(P, ( jugada(tateti(3), P0, _, P1),
                 jugada(tateti(3), P1, _, P) ), Ps),
    findall(P, ( nth0(I, Ps, P),
                 I mod 4 =:= 0,
                 alfabeta(natural, tateti(3), P, 7, _, V1, _),
                 alfabeta(mejores, tateti(3), P, 7, _, V2, _),
                 V1 =\= V2 ), Distintas).

test(abierta) :-
    abierta([x, v, v, v, o, v, v, v, v], o, [1, 2, 3]).

test(cerrada, [fail]) :-
    abierta([x, v, v, v, o, v, v, v, v], o, [1, 5, 9]).

test(ordenar_natural, [true(H == [1-a, 2-b])]) :-
    ordenar(natural, tateti(3), max, [1-a, 2-b], H).

% Para min, las mejores jugadas son las de menor evaluación: el centro,
% después las esquinas y al final los bordes.
test(ordenar_min, [true(Js == [5, 3, 7, 9, 2, 4, 6, 8])]) :-
    P0 = pos([x, v, v, v, v, v, v, v, v], o),
    findall(J-P, jugada(tateti(3), P0, J, P), H0),
    ordenar(mejores, tateti(3), min, H0, H),
    pairs_keys(H, Js).

:- end_tests(orden).
