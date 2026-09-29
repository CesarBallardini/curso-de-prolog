:- encoding(utf8).

% Capítulo 71 - Las torres de Hanoi como reducción de problemas.
%
% Hay tres postes, a, b y c, y N discos de tamaños distintos apilados en
% uno de ellos, el mayor abajo. Se mueve un disco por vez, el de arriba de
% un poste, y nunca sobre uno menor. El nodo torre(N, De, A), «pasar los N
% discos de arriba del poste De al poste A», se reduce a tres problemas
% independientes, un nodo Y: pasar N - 1 discos al tercer poste, mover el
% disco mayor de De a A, y pasar los N - 1 discos del tercer poste a A. El
% disco mayor es el problema más difícil, y la reducción lo resuelve
% primero: todo lo demás consiste en despejarle el camino y volver a
% apilar. Mover un disco, mover(De, A), es primitivo y cuesta 1; pasar
% cero discos también es primitivo.
%
% solo-local: agrega cláusulas a los predicados de arboles.pl, que carga.
%
%?- expansion(hanoi, torre(3, a, c), Tipo, Hijos).

:- ensure_loaded(arboles).

:- multifile primitivo/2, expansion/4, estimacion/3.

% primitivo(P, N): pasar cero discos y mover un disco son primitivos.
primitivo(hanoi, torre(0, _, _)).
primitivo(hanoi, mover(_, _)).

%!  expansion(+Problema, +Nodo, -Tipo, -Hijos:list) is semidet.
%
%   torre(N, De, A), con N > 0, es un nodo Y con tres hijos: pasar N - 1
%   discos al tercer poste, mover el mayor y volver a apilar.
expansion(hanoi, torre(N, De, A), y,
          [torre(N1, De, Via)-0, mover(De, A)-1, torre(N1, Via, A)-0]) :-
    N > 0,
    N1 is N - 1,
    tercero(De, A, Via).

%!  estimacion(+Problema, +Nodo, -H:integer) is det.
%
%   H es 2^N - 1, la cantidad exacta de movimientos para N discos.
estimacion(hanoi, torre(N, _, _), H) :-
    H is 2**N - 1.

%!  tercero(+De, +A, -Via) is semidet.
%
%   Via es el poste que no es De ni A.
tercero(De, A, Via) :-
    member(Via, [a, b, c]),
    Via \== De,
    Via \== A,
    !.

%!  movimientos(+Arbol, -Movimientos:list) is det.
%
%   Movimientos son los movimientos de disco de Arbol, en orden, como
%   De-A.
movimientos(Arbol, Movimientos) :-
    hojas(Arbol, Hojas),
    convlist(movimiento, Hojas, Movimientos).

% movimiento(Hoja, M): la hoja mover(De, A) es el movimiento De-A.
movimiento(mover(De, A), De-A).
