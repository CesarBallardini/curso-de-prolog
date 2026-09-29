:- encoding(utf8).

% Capítulo 40 - El Buscaminas como búsqueda.
%
% El tablero visible es el del capítulo 23: una cadena por fila, # en las
% celdas ocultas y el número de minas vecinas en las descubiertas. Una
% configuración asigna 0 o 1 (sin mina o con mina) a cada celda oculta que
% toca algún número, y es consistente si cada número tiene exactamente esa
% cantidad de minas vecinas. configuracion/3 la busca en profundidad: asigna
% las celdas de a una y abandona la rama en cuanto algún número ya no se
% puede cumplir. Una celda es segura si ninguna configuración le pone mina,
% y es una mina si ninguna la deja libre: es la deducción del capítulo 23,
% sin restricciones. jugar/6 encadena las deducciones: descubre una celda
% segura, lee el número que aparece, y vuelve a deducir, hasta descubrir
% todas las celdas sin mina o quedarse sin celdas seguras.
%
%?- tablero(chico, T), deducir(T, Seguras, Minas).
%?- jugar(4, 4, [1-1, 3-3], 1-4, Jugadas, Final).

:- use_module(library(assoc)).

% --- El tablero visible ---------------------------------------------------

% tablero(Nombre, Lineas): un tablero visible. chico es el del capítulo 23;
% grande es un tablero de 9 x 9 con 10 minas después de 30 jugadas de
% jugar/6.
tablero(chico, ["#100", "1211", "01##", "01##"]).
tablero(grande, ["01#112#10", "12111#210", "#10133311", "1101##2#1",
                 "0########", "#########", "#########", "#########",
                 "#########"]).

%!  leer(+Lineas:list(string), -Ocultas:list, -Numeros:list(pair)) is det.
%
%   Ocultas son las celdas Fila-Columna ocultas que tocan algún número, y
%   Numeros los pares N-Vecinas: un número N y sus vecinas ocultas.
leer(Lineas, Ocultas, Numeros) :-
    length(Lineas, Filas),
    Lineas = [Primera|_],
    string_length(Primera, Columnas),
    findall((F-C)-X,
            ( nth1(F, Lineas, Linea),
              string_chars(Linea, Xs),
              nth1(C, Xs, X) ),
            Celdas),
    findall(N-Vecinas,
            ( member(Celda-X, Celdas),
              atom_number(X, N),
              findall(V, ( vecina(Filas, Columnas, Celda, V),
                           memberchk(V-'#', Celdas) ),
                      Vecinas) ),
            Numeros),
    pairs_values(Numeros, Listas),
    append(Listas, Todas),
    sort(Todas, Ocultas).

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

% --- Las configuraciones --------------------------------------------------

%!  configuracion(+Lineas:list(string), +Fijas:list(pair), -Asignacion)
%!      is nondet.
%
%   Asignacion es un assoc de cada celda oculta que toca un número a 0 o 1,
%   consistente con los números de Lineas y con los pares Celda-B de
%   Fijas.
configuracion(Lineas, Fijas, Asignacion) :-
    leer(Lineas, Ocultas, Numeros),
    list_to_assoc(Fijas, Asignacion0),
    maplist(posible(Asignacion0), Numeros),
    asignar(Ocultas, Numeros, Asignacion0, Asignacion).

%!  asignar(+Celdas:list, +Numeros:list(pair), +Asignacion0, -Asignacion)
%!      is nondet.
%
%   Asignacion extiende Asignacion0 con un valor para cada celda de Celdas
%   que no lo tenga, y después de cada valor los Numeros se pueden cumplir.
asignar([], _, Asignacion, Asignacion).
asignar([Celda|Celdas], Numeros, Asignacion0, Asignacion) :-
    (   get_assoc(Celda, Asignacion0, _)
    ->  Asignacion1 = Asignacion0
    ;   member(B, [0, 1]),
        put_assoc(Celda, Asignacion0, B, Asignacion1),
        maplist(posible(Asignacion1), Numeros)
    ),
    asignar(Celdas, Numeros, Asignacion1, Asignacion).

