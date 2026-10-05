:- encoding(utf8).

% Capítulo 78 - Soluciones de los ejercicios.
%
% Carga nim.pl, candidatos.pl (que carga mastermind.pl) y kalah.pl sin
% modificarlos. Los juegos nuevos de los ejercicios 3 y 10 agregan sus
% cláusulas al módulo capitulo41, como nim.pl y kalah.pl.
%
% solo-local: carga otros archivos.
%
%?- segura_miseria([1, 1, 1]).
%?- particion([0, 1, 2, 3], Clases).

:- use_module(nim).
:- use_module(candidatos).
:- use_module(kalah).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

% --- Ejercicio 2: el Nim de la miseria ---------------------------------------

%!  ganadora_miseria(+Pilas:list(integer)) is semidet.
%
%   En el Nim en que pierde quien saca la última ficha, el que mueve en
%   Pilas gana. Búsqueda tabulada sobre la forma de la posición.
ganadora_miseria(Pilas) :-
    forma(Pilas, Forma),
    ganadora_miseria_forma(Forma).

:- table ganadora_miseria_forma/1.

%!  ganadora_miseria_forma(+Forma:list(integer)) is semidet.
%
%   ganadora_miseria/1 sobre una forma. Sin fichas, el que mueve ganó: el
%   rival sacó la última.
ganadora_miseria_forma(Forma) :-
    (   Forma == []
    ->  true
    ;   once(( sacar(Forma, _, Pilas1),
               forma(Pilas1, Forma1),
               \+ ganadora_miseria_forma(Forma1) ))
    ).

%!  segura_miseria(+Pilas:list(integer)) is semidet.
%
%   Pilas es segura en el Nim de la miseria: si ninguna pila tiene más de
%   una ficha, hay una cantidad impar de pilas de una ficha; si no, la
%   suma de Nim es 0.
segura_miseria(Pilas) :-
    max_list([0|Pilas], Mayor),
    (   Mayor =< 1
    ->  sum_list(Pilas, Unos),
        Unos mod 2 =:= 1
    ;   segura(Pilas)
    ).

% --- Ejercicio 3: la suma de Nim como evaluación -----------------------------

% nim_suma(Pilas) es nim(Pilas) con una evaluación que no es nula: 50 si
% la posición es buena para max según la suma de Nim, -50 si no.

%!  capitulo41:inicial(+Juego, -Posicion) is det.
%
%   nim_suma(Pilas) empieza como nim(Pilas).
capitulo41:inicial(nim_suma(Pilas), P) :-
    capitulo41:inicial(nim(Pilas), P).

%!  capitulo41:jugada(+Juego, +Posicion, ?Jugada, -Siguiente) is nondet.
%
%   Las jugadas de nim_suma(Pilas) son las de nim(Pilas).
capitulo41:jugada(nim_suma(Pilas), P, J, P1) :-
    capitulo41:jugada(nim(Pilas), P, J, P1).

%!  capitulo41:turno(+Juego, +Posicion, -Lado) is det.
%
%   Como en nim(Pilas).
capitulo41:turno(nim_suma(Pilas), P, Lado) :-
    capitulo41:turno(nim(Pilas), P, Lado).

%!  capitulo41:fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   Como en nim(Pilas).
capitulo41:fin(nim_suma(Pilas), P, R) :-
    capitulo41:fin(nim(Pilas), P, R).

%!  capitulo41:evaluar(+Juego, +Posicion, -Valor) is det.
%
%   La evaluación de nim_suma/1, con valor_suma/3.
capitulo41:evaluar(nim_suma(_), pilas(Pilas, J), Valor) :-
    valor_suma(Pilas, J, Valor).

