:- encoding(utf8).

:- use_module(programas).

:- begin_tests(almacen).

test(antepasado, all(D == [ana, pedro, luis, eva])) :-
    resolver(familia, antepasado(juan, D)).

test(concatenar, [true(Rs =@= Ns)]) :-
    findall(concatenar(X, Y, [1, 2, 3]),
            resolver(listas, concatenar(X, Y, [1, 2, 3])), Rs),
    respuestas_nativas(listas, concatenar(_, _, [1, 2, 3]), Ns).

% Una respuesta con variables libres, que comparten dos argumentos.
test(libres, [true(R =@= [concatenar([], L, L)])]) :-
    findall(concatenar([], Y, Z), resolver(listas, concatenar([], Y, Z)), R).

test(invertir, all(R == [[5, 4, 3, 2, 1]])) :-
    resolver(listas, invertir_hasta(5, R)).

test(longitud, all(N == [30])) :-
    resolver(listas, longitud_hasta(30, N)).

% Sin indexación, la última cláusula de suma/3 queda pendiente.
test(suma, [true(S == 6), nondet]) :-
    resolver(listas, suma([1, 2, 3], S)).

test(corte, [error(existence_error(procedure, !/0))]) :-
    resolver(maximo, maximo(4, 3, _)).

test(medir, [true(E-T-M == 101-102-4)]) :-
    medir(listas, suma_hasta(100, _),
          [respuestas-1, pasos-_, intentos-_, metas-M, elecciones-E,
           rastro-T, celdas-_]).

test(consulta, [true(Q-N == concatenar('$v'(0), '$v'(1), [a])-2)]) :-
    compilar_meta(concatenar(_, _, [a]), Q, N).

% Con la marca 1, la celda 0 se anota en el rastro y la 1 no.
test(unificar, [true(T-R == f(a, b)-[0])]) :-
    empty_assoc(A0),
    unificar(f('$v'(0), b), f(a, '$v'(1)), 1, A0-[], A-R),
    reconstruir(f('$v'(0), '$v'(1)), A, T).

test(ocurrencia, [fail]) :-
    empty_assoc(A0),
    unificar(f('$v'(0), b), f(a, c), 0, A0-[], _).

test(reconstruir, [true(T =@= g(X, X, _))]) :-
    empty_assoc(A0),
    unificar('$v'(0), '$v'(1), 0, A0-[], A-_),
    reconstruir(g('$v'(0), '$v'(1), '$v'(2)), A, T),
    T = g(X, _, _).

test(renombrar, [true(T == p('$v'(10), f('$v'(11)), a))]) :-
    renombrar(10, p('$v'(0), f('$v'(1)), a), T).

:- end_tests(almacen).
