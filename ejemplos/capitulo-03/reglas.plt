:- encoding(utf8).

:- begin_tests(reglas).

test(progenitores_de_ana, all(P == [juan, marta])) :-
    progenitor(P, ana).

test(nietos_de_juan, all(N == [luis, eva])) :-
    abuelo(juan, N).

test(nietos_de_marta, all(N == [luis, eva])) :-
    abuela(marta, N).

% marta es abuela, no abuelo: la regla de abuelo/2 pide varon/1.
test(marta_no_es_abuelo, [fail]) :-
    abuelo(marta, _).

% eva es madre de sofia, pero sofia no tiene hijos: no hay nieto.
test(eva_no_es_abuela, [fail]) :-
    abuela(eva, _).

:- end_tests(reglas).
