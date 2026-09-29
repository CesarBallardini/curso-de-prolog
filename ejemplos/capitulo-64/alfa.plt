:- encoding(utf8).

:- begin_tests(alfa).

test(sobre, A == [2]) :-
    red_de(cajas, Red),
    alfas_del_hecho(Red, sobre(a, piso), A).

% Un hecho que ningún patrón usa no se compara con ningún nodo.
test(ninguno, A == []) :-
    red_de(cajas, Red),
    alfas_del_hecho(Red, color(a, rojo), A).

% meta(apilar([a])) unifica con meta(apilar([_])), pero no con
% meta(apilar([X, Y|R])), que pide dos elementos.
test(apilar, A == [4]) :-
    red_de(cajas, Red),
    alfas_del_hecho(Red, meta(apilar([a])), A).

test(memorias, M == [1-[1-padre(juan, ana), 3-padre(ana, luis)],
                     2-[2-madre(ana, sofia)], 3-[], 4-[]]) :-
    memorias_alfa(familia, [padre(juan, ana), madre(ana, sofia),
                            padre(ana, luis), hola], M).

% Un hecho que sale deja la memoria como estaba.
test(salir, M == M0) :-
    red_de(familia, Red),
    memorias_alfa_vacias(Red, V),
    entrar_alfa(mas, 1, padre(juan, ana), Red, V, M0, _),
    entrar_alfa(mas, 2, padre(ana, luis), Red, M0, M1, _),
    entrar_alfa(menos, 2, padre(ana, luis), Red, M1, M, E),
    E = [1-alfa(padre(ana, luis), [])].

% Con el primer argumento conocido, solo se miran los de esa clave.
test(clave, E == [1-alfa(padre(juan, ana), [])]) :-
    red_de(familia, Red),
    memorias_alfa_vacias(Red, V),
    entrar_alfa(mas, 1, padre(juan, ana), Red, V, M0, _),
    entrar_alfa(mas, 2, padre(ana, luis), Red, M0, M1, _),
    get_assoc(1, M1, Memoria),
    elementos_alfa(Memoria, padre(juan, _), E).

test(todos, N == 2) :-
    red_de(familia, Red),
    memorias_alfa_vacias(Red, V),
    entrar_alfa(mas, 1, padre(juan, ana), Red, V, M0, _),
    entrar_alfa(mas, 2, padre(ana, luis), Red, M0, M1, _),
    get_assoc(1, M1, Memoria),
    elementos_alfa(Memoria, padre(_, _), E),
    length(E, N).

:- end_tests(alfa).
