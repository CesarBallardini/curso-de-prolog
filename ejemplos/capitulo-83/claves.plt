:- encoding(utf8).

% Pruebas de claves.pl: la tabla ingenua y sus dos ataques, y los
% registros con sal y costo. Los registros usan costo 8 para que las
% pruebas sean rápidas; el capítulo mide el costo 17.

:- begin_tests(claves).

test(huella_simple, true(H == ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad)) :-
    huella_simple(abc, H).

test(tabla_simple, true(L == [101, 102, 103, 104, 105, 106])) :-
    tabla_simple(T),
    pairs_keys(T, L).

test(iguales_iguales, true(H1 == H2)) :-
    tabla_simple(T),
    memberchk(101-H1, T),
    memberchk(104-H2, T).

test(atacar_diccionario, true(H == [101-'123456', 102-tango, 104-'123456',
                                    106-inscripciones])) :-
    tabla_simple(T),
    atacar_diccionario(T, H).

test(clave_corta, true(Cs == [aa, ab, ac])) :-
    findall(C, limit(3, clave_corta(2, C)), Cs).

test(clave_corta_cuenta, true(N == 676)) :-
    aggregate_all(count, clave_corta(2, _), N).

test(fuerza_bruta, true(C == sol)) :-
    huella_simple(sol, H),
    fuerza_bruta(H, 3, C).

test(fuerza_bruta_falla, [fail]) :-
    huella_simple(tango, H),
    fuerza_bruta(H, 2, _).

test(registrar_formato) :-
    registrar(tango, 8, R),
    sub_atom(R, 0, _, _, '$pbkdf2-sha512$t=256$').

test(comprobar) :-
    registrar(tango, 8, R),
    comprobar(tango, R).

test(comprobar_otra, [fail]) :-
    registrar(tango, 8, R),
    comprobar(tanga, R).

test(sal_distinta, [true(R1 \== R2)]) :-
    registrar(tango, 8, R1),
    registrar(tango, 8, R2).

test(atacar_registro, true(C == tango)) :-
    registrar(tango, 8, R),
    diccionario(Ps),
    atacar_registro(R, Ps, C).

test(atacar_registro_falla, [fail]) :-
    registrar('Vq7#mz!Lr2', 8, R),
    diccionario(Ps),
    atacar_registro(R, Ps, _).

:- end_tests(claves).
