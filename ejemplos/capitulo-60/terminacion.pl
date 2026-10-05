:- encoding(utf8).

% Capítulo 60 - Versión 5: vigilar la terminación.
%
% Un programa dirigido por patrones puede no terminar: porque la memoria
% crece sin fin o porque vuelve a un estado por el que ya pasó. vigilar/6
% ejecuta el ciclo de la versión 3 con dos controles: un límite de ciclos,
% y un registro de las memorias vistas, que detecta la repetición. Como la
% memoria es un término, compararla con las anteriores es comparar
% términos. Carga la versión 3.
%
% solo-local: carga conflictos.pl con ensure_loaded/1, y SWISH no permite
% cargar archivos.
%
%?- vigilar(luz, primera, 100, [luz(encendida)], M, R).
%?- vigilar(mcd_mal, primera, 100, [numero(25), numero(10)], M, R).

:- ensure_loaded(conflictos).
:- use_module(library(assoc)).

%!  vigilar(+Programa, +Estrategia, +Limite:integer, +Memoria0:list,
%!          -Memoria:list, -Resultado) is semidet.
%
%   Como ejecutar/5, con dos resultados más: limite(N) si el programa hizo
%   Limite ciclos sin terminar, y repetida(K, N) si la memoria después de
%   N ciclos es la misma, como colección de hechos, que después de K.
%   Falla si falla una acción de la instancia elegida.
vigilar(Programa, Estrategia, Limite, Memoria0, Memoria, Resultado) :-
    programa(Programa, Modulos),
    empty_assoc(Vistas),
    vigilado(Modulos, Estrategia, Limite, 0, Vistas, Memoria0, Memoria,
             Resultado).

%!  vigilado(+Modulos:list, +Estrategia, +Limite:integer, +N:integer,
%!           +Vistas, +Memoria0:list, -Memoria:list, -Resultado) is semidet.
%
%   Sigue el ciclo después de N ciclos. Vistas asocia cada memoria ya
%   vista, ordenada con msort/2, con el ciclo en que apareció. Falla si
%   falla una acción de la instancia elegida.
vigilado(Modulos, Estrategia, Limite, N, Vistas, Memoria0, Memoria,
         Resultado) :-
    msort(Memoria0, Clave),
    conflicto(Modulos, Memoria0, Instancias),
    (   get_assoc(Clave, Vistas, K)
    ->  Memoria = Memoria0,
        Resultado = repetida(K, N)
    ;   N >= Limite
    ->  Memoria = Memoria0,
        Resultado = limite(N)
    ;   Instancias == []
    ->  Memoria = Memoria0,
        Resultado = nada_aplicable
    ;   elegir(Estrategia, Memoria0, Instancias, Elegida),
        Elegida = instancia(_, _, _, Acciones),
        put_assoc(Clave, Vistas, N, Vistas1),
        acciones(Acciones, Memoria0, Memoria1, Fin),
        N1 is N + 1,
        (   Fin = parar(R)
        ->  Memoria = Memoria1,
            Resultado = R
        ;   vigilado(Modulos, Estrategia, Limite, N1, Vistas1, Memoria1,
                     Memoria, Resultado)
        )
    ).
