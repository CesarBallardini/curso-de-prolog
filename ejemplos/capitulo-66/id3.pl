:- encoding(utf8).

% Capítulo 66 - Ampliación: aprender el árbol de ejemplos, como ID3.
%
% La versión 4 construye el árbol a partir de reglas. ID3, de Quinlan, lo
% aprende de ejemplos: objetos descritos por los valores de unos atributos
% y ya clasificados. id3/4 elige en cada nodo el atributo con más
% ganancia de información, o con la mejor razón de ganancia, y divide los
% ejemplos por sus valores. Un valor sin ejemplos da una hoja con la clase
% más frecuente del nodo. Con el criterio ruido(Confianza), un atributo
% solo se usa si la prueba de chi-cuadrado rechaza, con esa confianza, que
% sea independiente de la clase. ventana/5 sigue el esquema iterativo de
% ID3: aprende de una parte de los ejemplos, la ventana, y le agrega los
% que el árbol clasifica mal, hasta que no queda ninguno. Los ejemplos son
% los catorce sábados a la mañana de la tabla 1 de Quinlan.
%
%?- medidas_atributos(Filas).
%?- mostrar_aprendido(ganancia, tabla).
%?- ventana_tabla(4, I, N).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

% sabado(N, Cielo, Temperatura, Humedad, Viento, Clase): el ejemplo N de la
% tabla 1 de Quinlan; la clase p es una mañana apta para una actividad, la
% n, una que no lo es.
sabado(1,  soleado, calor,    alta,   no, n).
sabado(2,  soleado, calor,    alta,   si, n).
sabado(3,  nublado, calor,    alta,   no, p).
sabado(4,  lluvia,  templado, alta,   no, p).
sabado(5,  lluvia,  fresco,   normal, no, p).
sabado(6,  lluvia,  fresco,   normal, si, n).
sabado(7,  nublado, fresco,   normal, si, p).
sabado(8,  soleado, templado, alta,   no, n).
sabado(9,  soleado, fresco,   normal, no, p).
sabado(10, lluvia,  templado, normal, no, p).
sabado(11, soleado, templado, normal, si, p).
sabado(12, nublado, templado, alta,   si, p).
sabado(13, nublado, calor,    normal, no, p).
sabado(14, lluvia,  templado, alta,   si, n).

% Otro archivo puede agregar atributos.
:- multifile valores/2.

% valores(Atributo, Valores): los valores posibles de cada atributo.
valores(cielo, [soleado, nublado, lluvia]).
valores(temperatura, [calor, templado, fresco]).
valores(humedad, [alta, normal]).
valores(viento, [si, no]).

%!  ejemplos(-Ejemplos:list) is det.
%
%   Ejemplos son los catorce sábados como pares Objeto-Clase, con el
%   Objeto como lista de pares Atributo=Valor, en el orden de la tabla.
ejemplos(Ejemplos) :-
    findall([cielo=C, temperatura=T, humedad=H, viento=V]-K,
            sabado(_, C, T, H, V, K),
            Ejemplos).

%!  corrompido(+N:integer, -Ejemplos:list) is det.
%
%   Ejemplos son los de ejemplos/1 con la clase del ejemplo N cambiada:
%   un error de registro, ruido en la clase.
corrompido(N, Ejemplos) :-
    ejemplos(Es),
    nth1(N, Es, Objeto-Clase, Resto),
    otra_clase(Clase, Otra),
    nth1(N, Ejemplos, Objeto-Otra, Resto).

% otra_clase(C, D): la clase opuesta a C.
otra_clase(p, n).
otra_clase(n, p).

%!  valor(+Objeto:list, +Atributo, -Valor) is det.
%
%   Valor es el del Atributo en el Objeto.
valor(Objeto, Atributo, Valor) :-
    memberchk(Atributo=Valor, Objeto).

%!  cuentas(+Ejemplos:list, -Cuentas:list) is det.
%
%   Cuentas son pares Clase-Cantidad, en orden de clase.
cuentas(Ejemplos, Cuentas) :-
    pairs_values(Ejemplos, Clases),
    msort(Clases, Ordenadas),
    clumped(Ordenadas, Cuentas).

