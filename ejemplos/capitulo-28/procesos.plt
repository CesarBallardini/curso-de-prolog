:- encoding(utf8).

:- begin_tests(procesos).

test(salida, true(S-E == "hola"-exit(0))) :-
    salida_de(swipl, ['-g', 'write(hola)', '-t', 'halt'], S, E).

test(codigo_de_salida, true(E == exit(3))) :-
    salida_de(swipl, ['-g', 'halt(3)'], _, E).

test(version, true(Inicio == "SWI-Prolog version")) :-
    version_de_swipl(V),
    sub_string(V, 0, 18, _, Inicio).

test(programa_inexistente,
     error(existence_error(source_sink, path(no_existe_este_programa)))) :-
    salida_de(no_existe_este_programa, [], _, _).

test(sistema, true(memberchk(S, [windows, unix]))) :-
    sistema(S).

:- end_tests(procesos).
