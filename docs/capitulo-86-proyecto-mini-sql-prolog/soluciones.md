# Soluciones del capítulo 86 — Proyecto: un mini-SQL en Prolog

El código de esta página está en `ejemplos/capitulo-86/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga el intérprete completo,
`minisql.pl`, y las mediciones de `costos.pl`, sin modificarlos. Es
`% solo-local`, porque carga otros archivos. Los predicados que las
consultas usan están en `lexico.pl` (`tokens/2`), `ingenuo.pl`
(`consulta_ingenua/2`, `traducir_ingenuo/3`), `consultas.pl` (`filas/3`,
`traducir/3`, `mostrar_traduccion/1`) y `minisql.pl` (`sql/2`, `guion/2`).
Cada consulta de esta página se ejecuta sobre la base del
[capítulo 42](../capitulo-42-prolog-y-sql/index.md) recién cargada.

## 1

Las palabras pasan a minúsculas; el menos es un símbolo, aunque esté
pegado a un número; la cadena se guarda con una sola comilla; `!=` es
`<>`, y el punto y coma final es un símbolo más, que la gramática admite
al final de una sentencia.

<!-- contexto: capitulo-86/soluciones.pl -->
```prolog
?- tokens("SELECT x-1, 'it''s' FROM t", Ts).
Ts = [n(select), n(x), -, i(1), ',', s('it\'s'), n(from), n(t)].

?- tokens("WHERE a != b;", Ts).
Ts = [n(where), n(a), <>, n(b), ;].
```

## 2

El compilador de Toy-Sequel no da ninguna fila; SQL y el mini-SQL dan
las dos de industrial.

```prolog
?- consulta_ingenua("SELECT nombre FROM alumnos WHERE NOT (carrera = 'civil' OR carrera = 'sistemas')", I), filas("SELECT nombre FROM alumnos WHERE NOT (carrera = 'civil' OR carrera = 'sistemas')", _, C).
I = [],
C = [[facundo], [gabriela]].

?- traducir_ingenuo("SELECT nombre FROM alumnos WHERE NOT (carrera = 'civil' OR carrera = 'sistemas')", F, M).
F = [_A],
M = (base:alumno(_, _A, civil, _), \+ (true;fail)).
```

En la meta ingenua, la primera igualdad puso `civil` en el generador, que
solo recorre los alumnos de civil; la segunda ya no puede unificar
`civil` con `sistemas` y es `fail`; y el filtro `\+ (true ; fail)` falla
siempre. El compilador de la versión 5 empuja el `NOT` hasta las
comparaciones: la negación de una disyunción es la conjunción de las
negaciones, y ninguna igualdad se resuelve al compilar, porque ninguna
está en la conjunción de primer nivel.

```prolog
% mostrar_traduccion("SELECT nombre FROM alumnos WHERE NOT (carrera = 'civil' OR carrera = 'sistemas')").
consulta([A]) :-
    base:alumno(_, A, B, _),
    B\==civil,
    B\==sistemas.
```

## 3

`nota <> 4` es verdadera para las trece inscripciones con una nota
distinta de 4; `NOT (nota <> 4)`, para la única con 4, la de Bruno en
Análisis 1; y las tres sin nota no cumplen ninguna de las dos, porque
una comparación con `NULL` es desconocida y su negación también. Las
tres cuentas suman las diecisiete inscripciones.

```prolog
?- filas("SELECT COUNT(*) FROM inscripciones WHERE nota <> 4", _, A), filas("SELECT COUNT(*) FROM inscripciones WHERE NOT (nota <> 4)", _, B), filas("SELECT COUNT(*) FROM inscripciones WHERE nota IS NULL", _, C).
A = [[13]],
B = [[1]],
C = [[3]].
```

## 4

La solución analiza la consulta, construye sus marcos y busca cada
referencia a una columna con `buscar_columna/4`, como el compilador. La
variable que esta da identifica el marco por igualdad estricta, `==`, y
el marco da el alias, que `desde/2` relaciona con la tabla. Un nombre
ambiguo produce el mismo error que en una consulta.

<!-- ejemplo: capitulo-86/soluciones.pl predicado: columnas_usadas/2 tabla_de_columna/4 -->
```prolog
%!  columnas_usadas(+Texto, -Columnas:list) is det.
%
%   Columnas son las columnas que nombra el SELECT Texto, de un solo
%   nivel, cada una Tabla-Columna, sin repetidas y en orden alfabético.
columnas_usadas(Texto, Columnas) :-
    analizar(Texto, consulta(seleccion(_, Items, Desde, Donde, Grupo, Ten),
                             _, _)),
    marcos(Desde, _, Marcos),
    findall(R, ( sub_term(R, f(Items, Donde, Grupo, Ten)),
                 ( R = columna(_) ; R = columna(_, _) ) ),
            Refs),
    maplist(tabla_de_columna(Desde, Marcos), Refs, Cs),
    sort(Cs, Columnas).