%!  info(+Ejemplos:list, -I:float) is det.
%
%   I es la información, en bits, necesaria para clasificar un ejemplo:
%   la entropía de las clases. Sin ejemplos, 0.
info(Ejemplos, I) :-
    length(Ejemplos, N),
    cuentas(Ejemplos, Cuentas),
    foldl(menos_plogp(N), Cuentas, 0.0, I).

%!  menos_plogp(+N:integer, +Cuenta, +S0:float, -S:float) is det.
%
%   S es S0 menos q log2 q, con q la fracción K/N de la Cuenta C-K.
menos_plogp(N, _-K, S0, S) :-
    Q is K / N,
    S is S0 - Q * log(Q) / log(2).

%!  particion(+Ejemplos:list, +Atributo, -Grupos:list) is det.
%
%   Grupos tiene un par Valor-Subconjunto por cada valor posible del
%   Atributo, en el orden de valores/2, con los ejemplos que lo tienen.
particion(Ejemplos, Atributo, Grupos) :-
    valores(Atributo, Valores),
    maplist(grupo(Ejemplos, Atributo), Valores, Grupos).

%!  grupo(+Ejemplos:list, +Atributo, +Valor, -Grupo) is det.
%
%   Grupo es Valor-Subconjunto, los Ejemplos con ese Valor del Atributo.
grupo(Ejemplos, Atributo, Valor, Valor-Subconjunto) :-
    include(con_valor(Atributo, Valor), Ejemplos, Subconjunto).

%!  con_valor(+Atributo, +Valor, +Ejemplo) is semidet.
%
%   El objeto del Ejemplo tiene ese Valor del Atributo.
con_valor(Atributo, Valor, Objeto-_) :-
    valor(Objeto, Atributo, Valor).

%!  ganancia(+Ejemplos:list, +Atributo, -G:float) is det.
%
%   G es la ganancia de información de dividir por el Atributo:
%   info(Ejemplos) menos la media de la información de cada grupo,
%   ponderada por su tamaño, con tres decimales.
ganancia(Ejemplos, Atributo, G) :-
    ganancia_exacta(Ejemplos, Atributo, G0),
    G is round(G0 * 1000) / 1000.0.

%!  ganancia_exacta(+Ejemplos:list, +Atributo, -G:float) is det.
%
%   G es la ganancia sin redondear.
ganancia_exacta(Ejemplos, Atributo, G) :-
    info(Ejemplos, I),
    length(Ejemplos, N),
    particion(Ejemplos, Atributo, Grupos),
    foldl(esperada(N), Grupos, 0.0, E),
    G is I - E.

%!  esperada(+N:integer, +Grupo, +E0:float, -E:float) is det.
%
%   E es E0 más la información del Grupo por su fracción de los N.
esperada(N, _-Subconjunto, E0, E) :-
    length(Subconjunto, K),
    info(Subconjunto, I),
    E is E0 + K / N * I.

%!  valor_intrinseco(+Ejemplos:list, +Atributo, -IV:float) is det.
%
%   IV es la información de conocer el valor del Atributo: la entropía de
%   los tamaños de los grupos, sin contar los vacíos.
valor_intrinseco(Ejemplos, Atributo, IV) :-
    length(Ejemplos, N),
    particion(Ejemplos, Atributo, Grupos),
    findall(V-K,
            ( member(V-S, Grupos),
              length(S, K),
              K > 0 ),
            Cuentas),
    foldl(menos_plogp(N), Cuentas, 0.0, IV).

%!  razon(+Ejemplos:list, +Atributo, -R:float) is det.
%
%   R es la razón de ganancia, la ganancia sobre el valor intrínseco, con
%   tres decimales; 0 si el valor intrínseco es 0.
razon(Ejemplos, Atributo, R) :-
    ganancia_exacta(Ejemplos, Atributo, G),
    valor_intrinseco(Ejemplos, Atributo, IV),
    (   IV =:= 0
    ->  R = 0.0
    ;   R is round(G / IV * 1000) / 1000.0
    ).

