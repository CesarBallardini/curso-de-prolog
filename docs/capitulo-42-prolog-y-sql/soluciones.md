# Soluciones del capítulo 42 — Prolog y SQL

El código de esta página está en `ejemplos/capitulo-42/`: `soluciones.pl`
para los ejercicios 3 a 10 y 12 a 14, que carga `universidad.pl` y
`recursion.pl` y tiene sus pruebas. Los ejercicios 1, 2 y 11 se resuelven
con consultas sobre esos dos archivos. Cada sentencia SQL se ejecutó en
SQLite sobre `references/ejercicios/sql-prolog/schema.sql`, y cada prueba de
`soluciones.plt` compara el resultado de Prolog con el de SQLite.

## 1

```text
nombre    carrera     ingreso
--------  ----------  -------
bruno     sistemas    2024
diego     sistemas    2024
facundo   industrial  2024
gabriela  industrial  2025
```

<!-- ejemplo: capitulo-42/universidad.pl predicado: alumno/4 -->
```prolog
% alumno(Legajo, Nombre, Carrera, Ingreso): la tabla alumnos.
alumno(101, ana,      sistemas,   2023).
alumno(102, bruno,    sistemas,   2024).
alumno(103, carla,    civil,      2023).
alumno(104, diego,    sistemas,   2024).
alumno(105, elena,    civil,      2025).
alumno(106, facundo,  industrial, 2024).
alumno(107, gabriela, industrial, 2025).
```

```prolog
?- alumno(_, N, C, I), I >= 2024, C \== civil.
N = bruno,
C = sistemas,
I = 2024 ;
N = diego,
C = sistemas,
I = 2024 ;
N = facundo,
C = industrial,
I = 2024 ;
N = gabriela,
C = industrial,
I = 2025.
```

Las dos dan las mismas cuatro filas. `<>` es `\==`, porque la carrera
llega siempre ligada; `I >= 2024` compara después de que `alumno/4` liga
`I`, como exige la aritmética.

## 2

La primera da siete filas, con `sistemas` tres veces, `civil` dos e
`industrial` dos: una por alumno. La segunda da tres, ordenadas. En Prolog,
la primera es la consulta directa, que responde una vez por hecho, y la
segunda es `setof/3` con las otras columnas cuantificadas:

```prolog
?- aggregate_all(count, alumno(_, _, _, _), K).
K = 7.

?- setof(C, L^N^I^alumno(L, N, C, I), Cs).
Cs = [civil, industrial, sistemas].
```

Sin `L^N^I^`, `setof/3` agruparía por esas variables y daría una lista de
un elemento por cada alumno.

## 3

<!-- ejemplo: capitulo-42/soluciones.pl predicado: aprobada_con_nombres/3 -->
```prolog
%!  aprobada_con_nombres(?Alumno, ?Materia, ?Nota) is nondet.
%
%   El alumno de nombre Alumno aprobó la materia de nombre Materia con
%   Nota: la reunión de tres tablas.
aprobada_con_nombres(Alumno, Materia, Nota) :-
    inscripcion(L, M, Nota),
    integer(Nota),
    Nota >= 6,
    alumno(L, Alumno, _, _),
    materia(M, Materia, _).
```

```prolog
?- aggregate_all(count, aprobada_con_nombres(_, _, _), K).
K = 10.
```

SQLite da las mismas diez filas, de ana con analisis_1 y nota 8 a facundo
con analisis_1 y nota 6. Sin `integer(Nota)`, la primera inscripción con
`null` hace que `Nota >= 6` lance un error, porque `null` no es una
expresión aritmética:

```text
?- aggregate_all(count, (inscripcion(_, _, N), N >= 6), K).
ERROR: Arithmetic: `null/0' is not a function
```

SQL no tiene ese problema: `NULL >= 6` es desconocido, y `WHERE` descarta
la fila. En Prolog, la pregunta por el tipo hace lo mismo explícitamente.

## 4

```sql
SELECT a1.nombre, a2.nombre, a1.carrera
FROM alumnos a1 JOIN alumnos a2
  ON a1.carrera = a2.carrera AND a1.legajo < a2.legajo;
