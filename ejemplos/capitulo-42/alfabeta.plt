:- encoding(utf8).

:- begin_tests(alfabeta).

% La poda deja sin visitar e2 y el subárbol de g: 11 nodos en lugar de 15.
test(arbol, [true(J-V-N == b-5-11)]) :-
    alfabeta(arbol, a, 3, J, V, N).

test(arbol_minimax, [true(N == 15)]) :-
    minimax(arbol, a, 3, _, _, N).

test(defiende_o, [true(J-V-N == 3-0-134)]) :-
    alfabeta(tateti(3), pos([x, o, v, v, x, v, v, v, o], o), 9, J, V, N).

test(gana_x, [true(J-V == 4-102)]) :-
    alfabeta(tateti(3), pos([x, o, v, v, x, v, v, v, o], x), 9, J, V, _).

test(terminada, [true(J-V-N == ninguna-104-1)]) :-
    alfabeta(tateti(3), pos([x, x, x, o, o, v, v, v, v], o), 5, J, V, N).

%!  muestra(-Posiciones:list) is det.
%
%   Posiciones son una de cada 25 de las posiciones que siguen a tres
%   jugadas desde el tablero vacío.
muestra(Posiciones) :-
    inicial(tateti(3), P0),
    findall(P, ( jugada(tateti(3), P0, _, P1),
                 jugada(tateti(3), P1, _, P2),
                 jugada(tateti(3), P2, _, P) ), Todas),
    findall(P, ( nth0(I, Todas, P), I mod 25 =:= 0 ), Posiciones).

% Sobre la muestra, la poda da la misma jugada y el mismo valor que minimax,
% y visita menos nodos.
test(igual_a_minimax, [true(Distintas == [])]) :-
    muestra(Ps),
    findall(P, ( member(P, Ps),
                 minimax(tateti(3), P, 6, J1, V1, N1),
                 alfabeta(tateti(3), P, 6, J2, V2, N2),
                 \+ ( J1-V1 == J2-V2, N2 =< N1 ) ), Distintas).

test(igual_con_limite, [true(Distintas == [])]) :-
    muestra(Ps),
    findall(P, ( member(P, Ps),
                 minimax(tateti(3), P, 2, J1, V1, _),
                 alfabeta(tateti(3), P, 2, J2, V2, _),
                 J1-V1 \== J2-V2 ), Distintas).

test(poda, [true(Ps == [si, no, si, no])]) :-
    findall(P, ( member(L-V, [max-5, max-4, min-2, min-3]),
                 ( poda(L, V, 2, 5) -> P = si ; P = no ) ), Ps).

test(estrecha_max, [true(A-B == 3-5)]) :-
    estrecha(max, 3, 2, 5, A, B).

test(estrecha_min, [true(A-B == 2-4)]) :-
    estrecha(min, 4, 2, 5, A, B).

test(no_estrecha, [fail]) :-
    estrecha(max, 2, 2, 5, _, _).

test(propia, [true(Vs == [2, 5])]) :-
    propia(max, 2, 5, V1),
    propia(min, 2, 5, V2),
    Vs = [V1, V2].

% Con cotas que dejan fuera el valor 5 de la raíz, el valor es una cota.
test(cota_alta, [true(V >= 3)]) :-
    acotado(arbol, a, 3, -inf, 3, _, V, 0, _).

test(cota_baja, [true(V =< 7)]) :-
    acotado(arbol, a, 3, 7, inf, _, V, 0, _).

:- end_tests(alfabeta).
