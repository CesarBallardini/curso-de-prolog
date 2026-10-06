:- encoding(utf8).

% Capítulo 75 - Versión 1: el tablero y los tramos del rompecabezas del lazo.
%
% Un tablero rectangular tiene algunas casillas marcadas con un círculo o
% con un numeral. Se busca un lazo cerrado que pase de casilla en casilla
% en horizontal o en vertical, sin cruzarse, y que pase una vez por cada
% marca. Entre dos marcas consecutivas del lazo, la cuerda es un tramo:
% recto si las dos marcas son de la misma clase, y con un solo giro en
% ángulo recto si son de clases distintas. Un tramo no pasa por otras
% marcas. Una posición es Fila-Columna, desde 1-1 arriba a la izquierda;
% un tramo es la lista de las casillas que recorre después de la marca de
% salida, la de llegada incluida.
%
%?- marca(csenki1, P, circulo).
%?- tramo(csenki1, 1-4, Q, Celdas).
%?- findall(Q, tramo(csenki1, 3-5, Q, _), Qs).

% problema(Nombre, Filas, Columnas, Marcas): el tablero Nombre tiene Filas
% por Columnas casillas, y Marcas son sus marcas, circulo(Pos) o
% numeral(Pos). chico y cruz son ejemplos pequeños del curso; csenki1 y
% csenki2, los rompecabezas de Csenki, sección 2.8. Es multifile porque
% otras versiones agregan tableros derivados de estos.
:- multifile problema/4.

problema(chico, 3, 3, [circulo(1-1), circulo(1-3), numeral(3-2)]).
problema(cruz, 3, 3, [circulo(1-2), numeral(2-3), circulo(3-2), numeral(2-1)]).
problema(csenki1, 6, 6,
         [ circulo(1-4), circulo(3-5), circulo(4-2), circulo(6-6),
           numeral(1-6), numeral(2-1), numeral(2-2), numeral(4-1),
           numeral(5-5)
         ]).
problema(csenki2, 9, 8,
         [ numeral(1-1), numeral(1-6), numeral(1-8), circulo(2-7),
           numeral(3-6), numeral(3-8), circulo(4-2), circulo(5-3),
           circulo(5-7), numeral(6-4), numeral(6-5), numeral(7-6),
           circulo(8-2), circulo(8-7), circulo(9-1)
         ]).

%!  marca(+Nombre, ?Pos, ?Clase) is nondet.
%
%   En el tablero Nombre hay una marca de Clase, circulo o numeral, en Pos.
marca(Nombre, Pos, Clase) :-
    problema(Nombre, _, _, Marcas),
    member(Marca, Marcas),
    clase(Marca, Clase, Pos).

% clase(Marca, Clase, Pos): Marca es una marca de Clase en Pos.
clase(circulo(Pos), circulo, Pos).
clase(numeral(Pos), numeral, Pos).

%!  tramo(+Nombre, +P, ?Q, -Celdas:list) is nondet.
%
%   Celdas es un tramo del tablero Nombre que sale de la marca en P y
%   llega a la marca en Q, distinta de P, sin pasar por otras marcas:
%   recto si las dos marcas son de la misma clase, con un giro si no.
tramo(Nombre, P, Q, Celdas) :-
    marca(Nombre, P, ClaseP),
    marca(Nombre, Q, ClaseQ),
    Q \== P,
    (   ClaseP == ClaseQ
    ->  linea(P, Q, Celdas)
    ;   con_giro(P, Q, Celdas)
    ),
    sin_marcas_intermedias(Nombre, Celdas).

%!  linea(+P, +Q, -Celdas:list) is semidet.
%
%   Celdas son las casillas que van de P, excluida, a Q, incluida, por la
%   fila o la columna que comparten. Falla si P y Q no comparten fila ni
%   columna, o si son la misma casilla.
linea(F1-C1, F2-C2, Celdas) :-
    (   F1 =:= F2
    ->  C1 =\= C2,
        pasos(C1, C2, Cs),
        findall(F1-C, member(C, Cs), Celdas)
    ;   C1 =:= C2,
        pasos(F1, F2, Fs),
        findall(F-C1, member(F, Fs), Celdas)
    ).

%!  pasos(+A:integer, +B:integer, -Ns:list(integer)) is det.
%
%   Ns son los enteros que van de A, excluido, a B, incluido, en ese
%   orden; A y B son distintos.
pasos(A, B, Ns) :-
    (   A < B
    ->  A1 is A + 1,
        numlist(A1, B, Ns)
    ;   B1 is A - 1,
        numlist(B, B1, Ns0),
        reverse(Ns0, Ns)
    ).

%!  con_giro(+P, +Q, -Celdas:list) is nondet.
%
%   Celdas va de P a Q con un solo giro en ángulo recto: primero por la
%   fila de P hasta la columna de Q, o primero por la columna de P hasta
%   la fila de Q. P y Q no comparten fila ni columna.
con_giro(F1-C1, F2-C2, Celdas) :-
    F1 =\= F2,
    C1 =\= C2,
    member(Esquina, [F1-C2, F2-C1]),
    linea(F1-C1, Esquina, Antes),
    linea(Esquina, F2-C2, Despues),
    append(Antes, Despues, Celdas).

%!  sin_marcas_intermedias(+Nombre, +Celdas:list) is semidet.
%
%   Ninguna casilla de Celdas salvo la última tiene una marca del tablero
%   Nombre.
sin_marcas_intermedias(Nombre, Celdas) :-
    \+ ( append(Intermedias, [_], Celdas),
         member(Pos, Intermedias),
         marca(Nombre, Pos, _) ).
