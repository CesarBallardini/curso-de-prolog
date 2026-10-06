:- encoding(utf8).

:- begin_tests(maquina).

test(suma, [true(S == [5])]) :-
    maquina([apilar(2), apilar(3), sumar, escribir], S).

test(orden_de_operandos, [true(S == [7, 2, 1])]) :-
    maquina([apilar(10), apilar(3), restar, escribir,
             apilar(7), apilar(3), dividir, escribir,
             apilar(2), apilar(3), comparar(<), escribir], S).

test(memoria, [true(S == [0, 4])]) :-
    maquina([cargar(3), escribir, apilar(4), guardar(3), cargar(3),
             escribir], S).

test(saltos, [true(S == [2])]) :-
    maquina([apilar(0), saltar_si_cero(4), apilar(1), escribir,
             apilar(2), escribir], S).

test(vacio, [true(S == [])]) :-
    maquina([], S).

test(correr, [true(S == [42])]) :-
    correr("x := 6; y := x * 7; escribir y", S).

% El código compilado escribe lo mismo que el intérprete.
test(como_el_interprete, [forall(fuente_ejemplo(_, T)),
                          true(Maquina == Interprete)]) :-
    correr(T, Maquina),
    ejecutar(T, Interprete).

test(division_por_cero, [error(evaluation_error(zero_divisor))]) :-
    correr("x := 0; escribir 1 / x", _).

test(paso_apilar, true(E-S == s(1, [4], t)-[])) :-
    phrase(paso(apilar(4), s(0, [], t), E), S).

test(paso_escribir, true(E-S == s(3, [], t)-[7])) :-
    phrase(paso(escribir, s(2, [7], t), E), S).

test(saltar_si_cero, true(E == s(9, [], t))) :-
    phrase(paso(saltar_si_cero(9), s(0, [0], t), E), _).

test(no_saltar, true(E == s(1, [], t))) :-
    phrase(paso(saltar_si_cero(9), s(0, [1], t), E), _).

test(operacion_orden, true(E == s(1, [5], t))) :-
    operacion(-, s(0, [2, 7], t), E).

test(celda_sin_escribir, true(V == 0)) :-
    empty_assoc(M),
    celda(3, M, V).

test(celda, true(V == 8)) :-
    list_to_assoc([3-8], M),
    celda(3, M, V).

test(ciclo, true(S == [5])) :-
    phrase(ciclo(codigo(apilar(5), escribir), s(0, [], t)), S).

:- end_tests(maquina).
