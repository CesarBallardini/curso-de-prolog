:- encoding(utf8).

:- use_module(programas).

:- begin_tests(corte).

test(maximo, all(M == [4])) :-
    resolver(maximo, maximo(4, 3, M)).

test(maximo_segundo, all(M == [4])) :-
    resolver(maximo, maximo(3, 4, M)).

test(nativo, [true(Rs == Ns)]) :-
    findall(maximo(4, 3, M), resolver(maximo, maximo(4, 3, M)), Rs),
    respuestas_nativas(maximo, maximo(4, 3, _), Ns).

test(primero, all(X == [a])) :-
    resolver(corte, primero(X, [a, b, c])).

% Un corte en la consulta deja solo la primera respuesta.
test(consulta, all(X == [[]])) :-
    resolver(listas, (concatenar(X, _, [1, 2]), !)).

test(suma, all(S == [5050])) :-
    resolver(corte, suma_hasta(100, S)).

% Con los cortes, la pila y el rastro no crecen con la lista.
test(medir, [true(E-T == 1-1)]) :-
    medir(corte, suma_hasta(100, _),
          [_, _, _, _, elecciones-E, rastro-T, _]).

test(sin_cortes, all(D == [ana, pedro, luis, eva])) :-
    resolver(familia, antepasado(juan, D)).

% cortar/4 deja los puntos de elección de más abajo y purga el rastro:
% de las entradas posteriores al que queda, solo las celdas anteriores a
% su marca.
test(cortar, [true(Ms-P-R == [r]-[eleccion(y, [], 1, 2), eleccion(z, [], 0, 0)]-[1, 0])]) :-
    pila(P0),
    empty_assoc(A),
    corte:cortar(2, [r], m([], P0, A, [5, 1, 0], 6, med(0, 0, 0, 0, 0)),
                 m(Ms, P, _, R, _, _)).

test(cortar_todo, [true(P-R == []-[])]) :-
    pila(P0),
    empty_assoc(A),
    corte:cortar(0, [r], m([], P0, A, [5, 1, 0], 6, med(0, 0, 0, 0, 0)),
                 m(_, P, _, R, _, _)).

% Una altura mayor que la pila no quita nada.
test(cortar_nada, [true(P == P0)]) :-
    pila(P0),
    empty_assoc(A),
    corte:cortar(5, [r], m([], P0, A, [5, 1, 0], 6, med(0, 0, 0, 0, 0)),
                 m(_, P, _, _, _, _)).

test(instanciar_corte, [true(M == '$corte'(3))]) :-
    corte:instanciar(10, 3, !, M).

test(instanciar_meta, [true(M == p('$v'(10), a))]) :-
    corte:instanciar(10, 3, p('$v'(0), a), M).

% La llamada anota la altura de la pila (1) en el corte del cuerpo.
test(paso_llamada, [true(Ms == ['$corte'(1), q, r])]) :-
    almacen:compilar([(p :- !, q), (p :- true)], T),
    empty_assoc(A),
    corte:paso(p, [r], T, m([], [eleccion(w, [], 0, 0)], A, [], 0,
                            med(0, 0, 0, 0, 0)),
               sigue(m(Ms, _, _, _, _, _))).

test(paso_corte, [true(Ms-P == [r]-[eleccion(z, [], 0, 0)])]) :-
    pila(P0),
    almacen:compilar([], T),
    empty_assoc(A),
    corte:paso('$corte'(1), [r], T, m([], P0, A, [], 6, med(0, 0, 0, 0, 0)),
               sigue(m(Ms, P, _, _, _, _))).

pila([eleccion(x, [], 2, 4), eleccion(y, [], 1, 2), eleccion(z, [], 0, 0)]).

:- end_tests(corte).
