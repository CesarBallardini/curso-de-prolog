:- encoding(utf8).

% Capítulo 62 - Construir un modelo por encadenamiento hacia adelante.
%
% Un modelo de un conjunto de cláusulas es un conjunto de fórmulas
% atómicas sin variables, las verdaderas, que hace verdadera cada
% cláusula. modelo/2 lo construye como Flach, sobre la idea de SATCHMO de
% Manthey y Bry: busca una cláusula violada, con todos sus literales
% negativos verdaderos y ninguno positivo, y agrega al modelo uno de sus
% literales positivos; si la cláusula violada no tiene ninguno, vuelve
% atrás y prueba otro. Las cláusulas pueden tener variables si son de
% rango restringido: cada variable de un literal positivo aparece en uno
% negativo, de modo que el modelo, que no tiene variables, las liga.
%
% Un conjunto de cláusulas tiene un modelo si y solo si no tiene
% refutación: el modelo de la negación de una fórmula es un
% contraejemplo, la contracara de la refutación.
%
% solo-local: carga clausal.pl, que carga el lector.
%
%?- modelo([[+p, +q], [-p, +r], [-q, +r], [-r, +s]], M).
%?- contramodelo("(p → q) → (q → p)", M).

:- module(modelos,
          [ modelo/2,
            contramodelo/2
          ]).

:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(clausal).

%!  modelo(+Clausulas:list, -Modelo:list) is nondet.
%
%   Modelo, un conjunto ordenado de fórmulas atómicas sin variables, hace
%   verdaderas todas las Clausulas, de rango restringido. Una respuesta
%   por cada manera de elegir el literal positivo de cada cláusula
%   violada; puede no ser mínimo. Falla si no hay ninguno; no termina si
%   todo modelo es infinito.
modelo(Clausulas, Modelo) :-
    modelo(Clausulas, [], Modelo).

%!  modelo(+Clausulas:list, +Modelo0:list, -Modelo:list) is nondet.
%
%   Modelo extiende Modelo0 hasta que ninguna de las Clausulas está
%   violada.
modelo(Clausulas, Modelo0, Modelo) :-
    (   member(C, Clausulas),
        violada(C, Modelo0, Positivos)
    ->  member(A, Positivos),
        ord_add_element(Modelo0, A, Modelo1),
        modelo(Clausulas, Modelo1, Modelo)
    ;   Modelo = Modelo0
    ).

%!  violada(+C:list, +Modelo:list, -Positivos:list) is semidet.
%
%   Una copia de la cláusula C está violada en Modelo: sus literales
%   negativos son verdaderos, con las variables ligadas por el modelo, y
%   ninguno de sus Positivos, ya sin variables, lo es. Una variable que
%   queda libre en un literal positivo produce un error de dominio: la
%   cláusula no es de rango restringido.
violada(C, Modelo, Positivos) :-
    copy_term(C, D),
    signos(D, Negativos, Positivos),
    maplist(verdadera(Modelo), Negativos),
    (   ground(Positivos)
    ->  true
    ;   domain_error(clausula_de_rango_restringido, C)
    ),
    \+ ( member(A, Positivos),
         ord_memberchk(A, Modelo)
       ),
    !.

%!  signos(+C:list, -Negativos:list, -Positivos:list) is det.
%
%   Negativos y Positivos son las fórmulas atómicas de los literales
%   negativos y positivos de C, con las mismas variables que C.
signos([], [], []).
signos([L|Ls], Negativos, Positivos) :-
    (   L = -A
    ->  Negativos = [A|Negativos1],
        Positivos = Positivos1
    ;   L = +A,
        Negativos = Negativos1,
        Positivos = [A|Positivos1]
    ),
    signos(Ls, Negativos1, Positivos1).

%!  verdadera(+Modelo:list, ?A) is nondet.
%
%   A es una fórmula atómica del Modelo; sus variables quedan ligadas.
verdadera(Modelo, A) :-
    member(A, Modelo).

%!  contramodelo(+Texto, -Modelo:list) is nondet.
%
%   Modelo es un modelo de la forma clausal de la negación de la fórmula
%   sin cuantificadores que Texto escribe: los átomos verdaderos de una
%   asignación que hace falsa la fórmula. Falla si la fórmula es una
%   tautología.
contramodelo(Texto, Modelo) :-
    leer_formula(Texto, F),
    clausulas(no(F), Clausulas),
    modelo(Clausulas, Modelo).
