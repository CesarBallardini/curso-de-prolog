:- encoding(utf8).

% Capítulo 21 - Recursión a izquierda y el argumento acumulador.
%
% La gramática de las restas, escrita como se lee en un libro de lenguajes
% formales, empieza por sí misma: expresion --> expresion, "-", numero. En
% Prolog esa regla no termina. resta//1 la reescribe sin recursión a izquierda,
% y lleva el valor acumulado de izquierda a derecha, para que 10-3-2 valga 5.
%
%?- phrase(resta(V), `10-3-2`).
%?- phrase(resta_derecha(V), `10-3-2`).

:- use_module(library(dcg/basics)).

%!  resta_izquierda(-V:integer)// is nondet.
%
%   La gramática con recursión a izquierda: se llama a sí misma antes de
%   consumir nada, y la consulta no termina.
resta_izquierda(V) -->
    resta_izquierda(V0),
    "-",
    integer(N),
    { V is V0 - N }.
resta_izquierda(V) -->
    integer(V).

%!  resta_derecha(-V:integer)// is semidet.
%
%   Sin recursión a izquierda, con la recursión después del primer número:
%   termina, pero agrupa a la derecha, y 10-3-2 vale 10-(3-2) = 9.
resta_derecha(V) -->
    integer(N),
    (   "-"
    ->  resta_derecha(Resto),
        { V is N - Resto }
    ;   { V = N }
    ).

%!  resta(-V:integer)// is semidet.
%
%   Sin recursión a izquierda y con acumulador: el primer número es el valor
%   inicial, y cada "-N" se resta del acumulado. 10-3-2 vale (10-3)-2 = 5.
resta(V) -->
    integer(N),
    restas(N, V).

%!  restas(+Hasta:integer, -V:integer)// is det.
%
%   V es Hasta menos cada uno de los números que siguen, en orden.
restas(Hasta, V) -->
    "-",
    !,
    integer(N),
    { Ahora is Hasta - N },
    restas(Ahora, V).
restas(V, V) -->
    [].
