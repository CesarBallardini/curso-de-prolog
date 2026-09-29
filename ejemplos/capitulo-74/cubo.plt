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

:- end_tests(cubo).
