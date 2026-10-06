:- encoding(utf8).

% Capítulo 70 - Un mundo de cubos con un estado inicial dudoso.
%
% Reexporta el mundo de cubos.pl y agrega dos estados iniciales que solo
% se distinguen por dónde está c: en c_sobre_a, c está sobre a, como en
% sussman; en c_sobre_b, c está sobre b. Quien planifica no sabe cuál de
% los dos es el verdadero hasta mirar.
%
% solo-local: carga cubos.pl.
%
%?- dado(c_sobre_b, H).

:- module(dudoso,
          [ dado/2
          ]).

:- reexport(cubos, except([dado/2])).

%!  dado(?Inicio, ?Hecho) is nondet.
%
%   Hecho vale en el estado inicial Inicio: los de cubos.pl, c_sobre_a y
%   c_sobre_b.
dado(Inicio, Hecho) :-
    cubos:dado(Inicio, Hecho).
dado(c_sobre_a, Hecho) :-
    cubos:dado(sussman, Hecho).
dado(c_sobre_b, Hecho) :-
    member(Hecho, [sobre(a, mesa), sobre(b, mesa), sobre(c, b), libre(a),
                   libre(c)]).
