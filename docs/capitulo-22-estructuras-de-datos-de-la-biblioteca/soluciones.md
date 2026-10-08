# Soluciones del capítulo 22 — Estructuras de datos de la biblioteca

El código de esta página está en `ejemplos/capitulo-22/soluciones.pl`,
`soluciones_bloques.pl`, `soluciones_buscaminas.pl` y `soluciones_proyecto.pl`,
en el mismo directorio, y pasa sus pruebas. Los tres últimos contienen el
ejemplo del capítulo que extienden, para que cada uno se cargue solo.

## 1

```prolog
?- msort([b, 2, "a", f(1), 1.5], L).
L = [1.5, 2, "a", b, f(1)].

?- sort(0, @>=, [3, 1, 2, 3], L).
L = [3, 3, 2, 1].

?- sort(1, @<, [b-1, a-2, b-3], L).
L = [a-2, b-1].
```

La primera sigue el orden estándar: números, cadenas, átomos, compuestos. La
segunda ordena de mayor a menor y conserva el 3 repetido, porque `@>=` no
elimina. La tercera ordena por la clave, el primer argumento de cada par, y
`@<` elimina los pares con la misma clave: de los dos `b`, queda el primero.

## 2

```prolog
?- sort([c, a, b, a], S), msort([c, a, b, a], M), list_to_set([c, a, b, a], T).
S = [a, b, c],
M = [a, a, b, c],
T = [c, a, b].
```

`sort/2` ordena y elimina; `msort/2` ordena y conserva; `list_to_set/2` elimina
y conserva el orden original, con la primera aparición de cada elemento.

## 3

<!-- ejemplo: capitulo-22/soluciones.pl predicado: por_longitud/2 consulta: por_longitud([[a, b, c], [d], [e, f]], L). -->
```prolog
%!  por_longitud(+Listas:list(list), -Ordenadas:list(list)) is det.
%
%   Ordenadas son las Listas de la más corta a la más larga; con la misma
%   longitud, en el orden original.
por_longitud(Listas, Ordenadas) :-
    map_list_to_pairs(length, Listas, Pares),
    keysort(Pares, Ordenados),
    pairs_values(Ordenados, Ordenadas).
```

```prolog
?- por_longitud([[a, b, c], [d], [e, f]], L).
L = [[d], [e, f], [a, b, c]].
```

`map_list_to_pairs(length, …)` decora cada lista con su longitud, `keysort/2`
ordena por ella, y `pairs_values/2` quita la decoración. `keysort/2` es estable:
dos listas de la misma longitud quedan en su orden original, y la prueba
`por_longitud_estable` lo verifica.

## 4

<!-- ejemplo: capitulo-22/soluciones.pl predicado: anagramas/3 letras/2 consulta: anagramas(roma, [amor, mora, ramo, rama, roma, aroma], L). -->
```prolog
%!  anagramas(+Palabra:atom, +Candidatas:list, -Anagramas:list) is det.
%
%   Anagramas son las Candidatas que tienen las mismas letras que Palabra,
%   en otro orden. Palabra misma no es su propio anagrama.
anagramas(Palabra, Candidatas, Anagramas) :-
    letras(Palabra, Letras),
    include([C]>>( C \== Palabra, letras(C, Letras) ), Candidatas,
            Anagramas).

%!  letras(+Palabra:atom, -Letras:list) is det.
%
%   Letras son los caracteres de Palabra ordenados, con los repetidos.
letras(Palabra, Letras) :-
    atom_chars(Palabra, Caracteres),
    msort(Caracteres, Letras).
```

```prolog
?- anagramas(roma, [amor, mora, ramo, rama, roma, aroma], L).
L = [amor, mora, ramo].
```

Dos palabras son anagramas si sus letras, ordenadas con los repetidos, son la
misma lista. `msort/2` conserva las letras repetidas. Con `sort/2`, «aroma»
daría `[a, m, o, r]`, igual que «roma», y pasaría por anagrama; `msort/2` da
`[a, a, m, o, r]` y la rechaza.

## 5

