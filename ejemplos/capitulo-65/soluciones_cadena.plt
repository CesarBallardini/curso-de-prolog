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

:- end_tests(soluciones_cadena).