%!  chi_cuadrado(+Ejemplos:list, +Atributo, -X2:float, -GL:integer) is det.
%
%   X2 es el estadístico de chi-cuadrado de la hipótesis de que la clase
%   es independiente del Atributo, sumado sobre los grupos no vacíos y las
%   clases, con tres decimales; GL son sus grados de libertad, la cantidad
%   de grupos no vacíos menos uno, por la de clases menos uno.
chi_cuadrado(Ejemplos, Atributo, X2, GL) :-
    length(Ejemplos, N),
    cuentas(Ejemplos, Totales),
    particion(Ejemplos, Atributo, Grupos),
    exclude(vacio, Grupos, NoVacios),
    findall(T,
            ( member(_-S, NoVacios),
              length(S, NS),
              cuentas(S, CS),
              member(C-NC, Totales),
              (   memberchk(C-O, CS)
              ->  true
              ;   O = 0
              ),
              Esperado is NC * NS / N,
              T is (O - Esperado) ** 2 / Esperado ),
            Ts),
    sum_list(Ts, X0),
    X2 is round(X0 * 1000) / 1000.0,
    length(NoVacios, G),
    length(Totales, K),
    GL is (G - 1) * (K - 1).

%!  vacio(+Grupo) is semidet.
%
%   El Grupo Valor-Subconjunto no tiene ejemplos.
vacio(_-[]).

% critico(Confianza, GL, X): el valor de chi-cuadrado con GL grados de
% libertad que se supera con probabilidad 1 - Confianza.
critico(0.99, 1, 6.635).
critico(0.99, 2, 9.210).
critico(0.99, 3, 11.345).
critico(0.90, 1, 2.706).
critico(0.90, 2, 4.605).
critico(0.90, 3, 6.251).

%!  relevante(+Confianza, +Ejemplos:list, +Atributo) is semidet.
%
%   La prueba de chi-cuadrado rechaza, con la Confianza, que la clase sea
%   independiente del Atributo.
relevante(Confianza, Ejemplos, Atributo) :-
    chi_cuadrado(Ejemplos, Atributo, X2, GL),
    GL > 0,
    critico(Confianza, GL, X),
    X2 > X.

%!  mayoritaria(+Ejemplos:list, -Clase) is det.
%
%   Clase es la más frecuente de los Ejemplos; ante un empate, la primera
%   en orden alfabético.
mayoritaria(Ejemplos, Clase) :-
    cuentas(Ejemplos, Cuentas),
    transpose_pairs(Cuentas, PorCantidad),
    last(PorCantidad, Max-_),
    memberchk(Clase-Max, Cuentas).

%!  elegir(+Criterio, +Ejemplos:list, +Atributos:list, -Atributo)
%!      is semidet.
%
%   Atributo es el de mayor ganancia, con ganancia o ruido(Confianza), o
%   el de mayor razón entre los de ganancia media o mayor, con razon; ante
%   un empate, el primero. Con ruido(Confianza) se consideran solo los
%   atributos relevantes, y falla si no hay ninguno.
elegir(Criterio, Ejemplos, Atributos, Atributo) :-
    candidatos(Criterio, Ejemplos, Atributos, Candidatos),
    Candidatos \== [],
    findall(V-A,
            ( member(A, Candidatos),
              medida(Criterio, Ejemplos, A, V) ),
            Pares),
    mejor(Pares, Atributo).

%!  medida(+Criterio, +Ejemplos:list, +Atributo, -V:float) is det.
%
%   V es la razón de ganancia del Atributo con razon, y su ganancia sin
%   redondear con los otros criterios.
medida(razon, Ejemplos, Atributo, V) :-
    !,
    razon(Ejemplos, Atributo, V).
medida(_, Ejemplos, Atributo, V) :-
    ganancia_exacta(Ejemplos, Atributo, V).

%!  candidatos(+Criterio, +Ejemplos:list, +Atributos:list,
%!             -Candidatos:list) is det.
%
%   Candidatos son los Atributos que el Criterio permite elegir.
candidatos(ganancia, _, Atributos, Atributos).
candidatos(ruido(Confianza), Ejemplos, Atributos, Candidatos) :-
    include(relevante(Confianza, Ejemplos), Atributos, Candidatos).
candidatos(razon, Ejemplos, Atributos, Candidatos) :-
    maplist(ganancia_exacta(Ejemplos), Atributos, Gs),
    sum_list(Gs, S),
    length(Gs, N),
    Media is S / N,
    pairs_keys_values(Pares, Atributos, Gs),
    findall(A, ( member(A-G, Pares), G >= Media ), Candidatos).

