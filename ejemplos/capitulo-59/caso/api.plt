:- encoding(utf8).

% Pruebas de la copia de api.pl que analiza el capítulo 59: la
% versión anterior a un cambio del capítulo 31 (ver LEEME.txt). Verifican
% que la copia se carga; las pruebas del programa están en
% ejemplos/capitulo-31/inscripciones/.

:- begin_tests(caso_api).

test(copia, [nondet]) :-
    source_file(Archivo),
    sub_atom(Archivo, _, _, 0, 'capitulo-59/caso/api.pl').

% Lo que el capítulo 59 encuentra: responder/1 ejecuta su argumento como
% meta, y la copia no lo declara.
test(sin_meta_predicate) :-
    \+ predicate_property(api:responder(_), meta_predicate(_)).

:- end_tests(caso_api).
