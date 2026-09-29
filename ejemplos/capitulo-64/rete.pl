:- encoding(utf8).

% Capítulo 64 - Versión 5: el ciclo sobre la red.
%
% El ciclo reconocer-actuar del capítulo 63, con el conjunto de conflicto
% guardado en la red en lugar de reunido en cada ciclo. Cada acción que
% agrega o quita un hecho lo propaga por la red, y el conjunto queda al día.
% La elección reutiliza refractar/3, preferida/3 e informar/5 del
% capítulo 63, y la memoria de trabajo es la de memoria.pl: el resultado
% tiene que ser el mismo, sello por sello.
%
% solo-local: carga negacion.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- encadenar_rete(familia, orden, [padre(juan, ana), madre(ana, sofia)], M, R).
%?- configurar_rete([pedido(nucleos, 8), pedido(memoria, 32), pedido(video, si)], C, P, W).

:- ensure_loaded(negacion).

%!  encadenar_rete(+Programa, +Estrategia, +Hechos:list, -Memoria:list,
%!                 -Resultado) is det.
%
%   Como encadenar/5 del capítulo 63, con el reconocimiento de la red.
encadenar_rete(Programa, Estrategia, Hechos, Memoria, Resultado) :-
    ejecutar_rete(Programa, Estrategia, sin_traza, Hechos, _, Mt,
                  Resultado),
    hechos(Mt, Memoria).

%!  rastrear_rete(+Programa, +Estrategia, +Hechos:list, -Memoria:list,
%!                -Resultado) is det.
%
%   Como rastrear/5 del capítulo 63: escribe una línea por ciclo.
rastrear_rete(Programa, Estrategia, Hechos, Memoria, Resultado) :-
    ejecutar_rete(Programa, Estrategia, con_traza, Hechos, _, Mt,
                  Resultado),
    hechos(Mt, Memoria).

%!  ejecutar_rete(+Programa, +Estrategia, +Traza, +Hechos:list,
%!                -Ciclos:integer, -Memoria, -Resultado) is det.
%
%   Como ejecutar_produccion/7 del capítulo 63: Ciclos es la cantidad de
%   reglas disparadas y Memoria, la memoria final como término mt/2.
ejecutar_rete(Programa, Estrategia, Traza, Hechos, Ciclos, Memoria,
              Resultado) :-
    red_de(Programa, Red),
    ejecutar_red(Red, Estrategia, Traza, Hechos, Ciclos, Memoria,
                 Resultado).

%!  ejecutar_red(+Red, +Estrategia, +Traza, +Hechos:list, -Ciclos:integer,
%!               -Memoria, -Resultado) is det.
%
%   Como ejecutar_rete/7, con una Red ya compilada.
ejecutar_red(Red, Estrategia, Traza, Hechos, Ciclos, Memoria,
             Resultado) :-
    cargar(Red, Hechos, Memoria0, Rete0),
    ciclo_rete(Red, Estrategia, Traza, 0, Ciclos, [], Memoria0-Rete0,
               Memoria-_, Resultado).

%!  ciclo_rete(+Red, +Estrategia, +Traza, +N0:integer, -N:integer,
%!             +Disparadas:list, +Estado0, -Estado, -Resultado) is det.
%
%   Repite un_ciclo/9 desde el par Memoria-Rete Estado0, después de N0
%   ciclos, hasta que una acción para o no queda nada aplicable. N es la
%   cantidad de ciclos al terminar.
ciclo_rete(Red, Estrategia, Traza, N0, N, Disparadas0, Estado0, Estado,
           Resultado) :-
    N1 is N0 + 1,
    un_ciclo(Red, Estrategia, Traza, N1, Disparadas0, Disparadas, Estado0,
             Estado1, Fin),
    (   Fin == seguir
    ->  ciclo_rete(Red, Estrategia, Traza, N1, N, Disparadas, Estado1,
                   Estado, Resultado)
    ;   Fin = parar(R)
    ->  N = N1,
        Estado = Estado1,
        Resultado = R
    ;   N = N0,
        Estado = Estado1,
        Resultado = nada_aplicable
    ).

