:- encoding(utf8).

% Capítulo 19 - Operadores propios.
%
% op/3 cambia la forma en que se leen y se escriben los términos, no los
% términos: juan es_padre_de ana es la estructura es_padre_de(juan, ana).
%
%?- juan es_padre_de Hijo.
%?- Quien es_abuelo_de eva.

:- op(700, xfx, es_padre_de).
:- op(700, xfx, es_abuelo_de).

% P es_padre_de H: P es el padre de H.
juan es_padre_de ana.
juan es_padre_de pedro.
pedro es_padre_de luis.
pedro es_padre_de eva.

%!  es_abuelo_de(?A, ?N) is nondet.
%
%   A es abuelo de N: el padre de uno de sus padres.
A es_abuelo_de N :-
    A es_padre_de H,
    H es_padre_de N.
