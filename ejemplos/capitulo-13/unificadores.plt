:- encoding(utf8).

:- begin_tests(unificadores).

test(una_constante_por_una_variable, Z == jorge) :-
    padre(Z, diego) = padre(jorge, diego).

% Dos variables distintas quedan ligadas entre sí: son la misma variable.
test(dos_variables, X == W) :-
    tio(X, diego) = tio(W, diego).

test(terminos_anidados, [X, Y, Z, W] == [3, 4, 4, 3]) :-
    p(q(X, Y), X, h(4)) = p(q(3, Z), W, h(Z)).

test(cabeza_y_resto, X-Y == [a, b]-[c, d]) :-
    r([X|Y]) = r([[a, b], c, d]).

test(la_lista_vacia_no_tiene_cabeza, [fail]) :-
    r([_|_]) = r([]).

test(dos_listas, [A, B, C] == [[X, 2], [Y], []]) :-
    [[X, 2], [Y]] = [A|[B|C]].

% Una sustitución no se muestra: se muestra su efecto sobre los términos.
test(el_efecto_de_una_sustitucion, T == abuelo(juan, Quien)) :-
    T = abuelo(A, N),
    A = juan,
    N = Quien.

:- end_tests(unificadores).