```

<!-- ejemplo: capitulo-42/soluciones.pl predicado: misma_carrera/3 -->
```prolog
%!  misma_carrera(?Nombre1, ?Nombre2, ?Carrera) is nondet.
%
%   Dos alumnos distintos de la misma Carrera, cada par una vez.
misma_carrera(Nombre1, Nombre2, Carrera) :-
    alumno(L1, Nombre1, Carrera, _),
    alumno(L2, Nombre2, Carrera, _),
    L1 < L2.
```

Las dos dan cinco pares: ana–bruno, ana–diego y bruno–diego en sistemas,
carla–elena en civil y facundo–gabriela en industrial. Con `<>` y con
`\==`, cada par aparece dos veces, una en cada orden: diez filas en los dos
lenguajes. `<` elige un orden y deja una sola.

## 5

`UNION` da seis legajos, 101 a 106; `UNION ALL`, nueve filas: los cinco
inscriptos en am1 más los cuatro inscriptos en log, con 101, 102 y 106 dos
veces.

<!-- ejemplo: capitulo-42/soluciones.pl predicado: en_am1_o_log/1 -->
```prolog
%!  en_am1_o_log(?Legajo) is nondet.
%
%   El alumno de Legajo está inscripto en am1 o en log: una respuesta por
%   inscripción, como UNION ALL.
en_am1_o_log(Legajo) :-
    inscripcion(Legajo, am1, _).
en_am1_o_log(Legajo) :-
    inscripcion(Legajo, log, _).
```

```prolog
?- aggregate_all(count, en_am1_o_log(_), K).
K = 9.

?- setof(L, en_am1_o_log(L), Ls).
Ls = [101, 102, 103, 104, 105, 106].
```

Las dos cláusulas son el `UNION ALL`; `setof/3` las convierte en el
`UNION`, que además ordena.

## 6

```sql
SELECT a.legajo, a.nombre FROM alumnos a
WHERE NOT EXISTS (SELECT * FROM inscripciones i
                  WHERE i.legajo = a.legajo);
```

<!-- ejemplo: capitulo-42/soluciones.pl predicado: sin_inscripciones/2 -->
```prolog
%!  sin_inscripciones(?Legajo, ?Nombre) is nondet.
%
%   El alumno de Legajo no tiene ninguna inscripción. alumno/4 liga Legajo
%   antes de la negación.
sin_inscripciones(Legajo, Nombre) :-
    alumno(Legajo, Nombre, _, _),
    \+ inscripcion(Legajo, _, _).
```

```prolog
?- sin_inscripciones(L, N).
L = 107,
N = gabriela.

?- \+ inscripcion(L, _, _), alumno(L, N, _, _).
false.
```

En el orden inverso, `\+ inscripcion(L, _, _)` recibe `L` libre y pregunta
si no se puede probar que alguien tenga una inscripción; como hay
inscripciones, falla, y la consulta no da ninguna respuesta. En SQL el
orden no importa: la subconsulta de `NOT EXISTS` se evalúa para cada fila
de `alumnos`, con `a.legajo` ya fijo.

## 7

```sql
SELECT a.legajo, a.nombre FROM alumnos a
WHERE NOT EXISTS (
    SELECT * FROM materias m
    WHERE m.anio = 1
      AND NOT EXISTS (SELECT * FROM inscripciones i
                      WHERE i.legajo = a.legajo
                        AND i.materia = m.codigo
                        AND i.nota >= 6));
```

<!-- ejemplo: capitulo-42/soluciones.pl predicado: aprobo_primer_anio/2 -->
```prolog
%!  aprobo_primer_anio(?Legajo, ?Nombre) is nondet.
%
%   El alumno de Legajo aprobó todas las materias de primer año.
aprobo_primer_anio(Legajo, Nombre) :-
    alumno(Legajo, Nombre, _, _),
    forall(materia(M, _, 1), aprobada(Legajo, M, _)).
