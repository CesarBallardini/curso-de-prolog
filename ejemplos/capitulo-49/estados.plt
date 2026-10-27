:- encoding(utf8).

:- use_module(library(yall)).
:- use_module(secuenciales).

:- begin_tests(estados).

test(divisor, [true(Es == [[0], [1]])]) :-
    alcanzables(divisor, [0], Es).

test(registro4, [true(N == 16)]) :-
    alcanzables(registro4, [0, 0, 0, 0], Es),
    length(Es, N).

test(gray_ocho, [true(N == 8)]) :-
    alcanzables(contador_gray, [0, 0, 0], Es),
    length(Es, N).

test(grafo_paridad, [true(As == [[0]-[0]/[0]-[0], [0]-[1]/[1]-[1],
                                 [1]-[0]/[1]-[1], [1]-[1]/[0]-[0]])]) :-
    grafo(paridad, [0], As).

% Sin tabla, las respuestas se repiten y la consulta no termina.
test(sin_tabla_repite, [true(Es == [[1], [0], [1], [0]])]) :-
    findall(E, limit(4, alcanzable_sin_tabla(divisor, [0], E)), Es).

test(sin_tabla_no_termina, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(
        findall(E, alcanzable_sin_tabla(divisor, [0], E), _),
        1000000, R).

% Entre un pulso y el siguiente, la salida del contador cambia un solo bit.
test(gray_un_bit) :-
    siempre(contador_gray, [0, 0, 0],
            [_, _, S, E1]>>( transicion(contador_gray, E1, _, S1, _),
                             distancia(S, S1, 1) )).

% El divisor cambia de estado en cada pulso: la condición «el estado no
% cambia» no se cumple en ningún arco, y siempre/3 falla.
test(siempre_falla, [fail]) :-
    siempre(divisor, [0], [E, _, _, E]>>true).

test(distancia, [true(D == 2)]) :-
    distancia([1, 0, 1], [0, 0, 0], D).

:- end_tests(estados).
