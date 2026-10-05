:- encoding(utf8).

% Capítulo 81 - Reglas de tránsito: los semáforos.
%
% Las reglas de Rowe para los semáforos de California, que dicen qué
% puede hacer un auto o un peatón ante las luces que ve. Una situación es
% una lista de observaciones: luz(Tipo, Estado), puede_frenar (el auto
% puede detenerse a tiempo y sin peligro) y cruce_horario (el peatón cruza
% en el sentido de las agujas del reloj respecto del centro del cruce).
% Las luces comunes y las de peatones están fijas o intermitentes; las
% flechas apuntan a la izquierda o a la derecha.
%
% Versión 1: las reglas como las escribe Rowe, con la situación como
% argumento en lugar de hechos en la base de datos. El orden de las
% cláusulas es la prioridad: la primera respuesta es la recomendada.
% Versión 2: las reglas por omisión se aplican solo cuando ninguna regla
% específica da una acción, como dice el texto de Rowe; decision/3 es la
% primera acción, y tabla/2 la calcula para cada luz sola.
%
%?- accion_v1([puede_frenar, luz(amarillo, fija), luz(flecha_verde, izquierda)], auto, A).
%?- accion_v1([cruce_horario, luz(verde, fija), luz(silueta, intermitente)], peaton, A).
%?- accion([luz(amarillo, intermitente)], auto, A).
%?- tabla(auto, Filas).

:- use_module(library(lists)).

% --- Las observaciones ---------------------------------------------------

%!  luz(+Situacion:list, ?Tipo, ?Estado) is nondet.
%
%   En Situacion se ve la luz Tipo en Estado.
luz(Situacion, Tipo, Estado) :-
    member(luz(Tipo, Estado), Situacion).

%!  puede_frenar(+Situacion:list) is semidet.
%
%   En Situacion el auto puede detenerse a tiempo y sin peligro.
puede_frenar(Situacion) :-
    memberchk(puede_frenar, Situacion).

%!  cruce_horario(+Situacion:list) is semidet.
%
%   En Situacion el peatón cruza en el sentido de las agujas del reloj.
cruce_horario(Situacion) :-
    memberchk(cruce_horario, Situacion).

%!  alto_peaton(+Situacion:list, ?Estado) is nondet.
%
%   Se ve una señal que detiene al peatón, en Estado: «espere», «no
%   cruce» o la mano levantada.
alto_peaton(Situacion, Estado) :-
    member(Tipo, [espere, no_cruce, mano]),
    luz(Situacion, Tipo, Estado).

%!  paso_peaton(+Situacion:list, ?Estado) is nondet.
%
%   Se ve una señal que deja pasar al peatón, en Estado: «cruce» o la
%   silueta que camina.
paso_peaton(Situacion, Estado) :-
    member(Tipo, [cruce, silueta]),
    luz(Situacion, Tipo, Estado).

%!  senales_peaton(+Situacion:list) is semidet.
%
%   El cruce tiene señales para peatones.
senales_peaton(Situacion) :-
    (   alto_peaton(Situacion, _)
    ;   paso_peaton(Situacion, _)
    ),
    !.

%!  verde_de_frente(+Situacion:list) is semidet.
%
%   El peatón tiene de frente una flecha verde: la de la derecha si no
%   cruza en el sentido de las agujas del reloj, la de la izquierda si
%   cruza en ese sentido.
verde_de_frente(Situacion) :-
    (   cruce_horario(Situacion)
    ->  luz(Situacion, flecha_verde, izquierda)
    ;   luz(Situacion, flecha_verde, derecha)
    ),
    !.

% --- Versión 1: las reglas de Rowe ---------------------------------------

%!  auto(+Situacion:list, ?Accion) is nondet.
%
%   Una regla que mira las luces dice que Accion es legal para un auto en
%   Situacion. Primero las flechas, que mandan sobre las otras luces; en
%   cada grupo, primero detenerse, por si hay más de una luz encendida.
auto(S, detenerse) :-
    luz(S, flecha_amarilla, _),
    puede_frenar(S).
auto(S, ceder_y_girar_izquierda) :-
    luz(S, flecha_amarilla, izquierda),
    \+ puede_frenar(S).
auto(S, ceder_y_girar_derecha) :-
    luz(S, flecha_amarilla, derecha),
    \+ puede_frenar(S).
auto(S, ceder_y_girar_izquierda) :-
    luz(S, flecha_verde, izquierda).
auto(S, ceder_y_girar_derecha) :-
    luz(S, flecha_verde, derecha).
auto(S, detenerse) :-
    luz(S, rojo, fija).
