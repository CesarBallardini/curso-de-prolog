:- encoding(utf8).

% Capítulo 43 - Solución del ejercicio 2: los axiomas de aislamiento del
% cociente.
%
% Los axiomas se agregan a axioma/3 de aislar.pl, que es multifile; el
% módulo vuelve a exportar resolver/3 de la versión 1, que ya los usa.
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- resolver(x / 2 = 5, x, S).
%?- resolver(12 / x = 4, x, S).
%?- resolver(12 / x = 0, x, S).

:- module(soluciones_aislar, []).

:- reexport(aislar, [resolver/3]).

:- multifile aislar:axioma/3.

% U / V = W: la incógnita en el dividendo, U = W * V; en el divisor,
% V = U / W, salvo que W sea 0, porque entonces no hay solución.
aislar:axioma(1, U / V = W, U = W * V).
aislar:axioma(2, U / V = W, V = U / W) :-
    W \== 0.