%!  valor_suma(+Pilas:list(integer), +Jugador, -Valor:integer) is det.
%
%   Valor es 50 si la posición es buena para max: segura con min por
%   mover, o insegura con max por mover; -50 en los otros casos.
valor_suma(Pilas, J, Valor) :-
    suma_nim(Pilas, S),
    (   ( S =:= 0, J == dos
        ; S =\= 0, J == uno
        )
    ->  Valor = 50
    ;   Valor = -50
    ).

% --- Ejercicio 5: la partición de un intento ---------------------------------

%!  particion(+Intento:list, +Codigos:list, -Clases:list) is det.
%
%   Clases son los términos Toros-Vacas-K, en orden: K códigos de Codigos
%   darían la respuesta Toros-Vacas a Intento.
particion(Intento, Codigos, Clases) :-
    findall(T-V, ( member(C, Codigos),
                   respuesta(C, Intento, T, V) ),
            Respuestas),
    msort(Respuestas, Ordenadas),
    clumped(Ordenadas, Clases).

%!  particion(+Intento:list, -Clases:list) is det.
%
%   particion/3 sobre los 5040 códigos.
particion(Intento, Clases) :-
    candidatos(Codigos),
    particion(Intento, Codigos, Clases).

% --- Ejercicio 6: el intento que deja menos códigos en el peor caso ----------

%!  adivinar_minimax(+Secreto:list, -Intentos:list) is det.
%
%   Como adivinar_candidatos/2, pero cada intento después del primero es
%   el código posible cuya mayor clase es la menor; ante un empate, el
%   primero.
adivinar_minimax(Secreto, Intentos) :-
    candidatos(Codigos),
    minimax_entre(Codigos, [0, 1, 2, 3], Secreto, Intentos).

%!  minimax_entre(+Codigos:list, +Intento:list, +Secreto:list,
%!                -Intentos:list) is det.
%
%   Intentos empiezan con Intento, uno de Codigos, los códigos posibles.
minimax_entre(Codigos, Intento, Secreto, [Intento|Intentos]) :-
    respuesta(Secreto, Intento, T, V),
    (   T =:= 4
    ->  Intentos = []
    ;   filtrar(Codigos, Intento, T, V, Codigos1),
        mejor_intento(Codigos1, Siguiente),
        minimax_entre(Codigos1, Siguiente, Secreto, Intentos)
    ).

%!  mejor_intento(+Codigos:list, -Intento:list) is det.
%
%   Intento es el código de Codigos cuya mayor clase sobre Codigos es la
%   menor; ante un empate, el primero.
mejor_intento(Codigos, Intento) :-
    map_list_to_pairs(peor_clase(Codigos), Codigos, Pares),
    keysort(Pares, [_-Intento|_]).

%!  peor_clase(+Codigos:list, +Intento:list, -Mayor:integer) is det.
%
%   Mayor es la cantidad de códigos de la mayor clase de Intento.
peor_clase(Codigos, Intento, Mayor) :-
    particion(Intento, Codigos, Clases),
    pairs_values(Clases, Ks),
    max_list(Ks, Mayor).

% --- Ejercicio 7: el Mastermind comercial ------------------------------------

%!  codigo_colores(-Codigo:list(integer)) is multi.
%
%   Codigo son cuatro colores, del 1 al 6, que pueden repetirse: 1296
%   códigos, en orden.
codigo_colores([A, B, C, D]) :-
    maplist(color, [A, B, C, D]).

% color(C): C es uno de los seis colores.
color(C) :-
    between(1, 6, C).

%!  respuesta_colores(+Secreto:list, +Intento:list, -Toros:integer,
%!                    -Vacas:integer) is det.
%
%   Toros son las posiciones iguales; Vacas, los colores comunes, cada uno
%   tantas veces como el menor de sus apariciones, menos los toros.
respuesta_colores(Secreto, Intento, Toros, Vacas) :-
    aggregate_all(count, ( nth1(I, Secreto, X), nth1(I, Intento, X) ), Toros),
    aggregate_all(sum(M), ( color(C),
                            veces(C, Secreto, N1),
                            veces(C, Intento, N2),
                            M is min(N1, N2) ),
                  Comunes),
    Vacas is Comunes - Toros.

