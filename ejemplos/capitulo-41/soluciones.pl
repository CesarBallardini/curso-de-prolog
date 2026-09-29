:- encoding(utf8).

% Capítulo 41 - Soluciones de los ejercicios 3, 4, 5, 6, 9 y 11.
%
% Cada solución es un juego nuevo que delega en los del capítulo, o una
% búsqueda nueva sobre los mismos predicados. minimax/6, alfabeta/6, el
% árbol de ejemplo y el ta-te-ti están copiados al final.
%
%?- minimax(plano(3), pos([x,o,x, v,x,o, v,o,v], x), 9, J, V, N).
%?- negamax(arbol, a, 3, J, V, N).

% Los juegos definen los mismos predicados en varios lugares del archivo.
:- discontiguous inicial/2, jugada/4, turno/3, fin/3, valor_final/3.

% --- Ejercicio 3: victorias que valen lo mismo -----------------------------

%!  inicial(+Juego, -Posicion) is det.
%
%   Posicion es la de partida de Juego: en plano(N), la de tateti(N).
inicial(plano(N), P) :-
    inicial(tateti(N), P).

%!  jugada(+Juego, +Posicion, ?Casilla:integer, -Siguiente) is nondet.
%
%   Siguiente es la posición que resulta de marcar Casilla en Posicion,
%   como en tateti(N).
jugada(plano(N), P, J, P1) :-
    jugada(tateti(N), P, J, P1).

%!  turno(+Juego, +Posicion, -Lado) is det.
%
%   Lado es el que mueve en Posicion, como en tateti(N).
turno(plano(N), P, Lado) :-
    turno(tateti(N), P, Lado).

%!  fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   La partida terminó en Posicion con Resultado: en plano(N), plano(R) con
%   el resultado R de tateti(N). Falla si la partida sigue.
fin(plano(N), P, plano(R)) :-
    fin(tateti(N), P, R).

%!  valor_final(+Resultado, +Posicion, -Valor:integer) is det.
%
%   Valor es el de una partida terminada, para x: 0 el empate, 100 si gana
%   x y -100 si gana o, sin contar las casillas vacías.
valor_final(plano(empate), _, 0).
valor_final(plano(gana(J)), _, V) :-
    signo(J, S),
    V is S * 100.

% --- Ejercicio 4: negamax ---------------------------------------------------

%!  negamax(+Juego, +Posicion, +Profundidad:integer, -Jugada, -Valor,
%!          -Nodos:integer) is det.
%
%   Como minimax/6, con un solo caso para los dos jugadores: internamente,
%   el valor de una posición se mide desde el punto de vista del que mueve.
%   Valor es, como en minimax/6, desde el punto de vista de max.
negamax(Juego, Posicion, Profundidad, Jugada, Valor, Nodos) :-
    turno(Juego, Posicion, Lado),
    signo_lado(Lado, S),
    nega(Juego, Posicion, Lado, Profundidad, Jugada, V, 0, Nodos),
    Valor is S * V.

%!  nega(+Juego, +Posicion, +Lado, +Profundidad:integer, -Jugada, -Valor,
%!       +N0:integer, -N:integer) is det.
%
%   Valor es el valor de Posicion para Lado, el jugador que mueve en ella.
%   Los valores de las posiciones siguientes, que son del rival, se toman
%   con el signo cambiado, y siempre se elige el máximo.
nega(Juego, Posicion, Lado, Profundidad, Jugada, Valor, N0, N) :-
    N1 is N0 + 1,
    signo_lado(Lado, S),
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, V),
        Valor is S * V,
        Jugada = ninguna,
        N = N1
    ;   Profundidad =:= 0
    ->  evaluar(Juego, Posicion, V),
        Valor is S * V,
        Jugada = ninguna,
        N = N1
    ;   findall(J-P, jugada(Juego, Posicion, J, P), [J1-P1|Hijos]),
        otro_lado(Lado, Rival),
        Profundidad1 is Profundidad - 1,
        nega(Juego, P1, Rival, Profundidad1, _, V1, N1, N2),
        W1 is -V1,
        mejor_nega(Hijos, Juego, Rival, Profundidad1, J1, W1, Jugada, Valor,
                   N2, N)
    ).

%!  mejor_nega(+Hijos:list, +Juego, +Rival, +Profundidad:integer, +J0,
%!             +V0, -Jugada, -Valor, +N0:integer, -N:integer) is det.
%
%   Jugada y Valor son los de la jugada de mayor valor, con el signo
%   cambiado del que tiene para Rival, entre J0 y las de Hijos.
mejor_nega([], _, _, _, Jugada, Valor, Jugada, Valor, N, N).
mejor_nega([J-P|Hijos], Juego, Rival, Profundidad, J0, V0, Jugada, Valor,
           N0, N) :-
    nega(Juego, P, Rival, Profundidad, _, V1, N0, N1),
    V is -V1,
    (   V > V0
    ->  mejor_nega(Hijos, Juego, Rival, Profundidad, J, V, Jugada, Valor,
                   N1, N)
    ;   mejor_nega(Hijos, Juego, Rival, Profundidad, J0, V0, Jugada, Valor,
                   N1, N)
    ).

% signo_lado(L, S): el valor de max se multiplica por S para el lado L.
signo_lado(max, 1).
signo_lado(min, -1).

% otro_lado(L, R): R es el lado contrario de L.
otro_lado(max, min).
otro_lado(min, max).

% --- Ejercicio 5: el árbol con las ramas de la raíz invertidas -------------

