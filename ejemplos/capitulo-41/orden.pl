:- encoding(utf8).

% Capítulo 41 - Funciones de evaluación y orden de las jugadas.
%
% evaluar/3 estima el valor de una posición sin buscar jugadas: las
% líneas que x todavía puede completar menos las que puede completar o.
% alfabeta/7 es la poda alfa-beta con un argumento más, el orden en que se
% buscan las jugadas: natural (el de jugada/4), mejores (las mejores según
% evaluar/3 primero) o peores (las peores primero). La poda corta más
% cuanto antes aparece la mejor jugada. El ta-te-ti está copiado al final.
%
%?- evaluar(tateti(3), pos([v,v,v, v,x,v, v,v,v], o), V).
%?- inicial(tateti(3), P), alfabeta(mejores, tateti(3), P, 9, J, V, N).

%!  evaluar(+Juego, +Posicion, -Valor:integer) is det.
%
%   Valor es la cantidad de líneas de Posicion en las que no hay ninguna o,
%   que x todavía puede completar, menos la cantidad de líneas en las que
%   no hay ninguna x.
evaluar(Juego, pos(Tablero, _), Valor) :-
    lineas(Juego, Lineas),
    aggregate_all(count, ( member(L, Lineas), abierta(Tablero, o, L) ), X),
    aggregate_all(count, ( member(L, Lineas), abierta(Tablero, x, L) ), O),
    Valor is X - O.

%!  abierta(+Tablero:list, +Rival, +Linea:list(integer)) is semidet.
%
%   Ninguna casilla de Linea tiene la marca de Rival.
abierta(Tablero, Rival, Linea) :-
    \+ ( member(C, Linea),
         marca(Tablero, Rival, C) ).

%!  alfabeta(+Orden, +Juego, +Posicion, +Profundidad:integer, -Jugada,
%!           -Valor, -Nodos:integer) is det.
%
%   Como alfabeta/6 del archivo alfabeta.pl, buscando las jugadas de cada
%   posición en Orden: natural, mejores o peores.
alfabeta(Orden, Juego, Posicion, Profundidad, Jugada, Valor, Nodos) :-
    acotado(Orden, Juego, Posicion, Profundidad, -inf, inf, Jugada, Valor,
            0, Nodos).

