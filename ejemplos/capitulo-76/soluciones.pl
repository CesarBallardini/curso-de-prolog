:- encoding(utf8).

% Capítulo 76 - Soluciones de los ejercicios.
%
% Carga robot.pl, laberinto.pl, caballo.pl y recorrido.pl sin modificarlos.
% Los problemas nuevos se definen en este módulo con inicial/2, meta/2,
% sucesor/5 y heuristica/3, y se resuelven con las búsquedas del capítulo
% 40 escribiendo soluciones:Problema.
%
% solo-local: carga archivos que cargan las búsquedas del capítulo 40.
%
%?- comparar_giros(patio, 28-8, 32-8, K1, K2).

:- module(soluciones,
          [ comparar_giros/5,
            camino8/5,
            cantidad_minimos/4,
            ida_con_tabla/4,
            camino_ida_con_tabla/5,
            salida_manhattan/3,
            salida_h3/3,
            estimacion_h3/3,
            sobreestimaciones/2,
            distancias/3,
            saltos_minimos/4,
            admisible/2,
            recorrido_cerrado/3
          ]).

:- use_module(library(assoc)).
:- use_module(library(pairs)).
:- reexport(giros).
:- reexport(laberinto).
:- reexport(caballo).
:- reexport(recorrido).
:- use_module(capitulo40).

% --- Ejercicio 2: un giro obligado ------------------------------------------

%!  inicial(+Problema, -Estado) is det.
%
%   El estado inicial de los problemas de este archivo, tomado del problema
%   del que cada uno es una variante.
inicial(giros2(P, D, H), E) :-
    giros:inicial(giros(P, D, H), E).
inicial(ruta8(_, D, _), D).
inicial(salir_m(Filas), E) :-
    laberinto:inicial(salir(Filas, cero), E).
inicial(salir_h3(Filas), E) :-
    laberinto:inicial(salir(Filas, cero), E).

%!  meta(+Problema, +Estado) is semidet.
%
%   La meta de los problemas de este archivo.
meta(giros2(P, D, H), E) :-
    giros:meta(giros(P, D, H), E).
meta(ruta8(_, _, H), H).
meta(salir_m(Filas), E) :-
    laberinto:meta(salir(Filas, cero), E).
meta(salir_h3(Filas), E) :-
    laberinto:meta(salir(Filas, cero), E).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Las transiciones de los problemas de este archivo.
sucesor(giros2(P, D, H), E, A, S, C) :-
    giros:sucesor(giros(P, D, H), E, A, S, C).
sucesor(ruta8(Plano, _, _), Celda, Vecina, Vecina, 1) :-
    vecina8(Plano, Celda, Vecina).
sucesor(salir_m(Filas), E, A, S, C) :-
    laberinto:sucesor(salir(Filas, cero), E, A, S, C).
sucesor(salir_h3(Filas), E, A, S, C) :-
    laberinto:sucesor(salir(Filas, cero), E, A, S, C).

%!  heuristica(+Problema, +Estado, -H:number) is det.
%
%   Las heurísticas de los problemas de este archivo; ninguna estima de más.
heuristica(giros2(_, _, X2-Y2), c(X-Y, _), H) :-
    manhattan(X-Y, X2-Y2, D),
    (   X =\= X2,
        Y =\= Y2
    ->  H is 10 * D + 1
    ;   H is 10 * D
    ).
heuristica(ruta8(_, _, X2-Y2), X-Y, H) :-
    H is max(abs(X - X2), abs(Y - Y2)).
heuristica(salir_m(Filas), g(F, P), H) :-
    length(Filas, N),
    last(Filas, [Q]),
    H is abs(P - Q) + N - F.
heuristica(salir_h3(Filas), G, H) :-
    length(Filas, N),
    last(Filas, [Q]),
    h3(Filas, G, g(N, Q), H).

%!  comparar_giros(+Plano, +Desde, +Hasta, -K1:integer, -K2:integer)
%!      is semidet.
%
%   K1 y K2 son los nodos que A* expande con giros, con la heurística del
%   capítulo y con la que suma el giro obligado; los dos caminos cuestan
%   lo mismo.
comparar_giros(Plano, Desde, Hasta, K1, K2) :-
    camino_con_giros(Plano, Desde, Hasta, _, C, K1),
    buscar(mejor(a_estrella), soluciones:giros2(Plano, Desde, Hasta), _, C,
           K2).

% --- Ejercicio 3: ocho direcciones -------------------------------------------

