:- encoding(utf8).

% Capítulo 39 - Lo que cuesta una tabla.
%
% cadena/1 arma una red de N enlaces en fila, de 0 a N, sin ciclos: Prolog
% la recorre sin tablas. alcanza_sin_tabla/2 tiene la recursión a la
% derecha y no está tabulado. alcanza_der/2 es la misma definición
% tabulada: cada nodo intermedio es una llamada nueva, con su propia tabla.
% alcanza_izq/2 tiene la recursión a la izquierda: todas las llamadas
% recursivas son variantes de la primera y usan una sola tabla. tablas/1
% cuenta las tablas que existen.
%
%?- cadena(100), aggregate_all(count, alcanza_izq(0, _), N), tablas(T).
%?- cadena(100), aggregate_all(count, alcanza_der(0, _), N), tablas(T).

:- dynamic enlace/2.

% enlace(X, Y): hay un enlace de X a Y.

%!  cadena(+N:integer) is det.
%
%   Reemplaza los enlaces por N enlaces en fila, de I a I + 1 para I de 0 a
%   N - 1, y borra las tablas.
cadena(N) :-
    must_be(nonneg, N),
    retractall(enlace(_, _)),
    abolish_all_tables,
    forall(between(1, N, J),
           ( I is J - 1,
             assertz(enlace(I, J)) )).

%!  alcanza_sin_tabla(?X, ?Y) is nondet.
%
%   Desde X se llega a Y por uno o más enlaces, sin tabla: termina solo si
%   la red no tiene ciclos.
alcanza_sin_tabla(X, Y) :-
    enlace(X, Y).
alcanza_sin_tabla(X, Y) :-
    enlace(X, Z),
    alcanza_sin_tabla(Z, Y).

:- table alcanza_der/2.

%!  alcanza_der(?X, ?Y) is nondet.
%
%   La misma relación, tabulada, con la recursión a la derecha.
alcanza_der(X, Y) :-
    enlace(X, Y).
alcanza_der(X, Y) :-
    enlace(X, Z),
    alcanza_der(Z, Y).

:- table alcanza_izq/2.

%!  alcanza_izq(?X, ?Y) is nondet.
%
%   La misma relación, tabulada, con la recursión a la izquierda.
alcanza_izq(X, Y) :-
    enlace(X, Y).
alcanza_izq(X, Y) :-
    alcanza_izq(X, Z),
    enlace(Z, Y).

%!  tablas(-N:integer) is det.
%
%   N es la cantidad de tablas que existen en este momento.
tablas(N) :-
    aggregate_all(count, current_table(_, _), N).
