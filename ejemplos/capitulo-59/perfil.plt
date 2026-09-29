:- encoding(utf8).

:- begin_tests(perfil).

test(inversa, [true(R-Cs == [d, c, b, a]-[concatenar/3-10, inversa/2-5])]) :-
    perfil(inversa([a, b, c, d], R), exito, Cs).

% La inversa ingenua de n elementos hace n(n+1)/2 llamadas a concatenar/3:
% 465 para n = 30. La del acumulador, n + 1 llamadas a inversa_acumulada/3.
test(treinta, [true(C1-C2 == 465-31)]) :-
    perfil(invertir(30), exito, Cuentas1),
    memberchk(concatenar/3-C1, Cuentas1),
    perfil(invertir_rapido(30), exito, Cuentas2),
    memberchk(inversa_acumulada/3-C2, Cuentas2).

test(formula, [forall(between(1, 12, N)), true(C =:= N * (N + 1) // 2)]) :-
    perfil((lista(N, L), inversa(L, _)), exito, Cuentas),
    memberchk(concatenar/3-C, Cuentas).

% Las llamadas de las ramas que fallan también se cuentan.
test(falla, [true(Cuentas == [concatenar/3-2, inversa/2-3])]) :-
    perfil(inversa([a, b], [a, b]), falla, Cuentas).

test(condicional, [true(R == si)]) :-
    perfil(( inversa([a], X) -> ( X = [a] -> R = si ; R = no ) ; R = nada ),
           exito, _).

test(negacion, [true(Cuentas == [concatenar/3-1, inversa/2-2])]) :-
    perfil(\+ inversa([a], [b]), exito, Cuentas).

test(espiar, [true(Lineas == [ "+ concatenar([], [b], [b])",
                               "- concatenar([b], [a], [a, b])",
                               "- concatenar([], [b], A)",
                               "" ]),
              cleanup(no_espiar(concatenar/3))]) :-
    espiar(concatenar/3),
    with_output_to(string(Salida),
                   perfil(inversa([a, b], [a, b]), falla, _)),
    split_string(Salida, "\n", "", Lineas).

:- end_tests(perfil).
