:- encoding(utf8).

:- begin_tests(colas).

% Los resultados llegan en cualquier orden; con_trabajadores/4 los ordena,
% y la comparación no depende de qué hilo hizo cada trabajo.
test(cuadrados, [true(Pares == Esperados)]) :-
    numlist(1, 500, Xs),
    findall(X-resultado(Y), ( member(X, Xs), Y is X * X ), Esperados),
    con_trabajadores(cuadrado, 4, Xs, Pares).

% Más trabajos que el tamaño máximo de la cola de pendientes: el productor
% espera, y todos los trabajos se hacen una vez.
test(cola_llena, [true(N-Suma == 1000-500500)]) :-
    numlist(1, 1000, Xs),
    con_trabajadores([X, X]>>true, 3, Xs, Pares),
    length(Pares, N),
    aggregate_all(sum(Y), member(_-resultado(Y), Pares), Suma).

test(fallos, [true(P = [15-fallo, 16-resultado(4), a-error(error(F, _))])]) :-
    con_trabajadores(raiz_exacta, 2, [16, a, 15], P),
    F = type_error(evaluable, a/0).

test(lista_vacia, [true(P == [])]) :-
    con_trabajadores(cuadrado, 2, [], P).

test(un_hilo_por_trabajo, [true(Es == [true, true, true])]) :-
    uno_por_trabajo(cuadrado, [1, 2, 3], Es).

:- end_tests(colas).
