:- encoding(utf8).

% Capítulo 85 - Las tablas del capítulo 39 y los hechos mágicos.
%
% El ejemplo es el de Warren: debe(X, Y), X le debe dinero a Y, y evita/2,
% su clausura transitiva, sobre un ciclo de N personas, 1 debe a 2, 2 a 3,
% y N a 1. evita_izq/2 tiene la recursión a la izquierda y evita_der/2 a
% la derecha; las dos están tabuladas. tablas/3 cuenta las tablas que
% crea una consulta y las respuestas que guardan; magia/4 cuenta, para la
% misma consulta sobre el mismo programa escrito como datos, los hechos
% mágicos y los átomos adornados que deriva la evaluación del programa
% transformado. Las dos cuentas coinciden.
%
% solo-local: es un módulo que carga otros.
%
%?- tablas(evita_izq(1, _), T, R).
%?- programa(izq, 100, Cs), magia(Cs, evita(1, _), M, A).

:- module(tablas,
          [ debe/2,
            evita_izq/2,
            evita_der/2,
            tablas/3,
            programa/3,
            magia/4
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).
:- use_module(magia).
:- use_module(estratos).

%!  debe(?X, ?Y) is nondet.
%
%   En el ciclo de 100 personas, X le debe dinero a Y: cada una a la
%   siguiente, y la 100 a la 1.
debe(X, Y) :-
    between(1, 100, X),
    Y is X mod 100 + 1.

:- meta_predicate tablas(0, -, -).

:- table evita_izq/2, evita_der/2.

%!  evita_izq(?X, ?Y) is nondet.
%
%   X evita a Y: le debe dinero, o evita a alguien que le debe. Recursión
%   a la izquierda, tabulada.
evita_izq(X, Y) :-
    debe(X, Y).
evita_izq(X, Y) :-
    evita_izq(X, Z),
    debe(Z, Y).

%!  evita_der(?X, ?Y) is nondet.
%
%   Como evita_izq/2, con la recursión a la derecha.
evita_der(X, Y) :-
    debe(X, Y).
evita_der(X, Y) :-
    debe(X, Z),
    evita_der(Z, Y).

%!  tablas(:Meta, -Tablas:integer, -Respuestas:integer) is det.
%
%   Después de borrar todas las tablas y resolver Meta, Tablas es la
%   cantidad de tablas de su predicado, una por cada variante llamada, y
%   Respuestas, la suma de las respuestas que guardan. Las tablas están en
%   el módulo que define el predicado de Meta.
tablas(Meta, Tablas, Respuestas) :-
    abolish_all_tables,
    forall(call(Meta), true),
    strip_module(Meta, Llamador, Meta1),
    (   predicate_property(Llamador:Meta1, imported_from(Modulo))
    ->  true
    ;   Modulo = Llamador
    ),
    functor(Meta1, Nombre, Aridad),
    functor(Patron, Nombre, Aridad),
    findall(V, ( current_table(Modulo:V, _), V = Patron ), Vs),
    length(Vs, Tablas),
    aggregate_all(count, ( member(V, Vs), call(Modulo:V) ), Respuestas).

%!  programa(+Recursion, +N:integer, -Clausulas:list) is det.
%
%   Clausulas son los hechos debe/2 del ciclo de N personas y evita/2 con
%   la Recursion izq o der, como datos.
programa(Recursion, N, Clausulas) :-
    must_be(oneof([izq, der]), Recursion),
    findall((debe(X, Y) :- true),
            ( between(1, N, X), Y is X mod N + 1 ),
            Hechos),
    reglas(Recursion, Reglas),
    append(Hechos, Reglas, Clausulas).

%!  reglas(+Recursion, -Reglas:list) is det.
%
%   Las dos reglas de evita/2, con la recursión a la izquierda o a la
%   derecha.
reglas(izq, [ (evita(X, Y) :- debe(X, Y)),
              (evita(X, Y) :- evita(X, Z), debe(Z, Y)) ]).
reglas(der, [ (evita(X, Y) :- debe(X, Y)),
              (evita(X, Y) :- debe(X, Z), evita(Z, Y)) ]).

%!  magia(+Clausulas:list, +Meta, -Magicos:integer, -Adornados:integer)
%!      is det.
%
%   Magicos y Adornados son las cantidades de átomos de predicados mágicos
%   (m_…) y de predicados adornados del predicado de Meta en el modelo del
%   programa que magico/3 transforma para Meta.
magia(Clausulas, Meta, Magicos, Adornados) :-
    magico(Clausulas, Meta, Programa),
    evaluar(Programa, Modelo, _),
    functor(Meta, Nombre, _),
    atom_concat(Nombre, '_', Prefijo),
    aggregate_all(count,
                  ( member(A, Modelo), functor(A, F, _),
                    sub_atom(F, 0, _, _, m_) ),
                  Magicos),
    aggregate_all(count,
                  ( member(A, Modelo), functor(A, F, _),
                    sub_atom(F, 0, _, _, Prefijo) ),
                  Adornados).
