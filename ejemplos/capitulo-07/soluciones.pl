:- encoding(utf8).

% Capítulo 7 - Soluciones de los ejercicios.
%
%?- dar_vuelta([ana, luis, eva], R).
%?- sacar(luis, [ana, luis, eva], R).

% --- Ejercicio 3 -----------------------------------------------------------

% primero_y_ultimo(L, P, U): P es el primero de L y U el último.
primero_y_ultimo([P|Resto], P, U) :-
    last([P|Resto], U).

% --- Ejercicio 4 -----------------------------------------------------------

% sin_el_primero(L, R): R es L sin su primer elemento. No requiere recursión:
% la unificación de la cabeza descompone la lista.
sin_el_primero([_|Resto], Resto).

% --- Ejercicio 5 -----------------------------------------------------------

% cuantos_gatos(L, N): N es la cantidad de apariciones de gato en L.
cuantos_gatos([], 0).
cuantos_gatos([gato|Resto], N) :-
    cuantos_gatos(Resto, Faltan),
    N is Faltan + 1.
cuantos_gatos([Otro|Resto], N) :-
    Otro \== gato,
    cuantos_gatos(Resto, N).

% --- Ejercicio 6 -----------------------------------------------------------

% empieza_con(L, Principio): L empieza con los elementos de Principio.
empieza_con(L, Principio) :-
    append(Principio, _, L).

% --- Ejercicio 7 -----------------------------------------------------------

% dar_vuelta(L, R): R es L en orden inverso, sin usar reverse/2.
dar_vuelta([], []).
dar_vuelta([X|Resto], R) :-
    dar_vuelta(Resto, RestoAlReves),
    append(RestoAlReves, [X], R).

% --- Ejercicio 8 -----------------------------------------------------------

% sacar(X, L, R): R es L sin la primera aparición de X.
sacar(X, [X|Resto], Resto).
sacar(X, [Otro|Resto], [Otro|RestoR]) :-
    Otro \== X,
    sacar(X, Resto, RestoR).

% --- Ejercicio 9 -----------------------------------------------------------

% es_sublista(S, L): los elementos de S aparecen contiguos y en orden en L.
es_sublista(S, L) :-
    append(_, Atras, L),
    append(S, _, Atras).

% --- Ejercicio 12 ----------------------------------------------------------

% todos_gatos(L): todos los elementos de L son gato. Plantilla 11.
todos_gatos([]).
todos_gatos([gato|Resto]) :-
    todos_gatos(Resto).

% algun_gato(L): alguno de los elementos de L es gato. Plantilla 10.
algun_gato([gato|_]).
algun_gato([_|Resto]) :-
    algun_gato(Resto).

% --- Ejercicio 13 ----------------------------------------------------------

% duplicar(L, R): R tiene cada elemento de L repetido dos veces.
% El resultado se escribe en la cabeza, no se arma en el cuerpo.
duplicar([], []).
duplicar([X|Resto], [X, X|Otros]) :-
    duplicar(Resto, Otros).

% --- Ejercicio 15 ----------------------------------------------------------

% segundo(L, X): X es el segundo elemento de L.
segundo([_, X|_], X).
