:- encoding(utf8).

% Capítulo 55 - ANALOGY: problemas de analogías geométricas.
%
% Un diagrama es una figura (circulo, cuadrado, triangulo, rombo) o una
% relación entre dos diagramas: dentro(A, B), A dentro de B, o encima(A,
% B), A encima de B. transformacion/3 relaciona dos diagramas por una
% operación, y sirve en los dos sentidos: con los dos diagramas da la
% operación, y con la operación y un diagrama da el otro. analogia/3
% resuelve «A es a B como C es a X» con la sucesión de operaciones más
% corta que lleva de A a B y de C a una de las respuestas.
%
%?- resolver(invertir, N, Ops).

:- op(700, xfx, es_a).

:- multifile
    figura/1,
    relacion/1,
    transformacion/3,
    problema/5.

% figura(F): F es una figura simple.
figura(circulo).
figura(cuadrado).
figura(triangulo).
figura(rombo).

% relacion(R): R es una relación entre dos diagramas.
relacion(dentro).
relacion(encima).

%!  partes(?D, ?R, ?A, ?B) is semidet.
%
%   El diagrama D es la relación R entre A y B. Con D instanciado o con R
%   instanciado.
partes(D, R, A, B) :-
    relacion(R),
    D =.. [R, A, B].

%!  transformacion(?Op, +D1, ?D2) is nondet.
%
%   La operación Op convierte el diagrama D1 en el diagrama D2, distinto
%   de D1: invertir intercambia las dos partes de una relación;
%   relacion(R) cambia la relación por R; interior(F) y exterior(F)
%   reemplazan la primera o la segunda parte por la figura F; quitar_
%   exterior deja la primera parte sola; y cambiar(F) reemplaza una figura
%   por la figura F.
transformacion(invertir, D1, D2) :-
    partes(D1, R, A, B),
    A \== B,
    partes(D2, R, B, A).
transformacion(relacion(R2), D1, D2) :-
    partes(D1, R1, A, B),
    relacion(R2),
    R2 \== R1,
    partes(D2, R2, A, B).
transformacion(interior(F), D1, D2) :-
    partes(D1, R, A, B),
    figura(F),
    F \== A,
    partes(D2, R, F, B).
transformacion(exterior(F), D1, D2) :-
    partes(D1, R, A, B),
    figura(F),
    F \== B,
    partes(D2, R, A, F).
transformacion(quitar_exterior, D1, A) :-
    partes(D1, _, A, _).
transformacion(cambiar(F), F0, F) :-
    figura(F0),
    figura(F),
    F \== F0.

%!  transforma(?Ops:list, +D0, ?D) is nondet.
%
%   Las operaciones Ops, aplicadas en orden, convierten D0 en D.
transforma([], D, D).
transforma([Op|Ops], D0, D) :-
    transformacion(Op, D0, D1),
    transforma(Ops, D1, D).

%!  analogia(+Par1, +Par2, +Respuestas:list) is semidet.
%
%   Par1 es A es_a B y Par2 es C es_a X: X es la respuesta de Respuestas a
%   la que la sucesión más corta de operaciones que convierte A en B, de
%   hasta tres, convierte C. Entre las sucesiones de igual largo, la
%   primera que se encuentra.
analogia(A es_a B, C es_a X, Respuestas) :-
    analogia(A es_a B, C es_a X, Respuestas, _).

%!  analogia(+Par1, +Par2, +Respuestas:list, -Ops:list) is semidet.
%
%   Como analogia/3; Ops son las operaciones que la explican.
analogia(A es_a B, C es_a X, Respuestas, Ops) :-
    between(1, 3, N),
    length(Ops, N),
    transforma(Ops, A, B),
    transforma(Ops, C, X),
    memberchk(X, Respuestas),
    !.

% problema(Nombre, A, B, C, Respuestas): un problema de analogía.
problema(invertir, dentro(cuadrado, triangulo), dentro(triangulo, cuadrado),
         dentro(circulo, cuadrado),
         [dentro(circulo, triangulo), dentro(cuadrado, circulo),
          dentro(triangulo, cuadrado)]).
problema(dos_pasos, dentro(cuadrado, triangulo),
         encima(triangulo, cuadrado), dentro(circulo, rombo),
         [encima(circulo, rombo), dentro(rombo, circulo),
          encima(rombo, circulo)]).
problema(quitar, encima(circulo, cuadrado), circulo,
         encima(triangulo, rombo),
         [rombo, triangulo, encima(rombo, triangulo)]).
problema(dos_lecturas, dentro(circulo, cuadrado), dentro(cuadrado, circulo),
         dentro(triangulo, rombo),
         [dentro(cuadrado, circulo), dentro(rombo, triangulo)]).
problema(sin_respuesta, dentro(cuadrado, triangulo), rombo,
         dentro(circulo, cuadrado), [circulo, cuadrado]).

%!  resolver(+Nombre, -Numero:integer, -Ops:list) is semidet.
%
%   Numero es la posición, desde 1, de la respuesta del problema Nombre, y
%   Ops las operaciones que la justifican.
resolver(Nombre, Numero, Ops) :-
    problema(Nombre, A, B, C, Respuestas),
    analogia(A es_a B, C es_a X, Respuestas, Ops),
    once(nth1(Numero, Respuestas, X)).
