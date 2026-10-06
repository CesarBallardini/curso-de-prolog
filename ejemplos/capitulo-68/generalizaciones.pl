:- encoding(utf8).

% Capítulo 68 - Versión 7: otros operadores de generalización.
%
% Luger y Stubblefield enumeran cuatro operaciones de generalización:
% reemplazar una constante por una variable, quitar condiciones de una
% conjunción, agregar un disyunto y subir en una jerarquía de clases. Las
% versiones 1 a 4 usan solo la primera. Este archivo escribe las otras
% tres sobre las mismas piezas: quitar condiciones es la misma operación
% vista sobre una lista de condiciones; subir en una jerarquía agrega
% conceptos intermedios entre un valor y la variable; agregar un disyunto
% hace que todo conjunto de ejemplos tenga un concepto consistente.
%
% solo-local: carga espacio.pl, que carga archivos de otros capítulos.
%
%?- condiciones_de(pieza(esfera, rojo, chico, madera), Cs).
%?- especifico_jerarquia(redondas_rojas, S).
%?- disyuncion(rojo_o_esfera, D).

:- module(generalizaciones,
          [ condiciones_de/2,
            comunes/3,
            clase/2,
            subir/3,
            generalizacion_jerarquia/3,
            cubre_jerarquia/2,
            especifico_jerarquia/2,
            disyuncion/2,
            disyuncion_de/2,
            cubre_disyuncion/2,
            ejemplos_de/2
          ]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(espacio).
:- reexport(unidireccional, [generalizacion/3]).

% --- Quitar condiciones ------------------------------------------------------

%!  condiciones_de(+C, -Cs:list) is det.
%
%   Cs es el concepto o la instancia C como lista de condiciones
%   Atributo = Valor, sin las de los atributos libres.
condiciones_de(C, Cs) :-
    C =.. [pieza|Valores],
    findall(A, atributo(A, _), Atributos),
    foldl(condicion, Atributos, Valores, Cs, []).

%!  condicion(+A, +V, ?Cs0:list, ?Cs:list) is det.
%
%   Cs0 es Cs con la condición A = V al frente si V no es una variable.
condicion(A, V, Cs0, Cs) :-
    (   var(V)
    ->  Cs0 = Cs
    ;   Cs0 = [A = V|Cs]
    ).

%!  comunes(+Cs1:list, +Cs2:list, -Cs:list) is det.
%
%   Cs son las condiciones de Cs1 que también están en Cs2: la
%   generalización que quita de una conjunción las condiciones que el
%   otro ejemplo no cumple.
comunes(Cs1, Cs2, Cs) :-
    include(esta_en(Cs2), Cs1, Cs).

%!  esta_en(+Cs:list, +C) is semidet.
%
%   La condición C está en Cs.
esta_en(Cs, C) :-
    memberchk(C, Cs).

% --- Las secuencias de ejemplos ----------------------------------------------

%!  ejemplos_de(+Nombre, -Ejs:list) is semidet.
%
%   Ejs es la secuencia Nombre: una de las de espacio.pl o una de este
%   archivo.
ejemplos_de(Nombre, Ejs) :-
    (   secuencia(Nombre, Ejs0)
    ->  Ejs = Ejs0
    ;   secuencia7(Nombre, Ejs)
    ).

% secuencia7(Nombre, Ejs): una secuencia de ejemplos de esta versión.
% redondas_rojas: las piezas rojas de forma redondeada.
secuencia7(redondas_rojas,
           [ pos(pieza(esfera, rojo, chico, madera)),
             pos(pieza(cilindro, rojo, grande, madera)),
             neg(pieza(cubo, rojo, chico, madera)),
             neg(pieza(esfera, verde, chico, madera))
           ]).
% esferas_y_cubos_verdes: un concepto que no es conjuntivo.
secuencia7(esferas_y_cubos_verdes,
           [ pos(pieza(esfera, rojo, chico, madera)),
             pos(pieza(cubo, verde, grande, metal)),
             pos(pieza(esfera, azul, grande, metal)),
             neg(pieza(cubo, rojo, chico, madera)),
             neg(pieza(cilindro, verde, chico, metal))
           ]).

% --- Subir en una jerarquía de clases ----------------------------------------

% clase(V, K): el valor V pertenece a la clase K.
clase(esfera, redondeada).
clase(cilindro, redondeada).
clase(cubo, poliedro).
clase(rojo, calido).
clase(verde, frio).
clase(azul, frio).

%!  subir(+V1, +V2, -G) is det.
%
%   G es la generalización mínima de los valores V1 y V2 en la jerarquía:
%   el valor mismo si son iguales, la clase común si la tienen, una
%   variable si no. V1 puede ser ya una clase o una variable.
subir(V1, V2, G) :-
    (   var(V1)
    ->  true
    ;   V1 == V2
    ->  G = V1
    ;   clase_o_valor(V1, K),
        clase(V2, K)
    ->  G = K
    ;   true
    ).

%!  clase_o_valor(+V, -K) is semidet.
%
%   K es la clase de V si V es un valor, o V si V ya es una clase.
clase_o_valor(V, K) :-
    (   clase(V, K0)
    ->  K = K0
    ;   clase(_, V)
    ->  K = V
    ).

%!  generalizacion_jerarquia(+S, +I, -S1) is det.
%
%   S1 es la generalización mínima del concepto S que cubre la instancia
%   I, subiendo cada atributo en la jerarquía: I misma si S es vacio.
generalizacion_jerarquia(S, I, S1) :-
    (   S == vacio
    ->  S1 = I
    ;   S =.. [pieza|Vs],
        I =.. [pieza|Ws],
        maplist(subir, Vs, Ws, Gs),
        S1 =.. [pieza|Gs]
    ).

%!  subir_con(+I, +S, -S1) is det.
%
%   generalizacion_jerarquia/3 con la instancia primero, para foldl/4.
subir_con(I, S, S1) :-
    generalizacion_jerarquia(S, I, S1).

%!  cubre_jerarquia(@C, +I) is semidet.
%
%   El concepto C, con valores, clases o variables, cubre la instancia I.
cubre_jerarquia(C, I) :-
    C \== vacio,
    C =.. [pieza|Vs],
    I =.. [pieza|Ws],
    maplist(cubre_valor, Vs, Ws).

%!  cubre_valor(@V, +W) is semidet.
%
%   V es una variable, el valor W o la clase de W.
cubre_valor(V, W) :-
    (   var(V)
    ->  true
    ;   V == W
    ->  true
    ;   clase(W, V)
    ).

%!  especifico_jerarquia(+Nombre, -S) is det.
%
%   S es el concepto más específico que cubre los positivos de la
%   secuencia Nombre, con la jerarquía, o colapso si cubre un negativo.
especifico_jerarquia(Nombre, S) :-
    ejemplos_de(Nombre, Ejs),
    findall(I, member(pos(I), Ejs), Pos),
    foldl(subir_con, Pos, vacio, S0),
    (   member(neg(N), Ejs),
        cubre_jerarquia(S0, N)
    ->  S = colapso
    ;   S = S0
    ).

% --- Agregar un disyunto -----------------------------------------------------

%!  disyuncion(+Nombre, -D:list) is det.
%
%   D es una disyunción de conceptos que cubre los positivos de la
%   secuencia Nombre y ningún negativo: cada positivo se generaliza con el
%   primer disyunto con el que la generalización sigue siendo consistente,
%   o se agrega como un disyunto nuevo.
disyuncion(Nombre, D) :-
    ejemplos_de(Nombre, Ejs),
    disyuncion_de(Ejs, D).

%!  disyuncion_de(+Ejs:list, -D:list) is det.
%
%   D es la disyunción de disyuncion/2 para la lista de ejemplos Ejs.
disyuncion_de(Ejs, D) :-
    findall(N, member(neg(N), Ejs), Negs),
    findall(I, member(pos(I), Ejs), Pos),
    foldl(agregar_positivo(Negs), Pos, [], D).

%!  agregar_positivo(+Negs:list, +I, +D0:list, -D:list) is det.
%
%   D es la disyunción D0 extendida para cubrir la instancia I sin cubrir
%   ningún ejemplo de Negs.
agregar_positivo(Negs, I, D0, D) :-
    (   append(Antes, [C|Despues], D0),
        generalizacion(C, I, C1),
        \+ ( member(N, Negs),
             cubre(C1, N) )
    ->  append(Antes, [C1|Despues], D)
    ;   append(D0, [I], D)
    ).

%!  cubre_disyuncion(+D:list, +I) is semidet.
%
%   Algún disyunto de D cubre la instancia I.
cubre_disyuncion(D, I) :-
    member(C, D),
    cubre(C, I),
    !.
