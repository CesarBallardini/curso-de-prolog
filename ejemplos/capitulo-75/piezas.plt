:- encoding(utf8).

:- begin_tests(piezas).

test(piezas_cantidad, [true(N-A-E == 26-12-8)]) :-
    resuelto(C),
    piezas(C, Ps),
    length(Ps, N),
    aggregate_all(count, ( member(P, Ps), functor(P, p, 2) ), A),
    aggregate_all(count, ( member(P, Ps), functor(P, p, 3) ), E).

% piezas/2 funciona en los dos sentidos: de la lista se recupera el cubo.
test(piezas_inversa, [true(C2 == C1)]) :-
    resuelto(C),
    aplicar([r, u, -f], C, C1),
    piezas(C1, Ps),
    piezas(C2, Ps).

% Cada casilla está en exactamente una pieza.
test(piezas_particion, [true(Vs == Ws)]) :-
    piezas(C, Ps),
    C =.. [c|Vs0],
    msort(Vs0, Vs),
    foldl([P, A0, A]>>( P =.. [p|Xs], append(A0, Xs, A) ), Ps, [], Ws0),
    msort(Ws0, Ws).

test(centro, all(I == [5, 14, 23, 32, 41, 50])) :-
    centro([I]).

test(pieza_de, [true(P == p(c, a))]) :-
    pieza_de(f(a, b, c), [3, 1], P).

test(casilla_de, [true(X == b)]) :-
    casilla_de(f(a, b, c), 2, X).

test(colores_de, [true(Cs == [d, f, r])]) :-
    colores_de('DFR', Cs).

test(nombre_de, [true(N == 'DFR')]) :-
    nombre_de([r, d, f], N).

test(donde_resuelto, [true(L-E == 'UF'-en_su_lugar)]) :-
    resuelto(C),
    donde(C, 'UF', L, E).

test(donde_fuera, [true(L-E == 'UFL'-fuera)]) :-
    resuelto(C),
    aplicar([r, u, -r], C, C1),
    donde(C1, 'DFR', L, E).

test(donde_girada, [true(L-E == 'DFR'-girada)]) :-
    resuelto(C),
    aplicar([r, u, -r, -u, r, u, -r, -u], C, C1),
    donde(C1, 'DFR', L, E).

test(donde_no_pieza, [fail]) :-
    resuelto(C),
    donde(C, 'UD', _, _).

test(piezas_tras, [true(N == 26)]) :-
    piezas_tras([r], Ps),
    length(Ps, N).

test(en_lugar, [true(P == p(u, r, f))]) :-
    resuelto(C),
    en_lugar(C, 'UFR', P).

test(pieza_tras, [true(P == p(f, r, d))]) :-
    pieza_tras([r], 'UFR', P).

test(en_lugar_no_pieza, [fail]) :-
    resuelto(C),
    en_lugar(C, 'UD', _).

test(donde_tras, [true(L-E == 'UL'-fuera)]) :-
    donde_tras([f, f, u, -f], 'DF', L, E).

test(buscar, [true(G-S == p(x, y)-p(b, a))]) :-
    buscar([p(z), p(x, y)], [p(c), p(b, a)], [a, b], G, S).

% La subida de la etapa 1 saca de abajo la arista DF que está girada.
test(ayuda_sube, [true(Ms == [f, f])]) :-
    resuelto(C),
    aplicar([u, f, l, d], C, C1),
    donde(C1, 'DF', 'DF', girada),
    ayuda(1, [], 'DF', C1, Ms).

test(ayuda_no_hace_falta, [true(Ms == [])]) :-
    resuelto(C),
    aplicar([u], C, C1),
    ayuda(1, [], 'DF', C1, Ms).

% La subida no puede mover las piezas ya colocadas.
test(ayuda_respeta_colocadas, [true]) :-
    resuelto(C),
    aplicar([r, u, -r, -u, r, u, -r, -u], C, C1),
    ayuda(2, ['DF', 'DR', 'DB', 'DL'], 'DFR', C1, Ms),
    Ms \== [],
    aplicar(Ms, C1, C2),
    criterio(['DF', 'DR', 'DB', 'DL'], Criterio),
    subsumes_term(Criterio, C2).

test(resolver_con_ayuda, [true(C2 == C)]) :-
    mezcla(3, 25, Ms),
    resuelto(C),
    aplicar(Ms, C, C1),
    resolver_con_ayuda(C1, Pasos),
    findall(G, member(paso(_, _, G), Pasos), Gs),
    append(Gs, Todos),
    aplicar(Todos, C1, C2).

test(colocar_con_ayuda, [true(Pasos == [])]) :-
    resuelto(C),
    colocar_con_ayuda([], [], C, Pasos).

% Las inferencias dependen de lo que ya está cargado; los giros, no.
test(comparar_ayuda, [true(G1-G2 == 1768-1732)]) :-
    comparar_ayuda(10, medida(G1, I1), medida(G2, I2)),
    integer(I1),
    integer(I2).

test(medir_metodo, [true(M = medida(_, _))]) :-
    medir_metodo(resolver, 2, M).

test(resolver_semilla, [true(G > 0)]) :-
    resolver_semilla(resolver_con_ayuda, 1, G, _).

:- end_tests(piezas).
