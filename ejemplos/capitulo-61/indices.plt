:- encoding(utf8).

:- begin_tests(indices).

% La memoria indexada devuelve los hechos en el orden de la lista.
test(indexar_y_hechos, [true(Hs == [b(1), a(2), b(3)])]) :-
    indexar([b(1), a(2), b(3)], M),
    hechos(M, Hs).

test(indexar_vacia, [true(Hs == [])]) :-
    indexar([], M),
    hechos(M, Hs).

test(clave, [true(K == numero/1)]) :-
    clave(numero(_), K).

% Un hecho agregado es el más reciente: tiene la mayor marca.
test(agregar_hecho, [true(Hs-T == [c(9), b(1), a(2)]-3)]) :-
    indexar([b(1), a(2)], M0),
    agregar_hecho(c(9), M0, M),
    hechos(M, Hs),
    hecho_en(c(_), M, T).

test(quitar_hecho, [true(Hs == [b(1), b(3)])]) :-
    indexar([b(1), a(2), b(3)], M0),
    quitar_hecho(a(_), M0, M),
    hechos(M, Hs).

% Quita el más reciente que unifica.
test(quitar_el_reciente, [true(Hs == [a(2), b(3)])]) :-
    indexar([b(1), a(2), b(3)], M0),
    quitar_hecho(b(_), M0, M),
    hechos(M, Hs).

test(quitar_ausente, [fail]) :-
    indexar([a(1)], M0),
    quitar_hecho(b(_), M0, _).

% hecho_en/3 recorre solo los hechos de la clave, del más reciente al más
% antiguo.
test(hecho_en, all(X-T == [1-3, 3-1])) :-
    indexar([b(1), a(2), b(3)], M),
    hecho_en(b(X), M, T).

test(hecho_en_sin_clave, [fail]) :-
    indexar([a(1)], M),
    hecho_en(z(_), M, _).

test(satisface_i, all(X-Y-Ts == [3-1-[1, 3]])) :-
    indexar([b(1), a(2), b(3)], M),
    satisface_i([b(X), b(Y), {X > Y}], M, Ts).

test(satisface_negacion, [true(Ts == []), nondet]) :-
    indexar([a(1)], M),
    satisface_i([no(b(_))], M, Ts).

test(acciones_i, [true(Hs-F == [n(5), m(1)]-parar(listo))]) :-
    indexar([n(4), m(1)], M0),
    acciones_i([reemplazar(n(4), n(5)), parar(listo), agregar(z)], M0, M, F),
    hechos(M, Hs).

% resta solo con 6 y 4; resultado con cada número.
test(conflicto_i, [true(Ns == [resta, resultado, resultado])]) :-
    programa(mcd, Ms),
    indexar([numero(4), numero(6)], M),
    conflicto_i(Ms, M, Is),
    findall(N, member(instancia(N, _, _, _), Is), Ns0),
    msort(Ns0, Ns).

test(elegir_i, [true(Ns == [a, b, c])]) :-
    Is = [instancia(a, 1, [1], []), instancia(b, 1, [5], []),
          instancia(c, 3, [2], [])],
    elegir_i(primera, Is, instancia(N1, _, _, _)),
    elegir_i(reciente, Is, instancia(N2, _, _, _)),
    elegir_i(especifica, Is, instancia(N3, _, _, _)),
    Ns = [N1, N2, N3].

% Dos restas, de 6 a 2 y de 4 a 2, y resultado: tres ciclos.
test(ciclo_i, [true(N-R == 3-2)]) :-
    programa(mcd, Ms),
    indexar([numero(4), numero(6)], M0),
    ciclo_i(Ms, primera, 0, N, M0, _, R).

% La versión indexada da el mismo resultado y la misma memoria que la 3.
test(igual_que_v3, [forall(member(P-E-H, [ mcd-primera-[numero(25), numero(10), numero(15), numero(30)],
                                           mcd_invertido-especifica-[numero(25), numero(10)],
                                           ordenar-primera-[pos(1, 3), pos(2, 1), pos(3, 2)],
                                           ordenar-reciente-[pos(1, 4), pos(2, 5), pos(3, 1), pos(4, 3), pos(5, 2)] ])),
                   true(MI-RI == M3-R3)]) :-
    ejecutar_indexado(P, E, H, MI, RI),
    ejecutar(P, E, H, M3, R3).

% Con las fases, el orden de los módulos y la estrategia no importan.
test(fases, [forall(member(E, [primera, reciente, especifica])),
             true(R == 5)]) :-
    programa_fases(mcd_fases, Fs),
    ejecutar_fases(Fs, E, [numero(25), numero(10), numero(15)], _, R).

test(fases_vacia, [true(M-R == [a]-nada_aplicable)]) :-
    ejecutar_fases([], primera, [a], M, R).

% Sin fase que pare, la última termina con nada_aplicable.
test(fases_sin_parar, [true(Hs-R == [numero(2), numero(2)]-nada_aplicable)]) :-
    programa_fases(mcd_fases, [Calcular|_]),
    indexar([numero(4), numero(6)], M0),
    fases([Calcular], primera, M0, M, R),
    hechos(M, Hs).

% Con la memoria indexada, 100 hechos ruido(I) agregan menos de un 5 % al
% costo de los ciclos: están en otra clave, y solo alargan los caminos del
% árbol del índice. Con la lista de la versión 3, el costo se duplica.
test(ruido_indexado, [true(R1-R3 == true-true)]) :-
    programa(mcd, Ms),
    numlist(1, 6, Is),
    findall(numero(V), ( member(I, Is), V is I * 60 ), Ns),
    findall(ruido(I), between(1, 100, I), Rs),
    append(Ns, Rs, Hs),
    indexar(Ns, M1),
    indexar(Hs, M2),
    inferencias(ciclo_i(Ms, primera, 0, _, M1, _, _), I1),
    inferencias(ciclo_i(Ms, primera, 0, _, M2, _, _), I2),
    inferencias(ejecutar(mcd, primera, Ns, _, _), L1),
    inferencias(ejecutar(mcd, primera, Hs, _, _), L2),
    (   I2 < I1 * 1.05
    ->  R1 = true
    ;   R1 = false
    ),
    (   L2 > L1 * 2
    ->  R3 = true
    ;   R3 = false
    ).

inferencias(Meta, N) :-
    statistics(inferences, A),
    call(Meta),
    statistics(inferences, B),
    N is B - A.

test(ejecutar_fases_de, [true(M-R == [numero(5), numero(5), numero(5)]-5)]) :-
    ejecutar_fases_de(mcd_fases, especifica, [numero(25), numero(10), numero(15)],
                      M, R).

:- end_tests(indices).
