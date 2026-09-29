:- encoding(utf8).

:- begin_tests(medida).

test(fila, N == 128) :-
    comparar(100, fila(N, I63, Carga, Ciclos)),
    maplist(integer, [I63, Carga, Ciclos]).

% Con 400 memorias más, casi todos los objetos del catálogo quedan en la
% memoria del nodo que sigue a objeto(P, C, R) en candidato_procesador.
test(mayores, M == [413-3, 3-4]) :-
    red_de(configurador, Red),
    pedido_ampliado(400, H),
    mayores_memorias(Red, H, 2, M).

test(tokens, T == 422) :-
    red_de(configurador, Red),
    pedido_ampliado(400, H),
    tokens_guardados(Red, H, T).

test(perfil, N == 21) :-
    red_de(configurador, Red),
    pedido_ampliado(0, H),
    perfil_red(Red, mea, H, Filas),
    length(Filas, N).

% Las memorias agregadas encarecen los ciclos que cambian de fase.
test(crece, Distintos == [2, 3, 5, 6, 8, 9, 11, 12, 14, 15, 18]) :-
    red_de(configurador, Red),
    pedido_ampliado(0, H0),
    pedido_ampliado(400, H),
    perfil_red(Red, mea, H0, F0),
    perfil_red(Red, mea, H, F),
    findall(N, ( member(ciclo(N, I0), F0), member(ciclo(N, I), F),
                 I > 2 * I0 ), Distintos).

:- end_tests(medida).
