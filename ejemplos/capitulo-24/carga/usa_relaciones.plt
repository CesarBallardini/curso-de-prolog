:- encoding(utf8).

:- begin_tests(usa_relaciones).

test(ana, true(Ms == [am1, alg, log, am2])) :-
    aprobadas_de(101, Ms).

test(gabriela, true(Ms == [])) :-
    aprobadas_de(107, Ms).

% user importa usa_relaciones, no relaciones: el operador no llega, y el
% texto no se puede leer como término.
test(sin_operador, [error(syntax_error(_), _)]) :-
    term_to_atom(_, '101 aprobo am1').

:- end_tests(usa_relaciones).
