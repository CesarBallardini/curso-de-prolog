:- encoding(utf8).

:- begin_tests(recorrer).

test(luis_esta, [nondet]) :-
    esta_en(luis, [ana, luis, eva]).

test(pedro_no_esta, [fail]) :-
    esta_en(pedro, [ana, luis, eva]).

% Con una variable, enumera todos los elementos, en orden.
test(todos_los_elementos, all(X == [ana, luis, eva])) :-
    esta_en(X, [ana, luis, eva]).

test(nada_esta_en_la_lista_vacia, [fail]) :-
    esta_en(_, []).

test(largo_de_tres, all(N == [3])) :-
    largo([ana, luis, eva], N).

test(largo_de_la_vacia, all(N == [0])) :-
    largo([], N).

test(pegar_dos_listas, all(C == [[ana, luis, eva]])) :-
    pegar([ana, luis], [eva], C).

% La misma relación en sentido inverso: todas las particiones de una lista.
test(todas_las_partes, all(A-B == [[]-[ana, luis, eva],
                                   [ana]-[luis, eva],
                                   [ana, luis]-[eva],
                                   [ana, luis, eva]-[]])) :-
    pegar(A, B, [ana, luis, eva]).

test(el_ultimo, all(X == [eva])) :-
    ultimo([ana, luis, eva], X).

test(la_vacia_no_tiene_ultimo, [fail]) :-
    ultimo([], _).

test(todos_estan_sublista, [nondet]) :-
    todos_estan([ana, eva], [ana, luis, eva]).

test(todos_estan_lista_vacia) :-
    todos_estan([], [ana, luis]).

test(todos_estan_falta_uno, [fail]) :-
    todos_estan([ana, sofia], [ana, luis, eva]).

:- end_tests(recorrer).
