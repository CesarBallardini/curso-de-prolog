# Capítulo 22 — Estructuras de datos de la biblioteca

La parte I escribió sus propios predicados de listas —`largo/2`, `pegar/3`,
`dar_vuelta/2`—, porque escribirlos es la forma de entender la recursión. Un
programa profesional no los vuelve a escribir: usa los de la biblioteca, que
están probados, documentados y optimizados. Lo mismo vale para las estructuras
que las listas representan mal: una tabla de búsqueda con miles de claves, un
conjunto, un registro con campos con nombre.

Este capítulo recorre las bibliotecas de estructuras de datos de SWI-Prolog:
el resto de `library(lists)`, el orden estándar de los términos y los
predicados que ordenan, los pares, los árboles de búsqueda de `library(assoc)`,
los conjuntos ordenados, los dicts, las opciones y los números al azar.
Termina con una búsqueda en un espacio de estados —el mundo de bloques con una
pinza—, el tablero del Buscaminas como tabla de búsqueda, y el ranking del
proyecto.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- usar los predicados de `library(lists)` en lugar de reescribirlos;
- explicar el orden estándar de los términos, y ordenar con `sort/2`,
  `msort/2`, `sort/4` y `predsort/3`;
- usar pares, `library(assoc)`, `library(ordsets)`, dicts y opciones;
- aislar el azar en un predicado, y fijar la semilla en las pruebas;
- representar un estado como un término y buscar una secuencia de acciones con
  un conjunto de visitados.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:30 h**.
    Resolver los 6 ejercicios marcados con ★: **1:53 h**.
    Resolver los 16 ejercicios del final: **4:58 h**.

## 22.1 El resto de `library(lists)`

`library(lists)` se carga sola, la primera vez que se usa uno de sus
predicados. Los del [capítulo 7](../capitulo-07-listas/index.md) —`member/2`, `append/3`, `length/2`,
`reverse/2`— son una parte. Los más usados del resto:

| Predicado | Relación |
|---|---|
| `nth1(I, L, X)`, `nth0/3` | X está en la posición I de L, contando desde 1 o desde 0 |
| `last(L, X)` | X es el último elemento de L |
| `sum_list/2`, `max_list/2`, `min_list/2` | suma, máximo y mínimo de una lista de números |
| `max_member/2`, `min_member/2` | máximo y mínimo en el orden estándar |
| `numlist(A, B, L)` | L es la lista de los enteros de A a B |
| `select(X, L, R)`, `selectchk/3` | R es L sin una aparición de X |
| `subtract/3`, `intersection/3`, `union/3` | operaciones de conjuntos sobre listas |
| `list_to_set/2` | sin repetidos, conservando la primera aparición |
| `permutation/2` | una permutación de la lista |
| `flatten/2` | una lista sin listas anidadas |

Ante una tarea sobre listas, el primer paso es buscar en la documentación de
`library(lists)` y `library(apply)`: con `help(sum_list)` en el toplevel, o en
el manual en línea.

## 22.2 El orden estándar

Todo término de Prolog se puede comparar con cualquier otro. El **orden
estándar** los ordena primero por tipo, y dentro de cada tipo por su valor:

1. las variables;
2. los números, por su valor; con el mismo valor, el de punto flotante antes
   que el entero;
3. las cadenas, en orden alfabético;
4. los átomos, en orden alfabético;
5. los términos compuestos: primero por aridad, después por nombre, y después
   por sus argumentos, de izquierda a derecha.

```prolog
?- msort([b, 1, "c", f(x), a, 2.0, 1.0], L).
L = [1.0, 1, 2.0, "c", a, b, f(x)].

?- compare(Orden, f(z), f(a, a)).
Orden = (<).
```

`f(z)` va antes que `f(a, a)` porque tiene un argumento menos. Los predicados
`@<`, `@>`, `@=<` y `@>=` comparan en este orden, `==` y `\==` comprueban la
igualdad, y `compare(Orden, A, B)` da `<`, `=` o `>`. El
[capítulo 11](../capitulo-11-texto/index.md) usó `@<` para comparar átomos; es el mismo orden.

## 22.3 Ordenar

<!-- ejemplo: capitulo-22/orden.pl predicado: edades/1 por_edad/1 por_edad_descendente/1 edades_distintas/1 consulta: por_edad(L). -->
```prolog
%!  edades(-Pares:list(pair)) is det.
%
%   Pares son los pares Persona-Edad de la base, en el orden de los hechos.
edades(Pares) :-
    findall(P-E, edad(P, E), Pares).

%!  por_edad(-Pares:list(pair)) is det.
%
%   Pares son los pares Persona-Edad ordenados por edad, de menor a mayor;
%   con la misma edad, en el orden de los hechos.
por_edad(Pares) :-
    edades(Todos),
    sort(2, @=<, Todos, Pares).

%!  por_edad_descendente(-Pares:list(pair)) is det.
%
%   Pares son los pares Persona-Edad de mayor a menor edad.
por_edad_descendente(Pares) :-
    edades(Todos),
    sort(2, @>=, Todos, Pares).

%!  edades_distintas(-Edades:list(integer)) is det.
%
%   Edades son las edades de la base, ordenadas y sin repetidos.
edades_distintas(Edades) :-
    findall(E, edad(_, E), Todas),
    sort(Todas, Edades).
```

```prolog
?- por_edad(L).
L = [eva-8, luis-12, pedro-39, ana-41, juan-68, marta-68].

?- por_edad_descendente(L).
L = [juan-68, marta-68, ana-41, pedro-39, luis-12, eva-8].

?- edades_distintas(L).
L = [8, 12, 39, 41, 68].
```

