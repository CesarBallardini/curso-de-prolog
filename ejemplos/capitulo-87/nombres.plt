:- encoding(utf8).

:- begin_tests(nombres).

test(materia_varias_palabras, [nondet, true(T-E == materia-bd)]) :-
    phrase(nombre_propio(T, E), ["bases", "de", "datos"]).

test(sin_tildes, [nondet, true(T-E == materia-log)]) :-
    phrase(nombre_propio(T, E), ["logica"]).

test(con_tildes, [nondet, true(T-E == materia-am1)]) :-
    phrase(nombre_propio(T, E), ["análisis", "1"]).

test(alumno, [nondet, true(T-E == alumno-101)]) :-
    phrase(nombre_propio(T, E), ["ana"]).

test(carrera, [nondet, true(T-E == carrera-sistemas)]) :-
    phrase(nombre_propio(T, E), ["sistemas"]).

% Una carrera se nombra una vez, aunque tenga varios alumnos.
test(carrera_una_vez, [all(E == [civil])]) :-
    phrase(nombre_propio(carrera, E), ["civil"]).

test(prefijo, [all(T-E-R == [materia-am1-["2"]])]) :-
    phrase(nombre_propio(T, E), ["análisis", "1", "2"], R).

test(desconocido, [fail]) :-
    phrase(nombre_propio(_, _), ["química"]).

test(nombre_de_alumno, [true(N == "ana")]) :-
    nombre_de(101, N).

test(nombre_de_materia, [true(N == "bases de datos")]) :-
    nombre_de(bd, N).

test(nombre_de_carrera, [true(N == "civil")]) :-
    nombre_de(civil, N).

% Cada materia de la base tiene su nombre escrito.
test(todas_escritas, [fail]) :-
    base:materia(M, _, _),
    \+ escrita(M, _).

:- end_tests(nombres).
