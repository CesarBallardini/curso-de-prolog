:- encoding(utf8).

:- begin_tests(utilidades).

test(diccionario, [true(D == [pacifista/1])]) :-
    diccionario(D).

% Una respuesta por individuo del que la base dice algo.
test(nixon, [true(P == [pacifista(nixon)-sin_conclusion,
                        pacifista(penn)-presumiblemente_si,
                        pacifista(reagan)-presumiblemente_no])]) :-
    respuestas([especificidad], pacifista(_), P).

test(contradicciones, [true(C == [mamifero(bruno)])]) :-
    contradicciones(C).

test(contradiccion, [true(R == contradiccion)]) :-
    respuesta([], mamifero(bruno), R).

test(complemento_positivo, [true(A-B == p(x)-p(x))]) :-
    complemento_positivo(neg p(x), A),
    complemento_positivo(p(x), B).

test(candidato, [true(L == [pacifista(nixon), pacifista(penn),
                            pacifista(reagan)])]) :-
    findall(X, ( X = pacifista(_), candidato([], X) ), L0),
    sort(L0, L).

test(evidencia, [nondet]) :-
    evidencia([], pacifista(penn)),
    evidencia([], neg pacifista(reagan)).

test(sin_evidencia, [fail]) :-
    evidencia([], pacifista(reagan)).

% contrario_estricto/1, interno del intérprete: un contrario de la meta se
% deriva en forma estricta.
test(contrario_estricto) :-
    rebatible:contrario_estricto(mamifero(bruno)),
    \+ rebatible:contrario_estricto(pacifista(penn)).

:- end_tests(utilidades).
