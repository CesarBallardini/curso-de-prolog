:- encoding(utf8).

% Pruebas de generar.pl: el generador de números, las sesiones, y que los
% archivos de archivos/ son exactamente lo que el generador escribe.

:- use_module(library(readutil)).

:- begin_tests(generar).

% lineas_de(Archivo, Lineas): las líneas del registro Archivo.
lineas_de(Archivo, Lineas) :-
    absolute_file_name(registros(Archivo), Ruta, [access(read)]),
    read_file_to_string(Ruta, Texto, [encoding(utf8)]),
    split_string(Texto, "\n", "", Lineas0),
    once(append(Lineas, [""], Lineas0)).

test(azar_rango, [true(Xs == [0, 1, 2])]) :-
    findall(X, ( between(1, 300, S0), azar(3, X, S0, _) ), Todos),
    sort(Todos, Xs).

test(azar_determinista, [true(X1-S1 == X2-S2)]) :-
    azar(1000, X1, 42, S1),
    azar(1000, X2, 42, S2).

test(sesion_sin_errores, [true(Codigos == [200, 200, 200])]) :-
    generar:sesion(100, 120, 0, 2, Eventos, 7, _),
    findall(C, member(ev(_, _, _, _, C, _, _), Eventos), Codigos).

test(sesion_con_errores, [true(Codigos == [401, 401, 200])]) :-
    generar:sesion(100, 120, 2, 1, Eventos, 7, _),
    findall(C, member(ev(_, _, post, '/sesion', C, _, _), Eventos), Codigos).

test(sesiones_del_dia, [true(N >= 50)]) :-
    sesiones(1, Eventos, 1, _),
    aggregate_all(count, member(ev(_, _, post, '/sesion', 200, _, _), Eventos),
                  N).

test(eventos_ordenados) :-
    eventos_del_dia(4, Eventos),
    msort(Eventos, Eventos).

test(archivos_iguales, [forall(dia(N, _))]) :-
    eventos_del_dia(N, Eventos),
    generar:registros_del_dia(N, Eventos, Pares),
    pairs_values(Pares, Esperadas0),
    maplist(atom_string, Esperadas0, Esperadas),
    dia(N, date(A, M, D)),
    format(atom(Nombre), "~d-~|~`0t~d~2+-~|~`0t~d~2+.log", [A, M, D]),
    lineas_de(Nombre, Lineas),
    assertion(Lineas == Esperadas).

test(comun_tiene_dos_defectuosas, [true(N == 2)]) :-
    lineas_de('2026-10-01-comun.log', Lineas),
    aggregate_all(count,
                  ( member(L, Lineas),
                    \+ sub_string(L, _, _, _, " HTTP/1.1\" ") ),
                  N).

:- end_tests(generar).
