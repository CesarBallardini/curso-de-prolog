:- encoding(utf8).

:- begin_tests(certeza).

test(balance, [true(L == [independiente-(-0.0849)-(-0.442),
                          conservador-(-0.2)-(-0.5),
                          liberal-0.3-(-0.3)])]) :-
    atardecer(O),
    findall(M-B-C,
            ( member(M, [independiente, conservador, liberal]),
              balance(guepardo, O, M, B),
              balance(tigre, O, M, C) ),
            L).

test(contra, [true(P == 0.27)]) :-
    atardecer(O),
    contra(guepardo, O, independiente, P).

test(sin_contra, [true(P == 0.0)]) :-
    contra(jirafa, [manchas_oscuras-1.0], independiente, P).

% El umbral deja afuera primero la evidencia débil en contra y después la
% regla a favor.
test(umbrales, [true(L == [0.2-[0.2822, -0.3699],
                           0.4-[0.476, -0.54],
                           0.6-[0.0, -0.54]])]) :-
    atardecer(O),
    findall(U-[G, T],
            ( member(U, [0.2, 0.4, 0.6]),
              factor(guepardo, O, U, G),
              factor(tigre, O, U, T) ),
            L).

test(aportes, [true(L == [0.476, -0.27])]) :-
    atardecer(O),
    findall(A, aporte(guepardo, O, 0.2, A), L0),
    maplist([X, Y]>>(Y is round(X * 10000) / 10000.0), L0, L).

test(premisa, [true(P =:= 0.6)]) :-
    atardecer(O),
    premisa(color_leonado y manchas_oscuras, O, 0.2, P).

test(premisa_falta, [fail]) :-
    premisa(nada, [], 0.2, _).

test(premisa_comparacion, [true(P =:= 1.0)]) :-
    premisa(90 > 50, [], 0.2, P).

test(cf_combinar, [true(L == [0.75, -0.75, 0.0])]) :-
    cf_combinar(0.5, 0.5, A),
    cf_combinar(-0.5, -0.5, B),
    cf_combinar(0.5, -0.5, C),
    L = [A, B, C].

test(cf_signos, [true(abs(Z - 2 / 3) < 1.0e-9)]) :-
    cf_combinar(0.8, -0.4, Z).

% Dos certezas opuestas no se pueden combinar.
test(cf_opuestos, [error(evaluation_error(_))]) :-
    cf_combinar(1.0, -1.0, _).

test(tabla_balance, [true(F == [f(independiente, -0.0849, -0.442),
                                 f(conservador, -0.2, -0.5),
                                 f(liberal, 0.3, -0.3)])]) :-
    tabla_balance(F).

test(tabla_factor, [true(F == [f(0.2, 0.2822, -0.3699),
                               f(0.6, 0.0, -0.54)])]) :-
    tabla_factor([0.2, 0.6], F).

:- end_tests(certeza).
