# Las subconsultas

Esta página contiene una parte de la
[sección 86.7](index.md#867-version-5-condiciones-de-tres-valores) del
[capítulo 86](index.md): las subconsultas de `IN`, `EXISTS` y las
escalares, compiladas con la tabla de símbolos de la consulta que las
contiene. El código está en `consultas.pl`, en `ejemplos/capitulo-86/`,
con sus pruebas.

## Las subconsultas

<!-- contexto: capitulo-86/consultas.pl -->

Una subconsulta se compila con la tabla de símbolos de
la consulta que la contiene, con un nivel más. Una columna de afuera es
una variable que el generador de afuera ya ligó cuando la subconsulta se
ejecuta: la correlación no necesita nada más. `EXISTS` es la meta de la
subconsulta, una vez; `NOT EXISTS`, su negación, que el
[capítulo 10](../capitulo-10-negacion-como-falla/index.md#101-el-supuesto-de-mundo-cerrado)
justificó con el supuesto de mundo cerrado. `x IN (…)` es verdadera si
algún valor es igual a `x`, y falsa si `x` no es `NULL`, ninguno es igual
y ninguno es `NULL`. Una subconsulta escalar da su único valor, o `NULL`
si no tiene filas.

```prolog
% mostrar_traduccion("SELECT a.legajo, a.nombre FROM alumnos a WHERE NOT EXISTS (SELECT * FROM inscripciones i WHERE i.legajo = a.legajo)").
consulta([A, B]) :-
    base:alumno(A, B, _, _),
    \+ base:inscripcion(A, _, _).
```

```prolog
% mostrar_traduccion("SELECT nombre FROM alumnos WHERE legajo IN (SELECT legajo FROM inscripciones WHERE materia = 'pp')").
consulta([A]) :-
    base:alumno(B, A, _, _),
    once(( base:inscripcion(C, pp, _),
           B=:=C
         )).
```

```prolog
?- filas("SELECT a.nombre FROM alumnos a, inscripciones i WHERE a.legajo = i.legajo AND i.materia = 'log' AND i.nota = (SELECT MAX(nota) FROM inscripciones WHERE materia = 'log')", _, Fs).
Fs = [[ana]].
```

En la primera traducción, la igualdad `i.legajo = a.legajo` de la
subconsulta se resolvió al compilar con la variable de afuera: el
generador de inscripciones se llama con el legajo del alumno, y la
subconsulta entera es una llamada negada. Es la consulta que el
[capítulo 42](../capitulo-42-prolog-y-sql/index.md#422-el-algebra-relacional-en-clausulas)
escribió a mano para la diferencia.
