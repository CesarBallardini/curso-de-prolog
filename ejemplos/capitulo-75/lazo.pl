:- encoding(utf8).

% Capítulo 75 - Versión 2: el lazo como búsqueda.
%
% El lazo se arma tramo por tramo con la búsqueda en profundidad limitada
% del capítulo 40: profundizacion.pl no es un módulo, así que se carga con
% load_files/2 en el módulo limitada40, sin copiarlo, después de declarar
% multifile sus predicados inicial/2, meta/2 y sucesor/5, y este archivo
% les agrega el problema lazo(Red). Red reúne lo que la búsqueda consulta
% en cada paso: la semilla, la marca donde el lazo empieza y termina; el
% límite, tantos tramos como marcas; y, para cada marca, sus tramos ya
% calculados, cada uno con la máscara de sus casillas, un entero con un
% bit por casilla del tablero. Un estado es e(Actual, Pendientes, Usadas):
% la cuerda llegó a la marca Actual, faltan las marcas de Pendientes y
% Usadas es la máscara de las casillas ocupadas. Las cláusulas de las
% jarras del capítulo 40 siguen ahí y no se usan.
%
% solo-local: carga archivos de otro capítulo.
%
%?- lazos(csenki1, 1-4, Lazos), length(Lazos, N).
%?- planes(csenki1, 1-4, [Plan|_]).

:- ensure_loaded(tramos).
:- use_module(library(assoc)).
:- use_module(library(ordsets)).

:- multifile
    limitada40:inicial/2,
    limitada40:meta/2,
    limitada40:sucesor/5.

:- load_files(limitada40:'../capitulo-40/profundizacion', []).

limitada40:inicial(lazo(Red), Estado) :-
    estado_inicial(Red, Estado).
limitada40:meta(lazo(_), cerrado(_)).
limitada40:sucesor(lazo(Red), Estado, Tramo, Siguiente, 1) :-
    avanzar(Red, Estado, Tramo, Siguiente).

%!  bit(+Columnas:integer, +Pos, -Bit:integer) is det.
%
%   Bit es el entero con un solo bit encendido, el de la casilla Pos en un
%   tablero de Columnas columnas: las casillas se numeran por filas desde 0.
bit(Columnas, F-C, Bit) :-
    Bit is 1 << ((F - 1) * Columnas + C - 1).

%!  mascara(+Columnas:integer, +Celdas:list, -Mascara:integer) is det.
%
%   Mascara tiene encendidos los bits de las casillas de Celdas.
mascara(Columnas, Celdas, Mascara) :-
    foldl(sumar_bit(Columnas), Celdas, 0, Mascara).

%!  sumar_bit(+Columnas:integer, +Pos, +M0:integer, -M:integer) is det.
%
%   M es M0 con el bit de Pos encendido.
sumar_bit(Columnas, Pos, M0, M) :-
    bit(Columnas, Pos, Bit),
    M is M0 \/ Bit.

%!  red(+Nombre, +Semilla, -Red) is det.
%
%   Red es red(Semilla, BitSemilla, Limite, Tramos) para el tablero Nombre:
%   Limite es la cantidad de marcas y Tramos asocia cada marca con la lista
%   de sus tramos de salida, t(Llegada, Celdas, Mascara).
red(Nombre, Semilla, red(Semilla, BitSemilla, Limite, Tramos)) :-
    problema(Nombre, _, Columnas, Marcas),
    length(Marcas, Limite),
    bit(Columnas, Semilla, BitSemilla),
    findall(P-Salidas,
            ( marca(Nombre, P, _),
              findall(t(Q, Celdas, M),
                      ( tramo(Nombre, P, Q, Celdas),
                        mascara(Columnas, Celdas, M) ),
                      Salidas) ),
            Pares),
    list_to_assoc(Pares, Tramos).

