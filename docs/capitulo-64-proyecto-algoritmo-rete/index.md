# Capítulo 64 — Proyecto: el algoritmo Rete

El intérprete del
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) reúne en
cada ciclo el conjunto de conflicto entero: compara todas las reglas con
toda la memoria de trabajo, aunque el ciclo anterior haya cambiado uno o dos
hechos. La [sección 63.6](../capitulo-63-proyecto-sistema-produccion/index.md#636-version-5-el-costo-del-reconocimiento)
lo midió: el 96 % de las instanciaciones de `familia` ya estaba en el ciclo
anterior, y el costo por ciclo del configurador crece con cada hecho del
catálogo, aunque ninguna regla lo use. El **algoritmo Rete** evita ese
trabajo repetido: compila las condiciones de las reglas en una **red**, cuyos
nodos guardan entre ciclos las comparaciones ya hechas, y en cada ciclo
hace pasar por la red solo los hechos que entran y salen de la memoria. El
conjunto de conflicto deja de reunirse: se mantiene.

El capítulo construye la red en siete versiones, sobre las reglas y la
memoria del [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md),
que carga sin copiarlas. La primera compila las reglas en nodos alfa, uno
por patrón, y nodos beta, uno por prefijo de condiciones, compartidos entre
reglas. La segunda llena las memorias alfa. La tercera propaga **tokens**
por las uniones y mantiene el conjunto de conflicto; la cuarta agrega la
negación, con cuentas. La quinta ejecuta el ciclo reconocer-actuar sobre la
red y obtiene los mismos resultados que el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), sello por sello. La
sexta lo mide, y encuentra que la red, tal como está, cuesta más que el
intérprete que reemplaza; la séptima mueve a la red alfa las pruebas que
miran un solo hecho, y el costo de los ciclos deja de depender del
catálogo.

