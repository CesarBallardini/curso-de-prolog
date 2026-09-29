:- encoding(utf8).

% Capítulo 51 - Los circuitos secuenciales del capítulo 48 como máquinas
% de Mealy.
%
% Un circuito secuencial tiene un conjunto finito de estados, los valores
% de su registro; en cada pulso lee las entradas y, según el estado, da
% las salidas y pasa a otro estado. Es una máquina de Mealy cuyos símbolos
% son las listas de bits de un pulso. circuito(Nombre, Estado0) es el
% transductor del circuito secuencial Nombre del capítulo 48, desde
% Estado0, con todos sus estados finales: cada transición es un arco de
% transicion/5 del módulo estados de ese capítulo.
%
% sumador_serie suma dos números binarios, el bit menos significativo
% primero, un par de bits por pulso: su estado es el acarreo, y cada
% transición es el sumador completo del módulo circuitos. Es final el
% estado sin acarreo: la suma cabe en la misma cantidad de bits.
%
% solo-local: carga módulos de otro capítulo, y SWISH no admite módulos
% propios.
%
%?- transducir(circuito(paridad, [0]), [[1], [0], [0], [1]], Ss).
%?- transducir(sumador_serie, [[1, 1], [0, 1], [0, 0]], S).
%?- transducir(sumador_serie, Ps, [0, 1, 1]).
%?- numero_estados(circuito(contador_gray, [0, 0, 0]), N).

:- module(secuencial, []).

:- use_module(library(lists)).
:- reexport(transductores).
:- use_module('../capitulo-48/circuitos').
:- use_module('../capitulo-48/estados').

:- multifile automatas:alfabeto/2, automatas:inicial/2, automatas:final/2,
             automatas:delta/4, automatas:epsilon/3.

automatas:alfabeto(circuito(Nombre, E0), Sigma) :-
    findall(P,
            ( alcanzable(circuito(Nombre, E0), E),
              delta(circuito(Nombre, E0), E, P, _) ),
            Sigma0),
    sort(Sigma0, Sigma).
automatas:inicial(circuito(_Nombre, E0), E0).
automatas:final(circuito(_Nombre, _E0), _E).
automatas:delta(circuito(Nombre, _E0), E, [Es]:[Ss], E1) :-
    transicion(Nombre, E, Es, Ss, E1).

automatas:alfabeto(sumador_serie, Sigma) :-
    findall(P, delta(sumador_serie, _, P, _), Sigma0),
    sort(Sigma0, Sigma).
automatas:inicial(sumador_serie, 0).
automatas:final(sumador_serie, 0).
automatas:delta(sumador_serie, C0, [[A, B]]:[S], C1) :-
    bit(C0),
    simular(sumador, [A, B, C0], [S, C1]).
