:- encoding(utf8).

% Capítulo 61 - Solución del ejercicio 6: una versión que escribe cada
% paso.
%
% El módulo traza es una versión más de la máquina para ejecutar/5 de
% almacen.pl: su paso/5 escribe la altura de la pila de puntos de elección
% y la meta, reconstruida con las ligaduras del almacén, y delega el paso
% en el de almacen.pl; su volver/3 escribe una línea y delega también.
%
% solo-local: carga el módulo almacen.
%
%?- resolver(familia, abuelo(juan, N)).

:- module(traza, [resolver/2]).

:- use_module(almacen, [resolver_con/3, compilar/2, reconstruir/3]).

%!  resolver(+Nombre:atom, ?Meta) is nondet.
%
%   Como resolver/2 de almacen.pl, escribiendo cada paso.
resolver(Nombre, Meta) :-
    resolver_con(traza, Nombre, Meta).

%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Escribe la altura de la pila y Meta, y da el paso de almacen.pl.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    Estado0 = m(_, Pila, Almacen, _, _, _),
    length(Pila, Altura),
    reconstruir(Meta, Almacen, Meta1),
    numbervars(Meta1, 0, _),
    format("~d ~W~n", [Altura, Meta1, [numbervars(true), quoted(true)]]),
    almacen:paso(Meta, Metas, Tabla, Estado0, Resultado).

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   Escribe que la máquina vuelve atrás, si hay a dónde, y vuelve con el
%   volver/3 de almacen.pl.
volver(Tabla, Estado0, Resultado) :-
    (   Estado0 = m(_, [_|_], _, _, _, _)
    ->  format("vuelve~n")
    ;   true
    ),
    almacen:volver(Tabla, Estado0, Resultado).
