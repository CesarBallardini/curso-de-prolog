:- encoding(utf8).

:- begin_tests(anticipacion).

% Sin anticipación, cada cadena derrota a la otra.
test(sin_anticipacion, [true(R == sin_conclusion)]) :-
    respuesta([especificidad], paga(lucia), R).

test(con_anticipacion, [true(R == presumiblemente_no)]) :-
    respuesta([anticipacion, especificidad], paga(lucia), R).

% Con una sola cadena, la anticipación no cambia la respuesta.
test(una_cadena, [true(R-S == presumiblemente_no-presumiblemente_no)]) :-
    respuesta([especificidad], paga(marcos), R),
    respuesta([anticipacion, especificidad], paga(marcos), S).

test(rival_anticipado, [true(Rs-Ss == [Rival]-[])]) :-
    Rival = (paga(lucia) :~ inscripto(lucia)),
    Regla = (neg paga(lucia) :~ intercambio(lucia)),
    findall(R, rival([especificidad], raiz, Regla, R), Rs),
    findall(S, rival([anticipacion, especificidad], raiz, Regla, S), Ss).

test(cuesta_mas, [true(A > E)]) :-
    medir([especificidad], paga(lucia), E),
    medir([anticipacion, especificidad], paga(lucia), A).

:- end_tests(anticipacion).
