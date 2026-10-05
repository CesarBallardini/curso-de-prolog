:- encoding(utf8).

% Capítulo 75 - Versión 8: generar solamente los representantes.
%
% tipos.pl evalúa un patrón por tipo, pero todavía genera todos los
% desarreglos para calcular su tipo. Los tipos de desarreglo de 1..N son
% las particiones de N en partes mayores que 1: se generan directamente,
% y de cada una se construye una permutación representante, con ciclos de
% números consecutivos. El tamaño del espacio pasa de los desarreglos
% (14 833 para N = 8) a las particiones (7).
%
% solo-local: carga tipos.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- findall(T, particion(8, T), Ts).
%?- representante([2, 3], P).
%?- maximo_representantes(8, Total, Tipo).

:- ensure_loaded(tipos).

%!  particion(+N:integer, -Partes:list(integer)) is nondet.
%
%   Partes es una partición de N en partes mayores que 1, de menor a
%   mayor. Las particiones salen en orden lexicográfico.
particion(N, Partes) :-
    particion(N, 2, Partes).

%!  particion(+N:integer, +Minima:integer, -Partes:list(integer))
%!      is nondet.
%
%   Partes es una partición de N en partes de al menos Minima, de menor a
%   mayor.
particion(0, _, []).
particion(N, Minima, [P|Partes]) :-
    between(Minima, N, P),
    Resto is N - P,
    (   Resto =:= 0
    ->  true
    ;   Resto >= P
    ),
    particion(Resto, P, Partes).

%!  representante(+Tipo:list(integer), -P:list(integer)) is det.
%
%   P es la permutación de 1..N, N la suma de Tipo, cuyos ciclos son
%   bloques de números consecutivos con las longitudes de Tipo, en ese
%   orden: [2, 3] da (1 2)(3 4 5), es decir [2, 1, 4, 5, 3].
representante(Tipo, P) :-
    foldl(bloque, Tipo, Bloques, 1, _),
    append(Bloques, P).

%!  bloque(+L:integer, -Imagenes:list(integer), +Desde:integer,
%!         -Hasta:integer) is det.
%
%   Imagenes son las imágenes del ciclo (Desde Desde+1 ... Desde+L-1):
%   cada número va al siguiente y el último vuelve a Desde. Hasta es
%   Desde + L.
bloque(L, Imagenes, Desde, Hasta) :-
    Hasta is Desde + L,
    Segundo is Desde + 1,
    Ultimo is Hasta - 1,
    numlist(Segundo, Ultimo, Siguientes),
    append(Siguientes, [Desde], Imagenes).

%!  total_de_tipo(+Tipo:list(integer), -Total:integer) is semidet.
%
%   Total es la suma del tablero de mayor suma para el representante de
%   Tipo. Falla si el patrón tiene dos filas iguales.
total_de_tipo(Tipo, Total) :-
    representante(Tipo, P),
    matriz_patron(P, M),
    filas_distintas(M),
    evaluar(M, Total).

%!  maximo_representantes(+N:integer, -Total:integer, -Tipo:list)
%!      is semidet.
%
%   Total es la mayor suma de un tablero de N por N y Tipo, un tipo de
%   desarreglo que la alcanza. Falla si ningún tipo da filas distintas.
maximo_representantes(N, Total, Tipo) :-
    aggregate_all(max(T, Ti), ( particion(N, Ti), total_de_tipo(Ti, T) ),
                  max(Total, Tipo)).
