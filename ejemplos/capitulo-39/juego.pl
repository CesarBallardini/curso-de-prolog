:- encoding(utf8).

% Capítulo 39 - Negación tabulada: la semántica bien fundada en SWI-Prolog.
%
% El juego de posiciones ganadoras del capítulo 38: el jugador que no puede
% mover pierde, y una posición gana si hay un movimiento a una posición que
% no gana para el rival. gana/2 depende de su propia negación. Con \+,
% Prolog no termina en los ciclos; con gana/2 tabulado y tnot/1 en lugar de
% \+, la consulta termina, y una posición de empate es una respuesta
% indefinida: se prueba solo con la condición de que otra posición no gane.
% valor/2 clasifica una meta sin variables en verdadera, falsa o
% indefinida con call_delays/2.
%
%?- gana(j1, X).
%?- gana(j2, c).
%?- valor(gana(j2, a), V).

% mueve(Juego, X, Y): en Juego, un jugador puede pasar de la posición X a
% la posición Y.
mueve(j1, a, b).
mueve(j1, b, a).
mueve(j1, b, c).
mueve(j2, a, b).
mueve(j2, b, a).
mueve(j2, b, c).
mueve(j2, c, d).

%!  gana_prolog(?Juego, ?X) is nondet.
%
%   En Juego, quien mueve desde X gana, con la negación de Prolog. Con los
%   ciclos de a y b, la consulta no termina.
gana_prolog(J, X) :-
    mueve(J, X, Y),
    \+ gana_prolog(J, Y).

:- table gana/2.

%!  gana(?Juego, ?X) is nondet.
%
%   En Juego, quien mueve desde X gana: puede pasar a una posición desde la
%   que el rival no gana. Las posiciones de empate son respuestas
%   indefinidas.
gana(J, X) :-
    mueve(J, X, Y),
    tnot(gana(J, Y)).

%!  valor(+Meta, -Valor) is det.
%
%   Valor es verdadero, falso o indefinido: el de Meta, tabulada y sin
%   variables, en la semántica bien fundada. Una respuesta sin condiciones
%   hace verdadera la meta; si todas tienen condiciones, es indefinida.
valor(Meta, Valor) :-
    must_be(ground, Meta),
    findall(Condicion, call_delays(Meta, Condicion), Condiciones),
    (   Condiciones == []
    ->  Valor = falso
    ;   memberchk(true, Condiciones)
    ->  Valor = verdadero
    ;   Valor = indefinido
    ).
