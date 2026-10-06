:- encoding(utf8).

:- begin_tests(propio).

% var/1, que reconoce una variable libre, se presenta en el capítulo 32.
% alternativas(G, R): R es pendientes si G termina con alternativas
% pendientes, o ninguna. El objetivo de limpieza de call_cleanup/2 se ejecuta
% cuando G ya no tiene alternativas.
alternativas(G, R) :-
    call_cleanup(G, Termino = true),
    (   var(Termino)
    ->  R = pendientes
    ;   R = ninguna
    ),
    !.

% La primera versión deja una alternativa pendiente; la segunda, no.
test(primera_version, true(R == pendientes)) :-
    alternativas(cada_uno_1(mayor_de_edad, [juan, ana]), R).

test(segunda_version, true(R == ninguna)) :-
    alternativas(cada_uno(mayor_de_edad, [juan, ana]), R).

test(cada_uno_mayor) :-
    cada_uno(mayor_de_edad, [juan, ana]).

test(cada_uno_con_un_menor, [fail]) :-
    cada_uno(mayor_de_edad, [juan, eva]).

test(cada_uno_de_ninguno) :-
    cada_uno(mayor_de_edad, []).

% Sin nondet: con la lista primero, la indexación elige la cláusula y no
% quedan alternativas pendientes.
test(relacionar, true(E == [68, 8])) :-
    relacionar(edad, [juan, eva], E).

test(relacionar_en_sentido_inverso, true(P == [ana, eva])) :-
    relacionar(edad, P, [41, 8]).

test(cuantos_cumplen, true(N == 2)) :-
    cuantos_cumplen(menor_de_edad, [juan, luis, eva], N).

test(cuantos_cumplen_ninguno, true(N == 0)) :-
    cuantos_cumplen(menor_de_edad, [], N).

% predicate_property/2, que consulta las propiedades,
% se presenta en el capítulo 33.
test(declaracion, true(M == cada_uno(1, ?))) :-
    predicate_property(cada_uno(_, _), meta_predicate(M)).

:- end_tests(propio).
