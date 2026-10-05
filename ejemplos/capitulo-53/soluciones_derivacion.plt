:- encoding(utf8).

:- begin_tests(soluciones_derivacion).

test(jota_como_la_version_3, [true(A == B)]) :-
    regla_dos_niveles(jota_g, P1, O1, I1, D1),
    compilar(P1, O1, I1, D1, Ps1),
    regla_dos_niveles(jota_j, P2, O2, I2, D2),
    compilar(P2, O2, I2, D2, Ps2),
    append(Ps1, Ps2, Ps),
    once(regla(jota, Qs)),
    msort(Ps, A),
    msort(Qs, B).

test(irreal_ilegal, [true(Ps == ["infeliz", "imposible", "inútil",
                                 "irreal", "ilegal"])]) :-
    findall(P, derivada(P, prefijo("in", _)), Ps).

test(ilegales, [true(As == [adjetivo("ilegal", masculino, plural),
                            adjetivo("ilegal", femenino, plural)])]) :-
    findall(A, forma("ilegales", A), As).

test(sin_inreal, [fail]) :-
    reglas(Rs),
    transducir(paralelo(Rs), [i, 'N', +, r, e, a, l], [i, n, r, e, a, l]).

:- end_tests(soluciones_derivacion).
