:- encoding(utf8).

% Capítulo 34 - Listas abiertas.
%
% Una lista abierta termina en una variable libre en lugar de []: sus primeros
% elementos se conocen y el resto no. agregar_al_final/2 recorre la lista
% hasta la variable del final y la liga a un elemento nuevo seguido de otra
% variable: la lista crece sin copiarse. cerrar/1 liga esa variable a [] y la
% convierte en una lista común. conocidos/2 da los elementos ya presentes sin
% ligar el final.
%
%?- L = [a, b|_], agregar_al_final(L, c), agregar_al_final(L, d).
%?- L = [a, b|_], agregar_al_final(L, c), cerrar(L).
%?- conocidos([a, b|_], C).

%!  agregar_al_final(+Abierta:list, +X) is det.
%
%   Abierta es una lista abierta; su variable final queda ligada a [X|_], y
%   la lista sigue abierta. Recorre los elementos conocidos para llegar al
%   final.
agregar_al_final(Final, X) :-
    var(Final),
    !,
    Final = [X|_].
agregar_al_final([_|Resto], X) :-
    agregar_al_final(Resto, X).

%!  cerrar(+Abierta:list) is det.
%
%   Liga la variable final de la lista abierta Abierta a []: la lista queda
%   cerrada, con los elementos que tenía.
cerrar(Final) :-
    var(Final),
    !,
    Final = [].
cerrar([_|Resto]) :-
    cerrar(Resto).

%!  conocidos(+Abierta:list, -Elementos:list) is det.
%
%   Elementos es la lista cerrada de los elementos ya presentes en la lista
%   abierta Abierta, que no cambia.
conocidos(Final, []) :-
    var(Final),
    !.
conocidos([X|Resto], [X|Xs]) :-
    conocidos(Resto, Xs).
