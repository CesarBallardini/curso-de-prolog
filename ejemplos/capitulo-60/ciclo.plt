:- encoding(utf8).

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

:- end_tests(ciclo).
