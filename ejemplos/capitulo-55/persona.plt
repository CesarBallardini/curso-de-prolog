:- encoding(utf8).

:- begin_tests(persona).

test(regular, [nondet, true(S == quieres)]) :-
    conjugada(quiero, S).

test(inversa, [nondet, true(P == entiendo)]) :-
    conjugada(P, entiendes).

test(irregular, [nondet, true(S == eres)]) :-
    conjugada(soy, S).

test(no_es_verbo, fail) :-
    conjugada(mesa, _).

test(palabra_a_palabra, true(Q == [tienes, miedo, de, "tu", trabajas])) :-
    palabra_a_palabra([tengo, miedo, de, mi, trabajo], Q).

test(sustantivo, true(Q == [tienes, miedo, de, "tu", trabajo])) :-
    reflejar([tengo, miedo, de, mi, trabajo], Q).

test(pronombre_tu, true(Q == ["yo", soy, "tú"])) :-
    reflejar([tu, eres, yo], Q).

test(tu_no, true(Q == ["yo", no, "te", entiendo])) :-
    reflejar([tu, no, me, entiendes], Q).

test(una_pasada, true(Q == ["te", digo, que, "yo", soy, "tu", amigo])) :-
    reflejar([me, dices, que, tu, eres, mi, amigo], Q).

test(escritura, true(E == ["tú", "estás", "cansadísimo"])) :-
    escritura("¡Estoy CANSADÍSIMO!", ["tú", "estás", cansadisimo], E).

test(responder, true(R == "¿Por qué crees que tu jefe no te entiende?")) :-
    responder("Creo que mi jefe no me entiende.", R).

test(me_dice, true(R == "¿Qué piensas de que tu madre te diga que yo no \c
                         te entiendo?")) :-
    responder("Mi madre me dice que tú no me entiendes", R).

test(tildes, true(R == "¿Qué te hace pensar que soy una máquina?")) :-
    responder("Eres una máquina", R).

test(palabra_pronombre, true(Q == "te")) :-
    persona:palabra(me, Q).

test(palabra_verbo_primera, true(Q == "estás")) :-
    persona:palabra(estoy, Q).

test(palabra_verbo_segunda, true(Q == quiero)) :-
    persona:palabra(quieres, Q).

test(palabra_sin_cambio, true(Q == mesa)) :-
    persona:palabra(mesa, Q).

test(tras_tu_pronombre, nondet) :-
    persona:tras_tu(me).

test(tras_tu_verbo) :-
    persona:tras_tu(entiendes).

test(tras_tu_sustantivo, fail) :-
    persona:tras_tu(mesa).

test(persona_determinante, all(Q == [["tu", trabajo, "te", cansa]])) :-
    phrase(persona(Q), [mi, trabajo, me, cansa]).

test(persona_vacia, all(Q == [[]])) :-
    phrase(persona(Q), []).

:- end_tests(persona).