%!  vecina8(+Plano, +Celda, -Vecina) is nondet.
%
%   Vecina es una celda libre junto a Celda en una de las ocho direcciones;
%   en diagonal, solo si las dos celdas por las que pasaría la esquina
%   también están libres.
vecina8(Plano, Celda, Vecina) :-
    vecina(Plano, Celda, _, Vecina).
vecina8(Plano, X-Y, X1-Y1) :-
    member(DX-DY, [1-1, 1-(-1), (-1)-1, (-1)-(-1)]),
    X1 is X + DX,
    Y1 is Y + DY,
    libre(Plano, X1, Y1),
    libre(Plano, X1, Y),
    libre(Plano, X, Y1).

%!  camino8(+Plano, +Desde, +Hasta, -Pasos:integer, -Expandidos:integer)
%!      is semidet.
%
%   Pasos es la menor cantidad de pasos de Desde a Hasta en ocho
%   direcciones, hallada con A* y la distancia de Chebyshev.
camino8(Plano, Desde, Hasta, Pasos, Expandidos) :-
    buscar(mejor(a_estrella), soluciones:ruta8(Plano, Desde, Hasta), _,
           Pasos, Expandidos).

% --- Ejercicio 4: cuántos caminos más cortos --------------------------------

%!  cantidad_minimos(+Plano, +Desde, +Hasta, -N:integer) is semidet.
%
%   N es la cantidad de caminos de largo mínimo de Desde a Hasta: una
%   búsqueda en anchura por niveles que suma, para cada celda, los caminos
%   que llegan a ella desde el nivel anterior. Falla si no hay camino.
cantidad_minimos(Plano, Desde, Hasta, N) :-
    list_to_assoc([Desde-1], Nivel),
    list_to_assoc([Desde-si], Vistas),
    niveles(Plano, Nivel, Vistas, Hasta, N).

%!  niveles(+Plano, +Nivel, +Vistas, +Hasta, -N:integer) is semidet.
%
%   Nivel da, para cada celda a la misma distancia, cuántos caminos mínimos
%   llegan a ella.
niveles(Plano, Nivel, Vistas, Hasta, N) :-
    (   get_assoc(Hasta, Nivel, N0)
    ->  N = N0
    ;   assoc_to_list(Nivel, Pares),
        Pares \== [],
        findall(V-K,
                ( member(C-K, Pares),
                  vecina(Plano, C, _, V),
                  \+ get_assoc(V, Vistas, _) ),
                Llegadas),
        keysort(Llegadas, Ordenadas),
        group_pairs_by_key(Ordenadas, Grupos),
        findall(V-S, ( member(V-Ks, Grupos), sum_list(Ks, S) ), Siguiente),
        list_to_assoc(Siguiente, Nivel1),
        foldl(ver, Siguiente, Vistas, Vistas1),
        niveles(Plano, Nivel1, Vistas1, Hasta, N)
    ).

%!  ver(+Par, +Vistas0, -Vistas) is det.
%
%   Vistas es Vistas0 con la celda del Par.
ver(V-_, Vistas0, Vistas) :-
    put_assoc(V, Vistas0, si, Vistas).

% --- Ejercicio 5: IDA* con una tabla ------------------------------------------

%!  ida_con_tabla(+Problema, -Plan:list, -Costo:number, -Expandidos:integer)
%!      is semidet.
%
%   Como ida_estrella/4 del capítulo 40, pero cada iteración recuerda en un
%   assoc el menor costo con que llegó a cada estado y no vuelve a expandir
%   un estado al que llega con un costo igual o mayor: lo que había debajo
%   ya se exploró con la misma cota y más margen.
ida_con_tabla(Problema, Plan, Costo, Expandidos) :-
    capitulo40:inicial(Problema, Estado),
    capitulo40:heuristica(Problema, Estado, Cota),
    iteracion_t(Problema, Estado, Cota, 0, Plan, Costo, Expandidos).

%!  iteracion_t(+Problema, +Estado, +Cota:number, +K0:integer, -Plan:list,
%!              -Costo:number, -K:integer) is semidet.
%
%   Busca con Cota, y si no encuentra un plan, con la cota siguiente.
iteracion_t(Problema, Estado, Cota, K0, Plan, Costo, K) :-
    list_to_assoc([Estado-0], T0),
    acotada_t(Problema, Estado, 0, Cota, T0, _, Resultado, K0, K1),
    (   Resultado = plan(Plan, Costo)
    ->  K = K1
    ;   Resultado = cota(Siguiente),
        Siguiente \== infinito,
        iteracion_t(Problema, Estado, Siguiente, K1, Plan, Costo, K)
    ).

