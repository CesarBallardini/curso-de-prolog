:- encoding(utf8).

% Capítulo 41 - Solución del ejercicio 10: la tabla de transposición con las
% posiciones simétricas juntas.
%
% Un giro o un reflejo del tablero no cambia el valor de una posición. Se
% tabula una sola posición por grupo, la forma canónica: la menor, en el
% orden estándar, de las ocho simetrías del tablero de 3 por 3. El
% ta-te-ti está copiado al final.
%
%?- inicial(tateti(3), P), valor_simetrico(tateti(3), P, V), canonicas(N).

%!  valor_simetrico(+Juego, +Posicion, -Valor) is det.
%
%   Valor es el valor minimax de Posicion, buscando hasta el final, con
%   una tabla por cada grupo de posiciones simétricas.
valor_simetrico(Juego, pos(Tablero, Turno), Valor) :-
    canonica(Tablero, Canonico),
    valor_canonico(Juego, pos(Canonico, Turno), Valor).

:- table valor_canonico/3.

%!  valor_canonico(+Juego, +Posicion, -Valor) is det.
%
%   Como valor/3 de transposicion.pl, para una posición en forma canónica.
%   Las posiciones siguientes se buscan con valor_simetrico/3.
valor_canonico(Juego, Posicion, Valor) :-
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor)
    ;   turno(Juego, Posicion, Lado),
        findall(V, ( jugada(Juego, Posicion, _, P),
                     valor_simetrico(Juego, P, V) ), Valores),
        extremo(Lado, Valores, Valor)
    ).

%!  extremo(+Lado, +Valores:list(number), -Valor:number) is det.
%
%   Valor es el mayor de Valores si Lado es max, y el menor si es min.
extremo(max, Valores, Valor) :-
    max_list(Valores, Valor).
extremo(min, Valores, Valor) :-
    min_list(Valores, Valor).

%!  canonica(+Tablero:list, -Canonico:list) is det.
%
%   Canonico es la menor, en el orden estándar, de las ocho simetrías de
%   Tablero, un tablero de 3 por 3.
canonica(Tablero, Canonico) :-
    findall(S, ( simetria(Orden),
                 maplist(casilla_de(Tablero), Orden, S) ), Simetricos),
    min_member(Canonico, Simetricos).

%!  casilla_de(+Tablero:list, +Casilla:integer, -Marca) is det.
%
%   Marca es la de Casilla en Tablero.
casilla_de(Tablero, Casilla, Marca) :-
    nth1(Casilla, Tablero, Marca).

% simetria(O): el tablero girado o reflejado tiene en cada casilla, por
% filas, la marca de la casilla de O del tablero original.
simetria([1, 2, 3, 4, 5, 6, 7, 8, 9]).
simetria([7, 4, 1, 8, 5, 2, 9, 6, 3]).
simetria([9, 8, 7, 6, 5, 4, 3, 2, 1]).
simetria([3, 6, 9, 2, 5, 8, 1, 4, 7]).
simetria([7, 8, 9, 4, 5, 6, 1, 2, 3]).
simetria([3, 2, 1, 6, 5, 4, 9, 8, 7]).
simetria([1, 4, 7, 2, 5, 8, 3, 6, 9]).
simetria([9, 6, 3, 8, 5, 2, 7, 4, 1]).

%!  canonicas(-Cantidad:integer) is det.
%
%   Cantidad es la cantidad de tablas de valor_canonico/3.
canonicas(Cantidad) :-
    aggregate_all(count,
                  ( current_table(Variante, _),
                    Variante = valor_canonico(_, _, _) ),
                  Cantidad).

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
