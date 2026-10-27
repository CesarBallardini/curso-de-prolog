:- encoding(utf8).

:- begin_tests(dinamico, [cleanup(retractall(hecho(_)))]).

test(mcd_de_cuatro, [M, R] == [[numero(5), numero(5), numero(5), numero(5)], 5]) :-
    ejecutar(mcd, [numero(25), numero(10), numero(15), numero(30)], M, R).

test(mcd_de_dos, R == 4) :-
    ejecutar(mcd, [numero(12), numero(8)], _, R).

test(mcd_de_uno, R == 7) :-
    ejecutar(mcd, [numero(7)], _, R).

% Sin números, ningún módulo se aplica.
test(mcd_sin_numeros, [M, R] == [[], nada_aplicable]) :-
    ejecutar(mcd, [], M, R).

test(ordenar, [L, R] == [[1, 2, 3, 4, 5], nada_aplicable]) :-
    posiciones([5, 3, 4, 1, 2], H),
    ejecutar(ordenar, H, M, R),
    valores(M, L).

% Cada ejecución empieza con la memoria que recibe, no con la anterior.
test(memoria_nueva, M == [numero(9)]) :-
    ejecutar(mcd, [numero(4), numero(6)], _, _),
    ejecutar(mcd, [numero(9)], M, _).

% La base dinámica no se deshace al retroceder: la ejecución deja su huella.
test(huella, H == [numero(2), numero(2)]) :-
    ejecutar(mcd, [numero(4), numero(6)], _, _),
    findall(F, hecho(F), H).

% condicion/1 sobre la base: una respuesta por hecho que unifica. La base
% es hecho/1 del módulo user, no de la unidad de pruebas.
test(condicion_patron, [true(Xs == [3, 4]), cleanup(retractall(user:hecho(_)))]) :-
    retractall(user:hecho(_)),
    assertz(user:hecho(numero(3))),
    assertz(user:hecho(numero(4))),
    findall(X, condicion(numero(X)), Xs).

test(condicion_negacion, [nondet, cleanup(retractall(user:hecho(_)))]) :-
    retractall(user:hecho(_)),
    assertz(user:hecho(numero(3))),
    condicion(no(numero(5))),
    \+ condicion(no(numero(_))).

test(condicion_prueba, [nondet]) :-
    condicion({3 > 2}).

test(accion_reemplazar, [true(Hs == [numero(1), numero(9)]),
                         cleanup(retractall(user:hecho(_)))]) :-
    retractall(user:hecho(_)),
    assertz(user:hecho(numero(5))),
    assertz(user:hecho(numero(1))),
    accion(reemplazar(numero(5), numero(9))),
    findall(F, user:hecho(F), Hs).

test(accion_quitar_ausente, [fail, cleanup(retractall(user:hecho(_)))]) :-
    retractall(user:hecho(_)),
    accion(quitar(numero(5))).

:- end_tests(dinamico).
