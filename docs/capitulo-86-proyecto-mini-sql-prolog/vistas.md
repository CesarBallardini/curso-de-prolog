# Las vistas

Esta página contiene la [sección 86.10](index.md#8610-version-8-las-vistas) del
[capítulo 86](index.md): `CREATE VIEW` compilada en una cláusula de Prolog. El código está en `vistas.pl`, en `ejemplos/capitulo-86/`, con sus pruebas.

## Las vistas

Kluźniak y Szpakowicz llaman **vista** a una relación que se calcula en
lugar de guardarse, y observan que, para quien la llama, un generador
calculado no se distingue de uno hecho de cláusulas unitarias. Las vistas
definidas son la primera extensión que proponen para Toy-Sequel.
`vistas.pl` compila la consulta de `CREATE VIEW` una sola vez y la guarda
como una cláusula del módulo `relaciones`: la cabeza lleva los valores de
una fila, y el cuerpo es la meta compilada. El catálogo la registra con un
generador de la misma forma que el de una tabla.

<!-- ejemplo: capitulo-86/vistas.pl predicado: vista/2 -->
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

<!-- contexto: capitulo-86/minisql.pl -->
```prolog
% guion("CREATE VIEW aprobadas AS SELECT legajo, materia, nota FROM inscripciones WHERE nota >= 6", _), mostrar_traduccion("SELECT a.nombre, p.materia FROM alumnos a, aprobadas p WHERE a.legajo = p.legajo AND p.nota = 10").
consulta([A, B]) :-
    base:alumno(C, A, _, _),
    relaciones:aprobadas(C, B, 10).
```

La vista es la regla `aprobada/3` del
[capítulo 42](../capitulo-42-prolog-y-sql/index.md#422-el-algebra-relacional-en-clausulas),
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
[capítulo 85](../capitulo-85-proyecto-motor-datalog/index.md) podría
evaluar de abajo hacia arriba. Una vista que se nombra a sí misma no se
puede crear: cuando se compila su consulta, la vista todavía no está en
el catálogo, y el error es `tabla_desconocida`. SQL escribe la recursión
con `WITH RECURSIVE`
([ejercicio 8](index.md#ejercicios)).
