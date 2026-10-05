:- encoding(utf8).

% Capítulo 75 - Soluciones de los ejercicios.
%
% Carga tablero.pl (y con él vista.pl, unico.pl, lazo.pl y tramos.pl) y
% representantes.pl (y con él tipos.pl y enigma.pl), sin modificarlos.
%
% solo-local: carga archivos de este capítulo y del capítulo 40.
%
%?- costo_por_semilla(csenki1, Filas).
%?- orbitas(cruz, Os), length(Os, N).
%?- lazo_recto(recto, Lazos), length(Lazos, N).
%?- conjetura(20).

:- ensure_loaded(tablero).
:- ensure_loaded(representantes).

% --- Ejercicio 2 ----------------------------------------------------------

%!  costo_por_semilla(+Nombre, -Filas:list) is det.
%
%   Filas tiene un término s(Marca, Tramos, Inferencias) por cada marca
%   del tablero Nombre: Tramos es la cantidad de tramos que salen de ella
%   e Inferencias, lo que cuesta buscar los lazos desde ella.
costo_por_semilla(Nombre, Filas) :-
    findall(s(M, T, I),
            ( marca(Nombre, M, _),
              aggregate_all(count, tramo(Nombre, M, _, _), T),
              statistics(inferences, I0),
              lazos_desde(Nombre, M, _),
              statistics(inferences, I1),
              I is I1 - I0 ),
            Filas).

% --- Ejercicio 3 ----------------------------------------------------------

%!  simetrias_propias(+Nombre, -Ss:list) is det.
%
%   Ss son las simetrías que llevan el tablero Nombre a sí mismo.
simetrias_propias(Nombre, Ss) :-
    imagen(identidad, Nombre, Propia),
    findall(S, ( simetria(S, _), imagen(S, Nombre, Propia) ), Ss).

%!  orbitas(+Nombre, -Orbitas:list) is det.
%
%   Orbitas agrupa las formas canónicas de los lazos del tablero Nombre:
%   dos lazos están en la misma órbita si una simetría propia del tablero
%   lleva uno al otro. Cada órbita es una lista ordenada.
orbitas(Nombre, Orbitas) :-
    problema(Nombre, Fs, Cs, _),
    simetrias_propias(Nombre, Ss),
    distintos(Nombre, Lazos),
    maplist(orbita(Ss, Fs, Cs), Lazos, Orbitas0),
    sort(Orbitas0, Orbitas).

%!  orbita(+Ss:list, +Fs:integer, +Cs:integer, +Lazo:list, -Orbita:list)
%!      is det.
%
%   Orbita son las formas canónicas de las imágenes de Lazo por las
%   simetrías Ss, sin repetir.
orbita(Ss, Fs, Cs, Lazo, Orbita) :-
    maplist(imagen_de_lazo(Fs, Cs, Lazo), Ss, Imagenes),
    sort(Imagenes, Orbita).

%!  imagen_de_lazo(+Fs:integer, +Cs:integer, +Lazo:list, +S, -Forma:list)
%!      is det.
%
%   Forma es la forma canónica de la imagen de Lazo por S.
imagen_de_lazo(Fs, Cs, Lazo, S, Forma) :-
    lazo_imagen(S, Fs, Cs, Lazo, Forma).

% --- Ejercicio 4 ----------------------------------------------------------

%!  leer_tablero(+Lineas:list(string), -Filas:integer, -Columnas:integer,
%!               -Marcas:list) is det.
%
%   Lineas es el dibujo de un tablero sin lazo, como el de
%   mostrar(Nombre, []): una línea de casillas por fila y una línea vacía
%   entre fila y fila. Filas y Columnas son sus dimensiones y Marcas sus
%   marcas, en el orden de lectura.
leer_tablero(Lineas, Filas, Columnas, Marcas) :-
    exclude(==(""), Lineas, DeCasillas),
    length(DeCasillas, Filas),
    DeCasillas = [Primera|_],
    split_string(Primera, " ", "", Simbolos),
    length(Simbolos, Columnas),
    foldl(marcas_de_fila, DeCasillas, Listas, 1, _),
    append(Listas, Marcas).

