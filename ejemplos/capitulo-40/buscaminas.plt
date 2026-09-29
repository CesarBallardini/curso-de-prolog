:- encoding(utf8).

:- begin_tests(buscaminas).

% Las mismas celdas que deduce el resolvedor con restricciones del
% capítulo 23.
test(chico, [true(S-M == [3-4, 4-3]-[1-1, 3-3])]) :-
    tablero(chico, T),
    deducir(T, S, M).

test(grande, [true(S-M == [5-2, 5-3, 5-4, 5-5, 5-6, 5-7, 5-8, 5-9, 6-1,
                           6-2]-[1-3, 1-7, 2-6, 3-1, 4-5, 4-6, 4-8])]) :-
    tablero(grande, T),
    deducir(T, S, M).

% (4, 4) no toca ningún número: no se asigna.
test(ocultas, [true(Os == [1-1, 3-3, 3-4, 4-3])]) :-
    tablero(chico, T),
    leer(T, Os, _).

test(configuraciones, [true(N == 1)]) :-
    tablero(chico, T),
    aggregate_all(count, configuracion(T, [], _), N).

% Un número que no se puede cumplir: ninguna configuración.
test(inconsistente, [fail]) :-
    deducir(["#4", "##"], _, _).

test(visible, [true(L == ["##00", "####", "####", "####"])]) :-
    visible(4, 4, [1-1, 3-3], [1-4, 1-3], L).

test(ganada, [true(N-F == 14-ganada)]) :-
    jugar(4, 4, [1-1, 3-3], 1-4, J, F),
    length(J, N).

% Con minas en (1, 2) y (2, 1), el 2 de la celda de partida no dice cuáles
% de sus tres vecinas ocultas tienen mina: ninguna es segura.
test(trabada, [true(J-F == [1-1]-trabada(["2###", "####"]))]) :-
    jugar(2, 4, [1-2, 2-1], 1-1, J, F).

% contar/6 y posible/2 sobre una asignación parcial: a tiene mina, b no, y
% c y d no tienen valor.
test(contar, [true(M-L == 1-2)]) :-
    list_to_assoc([a-1, b-0], As),
    contar([a, b, c, d], As, 0, 0, M, L).

test(posible) :-
    list_to_assoc([a-1, b-0], As),
    assertion(posible(As, 1-[a, b, c])),
    assertion(\+ posible(As, 0-[a, c])),
    assertion(\+ posible(As, 3-[a, b, c])).

:- end_tests(buscaminas).
