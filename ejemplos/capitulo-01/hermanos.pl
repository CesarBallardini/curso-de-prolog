:- encoding(utf8).

% Capítulo 1 - Soluciones: hermanos en el árbol de Taré.
%
% Ejercicios 10 y 11. El primero pide la regla directa; el segundo, corregirla,
% porque con la regla directa cada persona resulta hermana de sí misma.
%
%?- hermano(lot, Quien).
%?- hermano_de_verdad(lot, Quien).

padre(tare, abraham).
padre(tare, nacor).
padre(tare, haran).
padre(abraham, isaac).
padre(haran, lot).
padre(haran, milca).
padre(haran, isca).

% Ejercicio 10: la regla directa. Su defecto se corrige en el ejercicio 11.
hermano(A, B) :-
    padre(P, A),
    padre(P, B).

% Ejercicio 11: se agrega la condición de que no sean la misma persona.
hermano_de_verdad(A, B) :-
    padre(P, A),
    padre(P, B),
    \+ A = B.
