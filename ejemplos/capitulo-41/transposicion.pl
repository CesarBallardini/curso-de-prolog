:- encoding(utf8).

% Capítulo 41 - Tablas de transposición con tabulación.
%
% Una misma posición aparece en muchas ramas del árbol de la partida: x en
% 1 y después en 5 lleva al mismo tablero que x en 5 y después en 1. Una
% tabla de transposición guarda el valor de cada posición ya buscada, y la
% tabulación del capítulo 39 la da sin escribirla: valor/3 es minimax sin
% límite de profundidad, con :- table. Cada posición distinta se busca una
% sola vez, por más caminos que lleven a ella. valor_limitado/4 hace lo
% mismo hasta una profundidad, con la profundidad en la tabla. La
% evaluación y el ta-te-ti están copiados al final.
%
%?- inicial(tateti(3), P), jugada_optima(tateti(3), P, J, V).
%?- inicial(tateti(3), P), valor(tateti(3), P, V), posiciones(N).

:- table valor/3.

%!  valor(+Juego, +Posicion, -Valor) is det.
%
%   Valor es el valor minimax de Posicion, buscando hasta el final de la
%   partida. Está tabulado: cada posición se busca una sola vez.
valor(Juego, Posicion, Valor) :-
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor)
    ;   turno(Juego, Posicion, Lado),
        findall(V, ( jugada(Juego, Posicion, _, P),
                     valor(Juego, P, V) ), Valores),
        extremo(Lado, Valores, Valor)
    ).

%!  extremo(+Lado, +Valores:list(number), -Valor:number) is det.
%
%   Valor es el mayor de Valores si Lado es max, y el menor si es min.
extremo(max, Valores, Valor) :-
    max_list(Valores, Valor).
extremo(min, Valores, Valor) :-
    min_list(Valores, Valor).

%!  jugada_optima(+Juego, +Posicion, -Jugada, -Valor) is semidet.
%
%   Jugada es la primera jugada de Posicion que lleva a una posición del
%   mismo valor que Posicion, Valor. Falla si la partida terminó. valor/3
%   se llama con el valor libre: con el valor ligado, la llamada sería otra
%   variante y abriría otra tabla.
jugada_optima(Juego, Posicion, Jugada, Valor) :-
    \+ fin(Juego, Posicion, _),
    valor(Juego, Posicion, Valor),
    once(( jugada(Juego, Posicion, Jugada, P),
           valor(Juego, P, V),
           V =:= Valor )).

%!  posiciones(-Cantidad:integer) is det.
%
%   Cantidad es la cantidad de tablas de valor/3: las posiciones distintas
%   buscadas desde el último abolish_all_tables/0. current_table/2 busca la
%   variante exacta que recibe, y por eso la llamada va con la variable
%   libre y el filtro después.
posiciones(Cantidad) :-
    aggregate_all(count,
                  ( current_table(Variante, _),
                    Variante = valor(_, _, _) ),
                  Cantidad).

:- table valor_limitado/4.

%!  valor_limitado(+Juego, +Posicion, +Profundidad:integer, -Valor) is det.
%
%   Valor es el valor minimax de Posicion buscando Profundidad jugadas
%   hacia adelante, con evaluar/3 en el límite. Está tabulado: una posición
%   a la que se llega por dos caminos con la misma profundidad restante se
%   busca una sola vez.
valor_limitado(Juego, Posicion, Profundidad, Valor) :-
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor)
    ;   Profundidad =:= 0
    ->  evaluar(Juego, Posicion, Valor)
    ;   turno(Juego, Posicion, Lado),
        Profundidad1 is Profundidad - 1,
        findall(V, ( jugada(Juego, Posicion, _, P),
                     valor_limitado(Juego, P, Profundidad1, V) ), Valores),
        extremo(Lado, Valores, Valor)
    ).

% --- La evaluación, copiado de orden.pl -------------------------------------

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
