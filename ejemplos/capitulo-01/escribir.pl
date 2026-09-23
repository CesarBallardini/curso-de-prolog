:- encoding(utf8).

% Capítulo 1 - Salida de texto.
%
% Además de la respuesta de la consulta, un programa puede escribir texto
% durante la ejecución de un objetivo.
%
%?- saludar(ana).
%?- presentar(luis, 3).

%!  saludar(+A) is det.
%
%   Escribe un saludo para A y pasa a la línea siguiente.
saludar(A) :-
    write('Hola, '),
    write(A),
    nl.

%!  presentar(+A, +N) is det.
%
%   Escribe cuántos hermanos tiene A.
%   format/2 compone la salida en una sola llamada: ~w inserta el valor
%   siguiente de la lista y ~n produce un salto de línea.
presentar(A, N) :-
    format("~w tiene ~w hermanos~n", [A, N]).
