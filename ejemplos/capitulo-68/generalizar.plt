:- encoding(utf8).

:- begin_tests(generalizar).

test(parentesco, [true(G =@= abuelo(_, _))]) :-
    lgg(abuelo(juan, luis), abuelo(pedro, sofia), G).

test(mismo_par_misma_variable, [true(G =@= (2 * X = X + X))]) :-
    lgg(2 * 2 = 2 + 2, 2 * 3 = 3 + 3, G).

test(lista, [true(G =@= pertenece(X, [X|_]))]) :-
    lgg(pertenece(1, [1]), pertenece(z, [z, y, x]), G).

test(iguales, [true(G == f(a, [b]))]) :-
    lgg(f(a, [b]), f(a, [b]), G).

test(distinto_functor, [true(var(G))]) :-
    lgg(f(a), g(a), G).

test(distinta_aridad, [true(var(G))]) :-
    lgg(f(a), f(a, b), G).

test(sustitucion_inversa, [true(S =@= [(2-3)-X])]) :-
    lgg(2 * 2 = 2 + 2, 2 * 3 = 3 + 3, _ = _ + X, [], S).

% La lgg generaliza a los dos términos.
test(generaliza, [true]) :-
    T1 = p(f(a, b), a, [a, b]),
    T2 = p(f(c, d), c, [c, e]),
    lgg(T1, T2, G),
    mas_general(G, T1),
    mas_general(G, T2).

% La versión ingenua da una generalización más general que la lgg.
test(ingenua_mas_general, [true]) :-
    lgg_ingenua(f(a, a), f(b, b), G1),
    lgg(f(a, a), f(b, b), G2),
    mas_general(G1, G2),
    \+ mas_general(G2, G1).

% Toda generalización común es más general que la lgg.
test(menos_general, [true]) :-
    lgg(q(a, f(a), b), q(c, f(c), b), G),
    forall(member(H, [q(_, _, _), q(X, f(X), _), q(_, f(_), b),
                      q(Y, f(Y), b)]),
           mas_general(H, G)).

test(mas_general_no_liga, [true]) :-
    mas_general(f(X, Y), f(a, b)),
    var(X),
    var(Y).

test(mas_general_falla, [fail]) :-
    mas_general(f(Z, Z), f(_, _)).

% reemplazado/4 encuentra el par comparando con ==, sin unificar.
test(reemplazado, [true(V == W)]) :-
    generalizar:reemplazado([(a-b)-U, (2-3)-W], 2, 3, V),
    var(U).

test(reemplazado_no_unifica, [fail]) :-
    generalizar:reemplazado([(_-b)-_], a, b, _).

test(reemplazado_vacio, [fail]) :-
    generalizar:reemplazado([], a, b, _).

:- end_tests(generalizar).
