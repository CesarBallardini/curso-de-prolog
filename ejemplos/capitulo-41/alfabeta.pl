:- encoding(utf8).

% Capítulo 41 - La poda alfa-beta.
%
% alfabeta/6 da el mismo valor y la misma jugada que minimax/6, sin visitar
% las posiciones que no pueden cambiar la decisión. Cada posición se busca
% con dos cotas: Alfa, el valor que max ya tiene asegurado por otro camino,
% y Beta, el que min ya tiene asegurado. Una posición cuyo valor queda fuera
% del intervalo no se termina de buscar: el rival no la va a permitir, o el
% jugador no la va a elegir. minimax/6, el árbol de ejemplo y el ta-te-ti
% están copiados al final, para comparar las dos búsquedas.
%
%?- alfabeta(arbol, a, 3, Jugada, Valor, Nodos).
%?- inicial(tateti(3), P), alfabeta(tateti(3), P, 9, J, V, N).

% Los dos juegos, el árbol y el ta-te-ti, definen los mismos predicados en
% dos lugares del archivo.
:- discontiguous inicial/2, jugada/4, turno/3, fin/3, valor_final/3.

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

%!  evaluar(+Juego, +Posicion, -Valor:number) is det.
%
%   La evaluación nula: 0 para cualquier posición que no terminó.
evaluar(_, _, 0).

% --- Minimax, copiado de minimax.pl -----------------------------------------

%!  minimax(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor,
%!          -Nodos:integer) is det.
%
%   Valor es el valor minimax de Posicion buscando Profundidad jugadas
%   hacia adelante, y Jugada la primera de las mejores jugadas, o ninguna
%   si la partida terminó o Profundidad es 0. Nodos es la cantidad de
%   posiciones visitadas.
minimax(Juego, Posicion, Profundidad, Jugada, Valor, Nodos) :-
    valor(Juego, Posicion, Profundidad, Jugada, Valor, 0, Nodos).

%!  valor(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor,
%!        +N0:integer, -N:integer) is det.
%
%   Como minimax/6; N es N0 más los nodos visitados.
valor(Juego, Posicion, Profundidad, Jugada, Valor, N0, N) :-
    N1 is N0 + 1,
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   Profundidad =:= 0
    ->  evaluar(Juego, Posicion, Valor),
        Jugada = ninguna,
        N = N1
    ;   findall(J-P, jugada(Juego, Posicion, J, P), [J1-P1|Hijos]),
        turno(Juego, Posicion, Lado),
        Profundidad1 is Profundidad - 1,
        valor(Juego, P1, Profundidad1, _, V1, N1, N2),
        mejor(Hijos, Juego, Lado, Profundidad1, J1, V1, Jugada, Valor,
              N2, N)
    ).

%!  mejor(+Hijos:list, +Juego, +Lado, +Profundidad:integer, +J0, +V0,
%!        -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Jugada y Valor son los de la mejor jugada para Lado entre J0, de valor
%   V0, y las de Hijos, pares Jugada-Posicion. Ante un empate queda la
%   primera.
mejor([], _, _, _, Jugada, Valor, Jugada, Valor, N, N).
mejor([J-P|Hijos], Juego, Lado, Profundidad, J0, V0, Jugada, Valor,
      N0, N) :-
    valor(Juego, P, Profundidad, _, V, N0, N1),
    (   mejora(Lado, V, V0)
    ->  mejor(Hijos, Juego, Lado, Profundidad, J, V, Jugada, Valor, N1, N)
    ;   mejor(Hijos, Juego, Lado, Profundidad, J0, V0, Jugada, Valor,
              N1, N)
    ).

%!  mejora(+Lado, +V:number, +V0:number) is semidet.
%
%   Para Lado, el valor V es mejor que V0: mayor si Lado es max, menor si
%   es min.
mejora(max, V, V0) :-
    V > V0.
mejora(min, V, V0) :-
    V < V0.

% --- El árbol de ejemplo, copiado de minimax.pl -----------------------------

% rama(P, H): en el árbol de ejemplo, de la posición P se pasa a H.
rama(a, b).
rama(a, c).
rama(b, d).
rama(b, e).
rama(c, f).
rama(c, g).
rama(d, d1).
rama(d, d2).
rama(e, e1).
rama(e, e2).
rama(f, f1).
rama(f, f2).
rama(g, g1).
rama(g, g2).

% hoja(P, V): P es una hoja del árbol, de valor V.
hoja(d1, 3).
hoja(d2, 5).
hoja(e1, 6).
hoja(e2, 9).
hoja(f1, 1).
hoja(f2, 2).
hoja(g1, 8).
hoja(g2, 4).

% mueve(P, L): en la posición P del árbol le toca a L, max o min.
mueve(a, max).
mueve(b, min).
mueve(c, min).
mueve(d, max).
mueve(e, max).
mueve(f, max).
mueve(g, max).

%!  inicial(+Juego, -Posicion) is det.
%
%   Posicion es la de partida de Juego: en el árbol, la raíz.
inicial(arbol, a).

%!  jugada(+Juego, +Posicion, ?Jugada, -Siguiente) is nondet.
%
%   Siguiente es la posición a la que lleva Jugada desde Posicion: en el
%   árbol, la jugada es el hijo mismo.
jugada(arbol, P, H, H) :-
    rama(P, H).

%!  turno(+Juego, +Posicion, -Lado) is det.
%
%   Lado es max o min, el que mueve en Posicion.
turno(arbol, P, Lado) :-
    mueve(P, Lado).

%!  fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   La partida terminó en Posicion con Resultado: en el árbol, una hoja,
%   con hoja(V). Falla si la partida sigue.
fin(arbol, P, hoja(V)) :-
    hoja(P, V).

%!  valor_final(+Resultado, +Posicion, -Valor:integer) is det.
%
%   Valor es el de una partida terminada, para max: en el árbol, el de la
%   hoja.
valor_final(hoja(V), _, V).

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
