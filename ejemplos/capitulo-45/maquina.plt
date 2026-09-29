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

:- end_tests(maquina).
