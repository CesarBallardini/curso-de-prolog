:- encoding(utf8).

% Capítulo 36 - Soluciones de los ejercicios 4 y 5 sobre el Buscaminas a
% pantalla completa: el estado a la derecha del tablero, y la tecla ? que
% lleva el cursor a una celda segura.
%
% paso/3 de buscaminas_pantalla.pl no se modifica: paso_con_sugerencia/3
% atiende la tecla nueva y deja las demás a paso/3, que es lo mismo que
% agregar su cláusula al principio de paso/3.
%
% solo-local: SWISH no admite módulos propios.
%
%?- paso_con_sugerencia(letra(q), J0, J).

:- module(soluciones_buscaminas,
          [ pantalla_al_lado/2,
            paso_con_sugerencia/3
          ]).

:- use_module(buscaminas_pantalla).
:- use_module(soluciones_pantalla, [lado_a_lado/3]).
:- use_module('../../capitulo-31/buscaminas/partida').

%!  pantalla_al_lado(+Juego, -Lineas:list(string)) is det.
%
%   Lineas es la pantalla de pantalla/2 con la caja del estado a la
%   derecha de la del tablero, y la ayuda debajo.
pantalla_al_lado(Juego, Lineas) :-
    pantalla(Juego, Todas),
    append(Arriba, [Abajo|Resto], Todas),
    sub_string(Abajo, 0, 1, _, "└"),
    !,
    append(Arriba, [Abajo], Tablero),
    once(append(Estado, [Ayuda], Resto)),
    lado_a_lado(Tablero, Estado, Juntas),
    append(Juntas, [Ayuda], Lineas).

%!  paso_con_sugerencia(+Tecla, +Juego0, -Juego) is det.
%
%   Como paso/3, y además la tecla ? lleva el cursor a la celda que da
%   sugerencia/2; si no hay ninguna segura, el juego no cambia.
paso_con_sugerencia(letra(?), juego(P, Cursor0, Pedido),
                    juego(P, Cursor, Pedido)) :-
    !,
    (   sugerencia(P, Celda)
    ->  Cursor = Celda
    ;   Cursor = Cursor0
    ).
paso_con_sugerencia(Tecla, Juego0, Juego) :-
    paso(Tecla, Juego0, Juego).
