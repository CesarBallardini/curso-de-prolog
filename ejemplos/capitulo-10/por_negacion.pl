:- encoding(utf8).

% Capítulo 10 - Obtener una respuesta por negación.
%
% "X es el que cumple la condición porque no existe otro que la cumpla mejor":
% un objetivo genera el candidato y un \+ descarta que exista uno mejor.
%
%?- mayor_edad(Quien).
%?- hijo_menor(pedro, Quien).

% persona(P): P es una de las personas de la base.
persona(juan).
persona(ana).
persona(pedro).
persona(luis).
persona(eva).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

%!  mayor_edad(?P) is nondet.
%
%   P tiene la mayor edad de la base: ninguna otra edad es mayor que la suya.
%   Si dos personas empatan, las dos son respuestas.
mayor_edad(P) :-
    edad(P, E),
    \+ ( edad(_, Otra),
         Otra > E ).

%!  hijo_menor(?P, ?H) is nondet.
%
%   H es el hijo de menor edad de P: ningún otro hijo de P es menor que H.
hijo_menor(P, H) :-
    padre(P, H),
    edad(H, E),
    \+ ( padre(P, Otro),
         edad(Otro, E2),
         E2 < E ).