inicial(invertido, a).

jugada(invertido, P, H, H) :-
    (   P == a
    ->  member(H, [c, b])
    ;   rama(P, H)
    ).

turno(invertido, P, Lado) :-
    mueve(P, Lado).

fin(invertido, P, hoja(V)) :-
    hoja(P, V).

% --- Ejercicio 6: las líneas de un tablero de N por N ----------------------

%!  linea(+N:integer, -Casillas:list(integer)) is nondet.
%
%   Casillas son las de una fila, una columna o una diagonal de un tablero
%   de N por N, en orden: primero las filas, después las columnas, después
%   la diagonal principal y la otra.
linea(N, Casillas) :-
    numlist(1, N, Is),
    (   between(1, N, F),
        maplist(casilla(N, F), Is, Casillas)
    ;   between(1, N, C),
        maplist(casilla_columna(N, C), Is, Casillas)
    ;   maplist(diagonal(N), Is, Casillas)
    ;   maplist(antidiagonal(N), Is, Casillas)
    ).

%!  casilla(+N:integer, +Fila:integer, +Columna:integer, -Casilla:integer)
%!      is det.
%
%   Casilla es el número de la casilla en Fila y Columna, contadas desde 1.
casilla(N, Fila, Columna, Casilla) :-
    Casilla is (Fila - 1) * N + Columna.

%!  casilla_columna(+N:integer, +Columna:integer, +Fila:integer,
%!                  -Casilla:integer) is det.
%
%   Como casilla/4, con la columna antes que la fila.
casilla_columna(N, Columna, Fila, Casilla) :-
    casilla(N, Fila, Columna, Casilla).

%!  diagonal(+N:integer, +I:integer, -Casilla:integer) is det.
%
%   Casilla es la de la fila I en la diagonal principal.
diagonal(N, I, Casilla) :-
    casilla(N, I, I, Casilla).

%!  antidiagonal(+N:integer, +I:integer, -Casilla:integer) is det.
%
%   Casilla es la de la fila I en la otra diagonal.
antidiagonal(N, I, Casilla) :-
    Columna is N + 1 - I,
    casilla(N, I, Columna, Casilla).

% --- Ejercicio 9: el juego de restar ----------------------------------------

inicial(restar(K), r(K, x)).

jugada(restar(_), r(K, J), S, r(K1, Otro)) :-
    between(1, 3, S),
    S =< K,
    K1 is K - S,
    otro(J, Otro).

turno(restar(_), r(_, J), Lado) :-
    lado(J, Lado).

fin(restar(_), r(0, J), restar(gana(Otro))) :-
    otro(J, Otro).

valor_final(restar(gana(J)), _, V) :-
    signo(J, S),
    V is S * 100.

%!  perdedoras(+Maximo:integer, -Pilas:list(integer)) is det.
%
%   Pilas son las pilas de 1 a Maximo fichas en las que pierde el que
%   mueve, según la poda buscada hasta el final.
perdedoras(Maximo, Pilas) :-
    findall(K, ( between(1, Maximo, K),
                 alfabeta(restar(K), r(K, x), K, _, V, _),
                 V < 0 ), Pilas).

% --- Ejercicio 11: la poda tabulada ------------------------------------------

:- table acotado_tabulado/5.

%!  acotado_tabulado(+Juego, +Posicion, +Alfa, +Beta, -Valor) is det.
%
%   Como acotado/9 de la poda, hasta el final de la partida y sin la
%   jugada ni el contador, tabulado con las cotas como argumentos.
acotado_tabulado(Juego, Posicion, Alfa, Beta, Valor) :-
    (   fin(Juego, Posicion, Resultado)
    ->  valor_final(Resultado, Posicion, Valor)
    ;   findall(P, jugada(Juego, Posicion, _, P), Siguientes),
        turno(Juego, Posicion, Lado),
        cotas_tabuladas(Siguientes, Juego, Lado, Alfa, Beta, Valor)
    ).

%!  cotas_tabuladas(+Posiciones:list, +Juego, +Lado, +Alfa, +Beta, -Valor)
%!      is det.
%
%   Como cotas/11 de la poda, sobre acotado_tabulado/5.
cotas_tabuladas([], _, Lado, Alfa, Beta, Valor) :-
    propia(Lado, Alfa, Beta, Valor).
cotas_tabuladas([P|Ps], Juego, Lado, Alfa, Beta, Valor) :-
    acotado_tabulado(Juego, P, Alfa, Beta, V),
    (   poda(Lado, V, Alfa, Beta)
    ->  Valor = V
    ;   estrecha(Lado, V, Alfa, Beta, Alfa1, Beta1)
    ->  cotas_tabuladas(Ps, Juego, Lado, Alfa1, Beta1, Valor)
    ;   cotas_tabuladas(Ps, Juego, Lado, Alfa, Beta, Valor)
    ).

%!  tablas_de_la_poda(-Cantidad:integer) is det.
%
%   Cantidad es la cantidad de tablas de acotado_tabulado/5.
tablas_de_la_poda(Cantidad) :-
    aggregate_all(count,
                  ( current_table(Variante, _),
                    Variante = acotado_tabulado(_, _, _, _, _) ),
                  Cantidad).

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

inicial(arbol, a).

jugada(arbol, P, H, H) :-
    rama(P, H).

turno(arbol, P, Lado) :-
    mueve(P, Lado).

fin(arbol, P, hoja(V)) :-
    hoja(P, V).

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