```

```prolog
?- aprobo_primer_anio(L, N).
L = 101,
N = ana ;
false.
```

Solo ana aprobó am1, alg y log. SQL no tiene un cuantificador universal, y
lo escribe como «no existe una materia de primer año que no haya
aprobado»: dos negaciones. `forall(C, A)` es exactamente
`\+ (C, \+ A)`, la misma doble negación, y el nombre dice lo que significa.

## 8

```text
legajo  AVG(nota)
------  ---------
101     8.5
102     4.0
103     6.0
104     8.0
105     NULL
106     4.5
```

<!-- ejemplo: capitulo-42/soluciones.pl predicado: promedio_alumno/2 -->
```prolog
%!  promedio_alumno(?Legajo, ?Promedio) is nondet.
%
%   Promedio de las notas del alumno de Legajo, sin las filas con null.
%   Un alumno sin ninguna nota no tiene promedio.
promedio_alumno(Legajo, Promedio) :-
    bagof(N, M^(inscripcion(Legajo, M, N), integer(N)), Notas),
    sum_list(Notas, Suma),
    length(Notas, Cantidad),
    Promedio is Suma / Cantidad.
```

```prolog
?- findall(L-P, promedio_alumno(L, P), Ps).
Ps = [101-8.5, 102-4, 103-6, 104-8, 106-4.5].
```

El alumno 105 tiene una sola inscripción, sin nota. SQL forma su grupo, y
`AVG` de ninguna nota es `NULL`. En Prolog, `bagof/3` no encuentra ninguna
nota para 105 y no forma el grupo: el alumno no aparece. Para dar una
respuesta por alumno, habría que recorrer `alumno/4` y decidir qué valor
representa «sin promedio».

## 9

```sql
SELECT i.legajo, i.materia, c.requisito
FROM inscripciones i JOIN correlativas c ON c.materia = i.materia
WHERE NOT EXISTS (SELECT * FROM inscripciones r
                  WHERE r.legajo = i.legajo
                    AND r.materia = c.requisito
                    AND r.nota >= 6);
```

<!-- ejemplo: capitulo-42/soluciones.pl predicado: correlativa_pendiente/3 -->
```prolog
%!  correlativa_pendiente(?Legajo, ?Materia, ?Requisito) is nondet.
%
%   El alumno de Legajo está inscripto en Materia sin haber aprobado
%   Requisito, una de sus correlativas.
correlativa_pendiente(Legajo, Materia, Requisito) :-
    inscripcion(Legajo, Materia, _),
    correlativa(Materia, Requisito),
    \+ aprobada(Legajo, Requisito, _).
```

```prolog
?- correlativa_pendiente(L, M, R).
L = 103,
M = am2,
R = alg ;
false.
```

Los datos no la cumplen: carla cursa analisis_2 con algebra desaprobada
(nota 5). Un `CHECK` de SQL examina una sola fila, y esta restricción examina
otras filas de otras tablas: en SQL se verifica con un disparador o con
una consulta como esta. En Prolog es una cláusula más de las violaciones,
y `insertar/1` podría consultarla antes de agregar una inscripción.

## 10

`jefe <> 1` da cinco filas: pablo, sofia, tomas, valeria y nicolas. La
consulta Prolog da seis, marta incluida:

```prolog
?- findall(N, (empleado(_, N, _, _, J), J \== 1), Ns).
Ns = [marta, pablo, sofia, tomas, valeria, nicolas].
```

El jefe de marta es `NULL`. En SQL, `NULL <> 1` es desconocido y la fila se
descarta; en Prolog, `null \== 1` es verdadero. Para dar lo mismo que SQL,
se descarta `null` antes de comparar:

<!-- ejemplo: capitulo-42/soluciones.pl predicado: no_depende_de/2 -->
```prolog
%!  no_depende_de(?Nombre, +Jefe) is nondet.
%
%   El empleado Nombre tiene un jefe directo y no es Jefe, como en SQL,
%   donde jefe <> 1 no es verdadero cuando jefe es NULL.
no_depende_de(Nombre, Jefe) :-
    empleado(_, Nombre, _, _, J),
    J \== null,
    J \== Jefe.
