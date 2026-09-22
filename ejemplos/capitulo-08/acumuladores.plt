:- encoding(utf8).

:- begin_tests(acumuladores).

test(suma_sin_acumulador, all(S == [8])) :-
    suma_lista([3, 1, 4], S).

test(suma_con_acumulador, all(S == [8])) :-
    suma_con_acumulador([3, 1, 4], S).

% Las dos versiones producen el mismo resultado, también con la lista vacía.
test(la_lista_vacia_suma_cero, all(S == [0])) :-
    suma_con_acumulador([], S).

test(largo_de_tres, all(N == [3])) :-
    largo([ana, luis, eva], N).

test(largo_de_la_vacia, all(N == [0])) :-
    largo([], N).

test(dar_vuelta, all(R == [[eva, luis, ana]])) :-
    dar_vuelta([ana, luis, eva], R).

test(dar_vuelta_uno_solo, all(R == [[ana]])) :-
    dar_vuelta([ana], R).

test(dar_vuelta_la_vacia, all(R == [[]])) :-
    dar_vuelta([], R).

:- end_tests(acumuladores).
