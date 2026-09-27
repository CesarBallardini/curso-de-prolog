:- encoding(utf8).

% Capítulo 22 - Soluciones de los ejercicios 10 y 11: el mundo de bloques.
%
% El mundo y la búsqueda a lo ancho son los de bloques.pl. plan_iterativo/3
% es el ejercicio 10: búsqueda en profundidad con un límite que crece.
% plan_contando/4 es el ejercicio 11: la búsqueda a lo ancho que cuenta los
% estados visitados.
%
%?- plan_iterativo(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia), P).
%?- plan_contando(estado([[c,a], [b]], vacia), estado([[a,b,c]], vacia), P, N).

%!  normalizar(+Estado0, -Estado) is det.
%
%   Estado es Estado0 con las pilas ordenadas: dos estados con las mismas
%   pilas en distinto orden son el mismo estado.
normalizar(estado(Pilas0, Mano), estado(Pilas, Mano)) :-
    msort(Pilas0, Pilas).

%!  sucesor(+Estado, -Accion, -Siguiente) is nondet.
%
%   La pinza pasa de Estado a Siguiente con Accion: tomar(B), soltar(B) o
%   apilar(B, C). Siguiente está normalizado.
sucesor(estado(Pilas, vacia), tomar(B), Siguiente) :-
    select([B|Resto], Pilas, Otras),
    (   Resto == []
    ->  Nuevas = Otras
    ;   Nuevas = [Resto|Otras]
    ),
    normalizar(estado(Nuevas, B), Siguiente).
sucesor(estado(Pilas, B), soltar(B), Siguiente) :-
    B \== vacia,
    normalizar(estado([[B]|Pilas], vacia), Siguiente).
sucesor(estado(Pilas, B), apilar(B, C), Siguiente) :-
    B \== vacia,
    select([C|Resto], Pilas, Otras),
    normalizar(estado([[B, C|Resto]|Otras], vacia), Siguiente).

%!  plan(+Inicial, +Meta, -Plan:list) is semidet.
%
%   Plan es una de las secuencias de acciones más cortas que llevan de
%   Inicial a Meta. Falla si Meta no se puede alcanzar.
plan(Inicial, Meta, Plan) :-
    normalizar(Inicial, I),
    normalizar(Meta, M),
    a_lo_ancho([I-[]], [I], M, Invertido),
    reverse(Invertido, Plan).

%!  a_lo_ancho(+Cola:list(pair), +Visitados:list, +Meta, -Camino) is semidet.
%
%   Cola tiene los estados por examinar, cada uno con el camino que llegó a
%   él, la última acción primero. Visitados es el conjunto ordenado de los
%   estados ya encolados, que no se vuelven a encolar.
a_lo_ancho([Estado-Camino|Cola], Visitados, Meta, Plan) :-
    (   Estado == Meta
    ->  Plan = Camino
    ;   findall(S-[A|Camino],
                ( sucesor(Estado, A, S),
                  \+ ord_memberchk(S, Visitados) ),
                Nuevos0),
        sort(1, @<, Nuevos0, Nuevos),
        pairs_keys(Nuevos, Estados),
        ord_union(Visitados, Estados, Visitados1),
        append(Cola, Nuevos, Cola1),
        a_lo_ancho(Cola1, Visitados1, Meta, Plan)
    ).

% --- Ejercicio 10 ---------------------------------------------------------

%!  plan_iterativo(+Inicial, +Meta, -Plan:list) is semidet.
%
%   Plan es una de las secuencias de acciones más cortas de Inicial a Meta,
%   buscada en profundidad con un límite de 0, 1, 2, … acciones, hasta 20.
plan_iterativo(Inicial, Meta, Plan) :-
    normalizar(Inicial, I),
    normalizar(Meta, M),
    between(0, 20, Limite),
    en_profundidad(I, M, Limite, [I], Plan),
    !.

%!  en_profundidad(+Estado, +Meta, +Limite:integer, +Camino:list, -Plan)
%!      is nondet.
%
%   Plan lleva de Estado a Meta con a lo sumo Limite acciones, sin pasar por
%   los estados de Camino.
en_profundidad(Estado, Meta, _, _, []) :-
    Estado == Meta.
en_profundidad(Estado, Meta, Limite, Camino, [A|Plan]) :-
    Estado \== Meta,
    Limite > 0,
    sucesor(Estado, A, Siguiente),
    \+ memberchk(Siguiente, Camino),
    Resto is Limite - 1,
    en_profundidad(Siguiente, Meta, Resto, [Siguiente|Camino], Plan).

% --- Ejercicio 11 ---------------------------------------------------------

%!  plan_contando(+Inicial, +Meta, -Plan:list, -Visitados:integer) is semidet.
%
%   Como plan/3; Visitados es la cantidad de estados que la búsqueda encoló
%   hasta encontrar la meta.
plan_contando(Inicial, Meta, Plan, Visitados) :-
    normalizar(Inicial, I),
    normalizar(Meta, M),
    contando([I-[]], [I], M, Invertido, Visitados),
    reverse(Invertido, Plan).

%!  contando(+Cola, +Visitados, +Meta, -Camino, -Cantidad) is semidet.
%
%   Como a_lo_ancho/4; Cantidad es el tamaño del conjunto de visitados al
%   encontrar la meta.
contando([Estado-Camino|Cola], Visitados, Meta, Plan, Cantidad) :-
    (   Estado == Meta
    ->  Plan = Camino,
        length(Visitados, Cantidad)
    ;   findall(S-[A|Camino],
                ( sucesor(Estado, A, S),
                  \+ ord_memberchk(S, Visitados) ),
                Nuevos0),
        sort(1, @<, Nuevos0, Nuevos),
        pairs_keys(Nuevos, Estados),
        ord_union(Visitados, Estados, Visitados1),
        append(Cola, Nuevos, Cola1),
        contando(Cola1, Visitados1, Meta, Plan, Cantidad)
    ).
