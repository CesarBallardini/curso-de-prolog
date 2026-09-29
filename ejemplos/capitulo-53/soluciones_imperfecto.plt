:- encoding(utf8).

:- begin_tests(soluciones_imperfecto).

test(contabamos, [true(Ps == ["contábamos"])]) :-
    findall(P, forma(P, verbo("contar", imperfecto, 1, plural)), Ps).

test(seguia, [true(Ps == ["seguía"])]) :-
    findall(P, forma(P, verbo("seguir", imperfecto, 3, singular)), Ps).

test(eramos, [true(Ps == ["éramos"])]) :-
    findall(P, forma(P, verbo("ser", imperfecto, 1, plural)), Ps).

% La primera y la tercera persona del singular son la misma forma.
test(hacia, [true(As == [verbo("hacer", imperfecto, 1, singular),
                         verbo("hacer", imperfecto, 3, singular)])]) :-
    findall(A, forma("hacía", A), As0),
    sort(As0, As).

test(version_2, [true(P == "contábamos")]) :-
    once(reglas:forma(P, verbo("contar", imperfecto, 1, plural))).

:- end_tests(soluciones_imperfecto).
