# Las vistas

Esta página continúa la página
[Las sentencias que cambian las tablas](modificaciones.md#879-version-7-las-sentencias-que-cambian-las-tablas)
del [capítulo 87](index.md), con la sección [87.10](#8710-version-8-las-vistas): `CREATE VIEW`
compilada en una cláusula de Prolog. El código está en `vistas.pl`, en
`ejemplos/capitulo-87/`, con sus pruebas.

## 87.10 Versión 8: las vistas

Kluźniak y Szpakowicz llaman **vista** a una relación que se calcula en
lugar de guardarse, y observan que, para quien la llama, un generador
calculado no se distingue de uno hecho de cláusulas unitarias. Las vistas
definidas son la primera extensión que proponen para Toy-Sequel.
`vistas.pl` compila la consulta de `CREATE VIEW` una sola vez y la guarda
como una cláusula del módulo `relaciones`: la cabeza lleva los valores de
una fila, y el cuerpo es la meta compilada. El catálogo la registra con un
generador de la misma forma que el de una tabla.

<!-- ejemplo: capitulo-87/vistas.pl predicado: vista/2 -->
```prolog
%!  vista(+Sentencia, -Resultado) is det.
%
%   Ejecuta crear_vista(V, Q), con Resultado creada(V), o borrar_vista(V),
%   con Resultado borrada(V).
vista(crear_vista(V, Q), creada(V)) :-
    (   relacion(V, _, _, _)
    ->  throw(error(sql(ya_existe(V)), _))
    ;   true
    ),
    compilar_consulta(Q, [], Meta, Valores, Columnas),
    maplist(nombre_columna, Columnas, Nombres),
    (   append(_, [N|Resto], Nombres),
        memberchk(N, Resto)
    ->  throw(error(sql(columna_repetida(N)), _))
    ;   true
    ),
    Cabeza =.. [V|Valores],
    assertz(relaciones:(Cabeza :- Meta)),
    length(Valores, Aridad),
    length(Variables, Aridad),
    Generador =.. [V|Variables],
    maplist(columna_vista, Columnas, Variables, Cols),
    assertz(relacion(V, vista, relaciones:Generador, Cols)).
vista(borrar_vista(V), borrada(V)) :-
    (   relacion(V, vista, Generador, _)
    ->  retractall(Generador),
        retractall(relacion(V, _, _, _))
    ;   throw(error(sql(no_es_vista(V)), _))
    ).
```

<!-- contexto: capitulo-87/minisql.pl -->
```prolog
% guion("CREATE VIEW aprobadas AS SELECT legajo, materia, nota FROM inscripciones WHERE nota >= 6", _), mostrar_traduccion("SELECT a.nombre, p.materia FROM alumnos a, aprobadas p WHERE a.legajo = p.legajo AND p.nota = 10").
consulta([A, B]) :-
    base:alumno(C, A, _, _),
    relaciones:aprobadas(C, B, 10).
```

La vista es la regla `aprobada/3` del
[capítulo 43](../capitulo-43-prolog-y-sql/index.md#432-el-algebra-relacional-en-clausulas),
escrita por el compilador:

```prolog
% guion("CREATE VIEW aprobadas AS SELECT legajo, materia, nota FROM inscripciones WHERE nota >= 6", _), listing(relaciones:aprobadas/3).
:- dynamic aprobadas/3.

aprobadas(A, B, C) :-
    base:inscripcion(A, B, C),
    C\==null,
    C>=6.
```

La igualdad `p.nota = 10` se resolvió al compilar con la columna de la
vista, y la constante llega a la cabeza de la cláusula: la vista prueba
`10 >= 6` una vez por inscripción con nota 10. Una vista sin negación ni
agregados es una regla de Datalog, y un conjunto de ellas es un
programa que el motor del
[capítulo 86](../capitulo-86-proyecto-motor-datalog/index.md) podría
evaluar de abajo hacia arriba. Una vista que se nombra a sí misma no se
puede crear: cuando se compila su consulta, la vista todavía no está en
el catálogo, y el error es `tabla_desconocida`. SQL escribe la recursión
con `WITH RECURSIVE`
([ejercicio 10](modificaciones.md#ejercicios)).

El capítulo continúa en la página
[El mini-SQL frente a SQLite](sqlite.md#8711-el-mini-sql-frente-al-sql-del-capitulo-43),
con las sentencias
del [capítulo 43](../capitulo-43-prolog-y-sql/index.md) ejecutadas en el
mini-SQL y comparadas con SQLite.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

11. **(2)** El mini-SQL no tiene `LEFT JOIN`. Escribir con una vista y
    `UNION ALL` el par 19 del [capítulo 43](../capitulo-43-prolog-y-sql/index.md), la cantidad de inscriptos de
    cada materia incluidas las que no tienen ninguno, y comprobar que da
    las filas de SQLite.

## Referencias

- Feliks Kluźniak y Stanisław Szpakowicz, *Prolog for Programmers*,
  Academic Press, 1985 — «Two Case Studies», apartado 8.2,
  «Prolog and Relational Data Bases», con el listado 8.4, «Toy-Sequel
  Interpreter». Sin edición en línea de acceso libre verificada.
  Esta página toma de allí la definición de vista y la indistinción de su
  generador, y las vistas definidas como extensión de Toy-Sequel.
