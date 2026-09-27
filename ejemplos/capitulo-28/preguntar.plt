:- encoding(utf8).

% Pruebas de preguntar.pl: la entrada es un stream sobre una cadena, y la
% salida se captura en otra.

:- begin_tests(preguntar).

%!  responder(+Entrada:string, -In, :Pregunta, -Salida:string) is det.
%
%   Ejecuta Pregunta con In, un stream sobre Entrada, como teclado; Salida
%   es lo que Pregunta escribió.
responder(Entrada, In, Pregunta, Salida) :-
    setup_call_cleanup(open_string(Entrada, In),
                       with_output_to(string(Salida), Pregunta),
                       close(In)).

test(preguntar, true(R == "Ana Paz")) :-
    responder("  Ana   Paz \n", In, preguntar(In, "Nombre:", R), _).

test(entrada_terminada, error(existence_error(respuesta, "Nombre:"))) :-
    responder("", In, preguntar(In, "Nombre:", _), _).

test(si, true(R == si)) :-
    responder("S\n", In, preguntar_si_no(In, "¿Seguir?", R), _).

test(no, true(R == no)) :-
    responder("no\n", In, preguntar_si_no(In, "¿Seguir?", R), _).

% Una respuesta que no sirve: un aviso, y la pregunta otra vez.
test(repetir, true(R-S == si-"¿Seguir? (s/n) Responder s o n.\n\c
                                ¿Seguir? (s/n) ")) :-
    responder("tal vez\nsí\n", In, preguntar_si_no(In, "¿Seguir?", R), S).

test(numero, true(N == 7)) :-
    responder("doce\n15\n7\n", In, preguntar_numero(In, "Nota", 1, 10, N), _).

test(numero_no_entero, true(N == 8)) :-
    responder("7.5\n8\n", In, preguntar_numero(In, "Nota", 1, 10, N), _).

:- end_tests(preguntar).
