:- encoding(utf8).

% Capítulo 51 - Máquinas de Moore.
%
% En una máquina de Mealy la salida está en las transiciones; en una
% máquina de Moore, en los estados: salida_estado(M, Q, S) dice que el
% estado Q escribe S cada vez que la máquina entra en él, y también al
% comenzar, en el estado inicial. Las transiciones son las de un autómata
% del módulo automatas. moore/3 la ejecuta, y mealy(M) es la máquina de
% Mealy equivalente, un transductor cuyas transiciones escriben la salida
% del estado al que llegan: da la misma salida sin la del estado inicial.
%
% resto3 es el autómata multiplo3 con una salida en cada estado: el resto
% de dividir por 3 el número binario leído hasta ese momento.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- moore(resto3, [1, 0, 1], S).
%?- transducir(mealy(resto3), [1, 0, 1], S).
%?- length(E, 3), transducir(mealy(resto3), E, [1, 2, 2]).

:- module(moore,
          [ moore/3,
            salida_estado/3
          ]).

:- use_module(library(lists)).
:- reexport(transductores).

:- multifile salida_estado/3.

% salida_estado(M, Q, S): el estado Q de la máquina de Moore M escribe S.
salida_estado(resto3, r0, 0).
salida_estado(resto3, r1, 1).
salida_estado(resto3, r2, 2).

automatas:alfabeto(resto3, [0, 1]).
automatas:inicial(resto3, r0).
automatas:final(resto3, Q) :-
    salida_estado(resto3, Q, _).
automatas:delta(resto3, Q, S, Q1) :-
    delta(multiplo3, Q, S, Q1).

%!  moore(+M, ?Entrada:list, ?Salida:list) is nondet.
%
%   La máquina de Moore M, con la Entrada, escribe la Salida: la salida
%   del estado inicial y la de cada estado al que entra. Salida tiene un
%   símbolo más que Entrada. Una de las dos debe llegar ligada, o al menos
%   su longitud.
moore(M, Entrada, [S0|Salida]) :-
    inicial(M, Q0),
    salida_estado(M, Q0, S0),
    recorrer(M, Q0, Entrada, Salida).

%!  recorrer(+M, +Q, ?Entrada:list, ?Salida:list) is nondet.
%
%   Desde el estado Q, M lee Entrada y escribe Salida, un símbolo por
%   cada uno que lee.
recorrer(_, _, [], []).
recorrer(M, Q, [E|Es], [S|Ss]) :-
    delta(M, Q, E, Q1),
    salida_estado(M, Q1, S),
    recorrer(M, Q1, Es, Ss).

% mealy(M): la máquina de Mealy de la máquina de Moore M. Cada transición
% lee el símbolo de M y escribe la salida del estado al que llega; todos
% los estados son finales.

automatas:inicial(mealy(M), Q0) :-
    inicial(M, Q0).
automatas:final(mealy(M), Q) :-
    salida_estado(M, Q, _).
automatas:delta(mealy(M), Q, [E]:[S], Q1) :-
    delta(M, Q, E, Q1),
    salida_estado(M, Q1, S).
