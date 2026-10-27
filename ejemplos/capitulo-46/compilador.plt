:- encoding(utf8).

:- begin_tests(compilador).

test(mini, [true(Lineas == ["0   apilar(6)", "1   guardar(0)",
                            "2   apilar(7)", "3   cargar(0)",
                            "4   multiplicar", "5   escribir",
                            "salida: [42]", ""])]) :-
    with_output_to(string(S), mini("x := 6; escribir x * 7")),
    split_string(S, "\n", "", Lineas).

test(mini_ejemplo, [true(Ultimas == ["18  escribir", "salida: [120]", ""])]) :-
    with_output_to(string(S), mini_ejemplo(factorial)),
    split_string(S, "\n", "", Lineas),
    append(_, Ultimas, Lineas),
    length(Ultimas, 3),
    !.

test(no_es_mini, [fail]) :-
    with_output_to(string(_), mini("x := ")).

% Las cuatro formas de ejecutar un programa escriben lo mismo.
test(cuatro_formas, [forall(fuente_ejemplo(Nombre, T))]) :-
    programa_ejemplo(Nombre, P),
    interpretar(P, S),
    correr(T, S),
    correr_optimizado(T, S),
    correr_especializado(P, S).

:- end_tests(compilador).
