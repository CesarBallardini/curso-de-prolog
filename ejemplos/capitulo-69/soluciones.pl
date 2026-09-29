:- encoding(utf8).

% Capítulo 69 - Soluciones de los ejercicios.
%
% solo-local: carga los programas de los capítulos 32, 46 y 69, y SWISH
% no carga otros archivos.
%
%?- datos(puntos, Es), errores([0.13, -0.51, -0.35], Es, N).
%?- datos(o_exclusivo, Es), entrenar_n(1, 6, Es, [0, 0, 0], P, Curva).

:- ensure_loaded(rasgos).

% Ejercicio 3

%!  errores(+Pesos:list, +Ejemplos:list, -N:integer) is det.
%
%   N es la cantidad de Ejemplos que Pesos clasifican mal.
errores(Pesos, Ejemplos, N) :-
    exclude(bien_clasificado(Pesos), Ejemplos, Mal),
    length(Mal, N).

% Ejercicio 4

%!  entrenar_n(+Tasa:number, +N:integer, +Ejemplos:list, +Pesos0:list,
%!             -Pesos:list, -Curva:list(integer)) is det.
%
%   Pesos son los que quedan después de N épocas desde Pesos0, y Curva
%   los errores de cada época, aunque alguna no tenga errores.
entrenar_n(Tasa, N, Ejemplos, Pesos0, Pesos, Curva) :-
    numlist(1, N, Epocas),
    foldl(epoca_contada(Tasa, Ejemplos), Epocas, Pesos0-Curva, Pesos-[]).

%!  epoca_contada(+Tasa, +Ejemplos, +Numero:integer, +Estado0, -Estado)
%!      is det.
%
%   Estado0 es Pesos0-[Errores|Curva] y Estado es Pesos-Curva: la época
%   deja sus errores en la lista, que se completa de adelante hacia atrás.
epoca_contada(Tasa, Ejemplos, _, Pesos0-[Errores|Curva], Pesos-Curva) :-
    epoca(Tasa, Ejemplos, Pesos0, Pesos, Errores).

% Ejercicio 5

%!  puntos_con_ruido(-Ejemplos:list) is det.
%
%   Ejemplos son los puntos de datos/2 con la clase del último cambiada.
puntos_con_ruido(Ejemplos) :-
    datos(puntos, Ps),
    reverse(Ps, [ej(Xs, _)|Anteriores]),
    reverse([ej(Xs, -1)|Anteriores], Ejemplos).

%!  entrenar_bolsillo(+Tasa:number, +N:integer, +Ejemplos:list,
%!                    +Pesos0:list, -Mejores:list, -Errores:integer)
%!      is det.
%
%   Mejores son, entre Pesos0 y los pesos del final de cada una de N
%   épocas, los primeros que menos Ejemplos clasifican mal, y Errores es
%   esa cantidad.
entrenar_bolsillo(Tasa, N, Ejemplos, Pesos0, Mejores, Errores) :-
    errores(Pesos0, Ejemplos, E0),
    numlist(1, N, Epocas),
    foldl(epoca_bolsillo(Tasa, Ejemplos), Epocas,
          b(Pesos0, Pesos0, E0), b(_, Mejores, Errores)).

%!  epoca_bolsillo(+Tasa, +Ejemplos, +Numero:integer, +Estado0, -Estado)
%!      is det.
%
%   Estado0 es b(Pesos0, Mejores0, E0): los pesos actuales, los mejores
%   hasta ahora y sus errores. Estado es el mismo término después de una
%   época.
epoca_bolsillo(Tasa, Ejemplos, _, b(Pesos0, Mejores0, E0),
               b(Pesos, Mejores, E)) :-
    epoca(Tasa, Ejemplos, Pesos0, Pesos, _),
    errores(Pesos, Ejemplos, E1),
    (   E1 < E0
    ->  Mejores = Pesos,
        E = E1
    ;   Mejores = Mejores0,
        E = E0
    ).

% Ejercicio 6

% nand(Ejemplos): la negación de la conjunción.
nand([ej([0, 0], 1), ej([0, 1], 1), ej([1, 0], 1), ej([1, 1], -1)]).

%!  entrenar_capas(-Modelo) is det.
%
%   Modelo es capas(Po, Pn, Py): los pesos de la disyunción y de la
%   negación de la conjunción, que forman la primera capa, y los de la
%   conjunción, que combina sus salidas. Los tres se entrenan por
%   separado, desde pesos nulos y con tasa 1.
entrenar_capas(capas(Po, Pn, Py)) :-
    datos(o, O),
    entrenar(1, O, [0, 0, 0], Po, _),
    nand(N),
    entrenar(1, N, [0, 0, 0], Pn, _),
    datos(y, Y),
    entrenar(1, Y, [0, 0, 0], Py, _).