%!  acotada_t(+Problema, +Estado, +G:number, +Cota:number, +T0, -T,
%!            -Resultado, +K0:integer, -K:integer) is det.
%
%   Como acotada/8 del capítulo 40, con la tabla T0 de los menores costos
%   en lugar del rastro del camino.
acotada_t(Problema, Estado, G, Cota, T0, T, Resultado, K0, K) :-
    capitulo40:heuristica(Problema, Estado, H),
    F is G + H,
    (   F > Cota
    ->  Resultado = cota(F),
        T = T0,
        K = K0
    ;   capitulo40:meta(Problema, Estado)
    ->  Resultado = plan([], G),
        T = T0,
        K = K0
    ;   K1 is K0 + 1,
        findall(t(A, S, C),
                capitulo40:sucesor(Problema, Estado, A, S, C),
                Ts),
        probar_t(Ts, Problema, G, Cota, T0, T, infinito, Resultado, K1, K)
    ).

%!  probar_t(+Ts:list, +Problema, +G:number, +Cota:number, +T0, -T,
%!           +Menor, -Resultado, +K0:integer, -K:integer) is det.
%
%   Prueba las transiciones Ts en orden; salta las que llegan a un estado
%   ya alcanzado con un costo menor o igual.
probar_t([], _, _, _, T, T, Menor, cota(Menor), K, K).
probar_t([t(A, S, C)|Ts], Problema, G, Cota, T0, T, Menor0, Resultado,
         K0, K) :-
    G1 is G + C,
    (   get_assoc(S, T0, G0),
        G0 =< G1
    ->  probar_t(Ts, Problema, G, Cota, T0, T, Menor0, Resultado, K0, K)
    ;   put_assoc(S, T0, G1, T1),
        acotada_t(Problema, S, G1, Cota, T1, T2, R, K0, K1),
        (   R = plan(Plan, Costo)
        ->  Resultado = plan([A|Plan], Costo),
            T = T2,
            K = K1
        ;   R = cota(F),
            capitulo40:menor(F, Menor0, Menor),
            probar_t(Ts, Problema, G, Cota, T2, T, Menor, Resultado, K1, K)
        )
    ).

%!  camino_ida_con_tabla(+Plano, +Desde, +Hasta, -Pasos:integer,
%!                       -Expandidos:integer) is semidet.
%
%   Pasos es el largo del camino más corto, hallado con ida_con_tabla/4.
camino_ida_con_tabla(Plano, Desde, Hasta, Pasos, Expandidos) :-
    ida_con_tabla(robot:ruta(Plano, Desde, Hasta, manhattan), _, Pasos,
                  Expandidos).

% --- Ejercicios 7 y 8: otras heurísticas para el laberinto -------------------

%!  salida_manhattan(+Laberinto, -Costo:integer, -Expandidos:integer)
%!      is semidet.
%
%   Costo es el del recorrido más corto del Laberinto, hallado con A* y la
%   distancia horizontal más la cantidad de filas que faltan.
salida_manhattan(Laberinto, Costo, Expandidos) :-
    laberinto(Laberinto, Filas),
    buscar(mejor(a_estrella), soluciones:salir_m(Filas), _, Costo,
           Expandidos).

%!  salida_h3(+Laberinto, -Costo:number, -Expandidos:integer) is semidet.
%
%   Como salida_manhattan/3, con la heurística H3: vuelos en tres tramos.
salida_h3(Laberinto, Costo, Expandidos) :-
    laberinto(Laberinto, Filas),
    buscar(mejor(a_estrella), soluciones:salir_h3(Filas), _, Costo,
           Expandidos).

%!  estimacion_h3(+Laberinto, +X, -H:number) is det.
%
%   H es lo que estima H3 de la compuerta X a la salida del Laberinto.
estimacion_h3(Laberinto, X, H) :-
    laberinto(Laberinto, Filas),
    heuristica(salir_h3(Filas), X, H).

%!  h3(+Filas:list, +X, +Y, -H:number) is det.
%
%   H es la mayor, sobre los pares de filas intermedias, de la menor
%   longitud de un vuelo de X a Y en tres tramos rectos que pasa por una
%   compuerta de cada fila; si no hay dos filas intermedias, es la
%   estimación vuelo del capítulo.
h3(Filas, X, Y, H) :-
    X = g(F1, _),
    Y = g(F2, _),
    laberinto:estimacion(vuelo, Filas, X, Y, H2),
    findall(V,
            ( between(F1, F2, R1), R1 > F1,
              between(R1, F2, R2), R2 > R1, R2 < F2,
              vuelo3(Filas, X, Y, R1, R2, V) ),
            Vs),
    max_list([H2|Vs], H).

