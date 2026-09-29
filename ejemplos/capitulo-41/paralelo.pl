:- encoding(utf8).

% Capítulo 41 - Jugadas buscadas en paralelo, con un límite de tiempo.
%
% en_paralelo/5 reparte las jugadas de la posición entre los núcleos con
% concurrent_maplist/3 (capítulo 37): cada hilo busca con alfabeta/6 la
% posición que sigue a una jugada, y al final se elige la mejor. Cada
% búsqueda tiene sus propias cotas, y las jugadas no se podan entre sí: se
% visitan más nodos que en la búsqueda secuencial, repartidos entre varios
% núcleos. en_paralelo/6 pone el límite de tiempo dentro de cada hilo. La
% poda alfa-beta, la evaluación por líneas abiertas y el ta-te-ti están
% copiados al final.
%
% solo-local: SWISH no permite crear hilos.
%
%?- inicial(tateti(4), P), en_paralelo(tateti(4), P, 4, J, V).

%!  en_paralelo(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor)
%!      is semidet.
%
%   Jugada y Valor son los que da alfabeta/6 con Profundidad, calculados
%   con una búsqueda por jugada, cada una en un hilo. Falla si la partida
%   terminó o Profundidad es 0.
en_paralelo(Juego, Posicion, Profundidad, Jugada, Valor) :-
    Profundidad > 0,
    \+ fin(Juego, Posicion, _),
    findall(J-P, jugada(Juego, Posicion, J, P), Hijos),
    Profundidad1 is Profundidad - 1,
    concurrent_maplist(valor_hijo(Juego, Profundidad1), Hijos, Valores),
    turno(Juego, Posicion, Lado),
    pairs_keys(Hijos, Jugadas),
    pairs_keys_values(Pares, Valores, Jugadas),
    elegir(Lado, Pares, Valor-Jugada).

%!  valor_hijo(+Juego, +Profundidad:integer, +Hijo, -Valor) is det.
%
%   Valor es el valor alfa-beta de la posición de Hijo, un par
%   Jugada-Posicion.
valor_hijo(Juego, Profundidad, _-Posicion, Valor) :-
    alfabeta(Juego, Posicion, Profundidad, _, Valor, _).

%!  elegir(+Lado, +Pares:list(pair), -Mejor:pair) is det.
%
%   Mejor es el primer par Valor-Jugada de Pares con el mejor valor para
%   Lado: el mayor si es max, el menor si es min.
elegir(max, Pares, Mejor) :-
    foldl(mayor, Pares, -inf-ninguna, Mejor).
elegir(min, Pares, Mejor) :-
    foldl(menor, Pares, inf-ninguna, Mejor).

%!  mayor(+Par, +Mejor0, -Mejor) is det.
%
%   Mejor es Par si su valor supera al de Mejor0, y si no Mejor0.
mayor(V-J, V0-J0, Mejor) :-
    (   V > V0
    ->  Mejor = V-J
    ;   Mejor = V0-J0
    ).

%!  menor(+Par, +Mejor0, -Mejor) is det.
%
%   Mejor es Par si su valor es menor que el de Mejor0, y si no Mejor0.
menor(V-J, V0-J0, Mejor) :-
    (   V < V0
    ->  Mejor = V-J
    ;   Mejor = V0-J0
    ).

%!  en_paralelo(+Juego, +Posicion, +Profundidad:integer, +Segundos:number,
%!              -Jugada, -Valor) is semidet.
%
%   Como en_paralelo/5, con Segundos para cada búsqueda. Falla si alguna no
%   termina a tiempo. El límite está dentro de cada hilo: en Windows,
%   call_with_time_limit/2 no interrumpe la espera de thread_join/2.
en_paralelo(Juego, Posicion, Profundidad, Segundos, Jugada, Valor) :-
    Profundidad > 0,
    \+ fin(Juego, Posicion, _),
    findall(J-P, jugada(Juego, Posicion, J, P), Hijos),
    Profundidad1 is Profundidad - 1,
    catch(concurrent_maplist(valor_a_tiempo(Juego, Profundidad1, Segundos),
                             Hijos, Valores),
          time_limit_exceeded,
          fail),
    turno(Juego, Posicion, Lado),
    pairs_keys(Hijos, Jugadas),
    pairs_keys_values(Pares, Valores, Jugadas),
    elegir(Lado, Pares, Valor-Jugada).

