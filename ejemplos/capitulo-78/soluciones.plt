:- encoding(utf8).

:- begin_tests(soluciones).

test(ejercicio_1, [true(S-J == [2, 0, 0]-[sacar(1, 2)])]) :-
    maplist(suma_nim, [[3, 4, 5], [1, 4, 5], [2, 2, 7, 7]], S),
    findall(X, jugada_segura([3, 4, 5], X), J).

test(ejercicio_1_ganadoras, [true(G == [si, no, no])]) :-
    findall(R, ( member(P, [[3, 4, 5], [1, 4, 5], [2, 2, 7, 7]]),
                 ( ganadora_tabulada(P) -> R = si ; R = no ) ),
            G).

test(miseria, [true(L == [[1, 1, 1], [2, 2], [1, 2, 3]])]) :-
    findall(P, ( member(P, [[1, 1, 1], [1, 1], [2, 2], [1, 2, 3], [3, 4, 5]]),
                 segura_miseria(P) ),
            L).

test(miseria_sin_fichas) :-
    ganadora_miseria([0, 0]).

%!  posicion3(-Posicion:list) is nondet.
%
%   Posicion son tres pilas de 0 a 7 fichas.
posicion3([A, B, C]) :-
    between(0, 7, A),
    between(0, 7, B),
    between(0, 7, C).

test(miseria_igual_regla, [true(Distintas == [])]) :-
    findall(P, ( posicion3(P),
                 \+ ( ganadora_miseria(P) -> \+ segura_miseria(P)
                    ; segura_miseria(P) ) ),
            Distintas).

test(ejercicio_3, [true(J-V-N == sacar(5, 9)-50-26)]) :-
    alfabeta(nim_suma([1, 3, 5, 7, 9]), pilas([1, 3, 5, 7, 9], uno), 1,
             J, V, N).

test(valor_suma, [true(Vs == [50, -50, -50, 50])]) :-
    findall(V, ( member(P-J, [[1, 1]-dos, [1, 1]-uno, [1, 2]-dos,
                              [1, 2]-uno]),
                 valor_suma(P, J, V) ),
            Vs).

test(ejercicio_4, [true(N == 728)]) :-
    abolish_all_tables,
    ganadora_tabulada([1, 3, 5, 7, 9]),
    posiciones(N).

test(particion, [true(C == [0-0-360, 0-1-1440, 0-2-1260, 0-3-264, 0-4-9,
                            1-0-480, 1-1-720, 1-2-216, 1-3-8, 2-0-180,
                            2-1-72, 2-2-6, 3-0-24, 4-0-1])]) :-
    particion([0, 1, 2, 3], C).

% Después de dos respuestas quedan 83 códigos; el primero, 1547, deja en el
% peor caso 27, y 1574, el elegido, 25.
test(mejor_intento, [true(I-M == [1, 5, 7, 4]-25)]) :-
    candidatos(Cs0),
    filtrar(Cs0, [0, 1, 2, 3], 0, 1, Cs1),
    filtrar(Cs1, [1, 4, 5, 6], 1, 2, Cs),
    mejor_intento(Cs, I),
    peor_clase(Cs, I, M).

test(peor_clase, [true(M == 1440)]) :-
    candidatos(Cs),
    peor_clase(Cs, [0, 1, 2, 3], M).

test(colores, [true(T-V == 1-2)]) :-
    respuesta_colores([1, 1, 2, 3], [1, 2, 1, 6], T, V).

test(colores_repetidos, [true(T-V == 0-1)]) :-
    respuesta_colores([1, 2, 2, 2], [3, 1, 1, 1], T, V).

test(codigos_colores, [true(N == 1296)]) :-
    aggregate_all(count, codigo_colores(_), N).

test(adivinar_colores, [true(Is == [[1, 1, 1, 1], [1, 2, 2, 2],
                                    [3, 1, 2, 3], [3, 2, 1, 4],
                                    [4, 1, 3, 2], [4, 3, 2, 1]])]) :-
    adivinar_colores([4, 3, 2, 1], Is).

test(contradiccion, [true(K == 2)]) :-
    primera_contradiccion([r([0, 1, 2, 3], 0, 0), r([4, 5, 6, 7], 0, 0),
                           r([8, 9, 0, 1], 0, 0)], K).

test(sin_contradiccion, [fail]) :-
    primera_contradiccion([r([0, 1, 2, 3], 0, 1)], _).

test(ejercicio_9, [true(U-T == 3-tablero([1, 1, 0, 1, 1, 1], 3,
                                         [1, 1, 1, 0, 3, 1], 0))]) :-
    sembrar(3, tablero([0, 0, 13, 0, 0, 0], 0, [0, 0, 0, 0, 2, 0], 0), U, T0),
    capturar(U, T0, T).

test(piedras, [true(V-W == 4-(-4))]) :-
    piedras(tablero([2, 2, 2, 0, 0, 0], 5, [1, 1, 0, 0, 0, 0], 3), sur, V),
    piedras(tablero([2, 2, 2, 0, 0, 0], 5, [1, 1, 0, 0, 0, 0], 3), norte, W).

test(puntos, [true(P == [a-1.5, b-0.5])]) :-
    puntos([r(a-2, b-2, gana(sur)), r(b-2, a-2, empate)], P).

test(texto, [true(Ts == ["La computadora saca 3 fichas de la pila 2.",
                         "La computadora saca 1 ficha de la pila 1."])]) :-
    maplist(jugada_nim_texto, [sacar(2, 3), sacar(1, 1)], Ts).

:- end_tests(soluciones).
