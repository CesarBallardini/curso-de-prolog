:- encoding(utf8).

:- use_module(library(lists)).

:- begin_tests(incorporar).

test(olvidar, [true(Rs == [])]) :-
    recorrer(taza, _),
    olvidar(taza),
    aprendidas(taza, Rs).

test(recorrer, [true(U == [regla-2, teoria-2, no-44])]) :-
    recorrer(taza, U).

test(aprendidas, [true(N == 2)]) :-
    recorrer(taza, _),
    aprendidas(taza, Rs),
    length(Rs, N).

% La primera taza se explica con la teoría; la misma, otra vez, con la
% regla aprendida.
test(reconocer, [true(C1-C2 == teoria-regla)]) :-
    olvidar(taza),
    teorias:hechos(taza1, Hs),
    reconocer(taza, taza1-Hs, C1),
    reconocer(taza, taza1-Hs, C2).

test(reconocer_no, [true(C == no)]) :-
    olvidar(taza),
    teorias:hechos(vaso1, Hs),
    reconocer(taza, vaso1-Hs, C).

% Una taza que es liviana por el material no la reconoce la regla
% aprendida de una que es liviana por el peso.
test(reconocer_razon_nueva, [true(C == teoria)]) :-
    olvidar(taza),
    teorias:hechos(taza1, H1),
    reconocer(taza, taza1-H1, _),
    teorias:hechos(taza2, H2),
    reconocer(taza, taza2-H2, C).

:- end_tests(incorporar).
