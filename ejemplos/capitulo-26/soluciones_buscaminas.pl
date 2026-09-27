:- encoding(utf8).

% Capítulo 26 - Solución del ejercicio 11: probar lo que usa el azar.
%
% El tablero del capítulo 21. Las pruebas, en soluciones_buscaminas.plt, fijan
% la semilla para comparar con un resultado conocido, y recorren muchas
% semillas para comprobar propiedades que valen para cualquier tablero.
%
%?- tablero_al_azar(5, 5, 4, T), valor(T, 1-1, V).

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

%!  minas_al_azar(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                -Minas:list) is det.
%
%   Minas son Cantidad celdas distintas del tablero, elegidas al azar, en
%   orden.
minas_al_azar(Filas, Columnas, Cantidad, Minas) :-
    Total is Filas * Columnas,
    randseq(Cantidad, Total, Numeros),
    maplist(celda_numero(Columnas), Numeros, Celdas),
    sort(Celdas, Minas).

%!  celda_numero(+Columnas:integer, +K:integer, -Celda:pair) is det.
%
%   Celda es la celda número K del tablero, contando por filas desde 1.
celda_numero(Columnas, K, F-C) :-
    F is (K - 1) // Columnas + 1,
    C is (K - 1) mod Columnas + 1.

%!  tablero_al_azar(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                  -Tablero) is det.
%
%   Tablero es un tablero de Filas por Columnas con Cantidad minas al azar.
tablero_al_azar(Filas, Columnas, Cantidad, Tablero) :-
    minas_al_azar(Filas, Columnas, Cantidad, Minas),
    tablero(Filas, Columnas, Minas, Tablero).
