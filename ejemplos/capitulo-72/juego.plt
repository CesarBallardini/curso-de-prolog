:- encoding(utf8).

:- begin_tests(juego).

posicion(pos([x,o,v, v,x,v, v,v,o], x)).

test(plan, [true(P == jugar(4, [3-jugar(6, gana), 6-jugar(7, gana),
                                7-jugar(6, gana), 8-jugar(6, gana)]))]) :-
    posicion(P0),
    resolver(gana(tateti(3), x), mueve(P0), A, _),
    plan(A, P).

test(primitivo) :-
    primitivo(gana(tateti(3), x), responde(pos([x,x,x, o,o,v, v,v,v], o))).

test(final_sin_expansion, [fail]) :-
    expansion(gana(tateti(3), o), mueve(pos([x,x,x, o,o,v, v,v,v], o)), _,
              _).

% Después de x en la esquina y o al lado, x gana: la estrategia en
% profundidad tiene 61 jugadas; la de mejor primero, 21.
test(tamanos, [true(R == 170-61-102-61-73-21)]) :-
    P0 = pos([x,o,v, v,v,v, v,v,v], x),
    G = gana(tateti(3), x),
    resolver(G, mueve(P0), A1, K1),
    costo(A1, C1),
    compartido(G, mueve(P0), A2, K2),
    costo(A2, C2),
    mejor(G, mueve(P0), _, C3, K3),
    R = K1-C1-K2-C2-K3-C3.

% Desde el tablero vacío x no tiene estrategia ganadora.
test(vacio, [true(R1-K1-R2-K2 == no-9689-no-1878)]) :-
    V = pos([v,v,v, v,v,v, v,v,v], x),
    G = gana(tateti(3), x),
    profundidad(G, mueve(V), [], R1, 0, K1),
    empty_assoc(M),
    recordado(G, mueve(V), R2, m(M, 0), m(_, K2)).

test(estrategia, [true(R-K == jugadas(9, jugar(4, [3-jugar(6, gana),
                                                    6-jugar(7, gana),
                                                    7-jugar(6, gana),
                                                    8-jugar(6, gana)]))-13)]) :-
    estrategia(mejor, [x,o,v, v,x,v, v,v,o], R, K).

test(ninguna, [true(Rs == [profundidad-9689, compartido-1878, mejor-5165])]) :-
    findall(B-K,
            ( member(B, [profundidad, compartido, mejor]),
              estrategia(B, [v,v,v, v,v,v, v,v,v], ninguna, K) ),
            Rs).

test(estimacion, [true(H1-H2 == 1-2)]) :-
    estimacion(gana(tateti(3), x), mueve(_), H1),
    estimacion(gana(tateti(3), x), responde(_), H2).

:- end_tests(juego).
