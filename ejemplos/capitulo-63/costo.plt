:- encoding(utf8).

:- begin_tests(costo).

% De las 651 instanciaciones reunidas, 622 ya estaban en el ciclo anterior.
test(familia, [C, I, R] == [29, 651, 622]) :-
    familia(H),
    medir(familia, orden, H, C, I, R, _).

% En el ciclo 19 compiten descartar_caro, elegir con cada una de las dos
% fuentes candidatas y faltante.
test(perfil, [N, T, R] == [21, 4, 0]) :-
    pedido_ampliado(0, H),
    perfil(configurador, mea, H, Filas),
    length(Filas, N),
    nth1(19, Filas, ciclo(19, T, R, _)).

% Las memorias que ninguna placa admite no cambian los ciclos ni las
% instanciaciones, pero sí las inferencias.
test(ampliado, [C, I, Mayor] == [21, 46, true]) :-
    pedido_ampliado(0, H0),
    pedido_ampliado(100, H),
    medir(configurador, mea, H0, _, _, _, Inf0),
    medir(configurador, mea, H, C, I, _, Inf),
    (   Inf > 3 * Inf0
    ->  Mayor = true
    ;   Mayor = false
    ).

test(identidad, I == r-[3, 1]) :-
    identidad(instanciacion(r, [3, 1], 2, []), I).

:- end_tests(costo).
