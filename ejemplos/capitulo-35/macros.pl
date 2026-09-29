:- encoding(utf8).

% Capítulo 35 - Macros de la biblioteca: library(apply_macros) expande
% maplist/N, forall/2, once/1, ignore/1 y phrase/2,3 al cargar.
%
% En SWI-Prolog 9.2.9 la biblioteca expande solo si la bandera
% optimise_apply es true, o si swipl se inició con -O; por eso el archivo
% fija la bandera antes de cargarla. dobles/2 y dobles_lambda/2 se cargan
% como llamadas a predicados auxiliares que la biblioteca genera; todos/2
% se carga como una doble negación. dobles_en_ejecucion/2 arma la llamada
% a maplist/3 al ejecutarse, y esa no se expande.
%
% solo-local: la expansión ocurre al cargar el archivo, con una bandera
% del sistema que SWISH no permite cambiar.
%
%?- expand_goal(maplist(doble, L, D), G).
%?- dobles_lambda([1, 2, 3], D).
%?- expand_goal(forall(member(X, L), X > 0), G).

:- set_prolog_flag(optimise_apply, true).
:- use_module(library(apply_macros)).
:- use_module(library(yall)).

%!  doble(+X:number, -Y:number) is det.
%
%   Y es el doble de X.
doble(X, Y) :-
    Y is 2 * X.

%!  dobles(+Xs:list(number), -Ys:list(number)) is det.
%
%   Ys tiene el doble de cada número de Xs.
dobles(Xs, Ys) :-
    maplist(doble, Xs, Ys).

%!  dobles_lambda(+Xs:list(number), -Ys:list(number)) is det.
%
%   La misma relación que dobles/2, con una expresión lambda.
dobles_lambda(Xs, Ys) :-
    maplist([X, Y]>>(Y is 2 * X), Xs, Ys).

%!  dobles_en_ejecucion(+Xs:list(number), -Ys:list(number)) is det.
%
%   La misma relación, con la llamada a maplist/3 construida al ejecutarse:
%   no está escrita en el cuerpo, y no se expande.
dobles_en_ejecucion(Xs, Ys) :-
    Meta = maplist([X, Y]>>(Y is 2 * X), Xs, Ys),
    call(Meta).

%!  todos(+Xs:list(number), +Minimo:number) is semidet.
%
%   Todos los números de Xs son mayores que Minimo.
todos(Xs, Minimo) :-
    forall(member(X, Xs), X > Minimo).
