:- encoding(utf8).

:- begin_tests(soluciones).

% Ejercicio 1
test(hijos_de_pedro, all(H == [luis, eva])) :-
    hijo(H, pedro).

% Ejercicio 4
test(hermano_de_luis, all(B == [eva])) :-
    hermano_de(luis, B).

test(eva_no_es_hermano, [fail]) :-
    hermano_de(eva, _).

% Ejercicio 5: las dos versiones producen las mismas respuestas, en el mismo
% orden. Dos pruebas con la misma lista esperada lo especifican.
test(con_dos_clausulas,
     all(A-N == [juan-tomas, juan-luis, juan-eva, pedro-sofia,
                 marta-tomas, marta-luis, marta-eva])) :-
    abuelo_o_abuela(A, N).

test(con_una_sola_regla,
     all(A-N == [juan-tomas, juan-luis, juan-eva, pedro-sofia,
                 marta-tomas, marta-luis, marta-eva])) :-
    abuelo_o_abuela_directo(A, N).

test(abuelos_de_luis, all(A == [juan, marta])) :-
    abuelo_o_abuela(A, luis).

% Ejercicio 7
test(nietos_de_juan, all(N == [tomas, luis, eva])) :-
    nieto(N, juan).

% Ejercicio 8: con progenitor/2 la misma respuesta se obtiene dos veces, una
% por cada progenitor que ana y pedro tienen en común.
test(respuestas_repetidas, all(B == [pedro, pedro])) :-
    hermana_con_progenitor(ana, B).

% Ejercicio 9
test(primos_de_tomas, all(B == [luis, eva])) :-
    primo(tomas, B).

test(nadie_es_primo_de_si_mismo, [fail]) :-
    primo(tomas, tomas).

% Ejercicio 13
test(misma_madre, all(B == [pedro])) :-
    misma_madre(ana, B).

test(nadie_tiene_la_misma_madre_que_si_mismo, [fail]) :-
    misma_madre(ana, ana).

% Ejercicio 14
test(tia_de_luis, all(T == [ana])) :-
    tia(T, luis).

% Ejercicio 15: las dos versiones del ejercicio 5 producen la misma secuencia
test(abuelo_o_abuela_dos_clausulas,
     all(A-N == [juan-tomas, juan-luis, juan-eva, pedro-sofia,
                 marta-tomas, marta-luis, marta-eva])) :-
    abuelo_o_abuela(A, N).

test(abuelo_o_abuela_una_clausula,
     all(A-N == [juan-tomas, juan-luis, juan-eva, pedro-sofia,
                 marta-tomas, marta-luis, marta-eva])) :-
    abuelo_o_abuela_directo(A, N).

:- end_tests(soluciones).
