:- encoding(utf8).

:- begin_tests(soluciones_simbolos).

test(repetida, [error(permission_error(marcar, etiqueta, a))]) :-
    ensamblar([etiqueta(a), sumar, etiqueta(a)], _).

% Dos marcas seguidas tienen la misma dirección, y también son un error.
test(repetida_seguida, [error(permission_error(marcar, etiqueta, a))]) :-
    ensamblar([etiqueta(a), etiqueta(a), sumar], _).

test(adelante, true(C == [saltar(2), sumar])) :-
    ensamblar([saltar(fin), sumar, etiqueta(fin)], C).

test(atras, true(C == [sumar, saltar(0)])) :-
    ensamblar([etiqueta(inicio), sumar, saltar(inicio)], C).

test(sin_marca, [error(existence_error(etiqueta, fin))]) :-
    ensamblar([saltar(fin)], _).

test(asignar, true(C-N == [cargar(0), cargar(1), sumar, guardar(0)]-2)) :-
    asignar([cargar(x), cargar(y), sumar, guardar(x)], C, N).

test(asignar_sin_variables, true(C-N == [sumar]-0)) :-
    asignar([sumar], C, N).

test(asignar_cuenta, true(N == 1)) :-
    programa(cuenta, P),
    ensamblar(P, C0),
    asignar(C0, C, N),
    memberchk(guardar(0), C).

% Ejercicio 13: la marca liga la dirección que un salto anterior dejó libre.
test(marcar_despues_de_saltar, true(D == 4)) :-
    buscar(e, T, D),
    marcar(e, T, 4).

:- end_tests(soluciones_simbolos).
