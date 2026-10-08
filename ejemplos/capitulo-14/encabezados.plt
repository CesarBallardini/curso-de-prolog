:- encoding(utf8).

% Una prueba por modo declarado (Patrón 2), y las que documentan qué pasa
% fuera de los modos declarados.

:- begin_tests(encabezados).

% suma_lista(++L, -S) is det: una respuesta, sin alternativas pendientes.
% Una prueba sin nondet advierte si quedan puntos de elección.
test(suma_de_tres, true(S == 8)) :-
    suma_lista([3, 1, 4], S).

test(suma_de_la_vacia, true(S == 0)) :-
    suma_lista([], S).

% Fuera del modo: un elemento sin valor produce un error, no una respuesta.
test(suma_con_un_elemento_libre, [error(instantiation_error)]) :-
    suma_lista([3, _], _).

% primer_multiplo(+De, +Desde, --N) is semidet.
test(primer_multiplo_de_7, true(N == 56)) :-
    primer_multiplo(7, 50, N).

test(sin_multiplo_hasta_200, [fail]) :-
    primer_multiplo(300, 1, _).

% Fuera del modo: con N ligado a un múltiplo que no es el primero, el
% predicado lo acepta. Es lo que el signo -- advierte.
test(con_n_ligado_acepta_otro_multiplo) :-
    primer_multiplo(7, 50, 63).

% mismo_termino(@A, @B) is semidet: no liga nada.
test(variables_distintas_no_son_el_mismo_termino, [fail]) :-
    mismo_termino(_, _).

% var/1, que reconoce una variable libre, se presenta en el capítulo 32.
test(no_liga_variables) :-
    mismo_termino(f(X), f(X)),
    var(X).

% primero/1: $/1 produce un error cuando member/2 deja una alternativa.
test(primero_con_alternativa_es_error,
     [error(determinism_error(_, det, nondet, goal))]) :-
    primero(_).

:- end_tests(encabezados).