%!  tabla_de_columna(+Desde:list, +Marcos:list, +Ref, -TC) is det.
%
%   TC es Tabla-Columna para la referencia Ref, buscada en Marcos.
tabla_de_columna(Desde, Marcos, Ref, Tabla-C) :-
    buscar_columna(Ref, [Marcos], col(C, _, _, V), _),
    member(marco(Alias, Cs), Marcos),
    member(col(_, _, _, W), Cs),
    W == V,
    !,
    memberchk(desde(Tabla, Alias), Desde).
```

```prolog
?- columnas_usadas("SELECT a.nombre FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND nota > 6", Cs).
Cs = [alumnos-legajo, alumnos-nombre, inscripciones-legajo, inscripciones-nota].
```

## 5

`actualizar_tupla/2` compila la condición y las asignaciones como el
mini-SQL, pero retira la tupla vieja y agrega la nueva dentro del
recorrido, como el bucle de falla de Toy-Sequel.
`aggregate_all(count, …)` cuenta las filas cambiadas.

<!-- ejemplo: capitulo-86/soluciones.pl predicado: actualizar_tupla/2 nuevos/5 -->
```prolog
%!  actualizar_tupla(+Texto, -N:integer) is det.
%
%   Ejecuta el UPDATE Texto como Toy-Sequel: para cada fila que cumple la
%   condición, retira la tupla y agrega la nueva, dentro del recorrido.
%   N es la cantidad de filas cambiadas. La condición ve la tabla a medio
%   cambiar.
actualizar_tupla(Texto, N) :-
    analizar(Texto, actualizar(T, Asignaciones, Condicion)),
    marcos([desde(T, T)], [Generador], Marcos),
    Marcos = [marco(_, Columnas)],
    Pila = [Marcos],
    condicion(Condicion, fila, Pila, verdadera, Filtro),
    maplist([col(_, _, _, V), V]>>true, Columnas, Viejos),
    nuevos(Columnas, Asignaciones, Pila, Nuevos, Calculos),
    Generador = M:Cabeza,
    Cabeza =.. [P|Viejos],
    Nueva =.. [P|Nuevos],
    aggregate_all(count,
                  ( Generador,
                    once(Filtro),
                    Calculos,
                    retract(M:Cabeza),
                    assertz(M:Nueva) ),
                  N).

%!  nuevos(+Columnas:list, +Asignaciones:list, +Pila:list, -Nuevos:list,
%!         -Calculos) is det.
%
%   Nuevos son los valores nuevos de las columnas: el de su asignación, o
%   el viejo; Calculos es la meta que calcula los asignados.
nuevos([], _, _, [], true).
nuevos([col(C, _, _, V)|Cs], Asignaciones, Pila, [N|Ns], (M, Ms)) :-
    (   memberchk(C-E, Asignaciones)
    ->  expresion(E, fila, Pila, N, _, _, M)
    ;   N = V,
        M = true
    ),
    nuevos(Cs, Asignaciones, Pila, Ns, Ms).