%!  acotado(+Orden, +Juego, +Posicion, +Profundidad:integer, +Alfa, +Beta,
%!          -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Como acotado/9 de alfabeta.pl, con las jugadas ordenadas por ordenar/5.
acotado(Orden, Juego, Posicion, Profundidad, Alfa, Beta, Jugada, Valor,
        N0, N) :-
    N1 is N0 + 1,
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   Profundidad =:= 0
    ->  evaluar(Juego, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   findall(J-P, jugada(Juego, Posicion, J, P), Hijos0),
        turno(Juego, Posicion, Lado),
        ordenar(Orden, Juego, Lado, Hijos0, Hijos),
        Profundidad1 is Profundidad - 1,
        cotas(Hijos, Orden, Juego, Lado, Profundidad1, Alfa, Beta, ninguna,
              Jugada, Valor, N1, N)
    ).

%!  ordenar(+Orden, +Juego, +Lado, +Hijos0:list, -Hijos:list) is det.
%
%   Hijos son los pares Jugada-Posicion de Hijos0 en Orden. Con mejores,
%   primero los de mayor evaluación si Lado es max, y los de menor si es
%   min; con peores, al revés. Entre evaluaciones iguales se mantiene el
%   orden natural.
ordenar(natural, _, _, Hijos, Hijos).
ordenar(mejores, Juego, Lado, Hijos0, Hijos) :-
    por_evaluacion(Juego, Lado, Hijos0, Hijos).
ordenar(peores, Juego, Lado, Hijos0, Hijos) :-
    otro_lado(Lado, Rival),
    por_evaluacion(Juego, Rival, Hijos0, Hijos).

%!  por_evaluacion(+Juego, +Lado, +Hijos0:list, -Hijos:list) is det.
%
%   Hijos son los de Hijos0, primero los mejores para Lado según evaluar/3.
por_evaluacion(Juego, Lado, Hijos0, Hijos) :-
    map_list_to_pairs(clave(Lado, Juego), Hijos0, Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Hijos).

%!  clave(+Lado, +Juego, +Hijo, -Clave:integer) is det.
%
%   Clave ordena de menor a mayor los hijos del mejor al peor para Lado.
clave(max, Juego, _-P, Clave) :-
    evaluar(Juego, P, V),
    Clave is -V.
clave(min, Juego, _-P, V) :-
    evaluar(Juego, P, V).

% otro_lado(L, R): R es el lado contrario de L.
otro_lado(max, min).
otro_lado(min, max).

%!  cotas(+Hijos:list, +Orden, +Juego, +Lado, +Profundidad:integer, +Alfa,
%!        +Beta, +J0, -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Como cotas/11 de alfabeta.pl, con el orden para las posiciones de abajo.
cotas([], _, _, Lado, _, Alfa, Beta, Jugada, Jugada, Valor, N, N) :-
    propia(Lado, Alfa, Beta, Valor).
cotas([J-P|Hijos], Orden, Juego, Lado, Profundidad, Alfa, Beta, J0, Jugada,
      Valor, N0, N) :-
    acotado(Orden, Juego, P, Profundidad, Alfa, Beta, _, V, N0, N1),
    (   poda(Lado, V, Alfa, Beta)
    ->  Jugada = J,
        Valor = V,
        N = N1
    ;   estrecha(Lado, V, Alfa, Beta, Alfa1, Beta1)
    ->  cotas(Hijos, Orden, Juego, Lado, Profundidad, Alfa1, Beta1, J,
              Jugada, Valor, N1, N)
    ;   cotas(Hijos, Orden, Juego, Lado, Profundidad, Alfa, Beta, J0,
              Jugada, Valor, N1, N)
    ).

%!  propia(+Lado, +Alfa, +Beta, -Valor) is det.
%
%   Valor es la cota de Lado: Alfa para max, Beta para min.
propia(max, Alfa, _, Alfa).
propia(min, _, Beta, Beta).

%!  poda(+Lado, +V:number, +Alfa, +Beta) is semidet.
%
%   Una jugada de valor V alcanza la cota del rival.
poda(max, V, _, Beta) :-
    V >= Beta.
poda(min, V, Alfa, _) :-
    V =< Alfa.

%!  estrecha(+Lado, +V:number, +Alfa, +Beta, -Alfa1, -Beta1) is semidet.
%
%   V mejora la cota de Lado, que pasa a ser V.
estrecha(max, V, Alfa, Beta, V, Beta) :-
    V > Alfa.
estrecha(min, V, Alfa, Beta, Alfa, V) :-
    V < Beta.

% --- El ta-te-ti, copiado de tateti.pl --------------------------------------

%!  inicial(+Juego, -Posicion) is det.
%
%   Posicion es la de partida de Juego: el tablero vacío, y mueve x.
inicial(tateti(N), pos(Tablero, x)) :-
    Casillas is N * N,
    length(Tablero, Casillas),
    maplist(=(v), Tablero).

%!  jugada(+Juego, +Posicion, ?Casilla:integer, -Siguiente) is nondet.
%
%   Siguiente es la posición que resulta de que el jugador de turno en
%   Posicion marque Casilla, una casilla vacía. No comprueba si la partida
%   terminó: las búsquedas llaman antes a fin/3.
jugada(tateti(_), pos(Tablero0, Jugador), Casilla, pos(Tablero, Otro)) :-
    nth1(Casilla, Tablero0, v, Resto),
    nth1(Casilla, Tablero, Jugador, Resto),
    otro(Jugador, Otro).

% otro(J, K): K es el rival de J.
otro(x, o).
otro(o, x).

%!  turno(+Juego, +Posicion, -Lado) is det.
%
%   Lado es max si en Posicion mueve x, que busca los valores altos, y min
%   si mueve o.
turno(tateti(_), pos(_, Jugador), Lado) :-
    lado(Jugador, Lado).

% lado(J, L): el jugador J es L, max o min.
lado(x, max).
lado(o, min).

%!  fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   La partida terminó en Posicion con Resultado: gana(J) si J completó una
%   línea, o empate si el tablero está lleno. Falla si la partida sigue.
fin(Juego, pos(Tablero, _), Resultado) :-
    lineas(Juego, Lineas),
    (   member([C|Cs], Lineas),
        marca(Tablero, J, C),
        J \== v,
        maplist(marca(Tablero, J), Cs)
    ->  Resultado = gana(J)
    ;   \+ memberchk(v, Tablero),
        Resultado = empate
    ).

%!  marca(+Tablero:list, ?Marca, +Casilla:integer) is semidet.
%
%   Marca es lo que hay en Casilla: x, o o v.
marca(Tablero, Marca, Casilla) :-
    nth1(Casilla, Tablero, Marca).

% lineas(Juego, Lineas): Lineas son las filas, las columnas y las dos
% diagonales del tablero de Juego, cada una como la lista de sus casillas.
lineas(tateti(3), [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]).
lineas(tateti(4), [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12],
                   [13, 14, 15, 16],
                   [1, 5, 9, 13], [2, 6, 10, 14], [3, 7, 11, 15],
                   [4, 8, 12, 16],
                   [1, 6, 11, 16], [4, 7, 10, 13]]).

%!  valor_final(+Resultado, +Posicion, -Valor:integer) is det.
%
%   Valor es el de una partida terminada, para x: 0 el empate, y 100 más la
%   cantidad de casillas vacías si gana x, con el signo cambiado si gana o.
%   Las casillas vacías premian ganar antes.
valor_final(empate, _, 0).
valor_final(gana(J), pos(Tablero, _), Valor) :-
    include(==(v), Tablero, Vacias),
    length(Vacias, K),
    signo(J, S),
    Valor is S * (100 + K).

% signo(J, S): S es 1 si J es x, que maximiza, y -1 si es o, que minimiza.
signo(x, 1).
signo(o, -1).