%!  mejor(+Pares:list, -Atributo) is det.
%
%   Atributo es el del primer par Valor-Atributo de mayor Valor.
mejor([V-A|Pares], Atributo) :-
    foldl(mayor, Pares, V-A, _-Atributo).

%!  mayor(+Par, +Mejor0, -Mejor) is det.
%
%   Mejor es Par si su valor supera estrictamente al de Mejor0.
mayor(V-A, V0-A0, Mejor) :-
    (   V > V0
    ->  Mejor = V-A
    ;   Mejor = V0-A0
    ).

%!  id3(+Criterio, +Ejemplos:list, +Atributos:list, -Arbol) is det.
%
%   Arbol clasifica los Ejemplos: hoja(Clase) si todos tienen la misma
%   Clase o no queda atributo que elegir, con la clase mayoritaria; si no,
%   nodo(Atributo, Ramas), con un par Valor-Subarbol por cada valor. Una
%   rama sin ejemplos es una hoja con la clase mayoritaria del nodo.
id3(Criterio, Ejemplos, Atributos, Arbol) :-
    cuentas(Ejemplos, Cuentas),
    (   Cuentas = [Clase-_]
    ->  Arbol = hoja(Clase)
    ;   elegir(Criterio, Ejemplos, Atributos, A)
    ->  mayoritaria(Ejemplos, Mayoritaria),
        selectchk(A, Atributos, Resto),
        particion(Ejemplos, A, Grupos),
        maplist(rama(Criterio, Resto, Mayoritaria), Grupos, Ramas),
        Arbol = nodo(A, Ramas)
    ;   mayoritaria(Ejemplos, Clase),
        Arbol = hoja(Clase)
    ).

%!  rama(+Criterio, +Atributos:list, +Mayoritaria, +Grupo, -Rama) is det.
%
%   Rama es Valor-Subarbol para el Grupo Valor-Ejemplos.
rama(_, _, Mayoritaria, Valor-[], Valor-hoja(Mayoritaria)) :-
    !.
rama(Criterio, Atributos, _, Valor-Ejemplos, Valor-Subarbol) :-
    id3(Criterio, Ejemplos, Atributos, Subarbol).

%!  clasificar(+Arbol, +Objeto:list, -Clase) is det.
%
%   Clase es la de la hoja a la que el Objeto llega desde la raíz.
clasificar(hoja(Clase), _, Clase).
clasificar(nodo(A, Ramas), Objeto, Clase) :-
    valor(Objeto, A, V),
    memberchk(V-Subarbol, Ramas),
    clasificar(Subarbol, Objeto, Clase).

%!  nodos(+Arbol, -N:integer) is det.
%
%   N es la cantidad de nodos del Arbol, internos y hojas.
nodos(hoja(_), 1).
nodos(nodo(_, Ramas), N) :-
    pairs_values(Ramas, Subarboles),
    maplist(nodos, Subarboles, Ns),
    sum_list(Ns, S),
    N is S + 1.

%!  errores(+Arbol, +Ejemplos:list, -Mal:list) is det.
%
%   Mal son los Ejemplos que el Arbol clasifica mal.
errores(Arbol, Ejemplos, Mal) :-
    exclude(bien(Arbol), Ejemplos, Mal).

%!  bien(+Arbol, +Ejemplo) is semidet.
%
%   El Arbol da la clase del Ejemplo.
bien(Arbol, Objeto-Clase) :-
    clasificar(Arbol, Objeto, Clase).

%!  ventana(+Criterio, +Ejemplos:list, +Tamano:integer, -Arbol,
%!          -Iteraciones:integer) is det.
%
%   Arbol se aprende de una ventana que empieza con los primeros Tamano
%   Ejemplos y crece con los que el árbol de la iteración anterior
%   clasifica mal, hasta que clasifica bien todos; Iteraciones son los
%   árboles construidos.
ventana(Criterio, Ejemplos, Tamano, Arbol, Iteraciones) :-
    length(Ventana, Tamano),
    append(Ventana, Resto, Ejemplos),
    iterar(Criterio, Ventana, Resto, 1, Arbol, Iteraciones).