```

```prolog
?- findall(N, no_depende_de(N, 1), Ns).
Ns = [pablo, sofia, tomas, valeria, nicolas].
```

Si lo buscado es «todos los que no dependen de 1, incluidos los que no
tienen jefe», la consulta Prolog original es la correcta, y en SQL hace
falta `WHERE jefe IS NULL OR jefe <> 1`, que da seis filas.

## 11

El `COUNT(*)` da una fila con 0; con `GROUP BY carrera` no hay ningún
grupo y no hay filas; `SUM` y `MAX` sobre ninguna fila dan `NULL` los dos.
En Prolog:

```prolog
?- aggregate_all(count, alumno(_, _, quimica, _), K).
K = 0.

?- bagof(L, N^I^alumno(L, N, quimica, I), Ls).
false.

?- aggregate_all(sum(S), empleado(_, _, legal, S, _), T).
T = 0.

?- aggregate_all(max(S), empleado(_, _, legal, S, _), M).
false.
```

`count` y el agrupamiento coinciden con SQL. La suma de nada es 0 en
Prolog y `NULL` en SQL, y el máximo de nada no existe: Prolog falla, y SQL
responde `NULL`. Un programa que traduce consultas de un lenguaje al otro
tiene que tratar esos dos casos aparte.

## 12

```sql
WITH RECURSIVE nivel(id, k) AS (
    SELECT id, 0 FROM empleados WHERE jefe IS NULL
  UNION ALL
    SELECT e.id, n.k + 1 FROM empleados e JOIN nivel n ON e.jefe = n.id
)
SELECT e.nombre, n.k FROM nivel n JOIN empleados e ON e.id = n.id
ORDER BY n.k, e.nombre;
```

<!-- ejemplo: capitulo-42/soluciones.pl predicado: nivel/2 -->
```prolog
%!  nivel(?Id, ?Nivel) is nondet.
%
%   Nivel es la cantidad de jefes que hay entre el empleado Id y la
%   directora, que tiene nivel 0.
nivel(Id, 0) :-
    empleado(Id, _, _, _, null).
nivel(Id, Nivel) :-
    jefe(Id, Jefe),
    nivel(Jefe, Nivel0),
    Nivel is Nivel0 + 1.
```

```prolog
?- findall(K-N, (nivel(Id, K), empleado(Id, N, _, _, _)), Ps), msort(Ps, Ordenados).
Ps = [0-marta, 1-jorge, 1-lucia, 1-irene, 2-pablo, 2-sofia, 2-tomas, 2-valeria, 3-nicolas],
Ordenados = [0-marta, 1-irene, 1-jorge, 1-lucia, 2-pablo, 2-sofia, 2-tomas, 2-valeria, 3-nicolas].
```

Los dos dan marta en 0; irene, jorge y lucia en 1; pablo, sofia, tomas y
valeria en 2; nicolas en 3. La consulta SQL baja desde la directora; la
regla sube desde el empleado hasta ella. `UNION ALL` basta porque la
jerarquía es un árbol: cada empleado se alcanza por un único camino.

## 13

```sql
WITH RECURSIVE viaje(destino, precio, tramos) AS (
    SELECT destino, precio, 1 FROM vuelos WHERE origen = 'ros'
  UNION
    SELECT v.destino, t.precio + v.precio, t.tramos + 1
    FROM vuelos v JOIN viaje t ON v.origen = t.destino
    WHERE t.tramos < (SELECT COUNT(*) FROM vuelos)
)
SELECT destino, MIN(precio) FROM viaje
GROUP BY destino ORDER BY destino;
```

```text
destino  MIN(precio)
-------  -----------
aep      50
brc      160
cor      120
mdz      140
sla      200
ush      200
```

La cota se justifica así: los precios son positivos, de modo que el viaje
más barato a un destino nunca pasa dos veces por el mismo aeropuerto (la
vuelta al ciclo solo suma), y un viaje sin repeticiones tiene menos vuelos
que aeropuertos hay. Cualquier cota mayor o igual sirve; la cantidad de
vuelos, diez, es una que SQL calcula sin conocer los aeropuertos. En
Prolog, la misma idea sin tabla, con la cantidad de aeropuertos, ocho:

<!-- ejemplo: capitulo-42/soluciones.pl predicado: viaje/4 tarifa_con_tope/3 aeropuerto/1 aparece/1 -->
```prolog
%!  viaje(+Origen, ?Destino, -Precio, +Tope) is nondet.
%
%   Precio es el precio de un viaje de Origen a Destino de a lo sumo Tope
%   vuelos, sin tabla: la cota hace terminar la recursión, como el
%   contador de tramos de la consulta SQL.
viaje(Origen, Destino, Precio, _) :-
    vuelo(Origen, Destino, _, Precio).
