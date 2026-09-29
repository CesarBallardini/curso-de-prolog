:- encoding(utf8).

% Capítulo 74 - Versión 1: el cubo como término y los giros como
% unificación.
%
% El cubo es un término c/54: un argumento por casilla (las nueve de cada
% cara, en el orden de las caras u, r, f, d, l, b). Cada casilla lleva el
% nombre de la cara a la que pertenece su color. Un giro es un hecho
% giro(Cara, Antes, Despues) cuyos dos argumentos son términos c/54 con las
% mismas 54 variables en otro orden: girar el cubo es una sola unificación.
% Los seis hechos no se escriben a mano: al cargar el archivo,
% term_expansion/2 los calcula con la geometría del cubo, como el
% capítulo 35 genera cláusulas. El giro inverso es el mismo hecho leído
% en sentido inverso.
%
%?- color_tras([u], 19, Color).
%?- cambiadas([r, u, -r, -u], N).
%?- orden([r, u], N).

% --- La geometría ---------------------------------------------------------

% cara(Cara, K, Normal): Cara es la K-ésima cara, contando desde 0, y
% Normal es el vector que sale de ella.
cara(u, 0, p(0, 1, 0)).
cara(r, 1, p(1, 0, 0)).
cara(f, 2, p(0, 0, 1)).
cara(d, 3, p(0, -1, 0)).
cara(l, 4, p(-1, 0, 0)).
cara(b, 5, p(0, 0, -1)).

%!  posicion(?Cara, +Fila:integer, +Columna:integer, -P) is det.
%
%   P es el cubito, p(X, Y, Z) con coordenadas -1, 0 o 1, donde está la
%   casilla de Cara en Fila y Columna, contadas desde 0 y vistas desde
%   afuera de la cara. X crece hacia r, Y hacia u y Z hacia f.
posicion(u, F, C, p(X, 1, Z)) :- X is C - 1, Z is F - 1.
posicion(r, F, C, p(1, Y, Z)) :- Y is 1 - F, Z is 1 - C.
posicion(f, F, C, p(X, Y, 1)) :- X is C - 1, Y is 1 - F.
posicion(d, F, C, p(X, -1, Z)) :- X is C - 1, Z is 1 - F.
posicion(l, F, C, p(-1, Y, Z)) :- Y is 1 - F, Z is C - 1.
posicion(b, F, C, p(X, Y, -1)) :- X is 1 - C, Y is 1 - F.

%!  casilla(?I:integer, ?Cara, ?P, ?N) is nondet.
%
%   La casilla número I, de 1 a 54, pertenece a Cara, está en el cubito P
%   y mira en la dirección N.
casilla(I, Cara, P, N) :-
    cara(Cara, K, N),
    between(0, 2, F),
    between(0, 2, C),
    I is 9 * K + 3 * F + C + 1,
    posicion(Cara, F, C, P).

%!  rotar(+Eje, +V, -W) is det.
%
%   W es el vector V girado un cuarto de vuelta en el sentido de las
%   agujas del reloj, visto desde la punta del vector Eje:
%   W = (Eje . V) Eje - Eje x V.
rotar(p(A, B, C), p(X, Y, Z), p(X1, Y1, Z1)) :-
    E is A * X + B * Y + C * Z,
    X1 is E * A - (B * Z - C * Y),
    Y1 is E * B - (C * X - A * Z),
    Z1 is E * C - (A * Y - B * X).

%!  destino(+Cara, +I:integer, -J:integer) is det.
%
%   Al girar Cara, la casilla I pasa al lugar de la casilla J. Las
%   casillas fuera de la capa de Cara no se mueven.
destino(Cara, I, J) :-
    cara(Cara, _, Eje),
    casilla(I, _, P, N),
    Eje = p(A, B, C),
    P = p(X, Y, Z),
    (   A * X + B * Y + C * Z =:= 1
    ->  rotar(Eje, P, P1),
        rotar(Eje, N, N1),
        casilla(J, _, P1, N1)
    ;   J = I
    ).

% --- Los hechos generados al cargar ---------------------------------------

%!  term_expansion(+Termino, -Clausulas:list) is semidet.
%
%   El término generar_cubo se reemplaza, al cargar el archivo, por el
%   hecho resuelto/1 y un hecho giro/3 por cara. Falla con cualquier
%   otro término.
term_expansion(generar_cubo, [resuelto(Resuelto)|Giros]) :-
    findall(Cara, ( between(1, 54, I), casilla(I, Cara, _, _) ), Caras),
    Resuelto =.. [c|Caras],
    findall(giro(Cara, Antes, Despues),
            ( cara(Cara, _, _),
              giro_calculado(Cara, Antes, Despues) ),
            Giros).

