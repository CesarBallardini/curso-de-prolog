:- encoding(utf8).

% Capítulo 24 - La bandera double_quotes es propia de cada módulo.
%
% Este módulo lee las comillas dobles como listas de códigos. El cambio vale
% para las cláusulas de este archivo; los demás módulos, y el toplevel, siguen
% leyendo una cadena.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- vocal(0'e).

:- module(codigos, [vocal/1, texto/1]).

:- set_prolog_flag(double_quotes, codes).

%!  vocal(+Codigo:integer) is semidet.
%
%   Codigo es el código de una vocal minúscula sin acento.
vocal(Codigo) :-
    memberchk(Codigo, "aeiou").

% texto(T): T es lo que este módulo lee de "ab".
texto("ab").
