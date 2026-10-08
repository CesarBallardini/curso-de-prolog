:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 11: el tablero del Buscaminas como
% módulo.
%
% El tablero como assoc, del capítulo 22. vecina/4 se exporta porque el
% módulo resolver la usa.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- tablero(3, 4, [1-1, 2-3], T), valor(T, 2-2, V).

:- module(tablero, [tablero/4, valor/3, vecina/4, mostrar/1]).

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

%!  valor(+Tablero, +Celda:pair, -Valor) is semidet.
%
%   Valor es lo que hay en Celda: mina o la cantidad de minas vecinas. Falla
%   si Celda está fuera del tablero.
valor(tablero(_, _, Celdas), Celda, Valor) :-
    get_assoc(Celda, Celdas, Valor).

%!  mostrar(+Tablero) is det.
%
%   Escribe el tablero completo, una fila por línea: * en las minas y el
%   número de minas vecinas en las demás celdas.
mostrar(tablero(Filas, Columnas, Celdas)) :-
    forall(between(1, Filas, F),
           ( forall(between(1, Columnas, C),
                    ( get_assoc(F-C, Celdas, V),
                      simbolo(V, S),
                      write(S) )),
             nl )).

%!  simbolo(+Valor, -Simbolo) is det.
%
%   Simbolo es el carácter con que se muestra Valor.
simbolo(mina, '*') :-
    !.
simbolo(N, N).
