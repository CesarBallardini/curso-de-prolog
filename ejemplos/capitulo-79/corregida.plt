:- encoding(utf8).

:- use_module(consejos).

:- begin_tests(corregida).

test(mismas_reglas, [true(Rs == [borde, resto])]) :-
    findall(R, regla(R, _), Rs).

test(seis_consejos, [true(N == 6)]) :-
    aggregate_all(count, consejo(_, _, _, _, _), N).

test(no_ahogado, [true(M == (no torre_perdida y no ahogado))]) :-
    consejo(encierro, _, M, _, _).

% En la posición en que la tabla original ahoga al rey negro, la corregida
% elige otro consejo.
test(otro_consejo, [true(C-J == dividir_en_2-torre(2-2, 1-2))]) :-
    estrategia(corregida, pos(blancas, 1-3, 2-2, 1-1), C, juega(J, _)).

:- end_tests(corregida).
