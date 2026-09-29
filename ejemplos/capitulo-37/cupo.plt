:- encoding(utf8).

% Las pruebas comparan cantidades, que no dependen del orden en que los
% hilos se ejecutan. La versión ingenua con varios hilos no se prueba: su
% resultado cambia de una ejecución a otra, y la sección 37.3 lo muestra.

:- begin_tests(cupo).

% Con un solo hilo, las cuatro versiones cumplen el invariante.
test(un_hilo, [ forall(member(P, [ reservar, reservar_con_mutex,
                                    reservar_en_transaccion,
                                    reservar_cas ])),
                true(R == resumen(100, 1, [0], 0)) ]) :-
    concurrencia(P, 1, 300, 100, R).

% Con ocho hilos y menos vacantes que intentos: se llena el cupo, y no más.
test(mutex_lleno, [true(R == resumen(100, 1, [0], 0))]) :-
    concurrencia(reservar_con_mutex, 8, 1000, 100, R).

test(cas_lleno, [true(R == resumen(100, 1, [0], 0))]) :-
    concurrencia(reservar_cas, 8, 1000, 100, R).

% Con más vacantes que intentos: todos quedan inscriptos, y las vacantes
% bajan exactamente en la cantidad de inscriptos.
test(mutex_sobran, [true(R == resumen(8000, 1, [2000], 0))]) :-
    concurrencia(reservar_con_mutex, 8, 1000, 10000, R).

test(cas_sobran, [true(R == resumen(8000, 1, [2000], 0))]) :-
    concurrencia(reservar_cas, 8, 1000, 10000, R).

test(rechazada, [true(R-I == rechazada-0)]) :-
    abrir(m, 0),
    reservar_con_mutex(m, 1, R),
    aggregate_all(count, inscripto(_, m), I).

% Una transacción que falla no deja ninguno de sus cambios.
test(transaccion_descartada, [true(I-V == 0-[5])]) :-
    abrir(m, 5),
    \+ transaction(( reservar(m, 1, aceptada), fail )),
    aggregate_all(count, inscripto(_, m), I),
    findall(N, vacantes(m, N), V).

test(decidir_sin_vacantes, [true(R-I == rechazada-0)]) :-
    abrir(m, 0),
    decidir(m, 1, N, R),
    assertion(N == 0),
    aggregate_all(count, inscripto(_, m), I).

% La restricción de reservar_cas/3 falla si las vacantes ya no son las que
% se leyeron.
test(confirmar_cambiado, [fail]) :-
    abrir(m, 4),
    confirmar(m, 5, aceptada).

% confirmar/3 deja una alternativa: la segunda cláusula no se descarta
% por el tercer argumento. En reservar_cas/3, el corte final la descarta.
test(confirmar_igual, [nondet, true(V == [4])]) :-
    abrir(m, 5),
    confirmar(m, 5, aceptada),
    findall(N, vacantes(m, N), V).

:- end_tests(cupo).
