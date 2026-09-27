:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 3
test(suma_acc, true(S == 8)) :-
    suma_lista_acc([3, 1, 4], S).

% Ejercicio 4: sin nondet, porque ya no deja alternativas.
test(contar_bien, true(N == 3)) :-
    contar_bien([a, b, c], N).

% Ejercicio 5: el corte deja la relación en semidet, sin alternativas.
test(todos_estan_corte) :-
    todos_estan_corte([a, b], [a, b, c]).

test(falta_uno, [fail]) :-
    todos_estan_corte([a, z], [a, b, c]).

% Ejercicio 7: las dos dan lo mismo; la de la izquierda cuesta mucho más.
test(aplanar_igual, true(L1 == L2)) :-
    aplanar_izq([[a, b], [c], [], [d, e]], L1),
    aplanar_der([[a, b], [c], [], [d, e]], L2).

test(aplanar_izq_cuesta_mas, true(Izq > 100 * Der)) :-
    length(Listas, 1000),
    maplist(diez, Listas),
    inferencias(aplanar_izq(Listas, _), Izq),
    inferencias(aplanar_der(Listas, _), Der).

diez(L) :-
    numlist(1, 10, L).

:- end_tests(soluciones).
