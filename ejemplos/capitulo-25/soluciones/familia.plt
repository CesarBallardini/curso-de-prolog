:- encoding(utf8).

:- begin_tests(familia).

test(abuelo, all(N == [luis, eva])) :-
    abuelo(juan, N).

% padre/2 no se exporta: sin calificar, no existe fuera del módulo.
test(privado, [error(existence_error(procedure, _), _)]) :-
    padre(_, _).

test(calificado, all(H == [ana, pedro])) :-
    familia:padre(juan, H).

:- end_tests(familia).
