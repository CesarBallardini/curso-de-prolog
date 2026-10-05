:- encoding(utf8).

% Capítulo 84 - Versión 4: umbrales ajustados a partir de los datos.
%
% Los límites de la versión 3 se escriben a mano. Aquí se calculan con las
% horas de días de referencia, con dos modelos. El de la media y el desvío
% (Denning, 1987): un valor es anómalo si se aleja de la media más de D
% desvíos. El de la mediana y la desviación absoluta mediana (MAD): un
% valor es anómalo si su puntaje z modificado, 0.6745 (x - mediana) / MAD,
% pasa de Z en valor absoluto (Iglewicz y Hoaglin; 3.5 en el manual del
% NIST). La media y el desvío se desplazan con los mismos valores anómalos
% que deben detectar; la mediana y la MAD, no.
%
% solo-local: lee archivos y carga informes.pl.
%
%?- referencia(Horas), umbrales(media_desvio(3), Horas, U).

:- module(umbrales,
          [ dias_de_referencia/1,
            referencia/1,
            valores/3,
            valores_de_referencia/2,
            media_desvio/3,
            mediana/2,
            mad/3,
            ajustar/3,
            umbrales/3,
            umbrales_de_referencia/2,
            umbrales_del_dia/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- reexport(informes).

% dias_de_referencia(Archivos): los registros con los que se ajustan los
% umbrales.
dias_de_referencia([ registros('2026-09-28.log'),
                     registros('2026-09-29.log'),
                     registros('2026-09-30.log')
                   ]).

%!  referencia(-Horas:list) is det.
%
%   Horas son las métricas por hora de todos los días de referencia, una
%   lista de hora(H, Metricas) por día, concatenadas.
referencia(Horas) :-
    dias_de_referencia(Archivos),
    maplist(horas_del_dia, Archivos, Listas),
    append(Listas, Horas).

% horas_del_dia(Archivo, Horas): las métricas por hora de un registro.
horas_del_dia(Archivo, Horas) :-
    leer_registro(Archivo, Pedidos),
    metricas(Pedidos, Horas).

%!  valores(+Metrica, +Horas:list, -Valores:list(number)) is det.
%
%   Valores son los de la Metrica en cada una de las Horas.
valores(Metrica, Horas, Valores) :-
    maplist(valor(Metrica), Horas, Valores).

% valor(Metrica, hora(H, Ms), V): V es la Metrica de la hora.
valor(Metrica, hora(_, Ms), V) :-
    metrica(Metrica, Ms, V).

%!  valores_de_referencia(+Metrica, -Valores:list(number)) is det.
%
%   Valores son los de la Metrica en las horas de los días de referencia.
valores_de_referencia(Metrica, Valores) :-
    referencia(Horas),
    valores(Metrica, Horas, Valores).

%!  media_desvio(+Valores:list(number), -Media:float, -Desvio:float) is det.
%
%   Media es la media de los Valores y Desvio su desvío estándar, la raíz
%   de la media de los cuadrados menos el cuadrado de la media. Valores no
%   es vacía.
media_desvio(Valores, Media, Desvio) :-
    length(Valores, N),
    sum_list(Valores, Suma),
    foldl(sumar_cuadrado, Valores, 0, Cuadrados),
    Media is Suma / N,
    Desvio is sqrt(max(0, Cuadrados / N - Media ** 2)).

% sumar_cuadrado(X, S0, S): S es S0 + X².
sumar_cuadrado(X, S0, S) :-
    S is S0 + X * X.

%!  mediana(+Valores:list(number), -Mediana:number) is det.
%
%   Mediana es el valor del medio de los Valores ordenados, o la media de
%   los dos del medio si son una cantidad par. Valores no es vacía.
mediana(Valores, Mediana) :-
    msort(Valores, Ordenados),
    length(Ordenados, N),
    (   N mod 2 =:= 1
    ->  K is N // 2,
        nth0(K, Ordenados, Mediana)
    ;   K is N // 2 - 1,
        nth0(K, Ordenados, A),
        K1 is K + 1,
        nth0(K1, Ordenados, B),
        Mediana is (A + B) / 2
    ).

%!  mad(+Valores:list(number), -Mediana:number, -Mad:number) is det.
%
%   Mediana es la mediana de los Valores, y Mad la mediana de las
%   distancias de cada valor a ella: la desviación absoluta mediana.
mad(Valores, Mediana, Mad) :-
    mediana(Valores, Mediana),
    maplist(distancia(Mediana), Valores, Distancias),
    mediana(Distancias, Mad).

% distancia(M, X, D): D es |X - M|.
distancia(M, X, D) :-
    D is abs(X - M).

%!  ajustar(+Modelo, +Valores:list(number), -Intervalo) is det.
%
%   Intervalo es entre(Inferior, Superior): los valores normales según el
%   Modelo, ajustado con los Valores. Con media_desvio(D), la media más o
%   menos D desvíos; con mediana_mad(Z), los valores cuyo puntaje z
%   modificado no pasa de Z en valor absoluto, es decir, la mediana más o
%   menos Z · Mad / 0.6745.
ajustar(media_desvio(D), Valores, entre(Inferior, Superior)) :-
    media_desvio(Valores, Media, Desvio),
    Inferior is Media - D * Desvio,
    Superior is Media + D * Desvio.
ajustar(mediana_mad(Z), Valores, entre(Inferior, Superior)) :-
    mad(Valores, Mediana, Mad),
    Ancho is Z * Mad / 0.6745,
    Inferior is Mediana - Ancho,
    Superior is Mediana + Ancho.

%!  umbrales(+Modelo, +Horas:list, -Umbrales:list) is det.
%
%   Umbrales son los límites, con la forma de los de la versión 3, para
%   los pedidos, los fallos y el tiempo de CPU, ajustados con el Modelo a
%   las métricas de las Horas. Los pedidos tienen límite inferior y
%   superior; las otras dos, solo superior, porque un valor bajo no es
%   anómalo.
umbrales(Modelo, Horas, [ pedidos-menor(PI), pedidos-mayor(PS),
                          fallos-mayor(FS), cpu-mayor(CS) ]) :-
    valores(pedidos, Horas, Ps),
    ajustar(Modelo, Ps, entre(PI, PS)),
    valores(fallos, Horas, Fs),
    ajustar(Modelo, Fs, entre(_, FS)),
    valores(cpu, Horas, Cs),
    ajustar(Modelo, Cs, entre(_, CS)).

%!  umbrales_de_referencia(+Modelo, -Umbrales:list) is det.
%
%   Umbrales son los de umbrales/3 ajustados con el Modelo a las horas de
%   los días de referencia.
umbrales_de_referencia(Modelo, Umbrales) :-
    referencia(Horas),
    umbrales(Modelo, Horas, Umbrales).

%!  umbrales_del_dia(+Modelo, +Archivo, -Umbrales:list) is det.
%
%   Umbrales son los de umbrales/3 ajustados con el Modelo a las horas del
%   mismo registro Archivo que se va a examinar.
umbrales_del_dia(Modelo, Archivo, Umbrales) :-
    leer_registro(Archivo, Pedidos),
    metricas(Pedidos, Horas),
    umbrales(Modelo, Horas, Umbrales).
