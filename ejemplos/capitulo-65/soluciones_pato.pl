:- encoding(utf8).

% Capítulo 65 - Solución del ejercicio 5: la regla contrapuesta.
%
% Dos aves con plumas que nadan: un pato, del que se observó que vuela, y
% Pingu, del que no se observó nada. «Los pingüinos no vuelan» tiene su
% contrapuesta, «lo que vuela no es un pingüino», como otra regla
% estricta. Con el pato, la observación decide; con Pingu, cada regla
% espera a la otra, y la consulta no termina.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- respuesta([especificidad], pinguino(pato), R).

:- use_module(rebatible).

% tiene_plumas(X): X tiene plumas.
tiene_plumas(pato).
tiene_plumas(pingu).

% nada(X): X nada.
nada(pato).
nada(pingu).

% vuela(X): se observó que X vuela.
vuela(pato).

%!  ave(?X) is nondet.
%
%   X es un ave: tiene plumas.
ave(X) :-
    tiene_plumas(X).

% Un pingüino no vuela, y lo que vuela no es un pingüino.
neg vuela(X) :-
    pinguino(X).
neg pinguino(X) :-
    vuela(X).

vuela(X) :~ ave(X).
pinguino(X) :~ ave(X), nada(X).
