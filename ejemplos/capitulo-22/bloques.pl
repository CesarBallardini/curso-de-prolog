:- encoding(utf8).

% Capítulo 22 - El mundo de bloques con una pinza: un estado como término y
% una búsqueda a lo ancho con visitados.
%
% Un estado es estado(Pilas, Mano): Pilas es la lista de las pilas de bloques
% sobre la mesa, cada una con el bloque de arriba primero, y Mano es vacia o
% el bloque que sostiene la pinza. La pinza toma el bloque de arriba de una
% pila, lo suelta sobre la mesa, o lo apila sobre otro. plan/3 busca la
% secuencia de acciones más corta de un estado a otro.
%
%?- plan(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia), Plan).
%?- sucesor(estado([[c, a], [b]], vacia), Accion, Estado).

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
