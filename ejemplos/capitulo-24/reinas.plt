:- encoding(utf8).

:- begin_tests(reinas).

test(ocho, true(Qs == [1, 5, 8, 6, 3, 7, 2, 4])) :-
    once(reinas(8, Qs)).

test(ocho_todas, true(N == 92)) :-
    aggregate_all(count, reinas(8, _), N).

test(tres, [fail]) :-
    reinas(3, _).

% Generar y probar da las mismas 92 soluciones.
test(generar_y_probar, true(N == 92)) :-
    aggregate_all(count, reinas_gyp(8, _), N).

test(veinte, true(N == 20)) :-
    once(reinas(20, Qs)),
    length(Qs, N).

:- end_tests(reinas).
