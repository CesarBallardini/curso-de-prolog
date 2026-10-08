:- encoding(utf8).

:- begin_tests(codigos).

test(vocal) :-
    vocal(0'e).

test(consonante, [fail]) :-
    vocal(0'x).

% En codigos, "ab" es una lista de códigos.
test(texto_en_codigos, true(T == [97, 98])) :-
    texto(T).

% Este archivo se lee en user, que conserva el valor string.
test(texto_en_user) :-
    string("ab").

test(bandera_de_user, true(F == string)) :-
    current_prolog_flag(double_quotes, F).

:- end_tests(codigos).
