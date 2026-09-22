:- encoding(utf8).

% Capítulo 4 - Los operadores también son términos.
%
% 2 + 3 no es una operación pendiente de evaluar: es un término compuesto, de
% nombre + y dos argumentos, escrito en notación infija.
%
%?- 2 + 3 = +(2, 3).
%?- lados(2 + 3, Izquierda, Derecha).

% lados(Suma, A, B): A y B son los dos operandos de la suma.
lados(A + B, A, B).

% al_reves(Suma, Otra): Otra es la misma suma con los operandos intercambiados.
al_reves(A + B, B + A).

% es_suma(T): T es una suma, cualesquiera sean sus operandos.
es_suma(_ + _).
