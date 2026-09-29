:- encoding(utf8).

% Capítulo 40 - Soluciones de los ejercicios 13 y 14 sobre el Buscaminas.
%
% deducir/4 agrega el total de minas del tablero: una configuración de las
% celdas que tocan números sirve si sus minas, más las que pueden estar en
% las demás celdas ocultas, alcanzan justo el total. partidas_ganadas/4
% juega con jugar/6 en tableros al azar, con semillas fijas.
%
% solo-local: carga buscaminas.pl con ensure_loaded/1, y SWISH no permite
% cargar otro archivo.
%
%?- tablero(chico, T), deducir(T, 2, Seguras, Minas).
%?- partidas_ganadas(6, 5, 20, N).

:- ensure_loaded(buscaminas).

% Ejercicio 13

%!  deducir(+Lineas:list(string), +Total:integer, -Seguras:list,
%!          -Minas:list) is semidet.
%
%   Como deducir/3, sabiendo además que el tablero tiene Total minas.
%   Seguras y Minas incluyen las celdas ocultas que no tocan ningún número.
%   Falla si ninguna configuración es compatible con Total.
deducir(Lineas, Total, Seguras, Minas) :-
    leer(Lineas, Ocultas, _),
    ocultas(Lineas, Todas),
    subtract(Todas, Ocultas, Libres),
    length(Libres, K),
    \+ \+ con_total(Lineas, Total, K, []),
    findall(C, ( member(C, Ocultas),
                 \+ con_total(Lineas, Total, K, [C-1]) ),
            Seguras0),
    findall(C, ( member(C, Ocultas),
                 \+ con_total(Lineas, Total, K, [C-0]) ),
            Minas0),
    (   Libres == []
    ->  Seguras = Seguras0,
        Minas = Minas0
    ;   \+ ( configuracion(Lineas, [], A), minas_de(A, M), M < Total,
             Total =< M + K )
    ->  append(Seguras0, Libres, Seguras1),
        sort(Seguras1, Seguras),
        Minas = Minas0
    ;   \+ ( configuracion(Lineas, [], A), minas_de(A, M), M > Total - K,
             M =< Total )
    ->  Seguras = Seguras0,
        append(Minas0, Libres, Minas1),
        sort(Minas1, Minas)
    ;   Seguras = Seguras0,
        Minas = Minas0
    ).

%!  con_total(+Lineas, +Total:integer, +K:integer, +Fijas:list) is semidet.
%
%   Hay una configuración con Fijas cuyas minas M cumplen
%   M =< Total =< M + K: las K celdas libres completan el total.
con_total(Lineas, Total, K, Fijas) :-
    configuracion(Lineas, Fijas, A),
    minas_de(A, M),
    M =< Total,
    Total =< M + K,
    !.

%!  minas_de(+Asignacion, -M:integer) is det.
%
%   M es la cantidad de celdas con mina en Asignacion.
minas_de(Asignacion, M) :-
    assoc_to_values(Asignacion, Bs),
    sum_list(Bs, M).

%!  ocultas(+Lineas:list(string), -Celdas:list) is det.
%
%   Celdas son todas las celdas ocultas de Lineas, en orden.
ocultas(Lineas, Celdas) :-
    findall(F-C, ( nth1(F, Lineas, Linea),
                   string_chars(Linea, Xs),
                   nth1(C, Xs, '#') ),
            Celdas).

% Ejercicio 14

%!  partidas_ganadas(+Lado:integer, +Cantidad:integer, +Semillas:integer,
%!                   -Ganadas:integer) is det.
%
%   Ganadas es la cantidad de partidas que jugar/6 gana sin adivinar, en
%   tableros de Lado x Lado con Cantidad minas elegidas al azar con las
%   semillas 1 a Semillas, empezando en la primera celda sin mina.
partidas_ganadas(Lado, Cantidad, Semillas, Ganadas) :-
    aggregate_all(count,
                  ( between(1, Semillas, Semilla),
                    minas_al_azar(Lado, Cantidad, Semilla, Minas),
                    findall(F-C, ( between(1, Lado, F),
                                   between(1, Lado, C) ),
                            Celdas),
                    once(( member(Inicio, Celdas),
                           \+ memberchk(Inicio, Minas) )),
                    jugar(Lado, Lado, Minas, Inicio, _, ganada) ),
                  Ganadas).

%!  minas_al_azar(+Lado:integer, +Cantidad:integer, +Semilla:integer,
%!                -Minas:list) is det.
%
%   Minas son Cantidad celdas distintas de un tablero de Lado x Lado,
%   elegidas al azar con Semilla.
minas_al_azar(Lado, Cantidad, Semilla, Minas) :-
    set_random(seed(Semilla)),
    findall(F-C, ( between(1, Lado, F), between(1, Lado, C) ), Celdas),
    random_permutation(Celdas, Mezcladas),
    length(Minas0, Cantidad),
    append(Minas0, _, Mezcladas),
    msort(Minas0, Minas).
