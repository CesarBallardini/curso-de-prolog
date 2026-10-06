:- encoding(utf8).

% Capítulo 72 - Heurísticas consistentes.
%
% Una heurística es consistente (o monótona) si en cada transición de un
% estado E a un estado S con costo C cumple H(E) =< C + H(S): la
% estimación no baja más de lo que cuesta el paso. Una heurística
% consistente que da 0 en las metas nunca estima de más, y con ella A*
% no necesita expandir un estado dos veces. alcanzables/2 recorre todo el
% espacio de estados de un proyecto chico, y arista_inconsistente/5
% busca en él una transición que viole la condición. salteada/3 es una
% heurística admisible que no es consistente: la del camino crítico en
% los estados con una cantidad par de tareas pendientes, y 0 en los demás.
%
% solo-local: carga otros archivos, y SWISH no permite cargar otro archivo.
%
%?- medir_consistencia(casa, combinada, Estados, Malas).
%?- medir_consistencia(casa, salteada, Estados, Malas).

:- module(consistencia,
          [ alcanzables/2,
            arista_inconsistente/5,
            consistente/2,
            inconsistentes/3,
            medir_consistencia/4,
            salteada/3
          ]).

:- reexport(camino).
:- use_module(library(nb_set)).

:- meta_predicate
    arista_inconsistente(+, 3, -, -, -),
    consistente(+, 3),
    inconsistentes(+, 3, -),
    medir_consistencia(+, 3, -, -).

%!  alcanzables(+Proyecto, -Estados:list) is det.
%
%   Estados son todos los estados del espacio de la versión 2 que se
%   alcanzan desde el estado inicial de Proyecto, en el orden estándar.
alcanzables(Proyecto, Estados) :-
    inicial(datos(Proyecto, cero), Inicial),
    empty_nb_set(Vistos),
    add_nb_set(Inicial, Vistos),
    recorrer([Inicial], Proyecto, Vistos),
    nb_set_to_list(Vistos, Estados).

%!  recorrer(+Frontera:list, +Proyecto, +Vistos) is det.
%
%   Agrega a Vistos todos los estados que se alcanzan desde los de
%   Frontera.
recorrer([], _, _).
recorrer([Estado|Frontera], Proyecto, Vistos) :-
    findall(Siguiente,
            ( sucesor(datos(Proyecto, cero), Estado, _, Siguiente, _),
              add_nb_set(Siguiente, Vistos, true) ),
            Nuevos),
    append(Nuevos, Frontera, Frontera1),
    recorrer(Frontera1, Proyecto, Vistos).

%!  arista_inconsistente(+Proyecto, :Heuristica, -Estado, -Siguiente,
%!                       -Costo:integer) is nondet.
%
%   La transición de Estado a Siguiente, con Costo, viola la consistencia
%   de Heuristica: lo que estima en Estado supera Costo más lo que estima
%   en Siguiente.
arista_inconsistente(Proyecto, Heuristica, Estado, Siguiente, Costo) :-
    alcanzables(Proyecto, Estados),
    member(Estado, Estados),
    sucesor(datos(Proyecto, cero), Estado, _, Siguiente, Costo),
    call(Heuristica, Proyecto, Estado, H0),
    call(Heuristica, Proyecto, Siguiente, H1),
    H0 > Costo + H1.

%!  consistente(+Proyecto, :Heuristica) is semidet.
%
%   Heuristica es consistente en todo el espacio de estados de Proyecto.
consistente(Proyecto, Heuristica) :-
    \+ arista_inconsistente(Proyecto, Heuristica, _, _, _).

%!  inconsistentes(+Proyecto, :Heuristica, -N:integer) is det.
%
%   N es la cantidad de transiciones del espacio de Proyecto que violan la
%   consistencia de Heuristica.
inconsistentes(Proyecto, Heuristica, N) :-
    aggregate_all(count,
                  arista_inconsistente(Proyecto, Heuristica, _, _, _),
                  N).

%!  medir_consistencia(+Nombre, :Heuristica, -Estados:integer,
%!                     -Inconsistentes:integer) is semidet.
%
%   Estados es la cantidad de estados alcanzables del proyecto de ejemplo
%   Nombre, e Inconsistentes la de transiciones entre ellos que violan la
%   consistencia de Heuristica.
medir_consistencia(Nombre, Heuristica, Estados, Inconsistentes) :-
    ejemplo(Nombre, Proyecto),
    alcanzables(Proyecto, Lista),
    length(Lista, Estados),
    inconsistentes(Proyecto, Heuristica, Inconsistentes).

%!  salteada(+Proyecto, +Estado, -H:integer) is det.
%
%   H es lo que estima camino/3 si en Estado queda una cantidad par de
%   tareas pendientes, y 0 si queda una cantidad impar. Nunca estima de
%   más, porque nunca supera a camino/3, pero no es consistente.
salteada(Proyecto, e(Pendientes, Libres, Fines), H) :-
    length(Pendientes, N),
    (   N mod 2 =:= 0
    ->  camino(Proyecto, e(Pendientes, Libres, Fines), H)
    ;   H = 0
    ).