```

```prolog
?- guion("CREATE TABLE s (n TEXT, x INTEGER); INSERT INTO s VALUES ('a', 1000), ('b', 1100), ('c', 1200)", _), sql("UPDATE s SET x = x + 200 WHERE x = (SELECT MAX(x) FROM s) - 100", N), sql("SELECT * FROM s", R).
N = actualizadas(1),
R = filas([n, x], [[a, 1000], [b, 1300], [c, 1200]]).

?- guion("CREATE TABLE s (n TEXT, x INTEGER); INSERT INTO s VALUES ('a', 1000), ('b', 1100), ('c', 1200)", _), actualizar_tupla("UPDATE s SET x = x + 200 WHERE x = (SELECT MAX(x) FROM s) - 100", N), sql("SELECT * FROM s", R).
N = 2,
R = filas([n, x], [[a, 1000], [b, 1300], [c, 1400]]).
```

`sql/2` da lo mismo que SQLite: el máximo es 1 200 para toda la
sentencia, y solo la fila con 1 100 cumple la condición. Tupla por tupla,
`b` pasa a 1 300 antes de examinar `c`; la subconsulta, que se ejecuta de
nuevo para `c`, encuentra entonces el máximo 1 300, y `c`, con 1 200,
cumple la condición. La vista lógica de actualización del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#203-la-vista-logica-de-actualizacion)
evita que el recorrido vuelva a encontrar la fila nueva de `b`, pero no
que la subconsulta la vea. La prueba `soluciones:ejercicio_5` verifica
los dos resultados.

## 6

`generadores/3` separa las llamadas a tablas con que empieza la meta, y
`traducir_ordenado/2` las ordena por la cantidad de argumentos que la
compilación dejó ligados, de mayor a menor, con un ordenamiento estable.

<!-- ejemplo: capitulo-86/soluciones.pl predicado: traducir_ordenado/2 generadores/3 generador/1 ligados/2 -->
```prolog
%!  traducir_ordenado(+Texto, -Traduccion) is det.
%
%   Traduccion es Fila-Meta, la traducción de la consulta Texto con sus
%   generadores ordenados de más a menos argumentos ligados al compilar.
traducir_ordenado(Texto, Fila-Meta) :-
    traducir(Texto, _, Fila-Meta0),
    generadores(Meta0, Gs, Resto),
    map_list_to_pairs(ligados, Gs, Pares),
    sort(1, @>=, Pares, Ordenados),
    pairs_values(Ordenados, Gs1),
    (   Resto == true
    ->  Metas = Gs1
    ;   append(Gs1, [Resto], Metas)
    ),
    encadenar(Metas, Meta).

%!  generadores(+Meta, -Generadores:list, -Resto) is det.
%
%   Generadores son las llamadas a tablas con que empieza la conjunción
%   Meta, y Resto la meta que sigue.
generadores((G, Resto0), [G|Gs], Resto) :-
    generador(G),
    !,
    generadores(Resto0, Gs, Resto).
generadores(G, [G], true) :-
    generador(G),
    !.
generadores(Resto, [], Resto).

% generador(G): G llama a una tabla o una vista.
generador(M:_) :-
    memberchk(M, [base, relaciones]).

% ligados(G, K): K es la cantidad de argumentos de G ligados al compilar.
ligados(_:G, K) :-
    G =.. [_|Args],
    include(nonvar, Args, Ligados),
    length(Ligados, K).
