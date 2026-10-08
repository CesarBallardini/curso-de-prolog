:- encoding(utf8).

% Capítulo 16 - Indexación y puntos de elección.
%
% SWI-Prolog elige las cláusulas candidatas examinando los argumentos de la
% llamada. ultimo/2 del capítulo 7 no se distingue por el primer argumento y
% deja una alternativa al final; ultimo_indexado/2 pasa la lista al primer
% argumento de un auxiliar, que se distingue en [] y [_|_]. todos_estan/2 deja
% una alternativa en cada paso, y con ella la pila crece; con memberchk/2, no.
% copias/3 arma los datos de esa medición.
%
%?- ultimo_indexado([a, b, c], U).
%?- todos_estan_chk([a, b], [a, b, c]).
%?- copias(3, a, L).

%!  ultimo(?L:list, ?X) is nondet.
%
%   X es el último elemento de L. Las dos cláusulas empiezan con una lista no
%   vacía: al llegar al último elemento, la segunda queda pendiente.
ultimo([X], X).
ultimo([_|Resto], X) :-
    ultimo(Resto, X).

%!  ultimo_indexado(+L:list, -X) is semidet.
%
%   X es el último elemento de L, sin dejar alternativas.
ultimo_indexado([Primero|Resto], X) :-
    ultimo_desde(Resto, Primero, X).

%!  ultimo_desde(+L:list, +Anterior, -X) is det.
%
%   X es el último de L, o Anterior si L está vacía. El primer argumento
%   distingue las dos cláusulas: [] y [_|_].
ultimo_desde([], X, X).
ultimo_desde([Siguiente|Resto], _, X) :-
    ultimo_desde(Resto, Siguiente, X).

%!  esta_en(?X, ?L:list) is nondet.
%
%   X es uno de los elementos de L.
esta_en(X, [X|_]).
esta_en(X, [_|Resto]) :-
    esta_en(X, Resto).

%!  todos_estan(+Buscados:list, +L:list) is nondet.
%
%   Todos los elementos de Buscados están en L. esta_en/2 deja una
%   alternativa cada vez que encuentra un elemento antes del final de L.
todos_estan([], _).
todos_estan([X|Resto], L) :-
    esta_en(X, L),
    todos_estan(Resto, L).

%!  todos_estan_chk(+Buscados:list, +L:list) is semidet.
%
%   La misma relación con memberchk/2, que se cumple a lo sumo una vez.
todos_estan_chk([], _).
todos_estan_chk([X|Resto], L) :-
    memberchk(X, L),
    todos_estan_chk(Resto, L).

%!  copias(+N:integer, +X, -L:list) is det.
%
%   L es la lista de N copias de X: los datos con que se mide todos_estan/2.
copias(N, X, L) :-
    (   N =:= 0
    ->  L = []
    ;   L = [X|Resto],
        Faltan is N - 1,
        copias(Faltan, X, Resto)
    ).
