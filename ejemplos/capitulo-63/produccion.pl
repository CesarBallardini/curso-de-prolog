:- encoding(utf8).

% Capítulo 63 - Versión 1: el sistema de producción.
%
% Las reglas se escriben en el lenguaje de módulos del capítulo 60,
% Nombre :: Condiciones ---> Acciones, y un programa es una cláusula de
% programa/2. La memoria de trabajo es la de memoria.pl: un conjunto de
% hechos con sellos de tiempo. Cada ciclo reúne el conjunto de conflicto,
% quita por refracción las instanciaciones que ya se dispararon, elige una
% con una estrategia y ejecuta sus acciones. Una instanciación es una regla
% con los sellos de los hechos que cumplen sus patrones; la misma regla con
% los mismos hechos se dispara una sola vez.
%
% Carga también los intérpretes del capítulo 60, para ejecutar el mismo
% programa con los dos.
%
% solo-local: carga memoria.pl y terminacion.pl del capítulo 60 con
% ensure_loaded/1, y SWISH no permite cargar archivos.
%
%?- encadenar(familia, orden, [padre(juan, ana), madre(ana, sofia)], M, R).
%?- rastrear(familia, orden, [padre(juan, ana), madre(ana, sofia)], M, R).

:- ensure_loaded('../capitulo-60/terminacion').
:- ensure_loaded(memoria).
:- use_module(library(ordsets)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).

% Otros archivos agregan estrategias.
:- multifile clave_estrategia/3.

%!  encadenar(+Programa, +Estrategia, +Hechos:list, -Memoria:list,
%!            -Resultado) is det.
%
%   Ejecuta el Programa desde una memoria con los Hechos, eligiendo en cada
%   ciclo con la Estrategia. Memoria son los hechos al terminar, del más
%   reciente al más antiguo, y Resultado el término de parar/1, o
%   nada_aplicable si ninguna instanciación nueva quedaba.
encadenar(Programa, Estrategia, Hechos, Memoria, Resultado) :-
    ejecutar_produccion(Programa, Estrategia, sin_traza, Hechos, _, Mt,
                        Resultado),
    hechos(Mt, Memoria).

%!  rastrear(+Programa, +Estrategia, +Hechos:list, -Memoria:list,
%!           -Resultado) is det.
%
%   Como encadenar/5, y escribe una línea por ciclo: el número del ciclo,
%   la regla elegida, cuántas instanciaciones nuevas había y los hechos
%   que usa, con sus sellos.
rastrear(Programa, Estrategia, Hechos, Memoria, Resultado) :-
    ejecutar_produccion(Programa, Estrategia, con_traza, Hechos, _, Mt,
                        Resultado),
    hechos(Mt, Memoria).

%!  rastrear_reglas(+Programa, +Estrategia, +Hechos:list, -Memoria:list,
%!                  -Resultado) is det.
%
%   Como rastrear/5, pero cada línea da solo el ciclo, la regla y la
%   cantidad de instanciaciones nuevas.
rastrear_reglas(Programa, Estrategia, Hechos, Memoria, Resultado) :-
    ejecutar_produccion(Programa, Estrategia, breve, Hechos, _, Mt,
                        Resultado),
    hechos(Mt, Memoria).

%!  cantidad_de_ciclos(+Programa, +Estrategia, +Hechos:list,
%!                     -Ciclos:integer) is det.
%
%   Ciclos es la cantidad de reglas que dispara el Programa desde Hechos.
cantidad_de_ciclos(Programa, Estrategia, Hechos, Ciclos) :-
    ejecutar_produccion(Programa, Estrategia, sin_traza, Hechos, Ciclos, _,
                        _).

%!  ejecutar_produccion(+Programa, +Estrategia, +Traza, +Hechos:list,
%!                      -Ciclos:integer, -Memoria, -Resultado) is det.
%
%   Ejecuta el Programa desde Hechos. Ciclos es la cantidad de reglas
%   disparadas, y Memoria, la memoria final como término mt/2.
ejecutar_produccion(Programa, Estrategia, Traza, Hechos, Ciclos, Memoria,
                    Resultado) :-
    programa(Programa, Reglas),
    memoria_con(Hechos, Memoria0),
    reconocer_actuar(Reglas, Estrategia, Traza, 0, Ciclos, [], Memoria0,
                     Memoria, Resultado).

