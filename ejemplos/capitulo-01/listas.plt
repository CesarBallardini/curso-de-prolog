:- encoding(utf8).

:- begin_tests(listas).

test(luis_esta_invitado, [nondet]) :-
    esta_invitado(luis).

test(pedro_no_esta_invitado, [fail]) :-
    esta_invitado(pedro).

% Con una variable, member/2 enumera todos los elementos, en orden.
test(todos_los_invitados, all(P == [ana, luis, eva, sofia])) :-
    esta_invitado(P).

test(son_cuatro, all(N == [4])) :-
    cuantos_invitados(N).

test(primero_es_ana, all(P == [ana])) :-
    primero_en_llegar(P).

test(los_demas_son_tres, all(R == [[luis, eva, sofia]])) :-
    los_demas(R).

test(agregar_al_final, all(L == [[ana, luis, eva, sofia, pedro]])) :-
    con_uno_mas(pedro, L).

:- end_tests(listas).
