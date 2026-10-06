:- encoding(utf8).

% Capítulo 62 - La estrategia del conjunto de soporte.
%
% Rowe describe la estrategia de conjunto de soporte: las cláusulas se
% separan en las hipótesis, que se suponen consistentes, y el soporte, la
% negación de lo que se quiere probar. Cada paso de resolución usa al menos
% una cláusula del soporte, y los resolventes pasan a formar parte de él.
% Dos hipótesis nunca se resuelven entre sí: si las hipótesis son
% consistentes, de ellas solas no se deriva la cláusula vacía.
%
% Las cláusulas se numeran con las hipótesis primero; como cada paso
% r(I, J, R) tiene I =< J, basta con que J sea del soporte. La búsqueda es
% la profundización iterativa de la versión 6, con su resolvente, su
% factorización y la comprobación de ocurrencia.
%
% solo-local: carga resolucion_fo.pl, que carga las versiones anteriores.
%
%?- refutar_soporte([[-hombre(X), +mortal(X)], [+hombre(socrates)]], [[-mortal(socrates)]], 5, P).

:- module(soporte,
          [ refutar_soporte/4,
            comparar_estrategias/3
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(resolucion_fo).
:- use_module(clausal, [tautologica/1]).

%!  refutar_soporte(+Hipotesis:list, +Soporte:list, +Max:integer,
%!                  -Pasos:list) is semidet.
%
%   Pasos es la refutación más corta de las Hipotesis y el Soporte, de a
%   lo sumo Max pasos, en la que cada paso usa una cláusula del Soporte o
%   un resolvente anterior. Los resolventes que son variantes de una
%   cláusula anterior se descartan.
refutar_soporte(Hipotesis, Soporte, Max, Pasos) :-
    length(Hipotesis, NH),
    append(Hipotesis, Soporte, Clausulas),
    between(0, Max, N),
    length(Pasos, N),
    derivar_soporte(Pasos, NH, Clausulas),
    !.

%!  derivar_soporte(?Pasos:list, +NH:integer, +Clausulas:list) is nondet.
%
%   Pasos, una lista de longitud conocida, lleva de Clausulas a una lista
%   que contiene la cláusula vacía; las NH primeras son las hipótesis, y
%   ningún paso usa solo hipótesis.
derivar_soporte([], _, Clausulas) :-
    memberchk([], Clausulas).
derivar_soporte([Paso|Pasos], NH, Clausulas) :-
    paso_soporte(NH, Clausulas, Paso, R),
    \+ tautologica(R),
    \+ ( member(C, Clausulas),
         C =@= R
       ),
    append(Clausulas, [R], Clausulas1),
    derivar_soporte(Pasos, NH, Clausulas1).

%!  paso_soporte(+NH:integer, +Clausulas:list, -Paso, -R:list) is nondet.
%
%   Paso es un paso de resolución o de factorización sobre las Clausulas
%   cuya cláusula de número mayor es del soporte, de número mayor que NH;
%   R es la cláusula que agrega.
paso_soporte(NH, Clausulas, r(I, J, R), R) :-
    nth1(J, Clausulas, C2),
    J > NH,
    nth1(I, Clausulas, C1),
    I =< J,
    resolvente_fo(unify_with_occurs_check, C1, C2, R).
paso_soporte(NH, Clausulas, f(I, R), R) :-
    nth1(I, Clausulas, C),
    I > NH,
    factor(unify_with_occurs_check, C, R).

%!  comparar_estrategias(+Hipotesis:list, +Soporte:list,
%!                       -Inferencias:list) is det.
%
%   Inferencias son los pares general-N, lineal-N y soporte-N: las
%   inferencias de Prolog que cuesta encontrar la refutación más corta de
%   las Hipotesis y el Soporte con cada estrategia, con un máximo de 8
%   pasos.
comparar_estrategias(Hipotesis, Soporte,
                     [general-G, lineal-L, soporte-S]) :-
    append(Hipotesis, Soporte, Clausulas),
    inferencias(refutar_con(opciones(general, repetida,
                                     unify_with_occurs_check, si),
                            Clausulas, 8, _), G),
    inferencias(refutar_fo(Clausulas, 8, _), L),
    inferencias(refutar_soporte(Hipotesis, Soporte, 8, _), S).

%!  inferencias(:Meta, -N:integer) is det.
%
%   N es la cantidad de inferencias que cuesta probar Meta una vez.
inferencias(Meta, N) :-
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    N is I1 - I0.
