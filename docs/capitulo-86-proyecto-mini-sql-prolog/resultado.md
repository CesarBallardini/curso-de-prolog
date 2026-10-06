# El resultado entero

Esta página contiene la
[sección 86.8](index.md#868-version-6-el-resultado-entero) del
[capítulo 86](index.md): lo que el mini-SQL necesita calcular sobre todas
las filas de una consulta y no sobre una por vez. Los grupos y los
agregados, el orden, el límite, `DISTINCT` y las operaciones de conjuntos
están en `consultas.pl`, en `ejemplos/capitulo-86/`, con sus pruebas.

## Grupos y agregados

Kluźniak y Szpakowicz observan que las consultas hechas solo de
selecciones, proyecciones y reuniones se pueden responder sin construir
el resultado: cada tupla se genera y se muestra en el bucle de falla.
Para un agregado, en cambio, hace falta la columna entera, y la obtienen
con `bagof/3`. Toy-Sequel deja los agregados fuera, como una extensión
para el lector.

Una selección es **agrupada** si tiene `GROUP BY`, `HAVING` o un agregado
entre sus ítems. `grupo/10` la compila en cuatro pasos. Primero junta, con
`findall/3`, un par por cada fila que pasa el filtro: los valores de las
columnas de `GROUP BY` y los argumentos de los agregados. Después forma
los grupos. Para cada grupo liga las columnas de `GROUP BY` a la clave,
calcula los agregados y prueba `HAVING`. Al final calcula la fila. Las
expresiones de la selección y de `HAVING` se compilan en un contexto
`grupo(Claves, Agregados)`: una columna tiene que ser una de las claves,
y cada agregado se anota en la lista abierta `Agregados`, que se cierra
al terminar.

<!-- ejemplo: capitulo-86/consultas.pl predicado: grupo/10 -->
```prolog
%!  grupo(+Items, +Grupo:list, +Teniendo, +Marcos:list, +Pila:list,
%!        +Generadores:list, +Filtro, -Meta, -Valores:list,
%!        -Columnas:list) is det.
%
%   Compila una selección agrupada. Meta junta, para cada fila que pasa
%   el filtro, los valores de las columnas de GROUP BY y los argumentos de
%   los agregados; forma los grupos; y para cada grupo liga las columnas
%   de GROUP BY, calcula los agregados, prueba HAVING y calcula la fila.
grupo(Items, Grupo, Teniendo, Marcos, Pila, Generadores, Filtro, Meta,
      Valores, Columnas) :-
    maplist(clave_grupo(Pila), Grupo, Claves),
    Contexto = grupo(Claves, Agregados),
    proyeccion(Items, Contexto, Marcos, Pila, Valores, Columnas, Calculo),
    condicion(Teniendo, Contexto, Pila, verdadera, Having0),
    filtro(Having0, Having),
    cerrar(Agregados),
    partes(Agregados, Funciones, Argumentos, MetasArgumentos, Resultados),
    append([Generadores, [Filtro], MetasArgumentos], Metas),
    conjuncion(Metas, MetaFila),
    (   Grupo == []
    ->  Global = si
    ;   Global = no
    ),
    conjuncion([ findall(Claves-Argumentos, MetaFila, Pares),
                 consultas:grupos(Global, Pares, Grupos),
                 member(Claves-Filas, Grupos),
                 consultas:agregados(Funciones, Filas, Resultados),
                 Having,
                 Calculo ],
               Meta).
```

<!-- contexto: capitulo-86/consultas.pl -->
```prolog
% mostrar_traduccion("SELECT carrera, COUNT(*) AS n FROM alumnos GROUP BY carrera HAVING COUNT(*) >= 2").
consulta([A, B]) :-
    findall([A]-[1, 1],
            base:alumno(_, _, A, _),
            C),
    consultas:grupos(no, C, D),
    member([A]-E, D),
    consultas:agregados([count-no, count-no], E, [B, F]),
    F>=2.
```

La meta muestra los cuatro pasos. `COUNT(*)` aparece dos veces, en la
selección y en `HAVING`, y se calcula dos veces: el compilador no
reconoce que los dos agregados son el mismo. El argumento de `COUNT(*)`
es la constante 1, que nunca es `NULL`. La variable `A` de la carrera
queda libre dentro de `findall/3`, que copia la plantilla, y se liga al
recorrer los grupos con `member/2`. Una columna que no está en
`GROUP BY` no tiene valor en el grupo, y su uso es un error:

```prolog
?- catch(filas("SELECT nombre, carrera FROM alumnos GROUP BY carrera", _, _), E, true).
E = error(sql(no_agrupada(nombre)), _).
```

SQLite admite esa consulta y toma el nombre de alguna fila del grupo;
el estándar de SQL la rechaza, y el mini-SQL también.

`grupos/3` ordena los pares por la clave con `keysort/2`, que es estable,
y los agrupa con `group_pairs_by_key/2`. Sin `GROUP BY` hay un solo
grupo, aunque no haya ninguna fila; con `GROUP BY` y sin filas, no hay
ningún grupo. Los agregados siguen las reglas de SQL: `COUNT` cuenta los
valores que no son `NULL`, y los demás los ignoran; `SUM`, `AVG`, `MIN` y
`MAX` de ningún valor son `NULL`, y `AVG` es siempre de punto flotante.

<!-- ejemplo: capitulo-86/consultas.pl predicado: grupos/3 agregar/4 -->
```prolog
%!  grupos(+Global, +Pares:list, -Grupos:list) is det.
%
%   Grupos son los Clave-Filas de los pares Clave-Fila, ordenados por la
%   clave. Sin GROUP BY (Global = si) hay un solo grupo, aunque no haya
%   filas.
grupos(si, Pares, [[]-Filas]) :-
    pairs_values(Pares, Filas).
grupos(no, Pares, Grupos) :-
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos).

%!  agregar(+F, +Distinto, +Valores:list, -R) is det.
%
%   R es la función F sobre los Valores que no son NULL, sin repetidos si
%   Distinto es si. SUM, AVG, MIN y MAX de ningún valor son NULL; AVG es
%   de punto flotante.
agregar(F, D, Valores, R) :-
    exclude(==(null), Valores, Vs0),
    (   D == si
    ->  sort(Vs0, Vs)
    ;   Vs = Vs0
    ),
    (   F == count
    ->  length(Vs, R)
    ;   Vs == []
    ->  R = null
    ;   F == sum
    ->  sum_list(Vs, R)
    ;   F == avg
    ->  sum_list(Vs, S),
        length(Vs, K),
        R is float(S / K)
    ;   F == min
    ->  min_member(R, Vs)
    ;   max_member(R, Vs)
    ).
```

```prolog
?- filas("SELECT legajo, AVG(nota) FROM inscripciones WHERE nota IS NOT NULL GROUP BY legajo", Ns, Fs).
Ns = [legajo, avg],
Fs = [[101, 8.5], [102, 4.0], [103, 6.0], [104, 8.0], [106, 4.5]].

?- filas("SELECT COUNT(*), SUM(ingreso), MAX(nombre) FROM alumnos WHERE carrera = 'quimica'", Ns, Fs).
Ns = [count, sum, max],
Fs = [[0, null, null]].
```

La segunda consulta es la diferencia de los agregados que señaló la
[sección 42.4](../capitulo-42-prolog-y-sql/index.md#424-donde-difieren-bolsas-conjuntos-y-null):
`bagof/3` falla cuando no hay soluciones, y SQL da una fila con cero y
dos `NULL`.

## Orden, límite y filas distintas

`ORDER BY` nombra columnas del resultado, por su nombre o por su
posición; `pasos_orden/3` traduce cada una a su posición al compilar.
`procesar/3` aplica sobre la lista de filas los pasos que la consulta
necesita, en orden: `distinto`, `ordenar(Claves)` y `limite(N)`.
`list_to_set/2` elimina las filas repetidas y conserva la primera
aparición de cada una. El orden por varias claves es una sucesión de
ordenamientos estables, de la última clave a la primera: cada uno
conserva el orden que dejaron los anteriores entre las filas que empatan.

<!-- ejemplo: capitulo-86/consultas.pl predicado: paso/3 ordenar_por/3 con_clave/3 -->
```prolog
%!  paso(+Paso, +Filas0:list, -Filas:list) is det.
%
%   Un paso sobre el resultado entero.
paso(distinto, Filas0, Filas) :-
    list_to_set(Filas0, Filas).
paso(ordenar(Claves), Filas0, Filas) :-
    reverse(Claves, Inversas),
    foldl(ordenar_por, Inversas, Filas0, Filas).
paso(limite(N), Filas0, Filas) :-
    length(Filas0, L),
    (   L =< N
    ->  Filas = Filas0
    ;   length(Filas, N),
        append(Filas, _, Filas0)
    ).

%!  ordenar_por(+Clave, +Filas0:list, -Filas:list) is det.
%
%   Filas es Filas0 ordenada, de manera estable, por la columna I de
%   Clave = I-Direccion. NULL va primero en orden ascendente, como en
%   SQLite.
ordenar_por(I-D, Filas0, Filas) :-
    maplist(con_clave(I), Filas0, Pares),
    (   D == asc
    ->  sort(1, @=<, Pares, Ordenados)
    ;   sort(1, @>=, Pares, Ordenados)
    ),
    pairs_values(Ordenados, Filas).

% con_clave(I, Fila, K-Fila): K ordena NULL antes que cualquier valor.
con_clave(I, Fila, K-Fila) :-
    nth1(I, Fila, V),
    (   V == null
    ->  K = k(0)
    ;   K = k(1, V)
    ).
```

`sort/4` con `@=<` o `@>=` no elimina los elementos iguales, y es
estable. `con_clave/3` pone `NULL` antes que cualquier valor, como
SQLite: `k(0)` precede a `k(1, V)` en el orden estándar de los términos,
porque tiene menos argumentos.

```prolog
% mostrar_traduccion("SELECT DISTINCT carrera FROM alumnos ORDER BY carrera LIMIT 2").
consulta([A]) :-
    findall([B], base:alumno(_, _, B, _), C),
    consultas:procesar([distinto, ordenar([1-asc]), limite(2)], C, D),
    member([A], D).
```

```prolog
?- filas("SELECT nota FROM inscripciones WHERE nota IS NULL OR nota < 4 ORDER BY nota", _, Fs).
Fs = [[null], [null], [null], [2], [3]].
```

## Operaciones de conjuntos

`UNION`, `INTERSECT` y `EXCEPT` se aplican a dos selecciones con la misma
cantidad de columnas y tipos compatibles. Las dos se juntan enteras, y
`combinar/4` las combina: `UNION ALL` concatena las dos bolsas, y las
otras tres eliminan las filas repetidas, como el álgebra relacional. Es
la distinción del
[capítulo 42](../capitulo-42-prolog-y-sql/index.md#424-donde-difieren-bolsas-conjuntos-y-null)
entre las cláusulas de Prolog, que son un `UNION ALL`, y `setof/3`.

<!-- ejemplo: capitulo-86/consultas.pl predicado: combinar/4 -->
```prolog
%!  combinar(+Op, +FA:list, +FB:list, -Filas:list) is det.
%
%   Filas es la operación de conjuntos Op entre las filas FA y FB: union
%   y union_todo, interseccion y diferencia. Todas menos union_todo
%   eliminan las filas repetidas.
combinar(union_todo, FA, FB, Filas) :-
    append(FA, FB, Filas).
combinar(union, FA, FB, Filas) :-
    append(FA, FB, F0),
    list_to_set(F0, Filas).
combinar(interseccion, FA, FB, Filas) :-
    list_to_set(FA, SA),
    findall(F, ( member(F, SA), memberchk(F, FB) ), Filas).
combinar(diferencia, FA, FB, Filas) :-
    list_to_set(FA, SA),
    findall(F, ( member(F, SA), \+ memberchk(F, FB) ), Filas).
```

```prolog
% mostrar_traduccion("SELECT legajo FROM inscripciones WHERE materia = 'am1' EXCEPT SELECT legajo FROM inscripciones WHERE materia = 'alg'").
consulta([A]) :-
    findall([B], base:inscripcion(B, am1, _), C),
    findall([D], base:inscripcion(D, alg, _), E),
    consultas:combinar(diferencia, C, E, F),
    member([A], F).
```

```prolog
?- filas("SELECT legajo FROM inscripciones WHERE materia = 'am1' EXCEPT SELECT legajo FROM inscripciones WHERE materia = 'alg'", _, Fs).
Fs = [[105], [106]].
```

Juntar las filas tiene un costo: la meta ya no da la primera fila sin
calcular todas. Una consulta con `LIMIT 1` sobre una tabla grande calcula
la tabla entera antes de quedarse con una fila. Una base de datos real
evita ese costo cuando puede, y lo paga cuando el orden lo exige.

!!! question "Actividad"
    Predecir la meta y las filas de
    `SELECT carrera, MIN(ingreso), MAX(ingreso) FROM alumnos GROUP BY
    carrera ORDER BY 2 DESC, carrera`. Comprobarlo, y explicar el orden
    de las dos carreras que empatan.
