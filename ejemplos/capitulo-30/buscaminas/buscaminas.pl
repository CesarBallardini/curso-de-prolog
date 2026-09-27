:- encoding(utf8).

% Capítulo 30 - Solución del ejercicio 14: las reglas del Buscaminas, sin
% cambios desde el capítulo 29.
%
% Las usan dos adaptadores: adaptador_prolog.py, con Janus, y servicio.pl,
% que las ofrece por HTTP al adaptador adaptador_http.py.
% Las reglas son las del juego de la terminal del capítulo 28: el tablero
% como assoc y el recorrido que descubre una región. El módulo exporta solo
% lo que usa Python. Una partida es el término juego(Tablero, Descubiertas,
% Marcadas); cruza a Python envuelta en prolog/1, y Python la devuelve en
% cada jugada sin mirarla. Las filas del tablero cruzan como textos.
%
% solo-local: SWISH no admite módulos propios ni ejecuta Python.
%
%?- nueva_partida_py(3, 3, [1-1], prolog(J)), filas_py(J, @(false), F).

:- module(buscaminas,
          [ nueva_partida_py/4,
            partida_al_azar_py/5,
            jugar_py/6,
            filas_py/3
          ]).

:- use_module(library(assoc)).
:- use_module(library(ordsets)).
:- use_module(library(random)).

% --- La interfaz para Python -------------------------------------------------

%!  nueva_partida_py(+Filas:integer, +Columnas:integer, +Minas:list,
%!                   -Partida) is det.
%
%   Partida es una partida nueva, envuelta en prolog/1, en un tablero con
%   minas en las celdas de Minas, pares Fila-Columna.
nueva_partida_py(Filas, Columnas, Minas, prolog(juego(Tablero, [], []))) :-
    tablero(Filas, Columnas, Minas, Tablero).

%!  partida_al_azar_py(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                     +Semilla:integer, -Partida) is det.
%
%   Partida es una partida nueva con Cantidad minas al azar, elegidas con
%   Semilla: la misma semilla da el mismo tablero.
partida_al_azar_py(Filas, Columnas, Cantidad, Semilla, Partida) :-
    set_random(seed(Semilla)),
    Total is Filas * Columnas,
    randseq(Cantidad, Total, Numeros),
    maplist(celda_numero(Columnas), Numeros, Minas),
    nueva_partida_py(Filas, Columnas, Minas, Partida).

%!  jugar_py(+Juego0, +Accion:atom, +Fila:integer, +Columna:integer,
%!           -Juego, -Estado:atom) is det.
%
%   Juego es Juego0 después de Accion, descubrir o marcar, en la celda
%   Fila-Columna, envuelto en prolog/1. Estado es sigue, gano, perdio, o
%   fuera si la celda está fuera del tablero; en ese caso, Juego es Juego0.
jugar_py(Juego0, Accion, Fila, Columna, prolog(Juego), Estado) :-
    Jugada =.. [Accion, Fila-Columna],
    (   aplicar(Jugada, Juego0, Juego1, Estado1)
    ->  Juego = Juego1,
        Estado = Estado1
    ;   Juego = Juego0,
        Estado = fuera
    ).

%!  filas_py(+Juego, +Minas, -Filas:list(string)) is det.
%
%   Filas son las filas del tablero de Juego como textos: el número de minas
%   vecinas en las celdas descubiertas, . si es cero, M en las marcadas y #
%   en las demás. Con Minas en @(true), el True de Python, las minas se
%   muestran con *.
filas_py(juego(tablero(Filas, Columnas, Celdas), D, M), Minas, Textos) :-
    findall(Texto,
            ( between(1, Filas, F),
              findall(S,
                      ( between(1, Columnas, C),
                        get_assoc(F-C, Celdas, V),
                        simbolo(F-C, V, D, M, Minas, S) ),
                      Simbolos),
              atomic_list_concat(Simbolos, Atomo),
              atom_string(Atomo, Texto) ),
            Textos).

% --- El tablero y las jugadas, del capítulo 28 ------------------------------

