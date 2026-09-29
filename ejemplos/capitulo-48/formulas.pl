:- encoding(utf8).

% Capítulo 48 - Versión 3: qué calcula un circuito.
%
% La misma descripción de la versión 2, simulada con otra conducta: cada
% cable lleva una fórmula en lugar de un valor, y cada entrada, su propio
% nombre. Una fórmula es 0, 1, el nombre de una entrada (un átomo), o ~F,
% F * G, F + G y F # G: la negación, la conjunción, la disyunción y la
% disyunción exclusiva, con los operadores de library(clpb). La fórmula se
% lleva después a una suma de productos: una lista de productos, cada uno
% una lista ordenada de literales, X o ~X, sin productos contradictorios
% ni absorbidos por otro.
%
% solo-local: carga el módulo circuitos, y SWISH no admite módulos propios.
%
%?- formula(sumador, co, F).
%?- suma_de_productos(a*b + (a#b)*ci, Ps).

:- module(formulas,
          [ formula/3,
            simbolica/4,
            fnn/2,
            productos/2,
            simplificar/2,
            suma_de_productos/2,
            como_formula/2,
            op(300, fy, ~),
            op(500, yfx, #)
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(circuitos).

%!  simbolica(+Ruta:list, +Tipo, +Entradas:list, -Formula) is det.
%
%   Formula es la salida de la compuerta Tipo cuando sus entradas son las
%   fórmulas Entradas.
simbolica(_Ruta, inv, [A], ~A).
simbolica(_Ruta, and, [A, B], A * B).
simbolica(_Ruta, or, [A, B], A + B).
simbolica(_Ruta, xor, [A, B], A # B).
simbolica(_Ruta, nand, [A, B], ~(A * B)).
simbolica(_Ruta, nor, [A, B], ~(A + B)).

%!  formula(+Circuito, ?Salida, -Formula) is nondet.
%
%   Formula es la fórmula de la salida Salida de Circuito sobre los
%   nombres de sus entradas. Un circuito con realimentación produce un
%   error de dominio: su fórmula sería un término cíclico.
formula(Circuito, Salida, Formula) :-
    circuito(Circuito, Entradas, Salidas),
    simular(simbolica, Circuito, Entradas, Formulas),
    (   acyclic_term(Formulas)
    ->  true
    ;   domain_error(circuito_sin_realimentacion, Circuito)
    ),
    nth1(I, Salidas, Salida),
    nth1(I, Formulas, Formula).

%!  fnn(+Formula, -Normal) is det.
%
%   Normal es Formula en forma normal negativa: sin #, y con la negación
%   solo delante de un nombre de entrada (leyes de De Morgan). La
%   cláusula de las constantes y los nombres va primera, para que la
%   indexación no deje alternativas pendientes.
fnn(X, X) :-
    atomic(X).
fnn(~F, N) :-
    negar(F, N).
fnn(A * B, NA * NB) :-
    fnn(A, NA),
    fnn(B, NB).
fnn(A + B, NA + NB) :-
    fnn(A, NA),
    fnn(B, NB).
fnn(A # B, N) :-
    fnn(A * ~B + ~A * B, N).

%!  negar(+Formula, -Normal) is det.
%
%   Normal es la negación de Formula en forma normal negativa.
negar(X, ~X) :-
    atom(X).
negar(0, 1).
negar(1, 0).
negar(~F, N) :-
    fnn(F, N).
negar(A * B, NA + NB) :-
    negar(A, NA),
    negar(B, NB).
negar(A + B, NA * NB) :-
    negar(A, NA),
    negar(B, NB).
negar(A # B, N) :-
    fnn(A * B + ~A * ~B, N).

%!  productos(+Normal, -Productos:list(list)) is det.
%
%   Productos es la suma de productos de la fórmula Normal, en forma
%   normal negativa, distribuyendo la conjunción sobre la disyunción: []
%   es 0, y un producto vacío es 1.
productos(X, [[X]]) :-
    atom(X).
productos(0, []).
productos(1, [[]]).
productos(~X, [[~X]]).
productos(A + B, Ps) :-
    productos(A, PAs),
    productos(B, PBs),
    append(PAs, PBs, Ps).
productos(A * B, Ps) :-
    productos(A, PAs),
    productos(B, PBs),
    findall(P,
            ( member(PA, PAs),
              member(PB, PBs),
              append(PA, PB, P) ),
            Ps).

%!  simplificar(+Productos:list(list), -Simples:list(list)) is det.
%
%   Simples es la misma suma que Productos, con cada producto ordenado y
%   sin literales repetidos (X * X = X), sin productos contradictorios
%   (X * ~X = 0), sin productos repetidos (P + P = P) y sin productos que
%   contienen a otro (P + P * Q = P).
simplificar(Productos, Simples) :-
    maplist(sort, Productos, Ordenados),
    exclude(contradictorio, Ordenados, Consistentes),
    sort(Consistentes, Distintos),
    exclude(absorbido(Distintos), Distintos, Simples).

%!  contradictorio(+Producto:list) is semidet.
%
%   Producto tiene un literal y su negación.
contradictorio(Producto) :-
    member(X, Producto),
    atom(X),
    memberchk(~X, Producto),
    !.

%!  absorbido(+Productos:list(list), +Producto:list) is semidet.
%
%   Otro producto de Productos está contenido en Producto.
absorbido(Productos, Producto) :-
    member(Otro, Productos),
    Otro \== Producto,
    ord_subset(Otro, Producto),
    !.

%!  suma_de_productos(+Formula, -Productos:list(list)) is det.
%
%   Productos es la suma de productos simplificada de Formula.
suma_de_productos(Formula, Productos) :-
    fnn(Formula, Normal),
    productos(Normal, Productos0),
    simplificar(Productos0, Productos).

%!  como_formula(+Productos:list(list), -Formula) is det.
%
%   Formula es la suma de productos Productos escrita con * y +.
como_formula([], 0).
como_formula([P|Ps], Formula) :-
    producto(P, F0),
    foldl(sumar, Ps, F0, Formula).

%!  sumar(+Producto:list, +F0, -F) is det.
%
%   F es la fórmula F0 más el Producto.
sumar(P, F0, F0 + F) :-
    producto(P, F).

%!  producto(+Literales:list, -Formula) is det.
%
%   Formula es la conjunción de los Literales; 1 si no hay ninguno.
producto([], 1).
producto([L|Ls], Formula) :-
    foldl([X, F0, F0 * X]>>true, Ls, L, Formula).
