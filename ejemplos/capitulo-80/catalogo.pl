:- encoding(utf8).

% Capítulo 80 - El catálogo de uniones de Huffman y Clowes.
%
% En un dibujo de poliedros cuyos vértices son triedros, cada línea es la
% imagen de una arista convexa (mas), de una arista cóncava (menos) o de un
% contorno, donde una cara oculta a lo que está detrás. Un contorno se
% etiqueta según el lado en que está el cuerpo que oculta, visto desde una
% de sus uniones mirando a lo largo de la línea: der si el cuerpo queda a la
% derecha, izq si queda a la izquierda. Desde la otra punta, la misma línea
% se ve al revés: der e izq se intercambian, y mas y menos no cambian.
%
% Las uniones son de cuatro tipos según su forma: ele (dos líneas), horquilla
% (tres líneas, ningún ángulo mayor que 180 grados), flecha (tres líneas, un
% ángulo mayor que 180) y te (dos de las tres líneas alineadas). Las líneas
% de una unión se nombran en el sentido de las agujas del reloj; en la
% flecha, desde la primera aleta hasta la segunda pasando por el astil; en
% la te, primero las dos de la barra y al final el pie; en la ele, de modo
% que el ángulo de la primera a la segunda sea menor que 180 grados.
%
%?- union_posible(flecha, Etiquetas).
%?- cantidad(Tipo, N).

% etiqueta(E): E es una de las cuatro etiquetas de una línea.
etiqueta(mas).
etiqueta(menos).
etiqueta(der).
etiqueta(izq).

% inversa(E, F): una línea con la etiqueta E vista desde una punta tiene la
% etiqueta F vista desde la otra.
inversa(mas, mas).
inversa(menos, menos).
inversa(der, izq).
inversa(izq, der).

% union_posible(Tipo, Etiquetas): una unión de Tipo puede tener sus líneas,
% en el orden del encabezado, con esas Etiquetas. Son las 18 del catálogo.
union_posible(ele, [der, izq]).
union_posible(ele, [izq, der]).
union_posible(ele, [mas, der]).
union_posible(ele, [izq, mas]).
union_posible(ele, [menos, izq]).
union_posible(ele, [der, menos]).
union_posible(horquilla, [mas, mas, mas]).
union_posible(horquilla, [menos, menos, menos]).
union_posible(horquilla, [izq, der, menos]).
union_posible(horquilla, [menos, izq, der]).
union_posible(horquilla, [der, menos, izq]).
union_posible(flecha, [der, mas, izq]).
union_posible(flecha, [mas, menos, mas]).
union_posible(flecha, [menos, mas, menos]).
union_posible(te, [der, izq, mas]).
union_posible(te, [der, izq, menos]).
union_posible(te, [der, izq, der]).
union_posible(te, [der, izq, izq]).

%!  cantidad(?Tipo, ?N:integer) is nondet.
%
%   N es la cantidad de uniones posibles de Tipo en el catálogo.
cantidad(Tipo, N) :-
    member(Tipo, [ele, horquilla, flecha, te]),
    aggregate_all(count, union_posible(Tipo, _), N).