```

```prolog
?- T = "SELECT i.materia, i.nota FROM inscripciones i, alumnos a WHERE a.nombre = 'ana' AND a.legajo = i.legajo", traducir(T, _, F1-M1), traducir_ordenado(T, F2-M2).
T = "SELECT i.materia, i.nota FROM inscripciones i, alumnos a WHERE a.nombre = 'ana' AND a.legajo = i.legajo",
F1 = [_A, _B],
M1 = (base:inscripcion(_C, _A, _B), base:alumno(_C, ana, _, _)),
F2 = [_D, _E],
M2 = (base:alumno(_F, ana, _, _), base:inscripcion(_F, _D, _E)).
```

En el orden del `FROM`, la meta recorre las diecisiete inscripciones y
busca el alumno de cada una con el legajo ligado: 32 inferencias para
dar las cinco filas. Con el alumno primero, encuentra a Ana y después
sus cinco inscripciones por el índice del legajo: 16 inferencias (prueba
`soluciones:ejercicio_6_costos`, dentro de un 10 %). Las filas son las
mismas, en el mismo orden. Kluźniak y Szpakowicz señalan que la
ganancia depende de que la implementación indexe las cláusulas, y citan
el trabajo de David H. D. Warren sobre la optimización de consultas
expresadas en lógica. El criterio de contar argumentos ligados es una
aproximación: no sabe cuántas filas tiene cada tabla, que es lo que usa
el optimizador de una base de datos.

## 7

`violacion/1` del [capítulo 42](../capitulo-42-prolog-y-sql/index.md) examina la base entera, y `estado/1` y
`restaurar/1` del catálogo dan la manera de deshacer la inserción.

<!-- ejemplo: capitulo-86/soluciones.pl predicado: insertar_verificado/2 -->
```prolog
%!  insertar_verificado(+Texto, -Resultado) is det.
%
%   Ejecuta el INSERT Texto y verifica después las restricciones del
%   esquema del capítulo 42 con violacion/1. Si alguna no se cumple,
%   repone el estado anterior y lanza error(sql(Violacion), _).
insertar_verificado(Texto, Resultado) :-
    estado(E),
    sql(Texto, Resultado),
    (   base:violacion(V)
    ->  restaurar(E),
        throw(error(sql(V), _))
    ;   true
    ).
```

```prolog
?- catch(insertar_verificado("INSERT INTO inscripciones (legajo, materia) VALUES (999, 'am1')", R), E, true), filas("SELECT COUNT(*) FROM inscripciones", _, K).
E = error(sql(referencia(inscripciones, legajo, 999)), _),
K = [[17]].
```

La inscripción del legajo 999, que no existe, se rechaza, y la tabla
sigue con sus diecisiete filas. Verificar la base entera después de cada
`INSERT` es correcto pero costoso; una solución más fina verificaría
solo las filas nuevas con `referencia/4`, como hace `insertar/1` en el
[capítulo 42](../capitulo-42-prolog-y-sql/restricciones.md#claves-restricciones-y-actualizaciones).

## 8

Cada ronda agrega las filas que el paso deriva de las que ya están y que
todavía no están: `EXCEPT` elimina las repetidas y las ya guardadas. Es
la evaluación de abajo hacia arriba de la
[sección 38.6](../capitulo-38-semantica-de-los-programas-logicos/index.md#386-evaluacion-de-abajo-hacia-arriba),
en su forma ingenua: cada ronda vuelve a combinar todas las filas, no
solo las nuevas, que es lo que la evaluación semi-ingenua del
[capítulo 85](../capitulo-85-proyecto-motor-datalog/index.md) evita.

<!-- ejemplo: capitulo-86/soluciones.pl predicado: recursiva/5 rondas/3 -->
```prolog
%!  recursiva(+Tabla, +Crear, +Base, +Paso, -Rondas:integer) is det.
%
%   Calcula una consulta recursiva en la tabla Tabla, que crea la
%   sentencia Crear: la llena con el SELECT Base y después repite
%   INSERT INTO Tabla Paso EXCEPT SELECT * FROM Tabla, donde Paso nombra
%   a Tabla, hasta que no agrega ninguna fila. Rondas es la cantidad de
%   veces que se ejecutó Paso.
recursiva(Tabla, Crear, Base, Paso, Rondas) :-
    sql(Crear, _),
    format(atom(Inicio), "INSERT INTO ~w ~w", [Tabla, Base]),
    sql(Inicio, _),
    format(atom(Insertar), "INSERT INTO ~w ~w EXCEPT SELECT * FROM ~w",
           [Tabla, Paso, Tabla]),
    rondas(Insertar, 1, Rondas).