%!  posible(+Asignacion, +Numero:pair) is semidet.
%
%   El Numero N-Vecinas todavía se puede cumplir: las vecinas con mina no
%   pasan de N, y con las que no tienen valor alcanzan a N.
posible(Asignacion, N-Vecinas) :-
    contar(Vecinas, Asignacion, 0, 0, Minas, Libres),
    Minas =< N,
    N =< Minas + Libres.

%!  contar(+Vecinas:list, +Asignacion, +M0, +L0, -Minas, -Libres) is det.
%
%   Minas es M0 más las Vecinas con mina en Asignacion, y Libres es L0 más
%   las que todavía no tienen valor.
contar([], _, Minas, Libres, Minas, Libres).
contar([V|Vs], Asignacion, M0, L0, Minas, Libres) :-
    (   get_assoc(V, Asignacion, B)
    ->  M1 is M0 + B,
        L1 = L0
    ;   M1 = M0,
        L1 is L0 + 1
    ),
    contar(Vs, Asignacion, M1, L1, Minas, Libres).

%!  deducir(+Lineas:list(string), -Seguras:list, -Minas:list) is semidet.
%
%   Seguras son las celdas ocultas que tocan un número y no tienen mina en
%   ninguna configuración; Minas, las que la tienen en todas. Falla si no
%   hay ninguna configuración.
deducir(Lineas, Seguras, Minas) :-
    configuracion(Lineas, [], _),
    !,
    leer(Lineas, Ocultas, _),
    findall(C, ( member(C, Ocultas),
                 \+ configuracion(Lineas, [C-1], _) ),
            Seguras),
    findall(C, ( member(C, Ocultas),
                 \+ configuracion(Lineas, [C-0], _) ),
            Minas).

% --- Una partida sin adivinar ---------------------------------------------

%!  jugar(+Filas:integer, +Columnas:integer, +Minas:list, +Inicio:pair,
%!        -Jugadas:list, -Final) is det.
%
%   Jugadas son las celdas descubiertas, en orden, empezando por Inicio,
%   que no tiene mina: cada una se dedujo segura con lo visible hasta ese
%   momento. Final es ganada si se descubrieron todas las celdas sin mina,
%   o trabada(Lineas) si quedan celdas y ninguna es segura.
jugar(Filas, Columnas, Minas, Inicio, [Inicio|Jugadas], Final) :-
    seguir(Filas, Columnas, Minas, [Inicio], Jugadas, Final).

%!  seguir(+Filas, +Columnas, +Minas:list, +Vistas:list, -Jugadas:list,
%!         -Final) is det.
%
%   Con Vistas descubiertas, Jugadas son las que siguen hasta Final.
seguir(Filas, Columnas, Minas, Vistas, Jugadas, Final) :-
    visible(Filas, Columnas, Minas, Vistas, Lineas),
    length(Vistas, NV),
    length(Minas, NM),
    (   NV + NM =:= Filas * Columnas
    ->  Jugadas = [],
        Final = ganada
    ;   deducir(Lineas, [Celda|_], _)
    ->  Jugadas = [Celda|Jugadas1],
        seguir(Filas, Columnas, Minas, [Celda|Vistas], Jugadas1, Final)
    ;   Jugadas = [],
        Final = trabada(Lineas)
    ).

%!  visible(+Filas:integer, +Columnas:integer, +Minas:list, +Vistas:list,
%!          -Lineas:list(string)) is det.
%
%   Lineas es el tablero visible con las celdas de Vistas descubiertas:
%   cada una muestra cuántas de sus vecinas están en Minas.
visible(Filas, Columnas, Minas, Vistas, Lineas) :-
    findall(Linea,
            ( between(1, Filas, F),
              findall(X, ( between(1, Columnas, C),
                           simbolo(Filas, Columnas, Minas, Vistas, F-C, X) ),
                      Xs),
              string_chars(Linea, Xs) ),
            Lineas).

%!  simbolo(+Filas, +Columnas, +Minas:list, +Vistas:list, +Celda, -X)
%!      is det.
%
%   X es lo que muestra Celda: # si está oculta, o su número de minas
%   vecinas si está en Vistas.
simbolo(Filas, Columnas, Minas, Vistas, Celda, X) :-
    (   memberchk(Celda, Vistas)
    ->  aggregate_all(count,
                      ( vecina(Filas, Columnas, Celda, V),
                        memberchk(V, Minas) ),
                      N),
        atom_number(X, N)
    ;   X = '#'
    ).
