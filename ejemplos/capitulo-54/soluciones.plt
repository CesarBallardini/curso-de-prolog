:- encoding(utf8).

:- begin_tests(soluciones).

test(plurales, [true(Ps == ["narices", "razones", "orígenes",
                            "corteses"])]) :-
    findall(P,
            ( member(A, [ nombre("nariz", femenino, plural),
                          nombre("razón", femenino, plural),
                          nombre("origen", masculino, plural),
                          adjetivo("cortés", femenino, plural) ]),
              once(forma(P, A)) ),
            Ps).

test(empezar, [true(Fs == ["empecé", "empezaste", "empezó", "empezamos",
                           "empezasteis", "empezaron"])]) :-
    conjugacion("empezar", preterito, Fs).

test(colgar, [true(Fs == ["cuelgo", "cuelgas", "cuelga", "colgamos",
                          "colgáis", "cuelgan"])]) :-
    conjugacion("colgar", presente, Fs).

test(jugar, [true(Fs == ["jugué", "jugaste", "jugó", "jugamos",
                         "jugasteis", "jugaron"])]) :-
    conjugacion("jugar", preterito, Fs).

test(juegan, [true(As == [verbo("jugar", presente, 3, plural)])]) :-
    findall(A, forma("juegan", A), As).

% Las versiones 2 y 4 coinciden en las palabras nuevas.
test(como_la_version_2, [true(Ps2 == Ps4)]) :-
    findall(P, reglas:forma(P, verbo("empezar", presente, 1, singular)),
            Ps2),
    findall(P, forma(P, verbo("empezar", presente, 1, singular)), Ps4).

test(no_verbo, [fail]) :-
    conjugacion("casa", presente, _).

test(antes_genera, all(E == [[t, o, c, a, r]])) :-
    escribir_antes([t, o, k, a, r], E).

test(antes_no_analiza, [fail]) :-
    escribir_antes(_, [t, o, c, a, r]).

test(candidatos, [true(Ns == [26, 8, 260])]) :-
    findall(N,
            ( member(W, ["luces", "toqué", "camiones"]),
              candidatos(W, Ss),
              length(Ss, N) ),
            Ns).

:- end_tests(soluciones).
