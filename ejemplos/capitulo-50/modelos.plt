:- encoding(utf8).

:- use_module(library(lists)).
:- use_module(abduccion).
:- use_module(minimos).

:- begin_tests(modelos).

test(debil, [true(Ds == [[[m1, x1]-desconocida],
                         [[m1, y1]-desconocida, [m2, x1]-desconocida],
                         [[m2, x1]-desconocida, [m2, y1]-desconocida],
                         [[m2, x1]-desconocida, [o1]-desconocida]])]) :-
    minimos(debil, sumador, [[0, 0, 1]-[0, 1]], 2, Ds).

% Con una observación, los dos modelos sospechan de las mismas compuertas.
test(una_observacion, [true(F == D)]) :-
    sospechosas(fuerte, sumador, [[0, 0, 1]-[0, 1]], 2, F),
    sospechosas(debil, sumador, [[0, 0, 1]-[0, 1]], 2, D).

test(fuerte_separa, [true(F-N == [[[m1, x1]]]-4)]) :-
    Obs = [[0, 0, 1]-[0, 1], [0, 0, 0]-[1, 0]],
    sospechosas(fuerte, sumador, Obs, 2, F),
    sospechosas(debil, sumador, Obs, 2, D),
    length(D, N).

% Mismas entradas, salidas distintas: solo el modelo débil lo explica.
test(intermitente_fuerte, [fail]) :-
    mas_simples(fuerte, sumador, [[0, 0, 1]-[0, 1], [0, 0, 1]-[1, 0]], _).

test(intermitente_debil, [true(Ds == [[[m1, x1]-desconocida]])]) :-
    mas_simples(debil, sumador, [[0, 0, 1]-[0, 1], [0, 0, 1]-[1, 0]], Ds).

% En el modelo débil, agregar compuertas a un diagnóstico da otro.
test(hacia_arriba, [nondet]) :-
    diagnostico(debil, sumador, [[0, 0, 1]-[0, 1]], D),
    length(D, 5).

:- end_tests(modelos).
