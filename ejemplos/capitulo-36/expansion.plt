:- encoding(utf8).

:- begin_tests(expansion).

% Los términos padres/2 se cargaron como hechos padre/2.
test(hechos, true(Ps == [juan-ana, juan-pedro, ana-luis, luis-eva])) :-
    findall(P-H, padre(P, H), Ps).

test(sin_padres, [fail]) :-
    current_predicate(padres/2).

test(padre_de_luis, all(P == [ana])) :-
    padre(P, luis).

% Hechos indexados: con el hijo instanciado no quedan alternativas.
test(indexado) :-
    padre(ana, luis).

test(suma_x, true(S == 6)) :-
    puntos(3, Ps),
    suma_x(Ps, S).

test(iguales, true(S1 == S2)) :-
    puntos(100, Ps),
    suma_llamando(Ps, S1),
    suma_x(Ps, S2).

% La cláusula escrita después de goal_expansion/2 no llama a x_de/2.
test(expandida, true(Cuerpo = (_ = punto(_, _), _, _))) :-
    clause(suma_x([_|_], _), Cuerpo).

test(sin_expandir, true(Cuerpo = (x_de(_, _), _, _))) :-
    clause(suma_llamando([_|_], _), Cuerpo).

test(expand_goal, true(G = (P = punto(X, _)))) :-
    expand_goal(x_de(P, X), G).

% Una inferencia menos por punto.
test(menos_inferencias, true(I1 - I2 =:= 1000)) :-
    puntos(1000, Ps),
    inferencias(suma_llamando(Ps, _), I1),
    inferencias(suma_x(Ps, _), I2).

:- end_tests(expansion).

%!  inferencias(:G, -N:integer) is det.
%
%   N es la cantidad de inferencias de una ejecución de G.
inferencias(G, N) :-
    statistics(inferences, I0),
    once(G),
    statistics(inferences, I1),
    N is I1 - I0.
