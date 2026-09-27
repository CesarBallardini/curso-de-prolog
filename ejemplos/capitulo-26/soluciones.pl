:- encoding(utf8).

% Capítulo 26 - Soluciones de los ejercicios 9, 10, 12 y 14. Las de los
% ejercicios sobre el proyecto están en soluciones_proyecto.pl, y la del 11
% en soluciones_buscaminas.pl.
%
% largo_mal/2 y hermanos_mal/2 tienen errores plantados; largo/2 y
% hermanos/2 son las versiones corregidas. resumen_con_error/1 llama a un
% predicado mal escrito, para el ejercicio 12: la consulta check. lo informa.
%
%?- largo_mal([a, b], N).
%?- hermanos(ana, H).

:- op(920, fy, *).

% --- Ejercicio 9 ------------------------------------------------------------

%!  largo_mal(+L:list, -N:integer) is det.
%
%   Debería ser la cantidad de elementos de L; tiene un error plantado en el
%   caso base.
largo_mal([], 1).
largo_mal([_|Resto], N) :-
    largo_mal(Resto, N0),
    N is N0 + 1.

%!  largo(+L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L: largo_mal/2 corregido.
largo([], 0).
largo([_|Resto], N) :-
    largo(Resto, N0),
    N is N0 + 1.

% --- Ejercicio 10 -----------------------------------------------------------

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

%!  hermanos_mal(?A, ?B) is nondet.
%
%   Debería ser: A y B son hermanos, hijos del mismo padre y distintos. El
%   error: el último objetivo compara con == en lugar de \==.
hermanos_mal(A, B) :-
    padre(P, A),
    padre(P, B),
    A == B.

%!  hermanos_recortado(?A, ?B) is nondet.
%
%   hermanos_mal/2 con el último objetivo tachado: responde, y por eso el
%   error está en el objetivo tachado.
hermanos_recortado(A, B) :-
    padre(P, A),
    padre(P, B),
    * A == B.

%!  *(+Objetivo) is det.
%
%   Tacha Objetivo: *G se cumple siempre, sin ejecutar G.
*(_).

%!  hermanos(?A, ?B) is nondet.
%
%   A y B son hermanos: hermanos_mal/2 corregido.
hermanos(A, B) :-
    padre(P, A),
    padre(P, B),
    A \== B.

% --- Ejercicio 12 -----------------------------------------------------------

%!  resumen_con_error(-Texto:string) is det.
%
%   Llama a promedo/2, que no existe: el nombre está mal escrito. Cargar el
%   archivo no lo detecta; check/0 sí.
resumen_con_error(Texto) :-
    promedo([6, 9], P),
    format(string(Texto), "Promedio: ~w", [P]).

% --- Ejercicio 14 -----------------------------------------------------------

%!  natural(?N) is nondet.
%
%   N es un número natural. Con N libre, genera 0, 1, 2, … sin terminar.
natural(0).
natural(N) :-
    natural(N0),
    N is N0 + 1.
