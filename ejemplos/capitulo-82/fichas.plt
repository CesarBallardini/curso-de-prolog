:- encoding(utf8).

% Pruebas de fichas.pl: el HMAC contra el caso 2 del RFC 4231, y las
% fichas aceptadas y rechazadas.

:- begin_tests(fichas).

test(mac_rfc_4231, true(M == '5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843')) :-
    mac("Jefe", "what do ya want for nothing?", M).

test(mac_otra_clave, true(M1 \== M2)) :-
    mac(uno, datos, M1),
    mac(dos, datos, M2).

test(nuevo_secreto, true(N == 64)) :-
    nuevo_secreto(S),
    atom_length(S, N).

test(secretos_distintos, true(S1 \== S2)) :-
    nuevo_secreto(S1),
    nuevo_secreto(S2).

% El valor esperado se calculó aparte, con el módulo hmac de Python.
test(emitir, true(F == '101.1800000000.6f39660ece43ac33223f8b8ea46d5fec656aa355b82fe417f247a8c708e1845e')) :-
    emitir(secreto, 101, 1800000000, F).

test(validar, true(L == 101)) :-
    emitir(secreto, 101, 1800000000, F),
    validar(secreto, F, 1700000000, L).

test(validar_vencida, [fail]) :-
    emitir(secreto, 101, 1800000000, F),
    validar(secreto, F, 1800000000, _).

test(validar_otro_secreto, [fail]) :-
    emitir(secreto, 101, 1800000000, F),
    validar(otro, F, 1700000000, _).

test(validar_alterada, [fail]) :-
    emitir(secreto, 101, 1800000000, F),
    atomic_list_concat([_, V, M], '.', F),
    atomic_list_concat(['102', V, M], '.', F1),
    validar(secreto, F1, 1700000000, _).

test(validar_extendida, [fail]) :-
    emitir(secreto, 101, 1800000000, F),
    atomic_list_concat([L, _, M], '.', F),
    atomic_list_concat([L, '1900000000', M], '.', F1),
    validar(secreto, F1, 1700000000, _).

test(validar_mal_formada, [fail]) :-
    validar(secreto, 'abc.def', 1700000000, _).

test(validar_legajo_ligado) :-
    emitir(secreto, 101, 1800000000, F),
    validar(secreto, F, 1700000000, 101).

test(validar_legajo_otro, [fail]) :-
    emitir(secreto, 101, 1800000000, F),
    validar(secreto, F, 1700000000, 102).

test(iguales) :-
    iguales(abc, abc).

test(iguales_no, [fail]) :-
    iguales(abc, abd).

test(iguales_longitud, [fail]) :-
    iguales(abc, abcd).

:- end_tests(fichas).
