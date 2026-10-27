:- encoding(utf8).

% Pruebas de las soluciones. Las que usan hilos comparan cantidades o
% conjuntos; la transferencia ingenua, que puede quedar detenida para
% siempre, no se prueba: la solución del ejercicio 7 muestra una ejecución.

:- begin_tests(soluciones).

test(respuestas_en_hilo, [true(L == [a, b, c])]) :-
    respuestas_en_hilo(X, member(X, [a, b, c]), L).

test(respuestas_sin_ninguna, [true(L == [])]) :-
    respuestas_en_hilo(X, member(X, []), L).

test(respuestas_error, [error(instantiation_error)]) :-
    respuestas_en_hilo(X, atom_length(X, _), _).

test(tuberia, [true(S-Hilos == 338350-Antes)]) :-
    findall(T, thread_property(T, status(_)), Antes0),
    length(Antes0, Antes),
    numlist(1, 100, Xs),
    tuberia(Xs, S),
    findall(T, thread_property(T, status(_)), Despues),
    length(Despues, Hilos).

test(tuberia_vacia, [true(S == 0)]) :-
    tuberia([], S).

test(contador_cas, [true(F == 8000)]) :-
    sumar_en_hilos(8, 1000, F).

% La suma de los saldos no cambia, y cada cuenta tiene un solo saldo.
test(transferencias, [true(T-H == 4000-4)]) :-
    al_azar(8, 1250, T, H).

test(opuestas, [true(R == terminaron)]) :-
    opuestas(transferir, 2000, R).

test(extremos_unico, [true(P == 3)]) :-
    posicion_extremos([1, 3, 4, 5, 7], [X]>>(0 is X mod 2), P).

% Con dos elementos pares, cualquiera de las dos búsquedas puede ganar.
test(extremos_dos, [true(memberchk(P, [2, 4]))]) :-
    posicion_extremos([1, 2, 3, 4, 5], [X]>>(0 is X mod 2), P).

test(extremos_ninguno, [fail]) :-
    posicion_extremos([1, 3, 5], [X]>>(0 is X mod 2), _).

test(emparejar, [true(P == [2-5, 4-10, 6-15])]) :-
    emparejar(3, multiplo(2), multiplo(5), P).

test(emparejar_corto, [true(P == [2-a, 4-b])]) :-
    emparejar(5, multiplo(2), [X]>>member(X, [a, b]), P).

test(identificadores, [true(Ids == [id(1), id(2), id(3)])]) :-
    nuevo_generador(M),
    findall(Id, ( between(1, 3, _), siguiente_id(M, Id) ), Ids),
    engine_destroy(M).

% Cuatro hilos piden 100 identificadores cada uno al mismo motor: los 400
% son distintos, del 1 al 400, cualquiera sea el hilo que recibió cada uno.
test(identificadores_hilos, [true(Ns == Esperados)]) :-
    nuevo_generador(M),
    thread_self(Yo),
    length(Ids, 4),
    maplist([Id]>>thread_create(pedir_ids(M, 100, Yo), Id), Ids),
    maplist([Id]>>thread_join(Id, true), Ids),
    engine_destroy(M),
    length(Listas, 4),
    maplist([L]>>thread_get_message(ids(L)), Listas),
    append(Listas, Todos),
    findall(N, member(id(N), Todos), Ns0),
    msort(Ns0, Ns),
    numlist(1, 400, Esperados).

:- end_tests(soluciones).

%!  pedir_ids(+Motor, +N:integer, +Destino) is det.
%
%   Pide N identificadores a Motor y envía ids(Lista) a Destino.
pedir_ids(Motor, N, Destino) :-
    findall(Id, ( between(1, N, _), siguiente_id(Motor, Id) ), Ids),
    thread_send_message(Destino, ids(Ids)).
