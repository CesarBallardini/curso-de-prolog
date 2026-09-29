:- encoding(utf8).

% Capítulo 64 - Versión 6: medir la red contra el capítulo 63.
%
% Cuenta las inferencias de una ejecución completa con el intérprete del
% capítulo 63 y con la red, y en la red separa la carga de la memoria
% inicial de los ciclos. También cuenta los tokens que quedan guardados en
% las memorias beta después de la carga, y dice en qué nodos.
%
% solo-local: carga rete.pl con ensure_loaded/1, y SWISH no permite cargar
% archivos.
%
%?- comparar(100, F).
%?- memorias_grandes(400, 3, M).
%?- comparar_cadena(10, F).

:- ensure_loaded(rete).

%!  inferencias(:Meta, -N:integer) is det.
%
%   Ejecuta Meta una vez, conservando sus ligaduras, y N es la cantidad de
%   inferencias que costó. Antes la ejecuta una vez sin medir y sin
%   conservar nada, para que la cuenta no incluya la carga automática de
%   bibliotecas ni otros trabajos de la primera llamada.
inferencias(Meta, N) :-
    \+ \+ once(Meta),
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    N is I1 - I0.

%!  medir_red(+Red, +Estrategia, +Hechos:list, -Ciclos:integer,
%!            -Carga:integer, -Resto:integer) is det.
%
%   Ejecuta la Red desde Hechos. Carga son las inferencias de cargar la
%   memoria inicial en la red, y Resto, las de los Ciclos.
medir_red(Red, Estrategia, Hechos, Ciclos, Carga, Resto) :-
    inferencias(cargar(Red, Hechos, Memoria, Rete), Carga),
    inferencias(ciclo_rete(Red, Estrategia, sin_traza, 0, Ciclos, [],
                           Memoria-Rete, _, _),
                Resto).

%!  comparar(+K:integer, -Fila) is det.
%
%   Fila es fila(Hechos, Capitulo63, Carga, Ciclos) para el configurador
%   con MEA sobre pedido_ampliado(K, _): la cantidad de hechos iniciales,
%   las inferencias de la ejecución completa del capítulo 63, y las de la
%   carga y los ciclos de la red.
comparar(K, fila(N, I63, Carga, Ciclos)) :-
    pedido_ampliado(K, Hechos),
    length(Hechos, N),
    red_de(configurador, Red),
    inferencias(ejecutar_produccion(configurador, mea, sin_traza, Hechos, _,
                                    _, _),
                I63),
    medir_red(Red, mea, Hechos, _, Carga, Ciclos).

%!  mayores_memorias(+Red, +Hechos:list, +N:integer, -Mayores:list) is det.
%
%   Mayores tiene los pares Tokens-Nodo de los N nodos beta con más tokens
%   guardados después de cargar Hechos en la Red, de mayor a menor.
mayores_memorias(Red, Hechos, N, Mayores) :-
    cargar(Red, Hechos, _, Rete),
    Red = red(_, _, Nodos, _),
    findall(T-B,
            ( gen_assoc(B, Nodos, _),
              tokens(B, Rete, Tokens),
              length(Tokens, T) ),
            Pares),
    sort(0, @>=, Pares, Ordenados),
    length(Mayores, N),
    append(Mayores, _, Ordenados).

%!  tokens_guardados(+Red, +Hechos:list, -Total:integer) is det.
%
%   Total es la cantidad de tokens de todas las memorias beta después de
%   cargar Hechos en la Red.
tokens_guardados(Red, Hechos, Total) :-
    cargar(Red, Hechos, _, Rete),
    Red = red(_, _, Nodos, _),
    aggregate_all(sum(T),
                  ( gen_assoc(B, Nodos, _),
                    tokens(B, Rete, Tokens),
                    length(Tokens, T) ),
                  Total).

%!  perfil_red(+Red, +Estrategia, +Hechos:list, -Filas:list) is det.
%
%   Filas tiene un término ciclo(N, Inferencias) por cada ciclo que
%   dispara una regla: las inferencias del ciclo entero, desde reunir el
%   conjunto de conflicto hasta propagar los cambios de sus acciones.
perfil_red(Red, Estrategia, Hechos, Filas) :-
    cargar(Red, Hechos, Memoria, Rete),
    perfil_ciclos(Red, Estrategia, 1, [], Memoria-Rete, Filas).

