:- encoding(utf8).

:- begin_tests(agenda).

%!  respuestas(+Frases:list(string), -Respuestas:list, -Agenda:list) is det.
%
%   Respuestas son las respuestas de la agenda a Frases, en orden y desde
%   una agenda vacía; no_entiende para una frase que no es de la agenda.
%   Agenda es la agenda que queda.
respuestas(Frases, Respuestas, Agenda) :-
    foldl(paso, Frases, Respuestas, [], Agenda).

%!  paso(+Frase, -Respuesta, +A0, -A) is det.
%
%   atender/4 con la agenda en los dos últimos argumentos.
paso(Frase, Respuesta, A0, A) :-
    (   atender(Frase, A0, A1, R)
    ->  Respuesta = R,
        A = A1
    ;   Respuesta = no_entiende,
        A = A0
    ).

test(acto_anotar, true(A == anotar(nombre(una, reunion),
                                   [con(nombre(ninguno, perez)),
                                    dia(dia(martes)),
                                    hora(hora(10, 30))]))) :-
    once(phrase(acto(A), [tengo, una, reunion, con, perez, el, martes,
                          a, las, '10', y, media])).

test(acto_donde, true(A == donde(fecha(10, 3), hora(13, 0)))) :-
    once(phrase(acto(A), [donde, estoy, a, las, '1', de, la, tarde,
                          el, '3', de, octubre])).

test(anotar, true(R == ["Anotado: el martes a las 10:00, una reunión con \c
                         Pérez en la oficina."])) :-
    respuestas(["Tengo una reunión con Pérez el martes a las 10 en la \c
                 oficina"], R, _).

test(orden_libre, true(A == [cita(dia(jueves), hora(9, 15),
                                  nombre(una, "clase"), nadie,
                                  nombre(el, "aula"))])) :-
    respuestas(["Tengo una clase en el aula a las 9 y cuarto el jueves"],
               _, A).

test(choque, true(R2-N == "Ya tienes una cena el martes a las 21:00."-1)) :-
    respuestas(["Tengo una cena el martes a las 9 de la noche",
                "Tengo un partido el martes a las 21"], [_, R2], Agenda),
    length(Agenda, N).

test(del_dia, true(R == "El martes: a las 10:00, una reunión con Pérez; \c
                         a las 13:30, un almuerzo con Ana.")) :-
    respuestas(["Tengo un almuerzo con Ana el martes a las 1 y media de \c
                 la tarde",
                "Tengo una reunión con Pérez el martes a las 10",
                "¿Qué tengo el martes?"], [_, _, R], _).

test(dia_vacio, true(R == "No tienes nada anotado el miércoles.")) :-
    respuestas(["¿Qué tengo el miércoles?"], [R], _).

test(donde, true(Rs == ["El martes a las 10:00 estás en la oficina.",
                        "El martes a las 11:00 no tienes nada anotado."])) :-
    respuestas(["Tengo una reunión el martes a las 10 en la oficina",
                "¿Dónde estoy el martes a las 10?",
                "¿Dónde tengo que estar el martes a las 11?"], [_|Rs], _).

test(cuando, true(Rs == ["Ves a Pérez el lunes a las 9:00 y el 3 de \c
                          octubre a la 1:00.",
                         "No tienes nada anotado con Luis."])) :-
    respuestas(["Tengo un café con Pérez el lunes a las 9",
                "Tengo turno con Pérez el 3 de octubre a la una",
                "¿Cuándo veo a Pérez?",
                "¿Cuándo veo a Luis?"], [_, _|Rs], _).

test(fecha_invalida, true(R == [no_entiende])) :-
    respuestas(["Tengo una clase el 31 de septiembre a las 9"], R, _).

test(falta_hora, true(R == [no_entiende])) :-
    respuestas(["Tengo una clase el lunes"], R, _).

test(dos_dias, true(R == [no_entiende])) :-
    respuestas(["Tengo una clase el lunes el martes a las 9"], R, _).

test(no_es_de_la_agenda, fail) :-
    atender("Estoy cansado", [], _, _).

test(hora_la_una, all(H == [hora(13, 0)])) :-
    phrase(agenda:hora(H), [a, la, una, de, la, tarde]).

test(hora_cuarto_noche, all(H == [hora(21, 15)])) :-
    phrase(agenda:hora(H), [a, las, '9', y, cuarto, de, la, noche]).

test(hora_minutos, all(H == [hora(10, 45)])) :-
    phrase(agenda:hora(H), [a, las, '10', '45']).

test(hora_invalida, fail) :-
    phrase(agenda:hora(_), [a, las, '25']).

test(dia_fecha, all(D == [fecha(10, 3)])) :-
    phrase(agenda:dia(D), [el, '3', de, octubre]).

test(dia_semana, all(D == [dia(miercoles)])) :-
    phrase(agenda:dia(D), [miercoles]).

test(dia_fecha_invalida, fail) :-
    phrase(agenda:dia(_), [el, '31', de, septiembre]).

test(complemento, all(C == [con(nombre(el, director))])) :-
    phrase(agenda:complemento(C), [con, el, director]).

test(complementos, all(Cs == [[con(nombre(ninguno, ana)),
                               en(nombre(la, oficina))]])) :-
    phrase(agenda:complementos(Cs), [con, ana, en, la, oficina]).

test(efecto_que_hay_ordena,
     true(R == del_dia(dia(lunes), [cita(dia(lunes), hora(9, 0), d, e, f),
                                     cita(dia(lunes), hora(11, 0), a, b, c)]))) :-
    agenda:efecto(que_hay(dia(lunes)), "",
                  [cita(dia(lunes), hora(11, 0), a, b, c),
                   cita(dia(martes), hora(9, 0), x, y, z),
                   cita(dia(lunes), hora(9, 0), d, e, f)], _, R).

test(cita, true(C == cita(dia(lunes), hora(9, 0), nombre(una, "clase"),
                          nadie, ninguno))) :-
    agenda:cita(nombre(una, clase), [hora(hora(9, 0)), dia(dia(lunes))],
                "una clase", C).

test(cita_dos_horas, fail) :-
    agenda:cita(nombre(una, clase),
                [hora(hora(9, 0)), dia(dia(lunes)), hora(hora(10, 0))],
                "una clase", _).

test(oracion_libre, true(S == "El lunes a las 9:05 no tienes nada \c
                               anotado.")) :-
    phrase(agenda:oracion(libre(dia(lunes), hora(9, 5))), Codigos),
    string_codes(S, Codigos).

:- end_tests(agenda).
