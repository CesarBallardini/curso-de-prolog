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

test(clausura_conjunto, [true(D == [s0, s1])]) :-
    clausura_conjunto(ciclo, [s0], D).

test(clausura_conjunto_vacio, [true(D == [])]) :-
    clausura_conjunto(ciclo, [], D).

% Sin transiciones ε, la clausura es el conjunto ordenado y sin repetir.
test(clausura_conjunto_repetidos, [true(D == [q0, q1])]) :-
    clausura_conjunto(termina_ab, [q1, q0, q1], D).

test(lee, set(W-Q == [[a, a]-s0, [a, a]-s1, [a, b]-s2])) :-
    length(W, 2),
    automatas:lee(ciclo, s0, W, Q).

test(alcanzable, set(Q == [s0, s1, s2])) :-
    alcanzable(ciclo, Q).

test(numero_estados, [true(N == 3)]) :-
    numero_estados(multiplo3, N).

test(palabra_vacia, [true(Ws == [[]])]) :-
    palabras(multiplo3, 0, Ws).

test(sin_palabras, [true(Ws == [])]) :-
    palabras(termina_ab, 1, Ws).

% Un símbolo fuera del alfabeto no tiene transición.
test(fuera_del_alfabeto, [fail]) :-
    acepta(termina_ab, [a, c, b]).

test(anchura, [true(O == [r0, r1, r2])]) :-
    automatas:anchura([r0], multiplo3, [r0], O).

test(anchura_vacia, [true(O == [])]) :-
    automatas:anchura([], multiplo3, [], O).

test(nuevos, [true(N-V == [a, b]-[b, a, c])]) :-
    automatas:nuevos([a, b, a, c], [c], N, V).

:- end_tests(automatas).
