:- encoding(utf8).

:- begin_tests(soluciones).

test(astil_nunca_contorno, [true(Es == [mas, menos])]) :-
    posibles_en(flecha, 2, Es).

test(pie_de_te, [true(Es == [der, izq, mas, menos])]) :-
    posibles_en(te, 3, Es).

test(combinaciones_cubo, [true(Ns == [29160, 216])]) :-
    combinaciones(cubo, sin_borde, inicial, N1),
    combinaciones(cubo, sin_borde, filtrado, N2),
    Ns = [N1, N2].

test(combinaciones_poiuyt, [true(Ns == [544195584, 2073600])]) :-
    combinaciones(poiuyt, sin_borde, inicial, N1),
    combinaciones(poiuyt, sin_borde, filtrado, N2),
    Ns = [N1, N2].

test(producto, [true(P == 6)]) :-
    producto(3, 2, P).

test(apoyado_en_el_piso,
     [all(Ls == [[(a-b)-mas, (a-c)-mas, (a-d)-mas, (b-e)-der, (b-g)-izq,
                  (c-e)-izq, (c-f)-der, (d-f)-menos, (d-g)-menos]])]) :-
    etiquetar_apoyado(cubo, [d-g], Ls).

test(apoyar_falla_en_contorno_fijo, [fail]) :-
    apoyar([(a-b)-der], b-a).

test(dos_cubos, [true(Ns == [16, 4])]) :-
    interpretaciones_waltz(dos_cubos, sin_borde, N1),
    interpretaciones_waltz(dos_cubos, borde, N2),
    Ns = [N1, N2].

test(copia, [true(P == n)]) :-
    copia(g, P).

test(ambiguas_cubo, [true(Ls == [b-e, b-g, c-e, c-f, d-f, d-g])]) :-
    ambiguas(cubo, sin_borde, Ls).

test(ambiguas_bloques, [true(N == 10)]) :-
    ambiguas(bloques, sin_borde, Ls),
    length(Ls, N).

test(ambigua_en) :-
    ambigua_en([[l-mas], [l-menos]], l).

test(por_catalogo_mismas, [true(N == 4)]) :-
    aggregate_all(count, etiquetar_por_catalogo(cubo, sin_borde, _), N).

test(entradas, [true(N == 3)]) :-
    entradas(u(x, flecha, []), N).

test(medir_catalogo, [true(N == 4)]) :-
    medir_catalogo(escalera(2), sin_borde, N, I),
    integer(I).

test(crecimiento, [true(Ns == [2, 4])]) :-
    crecimiento(waltz, [2, 4], Filas),
    pairs_keys(Filas, Ns),
    pairs_values(Filas, [I1, I2]),
    I1 < I2.

test(pasos, [true(R == [1-[a], 12-[a, b, c, d, e, f, g]])]) :-
    pasos(cubo, borde, N1, U1),
    pasos(cubo, sin_borde, N2, U2),
    R = [N1-U1, N2-U2].

test(prisma, [true(Ns == [4, 1])]) :-
    interpretaciones_waltz(prisma, sin_borde, N1),
    interpretaciones_waltz(prisma, borde, N2),
    Ns = [N1, N2].

test(prisma_uniones, [true(Ts == [ele, flecha, ele, flecha, ele])]) :-
    uniones(prisma, Us),
    findall(T, member(u(_, T, _), Us), Ts).

test(catalogo_cambiado, [true(Ns == [0, 0])]) :-
    aggregate_all(count, etiquetar_cambiado(cubo, borde, _), N1),
    aggregate_all(count, etiquetar_cambiado(cubo, sin_borde, _), N2),
    Ns = [N1, N2].

test(union_cambiada, [true(N == 18)]) :-
    aggregate_all(count, union_cambiada(_, _), N).

test(elegir_cambiada, [fail]) :-
    elegir_cambiada(u(b, flecha, [directa(der), directa(mas),
                                  directa(izq)])).

:- end_tests(soluciones).
