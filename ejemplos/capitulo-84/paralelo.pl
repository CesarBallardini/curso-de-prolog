:- encoding(utf8).

% Capítulo 84 - Versión 6: resúmenes que se combinan, calculados en paralelo.
%
% Ajustar un umbral con muchos días de registro obliga a leerlos todos. Si
% cada día se resume en un término que no depende de los otros, los días se
% leen en paralelo, uno por hilo, y los resúmenes se combinan después. Para
% la media y el desvío alcanzan la cantidad, la suma y la suma de los
% cuadrados, que se combinan sumando (los parámetros del perfil de
% Denning). La mediana no se combina así: necesita los valores, y el
% resumen guarda su histograma, los pares Valor-Veces, que se combinan
% sumando las veces de cada valor.
%
% solo-local: lee archivos y usa hilos.
%
%?- dias_de_referencia(As), resumir_en_paralelo(fallos, As, R).

:- module(paralelo,
          [ resumir/3,
            combinar/3,
            resumir_en_serie/3,
            resumir_en_paralelo/3,
            ajustar_resumen/3,
            mediana_histograma/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(library(thread)).
:- reexport(umbrales).

%!  resumir(+Metrica, +Archivo, -Resumen) is det.
%
%   Resumen es r(N, Suma, Cuadrados, Histograma) de los valores de la
%   Metrica en las horas del registro Archivo: la cantidad, la suma, la
%   suma de los cuadrados, y los pares Valor-Veces, ordenados por valor.
resumir(Metrica, Archivo, r(N, Suma, Cuadrados, Histograma)) :-
    leer_registro(Archivo, Pedidos),
    metricas(Pedidos, Horas),
    valores(Metrica, Horas, Valores),
    length(Valores, N),
    sum_list(Valores, Suma),
    foldl(sumar_cuadrado, Valores, 0, Cuadrados),
    msort(Valores, Ordenados),
    clumped(Ordenados, Histograma).

% sumar_cuadrado(X, S0, S): S es S0 + X².
sumar_cuadrado(X, S0, S) :-
    S is S0 + X * X.

%!  combinar(+R1, +R2, -R) is det.
%
%   R resume los valores de R1 y los de R2 juntos.
combinar(r(N1, S1, Q1, H1), r(N2, S2, Q2, H2), r(N, S, Q, H)) :-
    N is N1 + N2,
    S is S1 + S2,
    Q is Q1 + Q2,
    mezclar(H1, H2, H).

% mezclar(H1, H2, H): H es la unión de los histogramas H1 y H2, con las
% veces de un valor común sumadas.
mezclar([], H, H) :- !.
mezclar(H, [], H) :- !.
mezclar([V1-K1|R1], [V2-K2|R2], H) :-
    compare(Orden, V1, V2),
    mezclar(Orden, V1-K1, R1, V2-K2, R2, H).

% mezclar(Orden, P1, R1, P2, R2, H): un paso de mezclar/3, según el Orden
% de los valores de los primeros pares.
mezclar(<, P1, R1, P2, R2, [P1|H]) :-
    mezclar(R1, [P2|R2], H).
mezclar(>, P1, R1, P2, R2, [P2|H]) :-
    mezclar([P1|R1], R2, H).
mezclar(=, V-K1, R1, V-K2, R2, [V-K|H]) :-
    K is K1 + K2,
    mezclar(R1, R2, H).

%!  resumir_en_serie(+Metrica, +Archivos:list, -Resumen) is det.
%
%   Resumen resume la Metrica en todos los Archivos, leídos uno tras otro.
%   Archivos no es vacía.
resumir_en_serie(Metrica, [A|As], Resumen) :-
    maplist(resumir(Metrica), [A|As], [R|Rs]),
    foldl(combinar, Rs, R, Resumen).

%!  resumir_en_paralelo(+Metrica, +Archivos:list, -Resumen) is det.
%
%   Como resumir_en_serie/3, con cada archivo leído en un hilo.
resumir_en_paralelo(Metrica, [A|As], Resumen) :-
    concurrent_maplist(resumir(Metrica), [A|As], [R|Rs]),
    foldl(combinar, Rs, R, Resumen).

%!  ajustar_resumen(+Modelo, +Resumen, -Intervalo) is det.
%
%   Como ajustar/3 de la versión 4, con los valores dados por su Resumen.
%   La media y el desvío salen de la cantidad, la suma y los cuadrados; la
%   mediana y la MAD, del histograma.
ajustar_resumen(media_desvio(D), r(N, S, Q, _), entre(Inferior, Superior)) :-
    Media is S / N,
    Desvio is sqrt(max(0, Q / N - Media ** 2)),
    Inferior is Media - D * Desvio,
    Superior is Media + D * Desvio.
ajustar_resumen(mediana_mad(Z), r(N, _, _, H), entre(Inferior, Superior)) :-
    mediana_histograma(H, N, Mediana),
    maplist(distancia_par(Mediana), H, Distancias0),
    keysort(Distancias0, Distancias1),
    sumar_iguales(Distancias1, Distancias),
    mediana_histograma(Distancias, N, Mad),
    Ancho is Z * Mad / 0.6745,
    Inferior is Mediana - Ancho,
    Superior is Mediana + Ancho.

% distancia_par(M, V-K, D-K): D es la distancia de V a M.
distancia_par(M, V-K, D-K) :-
    D is abs(V - M).

% sumar_iguales(Pares, H): H son los Pares ordenados, con las veces de las
% claves iguales sumadas.
sumar_iguales(Pares, H) :-
    group_pairs_by_key(Pares, Grupos),
    maplist(sumar_grupo, Grupos, H).

% sumar_grupo(V-Ks, V-K): K es la suma de Ks.
sumar_grupo(V-Ks, V-K) :-
    sum_list(Ks, K).

%!  mediana_histograma(+Histograma:list, +N:integer, -Mediana:number) is det.
%
%   Mediana es la mediana de los N valores del Histograma, con sus pares
%   ordenados por valor: el valor de la posición del medio, o la media de
%   los dos del medio si N es par.
mediana_histograma(H, N, Mediana) :-
    (   N mod 2 =:= 1
    ->  K is N // 2,
        posicion(H, K, Mediana)
    ;   K is N // 2 - 1,
        posicion(H, K, A),
        K1 is K + 1,
        posicion(H, K1, B),
        Mediana is (A + B) / 2
    ).

% posicion(H, K, V): V es el valor de la posición K, desde 0, de los
% valores del histograma H puestos en orden.
posicion([V-Veces|Resto], K, Valor) :-
    (   K < Veces
    ->  Valor = V
    ;   K1 is K - Veces,
        posicion(Resto, K1, Valor)
    ).
