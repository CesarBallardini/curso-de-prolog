:- encoding(utf8).

% Capítulo 7 - Soluciones de los ejercicios.
%
%?- dar_vuelta([ana, luis, eva], R).
%?- sacar(luis, [ana, luis, eva], R).

% --- Ejercicio 3 -----------------------------------------------------------

%!  primero_y_ultimo(?L, ?P, ?U) is nondet.
%
%   P es el primero de L y U el último. Con L libre, enumera listas cada vez
%   más largas que empiezan con P y terminan con U, sin fin.
primero_y_ultimo([P|Resto], P, U) :-
    last([P|Resto], U).

% --- Ejercicio 4 -----------------------------------------------------------

% sin_el_primero(L, R): R es L sin su primer elemento. No requiere recursión:
% la unificación de la cabeza descompone la lista.
sin_el_primero([_|Resto], Resto).

% --- Ejercicio 5 -----------------------------------------------------------

%!  cuantos_gatos(+L, -N) is det.
%
%   N es la cantidad de apariciones de gato en L.
cuantos_gatos([], 0).
cuantos_gatos([gato|Resto], N) :-
    cuantos_gatos(Resto, Faltan),
    N is Faltan + 1.
cuantos_gatos([Otro|Resto], N) :-
    Otro \== gato,
    cuantos_gatos(Resto, N).

% --- Ejercicio 6 -----------------------------------------------------------

%!  empieza_con(+L, ?Principio) is nondet.
%
%   L empieza con los elementos de Principio.
empieza_con(L, Principio) :-
    append(Principio, _, L).

% --- Ejercicio 7 -----------------------------------------------------------

%!  dar_vuelta(+L, -R) is det.
%!  dar_vuelta(-L, +R) is semidet.
%
%   R es L en orden inverso, sin usar reverse/2. Con L libre, después de la
%   respuesta no termina.
dar_vuelta([], []).
dar_vuelta([X|Resto], R) :-
    dar_vuelta(Resto, RestoAlReves),
    append(RestoAlReves, [X], R).

% --- Ejercicio 8 -----------------------------------------------------------

%!  sacar(+X, +L, -R) is semidet.
%
%   R es L sin la primera aparición de X.
sacar(X, [X|Resto], Resto).
sacar(X, [Otro|Resto], [Otro|RestoR]) :-
    Otro \== X,
    sacar(X, Resto, RestoR).

% --- Ejercicio 9 -----------------------------------------------------------

%!  es_sublista(?S, +L) is nondet.
%
%   Los elementos de S aparecen contiguos y en orden en L.
es_sublista(S, L) :-
    append(_, Atras, L),
    append(S, _, Atras).

% --- Ejercicio 12 ----------------------------------------------------------

%!  todos_gatos(?L) is nondet.
%
%   Todos los elementos de L son gato. Plantilla 11. Con L libre, enumera
%   listas de gatos de largo creciente, sin fin.
todos_gatos([]).
todos_gatos([gato|Resto]) :-
    todos_gatos(Resto).

%!  algun_gato(?L) is nondet.
%
%   Alguno de los elementos de L es gato. Plantilla 10. Con L libre, enumera
%   listas con gato en cada posición, sin fin.
algun_gato([gato|_]).
algun_gato([_|Resto]) :-
    algun_gato(Resto).

% --- Ejercicio 13 ----------------------------------------------------------

%!  duplicar(+L, -R) is det.
%!  duplicar(-L, +R) is semidet.
%
%   R tiene cada elemento de L repetido dos veces.
%   El resultado se escribe en la cabeza, no se arma en el cuerpo.
duplicar([], []).
duplicar([X|Resto], [X, X|Otros]) :-
    duplicar(Resto, Otros).

% --- Ejercicio 15 ----------------------------------------------------------

% segundo(L, X): X es el segundo elemento de L.
segundo([_, X|_], X).

% --- Ejercicio 17 ----------------------------------------------------------

% materias(L): L es la lista de materias, en orden.
materias([logica, algebra, fisica, quimica]).

%!  materia_en(?N, ?M) is nondet.
%
%   M es la materia que ocupa la posición N de la lista, contando desde 1.
materia_en(N, M) :-
    materias(Lista),
    nth1(N, Lista, M).
