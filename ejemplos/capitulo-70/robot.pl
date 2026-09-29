:- encoding(utf8).

% Capítulo 70 - La descripción de un mundo: el robot de STRIPS.
%
% Cinco habitaciones; la 5 es un pasillo, unido a cada una de las otras
% por una puerta. En la habitación 1 están los puntos 1 a 5, tres cajas en
% los puntos 1, 2 y 3, y el interruptor de la luz en el punto 4; el punto
% 6 está en la habitación 4. El robot empieza en el punto 5, en el piso.
% Solo el robot actúa, con siete acciones:
%
%   ir_a(P, R)          camina hasta el punto P de la habitación R;
%   acercarse(X, R)     camina hasta quedar junto a X, en la habitación R;
%   empujar(X, Y, R)    empuja la caja X hasta dejarla junto a Y, en R;
%   cruzar(D, R1, R2)   pasa por la puerta D de la habitación R1 a la R2;
%   subir(B)            sube a la caja B;
%   bajar(B)            baja de la caja B;
%   encender(S)         enciende el interruptor S, subido a la caja 1.
%
% Los hechos que ninguna acción cambia (qué puerta une qué habitaciones,
% dónde está cada punto, qué se puede empujar) se deducen con siempre/1.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- dado(strips1, H).

:- module(robot,
          [ agrega/2,
            borra/2,
            puede/2,
            imposible/1,
            siempre/1,
            prueba/1,
            dado/2,
            distinto/2
          ]).

% agrega(H, A): la acción A hace valer el hecho H.
agrega(en(robot, P), ir_a(P, _)).
agrega(junto(robot, X), acercarse(X, _)).
agrega(junto(X, Y), empujar(X, Y, _)).
agrega(junto(Y, X), empujar(X, Y, _)).
agrega(estado(S, encendido), encender(S)).
agrega(sobre(robot, B), subir(B)).
agrega(en_el_piso, bajar(_)).
agrega(en_habitacion(robot, R2), cruzar(_, _, R2)).

%!  borra(?Hecho, ?Accion) is nondet.
%
%   Accion puede hacer que Hecho deje de valer. Un objeto que se mueve
%   deja de estar donde estaba, sobre lo que estaba y junto a lo que
%   estaba, salvo el robot junto a la caja que empuja, a la que sube o de
%   la que baja. Borra también lo que la acción misma agrega: la regresión
%   pregunta primero si la acción agrega el hecho.
borra(en(X, _), Accion) :-
    movido(X, Accion).
borra(sobre(X, _), Accion) :-
    movido(X, Accion).
borra(junto(X, Y), Accion) :-
    (   movido(X, Accion)
    ;   movido(Y, Accion)
    ),
    \+ conserva(junto(X, Y), Accion).
borra(en_el_piso, subir(_)).
borra(en_habitacion(robot, _), cruzar(_, _, _)).
borra(estado(S, _), encender(S)).

% movido(X, A): la acción A mueve el objeto X.
movido(robot, ir_a(_, _)).
movido(robot, acercarse(_, _)).
movido(robot, empujar(_, _, _)).
movido(X, empujar(X, _, _)).
movido(robot, subir(_)).
movido(robot, bajar(_)).
movido(robot, cruzar(_, _, _)).

% conserva(H, A): el robot sigue junto a la caja con la que actúa.
conserva(junto(robot, X), empujar(X, _, _)).
conserva(junto(X, robot), empujar(X, _, _)).
conserva(junto(robot, B), subir(B)).
conserva(junto(B, robot), subir(B)).
conserva(junto(robot, B), bajar(B)).
conserva(junto(B, robot), bajar(B)).

% puede(A, Pre): la acción A se puede ejecutar donde valen los hechos de
% Pre.
puede(ir_a(P, R), [punto_en(P, R), en_habitacion(robot, R), en_el_piso]).
puede(acercarse(X, R), [en_habitacion(X, R), en_habitacion(robot, R),
                        en_el_piso]).
puede(encender(interruptor(S)), [sobre(robot, caja(1)),
                                 junto(caja(1), interruptor(S))]).
puede(empujar(X, Y, R), [empujable(X), en_habitacion(Y, R),
                         en_habitacion(X, R), junto(robot, X), en_el_piso]).
puede(cruzar(D, R1, R2), [conecta(D, R1, R2), en_habitacion(robot, R1),
                          junto(robot, D), en_el_piso]).
puede(bajar(caja(B)), [sobre(robot, caja(B))]).
puede(subir(caja(B)), [junto(robot, caja(B)), en_el_piso]).

% imposible(Hs): un objeto no está en dos puntos a la vez.
imposible([en(X, Y), en(X, Z), distinto(Y, Z)]).

%!  siempre(?Hecho) is nondet.
%
%   Hecho vale en todo estado: ninguna acción lo cambia.
siempre(en_habitacion(D, R1)) :-
    siempre(conecta(D, R1, _)).
siempre(conecta(D, R1, R2)) :-
    (   une(D, R1, R2)
    ;   une(D, R2, R1)
    ).
siempre(empujable(caja(_))).
siempre(punto_en(punto(N), habitacion(1))) :-
    between(1, 5, N).
siempre(punto_en(punto(6), habitacion(4))).
siempre(en_habitacion(interruptor(1), habitacion(1))).
siempre(en(interruptor(1), punto(4))).

%!  une(?Puerta, ?R1, ?R2) is nondet.
%
%   La puerta N une la habitación N con el pasillo, la habitación 5.
une(puerta(N), habitacion(N), habitacion(5)) :-
    between(1, 4, N).

% prueba(H): H se decide llamándolo.
prueba(distinto(_, _)).

%!  distinto(+X, +Y) is semidet.
%
%   X e Y son objetos distintos. Con una variable libre falla.
distinto(X, Y) :-
    X \= Y.

%!  dado(?Inicio, ?Hecho) is nondet.
%
%   Hecho vale en el estado inicial Inicio.
dado(strips1, en(caja(N), punto(N))) :-
    between(1, 3, N).
dado(strips1, en(robot, punto(5))).
dado(strips1, en_habitacion(caja(N), habitacion(1))) :-
    between(1, 3, N).
dado(strips1, en_habitacion(robot, habitacion(1))).
dado(strips1, en_el_piso).
dado(strips1, estado(interruptor(1), apagado)).
