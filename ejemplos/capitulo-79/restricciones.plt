:- encoding(utf8).

:- begin_tests(restricciones).

test(primero, [true(I == [0, 1, 2, 3])]) :-
    siguiente_clp([], I).

test(siguiente, [true(I == [1, 4, 5, 6])]) :-
    siguiente_clp([r([0, 1, 2, 3], 0, 1)], I).

test(contradiccion, [fail]) :-
    siguiente_clp([r([0, 1, 2, 3], 4, 0), r([0, 1, 2, 4], 4, 0)], _).

test(adivinar, [true(Is == [[0, 1, 2, 3], [1, 0, 4, 5], [2, 3, 5, 6],
                            [2, 4, 3, 7], [3, 8, 0, 6], [3, 8, 1, 6]])]) :-
    adivinar_clp([3, 8, 1, 6], Is).

% Las versiones 1 y 3 hacen los mismos intentos, sobre una muestra de 101
% códigos.
test(igual_version_1, [true(Distintos == [])]) :-
    findall(C, codigo(C), Cs),
    findall(S, ( nth0(K, Cs, S), K mod 50 =:= 0,
                 adivinar(S, A), adivinar_clp(S, B), A \== B ),
            Distintos).

test(restringir, [true(Toros-Vacas == 1-2)]) :-
    I = [1, 2, 3, 4],
    restricciones:restringir(I, r([1, 3, 2, 9], Toros, Vacas)).

:- end_tests(restricciones).