%!  rondas(+Insertar, +K0:integer, -K:integer) is det.
%
%   Ejecuta Insertar hasta que no agrega filas; K cuenta las ejecuciones.
rondas(Insertar, K0, K) :-
    sql(Insertar, insertadas(N)),
    (   N =:= 0
    ->  K = K0
    ;   K1 is K0 + 1,
        rondas(Insertar, K1, K)
    ).
```

```prolog
?- recursiva(requisito, "CREATE TABLE requisito (r TEXT)", "SELECT requisito FROM correlativas WHERE materia = 'bd'", "SELECT c.requisito FROM correlativas c, requisito q WHERE c.materia = q.r", Rondas), sql("SELECT r FROM requisito ORDER BY r", R).
Rondas = 2,
R = filas([r], [[alg], [log], [pp], [ssl]]).
```

La base da `pp` y `ssl`; la primera ronda agrega `log` y `alg`, sus
correlativas; la segunda no agrega nada, porque las correlativas de
`log` y de `alg` ya están o no existen. Las cuatro filas son las de
SQLite para el par 35.

## 9

La vista une las inscripciones de cada materia con una fila con `NULL`
para cada materia sin inscriptos; `COUNT(legajo)` no cuenta los `NULL`, y
esas materias dan cero, como con `LEFT JOIN`.

```prolog
?- guion("CREATE VIEW materia_legajo AS SELECT m.codigo AS codigo, i.legajo AS legajo FROM materias m, inscripciones i WHERE i.materia = m.codigo UNION ALL SELECT m.codigo, NULL FROM materias m WHERE NOT EXISTS (SELECT * FROM inscripciones i WHERE i.materia = m.codigo); SELECT codigo, COUNT(legajo) FROM materia_legajo GROUP BY codigo", Rs).
Rs = [creada(materia_legajo), filas([codigo, count], [[alg, 4], [am1, 5], [am2, 2], [bd, 0], [log, 4], [pp, 2], [ssl, 0]])].
```

Las siete filas son las de SQLite (prueba `soluciones:ejercicio_9`). La
columna de la segunda selección es la constante `NULL`, de tipo `nulo`,
que es compatible con el entero del legajo.

## 10

La consulta no da ninguna fila: hay notas `NULL` entre las de la
subconsulta, y entonces `x NOT IN (…)` nunca es verdadera.

```prolog
% mostrar_traduccion("SELECT nombre FROM alumnos WHERE ingreso NOT IN (SELECT nota FROM inscripciones)").
consulta([A]) :-
    base:alumno(_, A, _, B),
    \+ ( base:inscripcion(C, D, E),
         E==null
       ),
    \+ ( base:inscripcion(C, D, E),
         E\==null,
         B=:=E
       ).
```

```prolog
?- filas("SELECT nombre FROM alumnos WHERE ingreso NOT IN (SELECT nota FROM inscripciones)", _, Fs).
Fs = [].
```

La primera negación exige que la subconsulta no tenga ningún `NULL`; la
segunda, que ningún valor sea igual al ingreso. Hacen falta las dos para
que la condición sea falsa, y la negación de `IN` exige que lo sea. Con
tres notas `NULL`, la primera falla para todos los alumnos. Es el par 30
del [capítulo 42](../capitulo-42-prolog-y-sql/index.md#ejercicios), con
otras columnas. El ingreso no es `NULL` para ningún alumno, porque la
columna es `NOT NULL`, y la meta no lo controla.

## 11

`nota = nota` es una igualdad de primer nivel entre una columna y ella
misma: la unificación de la variable con sí misma tiene éxito, y la
igualdad desaparece. Pero la columna admite `NULL`, y en SQL `NULL =
NULL` es desconocida: la compilación deja el control `\== null`, y las
tres inscripciones sin nota no pasan. Quedan catorce.

```prolog
% mostrar_traduccion("SELECT legajo FROM inscripciones WHERE nota = nota").
consulta([A]) :-
    base:inscripcion(A, _, B),
    B\==null.
```

```prolog
?- filas("SELECT COUNT(*) FROM inscripciones WHERE nota = nota", _, K).
K = [[14]].
```
