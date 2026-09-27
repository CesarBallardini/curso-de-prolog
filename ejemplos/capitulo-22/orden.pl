:- encoding(utf8).

% Capítulo 22 - Ordenar: el orden estándar, sort/2, msort/2, sort/4 y
% predsort/3.
%
% Las edades de la familia, ordenadas de varias formas. sort/4 ordena por una
% clave y decide qué hacer con los repetidos; predsort/3 ordena con un
% predicado de comparación propio.
%
%?- por_edad(L).
%?- por_edad_descendente(L).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).
edad(marta, 68).

%!  edades(-Pares:list(pair)) is det.
%
%   Pares son los pares Persona-Edad de la base, en el orden de los hechos.
edades(Pares) :-
    findall(P-E, edad(P, E), Pares).

%!  por_edad(-Pares:list(pair)) is det.
%
%   Pares son los pares Persona-Edad ordenados por edad, de menor a mayor;
%   con la misma edad, en el orden de los hechos.
por_edad(Pares) :-
    edades(Todos),
    sort(2, @=<, Todos, Pares).

%!  por_edad_descendente(-Pares:list(pair)) is det.
%
%   Pares son los pares Persona-Edad de mayor a menor edad.
por_edad_descendente(Pares) :-
    edades(Todos),
    sort(2, @>=, Todos, Pares).

%!  edades_distintas(-Edades:list(integer)) is det.
%
%   Edades son las edades de la base, ordenadas y sin repetidos.
edades_distintas(Edades) :-
    findall(E, edad(_, E), Todas),
    sort(Todas, Edades).

%!  por_edad_y_nombre(-Personas:list) is det.
%
%   Personas son las personas de la base ordenadas de mayor a menor edad y,
%   con la misma edad, por nombre.
por_edad_y_nombre(Personas) :-
    findall(P, edad(P, _), Todas),
    predsort(comparar_personas, Todas, Personas).

%!  comparar_personas(-Orden, +A, +B) is det.
%
%   Orden es <, > o = según A vaya antes, después o en el mismo lugar que B:
%   primero la mayor edad, y con la misma edad, el nombre en orden
%   alfabético.
comparar_personas(Orden, A, B) :-
    edad(A, EA),
    edad(B, EB),
    compare(Orden, EB-A, EA-B).
