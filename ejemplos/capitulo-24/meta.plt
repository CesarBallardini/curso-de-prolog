:- encoding(utf8).

:- begin_tests(meta).

% Con predicados predefinidos, las dos versiones funcionan.
test(predefinido) :-
    cada_uno_sin_declarar(integer, [1, 2]),
    cada_uno_meta(integer, [1, 2]).

test(declaracion, true(M == cada_uno_meta(1, ?))) :-
    predicate_property(meta:cada_uno_meta(_, _), meta_predicate(M)).

:- end_tests(meta).
