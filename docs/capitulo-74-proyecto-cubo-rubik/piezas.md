# Piezas y una ayuda para la búsqueda

Esta página contiene la sección
[74.9](index.md#749-version-8-piezas-y-una-ayuda-para-la-busqueda) del
[capítulo 74](index.md): las dos partes del capítulo «Rubik's Cube» de
Merritt que las versiones 1 a 7 no usan. La primera es su segunda
representación del cubo, una lista de piezas, con la que su programa
averigua dónde está una pieza. La segunda son sus heurísticas
`shift_right`, que mueven una pieza a un lugar fijo antes de buscar. El
ejemplo está en `piezas.pl`, en `ejemplos/capitulo-74/`, con sus pruebas;
carga `etapas.pl` y se ejecuta localmente.

## El cubo como lista de piezas

Merritt observa que el cubo admite dos representaciones: 54 casillas, o
20 cubitos con dos o tres casillas cada uno. El término de 54 casillas
es el que se gira rápido, con una unificación; la lista de piezas es la
que conviene para preguntar dónde está una pieza. Su programa usa las
dos, y pasa de una a otra con un único hecho, `pieces/2`, cuyos dos
argumentos tienen las mismas variables. En este capítulo ese hecho se
genera al cargar, como los giros de la
[sección 74.2](index.md#742-version-1-el-cubo-como-termino), a partir de
los hechos `pieza/3` de `macros.pl`:

<!-- ejemplo: capitulo-74/piezas.pl predicado: term_expansion/2 centro/1 pieza_de/3 casilla_de/3 -->
```prolog
%!  term_expansion(+Termino, -Hecho) is semidet.
%
%   El término generar_lista se reemplaza, al cargar, por el hecho
%   piezas(Cubo, Piezas): Cubo es un término c/54 de variables y Piezas
%   la lista de sus 26 piezas, primero los seis centros, p/1, después las
%   doce aristas, p/2, y las ocho esquinas, p/3, con las mismas
%   variables.
term_expansion(generar_lista, piezas(Cubo, Piezas)) :-
    functor(Cubo, c, 54),
    findall(Is, centro(Is), Centros),
    findall(Is, ( pieza(_, _, Is), length(Is, 2) ), Aristas),
    findall(Is, ( pieza(_, _, Is), length(Is, 3) ), Esquinas),
    append([Centros, Aristas, Esquinas], Listas),
    maplist(pieza_de(Cubo), Listas, Piezas).

%!  centro(-Casillas:list(integer)) is nondet.
%
%   Casillas es la lista con la casilla del centro de una cara.
centro([I]) :-
    cara(_, K, _),
    I is 9 * K + 5.

%!  pieza_de(+Cubo, +Casillas:list(integer), -Pieza) is det.
%
%   Pieza es el término p con las casillas Casillas de Cubo.
pieza_de(Cubo, Casillas, Pieza) :-
    maplist(casilla_de(Cubo), Casillas, Colores),
    Pieza =.. [p|Colores].

%!  casilla_de(+Cubo, +I:integer, -Color) is det.
%
%   Color es la casilla I de Cubo.
casilla_de(Cubo, I, Color) :-
    arg(I, Cubo, Color).
```

El hecho generado es `piezas(c(V1, ..., V54), [p(V5), ..., p(V9, V10, V21)])`:
los seis centros como `p/1`, las doce aristas como `p/2` y las ocho
esquinas como `p/3`, cada una con sus casillas en el orden de sus
números. Como en el hecho de un giro, convertir es unificar, y la
conversión funciona en los dos sentidos: con el cubo da la lista, y con
la lista da el cubo. Una de las pruebas de `piezas.plt` arma un cubo a
partir de su lista y lo compara con el original; otra verifica que cada
casilla está en exactamente una pieza.

!!! example "Patrón 75 — Dos representaciones unidas por un hecho que comparte las variables"
    **Problema.** Un mismo objeto conviene representarlo de dos maneras,
    porque cada una facilita operaciones distintas: el término de 54
    casillas se gira con una unificación, y en la lista de 26 piezas se
    busca dónde está una pieza. El programa necesita pasar de una a otra,
    en los dos sentidos.

    **Versión ingenua.** Un procedimiento que lee el término con `arg/3`
    y arma la lista pieza por pieza, y otro, aparte, que arma el término
    a partir de la lista: dos definiciones de la misma correspondencia,
    que deben mantenerse de acuerdo. La primera no sirve en sentido
    inverso, porque `arg/3` con el término libre lanza un error de
    instanciación, y repite el trabajo en cada llamada: el cálculo que
    hace `term_expansion/2` al cargar cuesta 475 inferencias para el
    cubo resuelto.

    **Patrón.** Escribir la correspondencia como un hecho de dos
    argumentos con las mismas variables,
    `piezas(c(V1, ..., V54), [p(V5), ..., p(V9, V10, V21)])`, generado
    una sola vez al cargar
    ([Patrón 49](../patrones.md#49-expandir-al-cargar)). Convertir es
    una unificación: con el cubo instanciado, `piezas/2` da la lista, y
    con la lista da el cubo. Es el recurso del
    [Patrón 74](../patrones.md#74-transformacion-como-par-de-terminos)
    con otra lectura: allí los dos términos son el cubo antes y después
    de un giro; aquí son el mismo cubo en dos representaciones. Como en
    el [Patrón 20](../patrones.md#20-una-gramatica-para-analizar-y-generar),
    una sola definición sirve en los dos sentidos, y una prueba de ida y
    vuelta, la que arma el cubo a partir de su lista, la verifica.

    **Cuándo no usarlo.** Cuando la segunda representación no reparte
    exactamente las partes de la primera: si una casilla no está en
    ninguna pieza, el cubo armado desde la lista la deja libre, y si está
    en dos, la conversión impone que sean iguales; por eso la otra prueba
    verifica que cada casilla está en exactamente una pieza. Cuando la
    correspondencia depende de los valores y no solo de las posiciones:
    saber dónde está la pieza `DFR` exige comparar colores, y `donde/4`
    lo hace con una búsqueda, `buscar/5`, sobre las dos listas que da el
    hecho. Y cuando la segunda representación no tiene forma fija, como
    una lista de largo variable u ordenada por valor: un hecho solo
    relaciona términos de forma fija.

## Dónde está una pieza

Para encontrar una pieza, Merritt recorre a la vez dos listas: la del
cubo resuelto, que dice qué pieza va en cada lugar, y la del cubo dado,
que dice qué pieza hay. La pieza buscada es la primera de la segunda
lista con los mismos colores, en cualquier orden, y su lugar es el
elemento de la primera lista que ocupa la misma posición. Si los colores
están además en el mismo orden que en el cubo resuelto, la pieza está en
su lugar; si no, está girada:

<!-- ejemplo: capitulo-74/piezas.pl predicado: donde/4 buscar/5 colores_de/2 nombre_de/2 -->
```prolog
%!  donde(+Cubo, +Nombre, -Lugar, -Estado) is semidet.
%
%   La pieza Nombre del cubo resuelto ('DF', 'UFR', ...) está en Cubo en
%   el lugar Lugar, el nombre de la pieza que ocupa ese lugar en el cubo
%   resuelto. Estado es en_su_lugar, girada (en su lugar, con los colores
%   en otro orden) o fuera. Falla si Nombre no es una pieza.
donde(Cubo, Nombre, Lugar, Estado) :-
    resuelto(Resuelto),
    piezas(Resuelto, Gs),
    piezas(Cubo, Ss),
    colores_de(Nombre, Buscada),
    buscar(Gs, Ss, Buscada, G, S),
    G =.. [p|Lugares],
    nombre_de(Lugares, Lugar),
    (   Lugar \== Nombre
    ->  Estado = fuera
    ;   G == S
    ->  Estado = en_su_lugar
    ;   Estado = girada
    ).

%!  buscar(+Gs:list, +Ss:list, +Colores:list, -G, -S) is semidet.
%
%   S es la primera pieza de Ss con los mismos Colores, en cualquier
%   orden, y G la pieza de Gs que está en la misma posición de la lista:
%   las dos listas se recorren a la vez.
buscar([G|Gs], [S|Ss], Colores, G1, S1) :-
    S =.. [p|Cs],
    (   msort(Cs, Ordenados),
        msort(Colores, Ordenados)
    ->  G1 = G,
        S1 = S
    ;   buscar(Gs, Ss, Colores, G1, S1)
    ).

%!  colores_de(+Nombre, -Colores:list) is det.
%
%   Colores son las caras de la pieza Nombre, en minúscula y en el orden
%   del nombre.
colores_de(Nombre, Colores) :-
    atom_chars(Nombre, Letras),
    maplist(downcase_atom, Letras, Colores).

%!  nombre_de(+Colores:list, -Nombre) is det.
%
%   Nombre es el nombre de la pieza con las caras Colores: sus letras en
%   mayúscula, en el orden u, d, f, b, r, l.
nombre_de(Colores, Nombre) :-
    findall(C, ( member(C, [u, d, f, b, r, l]), memberchk(C, Colores) ),
            Ordenados),
    maplist(upcase_atom, Ordenados, Letras),
    atomic_list_concat(Letras, Nombre).
```

La misma búsqueda con las listas intercambiadas responde la pregunta
inversa, qué pieza ocupa un lugar dado:

<!-- ejemplo: capitulo-74/piezas.pl predicado: en_lugar/3 pieza_tras/3 donde_tras/4 -->
```prolog
%!  en_lugar(+Cubo, +Lugar, -Pieza) is semidet.
%
%   Pieza es la pieza de Cubo que ocupa el lugar Lugar, el nombre de una
%   pieza del cubo resuelto: la búsqueda inversa de donde/4. Falla si
%   Lugar no es una pieza.
en_lugar(Cubo, Lugar, Pieza) :-
    resuelto(Resuelto),
    piezas(Resuelto, Gs),
    piezas(Cubo, Ss),
    colores_de(Lugar, Colores),
    buscar(Ss, Gs, Colores, Pieza, _).

%!  pieza_tras(+Movimientos:list, +Lugar, -Pieza) is semidet.
%
%   Como en_lugar/3, en el cubo resuelto con Movimientos aplicados.
pieza_tras(Movimientos, Lugar, Pieza) :-
    resuelto(C),
    aplicar(Movimientos, C, C1),
    en_lugar(C1, Lugar, Pieza).

%!  donde_tras(+Movimientos:list, +Nombre, -Lugar, -Estado) is semidet.
%
%   Como donde/4, en el cubo resuelto con Movimientos aplicados.
donde_tras(Movimientos, Nombre, Lugar, Estado) :-
    resuelto(C),
    aplicar(Movimientos, C, C1),
    donde(C1, Nombre, Lugar, Estado).
```

```prolog
?- pieza_tras([], 'UFR', P).
P = p(u, r, f).

?- pieza_tras([r], 'UFR', P).
P = p(f, r, d).

?- donde_tras([r, u, -r], 'DFR', Lugar, Estado).
Lugar = 'UFL',
Estado = fuera.

?- donde_tras([r, u, -r, -u, r, u, -r, -u], 'DFR', Lugar, Estado).
Lugar = 'DFR',
Estado = girada.
```

En el cubo resuelto, la esquina de arriba, adelante y a la derecha tiene
sus casillas en las caras u, r y f, en el orden de sus números. Después
de girar R, ese lugar lo ocupa la esquina que estaba abajo: sus colores
son los de `DFR`, en otro orden. La secuencia R U R', que la etapa 2 usa
como candidata, lleva esa esquina a la capa de arriba, del lado
izquierdo, y la secuencia R U R' U', repetida dos veces, la devuelve a
su lugar, girada.

El resolvedor de la
[sección 74.7](index.md#747-version-6-la-solucion-por-etapas) no
necesita `donde/4`: no pregunta dónde está la pieza, sino si el cubo
unifica con el criterio, y esa prueba es una sola unificación. Merritt
hace la misma elección en su búsqueda, y reserva la lista de piezas para
el análisis previo a cada búsqueda, que es lo que usa la ayuda siguiente.

## Una ayuda para la búsqueda

Merritt cuenta que su programa, con solo la búsqueda, «casi funciona»:
cuando la pieza que hay que colocar ya está en una de las posiciones de
la etapa, pero en la equivocada o girada, la búsqueda tiene que sacarla
y volver a meterla, y esa secuencia es larga. Sus heurísticas
`shift_right` reconocen la situación y mueven la pieza, sin buscar, a
un lugar desde el que la búsqueda la coloca rápido. En este capítulo las
etapas 1 y 2 arman la capa de abajo, y la ayuda equivalente sube a la
capa de arriba la pieza que está abajo fuera de su lugar, con una
secuencia fija que no mueve las piezas ya colocadas:

<!-- ejemplo: capitulo-74/piezas.pl predicado: subida/2 ayuda/5 resolver_con_ayuda/2 colocar_con_ayuda/4 -->
```prolog
% subida(Etapa, Texto): una secuencia que sube a la capa de arriba la
% pieza de la etapa que está en la capa de abajo, de adelante a la
% derecha, sin mover las otras piezas de la capa de abajo. Se usa en sus
% cuatro orientaciones.
subida(1, "F2").
subida(2, "R U R'").

%!  ayuda(+Etapa, +Colocadas:list, +Pieza, +Cubo, -Movimientos:list) is det.
%
%   Movimientos es una subida de Etapa que lleva Pieza fuera de la capa de
%   abajo sin mover las piezas Colocadas, si Pieza está en la capa de
%   abajo y no en su lugar; [] en otro caso.
ayuda(Etapa, Colocadas, Pieza, Cubo, Movimientos) :-
    (   donde(Cubo, Pieza, Lugar, Estado),
        Estado \== en_su_lugar,
        sub_atom(Lugar, 0, 1, _, 'D'),
        criterio(Colocadas, Criterio),
        subida(Etapa, Texto),
        leer_notacion(Texto, Ms0),
        between(0, 3, K),
        orientar(K, Ms0, Ms),
        aplicar(Ms, Cubo, Cubo1),
        subsumes_term(Criterio, Cubo1),
        donde(Cubo1, Pieza, Lugar1, _),
        \+ sub_atom(Lugar1, 0, 1, _, 'D')
    ->  Movimientos = Ms
    ;   Movimientos = []
    ).

%!  resolver_con_ayuda(+Cubo, -Pasos:list) is det.
%
%   Como resolver/2, pero antes de buscar cada pieza aplica la ayuda/5 de
%   su etapa. Los giros de la ayuda quedan al principio de los del paso.
resolver_con_ayuda(Cubo, Pasos) :-
    findall(E-P, ( etapa(E, Ps), member(P, Ps) ), Plan),
    colocar_con_ayuda(Plan, [], Cubo, Pasos).

%!  colocar_con_ayuda(+Plan:list, +Colocadas:list, +Cubo, -Pasos:list)
%!      is det.
%
%   Como colocar_todas/4, con la ayuda antes de cada búsqueda.
colocar_con_ayuda([], _, _, []).
colocar_con_ayuda([Etapa-Pieza|Plan], Colocadas, Cubo,
                  [paso(Etapa, Pieza, Movimientos)|Pasos]) :-
    ayuda(Etapa, Colocadas, Pieza, Cubo, Subida),
    aplicar(Subida, Cubo, Cubo0),
    Colocadas1 = [Pieza|Colocadas],
    criterio(Colocadas1, Criterio),
    colocar(Etapa, Cubo0, Criterio, Buscados, Cubo1),
    append(Subida, Buscados, Movimientos),
    colocar_con_ayuda(Plan, Colocadas1, Cubo1, Pasos).
```

`comparar_ayuda/3` resuelve las mismas mezclas con `resolver/2` y con
`resolver_con_ayuda/2`, y suma los cuartos de vuelta y las inferencias
de cada uno:

<!-- ejemplo: capitulo-74/piezas.pl predicado: comparar_ayuda/3 medir_metodo/3 resolver_semilla/4 -->
```prolog
%!  comparar_ayuda(+Semillas:integer, -Sin, -Con) is det.
%
%   Sin y Con son medida(Giros, Inferencias): los cuartos de vuelta y las
%   inferencias que suman resolver/2 y resolver_con_ayuda/2 sobre las
%   mezclas de 25 giros de las semillas 1 a Semillas.
comparar_ayuda(Semillas, Sin, Con) :-
    medir_metodo(resolver, Semillas, Sin),
    medir_metodo(resolver_con_ayuda, Semillas, Con).

%!  medir_metodo(+Metodo, +Semillas:integer, -Medida) is det.
%
%   Medida es medida(Giros, Inferencias) para Metodo sobre las semillas 1
%   a Semillas. Lanza un error si alguna solución no deja el cubo
%   resuelto.
medir_metodo(Metodo, Semillas, medida(Giros, Inferencias)) :-
    findall(G-I, ( between(1, Semillas, S),
                   resolver_semilla(Metodo, S, G, I) ), Pares),
    pairs_keys_values(Pares, Gs, Is),
    sum_list(Gs, Giros),
    sum_list(Is, Inferencias).

%!  resolver_semilla(+Metodo, +Semilla:integer, -Giros:integer,
%!                   -Inferencias:integer) is det.
%
%   Metodo resuelve la mezcla de 25 giros de Semilla con Giros cuartos de
%   vuelta y Inferencias inferencias.
resolver_semilla(Metodo, Semilla, Giros, Inferencias) :-
    mezcla(Semilla, 25, Ms),
    resuelto(C),
    aplicar(Ms, C, C1),
    contar(call(Metodo, C1, Pasos), Inferencias),
    findall(G, member(paso(_, _, G), Pasos), Listas),
    append(Listas, Todos),
    length(Todos, Giros),
    aplicar(Todos, C1, C2),
    (   C2 == C
    ->  true
    ;   domain_error(cubo_resuelto, C2)
    ).
```

```prolog
?- comparar_ayuda(50, Sin, Con).
Sin = medida(8370, 2338073),
Con = medida(8476, 2612187).
```

En las cincuenta mezclas, la ayuda empeora las dos medidas: agrega 106
cuartos de vuelta y alrededor de un 12 % de inferencias. Con las diez
primeras mezclas el resultado es el inverso, y la ayuda ahorra un poco
de las dos; una prueba de `piezas.plt` lo registra. Medida por separado,
cada una de las dos subidas también empeora el total.

La razón está en los candidatos. Los de la primera etapa de Merritt son
solo los giros de tres caras, `cnd(1, [r, u, f])`: con ellos, una arista
que está abajo en el lugar equivocado necesita una secuencia larga, y
la ayuda la acorta. Los de este capítulo incluyen los giros de la cara
de abajo, y la subida de la etapa 2, R U R', es ella misma una de las
candidatas: la búsqueda ya encuentra esas soluciones cuando le sirven, y
aplicarlas siempre solo agrega giros. Merritt advierte lo mismo: una
heurística cuesta tiempo, y solo conviene cuando la búsqueda sin ella
es lenta. El [ejercicio 13](index.md#ejercicios) mide la ayuda etapa
por etapa.
