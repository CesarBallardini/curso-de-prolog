:- encoding(utf8).

% Capítulo 75 - Versión 4: el lazo a la vista.
%
% El dibujo sigue el patrón de modelo de pantalla del capítulo 36:
% lineas/3 es puro y da las líneas de texto; solo mostrar/2 escribe. Cada
% casilla ocupa un carácter: O y # para las marcas, una esquina o un trazo
% para las casillas por las que pasa la cuerda y un punto para las demás.
% Entre dos casillas vecinas unidas por la cuerda va un trazo horizontal o
% vertical. Las aristas del lazo, pares de casillas consecutivas, se
% guardan en un conjunto ordenado.
%
% solo-local: carga unico.pl, que carga archivos de otro capítulo.
%
%?- dibujar(csenki1).
%?- mostrar(csenki2, []).

:- ensure_loaded(unico).
:- use_module(library(ordsets)).

%!  aristas(+Lazo:list, -Aristas:list) is det.
%
%   Aristas es el conjunto ordenado de los pares P-Q, con P @< Q, de
%   casillas consecutivas de Lazo, incluido el par que lo cierra.
aristas([], []).
aristas([Primera|Resto], Aristas) :-
    append([Primera|Resto], [Primera], Cerrado),
    pares(Cerrado, Pares),
    sort(Pares, Aristas).

%!  pares(+Casillas:list, -Pares:list) is det.
%
%   Pares son los pares ordenados de casillas consecutivas de Casillas.
pares([P|Ps], Pares) :-
    pares(Ps, P, Pares).

%!  pares(+Casillas:list, +Anterior, -Pares:list) is det.
%
%   Pares son los pares ordenados de casillas consecutivas de
%   [Anterior|Casillas]. La indexación por el primer argumento distingue
%   la lista vacía y no deja alternativas pendientes.
pares([], _, []).
pares([Q|Qs], P, [Par|Pares]) :-
    (   P @< Q
    ->  Par = P-Q
    ;   Par = Q-P
    ),
    pares(Qs, Q, Pares).

%!  lineas(+Nombre, +Lazo:list, -Lineas:list(string)) is det.
%
%   Lineas son las líneas de texto del tablero Nombre con el lazo Lazo
%   dibujado; con Lazo vacío, solo el tablero y sus marcas.
lineas(Nombre, Lazo, Lineas) :-
    problema(Nombre, Filas, Columnas, _),
    aristas(Lazo, Aristas),
    numlist(1, Filas, Fs),
    foldl(lineas_de_fila(Nombre, Filas, Columnas, Aristas), Fs, Lineas, []).

%!  lineas_de_fila(+Nombre, +Filas, +Columnas, +Aristas, +F, -Lineas,
%!                 ?Resto) is det.
%
%   Lineas, hasta Resto, son la línea de las casillas de la fila F y, si
%   no es la última, la de los trazos verticales que la unen con la
%   siguiente.
lineas_de_fila(Nombre, Filas, Columnas, Aristas, F, [Casillas|Lineas], Resto) :-
    numlist(1, Columnas, Cs),
    foldl(casilla_y_trazo(Nombre, Columnas, Aristas, F), Cs, Partes, []),
    atomics_to_string(Partes, Casillas),
    (   F =:= Filas
    ->  Lineas = Resto
    ;   F1 is F + 1,
        maplist(vertical(Aristas, F, F1), Cs, Verticales),
        atomic_list_concat(Verticales, ' ', Abajo0),
        sin_espacios_finales(Abajo0, Abajo),
        Lineas = [Abajo|Resto]
    ).

%!  sin_espacios_finales(+Texto, -Recortado:string) is det.
%
%   Recortado es Texto sin los espacios del final.
sin_espacios_finales(Texto, Recortado) :-
    atom_codes(Texto, Codigos),
    reverse(Codigos, Invertidos),
    quitar_espacios(Invertidos, Invertidos1),
    reverse(Invertidos1, Codigos1),
    string_codes(Recortado, Codigos1).

