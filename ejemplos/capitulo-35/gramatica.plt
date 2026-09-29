:- encoding(utf8).

:- begin_tests(gramatica).

test(terminal_y_no_terminal,
     true(C =@= (saludo(S0, S) :- S0 = [hola|S1], nombre(S1, S)))) :-
    traducir((saludo --> [hola], nombre), C).

test(llaves,
     true(C =@= (digito(D, S0, S) :-
                     S0 = [D|S1], (code_type(D, digit), S = S1)))) :-
    traducir((digito(D) --> [D], { code_type(D, digit) }), C).

% La traducción de traducir/2 es la del sistema, con otras variables.
test(como_el_sistema, forall(regla(R))) :-
    traducir(R, C1),
    dcg_translate_rule(R, C2),
    assertion(C1 =@= C2).

test(a_b, [nondet]) :-
    aes_bes(3, L),
    phrase(a_b, L).

test(a_b_falla, [fail]) :-
    phrase(a_b, [a, b, a]).

test(a_b_append) :-
    aes_bes(3, L),
    a_b_append(L).

test(a_b_append_falla, [fail]) :-
    a_b_append([a, b, a]).

% Las reglas del archivo se cargaron con la traducción de traducir/2.
test(cargada, true(Cuerpo = (aes(_, _), bes(_, _)))) :-
    clause(a_b(_, _), Cuerpo).

% append/3 prueba cada partición: las inferencias crecen con el cuadrado.
test(cuadratica, true(I2 > 3 * I1)) :-
    aes_bes(200, L1),
    aes_bes(400, L2),
    inferencias(a_b_append(L1), I1),
    inferencias(a_b_append(L2), I2).

test(lineal, true(I2 < 3 * I1)) :-
    aes_bes(200, L1),
    aes_bes(400, L2),
    inferencias(phrase(a_b, L1), I1),
    inferencias(phrase(a_b, L2), I2).

test(aes_bes, true(L == [a, a, b, b])) :-
    aes_bes(2, L).

test(solo, [nondet]) :-
    solo(a, [a, a, a]).

test(solo_otro, [fail]) :-
    solo(a, [a, b]).

test(no_terminal, true(M == f(x, S0, S))) :-
    no_terminal(f(x), S0, S, M).

:- end_tests(gramatica).

% regla(R): una regla de gramática con cada construcción del cuerpo.
regla((a --> [x], b)).
regla((a --> [])).
regla((a --> {p}, [x])).
regla((a --> [x], !, b)).
regla((a --> (b ; [y]))).
regla((a --> \+ b, c)).
regla((a(X) --> X)).
regla((a --> [x, y])).
regla((a --> b, [x])).
regla((a --> call(g, 1))).
regla((a --> ([x] ; [y]), c)).
regla((a --> [x], {p}, b)).

%!  inferencias(:G, -N:integer) is det.
%
%   N es la cantidad de inferencias de una ejecución de G.
inferencias(G, N) :-
    statistics(inferences, I0),
    once(G),
    statistics(inferences, I1),
    N is I1 - I0.
