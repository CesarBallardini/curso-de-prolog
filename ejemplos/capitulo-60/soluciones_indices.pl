:- encoding(utf8).

% Capítulo 60 - Solución del ejercicio 13: las fases como prioridades.
%
% La metarregla de la versión 6 trata las fases como etapas: una fase que
% ya terminó no vuelve a activarse. La de prioridades vuelve a examinar las
% fases desde la primera en cada ciclo, y aplica la primera que tiene algún
% módulo aplicable. Carga indices.pl y no lo modifica.
%
% solo-local: carga indices.pl con ensure_loaded/1.
%
%?- ejecutar_prioridades_de(contador_fases, primera, [contador(0)], M, R).

:- ensure_loaded(indices).

% programa_fases(contador_fases, Fases): limpiar quita los hechos
% ruido(I), contar aumenta el contador hasta 3 y deja un ruido(I) en cada
% paso, informar para con el contador.
programa_fases(contador_fases,
    [ limpiar - [ quitar_ruido :: [ruido(I)]
                       ---> [quitar(ruido(I))] ],
      contar - [ paso :: [contador(N), {N < 3}]
                       ---> [{M is N + 1},
                             reemplazar(contador(N), contador(M)),
                             agregar(ruido(M))] ],
      informar - [ fin :: [contador(N)]
                       ---> [parar(N)] ]
    ]).

%!  ejecutar_prioridades(+Fases:list, +Estrategia, +Hechos0:list,
%!                       -Hechos:list, -Resultado) is semidet.
%
%   Como ejecutar_fases/5, con otra metarregla: en cada ciclo se activa la
%   primera fase de Fases que tiene algún módulo aplicable. Resultado es el
%   de parar/1, o nada_aplicable si ninguna fase tiene módulos aplicables.
%   Falla si falla una acción de la instancia elegida.
ejecutar_prioridades(Fases, Estrategia, Hechos0, Hechos, Resultado) :-
    indexar(Hechos0, Memoria0),
    prioridades(Fases, Estrategia, Memoria0, Memoria, Resultado),
    hechos(Memoria, Hechos).

%!  ejecutar_prioridades_de(+Nombre, +Estrategia, +Hechos0:list,
%!                          -Hechos:list, -Resultado) is semidet.
%
%   Como ejecutar_prioridades/5, con el programa por fases llamado
%   Nombre, y falla en los mismos casos.
ejecutar_prioridades_de(Nombre, Estrategia, Hechos0, Hechos, Resultado) :-
    programa_fases(Nombre, Fases),
    ejecutar_prioridades(Fases, Estrategia, Hechos0, Hechos, Resultado).

%!  prioridades(+Fases:list, +Estrategia, +Memoria0, -Memoria,
%!              -Resultado) is semidet.
%
%   Aplica una instancia de la primera fase con instancias, y vuelve a
%   empezar desde la primera fase, hasta parar/1 o hasta que ninguna fase
%   tiene instancias. Falla si falla una acción de la instancia elegida.
prioridades(Fases, Estrategia, Memoria0, Memoria, Resultado) :-
    (   primera_fase(Fases, Memoria0, Instancias)
    ->  elegir_i(Estrategia, Instancias, instancia(_, _, _, Acciones)),
        acciones_i(Acciones, Memoria0, Memoria1, Fin),
        (   Fin = parar(R)
        ->  Memoria = Memoria1,
            Resultado = R
        ;   prioridades(Fases, Estrategia, Memoria1, Memoria, Resultado)
        )
    ;   Memoria = Memoria0,
        Resultado = nada_aplicable
    ).

%!  primera_fase(+Fases:list, +Memoria, -Instancias:list) is semidet.
%
%   Instancias es el conjunto de conflicto, no vacío, de la primera fase de
%   Fases que tiene alguno. Falla si ninguna lo tiene.
primera_fase([_-Modulos|Fases], Memoria, Instancias) :-
    conflicto_i(Modulos, Memoria, Instancias0),
    (   Instancias0 == []
    ->  primera_fase(Fases, Memoria, Instancias)
    ;   Instancias = Instancias0
    ).
