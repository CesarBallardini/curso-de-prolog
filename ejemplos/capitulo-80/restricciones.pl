:- encoding(utf8).

% Capítulo 80 - Versión 3: cada unión es una restricción.
%
% La idea de Clocksin y Mellish: cada línea del dibujo es una variable, y
% el dibujo es el conjunto de restricciones que esas variables cumplen. La
% restricción de una unión es la lista de sus combinaciones posibles, y
% elegir una para la unión liga de una vez las variables de sus líneas. La
% unión siguiente que comparte una línea ya ligada solo acepta las
% combinaciones que unifican con esa etiqueta: la unificación propaga la
% elección, y una contradicción se descubre en cuanto aparece, sin esperar
% a que todas las líneas tengan etiqueta.
%
% El orden en que se eligen las uniones cambia el costo. ordenar/4 con
% vecindad pone primero una unión y después, una a una, las que están
% unidas por una línea a alguna de las anteriores, de modo que cada
% elección encuentra líneas ya ligadas.
%
% solo-local: carga dibujo.pl.
%
%?- etiquetar_por_uniones(cubo, borde, alfabetico, Lineas).
%?- interpretaciones_por_uniones(bloques, borde, vecindad, N).

:- ensure_loaded(dibujo).

%!  etiquetar_por_uniones(+F, +Modo, +Orden, -Lineas:list) is nondet.
%
%   Lineas es una interpretación del dibujo F. Elige una combinación del
%   catálogo para cada unión, en el Orden dado: alfabetico o vecindad.
etiquetar_por_uniones(F, Modo, Orden, Lineas) :-
    problema(F, Modo, Lineas, Uniones0),
    ordenar(Orden, F, Uniones0, Uniones),
    maplist(elegir, Uniones).

%!  elegir(+U) is nondet.
%
%   Elige para la unión U una combinación de su tipo y la unifica con las
%   variables de sus líneas.
elegir(u(_, Tipo, Vistas)) :-
    union_posible(Tipo, Locales),
    maplist(vista, Vistas, Locales).

%!  ordenar(+Orden, +F, +Us:list, -Ordenadas:list) is det.
%
%   Ordenadas son las uniones Us del dibujo F en el Orden pedido.
%   alfabetico las deja como están; vecindad empieza por la primera y sigue
%   siempre por una unión unida por una línea a alguna ya elegida.
ordenar(alfabetico, _, Us, Us).
ordenar(vecindad, _, [], []).
ordenar(vecindad, F, [U|Us], [U|Ordenadas]) :-
    vecindad(Us, F, [U], Ordenadas).

%!  vecindad(+Restantes:list, +F, +Elegidas:list, -Orden:list) is det.
%
%   Orden son las Restantes en el orden en que se agregan: cada vez, la
%   primera de ellas unida a una de las Elegidas, o la primera de todas si
%   ninguna lo está.
vecindad([], _, _, []).
vecindad([R|Rs], F, Elegidas, [U|Orden]) :-
    Restantes = [R|Rs],
    (   select(U, Restantes, Otras),
        unida(F, U, Elegidas)
    ->  true
    ;   Restantes = [U|Otras]
    ),
    vecindad(Otras, F, [U|Elegidas], Orden).

%!  unida(+F, +U, +Us:list) is semidet.
%
%   Una línea del dibujo F une la unión U con alguna de las uniones Us.
unida(F, u(P, _, _), Us) :-
    member(u(Q, _, _), Us),
    conectados(F, P, Q),
    !.

%!  interpretaciones_por_uniones(+F, +Modo, +Orden, -N:integer) is det.
%
%   N es la cantidad de interpretaciones del dibujo F.
interpretaciones_por_uniones(F, Modo, Orden, N) :-
    aggregate_all(count, etiquetar_por_uniones(F, Modo, Orden, _), N).
