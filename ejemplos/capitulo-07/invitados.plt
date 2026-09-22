:- encoding(utf8).

:- begin_tests(invitados).

test(todos, all(P == [ana, luis, eva, sofia])) :-
    esta_invitado(P).

test(son_cuatro, all(N == [4])) :-
    cuantos(N).

test(la_segunda_es_luis, all(P == [luis])) :-
    en_el_puesto(2, P).

% nth1/3 también determina la posición de un elemento.
test(en_que_puesto_esta_eva, all(N == [3])) :-
    en_el_puesto(N, eva).

test(la_ultima_es_sofia, all(P == [sofia])) :-
    ultimo_en_llegar(P).

test(al_reves, all(L == [[sofia, eva, luis, ana]])) :-
    orden_de_salida(L).

test(uno_mas_al_final, all(L == [[ana, luis, eva, sofia, pedro]])) :-
    con_uno_mas(pedro, L).

:- end_tests(invitados).
