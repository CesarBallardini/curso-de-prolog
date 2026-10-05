:- encoding(utf8).

% Capítulo 66 - Ampliación: del árbol al reticulado.
%
% Rowe llama reticulados de decisión a estas estructuras, porque dos ramas
% que se separan pueden volver a juntarse: un subárbol que aparece varias
% veces se guarda una vez, y cada nodo que lo usa apunta a él.
% reticulado/3 convierte un árbol de la versión 4 en una lista de nodos
% numerados, n(K)-hoja(H) o n(K)-pregunta(P, Si, No), donde Si y No son
% números de nodo; dos subárboles iguales reciben el mismo número.
% consultar_reticulado/4 lo recorre como consultar/4 recorre el árbol.
%
% solo-local: carga el sistema experto del capítulo 33, y SWISH no admite
% módulos propios.
%
%?- tamanos(Filas).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(assoc)).
:- use_module(arbol).

%!  reticulado(+Arbol, -Raiz, -Nodos:list) is det.
%
%   Nodos son los nodos distintos de Arbol, numerados desde 1 en el orden
%   en que se completan, de las hojas a la raíz; Raiz es el número del
%   nodo de la raíz.
reticulado(Arbol, Raiz, Nodos) :-
    empty_assoc(T0),
    compartir(Arbol, T0-[], _-Inversos, Raiz),
    reverse(Inversos, Nodos).

%!  compartir(+Arbol, +Estado0, -Estado, -Id) is det.
%
%   Estado0 y Estado son pares Tabla-Nodos: la Tabla lleva cada nodo, con
%   los hijos ya reemplazados por sus números, a su número, y Nodos son
%   los pares número-nodo creados, el último primero. Id es el número del
%   nodo de Arbol, nuevo si no estaba en la Tabla.
compartir(hoja(H), Estado0, Estado, Id) :-
    numerar(hoja(H), Estado0, Estado, Id).
compartir(pregunta(P, Si, No), Estado0, Estado, Id) :-
    compartir(Si, Estado0, Estado1, IdSi),
    compartir(No, Estado1, Estado2, IdNo),
    numerar(pregunta(P, IdSi, IdNo), Estado2, Estado, Id).

%!  numerar(+Nodo, +Estado0, -Estado, -Id) is det.
%
%   Id es el número de Nodo en la tabla de Estado0, o uno nuevo, el
%   siguiente al último, que Estado agrega.
numerar(Nodo, T0-Ns0, Estado, Id) :-
    (   get_assoc(Nodo, T0, Id)
    ->  Estado = T0-Ns0
    ;   length(Ns0, K),
        Id is K + 1,
        put_assoc(Nodo, T0, Id, T1),
        Estado = T1-[n(Id)-Nodo|Ns0]
    ).

%!  consultar_reticulado(+Nodos:list, +Raiz, +Fuente, -Hipotesis) is det.
%
%   Hipotesis es la de la hoja a la que se llega desde el nodo Raiz,
%   siguiendo en cada pregunta la rama de la respuesta de la Fuente.
consultar_reticulado(Nodos, Id, Fuente, Hipotesis) :-
    memberchk(n(Id)-Nodo, Nodos),
    (   Nodo = hoja(Hipotesis)
    ->  true
    ;   Nodo = pregunta(P, Si, No),
        (   responde_si(Fuente, P)
        ->  Siguiente = Si
        ;   Siguiente = No
        ),
        consultar_reticulado(Nodos, Siguiente, Fuente, Hipotesis)
    ).

%!  nodos_arbol(+Arbol, -N:integer) is det.
%
%   N es la cantidad de nodos de Arbol, preguntas y hojas.
nodos_arbol(Arbol, N) :-
    medidas(Arbol, m(Preguntas, Hojas, _)),
    N is Preguntas + Hojas.

%!  tamanos(-Filas:list) is det.
%
%   Filas tiene, por cada estrategia, el término
%   Estrategia-NodosArbol-NodosReticulado.
tamanos(Filas) :-
    findall(E-NA-NR,
            ( estrategia(E),
              arbol(E, A),
              nodos_arbol(A, NA),
              reticulado(A, _, Nodos),
              length(Nodos, NR) ),
            Filas).
