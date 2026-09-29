:- encoding(utf8).

% Capítulo 69 - Versión 3: separables o en ciclo.
%
% Con entradas enteras y una tasa entera, los pesos son enteros y el
% entrenamiento no puede producir infinitos pesos distintos dentro de una
% región acotada: si los ejemplos no son separables, los pesos del final
% de una época terminan por repetirse, y desde allí todo se repite. El
% estado de iterar/5 lleva los pesos y la historia de los pesos ya
% vistos, y el ciclo se detiene cuando los pesos se repiten. Una época sin
% errores es el caso de un ciclo de largo 1: los pesos no cambiaron.
%
% solo-local: carga los programas de los capítulos 32 y 46, y SWISH no
% carga otros archivos.
%
%?- probar(o_exclusivo, R).
%?- no_separables(Tablas).

:- ensure_loaded(epocas).

%!  paso_con_memoria(+Tasa, +Ejemplos, +Estado0, -Estado, -Resultado,
%!                   -Cambio:integer) is det.
%
%   El paso para iterar/5: Estado0 es Pesos0-Vistos, con Vistos los pesos
%   de las épocas anteriores; Estado es Pesos-[Pesos0|Vistos], Resultado
%   es Errores-Pesos, y Cambio es 0 si Pesos ya estaba entre los vistos, o
%   1 si no.
paso_con_memoria(Tasa, Ejemplos, Pesos0-Vistos, Pesos-[Pesos0|Vistos],
                 Errores-Pesos, Cambio) :-
    epoca(Tasa, Ejemplos, Pesos0, Pesos, Errores),
    (   memberchk(Pesos, [Pesos0|Vistos])
    ->  Cambio = 0
    ;   Cambio = 1
    ).

%!  entrenar_o_ciclo(+Tasa:number, +Ejemplos:list, +Pesos0:list,
%!                   -Resultado) is semidet.
%
%   Resultado es separa(Pesos, Curva) si una época termina sin errores,
%   con Pesos los pesos finales, o ciclo(Largo, Curva) si los pesos del
%   final de una época repiten los de Largo épocas antes con errores.
%   Curva son los errores de cada época. Falla si los pesos no se repiten
%   en maximo_de_epocas/1 épocas, lo que puede ocurrir con pesos de punto
%   flotante.
entrenar_o_ciclo(Tasa, Ejemplos, Pesos0, Resultado) :-
    maximo_de_epocas(Maximo),
    iterar(paso_con_memoria(Tasa, Ejemplos), 0, Maximo, Pesos0-[],
           Resultados),
    pairs_keys_values(Resultados, Curva, Sucesion),
    last(Curva, Errores),
    last(Sucesion, Pesos),
    (   Errores =:= 0
    ->  Resultado = separa(Pesos, Curva)
    ;   reverse([Pesos0|Sucesion], [Ultimo|Anteriores]),
        once(nth1(Largo, Anteriores, Ultimo)),
        Resultado = ciclo(Largo, Curva)
    ).

%!  probar(+Nombre:atom, -Resultado) is semidet.
%
%   Resultado es el de entrenar_o_ciclo/4 para el conjunto Nombre de
%   datos/2, desde pesos nulos y con tasa 1.
probar(Nombre, Resultado) :-
    datos(Nombre, Ejemplos),
    pesos_nulos(Ejemplos, Pesos0),
    entrenar_o_ciclo(1, Ejemplos, Pesos0, Resultado).

%!  pesos_nulos(+Ejemplos:list, -Pesos:list) is det.
%
%   Pesos son ceros, uno para el sesgo y uno por cada entrada del primero
%   de los Ejemplos.
pesos_nulos([ej(Xs, _)|_], [0|Pesos]) :-
    maplist(cero, Xs, Pesos).

%!  cero(+X, -Cero:integer) is det.
%
%   Cero es 0, para cualquier X.
cero(_, 0).

%!  tabla(?Clases:list) is multi.
%
%   Clases es la columna de una función lógica de dos entradas: las clases
%   de [0, 0], [0, 1], [1, 0] y [1, 1], cada una 1 o -1. Hay 16.
tabla(Clases) :-
    length(Clases, 4),
    maplist(clase, Clases).

% clase(C): C es una de las dos clases.
clase(-1).
clase(1).

%!  ejemplos_de(+Clases:list, -Ejemplos:list) is det.
%
%   Ejemplos son los de la función lógica de columna Clases.
ejemplos_de(Clases, Ejemplos) :-
    maplist(ejemplo_de, [[0, 0], [0, 1], [1, 0], [1, 1]], Clases,
            Ejemplos).

%!  ejemplo_de(+Entradas, +Clase, -Ejemplo) is det.
%
%   Ejemplo es ej(Entradas, Clase).
ejemplo_de(Xs, D, ej(Xs, D)).

%!  no_separables(-Tablas:list) is det.
%
%   Tablas son las columnas de las funciones lógicas de dos entradas con
%   las que el entrenamiento, desde pesos nulos y con tasa 1, entra en
%   ciclo.
no_separables(Tablas) :-
    findall(Clases,
            ( tabla(Clases),
              ejemplos_de(Clases, Ejemplos),
              entrenar_o_ciclo(1, Ejemplos, [0, 0, 0], ciclo(_, _))
            ),
            Tablas).