%!  salida_capas(+Modelo, +Entradas:list, -Clase) is det.
%
%   Clase es la salida de la segunda capa de Modelo para las Entradas.
%   Las salidas de la primera capa, 1 o -1, se pasan a 1 o 0 porque la
%   segunda capa se entrenó con entradas 1 y 0.
salida_capas(capas(Po, Pn, Py), Xs, Clase) :-
    salida(Po, Xs, A),
    salida(Pn, Xs, B),
    maplist(binaria, [A, B], Intermedias),
    salida(Py, Intermedias, Clase).

%!  binaria(+Clase, -Bit) is det.
%
%   Bit es 1 si Clase es 1, y 0 si es -1.
binaria(Clase, Bit) :-
    Bit is (Clase + 1) // 2.

% Ejercicio 7

% tres_clases(Ejemplos): puntos del plano con clases a, b y c.
tres_clases([ ej([0, 0], a), ej([1, 0], a), ej([0, 1], a),
              ej([6, 0], b), ej([7, 1], b), ej([6, 1], b),
              ej([0, 6], c), ej([1, 7], c), ej([1, 6], c)
            ]).

%!  entrenar_clases(+Ejemplos:list, -Modelo:list(pair)) is semidet.
%
%   Modelo es una lista Clase-Pesos con un perceptrón por clase, que
%   separa esa clase de todas las demás. Falla si alguna clase no se
%   separa de las otras.
entrenar_clases(Ejemplos, Modelo) :-
    findall(C, member(ej(_, C), Ejemplos), Cs0),
    sort(Cs0, Clases),
    maplist(entrenar_clase(Ejemplos), Clases, Modelo).

%!  entrenar_clase(+Ejemplos:list, +Clase, -Par:pair) is semidet.
%
%   Par es Clase-Pesos, con Pesos entrenados para dar 1 a los Ejemplos de
%   la Clase y -1 a los demás.
entrenar_clase(Ejemplos, Clase, Clase-Pesos) :-
    maplist(uno_contra_resto(Clase), Ejemplos, Binarios),
    entrenar(1, Binarios, [0, 0, 0], Pesos, _).

%!  uno_contra_resto(+Clase, +Ejemplo, -Binario) is det.
%
%   Binario es el Ejemplo con clase 1 si era de la Clase, y -1 si no.
uno_contra_resto(Clase, ej(Xs, C), ej(Xs, D)) :-
    (   C == Clase
    ->  D = 1
    ;   D = -1
    ).

%!  suma(+Pesos:list, +Entradas:list, -S:number) is det.
%
%   S es W0 + W1·X1 + ... + Wn·Xn.
suma([W0|Ws], Xs, S) :-
    foldl(sumar_producto, Ws, Xs, W0, S).

%!  clase_de(+Modelo:list(pair), +Entradas:list, -Clase) is det.
%
%   Clase es la del perceptrón de Modelo con la mayor suma para las
%   Entradas; con sumas iguales, la primera.
clase_de(Modelo, Xs, Clase) :-
    maplist(suma_de(Xs), Modelo, Pares),
    pairs_keys_values(Pares, Sumas, _),
    max_list(Sumas, Maxima),
    once(member(Maxima-Clase, Pares)).

%!  suma_de(+Entradas, +Par:pair, -Suma:pair) is det.
%
%   Par es Clase-Pesos y Suma es S-Clase, con S la suma de Pesos para las
%   Entradas.
suma_de(Xs, Clase-Pesos, S-Clase) :-
    suma(Pesos, Xs, S).

% Ejercicio 8

%!  recta(+Pesos:list, -Pendiente:float, -Ordenada:float) is semidet.
%
%   La frontera de Pesos [W0, W1, W2] es la recta y = Pendiente · x +
%   Ordenada. Falla si W2 es 0: la frontera es entonces vertical.
recta([W0, W1, W2], Pendiente, Ordenada) :-
    W2 =\= 0,
    Pendiente is -W1 / W2,
    Ordenada is -W0 / W2.

% Ejercicio 10

%!  entrenar_cola(+Tasa:number, +Ejemplos:list, +Pesos0:list,
%!                -Pesos:list, -Pasos:integer) is det.
%
%   Como entrenar_uno/5, con los ejemplos en una cola hecha con una lista
%   diferencia: pasar el primero al final no copia la lista.
entrenar_cola(Tasa, Ejemplos, Pesos0, Pesos, Pasos) :-
    append(Ejemplos, Fin, Cola),
    entrenar_cola(Tasa, Ejemplos, Cola-Fin, Pesos0, 0, Pesos, Pasos).

%!  entrenar_cola(+Tasa, +Ejemplos, +Cola, +Pesos0, +Pasos0:integer,
%!                -Pesos, -Pasos:integer) is det.
%
%   Cola es Frente-Fin, una lista diferencia con los ejemplos en el orden
%   en que se usan; Ejemplos es la lista fija que se verifica.
entrenar_cola(Tasa, Ejemplos, [E|Frente]-[E|Fin], Pesos0, Pasos0,
              Pesos, Pasos) :-
    (   maplist(bien_clasificado(Pesos0), Ejemplos)
    ->  Pesos = Pesos0,
        Pasos = Pasos0
    ;   corregir(Tasa, E, Pesos0, Pesos1),
        Pasos1 is Pasos0 + 1,
        entrenar_cola(Tasa, Ejemplos, Frente-Fin, Pesos1, Pasos1, Pesos,
                      Pasos)
    ).

