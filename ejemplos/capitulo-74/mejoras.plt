:- encoding(utf8).

:- begin_tests(mejoras).

test(cancelar, [true(Ms == [-f])]) :-
    simplificar([r, u, -u, -r, f, f, f], Ms).

test(media_vuelta, [true(Ms == [r, r, u])]) :-
    simplificar([-r, -r, u], Ms).

test(vacia, [true(Ms == [])]) :-
    simplificar([u, u, u, u], Ms).

test(sin_cambios, [true(Ms == [r, u, -r])]) :-
    simplificar([r, u, -r], Ms).

test(mismo_efecto, [true(C1 == C2)]) :-
    mezcla(5, 30, Ms0),
    append(Ms0, [u, -u, r, r, r, r], Ms),
    simplificar(Ms, S),
    resuelto(C),
    aplicar(Ms, C, C1),
    aplicar(S, C, C2).

test(cercana_resuelve, [true(C2 == C)]) :-
    mezcla(7, 20, Ms),
    resuelto(C),
    aplicar(Ms, C, C1),
    resolver_cercana(C1, Pasos),
    giros(Pasos, G),
    aplicar(G, C1, C2).

test(cercana_mas_corta, [true(N2 < N1)]) :-
    resuelto(C),
    findall(L1-L2,
            ( between(1, 10, S),
              mezcla(S, 25, Ms),
              aplicar(Ms, C, C1),
              resolver(C1, P1),
              giros(P1, G1),
              length(G1, L1),
              resolver_cercana(C1, P2),
              giros(P2, G2),
              simplificar(G2, S2),
              length(S2, L2) ),
            Pares),
    pairs_keys_values(Pares, L1s, L2s),
    sum_list(L1s, N1),
    sum_list(L2s, N2).

test(sesion, [true(Ultima == "Total: 118 cuartos de vuelta. El cubo queda \
resuelto.")]) :-
    with_output_to(string(S), sesion(7, 20)),
    split_string(S, "\n", "", Lineas),
    reverse(Lineas, ["", Ultima|_]).

test(largo, [true(N == 195)]) :-
    largo(etapas, 7, N).

test(medir, [true(M-X == 146.1-195)]) :-
    medir(cercana_simplificada, 20, M, X).

:- end_tests(mejoras).
