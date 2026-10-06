:- encoding(utf8).

:- begin_tests(concatenar).

test(genera, all(P == ["habló"])) :-
    forma(P, verbo("hablar", preterito, 3, singular)).

test(analiza, [true(As == [verbo("comer", presente, 1, plural)])]) :-
    findall(A, forma("comemos", A), As).

test(adjetivo, all(P == ["rojas"])) :-
    forma(P, adjetivo("rojo", femenino, plural)).

% verde es masculino y femenino: dos análisis.
test(verdes, [true(N == 2)]) :-
    findall(A, forma("verdes", A), As),
    length(As, N).

% Las limitaciones: ninguna letra cambia al unir las partes.
test(tocar, all(P == ["tocé"])) :-
    forma(P, verbo("tocar", preterito, 1, singular)).

test(lapiz, all(P == ["lápizes"])) :-
    forma(P, nombre("lápiz", masculino, plural)).

test(camion, all(P == ["camiónes"])) :-
    forma(P, nombre("camión", masculino, plural)).

test(contar, all(P == ["conto"])) :-
    forma(P, verbo("contar", presente, 1, singular)).

test(toque, [fail]) :-
    forma("toqué", _).

% partes/3 en sus dos sentidos: de las partes al análisis y al revés.
test(partes_analiza, all(A == [verbo("hablar", preterito, 3, singular)])) :-
    partes(A, "habl", "ó").

test(partes_plural_vocal, all(R-T == ["libro"-"s"])) :-
    partes(nombre("libro", masculino, plural), R, T).

test(partes_plural_consonante, all(R-T == ["luz"-"es"])) :-
    partes(nombre("luz", femenino, plural), R, T).

test(partes_femenino, all(R-T == ["roj"-"a"])) :-
    partes(adjetivo("rojo", femenino, singular), R, T).

test(partes_invariable, all(G == [masculino, femenino])) :-
    partes(adjetivo("verde", G, plural), "verde", "s").

test(partes_raiz_desconocida, [fail]) :-
    partes(_, "xyz", "o").

:- end_tests(concatenar).
