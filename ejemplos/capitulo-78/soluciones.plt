:- encoding(utf8).

:- begin_tests(soluciones).

test(ejercicio_1, [true(M-C == [[1-2, 2-1], [1-2], [2-1]]-
                               [desconocida, desconocida, desconocida])]) :-
    conocer(4, [1-1-[brisa]], K),
    mundos_pozos(K, M),
    maplist(clasificar(K), [1-2, 2-2, 3-3], C).

test(ejercicio_1_probabilidad, [true(abs(P - 5 / 9) < 1.0e-9)]) :-
    conocer(4, [1-1-[brisa]], K),
    probabilidad_pozo(K, 1-2, P).

test(distancia, [true(D == 2)]) :-
    distancia(1, 3, D).

test(mayor_distancia, [true(D == 5)]) :-
    mayor_distancia(D).

test(estricta_jugador, [true(Ms == [ruta_invalida])]) :-
    nueva_partida(7, E),
    jugada_estricta(disparar([4, 5]), E, _, _, Ms).

test(estricta_ida_y_vuelta, [true(Ms == [ruta_invalida])]) :-
    nueva_partida(7, E),
    jugada_estricta(disparar([4, 14, 4]), E, _, _, Ms).

test(estricta_valida, [true(R == gana)]) :-
    nueva_partida(7, E),
    jugada_estricta(disparar([4, 3]), E, _, R, _).

test(final, [true(F == [1-4, 2-3, 3-1, 3-2])]) :-
    conocimiento_final(2, K),
    frontera(K, F).

test(reglas2, [true(R == r(192, 0))]) :-
    numlist(1, 20, Ss),
    comparar_reglas2(Ss, R).

test(dpll_sat, [true]) :-
    satisfacible([[+p, +q], [-p], [+r, -q]]).

test(dpll_unsat, [fail]) :-
    satisfacible([[+p, +q], [-p], [-q]]).

test(dpll, [true(S-D == 83-0)]) :-
    comparar_dpll([1, 2, 3, 4, 5], r(S, D, _)).

test(tamano, [true(M == mundo(5, [1-5, 2-3, 3-5, 4-1, 5-4], 4-2, 2-3))]) :-
    mundo_sembrado(5, 1, M).

% Con N = 4, los mundos son los de mundo_sembrado/2.
test(tamano_4, [true(M1 == M2)]) :-
    mundo_sembrado(4, 2, M1),
    mundo_sembrado(2, M2).

test(solubles, [true(N == 77)]) :-
    numlist(1, 100, Ss),
    contar_solubles(Ss, N).

test(caza_k, [true(R == [gana-11, pierde(pozo)-1])]) :-
    numlist(1, 12, Ss),
    medir_caza_k(1, Ss, R).

test(humano, [true(sub_string(S, _, _, _, "Tu puntaje es 992"))]) :-
    mundo(figura_7_2, M),
    setup_call_cleanup(
        open_string("ir 1 2\nir 2 2\nir 2 3\ntomar\nir 2 2\nir 1 2\nir 1 1\n\
salir\n", In),
        with_output_to(string(S), jugar_humano(In, M)),
        close(In)).

test(distancia_niveles, [true(D == 2)]) :-
    soluciones:distancia_([1], [1], 3, 0, D).

test(segura2) :-
    conocer(4, [1-1-[], 1-2-[], 1-3-[hedor], 2-2-[hedor]], K),
    soluciones:segura2(K, 1-4).

test(dos_hedores, [true(W == 2-3)]) :-
    conocer(4, [1-1-[], 1-2-[], 1-3-[hedor], 2-2-[hedor]], K),
    soluciones:dos_hedores(K, W).

test(asignar, [true(R == [[+c], [+d]])]) :-
    soluciones:asignar(+a, [[+a, +b], [-a, +c], [+d]], R).

test(alcanzable) :-
    soluciones:alcanzable(4, [2-1], [1-1], [1-1], 3-1).

test(no_alcanzable, [fail]) :-
    soluciones:alcanzable(4, [2-1, 1-2], [1-1], [1-1], 3-1).

% Una sola lectura, aunque la gramática deja una alternativa abierta.
test(accion_ir, [all(A == [ir(2-3)])]) :-
    phrase(soluciones:accion(A), `ir 2 3`).

test(accion_disparar, [true(A == disparar(norte))]) :-
    phrase(soluciones:accion(A), `disparar norte`).

test(accion_direccion_mala, [fail]) :-
    phrase(soluciones:accion(_), `disparar arriba`).

% En la partida traducida de la figura 7.2, la acción 10 es tomar.
test(tiene_oro, [true(Ts == [11, 12, 13, 14, 15, 16, 17, 18])]) :-
    mundo(figura_7_2, M),
    jugar(M, final(_, _, Plan)),
    traducir(Plan, p(1-1, este), As, _),
    historia(M, As, H),
    findall(T, ( between(0, 18, T), tiene_oro(H, T) ), Ts).

test(tomar_sin_brillo, [fail]) :-
    mundo(figura_7_2, M),
    historia(M, [tomar], H),
    tiene_oro(H, 1).

:- end_tests(soluciones).
