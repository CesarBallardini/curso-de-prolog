:- encoding(utf8).

:- begin_tests(lemas).

test(preterito_plural, [true(A == verbo("aprobar", preterito, 3, plural))]) :-
    analisis("aprobaron", A).

test(diptongo, [true(A == verbo("aprobar", presente, 3, singular))]) :-
    analisis("aprueba", A).

test(preterito_con_tilde, [true(A == verbo("aprobar", preterito, 3, singular))]) :-
    analisis("aprobó", A).

test(presente, [true(As == [verbo("cursar", presente, 3, plural)])]) :-
    findall(A, analisis("cursan", A), As).

test(nombre_plural, [true(A == nombre("alumno", masculino, plural))]) :-
    analisis("alumnos", A).

test(nombre_femenino, [true(A == nombre("materia", femenino, singular))]) :-
    analisis("materia", A).

test(desconocida, [fail]) :-
    analisis("quién", _).

:- end_tests(lemas).
