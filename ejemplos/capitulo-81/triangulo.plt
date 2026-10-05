:- encoding(utf8).

:- begin_tests(triangulo).

test(casillas, [true(N == 15)]) :-
    aggregate_all(count, casilla(_, _, _), N).

test(casilla, [true(F-C == 3-2), nondet]) :-
    casilla(5, F, C).

test(lineas, [true(N == 18)]) :-
    aggregate_all(count, linea(_, _, _), N).

test(linea_borde) :-
    once(linea(1, 2, 4)),
    once(linea(11, 12, 13)).

test(linea_no_recta, [fail]) :-
    linea(1, 3, 5).

test(saltos, [true(N == 36)]) :-
    aggregate_all(count, salto(_, _, _), N).

test(saltos_desde_el_vertice, [true(Ss == [s(4, 2, 1), s(6, 3, 1)])]) :-
    inicio(1, T),
    findall(S, salto(S, T, _), Ss0),
    msort(Ss0, Ss).

test(salto_quita_una, [true(K == 13)]) :-
    inicio(1, T0),
    once(salto(_, T0, T)),
    clavijas(T, K).

test(giro, [true(Ns == [15, 11, 1])]) :-
    findall(N, ( member(A, [1, 15, 11]), imagen(giro, A, N) ), Ns).

test(espejo_fija_su_vertice, [true(Ns == [1, 11, 15])]) :-
    findall(N,
            ( member(S-A, [espejo1-1, espejo11-11, espejo15-15]),
              imagen(S, A, N) ),
            Ns).

test(simetrias_biyectivas) :-
    forall(simetria(S, _, _),
           ( findall(N1, ( between(1, 15, N), imagen(S, N, N1) ), Ns),
             msort(Ns, Ordenados),
             numlist(1, 15, Ordenados) )).

test(simetrias_conservan_lineas) :-
    forall(( simetria(S, _, _), linea(A, B, C) ),
           ( imagen(S, A, A1),
             imagen(S, B, B1),
             imagen(S, C, C1),
             ( linea(A1, B1, C1) -> true ; linea(C1, B1, A1) ) )).

test(simetria_de_posicion, [true(T1 == T15)]) :-
    inicio(1, T),
    simetria(giro, T, T1),
    inicio(15, T15).

test(seis_simetrias, [true(N == 6)]) :-
    aggregate_all(count, simetria(_, _, _), N).

test(inicio, [true(K == 14)]) :-
    inicio(7, T),
    clavijas(T, K),
    arg(7, T, 0).

test(resolver, [true(L == 13)]) :-
    inicio(1, T),
    once(resolver(T, Saltos)),
    length(Saltos, L),
    jugar(Saltos, T, Ts),
    last(Ts, Final),
    clavijas(Final, 1).

test(resolver_primera, [true(S == s(4, 2, 1))]) :-
    inicio(1, T),
    once(resolver(T, [S|_])).

test(jugar_ilegal, [fail]) :-
    inicio(1, T),
    jugar([s(1, 2, 4)], T, _).

test(filas, [true(Fs == ["    ·", "   o o", "  o o o", " o o o o",
                         "o o o o o"])]) :-
    inicio(1, T),
    filas(T, Fs).

test(dibujar, [true(S == "    o\n   o ·\n  o o o\n o o o o\no o o o o\n")]) :-
    inicio(3, T),
    with_output_to(string(S), dibujar(T)).

test(forma_invariante) :-
    inicio(4, T),
    forma(T, F),
    forall(simetria(_, T, I), forma(I, F)).

test(forma_de_vertices, [true(F1 == F11)]) :-
    inicio(1, T1),
    inicio(11, T11),
    forma(T1, F1),
    forma(T11, F11).

test(formas_de_inicio, [true(N == 4)]) :-
    setof(F, V^T^( between(1, 15, V), inicio(V, T), forma(T, F) ), Fs),
    length(Fs, N).

test(jugar_todas, [true(K-L == 487-13)]) :-
    jugar_todas(profundidad, 1, Saltos, K),
    length(Saltos, L),
    inicio(1, T),
    jugar(Saltos, T, _).

test(jugar_formas, [true(K == 390)]) :-
    jugar_formas(profundidad, 1, Saltos, K),
    inicio(1, T),
    jugar(Saltos, T, Ts),
    last(Ts, Final),
    clavijas(Final, 1).

test(en_el_tablero, [true(Saltos == [s(4, 2, 1)])]) :-
    inicio(1, T0),
    once(salto(s(4, 2, 1), T0, T)),
    forma(T, F),
    en_el_tablero([F], T0, Saltos).

:- end_tests(triangulo).
