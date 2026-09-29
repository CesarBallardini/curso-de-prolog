:- encoding(utf8).

% Capítulo 70 - La descripción de un mundo: los cubos.
%
% Tres cubos, a, b y c, y la mesa. Hay una sola acción, mover(U, V, W):
% lleva el cubo libre U, que está sobre V, a W, que es la mesa o un cubo
% libre. Un mundo se describe con siete predicados, que el planificador
% consulta sin conocer el mundo:
%
%   agrega(H, A)     la acción A hace valer el hecho H;
%   borra(H, A)      A puede hacer que H deje de valer;
%   puede(A, Pre)    A se puede ejecutar donde valen los hechos de Pre;
%   imposible(Hs)    los hechos de Hs no pueden valer juntos;
%   siempre(H)       H vale en todo estado;
%   prueba(H)        H no es un hecho del mundo sino una prueba, que se
%                    decide llamándola;
%   dado(I, H)       H vale en el estado inicial I.
%
% Ninguno guarda un estado: el planificador calcula lo que vale después de
% un plan a partir de dado/2 y de las acciones.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- dado(sussman, H).

:- module(cubos,
          [ agrega/2,
            borra/2,
            puede/2,
            imposible/1,
            siempre/1,
            prueba/1,
            dado/2,
            distinto/2
          ]).

%!  agrega(?Hecho, ?Accion) is nondet.
%
%   Accion hace valer Hecho: el cubo movido queda sobre su destino, y su
%   origen queda libre si es un cubo.
agrega(sobre(U, W), mover(U, _, W)).
agrega(libre(V), mover(_, V, _)) :-
    V \== mesa.

%!  borra(?Hecho, ?Accion) is nondet.
%
%   Accion puede hacer que Hecho deje de valer: el cubo movido deja de
%   estar donde estaba, y el destino deja de estar libre.
borra(sobre(U, _), mover(U, _, _)).
borra(libre(W), mover(_, _, W)).

%!  puede(?Accion, -Precondiciones:list) is nondet.
%
%   Accion se puede ejecutar en un estado donde valen las Precondiciones.
%   Las pruebas van después de los hechos que ligan sus variables.
puede(mover(U, V, mesa), [sobre(U, V), distinto(V, mesa), libre(U)]).
puede(mover(U, V, W), [libre(W), distinto(W, mesa), sobre(U, V),
                       distinto(U, W), libre(U)]).

% imposible(Hs): los hechos de Hs no pueden valer juntos.
imposible([sobre(_, Y), libre(Y)]).
imposible([sobre(X, Y), sobre(X, Z), distinto(Y, Z)]).
imposible([sobre(X, Z), sobre(Y, Z), distinto(Z, mesa), distinto(X, Y)]).
imposible([sobre(X, X)]).

% siempre(H): H vale en todo estado. En los cubos no hay ninguno: el
% predicado se declara sin cláusulas.
:- dynamic siempre/1.

% prueba(H): H se decide llamándolo.
prueba(distinto(_, _)).

%!  distinto(+X, +Y) is semidet.
%
%   X e Y son objetos distintos. Con una variable libre falla: dos
%   objetos que todavía no se conocen pueden ser el mismo.
distinto(X, Y) :-
    X \= Y.

% dado(I, H): H vale en el estado inicial I. En sussman, c está sobre a,
% y a y b sobre la mesa.
dado(sussman, sobre(a, mesa)).
dado(sussman, sobre(b, mesa)).
dado(sussman, sobre(c, a)).
dado(sussman, libre(b)).
dado(sussman, libre(c)).
