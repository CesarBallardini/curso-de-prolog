:- encoding(utf8).

% Capítulo 70 - Solución del ejercicio 7: el mundo con pinza, con
% combinaciones imposibles.
%
% El mundo es el de pinza.pl, con imposible/1 y prueba/1 propios: la pinza
% no está vacía mientras sostiene un bloque ni sostiene dos, un bloque no
% está en dos lugares, y lo que está debajo de otro bloque no está libre.
%
% solo-local: carga pinza.pl.
%
%?- planificar(pinza2, sussman, [sobre(a, b), sobre(b, c)], 6, Plan).

:- module(pinza2,
          [ imposible/1,
            prueba/1,
            distinto/2
          ]).

:- reexport(pinza, except([imposible/1, prueba/1])).

% imposible(Hs): los hechos de Hs no pueden valer juntos.
imposible([sostiene(_), mano_vacia]).
imposible([sostiene(X), sostiene(Y), distinto(X, Y)]).
imposible([sostiene(X), sobre(X, _)]).
imposible([sobre(X, Y), sobre(X, Z), distinto(Y, Z)]).
imposible([sobre(_, Y), libre(Y)]).

% prueba(H): H se decide llamándolo.
prueba(distinto(_, _)).

%!  distinto(+X, +Y) is semidet.
%
%   X e Y son objetos distintos. Con una variable libre falla.
distinto(X, Y) :-
    X \= Y.
