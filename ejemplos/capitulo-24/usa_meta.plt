:- encoding(utf8).

:- begin_tests(usa_meta).

test(con_meta_predicate) :-
    todos_mayores([juan, ana]).

test(con_meta_predicate_falla, [fail]) :-
    todos_mayores([juan, eva]).

% Sin la declaración, el predicado se busca en el módulo meta, donde no está.
test(sin_declarar,
     [error(existence_error(procedure, meta:mayor_de_edad/1), _)]) :-
    todos_mayores_sin_declarar([juan]).

% Calificado a mano, se encuentra: la calificación dice dónde buscarlo. Las
% pruebas corren en su propio módulo, que no importa meta: la llamada
% también se califica.
test(calificado) :-
    meta:cada_uno_sin_declarar(usa_meta:mayor_de_edad, [juan, ana]).

:- end_tests(usa_meta).