%!  veces(+X, +Lista:list, -N:integer) is det.
%
%   N es la cantidad de veces que X aparece en Lista.
veces(X, Lista, N) :-
    include(==(X), Lista, Xs),
    length(Xs, N).

%!  adivinar_colores(+Secreto:list, -Intentos:list) is det.
%
%   Intentos son los de la regla de la jugada consistente sobre los 1296
%   códigos de colores, hasta el que acierta.
adivinar_colores(Secreto, Intentos) :-
    findall(C, codigo_colores(C), Codigos),
    colores_entre(Codigos, Secreto, Intentos).

%!  colores_entre(+Codigos:list, +Secreto:list, -Intentos:list) is det.
%
%   Como adivinar_entre/3 de candidatos.pl, con respuesta_colores/4.
colores_entre([Intento|Codigos0], Secreto, [Intento|Intentos]) :-
    respuesta_colores(Secreto, Intento, T, V),
    (   T =:= 4
    ->  Intentos = []
    ;   include(explica_colores(Intento, T, V), Codigos0, Codigos),
        colores_entre(Codigos, Secreto, Intentos)
    ).

%!  explica_colores(+Intento:list, +T:integer, +V:integer, +Codigo:list)
%!      is semidet.
%
%   Si Codigo fuera el secreto, Intento recibiría T toros y V vacas.
explica_colores(Intento, T, V, Codigo) :-
    respuesta_colores(Codigo, Intento, T, V).

%!  medir_colores(-Cuantos:list(pair), -Media:float) is det.
%
%   medir/4 de mastermind.pl sobre los 1296 códigos de colores.
medir_colores(Cuantos, Media) :-
    findall(C, codigo_colores(C), Secretos),
    medir(adivinar_colores, Secretos, Cuantos, Media).

% --- Ejercicio 8: la primera contradicción -----------------------------------

%!  primera_contradiccion(+Respuestas:list, -K:integer) is semidet.
%
%   K es la posición en Respuestas de la primera respuesta después de la
%   cual ningún código las explica a todas. Falla si no hay contradicción.
primera_contradiccion(Respuestas, K) :-
    candidatos(Codigos),
    contradiccion(Respuestas, 1, Codigos, K).

%!  contradiccion(+Respuestas:list, +I:integer, +Codigos:list, -K:integer)
%!      is semidet.
%
%   Como primera_contradiccion/2, con I la posición de la primera de
%   Respuestas y Codigos los que explican las anteriores.
contradiccion([r(Intento, T, V)|Respuestas], I, Codigos0, K) :-
    filtrar(Codigos0, Intento, T, V, Codigos),
    (   Codigos == []
    ->  K = I
    ;   I1 is I + 1,
        contradiccion(Respuestas, I1, Codigos, K)
    ).

% --- Ejercicio 10: Kalah con las piedras de cada lado ------------------------

% kalah_piedras(N) es kalah(N) con otra evaluación: la diferencia de
% kalahs más la mitad de la diferencia de las piedras en los hoyos.

%!  capitulo41:inicial(+Juego, -Posicion) is det.
%
%   kalah_piedras(N) empieza como kalah(N).
capitulo41:inicial(kalah_piedras(N), P) :-
    capitulo41:inicial(kalah(N), P).

%!  capitulo41:jugada(+Juego, +Posicion, ?Jugada, -Siguiente) is nondet.
%
%   Las jugadas de kalah_piedras(N) son las de kalah(N).
capitulo41:jugada(kalah_piedras(N), P, J, P1) :-
    capitulo41:jugada(kalah(N), P, J, P1).

%!  capitulo41:turno(+Juego, +Posicion, -Lado) is det.
%
%   Como en kalah(N).
capitulo41:turno(kalah_piedras(N), P, Lado) :-
    capitulo41:turno(kalah(N), P, Lado).

