:- encoding(utf8).

% Capítulo 13 - Un programa para revisar antes de entregar.
%
% Se carga sin errores y responde bien a las consultas sobre abuelo/2, pero
% nieto/2 llama a persona/1, que no está definido en ninguna parte. La carga no
% lo advierte; check/0 sí.
%
%?- abuelo(juan, Quien).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  nieto(?N, ?A) is nondet.
%
%   N es nieto de A, y es una persona registrada.
nieto(N, A) :-
    abuelo(A, N),
    persona(N).