<!-- ejemplo: capitulo-22/soluciones.pl predicado: agregar_alumno/4 alumnos_de/3 escuela/2 consulta: escuela([2-luis, 1-ana, 2-eva, 1-ana], E), alumnos_de(E, 2, L). -->
```prolog
%!  agregar_alumno(+Grado:integer, +Nombre:atom, +Escuela0, -Escuela) is det.
%
%   Escuela es Escuela0, un assoc de cada grado a un conjunto ordenado de
%   nombres, con Nombre agregado al Grado.
agregar_alumno(Grado, Nombre, Escuela0, Escuela) :-
    (   get_assoc(Grado, Escuela0, Nombres0)
    ->  true
    ;   Nombres0 = []
    ),
    ord_add_element(Nombres0, Nombre, Nombres),
    put_assoc(Grado, Escuela0, Nombres, Escuela).

%!  alumnos_de(+Escuela, +Grado:integer, -Nombres:list(atom)) is det.
%
%   Nombres son los alumnos del Grado, en orden alfabético; la lista vacía si
%   no tiene ninguno.
alumnos_de(Escuela, Grado, Nombres) :-
    (   get_assoc(Grado, Escuela, Encontrados)
    ->  Nombres = Encontrados
    ;   Nombres = []
    ).

%!  escuela(+Altas:list(pair), -Escuela) is det.
%
%   Escuela es la escuela que resulta de agregar cada alta Grado-Nombre, en
%   orden, a una escuela vacía.
escuela(Altas, Escuela) :-
    empty_assoc(Vacia),
    foldl([G-N, E0, E]>>agregar_alumno(G, N, E0, E), Altas, Vacia, Escuela).
```

```prolog
?- escuela([2-luis, 1-ana, 2-eva, 1-ana], E), alumnos_de(E, 2, L).
E = t(2, [eva, luis], <, t(1, [ana], -, t, t), t),
L = [eva, luis].
```

Cada grado es una clave del assoc, y su valor un conjunto ordenado:
`ord_add_element/3` agrega el nombre en su lugar y no lo repite, y por eso ana,
dada de alta dos veces en el grado 1, aparece una sola vez. `escuela/2` pliega
la lista de altas con `foldl/4`, a partir del assoc sin claves que construye
`empty_assoc/1`.

## 6

<!-- ejemplo: capitulo-22/soluciones.pl predicado: por_valor/2 comparar_valor/3 consulta: por_valor([a-3, b-1, c-3, d-2], L). -->
```prolog
%!  por_valor(+Pares:list(pair), -Ordenados:list(pair)) is det.
%
%   Ordenados son los Pares de menor a mayor valor, con los repetidos:
%   comparar_valor/3 nunca responde =.
por_valor(Pares, Ordenados) :-
    predsort(comparar_valor, Pares, Ordenados).

%!  comparar_valor(-Orden, +A:pair, +B:pair) is det.
%
%   Orden es < si el valor de A es menor o igual que el de B, y > si no.
comparar_valor(Orden, _-VA, _-VB) :-
    (   VA =< VB
    ->  Orden = (<)
    ;   Orden = (>)
    ).
```

```prolog
?- por_valor([a-3, b-1, c-3, d-2], L).
L = [b-1, d-2, a-3, c-3].
```

`predsort/3` elimina los elementos que la comparación declara iguales. Con
`compare/3` sobre los valores, `a-3` y `c-3` serían iguales, y quedaría uno.
`comparar_valor/3` nunca responde `=`: ante valores iguales responde `<`, y los
dos pares se conservan. `sort(2, @=<, Pares, L)` hace lo mismo con menos código;
`predsort/3` se justifica cuando el criterio no es un argumento.

## 7

<!-- ejemplo: capitulo-22/soluciones.pl predicado: la_mayor/2 la_mayor_de_dos/3 consulta: la_mayor([_{n: a, edad: 3}, _{n: b, edad: 9}, _{n: c, edad: 9}], M). -->
```prolog
%!  la_mayor(+Personas:list(dict), -Mayor:dict) is semidet.
%
%   Mayor es el dict de mayor edad de Personas; con empate, el primero. Falla
%   con la lista vacía.
la_mayor([Primera|Resto], Mayor) :-
    foldl(la_mayor_de_dos, Resto, Primera, Mayor).

%!  la_mayor_de_dos(+P:dict, +Hasta:dict, -Mayor:dict) is det.
%
%   Mayor es P si es mayor que Hasta, o Hasta si no. La notación funcional
%   se expande en la cláusula que la contiene: dentro de una lambda, se
%   evaluaría antes de que la lambda reciba P.
la_mayor_de_dos(P, Hasta, Mayor) :-
    (   P.edad > Hasta.edad
    ->  Mayor = P
    ;   Mayor = Hasta
    ).
```

