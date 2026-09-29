:- encoding(utf8).

% Capítulo 65 - Versión 4: por qué sí y por qué no.
%
% derivacion/3 es derivable/2 con un argumento más: el árbol de la
% derivación, como los árboles de prueba del capítulo 33. Cada nodo dice
% con qué regla se concluyó su literal; supuestos/2 junta las reglas
% rebatibles y las presunciones del árbol, lo que la conclusión da por
% supuesto. por_que_no/3 responde lo que derivable/2 calla: qué reglas
% tenía la meta con el cuerpo derivable, y qué rivales las derrotaron.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- derivacion([especificidad], vuela(tweety), A).
%?- por_que_no([especificidad], vuela(opus), M).

:- module(explicaciones,
          [ derivacion/3,
            supuestos/2,
            por_que_no/3
          ]).

:- use_module(library(error)).
:- use_module(library(lists)).
:- reexport(rebatible).

%!  derivacion(+Criterio:list, +Meta, -Arbol) is nondet.
%
%   Arbol es una derivación rebatible de Meta: estricta(Literal) si el
%   literal se deriva con las reglas estrictas, predefinido(Literal) si es
%   un predicado del sistema, y regla(Regla, Arboles) si se concluye con
%   Regla, estricta o rebatible, sin rivales, y Arboles derivan su cuerpo.
derivacion(Criterio, Meta, Arbol) :-
    must_be(list(oneof([especificidad, declarada, anticipacion])), Criterio),
    must_be(callable, Meta),
    arbol(Criterio, Meta, Arbol).

%!  arbol(+Criterio:list, +Meta, -Arbol) is nondet.
%
%   Arbol deriva Meta, un literal, en la raíz de la base.
arbol(_, Meta, predefinido(Meta)) :-
    predefinido(Meta),
    !,
    call(user:Meta).
arbol(_, Meta, estricta(Meta)) :-
    estricto(Meta).
arbol(Cr, Meta, regla((Meta :- Cuerpo), Arboles)) :-
    regla_estricta(Meta, Cuerpo),
    arboles(Cr, Cuerpo, Arboles),
    \+ rival(Cr, raiz, (Meta :- Cuerpo), _).
arbol(Cr, Meta, regla((Meta :~ Cuerpo), Arboles)) :-
    regla_rebatible(raiz, Meta, Cuerpo),
    arboles(Cr, Cuerpo, Arboles),
    \+ rival(Cr, raiz, (Meta :~ Cuerpo), _).

%!  arboles(+Criterio:list, +Cuerpo, -Arboles:list) is nondet.
%
%   Arboles son las derivaciones de los literales de Cuerpo, en orden; el
%   cuerpo true no necesita ninguna.
arboles(_, true, []) :-
    !.
arboles(Cr, (A, B), [Arbol|Arboles]) :-
    !,
    arbol(Cr, A, Arbol),
    arboles(Cr, B, Arboles).
arboles(Cr, Meta, [Arbol]) :-
    arbol(Cr, Meta, Arbol).

%!  supuestos(+Arbol, -Reglas:list) is det.
%
%   Reglas son las reglas rebatibles y las presunciones que usa Arbol, en
%   el orden en que aparecen y sin repetidos.
supuestos(Arbol, Reglas) :-
    phrase(rebatibles(Arbol), Todas),
    list_to_set(Todas, Reglas).

%!  rebatibles(+Arbol)// is det.
%
%   Las reglas rebatibles de Arbol, de la raíz a las hojas.
rebatibles(predefinido(_)) -->
    [].
rebatibles(estricta(_)) -->
    [].
rebatibles(regla(Regla, Arboles)) -->
    (   { Regla = (_ :~ _) }
    ->  [Regla]
    ;   []
    ),
    lista_rebatibles(Arboles).

%!  lista_rebatibles(+Arboles:list)// is det.
%
%   Las reglas rebatibles de cada árbol de Arboles.
lista_rebatibles([]) -->
    [].
lista_rebatibles([Arbol|Arboles]) -->
    rebatibles(Arbol),
    lista_rebatibles(Arboles).

%!  por_que_no(+Criterio:list, +Meta, -Motivos:list) is det.
%
%   Motivos son los términos derrotada(Regla, Rivales): cada regla,
%   estricta o rebatible, de cabeza Meta y cuerpo derivable, con los
%   rivales que la derrotan. Una lista vacía dice que ninguna regla de
%   Meta tiene el cuerpo derivable. Meta no tiene variables.
por_que_no(Criterio, Meta, Motivos) :-
    must_be(list(oneof([especificidad, declarada, anticipacion])), Criterio),
    must_be(ground, Meta),
    findall(derrotada(Regla, Rivales),
            ( aplicable(Criterio, Meta, Regla),
              findall(Rival, rival(Criterio, raiz, Regla, Rival), Rivales0),
              sort(Rivales0, Rivales),
              Rivales \== []
            ),
            Motivos0),
    sort(Motivos0, Motivos).

%!  aplicable(+Criterio:list, +Meta, -Regla) is nondet.
%
%   Regla es una regla de cabeza Meta cuyo cuerpo se deriva.
aplicable(Cr, Meta, (Meta :- Cuerpo)) :-
    regla_estricta(Meta, Cuerpo),
    once(derivable(Cr, Cuerpo)).
aplicable(Cr, Meta, (Meta :~ Cuerpo)) :-
    regla_rebatible(raiz, Meta, Cuerpo),
    once(derivable(Cr, Cuerpo)).
