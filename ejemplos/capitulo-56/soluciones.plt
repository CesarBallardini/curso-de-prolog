:- encoding(utf8).

:- begin_tests(soluciones).

%!  respuestas(+Frases:list(string), -Respuestas:list(string)) is det.
%
%   Respuestas son las respuestas de ELIZA a Frases, desde el estado
%   inicial.
respuestas(Frases, Respuestas) :-
    eliza:estado_inicial(E0),
    foldl(paso, Frases, Respuestas, E0, _).

%!  paso(+Frase, -Respuesta, +E0, -E) is det.
%
%   responder/4 con el estado en los dos últimos argumentos.
paso(Frase, Respuesta, E0, E) :-
    eliza:responder(Frase, E0, E, Respuesta).

test(no_puedo, true(R == ["¿Qué te impide dormir por tu trabajo?"])) :-
    respuestas(["No puedo dormir por mi trabajo"], R).

test(siempre, true(R == ["¿Puedes pensar en un ejemplo concreto?"])) :-
    respuestas(["Siempre estoy cansado"], R).

test(preposicion, true(Q == [para, "ti", es, dificil])) :-
    reflejar_prep([para, mi, es, dificil], Q).

test(preposicion_ti, true(Q == [lo, haces, por, "mí"])) :-
    reflejar_prep([lo, hago, por, ti], Q).

test(posesivo, true(Q == [de, "tu", madre])) :-
    reflejar_prep([de, mi, madre], Q).

test(sin_cambio_de_regla, true(Q == ["yo", no, "te", entiendo])) :-
    reflejar_prep([tu, no, me, entiendes], Q).

test(infinitivo, [nondet, true(S == caminas)]) :-
    conjugada_inf(camino, S).

test(infinitivo_er, [nondet, true(S == comes)]) :-
    conjugada_inf(como, S).

test(infinitivo_inversa, [nondet, true(P == escribo)]) :-
    conjugada_inf(P, escribes).

test(primera_respuesta, true(R == "¿Puedes pensar en un ejemplo concreto?")) :-
    primera_respuesta("Siempre estoy cansado", R).

test(primera_respuesta_ninguna, true(R == "Continúa, por favor.")) :-
    primera_respuesta("Bueno", R).

:- end_tests(soluciones).
