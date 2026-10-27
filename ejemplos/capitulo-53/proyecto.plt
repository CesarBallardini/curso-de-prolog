:- encoding(utf8).

:- begin_tests(proyecto).

test(maquina_ii, [true(Fs == [0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1])]) :-
    figuras(ii, b, 15, Fs).

test(contador, [true(Fs == [0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1])]) :-
    figuras(contador, inicio, 15, Fs).

test(ce, [true(Ss == [schwa, schwa, 1, blanco, 0, blanco, 1, blanco, 0])]) :-
    cinta_de([schwa, schwa, 1, a, 0, a], 0, C0),
    ejecutar(biblioteca, ce(fin, a), C0, 1000, detenida(fin, C)),
    contenido(C, Ss).

test(incompleta, [true(N == 1001)]) :-
    completa(contador, inicio, [0, 1, schwa], 1000, incompleta(Es)),
    length(Es, N).

test(numero, [true(N == 31332531173113353111731113322531111731111335317)]) :-
    numero(i, b, [0, 1], N).

:- end_tests(proyecto).
