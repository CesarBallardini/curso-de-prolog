:- encoding(utf8).

:- begin_tests(promedios).

test(promedio, true(P =:= 8)) :-
    promedio([7, 9], P).

test(lista_vacia, [fail]) :-
    promedio([], _).

% foldl/4 llega de library(apply) por la directiva, no por la autocarga.
% predicate_property/2 se presenta en el capítulo 33.
test(importado) :-
    predicate_property(promedios:foldl(_, _, _, _), imported_from(apply)).

:- end_tests(promedios).