`sort/2`, que `edades_distintas/1` usa, se presentó en el
[capítulo 17](../capitulo-17-todas-las-soluciones/index.md). Cuatro
predicados ordenan, y se distinguen por qué hacen con los repetidos:

| Predicado | Orden | Repetidos |
|---|---|---|
| `sort/2` | estándar, ascendente | se eliminan |
| `msort/2` | estándar, ascendente | se conservan |
| `sort(Clave, Orden, L, R)` | por el argumento Clave (0 es el término entero); `@<`, `@=<`, `@>` o `@>=` | con `@<` y `@>` se eliminan los de igual clave; con `@=<` y `@>=` se conservan, en el orden original |
| `predsort(P, L, R)` | el que decide `call(P, Orden, A, B)` | se eliminan los que P compara como `=` |

`sort/4` es la herramienta habitual: ordena por un argumento de cada término, en
cualquier sentido, y es **estable** con `@=<` y `@>=`: juan y marta tienen la
misma edad, y quedan en el orden en que estaban. `predsort/3` queda para los
criterios que no son un argumento, como «de mayor a menor edad y, con la misma
edad, por nombre»:

<!-- ejemplo: capitulo-22/orden.pl predicado: por_edad_y_nombre/1 comparar_personas/3 consulta: por_edad_y_nombre(L). -->
```prolog
%!  por_edad_y_nombre(-Personas:list) is det.
%
%   Personas son las personas de la base ordenadas de mayor a menor edad y,
%   con la misma edad, por nombre.
por_edad_y_nombre(Personas) :-
    findall(P, edad(P, _), Todas),
    predsort(comparar_personas, Todas, Personas).

%!  comparar_personas(-Orden, +A, +B) is det.
%
%   Orden es <, > o = según A vaya antes, después o en el mismo lugar que B:
%   primero la mayor edad, y con la misma edad, el nombre en orden
%   alfabético.
comparar_personas(Orden, A, B) :-
    edad(A, EA),
    edad(B, EB),
    compare(Orden, EB-A, EA-B).
```

`comparar_personas/3` arma dos pares con la edad invertida y los compara con
`compare/3`: `EB-A` contra `EA-B` ordena de mayor a menor edad, y el nombre
desempata. Si dos personas tuvieran la misma edad y el mismo nombre,
`predsort/3` conservaría una sola.

!!! question "Actividad"
    Predecir y comprobar: `sort(2, @>, [a-1, b-2, c-1], L).` ·
    `sort(0, @>=, [c, a, b, a], L).` · ¿Qué elemento pierde la primera, y por
    qué?

## 22.4 Pares y `keysort/2`

Un **par** es un término `Clave-Valor`. `library(pairs)` tiene los predicados
que los arman y los separan —`pairs_keys_values/3`, `pairs_keys/2`,
`pairs_values/2`, `map_list_to_pairs/3`—, y `keysort/2` ordena una lista de
pares por la clave, de forma estable. Juntos resuelven el problema de ordenar
por un valor que se debe **calcular**:

<!-- ejemplo: capitulo-22/pares.pl predicado: por_largo/2 consulta: por_largo([pedro, ana, luis, eva], L). -->
```prolog
%!  por_largo(+Nombres:list(atom), -Ordenados:list(atom)) is det.
%
%   Ordenados son los Nombres de menor a mayor longitud; con la misma
%   longitud, en el orden de Nombres. Decora cada nombre con su longitud,
%   ordena por la clave y quita la decoración.
por_largo(Nombres, Ordenados) :-
    map_list_to_pairs(atom_length, Nombres, Pares),
    keysort(Pares, Ordenadas),
    pairs_values(Ordenadas, Ordenados).
```

```prolog
?- por_largo([pedro, ana, luis, eva], L).
L = [ana, eva, luis, pedro].
```

`map_list_to_pairs(atom_length, Nombres, Pares)` decora cada nombre con su
longitud: `[5-pedro, 3-ana, 4-luis, 3-eva]`. `keysort/2` ordena por la
longitud, conservando el orden de ana y eva, que empatan. `pairs_values/2`
quita la decoración. Del mismo modo, `pairs_keys/2` da las claves de una lista
de pares, y `pairs_keys_values(Pares, Claves, Valores)` relaciona la lista de
pares con la de sus claves y la de sus valores, en los dos sentidos: separa
los pares, o los arma a partir de dos listas del mismo largo.

!!! example "Patrón 23 — Decorar, ordenar, desdecorar"
    **Problema.** Es necesario ordenar elementos por un valor que no está en
    ellos sino que se calcula: una longitud, un promedio, una distancia.

    **Versión ingenua.** `predsort/3` con un predicado que calcula el valor en
    cada comparación: lo calcula muchas veces para cada elemento, y elimina los
    que empatan.

    **Patrón.** Calcular el valor una vez por elemento y formar pares
    `Valor-Elemento` (`map_list_to_pairs/3`), ordenarlos con `keysort/2` o
    `sort/4`, y quedarse con los elementos (`pairs_values/2`).

    **Cuándo no usarlo.** Cuando la clave ya es un argumento del término:
    `sort/4` ordena por él directamente.

`clumped/2`, de `library(lists)`, también produce pares: relaciona una lista
con los pares `Elemento-Cantidad` de sus **rachas**, los grupos de elementos
iguales consecutivos. Sobre la lista tal como viene, da las rachas; sobre la
lista ordenada con `msort/2`, que conserva los repetidos, los iguales quedan
juntos y cada racha es la **frecuencia** de un elemento:

