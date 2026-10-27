:- encoding(utf8).

:- begin_tests(formatos).

test(alumnos_csv, true(A-N == alumno(101, ana, sistemas, 2023)-7)) :-
    alumnos_csv(archivos('alumnos.csv'), [A|Resto]),
    length([A|Resto], N).

% Los números del CSV llegan como números; los textos, como átomos.
test(alumnos_csv_tipos) :-
    alumnos_csv(archivos('alumnos.csv'), Alumnos),
    forall(member(alumno(L, N, C, I), Alumnos),
           ( integer(L), atom(N), atom(C), integer(I) )).

test(materias_json, true(M-N == materia(am1, analisis_1, 1)-7)) :-
    materias_json(archivos('materias.json'), [M|Resto]),
    length([M|Resto], N).

% Un objeto con un campo de más se lee igual.
test(campo_de_mas, true(M == materia(bd, bases_de_datos, 3))) :-
    objeto_materia(_{codigo: bd, nombre: bases_de_datos, anio: 3,
                     horas: 6}, M).

test(json_ida_y_vuelta, true(M2 == M)) :-
    M = [materia(am1, analisis_1, 1), materia(bd, bases_de_datos, 3)],
    materias_a_json(M, Texto),
    atom_json_dict(Texto, Objetos, [value_string_as(atom)]),
    maplist(objeto_materia, Objetos, M2).

test(notas_csv, [ setup(tmp_file(notas, F)),
                  cleanup(delete_file(F)),
                  true(Filas == [row(legajo, materia, nota),
                                 row(101, am1, 8), row(102, log, 6)]) ]) :-
    notas_csv(F, [101-am1-8, 102-log-6]),
    csv_read_file(F, Filas).

test(aprueba_por_omision) :-
    aprueba(6).

test(aprueba_con_ajuste, [ setup(set_setting(user:nota_minima, 7)),
                           cleanup(restore_setting(user:nota_minima)),
                           fail ]) :-
    aprueba(6).

test(ajuste_fuera_de_rango, [ error(type_error(between(1, 10), 11)) ]) :-
    set_setting(user:nota_minima, 11).

test(tabla, true(S == "Legajo  Nombre        Promedio\n\c
                       101     ana               8.50\n")) :-
    with_output_to(string(S), tabla([101-ana-8.5])).

:- end_tests(formatos).
