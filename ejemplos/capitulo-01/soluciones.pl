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

% --- Ejercicio 5 ----------------------------------------------------------

%!  nieto(?N, ?A) is nondet.
%
%   N es nieto de A.
nieto(N, A) :-
    padre(A, P),
    padre(P, N).

% --- Ejercicio 6: propietarios de perro, y de cualquier mascota -----------
tiene(ana, mascota(gato, felix)).
tiene(luis, mascota(perro, rocco)).
tiene(eva, mascota(gato, gaturro)).
tiene(pedro, mascota(tortuga, manuelita)).

%!  propietario_de_perro(?P) is nondet.
%
%   P tiene por lo menos un perro.
propietario_de_perro(P) :-
    tiene(P, mascota(perro, _)).

%!  tiene_mascota(?P) is nondet.
%
%   P tiene alguna mascota.
tiene_mascota(P) :-
    tiene(P, _).

% --- Ejercicio 7: menor_que, definido a partir de mayor_que ---------------
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

%!  mayor_que(?A, ?B) is nondet.
%
%   A tiene más años que B.
mayor_que(A, B) :-
    edad(A, EdadA),
    edad(B, EdadB),
    EdadA > EdadB.

%!  menor_que(?A, ?B) is nondet.
%
%   A tiene menos años que B.
%   Se puede definir de manera independiente, o a partir de mayor_que/2 con
%   los argumentos en orden inverso.
menor_que(A, B) :-
    mayor_que(B, A).

% --- Ejercicio 8 ----------------------------------------------------------

%!  triple(+N, -T) is det.
%
%   T es el triple de N.
triple(N, T) :-
    T is N * 3.

% --- Ejercicio 9 ----------------------------------------------------------

%!  cuenta_al_reves(+Desde, +Hasta) is det.
%
%   Escribe los números de Desde a Hasta en orden descendente, uno por línea.
cuenta_al_reves(Desde, Hasta) :-
    Desde >= Hasta,
    format("~w~n", [Desde]),
    Siguiente is Desde - 1,
    cuenta_al_reves(Siguiente, Hasta).
cuenta_al_reves(Desde, Hasta) :-
    Desde < Hasta.

% --- Ejercicio 12: cuántos invitados habría -------------------------------
invitados([ana, luis, eva, sofia]).

%!  cuantos_invitados_mas(?P, -N) is det.
%
%   N es la cantidad de invitados que habría si se agregara P, sin modificar
%   la lista original.
cuantos_invitados_mas(P, N) :-
    invitados(Invitados),
    append(Invitados, [P], Con),
    length(Con, N).

% --- Ejercicio 14 ---------------------------------------------------------

%!  mayor_de(?P, +N) is nondet.
%
%   P tiene más de N años.
mayor_de(P, N) :-
    edad(P, A),
    A > N.

%!  en_edad_escolar(?P) is nondet.
%
%   P tiene más de 5 años y menos de 18.
en_edad_escolar(P) :-
    mayor_de(P, 5),
    edad(P, A),
    A < 18.
