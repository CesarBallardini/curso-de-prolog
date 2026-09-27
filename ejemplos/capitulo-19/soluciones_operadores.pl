:- encoding(utf8).

% Capítulo 19 - Soluciones de los ejercicios 1, 2, 3, 6, 9 y 12: operadores.
%
% Los operadores del ejercicio 1 y los del 3 comparten y, con la misma
% declaración; los demás son distintos, y por eso caben en un mismo archivo.
% Los ejercicios 6 y 9 son de predicción: sus respuestas están en las
% pruebas. El ejercicio 12 escribe las correlativas con el operador requiere.
%
%?- X = (merlin es_un famoso mago), write_canonical(X).
%?- X de Y es rojo.
%?- valor(no (v y f) implica f, V).
%?- correlativa(am2, R).

% --- Ejercicio 1 --------------------------------------------------------------

:- op(300, xfx, [son, es_un]).
:- op(300, fx, gusta_de).
:- op(200, xfy, y).
:- op(100, fy, famoso).

% --- Ejercicio 2 --------------------------------------------------------------

:- op(800, xfx, es).
:- op(400, yfx, de).

% X es C: X es de color C.
el_auto de la_hermana de ana es rojo.

% --- Ejercicio 3 --------------------------------------------------------------

:- op(150, fy, no).
:- op(250, xfy, o).
:- op(300, xfy, implica).

%!  valor(+Formula, -V) is det.
%
%   V es el valor de verdad, v o f, de Formula: una fórmula con las
%   constantes v y f y los operadores no, y, o e implica.
valor(v, v).
valor(f, f).
valor(no A, V) :-
    valor(A, VA),
    negacion(VA, V).
valor(A y B, V) :-
    valor(A, VA),
    valor(B, VB),
    conjuncion(VA, VB, V).
valor(A o B, V) :-
    valor(A, VA),
    valor(B, VB),
    disyuncion(VA, VB, V).
valor(A implica B, V) :-
    valor(no A o B, V).

% negacion(A, V): V es la negación de A.
negacion(v, f).
negacion(f, v).

% conjuncion(A, B, V): V es la conjunción de A y B.
conjuncion(v, v, v).
conjuncion(v, f, f).
conjuncion(f, v, f).
conjuncion(f, f, f).

% disyuncion(A, B, V): V es la disyunción de A y B.
disyuncion(v, v, v).
disyuncion(v, f, v).
disyuncion(f, v, v).
disyuncion(f, f, f).

% --- Ejercicio 12 -------------------------------------------------------------

:- op(700, xfx, requiere).

% Materia requiere Requisitos: para cursar Materia hay que aprobar cada uno
% de los Requisitos, unidos con y.
am2 requiere am1 y alg.
pp  requiere log.
ssl requiere log y alg.
bd  requiere pp y ssl.

%!  correlativa(?Materia:atom, ?Requisito:atom) is nondet.
%
%   Para cursar Materia hay que aprobar Requisito: la relación del proyecto,
%   obtenida de los hechos requiere.
correlativa(Materia, Requisito) :-
    Materia requiere Requisitos,
    entre(Requisito, Requisitos).

%!  entre(?X, +Conjuncion) is nondet.
%
%   X es uno de los términos de Conjuncion, unidos con y: a y b y c son a, b
%   y c. Un término que no es una conjunción es él mismo.
entre(X, A y B) :-
    !,
    (   entre(X, A)
    ;   entre(X, B)
    ).
entre(X, X).
