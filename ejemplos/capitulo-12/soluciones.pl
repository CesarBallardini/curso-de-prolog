:- encoding(utf8).

% Capítulo 12 - Soluciones de los ejercicios.
%
% Los ejercicios con una base de datos propia tienen su archivo: grafos.pl,
% libros.pl, campeonato.pl, agencia.pl y aerolinea.pl.
%
%?- matriz(a, A), elemento(A, posicion(2, 1), E).
%?- tablero_siguiente(reina(6, 2), T).

% --- Ejercicio 1 -----------------------------------------------------------

% matriz(Nombre, M): M es una de las matrices del enunciado, por filas.
matriz(a, [[1, 2, 3], [1, 3, 5], [4, 4, 4]]).
matriz(b, [[0, 0, 4], [7, 2, 10]]).
matriz(at, [[1, 1, 4], [2, 3, 4], [3, 5, 4]]).

%!  elemento(?M, ?Posicion, ?E) is nondet.
%
%   E es el elemento de la matriz M en Posicion, de la forma posicion(F, C).
elemento(M, posicion(F, C), E) :-
    nth1(F, M, Fila),
    nth1(C, Fila, E).

%!  actualiza(+M, +Posicion, +E, -M2) is semidet.
%
%   M2 es la matriz M con E en Posicion, de la forma posicion(F, C).
actualiza(M, posicion(F, C), E, M2) :-
    nth1(F, M, Fila),
    reemplaza_en(C, Fila, E, Fila2),
    reemplaza_en(F, M, Fila2, M2).

%!  reemplaza_en(+N, +L, +X, -L2) is semidet.
%
%   L2 es la lista L con X en la posición N, contando desde 1.
reemplaza_en(1, [_|Resto], X, [X|Resto]).
reemplaza_en(N, [Y|Resto], X, [Y|Resto2]) :-
    N > 1,
    Anterior is N - 1,
    reemplaza_en(Anterior, Resto, X, Resto2).

%!  transpuesta(+M, ?T) is semidet.
%
%   T es la matriz transpuesta de M: la fila i de T es la columna i de M.
transpuesta([[]|_], []).
transpuesta([[X|Xs]|Filas], [Columna|Columnas]) :-
    primera_columna([[X|Xs]|Filas], Columna, Restos),
    transpuesta(Restos, Columnas).

%!  primera_columna(+M, -Columna, -Restos) is det.
%
%   Columna es la primera columna de M, y Restos son las filas de M sin su
%   primer elemento.
primera_columna([], [], []).
primera_columna([[X|Xs]|Filas], [X|Columna], [Xs|Restos]) :-
    primera_columna(Filas, Columna, Restos).

%!  suma(+M1, +M2, -S) is semidet.
%
%   S es la suma de las matrices M1 y M2, de las mismas dimensiones.
suma([], [], []).
suma([F1|Filas1], [F2|Filas2], [F|Filas]) :-
    suma_fila(F1, F2, F),
    suma(Filas1, Filas2, Filas).

%!  suma_fila(+F1, +F2, -F) is semidet.
%
%   Cada elemento de F es la suma de los elementos de F1 y F2 en la misma
%   posición.
suma_fila([], [], []).
suma_fila([X|Xs], [Y|Ys], [Z|Zs]) :-
    Z is X + Y,
    suma_fila(Xs, Ys, Zs).

%!  suma_diagonales(+M, -SD) is det.
%
%   El elemento i de SD es la suma del elemento i de la diagonal principal de
%   la matriz cuadrada M y del elemento i de la diagonal secundaria.
suma_diagonales(M, SD) :-
    length(M, N),
    sumando_diagonales(M, 1, N, SD).

%!  sumando_diagonales(+Filas, +I, +N, -SD) is det.
%
%   Filas son las filas de la I a la N de una matriz de N columnas, y SD las
%   sumas de sus elementos de las dos diagonales.
sumando_diagonales([], _, _, []).
sumando_diagonales([Fila|Filas], I, N, [S|Ss]) :-
    nth1(I, Fila, Principal),
    J is N + 1 - I,
    nth1(J, Fila, Secundaria),
    S is Principal + Secundaria,
    Siguiente is I + 1,
    sumando_diagonales(Filas, Siguiente, N, Ss).

% --- Ejercicio 2 -----------------------------------------------------------

%!  convierte(+M, -Rala) is det.
%
%   Rala es la lista de los elementos de M distintos de cero, cada uno como
%   [Fila, Columna, Valor], recorriendo M por filas.
convierte(M, Rala) :-
    convierte_filas(M, 1, Rala).

