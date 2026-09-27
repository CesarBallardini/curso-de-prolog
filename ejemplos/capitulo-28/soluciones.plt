:- encoding(utf8).

:- begin_tests(soluciones).

%!  responder(+Entrada:string, -In, :Pregunta, -Salida:string) is det.
%
%   Ejecuta Pregunta con In, un stream sobre Entrada, como teclado; Salida
%   es lo que Pregunta escribió.
responder(Entrada, In, Pregunta, Salida) :-
    setup_call_cleanup(open_string(Entrada, In),
                       with_output_to(string(Salida), Pregunta),
                       close(In)).

%!  eco(-Archivo:atom) is det.
%
%   Archivo es la ruta de eco.pl, en el directorio de este capítulo.
eco(Archivo) :-
    source_file(user:codigo_de(_, _, _), Soluciones),
    file_directory_name(Soluciones, Directorio),
    directory_file_path(Directorio, 'eco.pl', Archivo).

% Ejercicio 4: un número fuera de rango, y después uno válido.
test(preguntar_opcion, true(E == algebra)) :-
    responder("3\n2\n", In,
              preguntar_opcion(In, "¿Materia?", [logica, algebra], E), _).

% Ejercicio 5.
test(guepardo, true(A == guepardo)) :-
    responder("s\ns\ns\ns\n", In, identificar(In, A), _).

test(tigre, true(A == tigre)) :-
    responder("s\ns\ns\nn\nn\ns\n", In, identificar(In, A), _).

test(desconocido, true(A == desconocido)) :-
    responder("n\nn\nn\nn\n", In, identificar(In, A), _).

% Cada dato se pregunta una sola vez: cuatro preguntas para el guepardo.
test(sin_repetir, true(N == 4)) :-
    responder("s\ns\ns\ns\n", In, identificar(In, _), S),
    aggregate_all(count, sub_string(S, _, _, _, "(s/n)"), N).

% Ejercicio 6.
test(primera_linea, true(Inicio == "SWI-Prolog")) :-
    primera_linea_de(swipl, ['--version'], L),
    sub_string(L, 0, 10, _, Inicio).

% Ejercicio 7: el programa del ejercicio 3, con y sin argumentos.
test(eco_con_argumentos, true(C == 0)) :-
    eco(Eco),
    codigo_de(Eco, [uno, dos], C).

test(eco_sin_argumentos, true(C == 1)) :-
    eco(Eco),
    codigo_de(Eco, [], C).

% Ejercicio 8.
test(antes_del_cumpleanios, true(E == 20)) :-
    edad_en(date(2005, 10, 3), date(2026, 9, 25), E).

test(el_dia_del_cumpleanios, true(E == 21)) :-
    edad_en(date(2005, 9, 25), date(2026, 9, 25), E).

% Ejercicio 9: de un viernes al lunes siguiente.
test(proximo_habil, true(H == date(2026, 9, 28))) :-
    proximo_habil(date(2026, 9, 25), H).

test(proximo_habil_entre_semana, true(H == date(2026, 9, 23))) :-
    proximo_habil(date(2026, 9, 22), H).

% Ejercicio 10.
test(fecha_corta, true(T == "vie 25/09")) :-
    fecha_corta(date(2026, 9, 25), T).

test(fecha_corta_con_cero, true(T == "sáb 05/09")) :-
    fecha_corta(date(2026, 9, 5), T).

% Ejercicio 11: la ruta termina con el nombre del programa.
test(directorio_de_datos) :-
    directorio_de_datos(inscripciones, D),
    file_base_name(D, inscripciones),
    \+ sub_atom(D, _, _, _, '\\').

:- end_tests(soluciones).
