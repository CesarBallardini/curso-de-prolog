:- encoding(utf8).

:- begin_tests(restricciones).

test(cubo_con_borde,
     [true(Ls == [(a-b)-mas, (a-c)-mas, (a-d)-mas, (b-e)-der, (b-g)-izq,
                  (c-e)-izq, (c-f)-der, (d-f)-izq, (d-g)-der])]) :-
    once(etiquetar_por_uniones(cubo, borde, alfabetico, Ls)).

test(cantidades, [true(Ns == [4-1, 15-1, 4-1, 0-0])]) :-
    findall(N1-N2,
            ( member(F, [cubo, bloques, escalon, poiuyt]),
              interpretaciones_por_uniones(F, sin_borde, vecindad, N1),
              interpretaciones_por_uniones(F, borde, vecindad, N2) ),
            Ns).

test(mismo_resultado_en_los_dos_ordenes) :-
    findall(L, etiquetar_por_uniones(bloques, sin_borde, alfabetico, L), A),
    findall(L, etiquetar_por_uniones(bloques, sin_borde, vecindad, L), B),
    msort(A, As),
    msort(B, Bs),
    As == Bs.

test(elegir, [all(Ls == [[mas, mas, mas], [menos, menos, menos],
                         [izq, der, menos], [menos, izq, der],
                         [der, menos, izq]])]) :-
    Ls = [A, B, C],
    elegir(u(a, horquilla, [directa(A), directa(B), directa(C)])).

test(elegir_con_linea_ligada, [all(L == [mas])]) :-
    elegir(u(b, flecha, [directa(der), inversa(L), directa(izq)])).

test(ordenar_alfabetico, [true(Os == Us)]) :-
    problema(cubo, borde, _, Us),
    ordenar(alfabetico, cubo, Us, Os).

test(ordenar_vecindad, [true(Ps == [b, b2, o, t, t2, c(1), c2(1)])]) :-
    problema(escalera(1), borde, _, Us),
    ordenar(vecindad, escalera(1), Us, Os),
    findall(P, member(u(P, _, _), Os), Ps).

test(vecindad_sin_uniones, [true(Os == [])]) :-
    vecindad([], cubo, [], Os).

test(unida) :-
    unida(cubo, u(e, ele, []), [u(b, flecha, [])]).

test(no_unida, [fail]) :-
    unida(cubo, u(e, ele, []), [u(a, horquilla, [])]).

:- end_tests(restricciones).