%!  un_ciclo(+Red, +Estrategia, +Traza, +N:integer, +Disparadas0:list,
%!           -Disparadas:list, +Estado0, -Estado, -Fin) is semidet.
%
%   Hace el ciclo número N. Disparadas0 es el conjunto ordenado de los
%   pares Regla-Sellos ya disparados. Fin es nada_aplicable si no hay
%   instanciaciones nuevas, parar(R) si una acción para, y seguir si no.
%   La instanciación elegida sale del conjunto de conflicto antes de
%   ejecutar sus acciones; Disparadas sigue haciendo falta, porque una
%   negación puede volver a agregarla con los mismos sellos. Falla si una
%   acción quita un hecho que no está.
un_ciclo(Red, Estrategia, Traza, N, Disparadas0, Disparadas, Estado0,
         Estado, Fin) :-
    Estado0 = Memoria0-Rete0,
    conjunto_rete(Rete0, Todas),
    refractar(Todas, Disparadas0, Nuevas),
    (   Nuevas == []
    ->  Disparadas = Disparadas0,
        Estado = Estado0,
        Fin = nada_aplicable
    ;   preferida(Estrategia, Nuevas, Elegida),
        informar(Traza, N, Nuevas, Elegida, Memoria0),
        Elegida = instanciacion(Nombre, Sellos, _, Acciones),
        ord_add_element(Disparadas0, Nombre-Sellos, Disparadas),
        quitar_elegida(Red, Elegida, Rete0, Rete1),
        acciones_rete(Acciones, Red, Memoria0-Rete1, Estado, Fin)
    ).

%!  quitar_elegida(+Red, +Elegida, +Rete0, -Rete) is det.
%
%   Rete es Rete0 sin la instanciación Elegida en el conjunto de conflicto.
%   La clave se busca entre las reglas de su nombre.
quitar_elegida(Red, Elegida, rete(Alfas, Betas, Conjunto0),
               rete(Alfas, Betas, Conjunto)) :-
    Red = red(_, _, _, Terminales),
    Elegida = instanciacion(Nombre, Sellos, _, _),
    maplist(opuesto, Sellos, Inversos),
    (   gen_assoc(K, Terminales, regla(Nombre, _, _, _)),
        get_assoc(K-Inversos, Conjunto0, Lista),
        member(I, Lista),
        I =@= Elegida
    ->  cambiar_lista(menos, K-Inversos, Elegida, Conjunto0, Conjunto)
    ;   Conjunto = Conjunto0
    ).

%!  acciones_rete(+Acciones:list, +Red, +Estado0, -Estado, -Fin)
%!      is semidet.
%
%   Como aplicar_acciones/4 del capítulo 63, sobre el par Memoria-Rete:
%   cada hecho que entra o sale de la memoria también entra o sale de la
%   red. Falla si una acción quita un hecho que no está.
acciones_rete([], _, Estado, Estado, seguir).
acciones_rete([A|As], Red, Estado0, Estado, Fin) :-
    (   A = parar(R)
    ->  Estado = Estado0,
        Fin = parar(R)
    ;   accion_rete(A, Red, Estado0, Estado1),
        acciones_rete(As, Red, Estado1, Estado, Fin)
    ).

%!  accion_rete(+Accion, +Red, +Estado0, -Estado) is semidet.
%
%   Ejecuta una Accion que no es parar/1.
accion_rete({Meta}, _, Estado, Estado) :-
    once(Meta).
accion_rete(agregar(F), Red, Estado0, Estado) :-
    afirmar_rete(Red, F, Estado0, Estado).
accion_rete(quitar(F), Red, Estado0, Estado) :-
    retirar_rete(Red, F, Estado0, Estado).
accion_rete(reemplazar(F, G), Red, Estado0, Estado) :-
    retirar_rete(Red, F, Estado0, Estado1),
    afirmar_rete(Red, G, Estado1, Estado).

%!  iguales(+Programa, +Estrategia, +Hechos:list) is semidet.
%
%   El capítulo 63 y la red ejecutan el Programa desde Hechos con la misma
%   cantidad de ciclos, la misma memoria final, con los mismos sellos, y el
%   mismo resultado.
iguales(Programa, Estrategia, Hechos) :-
    ejecutar_produccion(Programa, Estrategia, sin_traza, Hechos, C, M, R),
    ejecutar_rete(Programa, Estrategia, sin_traza, Hechos, C1, M1, R1),
    C-M-R == C1-M1-R1.

%!  configurar_rete(+Pedido:list, -Componentes:list, -Precio:number,
%!                  -Consumo:number) is det.
%
%   Como configurar/4 del capítulo 63, con el reconocimiento de la red.
configurar_rete(Pedido, Componentes, Precio, Consumo) :-
    memoria_del_pedido(Pedido, Hechos),
    encadenar_rete(configurador, mea, Hechos, Memoria, configurada),
    componentes(Memoria, Componentes, Precio),
    memberchk(consumo(Consumo), Memoria).
