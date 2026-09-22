:- encoding(utf8).

% Capítulo 3 - Soluciones de los ejercicios.
%
% La familia del capítulo, con un integrante más —tomas, hijo de ana— para que
% existan primos en la familia.
%
%?- primo(tomas, Quien).
%?- hijo(Quien, pedro).

varon(juan).
varon(pedro).
varon(luis).
varon(tomas).

mujer(marta).
mujer(ana).
mujer(eva).
mujer(sofia).

padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

madre(marta, ana).
madre(marta, pedro).
madre(ana, tomas).
madre(eva, sofia).

progenitor(P, H) :- padre(P, H).
progenitor(P, H) :- madre(P, H).

abuelo(A, N) :-
    varon(A),
    progenitor(A, P),
    progenitor(P, N).

abuela(A, N) :-
    mujer(A),
    progenitor(A, P),
    progenitor(P, N).

% --- Ejercicio 1 -----------------------------------------------------------

% hijo(H, P): H es hijo de P. Es progenitor/2 con los argumentos invertidos.
hijo(H, P) :-
    progenitor(P, H).

% --- Ejercicio 4 -----------------------------------------------------------

% hermano_de(A, B): A es hermano de B. A \== B es la misma condición de 3.5.
hermano_de(A, B) :-
    varon(A),
    padre(P, A),
    padre(P, B),
    A \== B.

% --- Ejercicio 5 -----------------------------------------------------------

% Con dos cláusulas: o es abuelo, o es abuela.
abuelo_o_abuela(A, N) :-
    abuelo(A, N).
abuelo_o_abuela(A, N) :-
    abuela(A, N).

% Con una sola: dos objetivos progenitor/2, sin considerar el sexo.
abuelo_o_abuela_directo(A, N) :-
    progenitor(A, P),
    progenitor(P, N).

% --- Ejercicio 7 -----------------------------------------------------------

% nieto(N, A): N es nieto de A.
nieto(N, A) :-
    abuelo_o_abuela(A, N).

% --- Ejercicio 8 -----------------------------------------------------------

% La regla de 3.5 con progenitor/2: se obtienen respuestas repetidas.
hermana_con_progenitor(A, B) :-
    mujer(A),
    progenitor(P, A),
    progenitor(P, B),
    A \== B.

% --- Ejercicio 9 -----------------------------------------------------------

% hermano_o_hermana(A, B): A y B tienen el mismo padre; no se considera el sexo.
hermano_o_hermana(A, B) :-
    padre(P, A),
    padre(P, B),
    A \== B.

% primo(A, B): un progenitor de A y un progenitor de B son hermanos.
primo(A, B) :-
    progenitor(PA, A),
    progenitor(PB, B),
    hermano_o_hermana(PA, PB).

% --- Ejercicio 13 ----------------------------------------------------------

% misma_madre(A, B): A y B tienen la misma madre y no son la misma persona.
% Sin el último objetivo, toda persona con madre registrada cumple la relación
% consigo misma, porque los dos objetivos se satisfacen con el mismo hecho.
misma_madre(A, B) :-
    madre(M, A),
    madre(M, B),
    A \== B.

% --- Ejercicio 14 ----------------------------------------------------------

% tia(T, S): T es hermana de alguno de los progenitores de S.
tia(T, S) :-
    mujer(T),
    progenitor(P, S),
    hermano_o_hermana(T, P).