```prolog
?- la_mayor([_{n: a, edad: 3}, _{n: b, edad: 9}, _{n: c, edad: 9}], M).
M = _{edad:9, n:b}.
```

Con la lambda `[P, M0, M]>>( P.edad > M0.edad -> … )` como paso, la consulta
produce un error de instanciación. La notación funcional se expande en la
cláusula que contiene la lambda: `P.edad` se vuelve un objetivo que se ejecuta
antes de `foldl/4`, cuando `P` todavía es una variable. La prueba
`punto_en_lambda` lo verifica. Un predicado con nombre, `la_mayor_de_dos/3`,
tiene su propia cláusula, y la expansión ocurre dentro de ella.

La actividad de la [sección 22.7](index.md#227-dicts) muestra las dos formas
de consultar una clave que el dict no tiene: `persona(ana, D),
get_dict(altura, D, V)` falla, y `persona(ana, D), V = D.altura` produce el
error `existence_error(key, altura, …)`, que la prueba `clave_inexistente` de
`dicts.plt` verifica.

## 8

<!-- ejemplo: capitulo-22/soluciones.pl predicado: formatear_nombre/3 consulta: formatear_nombre(ana, [mayusculas(true), prefijo('Sra. ')], T). -->
```prolog
%!  formatear_nombre(+Nombre:atom, +Opciones:list, -Texto:atom) is det.
%
%   Texto es Nombre con las Opciones: mayusculas(B), si se escribe en
%   mayúsculas, false si falta; prefijo(P), el texto que va antes, '' si
%   falta.
formatear_nombre(Nombre, Opciones, Texto) :-
    option(mayusculas(Mayusculas), Opciones, false),
    option(prefijo(Prefijo), Opciones, ''),
    (   Mayusculas == true
    ->  upcase_atom(Nombre, Base)
    ;   Base = Nombre
    ),
    atom_concat(Prefijo, Base, Texto).
```

```prolog
?- formatear_nombre(ana, [mayusculas(true), prefijo('Sra. ')], T).
T = 'Sra. ANA'.

?- formatear_nombre(ana, [], T).
T = ana.
```

`option/3` da el valor por omisión cuando la opción falta. El orden de las
opciones en la lista no importa, y una opción desconocida se ignora.

## 9

<!-- ejemplo: capitulo-22/soluciones.pl predicado: sorteo/3 consulta: sorteo(3, 10, L). -->
```prolog
%!  sorteo(+Cantidad:integer, +Hasta:integer, -Numeros:list(integer)) is det.
%
%   Numeros son Cantidad números distintos entre 1 y Hasta, elegidos al azar,
%   en el orden en que salieron.
sorteo(Cantidad, Hasta, Numeros) :-
    randseq(Cantidad, Hasta, Numeros).
```

`randseq/3` da números distintos. La prueba fija la semilla en su `setup`:

```prolog
test(sorteo, [ setup(set_random(seed(1))),
               true(L == [35, 19, 40, 15, 48, 28]) ]) :-
    sorteo(6, 49, L).
```

Sin semilla, la prueba solo puede verificar propiedades que valen para
cualquier resultado: que hay seis números, que son distintos, que están entre
1 y 49. `sorteo_sin_repetidos` verifica las dos primeras.

## 10

<!-- ejemplo: capitulo-22/soluciones_bloques.pl predicado: plan_iterativo/3 en_profundidad/5 consulta: plan_iterativo(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia), P). -->
```prolog
%!  plan_iterativo(+Inicial, +Meta, -Plan:list) is semidet.
%
%   Plan es una de las secuencias de acciones más cortas de Inicial a Meta,
%   buscada en profundidad con un límite de 0, 1, 2, … acciones, hasta 20.
plan_iterativo(Inicial, Meta, Plan) :-
    normalizar(Inicial, I),
    normalizar(Meta, M),
    between(0, 20, Limite),
    en_profundidad(I, M, Limite, [I], Plan),
    !.

%!  en_profundidad(+Estado, +Meta, +Limite:integer, +Camino:list, -Plan)
%!      is nondet.
%
%   Plan lleva de Estado a Meta con a lo sumo Limite acciones, sin pasar por
%   los estados de Camino.
en_profundidad(Estado, Meta, _, _, []) :-
    Estado == Meta.
en_profundidad(Estado, Meta, Limite, Camino, [A|Plan]) :-
    Estado \== Meta,
    Limite > 0,
    sucesor(Estado, A, Siguiente),
    \+ memberchk(Siguiente, Camino),
    Resto is Limite - 1,
    en_profundidad(Siguiente, Meta, Resto, [Siguiente|Camino], Plan).
```

