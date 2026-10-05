:- encoding(utf8).

:- begin_tests(bayes).

% Una causa segura: p(no arranca dado batería) = 1.
test(bateria, [true(P =:= 0.4)]) :-
    bayes(1.0, 0.02, 0.05, P).

test(pb_cero, [error(domain_error(_, _))]) :-
    bayes(1.0, 0.02, 0.0, _).

test(consistentes, [true(F == [])]) :-
    inconsistencias(0.3, 0.2, 0.75, 0.5, F).

test(desigualdad, [true(F == [1, igualdad])]) :-
    inconsistencias(0.1, 0.5, 0.6, 0.9, F).

test(condiciones, [true(L == [1, 2, 3, 4, igualdad])]) :-
    findall(F, condicion(F, 0, 0, 0, 0, 0, 0), L).

test(cumple) :-
    cumple(igualdad, 0, 0, 0, 0, 0.15, 0.15),
    \+ cumple(3, 0, 0.1, 0, 0, 0, 0.2).

% Sin observaciones, la posterior es la frecuencia.
test(sin_observaciones,
     [true(R == [pinguino-0.4, avestruz-0.2, cebra-0.15, guepardo-0.1,
                 tigre-0.1, jirafa-0.05])]) :-
    posterior([], 0.01, R).

test(manchas, [true(R == [guepardo-0.6306, jirafa-0.3153, pinguino-0.0255,
                          avestruz-0.0127, cebra-0.0096, tigre-0.0064])]) :-
    posterior([manchas_oscuras], 0.01, R).

test(cuello, [true(H-P == jirafa-0.9797)]) :-
    posterior([tiene_pelo, manchas_oscuras, cuello_largo], 0.01, [H-P|_]).

test(verosimilitud, [true(A-B =:= 0.99-0.01)]) :-
    verosimilitud(cebra, rayas_negras, 0.01, A),
    verosimilitud(cebra, nada, 0.01, B).

test(conjunta, [true(P =:= 0.1 * 0.99)]) :-
    conjunta([manchas_oscuras], 0.01, guepardo, P).

test(por_verosimilitud, [true(P =:= 0.5 * 0.99)]) :-
    por_verosimilitud(tigre, 0.01, rayas_negras, 0.5, P).

test(normalizar, [true(Q == 0.25)]) :-
    normalizar(4.0, a-1.0, a-Q).

:- end_tests(bayes).
