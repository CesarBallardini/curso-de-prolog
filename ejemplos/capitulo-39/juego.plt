:- encoding(utf8).

:- begin_tests(juego).

% El juego j1 no tiene empates: b gana, a y c pierden.
test(j1, [true(Xs == [b])]) :-
    findall(X, gana(j1, X), Xs).

test(j1_valores, [true(Vs == [a-falso, b-verdadero, c-falso])]) :-
    findall(X-V, ( member(X, [a, b, c]), valor(gana(j1, X), V) ), Vs).

% En j2, c gana, d pierde, y a y b son empates: indefinidas.
test(j2_valores, [true(Vs == [a-indefinido, b-indefinido, c-verdadero,
                              d-falso])]) :-
    findall(X-V, ( member(X, [a, b, c, d]), valor(gana(j2, X), V) ), Vs).

% findall/3 recoge también las respuestas indefinidas, sin distinguirlas.
test(j2_todas, [true(Xs == [a, b, c])]) :-
    findall(X, gana(j2, X), Xs0),
    msort(Xs0, Xs).

% La condición de una respuesta indefinida es la respuesta misma, cuyo
% programa residual la hace depender de la negación de la otra posición.
test(condicion, [true(G == gana(j2, a))]) :-
    call_delays(gana(j2, a), C),
    C = _:G.

test(sin_condicion, [true(C == true)]) :-
    call_delays(gana(j2, c), C).

% Sin ciclo en el camino, la negación de Prolog termina.
test(prolog_sin_ciclo, [true]) :-
    gana_prolog(j2, c).

% Con el ciclo de a y b, no: un millón de inferencias no alcanzan.
test(prolog_ciclo, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(gana_prolog(j1, a), 1000000, R).

test(valor_con_variables, [error(instantiation_error)]) :-
    valor(gana(j2, _), _).

% tnot/1 exige un objetivo tabulado; con variables libres, falla si la meta
% tiene alguna respuesta.
test(tnot_sin_tabla,
     [error(permission_error(tnot, non_tabled_procedure, mueve/3))]) :-
    tnot(mueve(j1, a, b)).

test(tnot_con_variables, [fail]) :-
    tnot(gana(j2, _)).

:- end_tests(juego).