%!  capitulo41:fin(+Juego, +Posicion, -Resultado) is semidet.
%
%   Como en kalah(N).
capitulo41:fin(kalah_piedras(N), P, R) :-
    capitulo41:fin(kalah(N), P, R).

%!  capitulo41:evaluar(+Juego, +Posicion, -Valor) is det.
%
%   La evaluación de kalah_piedras/1, con piedras/3.
capitulo41:evaluar(kalah_piedras(_), k(T, J), Valor) :-
    piedras(T, J, Valor).

%!  piedras(+Tablero, +Jugador, -Valor:number) is det.
%
%   Valor es, desde sur, la diferencia de los kalahs más la mitad de la
%   diferencia de las piedras de los hoyos, con Tablero visto desde
%   Jugador.
piedras(tablero(Mios, K, Suyos, L), J, Valor) :-
    sum_list(Mios, A),
    sum_list(Suyos, B),
    V is K - L + (A - B) / 2,
    (   J == sur
    ->  Valor = V
    ;   Valor is -V
    ).

%!  torneo(+Juegos:list, +Profundidades:list, -Resultados:list) is det.
%
%   Resultados son los términos r(Sur, Norte, Resultado) de las partidas
%   de kalah(6) con Sur y Norte, pares Juego-Profundidad con distinto
%   juego, como estrategias.
torneo(Juegos, Profundidades, Resultados) :-
    findall(r(GS-DS, GN-DN, R),
            ( member(GS, Juegos), member(GN, Juegos), GS \== GN,
              member(DS, Profundidades), member(DN, Profundidades),
              partida(kalah(6), profundidad_en(GS, DS),
                      profundidad_en(GN, DN), _, R) ),
            Resultados).

%!  profundidad_en(+Juego, +D:integer, +Juego0, +Posicion, -Jugada) is det.
%
%   La estrategia que busca D jugadas hacia adelante con la evaluación de
%   Juego, aunque la partida sea de Juego0: los dos juegos tienen las
%   mismas posiciones y jugadas.
profundidad_en(Juego, D, _, Posicion, Jugada) :-
    alfabeta(Juego, Posicion, D, Jugada, _, _).

%!  puntos(+Resultados:list, -Puntos:list(pair)) is det.
%
%   Puntos son los pares Juego-P: una victoria vale 1 y un empate 0,5.
puntos(Resultados, Puntos) :-
    findall(G-P, ( member(r(GS-_, GN-_, R), Resultados),
                   puntaje(R, GS, GN, G, P) ),
            Todos),
    keysort(Todos, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    maplist(sumar_grupo, Grupos, Puntos).

%!  puntaje(+Resultado, +GS, +GN, -G, -P:number) is nondet.
%
%   El juego G obtiene P puntos en una partida de GS como sur y GN como
%   norte.
puntaje(gana(sur), GS, _, GS, 1).
puntaje(gana(norte), _, GN, GN, 1).
puntaje(empate, GS, GN, G, 0.5) :-
    member(G, [GS, GN]).

%!  sumar_grupo(+Grupo, -Par) is det.
%
%   Par es G-Total, con Total la suma de los puntos del Grupo G-Ps.
sumar_grupo(G-Ps, G-Total) :-
    sum_list(Ps, Total).

% --- Ejercicio 11: el texto de una jugada de Nim -----------------------------

%!  jugada_nim_texto(+Jugada, -Texto:string) is det.
%
%   Texto describe la jugada sacar(K, M) de la computadora.
jugada_nim_texto(sacar(K, M), Texto) :-
    (   M =:= 1
    ->  format(string(Texto), "La computadora saca 1 ficha de la pila ~d.",
               [K])
    ;   format(string(Texto),
               "La computadora saca ~d fichas de la pila ~d.", [M, K])
    ).
