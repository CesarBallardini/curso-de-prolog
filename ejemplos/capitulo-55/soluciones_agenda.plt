:- encoding(utf8).

:- begin_tests(soluciones_agenda).

%!  respuestas(+Frases:list(string), -Respuestas:list, -Agenda:list) is det.
%
%   Respuestas son las respuestas de atender_con_cancelar/4 a Frases, en
%   orden y desde una agenda vacía, y Agenda la agenda que queda.
respuestas(Frases, Respuestas, Agenda) :-
    foldl(paso, Frases, Respuestas, [], Agenda).

%!  paso(+Frase, -Respuesta, +A0, -A) is det.
%
%   atender_con_cancelar/4 con la agenda en los dos últimos argumentos.
paso(Frase, Respuesta, A0, A) :-
    once(atender_con_cancelar(Frase, A0, A, Respuesta)).

test(cancelar, true(R-N == "Cancelado: una reunión con Pérez el martes a \c
                             las 10:00."-1)) :-
    respuestas(["Tengo una reunión con Pérez el martes a las 10",
                "Tengo un almuerzo el martes a las 13",
                "Cancela la reunión del martes"], [_, _, R], A),
    length(A, N).

test(cancelar_nada, true(R == "No tienes nada de eso anotado el lunes.")) :-
    respuestas(["Tengo una reunión el martes a las 10",
                "Borra la reunión el lunes"], [_, R], _).

test(cuando_es, true(R == "Tienes una clase el lunes a las 9:00; una \c
                           clase el jueves a las 9:00.")) :-
    respuestas(["Tengo una clase el lunes a las 9",
                "Tengo una clase el jueves a las 9",
                "¿Cuándo tengo la clase?"], [_, _, R], _).

test(sigue_la_agenda, true(R == "No tienes nada anotado el martes.")) :-
    respuestas(["¿Qué tengo el martes?"], [R], _).

test(guardar_y_cargar, true(A == A0)) :-
    respuestas(["Tengo una reunión con Pérez el martes a las 10 en la \c
                 oficina",
                "Tengo un examen el 3 de octubre a la una"], _, A0),
    tmp_file(agenda, Archivo),
    guardar_agenda(Archivo, A0),
    cargar_agenda(Archivo, A),
    delete_file(Archivo).

test(cargar_invalido, error(domain_error(cita, hola))) :-
    tmp_file(agenda, Archivo),
    setup_call_cleanup(open(Archivo, write, Out),
                       format(Out, "hola.~n", []),
                       close(Out)),
    call_cleanup(cargar_agenda(Archivo, _), delete_file(Archivo)).

:- end_tests(soluciones_agenda).
