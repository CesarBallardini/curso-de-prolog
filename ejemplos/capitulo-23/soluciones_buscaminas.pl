:- encoding(utf8).

% Capítulo 23 - Soluciones de los ejercicios 12 y 13: el Buscaminas.
%
% El modelo es el de buscaminas.pl. probabilidades/2 es el ejercicio 12: la
% probabilidad de mina de cada celda oculta, contando soluciones.
% consistente/1 es el ejercicio 13.
%
%?- probabilidades(["#100", "1211", "01##", "01##"], P).
%?- consistente(["##1#", "1211", "0000"]).

:- use_module(library(clpfd)).

%!  deducir(+Lineas:list(string), -Seguras:list, -Minas:list) is det.
%
%   Seguras son las celdas ocultas que no tienen mina en ninguna solución, y
%   Minas las que la tienen en todas, sin conocer el total de minas.
deducir(Lineas, Seguras, Minas) :-
    modelo(Lineas, Ocultas),
    clasificar(Ocultas, Seguras, Minas).

%!  deducir(+Lineas:list(string), +Total:integer, -Seguras:list,
%!          -Minas:list) is det.
%
%   Como deducir/3, sabiendo además que el tablero tiene Total minas.
deducir(Lineas, Total, Seguras, Minas) :-
    modelo(Lineas, Ocultas),
    pairs_values(Ocultas, Bs),
    sum(Bs, #=, Total),
    clasificar(Ocultas, Seguras, Minas).

%!  modelo(+Lineas:list(string), -Ocultas:list(pair)) is semidet.
%
%   Ocultas son pares Celda-B, uno por celda oculta, con B en 0..1 y
%   restringido por los números de las celdas descubiertas.
%   Falla si algún número no se puede cumplir.
modelo(Lineas, Ocultas) :-
    length(Lineas, Filas),
    Lineas = [Primera|_],
    string_length(Primera, Columnas),
    findall((F-C)-X,
            ( nth1(F, Lineas, Linea),
              string_chars(Linea, Cs),
              nth1(C, Cs, X) ),
            Celdas),
    findall(Celda-_, member(Celda-'#', Celdas), Ocultas),
    pairs_values(Ocultas, Bs),
    Bs ins 0..1,
    findall(Celda-N, ( member(Celda-X, Celdas),
                       atom_number(X, N) ), Numeros),
    maplist(restringir(Filas, Columnas, Ocultas), Numeros).

%!  restringir(+Filas, +Columnas, +Ocultas:list(pair), +Numero:pair)
%!      is semidet.
%
%   Numero es Celda-N: las celdas ocultas vecinas de Celda suman N minas.
%   Falla si las restricciones ya planteadas excluyen esa suma.
restringir(Filas, Columnas, Ocultas, Celda-N) :-
    findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
    convlist(variable_de(Ocultas), Vecinas, Bs),
    sum(Bs, #=, N).

%!  variable_de(+Ocultas:list(pair), +Celda:pair, -B) is semidet.
%
%   B es la variable de Celda en Ocultas. Falla si Celda no está oculta. Las
%   variables se buscan con memberchk/2, fuera de findall/3, que copiaría
%   las variables en lugar de devolver las mismas.
variable_de(Ocultas, Celda, B) :-
    memberchk(Celda-B, Ocultas).

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

%!  clasificar(+Ocultas:list(pair), -Seguras:list, -Minas:list) is det.
%
%   Seguras son las celdas que no pueden tener mina, y Minas las que no
%   pueden no tenerla, según las restricciones de Ocultas.
clasificar(Ocultas, Seguras, Minas) :-
    pairs_values(Ocultas, Bs),
    findall(C, ( member(C-B, Ocultas),
                 \+ ( B = 1, label(Bs) ) ), Seguras),
    findall(C, ( member(C-B, Ocultas),
                 \+ ( B = 0, label(Bs) ) ), Minas).

% --- Ejercicio 12 ---------------------------------------------------------

%!  probabilidades(+Lineas:list(string), -Pares:list(pair)) is semidet.
%
%   Pares tiene un par Celda-P por cada celda oculta: P es la fracción de las
%   soluciones del tablero en las que Celda tiene mina. Falla si el tablero
%   no tiene ninguna solución.
probabilidades(Lineas, Pares) :-
    modelo(Lineas, Ocultas),
    pairs_values(Ocultas, Bs),
    findall(Bs, label(Bs), Soluciones),
    length(Soluciones, Total),
    Total > 0,
    pairs_keys(Ocultas, Celdas),
    transpose(Soluciones, PorCelda),
    maplist({Total}/[Celda, Valores, Celda-P]>>( sum_list(Valores, Minas),
                                                P is Minas / Total ),
            Celdas, PorCelda, Pares).

% --- Ejercicio 13 ---------------------------------------------------------

%!  consistente(+Lineas:list(string)) is semidet.
%
%   Los números de Lineas se pueden cumplir: hay al menos una ubicación de
%   las minas en las celdas ocultas que da esos números.
consistente(Lineas) :-
    modelo(Lineas, Ocultas),
    pairs_values(Ocultas, Bs),
    once(label(Bs)).
