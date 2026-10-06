:- encoding(utf8).

:- begin_tests(claves).

test(quien, [true(R == lista(["ana", "bruno", "diego", "facundo"]))]) :-
    responder_claves("¿Quién cursa lógica?", R).

test(cuantos, [true(R == numero(2))]) :-
    responder_claves("¿Cuántos aprobaron álgebra?", R).

test(materias_de_un_alumno,
     [true(R == lista(["álgebra", "análisis 1", "análisis 2", "lógica",
                       "paradigmas"]))]) :-
    responder_claves("¿Qué materias cursa ana?", R).

test(si_no, [true(R == si)]) :-
    responder_claves("¿Ana aprobó lógica?", R).

% Los errores de la versión: la negación no se lee, y da los que aprobaron.
test(no_ignorado, [true(R == lista(["ana", "diego"]))]) :-
    responder_claves("¿Quién no aprobó álgebra?", R).

% La primera entidad es la carrera: cuenta las materias de «sistemas».
test(primera_entidad, [true(R == numero(0))]) :-
    responder_claves("¿Cuántos alumnos de sistemas aprobaron álgebra?", R).

test(datos_carrera, [true(C-V-Es == numero-aprobar-[carrera-sistemas,
                                                    materia-alg])]) :-
    datos_clave("¿Cuántos alumnos de sistemas aprobaron álgebra?",
                C, V, Es).

% Solo las correlativas directas.
test(correlativas_directas, [true(R == lista(["paradigmas", "sintaxis"]))]) :-
    responder_claves("¿Qué necesita bases de datos?", R).

% «aprueba» no empieza con «aprob».
test(aprueba, [fail]) :-
    responder_claves("¿Quién aprueba lógica?", _).

:- end_tests(claves).
