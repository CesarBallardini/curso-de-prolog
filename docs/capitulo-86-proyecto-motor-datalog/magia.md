# La transformación mágica y los hechos que llegan después

Esta página continúa el [capítulo 86](index.md) después de la
[sección 86.5](index.md#865-version-3-las-componentes-y-la-negacion),
con las secciones
[86.6](#866-version-4-las-consultas-y-la-transformacion-magica) y
[86.7](#867-version-5-los-hechos-que-llegan-despues): la versión 4 del
motor, que responde una consulta derivando solo lo que la consulta
necesita, y la versión 5, que agrega hechos a un modelo ya calculado sin recalcularlo. El código está en
`magia.pl`, `tablas.pl` e `incremental.pl`, en `ejemplos/capitulo-86/`,
con sus pruebas.

## 86.6 Versión 4: las consultas y la transformación mágica

### Los predicados mágicos

La consulta `camino(0, Y)` sobre los 40 arcos en fila necesita los 40
caminos que salen de 0; la evaluación calcula los 820. El
[ejercicio 13 del capítulo 39](../capitulo-39-semantica-de-los-programas-logicos/soluciones.md#13)
lo resolvió escribiendo a mano un programa especializado, `alcanza/1`. La
**transformación mágica** de Nilsson y Małuszyński (su definición 15.4)
escribe ese programa a partir de la consulta. Para cada predicado *p*
introduce uno nuevo que dice con qué argumentos se **llamaría** a *p* en
una ejecución de arriba hacia abajo, y agrega a cada regla de *p* la
condición de que haya sido llamado.

La versión de este capítulo es la de los **conjuntos mágicos**: los hechos
mágicos no tienen variables, porque el motor solo guarda átomos sin
variables. Cada predicado se **adorna** con una letra por argumento, `b`
si llega ligado y `f` si llega libre: la consulta `camino(0, Y)` es
`camino_bf`, y su hecho mágico guarda solo los argumentos ligados,
`m_camino_bf(0)`. Las reglas se transforman así:

- cada regla de `camino_bf` agrega delante del cuerpo el literal
  `m_camino_bf(X)`: solo deriva caminos que salen de un nodo llamado;
- cada literal del cuerpo de un predicado con reglas se adorna según lo
  que ligan la cabeza y los literales anteriores, de izquierda a derecha,
  como en Prolog, y produce una **regla mágica**: el literal es llamado si
  la cabeza fue llamada y los literales anteriores son verdaderos;
- la consulta aporta el primer hecho mágico, la **semilla**.

`mostrar_magico(nilsson, path(a, Y))` escribe el programa transformado,
sin los hechos de `edge/2`:

```prolog
m_path_bf(a).
path_bf(A, B) :-
    m_path_bf(A),
    edge(A, B).
path_bf(A, B) :-
    m_path_bf(A),
    path_bf(A, C),
    edge(C, B).
m_path_bf(A) :-
    m_path_bf(A).
```

La última regla es la mágica del literal recursivo: `path(X, Z)` se llama
con el mismo primer argumento que la cabeza, así que no agrega llamadas
nuevas. `magico/3` hace la transformación con una lista de pares
`Predicado-Adorno` pendientes, como un recorrido en anchura: cada regla
de un par produce los pares de los literales que llama, y un par ya
transformado no se repite:

<!-- ejemplo: capitulo-86/magia.pl predicado: adorno/3 magico_de/3 -->
```prolog
%!  adorno(+Atomo, +Ligadas:list, -Adorno:atom) is det.
%
%   Adorno tiene una letra por argumento de Atomo: b si el argumento está
%   ligado, porque es una constante o una variable de Ligadas, un conjunto
%   ordenado de variables, y f si está libre.
adorno(Atomo, Ligadas, Adorno) :-
    Atomo =.. [_|Args],
    maplist(letra(Ligadas), Args, Letras),
    atomic_list_concat(Letras, Adorno).

%!  magico_de(+Atomo, +Adorno, -Magico) is det.
%
%   Magico es el átomo m_Nombre_Adorno con los argumentos de Atomo que el
%   Adorno marca con b.
magico_de(Atomo, Adorno, Magico) :-
    Atomo =.. [Nombre|Args],
    atom_chars(Adorno, Letras),
    foldl(ligado, Letras, Args, Ligados, []),
    atomic_list_concat([m, Nombre, Adorno], '_', Nombre1),
    Magico =.. [Nombre1|Ligados].
```

<!-- ejemplo: capitulo-86/magia.pl predicado: magico/3 transformar_clausula/6 cuerpo/9 -->
```prolog
%!  magico(+Clausulas:list, +Meta, -Programa:list) is det.
%
%   Programa es la transformación mágica de Clausulas para la consulta
%   Meta, un átomo de un predicado definido por reglas: los hechos de los
%   predicados sin reglas, la semilla de Meta, las reglas adornadas y las
%   mágicas de cada predicado y adorno que la consulta alcanza, y las
%   cláusulas originales de los predicados que se usan negados y de los
%   que estos dependen. Error de dominio si Meta no tiene reglas.
magico(Clausulas, Meta, Programa) :-
    con_reglas(Clausulas, Idb),
    predicado(Meta, PM),
    (   ord_memberchk(PM, Idb)
    ->  true
    ;   domain_error(predicado_con_reglas, PM)
    ),
    adorno(Meta, [], Adorno),
    magico_de(Meta, Adorno, Semilla),
    transformar([PM-Adorno], [], Clausulas, Idb, Reglas, [], Negados),
    completos(Clausulas, Idb, Negados, Completos),
    include(original(Idb, Completos), Clausulas, Originales),
    append([Originales, [(Semilla :- true)], Reglas], Programa).

%!  transformar_clausula(+Clausula, +Adorno, +Idb:list, -Reglas:list,
%!                       -Llamados:list, -Negados:list) is det.
%
%   Reglas son la regla adornada de Clausula, con el hecho mágico de su
%   cabeza delante del cuerpo, y una regla mágica por cada literal de un
%   predicado de Idb. Llamados son los pares Predicado-Adorno de esos
%   literales, y Negados, ordenados, los predicados de Idb usados negados.
transformar_clausula(H :- B, Adorno, Idb, [Adornada|Magicas], Llamados,
                     Negados) :-
    literales(B, Ls),
    H =.. [_|Args],
    atom_chars(Adorno, Letras),
    foldl(ligado, Letras, Args, ArgsLigados, []),
    term_variables(ArgsLigados, Vs0),
    sort(Vs0, Ligadas),
    magico_de(H, Adorno, MH),
    cuerpo(Ls, Ligadas, MH, [], Idb, Cuerpo, Magicas, Llamados, Ns),
    sort(Ns, Negados),
    adornado(H, Adorno, HA),
    lista_conjuncion([MH|Cuerpo], C),
    Adornada = (HA :- C).

%!  cuerpo(+Literales:list, +Ligadas:list, +MH, +Antes:list, +Idb:list,
%!         -Cuerpo:list, -Magicas:list, -Llamados:list, -Negados:list)
%!      is det.
%
%   Cuerpo son los Literales con los de Idb adornados según las variables
%   Ligadas en cada punto, de izquierda a derecha. Antes son, en orden
%   inverso, los literales ya transformados; la regla mágica de un literal
%   de Idb tiene el cuerpo MH, el hecho mágico de la cabeza, seguido de
%   ellos.
cuerpo([], _, _, _, _, [], [], [], []).
cuerpo([L|Ls], Ligadas0, MH, Antes, Idb, [L1|Cuerpo], Magicas, Llamados,
       Negados) :-
    (   L = (\+ A)
    ->  L1 = L,
        Ligadas = Ligadas0,
        Magicas = Magicas1,
        Llamados = Llamados1,
        predicado(A, P),
        (   ord_memberchk(P, Idb)
        ->  Negados = [P|Negados1]
        ;   Negados = Negados1
        )
    ;   ( L = (_ is _) ; comparacion(L) )
    ->  L1 = L,
        term_variables(L, Vs0),
        sort(Vs0, Vs),
        ord_union(Ligadas0, Vs, Ligadas),
        Magicas = Magicas1,
        Llamados = Llamados1,
        Negados = Negados1
    ;   predicado(L, P),
        ord_memberchk(P, Idb)
    ->  adorno(L, Ligadas0, Adorno),
        adornado(L, Adorno, L1),
        magico_de(L, Adorno, ML),
        reverse(Antes, Previos),
        lista_conjuncion([MH|Previos], C),
        Magicas = [(ML :- C)|Magicas1],
        Llamados = [P-Adorno|Llamados1],
        Negados = Negados1,
        ligar(L, Ligadas0, Ligadas)
    ;   L1 = L,
        Magicas = Magicas1,
        Llamados = Llamados1,
        Negados = Negados1,
        ligar(L, Ligadas0, Ligadas)
    ),
    cuerpo(Ls, Ligadas, MH, [L1|Antes], Idb, Cuerpo, Magicas1, Llamados1,
           Negados1).
```

Un literal negado, `\+ q(X)`, no se adorna: la negación necesita la
relación `q` entera, y no solo los átomos que alguna llamada pidió. Los
predicados usados negados, y aquellos de los que dependen, conservan sus
reglas originales y se evalúan completos (`completos/4`). Así el programa
transformado sigue siendo estratificado: los predicados mágicos y los
adornados dependen de los completos, y nunca al revés.

La transformación es el patrón 96:

!!! example "Patrón 96 — La consulta como semilla"
    **Problema.** Un cálculo de abajo hacia arriba termina siempre, pero
    calcula todo lo que el programa permite deducir, aunque la pregunta
    sea por una parte pequeña.

    **Versión ingenua.** Calcular el modelo entero y quedarse con lo que
    unifica con la consulta (`respuestas/4`), o escribir de manera explícita
    una versión del programa especializada para cada forma de la consulta,
    como `alcanza/1` en el
    [ejercicio 13 del capítulo 39](../capitulo-39-semantica-de-los-programas-logicos/soluciones.md#13).

    **Patrón.** Reescribir el programa para que cada regla exija que su
    cabeza haya sido **pedida**: un predicado nuevo guarda los valores con
    que se pediría cada predicado, las reglas mágicas dicen qué pide cada
    literal a partir de su cabeza y de los literales anteriores, y la
    consulta aporta el primer pedido, la **semilla** (`magico/3`). El
    cálculo sigue siendo de abajo hacia arriba, y sigue terminando; solo
    deriva lo que alguna llamada pide. La fila de 40 arcos responde
    `camino(0, Y)` con 41 derivaciones en lugar de 820.

    **Cuándo no usarlo.** Cuando la consulta no liga nada que el programa
    pueda aprovechar: con el adorno `ff`, o con la recursión en la
    dirección que pierde el argumento ligado, la transformación agrega
    hechos mágicos al mismo trabajo (862 contra 820). Y cuando casi todo
    lo que la consulta usa está bajo una negación, que necesita la
    relación entera: en el Wumpus y en los marcos, la ganancia es pequeña
    o nula.

### Cuándo la transformación reduce el trabajo

<!-- contexto: capitulo-86/datalog.pl -->
```prolog
?- consulta(cadena(40), camino(0, Y), Rs, C1), consulta_magica(cadena(40), camino(0, Y), Rs, C2).
Rs = [camino(0, 1), camino(0, 2), camino(0, 3), camino(0, 4), camino(0, 5), camino(0, 6), camino(0, 7), camino(0, 8), camino(0, 9)|...],
C1 = costo(41, 820),
C2 = costo(42, 41).
```

Las mismas 40 respuestas con 41 derivaciones en lugar de 820: los 40
caminos y el único hecho mágico derivado, `m_camino_bf(0)` por la regla
mágica trivial. La transformación no siempre ayuda. Con el segundo
argumento ligado, `camino(X, 40)`, la recursión a la izquierda llama a
`camino(X, Z)` con los dos argumentos libres, y el adorno `ff` pide la
relación entera; con la recursión a la derecha, `fila(40)`, ocurre lo
contrario:

| Programa | Consulta | Modelo entero | Con magia |
|---|---|---|---|
| `cadena(40)`: `camino(X, Z), arco(Z, Y)` | `camino(0, Y)` | 820 | 41 |
| `cadena(40)` | `camino(X, 40)` | 820 | 862 |
| `fila(40)`: `arco(X, Z), camino(Z, Y)` | `camino(0, Y)` | 820 | 860 |
| `fila(40)` | `camino(X, 40)` | 820 | 158 |

La prueba `costos:tabla_magia` verifica las cuatro filas.

Con la recursión a la derecha y el primer argumento ligado, `camino(Z, Y)`
se llama con cada nodo `Z` que se alcanza desde 0: la evaluación calcula
todos los caminos de los 40 nodos alcanzables, que en una fila son todos.
Con el segundo argumento ligado, el literal `arco(X, Z)` liga `Z` antes
de llamar a `camino(Z, Y)`, que queda con el adorno `bb`: es el **paso de
información de un literal a otro** (*sideways information passing*), que
la transformación hace siempre de izquierda a derecha. Nilsson y
Małuszyński advierten que ese orden no es necesariamente el mejor, y que
elegir otro requiere analizar el flujo de los datos en el programa.

### Hechos mágicos y tablas

La tabulación del [capítulo 40](../capitulo-40-tabulacion/index.md)
llega al mismo resultado desde la otra punta: parte de la consulta, como
Prolog, y guarda las respuestas de cada llamada en una tabla. Warren
compara las dos direcciones de la recursión sobre un ciclo de 100
personas que se deben dinero: con la recursión a la izquierda, la
consulta `evita(1, Y)` crea una sola tabla; con la recursión a la
derecha, una por persona, cada una con las 100 respuestas. `tablas.pl`
mide las dos cosas, las tablas de SWI-Prolog y los hechos mágicos del
motor sobre el mismo programa escrito como datos:

<!-- contexto: capitulo-86/tablas.pl -->
```prolog
?- tablas(evita_izq(1, _), T1, R1), tablas(evita_der(1, _), T2, R2).
T1 = 1,
R1 = 100,
T2 = 100,
R2 = 10000.

?- findall(R-M-A, ( member(R, [izq, der]), programa(R, 100, Cs), magia(Cs, evita(1, _), M, A) ), L).
L = [izq-1-100, der-100-10000].
```

La prueba `costos:tablas_y_magia` verifica las cuatro cifras. Cada
tabla corresponde a un hecho mágico, y cada respuesta guardada, a un
átomo adornado: una tabla y cien respuestas, o cien tablas y diez mil
respuestas, en los dos casos. No es una coincidencia: François Bry
mostró en 1990 que la evaluación de abajo hacia arriba de un programa
transformado y la resolución con tablas hacen el mismo trabajo, y
Nilsson y Małuszyński lo ilustran comparando su traza con el árbol SLD.
La diferencia es de organización: la tabulación avanza una llamada por
vez, y el motor, un conjunto de átomos por paso.

!!! question "Actividad"
    Predecir el adorno de cada literal y las reglas mágicas que
    `mostrar_magico/2` escribe para `fila(3)` y la consulta
    `camino(X, 3)`. Comprobarlo, y explicar de dónde sale el adorno `bb`.

## 86.7 Versión 5: los hechos que llegan después

Un modelo calculado es un punto fijo: aplicar las reglas no agrega nada.
Si llega un hecho nuevo, todo lo que hay que derivar usa ese hecho o algo
derivado de él, y eso es exactamente lo que hace un paso semi-ingenuo
tomando como nuevos los hechos que llegan. `incremental.pl` guarda en un
**estado** las variantes de todas las reglas, una por cada literal
positivo, y la base:

<!-- ejemplo: capitulo-86/incremental.pl predicado: iniciar/3 agregar_hechos/4 -->
```prolog
%!  iniciar(+Clausulas:list, -Estado, -Costo) is det.
%
%   Estado tiene las reglas de Clausulas, un programa Datalog seguro sin
%   negación, y su modelo mínimo, calculado agregando los hechos a la base
%   vacía con agregar_hechos/4. Costo, el de ese cálculo. Error de dominio
%   si el programa no es seguro o tiene una negación.
iniciar(Clausulas, Estado, Costo) :-
    exigir_definido(Clausulas),
    separar(Clausulas, Hechos, Reglas),
    findall(Ind,
            ( member(r(_, Ls), Reglas),
              member(L, Ls),
              functor(L, Nombre, Aridad),
              Ind = Nombre/Aridad ),
            Is),
    sort(Is, Predicados),
    variantes(Reglas, Predicados, Variantes),
    empty_assoc(Vacia),
    agregar_hechos(Hechos, estado(Variantes, Vacia), Estado, Costo).

%!  agregar_hechos(+Hechos:list, +Estado0, -Estado, -Costo) is det.
%
%   Estado tiene la base de Estado0 con los Hechos, sin variables, y todo
%   lo que se deriva de ellos, hasta el punto fijo. Costo es costo(Pasos,
%   Derivaciones) de los pasos semi-ingenuos que hicieron falta.
agregar_hechos(Hechos, estado(Variantes, Base0),
               estado(Variantes, Base), Costo) :-
    agregar(Hechos, Base0, Base1, Nuevos),
    iterar(Variantes, Base0, Base1, Nuevos, Base, costo(0, 0), Costo).
```

La evaluación inicial es el mismo caso: agregar todos los hechos a la base
vacía; la consulta siguiente parte de los 40 arcos y agrega uno.

<!-- contexto: capitulo-86/datalog.pl -->
```prolog
?- agregar_a(cadena(40), [arco(40, 41)], C, M), length(M, N).
C = costo(2, 41),
M = [arco(0, 1), arco(1, 2), arco(2, 3), arco(3, 4), arco(4, 5), arco(5, 6), arco(6, 7), arco(7, 8), arco(..., ...)|...],
N = 902.
```

`agregar_a/4`, de `datalog.pl`, inicia el estado con el programa por su
nombre y le agrega los hechos.

El arco nuevo produce 41 caminos en dos pasos: `camino(40, 41)` y, con
cada `camino(I, 40)` de la base vieja, `camino(I, 41)`; el segundo paso
no encuentra arcos que salgan de 41, y termina. Recalcular el modelo de 41
arcos desde cero costaría 861 derivaciones (prueba `costos:agregar`).

**La red Rete del [capítulo 65](../capitulo-65-proyecto-algoritmo-rete/index.md#654-version-3-tokens-y-uniones)
hace lo mismo con otra organización.** Un hecho que entra en la memoria
de trabajo recorre la red y se une con lo que las memorias beta guardan
de los hechos anteriores; solo produce las instanciaciones que lo usan.
La red guarda las uniones parciales entre ciclos, y propaga un hecho por
vez; el motor no guarda uniones parciales, las recalcula en cada paso con
los índices de la base, y propaga un conjunto de hechos por paso. Las dos
cosas son la misma idea: **propagar solo lo que cambió**. Es también la
idea de la cola del filtrado de Waltz, en la
[sección 81.6](../capitulo-81-proyecto-etiquetado-waltz/index.md#816-version-4-el-filtrado-de-waltz):
una unión vuelve a la cola solo cuando su dominio cambió, y el filtrado
termina cuando la cola se vacía, como el motor termina cuando no hay
átomos nuevos. El filtrado quita combinaciones de dominios finitos, y el
motor agrega átomos de una base finita; los dos terminan porque cada
paso cambia algo en un solo sentido, y hay una cantidad finita de cosas
que cambiar.

La red Rete tiene algo que el motor no tiene: los hechos que **salen**. La
negación del [capítulo 65](../capitulo-65-proyecto-algoritmo-rete/index.md#655-version-4-la-negacion)
lleva una cuenta por token, y un hecho que sale quita lo que su entrada
había agregado. El paso semi-ingenuo solo agrega, y con una negación un
hecho nuevo puede invalidar algo ya derivado: en el mundo del Wumpus, una
brisa nueva quita la conclusión `sin_pozo` de las celdas vecinas. Por
eso `iniciar/3` rechaza los programas con negación:

<!-- contexto: capitulo-86/datalog.pl -->
```prolog
?- catch(iniciar([(p(X) :- r(X), \+ q(X))], _, _), error(E, _), true).
E = domain_error(programa_sin_negacion, \+q(_)).
```

Mantener un modelo con negación, o con hechos que se borran, pide otro
algoritmo: el más conocido, DRed, de Ashish Gupta, Inderpal Singh Mumick
y V. S. Subrahmanian, borra primero de más, todo lo que tenía una
derivación que usaba lo borrado, y vuelve a derivar lo que tiene otra.
El [ejercicio 9](#ejercicios) compara el costo de recalcular desde cero.

El capítulo continúa en la página
[Aplicaciones: el Wumpus, los marcos y los registros](aplicaciones.md#868-aplicaciones-el-wumpus-los-marcos-y-los-registros),
con el motor aplicado, sin cambiarlos, a programas y datos de otros
capítulos.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

5. **(2)** Nilsson y Małuszyński abren su capítulo con
   `married(X, Y) :- married(Y, X)` y el hecho `married(adam, anne)`.
   Escribir el programa como datos, predecir el costo de `evaluar/3` y
   las respuestas de `married(anne, X)` con `respuestas_magicas/4`, y
   explicar por qué Prolog no encuentra ninguna respuesta si la regla va
   primero.
6. **(3)** Escribir `suplementario(+Clausula, +K, -Clausulas)`, la
   transformación con predicados suplementarios de Nilsson y Małuszyński:
   la regla `A0 :- A1, …, An` se reemplaza por `S1 :- A1`,
   `S2 :- S1, A2`, …, y `A0 :- Sn-1, An`, donde cada Si lleva las
   variables de A1, …, Ai que todavía hacen falta, las de la cabeza y las
   de los literales siguientes, y K distingue los nombres. Aplicarla a
   dos programas y comparar las derivaciones y las inferencias con las
   del original: `sd/2` del ejercicio 7, y la regla de Warren
   `franja_del_anio(Anio, F) :- alumno(A, Anio), inscripto(A, M),
   horario(M, F)`, con 1 000 alumnos repartidos en cuatro años, cada uno
   inscripto en las cinco materias de su año, y 50 franjas por materia.
   Explicar por qué la transformación pierde en un caso y gana en el
   otro.
7. ★ **(2)** El programa `sd/2` de Nilsson y Małuszyński dice que dos
   nodos de un árbol están a la misma profundidad:
   `sd(X, X)` para cada nodo, y `sd(X, Y) :- child(X, Z), child(Y, W),
   sd(Z, W)`. Escribirlo con los diez hechos `child/2` de su ejercicio
   15.2, calcular `sd(d, X)` con el modelo entero y con la transformación
   mágica, y comparar los costos y el programa transformado.
8. **(2)** Escribir el programa de las personas que se deben dinero con
   `evita/2` recursivo a la izquierda sobre un **camino** de 100 personas,
   sin el arco de la 100 a la 1, y medir las tablas y los hechos mágicos
   de `evita(1, Y)` y de `evita(50, Y)`.
9. **(2)** Escribir `quitar_hechos(+Clausulas, +Hechos, -Modelo, -Costo)`,
   que quita hechos y recalcula el modelo desde cero. Quitar `arco(20,
   21)` de `cadena(40)`, y comparar ese costo con el de volver a agregar
   el arco con `agregar_hechos/4`.

## Referencias

- Ulf Nilsson y Jan Małuszyński, *Logic, Programming and Prolog*, 2.ª
  edición, John Wiley & Sons, 1995 — capítulo «Query-answering in
  Deductive Databases», apartados «Naive Evaluation», «Semi-naive
  Evaluation», «Magic Transformation» y «Optimizations», con sus
  ejercicios, y las notas bibliográficas del capítulo.
  [Edición en línea de los autores](https://www.ida.liu.se/~ulfni53/lpp/).
  Esta página toma de allí la definición de la transformación mágica y su
  lectura («es llamado si»), los teoremas de corrección y completitud, que
  cita sin demostrar, la observación sobre el orden del paso de
  información, y los programas `married/2` y `sd/2` y los predicados
  suplementarios de los ejercicios.
- David S. Warren, *Programming in Tabled Prolog*, borrador, Stony Brook
  University, 1999 — capítulo «Introduction to Prolog», sección
  «Deductive Databases»; capítulo «Tabling and Datalog Programming»; y
  sección «Stratified Negation» del capítulo «Negation in XSB».
  [Edición en línea del autor, en el archivo web](https://web.archive.org/web/20240628211257/https://www3.cs.stonybrook.edu/~warren/xsbbook/book.html).
  Esta página toma de allí el ejemplo de las personas que se deben dinero
  sobre un ciclo y el análisis de la cantidad de tablas según la dirección
  de la recursión, que `tablas.pl` reproduce.
- François Bancilhon, David Maier, Yehoshua Sagiv y Jeffrey D. Ullman,
  «Magic sets and other strange ways to implement logic programs»,
  *Proceedings of the 5th ACM Symposium on Principles of Database
  Systems*, 1986. [Edición en línea](https://doi.org/10.1145/6012.15399).
  Es el origen de los conjuntos mágicos con adornos, la forma de la
  transformación que el motor implementa; Nilsson y Małuszyński lo citan
  junto con las plantillas mágicas de Raghu Ramakrishnan (1988) y la
  formalización del paso de información de Catriel Beeri y Raghu
  Ramakrishnan, «On the power of magic», 1987.
- François Bry, «Query evaluation in recursive databases: bottom-up and
  top-down reconciled», *Data & Knowledge Engineering* 5, 1990,
  páginas 289–312. Citado por Nilsson y Małuszyński como la
  demostración de la correspondencia entre la evaluación de los
  programas mágicos y la tabulación, que la
  [sección 86.6](#866-version-4-las-consultas-y-la-transformacion-magica)
  observa contando tablas y hechos mágicos.
- Ashish Gupta, Inderpal Singh Mumick y V. S. Subrahmanian, «Maintaining
  views incrementally», *Proceedings of the 1993 ACM SIGMOD International
  Conference on Management of Data*, 1993.
  [Edición en línea](https://doi.org/10.1145/170035.170066). Es el
  algoritmo DRed, nombrado en la
  [sección 86.7](#867-version-5-los-hechos-que-llegan-despues) como la
  manera de mantener un modelo con negación o con hechos borrados.
- *SWI-Prolog Reference Manual*, sección de la tabulación:
  [manual en línea](https://www.swi-prolog.org/pldoc/doc_for?object=manual).
