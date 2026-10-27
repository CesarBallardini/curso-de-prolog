:- encoding(utf8).

:- begin_tests(revision).

test(los_nietos_de_juan, all(N == [luis, eva])) :-
    abuelo(juan, N).

% nieto/2 llama a persona/1, que no existe: la llamada produce un error.
test(nieto_llama_a_un_predicado_inexistente,
     [error(existence_error(procedure, persona/1))]) :-
    nieto(luis, _).

:- end_tests(revision).
