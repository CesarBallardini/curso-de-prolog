:- encoding(utf8).

:- begin_tests(analisis).

test(informe, [true(Lineas == [ "Programa: 11 archivos, 225 cláusulas, 98 predicados, 120 llamadas entre ellos",
                                "Indefinidos: ninguno",
                                "No alcanzables desde los puntos de entrada:",
                                "    legajo/2 (api.pl:155)",
                                "    resultado_json/3 (api.pl:134)",
                                "Recursivos:",
                                "    bucle/1",
                                "    palabras/3",
                                "    requisito/2",
                                "Avisos de estilo: ninguno",
                                "" ])]) :-
    with_output_to(string(S), informe(inscripciones)),
    split_string(S, "\n", "", Lineas).

test(referencias,
     [true(Lineas == [ "inscripcion_posible/3 (reglas.pl:54)",
                       "    llama a: [alumno/4,materia/3,aprobada/3,cursa/2,correlativa/2,vacantes/2]",
                       "    lo llaman: [inscribir/3,puede_inscribirse/2]",
                       "" ])]) :-
    with_output_to(string(S),
                   referencias(inscripciones, inscripcion_posible/3)),
    split_string(S, "\n", "", Lineas).

:- end_tests(analisis).
