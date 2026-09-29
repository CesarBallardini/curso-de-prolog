:- encoding(utf8).

% Capítulo 72 - La búsqueda del capítulo 40, para cualquier problema.
%
% puzzle8.pl del capítulo 40 no es un módulo, y su bucle llama a
% inicial/2, meta/2, sucesor/5 y heuristica/3 del mismo archivo. Este
% módulo lo incluye con include/1, sin copiarlo, y agrega a esos cuatro
% predicados una cláusula para el término problema(Modulo, Datos), que
% delega en los predicados del mismo nombre del módulo Modulo. Así, un
% módulo que define el espacio de estados de otro problema usa buscar/5 y
% ida_estrella/4 tal como el capítulo 40 los escribió.
%
% solo-local: incluye un archivo de otro capítulo, y SWISH no permite
% cargar otro archivo.
%
%?- buscar(mejor(a_estrella), puzzle([2,4,3,7,1,5,0,8,6], manhattan), P, C, K).

:- module(busqueda,
          [ buscar/5,
            ida_estrella/4
          ]).

:- discontiguous inicial/2, meta/2, sucesor/5, heuristica/3.

:- include('../capitulo-40/puzzle8').

%!  inicial(+Problema, -Estado) is det.
%
%   Estado es el estado de partida de problema(Modulo, Datos), según
%   Modulo.
inicial(problema(M, Datos), Estado) :-
    M:inicial(Datos, Estado).

%!  meta(+Problema, +Estado) is semidet.
%
%   Estado es un estado meta de problema(Modulo, Datos), según Modulo.
meta(problema(M, Datos), Estado) :-
    M:meta(Datos, Estado).

%!  sucesor(+Problema, +Estado, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion lleva de Estado a Siguiente con Costo, según Modulo.
sucesor(problema(M, Datos), Estado, Accion, Siguiente, Costo) :-
    M:sucesor(Datos, Estado, Accion, Siguiente, Costo).

%!  heuristica(+Problema, +Estado, -H:number) is det.
%
%   H es lo que estima Modulo que falta desde Estado.
heuristica(problema(M, Datos), Estado, H) :-
    M:heuristica(Datos, Estado, H).
