:- encoding(utf8).

% Capítulo 10 - Soluciones de los ejercicios.
%
%?- sin_hermanos(Quien).
%?- solo_en_la_primera([ana, luis, eva], [luis], R).

persona(juan).
persona(ana).
persona(pedro).
persona(luis).
persona(eva).

padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

tiene(ana, gato).
tiene(luis, perro).

casado(juan, marta).

% --- Ejercicio 3 -----------------------------------------------------------

% no_es_hijo_de(H, P): H es una persona que no es hijo de P.
% persona(H) se escribe primero para que \+ opere sobre un valor instanciado.
no_es_hijo_de(H, P) :-
    persona(H),
    \+ padre(P, H).

% --- Ejercicio 4 -----------------------------------------------------------

% tiene_hermano(P): P tiene algún hermano.
tiene_hermano(P) :-
    padre(Padre, P),
    padre(Padre, Otro),
    Otro \== P.

% sin_hermanos(P): P no tiene hermanos.
sin_hermanos(P) :-
    persona(P),
    \+ tiene_hermano(P).

% --- Ejercicio 6 -----------------------------------------------------------

% nadie_tiene(Cosa): nadie tiene Cosa. Es correcto con Cosa instanciada.
nadie_tiene(Cosa) :-
    \+ tiene(_, Cosa).

% --- Ejercicio 7 -----------------------------------------------------------

% soltero(P): P no está casado. Con los objetivos en el orden correcto.
soltero(P) :-
    persona(P),
    \+ casado(P, _).

% --- Ejercicio 8 -----------------------------------------------------------

% solo_en_la_primera(L1, L2, R): los elementos de L1 que no están en L2.
% El corte descarta las demás soluciones de member/2: es suficiente que X
% aparezca una vez en L2.
solo_en_la_primera([], _, []).
solo_en_la_primera([X|Resto], L2, [X|RestoR]) :-
    \+ member(X, L2),
    solo_en_la_primera(Resto, L2, RestoR).
solo_en_la_primera([X|Resto], L2, R) :-
    member(X, L2),
    !,
    solo_en_la_primera(Resto, L2, R).

% --- Ejercicio 12 ----------------------------------------------------------

% sin_mascota(P): P es una persona que no tiene ninguna mascota.
% persona(P) se escribe primero, para que \+ opere sobre un valor concreto.
sin_mascota_correcto(P) :-
    persona(P),
    \+ tiene(P, _).

% --- Ejercicio 13 ----------------------------------------------------------

% ninguno_es(X, L): ningún elemento de L es X. Con \+ sobre la pertenencia.
ninguno_es(X, L) :-
    \+ esta_en_lista(X, L).

esta_en_lista(X, [X|_]).
esta_en_lista(X, [_|Resto]) :-
    esta_en_lista(X, Resto).

% ninguno_es_recorriendo(X, L): lo mismo, sin \+, con la plantilla 11.
ninguno_es_recorriendo(_, []).
ninguno_es_recorriendo(X, [Otro|Resto]) :-
    X \== Otro,
    ninguno_es_recorriendo(X, Resto).
