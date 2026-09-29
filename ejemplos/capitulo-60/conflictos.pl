:- encoding(utf8).

% Capítulo 60 - Versión 3: el conjunto de conflicto.
%
% Cada ciclo reúne todas las instancias aplicables: cada módulo con cada
% combinación de hechos que cumple sus condiciones. Una estrategia elige
% una: primera (el orden del programa), reciente (la que usa el hecho más
% reciente) o especifica (la del módulo con más condiciones). Cada
% estrategia es una clave de orden, y otro archivo puede agregar claves a
% clave/4. trazar/5 escribe una línea por ciclo. Carga la versión 2 y usa
% su satisface/3 y su acciones/4.
%
% solo-local: carga ciclo.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- ejecutar(mcd_invertido, especifica, [numero(25), numero(10)], M, R).
%?- trazar(mcd, primera, [numero(25), numero(10)], M, R).

:- ensure_loaded(ciclo).

% Otros archivos agregan estrategias.
:- multifile clave/4.

%!  ejecutar(+Programa, +Estrategia, +Memoria0:list, -Memoria:list,
%!           -Resultado) is det.
%
%   Ejecuta el Programa desde Memoria0 eligiendo en cada ciclo una
%   instancia del conjunto de conflicto con la Estrategia: primera,
%   reciente o especifica.
ejecutar(Programa, Estrategia, Memoria0, Memoria, Resultado) :-
    programa(Programa, Modulos),
    ciclo(Modulos, Estrategia, sin_traza, 0, _, Memoria0, Memoria,
          Resultado).

%!  trazar(+Programa, +Estrategia, +Memoria0:list, -Memoria:list,
%!         -Resultado) is det.
%
%   Como ejecutar/5, y escribe una línea por ciclo: el número del ciclo,
%   el tamaño del conjunto de conflicto, el módulo elegido y los hechos que
%   usa.
trazar(Programa, Estrategia, Memoria0, Memoria, Resultado) :-
    programa(Programa, Modulos),
    ciclo(Modulos, Estrategia, con_traza, 0, _, Memoria0, Memoria,
          Resultado).

%!  ciclos(+Programa, +Estrategia, +Memoria0:list, -Ciclos:integer) is det.
%
%   Ciclos es la cantidad de ciclos que aplican un módulo en la ejecución
%   del Programa con la Estrategia desde Memoria0.
ciclos(Programa, Estrategia, Memoria0, Ciclos) :-
    programa(Programa, Modulos),
    ciclo(Modulos, Estrategia, sin_traza, 0, Ciclos, Memoria0, _, _).

%!  ciclo(+Modulos:list, +Estrategia, +Traza, +N0:integer, -N:integer,
%!        +Memoria0:list, -Memoria:list, -Resultado) is det.
%
%   Repite el ciclo de reconocimiento y acción desde Memoria0. N0 es la
%   cantidad de ciclos hechos antes, y N la cantidad al terminar. Traza es
%   con_traza o sin_traza.
ciclo(Modulos, Estrategia, Traza, N0, N, Memoria0, Memoria, Resultado) :-
    conflicto(Modulos, Memoria0, Instancias),
    (   Instancias == []
    ->  N = N0,
        Memoria = Memoria0,
        Resultado = nada_aplicable
    ;   elegir(Estrategia, Memoria0, Instancias, Elegida),
        N1 is N0 + 1,
        mostrar(Traza, N1, Instancias, Elegida, Memoria0),
        Elegida = instancia(_, _, _, Acciones),
        acciones(Acciones, Memoria0, Memoria1, Fin),
        (   Fin = parar(R)
        ->  N = N1,
            Memoria = Memoria1,
            Resultado = R
        ;   ciclo(Modulos, Estrategia, Traza, N1, N, Memoria1, Memoria,
                  Resultado)
        )
    ).

%!  conflicto(+Modulos:list, +Memoria:list, -Instancias:list) is det.
%
%   Instancias es el conjunto de conflicto: un término
%   instancia(Nombre, Condiciones, Posiciones, Acciones) por cada módulo y
%   cada manera de cumplir sus condiciones en Memoria, en el orden del
%   programa y, dentro de un módulo, en el orden de la memoria.
conflicto(Modulos, Memoria, Instancias) :-
    findall(instancia(Nombre, N, Posiciones, Acciones),
            ( member(Modulo, Modulos),
              copy_term(Modulo, Nombre :: Condiciones ---> Acciones),
              length(Condiciones, N),
              satisface(Condiciones, Memoria, Posiciones)
            ),
            Instancias).

%!  elegir(+Estrategia, +Memoria:list, +Instancias:list, -Elegida) is det.
%
%   Elegida es la instancia de Instancias, que no es vacía, con la menor
%   clave según la Estrategia; entre dos de igual clave, la que aparece
%   antes en Instancias, porque keysort/2 conserva el orden de los empates.
elegir(Estrategia, Memoria, Instancias, Elegida) :-
    length(Memoria, Largo),
    map_list_to_pairs(clave(Estrategia, Largo), Instancias, Pares),
    keysort(Pares, [_-Elegida|_]).

%!  clave(+Estrategia, +Largo:integer, +Instancia, -Clave) is det.
%
%   Clave ordena la Instancia según la Estrategia, en una memoria de Largo
%   hechos: una clave menor se prefiere. Con primera todas empatan; con
%   reciente, la clave es la posición del hecho más reciente que usa la
%   instancia, o Largo si no usa ninguno; con especifica, la cantidad de
%   condiciones del módulo, con el signo cambiado.
clave(primera, _, _, 0).
clave(reciente, Largo, instancia(_, _, Posiciones, _), Clave) :-
    min_list([Largo|Posiciones], Clave).
clave(especifica, _, instancia(_, N, _, _), Clave) :-
    Clave is -N.

%!  mostrar(+Traza, +N:integer, +Instancias:list, +Elegida, +Memoria:list)
%!      is det.
%
%   Con con_traza, escribe el ciclo N: cuántas instancias hay, cuál se
%   eligió y los hechos de Memoria que usa. Con sin_traza no hace nada.
mostrar(sin_traza, _, _, _, _).
mostrar(con_traza, N, Instancias, Elegida, Memoria) :-
    length(Instancias, Cantidad),
    Elegida = instancia(Nombre, _, Posiciones, _),
    findall(F, ( member(I, Posiciones), nth0(I, Memoria, F) ), Hechos),
    format("~w: ~w de ~w, con ~w~n", [N, Nombre, Cantidad, Hechos]).
