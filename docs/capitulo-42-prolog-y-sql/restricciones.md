# Claves, restricciones y actualizaciones

Esta página contiene la sección [42.6](index.md#426-claves-restricciones-y-actualizaciones) del
[capítulo 42](index.md): el esquema escrito como hechos, las restricciones
verificadas como consultas, y las actualizaciones que las respetan. Los
ejemplos están en `universidad.pl`, en `ejemplos/capitulo-42/`, con sus
pruebas, y corren en SWISH.

## Claves, restricciones y actualizaciones


`INSERT`, `DELETE` y `UPDATE` son `assertz/1` y `retract/1` sobre los
predicados dinámicos del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md); un `UPDATE` es un `retract/1`
seguido de un `assertz/1`. La diferencia está en lo que se verifica. SQLite
rechaza una fila que viola el esquema:

```sql
INSERT INTO alumnos VALUES (101, 'zoe', 'civil', 2025);
-- UNIQUE constraint failed: alumnos.legajo
INSERT INTO inscripciones VALUES (999, 'am1', NULL);
-- FOREIGN KEY constraint failed
INSERT INTO inscripciones VALUES (107, 'am1', 11);
-- CHECK constraint failed: nota BETWEEN 1 AND 10
```

`assertz(alumno(101, zoe, civil, 2025))` se acepta, y la base queda con dos
alumnos de legajo 101. Kluźniak y Szpakowicz lo resumen así: Prolog es, en
este sentido, demasiado poco restrictivo, y la integridad queda a cargo del
programa. Para verificarla, el esquema se escribe también como hechos:

<!-- ejemplo: capitulo-42/universidad.pl predicado: tabla/3 clave/2 referencia/4 admite_nulo/2 rango/4 -->
```prolog
% tabla(Tabla, Predicado, Columnas): la tabla SQL Tabla se guarda en
% Predicado, con una columna Nombre-Tipo por argumento y en ese orden.
tabla(alumnos,       alumno,      [legajo-entero, nombre-texto,
                                   carrera-texto, ingreso-entero]).
tabla(materias,      materia,     [codigo-texto, nombre-texto, anio-entero]).
tabla(correlativas,  correlativa, [materia-texto, requisito-texto]).
tabla(inscripciones, inscripcion, [legajo-entero, materia-texto,
                                   nota-entero]).

% clave(Tabla, Columnas): Columnas forman la clave primaria de Tabla.
clave(alumnos,       [legajo]).
clave(materias,      [codigo]).
clave(correlativas,  [materia, requisito]).
clave(inscripciones, [legajo, materia]).

% referencia(Tabla, Columna, Referida, ColumnaReferida): cada valor de
% Columna en Tabla debe existir en ColumnaReferida de Referida.
referencia(correlativas,  materia,   materias, codigo).
referencia(correlativas,  requisito, materias, codigo).
referencia(inscripciones, legajo,    alumnos,  legajo).
referencia(inscripciones, materia,   materias, codigo).

% admite_nulo(Tabla, Columna): Columna de Tabla puede valer null.
admite_nulo(inscripciones, nota).

% rango(Tabla, Columna, Min, Max): el CHECK de Columna.
rango(inscripciones, nota, 1, 10).
```

Con esos hechos, una restricción violada es una consulta más.
`violacion/1` recorre las filas de cada tabla (`fila/2`, una cláusula por
tabla) y da cada restricción que no se cumple: un valor de tipo equivocado,
un `null` donde no se admite, un valor fuera de rango, una referencia a una
fila que no existe y una clave repetida.

<!-- ejemplo: capitulo-42/universidad.pl predicado: violacion/1 -->
```prolog
%!  violacion(-Violacion) is nondet.
%
%   Violacion es una restricción del esquema que los hechos guardados no
%   cumplen. Sin respuestas, la base es consistente.
violacion(Violacion) :-
    tabla(Tabla, _, _),
    fila(Tabla, Fila),
    (   violacion_valor(Tabla, Fila, Violacion)
    ;   violacion_referencia(Tabla, Fila, Violacion)
    ).
violacion(clave(Tabla, Fila)) :-
    tabla(Tabla, _, _),
    fila(Tabla, Fila),
    aggregate_all(count, misma_clave(Tabla, Fila, _), N),
    N > 1.
```

```prolog
?- violacion(V).
false.

?- snapshot((assertz(alumno(101, zoe, civil, 2025)), findall(V, violacion(V), Vs))).
Vs = [clave(alumnos, alumno(101, ana, sistemas, 2023)), clave(alumnos, alumno(101, zoe, civil, 2025))].
```

La base es consistente, y la fila repetida aparece en las dos filas que
comparten la clave. `snapshot/1`, del [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md), descarta los cambios
al terminar. `insertar/1` hace lo que hace SQLite: verifica la fila nueva
antes de agregarla, y lanza un error si viola alguna restricción.

<!-- ejemplo: capitulo-42/universidad.pl predicado: insertar/1 violacion_al_insertar/3 -->
```prolog
%!  insertar(+Fila) is semidet.
%
%   INSERT: agrega Fila al final de su tabla si cumple las restricciones
%   del esquema; si no, lanza error(restriccion(Violacion), _) y la base no
%   cambia. Falla si Fila no tiene la forma de una fila de alguna tabla.
insertar(Fila) :-
    tabla_de(Fila, Tabla),
    (   violacion_al_insertar(Tabla, Fila, Violacion)
    ->  throw(error(restriccion(Violacion), _))
    ;   guardar(Fila)
    ).

%!  violacion_al_insertar(+Tabla, +Fila, -Violacion) is nondet.
%
%   Fila no se puede agregar a Tabla por Violacion.
violacion_al_insertar(Tabla, Fila, Violacion) :-
    violacion_valor(Tabla, Fila, Violacion).
violacion_al_insertar(Tabla, Fila, clave(Tabla, Otra)) :-
    misma_clave(Tabla, Fila, Otra).
violacion_al_insertar(Tabla, Fila, Violacion) :-
    violacion_referencia(Tabla, Fila, Violacion).
```

```prolog
?- catch(insertar(alumno(101, zoe, civil, 2025)), E, true).
E = error(restriccion(clave(alumnos, alumno(101, ana, sistemas, 2023))), _).

?- catch(insertar(inscripcion(999, am1, null)), E, true).
E = error(restriccion(referencia(inscripciones, legajo, 999)), _).

?- catch(insertar(inscripcion(107, am1, 11)), E, true).
E = error(restriccion(rango(inscripciones, nota, 11)), _).
```

`borrar/1` verifica la restricción en el otro sentido: no quita una fila a
la que otra se refiere, como SQLite con las claves foráneas activas, que
rechaza `DELETE FROM alumnos WHERE legajo = 101` porque ana tiene
inscripciones. `poner_nota/3` es el `UPDATE` de una nota. Las dos están en
`universidad.pl`. Una actualización de varias filas que debe hacerse
entera o no hacerse se envuelve en `transaction/1`, del [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md):
es el `BEGIN` … `COMMIT` de SQL, y si la meta falla o lanza un error, los
cambios se deshacen como con `ROLLBACK`.
