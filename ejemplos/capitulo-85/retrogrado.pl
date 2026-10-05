:- encoding(utf8).

% Capítulo 85 - La tabla de un juego, calculada hacia atrás.
%
% Un juego es una lista de jugadas X-Y: el que mueve en X puede dejar al
% rival en Y. Pierde quien no tiene jugadas. La tabla del juego da a cada
% posición gana(K) o pierde(K): el que mueve gana en K jugadas con el
% mejor juego de los dos, o pierde en K. Las posiciones que no reciben
% valor son tablas: ninguno puede forzar el final.
%
% rondas/3 calcula la tabla como el capítulo 79: en cada ronda examina
% todas las posiciones sin valor, hasta que una ronda no agrega nada.
% retrogrado/3 la calcula como la evaluación semi-ingenua: cada ronda
% parte solo de las posiciones que recibieron valor en la anterior y
% visita sus predecesoras; cada posición lleva la cuenta de sus jugadas
% que todavía no llevan a una posición ganada por el rival, y pierde
% cuando esa cuenta llega a 0. Las dos cuentan los arcos que examinan.
%
%?- rondas([a-b, b-c], T, N).
%?- retrogrado([a-b, b-c], T, N).
%?- restar(12, Js), retrogrado(Js, T, N).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(assoc)).
:- use_module(library(pairs)).

%!  restar(+N:integer, -Jugadas:list) is det.
%
%   Jugadas son las del juego de restar: una pila de N fichas, de la que
%   cada jugador saca 1, 2 o 3.
restar(N, Jugadas) :-
    findall(X-Y,
            ( between(1, N, X),
              between(1, 3, M),
              Y is X - M,
              Y >= 0 ),
            Jugadas).

%!  posiciones(+Jugadas:list, -Ps:list) is det.
%
%   Ps son, ordenadas, las posiciones que aparecen en las Jugadas.
posiciones(Jugadas, Ps) :-
    findall(P, ( member(X-Y, Jugadas), ( P = X ; P = Y ) ), Ps0),
    sort(Ps0, Ps).

%!  vecinos(+Pares:list, +Ps:list, -Vecinos) is det.
%
%   Vecinos es un árbol de library(assoc) que lleva cada posición de Ps a
%   la lista de las segundas componentes de sus Pares X-Y.
vecinos(Pares, Ps, Vecinos) :-
    findall(P-[], member(P, Ps), Vacios),
    list_to_assoc(Vacios, V0),
    foldl(agregar_vecino, Pares, V0, Vecinos).

%!  agregar_vecino(+Par, +V0, -V) is det.
%
%   V agrega a V0 la segunda componente de Par, X-Y, a la lista de X.
agregar_vecino(X-Y, V0, V) :-
    get_assoc(X, V0, Ys),
    put_assoc(X, V0, [Y|Ys], V).

%!  rondas(+Jugadas:list, -Tabla:list, -Arcos:integer) is det.
%
%   Tabla son los pares Posicion-Valor de las posiciones con valor,
%   ordenados; Arcos, los que se examinaron. Pierden en 0 las posiciones
%   sin jugadas; en cada ronda K, toda posición sin valor se examina: gana
%   en K si una jugada lleva a una que pierde, y pierde en K si todas
%   llevan a posiciones que ganan.
rondas(Jugadas, Tabla, Arcos) :-
    posiciones(Jugadas, Ps),
    vecinos(Jugadas, Ps, Sucesoras),
    findall(P-pierde(0), ( member(P, Ps), get_assoc(P, Sucesoras, []) ),
            Finales),
    list_to_assoc(Finales, Valores0),
    ronda(1, Ps, Sucesoras, Valores0, Valores, 0, Arcos),
    assoc_to_list(Valores, Tabla).

%!  ronda(+K:integer, +Ps:list, +Sucesoras, +Valores0, -Valores,
%!        +Arcos0:integer, -Arcos:integer) is det.
%
%   Valores agrega a Valores0 las posiciones que reciben valor en la ronda
%   K y en las siguientes, hasta una ronda que no agrega nada.
ronda(K, Ps, Sucesoras, Valores0, Valores, Arcos0, Arcos) :-
    findall(P-V-N,
            ( member(P, Ps),
              \+ get_assoc(P, Valores0, _),
              get_assoc(P, Sucesoras, Ss),
              length(Ss, N),
              valor_en(K, Ss, Valores0, V) ),
            Nuevos),
    findall(P, ( member(P, Ps), \+ get_assoc(P, Valores0, _) ), SinValor),
    foldl(sumar_sucesoras(Sucesoras), SinValor, Arcos0, Arcos1),
    (   Nuevos == []
    ->  Valores = Valores0,
        Arcos = Arcos1
    ;   foldl(poner_valor, Nuevos, Valores0, Valores1),
        K1 is K + 1,
        ronda(K1, Ps, Sucesoras, Valores1, Valores, Arcos1, Arcos)
    ).

