:- encoding(utf8).

:- begin_tests(cubo).

test(resuelto_nueve_por_cara, [true(Ns == [9, 9, 9, 9, 9, 9])]) :-
    resuelto(C),
    C =.. [c|Casillas],
    msort(Casillas, Ordenadas),
    clumped(Ordenadas, Pares),
    pairs_values(Pares, Ns).

test(seis_giros, [true(Caras == [b, d, f, l, r, u])]) :-
    findall(Cara, giro(Cara, _, _), Caras0),
    msort(Caras0, Caras).

test(u_trae_la_derecha_al_frente, [true(Fila == [r, r, r])]) :-
    resuelto(C),
    mover(u, C, C1),
    findall(X, ( member(I, [19, 20, 21]), arg(I, C1, X) ), Fila).

test(r_sube_el_frente, [true(Col == [f, f, f])]) :-
    resuelto(C),
    mover(r, C, C1),
    findall(X, ( member(I, [3, 6, 9]), arg(I, C1, X) ), Col).

test(cuatro_giros_vuelven, [nondet]) :-
    resuelto(C),
    forall(cara(Cara, _, _),
           ( aplicar([Cara, Cara, Cara, Cara], C, C1),
             C1 == C )).

test(inverso_deshace, [true(C2 == C)]) :-
    resuelto(C),
    aplicar([r, u, f], C, C1),
    inversa([r, u, f], I),
    aplicar(I, C1, C2).

test(inversa, [true(I == [-f, u, -r])]) :-
    inversa([r, -u, f], I).

test(tres_cuartos_son_el_inverso, [true(C1 == C2)]) :-
    resuelto(C),
    aplicar([l, l, l], C, C1),
    mover(-l, C, C2).

test(en_sentido_inverso, [true(Antes == C)]) :-
    resuelto(C),
    mover(f, C, C1),
    mover(f, Antes, C1).

test(casillas_distintas, [true(N == 12)]) :-
    resuelto(C),
    aplicar([r, u, -r, -u], C, C1),
    casillas_distintas(C, C1, N).

test(ordenes, [true(Ns == [4, 6, 105, 63])]) :-
    maplist(orden, [[u], [r, u, -r, -u], [r, u], [r, -u]], Ns).

test(doce_cuartos, [true(N == 12)]) :-
    aggregate_all(count, cuarto_de_vuelta(_), N).

test(color_tras, [true(C == r)]) :-
    color_tras([u], 19, C).

test(cambiadas, [true(N == 24)]) :-
    cambiadas([u, d], N).

% rotar/3: un cuarto de vuelta horario alrededor de z, visto desde la punta
% del eje, lleva el eje x al eje -y.
test(rotar, [true(W == p(0, -1, 0))]) :-
    rotar(p(0, 0, 1), p(1, 0, 0), W).

test(rotar_eje_fijo, [true(W == p(0, 1, 0))]) :-
    rotar(p(0, 1, 0), p(0, 1, 0), W).

% Un giro mueve 20 casillas: 8 de la cara y 12 de las vecinas.
test(destino_mueve_20, all(C-N == [u-20, r-20, f-20, d-20, l-20, b-20])) :-
    member(C, [u, r, f, d, l, b]),
    aggregate_all(count, ( between(1, 54, I), destino(C, I, J), I \== J ), N).

test(destino_centro, [nondet, true(J == 5)]) :-
    destino(u, 5, J).

test(destino_permutacion, [true(Js == Is)]) :-
    numlist(1, 54, Is),
    findall(J, ( between(1, 54, I), destino(f, I, J) ), Js0),
    msort(Js0, Js).

test(giro_calculado_igual_al_hecho, all(C == [u, r, f, d, l, b])) :-
    member(C, [u, r, f, d, l, b]),
    giro_calculado(C, A, D),
    giro(C, A1, D1),
    A-D =@= A1-D1.

:- end_tests(cubo).
