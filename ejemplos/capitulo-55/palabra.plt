:- encoding(utf8).

:- begin_tests(palabra).

test(orden_castellano, all(En == [["the", "cat", "black", "eats"]])) :-
    palabra_por_palabra(["el", "gato", "negro", "come"], En).

test(sin_sujeto, all(En == [["eats", "apples"]])) :-
    palabra_por_palabra(["come", "manzanas"], En).

test(una_manzana, all(En == [["a", "apple"], ["an", "apple"]])) :-
    palabra_por_palabra(["una", "manzana"], En).

test(dieciseis, true(N == 16)) :-
    aggregate_all(count,
                  palabra_por_palabra(_, ["the", "black", "cats"]),
                  N).

test(ninguna_correcta, fail) :-
    palabra_por_palabra(["los", "gatos", "negros"], ["the", "black", "cats"]).

test(desconocida, fail) :-
    palabra_por_palabra(["el", "perro"], _).

:- end_tests(palabra).