%!  vuelo3(+Filas:list, +X, +Y, +R1:integer, +R2:integer, -V:number)
%!      is det.
%
%   V es el vuelo más corto de X a Y que pasa por una compuerta de la fila
%   R1 y después por una de la fila R2.
vuelo3(Filas, X, Y, R1, R2, V) :-
    nth1(R1, Filas, Fila1),
    nth1(R2, Filas, Fila2),
    aggregate_all(min(D),
                  ( member(P, Fila1),
                    member(Q, Fila2),
                    laberinto:recta(X, g(R1, P), D1),
                    laberinto:recta(g(R1, P), g(R2, Q), D2),
                    laberinto:recta(g(R2, Q), Y, D3),
                    D is D1 + D2 + D3 ),
                  V).

% --- Ejercicios 9 y 10: medir las heurísticas del caballo ---------------------

%!  distancias(+N:integer, +Desde, -Distancias) is det.
%
%   Distancias es un assoc con la cantidad mínima de saltos del caballo
%   desde Desde hasta cada casilla del tablero de N x N, calculada en
%   anchura por niveles.
distancias(N, Desde, Distancias) :-
    list_to_assoc([Desde-0], D0),
    capas(N, [Desde], 0, D0, Distancias).

%!  capas(+N:integer, +Nivel:list, +K:integer, +D0, -D) is det.
%
%   Nivel son las casillas a K saltos; D agrega a D0 las que siguen.
capas(_, [], _, D, D) :-
    !.
capas(N, Nivel, K, D0, D) :-
    K1 is K + 1,
    findall(S,
            ( member(C, Nivel),
              salto(N, C, S, _),
              \+ get_assoc(S, D0, _) ),
            Ss0),
    sort(Ss0, Ss),
    foldl(con_distancia(K1), Ss, D0, D1),
    capas(N, Ss, K1, D1, D).

%!  saltos_minimos(+N:integer, +A, +B, -D:integer) is semidet.
%
%   D es la menor cantidad de saltos del caballo de A a B en el tablero de
%   N x N. Falla si no se puede llegar.
saltos_minimos(N, A, B, D) :-
    distancias(N, A, Ds),
    get_assoc(B, Ds, D).

%!  con_distancia(+K:integer, +S, +D0, -D) is det.
%
%   D es D0 con la casilla S a K saltos.
con_distancia(K, S, D0, D) :-
    put_assoc(S, D0, K, D).

%!  sobreestimaciones(+Heuristica, -Pares:list) is det.
%
%   Pares son los pares Desde-Hasta de casillas del tablero de 8 x 8,
%   Desde antes que Hasta en el orden estándar, en los que la Heuristica
%   estima más saltos que los necesarios.
sobreestimaciones(Heuristica, Pares) :-
    findall(A-B,
            ( casilla8(A),
              distancias(8, A, Ds),
              casilla8(B),
              A @< B,
              get_assoc(B, Ds, D),
              estimar(Heuristica, A, B, H),
              H > D ),
            Pares).

%!  admisible(+N:integer, +Heuristica) is semidet.
%
%   La Heuristica no estima de más para ningún par de casillas del tablero
%   de N x N.
admisible(N, Heuristica) :-
    forall(( between(1, N, X), between(1, N, Y) ),
           ( distancias(N, X-Y, Ds),
             forall(gen_assoc(B, Ds, D),
                    ( estimar(Heuristica, X-Y, B, H),
                      H =< D )) )).

%!  casilla8(-C) is multi.
%
%   C es una casilla del tablero de 8 x 8.
casilla8(X-Y) :-
    between(1, 8, X),
    between(1, 8, Y).

% --- Ejercicio 11: el recorrido cerrado -------------------------------------

%!  recorrido_cerrado(+N:integer, +Desde, -Camino:list) is nondet.
%
%   Camino es un recorrido del caballo por el tablero de N x N que empieza
%   en Desde y termina a un salto de Desde, hallado con la regla de
%   Warnsdorff.
recorrido_cerrado(N, Desde, Camino) :-
    recorrido(warnsdorff, N, Desde, Camino),
    last(Camino, Ultima),
    salto(N, Ultima, Desde, _).
