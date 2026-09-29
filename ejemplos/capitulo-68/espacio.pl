:- encoding(utf8).

% Capítulo 68 - Versión 1: el espacio de conceptos y el espacio de
% versiones por enumeración.
%
% Una pieza se describe por cuatro atributos: forma, color, tamaño y
% material. Una instancia es un término pieza/4 sin variables. Un concepto
% es un término pieza/4 en el que cada argumento es un valor o una
% variable, que significa «cualquier valor», o la constante vacio, el
% concepto que no cubre ninguna instancia. El orden de generalidad es la
% θ-subsunción del capítulo 67, que se carga en lugar de copiarse.
%
% Un ejemplo es pos(I) o neg(I). Un concepto es consistente con una lista
% de ejemplos si cubre todos los positivos y ningún negativo, y el espacio
% de versiones es el conjunto de los conceptos consistentes. Esta versión
% lo calcula recorriendo el espacio entero, y de él extrae sus elementos
% mínimos y máximos.
%
% solo-local: carga generalizar.pl del capítulo 67, y SWISH no permite
% cargar otro archivo.
%
%?- aggregate_all(count, concepto(_), N).
%?- tamanos(esfera_roja, Ns).

:- module(espacio,
          [ atributo/2,
            instancia/1,
            concepto/1,
            generaliza/2,
            cubre/2,
            consistente/2,
            secuencia/2,
            prefijo/3,
            version/2,
            tamanos/2,
            bordes_enumerados/4,
            minimos/2,
            maximos/2,
            conjunto/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(varnumbers)).
:- use_module('../capitulo-67/generalizar', [mas_general/2]).
:- reexport('../capitulo-67/generalizar', [lgg/3]).

:- dynamic atributo/2.

% atributo(A, Vs): el atributo A de una pieza toma los valores Vs.
atributo(forma, [esfera, cubo, cilindro]).
atributo(color, [rojo, verde, azul]).
atributo(tamano, [chico, grande]).
atributo(material, [madera, metal]).

%!  instancia(?I) is nondet.
%
%   I es una pieza: un valor de cada atributo, en el orden de atributo/2.
instancia(I) :-
    findall(Vs, atributo(_, Vs), Vss),
    maplist(member, Args, Vss),
    I =.. [pieza|Args].

%!  concepto(-C) is multi.
%
%   C es un concepto del lenguaje: vacio, o una pieza con un valor o una
%   variable en cada atributo.
concepto(vacio).
concepto(C) :-
    findall(Vs, atributo(_, Vs), Vss),
    maplist(valor_o_libre, Vss, Args),
    C =.. [pieza|Args].

%!  valor_o_libre(+Vs:list, -V) is multi.
%
%   V queda libre, o es uno de los valores de Vs.
valor_o_libre(_, _).
valor_o_libre(Vs, V) :-
    member(V, Vs).

%!  generaliza(@G, @E) is semidet.
%
%   El concepto G es al menos tan general como el concepto E: todo lo que
%   E cubre, G también lo cubre. vacio es el concepto menos general.
generaliza(G, E) :-
    (   E == vacio
    ->  true
    ;   mas_general(G, E)
    ).

%!  cubre(@C, +I) is semidet.
%
%   El concepto C cubre la instancia I. Ninguno de los dos queda ligado.
cubre(C, I) :-
    mas_general(C, I).

%!  consistente(@C, +Ejs:list) is semidet.
%
%   El concepto C cubre cada ejemplo pos(I) de Ejs y ningún ejemplo neg(I).
consistente(C, Ejs) :-
    forall(member(pos(I), Ejs), cubre(C, I)),
    \+ ( member(neg(I), Ejs),
         cubre(C, I) ).

% secuencia(Nombre, Ejs): Ejs es una lista de ejemplos de un concepto.
secuencia(esfera_roja,
          [ pos(pieza(esfera, rojo, chico, madera)),
            neg(pieza(cilindro, verde, grande, metal)),
            pos(pieza(esfera, rojo, grande, metal)),
            neg(pieza(esfera, azul, chico, madera)),
            neg(pieza(cubo, rojo, grande, madera))
          ]).
secuencia(rojo_o_esfera,
          [ pos(pieza(esfera, verde, chico, madera)),
            pos(pieza(cubo, rojo, chico, madera)),
            neg(pieza(cubo, verde, chico, madera))
          ]).

%!  prefijo(+Nombre, ?K:integer, -Ejs:list) is nondet.
%
%   Ejs son los primeros K ejemplos de la secuencia Nombre. Con K libre,
%   una respuesta por cada prefijo, del más corto al más largo.
prefijo(Nombre, K, Ejs) :-
    secuencia(Nombre, Todos),
    length(Todos, N),
    between(0, N, K),
    length(Ejs, K),
    append(Ejs, _, Todos).

%!  version(+Ejs:list, -V:list) is det.
%
%   V es el espacio de versiones de Ejs: los conceptos consistentes con
%   los ejemplos, en el orden en que concepto/1 los enumera.
version(Ejs, V) :-
    findall(C, ( concepto(C), consistente(C, Ejs) ), V).

%!  tamanos(+Nombre, -Ns:list) is det.
%
%   Ns son los tamaños del espacio de versiones de cada prefijo de la
%   secuencia Nombre, del vacío a la secuencia entera.
tamanos(Nombre, Ns) :-
    findall(N, ( prefijo(Nombre, _, Ejs),
                 version(Ejs, V),
                 length(V, N) ), Ns).

%!  bordes_enumerados(+Nombre, +K:integer, -S:list, -G:list) is det.
%
%   S y G son los conceptos mínimos y máximos del espacio de versiones de
%   los primeros K ejemplos de la secuencia Nombre, calculado por
%   enumeración.
bordes_enumerados(Nombre, K, S, G) :-
    prefijo(Nombre, K, Ejs),
    version(Ejs, V),
    minimos(V, S),
    maximos(V, G).

%!  minimos(+Cs:list, -M:list) is det.
%
%   M son los conceptos de Cs que no son más generales que otro concepto
%   de Cs distinto de ellos.
minimos(Cs, M) :-
    include(minimo_en(Cs), Cs, M).

%!  maximos(+Cs:list, -M:list) is det.
%
%   M son los conceptos de Cs que no son menos generales que otro concepto
%   de Cs distinto de ellos.
maximos(Cs, M) :-
    include(maximo_en(Cs), Cs, M).

%!  minimo_en(+Cs:list, @C) is semidet.
%
%   Ningún concepto de Cs es estrictamente menos general que C.
minimo_en(Cs, C) :-
    \+ ( member(D, Cs),
         estrictamente(C, D) ).

%!  maximo_en(+Cs:list, @C) is semidet.
%
%   Ningún concepto de Cs es estrictamente más general que C.
maximo_en(Cs, C) :-
    \+ ( member(D, Cs),
         estrictamente(D, C) ).

%!  estrictamente(@G, @E) is semidet.
%
%   G es más general que E, y E no es más general que G.
estrictamente(G, E) :-
    generaliza(G, E),
    \+ generaliza(E, G).

%!  conjunto(+Cs:list, -Ordenados:list) is det.
%
%   Ordenados son los conceptos de Cs, sin variantes repetidas, en el
%   orden estándar. Sirve para comparar dos listas de conceptos con =@=.
conjunto(Cs, Ordenados) :-
    maplist(copy_term, Cs, Copias),
    maplist(numerado, Copias, Numerados),
    sort(Numerados, Unicos),
    maplist(desnumerado, Unicos, Ordenados).

%!  numerado(+C, -N) is det.
%
%   N es C con sus variables reemplazadas por términos '$VAR'(K).
numerado(C, C) :-
    numbervars(C, 0, _).

%!  desnumerado(+N, -C) is det.
%
%   C es N con cada término '$VAR'(K) reemplazado por una variable nueva.
desnumerado(N, C) :-
    varnumbers(N, C).
