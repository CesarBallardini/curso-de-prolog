:- encoding(utf8).

:- begin_tests(circuito).

% En sentido inverso: las entradas que dan salida 1.
test(entradas_para_uno, all(X-Y == [0-1, 1-0])) :-
    circuito(X, Y, 1).

% La tabla completa es la de la disyunción exclusiva.
test(tabla, all(X-Y-Z == [0-0-0, 0-1-1, 1-0-1, 1-1-0])) :-
    circuito(X, Y, Z).

test(es_xor, true(T == 1)) :-
    es_xor(T).

% Con la misma salida, clpb da las mismas entradas que la tabla.
test(clpb_en_sentido_inverso, all(X-Y == [0-1, 1-0])) :-
    circuito_b(X, Y, 1),
    labeling([X, Y]).

% La salida no es la conjunción de las entradas: taut/2 no decide y falla.
test(no_es_and, [fail]) :-
    circuito_b(X, Y, Z),
    taut(Z =:= X * Y, _).

:- end_tests(circuito).
