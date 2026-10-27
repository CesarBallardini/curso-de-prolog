:- encoding(utf8).

:- begin_tests(sld).

test(programa_inexistente, [error(existence_error(programa, otro))]) :-
    clausulas(otro, _).

% Un paso con la regla de la izquierda: solo R4 se puede usar.
test(paso_abuelo, [true(Rs = [[padre(juan, P), padre(P, _)]])]) :-
    findall(R, paso(izquierda, familia, [abuelo(juan, _)], R), Rs).

% La regla de la derecha elige el último átomo: tres cláusulas lo resuelven.
test(paso_derecha, [true(Rs =@= [[padre(_, juan)], [padre(_, juan)],
                                 [padre(_, pedro)]])]) :-
    findall(R, paso(derecha, familia, [padre(_, X), padre(X, _)], R), Rs).

test(sin_paso, [fail]) :-
    paso(izquierda, familia, [padre(luis, _)], _).

test(arbol_izquierda, [true(A == arbol([[abuelo(juan, luis)]], 5, 1, 0))]) :-
    arbol_sld(izquierda, familia, [abuelo(juan, _)], 5, A).

test(arbol_derecha, [true(A == arbol([[abuelo(juan, luis)]], 6, 2, 0))]) :-
    arbol_sld(derecha, familia, [abuelo(juan, _)], 5, A).

% Recursión a la izquierda: con la regla de la izquierda el árbol es
% infinito y siempre hay ramas cortadas; con la de la derecha es finito.
test(conexion_izquierda, [true(R-C == [[conexion(a, b)], [conexion(a, c)],
                                       [conexion(a, d)]]-5)]) :-
    arbol_sld(izquierda, enlaces, [conexion(a, _)], 8, arbol(R, _, _, C)).

test(conexion_derecha, [true(A == B)]) :-
    arbol_sld(derecha, enlaces, [conexion(a, _)], 8, A),
    arbol_sld(derecha, enlaces, [conexion(a, _)], 30, B),
    A = arbol([[conexion(a, b)], [conexion(a, c)], [conexion(a, d)]],
              24, 7, 0).

test(sldnf_vuela, [true(Xs == [piolin])]) :-
    findall(X, sldnf(aves, [vuela(X)]), Xs).

% La regla segura elige ave(X) antes que la negación con X libre.
test(sldnf_vuela_mal, [true(Xs == [piolin])]) :-
    findall(X, sldnf(aves, [vuela_mal(X)]), Xs).

% Prolog elige siempre el primer literal: vuela_mal/1 no da ninguna.
test(prolog_vuela_mal, [true(Xs == [])]) :-
    findall(X, vuela_mal(X), Xs).

test(sldnf_atascada, [error(instantiation_error)]) :-
    sldnf(aves, [\+ pinguino(_)]).

test(sldnf_negacion_cerrada, [nondet]) :-
    sldnf(aves, [\+ pinguino(piolin)]).

test(complecion_vuela, [true(F =@= sii(vuela(X), (ave(X), \+ pinguino(X))))]) :-
    complecion(aves, vuela/1, F).

test(complecion_hechos, [true(F =@= sii(ave(X), (X = piolin ; X = pingu)))]) :-
    complecion(aves, ave/1, F).

test(complecion_existe,
     [true(F =@= sii(abuelo(A, N), existe([P], (padre(A, P), padre(P, N)))))]) :-
    complecion(familia, abuelo/2, F).

% Las versiones _de reciben la lista de cláusulas.
test(paso_de_lista, [true(Rs == [[q], []])]) :-
    findall(R, paso_de(izquierda, [(p :- q), (p :- true)], [p], R), Rs).

test(arbol_de_lista, [true(A == arbol([[p]], 3, 1, 0))]) :-
    arbol_sld_de(izquierda, [(p :- q), (p :- true)], [p], 5, A).

test(sldnf_de_lista, [nondet]) :-
    sldnf_de([(p :- \+ q), (q :- r)], [p]).

test(programa_generado_inexistente,
     [error(existence_error(programa, juego(j2)))]) :-
    sldnf(juego(j2), [gana(j2, c)]).

test(complecion_vacia, [true(F == sii(otro, falso))]) :-
    complecion_de([], otro/0, F).

% Una variable repetida en la cabeza da una igualdad entre argumentos.
test(complecion_repetida,
     [true(F =@= sii(p(X, Y, Z), (Y = X, Z = a, q(X))))]) :-
    complecion_de([(p(V, V, a) :- q(V))], p/3, F).

% seleccionar/5 elige el primer átomo o el último; falla con la consulta
% vacía.
test(seleccionar_izquierda, [true(A-D == a-[b, c])]) :-
    seleccionar(izquierda, [a, b, c], [], A, D).

test(seleccionar_derecha, [true(Antes-A == [a, b]-c)]) :-
    seleccionar(derecha, [a, b, c], Antes, A, []).

test(seleccionar_vacia, [fail]) :-
    seleccionar(derecha, [], _, _, _).

% seguro/1: un átomo, o una negación sin variables.
test(seguro) :-
    assertion(seguro(ave(_))),
    assertion(seguro(\+ pinguino(piolin))),
    assertion(\+ seguro(\+ pinguino(_))).

% Una cláusula cuya cabeza tiene una constante aporta una igualdad.
test(alternativa_igualdad, [true(Al == (X = a))]) :-
    alternativa(p(X), p(a), true, Al).

% Los programas del capítulo, ejecutados por Prolog.
test(abuelo_prolog, [all(A-N == [juan-luis])]) :-
    abuelo(A, N).

test(vuela_prolog, [all(X == [piolin])]) :-
    vuela(X).

% conexion/2 da sus tres respuestas y no termina: se toman las tres.
test(conexion_prolog, [true(Xs == [b, c, d])]) :-
    findall(X, limit(3, conexion(a, X)), Xs).

:- end_tests(sld).
