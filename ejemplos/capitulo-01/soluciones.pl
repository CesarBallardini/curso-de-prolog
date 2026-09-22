:- encoding(utf8).

% Capítulo 1 - Soluciones de los ejercicios.
%
% Las soluciones de los ejercicios que piden escribir un predicado. Cada una se
% verifica en capitulo-01/soluciones.plt.
%
%?- nieto(clara, Quien).
%?- tiene_mascota(Quien).

% --- Ejercicio 1: luis es padre de clara ----------------------------------
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).
padre(luis, clara).

% --- Ejercicio 5: nieto(N, A): N es nieto de A ----------------------------
nieto(N, A) :-
    padre(A, P),
    padre(P, N).

% --- Ejercicio 6: propietarios de perro, y de cualquier mascota -----------
tiene(ana, mascota(gato, felix)).
tiene(luis, mascota(perro, rocco)).
tiene(eva, mascota(gato, gaturro)).
tiene(pedro, mascota(tortuga, manuelita)).

propietario_de_perro(P) :-
    tiene(P, mascota(perro, _)).

tiene_mascota(P) :-
    tiene(P, _).

% --- Ejercicio 7: menor_que, definido a partir de mayor_que ---------------
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

mayor_que(A, B) :-
    edad(A, EdadA),
    edad(B, EdadB),
    EdadA > EdadB.

% Se puede definir de manera independiente, o a partir de mayor_que/2 con los
% argumentos en orden inverso.
menor_que(A, B) :-
    mayor_que(B, A).

% --- Ejercicio 8: triple ---------------------------------------------------
triple(N, T) :-
    T is N * 3.

% --- Ejercicio 9: cuenta descendente --------------------------------------
cuenta_al_reves(Desde, Hasta) :-
    Desde >= Hasta,
    format("~w~n", [Desde]),
    Siguiente is Desde - 1,
    cuenta_al_reves(Siguiente, Hasta).
cuenta_al_reves(Desde, Hasta) :-
    Desde < Hasta.

% --- Ejercicio 12: cuántos invitados habría -------------------------------
invitados([ana, luis, eva, sofia]).

cuantos_invitados_mas(P, N) :-
    invitados(Invitados),
    append(Invitados, [P], Con),
    length(Con, N).

% --- Ejercicio 14: mayor de N años, y en edad escolar ---------------------
% mayor_de(P, N): P tiene más de N años.
mayor_de(P, N) :-
    edad(P, A),
    A > N.

% en_edad_escolar(P): P tiene más de 5 años y menos de 18.
en_edad_escolar(P) :-
    mayor_de(P, 5),
    edad(P, A),
    A < 18.
