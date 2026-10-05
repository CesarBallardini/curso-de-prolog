:- encoding(utf8).

% Capítulo 49 - Diagnósticos mínimos a partir de diagnósticos.
%
% En el modelo débil, agregar una compuerta a un diagnóstico da otro
% diagnóstico. Entonces un diagnóstico se reduce a uno mínimo probando de
% sacar cada compuerta una vez: n verificaciones para n compuertas. Y
% cada diagnóstico mínimo nuevo deja fuera alguna compuerta de cada uno de
% los ya encontrados, porque si los contuviera no sería mínimo: se elige
% una compuerta de cada mínimo conocido, de a una y verificando que lo que
% queda siga siendo diagnóstico, y lo que queda al final se reduce. Es la
% idea de Mozetič (1992), calcular los mínimos a partir de diagnósticos y
% no de conflictos; el código es una versión simple escrita para el curso,
% no el algoritmo de su artículo.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- es_diagnostico(sumador, [[0, 0, 1]-[0, 1]], [[m1, x1]]).
%?- reducir(sumador, [[0, 0, 1]-[0, 1]], [[m1, x1], [m2, x1], [o1]], D).
%?- minimos_incrementales(sumador, [[0, 0, 1]-[0, 1]], Ds).

:- module(incremental,
          [ es_diagnostico/3,
            reducir/4,
            siguiente_minimo/4,
            minimos_incrementales/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(ordsets)).
:- use_module(abduccion).
:- use_module(modelos).

%!  es_diagnostico(+Circuito, +Observaciones:list(pair), +Rutas:list)
%!      is semidet.
%
%   Con las compuertas de Rutas en el estado desconocida del modelo débil
%   y las demás en ok, Circuito reproduce todas las Observaciones: una
%   sola verificación, sin suponer nada.
es_diagnostico(Circuito, Observaciones, Rutas) :-
    findall(Ruta, compuerta_en(Circuito, Ruta, _), Todas),
    maplist(estado_de(Rutas), Todas, Supuestos),
    once(explicar(debil, Circuito, Observaciones, Supuestos)).

%!  estado_de(+Rutas:list, +Ruta, -Par:pair) is det.
%
%   Par es Ruta-desconocida si Ruta está en Rutas, y Ruta-ok si no.
estado_de(Rutas, Ruta, Ruta-Estado) :-
    (   memberchk(Ruta, Rutas)
    ->  Estado = desconocida
    ;   Estado = ok
    ).

%!  reducir(+Circuito, +Observaciones:list(pair), +Diagnostico:list,
%!      -Minimo:list) is det.
%
%   Minimo es un diagnóstico mínimo contenido en Diagnostico, una lista
%   ordenada de rutas que es diagnóstico: se prueba sacar cada compuerta,
%   en orden, y se la deja fuera si lo que queda sigue siendo diagnóstico.
reducir(Circuito, Observaciones, Diagnostico, Minimo) :-
    foldl(probar_sacar(Circuito, Observaciones), Diagnostico,
          Diagnostico, Minimo).

%!  probar_sacar(+Circuito, +Observaciones:list(pair), +Ruta, +D0:list,
%!      -D:list) is det.
%
%   D es D0 sin Ruta si eso sigue siendo diagnóstico, y D0 si no.
probar_sacar(Circuito, Observaciones, Ruta, D0, D) :-
    ord_del_element(D0, Ruta, D1),
    (   es_diagnostico(Circuito, Observaciones, D1)
    ->  D = D1
    ;   D = D0
    ).

%!  siguiente_minimo(+Circuito, +Observaciones:list(pair),
%!      +Conocidos:list(list), -Minimo:list) is semidet.
%
%   Minimo es un diagnóstico mínimo que no está en Conocidos, una lista
%   de diagnósticos mínimos: se deja fuera una compuerta de cada uno, y lo
%   que queda, si es diagnóstico, se reduce. Falla si Conocidos los tiene
%   a todos, o si ni todas las compuertas desconocidas explican las
%   observaciones.
siguiente_minimo(Circuito, Observaciones, Conocidos, Minimo) :-
    findall(Ruta, compuerta_en(Circuito, Ruta, _), Todas0),
    sort(Todas0, Todas),
    excluir(Conocidos, Circuito, Observaciones, Todas, [], Fuera),
    ord_subtract(Todas, Fuera, Candidato),
    es_diagnostico(Circuito, Observaciones, Candidato),
    !,
    reducir(Circuito, Observaciones, Candidato, Minimo).

%!  excluir(+Conocidos:list(list), +Circuito, +Observaciones:list(pair),
%!      +Todas:list, +Fuera0:list, -Fuera:list) is nondet.
%
%   Fuera es Fuera0 con una compuerta más de cada diagnóstico de Conocidos
%   que Fuera0 todavía no toca, de modo que Todas sin Fuera sigue siendo
%   diagnóstico. Cada compuerta que se deja fuera se verifica en el
%   momento: si lo que queda ya no es diagnóstico, menos compuertas
%   tampoco lo son, y la rama se abandona.
excluir([], _, _, _, Fuera, Fuera).
excluir([D|Ds], Circuito, Observaciones, Todas, Fuera0, Fuera) :-
    (   ord_intersect(D, Fuera0)
    ->  excluir(Ds, Circuito, Observaciones, Todas, Fuera0, Fuera)
    ;   member(Ruta, D),
        ord_add_element(Fuera0, Ruta, Fuera1),
        ord_subtract(Todas, Fuera1, Quedan),
        es_diagnostico(Circuito, Observaciones, Quedan),
        excluir(Ds, Circuito, Observaciones, Todas, Fuera1, Fuera)
    ).

%!  minimos_incrementales(+Circuito, +Observaciones:list(pair),
%!      -Minimos:list(list)) is det.
%
%   Minimos son todos los diagnósticos mínimos del modelo débil, como
%   listas ordenadas de rutas, en el orden en que se encuentran.
minimos_incrementales(Circuito, Observaciones, Minimos) :-
    minimos_desde(Circuito, Observaciones, [], Minimos).

%!  minimos_desde(+Circuito, +Observaciones:list(pair),
%!      +Conocidos:list(list), -Minimos:list(list)) is det.
%
%   Minimos son los Conocidos seguidos de los demás diagnósticos mínimos.
minimos_desde(Circuito, Observaciones, Conocidos, Minimos) :-
    (   siguiente_minimo(Circuito, Observaciones, Conocidos, Minimo)
    ->  append(Conocidos, [Minimo], Conocidos1),
        minimos_desde(Circuito, Observaciones, Conocidos1, Minimos)
    ;   Minimos = Conocidos
    ).
