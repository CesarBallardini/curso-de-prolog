:- encoding(utf8).

% Capítulo 51 - Soluciones de los ejercicios 14 a 16.
%
% Agregan una construcción a los autómatas de pila de cintas.pl, comparan
% las máquinas de Turing de una y de dos cintas, y agregan un algoritmo
% de Markov a los de reescritura.pl.
%
% solo-local: carga otros archivos, y SWISH no lo permite.
%
%?- acepta_pila(final_de(anbn), [a, a, b, b]).
%?- comparar_pasos(8, P1, P2).
%?- markov(unario, [1, 0, 1], 100, R).

:- ensure_loaded(cintas).
:- ensure_loaded(soluciones_maquinas).
:- ensure_loaded(reescritura).

:- multifile inicial/2, final/2, fondo/2, pila/6, regla_markov/4.
:- discontiguous inicial/2, final/2, fondo/2, pila/6, regla_markov/4.

% Ejercicio 14: final_de(M) acepta por estado final lo que M acepta por
% pila vacía. Pone su propio fondo, fondo0, debajo del fondo de M, y pasa
% al estado acepta cuando lo ve en el tope: la pila de M quedó vacía.

inicial(final_de(_), inicio).
final(final_de(_), acepta).
fondo(final_de(_), fondo0).
pila(final_de(M), inicio, [], fondo0, [Z, fondo0], Q0) :-
    inicial(M, Q0),
    fondo(M, Z).
pila(final_de(M), Q, Lee, X, Apila, Q1) :-
    X \== fondo0,
    pila(M, Q, Lee, X, Apila, Q1).
pila(final_de(_), Q, [], fondo0, [fondo0], acepta) :-
    Q \== inicio,
    Q \== acepta.

% Ejercicio 15: los pasos de las dos máquinas de palíndromos.

%!  comparar_pasos(+N:integer, -P1:integer, -P2:integer) is det.
%
%   P1 y P2 son los pasos con los que palindromo_mt, de una cinta, y
%   palindromo_2c, de dos, aceptan la palabra de N letras a.
comparar_pasos(N, P1, P2) :-
    length(W, N),
    maplist(=(a), W),
    pasos(palindromo_mt, W, P1),
    pasos_cintas(palindromo_2c, W, P2).

% Ejercicio 16: unario convierte un número binario, el bit más
% significativo primero, en tantas i como su valor. La segunda regla
% cambia un 1 por 0i; la primera hace pasar cada i hacia la derecha por
% un 0, duplicándola, porque cada posición a la derecha vale el doble; la
% tercera borra los ceros cuando ya no quedan i a su izquierda.

regla_markov(unario, [i, 0], [0, i, i], sigue).
regla_markov(unario, [1], [0, i], sigue).
regla_markov(unario, [0], [], sigue).
