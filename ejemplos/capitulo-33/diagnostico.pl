:- encoding(utf8).

% Capítulo 33 - Depuración algorítmica: el intérprete busca la cláusula
% responsable de una respuesta incorrecta y el objetivo responsable de una
% respuesta que falta.
%
% El oráculo, pretendido/1, dice qué objetivos son verdaderos en el
% significado que el programa debería tener. respuesta_incorrecta/2 recorre
% el árbol de una prueba hasta una cláusula falsa: su cabeza es falsa y los
% objetivos de su cuerpo, verdaderos. respuesta_faltante/2 baja por
% objetivos verdaderos que el programa no prueba, hasta uno que ninguna
% cláusula cubre.
%
%?- respuesta_incorrecta(ordenar_incorrecto([3, 1, 2], S), Clausula).
%?- respuesta_faltante(ordenar_incompleto([2, 1], S), Objetivo).

%!  ordenar_incorrecto(+Lista:list, -Ordenada:list) is det.
%
%   Debería ser: Ordenada tiene los elementos de Lista en orden ascendente.
%   El error está en insertar_incorrecto/3.
ordenar_incorrecto([], []).
ordenar_incorrecto([X|Xs], Ys) :-
    ordenar_incorrecto(Xs, Zs),
    insertar_incorrecto(X, Zs, Ys).

%!  insertar_incorrecto(+X, +Ordenada0:list, -Ordenada:list) is det.
%
%   Debería ser: Ordenada es Ordenada0 con X en su lugar. El error: la
%   tercera cláusula pierde el primer elemento de Ordenada0.
insertar_incorrecto(X, [], [X]).
insertar_incorrecto(X, [Y|Ys], [Y|Zs]) :-
    Y < X,
    insertar_incorrecto(X, Ys, Zs).
insertar_incorrecto(X, [Y|Ys], [X|Ys]) :-
    X =< Y.

%!  ordenar_incompleto(+Lista:list, -Ordenada:list) is semidet.
%
%   Debería ser: Ordenada tiene los elementos de Lista en orden ascendente.
%   El error está en insertar_incompleto/3.
ordenar_incompleto([], []).
ordenar_incompleto([X|Xs], Ys) :-
    ordenar_incompleto(Xs, Zs),
    insertar_incompleto(X, Zs, Ys).

%!  insertar_incompleto(+X, +Ordenada0:list, -Ordenada:list) is semidet.
%
%   Debería ser: Ordenada es Ordenada0 con X en su lugar. El error: falta
%   la cláusula de la lista vacía.
insertar_incompleto(X, [Y|Ys], [Y|Zs]) :-
    Y < X,
    insertar_incompleto(X, Ys, Zs).
insertar_incompleto(X, [Y|Ys], [X, Y|Ys]) :-
    X =< Y.

%!  pretendido(+Meta) is semidet.
%
%   Meta es verdadero en el significado que el programa debería tener: el
%   oráculo. Con la lista ordenada libre, la liga a la respuesta correcta.
pretendido(ordenar_incorrecto(Xs, Ys)) :-
    msort(Xs, Ys).
pretendido(insertar_incorrecto(X, Xs, Ys)) :-
    msort([X|Xs], Ys).
pretendido(ordenar_incompleto(Xs, Ys)) :-
    msort(Xs, Ys).
pretendido(insertar_incompleto(X, Xs, Ys)) :-
    msort([X|Xs], Ys).

% predefinido(G): el intérprete ejecuta G con ejecutar/1.
predefinido(_ < _).
predefinido(_ =< _).

%!  ejecutar(+G) is semidet.
%
%   Ejecuta el objetivo predefinido G.
ejecutar(X < Y) :-
    X < Y.
ejecutar(X =< Y) :-
    X =< Y.

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
%   Meta se prueba, y Arbol es la prueba, como en arbol.pl.
resolver(Meta, Arbol) :-
    phrase(pruebas(prog(Meta)), [Arbol]).

%!  pruebas(+Cuerpo)// is nondet.
%
%   Cuerpo se prueba, y la lista describe las pruebas de sus objetivos.
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

%!  respuesta_incorrecta(+Meta, -Clausula) is nondet.
%
%   Meta se prueba con una respuesta que el oráculo rechaza, y Clausula es
%   una instancia falsa de una cláusula del programa: una por cada
%   respuesta incorrecta.
respuesta_incorrecta(Meta, Clausula) :-
    resolver(Meta, Arbol),
    \+ pretendido(Meta),
    clausula_falsa(Arbol, Clausula).

%!  clausula_falsa(+Arbol, -Clausula) is det.
%
%   La raíz de Arbol es falsa según el oráculo. Si algún hijo también lo
%   es, la cláusula falsa está debajo de él; si no, es la de la raíz.
clausula_falsa(prueba(G, Hijos), Clausula) :-
    (   member(prueba(H, Nietos), Hijos),
        \+ pretendido(H)
    ->  clausula_falsa(prueba(H, Nietos), Clausula)
    ;   maplist(objetivo, Hijos, Objetivos),
        conjuncion(Objetivos, Cuerpo),
        Clausula = (G :- Cuerpo)
    ).

%!  objetivo(+Arbol, -G) is det.
%
%   G es el objetivo que prueba Arbol.
objetivo(prueba(G, _), G).
objetivo(sis(G), G).

%!  conjuncion(+Objetivos:list, -Cuerpo) is det.
%
%   Cuerpo es la conjunción de Objetivos; true si no hay ninguno.
conjuncion([], true).
conjuncion([G], G) :-
    !.
conjuncion([G|Gs], (G, Cuerpo)) :-
    conjuncion(Gs, Cuerpo).

%!  respuesta_faltante(+Meta, -Objetivo) is semidet.
%
%   Meta es verdadero según el oráculo, que liga sus salidas, y el programa
%   no lo prueba. Objetivo es un objetivo verdadero que ninguna cláusula
%   cubre: la cláusula que falta, o que está mal escrita, es la suya.
respuesta_faltante(Meta, Objetivo) :-
    pretendido(Meta),
    \+ resolver(Meta, _),
    no_cubierto(Meta, Objetivo).

%!  no_cubierto(+Meta, -Objetivo) is det.
%
%   Meta es verdadero y el programa no lo prueba. Si una cláusula tiene el
%   cuerpo verdadero, alguno de sus objetivos no se prueba, y la búsqueda
%   sigue por él; si ninguna lo tiene, el objetivo es Meta.
no_cubierto(Meta, Objetivo) :-
    (   clausula(Meta, Cuerpo),
        cuerpo_pretendido(Cuerpo),
        no_probado(Cuerpo, G)
    ->  no_cubierto(G, Objetivo)
    ;   Objetivo = Meta
    ).

%!  cuerpo_pretendido(+Cuerpo) is nondet.
%
%   Cuerpo es verdadero según el oráculo, que liga sus variables.
cuerpo_pretendido(true).
cuerpo_pretendido((A, B)) :-
    cuerpo_pretendido(A),
    cuerpo_pretendido(B).
cuerpo_pretendido(sis(G)) :-
    ejecutar(G).
cuerpo_pretendido(prog(G)) :-
    pretendido(G).

%!  no_probado(+Cuerpo, -G) is semidet.
%
%   G es el primer objetivo del programa en Cuerpo que el programa no
%   prueba.
no_probado((A, B), G) :-
    (   no_probado(A, G)
    ->  true
    ;   no_probado(B, G)
    ).
no_probado(prog(G), G) :-
    \+ resolver(G, _).
