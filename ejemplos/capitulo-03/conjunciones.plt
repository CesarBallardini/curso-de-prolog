:- encoding(utf8).

:- begin_tests(conjunciones).

% A ana le gustan dos cosas; tiene en común con luis una sola.
test(que_les_gusta_a_los_dos, all(Que == [futbol])) :-
    gusta(ana, Que),
    gusta(luis, Que).

test(hijos_de_juan_a_los_que_les_gusta_prolog, all(Q == [ana])) :-
    padre(juan, Q),
    gusta(Q, prolog).

% El orden de los dos objetivos no cambia la respuesta.
test(el_orden_no_cambia_la_respuesta, all(Que == [futbol])) :-
    gusta(luis, Que),
    gusta(ana, Que).

test(nadie_comparte_gusto_con_sofia, [fail]) :-
    gusta(sofia, Que),
    gusta(ana, Que).

:- end_tests(conjunciones).
