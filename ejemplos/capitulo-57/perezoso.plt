:- encoding(utf8).

:- begin_tests(perezoso).

test(infinita, [true(V == [1, 2, 3, 4, 5])]) :-
    ejecutar_perezoso(nombre, "tomar 5 (desde 1)", "", V).

test(fibs, [true(V == [0, 1, 1, 2, 3, 5, 8, 13])]) :-
    ejecutar_perezoso(nombre, "tomar 8 fibs", "", V).

% El elemento que no se usa no se evalúa.
test(sin_usar, [true(V == 1)]) :-
    ejecutar_perezoso(nombre, "cabeza [1, cabeza []]", "", V).

test(sea_sin_usar, [true(V == 3)]) :-
    ejecutar_perezoso(nombre, "sea x = cabeza [] en 3", "", V).

test(como_estricta, [true(V == [1, 4, 9])]) :-
    ejecutar_perezoso(nombre, "map (fun x -> x * x) [1, 2, 3]", "", V).

% Un punto fijo escrito en el propio lenguaje.
test(punto_fijo, [true(V == 120)]) :-
    ejecutar_perezoso(nombre, "y f 5",
                      "y g = (fun x -> g (x x)) (fun x -> g (x x)); \c
                       f fact n = si n = 0 entonces 1 \c
                       sino n * fact (n - 1)", V).

test(forzar_error, [error(type_error(lista_no_vacia, []))]) :-
    ejecutar_perezoso(nombre, "tomar 2 [1, cabeza []]", "", _).

:- end_tests(perezoso).
