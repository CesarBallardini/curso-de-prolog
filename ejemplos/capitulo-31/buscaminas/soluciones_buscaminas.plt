:- encoding(utf8).

% Pruebas de soluciones_buscaminas.pl: los niveles, y el programa ejecutado
% en otro proceso con --nivel.

:- use_module(library(process)).
:- use_module(library(readutil)).

:- begin_tests(soluciones_buscaminas).

%!  primera_linea(+Argumentos:list, -Linea:string, -Estado) is det.
%
%   Ejecuta soluciones_buscaminas.pl con Argumentos y sin jugadas; Linea es
%   la primera línea que escribe, y Estado, exit(Codigo).
primera_linea(Argumentos, Linea, Estado) :-
    source_file(user:nivel(_, _, _, _), Programa),
    process_create(path(swipl), [Programa|Argumentos],
                   [ stdin(null), stdout(pipe(Out)), stderr(null),
                     process(Pid) ]),
    read_line_to_string(Out, Linea),
    read_string(Out, _, _),
    close(Out),
    process_wait(Pid, Estado).

test(niveles, true(Ns == [principiante-10, intermedio-40, experto-99])) :-
    findall(N-M, nivel(N, _, _, M), Ns).

test(principiante, true(L == "     1  2  3  4  5  6  7  8  9")) :-
    primera_linea(['--nivel=principiante'], L, _).

% Un nivel que no existe lo rechaza argv_options/3, con el código 1.
test(nivel_desconocido, true(E == exit(1))) :-
    primera_linea(['--nivel=facil'], _, E).

% Sin nivel ni números, el error de uso de siempre.
test(sin_tablero, true(E == exit(2))) :-
    primera_linea([], _, E).

:- end_tests(soluciones_buscaminas).
