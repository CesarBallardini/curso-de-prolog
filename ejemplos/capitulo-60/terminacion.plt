:- encoding(utf8).

:- begin_tests(terminacion).

test(luz, [M, R] == [[luz(encendida)], repetida(0, 2)]) :-
    vigilar(luz, primera, 100, [luz(encendida)], M, R).

% Con >=, las dos condiciones pueden usar el mismo hecho: 25 - 25 = 0.
test(mcd_mal, [M, R] == [[numero(0), numero(10)], repetida(1, 2)]) :-
    vigilar(mcd_mal, primera, 100, [numero(25), numero(10)], M, R).

test(contador, [M, R] == [[contador(50)], limite(50)]) :-
    vigilar(contador, primera, 50, [contador(0)], M, R).

test(mcd, R == 5) :-
    vigilar(mcd, primera, 100,
            [numero(25), numero(10), numero(15), numero(30)], _, R).

% El límite corta también un programa que terminaría.
test(limite_corto, R == limite(3)) :-
    vigilar(mcd, primera, 3,
            [numero(25), numero(10), numero(15), numero(30)], _, R).

% La memoria se compara como colección: el orden de los hechos no cuenta.
test(misma_coleccion, R == repetida(0, 2)) :-
    vigilar(luz, primera, 100, [luz(encendida), otro], _, R).

% vigilado/8 directamente: una memoria ya vista en el ciclo 4 se reconoce
% como repetida en el ciclo 7, antes de ejecutar nada.
test(vigilado_vista, [true(M-R == [b, a]-repetida(4, 7))]) :-
    list_to_assoc([[a, b]-4], Vistas),
    vigilado([], primera, 10, 7, Vistas, [b, a], M, R).

test(vigilado_limite, [true(R == limite(10))]) :-
    empty_assoc(Vistas),
    vigilado([], primera, 10, 10, Vistas, [a], _, R).

test(vigilado_nada, [true(R == nada_aplicable)]) :-
    empty_assoc(Vistas),
    vigilado([], primera, 10, 0, Vistas, [a], _, R).

:- end_tests(terminacion).