auto(S, detenerse_y_avanzar) :-
    luz(S, rojo, intermitente).
auto(S, detenerse) :-
    luz(S, amarillo, fija),
    puede_frenar(S).
auto(S, ceder_y_avanzar) :-
    luz(S, amarillo, fija),
    \+ puede_frenar(S).
auto(S, ceder_y_avanzar) :-
    luz(S, verde, fija).
auto(S, avanzar_despacio) :-
    luz(S, amarillo, intermitente).
auto(S, detenerse) :-
    luz(S, flecha_roja, _).

%!  peaton(+Situacion:list, ?Accion) is nondet.
%
%   Una regla que mira las señales de peatones, o la flecha que el peatón
%   tiene de frente, dice que Accion es legal para él en Situacion.
peaton(S, detenerse) :-
    alto_peaton(S, fija).
peaton(S, detenerse) :-
    \+ senales_peaton(S),
    verde_de_frente(S).
peaton(S, detenerse) :-
    alto_peaton(S, intermitente),
    puede_frenar(S).
peaton(S, ceder_y_avanzar) :-
    alto_peaton(S, intermitente),
    \+ puede_frenar(S).
peaton(S, ceder_y_avanzar) :-
    paso_peaton(S, fija).

%!  accion_v1(+Situacion:list, +Quien, ?Accion) is nondet.
%
%   Accion es legal para Quien, auto o peaton, en Situacion, con las dos
%   reglas por omisión de Rowe: el peatón sin señales ni flecha de frente
%   hace lo que haría un auto, y cualquiera avanza si no tiene que
%   detenerse. Las respuestas salen en orden de prioridad. Quien debe
%   llegar instanciado: la última regla lo usa dentro de \+.
accion_v1(S, auto, A) :-
    auto(S, A).
accion_v1(S, peaton, A) :-
    peaton(S, A).
accion_v1(S, peaton, A) :-
    \+ senales_peaton(S),
    \+ verde_de_frente(S),
    accion_v1(S, auto, A).
accion_v1(S, Quien, avanzar) :-
    \+ accion_v1(S, Quien, detenerse),
    \+ accion_v1(S, Quien, detenerse_y_avanzar).

% --- Versión 2: las reglas por omisión, solo por omisión ------------------

%!  especifica(+Situacion:list, ?Quien, ?Accion) is nondet.
%
%   Accion es legal para Quien en Situacion según una regla que mira las
%   luces.
especifica(S, auto, A) :-
    auto(S, A).
especifica(S, peaton, A) :-
    peaton(S, A).

%!  accion(+Situacion:list, +Quien, ?Accion) is nondet.
%
%   Accion es legal para Quien en Situacion: lo que dicen las reglas
%   específicas; si ninguna dice nada, el peatón sin señales ni flecha de
%   frente hace lo que haría un auto, y en cualquier otro caso se avanza.
accion(S, Quien, A) :-
    (   especifica(S, Quien, _)
    ->  especifica(S, Quien, A)
    ;   Quien == peaton,
        \+ senales_peaton(S),
        \+ verde_de_frente(S)
    ->  accion(S, auto, A)
    ;   A = avanzar
    ).

%!  decision(+Situacion:list, +Quien, -Accion) is semidet.
%
%   Accion es la acción recomendada a Quien en Situacion: la primera
%   legal, en el orden de prioridad de las reglas.
decision(S, Quien, A) :-
    once(accion(S, Quien, A)).

% --- La tabla de las luces solas ----------------------------------------

% vehicular(Tipo, Estado): una luz para los autos y uno de sus estados.
vehicular(Tipo, Estado) :-
    member(Tipo, [rojo, amarillo, verde]),
    member(Estado, [fija, intermitente]).
vehicular(Tipo, Estado) :-
    member(Tipo, [flecha_roja, flecha_amarilla, flecha_verde]),
    member(Estado, [izquierda, derecha]).

%!  tabla(+Quien, -Filas:list) is det.
%
%   Filas tiene una fila Luz-Frenar-Acciones por cada luz para los autos,
%   sola, con Frenar si o no según el auto pueda detenerse, y Acciones las
%   acciones legales para Quien, en orden de prioridad.
tabla(Quien, Filas) :-
    findall(luz(T, E)-F-As,
            ( vehicular(T, E),
              member(F, [si, no]),
              situacion(luz(T, E), F, S),
              findall(A, accion(S, Quien, A), As) ),
            Filas).

%!  situacion(+Luz, +Frenar, -Situacion:list) is det.
%
%   Situacion tiene solo Luz, y puede_frenar si Frenar es si.
situacion(Luz, si, [Luz, puede_frenar]).
situacion(Luz, no, [Luz]).
