:- encoding(utf8).

% Un programa cuya única acción quita un hecho que la memoria no tiene.
user:programa(quitar_ausente,
    [ quitar :: [numero(_)] ---> [quitar(letra(a))] ]).

:- begin_tests(ciclo).

test(mcd_de_cuatro, [M, R] == [[numero(5), numero(5), numero(5), numero(5)], 5]) :-
    ejecutar(mcd, [numero(25), numero(10), numero(15), numero(30)], M, R).

test(mcd_de_dos, R == 4) :-
    ejecutar(mcd, [numero(12), numero(8)], _, R).

test(ordenar, [L, R] == [[1, 2, 3, 4, 5], nada_aplicable]) :-
    posiciones([5, 3, 4, 1, 2], H),
    ejecutar(ordenar, H, M, R),
    valores(M, L).

test(posiciones, all(P == [[1, 0], [1, 2], [2, 0]])) :-
    satisface([numero(X), numero(Y), {X > Y}],
              [numero(3), numero(5), numero(4)], P).

test(negacion, [fail]) :-
    satisface([no(numero(_))], [numero(3)], _).

test(quitar_primera, M == [numero(1), numero(2)]) :-
    acciones([quitar(numero(2))], [numero(2), numero(1), numero(2)], M, _).

test(reemplazar_al_principio, M == [numero(9), numero(1)]) :-
    acciones([reemplazar(numero(2), numero(9))], [numero(1), numero(2)], M,
             seguir).

test(parar_corta, [M, F] == [[a], parar(listo)]) :-
    acciones([parar(listo), agregar(b)], [a], M, F).

test(ordenar_todas, [N, Ls] == [5, [[1, 2, 3]]]) :-
    posiciones([3, 2, 1], H),
    findall(L, ( ejecucion(ordenar, H, M, nada_aplicable), valores(M, L) ),
            Todas),
    length(Todas, N),
    sort(Todas, Ls).

% Sin resolución de conflictos, el resultado depende de la elección.
test(mcd_todas, [N, Rs] == [8, [5, 10, 15, 25]]) :-
    findall(R, ejecucion(mcd, [numero(25), numero(10)], _, R), Todas),
    length(Todas, N),
    sort(Todas, Rs).

% condicion/4 da la posición de cada hecho que cumple el patrón.
test(condicion_posiciones, all(X-P == [3-[0], 4-[2]])) :-
    condicion(numero(X), [numero(3), letra(a), numero(4)], P, []).

test(condicion_negacion, [true(P == fin), nondet]) :-
    condicion(no(numero(5)), [numero(3)], P, fin).

test(accion_agregar, [true(M == [b, a])]) :-
    accion(agregar(b), [a], M).

test(accion_quitar_ausente, [fail]) :-
    accion(quitar(c), [a, b], _).

test(accion_prueba, [true(M == [a])]) :-
    accion({X is 2 + 2, X =:= 4}, [a], M).

test(seguir_parar, [true(M-R == [a]-listo)]) :-
    seguir(parar(listo), [], [a], M, R).

% Sin módulos que se apliquen, seguir vuelve al ciclo y termina.
test(seguir_ciclo, [true(M-R == [a]-nada_aplicable)]) :-
    seguir(seguir, [], [a], M, R).

% ciclo_libre/4 directamente, con los módulos de mcd: sin resolver el
% conflicto, resultado puede parar antes de que resta termine, y de las
% seis ejecuciones solo tres dan el mcd, 2.
test(ciclo_libre, [true(Rs == [2, 2, 2, 4, 4, 6])]) :-
    programa(mcd, Ms),
    findall(R, ciclo_libre(Ms, [numero(4), numero(6)], _, R), Rs).

test(ciclo_libre_vacio, all(M-R == [[]-nada_aplicable])) :-
    ciclo_libre([], [], M, R).

% quitar/1 no encuentra el hecho, la acción falla y ejecutar/4 también.
test(accion_fallida, [fail]) :-
    ejecutar(quitar_ausente, [numero(1)], _, _).

:- end_tests(ciclo).