```prolog
?- plan_iterativo(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia), P).
P = [tomar(c), soltar(c), tomar(b), apilar(b, c), tomar(a), apilar(a, b)].
```

La búsqueda en profundidad con límite no entra en ramas infinitas: con un
límite de N acciones, cada rama termina. Probar límites crecientes —0, 1, 2,
…— encuentra primero el plan más corto, como la búsqueda a lo ancho, y en
memoria solo guarda el camino actual, no la cola completa. A cambio, repite el
trabajo de los límites anteriores. `\+ memberchk(Siguiente, Camino)` evita los
ciclos dentro de un mismo camino. La prueba `iterativo` verifica que el plan es
el mismo de `plan/3`.

La actividad de la [sección 22.10](index.md#2210-un-estado-como-termino-el-mundo-de-bloques)
cuenta dos sucesores de `estado([[c, a], [b]], vacia)`, `tomar(c)` y
`tomar(b)`: con la mano vacía, solo se cumple la primera cláusula de
`sucesor/3`; `soltar` y `apilar` exigen que la mano sostenga un bloque, y
ambas cláusulas empiezan con `B \== vacia`. La prueba `sucesores` de
`bloques.plt` enumera las dos acciones.

## 11

<!-- ejemplo: capitulo-22/soluciones_bloques.pl predicado: plan_contando/4 contando/5 consulta: plan_contando(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia), P, N). -->
```prolog
%!  plan_contando(+Inicial, +Meta, -Plan:list, -Visitados:integer) is semidet.
%
%   Como plan/3; Visitados es la cantidad de estados que la búsqueda encoló
%   hasta encontrar la meta.
plan_contando(Inicial, Meta, Plan, Visitados) :-
    normalizar(Inicial, I),
    normalizar(Meta, M),
    contando([I-[]], [I], M, Invertido, Visitados),
    reverse(Invertido, Plan).

%!  contando(+Cola, +Visitados, +Meta, -Camino, -Cantidad) is semidet.
%
%   Como a_lo_ancho/4; Cantidad es el tamaño del conjunto de visitados al
%   encontrar la meta.
contando([Estado-Camino|Cola], Visitados, Meta, Plan, Cantidad) :-
    (   Estado == Meta
    ->  Plan = Camino,
        length(Visitados, Cantidad)
    ;   findall(S-[A|Camino],
                ( sucesor(Estado, A, S),
                  \+ ord_memberchk(S, Visitados) ),
                Nuevos0),
        sort(1, @<, Nuevos0, Nuevos),
        pairs_keys(Nuevos, Estados),
        ord_union(Visitados, Estados, Visitados1),
        append(Cola, Nuevos, Cola1),
        contando(Cola1, Visitados1, Meta, Plan, Cantidad)
    ).
```

```prolog
?- plan_contando(estado([[c, a], [b]], vacia), estado([[a, b, c]], vacia), P, N).
P = [tomar(c), soltar(c), tomar(b), apilar(b, c), tomar(a), apilar(a, b)],
N = 22.
```

La búsqueda encoló 22 estados distintos antes de llegar a la meta. Sin el
conjunto de visitados, los ciclos de tomar y soltar el mismo bloque harían
crecer la cola sin límite.

## 12