%!  convierte_filas(+Filas, +F, -Rala) is det.
%
%   Rala es la representación compacta de Filas, cuya primera fila es la F.
convierte_filas([], _, []).
convierte_filas([Fila|Filas], F, Rala) :-
    convierte_fila(Fila, F, 1, RalaFila),
    Siguiente is F + 1,
    convierte_filas(Filas, Siguiente, RalaResto),
    append(RalaFila, RalaResto, Rala).

%!  convierte_fila(+Fila, +F, +C, -Rala) is det.
%
%   Rala son los elementos distintos de cero de Fila, que es la fila F a
%   partir de la columna C.
convierte_fila([], _, _, []).
convierte_fila([0|Xs], F, C, Rala) :-
    Siguiente is C + 1,
    convierte_fila(Xs, F, Siguiente, Rala).
convierte_fila([X|Xs], F, C, [[F, C, X]|Rala]) :-
    X =\= 0,
    Siguiente is C + 1,
    convierte_fila(Xs, F, Siguiente, Rala).

% --- Ejercicio 3 -----------------------------------------------------------

%!  tablero_siguiente(+Actual, ?Nuevo) is nondet.
%
%   Nuevo es un tablero que resulta de mover la reina del tablero Actual. Un
%   tablero es reina(Fila, Columna), la casilla de la única pieza, con filas
%   y columnas de 1 a 8.
tablero_siguiente(reina(F, C), reina(F2, C2)) :-
    between(1, 8, F2),
    between(1, 8, C2),
    movida_reina(F, C, F2, C2).

%!  movida_reina(+F, +C, +F2, +C2) is semidet.
%
%   La reina pasa de la casilla (F, C) a la casilla (F2, C2) en una movida:
%   por la fila, por la columna o por una de las dos diagonales.
movida_reina(F, C, F2, C2) :-
    F2 =:= F,
    C2 =\= C.
movida_reina(F, C, F2, C2) :-
    C2 =:= C,
    F2 =\= F.
movida_reina(F, C, F2, C2) :-
    F2 =\= F,
    F2 - F =:= C2 - C.
movida_reina(F, C, F2, C2) :-
    F2 =\= F,
    F2 - F =:= C - C2.

% --- Ejercicio 9 -----------------------------------------------------------

%!  color_map(?Mapa, +Colores) is nondet.
%
%   Cada región de Mapa tiene un color de Colores distinto del de sus
%   vecinas. Mapa es una lista de region(Nombre, Color, ColoresVecinas).
color_map([Region|Regiones], Colores) :-
    color_region(Region, Colores),
    color_map(Regiones, Colores).
color_map([], _).

%!  color_region(?Region, +Colores) is nondet.
%
%   La región y sus vecinas tienen colores de Colores, y el de la región es
%   distinto del de cada vecina: selecciona/3 elige el color de la región y
%   members/2 elige o verifica los de las vecinas entre los restantes.
color_region(region(_, Color, Vecinas), Colores) :-
    selecciona(Color, Colores, Restantes),
    members(Vecinas, Restantes).

%!  selecciona(?X, ?Xs, +Ys) is nondet.
%
%   Ys es Xs sin una de las apariciones de X: una respuesta por cada
%   aparición. Con Ys dada y Xs libre, inserta X en cada posición de Ys.
selecciona(X, [X|Xs], Xs).
selecciona(X, [Y|Ys], [Y|Zs]) :-
    selecciona(X, Ys, Zs).

%!  members(?Xs, +Ys) is nondet.
%
%   Cada elemento de Xs es un elemento de Ys.
members([X|Xs], Ys) :-
    member(X, Ys),
    members(Xs, Ys).
members([], _).

% mapa_ejemplo(M): M es el mapa del enunciado, con los colores libres.
mapa_ejemplo([region(a, A, [B, C, D]), region(b, B, [A, C, E]),
              region(c, C, [A, B, D, E, F]), region(d, D, [A, C, F]),
              region(e, E, [B, C, F]), region(f, F, [C, D, E])]).

% --- Ejercicio 14 ----------------------------------------------------------

