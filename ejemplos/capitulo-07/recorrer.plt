:- encoding(utf8).

:- begin_tests(recorrer).

test(luis_esta, [nondet]) :-
    pertenece(luis, [ana, luis, eva]).

test(pedro_no_esta, [fail]) :-
    pertenece(pedro, [ana, luis, eva]).

% Con una variable, enumera todos los elementos, en orden.
test(todos_los_elementos, all(X == [ana, luis, eva])) :-
    pertenece(X, [ana, luis, eva]).

test(nada_pertenece_a_la_lista_vacia, [fail]) :-
    pertenece(_, []).

test(longitud_de_tres, all(N == [3])) :-
    longitud([ana, luis, eva], N).

test(longitud_de_la_vacia, all(N == [0])) :-
    longitud([], N).

test(concatenar_dos_listas, all(C == [[ana, luis, eva]])) :-
    concatenar([ana, luis], [eva], C).

% La misma relación en sentido inverso: todas las particiones de una lista.
test(todas_las_partes, all(A-B == [[]-[ana, luis, eva],
                                   [ana]-[luis, eva],
                                   [ana, luis]-[eva],
                                   [ana, luis, eva]-[]])) :-
    concatenar(A, B, [ana, luis, eva]).

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