%!  reconocer_actuar(+Reglas:list, +Estrategia, +Traza, +N0:integer,
%!                   -N:integer, +Disparadas:list, +Memoria0, -Memoria,
%!                   -Resultado) is det.
%
%   Repite el ciclo desde Memoria0. N0 es la cantidad de ciclos hechos
%   antes, y N la cantidad al terminar. Traza es sin_traza, con_traza o
%   breve. Disparadas es el conjunto ordenado de las instanciaciones ya
%   disparadas, como pares Regla-Sellos.
reconocer_actuar(Reglas, Estrategia, Traza, N0, N, Disparadas, Memoria0,
                 Memoria, Resultado) :-
    conjunto_conflicto(Reglas, Memoria0, Todas),
    refractar(Todas, Disparadas, Nuevas),
    (   Nuevas == []
    ->  N = N0,
        Memoria = Memoria0,
        Resultado = nada_aplicable
    ;   preferida(Estrategia, Nuevas, Elegida),
        N1 is N0 + 1,
        informar(Traza, N1, Nuevas, Elegida, Memoria0),
        Elegida = instanciacion(Nombre, Sellos, _, Acciones),
        ord_add_element(Disparadas, Nombre-Sellos, Disparadas1),
        aplicar_acciones(Acciones, Memoria0, Memoria1, Fin),
        (   Fin = parar(R)
        ->  N = N1,
            Memoria = Memoria1,
            Resultado = R
        ;   reconocer_actuar(Reglas, Estrategia, Traza, N1, N, Disparadas1,
                             Memoria1, Memoria, Resultado)
        )
    ).

%!  conjunto_conflicto(+Reglas:list, +Memoria, -Instanciaciones:list) is det.
%
%   Instanciaciones tiene un término
%   instanciacion(Nombre, Sellos, Condiciones, Acciones) por cada regla y
%   cada manera de cumplir sus condiciones en Memoria: Sellos son los de
%   los hechos que cumplen sus patrones, en el orden de las condiciones, y
%   Condiciones, la cantidad de condiciones de la regla. Están en el orden
%   del programa y, dentro de una regla, del hecho más reciente al más
%   antiguo.
conjunto_conflicto(Reglas, Memoria, Instanciaciones) :-
    findall(instanciacion(Nombre, Sellos, N, Acciones),
            ( member(Nombre :: Condiciones ---> Acciones, Reglas),
              length(Condiciones, N),
              cumple(Condiciones, Memoria, Sellos)
            ),
            Instanciaciones).

%!  cumple(+Condiciones:list, +Memoria, -Sellos:list(integer)) is nondet.
%
%   Memoria cumple todas las Condiciones. Sellos son los sellos de los
%   hechos que cumplen los patrones, en el orden de las condiciones.
cumple([], _, []).
cumple([C|Cs], Memoria, Sellos) :-
    cumple_condicion(C, Memoria, Sellos, Resto),
    cumple(Cs, Memoria, Resto).

%!  cumple_condicion(+Condicion, +Memoria, -Sellos:list, ?Resto:list)
%!      is nondet.
%
%   Memoria cumple Condicion. Sellos es Resto precedida por el sello del
%   hecho que cumple un patrón; una prueba {Meta} y una negación no(F) no
%   agregan ninguno.
cumple_condicion({Meta}, _, Resto, Resto) :-
    call(Meta).
cumple_condicion(no(F), Memoria, Resto, Resto) :-
    \+ elemento(_, F, Memoria).
cumple_condicion(F, Memoria, [Sello|Resto], Resto) :-
    patron(F),
    elemento(Sello, F, Memoria).

%!  refractar(+Instanciaciones:list, +Disparadas:list, -Nuevas:list) is det.
%
%   Nuevas son las Instanciaciones que no están en el conjunto ordenado
%   Disparadas, comparadas por su regla y sus sellos.
refractar(Instanciaciones, Disparadas, Nuevas) :-
    exclude(disparada(Disparadas), Instanciaciones, Nuevas).

%!  disparada(+Disparadas:list, +Instanciacion) is semidet.
%
%   La Instanciacion ya se disparó: su par Regla-Sellos está en Disparadas.
disparada(Disparadas, instanciacion(Nombre, Sellos, _, _)) :-
    ord_memberchk(Nombre-Sellos, Disparadas).

%!  preferida(+Estrategia, +Instanciaciones:list, -Elegida) is det.
%
%   Elegida es la instanciación de mayor clave según la Estrategia; entre
%   dos de igual clave, la que aparece antes, porque sort/4 conserva el
%   orden de los empates.
preferida(Estrategia, Instanciaciones, Elegida) :-
    map_list_to_pairs(clave_estrategia(Estrategia), Instanciaciones, Pares),
    sort(1, @>=, Pares, [_-Elegida|_]).

%!  clave_estrategia(+Estrategia, +Instanciacion, -Clave) is det.
%
%   Clave ordena la Instanciacion según la Estrategia: se prefiere la mayor
%   en el orden estándar. Con orden todas empatan, y gana la primera del
%   conjunto de conflicto.
clave_estrategia(orden, _, 0).

