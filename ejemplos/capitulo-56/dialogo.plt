:- encoding(utf8).

:- begin_tests(dialogo).

%!  con_entrada(+Texto:string, -Lineas:list(string)) is det.
%
%   Lineas son las líneas que escribe dialogo/1 al leer las frases de
%   Texto.
con_entrada(Texto, Lineas) :-
    setup_call_cleanup(
        open_string(Texto, In),
        with_output_to(string(Salida), dialogo(In)),
        close(In)),
    split_string(Salida, "\n", "", Lineas).

test(agenda_o_eliza, true(R1-R2 == "Anotado: el lunes a las 9:00, un \c
                                   examen."-"¿Qué te asusta de ese \c
                                   examen?")) :-
    dialogo_inicial(E0),
    responder("Tengo un examen el lunes a las 9", E0, E1, R1),
    responder("Tengo miedo de ese examen", E1, _, R2).

test(sesion, true(Lineas ==
                  [ "Hola. Cuéntame qué te preocupa, o dime qué citas \c
                     tienes.",
                    "> ¿Por qué estás cansada?",
                    "> ¿Qué piensas de que tu jefe te diga que trabajas \c
                     poco?",
                    "> Anotado: el martes a las 10:00, una reunión con \c
                     Pérez en la oficina.",
                    "> ¿Qué te asusta de esa reunión?",
                    "> Anotado: el martes a las 13:30, un almuerzo con \c
                     Ana.",
                    "> El martes: a las 10:00, una reunión con Pérez en \c
                     la oficina; a las 13:30, un almuerzo con Ana.",
                    "> ¿Te preocupan las máquinas?",
                    "> Antes dijiste que tu jefe te dice que trabajas \c
                     poco. ¿Tiene algo que ver con esto?",
                    "> El martes a las 10:00 estás en la oficina.",
                    "> Adiós. Gracias por conversar.",
                    ""
                  ])) :-
    con_entrada("Estoy cansada.\n\c
                 Mi jefe me dice que trabajo poco.\n\c
                 Tengo una reunión con Pérez el martes a las 10 en la \c
                 oficina.\n\c
                 Tengo miedo de esa reunión.\n\c
                 Tengo un almuerzo con Ana el martes a las 1 y media de \c
                 la tarde.\n\c
                 ¿Qué tengo el martes?\n\c
                 Creo que eres una computadora.\n\c
                 Bueno.\n\c
                 ¿Dónde estoy el martes a las 10?\n\c
                 Adiós.\n", Lineas).

test(dialogo_inicial, true(E == dialogo(eliza(t, []), []))) :-
    dialogo_inicial(E).

test(estado_tras_cita, true(A-T == [cita(dia(lunes), hora(9, 0),
                                         nombre(un, "examen"), nadie,
                                         ninguno)]-t)) :-
    dialogo_inicial(E0),
    responder("Tengo un examen el lunes a las 9", E0,
              dialogo(eliza(T, _), A), _).

test(estado_tras_eliza, true(A == [])) :-
    dialogo_inicial(E0),
    responder("Estoy cansada", E0, dialogo(_, A), _).

:- end_tests(dialogo).
