:- encoding(utf8).

:- begin_tests(automatas).

test(clausura, [true(Qs == [s0, s1])]) :-
    findall(Q, clausura(ciclo, s0, Q), Qs0),
    msort(Qs0, Qs).

test(acepta_ciclo) :-
    acepta(ciclo, [a, a, b]).

test(rechaza_ciclo, [fail]) :-
    acepta(ciclo, [a]).

% Una sola demostración: la clausura tabulada no repite estados.
test(reconoce, [true(N == 1)]) :-
    aggregate_all(count, reconoce(ciclo, [a, b]), N).

test(palabras, [true(Ws == [[a, a, b], [b, a, b]])]) :-
    palabras(termina_ab, 3, Ws).

test(palabras_ciclo, [true(Ws == [[a, a, b]])]) :-
    palabras(ciclo, 3, Ws).

test(mover, [true(D == [q0, q1])]) :-
    mover(termina_ab, a, [q0], D).

test(mover_vacio, [true(D == [])]) :-
    mover(termina_ab, a, [q2], D).

test(estados, [true(Qs == [s0, s1, s2])]) :-
    estados(ciclo, Qs).

test(tabla, [true(T == automata(3, [0], [0-0-0, 0-1-1, 1-0-2, 1-1-0,
                                         2-0-1, 2-1-2]))]) :-
    tabla(multiplo3, T).

% acepta/2 y reconoce/2 coinciden en todas las palabras de longitud 4.
test(acepta_reconoce) :-
    forall(( length(W, 4), maplist([S]>>member(S, [a, b]), W) ),
           (   acepta(termina_ab, W)
           ->  once(reconoce(termina_ab, W))
           ;   \+ reconoce(termina_ab, W)
           )).

:- end_tests(automatas).
