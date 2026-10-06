# Las sentencias que cambian las tablas

Esta página contiene la [sección 86.9](index.md#869-version-7-las-sentencias-que-cambian-las-tablas) del
[capítulo 86](index.md): `CREATE TABLE`, `DROP TABLE`, `INSERT`, `DELETE` y `UPDATE` sobre la instantánea del estado anterior, y la conversación con que Kluźniak y Szpakowicz presentan Toy-Sequel. El código está en `modificaciones.pl` y `minisql.pl`, en `ejemplos/capitulo-86/`, con sus pruebas.

## Las sentencias que cambian las tablas

`modificaciones.pl` ejecuta `CREATE TABLE`, `DROP TABLE`, `INSERT`,
`DELETE` y `UPDATE`. `CREATE TABLE` agrega una relación al catálogo y
declara su predicado dinámico en el módulo `relaciones`; la clave
primaria y `NOT NULL` quedan como restricciones. Las otras tres
sentencias tienen la misma forma: calculan primero, sobre el estado
anterior, todas las filas que la tabla tendrá después; verifican sobre
ese resultado los tipos, `NOT NULL`, los rangos del
[capítulo 42](../capitulo-42-prolog-y-sql/restricciones.md#claves-restricciones-y-actualizaciones)
y la clave primaria; y solo entonces reemplazan las filas de la tabla,
en el orden en que estaban.

<!-- ejemplo: capitulo-86/modificaciones.pl predicado: actualizar/4 -->
```prolog
%!  actualizar(+T, +Asignaciones:list, +Condicion, -N:integer) is det.
%
%   Cambia en las N filas de T para las que Condicion es verdadera las
%   columnas de Asignaciones, cada una C-Expresion, calculadas con los
%   valores anteriores de la fila.
actualizar(T, Asignaciones, Condicion, N) :-
    filtro_tabla(T, Condicion, Generador, Pila, Filtro),
    Pila = [[marco(_, Columnas)]],
    variables(Columnas, Vs),
    asignar(Asignaciones, Pila, Vs, Nuevos, Calculos),
    conjuncion_lista(Calculos, Calculo),
    findall(Fila-Cambia,
            ( Generador,
              (   Filtro
              ->  Calculo,
                  Fila = Nuevos,
                  Cambia = si
              ;   Fila = Vs,
                  Cambia = no
              ) ),
            Pares),
    pairs_keys(Pares, Todas),
    pares_con(Pares, si, Cambiadas),
    length(Cambiadas, N),
    verificar(T, Columnas, Cambiadas, Todas),
    reemplazar(Generador, Todas).
```

Toy-Sequel actualiza cada tupla dentro del bucle de falla:
`retract(OldTup), assert(NewTup), fail`. Con la vista lógica de
actualización del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#203-la-vista-logica-de-actualizacion),
el recorrido no vuelve a ver las tuplas nuevas, pero una subconsulta de
la condición, que se ejecuta de nuevo en cada fila, ve la tabla a medio
cambiar ([ejercicio 5](index.md#ejercicios)). SQL exige que la sentencia entera
vea el estado anterior, y `findall/3` lo obtiene: junta todas las filas
nuevas antes de cambiar la primera. Si una fila no cumple una
restricción, la sentencia lanza el error antes de tocar la tabla, y no
cambia nada:

<!-- contexto: capitulo-86/minisql.pl -->
```prolog
?- sql("UPDATE alumnos SET ingreso = ingreso + 1 WHERE ingreso = (SELECT MIN(ingreso) FROM alumnos)", R), sql("SELECT nombre, ingreso FROM alumnos WHERE carrera <> 'industrial'", F).
R = actualizadas(2),
F = filas([nombre, ingreso], [[ana, 2024], [bruno, 2024], [carla, 2024], [diego, 2024], [elena, 2025]]).

?- catch(sql("INSERT INTO alumnos VALUES (108, 'hugo', 'civil', 2025), (109, NULL, 'civil', 2025)", R), E, true), sql("SELECT COUNT(*) FROM alumnos", F).
E = error(sql(nulo(alumnos, nombre)), _),
F = filas([count], [[7]]).

?- catch(sql("INSERT INTO inscripciones VALUES (107, 'log', 11)", R), E, true).
E = error(sql(rango(inscripciones, nota, 11)), _).
```

El segundo `INSERT` no agrega a Hugo, aunque su fila es correcta: la de
la otra fila nueva no lo es. Reemplazar la tabla entera cuesta un
recorrido por sentencia, que en tablas de este tamaño no importa; una
base de datos real lleva un registro de los cambios para deshacerlos.

La forma común de las tres sentencias es el patrón 100:

!!! example "Patrón 100 — Calcular el estado nuevo antes de cambiar"
    **Problema.** Una operación cambia muchos hechos de una base dinámica.
    Tiene que leer el estado como estaba antes de empezar, aunque sus
    condiciones consulten los mismos hechos que cambia, y tiene que
    cambiarlos todos o ninguno, aunque un hecho a mitad del recorrido no
    cumpla una restricción.

    **Versión ingenua.** Retirar y agregar cada hecho dentro del
    recorrido, `retract(Viejo), assertz(Nuevo), fail`, como Toy-Sequel. La
    vista lógica de actualización protege al recorrido, pero no a una
    subconsulta que se vuelve a ejecutar en cada fila y ve la tabla a
    medio cambiar; y un error en la fila diez deja cambiadas las nueve
    anteriores.

    **Patrón.** Calcular primero, con `findall/3` sobre el estado
    anterior, todas las filas que la tabla tendrá después (`actualizar/4`);
    verificar sobre ese resultado los tipos, `NOT NULL`, los rangos y la
    clave (`verificar/4`); y solo entonces reemplazar las filas de la
    tabla en un solo paso (`reemplazar/2`). Una restricción violada lanza
    el error antes de tocar la base. Es el
    [Patrón 86](../patrones.md#86-el-estado-como-valor-la-base-de-datos-como-capa)
    aplicado a una tabla: la relación entre el estado viejo y el nuevo es
    pura, y la base cambia en una sola meta al final.

    **Cuándo no usarlo.** Cuando la tabla es grande y la operación cambia
    pocas filas: reemplazar la tabla entera cuesta un recorrido por
    sentencia, y conviene cambiar solo esas filas y llevar un registro de
    los cambios para deshacerlos. Y cuando ninguna condición lee lo que la
    operación cambia y un error a mitad del camino no deja la base
    inconsistente, como al agregar hechos que no tienen restricciones
    entre sí: el bucle de falla es más simple y basta.

**La conversación de Toy-Sequel.** Kluźniak y Szpakowicz muestran su
lenguaje con una conversación: crean las tablas de empleados y
departamentos, insertan filas, preguntan quién gana al menos 1 000 fuera
del departamento 2, contratan a los dos jefes con una inserción desde un
`SELECT`, suben el sueldo de uno, despiden a otro, buscan a quien gana
más que su jefe, y dan a los que ganan más de 100 menos que su jefe la
mitad de la diferencia. `sesion/0` lee sentencias de la entrada hasta
`salir`, como el bucle `toysequel` del libro. La misma conversación, con
los datos en minúsculas:

```text
mini-SQL. Cada sentencia termina en ';'. «salir» termina.
CREATE TABLE empleados (nombre TEXT PRIMARY KEY, sueldo INTEGER NOT NULL,
                        depto INTEGER);
Relación empleados creada.
CREATE TABLE deptos (depto INTEGER PRIMARY KEY, jefe TEXT);
Relación deptos creada.
INSERT INTO empleados VALUES ('brown', 1000, 1), ('white', 800, 1),
  ('miller', 850, 1), ('barry', 900, 2), ('thomas', 850, 1),
  ('morgan', 1050, 1);
Filas insertadas: 6.
INSERT INTO deptos VALUES (1, 'jones'), (2, 'smith');
Filas insertadas: 2.
DESCRIBE empleados;
empleados: nombre texto no nulo, sueldo entero no nulo, depto entero
SELECT nombre, sueldo FROM empleados WHERE depto <> 2 AND sueldo >= 1000;
nombre  sueldo
------  ------
brown   1000
morgan  1050
INSERT INTO empleados SELECT jefe, 1000, depto FROM deptos;
Filas insertadas: 2.
UPDATE empleados SET sueldo = 1200 WHERE nombre = 'smith';
Filas actualizadas: 1.
DELETE FROM empleados WHERE nombre = 'barry';
Filas eliminadas: 1.
SELECT e.nombre FROM empleados e, deptos d, empleados j
  WHERE e.depto = d.depto AND d.jefe = j.nombre AND j.sueldo < e.sueldo;
nombre
------
morgan
UPDATE empleados
  SET sueldo = sueldo + ((SELECT j.sueldo FROM deptos d, empleados j
                          WHERE d.depto = empleados.depto
                            AND d.jefe = j.nombre) - sueldo) / 2
  WHERE sueldo + 100 < (SELECT j.sueldo FROM deptos d, empleados j
                        WHERE d.depto = empleados.depto
                          AND d.jefe = j.nombre);
Filas actualizadas: 3.
SELECT * FROM empleados;
nombre  sueldo  depto
------  ------  -----
brown   1000    1
white   900     1
miller  925     1
thomas  925     1
morgan  1050    1
jones   1000    1
smith   1200    2
SELECT nombre FROM empleados WHERE nombre < 'm' OR nombre >= 'n';
nombre
------
brown
white
thomas
jones
smith
INSERT INTO empleados VALUES ('brown', 900, 2);
Error: clave_repetida(empleados,[brown]).
salir
```

Los resultados son los del libro: Brown y Morgan ganan al menos 1 000,
Morgan gana más que su jefe, la actualización alcanza a tres empleados,
y cinco nombres no empiezan con m. Las diferencias de notación son las de
SQL: Toy-Sequel escribe `EMP_dno` donde SQL escribe `e.depto`, y
`Mgr = EMP` donde SQL escribe `empleados j`; su `update … using DEPT,
Mgr = EMP` se escribe con subconsultas correlacionadas, que nombran la
fila que se actualiza como `empleados.depto`. La prueba
`minisql:conversacion` ejecuta la conversación con `guion/2` y verifica
cada resultado.
