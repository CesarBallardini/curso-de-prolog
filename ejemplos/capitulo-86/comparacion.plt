:- encoding(utf8).

% Una prueba por par: el mini-SQL da las filas de SQLite. Los pares 30,
% 32, 47, 47b y 49 son los que en el capítulo 42 dan en Prolog filas
% distintas de las de SQL; el mini-SQL da las de SQL.

:- begin_tests(comparacion).

test(par_1) :-
    coincide('1').

test(par_2) :-
    coincide('2').

test(par_3) :-
    coincide('3').

test(par_4) :-
    coincide('4').

test(par_5) :-
    coincide('5').

test(par_6) :-
    coincide('6').

test(par_7) :-
    coincide('7').

test(par_8) :-
    coincide('8').

test(par_9) :-
    coincide('9').

test(par_10) :-
    coincide('10').

test(par_11) :-
    coincide('11').

test(par_12) :-
    coincide('12').

test(par_13) :-
    coincide('13').

test(par_15) :-
    coincide('15').

test(par_16) :-
    coincide('16').

test(par_17) :-
    coincide('17').

test(par_18) :-
    coincide('18').

test(par_20) :-
    coincide('20').

test(par_21) :-
    coincide('21').

test(par_22) :-
    coincide('22').

test(par_23) :-
    coincide('23').

test(par_25) :-
    coincide('25').

test(par_26) :-
    coincide('26').

test(par_27) :-
    coincide('27').

test(par_28) :-
    coincide('28').

test(par_29) :-
    coincide('29').

test(par_30) :-
    coincide('30').

test(par_31) :-
    coincide('31').

test(par_32) :-
    coincide('32').

test(par_36) :-
    coincide('36').

test(par_39) :-
    coincide('39').

test(par_40) :-
    coincide('40').

test(par_41) :-
    coincide('41').

test(par_42) :-
    coincide('42').

test(par_43) :-
    coincide('43').

test(par_44) :-
    coincide('44').

test(par_46) :-
    coincide('46').

test(par_46b) :-
    coincide('46b').

test(par_47) :-
    coincide('47').

test(par_47b) :-
    coincide('47b').

test(par_49) :-
    coincide('49').

test(par_50) :-
    coincide('50').

test(resumen, [true(C-T == 42-42)]) :-
    resumen(C, T).

test(filas_par, [true(Fs == [[102, am1, 4], [102, alg, 2], [103, alg, 5],
                             [106, log, 3]])]) :-
    filas_par('49', Fs).

test(empresa_se_repone, [true(Ns == [alumnos, correlativas, inscripciones,
                                     materias])]) :-
    filas_par('23', _),
    relaciones(Ns).

:- end_tests(comparacion).
