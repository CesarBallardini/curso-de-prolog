:- encoding(utf8).

:- begin_tests(descubrir).

test(cortos_no_sirven, [true(E-P == []-1584)]) :-
    descubrir(2, E, P).

test(largo_tres, [true(N-P-Ps == 24-15984-['UBL', 'UBR', 'UFR'])]) :-
    descubrir(3, E, P),
    length(E, N),
    conmutador([-u, -l, u], [r], S),
    memberchk(S, E),
    compilar(S, M),
    efecto(M, Ps).

test(reducida, [true(N == 120)]) :-
    aggregate_all(count, ( length(Ms, 2), reducida(Ms) ), N).

test(descubierta, [true(Ts == ["U' L' U R U' L U R'"])]) :-
    findall(T, ( descubierta(3, T), sub_string(T, 0, _, _, "U' L") ), Ts).

:- end_tests(descubrir).