viaje(Origen, Destino, Precio, Tope) :-
    Tope > 1,
    vuelo(Origen, Escala, _, P1),
    Tope1 is Tope - 1,
    viaje(Escala, Destino, P2, Tope1),
    Precio is P1 + P2.

%!  tarifa_con_tope(+Origen, ?Destino, -Precio) is nondet.
%
%   El menor precio de cada destino entre los viajes de a lo sumo tantos
%   vuelos como aeropuertos hay.
tarifa_con_tope(Origen, Destino, Precio) :-
    aggregate_all(count, aeropuerto(_), Tope),
    setof(D, P^viaje(Origen, D, P, Tope), Destinos),
    member(Destino, Destinos),
    aggregate_all(min(P), viaje(Origen, Destino, P, Tope), Precio).

%!  aeropuerto(?A) is nondet.
%
%   A es origen o destino de algún vuelo, una vez cada uno.
aeropuerto(A) :-
    setof(X, aparece(X), As),
    member(A, As).

%!  aparece(?A) is nondet.
%
%   A es origen o destino de un vuelo, una vez por cada vuelo.
aparece(A) :-
    vuelo(A, _, _, _).
aparece(A) :-
    vuelo(_, A, _, _).
```

```prolog
?- findall(D-P, tarifa_con_tope(ros, D, P), Ts).
Ts = [aep-50, brc-160, cor-120, mdz-140, sla-200, ush-200].
```

Da los mismos mínimos que `tarifa/3`, y la prueba `ej13_como_tabla` lo
comprueba. La diferencia está en el trabajo: la versión acotada enumera
todos los viajes de hasta ocho vuelos, con sus vueltas al ciclo, y después
elige el mínimo; la tabla con `min` descarta un precio en cuanto no mejora
el guardado.

## 14

<!-- ejemplo: capitulo-42/soluciones.pl predicado: aumentar/2 -->
```prolog
%!  aumentar(+Depto, +Porcentaje) is det.
%
%   Aumenta en Porcentaje el salario de cada empleado de Depto, con
%   división entera como en SQL.
aumentar(Depto, Porcentaje) :-
    forall(retract(empleado(Id, Nombre, Depto, Salario, Jefe)),
           ( Nuevo is Salario * (100 + Porcentaje) // 100,
             assertz(empleado(Id, Nombre, Depto, Nuevo, Jefe)) )).
```

```prolog
?- aumentar(it, 10), findall(Id-S, empleado(Id, _, it, S, _), Ss).
Ss = [3-715000, 6-462000, 7-495000, 8-330000].
```

Son los salarios que da el `UPDATE` en SQLite. Los hechos agregados no se
vuelven a aumentar por la vista lógica de actualización
([sección 20.3](../capitulo-20-base-de-datos-dinamica/index.md#203-la-vista-logica-de-actualizacion)): `retract/1` recorre las cláusulas que había
cuando empezó, y las que `assertz/1` agrega al final no están en ese
recorrido. SQL garantiza lo mismo: un `UPDATE` calcula cada fila nueva a
partir de la tabla anterior a la sentencia.