%!  marcas_de_fila(+Linea:string, -Marcas:list, +F:integer, -F1:integer)
%!      is det.
%
%   Marcas son las marcas de la fila F, cuyas casillas dibuja Linea; F1 es
%   F + 1.
marcas_de_fila(Linea, Marcas, F, F1) :-
    F1 is F + 1,
    split_string(Linea, " ", "", Simbolos),
    findall(Marca,
            ( nth1(C, Simbolos, Simbolo),
              atom_string(Caracter, Simbolo),
              simbolo(Clase, Caracter),
              clase(Marca, Clase, F-C) ),
            Marcas).

% --- Ejercicio 5 ----------------------------------------------------------

% recto(Filas, Columnas, Marcas): el tablero del lazo recto de Csenki.
recto(6, 6, [2-2, 2-4, 3-1, 3-4, 4-3, 5-3, 5-5, 6-4]).

% El mismo tablero como problema/4, para dibujarlo con mostrar/2.
problema(recto6, 6, 6, [ circulo(2-2), circulo(2-4), circulo(3-1),
                         circulo(3-4), circulo(4-3), circulo(5-3),
                         circulo(5-5), circulo(6-4) ]).

%!  lazo_recto(+Nombre, -Lazos:list) is det.
%
%   Lazos son los lazos del tablero recto Nombre que pasan por todas las
%   casillas y atraviesan cada marca sin girar. Como ninguna marca puede
%   estar en una esquina, el lazo gira en 1-1: empieza allí, sigue por
%   1-2 y termina en 2-1, con lo que cada lazo aparece una sola vez.
lazo_recto(Nombre, Lazos) :-
    call(Nombre, Filas, Columnas, Marcas),
    Total is Filas * Columnas,
    findall([1-1|Camino],
            camino_recto(t(Filas, Columnas, Marcas, Total), 1-1, 1-2,
                         [1-2, 1-1], 2, Camino),
            Lazos).

%!  camino_recto(+T, +Anterior, +Actual, +Visitadas:list, +K:integer,
%!               -Camino:list) is nondet.
%
%   Camino sigue desde Actual, a la que se llegó desde Anterior, por
%   casillas no visitadas hasta completar las del tablero y terminar en
%   2-1, vecina de 1-1. K es la cantidad de casillas visitadas. En una
%   marca, la casilla siguiente sigue la línea de Anterior y Actual.
camino_recto(t(_, _, Marcas, Total), Anterior, Actual, _, Total, [Actual]) :-
    Actual == 2-1,
    recta_si_marca(Marcas, Anterior, Actual, 1-1).
camino_recto(T, Anterior, Actual, Visitadas, K, [Actual|Camino]) :-
    T = t(Filas, Columnas, Marcas, Total),
    K < Total,
    vecina(Filas, Columnas, Actual, Siguiente),
    \+ memberchk(Siguiente, Visitadas),
    recta_si_marca(Marcas, Anterior, Actual, Siguiente),
    K1 is K + 1,
    camino_recto(T, Actual, Siguiente, [Siguiente|Visitadas], K1, Camino).

%!  vecina(+Filas:integer, +Columnas:integer, +Pos, -Vecina) is nondet.
%
%   Vecina es una casilla del tablero que comparte un lado con Pos.
vecina(Filas, Columnas, F-C, F1-C1) :-
    member(DF-DC, [0-1, 1-0, 0-(-1), (-1)-0]),
    F1 is F + DF,
    C1 is C + DC,
    between(1, Filas, F1),
    between(1, Columnas, C1).

%!  recta_si_marca(+Marcas:list, +A, +B, +C) is semidet.
%
%   Si B es una marca, A, B y C están alineadas.
recta_si_marca(Marcas, F0-C0, B, F2-C2) :-
    (   memberchk(B, Marcas)
    ->  B = F1-C1,
        F1 - F0 =:= F2 - F1,
        C1 - C0 =:= C2 - C1
    ;   true
    ).

% --- Ejercicio 7 ----------------------------------------------------------

