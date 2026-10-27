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

test(nueva_cancelar, all(A == [cancelar(nombre(la, reunion), dia(martes))])) :-
    phrase(soluciones_agenda:nueva(A), [cancela, la, reunion, del, martes]).

test(nueva_cuando, all(A == [cuando_es(nombre(la, reunion))])) :-
    phrase(soluciones_agenda:nueva(A), [cuando, tengo, la, reunion]).

test(nueva_otra_frase, fail) :-
    phrase(soluciones_agenda:nueva(_), [tengo, una, reunion]).

test(de_actividad) :-
    soluciones_agenda:de_actividad(reunion,
        cita(dia(martes), hora(9, 0), nombre(una, "reunión"), nadie, ninguno)).

test(de_otra_actividad, fail) :-
    soluciones_agenda:de_actividad(clase,
        cita(dia(martes), hora(9, 0), nombre(una, "reunión"), nadie, ninguno)).

test(nuevo_efecto_cancelar,
     true(A-R == [C2, C3]-canceladas(dia(martes), [C1]))) :-
    C1 = cita(dia(martes), hora(9, 0), nombre(una, "reunión"), nadie, ninguno),
    C2 = cita(dia(martes), hora(11, 0), nombre(una, "clase"), nadie, ninguno),
    C3 = cita(dia(lunes), hora(9, 0), nombre(una, "reunión"), nadie, ninguno),
    soluciones_agenda:nuevo_efecto(cancelar(nombre(la, reunion), dia(martes)),
                                   [C1, C2, C3], A, R).

test(nuevo_efecto_cuando, true(R == cuando_es([C1]))) :-
    C1 = cita(dia(lunes), hora(9, 0), nombre(una, "clase"), nadie, ninguno),
    C2 = cita(dia(lunes), hora(11, 0), nombre(una, "cena"), nadie, ninguno),
    soluciones_agenda:nuevo_efecto(cuando_es(nombre(la, clase)), [C1, C2],
                                   _, R).

test(leer_citas, true(Cs == [cita(dia(lunes), hora(9, 0),
                                  nombre(una, "clase"), nadie, ninguno)])) :-
    setup_call_cleanup(
        open_string("cita(dia(lunes), hora(9, 0), nombre(una, \"clase\"), \c
                     nadie, ninguno).\n", In),
        soluciones_agenda:leer_citas(In, Cs),
        close(In)).

test(es_cita) :-
    soluciones_agenda:es_cita(cita(fecha(10, 3), hora(9, 0),
                                   nombre(una, "clase"),
                                   nombre(ninguno, "Ana"), ninguno)).

test(es_cita_con_variable, fail) :-
    soluciones_agenda:es_cita(cita(dia(lunes), hora(9, 0), _, nadie,
                                   ninguno)).

test(es_cita_hora_mal, fail) :-
    soluciones_agenda:es_cita(cita(dia(lunes), hora(nueve, 0),
                                   nombre(una, "clase"), nadie, ninguno)).

:- end_tests(soluciones_agenda).
