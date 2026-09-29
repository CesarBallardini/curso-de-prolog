:- encoding(utf8).

% Capítulo 49 - Versión 5: la próxima medición.
%
% Con varios diagnósticos mínimos, conviene elegir la próxima entrada que
% se aplica al circuito. En el modelo fuerte, cada diagnóstico predice las
% salidas de cada entrada; una entrada separa los diagnósticos en grupos,
% uno por salida predicha, y la mejor es la que minimiza el tamaño del
% grupo más grande: sea cual sea la salida observada, quedan a lo sumo esos
% candidatos. localizar/5 repite el ciclo, midiendo sobre un circuito con
% una avería oculta, hasta que ninguna entrada separa a los candidatos.
%
% solo-local: carga módulos propios, y SWISH no los admite.
%
%?- localizar(sumador, [[o1]-pegada(1)], [[0, 0, 0]-[0, 1]], Obs, Ds).

:- module(medicion,
          [ predecir/4,
            proxima/4,
            localizar/5
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(fallas).
:- reexport(minimos).

%!  predecir(+Circuito, +Entradas:list, +Fallas:list(pair),
%!      -Salidas:list) is semidet.
%
%   Salidas son las salidas de Circuito con las Entradas y las Fallas del
%   modelo fuerte, que dan una sola respuesta.
predecir(Circuito, Entradas, Fallas, Salidas) :-
    once(simular(con_fallas(Fallas), Circuito, Entradas, Salidas)).

%!  proxima(+Circuito, +Diagnosticos:list(list), -Entradas:list,
%!      -Peor:integer) is semidet.
%
%   Entradas es la combinación de entradas de Circuito que minimiza Peor,
%   la cantidad de Diagnosticos que predicen la salida más predicha; ante
%   un empate, la primera en orden binario.
proxima(Circuito, Diagnosticos, Entradas, Peor) :-
    circuito(Circuito, Nombres, _),
    same_length(Nombres, Es),
    findall(P-Es,
            ( maplist(bit, Es),
              peor_grupo(Circuito, Diagnosticos, Es, P) ),
            Puntajes),
    keysort(Puntajes, [Peor-Entradas|_]).

%!  peor_grupo(+Circuito, +Diagnosticos:list(list), +Entradas:list,
%!      -Peor:integer) is det.
%
%   Peor es el tamaño del grupo más grande de Diagnosticos que predicen
%   las mismas salidas con Entradas.
peor_grupo(Circuito, Diagnosticos, Entradas, Peor) :-
    maplist(predecir(Circuito, Entradas), Diagnosticos, Predichas),
    msort(Predichas, Ordenadas),
    clumped(Ordenadas, Grupos),
    pairs_values(Grupos, Tamanos),
    max_list(Tamanos, Peor).

%!  localizar(+Circuito, +Averia:list(pair), +Observaciones0:list(pair),
%!      -Observaciones:list(pair), -Candidatos:list(list)) is det.
%
%   Partiendo de las Observaciones0 de Circuito, que tiene las fallas
%   Averia, se mide con la próxima entrada mientras separe a los
%   diagnósticos mínimos con a lo sumo dos fallas. Observaciones son todas
%   las mediciones, la última primero, y Candidatos, los diagnósticos que
%   ninguna entrada separa.
localizar(Circuito, Averia, Observaciones0, Observaciones, Candidatos) :-
    minimos(fuerte, Circuito, Observaciones0, 2, Diagnosticos),
    (   proxima(Circuito, Diagnosticos, Entradas, Peor),
        length(Diagnosticos, N),
        Peor < N
    ->  predecir(Circuito, Entradas, Averia, Salidas),
        localizar(Circuito, Averia, [Entradas-Salidas|Observaciones0],
                  Observaciones, Candidatos)
    ;   Observaciones = Observaciones0,
        Candidatos = Diagnosticos
    ).
