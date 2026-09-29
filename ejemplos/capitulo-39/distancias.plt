:- encoding(utf8).

:- begin_tests(distancias).

test(desde_a, [true(Ps == [a-11, b-3, c-1, d-8])]) :-
    findall(Y-D, distancia(a, Y, D), Ps0),
    msort(Ps0, Ps).

% Una respuesta por par de nodos: la menor.
test(una_por_par, [true(N == 16)]) :-
    aggregate_all(count, distancia(_, _, _), N).

test(par, [true(D == 3)]) :-
    distancia(a, b, D).

% El argumento del modo min debe llegar libre.
test(ligado, [error(uninstantiation_error(3))]) :-
    distancia(a, b, 3).

test(ruta, [true(R == 8-[a, c, b, d])]) :-
    ruta(a, d, R).

test(ruta_ciclo, [true(R == 11-[a, c, b, d, a])]) :-
    ruta(a, a, R).

% ruta/3 y distancia/3 dan las mismas longitudes.
test(coinciden, [forall(member(Y, [a, b, c, d])), true(D1 == D2)]) :-
    distancia(a, Y, D1),
    ruta(a, Y, R),
    R = D2-_.

test(mas_corta_empate, [true(R == 3-[x])]) :-
    mas_corta(3-[x], 3-[y], R).

% Sin el modo min, cada vuelta al ciclo es una respuesta nueva y la tabla
% no se completa: la consulta no termina. SWI-Prolog entrega las respuestas
% de una tabla cuando la completa, así que limit/2 tampoco la detiene; un
% millón de inferencias no alcanzan.
test(sin_min, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(suma_tramos(a, b, _), 1000000, R).

:- end_tests(distancias).