%!  valor_en(+K:integer, +Ss:list, +Valores, -V) is semidet.
%
%   V es gana(K) si una de las sucesoras Ss pierde, o pierde(K) si todas
%   ganan, según los Valores de las rondas anteriores.
valor_en(K, Ss, Valores, V) :-
    (   member(S, Ss),
        get_assoc(S, Valores, pierde(_))
    ->  V = gana(K)
    ;   forall(member(S, Ss), get_assoc(S, Valores, gana(_)))
    ->  V = pierde(K)
    ).

%!  sumar_sucesoras(+Sucesoras, +P, +N0:integer, -N:integer) is det.
%
%   N es N0 más la cantidad de sucesoras de P.
sumar_sucesoras(Sucesoras, P, N0, N) :-
    get_assoc(P, Sucesoras, Ss),
    length(Ss, L),
    N is N0 + L.

%!  poner_valor(+Nuevo, +Valores0, -Valores) is det.
%
%   Valores agrega a Valores0 el valor V de Nuevo, P-V-N.
poner_valor(P-V-_, Valores0, Valores) :-
    put_assoc(P, Valores0, V, Valores).

%!  retrogrado(+Jugadas:list, -Tabla:list, -Arcos:integer) is det.
%
%   La misma Tabla que rondas/3. Cada ronda parte de las posiciones que
%   recibieron valor en la anterior, las nuevas, y examina solo los arcos
%   que llegan a ellas: una predecesora sin valor gana si la nueva pierde,
%   y si la nueva gana, descuenta una de sus jugadas pendientes, y pierde
%   cuando no le quedan.
retrogrado(Jugadas, Tabla, Arcos) :-
    posiciones(Jugadas, Ps),
    vecinos(Jugadas, Ps, Sucesoras),
    findall(Y-X, member(X-Y, Jugadas), Inversas),
    vecinos(Inversas, Ps, Predecesoras),
    findall(P-N,
            ( member(P, Ps),
              get_assoc(P, Sucesoras, Ss),
              length(Ss, N) ),
            Cuentas0),
    list_to_assoc(Cuentas0, Cuentas),
    findall(P-pierde(0), member(P-0, Cuentas0), Finales),
    list_to_assoc(Finales, Valores0),
    pairs_keys(Finales, Nuevas),
    hacia_atras(1, Nuevas, Predecesoras, Cuentas, Valores0, Valores,
                0, Arcos),
    assoc_to_list(Valores, Tabla).

%!  hacia_atras(+K:integer, +Nuevas:list, +Predecesoras, +Cuentas0,
%!              +Valores0, -Valores, +Arcos0:integer, -Arcos:integer)
%!      is det.
%
%   Valores agrega a Valores0 los de la ronda K, que parte de las
%   posiciones Nuevas, y los de las siguientes, hasta que no hay nuevas.
hacia_atras(K, Nuevas, Predecesoras, Cuentas0, Valores0, Valores,
            Arcos0, Arcos) :-
    (   Nuevas == []
    ->  Valores = Valores0,
        Arcos = Arcos0
    ;   foldl(propagar(K, Predecesoras, Valores0), Nuevas,
              Cuentas0-[]-Arcos0, Cuentas-Ganadas0-Arcos1),
        sort(Ganadas0, Ganadas),
        foldl(poner_valor, Ganadas, Valores0, Valores1),
        findall(P, member(P-_-_, Ganadas), Siguientes),
        K1 is K + 1,
        hacia_atras(K1, Siguientes, Predecesoras, Cuentas, Valores1,
                    Valores, Arcos1, Arcos)
    ).

%!  propagar(+K:integer, +Predecesoras, +Valores, +Nueva, +Estado0,
%!           -Estado) is det.
%
%   Estado0 es Cuentas0-Ganadas0-Arcos0. Recorre los arcos que llegan a la
%   posición Nueva desde las predecesoras sin valor: si Nueva pierde, la
%   predecesora gana en K; si gana, la cuenta de la predecesora baja en 1,
%   y al llegar a 0 pierde en K. Ganadas agrega los términos P-V-0 de las
%   posiciones que reciben valor.
propagar(K, Predecesoras, Valores, Nueva, C0-G0-A0, C-G-A) :-
    get_assoc(Nueva, Valores, VNueva),
    get_assoc(Nueva, Predecesoras, Qs),
    length(Qs, L),
    A is A0 + L,
    foldl(predecesora(K, VNueva, Valores), Qs, C0-G0, C-G).

%!  predecesora(+K:integer, +VNueva, +Valores, +Q, +Estado0, -Estado)
%!      is det.
%
%   Estado0 es Cuentas0-Ganadas0: aplica a la predecesora Q el valor
%   VNueva de una de sus sucesoras, si Q no tiene valor todavía.
predecesora(K, VNueva, Valores, Q, C0-G0, C-G) :-
    (   get_assoc(Q, Valores, _)
    ->  C = C0,
        G = G0
    ;   VNueva = pierde(_)
    ->  C = C0,
        G = [Q-gana(K)-0|G0]
    ;   get_assoc(Q, C0, N0),
        N is N0 - 1,
        put_assoc(Q, C0, N, C),
        (   N =:= 0
        ->  G = [Q-pierde(K)-0|G0]
        ;   G = G0
        )
    ).
