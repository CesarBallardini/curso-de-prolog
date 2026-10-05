:- encoding(utf8).

% Capítulo 44 - El puntaje y los turnos.
%
% Colossal Cave Adventure cuenta los turnos y da puntos por cada logro, y
% al terminar dice cuántos de los puntos posibles se obtuvieron y en
% cuántos turnos. Este archivo agrega lo mismo sobre estado.pl: jugada/2
% realiza una orden, cuenta el turno y registra los logros nuevos. Un
% logro es un hecho del estado que vale por primera vez; queda registrado
% aunque después deje de valer. logro/2 es multifile: otro archivo agrega
% logros con cláusulas puntaje:logro(...).
%
% solo-local: carga otros módulos, y SWISH no admite módulos propios.
%
%?- iniciar_puntaje, jugada(ir(biblioteca), _), jugada(tomar(llave), _), puntaje(P), turnos(T).
%?- iniciar_puntaje, informe(Texto).

:- module(puntaje,
          [ iniciar_puntaje/0,
            jugada/2,
            puntaje/1,
            turnos/1,
            rango/2,
            informe/1,
            maximo/1
          ]).

:- use_module(library(apply)).
:- use_module(library(aggregate)).
:- use_module(estado).

:- dynamic
    turnos/1,
    logrado/1.

% turnos(T): se jugaron T turnos.
% logrado(H): el logro H ya se obtuvo.

:- multifile
    logro/2.

% logro(H, Puntos): el hecho H del estado vale Puntos la primera vez que
% se cumple.
logro(esta_en(llave, jugador), 5).
logro(esta_en(linterna, jugador), 5).
logro(aqui(sotano), 10).
logro(esta_en(lente, jugador), 10).
logro(esta_en(lente, telescopio), 20).

%!  iniciar_puntaje is det.
%
%   Empieza una partida nueva, sin turnos ni logros.
iniciar_puntaje :-
    iniciar,
    retractall(turnos(_)),
    retractall(logrado(_)),
    assertz(turnos(0)).

%!  jugada(+Orden, -Respuesta) is det.
%
%   Realiza Orden con realizar/2, suma un turno y registra los logros que
%   se cumplen por primera vez.
jugada(Orden, Respuesta) :-
    realizar(Orden, Respuesta),
    retract(turnos(T0)),
    T is T0 + 1,
    assertz(turnos(T)),
    forall(nuevo_logro(H), assertz(logrado(H))).

%!  nuevo_logro(-H) is nondet.
%
%   H es un logro que se cumple en el estado actual y no estaba registrado.
nuevo_logro(H) :-
    logro(H, _),
    \+ logrado(H),
    call(estado:H).

%!  puntaje(-P:integer) is det.
%
%   P es la suma de los puntos de los logros registrados.
puntaje(P) :-
    aggregate_all(sum(N), ( logrado(H), logro(H, N) ), P).

%!  maximo(-P:integer) is det.
%
%   P es la suma de los puntos de todos los logros.
maximo(P) :-
    aggregate_all(sum(N), logro(_, N), P).

%!  rango(+P:integer, -Rango:string) is det.
%
%   Rango es el título que corresponde a P puntos: el del primer umbral
%   que P alcanza, de mayor a menor.
rango(P, Rango) :-
    once(( umbral(Minimo, Rango),
           P >= Minimo )).

% umbral(Minimo, Rango): con Minimo puntos o más se obtiene Rango.
umbral(50, "astrónomo").
umbral(30, "astrónomo aficionado").
umbral(10, "explorador").
umbral(0, "principiante").

%!  informe(-Texto:string) is det.
%
%   Texto es el informe del final de la partida, dirigido al jugador.
informe(Texto) :-
    puntaje(P),
    maximo(M),
    turnos(T),
    rango(P, Rango),
    format(string(Texto),
           "Obtuviste ~d de ~d puntos posibles en ~d turnos. \c
            Tu rango: ~s.",
           [P, M, T, Rango]).
