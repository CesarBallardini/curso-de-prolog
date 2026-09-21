:- encoding(utf8).

% Capítulo 1 - Escribir resultados.
%
% Hasta acá Prolog contestaba con las respuestas de la consulta. Un programa
% también puede escribir él mismo lo que quiera, mientras prueba un objetivo.
%
%?- saludar(ana).
%?- presentar(luis, 3).

% saludar(A): escribe un saludo para A y pasa a la línea siguiente.
saludar(A) :-
    write('Hola, '),
    write(A),
    nl.

% presentar(A, N): escribe cuántos hermanos tiene A.
% format/2 arma el texto de una vez: ~w pone el valor que sigue y ~n corta la línea.
presentar(A, N) :-
    format("~w tiene ~w hermanos~n", [A, N]).