<!-- ejemplo: capitulo-22/soluciones_buscaminas.pl predicado: descubrir/4 consulta: tablero(3, 4, [1-1, 2-3], T), descubrir(T, 3-1, [], D). -->
```prolog
%!  descubrir(+Tablero, +Celda:pair, +Vistas:list, -Descubiertas:list) is det.
%
%   Descubiertas son las celdas de Vistas más las que descubre un clic en
%   Celda, que no tiene mina: la celda y, si su valor es 0, las que
%   descubren sus vecinas.
descubrir(Tablero, Celda, Vistas, Descubiertas) :-
    Tablero = tablero(Filas, Columnas, _),
    (   memberchk(Celda, Vistas)
    ->  Descubiertas = Vistas
    ;   valor(Tablero, Celda, 0)
    ->  findall(V, vecina(Filas, Columnas, Celda, V), Vecinas),
        foldl(descubrir(Tablero), Vecinas, [Celda|Vistas], Descubiertas)
    ;   Descubiertas = [Celda|Vistas]
    ).
```

```prolog
?- tablero(3, 4, [1-1, 2-3], T), descubrir(T, 3-1, [], D), msort(D, S).
T = tablero(3, 4, t(2-3, mina, -, t(1-4, 1, -, t(1-2, 2, -, t(1-1, mina, -, t, t), t(1-3, 1, -, t, t)), t(2-2, 2, <, t(2-1, 1, -, t, t), t)), t(3-2, 1, -, t(3-1, 0, <, t(2-4, 1, -, t, t), t), t(3-4, 1, <, t(3-3, 1, -, t, t), t)))),
D = [3-2, 2-2, 2-1, 3-1],
S = [2-1, 2-2, 3-1, 3-2].
```

Es el `descubrir/3` del [capítulo 18](../capitulo-18-orden-superior/index.md) con el tablero como argumento: el
valor de cada celda sale de `valor/3` en lugar de contarse con
`minas_alrededor/3`. (3, 1) no tiene minas vecinas, y descubre sus tres vecinas,
que sí las tienen.

## 13

<!-- ejemplo: capitulo-22/soluciones_buscaminas.pl predicado: tablero_desde_texto/2 valor_de_caracter/2 consulta: tablero_desde_texto(["*211", "12*1", "0111"], T), valor(T, 2-2, V). -->
```prolog
%!  tablero_desde_texto(+Lineas:list(string), -Tablero) is det.
%
%   Tablero es el tablero que mostrar/1 escribe como Lineas: una cadena por
%   fila, con * en las minas y el número de minas vecinas en las demás.
tablero_desde_texto(Lineas, tablero(Filas, Columnas, Celdas)) :-
    length(Lineas, Filas),
    Lineas = [Primera|_],
    string_length(Primera, Columnas),
    findall((F-C)-Valor,
            ( nth1(F, Lineas, Linea),
              string_chars(Linea, Caracteres),
              nth1(C, Caracteres, Caracter),
              valor_de_caracter(Caracter, Valor) ),
            Pares),
    list_to_assoc(Pares, Celdas).

%!  valor_de_caracter(+Caracter, -Valor) is det.
%
%   Valor es mina para *, o el número que escribe el dígito Caracter.
valor_de_caracter('*', mina) :-
    !.
valor_de_caracter(Caracter, N) :-
    atom_number(Caracter, N).
```

La prueba `mismo_tablero` verifica que el tablero leído del texto es idéntico,
con `==`, al que construye `tablero/4` con las mismas minas: la tabla de
búsqueda tiene los mismos pares, y `list_to_assoc/2` construye el mismo árbol a
partir de las mismas claves. `desde_texto` hace la ida y vuelta con
`mostrar/1`. La cantidad de columnas es la longitud de la primera línea, que
`string_length/2` da en caracteres.

## 14

<!-- ejemplo: capitulo-22/soluciones_proyecto.pl predicado: ranking_de_carrera/2 consulta: ranking_de_carrera(sistemas, R). -->
```prolog
%!  ranking_de_carrera(+Carrera:atom, -Ranking:list(pair)) is det.
%
%   Ranking es el ranking de los alumnos de Carrera, de mayor a menor
%   promedio.
ranking_de_carrera(Carrera, Ranking) :-
    ranking(Todos),
    include({Carrera}/[L-_]>>alumno(L, _, Carrera, _), Todos, Ranking).
```

