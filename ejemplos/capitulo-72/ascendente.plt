:- encoding(utf8).

:- ensure_loaded(mejor).
:- ensure_loaded(compartidos).

:- begin_tests(ascendente).

test(alamos_islas, [true(C-R == 106-56)]) :-
    ascendente(rio(cero), ruta(alamos, islas), C, R).

% El método ascendente da el mismo costo que la búsqueda mejor primero en
% los 169 pares de pueblos.
test(todos_los_pares, [true(Malos == [])]) :-
    findall(X-Y,
            ( pueblo(X, _, _, _),
              pueblo(Y, _, _, _),
              ascendente(rio(cero), ruta(X, Y), C1, _),
              mejor(rio(distancia), ruta(X, Y), _, C2, _),
              C1 =\= C2 ),
            Malos).

test(hanoi, [true(C-R == 1048575-66)]) :-
    ascendente(hanoi, torre(20, a, c), C, R).

test(primitivo, [true(C-R == 0-1)]) :-
    ascendente(rio(cero), ruta(paso, paso), C, R).

test(sin_solucion, [fail]) :-
    ascendente(rio(cero), ruta(zz, islas), _, _).

test(alcanzables, [true(N == 67)]) :-
    alcanzables(rio(cero), ruta(alamos, islas), Ns),
    length(Ns, N).

test(alcanzar, [true(Ns == [mover(a, c), torre(0, a, b), torre(0, b, c),
                            torre(1, a, c)])]) :-
    empty_assoc(V0),
    put_assoc(torre(1, a, c), V0, si, V1),
    alcanzar([torre(1, a, c)], hanoi, V1, V),
    assoc_to_keys(V, Ns).

test(nuevos, [true(Ns == [b])]) :-
    list_to_assoc([a-si], V0),
    nuevos([a, b, a], V0, _, Ns).

test(padres, [true(Ps == [torre(1, a, c)-y-0])]) :-
    padres(hanoi, [torre(1, a, c)], P),
    get_assoc(torre(0, a, b), P, Ps).

test(pendientes, [true(F == f(3, 0))]) :-
    pendientes(hanoi, [torre(1, a, c), mover(a, c)], P),
    get_assoc(torre(1, a, c), P, F).

test(avisar_o, [true(K-N == 7-x)]) :-
    empty_assoc(R),
    list_to_heap([], H0),
    avisar(5, R, x-o-2, H0-p, H-p),
    get_from_heap(H, K, N, _).

test(avisar_y, [true(F == f(1, 7))]) :-
    empty_assoc(R),
    list_to_assoc([x-f(2, 0)], P0),
    list_to_heap([], H0),
    avisar(5, R, x-y-2, H0-P0, _-P),
    get_assoc(x, P, F).

test(avisar_resuelto, [true(H == H0)]) :-
    list_to_assoc([x-3], R),
    list_to_heap([], H0),
    avisar(5, R, x-o-2, H0-p, H-p).

test(agregar_al_monton, [true(K-N == 4-n)]) :-
    list_to_heap([], H0),
    agregar_al_monton(n-4, H0, H),
    get_from_heap(H, K, N, _).

:- end_tests(ascendente).