El proyecto parte del capítulo «Performance» de *Building Expert Systems in
Prolog* de Dennis Merritt, que implementa un Rete simplificado para su
sistema *Foops*: nodos raíz, nodos de dos entradas con memorias izquierda y
derecha, tokens con un signo que dice si agregan o quitan, un compilador
que reconoce patrones repetidos y nodos de negación con una cuenta. El
algoritmo es de Charles Forgy. La lista completa está en
[Referencias](#referencias); el código es propio.

El capítulo reutiliza las tablas de `library(assoc)` del
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#225-libraryassoc-y-libraryrbtrees),
las variantes y `=@=` del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md#325-variables-como-datos),
la compilación de reglas del
[capítulo 35](../capitulo-35-transformacion-de-programas-y-compilacion/index.md),
la tabulación del
[capítulo 39](../capitulo-39-tabulacion/index.md#392-memorizacion-sin-estado-escrito-a-mano)
para compilar cada red una sola vez, y el grafo de subexpresiones comunes
del [capítulo 50](../capitulo-50-proyecto-fft-simbolica/index.md#505-las-subexpresiones-comunes-un-grafo).
Todos los archivos cargan otros archivos, así que se ejecutan en una
instalación local.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- compilar las condiciones de un conjunto de reglas en una red de nodos alfa
  y beta, y explicar qué nodos comparten dos reglas;
- propagar por la red un hecho que entra o sale, con activaciones por la
  derecha y por la izquierda, y mantener el conjunto de conflicto;
- implementar la negación con una cuenta por token, y explicar por qué
  quitar un hecho puede agregar instanciaciones;
- comprobar que dos implementaciones del mismo ciclo dan el mismo
  resultado, comparando la memoria final sello por sello;
- medir dónde gasta la red, y decidir qué pruebas se pueden hacer en la red
  alfa sin cambiar el significado de una regla.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:15 h**.
    Resolver los 5 ejercicios marcados con ★: **1:35 h**.
    Resolver los 12 ejercicios del final: **3:20 h**.

## 64.1 El programa terminado

El programa terminado se carga con `swipl ejemplos/capitulo-64/pruebas.pl`,
o con `rete.pl` si no interesan las mediciones. `configurar_rete/4` es el
`configurar/4` del
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), con el
reconocimiento de la red:

<!-- contexto: capitulo-64/rete.pl -->
```prolog
?- configurar_rete([pedido(nucleos, 8), pedido(memoria, 32), pedido(video, si)], C, P, W).
C = [procesador-cpu_b, placa-placa_a, memoria-mem_b, disipador-dis_a, placa_de_video-gpu_a, fuente-fuente_b],
P = 1125,
W = 378.
```

La respuesta es la del [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md). No es una coincidencia buscada: el
ciclo de la red usa la misma memoria de trabajo, la misma refracción y las
mismas estrategias, y una prueba compara la memoria final de los dos
intérpretes, con sus sellos, en todos los programas del [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md).

| Versión | Archivo | Agrega | Lo que no puede hacer todavía |
|---|---|---|---|
| 1 | `red.pl` | la red compilada, con nodos compartidos | guardar hechos |
| 2 | `alfa.pl` | las memorias alfa, indexadas | unir condiciones |
| 3 | `tokens.pl` | tokens, uniones, pruebas y el conjunto de conflicto | la negación |
| 4 | `negacion.pl` | los nodos de negación con cuentas | ejecutar el ciclo |
| 5 | `rete.pl` | el ciclo reconocer-actuar sobre la red | — (funciona; la versión 6 lo mide) |
| 6 | `medida.pl` | la medición contra el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) | evitar que cada objeto entre en cada unión |
| 7 | `pruebas.pl` | las pruebas de un solo hecho en la red alfa | abaratar la carga del catálogo |

## 64.2 Versión 1: la red

**La idea.** Una regla del [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) es una lista de condiciones que se
cumplen de izquierda a derecha. La red tiene un **nodo beta** por cada
prefijo de esa lista: el nodo de `[padre(A, P)]`, el de
`[padre(A, P), progenitor(P, N)]`, y así hasta la regla completa, de cuyo
último nodo cuelga la regla. Cada patrón, además, tiene un **nodo alfa**,
que representa el patrón suelto. El nodo beta de un prefijo que termina en
un patrón **une** el nodo beta anterior con el nodo alfa del patrón; uno que
termina en una prueba `{Meta}` solo la ejecuta. La raíz, el nodo 0, es el
prefijo vacío.

**Compartir.** Dos reglas que empiezan igual comparten los nodos de ese
comienzo, y dos patrones iguales comparten el nodo alfa. «Igual» no puede ser
«unificable»: `sobre(Y, X)` unifica con `sobre(a, piso)` y no piden lo mismo.
Merritt resuelve la comparación ligando las variables de los dos términos a
átomos generados y comparando después; SWI-Prolog ya tiene la relación que
hace falta, `=@=`, que se cumple cuando dos términos son **variantes**:
iguales salvo el nombre de las variables. Para los nodos beta la variante se
pide sobre el prefijo entero, porque importa qué variables comparten las
condiciones: `[p(X), q(X)]` y `[p(X), q(Y)]` no son el mismo nodo.

<!-- ejemplo: capitulo-64/red.pl predicado: unir/6 nodo_beta/6 -->
```prolog
%!  unir(+Pasos:list, +Prefijo0:list, +Padre:integer, +Red0, -Red,
%!       -Hoja:integer) is det.
%
%   Recorre los Pasos que siguen al Prefijo0, cuyo nodo es Padre. Hoja es
%   el nodo del prefijo completo.
unir([], _, Hoja, Red, Red, Hoja).
unir([Paso|Pasos], Prefijo0, Padre, Red0, Red, Hoja) :-
    append(Prefijo0, [Paso], Prefijo),
    nodo_beta(Paso, Prefijo, Padre, Red0, Red1, Nodo),
    unir(Pasos, Prefijo, Nodo, Red1, Red, Hoja).

%!  nodo_beta(+Paso, +Prefijo:list, +Padre:integer, +Red0, -Red,
%!            -Nodo:integer) is det.
%
%   Nodo es el hijo de Padre cuyo prefijo es una variante de Prefijo, que
%   termina en Paso. Si no hay ninguno, se crea.
nodo_beta(_, Prefijo, Padre, Red, Red, Nodo) :-
    Red = red(_, _, Betas, _),
    get_assoc(Padre, Betas, beta(_, _, _, Hijos, _)),
    member(Nodo, Hijos),
    get_assoc(Nodo, Betas, beta(_, _, Guardado, _, _)),
    Guardado =@= Prefijo,
    !.
nodo_beta(Paso, Prefijo, Padre, Red0, Red, Nodo) :-
    tipo_de(Paso, Tipo, Red0, Red1),
    Red1 = red(Indice, Alfas0, Betas0, Terminales),
    max_assoc(Betas0, Ultimo, _),
    Nodo is Ultimo + 1,
    copy_term(Prefijo, Copia),
    put_assoc(Nodo, Betas0, beta(Tipo, Padre, Copia, [], []), Betas1),
    get_assoc(Padre, Betas1, beta(T, P, Pr, Hijos, Rs)),
    append(Hijos, [Nodo], Hijos1),
    put_assoc(Padre, Betas1, beta(T, P, Pr, Hijos1, Rs), Betas),
    agregar_sucesor(Tipo, Nodo, Alfas0, Alfas),
    Red = red(Indice, Alfas, Betas, Terminales).
```

Cada condición se traduce primero a un **paso**: un patrón `F` es
`alfa(F, [])`, y `no(F)` y `{Meta}` quedan como están. La lista vacía del
paso alfa espera a la [sección 64.8](medicion.md#648-version-7-las-pruebas-de-un-solo-hecho-en-la-red-alfa).
`red_de/2` compila la red de un programa; está tabulada, así que la
compilación se hace una vez por programa, y `mostrar_red/1` la escribe:

<!-- contexto: capitulo-64/red.pl -->
```prolog
?- mostrar_red(familia).
alfa 1: padre(A,B) -> [1]
alfa 2: madre(A,B) -> [2]
alfa 3: progenitor(A,B) -> [5,4,3]
alfa 4: antepasado(A,B) -> [7]
beta 1 (de 0, union(1)): padre(A,B) => [progenitor_p]
beta 2 (de 0, union(2)): madre(A,B) => [progenitor_m]
beta 3 (de 1, union(3)): progenitor(B,C) => [abuelo]
beta 4 (de 0, union(3)): progenitor(A,B) => [antepasado_1]
beta 5 (de 4, union(3)): progenitor(A,C)
beta 6 (de 5, prueba): {B\==C} => [hermanos]
beta 7 (de 4, union(4)): antepasado(B,C) => [antepasado_2]
true.
```

Las letras de un nodo beta nombran las variables de todo su prefijo: en el
nodo 3, `progenitor(B,C)` sigue a `padre(A,B)`, y la `B` repetida es la unión.
`hermanos`, `antepasado_1` y `antepasado_2` empiezan con `progenitor(A, B)` y
comparten el nodo 4, que es a la vez la regla `antepasado_1` completa y el
comienzo de las otras dos. El nodo alfa 3 alimenta tres nodos beta: 3, 4 y
5; `hermanos` usa dos veces el mismo patrón, y sus dos uniones leen la misma
memoria alfa. La red no es un árbol por regla sino un grafo acíclico, como
el grafo de la FFT del [capítulo 50](../capitulo-50-proyecto-fft-simbolica/index.md#505-las-subexpresiones-comunes-un-grafo),
que calcula una sola vez cada subexpresión común: aquí se compara una sola
vez cada prefijo común.

```prolog
?- tamano_red(familia, A, B, C).
A = 4,
B = 7,
C = 10.

?- tamano_red(cajas, A, B, C).
A = 4,
B = 14,
C = 20.

?- tamano_red(configurador, A, B, C).
A = 19,
B = 54,
C = 58.
```

`C` es la cantidad de condiciones de las reglas, que sería la de nodos beta
sin compartir ninguno. El robot de las cajas comparte mucho: cuatro reglas
empiezan con `meta(apilar([X, Y|R]))`, y un solo nodo alfa, el de
`sobre(A, B)`, alimenta nueve nodos beta. El configurador comparte poco,
porque casi todas sus reglas empiezan con una fase distinta; pero sus doce
patrones con `objeto/3` comparten un único nodo alfa, que alimenta doce
nodos beta.

!!! question "Actividad"
    Predecir la red del programa `mcd` del
    [capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md#602-modulos-dirigidos-por-patrones),
    cuyas reglas son `resta :: [numero(X), numero(Y), {X > Y}]` y
    `resultado :: [numero(X)]`: cuántos nodos alfa y beta tiene, y de qué
    nodo cuelga cada regla. Comprobarlo con `mostrar_red(mcd)`.

## 64.3 Versión 2: las memorias alfa

Cada nodo alfa tiene una **memoria**: los hechos de la memoria de trabajo
que unifican con su patrón, como pares `Sello-Paso`, donde `Paso` es el
paso del nodo con el patrón ligado al hecho. Un hecho que entra se compara
solo con los nodos alfa de su functor, que el índice de la red da con una
consulta a una tabla; un hecho que ningún patrón usa no se compara con nada.
Merritt llama a estos nodos **raíces** y observa que actúan como índices de
la red.

<!-- contexto: capitulo-64/alfa.pl -->
```prolog
?- alfas_de(cajas, sobre(a, piso), Alfas).
Alfas = [2].

?- alfas_de(cajas, meta(apilar([a])), Alfas).
Alfas = [4].

?- alfas_de(cajas, color(a, rojo), Alfas).
Alfas = [].

?- memorias_alfa(familia, [padre(juan, ana), madre(ana, sofia), padre(ana, luis), hola], M).
M = [1-[1-padre(juan, ana), 3-padre(ana, luis)], 2-[2-madre(ana, sofia)], 3-[], 4-[]].
```

`meta(apilar([a]))` tiene el functor de los nodos 1 y 4, pero el patrón del
nodo 1, `meta(apilar([X, Y|R]))`, pide dos elementos. La memoria de cada
nodo, a su vez, es una tabla indexada por el **primer argumento** del
hecho, como Prolog indexa las cláusulas de un predicado
([sección 16.3](../capitulo-16-rendimiento/index.md#163-indexacion)): quien
busca `padre(juan, X)` mira solo la clave `juan`.

<!-- ejemplo: capitulo-64/alfa.pl predicado: elementos_alfa/3 -->
```prolog
%!  elementos_alfa(+Memoria, +F, -Elementos:list) is det.
%
%   Elementos son los pares Sello-Paso de la Memoria de un nodo alfa que
%   pueden unificar con F. Si el primer argumento de F no tiene variables,
%   se toman solo los de esa clave; si no, todos.
elementos_alfa(Memoria, F, Elementos) :-
    clave(F, Clave),
    (   ground(Clave)
    ->  (   get_assoc(Clave, Memoria, Elementos)
        ->  true
        ;   Elementos = []
        )
    ;   assoc_to_values(Memoria, Listas),
        append(Listas, Elementos)
    ).
```

Un hecho que sale se quita por su sello, sin volver a compararlo con los
patrones. La memoria alfa es solo la entrada de la red: todavía no une una
condición con otra.

## 64.4 Versión 3: tokens y uniones

**Tokens.** Un token es una manera de cumplir el prefijo de un nodo beta: el
par `Sellos-Instancia`, con los sellos de los hechos usados y el prefijo con
las variables ligadas. La memoria de cada nodo beta guarda sus tokens,
indexados por los sellos. La raíz tiene un solo token, `[]-[]`.

**Dos activaciones.** Un nodo de unión tiene dos entradas, y cada una lo
activa de una manera. Cuando un hecho entra en su memoria alfa, el nodo se
activa **por la derecha**: el hecho se une con cada token del padre. Cuando
el padre produce un token nuevo, el nodo se activa **por la izquierda**: el
token se une con cada hecho de la memoria alfa que puede unificar. Los
tokens que resultan entran en la memoria del nodo y siguen hacia sus hijos;
el token que completa una regla es una instanciación, que entra en el
conjunto de conflicto. Un hecho que sale recorre el mismo camino con el
signo `menos` y quita lo que su entrada agregó.

<!-- ejemplo: capitulo-64/tokens.pl predicado: propagar/6 derecha/8 izquierda/8 -->
```prolog
%!  propagar(+Signo, +Sello:integer, +Hecho, +Red, +Rete0, -Rete) is det.
%
%   Hecho, con el Sello, entra en la red (Signo mas) o sale (Signo menos).
%   Primero cambian las memorias alfa; después se activan por la derecha
%   los nodos que las leen, del más profundo al menos profundo, para que un
%   token nuevo no se una dos veces con el mismo hecho.
propagar(Signo, Sello, Hecho, Red, rete(Alfas0, Betas, Conjunto), Rete) :-
    entrar_alfa(Signo, Sello, Hecho, Red, Alfas0, Alfas, Entradas),
    Red = red(_, Info, _, _),
    findall(B-Paso,
            ( member(A-Paso, Entradas),
              get_assoc(A, Info, a(_, Sucesores)),
              member(B, Sucesores) ),
            Activaciones0),
    sort(1, @>=, Activaciones0, Activaciones),
    foldl(activar_derecha(Signo, Sello, Red), Activaciones,
          rete(Alfas, Betas, Conjunto), Rete).

%!  derecha(+Tipo, +Signo, +Elemento, +PadreNodo, +Prefijo:list, +Red,
%!          +Rete0, -Rete) is det.
%
%   Un nodo de unión une el Elemento Sello-Paso con cada token de su
%   padre, y pasa a su salida los tokens que resultan. El prefijo se copia
%   una sola vez; findall/3 deshace las ligaduras de cada intento.
derecha(union(_), Signo, Sello-Paso, Padre-Nodo, Prefijo, Red, Rete0,
        Rete) :-
    tokens(Padre, Rete0, Tokens),
    copy_term(Prefijo, P),
    once(append(Anterior, [Paso], P)),
    findall(Sellos1-P,
            ( member(Sellos-Anterior, Tokens),
              append(Sellos, [Sello], Sellos1) ),
            Nuevos),
    foldl(salida(Signo, Nodo, Red), Nuevos, Rete0, Rete).

%!  izquierda(+Tipo, +Signo, +Token, +Nodo:integer, +Prefijo:list, +Red,
%!            +Rete0, -Rete) is det.
%
%   Un nodo de unión une el Token que llega de su padre con cada hecho de
%   su memoria alfa que puede unificar; una prueba ejecuta su meta con las
%   variables del Token, y pasa un token por cada solución.
izquierda(union(A), Signo, Sellos-Instancia, Nodo, Prefijo, Red, Rete0,
          Rete) :-
    Rete0 = rete(Alfas, _, _),
    get_assoc(A, Alfas, Memoria),
    copy_term(Prefijo, P),
    findall(Sellos1-P,
            ( append(Instancia, [Paso], P),
              Paso = alfa(F, _),
              elementos_alfa(Memoria, F, Elementos),
              member(Sello-Paso, Elementos),
              append(Sellos, [Sello], Sellos1) ),
            Nuevos),
    foldl(salida(Signo, Nodo, Red), Nuevos, Rete0, Rete).
izquierda(prueba, Signo, Sellos-Instancia, Nodo, Prefijo, Red, Rete0,
          Rete) :-
    copy_term(Prefijo, P),
    findall(Sellos-P,
            ( append(Instancia, [{Meta}], P),
              call(Meta) ),
            Nuevos),
    foldl(salida(Signo, Nodo, Red), Nuevos, Rete0, Rete).
```

El prefijo del nodo se copia una sola vez por activación; dentro de
`findall/3`, cada intento liga las variables de la copia y el retroceso las
deshace. La unión es la unificación: `append(Instancia, [Paso], P)` pide
que la instancia del token y el hecho sean compatibles con el prefijo.

**El orden de las activaciones.** Un hecho puede entrar por los dos lados de
la misma cadena: en `hermanos`, `progenitor(juan, ana)` activa por la derecha
el nodo 4, que produce un token que activa por la izquierda el nodo 5, que
lee la misma memoria alfa. Si después el hecho activara por la derecha el
nodo 5, la pareja del hecho consigo mismo aparecería dos veces. Por eso los
sucesores de cada nodo alfa quedan del más profundo al menos profundo, y
`propagar/6` los activa en ese orden: el nodo 5 se activa por la derecha
antes de que el nodo 4 le entregue el token nuevo.

**El conjunto de conflicto.** Se guarda en una tabla cuya clave es `K-Inversos`:
el número de la regla y sus sellos cambiados de signo. Recorrer la tabla en
orden da las instanciaciones por el orden de las reglas y, dentro de una
regla, del hecho más reciente al más antiguo, que es el orden en que las
reúne `conjunto_conflicto/3` del [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md):

```prolog
?- reconocer_rete(familia, [padre(juan, ana), padre(ana, sofia)], Is).
Is = [instanciacion(progenitor_p, [2], 1, [agregar(progenitor(ana, sofia))]), instanciacion(progenitor_p, [1], 1, [agregar(progenitor(juan, ana))])].

?- cambios_rete(familia, [padre(juan, ana), padre(ana, sofia)], [mas(progenitor(ana, sofia)), menos(padre(juan, ana))], Is).
Is = [instanciacion(progenitor_p, [2], 1, [agregar(progenitor(ana, sofia))]), instanciacion(antepasado_1, [3], 1, [agregar(antepasado(ana, sofia))])].
```

Con `progenitor(ana, sofia)` entran `abuelo` y `antepasado_1`; al salir
`padre(juan, ana)` salen `progenitor_p` con el sello 1 y `abuelo`, que lo
usaba. `mismo_conjunto/3` aplica una lista de cambios y compara el conjunto
de la red con el que reúne el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) en la misma memoria; las pruebas
de `tokens.plt` lo hacen con `familia`, `mcd`, `ordenar` y los disipadores.

Esta versión no conoce la negación: en el robot de las cajas, la meta llega
al nodo de `no(sobre(_, X))`, `izquierda/8` no tiene cláusula para él, y la
consulta falla.

```prolog
?- reconocer_rete(cajas, [meta(despejar(a)), sobre(a, piso)], Is).
false.
```

## 64.5 Versión 4: la negación

Un nodo `no(F)` no puede guardar solo los tokens que pasan: un hecho que
sale de su memoria alfa puede dejar pasar uno que estaba bloqueado. Guarda
cada token de su padre con una **cuenta**: cuántos hechos de su memoria alfa
unifican con `F` bajo las variables del token. El token pasa a la salida
mientras su cuenta es cero. Un hecho que entra sube la cuenta de los tokens
que bloquea, y el que pasa de cero a uno sale de la salida; un hecho que
sale la baja, y el token que llega a cero vuelve a entrar.

<!-- ejemplo: capitulo-64/negacion.pl predicado: recontar/7 paso_cuenta/6 -->
```prolog
%!  recontar(+Signo, +Prefijo:list, +Hecho, +Cuenta0, -Cuenta, +Cambios0,
%!           -Cambios) is det.
%
%   Cuenta0 y Cuenta son términos Sellos-(Instancia-N). Si Hecho bloquea el
%   token Sellos-Instancia, N sube (mas) o baja (menos) en uno. Cambios
%   agrega a Cambios0 el par menos-Token si la cuenta pasó de cero a uno, y
%   mas-Token si pasó de uno a cero.
recontar(Signo, Prefijo, Hecho, Sellos-(Instancia-N0),
         Sellos-(Instancia-N), Cambios0, Cambios) :-
    (   bloquea(Instancia, Prefijo, Hecho)
    ->  paso_cuenta(Signo, N0, N, Sellos-Instancia, Cambios0, Cambios)
    ;   N = N0,
        Cambios = Cambios0
    ).

%!  paso_cuenta(+Signo, +N0:integer, -N:integer, +Token, +Cambios0,
%!              -Cambios) is det.
%
%   N es N0 más o menos uno, según el Signo, y Cambios registra si el
%   Token deja de pasar o vuelve a pasar.
paso_cuenta(mas, N0, N, Token, Cambios0, Cambios) :-
    N is N0 + 1,
    (   N0 =:= 0
    ->  Cambios = [menos-Token|Cambios0]
    ;   Cambios = Cambios0
    ).
paso_cuenta(menos, N0, N, Token, Cambios0, Cambios) :-
    N is N0 - 1,
    (   N =:= 0
    ->  Cambios = [mas-Token|Cambios0]
    ;   Cambios = Cambios0
    ).
```

`negacion.pl` agrega estas cláusulas a `derecha/8` e `izquierda/8`, que
`tokens.pl` declara `multifile`, como el
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md#633-version-2-las-estrategias-lex-y-mea)
agrega estrategias a `clave_estrategia/3`. En el robot, el nodo 11 es
`no(sobre(B, A))` después de `meta(despejar(A))`:

<!-- contexto: capitulo-64/negacion.pl -->
```prolog
?- cuentas(cajas, [meta(despejar(a)), sobre(b, a)], 11, C).
C = [[1]-1].

?- cuentas(cajas, [meta(despejar(a)), meta(despejar(b)), sobre(b, a), sobre(c, a)], 11, C).
C = [[1]-2, [2]-0].

?- cambios_rete(cajas, [meta(despejar(a)), sobre(b, a)], [menos(sobre(b, a))], Is).
Is = [instanciacion(despejada, [1], 2, [quitar(meta(despejar(a)))])].
```

La caja `a` tiene dos cajas encima y `b` ninguna. En la última consulta,
**quitar** un hecho **agrega** una instanciación: sin `sobre(b, a)`, la meta
de despejar `a` está cumplida, y `despejada` entra en el conjunto de
conflicto. Antes del cambio el conjunto tenía `despejar_encima`, que usaba
`sobre(b, a)` y salió con él.

## 64.6 Versión 5: el ciclo sobre la red

El ciclo es el de `reconocer_actuar/9` del [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), con dos cambios: el
conjunto de conflicto se lee de la red en lugar de reunirse, y cada acción
que agrega o quita un hecho lo propaga. `un_ciclo/9` hace un ciclo, y
`ciclo_rete/9` lo repite:

<!-- ejemplo: capitulo-64/rete.pl predicado: un_ciclo/9 -->
```prolog
%!  un_ciclo(+Red, +Estrategia, +Traza, +N:integer, +Disparadas0:list,
%!           -Disparadas:list, +Estado0, -Estado, -Fin) is semidet.
%
%   Hace el ciclo número N. Disparadas0 es el conjunto ordenado de los
%   pares Regla-Sellos ya disparados. Fin es nada_aplicable si no hay
%   instanciaciones nuevas, parar(R) si una acción para, y seguir si no.
%   La instanciación elegida sale del conjunto de conflicto antes de
%   ejecutar sus acciones; Disparadas sigue haciendo falta, porque una
%   negación puede volver a agregarla con los mismos sellos. Falla si una
%   acción quita un hecho que no está.
un_ciclo(Red, Estrategia, Traza, N, Disparadas0, Disparadas, Estado0,
         Estado, Fin) :-
    Estado0 = Memoria0-Rete0,
    conjunto_rete(Rete0, Todas),
    refractar(Todas, Disparadas0, Nuevas),
    (   Nuevas == []
    ->  Disparadas = Disparadas0,
        Estado = Estado0,
        Fin = nada_aplicable
    ;   preferida(Estrategia, Nuevas, Elegida),
        informar(Traza, N, Nuevas, Elegida, Memoria0),
        Elegida = instanciacion(Nombre, Sellos, _, Acciones),
        ord_add_element(Disparadas0, Nombre-Sellos, Disparadas),
        quitar_elegida(Red, Elegida, Rete0, Rete1),
        acciones_rete(Acciones, Red, Memoria0-Rete1, Estado, Fin)
    ).
```

`refractar/3`, `preferida/3` e `informar/5` son los del
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md#632-version-1-la-memoria-como-conjunto-y-la-refraccion);
la memoria de trabajo es `mt/2`, con `afirmar/3` y `retirar/3`, y cada hecho
nuevo entra en la red con el sello que le da el reloj. La traza es la misma:

```prolog
?- rastrear_rete(familia, orden, [padre(juan, ana), madre(ana, sofia)], M, R).
1: progenitor_p de 2, con [1-padre(juan,ana)]
2: progenitor_m de 2, con [2-madre(ana,sofia)]
3: abuelo de 3, con [1-padre(juan,ana),4-progenitor(ana,sofia)]
4: antepasado_1 de 2, con [4-progenitor(ana,sofia)]
5: antepasado_1 de 2, con [3-progenitor(juan,ana)]
6: antepasado_2 de 1, con [3-progenitor(juan,ana),6-antepasado(ana,sofia)]
M = [antepasado(juan, sofia), antepasado(juan, ana), antepasado(ana, sofia), abuelo(juan, sofia), progenitor(ana, sofia), progenitor(juan, ana), madre(ana, sofia), padre(juan, ana)],
R = nada_aplicable.
```

**La refracción.** Merritt observa que con la red la instanciación
disparada sale del conjunto de conflicto y no vuelve, porque ningún token
nuevo repite sus sellos; la refracción del intérprete se vuelve
innecesaria. `un_ciclo/9` también la saca, y así el conjunto no crece con
las ya disparadas; pero conserva el registro `Disparadas`, porque con la
negación el argumento no vale: una condición `no(F)` no aporta sellos, y
cuando `F` entra y vuelve a salir, el mismo token vuelve a pasar con los
mismos sellos. El programa `reingreso` de `negacion.pl` lo muestra:

<!-- ejemplo: capitulo-64/negacion.pl fragmento: programa(reingreso, .. ]). -->
```prolog
programa(reingreso,
    [ avisar :: [no(ocupado)] ---> [agregar(aviso)],
      ocupar :: [aviso, no(ocupado)] ---> [agregar(ocupado)],
      liberar :: [ocupado] ---> [quitar(ocupado)]
    ]).
```

<!-- contexto: capitulo-64/rete.pl -->
```prolog
?- rastrear_rete(reingreso, orden, [], M, R).
1: avisar de 1, con []
2: ocupar de 1, con [1-aviso]
3: liberar de 1, con [2-ocupado]
M = [aviso],
R = nada_aplicable.
```

En el ciclo 3, `liberar` quita `ocupado`, y `avisar` y `ocupar` vuelven al
conjunto de conflicto con los sellos `[]` y `[1]`. Están en `Disparadas`, y
el programa termina, como en el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md); sin el registro, `ocupar`
volvería a agregar `ocupado` con un sello nuevo, `liberar` a quitarlo, y el
programa no terminaría (ejercicio 6).

**La comparación.** `iguales/3` ejecuta un programa con los dos
intérpretes y compara la cantidad de ciclos, el resultado y la memoria
final como término `mt/2`, con el reloj y los sellos:

```prolog
?- iguales(cajas, mea, [meta(apilar([b, c])), meta(apilar([a, d])), sobre(a, piso), sobre(b, piso), sobre(c, a), sobre(d, piso)]).
true.
```

Las pruebas de `rete.plt` lo hacen con `familia`, el robot, `mcd`,
`ordenar`, `reingreso` y el configurador y su versión invertida con los
tres pedidos del [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), con las tres estrategias.

!!! question "Actividad"
    Predecir cuántas instanciaciones hay en el conjunto de conflicto de la
    red de `familia` después del ciclo 3 de la traza anterior, contando las
    que no se disparan porque ya salieron. Comprobarlo con
    `cambios_rete/4`, aplicando a mano los cambios de los tres primeros
    ciclos.

La [versión 6](medicion.md#647-version-6-la-medicion) mide la red contra el
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), y la [versión 7](medicion.md#648-version-7-las-pruebas-de-un-solo-hecho-en-la-red-alfa)
mueve a la red alfa las pruebas que miran un solo hecho. Las dos están en
[una página aparte](medicion.md).

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; la propagación, la compilación y el ciclo son `det`, y `retirar_rete/4`, `un_ciclo/9` y `acciones_rete/5` son `semidet`, como sus originales del [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) |
    | C2 | la red es un término, `red/4`, con tablas de `library(assoc)`; el estado, `rete/3`, viaja en argumentos junto a la memoria `mt/2`; los nodos se comparan con `=@=` y no con unificación |
    | C4 | las cláusulas de los tres tipos de nodo se distinguen por su primer argumento, y la negación despacha por el signo en `llega_a_negacion/8`; las pruebas fallan si queda una alternativa pendiente |
    | C6 | la red se escribe sin copiar el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md): carga sus archivos, reutiliza su memoria, su refracción, sus estrategias y su traza, y la negación y las pruebas alfa se agregan con cláusulas `multifile` y con otro agrupador para el mismo compilador |
    | C7 | 51 pruebas en siete archivos; la central compara con el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) el conjunto de conflicto después de cambios sueltos y la memoria final de ejecuciones enteras, sello por sello, en todos sus programas y estrategias |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden los programas: cada solución es un
archivo que carga los del capítulo, sin modificarlos.

1. ★ **(1)** Predecir la red del programa `tienda`, con las reglas
   `oferta :: [producto(P, C), {C > 100}, cliente(K, P)]`,
   `aviso :: [producto(P, C), {C > 100}]` y
   `venta :: [producto(Q, D), cliente(K, Q)]`: cuántos nodos alfa y beta
   tiene, cuáles comparten las reglas, y de qué nodo cuelga cada una.
   Comprobarlo con `compilar_red/3` y `mostrar/1`.
2. **(1)** Escribir `hermanos` con la prueba `{A \== B}` antes de la
   segunda condición, donde falla porque `B` todavía está libre, y con las
   dos condiciones en el orden inverso. Predecir qué nodos comparte cada
   versión con `antepasado_1`, y comprobarlo.
3. **(1)** Explicar por qué la clave del conjunto de conflicto lleva los
   sellos cambiados de signo. Con la clave `K-Sellos`, ¿qué estrategia
   elegiría otra instanciación, y en qué programa se nota? Comprobarlo con
   una copia de `terminal/6`.
4. ★ **(2)** Escribir, en otro archivo, una carga de hechos que activa los
   sucesores de cada nodo alfa en el orden inverso al de `propagar/6`, del
   menos profundo al más profundo. Predecir qué instanciación aparece dos veces en el
   conjunto de conflicto del programa `pares :: [p(X), p(Y)] --->
   [agregar(par(X, Y))]` con los hechos `p(1)` y `p(2)`, comprobarlo, y
   explicarlo con las dos activaciones de la
   [sección 64.4](#644-version-3-tokens-y-uniones). Explicar por qué en
   `hermanos` el error no llega al conjunto de conflicto.
5. ★ **(2)** Predecir las cuentas del nodo 11 del robot después de cargar
   `[meta(despejar(a)), meta(despejar(b)), sobre(b, a), sobre(c, b)]` y
   después de quitar `sobre(b, a)`. Predecir qué instanciaciones entran y
   salen del conjunto con ese cambio, y comprobarlo con `cuentas/4` y
   `cambios_rete/4`.
6. ★ **(2)** Escribir `ciclo_sin_registro/6`, que ejecuta una red como
   `ciclo_rete/9` pero sin `Disparadas`, confiando en que la instanciación
   disparada sale del conjunto, con un límite de ciclos. Ejecutar
   `reingreso` y explicar lo que ocurre; comprobar que con `familia` y con
   el configurador da los mismos resultados que el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md).
7. **(2)** Escribir una versión de `activar_derecha/6` que activa el nodo
   aunque su padre no tenga tokens, y medir con ella la carga del
   configurador con 0 y 400 memorias agregadas. Explicar la diferencia.
8. **(1)** `red_de/2` está tabulada. Agregar, en una sesión, una cláusula
   nueva de `programa/2` para un nombre ya compilado es imposible, pero sí
   puede cambiar un predicado que una prueba `{Meta}` llama. Explicar qué
   parte de la red queda desactualizada cuando cambia un marco que usa
   `es_de_clase/2` en la versión 7, y qué hace falta para compilarla de
   nuevo.
9. ★ **(3)** Escribir `rastrear_cambios/4`, que ejecuta un programa en la
   red y escribe en cada ciclo, además de la regla elegida, qué
   instanciaciones entraron en el conjunto de conflicto y cuáles salieron
   por las acciones de ese ciclo. Usarlo con el robot y explicar las
   salidas que provoca una negación.
10. **(2)** Contar con `tokens_guardados/3` los tokens de la red de
    `familia` al terminar la cadena de 10, 20 y 40 generaciones, y
    relacionarlos con la cantidad de hechos `antepasado/2` de la memoria.
    Explicar qué parte de la memoria del programa ocupa la red.
11. **(3)** Escribir `pasos_forzados/2`, un agrupador que mueve al nodo alfa
    todas las pruebas que siguen a un patrón, sin mirar sus variables.
    Encontrar una regla del configurador cuyo resultado cambia con él, y
    explicar el cambio con `solo_del_hecho/3`.
12. **(2)** Con las filas de la
    [sección 64.8](medicion.md#648-version-7-las-pruebas-de-un-solo-hecho-en-la-red-alfa),
    calcular cuántos ciclos tendría que hacer el configurador sobre el
    catálogo de 828 hechos para que la red con pruebas alfa costara menos
    que el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), suponiendo que cada ciclo agregado cuesta lo que el
    promedio de los medidos. Discutir si la suposición es razonable.

## Resumen

| | |
|---|---|
| **Rete** | las reglas compiladas en una red que guarda entre ciclos las comparaciones hechas; solo los hechos que cambian la recorren |
| **nodo alfa** | un patrón suelto y su memoria: los hechos que unifican con él, indexados por el primer argumento |
| **nodo beta** | un prefijo de las condiciones de una regla y su memoria de tokens; dos reglas con prefijos variantes lo comparten |
| **token** | una manera de cumplir un prefijo: los sellos de los hechos usados y el prefijo con las variables ligadas |
| **activación por la derecha** | un hecho que entra en la memoria alfa se une con cada token del padre |
| **activación por la izquierda** | un token nuevo del padre se une con cada hecho de la memoria alfa, o pasa la prueba |
| **negación con cuentas** | cada token recuerda cuántos hechos lo bloquean, y pasa mientras la cuenta es cero |
| **prueba en la red alfa** | una prueba que solo mira el hecho de su patrón se ejecuta antes de las uniones |
| `red.pl`, `alfa.pl` | la compilación con nodos compartidos y las memorias alfa |
| `tokens.pl`, `negacion.pl` | la propagación con signo, el conjunto de conflicto y la negación |
| `rete.pl`, `medida.pl`, `pruebas.pl` | el ciclo, su comparación con el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), la medición y las pruebas alfa |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La evaluación de reglas de abajo hacia arriba sobre una base que crece, con la técnica semi-ingenua, que como la red solo procesa lo que cambió en cada paso | [capítulo 85](../capitulo-85-proyecto-motor-datalog/index.md) |

## Referencias

- Dennis Merritt, *Building Expert Systems in Prolog*, Springer-Verlag,
  1989 — capítulo «Performance», apartados «Rete Match Algorithm», «The
  Rete Graph Data Structures», «Propagating Tokens», «The Rule Compiler»,
  «Integration with Foops» y «Design Tradeoffs».
  [Edición en línea](https://www.amzi.com/ExpertSystemsInProlog/08performance.php),
  de Amzi!. El capítulo toma de allí la red de nodos raíz, de dos entradas y
  de regla; las memorias izquierda y derecha; los tokens con un signo que
  agrega o quita; el compilador que reconoce patrones y prefijos repetidos
  comparando los términos salvo el nombre de las variables; los nodos de
  prueba sin memoria; la negación con una cuenta por token; la observación
  de que la refracción se vuelve innecesaria sin negación, y el intercambio
  entre memoria y velocidad. La licencia de esa edición no permite obras
  derivadas: se toman las ideas, no el código.
- Charles L. Forgy, «Rete: A Fast Algorithm for the Many Pattern/Many
  Object Pattern Match Problem», *Artificial Intelligence* 19 (1), 1982.
  [DOI 10.1016/0004-3702(82)90020-0](https://doi.org/10.1016/0004-3702(82)90020-0).
  El artículo que presenta el algoritmo; el capítulo toma de allí el nombre
  y la idea de guardar entre ciclos el estado de la comparación.
- Robert B. Doorenbos, *Production Matching for Large Learning Systems*,
  tesis doctoral, Carnegie Mellon University, 1995 (informe
  CMU-CS-95-113). El capítulo toma de allí los nombres de memorias alfa y
  beta, el orden de los sucesores de una memoria alfa, del más profundo al
  menos profundo, para no unir dos veces un hecho consigo mismo, y la idea
  de no activar un nodo cuyo padre no tiene tokens.

El código del capítulo es propio, escrito para el curso: la compilación, las
memorias, la propagación, la negación, el ciclo, la medición y las pruebas
alfa son nuevos, y de las fuentes se toman las ideas, no el código.
