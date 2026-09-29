:- encoding(utf8).

:- begin_tests(vainilla).

test(abuelo, all(N == [luis])) :-
    resolver(abuelo(juan, N)).

% El intérprete da las mismas respuestas que Prolog, en el mismo orden.
test(antepasado_como_prolog, true(Rs == Ps)) :-
    findall(A-D, resolver(antepasado(A, D)), Rs),
    findall(A-D, antepasado(A, D), Ps).

test(antepasado_de_eva, all(A == [luis, juan, ana])) :-
    resolver(antepasado(A, eva)).

test(sin_prueba, [fail]) :-
    resolver(abuelo(eva, _)).

% Una comparación llega a clause/2, que no da acceso a los predefinidos.
test(predefinido_error,
     [error(permission_error(access, private_procedure, (>)/2))]) :-
    resolver(mayor_que(juan, ana)).

:- end_tests(vainilla).
