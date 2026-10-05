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

% Una celda anterior a la marca se anota en el rastro; una posterior, no.
test(ligar_critica, [true(L-R == [3-f(x)]-[3])]) :-
    empty_assoc(A0),
    almacen:ligar(3, f(x), 5, A0-[], A-R),
    assoc_to_list(A, L).

test(ligar_reciente, [true(R == [])]) :-
    empty_assoc(A0),
    almacen:ligar(7, f(x), 5, A0-[], _-R).

% usar/5 renombra la cláusula desde la primera celda libre y pone el
% cuerpo delante de las metas que quedan.
test(usar, [true(Ms-L == [q('$v'(1)), r]-2)]) :-
    estado_inicial(1, E0),
    almacen:compilar_clausula((p(X) :- q(X)), _-C),
    almacen:usar(C, p(b), [r], E0, m(Ms, _, _, _, L, _)).

test(usar_falla, [fail]) :-
    estado_inicial(1, E0),
    almacen:compilar_clausula((p(a) :- true), _-C),
    almacen:usar(C, p(b), [r], E0, _).

% Con dos cláusulas, la primera sirve y la segunda queda en un punto de
% elección; la celda 0, anterior a él, queda en el rastro.
test(llamar_sigue, [true(Ms-Ps-R == [r]-[p('$v'(0)), r]-[0])]) :-
    estado_inicial(1, E0),
    almacen:compilar_clausula((p(a) :- true), _-C1),
    almacen:compilar_clausula((p(X) :- q(X)), _-C2),
    almacen:llamar([C1, C2], p('$v'(0)), [r], E0,
                   sigue(m(Ms, [eleccion(Ps, [C2], 0, 1)], _, R, _, _))).

% La falla devuelve el estado con el intento contado.
test(llamar_falla, [true(I == 1)]) :-
    estado_inicial(1, E0),
    almacen:compilar_clausula((p(a) :- true), _-C),
    almacen:llamar([C], p(b), [r], E0,
                   falla(m(_, [], _, _, _, med(_, I, _, _, _)))).

estado_inicial(Libre, m([], [], A, [], Libre, med(0, 0, 0, 0, 0))) :-
    empty_assoc(A).

:- end_tests(almacen).
