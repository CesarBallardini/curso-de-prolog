:- encoding(utf8).

% Capítulo 51 - El programa terminado.
%
% Carga los módulos del proyecto: los autómatas como hechos y la clausura
% ε tabulada, las construcciones (determinista, complemento, intersección,
% unión, equivalencia), el autómata mínimo, las expresiones regulares, el
% analizador léxico, los transductores y los circuitos secuenciales del
% capítulo 48 como máquinas de Mealy. Los autómatas de pila y las máquinas
% de Turing están en maquinas.pl, que se carga aparte.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- acepta(er("(a|b)*abb"), [a, b, a, b, b]).
%?- tabla(min(er("(a|b)*abb")), T).
%?- contraejemplo(er("(ab)*"), er("a*b*"), W).
%?- componentes("mientras x <= 10 hacer x := x + 1 fin", Cs).
%?- transducir(plural, W, [l, u, c, e, s]).

:- use_module(lexico).
:- use_module(secuencial).
