:- encoding(utf8).

:- begin_tests(explicar).

test(tweety, [nondet, true(A == regla((vuela(tweety) :~ ave(tweety)),
                              [estricta(ave(tweety))]))]) :-
    derivacion([especificidad], vuela(tweety), A).

test(opus_estricta, [nondet, true(A == estricta(ave(opus)))]) :-
    derivacion([especificidad], ave(opus), A).

% derivacion/3 prueba lo mismo que derivable/2.
test(como_derivable, [true(Xs == Ys)]) :-
    findall(X, derivable([especificidad], vuela(X)), Xs0),
    findall(X, derivacion([especificidad], vuela(X), _), Ys0),
    sort(Xs0, Xs),
    sort(Ys0, Ys).

test(supuestos, [nondet, true(S == [(bien(auto1, bateria) :~ true),
                            (bien(auto1, arranque) :~ true),
                            (bien(auto1, combustible) :~ true)])]) :-
    derivacion([especificidad], arranca(auto1), A),
    supuestos(A, S).

test(sin_supuestos, [true(S == [])]) :-
    supuestos(estricta(ave(opus)), S).

test(por_que_no_opus, [true(M == [derrotada(R, [Rival])])]) :-
    R = (vuela(opus) :~ ave(opus)),
    Rival = (neg vuela(opus) :~ pinguino(opus)),
    por_que_no([especificidad], vuela(opus), M).

test(por_que_no_coco, [true(M == [derrotada(R, [Rival])])]) :-
    R = (vuela(coco) :~ ave(coco)),
    Rival = (neg vuela(coco) :^ ave(coco), enferma(coco)),
    por_que_no([especificidad], vuela(coco), M).

test(por_que_no_auto, [true(Rs == [estricto(neg arranca(auto2))])]) :-
    por_que_no([especificidad], arranca(auto2), [derrotada(_, Rs)]).

test(sin_reglas, [true(M == [])]) :-
    por_que_no([especificidad], vuela(nadie), M).

test(meta_libre, [error(instantiation_error)]) :-
    por_que_no([especificidad], vuela(_), _).

% arbol/3 y arboles/3 no se exportan: se llaman con el módulo.
test(arbol_estricta, [nondet, true(A == estricta(ave(opus)))]) :-
    explicaciones:arbol([especificidad], ave(opus), A).

test(arbol_derrotada, [fail]) :-
    explicaciones:arbol([especificidad], vuela(opus), _).

test(arboles, [nondet, true(As == [estricta(ave(opus)),
                                   predefinido(1 < 2)])]) :-
    explicaciones:arboles([especificidad], (ave(opus), 1 < 2), As).

test(arboles_true, [true(As == [])]) :-
    explicaciones:arboles([], true, As).

% rebatibles//1 recoge las reglas rebatibles de la raíz a las hojas, con
% repetidos; supuestos/2 los quita.
test(rebatibles, [true(L == [(p :~ q), (q :~ true), (q :~ true)])]) :-
    A = regla((p :~ q), [regla((q :~ true), []), regla((q :~ true), [])]),
    phrase(explicaciones:rebatibles(A), L).

test(lista_rebatibles, [true(L == [])]) :-
    phrase(explicaciones:lista_rebatibles([estricta(a), predefinido(b)]),
           L).

:- end_tests(explicar).
