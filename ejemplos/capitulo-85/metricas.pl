:- encoding(utf8).

% Capítulo 85 - Las anomalías del capítulo 84 como reglas Datalog.
%
% El capítulo 84 resume un día de registros en cuatro métricas por hora y
% marca anómala una hora en la que una métrica pasa un límite. Aquí las
% métricas y los límites son hechos, medida(Hora, Metrica, Valor) y
% umbral(Metrica, Sentido, Limite), y las anomalías, reglas que el motor
% evalúa de abajo hacia arriba: las horas anómalas, las normales, con una
% negación, y las rachas de horas anómalas seguidas, con una recursión.
% anomalias_motor/2 da las mismas anomalías que anomalia/3 del capítulo
% 84.
%
% solo-local: carga módulos de otros capítulos y lee archivos.
%
%?- consulta_metricas(registros('2026-10-01.log'), racha(D, H), Rs, C).

:- module(metricas,
          [ reglas_metricas/1,
            programa_metricas/2,
            consulta_metricas/4,
            anomalias_motor/2,
            anomalias_capitulo84/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module('../capitulo-84/informes').
:- use_module(estratos).
:- use_module(magia, [respuestas/4]).

%!  reglas_metricas(-Reglas:list) is det.
%
%   Las reglas de las anomalías, en el orden en que el motor necesita las
%   variables ligadas.
reglas_metricas([
    (anomala(H, M, V) :- medida(H, M, V), umbral(M, mayor, L), V > L),
    (anomala(H, M, V) :- medida(H, M, V), umbral(M, menor, L), V < L),
    (hora_anomala(H) :- anomala(H, _, _)),
    (normal(H) :- medida(H, pedidos, _), \+ hora_anomala(H)),
    (racha(H, H) :- hora_anomala(H)),
    (racha(D, H1) :- racha(D, H), H1 is H + 1, hora_anomala(H1))
]).

%!  programa_metricas(+Archivo, -Clausulas:list) is det.
%
%   Clausulas son las métricas por hora de los pedidos de Archivo, como
%   hechos medida/3, los umbrales fijos del capítulo 84, como hechos
%   umbral/3, y las reglas de reglas_metricas/1.
programa_metricas(Archivo, Clausulas) :-
    leer_registro(Archivo, Pedidos),
    metricas(Pedidos, Horas),
    findall((medida(H, M, V) :- true),
            ( member(hora(H, Ms), Horas),
              metrica(M, Ms, V) ),
            Medidas),
    umbrales_fijos(Umbrales),
    findall((umbral(M, S, L) :- true),
            ( member(M-Limite, Umbrales),
              Limite =.. [S, L] ),
            Limites),
    reglas_metricas(Reglas),
    append([Medidas, Limites, Reglas], Clausulas).

%!  consulta_metricas(+Archivo, +Meta, -Respuestas:list, -Costo) is det.
%
%   Respuestas son las instancias de Meta en el modelo del programa de
%   Archivo, con respuestas/4; Costo, el de la evaluación.
consulta_metricas(Archivo, Meta, Respuestas, Costo) :-
    programa_metricas(Archivo, Clausulas),
    respuestas(Clausulas, Meta, Respuestas, Costo).

%!  anomalias_motor(+Archivo, -Anomalias:list) is det.
%
%   Anomalias son, ordenados, los términos H-Metrica-Valor de los átomos
%   anomala/3 del modelo del programa de Archivo.
anomalias_motor(Archivo, Anomalias) :-
    programa_metricas(Archivo, Clausulas),
    evaluar(Clausulas, Modelo, _),
    findall(H-M-V, member(anomala(H, M, V), Modelo), As),
    sort(As, Anomalias).

%!  anomalias_capitulo84(+Archivo, -Anomalias:list) is det.
%
%   Las mismas Anomalias, con anomalia/3 del capítulo 84 y los umbrales
%   fijos.
anomalias_capitulo84(Archivo, Anomalias) :-
    leer_registro(Archivo, Pedidos),
    metricas(Pedidos, Horas),
    umbrales_fijos(Umbrales),
    findall(H-M-V, anomalia(Umbrales, Horas, anomalia(H, M, V, _)), As),
    sort(As, Anomalias).
