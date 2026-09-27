:- encoding(utf8).

% Capítulo 31 - Buscaminas completo, módulo partida: el estado de una
% partida y sus jugadas.
%
% Una partida es partida(Tablero, Descubiertas, Marcadas, Estado): las
% celdas descubiertas y las marcadas son conjuntos ordenados, y Estado es
% sigue, gano o perdio. Las jugadas no modifican nada: dan la partida
% siguiente. Una jugada imposible produce un error ISO, no una falla. La
% terminal y el servicio usan este módulo, y solo este.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- partida_con_minas(3, 3, [1-1], P0), jugar(descubrir, 3-3, P0, P),
%   estado(P, E).

:- module(partida,
          [ nueva_partida/5,
            partida_con_minas/4,
            jugar/4,
            estado/2,
            dimensiones/3,
            minas_restantes/2,
            filas/3,
            sugerencia/2
          ]).

:- use_module(library(ordsets)).
:- use_module(library(error)).
:- use_module(tablero).
:- use_module(descubrir).
:- use_module(resolver).

%!  nueva_partida(+Filas:integer, +Columnas:integer, +Minas:integer,
%!                +Semilla:integer, -Partida) is det.
%
%   Partida empieza con Minas minas al azar, elegidas con Semilla.
%
%   @error los de tablero_al_azar/5.
nueva_partida(Filas, Columnas, Minas, Semilla,
              partida(Tablero, [], [], sigue)) :-
    tablero_al_azar(Filas, Columnas, Minas, Semilla, Tablero).

%!  partida_con_minas(+Filas:integer, +Columnas:integer, +Minas:list,
%!                    -Partida) is det.
%
%   Partida empieza con minas en las celdas de Minas: para las pruebas.
partida_con_minas(Filas, Columnas, Minas, partida(Tablero, [], [], sigue)) :-
    tablero(Filas, Columnas, Minas, Tablero).

%!  jugar(+Accion:atom, +Celda:pair, +Partida0, -Partida) is det.
%
%   Partida es Partida0 después de Accion, descubrir o marcar, en Celda.
%   Marcar una celda marcada le quita la marca.
%
%   @error domain_error(accion, Accion) si no es descubrir ni marcar.
%   @error domain_error(partida_en_curso, Estado) si la partida terminó.
%   @error domain_error(celda_del_tablero, Celda) si la celda no existe.
jugar(Accion, Celda, partida(T, D0, M0, Estado0), Partida) :-
    (   memberchk(Accion, [descubrir, marcar])
    ->  true
    ;   domain_error(accion, Accion)
    ),
    (   Estado0 == sigue
    ->  true
    ;   domain_error(partida_en_curso, Estado0)
    ),
    (   valor(T, Celda, Valor)
    ->  true
    ;   domain_error(celda_del_tablero, Celda)
    ),
    aplicar(Accion, Celda, Valor, partida(T, D0, M0, Estado0), Partida).

%!  aplicar(+Accion, +Celda, +Valor, +Partida0, -Partida) is det.
%
%   Aplica una jugada válida.
aplicar(descubrir, Celda, mina, partida(T, D0, M, _), partida(T, D, M, perdio)) :-
    !,
    ord_add_element(D0, Celda, D).
aplicar(descubrir, Celda, _, partida(T, D0, M, _), partida(T, D, M, Estado)) :-
    descubrir(T, Celda, D0, D),
    T = tablero(Filas, Columnas, _),
    cantidad_de_minas(T, Minas),
    length(D, Descubiertas),
    (   Descubiertas =:= Filas * Columnas - Minas
    ->  Estado = gano
    ;   Estado = sigue
    ).
aplicar(marcar, Celda, _, partida(T, D, M0, E), partida(T, D, M, E)) :-
    (   ord_memberchk(Celda, M0)
    ->  ord_del_element(M0, Celda, M)
    ;   ord_add_element(M0, Celda, M)
    ).

%!  estado(+Partida, -Estado:atom) is det.
%
%   Estado es sigue, gano o perdio.
estado(partida(_, _, _, Estado), Estado).

%!  dimensiones(+Partida, -Filas:integer, -Columnas:integer) is det.
%
%   Filas y Columnas son las dimensiones del tablero de Partida.
dimensiones(partida(tablero(Filas, Columnas, _), _, _, _), Filas, Columnas).

%!  minas_restantes(+Partida, -N:integer) is det.
%
%   N es la cantidad de minas menos la de celdas marcadas.
minas_restantes(partida(T, _, M, _), N) :-
    cantidad_de_minas(T, Minas),
    length(M, Marcadas),
    N is Minas - Marcadas.

%!  filas(+Partida, +Minas:boolean, -Filas:list(string)) is det.
%
%   Filas son las filas del tablero, un carácter por celda: el número de
%   minas vecinas en las descubiertas, . si es cero, M en las marcadas y #
%   en las demás. Con Minas en true, las minas se muestran con *.
filas(partida(tablero(Filas, Columnas, Celdas), D, M, _), Minas, Textos) :-
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

%!  simbolo(+Celda, +Valor, +Descubiertas, +Marcadas, +Minas:boolean,
%!          -Simbolo) is det.
%
%   Simbolo es el carácter con que se muestra Celda.
simbolo(Celda, Valor, D, M, Minas, Simbolo) :-
    (   ord_memberchk(Celda, D)
    ->  visible(Valor, Simbolo)
    ;   Minas == true, Valor == mina
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

%!  sugerencia(+Partida, -Celda:pair) is semidet.
%
%   Celda es una celda oculta sin marcar que, según lo que se ve del
%   tablero, no puede tener una mina. Falla si no hay ninguna segura.
sugerencia(Partida, Celda) :-
    filas(Partida, false, Filas),
    deducir(Filas, Seguras, _),
    Partida = partida(_, _, Marcadas, sigue),
    member(Celda, Seguras),
    \+ ord_memberchk(Celda, Marcadas),
    !.
