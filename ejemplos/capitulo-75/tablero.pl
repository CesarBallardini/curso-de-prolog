:- encoding(utf8).

% Capítulo 75 - Versión 5: las simetrías del tablero.
%
% Girar o reflejar el tablero no cambia las reglas: un tramo recto sigue
% recto y un giro sigue siendo un giro. Las ocho simetrías del rectángulo
% (la identidad, tres giros, dos espejos y dos trasposiciones) llevan
% cada rompecabezas a uno equivalente, cuyos lazos son las imágenes de
% los del original. sim(S, Nombre) es el tablero Nombre transformado por
% S. La forma canónica de un tablero es la menor de sus ocho imágenes, en
% el orden estándar de los términos: dos tableros equivalentes tienen la
% misma. resolver/2 busca los lazos de la forma canónica, con tabulación
% (capítulo 39), y los devuelve transformados: los ocho tableros
% equivalentes cuestan una sola búsqueda.
%
% solo-local: carga vista.pl, que carga archivos de otro capítulo.
%
%?- simetria_de(giro90, 2, 3, 1-1, P).
%?- forma(sim(giro90, csenki1), F), forma(csenki1, F).
%?- resolver(sim(giro90, csenki1), Ls), length(Ls, N).

:- ensure_loaded(vista).

% simetria(S, Inversa): S es una simetría del rectángulo e Inversa, la
% que la deshace.
simetria(identidad, identidad).
simetria(giro90, giro270).
simetria(giro180, giro180).
simetria(giro270, giro90).
simetria(espejo_filas, espejo_filas).
simetria(espejo_columnas, espejo_columnas).
simetria(traspuesta, traspuesta).
simetria(antitraspuesta, antitraspuesta).

%!  dimensiones(+S, +Filas:integer, +Columnas:integer, -Filas1:integer,
%!              -Columnas1:integer) is det.
%
%   Un tablero de Filas por Columnas, transformado por S, tiene Filas1 por
%   Columnas1 casillas: los giros de un cuarto y las trasposiciones
%   intercambian filas y columnas.
dimensiones(S, F, C, F1, C1) :-
    (   memberchk(S, [giro90, giro270, traspuesta, antitraspuesta])
    ->  F1 = C,
        C1 = F
    ;   F1 = F,
        C1 = C
    ).

%!  simetria_de(+S, +Filas:integer, +Columnas:integer, +Pos, -Pos1) is det.
%
%   Pos1 es la casilla a la que S lleva la casilla Pos de un tablero de
%   Filas por Columnas. giro90 gira un cuarto de vuelta en el sentido de
%   las agujas del reloj; espejo_filas invierte el orden de las filas.
simetria_de(identidad, _, _, F-C, F-C).
simetria_de(giro90, Fs, _, F-C, C-F1) :-
    F1 is Fs + 1 - F.
simetria_de(giro180, Fs, Cs, F-C, F1-C1) :-
    F1 is Fs + 1 - F,
    C1 is Cs + 1 - C.
simetria_de(giro270, _, Cs, F-C, C1-F) :-
    C1 is Cs + 1 - C.
simetria_de(espejo_filas, Fs, _, F-C, F1-C) :-
    F1 is Fs + 1 - F.
simetria_de(espejo_columnas, _, Cs, F-C, F-C1) :-
    C1 is Cs + 1 - C.
simetria_de(traspuesta, _, _, F-C, C-F).
simetria_de(antitraspuesta, Fs, Cs, F-C, C1-F1) :-
    F1 is Fs + 1 - F,
    C1 is Cs + 1 - C.

%!  marca_imagen(+S, +Filas:integer, +Columnas:integer, +Marca, -Marca1)
%!      is det.
%
%   Marca1 es Marca, de la misma clase, en la casilla a la que la lleva S.
marca_imagen(S, Fs, Cs, Marca, Marca1) :-
    clase(Marca, Clase, Pos),
    simetria_de(S, Fs, Cs, Pos, Pos1),
    clase(Marca1, Clase, Pos1).

%!  problema(+Nombre, -Filas:integer, -Columnas:integer, -Marcas:list)
%!      is semidet.
%
%   Agrega a los tableros de tramos.pl dos clases de nombres derivados.
%   sim(S, Base) es el tablero Base, que tiene que ser un átomo,
%   transformado por la simetría S, con las marcas ordenadas. forma(t(F,
%   C, Ms)) es el tablero de F por C con las marcas Ms.
problema(sim(S, Base), Filas, Columnas, Marcas) :-
    atom(Base),
    simetria(S, _),
    problema(Base, F0, C0, Marcas0),
    dimensiones(S, F0, C0, Filas, Columnas),
    maplist(marca_imagen(S, F0, C0), Marcas0, Marcas1),
    msort(Marcas1, Marcas).
problema(forma(t(Filas, Columnas, Marcas)), Filas, Columnas, Marcas).

%!  imagen(+S, +Nombre, -Imagen) is det.
%
%   Imagen es t(Filas, Columnas, Marcas): el tablero Nombre transformado
%   por S, con las marcas ordenadas.
imagen(S, Nombre, t(F1, C1, Marcas)) :-
    problema(Nombre, F0, C0, Marcas0),
    dimensiones(S, F0, C0, F1, C1),
    maplist(marca_imagen(S, F0, C0), Marcas0, Marcas1),
    msort(Marcas1, Marcas).

%!  forma(+Nombre, -Forma) is det.
%
%   Forma es la forma canónica del tablero Nombre: la menor de sus ocho
%   imágenes en el orden estándar de los términos.
forma(Nombre, Forma) :-
    forma(Nombre, _, Forma).

%!  forma(+Nombre, -S, -Forma) is det.
%
%   Forma es la forma canónica del tablero Nombre y S, la primera simetría
%   que lleva el tablero a ella.
forma(Nombre, S, Forma) :-
    findall(Imagen-S0, ( simetria(S0, _), imagen(S0, Nombre, Imagen) ),
            Pares),
    keysort(Pares, [Forma-S|_]).

%!  lazo_imagen(+S, +Filas:integer, +Columnas:integer, +Lazo:list,
%!              -Forma:list) is det.
%
%   Forma es la forma canónica de la imagen por S de Lazo, un lazo de un
%   tablero de Filas por Columnas.
lazo_imagen(S, Fs, Cs, Lazo, Forma) :-
    maplist(simetria_de(S, Fs, Cs), Lazo, Lazo1),
    canonica(Lazo1, Forma).

:- table lazos_de_forma/2.

%!  lazos_de_forma(+Forma, -Lazos:list) is det.
%
%   Lazos son las formas canónicas, sin repetir, de los lazos del tablero
%   Forma. El predicado está tabulado: cada forma se resuelve una sola vez.
lazos_de_forma(Forma, Lazos) :-
    distintos(forma(Forma), Lazos).

%!  resolver(+Nombre, -Lazos:list) is det.
%
%   Lazos son las formas canónicas, sin repetir y ordenadas, de los lazos
%   del tablero Nombre, obtenidas de los de su forma canónica.
resolver(Nombre, Lazos) :-
    forma(Nombre, S, Forma),
    lazos_de_forma(Forma, LazosForma),
    simetria(S, Inversa),
    Forma = t(Fs, Cs, _),
    maplist(lazo_imagen(Inversa, Fs, Cs), LazosForma, Lazos0),
    sort(Lazos0, Lazos).
