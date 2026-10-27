:- encoding(utf8).

:- use_module(dudoso, []).

:- begin_tests(condicional).

test(libre_a, [true(P == si(libre(a), [], [mover(c, a, mesa)]))]) :-
    planificar_casos(dudoso, [c_sobre_a, c_sobre_b], [libre(a)], 4, P).

test(sussman, [true(P == si(libre(a),
                            [mover(c, b, mesa), mover(b, mesa, c),
                             mover(a, mesa, b)],
                            [mover(c, a, mesa), mover(b, mesa, c),
                             mover(a, mesa, b)]))]) :-
    planificar_casos(dudoso, [c_sobre_a, c_sobre_b],
                     [sobre(a, b), sobre(b, c)], 6, P).

% Un plan que sirve en los dos estados no necesita examinar nada.
test(sin_rama, [true(P == [])]) :-
    planificar_casos(dudoso, [c_sobre_a, c_sobre_b], [libre(c)], 4, P).

test(un_solo_caso, [true(P == [mover(c, a, mesa)])]) :-
    planificar_casos(dudoso, [c_sobre_a], [sobre(c, mesa)], 4, P).

test(ejecutar, [true(As == [mover(c, b, mesa)])]) :-
    planificar_casos(dudoso, [c_sobre_a, c_sobre_b], [sobre(c, mesa)], 4, P),
    ejecutar_casos(dudoso, c_sobre_b, P, As).

test(cada_rama_logra, [true]) :-
    Metas = [sobre(a, b), sobre(b, c)],
    planificar_casos(dudoso, [c_sobre_a, c_sobre_b], Metas, 6, P),
    forall(member(I, [c_sobre_a, c_sobre_b]),
           ( ejecutar_casos(dudoso, I, P, As),
             regresion:logra(dudoso, I, As, Metas) )).

test(distinguidor, [true(H == libre(a))]) :-
    condicional:distinguidor(dudoso, [c_sobre_a, c_sobre_b], H).

test(sin_distinguidor, [fail]) :-
    condicional:distinguidor(dudoso, [c_sobre_a, sussman], _).

test(vale_al_inicio) :-
    condicional:vale_al_inicio(dudoso, sobre(c, b), c_sobre_b).

test(sin_plan, [fail]) :-
    planificar_casos(dudoso, [c_sobre_a, c_sobre_b],
                     [sobre(a, b), sobre(a, c)], 4, _).

:- end_tests(condicional).
