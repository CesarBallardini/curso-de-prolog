:- encoding(utf8).

% Capítulo 22 - Soluciones de los ejercicios 12 y 13: el tablero como assoc.
%
% El tablero es el de buscaminas.pl. descubrir/4 es el ejercicio 12: el
% recorrido del capítulo 18 sobre el assoc. tablero_desde_texto/2 es el
% ejercicio 13: el inverso de mostrar/1.
%
%?- tablero(3, 4, [1-1, 2-3], T), descubrir(T, 3-1, [], D).
%?- tablero_desde_texto(["*211", "12*1", "0111"], T), valor(T, 2-2, V).

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

% --- Ejercicio 12 ---------------------------------------------------------

%!  descubrir(+Tablero, +Celda:pair, +Vistas:list, -Descubiertas:list) is det.
%
%   Descubiertas son las celdas de Vistas más las que descubre un clic en
%   Celda, que no tiene mina: la celda y, si su valor es 0, las que
%   descubren sus vecinas.
descubrir(Tablero, Celda, Vistas, Descubiertas) :-
    Tablero = tablero(Filas, Columnas, _),
    (   memberchk(Celda, Vistas)
    ->  Descubiertas = Vistas
    ;   valor(Tablero, Celda, 0)
    ->  findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
        foldl(descubrir(Tablero), Vecinas, [Celda|Vistas], Descubiertas)
    ;   Descubiertas = [Celda|Vistas]
    ).

% --- Ejercicio 13 ---------------------------------------------------------

%!  tablero_desde_texto(+Lineas:list(string), -Tablero) is det.
%
%   Tablero es el tablero que mostrar/1 escribe como Lineas: una cadena por
%   fila, con * en las minas y el número de minas vecinas en las demás.
tablero_desde_texto(Lineas, tablero(Filas, Columnas, Celdas)) :-
    length(Lineas, Filas),
    Lineas = [Primera|_],
    string_length(Primera, Columnas),
    findall((F-C)-Valor,
            ( nth1(F, Lineas, Linea),
              string_chars(Linea, Caracteres),
              nth1(C, Caracteres, Caracter),
              valor_de_caracter(Caracter, Valor) ),
            Pares),
    list_to_assoc(Pares, Celdas).

%!  valor_de_caracter(+Caracter, -Valor) is det.
%
%   Valor es mina para *, o el número que escribe el dígito Caracter.
valor_de_caracter('*', mina) :-
    !.
valor_de_caracter(Caracter, N) :-
    atom_number(Caracter, N).
