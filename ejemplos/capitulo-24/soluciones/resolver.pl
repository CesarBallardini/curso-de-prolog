:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 11: la deducción del Buscaminas como
% módulo.
%
% El modelo de restricciones del capítulo 22. Usa vecina/4 del módulo
% tablero en lugar de definir la suya.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- deducir(["#100", "1211", "01##", "01##"], Seguras, Minas).

:- module(resolver, [deducir/3, deducir/4]).

:- use_module(library(clpfd)).
:- use_module(tablero, [vecina/4]).

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

%!  modelo(+Lineas:list(string), -Ocultas:list(pair)) is det.
%
%   Ocultas son pares Celda-B, uno por celda oculta, con B en 0..1 y
%   restringido por los números de las celdas descubiertas.
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
%   Falla si ya se sabe que no pueden sumarlas.
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
