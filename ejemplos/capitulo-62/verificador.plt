:- encoding(utf8).

:- begin_tests(verificador).

test(modus_ponens) :-
    verificar(prueba([[+p], [+q, -p], [-q]],
                     [r(1, 2, [+q]), r(3, 4, [])])).

% El orden de los literales del resolvente no importa.
test(orden) :-
    verificar(prueba([[+p, +q], [-p, +r], [-q], [-r]],
                     [r(1, 2, [+r, +q]), r(3, 5, [+r]), r(4, 6, [])])).

% Un paso cuyos padres no tienen literales opuestos se rechaza.
test(sin_opuestos, [fail]) :-
    verificar(prueba([[+p], [+q, -p], [-q]], [r(1, 3, [])])).

% Un resolvente al que le falta un literal se rechaza.
test(resolvente_falso, [fail]) :-
    verificar(prueba([[+p, +q], [-p], [-q]], [r(1, 2, [])])).

% Una lista de pasos correctos que no llega a la cláusula vacía no es una
% refutación.
test(incompleta, [fail]) :-
    verificar(prueba([[+p], [+q, -p], [-q]], [r(1, 2, [+q])])).

test(indice_fuera, [fail]) :-
    verificar(prueba([[+p], [-p]], [r(1, 7, [])])).

% Con variables: las dos copias no comparten variables, y el resolvente
% se compara salvo el nombre de sus variables.
test(variables) :-
    verificar(prueba([[+hombre(socrates)], [-hombre(X), +mortal(X)],
                      [-mortal(socrates)]],
                     [r(1, 2, [+mortal(socrates)]), r(3, 4, [])])).

test(variables_renombradas) :-
    verificar(prueba([[+p(X, a)], [-p(b, Y), +q(Y)], [-q(Z)]],
                     [r(1, 2, [+q(a)]), r(3, 4, [])])),
    var(X), var(Y), var(Z).

% La unificación tiene la comprobación de ocurrencia: p(X, f(X)) y
% p(g(Y), Y) no unifican.
test(ocurrencia, [fail]) :-
    verificar(prueba([[+p(X, f(X))], [-p(g(Y), Y)]], [r(1, 2, [])])).

% El factor une dos literales del mismo signo.
test(factor) :-
    verificar(prueba([[+p(_), +p(a)], [-p(_)]],
                     [f(1, [+p(a)]), r(2, 3, [])])).

test(factor_falso, [fail]) :-
    verificar(prueba([[+p(a), +p(b)], [-p(a)], [-p(b)]],
                     [f(1, [+p(a)]), r(2, 4, [])])).

:- end_tests(verificador).
