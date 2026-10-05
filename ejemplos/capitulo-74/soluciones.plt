:- encoding(utf8).

:- begin_tests(soluciones).

test(ejercicio_1, [true(Ns == [2, 4, 0])]) :-
    orden([r, r], A),
    orden([r, l], B),
    cambiadas([r, l, -r, -l], C),
    Ns = [A, B, C].

test(medio_cuatro_veces, [nondet]) :-
    forall(giro_medio(E, _, _),
           ( resuelto(C),
             giro_medio(E, C, C1), giro_medio(E, C1, C2),
             giro_medio(E, C2, C3), giro_medio(E, C3, C4),
             C4 == C )).

test(cara_medio_opuesta, [true(C3 \== C)]) :-
    resuelto(C),
    giro(u, C, C1),
    giro_medio(u, C1, C2),
    mover(-d, C2, C3),
    caras_uniformes(C3).

test(rotacion_igual, [true(R == C3)]) :-
    resuelto(C),
    giro(u, C, C1),
    giro_medio(u, C1, C2),
    mover(-d, C2, C3),
    rotacion(u, C, R).

test(repeticion, [true(Ms == [-r, -d, r, d, -r, -d, r, d, u])]) :-
    leer_notacion_rep("(R' D' R D)2 U", Ms).

test(repeticion_igual_macro, [true(Ms == Ms1)]) :-
    leer_notacion_rep("(R' D' R D)2", Ms),
    texto_macro(giro_esquina, T),
    leer_notacion(T, Ms1).

test(tipo_efecto, [true(E-A == 4-3)]) :-
    tipo_efecto("R U R' U'", E, A).

test(etapa_3_no_toca_abajo, [true(Ts == [])]) :-
    findall(T, ( familia(3, T), capa_de_abajo_movida(T) ), Ts).

test(leer_red, [true(Mal == [])]) :-
    resuelto(C),
    findall(S, ( between(1, 20, S),
                 mezcla(S, 25, M),
                 aplicar(M, C, C1),
                 red(C1, L),
                 \+ ( leer_red(L, C2), C2 == C1 ) ), Mal).

test(red_color, [true(L == "      \e[47m  \e[47m  \e[47m  \e[0m")]) :-
    resuelto(C),
    red_color(C, [L|_]).

test(orientar_es_conjugar, [true(Ts == [])]) :-
    findall(T, ( familia(_, T),
                 leer_notacion(T, Ms),
                 \+ orientar_es_conjugar(Ms) ), Ts).

test(podado_resuelve, [true(C2 == C)]) :-
    mezcla(3, 25, M),
    resuelto(C),
    aplicar(M, C, C1),
    resolver_con(colocar_podado, C1, Pasos),
    giros(Pasos, G),
    aplicar(G, C1, C2).

test(aristas, [true(P-N == 2664-0)]) :-
    aristas_descubiertas(P, N).

test(aprender, [true(A-G == 21-1848)]) :-
    aprender(10, A, G, _).

test(tres_capas, [nondet]) :-
    tres_capas(u, d),
    tres_capas(r, l),
    tres_capas(f, b).

test(poda_mismo_largo, [true(L1 == L2)]) :-
    mezcla(4, 25, M),
    resuelto(C),
    aplicar(M, C, C1),
    resolver_con(colocar_sin_poda, C1, P1),
    resolver_con(colocar_podado, C1, P2),
    giros(P1, G1), giros(P2, G2),
    length(G1, L1), length(G2, L2).

% La capa de afuera de U es el giro de U; la del medio, giro_medio/3.
test(capa_calculada_cara, [true(A-D =@= A1-D1)]) :-
    capa_calculada(u, [1], A, D),
    giro(u, A1, D1).

test(capa_calculada_medio, [true(A-D =@= A1-D1)]) :-
    capa_calculada(r, [0], A, D),
    giro_medio(r, A1, D1).

test(destino_capa_igual_destino, all(I == [])) :-
    between(1, 54, I),
    destino_capa(f, 1, I, J1),
    destino(f, I, J2),
    J1 \== J2.

test(destino_capas_fuera, [nondet, true(J == 5)]) :-
    destino_capas(u, [0], 5, J).

% Conjugar la secuencia vacía da la identidad.
test(conjugada_identidad, [true(A == D)]) :-
    conjugada_por_rotacion([], A, D).

test(fila_color, [true(F == "\e[47m  \e[47m  \e[47m  \e[0m")]) :-
    resuelto(C),
    fila_color(C, u, 0, F).

test(mostrar_color, [true(N == 9)]) :-
    resuelto(C),
    with_output_to(string(S), mostrar_color(C)),
    split_string(S, "\n", "", L0),
    exclude(==(""), L0, L),
    length(L, N).

test(leer_linea, [true(F-A1-A3 == 1-u-u)]) :-
    functor(K, c, 54),
    leer_linea(K, "U U U", 0, F),
    arg(1, K, A1),
    arg(3, K, A3),
    arg(4, K, A4),
    var(A4).

test(leer_linea_corta, [fail]) :-
    functor(K, c, 54),
    leer_linea(K, "U U", 0, _).

test(grupos, [true(Ms == [r, u, r, u, -f])]) :-
    phrase(grupos(Ms), `(R U)2 F'`).

test(grupo_sin_cierre, [fail]) :-
    phrase(grupo(_), `(R U`).

test(veces, [true(N1-N2 == 3-1)]) :-
    phrase(veces(N1), `3`),
    phrase(veces(N2), ``).

test(solo_u, [true]) :-
    solo_u([u, -u]).

test(solo_u_no, [fail]) :-
    solo_u([u, r]).

test(podada_poda, [fail]) :-
    resuelto(C),
    podada([[u], [u]], si, 4, no, C, _).

test(podada_sin_poda, [nondet, true(X == C2)]) :-
    resuelto(C),
    podada([[u], [u]], no, 4, no, C, X),
    mover(u, C, C1),
    mover(u, C1, C2).

test(colocar_podado, [true(M == [-u])]) :-
    resuelto(C),
    mover(u, C, C1),
    colocar_podado(4, C1, C, M, _).

test(colocar_sin_poda, [true(M == [-u])]) :-
    resuelto(C),
    mover(u, C, C1),
    colocar_sin_poda(4, C1, C, M, _).

test(colocar_propio_resuelto, [true(M == [])]) :-
    resuelto(C),
    colocar_propio(si, 4, C, C, M, _).

% Una secuencia de dos candidatos no se aprende.
test(colocar_aprendiendo, [true(M-N == [-u, -r]-0)]) :-
    retractall(aprendido(_, _, _, _)),
    resuelto(C),
    mover(r, C, C1),
    mover(u, C1, C2),
    colocar_aprendiendo(1, C2, C, M, _),
    aggregate_all(count, aprendido(_, _, _, _), N).

test(por_etapa, [true(T == [1-media(10.5)-maximo(12), 2-media(34)-maximo(43),
                            3-media(44)-maximo(50), 4-media(17.5)-maximo(29),
                            5-media(56)-maximo(84)])]) :-
    por_etapa(2, T).

:- end_tests(soluciones).
