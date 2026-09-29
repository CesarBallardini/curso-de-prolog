:- encoding(utf8).

% Capítulo 74 - Versión 7: soluciones más cortas.
%
% Dos cambios sobre etapas.pl, cada uno medido por separado. El primero
% es simplificar/2: las macros terminan y empiezan con giros de la misma
% cara, y al ponerlas una detrás de otra quedan un giro seguido de su
% inverso, o tres cuartos de vuelta seguidos de una cara, que valen uno
% solo en sentido contrario. El segundo es elegir, dentro de cada etapa,
% la pieza más cercana en lugar de la siguiente de la lista: el criterio
% de colocar_pieza/4 pasa a ser una lista, con un criterio por cada pieza
% que falta, y la búsqueda termina con la primera que alcanza.
%
% solo-local: carga etapas.pl.
%
%?- simplificar([r, u, -u, -r, f, f, f], Ms).
%?- sesion(7, 20).
%?- medir(cercana_simplificada, 20, Media, Maximo).

:- ensure_loaded(etapas).

% --- Simplificar una secuencia ----------------------------------------------

%!  simplificar(+Movimientos:list, -Simplificada:list) is det.
%
%   Simplificada hace lo mismo que Movimientos, con los giros seguidos de
%   una misma cara reducidos: se suman los cuartos de vuelta, módulo 4, y
%   el resultado se escribe con la menor cantidad de cuartos de vuelta.
simplificar(Movimientos, Simplificada) :-
    foldl(apilar, Movimientos, [], Pila),
    reverse(Pila, Grupos),
    foldl(desplegar, Grupos, Simplificada, []).

%!  apilar(+Movimiento, +Pila0:list, -Pila:list) is det.
%
%   Pila es Pila0 con Movimiento sumado: Pila es una lista de pares
%   Cara-Cuartos, el último grupo primero. Si el grupo de arriba es de la
%   misma cara, se suman; si la suma da 0 módulo 4, el grupo desaparece y
%   el de abajo puede volver a sumarse con el siguiente.
apilar(Movimiento, Pila0, Pila) :-
    cara_de(Movimiento, Cara),
    cuartos(Movimiento, K),
    (   Pila0 = [Cara-K0|Resto]
    ->  K1 is (K0 + K) mod 4,
        (   K1 =:= 0
        ->  Pila = Resto
        ;   Pila = [Cara-K1|Resto]
        )
    ;   Pila = [Cara-K|Pila0]
    ).

%!  cuartos(+Movimiento, -K:integer) is det.
%
%   K es la cantidad de cuartos de vuelta, en el sentido de las agujas del
%   reloj y módulo 4, de Movimiento.
cuartos(-_, 3) :-
    !.
cuartos(_, 1).

%!  desplegar(+Grupo, ?Movimientos0:list, ?Movimientos:list) is det.
%
%   Movimientos0 es Movimientos precedida por los giros de Grupo, un par
%   Cara-K: K = 1 es un giro, K = 2 son dos y K = 3 es el giro inverso.
desplegar(Cara-K, Ms0, Ms) :-
    giros_de(K, Cara, Ms0, Ms).

%!  giros_de(+K:integer, +Cara, ?Movimientos0:list, ?Movimientos:list)
%!      is det.
%
%   Movimientos0 es Movimientos precedida por K cuartos de vuelta de
%   Cara, escritos con la menor cantidad de giros.
giros_de(1, Cara, [Cara|Ms], Ms).
giros_de(2, Cara, [Cara, Cara|Ms], Ms).
giros_de(3, Cara, [-Cara|Ms], Ms).

% --- La pieza más cercana ---------------------------------------------------

%!  resolver_cercana(+Cubo, -Pasos:list) is det.
%
%   Como resolver/2, pero en cada etapa se coloca primero la pieza que
%   pide la secuencia más corta.
resolver_cercana(Cubo, Pasos) :-
    findall(E-Ps, etapa(E, Ps), Etapas),
    etapas_cercanas(Etapas, [], Cubo, Pasos).

%!  etapas_cercanas(+Etapas:list, +Colocadas:list, +Cubo, -Pasos:list)
%!      is det.
%
%   Pasos coloca las piezas de Etapas en Cubo, que ya tiene Colocadas.
etapas_cercanas([], _, _, []).
etapas_cercanas([_-[]|Etapas], Colocadas, Cubo, Pasos) :-
    !,
    etapas_cercanas(Etapas, Colocadas, Cubo, Pasos).
