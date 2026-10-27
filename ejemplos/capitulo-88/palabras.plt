:- encoding(utf8).

:- begin_tests(palabras).

test(palabras, [true(Ps == ["quién", "cursa", "lógica"])]) :-
    palabras("¿Quién cursa Lógica?", Ps).

test(espacios_y_comas, [true(Ps == ["ana", "y", "bruno"])]) :-
    palabras("  ¡Ana,   y Bruno!  ", Ps).

test(vacio, [true(Ps == [])]) :-
    palabras("¿?", Ps).

test(sin_tildes, [true(S == "analisis pinguino")]) :-
    sin_tildes("análisis pingüino", S).

test(sin_tildes_igual, [true(S == "logica")]) :-
    sin_tildes("logica", S).

:- end_tests(palabras).
