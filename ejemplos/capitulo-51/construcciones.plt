:- encoding(utf8).

:- begin_tests(construcciones).

test(det, [true(T == automata(3, [2], [0-a-1, 0-b-0, 1-a-1, 1-b-2,
                                        2-a-1, 2-b-0]))]) :-
    tabla(det(termina_ab), T).

test(det_inicial, [true(D == [s0, s1])]) :-
    inicial(det(ciclo), D).

% El conjunto vacío es el sumidero.
test(det_sumidero, [true(Ds == [[], [s0, s1], [s2]])]) :-
    estados(det(ciclo), Ds).

test(det_equivalente) :-
    equivalentes(termina_ab, det(termina_ab)).

test(complemento, [true(Ws == [[a, a], [b, a]])]) :-
    palabras(complemento(termina_b), 2, Ws).

test(interseccion, [true(Ws == [[a, b]])]) :-
    palabras(interseccion(termina_ab, termina_b), 2, Ws).

test(union, [true(Ws == [[a, b], [b, b]])]) :-
    palabras(union(termina_ab, termina_b), 2, Ws).

test(incluido) :-
    incluido(termina_ab, termina_b).

test(no_incluido, [fail]) :-
    incluido(termina_b, termina_ab).

test(contraejemplo, [true(W == [b])]) :-
    contraejemplo(termina_ab, termina_b, W).

test(sin_contraejemplo, [fail]) :-
    contraejemplo(ciclo, det(ciclo), _).

test(vacio) :-
    vacio(interseccion(termina_ab, complemento(termina_ab))).

test(mas_corta, [true(W == [a, b])]) :-
    palabra_mas_corta(termina_ab, W).

:- end_tests(construcciones).
