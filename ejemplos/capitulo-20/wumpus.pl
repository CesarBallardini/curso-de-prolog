:- encoding(utf8).

% Capítulo 20 - El agente del mundo del Wumpus.
%
% Una cueva de 4 x 4 celdas tiene pozos, un wumpus y oro. En la celda vecina
% de un pozo se siente brisa; en la vecina del wumpus, hedor; en la del oro,
% brillo. El agente empieza en (1, 1) y solo conoce lo que percibió: sus
% percepciones y las celdas que visitó son hechos dinámicos que agrega a
% medida que explora. Con ellos deduce qué celdas son seguras, y se mueve
% solo a esas, hasta encontrar el oro o quedarse sin celdas seguras.
%
% La cueva es la de la figura 7.2 de Russell y Norvig, Artificial
% Intelligence: A Modern Approach, con las celdas escritas X-Y.
%
%?- explorar(Resultado), recorrido(Celdas).
%?- explorar(_), segura(3-2).

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