%!  tablero(+Filas:integer, +Columnas:integer, +Minas:list, -Tablero) is det.
%
%   Tablero es el tablero de Filas por Columnas con minas en las celdas de
%   Minas.
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
valor_inicial(Filas, Columnas, Minas, F-C, Valor) :-
    (   ord_memberchk(F-C, Minas)
    ->  Valor = mina
    ;   aggregate_all(count,
                      ( vecina(Filas, Columnas, F-C, V),
                        ord_memberchk(V, Minas) ),
                      Valor)
    ).

%!  vecina(+Filas:integer, +Columnas:integer, +Celda:pair, -Vecina:pair)
%!      is nondet.
%
%   Vecina es una de las celdas que rodean a Celda dentro del tablero.
vecina(Filas, Columnas, F-C, VF-VC) :-
    between(-1, 1, DF),
    between(-1, 1, DC),
    ( DF, DC ) \== ( 0, 0 ),
    VF is F + DF,
    VC is C + DC,
    between(1, Filas, VF),
    between(1, Columnas, VC).

%!  celda_numero(+Columnas:integer, +K:integer, -Celda:pair) is det.
%
%   Celda es la celda número K del tablero, contando por filas desde 1.
celda_numero(Columnas, K, F-C) :-
    F is (K - 1) // Columnas + 1,
    C is (K - 1) mod Columnas + 1.

%!  descubrir(+Tablero, +Celda:pair, +Vistas:list, -Descubiertas:list)
%!      is det.
%
%   Descubiertas es Vistas más las celdas que descubre un clic en Celda.
descubrir(Tablero, Celda, Vistas, Descubiertas) :-
    (   ord_memberchk(Celda, Vistas)
    ->  Descubiertas = Vistas
    ;   ord_add_element(Vistas, Celda, Vistas1),
        Tablero = tablero(Filas, Columnas, Celdas),
        (   get_assoc(Celda, Celdas, 0)
        ->  findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
            foldl(descubrir(Tablero), Vecinas, Vistas1, Descubiertas)
        ;   Descubiertas = Vistas1
        )
    ).

%!  aplicar(+Jugada, +Juego0, -Juego, -Estado) is semidet.
%
%   Juego es Juego0 después de Jugada, descubrir(Celda) o marcar(Celda).
%   Estado es sigue, gano o perdio. Falla si la celda está fuera del
%   tablero.
aplicar(descubrir(Celda), juego(T, D0, M), juego(T, D, M), Estado) :-
    T = tablero(_, _, Celdas),
    get_assoc(Celda, Celdas, Valor),
    (   Valor == mina
    ->  ord_add_element(D0, Celda, D),
        Estado = perdio
    ;   descubrir(T, Celda, D0, D),
        (   todas_descubiertas(T, D)
        ->  Estado = gano
        ;   Estado = sigue
        )
    ).
aplicar(marcar(Celda), juego(T, D, M0), juego(T, D, M), sigue) :-
    T = tablero(_, _, Celdas),
    get_assoc(Celda, Celdas, _),
    (   ord_memberchk(Celda, M0)
    ->  ord_del_element(M0, Celda, M)
    ;   ord_add_element(M0, Celda, M)
    ).

%!  todas_descubiertas(+Tablero, +Descubiertas:list) is semidet.
%
%   Descubiertas tiene todas las celdas libres de Tablero.
todas_descubiertas(tablero(Filas, Columnas, Celdas), Descubiertas) :-
    assoc_to_values(Celdas, Valores),
    include(==(mina), Valores, Minas),
    length(Minas, CantidadDeMinas),
    Libres is Filas * Columnas - CantidadDeMinas,
    length(Descubiertas, Libres).

%!  simbolo(+Celda, +Valor, +Descubiertas, +Marcadas, +Minas, -Simbolo)
%!      is det.
%
%   Simbolo es el carácter con que se muestra Celda.
simbolo(Celda, Valor, D, M, Minas, Simbolo) :-
    (   ord_memberchk(Celda, D)
    ->  visible(Valor, Simbolo)
    ;   Minas == @(true), Valor == mina
    ->  Simbolo = '*'
    ;   ord_memberchk(Celda, M)
    ->  Simbolo = 'M'
    ;   Simbolo = '#'
    ).

%!  visible(+Valor, -Simbolo) is det.
%
%   Simbolo muestra el Valor de una celda descubierta.
visible(mina, '*') :-
    !.
visible(0, '.') :-
    !.
visible(N, N).
