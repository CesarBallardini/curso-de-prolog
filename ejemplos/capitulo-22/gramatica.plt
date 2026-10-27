:- encoding(utf8).

:- begin_tests(gramatica).

% oracion//1 es nondet: después de la respuesta quedan personas por probar.
test(analizar, [nondet, true(H == padre(juan, ana))]) :-
    phrase(oracion(H), [juan, es, el, padre, de, ana]).

test(generar, true(P == [marta, es, la, madre, de, pedro])) :-
    phrase(oracion(madre(marta, pedro)), P).

test(no_es_oracion, [fail]) :-
    phrase(oracion(_), [juan, es, padre, de, ana]).

% La gramática no conoce los hechos: genera también oraciones falsas.
test(todas_las_oraciones, true(N == 32)) :-
    aggregate_all(count, phrase(oracion(_), _), N).

test(saludo) :-
    phrase(saludo, `hola`).

% Una cadena no es una lista de códigos: phrase/2 la rechaza.
test(saludo_con_cadena, [error(type_error(list, "hola"))]) :-
    phrase(saludo, "hola").

test(pushback, true(T-R == numero-`42x`)) :-
    phrase(palabra_o_numero(T), `42x`, R).

test(pushback_palabra, true(T == palabra)) :-
    phrase(palabra_o_numero(T), `x42`, _).

:- end_tests(gramatica).

:- begin_tests(seq).

test(menciona, all(P == [juan, es, el, padre, de, ana])) :-
    menciona(P, [juan, es, el, padre, de, ana]).

test(menciona_ana) :-
    once(menciona(ana, [juan, es, el, padre, de, ana])).

test(partir, [nondet, true(A-D == [juan, es, el, padre]-[ana])]) :-
    phrase(( seq(A), [de], seq(D) ), [juan, es, el, padre, de, ana]).

:- end_tests(seq).
