:- encoding(utf8).

% Capítulo 67 - Soluciones de los ejercicios 12 y 13.
%
% El ejercicio 12 explica varios ejemplos con cláusulas supuestas sin
% instanciar; el 13 agrega dos negativos a los ejemplos de numerales.
%
% solo-local: carga módulos del capítulo, que cargan archivos de otros
% capítulos.
%
%?- inducibles(abuelo, Is), modelo_fondo(M), ejemplos(abuelo, Pos, _), inducir_todos(Pos, Is, M, H).
%?- numerales_corregidos(H).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(abductiva).
:- use_module(mis, [mis/4, mostrar_mis/1]).

% Ejercicio 12

%!  inducir_todos(+Ejemplos:list, +Inducibles:list, +Fondo:list, -H:list)
%!      is nondet.
%
%   H es una lista de cláusulas de Inducibles, sin instanciar, con las que
%   se prueban todos los Ejemplos junto con los hechos de Fondo. Una
%   cláusula supuesta para un ejemplo se reutiliza, renombrada, para los
%   siguientes.
inducir_todos(Ejemplos, Inducibles, Fondo, H) :-
    foldl(inducir_general(Inducibles, Fondo), Ejemplos, [], H).

%!  inducir_general(+Inducibles:list, +Fondo:list, +Meta, +H0:list,
%!                  -H:list) is nondet.
%
%   Como inducir/5, pero las cláusulas de H0 y H no están instanciadas:
%   cada uso es una copia.
inducir_general(_, Fondo, Meta, H, H) :-
    member(Meta, Fondo).
inducir_general(Inducibles, Fondo, Meta, H0, H) :-
    member(C, H0),
    copy_term(C, (Meta :- Cuerpo)),
    foldl(inducir_general(Inducibles, Fondo), Cuerpo, H0, H).
inducir_general(Inducibles, Fondo, Meta, H0, H) :-
    member(R, Inducibles),
    \+ ( member(C, H0),
         C =@= R ),
    copy_term(R, (Meta :- Cuerpo)),
    foldl(inducir_general(Inducibles, Fondo), Cuerpo, [R|H0], H).

% Ejercicio 13

%!  numerales_corregidos(-H:list) is semidet.
%
%   H es la hipótesis de mis/4 para los ejemplos de numerales con dos
%   negativos más después del primer positivo: listnum([], [uno]) y
%   listnum([uno], []).
numerales_corregidos(H) :-
    mis(numerales,
        [ pos(listnum([], [])),
          neg(listnum([], [uno])),
          neg(listnum([uno], [])),
          neg(listnum([uno], [uno])),
          neg(listnum([1, dos], [uno, dos])),
          pos(listnum([1], [uno])),
          neg(listnum([cuatro, dos], [4, dos])),
          pos(listnum([cuatro], [4]))
        ], H, _).
