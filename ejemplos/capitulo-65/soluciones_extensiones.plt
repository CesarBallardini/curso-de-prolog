:- encoding(utf8).

:- begin_tests(soluciones_extensiones).

% Las dos versiones declaran libre el mismo bloque; la auxiliar necesita
% un ciclo más, para marcar.
test(comparar, [true(F == f(1, [b], 2, [b]))]) :-
    comparar_bloques([bloque(a), bloque(b), sobre(c, a), color(c, rojo)], F).

% Al quitar el color, la negación conjuntiva libera el bloque a; el hecho
% auxiliar rojo_encima(a) queda en la memoria y lo sigue bloqueando.
test(quitar,
     [true(I1-I2 == [instanciacion(libre, [1], 2,
                                   [agregar(libre_de_rojo(a))])]-[])]) :-
    H = [bloque(a), bloque(b), sobre(c, a), color(c, rojo)],
    despues_de_quitar(bloques, H, color(c, rojo), I1),
    despues_de_quitar(bloques_aux, H, color(c, rojo), I2).

test(libres, [true(L == [a, b])]) :-
    memoria_con([libre_de_rojo(b), libre_de_rojo(a)], M),
    libres(M, L).

test(de_libre) :-
    de_libre(instanciacion(libre, [], 1, [])),
    \+ de_libre(instanciacion(marcar, [], 1, [])).

test(despues_de_quitar_con, [true(Is == [])]) :-
    red_de(bloques_aux, Red),
    despues_de_quitar_con(Red, [bloque(a), sobre(c, a), color(c, rojo)],
                          sobre(c, a), Is).

test(familia, [forall(between(1, 6, I))]) :-
    familia(H),
    igual_sin_regla(familia, I, H).

test(configurador) :-
    pedido_ampliado(0, H),
    programa(configurador, Rs),
    length(Rs, N),
    forall(between(1, N, I), igual_sin_regla(configurador, I, H)).

% Quitar la única regla deja la red vacía, salvo la raíz.
test(quitar_regla, [true(A-B-Is == 0-0-[])]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], Red0),
    cargar(Red0, [p(a), q(a)], _, Rete0),
    quitar_regla(1, Red0, Rete0, Red, Rete),
    medidas_red(Red, A, B, _),
    conjunto_rete(Rete, Is).

test(de_regla) :-
    de_regla(2, (2-[-1])-x),
    \+ de_regla(1, (2-[-1])-x).

% Un nodo con hijos no se poda.
test(podar, [true(B == 2)]) :-
    compilar_red(pasos, [r :: [p(X), q(X)] ---> []], Red0),
    empty_assoc(M),
    podar(1, Red0-M, Red-_),
    medidas_red(Red, _, B, _).

test(alfas_del_tipo, [true(L == [[1], [2], [3, 4], []])]) :-
    findall(As, ( member(T, [union(1), negacion(2), negacion_conj([3, 4]),
                             prueba]),
                  alfas_del_tipo(T, As) ),
            L).

test(sin_sucesor, [true(S == [])]) :-
    compilar_red(pasos, [r :: [p(_)] ---> []], red(_, A0, _, _)),
    sin_sucesor(1, 1, A0, A),
    get_assoc(1, A, a(_, S)).

test(borrar_clave, [true(K == [b])]) :-
    list_to_assoc([a-1, b-2], T0),
    borrar_clave(a, T0, T1),
    borrar_clave(z, T1, T),
    assoc_to_keys(T, K).

test(podar_alfas, [true(N-I == 0-[])]) :-
    compilar_red(pasos, [r :: [p(_)] ---> []], red(I0, A0, B, T)),
    sin_sucesor(1, 1, A0, A1),
    empty_assoc(M),
    podar_alfas(red(I0, A1, B, T), M, red(I1, A, _, _), _),
    assoc_to_keys(A, Ks),
    length(Ks, N),
    assoc_to_list(I1, I).

:- end_tests(soluciones_extensiones).
