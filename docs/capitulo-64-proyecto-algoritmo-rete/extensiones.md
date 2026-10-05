# Cinco extensiones de la red

Esta página continúa el [capítulo 64](index.md) con cinco temas que las
fuentes del capítulo tratan y las siete versiones dejan afuera: la herencia
de los marcos en los patrones, que Merritt señala como el límite de su
*Rete-Foops*; los tokens que guardan referencias en lugar de copias, su
ejercicio 8.2; y tres temas de la tesis de Doorenbos: la negación de una
conjunción, las activaciones nulas y el agregado de reglas con la red en
marcha. Cada extensión es un archivo de `ejemplos/capitulo-64/` que carga
las versiones del capítulo sin modificarlas, salvo una declaración
`multifile` que `red.pl` agrega para que otro archivo defina pasos nuevos.

## 64.9 La herencia en los patrones

Merritt cierra su capítulo con un intercambio: *Rete-Foops* completa cada
patrón de marco con los valores del objeto antes de propagarlo, y así un
patrón escrito para una clase general, como la regla que busca enchufes en
cualquier artefacto eléctrico, deja de encontrar los objetos de las
subclases. Lo propone como su ejercicio 8.4.

En el curso el problema no aparece, por la forma en que el
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md#634-version-3-marcos)
traduce los marcos. La condición `es(X, componente, [precio-P])` llega a
la red como el patrón `objeto(X, C, R)` seguido de la prueba
`{es_de_clase(C, componente), consultar(C, R, [precio-P])}`, y la
[versión 7](medicion.md#648-version-7-las-pruebas-de-un-solo-hecho-en-la-red-alfa)
lleva esa prueba al nodo alfa. La clase no es una constante del patrón: es
una consulta a los marcos, que recorre la herencia cada vez que un objeto
entra.

<!-- ejemplo: capitulo-64/herencia.pl predicado: clases_que_aceptan/2 -->
```prolog
%!  clases_que_aceptan(+Objeto, -Clases:list) is det.
%
%   Clases son las clases de los patrones es/3 del configurador cuyos
%   nodos alfa, en la red de red_con_pruebas/2, aceptan el Objeto, sin
%   repetidos y en orden alfabético.
clases_que_aceptan(Objeto, Clases) :-
    red_con_pruebas(configurador, Red),
    alfas_del_hecho(Red, Objeto, Nodos),
    Red = red(_, Alfas, _, _),
    findall(Clase,
            ( member(A, Nodos),
              get_assoc(A, Alfas, a(alfa(_, Pruebas), _)),
              memberchk(es_de_clase(_, Clase), Pruebas) ),
            Clases0),
    sort(Clases0, Clases).
```

<!-- contexto: capitulo-64/herencia.pl -->
```prolog
?- clases_que_aceptan(objeto(cpu_a, procesador, [nucleos-6, precio-190]), Cs).
Cs = [componente, procesador].

?- nodos_por_clase(componente, N).
N = 2.
```

El procesador entra en los tres nodos alfa que piden un procesador y en
los dos de `descartar_caro` y `elegir`, que piden un componente. Con la
clase escrita como constante, `objeto(X, componente, R)`, ningún objeto del
catálogo entraría en esos dos nodos, porque todos se crean con su clase
más específica, y el configurador no podría comparar precios.

El precio de esta solución es el de la
[sección 64.8](medicion.md#648-version-7-las-pruebas-de-un-solo-hecho-en-la-red-alfa):
cada objeto pasa por la prueba de clase de cada nodo de `objeto/3`. Y la
herencia se evalúa cuando el objeto entra en la red: si cambiara la
jerarquía de los marcos con la red cargada, las memorias alfa quedarían
desactualizadas. En el capítulo los marcos son fijos y la pregunta no se
plantea; el [ejercicio 8](index.md#ejercicios) la discute.

## 64.10 Tokens con referencias

Un token guarda los sellos de los hechos que usa y la **instancia** del
prefijo: los pasos con las variables ligadas a copias de esos hechos.
Merritt observa que guardar una copia completa en cada memoria es caro, y
propone en su ejercicio 8.2 guardar solo referencias a los hechos; el
comentario de su `retepred.pro` lo deja pendiente. En el curso las
referencias ya existen: son los sellos. `referencias.pl` mide cuánto
ocuparían las memorias beta con solo los sellos, y verifica que la
instancia se puede reconstruir a partir de ellos:

<!-- ejemplo: capitulo-64/referencias.pl predicado: reconstruir/4 reconstruir_paso/4 -->
```prolog
%!  reconstruir(+Prefijo:list, +Memoria, +Sellos:list,
%!              -Instancia:list) is nondet.
%
%   Instancia es una copia del Prefijo con cada patrón ligado al hecho de
%   su sello en la Memoria de trabajo y cada prueba ejecutada. Una prueba
%   con varias soluciones da varias instancias.
reconstruir(Prefijo, Memoria, Sellos, Instancia) :-
    copy_term(Prefijo, Instancia),
    reconstruir_pasos(Instancia, Memoria, Sellos).

%!  reconstruir_paso(+Paso, +Memoria, +Sellos:list, -Resto:list)
%!      is nondet.
%
%   Un patrón toma el primer sello; una prueba se ejecuta; una negación
%   no usa ningún hecho, porque el nodo ya verificó que no lo hay.
reconstruir_paso(alfa(F, Pruebas), Memoria, [Sello|Resto], Resto) :-
    once(elemento(Sello, F, Memoria)),
    maplist(call, Pruebas).
reconstruir_paso({Meta}, _, Sellos, Sellos) :-
    call(Meta).
reconstruir_paso(no(_), _, Sellos, Sellos).
```

Un patrón toma el hecho de su sello en la memoria de trabajo, y una prueba
se vuelve a ejecutar. `tamano_memorias/4` compara, con `term_size/2`, las
celdas de todos los tokens al final de una ejecución con las de sus listas
de sellos:

<!-- contexto: capitulo-64/referencias.pl -->
```prolog
?- tamano_memorias(familia, cadena(5), Completo, Sellos).
Completo = 837,
Sellos = 231.

?- tamano_memorias(familia, cadena(20), Completo, Sellos).
Completo = 8397,
Sellos = 2301.

?- reconstruibles(familia, cadena(10), Tokens, Ambiguos).
Tokens = 84,
Ambiguos = 0.
```

Los sellos ocupan algo más de la cuarta parte, y los 84 tokens de la
cadena de 10 generaciones se reconstruyen sin ambigüedad. Hay un caso en
que los sellos no alcanzan: una prueba con varias soluciones produce un
token por solución, todos con los mismos sellos. El programa `rangos`
tiene la regla `contar :: [n(X), {between(1, X, Y)}]`:

```prolog
?- reconstruibles(rangos, lista([n(2), n(3)]), Tokens, Ambiguos).
Tokens = 5,
Ambiguos = 5.
```

Cada token de `n(3)` tiene tres reconstrucciones, una por cada valor de
`Y`, y el sello no dice cuál es. Una red que guarde referencias necesita,
para esas pruebas, guardar también la solución, o no admitir pruebas que
liguen variables nuevas. Es el intercambio de Merritt con un término más:
guardar menos obliga a recalcular, y recalcular una prueba no siempre da
una sola respuesta.

## 64.11 La negación de una conjunción

`no(F)` pide que no haya un hecho que cumpla `F`. Doorenbos dedica un
apartado de su tesis, «Conjunctive Negations», a la condición más general:
que no haya una **combinación** de hechos que cumpla varios patrones a la
vez. La regla del programa `bloques` declara libre de rojo un bloque que no
tiene encima un bloque rojo:

```prolog
libre :: [bloque(X), no_todos([sobre(Y, X), color(Y, rojo)])]
         ---> [agregar(libre_de_rojo(X))]
```

Escrita con dos negaciones simples, `no(sobre(Y, X))` y
`no(color(Y, rojo))`, la regla diría otra cosa: que el bloque no tiene
nada encima y que no hay ningún bloque rojo en toda la memoria. Sin la
negación conjuntiva hace falta una regla auxiliar que agregue un hecho
`tiene_rojo_encima(X)`, con un ciclo más por cada bloque.

`conjuntiva.pl` agrega un tipo de nodo, `negacion_conj(As)`, que lee un
nodo alfa por patrón y guarda cada token de su padre con la cantidad de
combinaciones que lo bloquean. Un hecho que entra o sale de cualquiera de
esas memorias alfa hace recontar los tokens; el que pasa de cero a más deja
de pasar, y el que vuelve a cero pasa de nuevo:

<!-- ejemplo: capitulo-64/conjuntiva.pl predicado: bloqueos/5 combinacion/3 recontar_conj/7 -->
```prolog
%!  bloqueos(+As:list, +Alfas, +Prefijo:list, +Instancia:list,
%!           -N:integer) is det.
%
%   N es la cantidad de combinaciones de hechos de las memorias alfa As
%   que cumplen los patrones del último paso no_todos(Fs) del Prefijo con
%   las variables de la Instancia.
bloqueos(As, Alfas, Prefijo, Instancia, N) :-
    aggregate_all(count,
                  ( copy_term(Prefijo, P),
                    append(Instancia, [no_todos(Fs)], P),
                    combinacion(Fs, As, Alfas) ),
                  N).

%!  combinacion(+Fs:list, +As:list, +Alfas) is nondet.
%
%   Cada patrón de Fs unifica con un hecho de la memoria alfa que le
%   corresponde en As. Una solución por combinación.
combinacion([], [], _).
combinacion([F|Fs], [A|As], Alfas) :-
    get_assoc(A, Alfas, Memoria),
    elementos_alfa(Memoria, F, Elementos),
    member(_-alfa(F, _), Elementos),
    combinacion(Fs, As, Alfas).

%!  recontar_conj(+As:list, +Alfas, +Prefijo:list, +Cuenta0, -Cuenta,
%!                +Cambios0, -Cambios) is det.
%
%   Cuenta tiene la cantidad de bloqueos actual del token de Cuenta0.
%   Cambios registra menos-Token si el token dejó de pasar y mas-Token si
%   volvió a pasar.
recontar_conj(As, Alfas, Prefijo, Sellos-(Instancia-N0),
              Sellos-(Instancia-N), Cambios0, Cambios) :-
    bloqueos(As, Alfas, Prefijo, Instancia, N),
    (   N0 =:= 0, N > 0
    ->  Cambios = [menos-(Sellos-Instancia)|Cambios0]
    ;   N0 > 0, N =:= 0
    ->  Cambios = [mas-(Sellos-Instancia)|Cambios0]
    ;   Cambios = Cambios0
    ).
```

`red.pl` declara `tipo_de/4` y `agregar_sucesor/4` como `multifile`, y
`conjuntiva.pl` les agrega una cláusula para el paso nuevo; `derecha/8` e
`izquierda/8` ya lo eran desde la
[versión 4](index.md#645-version-4-la-negacion).

<!-- contexto: capitulo-64/conjuntiva.pl -->
```prolog
?- conjunto_conj(bloques, [bloque(a), bloque(b), sobre(c, a), color(c, rojo)], Is).
Is = [instanciacion(libre, [2], 2, [agregar(libre_de_rojo(b))])].

?- cambios_conj(bloques, [bloque(a), sobre(c, a), color(c, rojo)], [menos(color(c, rojo))], Is).
Is = [instanciacion(libre, [1], 2, [agregar(libre_de_rojo(a))])].
```

El bloque `a` tiene encima el bloque rojo `c`; al quitar el color, la
combinación desaparece y `a` queda libre de rojo, aunque `c` sigue encima.
Las pruebas comparan, después de cada cambio, el conjunto de la red con el
que `desde_cero/3` reúne recorriendo la memoria, como el
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) con una
cláusula más para `no_todos/1`.

Recontar todos los tokens del nodo ante cada hecho es la forma más simple,
no la más eficiente. Doorenbos construye debajo del nodo una subred con
las uniones de la conjunción, que mantiene las combinaciones de manera
incremental como cualquier otra parte de la red; el recuento cuesta, en
cambio, una búsqueda en las memorias alfa por cada token y cada hecho que
toca la conjunción.

## 64.12 Las activaciones nulas

Una activación es **nula** cuando no puede producir nada: por la derecha,
cuando el padre del nodo de unión no tiene tokens; por la izquierda, cuando
la memoria alfa del nodo está vacía. La
[versión 3](index.md#644-version-3-tokens-y-uniones) ya evita las primeras
con una consulta, y la
[sección 64.7](medicion.md#647-version-6-la-medicion) mostró lo que
ahorra. Doorenbos estudia las dos clases en sistemas de cien mil reglas, y
las evita **desconectando** los nodos: un nodo con el padre vacío se quita
de la lista de sucesores de su memoria alfa, y uno con la memoria alfa
vacía, de la lista de hijos de su padre. Llama Rete/UL a la red con las dos
desconexiones, y muestra que un nodo no puede estar desconectado de los dos
lados a la vez, porque entonces nada lo volvería a conectar.

`desconexion.pl` cuenta las activaciones durante la carga de los hechos:

<!-- contexto: capitulo-64/desconexion.pl -->
```prolog
?- activaciones(configurador, pedido(0), A).
A = a(189, 187, 2, 0).

?- activaciones(configurador, pedido(200), A).
A = a(2589, 2587, 2, 0).

?- activaciones(familia, familia, A).
A = a(7, 0, 4, 4).

?- nodos_vacios(configurador, pedido(0), N).
N = n(35, 24, 12, 5).
```

En el configurador, de 189 activaciones por la derecha, 187 son nulas, y
con 200 memorias más en el catálogo son 2 587 de 2 589: cada objeto entra
en las memorias alfa de `objeto/3`, y casi ningún padre tiene tokens
mientras no hay fases. Es la situación para la que Doorenbos propone la
desconexión por la derecha, y la consulta de la versión 3 obtiene el mismo
ahorro sin cambiar la red. En `familia` ocurre lo contrario: los cuatro
tokens que entran llegan a nodos cuya memoria alfa todavía está vacía.
Al terminar la carga del configurador, de sus 35 nodos de unión, 24 tienen
el padre vacío, 12 la memoria alfa vacía y 5 las dos cosas: esos cinco son
los que Rete/UL no puede desconectar de los dos lados.

## 64.13 Una regla nueva con la red en marcha

La red del capítulo se compila una sola vez. Doorenbos describe, en el
apartado «Adding and Removing Productions», cómo agregar una regla a una
red que ya tiene hechos: compilarla compartiendo lo que se pueda, y llenar
los nodos nuevos con lo que ya está en la memoria de trabajo.
`en_marcha.pl` lo hace con `compilar_regla/4` de la
[versión 1](index.md#642-version-1-la-red) y tres pasos:

<!-- ejemplo: capitulo-64/en_marcha.pl predicado: agregar_regla/6 -->
```prolog
%!  agregar_regla(+Regla, +Memoria, +Red0, +Rete0, -Red, -Rete) is det.
%
%   Red es Red0 con la Regla compilada, y Rete, el estado Rete0 con los
%   nodos nuevos llenos con los hechos de la Memoria de trabajo.
agregar_regla(Regla, Memoria, Red0, Rete0, Red, Rete) :-
    Red0 = red(_, Alfas0, Betas0, Terminales0),
    assoc_to_keys(Terminales0, Ks),
    length(Ks, N),
    K is N + 1,
    compilar_regla(pasos, Regla, Red0-K, Red-_),
    Red = red(_, Alfas, Betas, _),
    nuevas_claves(Alfas0, Alfas, NuevosAlfas),
    nuevas_claves(Betas0, Betas, NuevosBetas),
    foldl(llenar_alfa(Red, Memoria), NuevosAlfas, Rete0, Rete1),
    (   NuevosBetas == []
    ->  colgar_regla(Red, K, Rete1, Rete)
    ;   include(con_padre_viejo(Betas, NuevosBetas), NuevosBetas, Raices),
        foldl(llenar_beta(Red), Raices, Rete1, Rete)
    ).
```

Los nodos alfa nuevos reciben los hechos de la memoria de trabajo del más
antiguo al más reciente, como si hubieran estado desde el principio. Los
nodos beta nuevos cuyo padre ya existía reciben por la izquierda los tokens
del padre, y `salida/6` lleva los tokens hacia los nodos nuevos de más
abajo y hasta la regla. Si la regla no crea ningún nodo beta, porque su
prefijo completo ya estaba en la red, sus instanciaciones salen de los
tokens del nodo del que cuelga.

<!-- contexto: capitulo-64/en_marcha.pl -->
```prolog
?- con_regla_nueva(familia, [padre(juan, ana), padre(ana, sofia)], Is).
Is = [instanciacion(progenitor_p, [2], 1, [agregar(progenitor(ana, sofia))]), instanciacion(progenitor_p, [1], 1, [agregar(progenitor(juan, ana))])].
```

Las pruebas verifican, para cada regla de `familia`, `cajas`, `mcd` y el
configurador, que agregarla después de cargar los hechos da las mismas
instanciaciones que compilarla con las demás; el orden cambia solo porque
la regla agregada recibe el último número. Quitar una regla es el camino
inverso, más simple en este diseño: se borran sus instanciaciones y los
nodos que ninguna otra regla usa, con sus memorias.