etapas_cercanas([E-Faltan|Etapas], Colocadas, Cubo,
                [paso(E, Pieza, Movimientos)|Pasos]) :-
    maplist(criterio_con(Colocadas), Faltan, Criterios),
    colocar_pieza(E, Cubo, Criterios, Plan),
    append(Plan, Movimientos),
    aplicar(Movimientos, Cubo, Cubo1),
    once(( member(Pieza, Faltan),
           criterio([Pieza|Colocadas], Criterio),
           subsumes_term(Criterio, Cubo1) )),
    selectchk(Pieza, Faltan, Faltan1),
    etapas_cercanas([E-Faltan1|Etapas], [Pieza|Colocadas], Cubo1, Pasos).

%!  criterio_con(+Colocadas:list, +Pieza, -Criterio) is det.
%
%   Criterio es el criterio de Colocadas y Pieza.
criterio_con(Colocadas, Pieza, Criterio) :-
    criterio([Pieza|Colocadas], Criterio).

% --- Medir ---------------------------------------------------------------

%!  largo(+Metodo, +Semilla:integer, -N:integer) is det.
%
%   N es la cantidad de cuartos de vuelta con que Metodo resuelve la
%   mezcla de 25 giros de Semilla. Metodo es etapas (resolver/2),
%   simplificada (resolver/2 y simplificar/2), cercana
%   (resolver_cercana/2) o cercana_simplificada (las dos mejoras).
largo(Metodo, Semilla, N) :-
    mezcla(Semilla, 25, Ms),
    resuelto(C),
    aplicar(Ms, C, C1),
    solucion(Metodo, C1, G),
    length(G, N).

%!  solucion(+Metodo, +Cubo, -Movimientos:list) is det.
%
%   Movimientos resuelve Cubo con Metodo.
solucion(etapas, C, G) :-
    resolver(C, Pasos),
    giros(Pasos, G).
solucion(simplificada, C, G) :-
    resolver(C, Pasos),
    giros(Pasos, G0),
    simplificar(G0, G).
solucion(cercana, C, G) :-
    resolver_cercana(C, Pasos),
    giros(Pasos, G).
solucion(cercana_simplificada, C, G) :-
    resolver_cercana(C, Pasos),
    giros(Pasos, G0),
    simplificar(G0, G).

%!  medir(+Metodo, +Semillas:integer, -Media:number, -Maximo:integer)
%!      is det.
%
%   Media y Maximo son la media y el máximo de los cuartos de vuelta con
%   que Metodo resuelve las mezclas de las semillas 1 a Semillas.
medir(Metodo, Semillas, Media, Maximo) :-
    findall(N, ( between(1, Semillas, S), largo(Metodo, S, N) ), Ns),
    sum_list(Ns, Suma),
    Media is Suma / Semillas,
    max_list(Ns, Maximo).

%!  giros(+Pasos:list, -Movimientos:list) is det.
%
%   Movimientos son los giros de Pasos, uno detrás de otro.
giros(Pasos, Movimientos) :-
    findall(Ms, member(paso(_, _, Ms), Pasos), Listas),
    append(Listas, Movimientos).

% --- El programa terminado -----------------------------------------------

%!  sesion(+Semilla:integer, +Largo:integer) is det.
%
%   Mezcla el cubo con Largo giros de Semilla, lo muestra, lo resuelve con
%   resolver_cercana/2 y escribe los giros de cada etapa, simplificados.
sesion(Semilla, Largo) :-
    mezcla(Semilla, Largo, Mezcla),
    escribir_notacion(Mezcla, TextoMezcla),
    format("Mezcla de ~d cuartos de vuelta: ~s~n", [Largo, TextoMezcla]),
    resuelto(C),
    aplicar(Mezcla, C, C1),
    mostrar(C1),
    resolver_cercana(C1, Pasos),
    forall(etapa(E, _), escribir_etapa(E, Pasos)),
    giros(Pasos, G0),
    simplificar(G0, G),
    length(G, N),
    aplicar(G, C1, C2),
    (   C2 == C
    ->  Estado = "queda resuelto"
    ;   Estado = "no queda resuelto"
    ),
    format("Total: ~d cuartos de vuelta. El cubo ~s.~n", [N, Estado]).

%!  escribir_etapa(+Etapa, +Pasos:list) is det.
%
%   Escribe el nombre de Etapa y sus giros de Pasos, simplificados.
escribir_etapa(E, Pasos) :-
    findall(Ms, member(paso(E, _, Ms), Pasos), Listas),
    append(Listas, G0),
    simplificar(G0, G),
    length(G, N),
    escribir_notacion(G, Texto),
    nombre_etapa(E, Nombre),
    format("~d. ~s (~d cuartos de vuelta):~n   ~s~n", [E, Nombre, N, Texto]).
