:- encoding(utf8).

:- begin_tests(lexico).

test(palabras_y_simbolos,
     [true(Ts == [n(select), n(nombre), n(from), n(alumnos), n(where),
                  n(ingreso), >=, i(2024)])]) :-
    tokens("SELECT nombre FROM alumnos WHERE ingreso >= 2024", Ts).

test(mayusculas, [true(Ts == [n(alumnos), n(nombre)])]) :-
    tokens("Alumnos NOMBRE", Ts).

test(cadena_con_comilla, [true(Ts == [n(where), n(nombre), <>, s('O''Brien')])]) :-
    tokens("WHERE nombre <> 'O''Brien' -- un comentario", Ts).

test(simbolos_dobles, [true(Ts == [<=, >=, <>, <>, <, >, =])]) :-
    tokens("<= >= <> != < > =", Ts).

test(menos_separado, [true(Ts == [n(x), -, i(5)])]) :-
    tokens("x-5", Ts).

test(puntuacion, [true(Ts == [n(a), '.', *, ',', '(', ')', ;])]) :-
    tokens("a.*,();", Ts).

test(vacio, [true(Ts == [])]) :-
    tokens("  -- solo un comentario", Ts).

test(caracter_extranio, [throws(error(sql(caracter(#)), _))]) :-
    tokens("a # b", _).

test(cadena_abierta, [throws(error(sql(caracter('''')), _))]) :-
    tokens("'abc", _).

:- end_tests(lexico).
