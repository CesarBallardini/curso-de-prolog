:- encoding(utf8).

% Esta cláusula se lee en user, después de comillas.pl: también lee códigos.
% leido(T): T es lo que user lee de "ab".
leido("ab").

:- begin_tests(comillas).

test(saludo, true(S == [104, 111, 108, 97])) :-
    saludo(S).

test(despues_en_user, true(T == [97, 98])) :-
    leido(T).

% La unidad de pruebas es otro módulo, plunit_comillas, con su propia
% bandera: allí "ab" es una cadena.
test(en_la_unidad) :-
    string("ab").

test(bandera_de_user, true(F == codes)) :-
    user:current_prolog_flag(double_quotes, F).

:- end_tests(comillas).
