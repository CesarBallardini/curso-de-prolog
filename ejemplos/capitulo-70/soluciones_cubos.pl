:- encoding(utf8).

% Capítulo 70 - Soluciones de los ejercicios 2, 9 y 11: los cubos con más
% estados iniciales y una combinación imposible más.
%
% El mundo es el de cubos.pl, con dos estados iniciales nuevos: torre, con
% a sobre b sobre c, y cuatro, con d sobre c sobre b sobre a. imposible/1
% agrega a las combinaciones de cubos.pl la de dos cubos, cada uno sobre
% el otro. Los demás predicados se reexportan sin cambios.
%
% solo-local: carga cubos.pl.
%
%?- dado(torre, H).

:- module(cubos2,
          [ dado/2,
            imposible/1
          ]).

:- reexport(cubos, except([dado/2, imposible/1])).

%!  dado(?Inicio, ?Hecho) is nondet.
%
%   Hecho vale en el estado inicial Inicio: los de cubos.pl, torre, con a
%   sobre b sobre c, y cuatro, con d sobre c sobre b sobre a.
dado(Inicio, Hecho) :-
    cubos:dado(Inicio, Hecho).
dado(torre, Hecho) :-
    member(Hecho, [sobre(a, b), sobre(b, c), sobre(c, mesa), libre(a)]).
dado(cuatro, Hecho) :-
    member(Hecho, [sobre(d, c), sobre(c, b), sobre(b, a), sobre(a, mesa),
                   libre(d)]).

%!  imposible(?Hechos:list) is nondet.
%
%   Las combinaciones de cubos.pl, y dos cubos cada uno sobre el otro.
imposible(Hechos) :-
    cubos:imposible(Hechos).
imposible([sobre(X, Y), sobre(Y, X)]).
