:- encoding(utf8).

:- begin_tests(soluciones_cadena).

test(par, [true(R == presumiblemente_si)]) :-
    medir(2, R, _).

test(impar, [true(R == presumiblemente_no)]) :-
    medir(3, R, _).

% De 8 a 16 clases, las inferencias se multiplican por más de 16.
test(crece, [true(I16 > 16 * I8)]) :-
    medir(8, _, I8),
    medir(16, _, I16).

% cadena/1 reemplaza la base: la segunda llamada no deja reglas de la
% primera.
test(cadena, [true(N-K == 3-2)]) :-
    cadena(5),
    cadena(2),
    aggregate_all(count, clause(clase(_, _), _), N),
    aggregate_all(count, (tiene(_) :~ _), K).

test(cadena_negativa, [error(type_error(_, _))]) :-
    cadena(-1).

:- end_tests(soluciones_cadena).
