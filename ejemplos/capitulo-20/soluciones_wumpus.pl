:- encoding(utf8).

% Capítulo 20 - Soluciones de los ejercicios 11 y 12: el mundo del Wumpus.
%
% El agente y la cueva son los de wumpus.pl. camino_de_vuelta/2 es el
% ejercicio 11 y posible_pozo/1 el 12.
%
%?- explorar(oro(C)), camino_de_vuelta(C, Camino).
%?- explorar(_), findall(C, posible_pozo(C), L).

:- dynamic percibio/2, visitada/1.

% --- La cueva: el agente no consulta estos hechos, solo los percibe --------

% pozo(C): hay un pozo en la celda C.
pozo(3-1).
pozo(3-3).
pozo(4-4).

% wumpus(C): el wumpus está en la celda C.
wumpus(1-3).

% oro(C): el oro está en la celda C.
oro(2-3).

%!  vecina(+C, -V) is nondet.
%
%   V es una celda vecina de C, arriba, abajo, a la izquierda o a la derecha,
%   dentro de la cueva de 4 x 4.
vecina(X-Y, VX-VY) :-
    member(DX-DY, [1-0, -1-0, 0-1, 0-(-1)]),
    VX is X + DX,
    VY is Y + DY,
    between(1, 4, VX),
    between(1, 4, VY).

%!  percepcion(+C, -P) is nondet.
%
%   P es una de las percepciones de la celda C: brisa, hedor o brillo.
percepcion(C, brisa) :-
    once(( vecina(C, V), pozo(V) )).
percepcion(C, hedor) :-
    once(( vecina(C, V), wumpus(V) )).
percepcion(C, brillo) :-
    oro(C).

% --- El conocimiento del agente ----------------------------------------------

%!  reiniciar is det.
%
%   Borra el conocimiento del agente: ninguna celda visitada, ninguna
%   percepción.
reiniciar :-
    retractall(visitada(_)),
    retractall(percibio(_, _)).

%!  visitar(+C) is det.
%
%   El agente entra en la celda C y registra lo que percibe allí.
visitar(C) :-
    assertz(visitada(C)),
    forall(percepcion(C, P), assertz(percibio(C, P))).

%!  sin_pozo(+C) is semidet.
%
%   Está probado que C no tiene pozo: alguna vecina visitada no tuvo brisa.
sin_pozo(C) :-
    once(( vecina(C, V),
           visitada(V),
           \+ percibio(V, brisa) )).

%!  sin_wumpus(+C) is semidet.
%
%   Está probado que el wumpus no está en C: alguna vecina visitada no
%   tuvo hedor.
sin_wumpus(C) :-
    once(( vecina(C, V),
           visitada(V),
           \+ percibio(V, hedor) )).

%!  segura(+C) is semidet.
%
%   C es segura: se visitó, o está probado que no tiene pozo ni wumpus.
segura(C) :-
    (   visitada(C)
    ->  true
    ;   sin_pozo(C),
        sin_wumpus(C)
    ).

%!  siguiente(-C) is semidet.
%
%   C es la primera celda segura sin visitar vecina de una visitada, en el
%   orden en que se visitaron. Falla si no queda ninguna.
siguiente(C) :-
    once(( visitada(V),
           vecina(V, C),
           \+ visitada(C),
           segura(C) )).

%!  explorar(-Resultado) is det.
%
%   El agente explora la cueva desde (1, 1). Resultado es oro(C) si encuentra
%   el oro en C, o sin_celdas_seguras si no queda adónde ir.
explorar(Resultado) :-
    reiniciar,
    visitar(1-1),
    explorar_(Resultado).

%!  explorar_(-Resultado) is det.
%
%   Un paso de la exploración: termina si ya percibió el brillo, o visita la
%   siguiente celda segura y continúa.
explorar_(Resultado) :-
    (   percibio(C, brillo)
    ->  Resultado = oro(C)
    ;   siguiente(C)
    ->  visitar(C),
        explorar_(Resultado)
    ;   Resultado = sin_celdas_seguras
    ).

%!  recorrido(-Celdas:list) is det.
%
%   Celdas son las celdas visitadas, en el orden en que se visitaron.
recorrido(Celdas) :-
    findall(C, visitada(C), Celdas).

% --- Ejercicio 11 -------------------------------------------------------------

%!  camino_de_vuelta(+Desde, -Camino:list) is semidet.
%
%   Camino es una lista de celdas visitadas, vecinas de a pares, que va de
%   Desde a la entrada, (1, 1), sin repetir ninguna. Falla si no hay camino
%   por celdas visitadas.
camino_de_vuelta(Desde, Camino) :-
    once(camino(Desde, [Desde], Invertido)),
    reverse(Invertido, Camino).

%!  camino(+Celda, +Recorridas:list, -Invertido:list) is nondet.
%
%   Invertido es Recorridas, la última celda primero, extendida por celdas
%   visitadas hasta la entrada. Recorridas evita volver a pasar por una celda.
camino(1-1, Recorridas, Recorridas).
camino(Celda, Recorridas, Invertido) :-
    Celda \== 1-1,
    vecina(Celda, Siguiente),
    visitada(Siguiente),
    \+ memberchk(Siguiente, Recorridas),
    camino(Siguiente, [Siguiente|Recorridas], Invertido).

% --- Ejercicio 12 -------------------------------------------------------------

%!  posible_pozo(?C) is nondet.
%
%   C puede tener un pozo: no se visitó, es vecina de una celda visitada con
%   brisa, y ninguna vecina visitada sin brisa lo descarta.
posible_pozo(C) :-
    setof(C0, V^( visitada(V),
                  percibio(V, brisa),
                  vecina(V, C0),
                  \+ visitada(C0),
                  \+ sin_pozo(C0) ), Celdas),
    member(C, Celdas).