% Ejercicio 11

%!  margen(+Pesos:list, +Ejemplos:list, -Margen:float) is det.
%
%   Margen es la menor distancia con signo de los Ejemplos a la frontera
%   de Pesos: positiva si todos están del lado de su clase. Pesos debe
%   tener algún peso distinto de cero además del sesgo.
margen([W0|Ws], Ejemplos, Margen) :-
    foldl(sumar_producto, Ws, Ws, 0, Cuadrados),
    Norma is sqrt(Cuadrados),
    maplist(distancia([W0|Ws], Norma), Ejemplos, Distancias),
    min_list(Distancias, Margen).

%!  distancia(+Pesos:list, +Norma:float, +Ejemplo, -D:float) is det.
%
%   D es la distancia con signo del Ejemplo ej(Xs, C) a la frontera: la
%   suma de Pesos para Xs, por C, dividida por la Norma.
distancia(Pesos, Norma, ej(Xs, C), D) :-
    suma(Pesos, Xs, S),
    D is C * S / Norma.

% Ejercicio 12

% anillo(Ejemplos): la clase 1 dentro del círculo de radio 2, -1 fuera.
anillo([ ej([0, 0], 1), ej([1, 0], 1), ej([0, -1], 1), ej([-1, 1], 1),
         ej([3, 0], -1), ej([0, 3], -1), ej([-3, 1], -1),
         ej([2, -2], -1), ej([-2, -2], -1)
       ]).

%!  cuadrados(+Ejemplo0, -Ejemplo) is det.
%
%   Ejemplo tiene como entradas los cuadrados de las de Ejemplo0.
cuadrados(ej(Xs, D), ej(Cs, D)) :-
    maplist(cuadrado, Xs, Cs).

%!  cuadrado(+X:number, -C:number) is det.
%
%   C es X·X.
cuadrado(X, C) :-
    C is X * X.

% Consultas de la página de soluciones

%!  errores_en(+Nombre:atom, +Pesos:list, -N:integer) is det.
%
%   N es la cantidad de ejemplos del conjunto Nombre de datos/2 que Pesos
%   clasifican mal.
errores_en(Nombre, Pesos, N) :-
    datos(Nombre, Ejemplos),
    errores(Pesos, Ejemplos, N).

%!  bolsillo_con_ruido(+N:integer, -Mejores:list, -Errores:integer) is det.
%
%   Como entrenar_bolsillo/6 con N épocas sobre puntos_con_ruido/1, desde
%   los pesos iniciales de Csenki y con tasa 0.25.
bolsillo_con_ruido(N, Mejores, Errores) :-
    puntos_con_ruido(Ejemplos),
    entrenar_bolsillo(0.25, N, Ejemplos, [0.13, -0.51, -0.35], Mejores,
                      Errores).

%!  margen_en(+Nombre:atom, +Tasa:number, +Pesos0:list, -Margen:float)
%!      is semidet.
%
%   Margen es el de los pesos que entrenar/5 obtiene para el conjunto
%   Nombre de datos/2 desde Pesos0 con la Tasa.
margen_en(Nombre, Tasa, Pesos0, Margen) :-
    datos(Nombre, Ejemplos),
    entrenar(Tasa, Ejemplos, Pesos0, Pesos, _),
    margen(Pesos, Ejemplos, Margen).

%!  probar_anillo(+Rasgos:atom, -Resultado) is semidet.
%
%   Resultado es el de entrenar_o_ciclo/4 para anillo/1, con las entradas
%   originales (Rasgos = entradas) o sus cuadrados (Rasgos = cuadrados),
%   desde pesos nulos y con tasa 1.
probar_anillo(entradas, Resultado) :-
    anillo(Ejemplos),
    entrenar_o_ciclo(1, Ejemplos, [0, 0, 0], Resultado).
probar_anillo(cuadrados, Resultado) :-
    anillo(Ejemplos0),
    maplist(cuadrados, Ejemplos0, Ejemplos),
    entrenar_o_ciclo(1, Ejemplos, [0, 0, 0], Resultado).

%!  modelo_tres_clases(-Modelo:list(pair)) is det.
%
%   Modelo es el de entrenar_clases/2 para tres_clases/1.
modelo_tres_clases(Modelo) :-
    tres_clases(Ejemplos),
    entrenar_clases(Ejemplos, Modelo).

%!  costo_cola(-Cola:integer, -Uno:integer) is det.
%
%   Cola y Uno son las inferencias de entrenar_cola/5 y de entrenar_uno/5
%   con los ocho puntos, los pesos iniciales de Csenki y tasa 0.25.
costo_cola(Cola, Uno) :-
    datos(puntos, Ejemplos),
    inferencias(entrenar_cola(0.25, Ejemplos, [0.13, -0.51, -0.35], _, _),
                Cola),
    inferencias(entrenar_uno(0.25, Ejemplos, [0.13, -0.51, -0.35], _, _),
                Uno).
