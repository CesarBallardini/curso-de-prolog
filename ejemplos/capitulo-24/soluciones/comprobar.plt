:- encoding(utf8).

:- use_module('../inscripciones/datos').

:- begin_tests(comprobar).

% with_output_to/2, que captura la salida, se presenta en el capítulo 27.
% setup_call_cleanup/3, que asegura la limpieza, se presenta en el capítulo 25.
% La advertencia va a la salida de errores, que with_output_to/2 no captura.
% Las pruebas dan a la salida capturada el alias user_error mientras se
% ejecuta el objetivo, y después lo devuelven a la salida de errores original.
errores(Objetivo, S) :-
    stream_property(Err, alias(user_error)),
    with_output_to(string(S),
                   ( current_output(Out),
                     setup_call_cleanup(set_stream(Out, alias(user_error)),
                                        Objetivo,
                                        set_stream(Err, alias(user_error))) )).

test(sin_advertencias, true(S == "")) :-
    errores(comprobar_vacantes, S).

test(con_vacantes_negativas,
     [ setup(estado(E)), cleanup(restaurar(E)),
       true(S == "Vacantes negativas: log tiene -1\n") ]) :-
    cambiar_vacantes(log, -1),
    errores(comprobar_vacantes, S).

:- end_tests(comprobar).