%!  perfil_ciclos(+Red, +Estrategia, +N:integer, +Disparadas:list,
%!                +Estado, -Filas:list) is det.
%
%   Como ciclo_rete/9, y devuelve la fila de cada ciclo desde el N.
perfil_ciclos(Red, Estrategia, N, Disparadas0, Estado0, Filas) :-
    inferencias(un_ciclo(Red, Estrategia, sin_traza, N, Disparadas0,
                         Disparadas, Estado0, Estado, Fin),
                Inferencias),
    (   Fin == nada_aplicable
    ->  Filas = []
    ;   Filas = [ciclo(N, Inferencias)|Filas1],
        (   Fin == seguir
        ->  N1 is N + 1,
            perfil_ciclos(Red, Estrategia, N1, Disparadas, Estado, Filas1)
        ;   Filas1 = []
        )
    ).

%!  memorias_grandes(+K:integer, +N:integer, -Mayores:list) is det.
%
%   Como mayores_memorias/4, con la red del configurador y la memoria
%   inicial de pedido_ampliado(K, _).
memorias_grandes(K, N, Mayores) :-
    red_de(configurador, Red),
    pedido_ampliado(K, Hechos),
    mayores_memorias(Red, Hechos, N, Mayores).

%!  perfil_pedido(+K:integer, -Inferencias:list(integer)) is det.
%
%   Inferencias son las de cada ciclo del configurador con MEA en la red,
%   sobre pedido_ampliado(K, _).
perfil_pedido(K, Inferencias) :-
    red_de(configurador, Red),
    pedido_ampliado(K, Hechos),
    perfil_red(Red, mea, Hechos, Filas),
    findall(I, member(ciclo(_, I), Filas), Inferencias).

%!  cadena(+N:integer, -Hechos:list) is det.
%
%   Hechos son padre(1, 2), padre(2, 3), ..., padre(N, N + 1): una familia
%   de N + 1 generaciones, con una persona en cada una.
cadena(N, Hechos) :-
    findall(padre(I, J), ( between(1, N, I), J is I + 1 ), Hechos).

%!  comparar_cadena(+N:integer, -Fila) is det.
%
%   Fila es fila(Ciclos, Capitulo63, Carga, Resto) para el programa familia
%   con la estrategia orden sobre cadena(N, _): los ciclos, las
%   inferencias de la ejecución completa del capítulo 63, y las de la
%   carga y los ciclos de la red.
comparar_cadena(N, fila(Ciclos, I63, Carga, Resto)) :-
    cadena(N, Hechos),
    red_de(familia, Red),
    inferencias(ejecutar_produccion(familia, orden, sin_traza, Hechos,
                                    Ciclos, _, _),
                I63),
    medir_red(Red, orden, Hechos, _, Carga, Resto).

%!  ciclos_distintos(+Red, +K:integer, -Ciclos:list(integer)) is det.
%
%   Ciclos son los números de los ciclos del configurador con MEA en la
%   Red que cuestan otra cantidad de inferencias con pedido_ampliado(K, _)
%   que con pedido_ampliado(0, _).
ciclos_distintos(Red, K, Ciclos) :-
    pedido_ampliado(0, Hechos0),
    pedido_ampliado(K, Hechos),
    perfil_red(Red, mea, Hechos0, Filas0),
    perfil_red(Red, mea, Hechos, Filas),
    findall(N, ( member(ciclo(N, I0), Filas0),
                 member(ciclo(N, I), Filas),
                 I =\= I0 ),
            Ciclos).

%!  ciclos_que_cambian(+K:integer, -Ciclos:list(integer)) is det.
%
%   Como ciclos_distintos/3, con la red del configurador.
ciclos_que_cambian(K, Ciclos) :-
    red_de(configurador, Red),
    ciclos_distintos(Red, K, Ciclos).
