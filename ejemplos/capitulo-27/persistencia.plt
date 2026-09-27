:- encoding(utf8).

:- begin_tests(persistencia).

% Lo registrado con un archivo asociado se recupera al volver a asociarlo.
test(recuperar, [ setup(tmp_file(notas, F)),
                  cleanup(delete_file(F)),
                  true(Notas == [101-am1-9, 102-log-6]) ]) :-
    abrir_notas(F),
    registrar(101, am1, 8),
    registrar(101, am1, 9),
    registrar(102, log, 6),
    cerrar_notas,
    notas([]),
    abrir_notas(F),
    notas(Notas),
    cerrar_notas.

test(tipo_declarado, [ setup(( tmp_file(notas, F), abrir_notas(F) )),
                       cleanup(( cerrar_notas, delete_file(F) )),
                       error(type_error(between(1, 10), 11)) ]) :-
    registrar(101, am1, 11).

:- end_tests(persistencia).