%!  actualizar(+Tabla, +Resultados, -TablaAct) is det.
%
%   TablaAct es Tabla con los Resultados incorporados, ordenada por puntaje
%   de mayor a menor. Cada fila es [Equipo, Puntaje, Ganados, Empatados,
%   Perdidos]; cada resultado, [Equipo1, Equipo2, R].
actualizar(Tabla, Resultados, TablaAct) :-
    incorporar(Tabla, Resultados, Tabla2),
    ordena_tabla(Tabla2, TablaAct).

%!  incorporar(+Tabla, +Resultados, -Tabla2) is det.
%
%   Tabla2 es Tabla con los Resultados incorporados, uno por uno.
incorporar(Tabla, [], Tabla).
incorporar(Tabla, [[E1, E2, R]|Resultados], Tabla2) :-
    desenlace(R, D1, D2),
    sumar(Tabla, E1, D1, T1),
    sumar(T1, E2, D2, T2),
    incorporar(T2, Resultados, Tabla2).

% desenlace(R, D1, D2): con el resultado R, el primer equipo tiene el
% desenlace D1 y el segundo, D2.
desenlace(1, gana, pierde).
desenlace(2, pierde, gana).
desenlace(3, empata, empata).

%!  sumar(+Tabla, +E, +D, -Tabla2) is semidet.
%
%   Tabla2 es Tabla con el desenlace D sumado a la fila del equipo E.
sumar([[E|Datos]|Filas], E, D, [Fila|Filas]) :-
    fila_actualizada(D, [E|Datos], Fila).
sumar([[Otro|Datos]|Filas], E, D, [[Otro|Datos]|Filas2]) :-
    Otro \== E,
    sumar(Filas, E, D, Filas2).

%!  fila_actualizada(+D, +Fila, -Fila2) is det.
%
%   Fila2 es Fila con el desenlace D: 3 puntos por partido ganado, 1 por
%   partido empatado y ninguno por partido perdido.
fila_actualizada(gana, [E, P, G, Em, Pe], [E, P1, G1, Em, Pe]) :-
    P1 is P + 3,
    G1 is G + 1.
fila_actualizada(empata, [E, P, G, Em, Pe], [E, P1, G, Em1, Pe]) :-
    P1 is P + 1,
    Em1 is Em + 1.
fila_actualizada(pierde, [E, P, G, Em, Pe], [E, P, G, Em, Pe1]) :-
    Pe1 is Pe + 1.

%!  ordena_tabla(+Tabla, -Ordenada) is det.
%
%   Ordenada tiene las filas de Tabla de mayor a menor puntaje; las de igual
%   puntaje conservan su orden. Ordenamiento por inserción, como ordena/2.
ordena_tabla([], []).
ordena_tabla([Fila|Filas], Ordenada) :-
    ordena_tabla(Filas, Parcial),
    inserta_fila(Fila, Parcial, Ordenada).

%!  inserta_fila(+Fila, +Filas, -Filas2) is det.
%
%   Filas2 es Filas, ordenada por puntaje, con Fila insertada en su lugar.
inserta_fila(Fila, [], [Fila]).
inserta_fila([E, P|Datos], [[E2, P2|Datos2]|Filas], [[E2, P2|Datos2]|Zs]) :-
    P < P2,
    inserta_fila([E, P|Datos], Filas, Zs).
inserta_fila([E, P|Datos], [[E2, P2|Datos2]|Filas],
             [[E, P|Datos], [E2, P2|Datos2]|Filas]) :-
    P >= P2.

% --- Ejercicio 16 ----------------------------------------------------------

%!  es_subsecuencia(?S, +L) is nondet.
%
%   Los elementos de S aparecen en L en el mismo orden, no necesariamente
%   contiguos. Con S libre, enumera cada subsecuencia de L una sola vez.
es_subsecuencia([], []).
es_subsecuencia([X|Resto], [X|Otros]) :-
    es_subsecuencia(Resto, Otros).
es_subsecuencia(S, [_|Otros]) :-
    es_subsecuencia(S, Otros).

%!  creciente(+L) is semidet.
%
%   Los números de L están en orden estrictamente creciente.
creciente([]).
creciente([_]).
creciente([X, Y|Resto]) :-
    X < Y,
    creciente([Y|Resto]).

%!  sub_crec_mayor(+L, ?S) is nondet.
%
%   S es una subsecuencia estrictamente creciente de L, y ninguna otra
%   subsecuencia creciente de L es más larga.
sub_crec_mayor(L, S) :-
    es_subsecuencia(S, L),
    creciente(S),
    length(S, N),
    \+ ( es_subsecuencia(Otra, L),
         creciente(Otra),
         length(Otra, M),
         M > N ).