```prolog
?- clumped([a, a, b, a, a, a], Rachas).
Rachas = [a-2, b-1, a-3].

?- msort([b, a, c, a, b, a], Ordenada), clumped(Ordenada, Frecuencias).
Ordenada = [a, a, a, b, b, c],
Frecuencias = [a-3, b-2, c-1].
```

Son el mapeo secuencial con estado y el mapeo disperso con estado de la tabla
de la [sección 18.7](../capitulo-18-orden-superior/index.md#187-cuando-no-usar-el-orden-superior). Con `sort/2` en lugar de `msort/2`, cada frecuencia
sería 1: `sort/2` elimina los repetidos antes de contarlos.

## 22.5 `library(assoc)` y `library(rbtrees)`

Buscar una clave en una lista recorre la lista: con miles de claves, cada
búsqueda cuesta miles de pasos. `library(assoc)` guarda los pares en un
**árbol AVL**, un árbol de búsqueda balanceado: una búsqueda recorre una sola
rama, de longitud proporcional al logaritmo de la cantidad de claves.

<!-- ejemplo: capitulo-22/pares.pl predicado: hijos_por_padre/1 agregar_hijo/4 consulta: hijos_por_padre(A), get_assoc(pedro, A, Hijos). -->
```prolog
%!  hijos_por_padre(-Assoc) is det.
%
%   Assoc relaciona cada padre con la lista de sus hijos, en el orden de los
%   hechos.
hijos_por_padre(Assoc) :-
    findall(P-H, padre(P, H), Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    list_to_assoc(Grupos, Assoc).

%!  agregar_hijo(+Padre, +Hijo, +Assoc0, -Assoc) is det.
%
%   Assoc es Assoc0 con Hijo agregado a los hijos de Padre. Assoc0 no cambia:
%   put_assoc/4 construye un assoc nuevo.
agregar_hijo(Padre, Hijo, Assoc0, Assoc) :-
    (   get_assoc(Padre, Assoc0, Hijos0)
    ->  true
    ;   Hijos0 = []
    ),
    append(Hijos0, [Hijo], Hijos),
    put_assoc(Padre, Assoc0, Hijos, Assoc).
```

```prolog
?- hijos_por_padre(A), get_assoc(pedro, A, Hijos).
A = t(pedro, [luis, eva], <, t(juan, [ana, pedro], -, t, t), t),
Hijos = [luis, eva].
```

`list_to_assoc/2` construye el árbol, `get_assoc/3` busca, `put_assoc/4`
agrega o reemplaza, `del_assoc(Clave, Assoc0, Valor, Assoc)` quita una clave,
y `assoc_to_list/2`, `assoc_to_keys/2` y `assoc_to_values/2` lo recorren en
orden de clave. Un assoc es un término: `put_assoc/4` no
modifica el árbol que recibe, sino que construye uno nuevo, que comparte con
el anterior todo lo que no cambió. `group_pairs_by_key/2` agrupa pares
consecutivos con la misma clave: `[juan-ana, juan-pedro]` se vuelve
`[juan-[ana, pedro]]`.

La diferencia se mide. Con 10 000 claves, buscar cada una en una lista de
pares con `memberchk/2` tarda 1,3 segundos; en un assoc, 0,003. Con `time/1`
sobre `forall(member(K, Ks), memberchk(K-_, Pares))` y sobre
`forall(member(K, Ks), get_assoc(K, A, _))`:

```text
% 30,001 inferences, 1.313 CPU in 1.306 seconds (101% CPU, 22858 Lips)
% 40,000 inferences, 0.000 CPU in 0.003 seconds (0% CPU, Infinite Lips)
```

La cantidad de inferencias no refleja el costo aquí: `memberchk/2` está
escrito en C y cuenta como una inferencia, aunque recorra la lista entera. Para
comparar predicados de la biblioteca es necesario medir el tiempo, no solo las
inferencias del [capítulo 16](../capitulo-16-rendimiento/index.md).

`library(rbtrees)` ofrece lo mismo con árboles rojinegros y una interfaz
parecida (`rb_new/1`, `rb_insert/4`, `rb_lookup/3`, `rb_delete/3`), con otro
equilibrio entre el costo de buscar y el de insertar.

!!! example "Patrón 24 — Tabla de búsqueda con `assoc`"
    **Problema.** Un programa busca muchas veces valores por una clave: la
    celda de un tablero, el alumno de un legajo.

    **Versión ingenua.** Una lista de pares y `memberchk/2`, que recorre la
    lista en cada búsqueda.

    **Patrón.** Construir un assoc una vez, con `list_to_assoc/2`, y buscar con
    `get_assoc/3`. Actualizar con `put_assoc/4`, que da un assoc nuevo.

    **Cuándo no usarlo.** Con pocas claves, o cuando los datos son hechos del
    programa: la indexación de los hechos ya busca por el primer argumento sin
    recorrerlos todos.

## 22.6 `library(ordsets)` y `library(nb_set)`

Un **conjunto ordenado** es una lista ordenada y sin repetidos, como la que da
`sort/2`. Sobre esa representación, `library(ordsets)` implementa las
operaciones de conjuntos en tiempo lineal: `ord_union/3`, `ord_intersection/3`,
`ord_subtract/3`, `ord_memberchk/2`, `ord_add_element/3`.

<!-- ejemplo: capitulo-22/pares.pl predicado: en_los_dos/3 solo_en_el_primero/3 consulta: en_los_dos([eva, ana, luis], [luis, juan, ana], L). -->
```prolog
%!  en_los_dos(+A:list, +B:list, -Ambos:list) is det.
%
%   Ambos son los elementos que están en A y en B, como conjunto ordenado.
en_los_dos(A, B, Ambos) :-
    list_to_ord_set(A, SA),
    list_to_ord_set(B, SB),
    ord_intersection(SA, SB, Ambos).

%!  solo_en_el_primero(+A:list, +B:list, -Solo:list) is det.
%
%   Solo son los elementos de A que no están en B, como conjunto ordenado.
solo_en_el_primero(A, B, Solo) :-
    list_to_ord_set(A, SA),
    list_to_ord_set(B, SB),
    ord_subtract(SA, SB, Solo).
```

```prolog
?- en_los_dos([eva, ana, luis], [luis, juan, ana], L).
L = [ana, luis].
```

`list_to_ord_set/2` convierte una lista cualquiera en un conjunto ordenado: la
ordena y elimina los repetidos.
Las operaciones de `library(lists)` sobre listas comunes —`intersection/3`,
`subtract/3`— hacen lo mismo recorriendo una lista por cada elemento de la
otra. Con conjuntos grandes, la diferencia es la de la sección anterior.
`library(nb_set)` ofrece conjuntos que se modifican en su lugar, para
acumular muchos elementos dentro de un bucle; este curso no los usa.

## 22.7 Dicts

Un **dict** reúne valores con nombre: `_{nombre: ana, edad: 41}`. Es una
estructura propia de SWI-Prolog, que otras implementaciones no tienen. Tiene
una **etiqueta** —un átomo o una variable, antes de la llave— y pares
`clave: valor` sin orden.

<!-- ejemplo: capitulo-22/dicts.pl predicado: persona/2 cumple_anios/2 mayores/1 consulta: persona(ana, D), E = D.edad. -->
```prolog
%!  persona(?Nombre, -Dict) is nondet.
%
%   Dict es el dict de la persona Nombre, con las claves nombre y edad.
persona(Nombre, persona{nombre: Nombre, edad: Edad}) :-
    edad(Nombre, Edad).

%!  cumple_anios(+Dict0, -Dict) is det.
%
%   Dict es Dict0 con la edad siguiente. Dict0 no cambia.
cumple_anios(Dict0, Dict) :-
    Edad is Dict0.edad + 1,
    Dict = Dict0.put(edad, Edad).

%!  mayores(-Nombres:list) is det.
%
%   Nombres son los nombres de las personas de 18 años o más.
mayores(Nombres) :-
    findall(N, ( persona(N, D), get_dict(edad, D, E), E >= 18 ), Nombres).
```

```prolog
?- persona(ana, D), E = D.edad.
D = persona{edad:41, nombre:ana},
E = 41.

?- persona(ana, D0), cumple_anios(D0, D).
D0 = persona{edad:41, nombre:ana},
D = persona{edad:42, nombre:ana}.
```

`get_dict(Clave, Dict, Valor)` obtiene un valor, y `put_dict/4` da un dict nuevo
con un valor cambiado. La **notación funcional**, `D.edad` y `D.put(edad, 42)`,
es una forma abreviada de las mismas operaciones: al cargar el archivo, cada
`D.clave` en el cuerpo de una cláusula se reemplaza por una llamada que obtiene
el valor, **antes** del objetivo que lo contiene. `listing/1` lo muestra:

```text
cumple_anios(Dict0, Dict) :-
    '.'(Dict0, edad, A),
    Edad is A+1,
    '.'(Dict0, put(edad, Edad), B),
    Dict=B.
```

Esa expansión tiene una consecuencia: dentro de una lambda, `P.edad` se evalúa
en la cláusula que contiene la lambda, antes de que `P` tenga valor, y produce
un error de instanciación. El ejercicio 7 lo muestra. Una clave inexistente
produce un error con la notación funcional, y `get_dict/3` falla.

!!! question "Actividad"
    Predecir y comprobar: `persona(ana, D), get_dict(altura, D, V).` y
    `persona(ana, D), V = D.altura.`

Los dicts son la representación natural de los objetos de JSON; el
[capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) los lee y los escribe, y el [capítulo 30](../capitulo-30-servicios-web-rest/index.md) los usa en un servicio web.
Dentro de un programa, un término común —`persona(ana, 41)`— sigue siendo la
representación más simple cuando los campos son pocos y fijos.

## 22.8 `library(option)`

Un predicado con muchos parámetros opcionales los recibe en una lista de
**opciones**: términos como `saludo(buenas)`. `option(Opcion, Lista, PorOmision)`
obtiene una, con un valor por omisión si falta:

<!-- ejemplo: capitulo-22/dicts.pl predicado: presentar/3 consulta: presentar(ana, [saludo(buenas)], Texto). -->
```prolog
%!  presentar(+Nombre, +Opciones:list, -Texto:string) is det.
%
%   Texto presenta a Nombre. Opciones: saludo(S), el saludo, hola si falta;
%   con_edad(B), si se dice la edad, true si falta.
presentar(Nombre, Opciones, Texto) :-
    option(saludo(Saludo), Opciones, hola),
    option(con_edad(ConEdad), Opciones, true),
    (   ConEdad == true,
        edad(Nombre, Edad)
    ->  format(string(Texto), "~w, ~w (~d)", [Saludo, Nombre, Edad])
    ;   format(string(Texto), "~w, ~w", [Saludo, Nombre])
    ).
```

```prolog
?- presentar(ana, [saludo(buenas)], Texto).
Texto = "buenas, ana (41)".

?- presentar(eva, [con_edad(false)], Texto).
Texto = "hola, eva".
```

Los predicados de la biblioteca de SWI-Prolog usan esta convención; el
[capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) la encuentra en `open/4` y en `read_term/3`. `select_option/3` obtiene
una opción y la quita de la lista, para pasar las demás a otro predicado.

## 22.9 `library(random)`

`library(random)` genera números al azar: `random_between(A, B, N)` da un entero
entre A y B, `random_member(X, L)` un elemento de L, `random_permutation/2` una
permutación, y `randseq(K, N, L)` K enteros distintos entre 1 y N. La secuencia
depende de una **semilla**: `set_random(seed(42))` la fija, y con la misma
semilla se obtienen los mismos números.

Un predicado que usa el azar no es una relación: la misma consulta responde
distinto cada vez, y no se puede probar comparando con un resultado fijo. Dos
decisiones lo contienen. El azar se usa en **un solo predicado**, en el borde
del programa, y todo lo demás recibe sus resultados como argumentos. Y las
pruebas fijan la semilla en su `setup`, como en `buscaminas.plt`. El sandbox de
SWISH permite `random_between/3` y los demás, pero no `set_random/1`: las
consultas del encabezado de los ejemplos no fijan la semilla.

## 22.10 Un estado como término: el mundo de bloques

Muchos problemas se resuelven buscando una secuencia de acciones que lleva de
un estado a otro. El **mundo de bloques** es el ejemplo clásico de la
planificación: bloques apilados sobre una mesa, y una pinza que toma el bloque
de arriba de una pila, lo suelta sobre la mesa, o lo apila sobre otro bloque.

Un estado es un término: `estado(Pilas, Mano)`, con cada pila como lista, el
bloque de arriba primero, y `Mano` igual a `vacia` o al bloque que sostiene la
pinza. `sucesor/3` da los estados que se alcanzan con una acción:

<!-- ejemplo: capitulo-22/bloques.pl predicado: normalizar/2 sucesor/3 consulta: sucesor(estado([[c, a], [b]], vacia), Accion, Estado). -->
```prolog
%!  normalizar(+Estado0, -Estado) is det.
%
%   Estado es Estado0 con las pilas ordenadas: dos estados con las mismas
%   pilas en distinto orden son el mismo estado.
normalizar(estado(Pilas0, Mano), estado(Pilas, Mano)) :-
    msort(Pilas0, Pilas).

%!  sucesor(+Estado, -Accion, -Siguiente) is nondet.
%
%   La pinza pasa de Estado a Siguiente con Accion: tomar(B), soltar(B) o
%   apilar(B, C). Siguiente está normalizado.
sucesor(estado(Pilas, vacia), tomar(B), Siguiente) :-
    select([B|Resto], Pilas, Otras),
    (   Resto == []
    ->  Nuevas = Otras
    ;   Nuevas = [Resto|Otras]
    ),
    normalizar(estado(Nuevas, B), Siguiente).
sucesor(estado(Pilas, B), soltar(B), Siguiente) :-
    B \== vacia,
    normalizar(estado([[B]|Pilas], vacia), Siguiente).
sucesor(estado(Pilas, B), apilar(B, C), Siguiente) :-
    B \== vacia,
    select([C|Resto], Pilas, Otras),
    normalizar(estado([[B, C|Resto]|Otras], vacia), Siguiente).
```

`normalizar/2` ordena las pilas: dos estados con las mismas pilas en otro
orden son el mismo, y deben ser el mismo término para que el conjunto de
visitados los reconozca. La búsqueda es **a lo ancho**: examina primero todos
los estados a una acción, después los que están a dos, y así; por eso el
primer plan que encuentra es uno de los más cortos.

!!! question "Actividad"
    Contar los sucesores de `estado([[c, a], [b]], vacia)` con
    `aggregate_all(count, sucesor(estado([[c, a], [b]], vacia), _, _), N)` y
    explicar por qué ninguno es `soltar` ni `apilar`.

<!-- ejemplo: capitulo-22/bloques.pl predicado: plan/3 a_lo_ancho/4 consulta: plan(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia), Plan). -->
```prolog
%!  plan(+Inicial, +Meta, -Plan:list) is semidet.
%
%   Plan es una de las secuencias de acciones más cortas que llevan de
%   Inicial a Meta. Falla si Meta no se puede alcanzar.
plan(Inicial, Meta, Plan) :-
    normalizar(Inicial, I),
    normalizar(Meta, M),
    a_lo_ancho([I-[]], [I], M, Invertido),
    reverse(Invertido, Plan).

%!  a_lo_ancho(+Cola:list(pair), +Visitados:list, +Meta, -Camino) is semidet.
%
%   Cola tiene los estados por examinar, cada uno con el camino que llegó a
%   él, la última acción primero. Visitados es el conjunto ordenado de los
%   estados ya encolados, que no se vuelven a encolar.
a_lo_ancho([Estado-Camino|Cola], Visitados, Meta, Plan) :-
    (   Estado == Meta
    ->  Plan = Camino
    ;   findall(S-[A|Camino],
                ( sucesor(Estado, A, S),
                  \+ ord_memberchk(S, Visitados) ),
                Nuevos0),
        sort(1, @<, Nuevos0, Nuevos),
        pairs_keys(Nuevos, Estados),
        ord_union(Visitados, Estados, Visitados1),
        append(Cola, Nuevos, Cola1),
        a_lo_ancho(Cola1, Visitados1, Meta, Plan)
    ).
```

