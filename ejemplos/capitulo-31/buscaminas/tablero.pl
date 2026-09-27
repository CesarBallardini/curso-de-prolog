:- encoding(utf8).

% Capítulo 31 - Buscaminas completo, módulo tablero: el tablero como assoc
% (capítulo 22).
%
% Un tablero es tablero(Filas, Columnas, Celdas): Celdas es un assoc de cada
% celda Fila-Columna a mina o a la cantidad de minas vecinas. tablero/4 lo
% construye a partir de las minas; tablero_al_azar/5 elige las minas con una
% semilla, que repite el mismo tablero.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- tablero(3, 3, [1-1], T), valor(T, 2-2, V).

:- module(tablero,
          [ tablero/4,
            tablero_al_azar/5,
            valor/3,
            cantidad_de_minas/2
          ]).

:- use_module(library(assoc)).
:- use_module(library(ordsets)).
:- use_module(library(random)).
:- use_module(library(error)).
:- use_module(vecinos).

%!  tablero(+Filas:integer, +Columnas:integer, +Minas:list, -Tablero) is det.
%
%   Tablero es el tablero de Filas por Columnas con minas en las celdas de
%   Minas, pares Fila-Columna.
tablero(Filas, Columnas, Minas, tablero(Filas, Columnas, Celdas)) :-
    list_to_ord_set(Minas, ConjuntoDeMinas),
    findall(F-C, ( between(1, Filas, F), between(1, Columnas, C) ), Todas),
    maplist(valor_inicial(Filas, Columnas, ConjuntoDeMinas), Todas, Valores),
    pairs_keys_values(Pares, Todas, Valores),
    list_to_assoc(Pares, Celdas).

%!  valor_inicial(+Filas:integer, +Columnas:integer, +Minas:list,
%!                +Celda:pair, -Valor) is det.
%
%   Valor es mina si Celda está en Minas, o la cantidad de minas vecinas.
valor_inicial(Filas, Columnas, Minas, Celda, Valor) :-
    (   ord_memberchk(Celda, Minas)
    ->  Valor = mina
    ;   minas_vecinas(Filas, Columnas, Minas, Celda, Valor)
    ).

%!  tablero_al_azar(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                  +Semilla:integer, -Tablero) is det.
%
%   Tablero tiene Cantidad minas en celdas elegidas al azar con Semilla.
%
%   @error type_error(positive_integer, X) si una dimensión o la cantidad
%          no es un entero positivo.
%   @error domain_error(cantidad_de_minas, Cantidad) si las minas no dejan
%          ninguna celda libre.
tablero_al_azar(Filas, Columnas, Cantidad, Semilla, Tablero) :-
    maplist(must_be(positive_integer), [Filas, Columnas, Cantidad]),
    must_be(integer, Semilla),
    Total is Filas * Columnas,
    (   Cantidad < Total
    ->  true
    ;   domain_error(cantidad_de_minas, Cantidad)
    ),
    set_random(seed(Semilla)),
    randseq(Cantidad, Total, Numeros),
    maplist(celda_numero(Columnas), Numeros, Minas),
    tablero(Filas, Columnas, Minas, Tablero).

%!  celda_numero(+Columnas:integer, +K:integer, -Celda:pair) is det.
%
%   Celda es la celda número K del tablero, contando por filas desde 1.
celda_numero(Columnas, K, F-C) :-
    F is (K - 1) // Columnas + 1,
    C is (K - 1) mod Columnas + 1.

%!  valor(+Tablero, +Celda:pair, -Valor) is semidet.
%
%   Valor es lo que hay en Celda. Falla si Celda está fuera del tablero.
valor(tablero(_, _, Celdas), Celda, Valor) :-
    get_assoc(Celda, Celdas, Valor).

%!  cantidad_de_minas(+Tablero, -N:integer) is det.
%
%   N es la cantidad de minas de Tablero.
cantidad_de_minas(tablero(_, _, Celdas), N) :-
    assoc_to_values(Celdas, Valores),
    include(==(mina), Valores, Minas),
    length(Minas, N).
