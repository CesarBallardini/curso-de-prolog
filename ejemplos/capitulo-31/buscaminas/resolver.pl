:- encoding(utf8).

% Capítulo 31 - Buscaminas completo, módulo resolver: deducir dónde están
% las minas (capítulo 23).
%
% Recibe el tablero visible, una cadena por fila: # u M en las celdas
% ocultas, . en las descubiertas sin minas vecinas y el número de minas
% vecinas en las demás. Cada celda oculta tiene una variable, 1 si tiene
% mina y 0 si no, y cada número exige que sus vecinas ocultas sumen ese
% número. Una celda es segura si ninguna solución le pone una mina.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- deducir(["#1.", "11.", "..."], Seguras, Minas).

:- module(resolver,
          [ deducir/3
          ]).

:- use_module(library(clpfd)).
:- use_module(vecinos).

%!  deducir(+Lineas:list(string), -Seguras:list, -Minas:list) is det.
%
%   Seguras son las celdas ocultas que no tienen mina en ninguna solución, y
%   Minas las que la tienen en todas. Si el tablero no tiene solución, las
%   dos son la lista vacía.
deducir(Lineas, Seguras, Minas) :-
    (   modelo(Lineas, Ocultas)
    ->  clasificar(Ocultas, Seguras, Minas)
    ;   Seguras = [],
        Minas = []
    ).

%!  modelo(+Lineas:list(string), -Ocultas:list(pair)) is semidet.
%
%   Ocultas son pares Celda-B, uno por celda oculta, con B en 0..1 y
%   restringido por los números de las celdas descubiertas. Falla si algún
%   número no se puede cumplir.
modelo(Lineas, Ocultas) :-
    length(Lineas, Filas),
    Lineas = [Primera|_],
    string_length(Primera, Columnas),
    findall((F-C)-X,
            ( nth1(F, Lineas, Linea),
              string_chars(Linea, Cs),
              nth1(C, Cs, X) ),
            Celdas),
    findall(Celda-_, ( member(Celda-X, Celdas), oculta(X) ), Ocultas),
    pairs_values(Ocultas, Bs),
    Bs ins 0..1,
    findall(Celda-N, ( member(Celda-X, Celdas), numero(X, N) ), Numeros),
    maplist(restringir(Filas, Columnas, Ocultas), Numeros).

%!  oculta(+Simbolo:atom) is semidet.
%
%   Simbolo es el de una celda oculta: sin marcar o marcada.
oculta('#').
oculta('M').

%!  numero(+Simbolo:atom, -N:integer) is semidet.
%
%   N es la cantidad de minas vecinas que muestra Simbolo; . es 0.
numero('.', 0) :-
    !.
numero(Simbolo, N) :-
    atom_number(Simbolo, N).

%!  restringir(+Filas, +Columnas, +Ocultas:list(pair), +Numero:pair)
%!      is semidet.
%
%   Numero es Celda-N: las celdas ocultas vecinas de Celda suman N minas.
restringir(Filas, Columnas, Ocultas, Celda-N) :-
    findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
    convlist(variable_de(Ocultas), Vecinas, Bs),
    sum(Bs, #=, N).

%!  variable_de(+Ocultas:list(pair), +Celda:pair, -B) is semidet.
%
%   B es la variable de Celda en Ocultas. Falla si Celda no está oculta.
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
