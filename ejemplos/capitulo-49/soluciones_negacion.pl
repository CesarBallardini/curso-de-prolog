:- encoding(utf8).

% Capítulo 49 - Solución del ejercicio 12: un ave herida es anormal.
%
% Agrega a la teoría de negacion.pl, con cláusulas multifile, el
% abducible herido/1 y una regla más de anormal/1.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- suponer(vuela(piolin), S), cerrar(S).
%?- suponer((no(vuela(piolin)), ave(piolin)), S), cerrar(S).

:- use_module(negacion).

:- multifile negacion:abducible/1, negacion:regla/2.

negacion:abducible(herido(_)).
negacion:regla(anormal(X), herido(X)).
