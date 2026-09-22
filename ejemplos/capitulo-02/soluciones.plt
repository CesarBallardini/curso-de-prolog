:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(sofia_es_mujer) :-
    mujer(sofia).

test(marta_es_madre_de_ana) :-
    madre(marta, ana).

test(a_luis_le_gusta_el_futbol) :-
    gusta(luis, futbol).

% Ejercicio 7: el orden de los argumentos es el que documenta el comentario.
test(quien_le_regala_a_ana, all(Q-C == [juan-libro])) :-
    regala(Q, C, ana).

test(ana_regala_una_pelota, all(C == [pelota])) :-
    regala(ana, C, _).

% Ejercicio 10: con los hechos agregados, sofia tiene padre.
test(sofia_ya_tiene_padre, all(P == [diego])) :-
    padre(P, sofia).

% Ejercicio 12
test(materias_de_ana, all(M == [logica, algebra])) :-
    cursa(ana, M).

test(garcia_dicta_dos, all(M == [logica, algebra])) :-
    dicta(garcia, M).

test(nadie_cursa_quimica, [fail]) :-
    cursa(_, quimica).

% Ejercicio 13
test(nacio_en, all(A == [1985])) :-
    nacio_en(ana, A).

test(horas_de_logica, all(H == [4])) :-
    horas_semanales(logica, H).

test(companiero_en_los_dos_sentidos) :-
    companiero(ana, luis),
    companiero(luis, ana).

:- end_tests(soluciones).
