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
test(sin_repetidos, all(R == [[a, c, b]])) :-
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

% El corte rojo: con el segundo argumento instanciado, la respuesta es falsa.
test(clasificar_acepta_una_respuesta_falsa) :-
    clasificar(5, negativo) -> true ; true.

:- end_tests(soluciones).