%!  valor_a_tiempo(+Juego, +Profundidad:integer, +Segundos:number,
%!                 +Hijo, -Valor) is det.
%
%   Como valor_hijo/4, en Segundos como mucho; si no, lanza
%   time_limit_exceeded.
valor_a_tiempo(Juego, Profundidad, Segundos, Hijo, Valor) :-
    call_with_time_limit(Segundos,
                         valor_hijo(Juego, Profundidad, Hijo, Valor)).

% --- La poda alfa-beta, copiado de alfabeta.pl ------------------------------

%!  alfabeta(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor,
%!           -Nodos:integer) is det.
%
%   Valor es el valor minimax de Posicion buscando Profundidad jugadas
%   hacia adelante, y Jugada la primera de las mejores jugadas, o ninguna
%   si la partida terminó o Profundidad es 0: los mismos que da minimax/6.
%   Nodos es la cantidad de posiciones visitadas.
alfabeta(Juego, Posicion, Profundidad, Jugada, Valor, Nodos) :-
    acotado(Juego, Posicion, Profundidad, -inf, inf, Jugada, Valor, 0, Nodos).

%!  acotado(+Juego, +Posicion, +Profundidad:integer, +Alfa, +Beta,
%!          -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Valor es el valor minimax V de Posicion si queda entre Alfa y Beta. Si
%   no, es una cota que basta para descartar la posición: un valor menor o
%   igual que Alfa si V =< Alfa, mayor o igual que Beta si V >= Beta. N es
%   N0 más los nodos visitados.
acotado(Juego, Posicion, Profundidad, Alfa, Beta, Jugada, Valor, N0, N) :-
    N1 is N0 + 1,
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   Profundidad =:= 0
    ->  evaluar(Juego, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   findall(J-P, jugada(Juego, Posicion, J, P), Hijos),
        turno(Juego, Posicion, Lado),
        Profundidad1 is Profundidad - 1,
        cotas(Hijos, Juego, Lado, Profundidad1, Alfa, Beta, ninguna,
              Jugada, Valor, N1, N)
    ).

%!  cotas(+Hijos:list, +Juego, +Lado, +Profundidad:integer, +Alfa, +Beta,
%!        +J0, -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Busca las jugadas de Hijos, pares Jugada-Posicion, con las cotas Alfa y
%   Beta, que se estrechan a medida que aparecen jugadas mejores para Lado.
%   J0 es la mejor jugada hasta el momento. Si una jugada alcanza la cota
%   del rival, las demás no se buscan: es la poda.
cotas([], _, Lado, _, Alfa, Beta, Jugada, Jugada, Valor, N, N) :-
    propia(Lado, Alfa, Beta, Valor).
cotas([J-P|Hijos], Juego, Lado, Profundidad, Alfa, Beta, J0, Jugada, Valor,
      N0, N) :-
    acotado(Juego, P, Profundidad, Alfa, Beta, _, V, N0, N1),
    (   poda(Lado, V, Alfa, Beta)
    ->  Jugada = J,
        Valor = V,
        N = N1
    ;   estrecha(Lado, V, Alfa, Beta, Alfa1, Beta1)
    ->  cotas(Hijos, Juego, Lado, Profundidad, Alfa1, Beta1, J, Jugada,
              Valor, N1, N)
    ;   cotas(Hijos, Juego, Lado, Profundidad, Alfa, Beta, J0, Jugada,
              Valor, N1, N)
    ).

%!  propia(+Lado, +Alfa, +Beta, -Valor) is det.
%
%   Valor es la cota de Lado: Alfa para max, Beta para min. Al terminar las
%   jugadas, es el valor de la mejor, o la cota que ninguna superó.
propia(max, Alfa, _, Alfa).
propia(min, _, Beta, Beta).

%!  poda(+Lado, +V:number, +Alfa, +Beta) is semidet.
%
%   Una jugada de valor V alcanza la cota del rival: con ella, max obtiene
%   al menos Beta, que min ya evita por otro camino; min obtiene a lo sumo
%   Alfa, que max ya evita.
poda(max, V, _, Beta) :-
    V >= Beta.
poda(min, V, Alfa, _) :-
    V =< Alfa.

%!  estrecha(+Lado, +V:number, +Alfa, +Beta, -Alfa1, -Beta1) is semidet.
%
%   V mejora la cota de Lado, que pasa a ser V. Falla si no la mejora.
estrecha(max, V, Alfa, Beta, V, Beta) :-
    V > Alfa.
estrecha(min, V, Alfa, Beta, Alfa, V) :-
    V < Beta.

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
