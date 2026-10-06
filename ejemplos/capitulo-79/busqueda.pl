:- encoding(utf8).

% Capítulo 79 - Versión 2: buscar el mate sin conocimiento.
%
% Las blancas dan mate en N jugadas si tienen una jugada tras la cual todas
% las respuestas de las negras llevan a un mate en N - 1, o al mate mismo.
% Es la posición ganada del capítulo 41 como un árbol Y/O, con un límite de
% jugadas: la búsqueda no sabe nada del final salvo sus reglas, y por eso
% recorre todas las jugadas de los dos bandos.
%
% solo-local: carga reglas.pl.
%
%?- mate_forzado(pos(blancas, 2-3, 4-2, 2-1), 1, J).
%?- menor_mate(pos(blancas, 1-3, 4-2, 2-1), 3, N, J).

:- module(busqueda,
          [ mate_forzado/3,
            menor_mate/4
          ]).

:- use_module(reglas).

%!  mate_forzado(+Posicion, +N:integer, -Jugada) is semidet.
%
%   Con las blancas a mover en Posicion, Jugada es la primera de sus
%   jugadas que da mate en a lo sumo N jugadas de las blancas contra
%   cualquier defensa.
mate_forzado(Posicion, N, Jugada) :-
    N >= 1,
    jugada(Posicion, Jugada, Siguiente),
    pierde(Siguiente, N),
    !.

%!  pierde(+Posicion, +N:integer) is semidet.
%
%   Con las negras a mover en Posicion, reciben el mate, ya o en a lo sumo
%   N - 1 jugadas más de las blancas, respondan lo que respondan: ninguna
%   respuesta captura la torre.
pierde(Posicion, N) :-
    (   mate(Posicion)
    ->  true
    ;   N > 1,
        jugada(Posicion, _, _),
        N1 is N - 1,
        forall(jugada(Posicion, _, Siguiente),
               ( Siguiente = pos(_, _, T, _),
                 T \== capturada,
                 mate_forzado(Siguiente, N1, _) ))
    ).

%!  menor_mate(+Posicion, +Maximo:integer, -N:integer, -Jugada) is semidet.
%
%   N es la menor cantidad de jugadas, hasta Maximo, en que las blancas dan
%   mate desde Posicion, y Jugada la primera: profundización iterativa.
menor_mate(Posicion, Maximo, N, Jugada) :-
    between(1, Maximo, N),
    mate_forzado(Posicion, N, Jugada),
    !.
