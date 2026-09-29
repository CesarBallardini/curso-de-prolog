:- encoding(utf8).

:- begin_tests(arbol).

test(hecho, all(A == [prueba(padre(juan, ana), [])])) :-
    resolver(padre(juan, ana), A).

test(antepasado,
     all(A == [prueba(antepasado(juan, luis),
                      [ prueba(padre(juan, ana), []),
                        prueba(antepasado(ana, luis),
                               [prueba(padre(ana, luis), [])]) ])])) :-
    resolver(antepasado(juan, luis), A).

test(predefinido, true(A == prueba(mayor_que(juan, pedro),
                                   [ prueba(edad(juan, 68), []),
                                     prueba(edad(pedro, 37), []),
                                     sis(68 > 37) ]))) :-
    resolver(mayor_que(juan, pedro), A).

% Las respuestas son las de Prolog: el árbol no cambia qué se prueba.
test(como_prolog, true(Rs == Ps)) :-
    findall(A-D, resolver(antepasado(A, D), _), Rs),
    findall(A-D, antepasado(A, D), Ps).

% Una respuesta por prueba: los árboles distintos son pruebas distintas.
test(una_por_prueba, true(N == 2)) :-
    aggregate_all(count, resolver(mayor_que(juan, _), _), N).

test(sin_prueba, [fail]) :-
    resolver(antepasado(eva, _), _).

test(mostrar, true(S == "antepasado(juan, luis)\n  padre(juan, ana)\n  \c
                         antepasado(ana, luis)\n    padre(ana, luis)\n")) :-
    resolver(antepasado(juan, luis), A),
    !,
    with_output_to(string(S), mostrar(A)).

test(como, all(S == ["mayor_que(juan, pedro)\n  edad(juan, 68)\n  \c
                     edad(pedro, 37)\n  68>37\n"])) :-
    with_output_to(string(S), como(mayor_que(juan, pedro))).

:- end_tests(arbol).
