:- encoding(utf8).

% Capítulo 31 - Buscaminas completo, módulo descubrir: descubrir una región
% (capítulo 18).
%
% Al descubrir una celda sin minas vecinas, se descubren también sus
% vecinas, y así mientras aparezcan celdas sin minas vecinas. foldl/4
% recorre las vecinas con el conjunto de las celdas ya descubiertas como
% valor acumulado, que además evita volver a visitar una celda.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- tablero(3, 3, [1-1], T), descubrir(T, 3-3, [], D).

:- module(descubrir,
          [ descubrir/4
          ]).

:- use_module(library(ordsets)).
:- use_module(tablero).
:- use_module(vecinos).

%!  descubrir(+Tablero, +Celda:pair, +Vistas:list, -Descubiertas:list)
%!      is det.
%
%   Descubiertas es el conjunto ordenado Vistas más las celdas que descubre
%   un clic en Celda, una celda sin mina: la celda, y si no tiene minas
%   vecinas, las que descubren sus vecinas.
descubrir(Tablero, Celda, Vistas, Descubiertas) :-
    (   ord_memberchk(Celda, Vistas)
    ->  Descubiertas = Vistas
    ;   ord_add_element(Vistas, Celda, Vistas1),
        (   valor(Tablero, Celda, 0)
        ->  Tablero = tablero(Filas, Columnas, _),
            findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
            foldl(descubrir(Tablero), Vecinas, Vistas1, Descubiertas)
        ;   Descubiertas = Vistas1
        )
    ).
