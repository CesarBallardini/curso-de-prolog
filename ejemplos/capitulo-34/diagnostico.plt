:- encoding(utf8).

:- begin_tests(diagnostico).

% Los dos programas tienen un error cada uno.
test(incorrecto_responde_mal, all(S == [[1, 3]])) :-
    ordenar_incorrecto([3, 1, 2], S).

test(incompleto_falla, [fail]) :-
    ordenar_incompleto([2, 1], _).

test(oraculo_verifica, [true]) :-
    pretendido(ordenar_incorrecto([3, 1, 2], [1, 2, 3])).

test(oraculo_rechaza, [fail]) :-
    pretendido(ordenar_incorrecto([3, 1, 2], [1, 3])).

test(oraculo_liga, true(S == [1, 2])) :-
    pretendido(ordenar_incompleto([2, 1], S)).

test(incorrecta,
     all(S-C == [[1, 3]-(insertar_incorrecto(1, [2], [1]) :- 1 =< 2)])) :-
    respuesta_incorrecta(ordenar_incorrecto([3, 1, 2], S), C).

% Con una respuesta correcta no hay nada que diagnosticar.
test(incorrecta_sin_error, [fail]) :-
    respuesta_incorrecta(ordenar_incorrecto([2, 1], _), _).

% La cláusula falsa puede ser un hecho: su cuerpo es true.
test(clausula_falsa_hecho, true(C == (p(a) :- true))) :-
    clausula_falsa(prueba(p(a), []), C).

test(faltante, true(S-G == [1, 2]-insertar_incompleto(1, [], [1]))) :-
    respuesta_faltante(ordenar_incompleto([2, 1], S), G).

% El objetivo no cubierto es la inserción del último elemento en la lista
% vacía, la primera que hace el programa.
test(faltante_otra_lista, true(G == insertar_incompleto(7, [], [7]))) :-
    respuesta_faltante(ordenar_incompleto([5, 9, 7], _), G).

% Si el programa prueba el objetivo, no falta ninguna respuesta.
test(faltante_sin_error, [fail]) :-
    respuesta_faltante(ordenar_incompleto([], _), _).

test(conjuncion, true(C == (a, b, c))) :-
    conjuncion([a, b, c], C).

test(conjuncion_vacia, true(C == true)) :-
    conjuncion([], C).

:- end_tests(diagnostico).
