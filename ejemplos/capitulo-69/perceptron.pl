:- encoding(utf8).

% Capítulo 69 - Versión 1: el perceptrón y su regla de aprendizaje.
%
% Un perceptrón clasifica un punto por el signo de una suma pesada de sus
% coordenadas más un sesgo. Los pesos son una lista [W0, W1, ..., Wn]: W0
% es el sesgo, que multiplica a una entrada fija igual a 1. Un ejemplo es
% ej(Entradas, Clase), con Clase igual a 1 o a -1. Esta versión entrena de
% a un ejemplo por vez: corrige los pesos con el primero de la lista, lo
% pasa al final y se detiene cuando todos los ejemplos quedan bien
% clasificados. No tiene un límite de pasos.
%
%?- pasos(y, 1, [0, 0, 0], Pesos, Pasos).
%?- salida([-3, 2, 2], [1, 1], Clase).

:- use_module(library(apply)).
:- use_module(library(lists)).

% datos(Nombre, Ejemplos): Ejemplos es un conjunto de entrenamiento.
% y, o, o_exclusivo: las funciones lógicas de dos entradas 0 y 1, con 1
% para verdadero y -1 para falso. puntos: ocho puntos del plano, de dos
% clases (tabla 1.4 de Csenki, «Prolog Techniques»).
datos(y, [ej([0, 0], -1), ej([0, 1], -1), ej([1, 0], -1), ej([1, 1], 1)]).
datos(o, [ej([0, 0], -1), ej([0, 1], 1), ej([1, 0], 1), ej([1, 1], 1)]).
datos(o_exclusivo,
      [ej([0, 0], -1), ej([0, 1], 1), ej([1, 0], 1), ej([1, 1], -1)]).
datos(puntos,
      [ ej([6.981, 0.554], -1), ej([14.414, 4.466], 1),
        ej([2.337, 4.040], -1), ej([8.500, 3.496], 1),
        ej([9.190, 2.000], -1), ej([1.149, 6.100], -1),
        ej([14.786, 2.179], 1), ej([7.842, 6.331], 1)
      ]).

%!  salida(+Pesos:list(number), +Entradas:list(number), -Clase) is det.
%
%   Clase es 1 si W0 + W1·X1 + ... + Wn·Xn es mayor o igual que cero, y -1
%   si es negativo. Pesos es [W0, W1, ..., Wn] y Entradas [X1, ..., Xn].
salida([W0|Ws], Xs, Clase) :-
    foldl(sumar_producto, Ws, Xs, W0, S),
    (   S >= 0
    ->  Clase = 1
    ;   Clase = -1
    ).

%!  sumar_producto(+W:number, +X:number, +S0:number, -S:number) is det.
%
%   S es S0 + W·X.
sumar_producto(W, X, S0, S) :-
    S is S0 + W * X.

%!  corregir(+Tasa:number, +Ejemplo, +Pesos0:list, -Pesos:list) is det.
%
%   Pesos son los Pesos0 corregidos por la regla del perceptrón con el
%   Ejemplo ej(Xs, D): si la salida Y es D, no cambian; si no, cada peso
%   Wi suma Tasa·(D - Y)·Xi, con X0 = 1 para el sesgo.
corregir(Tasa, ej(Xs, D), Pesos0, Pesos) :-
    salida(Pesos0, Xs, Y),
    (   Y =:= D
    ->  Pesos = Pesos0
    ;   K is Tasa * (D - Y),
        maplist(ajustar(K), Pesos0, [1|Xs], Pesos)
    ).

%!  ajustar(+K:number, +W0:number, +X:number, -W:number) is det.
%
%   W es W0 + K·X.
ajustar(K, W0, X, W) :-
    W is W0 + K * X.

%!  bien_clasificado(+Pesos:list, +Ejemplo) is semidet.
%
%   Pesos da al Ejemplo ej(Xs, D) la clase D.
bien_clasificado(Pesos, ej(Xs, D)) :-
    salida(Pesos, Xs, Y),
    Y =:= D.

%!  entrenar_uno(+Tasa:number, +Ejemplos:list, +Pesos0:list, -Pesos:list,
%!               -Pasos:integer) is det.
%
%   Pesos clasifican bien todos los Ejemplos, y se obtienen desde Pesos0
%   aplicando corregir/4 Pasos veces, con un ejemplo por vez en orden
%   circular. Si los ejemplos no son linealmente separables, no termina.
entrenar_uno(Tasa, Ejemplos, Pesos0, Pesos, Pasos) :-
    entrenar_uno(Tasa, Ejemplos, Pesos0, 0, Pesos, Pasos).

%!  entrenar_uno(+Tasa, +Ejemplos, +Pesos0, +Pasos0:integer, -Pesos,
%!               -Pasos:integer) is det.
%
%   Como entrenar_uno/5, con Pasos0 pasos ya dados: el acumulador.
entrenar_uno(Tasa, [E|Es], Pesos0, Pasos0, Pesos, Pasos) :-
    (   maplist(bien_clasificado(Pesos0), [E|Es])
    ->  Pesos = Pesos0,
        Pasos = Pasos0
    ;   corregir(Tasa, E, Pesos0, Pesos1),
        Pasos1 is Pasos0 + 1,
        append(Es, [E], Es1),
        entrenar_uno(Tasa, Es1, Pesos1, Pasos1, Pesos, Pasos)
    ).

%!  pasos(+Nombre:atom, +Tasa:number, +Pesos0:list, -Pesos:list,
%!        -Pasos:integer) is det.
%
%   Como entrenar_uno/5, con los ejemplos del conjunto Nombre de datos/2.
pasos(Nombre, Tasa, Pesos0, Pesos, Pasos) :-
    datos(Nombre, Ejemplos),
    entrenar_uno(Tasa, Ejemplos, Pesos0, Pesos, Pasos).

:- meta_predicate
    inferencias(0, -).

%!  inferencias(:Meta, -I:integer) is det.
%
%   I es la cantidad de inferencias que usa la primera solución de Meta,
%   que debe cumplirse.
inferencias(Meta, I) :-
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I1),
    I is I1 - I0.
