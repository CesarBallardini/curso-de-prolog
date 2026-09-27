:- encoding(utf8).

% Capítulo 26 - El depurador: trace/0, spy/1 y los puertos de la caja de Byrd.
%
% El programa es el de la sección 5.3: abuelo/2 a partir de padre/2. La
% traza muestra cada llamada con su puerto: Call, Exit, Redo y Fail.
%
% solo-local: el depurador interactivo necesita una consola local.
%
%?- abuelo(juan, Quien).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N: el padre de uno de sus padres.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).
