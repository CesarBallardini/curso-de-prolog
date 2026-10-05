:- encoding(utf8).

:- begin_tests(eliza).

%!  respuestas(+Frases:list(string), -Respuestas:list(string)) is det.
%
%   Respuestas son las respuestas de ELIZA a Frases, dichas en orden desde
%   el estado inicial.
respuestas(Frases, Respuestas) :-
    estado_inicial(E0),
    foldl(paso, Frases, Respuestas, E0, _).

%!  paso(+Frase, -Respuesta, +E0, -E) is det.
%
%   responder/4 con el estado en los dos últimos argumentos.
paso(Frase, Respuesta, E0, E) :-
    responder(Frase, E0, E, Respuesta).

%!  con_entrada(+Texto:string, -Salida:string) is det.
%
%   Salida es lo que escribe eliza/1 al leer las frases de Texto.
con_entrada(Texto, Salida) :-
    setup_call_cleanup(
        open_string(Texto, In),
        with_output_to(string(Salida), eliza(In)),
        close(In)).

test(rango_maquinas, true(R == ["¿Te preocupan las máquinas?"])) :-
    respuestas(["Mi madre dice que las computadoras son peligrosas"], R).

test(rango_me_dice, true(R == ["¿Qué piensas de que tu madre te diga \c
                                que trabajas poco?"])) :-
    respuestas(["Mi madre me dice que trabajo poco"], R).

test(turnos, true(R == ["¿Por qué estás triste?",
                        "¿Desde cuándo estás cansado?",
                        "¿Por qué estás solo?"])) :-
    respuestas(["Estoy triste", "Estoy cansado", "Estoy solo"], R).

test(memoria, true(R == ["Continúa, por favor.",
                         "Antes dijiste que tu novio te trajo aquí. \c
                          ¿Tiene algo que ver con esto?",
                         "Cuéntame más."])) :-
    respuestas(["Mi novio me trajo aquí.", "Bueno.", "Nada."], R).

test(elegir_regla, true(Id-P == familia-["Háblame más de tu familia."])) :-
    eliza:elegir_regla([mi, hermano, trabaja], Id, [P|_]).

test(conversar, true(Lineas == ["Hola. Cuéntame qué te preocupa.",
                                "> ¿Por qué estás cansado?",
                                "> Continúa, por favor.",
                                "> Adiós. Gracias por conversar.",
                                ""])) :-
    con_entrada("Estoy cansado\nsí\nadiós\nEstoy bien\n", Salida),
    split_string(Salida, "\n", "", Lineas).

test(fin_de_entrada, true(Lineas == ["Hola. Cuéntame qué te preocupa.",
                                     "> Adiós. Gracias por conversar.",
                                     ""])) :-
    con_entrada("", Salida),
    split_string(Salida, "\n", "", Lineas).

%!  eco(+Frase:string, +N0:integer, -N:integer, -Respuesta:string) is det.
%
%   Respuesta numera Frase con el contador N0; N es el contador siguiente.
eco(Frase, N0, N, Respuesta) :-
    N is N0 + 1,
    format(string(Respuesta), "~w: ~w", [N0, Frase]).

test(estado_inicial, true(E == eliza(t, []))) :-
    estado_inicial(E).

test(elegir_regla_clase, true(Id == maquinas)) :-
    eliza:elegir_regla([creo, que, eres, una, computadora], Id, _).

test(elegir_regla_rango, true(Id == me_dice)) :-
    eliza:elegir_regla([mi, hermano, me, dice, que, estoy, loco], Id, _).

test(elegir_regla_ninguna, true(Id == ninguna)) :-
    eliza:elegir_regla([bueno], Id, _).

test(turno_ciclo, true(Ps == [a, b, a])) :-
    empty_assoc(T0),
    eliza:turno(r, [a, b], T0, T1, P1),
    eliza:turno(r, [a, b], T1, T2, P2),
    eliza:turno(r, [a, b], T2, _, P3),
    Ps = [P1, P2, P3].

test(texto, true(T == "¿Por qué estás cansada?")) :-
    eliza:texto("Estoy cansada", ["¿Por qué estás ", [cansada], "?"], T).

test(recordar, true(R == ["x", "Antes dijiste que tu jefe te grita. \c
                                ¿Tiene algo que ver con esto?"])) :-
    eliza:recordar("Mi jefe me grita", [mi, jefe, me, grita], ["x"], R).

test(no_recordar, true(R == ["x"])) :-
    eliza:recordar("Estoy bien", [estoy, bien], ["x"], R).

test(despedida) :-
    eliza:despedida("Adiós, hasta mañana").

test(despedida_chau) :-
    eliza:despedida("chau").

test(no_despedida, fail) :-
    eliza:despedida("Hola").

test(conversar_otro_responder,
     true(Lineas == ["> 0: uno", "> 1: dos",
                     "> Adiós. Gracias por conversar.", ""])) :-
    setup_call_cleanup(
        open_string("uno\ndos\nchau\n", In),
        with_output_to(string(Salida), conversar(In, eco, 0)),
        close(In)),
    split_string(Salida, "\n", "", Lineas).

:- end_tests(eliza).
