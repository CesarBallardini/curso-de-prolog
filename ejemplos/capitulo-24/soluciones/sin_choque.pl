:- encoding(utf8).

% Capítulo 24 - Solución del ejercicio 4: importar dos predicados con el
% mismo nombre.
%
% Importar los dos módulos enteros produce un error de permiso al cargar: el
% segundo saludo/1 no se puede importar donde ya está el primero. use_module/2
% importa el segundo con otro nombre.
%
% solo-local: SWISH no admite módulos propios en un programa.
%
%?- saludos(L).

:- module(sin_choque, [saludos/1]).

:- use_module(saludo_a).
:- use_module(saludo_b, [saludo/1 as despedida]).

%!  saludos(-L:list) is det.
%
%   L tiene el saludo de cada módulo.
saludos([S, D]) :-
    saludo(S),
    despedida(D).
