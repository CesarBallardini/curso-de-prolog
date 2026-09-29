:- encoding(utf8).

% Pruebas de la copia de puente.pl que analiza el capítulo 59: la
% versión anterior a un cambio del capítulo 31 (ver LEEME.txt). Verifican
% que la copia se carga; las pruebas del programa están en
% ejemplos/capitulo-31/inscripciones/.

:- begin_tests(caso_puente).

test(copia, [nondet]) :-
    source_file(Archivo),
    sub_atom(Archivo, _, _, 0, 'capitulo-59/caso/puente.pl').

:- end_tests(caso_puente).
