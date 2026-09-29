:- encoding(utf8).

:- begin_tests(subsuncion).

test(regla_explica_hecho, [true]) :-
    subsume((abuelo(A, N) :- [padre(A, P), padre(P, N)]),
            (abuelo(juan, luis) :- [padre(juan, pedro), padre(pedro, luis),
                                    varon(juan)])).

test(no_liga, [true(C1 =@= (abuelo(X, _) :- [padre(X, _)]))]) :-
    C1 = (abuelo(A, _) :- [padre(A, _)]),
    subsume(C1, (abuelo(juan, luis) :- [padre(juan, pedro)])).

% Las variables de la segunda cláusula no se sustituyen.
test(segunda_congelada, [fail]) :-
    subsume((p(a) :- []), (p(X) :- [q(X)])).

test(falta_literal, [fail]) :-
    subsume((abuelo(A, N) :- [padre(A, P), madre(P, N)]),
            (abuelo(juan, luis) :- [padre(juan, pedro), padre(pedro, luis)])).

% Una cláusula más larga puede subsumir a una más corta.
test(mas_larga, [true]) :-
    subsume((p(X) :- [q(X, Y), q(Y, X)]), (p(A) :- [q(A, A)])).

% La θ-subsunción es más débil que la consecuencia lógica.
test(lista_par, [fail]) :-
    subsume((lista([_|W]) :- [lista(W)]), (lista([_, _|Z]) :- [lista(Z)])).

test(lgg_pertenece,
     [true(C =@= (p(X, [b, c|Y]) :- [p(X, [c|Y]), p(X, [X])]))]) :-
    lgg_clausula((p(c, [b, c]) :- [p(c, [c])]),
                 (p(d, [b, c, d]) :- [p(d, [c, d]), p(d, [d])]),
                 C).

% La lgg de dos cláusulas subsume a cada una.
test(lgg_subsume, [true]) :-
    C1 = (abuelo(juan, luis) :- [varon(juan), padre(juan, pedro),
                                 padre(pedro, luis)]),
    C2 = (abuelo(pedro, sofia) :- [varon(pedro), padre(pedro, eva),
                                   madre(eva, sofia)]),
    lgg_clausula(C1, C2, C),
    subsume(C, C1),
    subsume(C, C2).

test(lgg_sin_repetidos, [true(B =@= [q(_)])]) :-
    lgg_clausula((p(a) :- [q(a), q(a)]), (p(b) :- [q(b)]), (_ :- B)).

test(mismo_predicado, [true]) :-
    mismo_predicado(padre(a, b), padre(_, _)),
    \+ mismo_predicado(padre(a, b), madre(a, b)),
    \+ mismo_predicado(padre(a, b), padre(a)).

test(como_regla_hecho, [true(R == (p(a) :- true))]) :-
    como_regla((p(a) :- []), R).

test(como_regla, [true(R == (p(a) :- q(a), r(a), s(a)))]) :-
    como_regla((p(a) :- [q(a), r(a), s(a)]), R).

:- end_tests(subsuncion).
