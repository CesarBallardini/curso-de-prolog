:- encoding(utf8).

% Pruebas del módulo consola (capítulo 31): las respuestas, los códigos de
% salida y el bucle, con la entrada en una cadena y la salida capturada.

:- use_module(datos).

:- begin_tests(consola).

%!  en_bucle(+Entrada:string, -Salida:string) is det.
%
%   Salida es lo que escribe el bucle leyendo las órdenes de Entrada.
en_bucle(Entrada, Salida) :-
    setup_call_cleanup(open_string(Entrada, In),
                       with_output_to(string(Salida), bucle(In)),
                       close(In)).

test(listar, true(S-R == "Inscriptos: 101, 102, 104, 106.\n"
                        -inscriptos([101, 102, 104, 106]))) :-
    with_output_to(string(S), responder("listar logica", R)).

test(rechazada, true(S == "Rechazada: sin_vacantes.\n")) :-
    with_output_to(string(S), responder("inscribir a 105 en logica", _)).

test(no_entendido, true(R == no_entendido)) :-
    with_output_to(string(_), responder("hola", R)).

test(ranking, true(R == ranking)) :-
    with_output_to(string(S), responder("ranking", R)),
    sub_string(S, 0, 6, _, "Legajo").

test(codigos, true(Codigos == [0, 0, 1, 1, 2])) :-
    maplist(codigo_de_salida,
            [aceptada, inscriptos([]), rechazada(sin_vacantes),
             no_entendido, error(type_error(text, 3))],
            Codigos).

test(bucle, true(S == "inscripciones> Inscriptos: 101, 102, 104, 106.\n\c
                       inscripciones> inscripciones> ")) :-
    en_bucle("listar logica\n\nsalir\nlistar sintaxis\n", S).

% El bucle también termina cuando la entrada se termina.
test(fin_de_la_entrada, true(S == "inscripciones> \n")) :-
    en_bucle("", S).

% Una inscripción en el bucle cambia el estado.
test(bucle_inscribe, [ setup(estado(E)), cleanup(restaurar(E)),
                       true(Estado == cursando) ]) :-
    en_bucle("inscribir a 104 en sintaxis\n", _),
    inscripcion(104, ssl, Estado).

:- end_tests(consola).
