:- encoding(utf8).

:- begin_tests(ingenuo).

test(constante_en_el_generador, [true(F-M =@= [N]-(base:alumno(_, N, civil, _)))]) :-
    traducir_ingenuo("SELECT nombre FROM alumnos WHERE carrera = 'civil'",
                     F, M).

test(reunion_sin_igualdades,
     [true(M =@= (base:alumno(L, A, _, _), base:inscripcion(L, am1, N)))]) :-
    traducir_ingenuo("SELECT a.nombre, i.nota FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND i.materia = 'am1'",
                     [A, N], M).

test(conjuncion, [true(Fs == [[carla], [elena]])]) :-
    consulta_ingenua("SELECT nombre FROM alumnos WHERE carrera = 'civil'", Fs).

% Los dos errores de resolver la igualdad al compilar fuera de una
% conjunción: OR pierde las filas de la segunda igualdad, y NOT todas.
test(o_pierde_filas, [true(Fs == [[carla], [elena]])]) :-
    consulta_ingenua("SELECT nombre FROM alumnos WHERE carrera = 'civil' OR carrera = 'industrial'", Fs).

test(no_pierde_todas, [true(Fs == [])]) :-
    consulta_ingenua("SELECT nombre FROM alumnos WHERE NOT carrera = 'civil'", Fs).

% Sin NULL: una comparación aritmética con null lanza un error.
test(null_aritmetico, [throws(error(type_error(evaluable, null/0), _))]) :-
    consulta_ingenua("SELECT legajo FROM inscripciones WHERE nota > 5", _).

test(todas_las_columnas, [true(Fs == [[am2, analisis_2, 2], [pp, paradigmas, 2],
                                       [ssl, sintaxis, 2],
                                       [bd, bases_de_datos, 3]])]) :-
    consulta_ingenua("SELECT * FROM materias WHERE anio > 1", Fs).

:- end_tests(ingenuo).
