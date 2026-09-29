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

:- end_tests(soluciones).
