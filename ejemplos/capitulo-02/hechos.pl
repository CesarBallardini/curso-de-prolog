:- encoding(utf8).

% Capítulo 2 - Hechos.
%
% Una base de conocimiento formada exclusivamente por hechos: el sexo de cada
% persona, y quién es padre o madre de quién. Las reglas se presentan en el
% capítulo 3.
%
% Ningún hecho indica quién es el padre de sofia. Esa ausencia se refleja en las
% respuestas de las consultas.
%
%?- padre(juan, ana).
%?- madre(marta, pedro).

% varon(P): P es varón.
varon(juan).
varon(pedro).
varon(luis).

% mujer(P): P es mujer.
mujer(marta).
mujer(ana).
mujer(eva).
mujer(sofia).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% madre(M, H): M es la madre de H.
madre(marta, ana).
madre(marta, pedro).
madre(eva, sofia).
