:- encoding(utf8).

:- begin_tests(capitulo32).

test(simplificar, true(E == 6 * x)) :-
    simplificar((x * 2) * 3, E).

test(apariciones, true(N == 3)) :-
    apariciones(x * x + 1 = 3 * x, x, N).

test(derivar, true(D == 3 * x ^ 2 - 2)) :-
    derivar(x ^ 3 - 2 * x - 5, x, D).

test(evaluar, true(V == -1)) :-
    evaluar(x ^ 3 - 2 * x - 5, [x-2], V).

test(no_derivable, [error(domain_error(expresion_derivable, cos(x)))]) :-
    derivar(cos(x) - x, x, _).

% Las dos versiones de simplificar/2 conviven: la de este módulo no
% agrupa términos semejantes; la que usa derivar/3, sí.
test(dos_versiones, true(E == 2 * x + x)) :-
    simplificar(2 * x + x, E).

:- end_tests(capitulo32).
