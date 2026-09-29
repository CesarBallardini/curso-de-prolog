:- encoding(utf8).

% Capítulo 61 - Los programas que ejecuta la máquina, y lo que la máquina
% sabe del lenguaje objeto.
%
% Un programa objeto es una lista de cláusulas escritas como términos de
% Prolog: un hecho es su cabeza, y una regla, Cabeza :- Cuerpo.
% programa/2 los entrega con la forma Cabeza :- Cuerpo en todos los casos.
% clase/2 dice qué clase de meta es un término, y ejecutar/1 ejecuta los
% predicados predefinidos, que la máquina no define con cláusulas.
% respuestas_nativas/3 ejecuta un programa con el propio Prolog, en un
% módulo temporal: es la referencia con que las pruebas comparan cada
% versión de la máquina.
%
% solo-local: respuestas_nativas/3 crea un módulo temporal.
%
%?- programa(familia, Cs), length(Cs, N).
%?- respuestas_nativas(familia, antepasado(juan, D), Ds).
%?- respuestas_nativas(maximo, maximo(4, 3, M), Ms).

:- module(programas,
          [ programa/2,
            clase/2,
            predefinida/1,
            ejecutar/1,
            respuestas_nativas/3
          ]).

:- use_module(library(apply)).
:- use_module(library(error)).
:- use_module(library(lists)).
:- use_module(library(modules)).

% objeto(Nombre, Clausulas): el programa objeto Nombre, como una lista de
% cláusulas.
objeto(familia,
       [ padre(juan, ana),
         padre(juan, pedro),
         padre(ana, luis),
         padre(luis, eva),
         (abuelo(A, N) :- padre(A, P), padre(P, N)),
         (antepasado(A, D) :- padre(A, D)),
         (antepasado(A, D) :- padre(A, H), antepasado(H, D))
       ]).
objeto(listas,
       [ concatenar([], L, L),
         (concatenar([X|Xs], L, [X|Ys]) :- concatenar(Xs, L, Ys)),
         (invertir([], [])),
         (invertir([X|Xs], R) :- invertir(Xs, R0), concatenar(R0, [X], R)),
         (lista_hasta(N, L) :- desde(N, [], L)),
         desde(0, L, L),
         (desde(N, L0, L) :- N > 0, N1 is N - 1, desde(N1, [N|L0], L)),
         (suma(Xs, S) :- suma(Xs, 0, S)),
         (suma([X|Xs], S0, S) :- S1 is S0 + X, suma(Xs, S1, S)),
         suma([], S, S),
         longitud([], 0),
         (longitud([_|Xs], N) :- longitud(Xs, N0), N is N0 + 1),
         (suma_hasta(N, S) :- lista_hasta(N, L), suma(L, S)),
         (longitud_hasta(N, K) :- lista_hasta(N, L), longitud(L, K)),
         (invertir_hasta(N, R) :- lista_hasta(N, L), invertir(L, R))
       ]).
objeto(maximo,
       [ (maximo(X, Y, X) :- X >= Y, !),
         maximo(_, Y, Y)
       ]).
objeto(corte,
       [ (suma(Xs, S) :- suma(Xs, 0, S)),
         (suma([X|Xs], S0, S) :- !, S1 is S0 + X, suma(Xs, S1, S)),
         suma([], S, S),
         (suma_hasta(N, S) :- desde(N, [], L), suma(L, S)),
         (desde(N, L0, L) :- N > 0, !, N1 is N - 1, desde(N1, [N|L0], L)),
         desde(0, L, L),
         (primero(X, L) :- concatenar(_, [X|_], L), !),
         concatenar([], L, L),
         (concatenar([X|Xs], L, [X|Ys]) :- concatenar(Xs, L, Ys))
       ]).

%!  programa(?Nombre:atom, -Clausulas:list) is nondet.
%
%   Clausulas son las cláusulas del programa objeto Nombre, en orden, todas
%   con la forma Cabeza :- Cuerpo; un hecho tiene el cuerpo true.
programa(Nombre, Clausulas) :-
    objeto(Nombre, Clausulas0),
    maplist(regla, Clausulas0, Clausulas).

%!  regla(+Clausula0, -Clausula) is det.
%
%   Clausula es Clausula0 escrita como Cabeza :- Cuerpo.
regla(Clausula0, Clausula) :-
    (   Clausula0 = (_ :- _)
    ->  Clausula = Clausula0
    ;   Clausula = (Clausula0 :- true)
    ).

%!  clase(+Meta, -Clase) is det.
%
%   Clase describe la meta Meta con un functor por cada clase: verdad,
%   conjuncion(A, B), corte, predefinida(Meta) o usuario(Meta). Una meta
%   que es una variable produce un error de instanciación.
clase(Meta, Clase) :-
    (   var(Meta)
    ->  instantiation_error(Meta)
    ;   Meta == true
    ->  Clase = verdad
    ;   Meta = (A, B)
    ->  Clase = conjuncion(A, B)
    ;   Meta == !
    ->  Clase = corte
    ;   predefinida(Meta)
    ->  Clase = predefinida(Meta)
    ;   Clase = usuario(Meta)
    ).

% predefinida(Meta): Meta es una meta de un predicado predefinido.
predefinida(_ = _).
predefinida(_ is _).
predefinida(_ < _).
predefinida(_ > _).
predefinida(_ =< _).
predefinida(_ >= _).
predefinida(_ =:= _).
predefinida(_ =\= _).
predefinida(fail).

%!  ejecutar(+Meta) is semidet.
%
%   Ejecuta con Prolog la meta predefinida Meta.
ejecutar(X = Y) :-
    X = Y.
ejecutar(X is E) :-
    X is E.
ejecutar(X < Y) :-
    X < Y.
ejecutar(X > Y) :-
    X > Y.
ejecutar(X =< Y) :-
    X =< Y.
ejecutar(X >= Y) :-
    X >= Y.
ejecutar(X =:= Y) :-
    X =:= Y.
ejecutar(X =\= Y) :-
    X =\= Y.
ejecutar(fail) :-
    fail.

%!  respuestas_nativas(+Nombre:atom, +Meta, -Respuestas:list) is det.
%
%   Respuestas son las instancias de Meta que Prolog obtiene, en orden, al
%   ejecutar Meta con las cláusulas del programa objeto Nombre cargadas en
%   un módulo temporal.
respuestas_nativas(Nombre, Meta, Respuestas) :-
    programa(Nombre, Clausulas),
    in_temporary_module(Modulo,
                        cargar(Modulo, Clausulas),
                        findall(Meta, Modulo:Meta, Respuestas)).

%!  cargar(+Modulo:atom, +Clausulas:list) is det.
%
%   Agrega las Clausulas al Modulo.
cargar(Modulo, Clausulas) :-
    forall(member(Clausula, Clausulas), assertz(Modulo:Clausula)).