```prolog
?- ranking_de_carrera(sistemas, R).
R = [101-8.5, 104-8, 102-4].
```

Filtrar el ranking general conserva su orden: no hace falta volver a ordenar.
La lambda comparte `Carrera` con la cláusula, entre llaves, como exige el
[capítulo 18](../capitulo-18-orden-superior/index.md).

## 15

<!-- ejemplo: capitulo-22/soluciones_proyecto.pl predicado: indice_por_materia/1 alumnos_en_comun/4 alumnos_de_materia/3 consulta: indice_por_materia(I), alumnos_en_comun(I, am1, log, L). -->
```prolog
%!  indice_por_materia(-Indice) is det.
%
%   Indice es un assoc de cada materia con inscriptos al conjunto ordenado
%   de sus legajos.
indice_por_materia(Indice) :-
    findall(M-L, inscripcion(L, M, _), Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    maplist([M-Ls, M-Conjunto]>>list_to_ord_set(Ls, Conjunto), Grupos,
            Conjuntos),
    list_to_assoc(Conjuntos, Indice).

%!  alumnos_en_comun(+Indice, +M1:atom, +M2:atom, -Legajos:list) is det.
%
%   Legajos son los alumnos inscriptos en M1 y en M2, en orden.
alumnos_en_comun(Indice, M1, M2, Legajos) :-
    alumnos_de_materia(Indice, M1, A),
    alumnos_de_materia(Indice, M2, B),
    ord_intersection(A, B, Legajos).

%!  alumnos_de_materia(+Indice, +Materia:atom, -Legajos:list) is det.
%
%   Legajos son los alumnos de Materia en Indice; el conjunto vacío si no
%   tiene inscriptos.
alumnos_de_materia(Indice, Materia, Legajos) :-
    (   get_assoc(Materia, Indice, Encontrados)
    ->  Legajos = Encontrados
    ;   Legajos = []
    ).
```

La consulta con el índice imprime también el assoc entero; lo que interesa es
`L`, los alumnos inscriptos en las dos materias:

```prolog
?- indice_por_materia(I), alumnos_en_comun(I, am1, log, L).
I = t(am2, [101, 103], -, t(am1, [101, 102, 103, 105, 106], <, t(alg, [101, 102, 103, 104], -, t, t), t), t(pp, [101, 104], <, t(log, [101, 102, 104, 106], -, t, t), t)),
L = [101, 102, 106].
```

Cada valor del índice es un conjunto ordenado, y
`ord_intersection/3` los recorre una sola vez, a la par.

## 16

En `soluciones.pl`, la versión del enunciado se llama `insertar_mal/3`:

<!-- ejemplo: capitulo-22/soluciones.pl predicado: insertar_mal/3 consulta: insertar_mal(5, n(vacio, 7, vacio), A). -->
```prolog
%!  insertar_mal(+Clave, +Arbol0, -Arbol) is det.
%
%   Arbol es Arbol0 con Clave agregada. Versión incorrecta, la del
%   enunciado: las cláusulas recursivas devuelven el árbol del subárbol, sin
%   el nodo que lo contiene, y la última no liga Arbol.
insertar_mal(Clave, vacio, n(vacio, Clave, vacio)).
insertar_mal(Clave, n(Izq, Clave0, _), Arbol) :-
    Clave @< Clave0,
    insertar_mal(Clave, Izq, Arbol).
insertar_mal(Clave, n(_, Clave0, Der), Arbol) :-
    Clave @> Clave0,
    insertar_mal(Clave, Der, Arbol).
insertar_mal(Clave, n(_, Clave, _), _).
```

```prolog
?- insertar_mal(5, n(vacio, 7, vacio), A).
A = n(vacio, 5, vacio) ;
false.

?- insertar_mal(7, n(vacio, 7, vacio), A).
true.
```

La primera respuesta perdió la raíz 7: el árbol resultante tiene solo la clave
nueva. La segunda deja `A` libre. Cada cláusula pone en el tercer argumento
algo distinto de lo que promete el encabezado:

- la primera, un nodo nuevo con la clave: es la única correcta;
- la segunda y la tercera, el resultado de insertar en un subárbol, **sin el
  nodo que lo contiene**: la raíz, el otro subárbol y todo lo que queda por
  encima del lugar de inserción se pierden;