```prolog
?- plan(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia), Plan).
Plan = [tomar(c), soltar(c), tomar(b), apilar(b, c), tomar(a), apilar(a, b)].
```

Es la **anomalía de Sussman**: para apilar a sobre b se debe deshacer la pila
de c sobre a, aunque la meta no menciona esa pila. La cola guarda cada estado
con el camino que llegó a él, y `Visitados` es un conjunto ordenado con los
estados ya encolados: un estado que se alcanza por dos caminos se examina una
sola vez, y la búsqueda termina aunque el grafo de estados tenga ciclos
—tomar un bloque y soltarlo vuelve al mismo estado—.

!!! example "Patrón 25 — Búsqueda en un espacio de estados con visitados"
    **Problema.** Es necesario encontrar una secuencia de acciones que lleva
    de un estado inicial a uno final, y las acciones pueden volver a estados ya
    vistos.

    **Versión ingenua.** Una búsqueda en profundidad que prueba acciones
    recursivamente, como la [plantilla 15](../plantillas.md#15-generar-y-probar): entra en ciclos, o encuentra
    un plan largo antes que uno corto.

    **Patrón.** El estado como término normalizado; `sucesor/3` con las
    acciones; una cola de estados con su camino, y un conjunto ordenado de
    visitados que no se vuelven a encolar. A lo ancho, el primer plan es uno
    de los más cortos.

    **Cuándo no usarlo.** Cuando el espacio de estados es demasiado grande
    para recorrerlo y hace falta una heurística que guíe la búsqueda, como en
    el [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md); o
    cuando el problema se modela mejor con restricciones
    ([capítulo 23](../capitulo-23-programacion-con-restricciones/index.md)).

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C4 | `por_edad/1` y `ranking/1` son `det`, y `plan/3` `semidet`: ninguno deja alternativas pendientes, y sus pruebas no declaran `nondet` |
    | C6 | el azar está en un solo predicado, `minas_al_azar/4`; `tablero/4` recibe las minas como argumento y es una relación; las pruebas de lo aleatorio fijan la semilla en `setup` |

## 22.11 Buscaminas: el tablero como tabla de búsqueda

Los capítulos [17](../capitulo-17-todas-las-soluciones/index.md) y [18](../capitulo-18-orden-superior/index.md) representaron el tablero con hechos `mina/2`. Un juego
completo necesita un tablero distinto en cada partida, que se construye
durante la ejecución, y consulta el valor de una celda muchas veces: es el [Patrón 24](../patrones.md#24-tabla-de-busqueda-con-assoc).
Un tablero es `tablero(Filas, Columnas, Celdas)`, con `Celdas` un assoc de cada
celda a `mina` o a la cantidad de minas vecinas, calculada una sola vez.

<!-- ejemplo: capitulo-22/buscaminas.pl predicado: tablero/4 valor_inicial/5 valor/3 consulta: tablero(3, 4, [1-1, 2-3], T), valor(T, 2-2, V). -->
```prolog
%!  tablero(+Filas:integer, +Columnas:integer, +Minas:list, -Tablero) is det.
%
%   Tablero es el tablero de Filas por Columnas con minas en las celdas de
%   Minas, pares Fila-Columna.
tablero(Filas, Columnas, Minas, tablero(Filas, Columnas, Celdas)) :-
    list_to_ord_set(Minas, ConjuntoDeMinas),
    findall(F-C, ( between(1, Filas, F), between(1, Columnas, C) ), Todas),
    maplist(valor_inicial(Filas, Columnas, ConjuntoDeMinas), Todas, Valores),
    pairs_keys_values(Pares, Todas, Valores),
    list_to_assoc(Pares, Celdas).

%!  valor_inicial(+Filas:integer, +Columnas:integer, +Minas:list,
%!                +Celda:pair, -Valor) is det.
%
%   Valor es mina si Celda está en Minas, o la cantidad de minas vecinas.
valor_inicial(Filas, Columnas, Minas, F-C, Valor) :-
    (   ord_memberchk(F-C, Minas)
    ->  Valor = mina
    ;   aggregate_all(count,
                      ( vecina(Filas, Columnas, F-C, V),
                        ord_memberchk(V, Minas) ),
                      Valor)
    ).

%!  valor(+Tablero, +Celda:pair, -Valor) is semidet.
%
%   Valor es lo que hay en Celda: mina o la cantidad de minas vecinas. Falla
%   si Celda está fuera del tablero.
valor(tablero(_, _, Celdas), Celda, Valor) :-
    get_assoc(Celda, Celdas, Valor).
```

`vecina/4`, en el mismo archivo, enumera las celdas que rodean a una dentro
del tablero: es la del [capítulo 18](../capitulo-18-orden-superior/index.md)
con la celda y su vecina como pares `Fila-Columna`. `mostrar/1`, también del
archivo, escribe el tablero con `*` en las minas:
`tablero(3, 4, [1-1, 2-3], T), mostrar(T)` escribe:

```text
*211
12*1
0111
```

El tablero al azar separa las dos decisiones de la [sección 22.9](#229-libraryrandom): `tablero/4` es
una relación, que recibe las minas; `minas_al_azar/4` las elige con
`randseq/3`, y es el único predicado del archivo que usa el azar.

<!-- ejemplo: capitulo-22/buscaminas.pl predicado: minas_al_azar/4 celda_numero/3 tablero_al_azar/4 consulta: tablero(3, 4, [1-1, 2-3], T), mostrar(T). -->
```prolog
%!  minas_al_azar(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                -Minas:list) is det.
%
%   Minas son Cantidad celdas distintas del tablero, elegidas al azar, en
%   orden.
minas_al_azar(Filas, Columnas, Cantidad, Minas) :-
    Total is Filas * Columnas,
    randseq(Cantidad, Total, Numeros),
    maplist(celda_numero(Columnas), Numeros, Celdas),
    sort(Celdas, Minas).

%!  celda_numero(+Columnas:integer, +K:integer, -Celda:pair) is det.
%
%   Celda es la celda número K del tablero, contando por filas desde 1.
celda_numero(Columnas, K, F-C) :-
    F is (K - 1) // Columnas + 1,
    C is (K - 1) mod Columnas + 1.

%!  tablero_al_azar(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                  -Tablero) is det.
%
%   Tablero es un tablero de Filas por Columnas con Cantidad minas al azar.
tablero_al_azar(Filas, Columnas, Cantidad, Tablero) :-
    minas_al_azar(Filas, Columnas, Cantidad, Minas),
    tablero(Filas, Columnas, Minas, Tablero).
```

`buscaminas.plt` prueba `minas_al_azar/4` con la semilla fija, y comprueba que
un tablero al azar de 9 × 9 con 10 minas tiene exactamente 10.

## 22.12 El proyecto: el ranking y un índice por alumno

La versión de *Inscripciones* de este capítulo calcula el ranking con `sort/4`,
en lugar de `order_by/2`, y agrega un índice de cada alumno a sus
inscripciones:

<!-- ejemplo: capitulo-22/inscripciones.pl predicado: ranking/1 mejores/2 indice_por_alumno/1 materias_de/3 consulta: ranking(R). -->
```prolog
%!  ranking(-Ranking:list(pair)) is det.
%
%   Ranking son los pares Legajo-Promedio de los alumnos con alguna nota, de
%   mayor a menor promedio; con el mismo promedio, en el orden de los legajos.
ranking(Ranking) :-
    findall(Legajo-Promedio, promedio_de_alumno(Legajo, Promedio), Pares),
    sort(2, @>=, Pares, Ranking).

%!  mejores(+Cantidad:integer, -Ranking:list(pair)) is det.
%
%   Ranking es la lista de los Cantidad mejores promedios, de mayor a menor,
%   como pares Legajo-Promedio.
mejores(Cantidad, Ranking) :-
    ranking(Todos),
    findall(Par, limit(Cantidad, member(Par, Todos)), Ranking).

%!  indice_por_alumno(-Indice) is det.
%
%   Indice es un assoc de cada legajo con inscripciones a la lista de sus
%   pares Materia-Estado, en el orden de los hechos.
indice_por_alumno(Indice) :-
    findall(Legajo-(Materia-Estado),
            inscripcion(Legajo, Materia, Estado),
            Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    list_to_assoc(Grupos, Indice).

%!  materias_de(+Indice, +Legajo:integer, -Materias:list(pair)) is det.
%
%   Materias son los pares Materia-Estado del alumno Legajo en Indice; la
%   lista vacía si no tiene inscripciones.
materias_de(Indice, Legajo, Materias) :-
    (   get_assoc(Legajo, Indice, Encontradas)
    ->  Materias = Encontradas
    ;   Materias = []
    ).
```

```prolog
?- ranking(R).
R = [101-8.5, 104-8, 103-6, 106-4.5, 102-4].
```

Con el índice de `indice_por_alumno(I)`, `materias_de(I, 104, M)` da
`M = [log-nota(9), alg-nota(7), pp-nota(8)]`.

`sort(2, @>=, Pares, Ranking)` ordena por el promedio, de mayor a menor, y
conserva el orden de los legajos en los empates. `mejores/2` toma los primeros
con `limit/2` sobre `member/2`. La prueba `los_tres_mejores` del
[capítulo 17](../capitulo-17-todas-las-soluciones/index.md) pasa sin cambios: la reescritura da el mismo resultado.

`indice_por_alumno/1` agrupa las inscripciones por legajo con `keysort/2` y
`group_pairs_by_key/2`, y guarda los grupos en un assoc: un informe que
consulta las materias de cada uno de miles de alumnos construye el índice una
vez, en lugar de recorrer todas las inscripciones por alumno.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir la respuesta de cada consulta:
   `msort([b, 2, "a", f(1), 1.5], L).` · `sort(0, @>=, [3, 1, 2, 3], L).` ·
   `sort(1, @<, [b-1, a-2, b-3], L).`
2. **(1)** Aplicar `sort/2`, `msort/2` y `list_to_set/2` a `[c, a, b, a]`.
   ¿Cuál conserva el orden original, y cuáles eliminan los repetidos?
3. ★ **(2)** Escribir `por_longitud(Listas, Ordenadas)`, que ordena una lista
   de listas de la más corta a la más larga, con el [Patrón 23](../patrones.md#23-decorar-ordenar-desdecorar).
4. **(2)** Escribir `anagramas(Palabra, Candidatas, Anagramas)`: las candidatas
   con las mismas letras que la palabra, en otro orden.
5. ★ **(2)** Escribir el registro de una escuela: `agregar_alumno/4` agrega un
   nombre a un grado, y `alumnos_de/3` da los alumnos de un grado en orden
   alfabético. La escuela es un assoc de cada grado a un conjunto ordenado.
6. **(2)** Escribir `por_valor(Pares, Ordenados)` con `predsort/3`, ordenando
   por el valor sin perder los pares con el mismo valor.
7. **(2)** Escribir `la_mayor(Personas, Mayor)` para una lista de dicts con la
   clave `edad`, con `foldl/4`. ¿Qué ocurre si el paso de `foldl/4` es una
   lambda que usa `P.edad`?
8. ★ **(2)** Escribir `formatear_nombre(Nombre, Opciones, Texto)` con las
   opciones `mayusculas(B)`, `false` por omisión, y `prefijo(P)`, `''` por
   omisión.
9. **(2)** Escribir `sorteo(Cantidad, Hasta, Numeros)`: Cantidad números
   distintos entre 1 y Hasta, al azar, y una prueba que fija la semilla.
10. ★ **(3)** Escribir `plan_iterativo/3` para el mundo de bloques: una
    búsqueda en profundidad con un límite de acciones que empieza en 0 y crece
    de a uno. ¿Encuentra el mismo plan que `plan/3`?
11. **(2)** Escribir `plan_contando/4`, que además del plan da la cantidad de
    estados que la búsqueda a lo ancho visitó.
12. ★ **(2)** Escribir `descubrir/4` para el tablero de la [sección 22.11](#2211-buscaminas-el-tablero-como-tabla-de-busqueda): el
    recorrido del [capítulo 18](../capitulo-18-orden-superior/index.md), con los valores del assoc.
13. **(2)** Escribir `tablero_desde_texto(Lineas, Tablero)`, el inverso de
    `mostrar/1`: construye el tablero a partir de las cadenas que escribe.
14. **(2)** Escribir `ranking_de_carrera(Carrera, Ranking)` para el proyecto.
15. **(3)** Escribir un índice de cada materia al conjunto ordenado de sus
    alumnos, y `alumnos_en_comun/4`, con `ord_intersection/3`.
16. **(2)** Un árbol binario de búsqueda se representa con la constante
    `vacio` y el término `n(Izq, Clave, Der)`: las claves de `Izq` son menores
    que `Clave` y las de `Der`, mayores. La versión siguiente de
    `insertar(Clave, Arbol0, Arbol)` es incorrecta:

    ```prolog
    %!  insertar(+Clave, +Arbol0, -Arbol) is det.
    %
    %   Arbol es Arbol0 con Clave agregada.
    insertar(Clave, vacio, n(vacio, Clave, vacio)).
    insertar(Clave, n(Izq, Clave0, _), Arbol) :-
        Clave @< Clave0,
        insertar(Clave, Izq, Arbol).
    insertar(Clave, n(_, Clave0, Der), Arbol) :-
        Clave @> Clave0,
        insertar(Clave, Der, Arbol).
    insertar(Clave, n(_, Clave, _), _).
    ```

    Predecir la respuesta de `insertar(5, n(vacio, 7, vacio), A).` y la de
    `insertar(7, n(vacio, 7, vacio), A).`, y explicar qué pone cada cláusula
    en el tercer argumento. Corregirla con `compare/3`, sin dejar alternativas
    pendientes. ¿Cuántos nodos nuevos construye una inserción, y qué se obtiene
    al insertar una clave que ya está? Relacionarlo con lo que la
    [sección 22.5](#225-libraryassoc-y-libraryrbtrees) dice de `put_assoc/4`.

## Resumen

| | |
|---|---|
| `library(lists)` | `nth1/3`, `last/2`, `sum_list/2`, `max_member/2`, `select/3`, `subtract/3`, `list_to_set/2`, … |
| orden estándar | variables, números, cadenas, átomos, compuestos (por aridad, nombre y argumentos) |
| `sort/2`, `msort/2` | ordenar sin repetidos, o con ellos |
| `sort/4` | ordenar por un argumento, en cualquier sentido; estable con `@=<` y `@>=` |
| `predsort/3` | ordenar con una comparación propia; elimina los iguales |
| pares y `keysort/2` | `Clave-Valor`; ordenar por la clave, de forma estable |
| `library(pairs)`: `map_list_to_pairs/3`, `pairs_keys_values/3`, `pairs_keys/2`, `pairs_values/2`, `group_pairs_by_key/2` | armar pares, separar claves y valores, agrupar los valores de claves consecutivas iguales |
| `clumped/2` | las rachas de elementos iguales consecutivos, como pares `Elemento-Cantidad`; después de `msort/2`, las frecuencias |
| `library(assoc)` | árbol balanceado de búsqueda: `list_to_assoc/2`, `get_assoc/3`, `put_assoc/4`, `del_assoc/4`; `empty_assoc/1` (en las soluciones); `assoc_to_keys/2`, `assoc_to_values/2` |
| `library(ordsets)`: `list_to_ord_set/2`, `ord_union/3`, `ord_intersection/3`, `ord_subtract/3`, `ord_memberchk/2`, `ord_add_element/3` | conjuntos como listas ordenadas: conversión desde una lista, unión, intersección, diferencia, pertenencia, agregado |
| dicts | `_{clave: valor}`, `get_dict/3`, `put_dict/4`, `D.clave` |
| `option/3` | una opción de una lista, con valor por omisión |
| `library(random)`: `randseq/3`, `set_random/1` | azar con semilla; en un solo predicado, con la semilla fija en las pruebas |
| `string_length/2` | la cantidad de caracteres de una cadena (en las soluciones) |
| `is_dict/2` | se cumple si el término es un dict, y da su etiqueta; en las pruebas |
| `same_term/2` | se cumple si los dos argumentos son el mismo término en memoria; en las pruebas de las soluciones |
| **Patrones 23, 24, 25** | decorar, ordenar, desdecorar; tabla de búsqueda con `assoc`; búsqueda con visitados |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| El Buscaminas: deducir dónde están las minas | [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md) |
| JSON y dicts en archivos | [capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) |
| El tablero en la terminal, con un tablero al azar | [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) |
| Dicts en un servicio web | [capítulo 30](../capitulo-30-servicios-web-rest/index.md) |
| Búsqueda con heurísticas; el mundo de bloques con análisis de medios y fines | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
| La búsqueda en un espacio de estados, en los juegos de dos jugadores | [capítulo 41](../capitulo-41-juegos/index.md) |
