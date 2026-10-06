:- encoding(utf8).

:- begin_tests(catalogo).

test(materias,
     [true(C-G-Cs =@= tabla-(base:materia(A, B, D))-[col(codigo, texto, no_nulo, A),
                                                   col(nombre, texto, no_nulo, B),
                                                   col(anio, entero, no_nulo, D)])]) :-
    relacion(materias, C, G, Cs).

test(nota_admite_nulo, [true(N == nulo)]) :-
    relacion(inscripciones, _, _, Cs),
    memberchk(col(nota, _, N, _), Cs).

test(restricciones,
     [true(Rs == [clave([legajo, materia]), rango(nota, 1, 10)])]) :-
    findall(R, restriccion(inscripciones, R), Rs).

test(relaciones, [true(Ns == [alumnos, correlativas, inscripciones, materias])]) :-
    relaciones(Ns).

test(marcos_comparten_variables) :-
    marcos([desde(alumnos, a), desde(inscripciones, i)], Gs, Ms),
    Gs = [base:alumno(L, _, _, _), base:inscripcion(_, _, _)],
    buscar_columna(columna(a, legajo), [Ms], col(legajo, entero, no_nulo, V), 0),
    V == L.

test(sin_calificar, [true(N-Nivel == nombre-0)]) :-
    marcos([desde(alumnos, a), desde(inscripciones, i)], _, Ms),
    buscar_columna(columna(nombre), [Ms], col(N, _, _, _), Nivel).

test(ambigua, [throws(error(sql(columna_ambigua(legajo)), _))]) :-
    marcos([desde(alumnos, a), desde(inscripciones, i)], _, Ms),
    buscar_columna(columna(legajo), [Ms], _, _).

test(desconocida, [throws(error(sql(columna_desconocida('i.nombre')), _))]) :-
    marcos([desde(alumnos, a), desde(inscripciones, i)], _, Ms),
    buscar_columna(columna(i, nombre), [Ms], _, _).

test(nivel_de_afuera, [true(Nivel == 1)]) :-
    marcos([desde(alumnos, a)], _, Afuera),
    marcos([desde(materias, m)], _, Adentro),
    buscar_columna(columna(legajo), [Adentro, Afuera], _, Nivel).

test(tabla_desconocida, [throws(error(sql(tabla_desconocida(x)), _))]) :-
    marcos([desde(x, x)], _, _).

test(alias_repetido, [throws(error(sql(alias_repetido(a)), _))]) :-
    marcos([desde(alumnos, a), desde(materias, a)], _, _).

test(estado_y_restaurar, [true(Ns-K == [alumnos, correlativas, inscripciones,
                                        materias]-7)]) :-
    estado(E),
    retractall(base:alumno(_, _, _, _)),
    retract(relacion(materias, _, _, _)),
    restaurar(E),
    relaciones(Ns),
    aggregate_all(count, base:alumno(_, _, _, _), K).

:- end_tests(catalogo).
