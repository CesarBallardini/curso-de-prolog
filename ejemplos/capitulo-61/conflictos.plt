:- encoding(utf8).

:- begin_tests(conflictos).

test(mcd, R == 5) :-
    ejecutar(mcd, primera, [numero(25), numero(10), numero(15), numero(30)],
             _, R).

% Seis pares de números distintos para resta y cuatro números para
% resultado.
test(conjunto_de_conflicto, [N, Nombres] == [10, [resta, resultado]]) :-
    programa(mcd, Ms),
    conflicto(Ms, [numero(25), numero(10), numero(15), numero(30)], Is),
    length(Is, N),
    findall(Nombre, member(instancia(Nombre, _, _, _), Is), Todos),
    sort(Todos, Nombres).

test(primera_invertido, R == 25) :-
    ejecutar(mcd_invertido, primera, [numero(25), numero(10)], _, R).

test(especifica_invertido, R == 5) :-
    ejecutar(mcd_invertido, especifica, [numero(25), numero(10)], _, R).

test(reciente, E == instancia(b, 1, [0], [])) :-
    elegir(reciente, [y, x],
           [instancia(a, 1, [1], []), instancia(b, 1, [0], [])], E).

test(reciente_sin_hechos, E == instancia(a, 1, [1], [])) :-
    elegir(reciente, [y, x],
           [instancia(c, 0, [], []), instancia(a, 1, [1], [])], E).

test(especifica_empate, E == instancia(a, 2, [], [])) :-
    elegir(especifica, [],
           [instancia(a, 2, [], []), instancia(b, 2, [], []),
            instancia(c, 1, [], [])], E).

% Al ordenar, cada instancia es una inversión, y cada ciclo quita una.
test(ordenar_invertida, [N, L] == [6, [1, 2, 3, 4]]) :-
    posiciones([4, 3, 2, 1], H),
    ciclos(ordenar, primera, H, N),
    ejecutar(ordenar, primera, H, M, nada_aplicable),
    valores(M, L).

test(ordenar_estrategias, [P, R] == [58, 42]) :-
    Lista = [8, 2, 12, 10, 9, 5, 14, 15, 20, 13, 4, 11, 17, 16, 6, 7, 19, 1,
             3, 18],
    posiciones(Lista, H),
    ciclos(ordenar, primera, H, P),
    ciclos(ordenar, reciente, H, R).

test(traza, S == "1: resta de 3, con [numero(12),numero(8)]\n\c
                  2: resta de 3, con [numero(8),numero(4)]\n\c
                  3: resultado de 2, con [numero(4)]\n") :-
    with_output_to(string(S),
                   trazar(mcd, primera, [numero(12), numero(8)], _, _)).

test(clave_primera, [true(C == 0)]) :-
    clave(primera, 5, instancia(a, 2, [3], []), C).

% reciente: la menor posición usada; sin hechos, el largo de la memoria.
test(clave_reciente, [true(Cs == [1, 5])]) :-
    clave(reciente, 5, instancia(a, 2, [3, 1], []), C1),
    clave(reciente, 5, instancia(b, 1, [], []), C2),
    Cs = [C1, C2].

test(clave_especifica, [true(C == -3)]) :-
    clave(especifica, 5, instancia(a, 3, [0], []), C).

test(mostrar_sin_traza, [true(S == "")]) :-
    with_output_to(string(S),
                   mostrar(sin_traza, 1, [x], instancia(a, 1, [0], []), [h])).

test(mostrar_con_traza, [true(S == "2: a de 3, con [h2,h0]\n")]) :-
    with_output_to(string(S),
                   mostrar(con_traza, 2, [x, y, z],
                           instancia(a, 2, [2, 0], []), [h0, h1, h2])).

:- end_tests(conflictos).
