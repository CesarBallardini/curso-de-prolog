:- encoding(utf8).

% Capítulo 65 - El problema: excepciones con negación como falla.
%
% «Las aves vuelan, salvo las anormales» se escribe con \+: vuela/1 pide
% que no se pueda probar anormal/1, y cada excepción es una cláusula de
% anormal/1. «Los murciélagos vuelan, salvo que se pruebe que no vuelan»,
% junto con «los muertos no vuelan, salvo que se pruebe que vuelan», son
% dos reglas con excepciones que se niegan una a la otra: con Drácula, que
% es las dos cosas, la consulta no termina.
%
%?- vuela(tweety).
%?- vuela(opus).
%?- vuela(nadie).

% pinguino(X): X es un pingüino.
pinguino(opus).

% murcielago(X): X es un murciélago.
murcielago(dracula).

% muerto(X): X está muerto.
muerto(dracula).

%!  ave(?X) is nondet.
%
%   X es un ave: Tweety, o cualquier pingüino.
ave(tweety).
ave(X) :-
    pinguino(X).

%!  vuela(+X) is semidet.
%
%   X vuela: es un ave que no se puede probar anormal, o un murciélago del
%   que no se puede probar que no vuela. Con Drácula no termina.
vuela(X) :-
    ave(X),
    \+ anormal(X).
vuela(X) :-
    murcielago(X),
    \+ no_vuela(X).

%!  anormal(+X) is semidet.
%
%   X es un ave anormal para volar: un pingüino.
anormal(X) :-
    pinguino(X).

%!  no_vuela(+X) is semidet.
%
%   X no vuela: está muerto y no se puede probar que vuela.
no_vuela(X) :-
    muerto(X),
    \+ vuela(X).
