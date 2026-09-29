:- encoding(utf8).

:- begin_tests(compartidos).

test(tres_discos, [true(K-Ms == 6-[a-c, a-b, c-b, a-c, b-a, b-c, a-c])]) :-
    compartido(hanoi, torre(3, a, c), A, K),
    movimientos(A, Ms).

% Para N discos se expanden 3N - 3 nodos distintos, y el árbol tiene
% 2^N - 1 movimientos.
test(expandidos, [true(Rs == [5-12-31, 10-27-1023, 20-57-1048575])]) :-
    findall(N-K-C,
            ( member(N, [5, 10, 20]),
              compartido(hanoi, torre(N, a, c), A, K),
              costo(A, C) ),
            Rs).

test(uno, [true(K == 1)]) :-
    compartido(hanoi, torre(1, b, a), _, K).

test(sin_solucion, [fail]) :-
    compartido(hanoi, torre(-1, a, c), _, _).

test(torres, [true(R == [profundidad-1023-1023, compartido-1023-27])]) :-
    findall(B-M-K,
            ( member(B, [profundidad, compartido]),
              torres(B, 10, M, K) ),
            R).

test(plan_torres, [true(Ms == [a-c])]) :-
    plan_torres(1, Ms).

:- end_tests(compartidos).
