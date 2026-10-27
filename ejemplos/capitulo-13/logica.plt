:- encoding(utf8).

:- begin_tests(logica).

test(la_madre_de_luis, all(M == [])) :-
    madre(M, luis).

test(la_madre_de_ana, all(M == [marta])) :-
    madre(M, ana).

test(el_padre_de_luis, all(P == [pedro])) :-
    padre(P, luis).

% tiene_hijos/1 produce una respuesta por cada hijo: el cuantificador
% existencial no elimina las demostraciones repetidas.
test(quienes_tienen_hijos, all(P == [juan, marta, juan, marta, pedro, pedro])) :-
    tiene_hijos(P).

test(los_ascendientes_de_luis, all(A == [pedro, juan, marta])) :-
    ascendiente(A, luis).

test(eva_no_es_ascendiente_de_nadie, [fail]) :-
    ascendiente(eva, _).

test(luis_no_tiene_hijos) :-
    sin_hijos(luis).

test(pedro_tiene_hijos, [fail]) :-
    sin_hijos(pedro).

% Con el argumento libre, la negación con corte y fail falla para todos, como
% \+ tiene_hijos(P): no enumera a quienes no tienen hijos.
test(sin_hijos_con_la_variable_libre, [fail]) :-
    sin_hijos(_).

:- end_tests(logica).
