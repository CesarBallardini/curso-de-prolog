:- encoding(utf8).

:- begin_tests(cazador).

% Corriente en la sala 1: uno de los dos pozos está en 2, 5 u 8; son los
% pares de las 19 salas sin visitar menos los 16 * 15 / 2 que no tocan
% ninguna.
test(pozos, [true(L == 51)]) :-
    K = k(1, [1-[corriente]], [1-[corriente]], [], 5),
    mundos(K, corriente, 2, M),
    length(M, L).

test(wumpus, [true(W == [[2], [5], [8]])]) :-
    K = k(1, [1-[wumpus]], [1-[wumpus]], [], 5),
    mundos(K, wumpus, 1, W).

% Los murciélagos alzaron al agente en la sala 5: la otra sala con
% murciélagos no es vecina de 9, donde no los oyó.
test(murcielagos, [true(L-Todos == 15-si)]) :-
    K = k(9, [9-[]], [9-[]], [5], 5),
    mundos(K, murcielagos, 2, M),
    length(M, L),
    (   forall(member(Mu, M), memberchk(5, Mu))
    ->  Todos = si
    ;   Todos = no
    ).

% El agente pasó por la sala 5 antes de que el wumpus despertara: ahora
% el wumpus puede estar allí.
test(olvido, [true(W == [[2], [5], [8]])]) :-
    K = k(1, [5-[], 1-[wumpus]], [1-[wumpus]], [], 4),
    mundos(K, wumpus, 1, W).

test(cazar, [true(R-O == gana-[mover(1), mover(2), mover(1), mover(8),
                                mover(1), mover(5), mover(4),
                                disparar([3])])]) :-
    cazar(7, R, O).

test(narrar, [true(sub_string(S, _, _, _, "> d 3"))]) :-
    with_output_to(string(S), narrar(7)).

test(medir, [true(R == [gana-11, pierde(pozo)-1])]) :-
    numlist(1, 12, Ss),
    medir_caza(Ss, R).

:- end_tests(cazador).
