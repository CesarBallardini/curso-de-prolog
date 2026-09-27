:- encoding(utf8).

:- begin_tests(buscaminas).

test(minas_alrededor_de_2_2, true(N == 2)) :-
    minas_alrededor(2, 2, N).

% Una celda con minas vecinas se descubre sola.
test(una_celda_con_numero, true(D == [1-2])) :-
    descubrir(1-2, [], D).

% Desde (1, 6), sin minas vecinas, se descubre toda la región.
test(region_de_la_esquina,
     true(S == [1-2, 1-3, 1-4, 1-5, 1-6, 2-2, 2-3, 2-4, 2-5, 2-6,
                3-3, 3-4, 3-5, 3-6])) :-
    descubrir(1-6, [], D),
    msort(D, S).

% Cada celda se descubre una vez: la lista no tiene repetidos.
test(sin_repetidos, true(N == 14)) :-
    descubrir(1-6, [], D),
    sort(D, S),
    length(S, N).

% Una celda ya descubierta no cambia nada.
test(celda_ya_vista, true(D == [1-6])) :-
    descubrir(1-6, [1-6], D).

% (6, 1) y (5, 1) no tienen minas vecinas: se descubre también la fila 4.
test(region_de_abajo, true(S == [4-1, 4-2, 5-1, 5-2, 6-1, 6-2])) :-
    descubrir(6-1, [], D),
    msort(D, S).

test(mostrar, true(S == "#10000\n#21000\n##1111\n######\n######\n######\n")) :-
    descubrir(1-6, [], D),
    with_output_to(string(S), mostrar(D)).

:- end_tests(buscaminas).
