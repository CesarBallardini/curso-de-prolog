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

:- end_tests(dinamico).