%!  giro_calculado(+Cara, -Antes, -Despues) is det.
%
%   Antes y Despues son dos términos c/54 con las mismas variables:
%   Despues es Antes con la capa de Cara girada.
giro_calculado(Cara, Antes, Despues) :-
    findall(J, ( between(1, 54, I), destino(Cara, I, J) ), Destinos),
    length(Vs, 54),
    Antes =.. [c|Vs],
    pairs_keys_values(Pares, Destinos, Vs),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Ws),
    Despues =.. [c|Ws].

generar_cubo.

% --- Mover el cubo ----------------------------------------------------------

%!  mover(+Movimiento, ?Antes, ?Despues) is det.
%
%   Despues es Antes con Movimiento aplicado. Movimiento es una cara (un
%   cuarto de vuelta en el sentido de las agujas del reloj) o -Cara (el
%   giro inverso: el mismo hecho, leído en sentido inverso). Basta con que
%   llegue instanciado uno de los dos cubos.
mover(-Cara, Antes, Despues) :-
    !,
    giro(Cara, Despues, Antes).
mover(Cara, Antes, Despues) :-
    giro(Cara, Antes, Despues).

%!  cuarto_de_vuelta(-M) is multi.
%
%   M es uno de los doce cuartos de vuelta.
cuarto_de_vuelta(M) :-
    cara(Cara, _, _),
    member(M, [Cara, -Cara]).

%!  aplicar(+Movimientos:list, ?Antes, ?Despues) is det.
%
%   Despues es Antes con Movimientos aplicados, de izquierda a derecha.
aplicar(Movimientos, Antes, Despues) :-
    foldl(mover, Movimientos, Antes, Despues).

%!  inversa(+Movimientos:list, -Inversa:list) is det.
%
%   Inversa deshace Movimientos: los mismos giros invertidos, en el orden
%   contrario.
inversa(Movimientos, Inversa) :-
    reverse(Movimientos, Invertidos),
    maplist(invertir, Invertidos, Inversa).

%!  invertir(+Movimiento, -Inverso) is det.
%
%   Inverso es el giro que deshace Movimiento.
invertir(-Cara, Cara) :-
    !.
invertir(Cara, -Cara).

% --- Consultas sobre el cubo ------------------------------------------------

%!  casillas_distintas(+C1, +C2, -N:integer) is det.
%
%   N es la cantidad de casillas en que difieren los cubos C1 y C2.
casillas_distintas(C1, C2, N) :-
    aggregate_all(count,
                  ( between(1, 54, I),
                    arg(I, C1, X),
                    arg(I, C2, Y),
                    X \== Y ),
                  N).

%!  orden(+Movimientos:list, -N:integer) is det.
%
%   N es la menor cantidad de veces que hay que repetir Movimientos,
%   desde el cubo resuelto, para volver a él.
orden(Movimientos, N) :-
    resuelto(C),
    aplicar(Movimientos, C, C1),
    repetir_hasta(Movimientos, C, C1, 1, N).

%!  repetir_hasta(+Movimientos, +Meta, +C, +K0:integer, -K:integer) is det.
%
%   K es K0 más la cantidad de aplicaciones de Movimientos que llevan C a
%   Meta.
repetir_hasta(_, Meta, C, K, K) :-
    C == Meta,
    !.
repetir_hasta(Movimientos, Meta, C, K0, K) :-
    aplicar(Movimientos, C, C1),
    K1 is K0 + 1,
    repetir_hasta(Movimientos, Meta, C1, K1, K).

%!  color_tras(+Movimientos:list, +I:integer, -Color) is det.
%
%   Color es el de la casilla I del cubo resuelto con Movimientos
%   aplicados.
color_tras(Movimientos, I, Color) :-
    resuelto(C),
    aplicar(Movimientos, C, C1),
    arg(I, C1, Color).

%!  cambiadas(+Movimientos:list, -N:integer) is det.
%
%   N es la cantidad de casillas que Movimientos cambia de color en el
%   cubo resuelto.
cambiadas(Movimientos, N) :-
    resuelto(C),
    aplicar(Movimientos, C, C1),
    casillas_distintas(C, C1, N).
