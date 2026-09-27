:- encoding(utf8).

% Capítulo 31 - Solución del ejercicio 9: el predicado que se agrega al pack
% fechas_castellano, en su versión 1.1.0.
%
% En el pack, bisiesto/1 se agrega a la lista de exportación del módulo
% fechas_castellano, y pack.pl pasa a decir version('1.1.0').
%
%?- bisiesto(2024).

:- use_module(library(error)).

%!  bisiesto(+Anio:integer) is semidet.
%
%   Anio es bisiesto: es múltiplo de 4, salvo los múltiplos de 100 que no
%   lo son de 400.
%
%   @error type_error(integer, Anio) si Anio no es un entero.
bisiesto(Anio) :-
    must_be(integer, Anio),
    (   Anio mod 400 =:= 0
    ->  true
    ;   Anio mod 100 =\= 0,
        Anio mod 4 =:= 0
    ).
