:- encoding(utf8).

% Capítulo 68 - Versión 5: explicar un ejemplo con la teoría del dominio.
%
% explicar/4 es un metaintérprete con árbol de prueba, como el del
% capítulo 33, que prueba un objetivo con una teoría y la descripción de
% un ejemplo. Un objetivo predefinido se ejecuta; uno operacional se busca
% entre los hechos de la descripción; cualquier otro se prueba con las
% reglas de la teoría. El árbol usa la representación del capítulo 33,
% prueba(G, Hijos) y sis(G), y se escribe con su mostrar/1: el archivo
% arbol.pl de ese capítulo se carga en el módulo arbol33.
%
% solo-local: carga archivos de otros capítulos.
%
%?- como(taza, taza1, taza(taza1)).
%?- clasificar_con_teoria(taza, Tazas).

:- module(explicacion,
          [ explicar/4,
            como/3,
            operacional/2,
            predefinido/1,
            ejecutar/1,
            clasificar_con_teoria/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(teorias).
:- load_files(arbol33:'../capitulo-33/arbol', []).

%!  explicar(+T, +Hs:list, +Meta, -Arbol) is nondet.
%
%   Meta se prueba con la teoría T y los hechos Hs, y Arbol es la prueba:
%   una respuesta por cada prueba.
explicar(T, Hs, Meta, Arbol) :-
    phrase(prueba(T, Hs, Meta), [Arbol]).

%!  prueba(+T, +Hs:list, +G)// is nondet.
%
%   La lista tiene un elemento, la prueba del objetivo G: sis(G) si es
%   predefinido, prueba(G, []) si es operacional y está en Hs, y
%   prueba(G, Hijos) si se prueba con una regla de T.
prueba(T, Hs, G) -->
    (   { predefinido(G) }
    ->  { ejecutar(G) },
        [sis(G)]
    ;   { operacional(T, G) }
    ->  { member(G, Hs) },
        [prueba(G, [])]
    ;   { regla(T, R),
          copy_term(R, (G :- Cuerpo)),
          phrase(pruebas(T, Hs, Cuerpo), Hijos) },
        [prueba(G, Hijos)]
    ).

%!  pruebas(+T, +Hs:list, +Cuerpo)// is nondet.
%
%   La lista tiene las pruebas de los objetivos de Cuerpo, una conjunción,
%   de izquierda a derecha.
pruebas(T, Hs, Cuerpo) -->
    (   { Cuerpo = (A, B) }
    ->  pruebas(T, Hs, A),
        pruebas(T, Hs, B)
    ;   { Cuerpo == true }
    ->  []
    ;   prueba(T, Hs, Cuerpo)
    ).

%!  operacional(+T, @G) is semidet.
%
%   El predicado del objetivo G es operacional en la teoría T.
operacional(T, G) :-
    operacionales(T, Ps),
    functor(G, Nombre, Aridad),
    memberchk(Nombre/Aridad, Ps).

% predefinido(G): el intérprete ejecuta G con ejecutar/1.
predefinido(_ < _).
predefinido(_ > _).
predefinido(_ =< _).
predefinido(_ >= _).

%!  ejecutar(+G) is semidet.
%
%   Ejecuta la comparación predefinida G.
ejecutar(X < Y) :-
    X < Y.
ejecutar(X > Y) :-
    X > Y.
ejecutar(X =< Y) :-
    X =< Y.
ejecutar(X >= Y) :-
    X >= Y.

%!  como(+T, +E, +Meta) is nondet.
%
%   Escribe una prueba de Meta con la teoría T y la descripción del
%   ejemplo E: una respuesta por cada prueba.
como(T, E, Meta) :-
    hechos(E, Hs),
    explicar(T, Hs, Meta, Arbol),
    arbol33:mostrar(Arbol).

%!  clasificar_con_teoria(+T, -Tazas:list) is det.
%
%   Tazas son los objetos de la población que la teoría T reconoce como
%   tazas.
clasificar_con_teoria(T, Tazas) :-
    poblacion(Os),
    findall(O, ( member(O-Hs, Os),
                 once(explicar(T, Hs, taza(O), _)) ), Tazas).