- la cuarta, una variable anónima: no construye ningún árbol, y el árbol de
  la clave que ya estaba no se devuelve.

La causa común es suponer que insertar modifica el árbol que se recibe. Un
árbol es un término, y un término no cambia: el árbol con la clave agregada es
un término nuevo, y cada cláusula tiene que construirlo entero. La corrección
reconstruye el nodo de cada nivel con el subárbol que cambió y conserva el
otro:

<!-- ejemplo: capitulo-22/soluciones.pl predicado: insertar/3 insertar_en/3 insertar_segun/4 consulta: foldl(insertar, [7, 3, 9, 1, 5], vacio, A). -->
```prolog
%!  insertar(+Clave, +Arbol0, -Arbol) is det.
%
%   Arbol es el árbol de búsqueda Arbol0 con Clave agregada; si Clave ya
%   está, Arbol es igual a Arbol0. El árbol es vacio o n(Izq, Clave, Der).
insertar(Clave, Arbol0, Arbol) :-
    insertar_en(Arbol0, Clave, Arbol).

%!  insertar_en(+Arbol0, +Clave, -Arbol) is det.
%
%   El recorrido de insertar/3, con el árbol como primer argumento para que
%   la indexación distinga vacio de n/3.
insertar_en(vacio, Clave, n(vacio, Clave, vacio)).
insertar_en(n(Izq, Clave0, Der), Clave, Arbol) :-
    compare(Orden, Clave, Clave0),
    insertar_segun(Orden, Clave, n(Izq, Clave0, Der), Arbol).

%!  insertar_segun(+Orden, +Clave, +Nodo, -Arbol) is det.
%
%   Arbol es Nodo con Clave agregada, según el Orden de Clave respecto de la
%   clave de Nodo: un nodo nuevo con el subárbol que cambió, o el mismo Nodo
%   si la clave ya está.
insertar_segun(<, Clave, n(Izq, Clave0, Der), n(Izq1, Clave0, Der)) :-
    insertar_en(Izq, Clave, Izq1).
insertar_segun(=, _, Nodo, Nodo).
insertar_segun(>, Clave, n(Izq, Clave0, Der), n(Izq, Clave0, Der1)) :-
    insertar_en(Der, Clave, Der1).
```

```prolog
?- insertar(5, n(vacio, 7, vacio), A).
A = n(n(vacio, 5, vacio), 7, vacio).

?- insertar(7, n(vacio, 7, vacio), A).
A = n(vacio, 7, vacio).

?- foldl(insertar, [7, 3, 9, 1, 5], vacio, A).
A = n(n(n(vacio, 1, vacio), 3, n(vacio, 5, vacio)), 7, n(vacio, 9, vacio)).
```

`compare/3` da el orden de la clave respecto de la del nodo una sola vez, y
`insertar_segun/4` elige la cláusula por ese orden: las tres son mutuamente
excluyentes y la indexación por el primer argumento no deja alternativas.
`insertar_en/3` lleva el árbol como primer argumento, por la misma razón que
`cada_uno_/2` en el [capítulo 18](../capitulo-18-orden-superior/index.md): con la clave primero, las dos cláusulas
tendrían una variable en ese lugar y la búsqueda de la clave 5 quedaría con
una alternativa pendiente.

Una inserción construye un nodo nuevo por cada nodo del camino de la raíz al
lugar de la clave, más la hoja nueva: si ese lugar está a profundidad d, d + 1
nodos. Al insertar 4 en el árbol de la última consulta se construyen cuatro
nodos, copias de 7, 3 y 5 y la hoja de 4; el subárbol de 9 y el de 1 no se
copian: el árbol nuevo los comparte con el anterior, y la prueba
`insertar_comparte` lo verifica con `same_term/2`, que se cumple solo si los
dos argumentos son el mismo término en memoria. Insertar una clave que ya
está copia el camino hasta ella y da un árbol igual, con `==`, al anterior
(prueba `reinsertar_da_el_mismo_arbol`). Es lo que la
[sección 22.5](index.md#225-libraryassoc-y-libraryrbtrees) dice de `put_assoc/4`: el assoc nuevo comparte con el
anterior todo lo que no cambió, y el anterior sigue disponible sin cambios.