%!  cantidad_desarreglos(+N:integer, -D:integer) is det.
%
%   D es la cantidad de desarreglos de 1..N, por la recurrencia
%   D(N) = (N - 1)(D(N - 1) + D(N - 2)), con D(1) = 0 y D(2) = 1. N
%   debe ser al menos 1.
cantidad_desarreglos(N, D) :-
    cantidad_desarreglos(N, D, _).

%!  cantidad_desarreglos(+N:integer, -D:integer, -DAnterior:integer) is det.
%
%   D es la cantidad de desarreglos de 1..N y DAnterior la de 1..N-1 (1
%   para N = 1: la permutación vacía). N debe ser al menos 1.
cantidad_desarreglos(N, D, D1) :-
    (   N =:= 1
    ->  D = 0,
        D1 = 1
    ;   N1 is N - 1,
        cantidad_desarreglos(N1, D1, D2),
        D is N1 * (D1 + D2)
    ).

% --- Ejercicio 8 ----------------------------------------------------------

%!  particion_libre(+N:integer, -Partes:list(integer)) is nondet.
%
%   Partes es una partición de N en partes cualesquiera, de menor a mayor.
particion_libre(N, Partes) :-
    particion(N, 1, Partes).

% --- Ejercicio 9 ----------------------------------------------------------

%!  conjugacion_verificada(+N:integer) is semidet.
%
%   Para cada desarreglo de 1..N cuyo patrón tiene filas distintas, su
%   total es el del representante de su tipo.
conjugacion_verificada(N) :-
    forall(tablero(N, P, _, T),
           ( tipo(P, Tipo), total_de_tipo(Tipo, T) )).

% --- Ejercicio 10 ---------------------------------------------------------

%!  polinomio(+N:integer, -T:integer) is det.
%
%   T es N²(N² + 4)/8, la conjetura para el máximo con N par.
polinomio(N, T) :-
    T is N * N * (N * N + 4) // 8.

%!  conjetura(+Hasta:integer) is semidet.
%
%   Para cada N par de 4 a Hasta, el máximo de maximo_representantes/3 es
%   el de polinomio/2 y lo alcanza el tipo de N/2 ciclos de longitud 2.
conjetura(Hasta) :-
    forall(( between(2, Hasta, N), N mod 2 =:= 0, N >= 4 ),
           ( maximo_representantes(N, T, _),
             polinomio(N, T),
             K is N // 2,
             length(Doses, K),
             maplist(=(2), Doses),
             total_de_tipo(Doses, T) )).

% --- Ejercicio 11 ---------------------------------------------------------

%!  lineas_matriz(+M:list(list(integer)), -Lineas:list(string)) is det.
%
%   Lineas son las filas de M con cada número alineado a la derecha en una
%   columna del ancho del número más largo, más un espacio.
lineas_matriz(M, Lineas) :-
    append(M, Todos),
    max_list(Todos, Mayor),
    format(string(Texto), "~d", [Mayor]),
    string_length(Texto, Ancho0),
    Ancho is Ancho0 + 1,
    maplist(linea_matriz(Ancho), M, Lineas).

%!  linea_matriz(+Ancho:integer, +Fila:list(integer), -Linea:string) is det.
%
%   Linea es Fila con cada número alineado a la derecha en Ancho columnas.
linea_matriz(Ancho, Fila, Linea) :-
    foldl(celda_matriz(Ancho), Fila, "", Linea).

%!  celda_matriz(+Ancho:integer, +X:integer, +L0:string, -L:string) is det.
%
%   L es L0 seguido de X alineado a la derecha en Ancho columnas.
celda_matriz(Ancho, X, L0, L) :-
    format(string(Celda), "~t~d~*|", [X, Ancho]),
    string_concat(L0, Celda, L).

%!  mostrar_matriz(+M:list(list(integer))) is det.
%
%   Escribe las líneas de lineas_matriz/2, una por renglón.
mostrar_matriz(M) :-
    lineas_matriz(M, Lineas),
    forall(member(L, Lineas), writeln(L)).
