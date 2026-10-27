:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 3: una sola respuesta por persona, sin corte.
test(sofia_es_bebe, all(C == [bebe])) :-
    categoria_sin_ningun_corte(sofia, C).

test(eva_es_chica, all(C == [chico])) :-
    categoria_sin_ningun_corte(eva, C).

test(juan_es_adulto, all(C == [adulto])) :-
    categoria_sin_ningun_corte(juan, C).

% Ejercicio 4: esta versión responde correctamente la consulta inversa.
test(sofia_no_es_adulta, [fail]) :-
    categoria_sin_ningun_corte(sofia, adulto).

% Ejercicio 5
test(primer_par, all(X == [4])) :-
    primer_par([3, 7, 4, 8], X).

test(sin_pares, [fail]) :-
    primer_par([3, 7], _).

% Ejercicio 6
test(hay_alguno_menor, [nondet]) :-
    hay_algun_menor([41, 12, 68]).

test(no_hay_ninguno_menor, [fail]) :-
    hay_algun_menor([41, 68]).

% Ejercicio 8
test(primer_cuadrado_mayor_que_cincuenta, all(C == [8])) :-
    primer_cuadrado_mayor(50, C).

% Ejercicio 9
test(descuento_de_un_chico, all(D == [50])) :-
    descuento(8, D).

test(descuento_de_un_jubilado, all(D == [30])) :-
    descuento(70, D).

test(descuento_de_un_adulto, all(D == [0])) :-
    descuento(40, D).

% La versión corregida responde correctamente la consulta inversa.
test(un_chico_no_tiene_cero, [fail]) :-
    descuento(8, 0).

% Ejercicio 10
test(sin_repetidos, all(R == [[a, b, c]])) :-
    sin_repetidos([a, b, a, c, b], R).

test(sin_repetidos_sin_nada_que_sacar, all(R == [[a, b, c]])) :-
    sin_repetidos([a, b, c], R).

% Un elemento que aparece tres veces produce una sola respuesta.
test(sin_repetidos_con_tres_apariciones, all(R == [[a, b]])) :-
    sin_repetidos([a, a, a, b], R).

% Ejercicio 14
test(clasificar_negativo, all(C == [negativo])) :-
    clasificar(-2, C).

test(clasificar_cero, all(C == [cero])) :-
    clasificar(0, C).

test(clasificar_positivo, all(C == [positivo])) :-
    clasificar(5, C).

% El corte rojo: con el segundo argumento instanciado, el predicado acepta
% una respuesta falsa. La prueba documenta el defecto.
test(clasificar_acepta_una_respuesta_falsa) :-
    clasificar(-2, positivo).

% Ejercicio 16: el lugar del corte decide cuántas respuestas quedan.
test(prenda_sin_corte, all(P == [unico-blanco-lino,
                                 chico-rojo-algodon, chico-rojo-lana,
                                 chico-azul-algodon, chico-azul-lana,
                                 grande-rojo-algodon, grande-rojo-lana,
                                 grande-azul-algodon, grande-azul-lana,
                                 unico-negro-cuero])) :-
    prenda(T, C, M),
    P = T-C-M.

test(prenda_corte_talle, all(P == [unico-blanco-lino,
                                   chico-rojo-algodon, chico-rojo-lana,
                                   chico-azul-algodon, chico-azul-lana])) :-
    prenda_corte_talle(T, C, M),
    P = T-C-M.

test(prenda_corte_color, all(P == [unico-blanco-lino,
                                   chico-rojo-algodon, chico-rojo-lana])) :-
    prenda_corte_color(T, C, M),
    P = T-C-M.

test(prenda_corte_final, all(P == [unico-blanco-lino,
                                   chico-rojo-algodon])) :-
    prenda_corte_final(T, C, M),
    P = T-C-M.

% Ejercicio 17: las cuatro formas del enunciado.
test(identifica_maximo, all(Z == [maximo])) :-
    identifica([1, 3, 4, 10, 99, 98, 23, 2], Z).

test(identifica_minimo, all(Z == [minimo])) :-
    identifica([34, 3, 6, 99, 100], Z).

test(identifica_meseta, all(Z == [meseta])) :-
    identifica([34, 35, 67, 67, 67, 30, 21], Z).

test(identifica_sinorden, all(Z == [sinorden])) :-
    identifica([23, 45, 46, 2, 1, 4], Z).

% Sin subida antes de la cima no hay máximo.
test(identifica_solo_baja, all(Z == [sinorden])) :-
    identifica([5, 4, 3], Z).

test(identifica_no_es_minimo, [fail]) :-
    identifica([1, 3, 4, 10, 99, 98, 23, 2], minimo).

% El corte de la plantilla 14 es rojo: con sinorden ya ligado, la última
% cláusula lo acepta aunque la lista tenga un máximo.
test(identifica_corte_rojo) :-
    identifica([1, 3, 2], sinorden).

% Ejercicio 18
test(sust_borra, all(L == [[p, r, o, l, o, g]])) :-
    sust([p, r, o, l, g, g, o, g, g, g], [g, g], [], L).

test(sust_reemplaza, all(T == [[a, b, c, d, c, b, c, c]])) :-
    sust([a, b, c, d, 1, a, b, c, 1, a], [1, a], [c], T).

test(sust_sin_apariciones, all(L == [[1, 2, 3, 4, z]])) :-
    sust([1, 2, 3, 4, z], [1, 2, 4], [a, b, c, d, e, f], L).

test(sust_verifica, [nondet]) :-
    sust([1, 0, 0, 1, 1], [2], [1, 1], [1, 0, 0, 1, 1]).

test(sust_no_conserva, [fail]) :-
    sust([a, b, a], [a], [x], [a, b, x]).

% Ejercicio 19
test(atomiza, all(X == [[5, s, p, q, r, 2]])) :-
    atomiza([[[5, s], [p, q]], r, [2]], X).

test(atomiza_verifica) :-
    atomiza([1, [[2, a], 3], [4]], [1, 2, a, 3, 4]).

% La unificación con [] después del corte impide aceptar un resultado falso.
test(atomiza_vacia_ligada, [fail]) :-
    atomiza([], [[]]).

:- end_tests(soluciones).
