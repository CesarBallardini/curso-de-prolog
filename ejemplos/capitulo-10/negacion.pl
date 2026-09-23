:- encoding(utf8).

% Capítulo 10 - Negación como falla.
%
% \+ se lee "no se puede probar". Es confiable cuando el objetivo negado tiene
% todas sus variables instanciadas; en caso contrario, produce resultados
% incorrectos.
%
%?- no_tiene_hijos(Quien).
%?- mal_no_tiene_hijos(Quien).

% persona(P): P es una de las personas de la base.
persona(juan).
persona(ana).
persona(pedro).
persona(luis).
persona(eva).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

%!  no_tiene_hijos(?P) is nondet.
%
%   P no es padre de nadie. Primero se genera una persona; después se evalúa
%   la negación sobre ella.
no_tiene_hijos(P) :-
    persona(P),
    \+ padre(P, _).

%!  mal_no_tiene_hijos(?P) is nondet.
%
%   La misma regla con los objetivos en orden inverso. Es incorrecta; la
%   sección 10.4 explica la causa.
mal_no_tiene_hijos(P) :-
    \+ padre(P, _),
    persona(P).

%!  distinto_de(?P, +Otro) is nondet.
%
%   P es una persona que no es Otro.
distinto_de(P, Otro) :-
    persona(P),
    P \= Otro.

%!  hijo_unico(?H) is nondet.
%
%   H tiene un padre, y ese padre no tiene otros hijos.
hijo_unico(H) :-
    padre(P, H),
    \+ otro_hijo(P, H).

%!  otro_hijo(?P, +H) is nondet.
%
%   P tiene algún hijo que no es H.
otro_hijo(P, H) :-
    padre(P, Otro),
    Otro \== H.