%!  estado_inicial(+Red, -Estado) is det.
%
%   Estado es el de la cuerda que todavía no salió de la semilla: faltan
%   las demás marcas y solo la semilla está ocupada.
estado_inicial(red(Semilla, BitSemilla, _, Tramos), e(Semilla, Pendientes, BitSemilla)) :-
    assoc_to_keys(Tramos, Marcas),
    ord_del_element(Marcas, Semilla, Pendientes).

%!  avanzar(+Red, +Estado, -Celdas:list, -Siguiente) is nondet.
%
%   Siguiente es el estado después de agregar el tramo Celdas, que sale de
%   la marca actual y no toca casillas ocupadas. Si faltan marcas, el tramo
%   llega a una de ellas; si no, vuelve a la semilla y Siguiente es
%   cerrado(Usadas).
avanzar(red(Semilla, BitSemilla, _, Tramos), e(Actual, Pendientes, Usadas),
        Celdas, Siguiente) :-
    get_assoc(Actual, Tramos, Salidas),
    (   Pendientes == []
    ->  member(t(Llegada, Celdas, M), Salidas),
        Llegada == Semilla,
        (M /\ \ BitSemilla) /\ Usadas =:= 0,
        Usadas1 is Usadas \/ M,
        Siguiente = cerrado(Usadas1)
    ;   member(t(Q, Celdas, M), Salidas),
        M /\ Usadas =:= 0,
        ord_selectchk(Q, Pendientes, Pendientes1),
        Usadas1 is Usadas \/ M,
        Siguiente = e(Q, Pendientes1, Usadas1)
    ).

%!  planes(+Nombre, +Semilla, -Planes:list) is det.
%
%   Planes son todos los planes de la búsqueda limitada del capítulo 40
%   que cierran un lazo en el tablero Nombre a partir de la marca Semilla:
%   cada plan es la lista de sus tramos, uno por marca.
planes(Nombre, Semilla, Planes) :-
    red(Nombre, Semilla, Red),
    Red = red(_, _, Limite, _),
    findall(Plan, limitada40:con_limite(lazo(Red), Limite, Plan), Planes).

%!  lazo_de_plan(+Semilla, +Plan:list, -Lazo:list) is det.
%
%   Lazo es la lista de las casillas del lazo de Plan, empezando por
%   Semilla y sin repetirla al final.
lazo_de_plan(Semilla, Plan, [Semilla|Casillas]) :-
    append(Plan, Todas),
    sin_ultima(Todas, Casillas).

%!  sin_ultima(+Lista:list, -Resto:list) is semidet.
%
%   Resto es Lista sin su último elemento. Falla si Lista está vacía.
sin_ultima([X|Xs], Resto) :-
    sin_ultima(Xs, X, Resto).

%!  sin_ultima(+Xs:list, +X, -Resto:list) is det.
%
%   Resto es [X|Xs] sin su último elemento. La indexación por el primer
%   argumento distingue la lista vacía y no deja alternativas pendientes.
sin_ultima([], _, []).
sin_ultima([Y|Ys], X, [X|Resto]) :-
    sin_ultima(Ys, Y, Resto).

%!  lazos(+Nombre, ?Semilla, -Lazos:list) is nondet.
%
%   Lazos son los lazos del tablero Nombre que empiezan en la marca
%   Semilla, en el orden en que la búsqueda los halla. Con Semilla libre,
%   recorre las marcas.
lazos(Nombre, Semilla, Lazos) :-
    marca(Nombre, Semilla, _),
    lazos_desde(Nombre, Semilla, Lazos).

%!  lazos_desde(+Nombre, +Semilla, -Lazos:list) is det.
%
%   Lazos son los lazos del tablero Nombre que empiezan en la marca
%   Semilla, en el orden en que la búsqueda los halla.
lazos_desde(Nombre, Semilla, Lazos) :-
    planes(Nombre, Semilla, Planes),
    maplist(lazo_de_plan(Semilla), Planes, Lazos).
