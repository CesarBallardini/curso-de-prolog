:- encoding(utf8).

% El servidor arranca con tres trabajadores al empezar la unidad de las
% pruebas por la red. Las respuestas se comparan con las de preguntar/1
% en el mismo proceso.

:- use_module(preguntas, [ejemplo/2, preguntar/1]).
:- use_module(library(http/thread_httpd), [http_workers/2]).

:- dynamic puerto_de_prueba/1.

%!  arrancar is det.
%
%   Arranca el servidor de las pruebas en un puerto libre.
arrancar :-
    iniciar(Puerto, 3),
    assertz(puerto_de_prueba(Puerto)).

%!  parar is det.
%
%   Detiene el servidor de las pruebas.
parar :-
    retract(puerto_de_prueba(Puerto)),
    detener(Puerto).

%!  lineas_locales(+Texto, -Lineas:list(string)) is det.
%
%   Lineas son las líneas que preguntar/1 escribe para Texto.
lineas_locales(Texto, Lineas) :-
    with_output_to(string(S), preguntar(Texto)),
    split_string(S, "\n", "", Partes),
    exclude(==(""), Partes, Lineas).

:- begin_tests(servicio_puro).

test(json, [true(L == ["2",
                              "  ana: inscripcion(101, alg, 9), 9 >= 6",
                              "  diego: inscripcion(104, alg, 7), 7 >= 6"])]) :-
    respuesta_json("¿Cuántos aprobaron álgebra?", D),
    get_dict(lineas, D, L).

test(json_sql, [true(S == "SELECT EXISTS (SELECT 1 FROM inscripciones t1 \c
                               WHERE t1.legajo = 101 AND t1.materia = 'log' \c
                               AND t1.nota >= 6)")]) :-
    respuesta_json("¿Ana aprobó lógica?", D),
    get_dict(sql, D, S).

test(json_sin_analisis, [true(S == null)]) :-
    respuesta_json("¿Quién enseña lógica?", D),
    get_dict(sql, D, S).

test(pagina_vacia, [true(Cuerpo == [ h1('Preguntas sobre Inscripciones'),
                                    form([action('/'), method(get)],
                                         [ input([name(texto), value(""),
                                                  size(50)]),
                                           input([type(submit),
                                                  value('Preguntar')]) ]) ])]) :-
    cuerpo_pagina("", Cuerpo).

test(pagina, [true(R == [ h2('Respuesta'),
                          pre('Sí\n  inscripcion(101, log, 10), 10 >= 6'),
                          h2('SQL'),
                          pre("SELECT EXISTS (SELECT 1 FROM inscripciones t1 \c
                               WHERE t1.legajo = 101 AND t1.materia = 'log' \c
                               AND t1.nota >= 6)") ])]) :-
    cuerpo_pagina("¿Ana aprobó lógica?", [_, _|R]).

:- end_tests(servicio_puro).

:- begin_tests(servicio, [setup(arrancar), cleanup(parar)]).

test(una, [true(L0 == L)]) :-
    puerto_de_prueba(P),
    preguntar_servicio(P, "¿Quién cursa lógica?", D),
    get_dict(lineas, D, L0),
    lineas_locales("¿Quién cursa lógica?", L).

% Las dieciséis preguntas a la vez: las mismas respuestas que en el
% proceso, en el orden de las preguntas.
test(a_la_vez, [true(Ls == Esperadas)]) :-
    puerto_de_prueba(P),
    findall(T, ejemplo(_, T), Ts),
    muchas_preguntas(P, Ts, Ls),
    maplist(lineas_locales, Ts, Esperadas).

test(tres, [true(N == 3)]) :-
    puerto_de_prueba(P),
    http_workers(P, N).

:- end_tests(servicio).
