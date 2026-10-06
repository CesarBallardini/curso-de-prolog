# Consultas recursivas

Esta página contiene la sección [42.5](index.md#425-consultas-recursivas-with-recursive-y-tablas) del
[capítulo 42](index.md): las consultas recursivas con `WITH RECURSIVE` y con
reglas tabuladas. Los ejemplos están en `recursion.pl`, en
`ejemplos/capitulo-42/`, con sus pruebas, y corren en SWISH.

## Consultas recursivas

Los superiores de un empleado son su jefe, el jefe de su jefe, y así hasta
la directora. `recursion.pl` guarda las tablas `empleados` y `vuelos`, y
define la relación con una regla recursiva:

<!-- ejemplo: capitulo-42/recursion.pl predicado: jefe/2 superior/2 -->
```prolog
%!  jefe(?Empleado, ?Jefe) is nondet.
%
%   Jefe es el jefe directo de Empleado: la columna jefe sin los null.
jefe(Empleado, Jefe) :-
    empleado(Empleado, _, _, _, Jefe),
    Jefe \== null.

%!  superior(?Empleado, ?Superior) is nondet.
%
%   Superior es el jefe de Empleado, o un superior de su jefe.
superior(Empleado, Superior) :-
    jefe(Empleado, Superior).
superior(Empleado, Superior) :-
    jefe(Empleado, Jefe),
    superior(Jefe, Superior).
```

SQL la escribe con una expresión de tabla común recursiva: una parte no
recursiva, `UNION`, y una parte recursiva que reúne la tabla que se está
definiendo con otra tabla.

```sql
WITH RECURSIVE superior(id) AS (
    SELECT jefe FROM empleados WHERE id = 8
  UNION
    SELECT e.jefe FROM empleados e JOIN superior s ON e.id = s.id
    WHERE e.jefe IS NOT NULL
)
SELECT e.id, e.nombre FROM superior s JOIN empleados e ON e.id = s.id;
```

```text
id  nombre
--  -------
7   valeria
3   lucia
1   marta
```

```prolog
?- superior(8, J).
J = 7 ;
J = 3 ;
J = 1 ;
false.
```

**Cómo evalúa SQL la recursión.** SQLite mantiene una tabla de trabajo con
las filas nuevas. La parte no recursiva la llena; después, en cada paso,
reúne con `empleados` solo las filas de la tabla de trabajo, agrega al
resultado las que no estaban (con `UNION`) y las pone como nueva tabla de
trabajo, hasta que un paso no agrega nada. Es la **evaluación
semi-ingenua** de la [sección 38.6](../capitulo-38-semantica-de-los-programas-logicos/index.md#386-evaluacion-de-abajo-hacia-arriba): cada paso usa solo lo derivado en el
paso anterior, y el cálculo termina en el punto fijo (Nilsson y
Małuszyński, capítulo «Query-answering in Deductive Databases»).
`iteraciones/2` la reproduce para los destinos que se alcanzan desde un
aeropuerto:

<!-- ejemplo: capitulo-42/recursion.pl predicado: iteraciones/2 iterar/3 -->
```prolog
%!  iteraciones(+Origen, -Iteraciones) is det.
%
%   Iteraciones es la lista de las filas nuevas de cada paso de una
%   evaluación de abajo hacia arriba de los destinos de Origen: el primer
%   paso es la parte no recursiva, y cada paso siguiente une con vuelos
%   solo las filas nuevas del anterior. Termina cuando un paso no agrega
%   nada.
iteraciones(Origen, [Base|Resto]) :-
    findall(D, vuelo(Origen, D, _, _), Ds),
    sort(Ds, Base),
    iterar(Base, Base, Resto).

%!  iterar(+Nuevas, +Vistas, -Iteraciones) is det.
%
%   Nuevas son las filas del último paso y Vistas todas las obtenidas,
%   ambas conjuntos ordenados.
iterar([], _, []).
iterar([N|Ns], Vistas, [Nuevas|Resto]) :-
    findall(D, ( member(X, [N|Ns]), vuelo(X, D, _, _) ), Ds),
    sort(Ds, Obtenidas),
    ord_subtract(Obtenidas, Vistas, Nuevas),
    ord_union(Vistas, Nuevas, Vistas1),
    iterar(Nuevas, Vistas1, Resto).
```

```prolog
?- iteraciones(aep, Is).
Is = [[brc, cor, mdz, ush], [aep, sla], []].
```

El primer paso son los vuelos directos desde aep; el segundo agrega aep y
sla, a los que se llega desde cor; el tercero no agrega nada, porque todo
lo que se alcanza desde aep y sla ya estaba. La consulta SQL equivalente
da los mismos seis aeropuertos:

```sql
WITH RECURSIVE destino(aeropuerto) AS (
    SELECT destino FROM vuelos WHERE origen = 'aep'
  UNION
    SELECT v.destino FROM vuelos v JOIN destino d ON v.origen = d.aeropuerto
)
SELECT aeropuerto FROM destino ORDER BY aeropuerto;
```

**Ciclos.** Los vuelos tienen un ciclo: aep → cor → aep. Con `UNION`, la
consulta termina porque una fila que ya está no vuelve a la tabla de
trabajo. Con `UNION ALL` no termina: cada vuelta al ciclo agrega las
mismas filas otra vez. Con `LIMIT 12` para verlo, la consulta con
`UNION ALL` da `brc, cor, mdz, ush, aep, mdz, sla, brc, brc, cor, mdz,
ush`. La regla recursiva de Prolog sin tabla se comporta como `UNION ALL`:

<!-- ejemplo: capitulo-42/recursion.pl predicado: destino_sin_tabla/2 -->
```prolog
%!  destino_sin_tabla(+Origen, -Destino) is nondet.
%
%   Destino se alcanza desde Origen con uno o más vuelos. Por el ciclo
%   entre aep y cor, repite respuestas sin fin.
destino_sin_tabla(Origen, Destino) :-
    vuelo(Origen, Destino, _, _).
destino_sin_tabla(Origen, Destino) :-
    vuelo(Origen, Escala, _, _),
    destino_sin_tabla(Escala, Destino).
```

```prolog
?- findall(D, limit(8, destino_sin_tabla(aep, D)), Ds).
Ds = [cor, mdz, brc, ush, aep, mdz, sla, cor].
```

La directiva `table` del [capítulo 39](../capitulo-39-tabulacion/index.md#391-table-recursion-a-la-izquierda-y-ciclos) da el comportamiento de `UNION`:
cada respuesta una vez, y la consulta termina.

<!-- ejemplo: capitulo-42/recursion.pl fragmento: :- table destino/2. .. vuelo(Escala, Destino, _, _). -->
```prolog
:- table destino/2.

%!  destino(?Origen, ?Destino) is nondet.
%
%   La misma relación, tabulada: cada destino una vez, y termina.
destino(Origen, Destino) :-
    vuelo(Origen, Destino, _, _).
destino(Origen, Destino) :-
    destino(Origen, Escala),
    vuelo(Escala, Destino, _, _).
```

```prolog
?- findall(D, destino(aep, D), Ds), msort(Ds, Ordenados).
Ds = [cor, aep, ush, brc, mdz, sla],
Ordenados = [aep, brc, cor, mdz, sla, ush].
```

La regla tabulada tiene la recursión a la izquierda, en el orden de la
consulta SQL, que reúne la tabla recursiva con `vuelos`. Sin tabla, esa
forma no termina ni siquiera sin ciclos: `superior_izq/2`, en
`recursion.pl`, da los tres superiores de nicolas y, al pedir otra
respuesta, se llama a sí misma hasta agotar la pila. La dirección de la
evaluación también difiere: SQL parte de la parte no recursiva y calcula
todo lo que se deriva de ella; la tabla parte de la consulta, y
`destino(O, sla)` calcula solo lo necesario para llegar a sla.

**Agregados en la recursión.** El precio más barato para llegar a cada
destino desde ros es un mínimo sobre caminos. SQLite no admite agregados
en la parte recursiva: con `MIN(t.precio + v.precio)` y `GROUP BY` la
consulta se rechaza con `recursive aggregate queries not supported`. Y sin
el agregado no termina, ni siquiera con `UNION`: cada vuelta al ciclo
produce una fila con un precio mayor, distinta de las anteriores, y la
consulta con `LIMIT 1000` devuelve mil filas. Una tabla con subsunción de
respuestas ([capítulo 39](../capitulo-39-tabulacion/subsuncion.md)) guarda solo el menor precio de cada destino,
así que el ciclo deja de agregar respuestas:

<!-- ejemplo: capitulo-42/recursion.pl fragmento: :- table tarifa(_, _, min). .. Precio is P1 + P2. -->
```prolog
:- table tarifa(_, _, min).

%!  tarifa(?Origen, ?Destino, -Precio) is nondet.
%
%   Precio es el menor precio de un viaje de Origen a Destino, con uno o
%   más vuelos. La tabla guarda solo el mínimo para cada par, así que el
%   ciclo no agrega respuestas: Precio debe llegar libre.
tarifa(Origen, Destino, Precio) :-
    vuelo(Origen, Destino, _, Precio).
tarifa(Origen, Destino, Precio) :-
    tarifa(Origen, Escala, P1),
    vuelo(Escala, Destino, _, P2),
    Precio is P1 + P2.
```

```prolog
?- findall(D-P, tarifa(ros, D, P), Ts), msort(Ts, Ordenadas).
Ts = [brc-160, mdz-140, sla-200, cor-120, aep-50, ush-200],
Ordenadas = [aep-50, brc-160, cor-120, mdz-140, sla-200, ush-200].
```

En SQL, la forma de terminar es acotar la recursión, por ejemplo con un
contador de vuelos, y calcular el mínimo afuera; el [ejercicio 13](index.md#ejercicios)
lo hace.

!!! question "Actividad"
    Predecir el resultado de `iteraciones(cor, Is)` y de
    `iteraciones(igr, Is)`: cuántos pasos da cada una y qué agrega cada
    paso. Comprobarlo, y escribir la consulta SQL con `UNION` que da el
    mismo conjunto de aeropuertos.
