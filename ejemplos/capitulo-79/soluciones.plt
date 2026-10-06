:- encoding(utf8).

:- use_module(consejos).
:- use_module(busqueda).
:- use_module(verificar).
:- use_module(finales).
:- use_module(reglas).

:- begin_tests(soluciones, [setup(calcular)]).

% Ejercicio 4: el consejo sin restricciones y la búsqueda de la versión 2
% eligen la misma primera jugada.
test(ciega, [forall(member(P, [pos(blancas, 2-3, 4-2, 2-1),
                               pos(blancas, 1-3, 1-4, 2-1),
                               pos(blancas, 1-3, 4-2, 2-1)])),
             true(J1 == J2)]) :-
    satisfacible(ciega, mate_en_3, P, juega(J1, _)),
    mate_forzado(P, 3, J2).

test(por_que, [true(Ls == ["regla borde",
                            "  mate_en_2: no satisfacible",
                            "  encierro: no satisfacible",
                            "  acercamiento: no satisfacible",
                            "  mantener_espacio: satisfacible, juega Rb3",
                            ""])]) :-
    with_output_to(string(S), por_que(krk, pos(blancas, 1-3, 2-2, 1-1))),
    split_string(S, "\n", "", Ls).

test(azar_legal) :-
    P = pos(negras, 5-5, 3-6, 4-8),
    azar(7, P, J),
    once(jugada(P, J, _)).

test(azar_repetible, [true(J1 == J2)]) :-
    P = pos(negras, 5-5, 3-6, 4-8),
    azar(7, P, J1),
    azar(7, P, J2).

test(historia, [true(H == [dividir_en_2, encierro, encierro, acercamiento,
                           acercamiento, encierro, mate_en_2])]) :-
    historia(krk, resistente, pos(blancas, 5-5, 1-1, 4-7), H).

test(cuantas, [true(K-N-Total == 12-3135-27352)]) :-
    cuantas(Pares),
    pairs_values(Pares, Ns),
    sum_list(Ns, Total),
    max_member(N, Ns),
    memberchk(K-N, Pares).

% Ejercicio 9: sin no torre_expuesta, ningún árbol pierde la torre.
test(sin_cuidado_no_pierde, [true(N == 0)]) :-
    posiciones(blancas, Ps),
    aggregate_all(count,
                  ( member(P, Ps),
                    P = pos(_, _, _, 1-1),
                    salidas(sin_cuidado, P, S),
                    memberchk(_-falla(torre_perdida), S) ),
                  N).

% Ejercicio 11: la otra corrección también asegura las posiciones del
% ahogado.
test(meta_mejor, [forall(member(P, [pos(blancas, 1-3, 2-2, 1-1),
                                    pos(blancas, 7-5, 7-1, 7-8)])),
                  true(A == T)]) :-
    verificar_desde(meta_mejor, P, r(A, T, _)).

test(sin_memoria, [true(R == r(25580, 27352, 32))]) :-
    politica_sin_memoria(corregida, R).

:- end_tests(soluciones).
