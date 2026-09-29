:- encoding(utf8).

% Capítulo 33 - Árboles de prueba: el intérprete devuelve, además de la
% respuesta, la prueba que la justifica.
%
% resolver/2 construye el árbol con una gramática sobre el cuerpo de cada
% cláusula: prueba(G, Hijos) para un objetivo del programa, con las pruebas
% de los objetivos del cuerpo, y sis(G) para un predefinido. mostrar/1
% escribe el árbol con cada nivel sangrado dos columnas, y como/1 escribe
% cada prueba de un objetivo.
%
%?- resolver(antepasado(juan, luis), Arbol).
%?- como(mayor_que(juan, P)).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(ana, luis).
padre(luis, eva).

% edad(P, E): P tiene E años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 37).

%!  antepasado(?A, ?D) is nondet.
%
%   A es un antepasado de D: su padre, o un antepasado de su padre.
antepasado(A, D) :-
    padre(A, D).
antepasado(A, D) :-
    padre(A, H),
    antepasado(H, D).

%!  mayor_que(?A, ?B) is nondet.
%
%   A tiene más años que B.
mayor_que(A, B) :-
    edad(A, EA),
    edad(B, EB),
    EA > EB.

% predefinido(G): el intérprete ejecuta G con ejecutar/1.
predefinido(_ = _).
predefinido(_ is _).
predefinido(_ < _).
predefinido(_ > _).

%!  ejecutar(+G) is semidet.
%
%   Ejecuta el objetivo predefinido G.
ejecutar(X = Y) :-
    X = Y.
ejecutar(X is E) :-
    X is E.
ejecutar(X < Y) :-
    X < Y.
ejecutar(X > Y) :-
    X > Y.

%!  clausula(+Meta, -Cuerpo) is nondet.
%
%   Meta :- Cuerpo es una cláusula del programa, con el cuerpo en la
%   representación limpia: true, (A, B), prog(G) o sis(G).
clausula(Meta, Cuerpo) :-
    clause(Meta, Cuerpo0),
    limpiar(Cuerpo0, Cuerpo).

%!  limpiar(+Cuerpo0, -Cuerpo) is det.
%
%   Cuerpo es el cuerpo Cuerpo0 con cada objetivo marcado.
limpiar(true, true) :-
    !.
limpiar((A0, B0), (A, B)) :-
    !,
    limpiar(A0, A),
    limpiar(B0, B).
limpiar(G, sis(G)) :-
    predefinido(G),
    !.
limpiar(G, prog(G)).

%!  resolver(+Meta, -Arbol) is nondet.
%
%   Meta, un objetivo del programa, se prueba con sus cláusulas, y Arbol es
%   la prueba: una respuesta por cada prueba.
resolver(Meta, Arbol) :-
    phrase(pruebas(prog(Meta)), [Arbol]).

%!  pruebas(+Cuerpo)// is nondet.
%
%   Cuerpo se prueba, y la lista describe las pruebas de sus objetivos, de
%   izquierda a derecha: prueba(G, Hijos) para un objetivo del programa,
%   sis(G) para un predefinido.
pruebas(true) -->
    [].
pruebas((A, B)) -->
    pruebas(A),
    pruebas(B).
pruebas(sis(G)) -->
    { ejecutar(G) },
    [sis(G)].
pruebas(prog(G)) -->
    { clausula(G, Cuerpo),
      phrase(pruebas(Cuerpo), Hijos) },
    [prueba(G, Hijos)].

%!  como(+Meta) is nondet.
%
%   Meta se prueba, y se escribe su prueba: una respuesta por cada prueba.
como(Meta) :-
    resolver(Meta, Arbol),
    mostrar(Arbol).

%!  mostrar(+Arbol) is det.
%
%   Escribe Arbol, un objetivo por línea, con los hijos de cada nodo dos
%   columnas más adentro.
mostrar(Arbol) :-
    mostrar(Arbol, 0).

%!  mostrar(+Arbol, +Sangria:integer) is det.
%
%   Escribe Arbol a partir de la columna Sangria.
mostrar(sis(G), Sangria) :-
    linea(Sangria, G).
mostrar(prueba(G, Hijos), Sangria) :-
    linea(Sangria, G),
    Siguiente is Sangria + 2,
    forall(member(H, Hijos), mostrar(H, Siguiente)).

%!  linea(+Sangria:integer, +G) is det.
%
%   Escribe G en la columna Sangria, con un espacio después de cada coma.
linea(Sangria, G) :-
    format("~t~*|~W~n",
           [Sangria, G, [quoted(true), spacing(next_argument)]]).
