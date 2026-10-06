:- encoding(utf8).

:- begin_tests(dibujo).

test(conectados_en_los_dos_sentidos, [nondet]) :-
    conectados(cubo, b, a).

test(vecinos_horario, [true(Vs == [e, f, a])]) :-
    vecinos(cubo, c, Vs).

test(vector, [true(V == 25-15)]) :-
    vector(cubo, a, c, V).

test(giro_horario, [true(G < 0)]) :-
    giro(cubo, e, c, b, G).

test(giro_alineado, [true(G =:= 0)]) :-
    giro(bloques, n, c, e, G).

test(opuestos) :-
    opuestos(bloques, n, c, e).

test(no_opuestos, [fail]) :-
    opuestos(bloques, n, c, i).

test(union_flecha, [true(T-Ls == flecha-[e, a, g])]) :-
    union(cubo, b, T, Ls).

test(union_te, [true(T-Ls == te-[c, e, i])]) :-
    union(bloques, n, T, Ls).

test(union_horquilla_concava, [true(T-Ls == horquilla-[h, j, d])]) :-
    union(escalon, i, T, Ls).

test(tipo_ele, [true(Ls == [c, b])]) :-
    tipo([b, c], cubo, e, ele, Ls).

test(rotaciones, [true(Rs == [[a, b, c], [b, c, a], [c, a, b]])]) :-
    rotaciones([a, b, c], Rs).

test(uniones_cubo,
     [true(Us == [u(a, horquilla, [b, c, d]), u(b, flecha, [e, a, g]),
                  u(c, flecha, [f, a, e]), u(d, flecha, [g, a, f]),
                  u(e, ele, [c, b]), u(f, ele, [d, c]),
                  u(g, ele, [b, d])])]) :-
    uniones(cubo, Us).

test(uniones_poiuyt, [true(Ts == [ele-10, flecha-2])]) :-
    uniones(poiuyt, Us),
    findall(T, member(u(_, T, _), Us), Ts0),
    msort(Ts0, Ts1),
    clumped(Ts1, Ts).

test(union_de, [true(U == u(g, ele, [b, d]))]) :-
    union_de(cubo, g, U).

test(lineas, [true(Ls == [a-b, a-c, a-d, b-e, b-g, c-e, c-f, d-f, d-g])]) :-
    lineas(cubo, Ls).

test(linea_ordenada, [true(L == a-b)]) :-
    linea(b, a, L).

test(contorno_cubo, [true(C == [g, b, e, c, f, d])]) :-
    contorno(cubo, C).

test(contorno_escalon, [true(C == [a, f, g, h, i, j, k, b])]) :-
    contorno(escalon, C).

test(recorrer, [true(C == [b, e, c, f, d])]) :-
    recorrer(cubo, g, b, g, b, C).

test(siguiente, [true(Ws == [b, a])]) :-
    siguiente([a, b, c], a, W1),
    siguiente([a, b, c], c, W2),
    Ws = [W1, W2].

test(fijas_sin_borde, [true(Fs == [])]) :-
    fijas(cubo, sin_borde, Fs).

test(fijas_borde, [true(Fs == [b-e-der, b-g-izq, c-e-izq, c-f-der,
                               d-f-izq, d-g-der])]) :-
    fijas(cubo, borde, Fs).

test(pares_consecutivos, [true(Ps == [a-b, b-c])]) :-
    pares_consecutivos([a, b, c], Ps).

test(borde_derecha, [true(Fs == [(a-b)-der, (a-b)-izq])]) :-
    borde_derecha(a-b, F1),
    borde_derecha(b-a, F2),
    Fs = [F1, F2].

test(problema_borde, [true(Libres == 3)]) :-
    problema(cubo, borde, Lineas, Uniones),
    length(Uniones, 7),
    pairs_values(Lineas, Es),
    include(var, Es, Vs),
    length(Vs, Libres).

test(fijar_contradictorio, [fail]) :-
    fijar([(a-b)-der], (a-b)-izq).

test(con_vistas, [true(V == u(e, ele, [inversa(X), inversa(Y)]))]) :-
    Lineas = [(b-e)-Y, (c-e)-X],
    con_vistas(Lineas, u(e, ele, [c, b]), V).

test(vista_de, [true(Vs == [directa(E), inversa(E)])]) :-
    vista_de([(a-b)-E], a, b, V1),
    vista_de([(a-b)-E], b, a, V2),
    Vs = [V1, V2].

test(vista_inversa, [true(L == izq)]) :-
    vista(inversa(der), L).

:- end_tests(dibujo).
