:- encoding(utf8).

% Capítulo 35 - Evaluación parcial: el intérprete con árboles de prueba del
% capítulo 33, especializado para un programa.
%
% resolver/2 y pruebas//1 son los de arbol.pl del capítulo 33: prueban un
% objetivo y construyen su árbol de prueba. especializar/2 evalúa
% parcialmente pruebas//1 sobre el cuerpo conocido de una cláusula del
% programa, con parcial/3 de parcial.pl: el resultado es una cláusula que
% construye el mismo árbol sin intérprete, con un argumento más para la
% prueba. instalar/1 agrega las cláusulas especializadas de los predicados
% indicados al módulo esp; el archivo lo hace al cargarse, con todo el
% programa.
%
% solo-local: carga parcial.pl con ensure_loaded/1 y agrega reglas con
% assertz/1, y SWISH no permite ninguna de las dos cosas.
%
%?- especializar((antepasado(A, D) :- padre(A, H), antepasado(H, D)), C).
%?- esp:antepasado(juan, luis, P).
%?- resolver(antepasado(juan, luis), P).

:- ensure_loaded(parcial).

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

%!  longitud(+Lista:list, -N:integer) is det.
%
%   N es la cantidad de elementos de Lista.
longitud([], 0).
longitud([_|Xs], N) :-
    longitud(Xs, N0),
    N is N0 + 1.

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

%!  especializar(+Clausula, -Especializada) is nondet.
%
%   Especializada es Clausula con la prueba como último argumento de la
%   cabeza, y como cuerpo el residuo de pruebas//1 sobre su cuerpo.
especializar((Cabeza :- Cuerpo0), (Cabeza1 :- Residuo)) :-
    limpiar(Cuerpo0, Cuerpo),
    con_prueba(Cabeza, prueba(Cabeza, Hijos), Cabeza1),
    parcial(pruebas(Cuerpo, Hijos, []), control, Residuo).

%!  control(+Meta, -Accion) is semidet.
%
%   Se despliegan pruebas//1 y ejecutar/1; la prueba de un objetivo del
%   programa queda como llamada a su versión especializada.
control(pruebas(prog(G), S0, S), dejar(Llamada)) :-
    S0 = [Prueba|S],
    con_prueba(G, Prueba, Llamada).
control(pruebas(Cuerpo, _, _), desplegar) :-
    Cuerpo \= prog(_).
control(ejecutar(_), desplegar).

%!  con_prueba(+Meta, ?Prueba, -Meta1) is det.
%
%   Meta1 es Meta con Prueba como último argumento.
con_prueba(Meta, Prueba, Meta1) :-
    Meta =.. Lista0,
    append(Lista0, [Prueba], Lista),
    Meta1 =.. Lista.

%!  instalar(+Predicados:list) is det.
%
%   Agrega al módulo esp, en lugar de las que tuviera, las cláusulas
%   especializadas de los predicados Nombre/Aridad de Predicados.
instalar(Predicados) :-
    forall(member(Nombre/Aridad, Predicados),
           instalar(Nombre, Aridad)).

%!  instalar(+Nombre, +Aridad:integer) is det.
%
%   Agrega al módulo esp las cláusulas especializadas de Nombre/Aridad.
instalar(Nombre, Aridad) :-
    Aridad1 is Aridad + 1,
    functor(Especializada, Nombre, Aridad1),
    retractall(esp:Especializada),
    functor(Meta, Nombre, Aridad),
    forall(( clause(Meta, Cuerpo),
             especializar((Meta :- Cuerpo), Clausula) ),
           assertz(esp:Clausula)).

% Al cargar el archivo, el módulo esp recibe la versión especializada de
% todo el programa.
:- instalar([padre/2, edad/2, antepasado/2, mayor_que/2, longitud/2]).
