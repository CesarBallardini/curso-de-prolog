:- encoding(utf8).

% Capítulo 39 - Tabulación incremental: tablas que siguen a los datos.
%
% enlace/2 es dinámico: los enlaces de una red cambian mientras el programa
% corre. alcanza_fijo/2 está tabulado de la manera común: después de
% agregar un enlace sigue respondiendo con la tabla vieja, hasta que se
% borran las tablas con abolish_all_tables/0. alcanza/2 está declarado
% incremental, y enlace/2 también: agregar o quitar un enlace invalida las
% tablas que dependen de él, y la próxima consulta las recalcula.
%
%?- alcanza(a, Y).
%?- assertz(enlace(c, d)), alcanza(a, Y).

:- dynamic enlace/2 as incremental.

% enlace(X, Y): hay un enlace de X a Y.
enlace(a, b).
enlace(b, c).

:- table alcanza_fijo/2.

%!  alcanza_fijo(?X, ?Y) is nondet.
%
%   Desde X se llega a Y por uno o más enlaces. La tabla no sigue los
%   cambios de enlace/2.
alcanza_fijo(X, Y) :-
    enlace(X, Y).
alcanza_fijo(X, Y) :-
    alcanza_fijo(X, Z),
    enlace(Z, Y).

:- table alcanza/2 as incremental.

%!  alcanza(?X, ?Y) is nondet.
%
%   La misma relación, con una tabla incremental: sigue los cambios de
%   enlace/2.
alcanza(X, Y) :-
    enlace(X, Y).
alcanza(X, Y) :-
    alcanza(X, Z),
    enlace(Z, Y).

%!  restaurar is det.
%
%   Deja la red con sus dos enlaces iniciales y borra las tablas.
restaurar :-
    retractall(enlace(_, _)),
    assertz(enlace(a, b)),
    assertz(enlace(b, c)),
    abolish_all_tables.
