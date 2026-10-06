:- encoding(utf8).

:- begin_tests(soluciones_doctor).

test(recuerdo, true(R == ["¿Piensas a menudo en tu infancia?"])) :-
    respuestas_doctor(["Recuerdo mi infancia."], R).

% recuerdo, de rango 5, gana a mi, de rango 2; la frase no se recuerda.
test(gana_a_mi, true(R == ["¿Piensas a menudo en tu barrio?",
                           "Continúa, por favor."])) :-
    respuestas_doctor(["Recuerdo mi barrio.", "Bueno."], R).

test(turnos, true(R == ["¿Piensas a menudo en el mar?",
                        "¿Qué más recuerdas?"])) :-
    respuestas_doctor(["Recuerdo el mar.", "Recuerdo el mar."], R).

test(respuestas_doctor_vacia, true(R == [])) :-
    respuestas_doctor([], R).

:- end_tests(soluciones_doctor).
