:- encoding(utf8).

% Capítulo 71 - Las torres de Hanoi como espacio de estados, con la
% búsqueda del capítulo 40.
%
% visitados.pl del capítulo 40 no es un módulo: se carga dentro del módulo
% capitulo40, sin copiarlo, y este archivo agrega a sus predicados
% inicial/2, meta/2 y sucesor/5 las cláusulas del problema torres(N). Para
% eso los declara multifile antes de cargarlo. Un estado es la lista de los
% postes de los N discos, del menor al mayor: [a, a, c] tiene los dos
% discos menores en a y el mayor en c. Un disco se puede mover si ningún
% disco menor está en su poste ni en el poste de destino.
%
% solo-local: carga un archivo de otro capítulo, y SWISH no permite cargar
% otro archivo.
%
%?- torres_en_anchura(3, Plan, K).

:- module(capitulo40,
          [ torres_en_anchura/3
          ]).

:- multifile inicial/2, meta/2, sucesor/5.

:- load_files(capitulo40:'../capitulo-40/visitados', []).

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es el de partida de torres(N): todos los discos en a.
inicial(torres(N), Estado) :-
    length(Estado, N),
    maplist(=(a), Estado).

%!  meta(+Problema, +Estado) is semidet.
%
%   En Estado todos los discos están en c.
meta(torres(_), Estado) :-
    maplist(==(c), Estado).

%!  sucesor(+Problema, +Estado0, -Movimiento, -Estado, -Costo) is nondet.
%
%   Movimiento, De-A, pasa el disco de arriba del poste De al poste A, y
%   lleva de Estado0 a Estado con costo 1.
sucesor(torres(_), Estado0, De-A, Estado, 1) :-
    nth1(I, Estado0, De),
    \+ ( nth1(J, Estado0, De), J < I ),
    member(A, [a, b, c]),
    A \== De,
    \+ ( nth1(J, Estado0, A), J < I ),
    nth1(I, Estado0, _, Resto),
    nth1(I, Estado, A, Resto).

%!  torres_en_anchura(+N:integer, -Plan:list, -Expandidos:integer)
%!      is det.
%
%   Plan es el plan más corto para pasar N discos del poste a al c,
%   hallado con la búsqueda en anchura con visitados del capítulo 40, que
%   expandió Expandidos estados.
torres_en_anchura(N, Plan, Expandidos) :-
    buscar(anchura, torres(N), Plan, _, Expandidos).
