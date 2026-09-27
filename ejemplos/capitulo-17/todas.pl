:- encoding(utf8).

% Capítulo 17 - Reunir todas las respuestas: findall/3, bagof/3 y setof/3.
%
% Los tres reúnen las respuestas de un objetivo en una lista. findall/3 da la
% lista vacía cuando no hay respuestas; bagof/3 falla, y agrupa por las
% variables libres; setof/3 además ordena y elimina los repetidos.
%
%?- hijos_de(juan, Hijos).
%?- padres(Padres).

% persona(P): P es una de las personas de la base.
persona(juan).
persona(ana).
persona(pedro).
persona(luis).
persona(eva).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

%!  hijos_de(+P, -Hijos:list) is det.
%
%   Hijos es la lista de los hijos de P, en el orden de los hechos; la lista
%   vacía si P no tiene hijos.
hijos_de(P, Hijos) :-
    findall(H, padre(P, H), Hijos).

%!  cuantos_hijos(+P, -N:integer) is det.
%
%   N es la cantidad de hijos de P.
cuantos_hijos(P, N) :-
    hijos_de(P, Hijos),
    length(Hijos, N).

%!  hijos_agrupados(?P, -Hijos:list) is nondet.
%
%   Hijos es la lista de los hijos de P, para cada P que tiene hijos: una
%   respuesta por padre.
hijos_agrupados(P, Hijos) :-
    bagof(H, padre(P, H), Hijos).

%!  padres(-Padres:list) is semidet.
%
%   Padres es la lista ordenada y sin repetidos de las personas que tienen
%   algún hijo. H^ indica que el hijo no agrupa: hay una sola lista.
padres(Padres) :-
    setof(P, H^padre(P, H), Padres).

%!  no_tiene_hijos(?P) is nondet.
%
%   P es una persona sin hijos: la lista de sus hijos está vacía. Sin \+ y
%   sin repetir los datos en una lista.
no_tiene_hijos(P) :-
    persona(P),
    findall(H, padre(P, H), []).