%!  aplicar_acciones(+Acciones:list, +Memoria0, -Memoria, -Fin) is semidet.
%
%   Ejecuta las Acciones en orden. Fin es parar(R) si una de ellas es
%   parar(R), que deja sin ejecutar las siguientes, o seguir. Falla si una
%   acción quita un hecho que no está.
aplicar_acciones([], Memoria, Memoria, seguir).
aplicar_acciones([A|As], Memoria0, Memoria, Fin) :-
    (   A = parar(R)
    ->  Memoria = Memoria0,
        Fin = parar(R)
    ;   aplicar_accion(A, Memoria0, Memoria1),
        aplicar_acciones(As, Memoria1, Memoria, Fin)
    ).

%!  aplicar_accion(+Accion, +Memoria0, -Memoria) is semidet.
%
%   Memoria es Memoria0 después de una acción que no es parar/1: agregar un
%   hecho que ya está no cambia la memoria.
aplicar_accion({Meta}, Memoria, Memoria) :-
    once(Meta).
aplicar_accion(agregar(F), Memoria0, Memoria) :-
    afirmar(F, Memoria0, Memoria).
aplicar_accion(quitar(F), Memoria0, Memoria) :-
    retirar(F, Memoria0, Memoria).
aplicar_accion(reemplazar(F, G), Memoria0, Memoria) :-
    retirar(F, Memoria0, Memoria1),
    afirmar(G, Memoria1, Memoria).

%!  informar(+Traza, +N:integer, +Instanciaciones:list, +Elegida,
%!           +Memoria) is det.
%
%   Con con_traza, escribe el ciclo N: la regla elegida, cuántas
%   instanciaciones nuevas había y los hechos que usa, como pares
%   Sello-Hecho. Con breve, omite los hechos; con sin_traza no hace nada.
informar(sin_traza, _, _, _, _).
informar(breve, N, Instanciaciones, instanciacion(Nombre, _, _, _), _) :-
    length(Instanciaciones, Cantidad),
    format("~w: ~w de ~w~n", [N, Nombre, Cantidad]).
informar(con_traza, N, Instanciaciones, Elegida, Memoria) :-
    length(Instanciaciones, Cantidad),
    Elegida = instanciacion(Nombre, Sellos, _, _),
    findall(S-F, ( member(S, Sellos), elemento(S, F, Memoria) ), Usados),
    format("~w: ~w de ~w, con ~w~n", [N, Nombre, Cantidad, Usados]).

% El sistema experto hacia adelante del capítulo 20, sin la condición que
% impedía repetir una conclusión: la refracción y la memoria como conjunto
% la vuelven innecesaria.
programa(familia,
    [ progenitor_p :: [padre(P, H)] ---> [agregar(progenitor(P, H))],
      progenitor_m :: [madre(M, H)] ---> [agregar(progenitor(M, H))],
      abuelo :: [padre(A, P), progenitor(P, N)] ---> [agregar(abuelo(A, N))],
      hermanos :: [progenitor(P, A), progenitor(P, B), {A \== B}]
           ---> [agregar(hermanos(A, B))],
      antepasado_1 :: [progenitor(A, D)] ---> [agregar(antepasado(A, D))],
      antepasado_2 :: [progenitor(A, H), antepasado(H, D)]
           ---> [agregar(antepasado(A, D))]
    ]).

%!  familia(-Hechos:list) is det.
%
%   Hechos son los hechos iniciales de la familia del capítulo 20.
familia([padre(juan, ana), padre(juan, pedro), padre(pedro, luis),
         padre(pedro, eva), madre(marta, ana), madre(marta, pedro),
         madre(ana, sofia)]).

%!  contar_hechos(+Interprete, +Programa, +Hechos:list, -Resultado,
%!                -Cantidad:integer, -Distintos:integer) is det.
%
%   Ejecuta el Programa desde Hechos con uno de dos intérpretes:
%   capitulo_60, vigilar/6 del capítulo 60 con la estrategia primera y un
%   límite de 100 ciclos, o capitulo_63, encadenar/5 con la estrategia
%   orden. Cantidad es la cantidad de hechos de la memoria final, y
%   Distintos, la de hechos distintos.
contar_hechos(capitulo_60, Programa, Hechos, Resultado, Cantidad,
              Distintos) :-
    vigilar(Programa, primera, 100, Hechos, Memoria, Resultado),
    cantidades(Memoria, Cantidad, Distintos).
contar_hechos(capitulo_63, Programa, Hechos, Resultado, Cantidad,
              Distintos) :-
    encadenar(Programa, orden, Hechos, Memoria, Resultado),
    cantidades(Memoria, Cantidad, Distintos).

%!  cantidades(+Hechos:list, -Cantidad:integer, -Distintos:integer) is det.
%
%   Cantidad es la longitud de Hechos, y Distintos, la cantidad de hechos
%   distintos.
cantidades(Hechos, Cantidad, Distintos) :-
    length(Hechos, Cantidad),
    sort(Hechos, Sin),
    length(Sin, Distintos).