%!  iterar(+Criterio, +Ventana:list, +Resto:list, +I:integer, -Arbol,
%!         -Iteraciones:integer) is det.
%
%   Aprende de Ventana; si clasifica mal alguno del Resto, los pasa a la
%   Ventana y sigue.
iterar(Criterio, Ventana, Resto, I, Arbol, Iteraciones) :-
    findall(At, valores(At, _), Atributos),
    id3(Criterio, Ventana, Atributos, A),
    errores(A, Resto, Mal),
    (   Mal == []
    ->  Arbol = A,
        Iteraciones = I
    ;   append(Ventana, Mal, Ventana1),
        subtract(Resto, Mal, Resto1),
        I1 is I + 1,
        iterar(Criterio, Ventana1, Resto1, I1, Arbol, Iteraciones)
    ).

%!  atributos(-Atributos:list) is det.
%
%   Atributos son los de valores/2, en orden.
atributos(Atributos) :-
    findall(A, valores(A, _), Atributos).

%!  datos(+Nombre, -Ejemplos:list) is det.
%
%   Ejemplos son los de la tabla, con tabla, o los de la tabla con la
%   clase del ejemplo N cambiada, con corrompido(N).
datos(tabla, Ejemplos) :-
    ejemplos(Ejemplos).
datos(corrompido(N), Ejemplos) :-
    corrompido(N, Ejemplos).

%!  aprender(+Criterio, +Datos, -Arbol) is det.
%
%   Arbol es el que id3/4 aprende de los ejemplos de Datos con todos los
%   atributos.
aprender(Criterio, Datos, Arbol) :-
    datos(Datos, Ejemplos),
    atributos(Atributos),
    id3(Criterio, Ejemplos, Atributos, Arbol).

%!  medidas_atributos(-Filas:list) is det.
%
%   Filas tiene un término Atributo-Ganancia-Razon por atributo, sobre la
%   tabla.
medidas_atributos(Filas) :-
    ejemplos(Es),
    atributos(As),
    findall(A-G-R,
            ( member(A, As),
              ganancia(Es, A, G),
              razon(Es, A, R) ),
            Filas).

%!  mostrar(+Arbol) is det.
%
%   Escribe el Arbol con una línea por rama, Atributo = Valor, sangrada
%   según la profundidad, y la clase después de dos puntos en las ramas
%   que terminan en una hoja.
mostrar(hoja(Clase)) :-
    format("~w~n", [Clase]).
mostrar(nodo(A, Ramas)) :-
    mostrar_ramas(A, Ramas, "").

%!  mostrar_ramas(+Atributo, +Ramas:list, +Sangria:string) is det.
%
%   Escribe cada rama Valor-Subarbol del Atributo con la Sangria.
mostrar_ramas(A, Ramas, Sangria) :-
    forall(member(V-Sub, Ramas),
           (   Sub = hoja(Clase)
           ->  format("~s~w = ~w: ~w~n", [Sangria, A, V, Clase])
           ;   Sub = nodo(A1, Ramas1),
               format("~s~w = ~w~n", [Sangria, A, V]),
               string_concat(Sangria, "|   ", Sangria1),
               mostrar_ramas(A1, Ramas1, Sangria1)
           )).

%!  mostrar_aprendido(+Criterio, +Datos) is det.
%
%   Escribe con mostrar/1 el árbol que aprender/3 da, y su cantidad de
%   nodos.
mostrar_aprendido(Criterio, Datos) :-
    aprender(Criterio, Datos, Arbol),
    mostrar(Arbol),
    nodos(Arbol, N),
    format("nodos: ~d~n", [N]).

%!  ventana_tabla(+Tamano:integer, -Iteraciones:integer, -Nodos:integer)
%!      is det.
%
%   Iteraciones y Nodos son los de ventana/5 con la ganancia sobre la
%   tabla, empezando con los primeros Tamano ejemplos.
ventana_tabla(Tamano, Iteraciones, Nodos) :-
    ejemplos(Es),
    ventana(ganancia, Es, Tamano, Arbol, Iteraciones),
    nodos(Arbol, Nodos).
