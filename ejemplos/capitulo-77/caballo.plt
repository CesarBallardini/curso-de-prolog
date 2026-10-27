:- encoding(utf8).

:- begin_tests(caballo).

test(saltos_entre, [true(L == 7)]) :-
    saltos_entre(a8, h1, Cs),
    length(Cs, L).

test(saltos_entre_valido) :-
    saltos_entre(a8, h1, Cs),
    maplist(casilla, Cs, Celdas),
    forall(nextto(A, B, Celdas), salto(8, A, B, _)).

test(casilla, [true(C == 1-8)]) :-
    casilla(a8, C).

test(casilla_inversa, [true(N == h1)]) :-
    casilla(N, 8-1).

test(casilla_fuera, [fail]) :-
    casilla(i9, _).

test(salto, [true(Ss == [2-3, 3-2])]) :-
    findall(S, salto(8, 1-1, S, _), Ss).

test(admisibles, [true(Ss == [6, 6, 6, 6, 6, 6, 6, 6])]) :-
    findall(S,
            ( member(A, [a_estrella, ida_estrella]),
              member(H, [cero, manhattan, euclidea, combinada]),
              caballo(8, A, H, 1-8, 8-1, _, S, _) ),
            Ss).

test(expandidos_ida, [true(Ks == [225, 1148, 657, 35])]) :-
    findall(K,
            ( member(H, [manhattan, euclidea, combinada,
                         entera(combinada)]),
              caballo(8, ida_estrella, H, 1-8, 8-1, _, _, K) ),
            Ks).

test(minima, [true(S-S0 == 6-4)]) :-
    caballo(8, ida_estrella, minima, 7-2, 1-8, _, S, _),
    caballo(8, ida_estrella, combinada, 7-2, 1-8, _, S0, _).

test(estimar, [true(H1-H2 == 1-0)]) :-
    estimar(manhattan, 1-1, 2-3, H1),
    estimar(cero, 1-1, 2-3, H2).

test(ninguna_domina) :-
    estimar(manhattan, 4-3, 7-4, A1),
    estimar(euclidea, 4-3, 7-4, A2),
    estimar(manhattan, 4-3, 6-1, B1),
    estimar(euclidea, 4-3, 6-1, B2),
    A1 < A2,
    B1 > B2.

test(entera, [true(H == 2)]) :-
    estimar(entera(manhattan), 1-1, 3-3, H).

test(grande, [true(S-K == 66-66)]) :-
    caballo(100, a_estrella, combinada, 1-1, 100-100, _, S, K).

:- end_tests(caballo).
