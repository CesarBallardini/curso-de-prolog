:- encoding(utf8).

:- begin_tests(doctor).

%!  respuestas(+Frases:list(string), -Respuestas:list(string)) is det.
%
%   Respuestas son las respuestas del guion a Frases, dichas en orden desde
%   el estado inicial.
respuestas(Frases, Respuestas) :-
    estado_doctor(E0),
    foldl(paso, Frases, Respuestas, E0, _).

%!  paso(+Frase, -Respuesta, +E0, -E) is det.
%
%   responder_doctor/4 con el estado en los dos últimos argumentos.
paso(Frase, Respuesta, E0, E) :-
    responder_doctor(Frase, E0, E, Respuesta).

% La conversación de la sección 55.9, frase por frase.
test(conversacion,
     true(Rs == [ "¿En qué sentido?",
                  "¿Puedes pensar en un ejemplo concreto?",
                  "Tu novio te hizo venir aquí.",
                  "Lamento oír que estás deprimida.",
                  "¿Crees que venir aquí te ayudará a no ser infeliz?",
                  "¿Qué significaría para ti conseguir un poco de ayuda?",
                  "Háblame más de tu familia.",
                  "¿Quién más en tu familia te cuida?",
                  "Tu padre.",
                  "¿Qué parecido ves?",
                  "Hablemos más de por qué tu novio te hizo venir aquí."
                ])) :-
    respuestas([ "Los hombres son todos iguales.",
                 "Siempre nos molestan con algo.",
                 "Bueno, mi novio me hizo venir aquí.",
                 "Dice que estoy deprimida la mayor parte del tiempo.",
                 "Es verdad. Soy infeliz.",
                 "Necesito un poco de ayuda.",
                 "Quizás podría llevarme bien con mi madre.",
                 "Mi madre me cuida.",
                 "Mi padre.",
                 "Te pareces a mi padre en algunas cosas.",
                 "Bueno."
               ], Rs).

test(estado_doctor, true(E == doctor(t, []))) :-
    estado_doctor(E).

test(explorar, true(T-P == [quizas, podria, "tu", madre]-[mi, quizas])) :-
    explorar([quizas, podria, mi, madre], T, P).

% Una clave de rango mayor va arriba; una de rango menor o igual, abajo.
test(pila, true(P == [computadora, mi, siempre])) :-
    explorar([mi, padre, siempre, dice, que, eres, una, computadora], _, P).

test(sin_claves, true(T-P == [hola]-[])) :-
    explorar([hola], T, P).

test(descomponer_cero, true(Ps == [[a, b], [te], [c]])) :-
    descomponer([0, te, 0], [a, b, te, c], Ps).

test(descomponer_contada, true(Ps == [[a], [te], [b], ["te"], [c, d]])) :-
    descomponer([0, te, 1, "te", 0], [a, te, b, "te", c, d], Ps).

test(descomponer_contada_falla, fail) :-
    descomponer([0, te, 1, "te", 0], [a, te, b, c, "te"], _).

test(descomponer_clase, true(Ps == [[], ["tu"], [], [madre], [me]])) :-
    descomponer([0, "tu", 0, clase(familia), 0], ["tu", madre, me], Ps).

test(descomponer_alguna, true(Ps == [["estás"], [triste]])) :-
    descomponer(["estás", alguna([triste, infeliz])], ["estás", triste],
                Ps).

test(descomponer_alguna_falla, fail) :-
    descomponer(["estás", alguna([triste, infeliz])], ["estás", bien], _).

test(reensamblar, true(R == "¿Quién más en tu familia te cuida?")) :-
    reensamblar("Mi madre me cuida.",
                ["¿Quién más en tu familia ", 5, "?"]
                - [[], ["tu"], [], [madre], ["te", cuida]],
                _, R).

test(reensamblar_tildes, true(R == "Tu novio te hizo venir aquí.")) :-
    reensamblar("Mi novio me hizo venir aquí.", ["Tu ", 3, "."]
                - [[], ["tu"], [novio, "te", hizo, venir, aqui]], _, R).

% Las claves que redirigen comparten los turnos de la clave de destino.
test(ir_a, true(Rs == ["¿En qué sentido?", "¿Qué parecido ves?"])) :-
    respuestas(["Somos iguales.", "Te pareces a mi tía."], Rs).

% La segunda vez, porque pasa la frase a la clave siguiente de la pila.
test(nueva_clave, true(Rs == ["¿Es esa la verdadera razón?",
                              "Lamento oír que estás triste."])) :-
    respuestas(["Estoy triste porque nadie me escucha.",
                "Estoy triste porque nadie me escucha."], Rs).

test(ninguna, true(Rs == ["Continúa, por favor.",
                          "No estoy seguro de entenderte del todo."])) :-
    respuestas(["Bueno.", "Nada."], Rs).

% La memoria se usa en orden y se descarta.
test(memoria, true(Rs == ["Tu jefe te grita.",
                          "Antes dijiste que tu jefe te grita.",
                          "Continúa, por favor."])) :-
    respuestas(["Mi jefe me grita.", "Bueno.", "Nada."], Rs).

test(doctor, true(Lineas == ["¿Cómo estás? Cuéntame tu problema.",
                             "> ¿Te preocupan las computadoras?",
                             "> Adiós. Gracias por conversar.",
                             ""])) :-
    setup_call_cleanup(
        open_string("Las computadoras me ponen nerviosa.\nadiós\n", In),
        with_output_to(string(Salida), doctor(In)),
        close(In)),
    split_string(Salida, "\n", "", Lineas).

% Una palabra que no es clave se sustituye y no entra en la pila.
test(explorar_palabra, true(Q-P == "te"-[computadora])) :-
    doctor:explorar_palabra(me, Q, [computadora], P).

test(explorar_palabra_clave, true(Q-P == computadora-[computadora, mi])) :-
    doctor:explorar_palabra(computadora, Q, [mi], P).

test(parte_contada, all(P-R == [[a, b]-[c]])) :-
    doctor:parte(2, [a, b, c], P, R).

test(parte_cero, all(P == [[], [a], [a, b]])) :-
    doctor:parte(0, [a, b], P, _).

test(turno, true(Rs == [a, b, a])) :-
    empty_assoc(T0),
    doctor:turno(r, [a, b], T0, T1, R1),
    doctor:turno(r, [a, b], T1, T2, R2),
    doctor:turno(r, [a, b], T2, _, R3),
    Rs = [R1, R2, R3].

test(transformar_ir_a,
     true(R == ["¿Te preocupan las computadoras?"]-[[una, maquina]])) :-
    empty_assoc(T0),
    doctor:transformar([ir_a(computadora)], maquina, [una, maquina], T0, _,
                       R).

test(transformar_nueva_clave, true(R == nueva_clave)) :-
    empty_assoc(T0),
    put_assoc(porque-[0, porque, 0], T0, 1, T1),
    doctor:clave(porque, _, Reglas),
    doctor:transformar(Reglas, porque, [a, porque, b], T1, _, R).

test(recordar_frase, true(M == ["x", "Antes dijiste que tu jefe te grita."])) :-
    doctor:recordar_frase("Mi jefe me grita.", [mi],
                          ["tu", jefe, "te", grita], ["x"], M).

test(no_recordar_frase, true(M == ["x"])) :-
    doctor:recordar_frase("Estoy bien.", [estoy], ["estás", bien], ["x"], M).

:- end_tests(doctor).
