:- encoding(utf8).

% Capítulo 85 - Versión 3: las componentes del grafo de dependencias y la
% negación.
%
% El grafo de dependencias tiene un vértice por cada predicado definido
% por reglas y un arco de P a Q cuando una regla de P usa Q en el cuerpo,
% negado o no. Sus componentes fuertemente conexas, los grupos de
% predicados que dependen unos de otros, se evalúan de a una, cada una
% después de las componentes de las que depende, con bloque/6 de
% motor.pl: una componente sin recursión se resuelve en un solo paso. El
% programa es estratificado si ningún literal negado usa un predicado de
% su misma componente; si no lo es, evaluar/3 produce un error que nombra
% los arcos negados que cierran un ciclo.
%
% solo-local: es un módulo que carga otros.
%
%?- componentes([(p :- q, \+ r), (q :- p), (r :- s)], Cs).
%?- evaluar([(s :- true), (r :- s), (p :- \+ r), (q :- p)], M, C).

:- module(estratos,
          [ dependencias/2,
            componentes/2,
            ciclos_negativos/2,
            evaluar/3,
            evaluar_base/3
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(ordsets)).
:- use_module(library(ugraphs)).
:- use_module(seguro).
:- use_module(motor).

%!  dependencias(+Clausulas:list, -Aristas:list) is det.
%
%   Aristas son los términos P-Q-Signo, ordenados: una regla de P usa en el
%   cuerpo a Q, un predicado definido por reglas, en un literal positivo
%   (Signo pos) o negado (neg).
dependencias(Clausulas, Aristas) :-
    separar(Clausulas, _, Reglas),
    aristas(Reglas, Aristas).

%!  aristas(+Reglas:list, -Aristas:list) is det.
%
%   Aristas, como en dependencias/2, sobre las reglas r(Cabeza, Literales).
aristas(Reglas, Aristas) :-
    definidos(Reglas, Ps),
    findall(P-Q-Signo,
            ( member(r(H, Ls), Reglas),
              predicado(H, P),
              member(L, Ls),
              signo(L, A, Signo),
              predicado(A, Q),
              ord_memberchk(Q, Ps) ),
            Todas),
    sort(Todas, Aristas).

%!  signo(+Literal, -Atomo, -Signo) is semidet.
%
%   Literal es Atomo, con Signo pos, o \+ Atomo, con Signo neg. Falla con
%   una comparación o con is/2.
signo(L, A, Signo) :-
    (   L = (\+ A)
    ->  Signo = neg
    ;   ( L = (_ is _) ; comparacion(L) )
    ->  fail
    ;   A = L,
        Signo = pos
    ).

%!  predicado(+Atomo, -Indicador) is det.
%
%   Indicador es Nombre/Aridad, el predicado de Atomo.
predicado(A, Nombre/Aridad) :-
    functor(A, Nombre, Aridad).

%!  definidos(+Reglas:list, -Ps:list) is det.
%
%   Ps son, ordenados, los predicados de las cabezas de las Reglas.
definidos(Reglas, Ps) :-
    findall(P, ( member(r(H, _), Reglas), predicado(H, P) ), Ps0),
    sort(Ps0, Ps).

%!  componentes(+Clausulas:list, -Componentes:list(list)) is det.
%
%   Componentes son las componentes fuertemente conexas del grafo de
%   dependencias, cada una la lista ordenada de sus predicados, en un orden
%   de evaluación: cada componente está después de aquellas de las que
%   depende.
componentes(Clausulas, Componentes) :-
    separar(Clausulas, _, Reglas),
    componentes_reglas(Reglas, Componentes).

%!  componentes_reglas(+Reglas:list, -Componentes:list(list)) is det.
%
%   Componentes, como en componentes/2, sobre las reglas r(Cabeza,
%   Literales). Dos predicados están en la misma componente si cada uno
%   alcanza al otro en la clausura transitiva del grafo; el grafo de las
%   componentes no tiene ciclos, y top_sort/2 lo ordena.
componentes_reglas(Reglas, Componentes) :-
    definidos(Reglas, Ps),
    aristas(Reglas, Aristas),
    findall(P-Q, member(P-Q-_, Aristas), Arcos),
    vertices_edges_to_ugraph(Ps, Arcos, Grafo),
    transitive_closure(Grafo, Clausura),
    maplist(componente_de(Clausura), Ps, Cs0),
    sort(Cs0, Cs),
    findall(CP-CQ,
            ( member(P-Q, Arcos),
              member(CP, Cs), ord_memberchk(P, CP),
              member(CQ, Cs), ord_memberchk(Q, CQ),
              CP \== CQ ),
            Arcos2),
    vertices_edges_to_ugraph(Cs, Arcos2, Condensado),
    top_sort(Condensado, Orden),
    reverse(Orden, Componentes).

%!  componente_de(+Clausura, +P, -Componente:list) is det.
%
%   Componente son, ordenados, P y los predicados que P alcanza y que lo
%   alcanzan en la Clausura.
componente_de(Clausura, P, Componente) :-
    neighbours(P, Clausura, SP),
    findall(Q,
            ( member(Q, SP),
              neighbours(Q, Clausura, SQ),
              ord_memberchk(P, SQ) ),
            Qs),
    sort([P|Qs], Componente).

%!  ciclos_negativos(+Clausulas:list, -Pares:list) is det.
%
%   Pares son los P-Q, ordenados, tales que una regla de P usa negado a Q y
%   Q está en la componente de P: cada par cierra un ciclo que pasa por una
%   negación. Pares es vacía si y solo si el programa es estratificado.
ciclos_negativos(Clausulas, Pares) :-
    separar(Clausulas, _, Reglas),
    componentes_reglas(Reglas, Componentes),
    aristas(Reglas, Aristas),
    findall(P-Q,
            ( member(P-Q-neg, Aristas),
              member(C, Componentes),
              ord_memberchk(P, C),
              ord_memberchk(Q, C) ),
            Pares).

%!  evaluar(+Clausulas:list, -Modelo:list, -Costo) is det.
%
%   Modelo es el modelo estándar de Clausulas, un programa Datalog seguro
%   y estratificado, como lista ordenada de átomos. Costo es costo(Pasos,
%   Derivaciones), sumado sobre las componentes. Error de dominio si el
%   programa no es seguro o no es estratificado.
evaluar(Clausulas, Modelo, Costo) :-
    evaluar_base(Clausulas, Base, Costo),
    atomos(Base, Modelo).

%!  evaluar_base(+Clausulas:list, -Base, -Costo) is det.
%
%   Como evaluar/3, con el modelo en una base de motor.pl.
evaluar_base(Clausulas, Base, Costo) :-
    problemas(Clausulas, Problemas),
    (   Problemas = [P|_]
    ->  domain_error(datalog_seguro, P)
    ;   true
    ),
    ciclos_negativos(Clausulas, Pares),
    (   Pares == []
    ->  true
    ;   domain_error(programa_estratificado, Pares)
    ),
    separar(Clausulas, Hechos, Reglas),
    componentes_reglas(Reglas, Componentes),
    base(Hechos, Base0),
    foldl(evaluar_componente(Reglas), Componentes,
          Base0-costo(0, 0), Base-Costo).

%!  evaluar_componente(+Reglas:list, +Componente:list, +Estado0, -Estado)
%!      is det.
%
%   Estado0 es Base0-Costo0; Estado agrega lo que derivan hasta el punto
%   fijo las reglas de los predicados de Componente.
evaluar_componente(Reglas, Componente, Base0-Costo0, Base-Costo) :-
    include(de_componente(Componente), Reglas, DeLaComponente),
    bloque(DeLaComponente, Componente, Base0, Base, Costo0, Costo).

%!  de_componente(+Componente:list, +Regla) is semidet.
%
%   La cabeza de Regla es de un predicado de Componente.
de_componente(Componente, r(H, _)) :-
    predicado(H, P),
    ord_memberchk(P, Componente).
