:- encoding(utf8).

% Capítulo 51 - Versión 1: autómatas finitos como hechos.
%
% Un autómata finito M = (Q, Σ, δ, q0, F) se escribe con cuatro relaciones,
% con el nombre del autómata como primer argumento para que un mismo
% programa describa varios:
%
%   inicial(M, Q0)        Q0 es el estado inicial de M;
%   final(M, Q)           Q es un estado final de M;
%   delta(M, Q, S, Q1)    M pasa de Q a Q1 leyendo el símbolo S;
%   epsilon(M, Q, Q1)     M pasa de Q a Q1 sin leer nada (transición ε).
%
% Una palabra es una lista de símbolos. El autómata determinista es el
% caso en el que delta/4 es una función y no hay transiciones ε.
%
%?- acepta(multiplo3, [1, 1, 0]).
%?- length(W, 3), acepta(multiplo3, W).
%?- acepta(termina_ab, [a, b, a, b]).
%?- call_with_inference_limit(acepta(ciclo, [a]), 100000, R).

% inicial(M, Q0): Q0 es el estado inicial del autómata M.
inicial(multiplo3, r0).
inicial(termina_ab, q0).
inicial(ciclo, s0).

% final(M, Q): Q es un estado final del autómata M.
final(multiplo3, r0).
final(termina_ab, q2).
final(ciclo, s2).

% delta(M, Q, S, Q1): el autómata M pasa de Q a Q1 leyendo S.
%
% multiplo3 lee un número binario, el bit más significativo primero, y el
% estado es el resto de dividir por 3 lo leído: leer el bit B desde el
% resto R deja el resto de 2R + B.
delta(multiplo3, r0, 0, r0).
delta(multiplo3, r0, 1, r1).
delta(multiplo3, r1, 0, r2).
delta(multiplo3, r1, 1, r0).
delta(multiplo3, r2, 0, r1).
delta(multiplo3, r2, 1, r2).
% termina_ab acepta las palabras sobre {a, b} que terminan en ab: en q0
% elige, en cada a, si es la penúltima letra.
delta(termina_ab, q0, a, q0).
delta(termina_ab, q0, b, q0).
delta(termina_ab, q0, a, q1).
delta(termina_ab, q1, b, q2).
% ciclo acepta a*b, con dos estados unidos por transiciones ε en los dos
% sentidos.
delta(ciclo, s0, a, s0).
delta(ciclo, s1, b, s2).

% epsilon(M, Q, Q1): el autómata M pasa de Q a Q1 sin leer un símbolo.
epsilon(ciclo, s0, s1).
epsilon(ciclo, s1, s0).

%!  acepta(+M, ?W:list) is nondet.
%
%   El autómata M acepta la palabra W: hay un camino desde el estado
%   inicial hasta uno final que lee W. Da una respuesta por camino, y no
%   termina si M tiene un ciclo de transiciones ε.
acepta(M, W) :-
    inicial(M, Q0),
    lee(M, Q0, W).

%!  lee(+M, +Q, ?W:list) is nondet.
%
%   Desde el estado Q, el autómata M lee W y termina en un estado final.
lee(M, Q, []) :-
    final(M, Q).
lee(M, Q, [S|W]) :-
    delta(M, Q, S, Q1),
    lee(M, Q1, W).
lee(M, Q, W) :-
    epsilon(M, Q, Q1),
    lee(M, Q1, W).
