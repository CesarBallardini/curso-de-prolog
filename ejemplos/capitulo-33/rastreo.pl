:- encoding(utf8).

% Capítulo 33 - Un rastreador escrito en Prolog: el intérprete escribe los
% cuatro puertos del modelo de cajas de cada objetivo.
%
% entrar/2 escribe Call al entrar y Fail cuando se vuelve atrás sin más
% alternativas; salir/2 escribe Exit al salir y Redo cuando se vuelve atrás
% a buscar otra respuesta. Las variables se escriben con nombres A, B…
%
%?- rastrear(abuelo(juan, N)).

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

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

%!  rastrear(+Meta) is nondet.
%
%   Meta se prueba como con resolver/1, y se escribe cada puerto de cada
%   objetivo, con su nivel de profundidad.
rastrear(Meta) :-
    rastro(prog(Meta), 1).

%!  rastro(+Cuerpo, +Nivel:integer) is nondet.
%
%   Cuerpo se prueba, y sus objetivos se escriben en el nivel Nivel.
rastro(true, _).
rastro((A, B), Nivel) :-
    rastro(A, Nivel),
    rastro(B, Nivel).
rastro(sis(G), Nivel) :-
    entrar(G, Nivel),
    ejecutar(G),
    salir(G, Nivel).
rastro(prog(G), Nivel) :-
    entrar(G, Nivel),
    Siguiente is Nivel + 1,
    clausula(G, Cuerpo),
    rastro(Cuerpo, Siguiente),
    salir(G, Nivel).

%!  entrar(+G, +Nivel:integer) is det.
%
%   Escribe el puerto Call de G. Al volver atrás hasta aquí, G no tiene más
%   respuestas: escribe el puerto Fail y falla.
entrar(G, Nivel) :-
    puerto('Call', G, Nivel).
entrar(G, Nivel) :-
    puerto('Fail', G, Nivel),
    fail.

%!  salir(+G, +Nivel:integer) is det.
%
%   Escribe el puerto Exit de G. Al volver atrás hasta aquí, se busca otra
%   respuesta de G: escribe el puerto Redo y falla.
salir(G, Nivel) :-
    puerto('Exit', G, Nivel).
salir(G, Nivel) :-
    puerto('Redo', G, Nivel),
    fail.

%!  puerto(+Puerto, +G, +Nivel:integer) is det.
%
%   Escribe una línea del rastro, con las variables de G nombradas A, B…
%   sin ligarlas.
puerto(Puerto, G, Nivel) :-
    \+ \+ ( numbervars(G, 0, _),
            format("~w: (~d) ~W~n",
                   [Puerto, Nivel, G, [quoted(true), numbervars(true),
                                       spacing(next_argument)]]) ).
