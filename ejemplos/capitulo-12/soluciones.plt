:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(elemento, all(E == [1])) :-
    matriz(a, A),
    elemento(A, posicion(2, 1), E).

test(elemento_fuera_de_la_matriz, [fail]) :-
    matriz(b, B),
    elemento(B, posicion(3, 1), _).

test(actualiza, all(M == [[[1, 2, 3], [9, 3, 5], [4, 4, 4]]])) :-
    matriz(a, A),
    actualiza(A, posicion(2, 1), 9, M).

test(transpuesta_verifica) :-
    matriz(at, AT),
    matriz(a, A),
    transpuesta(AT, A).

test(transpuesta, all(T == [[[0, 7], [0, 2], [4, 10]]])) :-
    matriz(b, B),
    transpuesta(B, T).

test(transpuesta_equivocada, [fail]) :-
    matriz(a, A),
    transpuesta(A, A).

test(suma, all(S == [[[2, 4, 6], [2, 6, 10], [8, 8, 8]]])) :-
    matriz(a, A),
    suma(A, A, S).

test(suma_de_dimensiones_distintas, [fail]) :-
    matriz(a, A),
    matriz(b, B),
    suma(A, B, _).

test(suma_diagonales, all(SD == [[4, 6, 8]])) :-
    matriz(a, A),
    suma_diagonales(A, SD).

% Ejercicio 2
test(convierte, all(R == [[[1, 1, 10], [1, 4, 10], [2, 2, 20], [3, 1, 30],
                          [3, 5, 30], [4, 1, 40], [5, 1, 50], [5, 5, 50]]])) :-
    convierte([[10, 0, 0, 10, 0], [0, 20, 0, 0, 0], [30, 0, 0, 0, 30],
               [40, 0, 0, 0, 0], [50, 0, 0, 0, 50]], R).

test(convierte_la_matriz_nula, all(R == [[]])) :-
    convierte([[0, 0], [0, 0]], R).

% Ejercicio 3
test(tablero_siguiente_cantidad, all(T == [reina(1, 2), reina(1, 7),
                                           reina(2, 2), reina(2, 6),
                                           reina(3, 2), reina(3, 5),
                                           reina(4, 2), reina(4, 4),
                                           reina(5, 1), reina(5, 2),
                                           reina(5, 3), reina(6, 1),
                                           reina(6, 3), reina(6, 4),
                                           reina(6, 5), reina(6, 6),
                                           reina(6, 7), reina(6, 8),
                                           reina(7, 1), reina(7, 2),
                                           reina(7, 3), reina(8, 2),
                                           reina(8, 4)])) :-
    tablero_siguiente(reina(6, 2), T).

test(tablero_siguiente_no_salta_como_caballo, [fail]) :-
    tablero_siguiente(reina(6, 2), reina(8, 3)).

test(tablero_siguiente_no_se_queda_quieta, [fail]) :-
    tablero_siguiente(reina(6, 2), reina(6, 2)).

% Ejercicio 9: con tres colores no hay coloreo; con cuatro, sí.
test(tres_colores_no_alcanzan, [fail]) :-
    mapa_ejemplo(M),
    color_map(M, [rojo, verde, azul]).

test(primer_coloreo, [nondet]) :-
    mapa_ejemplo(M),
    color_map(M, [rojo, verde, azul, blanco]),
    M = [region(a, rojo, _), region(b, verde, _), region(c, azul, _),
         region(d, verde, _), region(e, rojo, _), region(f, blanco, _)].

test(vecinas_con_el_mismo_color, [fail]) :-
    color_map([region(a, rojo, [rojo])], [rojo, verde]).

% Ejercicio 14: el ejemplo del enunciado.
test(tabla_del_ejemplo, all(T == [[[equipo_c, 4, 1, 1, 0], [equipo_b, 1, 0, 1, 0],
                                    [equipo_a, 0, 0, 0, 1]]])) :-
    actualizar([[equipo_b, 0, 0, 0, 0], [equipo_a, 0, 0, 0, 0],
                [equipo_c, 0, 0, 0, 0]],
               [[equipo_c, equipo_b, 3], [equipo_a, equipo_c, 2]], T).

test(sin_resultados_solo_ordena, all(T == [[[b, 3, 1, 0, 0], [a, 1, 0, 1, 0]]])) :-
    actualizar([[a, 1, 0, 1, 0], [b, 3, 1, 0, 0]], [], T).

test(equipo_ajeno, [fail]) :-
    actualizar([[a, 0, 0, 0, 0]], [[a, z, 1]], _).

% Ejercicio 16: el ejemplo del enunciado, con una sola respuesta.
test(sub_crec_mayor_una_respuesta, all(S == [[1, 2, 4, 6]])) :-
    sub_crec_mayor([20, 19, 1, 5, 2, 4, 6], S).

test(sub_crec_mayor_dos_respuestas, all(S == [[2, 4, 8], [2, 3, 4]])) :-
    sub_crec_mayor([2, 4, 8, 3, 4], S).

test(sub_crec_mayor_no_es_la_mas_larga, [fail]) :-
    sub_crec_mayor([2, 4, 8, 3, 4], [2, 4]).

test(creciente_estricto, [fail]) :-
    creciente([1, 2, 2]).

:- end_tests(soluciones).
