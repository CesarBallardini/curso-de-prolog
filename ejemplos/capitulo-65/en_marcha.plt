:- encoding(utf8).

:- begin_tests(en_marcha).

% Agregar la última regla después de cargar da el mismo conjunto, en el
% mismo orden, que compilarla antes.
test(familia) :-
    familia(H),
    con_regla_nueva(familia, H, Is),
    reconocer_rete(familia, H, Is0),
    Is =@= Is0.

test(cualquier_regla, [forall(member(P-H,
        [cajas-[meta(apilar([a, b, c])), sobre(a, piso), sobre(b, piso),
                sobre(c, a), meta(despejar(a))],
         mcd-[numero(9), numero(6)]]))]) :-
    igual_con_cualquier_tardia(P, H).

test(familia_cualquier_regla) :-
    familia(H),
    igual_con_cualquier_tardia(familia, H).

test(configurador) :-
    pedido_ampliado(0, H),
    igual_con_cualquier_tardia(configurador, H).

% Una regla cuyo prefijo ya está en la red no crea nodos beta: cuelga del
% nodo que existía, y sus instanciaciones salen de los tokens de ese nodo.
test(sin_nodos_nuevos,
     [true(Is == [instanciacion(r1, [1], 1, []),
                  instanciacion(r2, [1], 1, [agregar(b)])])]) :-
    compilar_red(pasos, [r1 :: [p(_)] ---> []], Red0),
    cargar(Red0, [p(a)], M, R0),
    agregar_regla(r2 :: [p(_)] ---> [agregar(b)], M, Red0, R0, Red, R),
    conjunto_rete(R, Is),
    medidas_red(Red, 1, 1, _).

test(con_regla_tardia, [true(N == 2)]) :-
    con_regla_tardia(familia, 1, [padre(juan, ana), padre(ana, sofia)], Is),
    length(Is, N).

test(nuevas_claves, [true(L == [3, 4])]) :-
    list_to_assoc([1-a, 2-b], A),
    list_to_assoc([1-a, 2-b, 3-c, 4-d], B),
    nuevas_claves(A, B, L).

test(clave_de) :-
    list_to_assoc([1-a], A),
    clave_de(A, 1),
    \+ clave_de(A, 2).

% llenar_alfa/5 pone en el nodo nuevo los hechos que acepta.
test(llenar_alfa, [true(E == [1-q(a)])]) :-
    compilar_red(pasos, [r1 :: [p(_)] ---> []], Red0),
    cargar(Red0, [q(a), p(b)], M, R0),
    compilar_regla(pasos, r2 :: [q(_)] ---> [], Red0-2, Red-_),
    llenar_alfa(Red, M, 2, R0, rete(Alfas, _, _)),
    get_assoc(2, Alfas, Memoria),
    assoc_to_values(Memoria, [[S-alfa(H, [])]]),
    E = [S-H].

test(llenar_con, [true(L == [[7-alfa(p(b), [])]])]) :-
    compilar_red(pasos, [r1 :: [p(_)] ---> []], red(_, Alfas, _, _)),
    empty_assoc(V),
    list_to_assoc([1-V], M0),
    llenar_con(Alfas, 1, 7-p(b), M0, M),
    get_assoc(1, M, Memoria),
    assoc_to_values(Memoria, L).

test(con_padre_viejo) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], red(_, _, Betas, _)),
    con_padre_viejo(Betas, [1, 2], 1),
    \+ con_padre_viejo(Betas, [1, 2], 2).

% Con las memorias beta borradas, llenar_beta/4 desde el nodo 1 las
% reconstruye hasta la regla.
test(llenar_beta, [true([N1, N2, N3] == [1, 1, 1])]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], Red),
    cargar(Red, [p(a), q(a)], _, rete(A, B0, _)),
    del_assoc(1, B0, _, B1),
    del_assoc(2, B1, _, B),
    empty_assoc(C),
    llenar_beta(Red, 1, rete(A, B, C), R),
    tokens(1, R, T1), length(T1, N1),
    tokens(2, R, T2), length(T2, N2),
    conjunto_rete(R, Is), length(Is, N3).

% activar_con/5 une el token de la raíz con los hechos de la memoria alfa.
test(activar_con, [true(T == [[1]-[alfa(p(a), [])]])]) :-
    compilar_red(pasos, [r :: [p(_)] ---> []], Red),
    cargar(Red, [p(a)], _, rete(A, B0, C)),
    del_assoc(1, B0, _, B),
    activar_con(Red, 1, []-[], rete(A, B, C), R),
    tokens(1, R, T).

test(colgar_regla, [true(N == 2)]) :-
    compilar_red(pasos, [r1 :: [p(_)] ---> [], r2 :: [p(_)] ---> []], Red),
    cargar(Red, [p(a)], _, rete(A, B, _)),
    empty_assoc(V),
    colgar_regla(Red, 2, rete(A, B, V), R),
    colgar_regla(Red, 1, R, R2),
    conjunto_rete(R2, Is),
    length(Is, N).

test(terminal_de, [true(Is == [instanciacion(r, [1], 1, [])])]) :-
    compilar_red(pasos, [r :: [p(_)] ---> []], Red),
    rete_vacio(Red, R0),
    terminal_de(Red, 1, [1]-[alfa(p(a), [])], R0, R),
    conjunto_rete(R, Is).

:- end_tests(en_marcha).
