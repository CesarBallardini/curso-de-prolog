:- encoding(utf8).

% Capítulo 63 - Versión 5: el costo del reconocimiento.
%
% Ejecuta el ciclo de produccion.pl y mide, en cada ciclo, cuántas
% instanciaciones tiene el conjunto de conflicto, cuántas estaban ya en
% el ciclo anterior —la misma regla con los mismos sellos— y cuántas
% inferencias cuesta reunirlo. Cada ciclo cambia unos pocos hechos, pero
% el reconocimiento vuelve a comparar todas las reglas con toda la
% memoria.
%
% solo-local: carga configurador.pl con ensure_loaded/1, y SWISH no
% permite cargar archivos.
%
%?- perfil(familia, orden, [padre(juan, ana), madre(ana, sofia)], F).
%?- pedido_ampliado(100, H), medir(configurador, mea, H, C, I, R, Inf).

:- ensure_loaded(configurador).

%!  medir(+Programa, +Estrategia, +Hechos:list, -Ciclos:integer,
%!        -Instanciaciones:integer, -Repetidas:integer,
%!        -Inferencias:integer) is det.
%
%   Ejecuta el Programa desde Hechos. Ciclos es la cantidad de reglas
%   disparadas; Instanciaciones, la suma de los tamaños de los conjuntos de
%   conflicto; Repetidas, cuántas de ellas estaban en el conjunto del
%   ciclo anterior, e Inferencias, las que costó reunir los conjuntos.
medir(Programa, Estrategia, Hechos, Ciclos, Instanciaciones, Repetidas,
      Inferencias) :-
    perfil(Programa, Estrategia, Hechos, Filas),
    length(Filas, Ciclos),
    findall(T, member(ciclo(_, T, _, _), Filas), Tamanos),
    sum_list(Tamanos, Instanciaciones),
    findall(R, member(ciclo(_, _, R, _), Filas), Rs),
    sum_list(Rs, Repetidas),
    findall(I, member(ciclo(_, _, _, I), Filas), Is),
    sum_list(Is, Inferencias).

%!  perfil(+Programa, +Estrategia, +Hechos:list, -Filas:list) is det.
%
%   Filas tiene un término ciclo(N, Tamano, Repetidas, Inferencias) por
%   cada ciclo que dispara una regla: el tamaño del conjunto de conflicto,
%   cuántas de sus instanciaciones estaban en el del ciclo anterior y las
%   inferencias que costó reunirlo.
perfil(Programa, Estrategia, Hechos, Filas) :-
    programa(Programa, Reglas),
    memoria_con(Hechos, Memoria),
    medir_ciclos(Reglas, Estrategia, 1, [], [], Memoria, Filas).

%!  medir_ciclos(+Reglas:list, +Estrategia, +N:integer, +Anteriores:list,
%!               +Disparadas:list, +Memoria, -Filas:list) is det.
%
%   Como reconocer_actuar/9, y devuelve la fila de cada ciclo. Anteriores
%   es el conjunto ordenado de las instanciaciones del ciclo anterior, como
%   pares Regla-Sellos.
medir_ciclos(Reglas, Estrategia, N, Anteriores, Disparadas, Memoria0,
             Filas) :-
    statistics(inferences, I0),
    conjunto_conflicto(Reglas, Memoria0, Todas),
    statistics(inferences, I1),
    Inferencias is I1 - I0,
    maplist(identidad, Todas, Identidades0),
    sort(Identidades0, Identidades),
    ord_intersection(Identidades, Anteriores, Comunes),
    length(Todas, Tamano),
    length(Comunes, Repetidas),
    refractar(Todas, Disparadas, Nuevas),
    (   Nuevas == []
    ->  Filas = []
    ;   preferida(Estrategia, Nuevas, Elegida),
        Elegida = instanciacion(Nombre, Sellos, _, Acciones),
        ord_add_element(Disparadas, Nombre-Sellos, Disparadas1),
        aplicar_acciones(Acciones, Memoria0, Memoria1, Fin),
        Filas = [ciclo(N, Tamano, Repetidas, Inferencias)|Filas1],
        (   Fin = parar(_)
        ->  Filas1 = []
        ;   N1 is N + 1,
            medir_ciclos(Reglas, Estrategia, N1, Identidades, Disparadas1,
                         Memoria1, Filas1)
        )
    ).

%!  identidad(+Instanciacion, -Identidad) is det.
%
%   Identidad es el par Regla-Sellos de la Instanciacion.
identidad(instanciacion(Nombre, Sellos, _, _), Nombre-Sellos).

%!  pedido_ampliado(+K:integer, -Hechos:list) is det.
%
%   Hechos es la memoria inicial del configurador para el pedido de 8
%   núcleos, 32 GB y placa de video, con K memorias más en el catálogo que
%   ninguna placa admite.
pedido_ampliado(K, Hechos) :-
    memoria_del_pedido([pedido(nucleos, 8), pedido(memoria, 32),
                        pedido(video, si)], Hechos0),
    findall(objeto(extra(I), memoria, [tipo-ddr3, gb-8, precio-20]),
            between(1, K, I), Extras),
    append(Extras, Hechos0, Hechos).

%!  medir_ampliado(+K:integer, -Hechos:integer, -Ciclos:integer,
%!                 -Instanciaciones:integer, -Inferencias:integer) is det.
%
%   Mide con medir/7 el configurador con MEA sobre pedido_ampliado(K, _).
%   Hechos es la cantidad de hechos de la memoria inicial.
medir_ampliado(K, Hechos, Ciclos, Instanciaciones, Inferencias) :-
    pedido_ampliado(K, Memoria),
    length(Memoria, Hechos),
    medir(configurador, mea, Memoria, Ciclos, Instanciaciones, _,
          Inferencias).
