:- encoding(utf8).

:- begin_tests(plegados).

test(maximo, true(V == 9)) :-
    lam_plegados("maximo [3, 1, 4, 1, 5, 9, 2, 6]", V).

% Pliega desde la derecha: 10 - (4 - 1).
test(desde_la_derecha, true(V == 7)) :-
    lam_plegados("plegar1_der (-) [10, 4, 1]", V).

% Con un solo elemento, el resultado es ese elemento: f no se aplica.
test(un_elemento, true(V == 7)) :-
    lam_plegados("plegar1_der (fun x a -> cabeza []) [7]", V).

test(lista_vacia, error(type_error(lista_no_vacia, []))) :-
    lam_plegados("plegar1_der (+) []", _).

test(producto_interno, true(V == 32)) :-
    lam_plegados("producto_interno [1, 2, 3] [4, 5, 6]", V).

test(plegar2_der, true(V == [11, 22])) :-
    lam_plegados("plegar2_der (fun x y a -> cons (x + y) a) [] [1, 2] \c
                  [10, 20]", V).

test(plegados, true(N == 5)) :-
    plegados(D),
    leer_programa(D, P),
    length(P, N).

:- end_tests(plegados).
