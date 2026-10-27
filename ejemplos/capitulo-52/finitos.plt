:- encoding(utf8).

:- begin_tests(finitos).

test(multiplo3, [nondet]) :-
    acepta(multiplo3, [1, 1, 0]).

test(no_multiplo3, [fail]) :-
    acepta(multiplo3, [1, 1, 1]).

% Las palabras de tres bits que acepta son 0, 3 y 6.
test(generar, [true(Ws == [[0, 0, 0], [0, 1, 1], [1, 1, 0]])]) :-
    findall(W, ( length(W, 3), acepta(multiplo3, W) ), Ws).

% Cada número de 0 a 30 es aceptado si y solo si es múltiplo de 3.
test(todos) :-
    forall(between(0, 30, N),
           ( format(atom(A), '~2r', [N]),
             atom_chars(A, Cs),
             maplist([C, B]>>atom_number(C, B), Cs, Bits),
             (   acepta(multiplo3, Bits)
             ->  N mod 3 =:= 0
             ;   N mod 3 =\= 0
             ) )).

test(termina_ab, [nondet]) :-
    acepta(termina_ab, [a, b, a, b]).

test(no_termina_ab, [fail]) :-
    acepta(termina_ab, [a, b, a]).

test(ciclo_acepta, [nondet]) :-
    acepta(ciclo, [a, a, b]).

% Con el ciclo ε, rechazar una palabra no termina.
test(ciclo_no_termina, [true(R == inference_limit_exceeded)]) :-
    call_with_inference_limit(acepta(ciclo, [a]), 100000, R).

% Y una palabra aceptada tiene infinitas demostraciones.
test(ciclo_demostraciones, [true(N == 5)]) :-
    aggregate_all(count, limit(5, acepta(ciclo, [a, b])), N).

:- end_tests(finitos).