%!  quitar_espacios(+Codigos:list, -Resto:list) is det.
%
%   Resto es Codigos sin los espacios del principio.
quitar_espacios([0' |Codigos], Resto) :-
    !,
    quitar_espacios(Codigos, Resto).
quitar_espacios(Codigos, Codigos).

%!  casilla_y_trazo(+Nombre, +Columnas, +Aristas, +F, +C, -Partes,
%!                  ?Resto) is det.
%
%   Partes, hasta Resto, son el carácter de la casilla F-C y, si no es la
%   última columna, el trazo horizontal o el espacio que la sigue.
casilla_y_trazo(Nombre, Columnas, Aristas, F, C, [Caracter|Partes], Resto) :-
    caracter(Nombre, Aristas, F-C, Caracter),
    (   C =:= Columnas
    ->  Partes = Resto
    ;   C1 is C + 1,
        (   ord_memberchk((F-C)-(F-C1), Aristas)
        ->  Partes = ['─'|Resto]
        ;   Partes = [' '|Resto]
        )
    ).

%!  vertical(+Aristas, +F, +F1, +C, -Partes) is det.
%
%   Partes es el trazo vertical entre F-C y F1-C, o un espacio si el lazo
%   no los une.
vertical(Aristas, F, F1, C, Partes) :-
    (   ord_memberchk((F-C)-(F1-C), Aristas)
    ->  Partes = '│'
    ;   Partes = ' '
    ).

%!  caracter(+Nombre, +Aristas, +Pos, -Caracter) is det.
%
%   Caracter es O o # si hay una marca en Pos; si no, el trazo que forman
%   las dos aristas del lazo que tocan Pos, o un punto si no lo toca.
caracter(Nombre, Aristas, Pos, Caracter) :-
    (   marca(Nombre, Pos, Clase)
    ->  simbolo(Clase, Caracter)
    ;   aggregate_all(sum(P), ( direccion(Aristas, Pos, D), peso(D, P) ),
                      Suma),
        trazo(Suma, Caracter)
    ).

% simbolo(Clase, Caracter): las marcas de Clase se dibujan con Caracter.
simbolo(circulo, 'O').
simbolo(numeral, '#').

%!  direccion(+Aristas, +Pos, -D) is nondet.
%
%   El lazo sale de Pos hacia D: arriba, abajo, izquierda o derecha.
direccion(Aristas, F-C, arriba) :-
    F0 is F - 1,
    ord_memberchk((F0-C)-(F-C), Aristas).
direccion(Aristas, F-C, abajo) :-
    F1 is F + 1,
    ord_memberchk((F-C)-(F1-C), Aristas).
direccion(Aristas, F-C, izquierda) :-
    C0 is C - 1,
    ord_memberchk((F-C0)-(F-C), Aristas).
direccion(Aristas, F-C, derecha) :-
    C1 is C + 1,
    ord_memberchk((F-C)-(F-C1), Aristas).

% peso(D, P): la dirección D cuenta P en la suma que identifica un trazo;
% cada dirección es un bit distinto, así que la suma determina el par.
peso(arriba, 1).
peso(abajo, 2).
peso(izquierda, 4).
peso(derecha, 8).

% trazo(Suma, Caracter): una casilla de la que el lazo sale hacia las
% direcciones cuyos pesos suman Suma se dibuja con Caracter.
trazo(0, '·').
trazo(3, '│').
trazo(12, '─').
trazo(5, '┘').
trazo(9, '└').
trazo(6, '┐').
trazo(10, '┌').

%!  mostrar(+Nombre, +Lazo:list) is det.
%
%   Escribe las líneas de lineas/3, una por renglón.
mostrar(Nombre, Lazo) :-
    lineas(Nombre, Lazo, Lineas),
    forall(member(Linea, Lineas), writeln(Linea)).

%!  cubre(+Nombre, +Lazo:list) is semidet.
%
%   Lazo pasa por todas las casillas del tablero Nombre.
cubre(Nombre, Lazo) :-
    problema(Nombre, Filas, Columnas, _),
    length(Lazo, N),
    N =:= Filas * Columnas.

%!  cobertura(+Nombre, -Distintos:integer, -Cubren:integer) is det.
%
%   Distintos es la cantidad de lazos distintos del tablero Nombre y
%   Cubren, cuántos de ellos pasan por todas sus casillas.
cobertura(Nombre, Distintos, Cubren) :-
    distintos(Nombre, Formas),
    length(Formas, Distintos),
    include(cubre(Nombre), Formas, Completos),
    length(Completos, Cubren).

%!  dibujar(+Nombre) is det.
%
%   Escribe cada lazo distinto del tablero Nombre, en el orden de sus
%   formas canónicas, con una línea en blanco entre uno y otro.
dibujar(Nombre) :-
    distintos(Nombre, Formas),
    forall(nth1(I, Formas, Forma),
           ( (   I > 1
             ->  nl
             ;   true
             ),
             mostrar(Nombre, Forma) )).
