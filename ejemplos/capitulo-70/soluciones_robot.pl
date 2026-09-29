:- encoding(utf8).

% Capítulo 70 - Soluciones de los ejercicios 4 y 5: el robot corregido y
% con una acción más.
%
% El mundo es el de robot.pl con dos cambios. empujar(X, Y, R) exige que
% Y no sea el robot, que no puede quedar junto a la caja que él mismo
% empuja hacia él. Y hay una acción nueva, empujar_por(X, D, R1, R2): el
% robot, junto a la caja X, que está junto a la puerta D, la empuja por
% esa puerta de la habitación R1 a la R2, y pasa con ella. Los predicados
% que no cambian llaman a los de robot.pl.
%
% solo-local: carga robot.pl.
%
%?- puede(empujar(caja(1), robot, habitacion(1)), Pre).

:- module(robot2,
          [ agrega/2,
            borra/2,
            puede/2,
            imposible/1,
            siempre/1,
            prueba/1,
            dado/2,
            distinto/2
          ]).

:- reexport(robot, [imposible/1, siempre/1, prueba/1, dado/2, distinto/2]).

%!  agrega(?Hecho, ?Accion) is nondet.
%
%   Las de robot.pl, y las de empujar_por/4: la caja y el robot quedan en
%   la habitación R2, uno junto al otro.
agrega(Hecho, Accion) :-
    robot:agrega(Hecho, Accion).
agrega(en_habitacion(X, R2), empujar_por(X, _, _, R2)).
agrega(en_habitacion(robot, R2), empujar_por(_, _, _, R2)).
agrega(junto(robot, X), empujar_por(X, _, _, _)).

%!  borra(?Hecho, ?Accion) is nondet.
%
%   Las de robot.pl, y las de empujar_por/4: la caja y el robot dejan la
%   habitación de la que salen, su punto y lo que tenían al lado, salvo
%   estar uno junto al otro.
borra(Hecho, Accion) :-
    robot:borra(Hecho, Accion).
borra(en_habitacion(X, _), empujar_por(X, _, _, _)).
borra(en_habitacion(robot, _), empujar_por(_, _, _, _)).
borra(en(X, _), empujar_por(X, _, _, _)).
borra(en(robot, _), empujar_por(_, _, _, _)).
borra(junto(X, Y), empujar_por(Z, _, _, _)) :-
    (   X == Z
    ;   Y == Z
    ;   X == robot
    ;   Y == robot
    ),
    \+ ( X == robot, Y == Z ),
    \+ ( X == Z, Y == robot ).

%!  puede(?Accion, -Precondiciones:list) is nondet.
%
%   Las de robot.pl, con empujar/3 restringida a un Y que no es el robot,
%   y las de empujar_por/4.
puede(empujar(X, Y, R), [empujable(X), en_habitacion(Y, R),
                         distinto(Y, robot), en_habitacion(X, R),
                         junto(robot, X), en_el_piso]).
puede(Accion, Pre) :-
    robot:puede(Accion, Pre),
    Accion \= empujar(_, _, _).
puede(empujar_por(X, D, R1, R2), [empujable(X), conecta(D, R1, R2),
                                  en_habitacion(X, R1),
                                  en_habitacion(robot, R1),
                                  junto(X, D), junto(robot, X),
                                  en_el_piso]).
