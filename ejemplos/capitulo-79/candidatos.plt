:- encoding(utf8).

:- begin_tests(candidatos).

test(candidatos, [true(N == 5040)]) :-
    candidatos(Cs),
    length(Cs, N).

% Sin toros ni vacas, los cuatro dígitos del intento quedan descartados:
% quedan las variaciones de los otros seis, 6 · 5 · 4 · 3.
test(filtrar, [true(N == 360)]) :-
    candidatos(Cs0),
    filtrar(Cs0, [0, 1, 2, 3], 0, 0, Cs),
    length(Cs, N).

test(filtrar_orden, [true(Cs == [[0, 4, 5, 6], [0, 4, 5, 7]])]) :-
    candidatos(Cs0),
    filtrar(Cs0, [0, 1, 2, 3], 1, 0, Cs1),
    findall(C, limit(2, member(C, Cs1)), Cs).

test(quedan, [true(Ns == [5040, 360, 1440])]) :-
    maplist(quedan, [[], [r([0, 1, 2, 3], 0, 0)], [r([0, 1, 2, 3], 0, 1)]],
            Ns).

test(adivinar, [true(Is == [[0, 1, 2, 3], [1, 0, 4, 5], [2, 3, 5, 6],
                            [2, 4, 3, 7], [3, 8, 0, 6], [3, 8, 1, 6]])]) :-
    adivinar_candidatos([3, 8, 1, 6], Is).

% Las versiones 1 y 2 hacen los mismos intentos, sobre una muestra de 101
% códigos.
test(igual_version_1, [true(Distintos == [])]) :-
    findall(C, codigo(C), Cs),
    findall(S, ( nth0(K, Cs, S), K mod 50 =:= 0,
                 adivinar(S, A), adivinar_candidatos(S, B), A \== B ),
            Distintos).

test(jugar, [true(S == "Piensa un código de cuatro dígitos distintos.\n\c
Intento 1: 0 1 2 3. ¿Toros y vacas? 0 1\n\c
Intento 2: 1 4 5 6. ¿Toros y vacas? 9 9\n\c
Esa respuesta no es posible. ¿Toros y vacas? 1 2\n\c
Intento 3: 1 5 4 7. ¿Toros y vacas? 0 2\n\c
Intento 4: 2 4 6 5. ¿Toros y vacas? 0 3\n\c
Intento 5: 3 6 5 4. ¿Toros y vacas? 2 2\n\c
Intento 6: 6 3 5 4. ¿Toros y vacas? 4 0\n\c
Tu código es 6 3 5 4: encontrado en 6 intentos.\n")]) :-
    open_string("0 1\n9 9\n1 2\n0 2\n0 3\n2 2\n4 0\n", In),
    with_output_to(string(S), jugar(In)).

test(contradicen, [true(S == "Piensa un código de cuatro dígitos distintos.\n\c
Intento 1: 0 1 2 3. ¿Toros y vacas? 0 0\n\c
Intento 2: 4 5 6 7. ¿Toros y vacas? 0 0\n\c
Tus respuestas se contradicen: ningún código las cumple.\n")]) :-
    open_string("0 0\n0 0\n0 0\n", In),
    with_output_to(string(S), jugar(In)).

test(posibles, [true(Ps == [si, no, no, si, no])]) :-
    findall(P, ( member(T-V, [0-0, 3-1, 2-3, 0-4, (-1)-0]),
                 ( candidatos:posible(T, V) -> P = si ; P = no ) ),
            Ps).

:- end_tests(candidatos).
