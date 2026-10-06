# El horario de una materia

Esta página contiene la [sección 87.9](index.md#879-una-pregunta-mas-el-horario-de-una-materia)
del [capítulo 87](index.md): una clase de pregunta nueva, agregada sin
modificar los módulos de las versiones anteriores. El código está en
`horario.pl`, en `ejemplos/capitulo-87/`, con sus pruebas.

## Una pregunta más

El [capítulo 73](../capitulo-73-proyecto-horarios-inscripciones/index.md)
construye los horarios de las materias de *Inscripciones*, y su
`oferta.pl` tiene un horario de ejemplo. «¿Cuándo se cursa lógica?» es
una clase de pregunta nueva: no pide alumnos ni materias, sino clases en
la semana. `horario.pl` la agrega sin modificar ninguno de los módulos
anteriores, con el
[Patrón 79](../patrones.md#79-clausulas-para-un-modulo-cargado): los
predicados que una versión nueva extiende están declarados `multifile`
(`pregunta//1` en `gramatica.pl`, `evaluar/2` y `explicar/2` en
`evaluar.pl`, `escribir_respuesta/1` y `escribir_explicacion/1` en
`preguntas.pl`), y `horario.pl` les agrega una cláusula cada uno:

<!-- ejemplo: capitulo-87/horario.pl fragmento: gramatica:pregunta(cuando(Materia)) .. clases_de(Materia, Clases). -->
```prolog
gramatica:pregunta(cuando(Materia)) -->
    palabra("cuando"),
    palabra("se"),
    [Palabra],
    { lemas:analisis(Palabra, verbo(Lema, _, 3, singular)),
      memberchk(Lema, ["cursar", "dictar"]) },
    nombre_propio(materia, Materia).

evaluar:evaluar(cuando(Materia), horario(Clases)) :-
    clases_de(Materia, Clases).
```

<!-- contexto: capitulo-87/horario.pl -->
```prolog
?- preguntar("¿Cuándo se cursa lógica?").
martes, franja 2, aula a2; jueves, franja 2, aula a2
  asignada(log-1, 2, 5, 6)
  asignada(log-2, 2, 13, 14)
true.

?- sql("¿Cuándo se cursa lógica?").
false.
```

La explicación son los hechos del horario: cada clase de lógica, con su
aula y su momento de la semana, que `momento/4` del
[capítulo 73](../capitulo-73-proyecto-horarios-inscripciones/index.md)
convierte en día y franja. La pregunta no tiene sentencia SQL, porque el
horario no es una tabla de la base del
[capítulo 42](../capitulo-42-prolog-y-sql/index.md): `sql/2` falla cuando
un predicado no tiene tabla. Las demás preguntas siguen igual, y las
pruebas de `horario.plt` lo verifican.
