:- encoding(utf8).

:- begin_tests(funcional).

test(lam, [true(V == [1, 4, 9])]) :-
    lam("map (fun x -> x * x) [1, 2, 3]", V).

test(definiciones, [true(V == 18)]) :-
    lam("f 10", "f n = suma (filtrar (fun x -> mod x 3 = 0) (hasta 1 n))",
        V).

test(limite, [true(C == limite)]) :-
    inferencias(estricto, "tomar 5 (desde 1)", C).

test(modos, [true(C1 < C2)]) :-
    inferencias(necesidad, "nesimo 20 fibs", C1),
    inferencias(nombre, "nesimo 20 fibs", C2).

% La sustitución crece con el cuadrado; los entornos, linealmente.
test(sustitucion) :-
    numlist(1, 200, L),
    programa_ejemplo(Prog),
    contar(valor(invertir@[L], _), A),
    contar(evaluar(ap(id(invertir), id(l)), [l-L], Prog, _), B),
    A > 10 * B.

:- end_tests(funcional).
