:- encoding(utf8).

:- begin_tests(macros).

test(dobles, true(Ys == [2, 4, 6])) :-
    dobles([1, 2, 3], Ys).

test(dobles_lambda, true(Ys == [2, 4, 6])) :-
    dobles_lambda([1, 2, 3], Ys).

test(dobles_en_ejecucion, true(Ys == [2, 4, 6])) :-
    dobles_en_ejecucion([1, 2, 3], Ys).

test(todos) :-
    todos([3, 4, 5], 2).

test(todos_falla, [fail]) :-
    todos([3, 1, 5], 2).

% El cuerpo cargado ya no llama a maplist/3.
test(expandido, true(Nombre \== maplist)) :-
    clause(dobles(_, _), Cuerpo),
    functor(Cuerpo, Nombre, _).

test(forall_expandido, true(Cuerpo = (\+ _))) :-
    clause(todos(_, _), Cuerpo).

test(sin_expandir, true(Cuerpo = (_ = maplist(_, _, _), call(_)))) :-
    clause(dobles_en_ejecucion(_, _), Cuerpo).

% La lambda expandida no se copia en cada elemento.
test(lambda_expandida, true(I2 > 3 * I1)) :-
    numlist(1, 1000, Xs),
    inferencias(dobles_lambda(Xs, _), I1),
    inferencias(dobles_en_ejecucion(Xs, _), I2).

:- end_tests(macros).

%!  inferencias(:G, -N:integer) is det.
%
%   N es la cantidad de inferencias de una ejecución de G.
inferencias(G, N) :-
    statistics(inferences, I0),
    once(G),
    statistics(inferences, I1),
    N is I1 - I0.
