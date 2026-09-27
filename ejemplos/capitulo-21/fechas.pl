:- encoding(utf8).

% Capítulo 21 - Fechas con library(dcg/basics) y listas con
% library(dcg/high_order).
%
% fecha//1 relaciona el texto 24/9/2026 con el término fecha(2026, 9, 24), en
% los dos sentidos. fechas//1 reconoce una lista de fechas separadas por una
% coma y un espacio, con sequence//3.
%
%?- string_codes("24/09/2026", Cs), phrase(fecha(F), Cs).
%?- phrase(fecha(fecha(2026, 9, 24)), Cs), atom_codes(A, Cs).

:- use_module(library(dcg/basics)).
:- use_module(library(dcg/high_order)).

%!  fecha(?F)// is semidet.
%
%   El texto Dia/Mes/Anio de la fecha F = fecha(Anio, Mes, Dia). Al analizar,
%   admite ceros a la izquierda; al generar, no los escribe.
fecha(fecha(Anio, Mes, Dia)) -->
    integer(Dia),
    "/",
    integer(Mes),
    "/",
    integer(Anio),
    { fecha_valida(Anio, Mes, Dia) }.

%!  fecha_valida(+Anio:integer, +Mes:integer, +Dia:integer) is semidet.
%
%   El mes está entre 1 y 12 y el día entre 1 y la cantidad de días del mes.
fecha_valida(Anio, Mes, Dia) :-
    between(1, 12, Mes),
    dias_del_mes(Anio, Mes, Dias),
    between(1, Dias, Dia).

%!  dias_del_mes(+Anio:integer, +Mes:integer, -Dias:integer) is det.
%
%   Dias es la cantidad de días del mes Mes del año Anio.
dias_del_mes(Anio, 2, Dias) :-
    !,
    (   bisiesto(Anio)
    ->  Dias = 29
    ;   Dias = 28
    ).
dias_del_mes(_, Mes, Dias) :-
    (   memberchk(Mes, [4, 6, 9, 11])
    ->  Dias = 30
    ;   Dias = 31
    ).

%!  bisiesto(+Anio:integer) is semidet.
%
%   Anio es bisiesto: divisible por 4, y no por 100 salvo que lo sea por 400.
bisiesto(Anio) :-
    Anio mod 4 =:= 0,
    (   Anio mod 100 =\= 0
    ->  true
    ;   Anio mod 400 =:= 0
    ).

%!  fechas(?Fs:list)// is semidet.
%
%   Una lista de fechas separadas por una coma y un espacio.
fechas(Fs) -->
    sequence(fecha, ", ", Fs).
