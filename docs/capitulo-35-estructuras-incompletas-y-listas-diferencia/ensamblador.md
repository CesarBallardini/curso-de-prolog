# La tabla de símbolos del compilador

Esta página continúa el [capítulo 35](index.md) después de la
[sección 35.6](index.md#356-cuanto-se-gana), con la
[sección 35.7](#357-la-tabla-de-simbolos-del-compilador): la tabla de símbolos
de un ensamblador, que combina el diccionario incompleto de la
[sección 35.4](index.md#354-diccionarios-incompletos) con la gramática como lista diferencia de la
[sección 35.5](index.md#355-las-gramaticas-como-listas-diferencia). El código está en `ejemplos/capitulo-35/simbolos.pl`, con
sus pruebas en `simbolos.plt`; el [capítulo 46](../capitulo-46-proyecto-compilador/index.md) aplica las mismas técnicas en su compilador.

## 35.7 La tabla de símbolos del compilador

Un compilador traduce un programa a instrucciones numeradas, y un salto
dirige la ejecución a otra instrucción por su número. En el programa fuente,
el destino de un salto es una **etiqueta**, un nombre que marca una posición.
Un salto hacia atrás usa una etiqueta ya marcada, cuyo número se conoce; uno
hacia adelante usa una etiqueta que se marca más abajo, cuyo número todavía no
se conoce. La solución habitual es recorrer el programa dos veces: la primera
calcula los números de las etiquetas, la segunda los usa.

Con un diccionario incompleto alcanza una sola pasada. La **tabla de
símbolos**, que asocia cada etiqueta con su dirección, se consulta con
`buscar/3`. Un salto hacia adelante agrega la etiqueta con la dirección libre y
escribe esa variable en la instrucción; la marca, al aparecer, busca la misma
etiqueta y liga la variable al número de la instrucción que la sigue. El
programa de ejemplo, para una máquina de pila, escribe 3, 2 y 1:

<!-- ejemplo: capitulo-35/simbolos.pl predicado: programa/2 consulta: listar(cuenta). -->
```prolog
% programa(Nombre, Instrucciones): un programa de ejemplo. cuenta escribe
% 3, 2 y 1.
programa(cuenta, [ apilar(3), guardar(n),
                   etiqueta(inicio),
                   cargar(n), saltar_si_cero(fin),
                   cargar(n), escribir,
                   cargar(n), apilar(1), restar, guardar(n),
                   saltar(inicio),
                   etiqueta(fin) ]).
```

`ensamblar/2` produce el código con una gramática, es decir, como lista
diferencia, y lleva la tabla de símbolos como diccionario incompleto:

<!-- ejemplo: capitulo-35/simbolos.pl predicado: ensamblar/2 consulta: ensamblar([saltar(fin), sumar, etiqueta(fin)], C). -->
```prolog
%!  ensamblar(+Programa:list, -Codigo:list) is semidet.
%
%   Codigo es Programa con las marcas de etiqueta quitadas y cada salto
%   dirigido al número de instrucción de su etiqueta, contando desde 0.
%   Produce un error de existencia si un salto usa una etiqueta que no se
%   marca; falla si una etiqueta se marca dos veces en direcciones
%   distintas.
ensamblar(Programa, Codigo) :-
    phrase(codigo(Programa, 0, Tabla), Codigo),
    etiquetas_definidas(Tabla).
```

`codigo//3` pasa cada instrucción, con su dirección, a `instruccion//4`.
Una marca no ocupa lugar en el código; un salto ocupa una dirección, y busca en
la tabla la de su etiqueta:

<!-- ejemplo: capitulo-35/simbolos.pl fragmento: instruccion(etiqueta(E) .. Dir1 is Dir + 1 }. -->
```prolog
instruccion(etiqueta(E), Dir, Dir, Tabla) -->
    { buscar(E, Tabla, Dir) }.
instruccion(saltar(E), Dir, Dir1, Tabla) -->
    [saltar(D)],
    { buscar(E, Tabla, D),
      Dir1 is Dir + 1 }.
```

El programa de ejemplo, ensamblado:

```prolog
?- listar(cuenta).
0   apilar(3)
1   guardar(n)
2   cargar(n)
3   saltar_si_cero(11)
4   cargar(n)
5   escribir
6   cargar(n)
7   apilar(1)
8   restar
9   guardar(n)
10  saltar(2)
true.
```

`saltar_si_cero(fin)`, en la dirección 3, se tradujo antes de llegar a
`etiqueta(fin)`: su dirección, 11, llegó por unificación cuando la marca
apareció al final. Una etiqueta a la que se salta y que nunca se marca deja su
dirección libre; `etiquetas_definidas/1` recorre la tabla al terminar y lo
informa con un error de existencia, del [capítulo 26](../capitulo-26-errores-y-excepciones/index.md):

```prolog
?- ensamblar([saltar(fin), sumar, etiqueta(fin)], C).
C = [saltar(2), sumar].

?- ensamblar([saltar(fin), sumar], C).
ERROR: etiqueta `fin' does not exist
```

Una etiqueta marcada dos veces en lugares distintos hace fallar el
ensamblado: la segunda marca unifica con otro número una dirección ya
ligada, y la unificación falla. Dos marcas seguidas tienen el mismo número, y pasan sin aviso. El
[ejercicio 14](#ejercicios) convierte los dos casos en un error. El [capítulo 46](../capitulo-46-proyecto-compilador/index.md)
genera este código a partir de un lenguaje con asignaciones, `si` y
`mientras`, guarda las variables en el diccionario incompleto de la
[sección 35.4](index.md#354-diccionarios-incompletos) y deja las etiquetas como variables que el
ensamblado liga por unificación, y escribe la máquina de pila que lo ejecuta.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara sus modos; las estructuras incompletas se indican en el texto del encabezado: «Abierta es una lista abierta», «Dif, un par L-F» |
    | C4 | `inorden/2`, `invertir/2`, `por_niveles/2`, `codificar/2` y `ensamblar/2` no dejan alternativas: sus pruebas no declaran `nondet` |
    | C5 | una etiqueta sin marca produce un error de existencia en lugar de una dirección libre (prueba `sin_marca`); la etiqueta repetida falla, y el [ejercicio 14](#ejercicios) la convierte en error |
    | C7 | 85 pruebas en los seis archivos del capítulo; cada versión incompleta se compara con la cerrada sobre los mismos datos (pruebas `degenerado_iguales`, `iguales`, `arbol_como_lista`), y dos pruebas acotan las inferencias (`costo_lineal`, `arbol_menos_inferencias`) |
    | lo que se pierde | la relación en sentido inverso: `agregar_al_final/2`, `conocidos/2` y `buscar_arbol/3` preguntan con `var/1` si llegaron al final, y no tienen modo con la estructura libre; y la verificación de ocurrencias, que la cola con contador hace innecesaria |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

14. **(2)** Cambiar `ensamblar/2`, de la
    [sección 35.7](#357-la-tabla-de-simbolos-del-compilador), para que una
    etiqueta marcada dos veces produzca un error de permiso,
    `permission_error(marcar, etiqueta, E)`. Considerar que un salto hacia
    adelante ya puede haber agregado la etiqueta a la tabla.
15. **(3)** Escribir `asignar(Codigo, Codigo1, N)`, que reemplaza el nombre
    de la variable de cada `cargar/1` y `guardar/1` por una dirección de
    memoria —0 para la primera variable que aparece, 1 para la segunda— con
    un diccionario incompleto; N es la cantidad de variables.
16. **(3)** Escribir `nivelar(Arbol, Nivelado)`: Nivelado tiene la misma
    forma que Arbol, un árbol `vacio` o `n(Izq, X, Der)` como el de la
    [sección 35.2](index.md#352-de-append3-a-la-lista-diferencia), y cada uno de sus nodos tiene el máximo de los
    elementos de Arbol. Arbol se recorre una sola vez.
    `nivelar(n(n(vacio, 4, vacio), 3, n(vacio, 9, vacio)), N)` da un árbol con
    9 en los tres nodos, y `nivelar(vacio, N)` da `vacio`. El valor de los
    nodos nuevos no se conoce cuando se construyen: ¿qué estructura de la
    [sección 35.7](#357-la-tabla-de-simbolos-del-compilador) resuelve el mismo problema?

## Resumen

| | |
|---|---|
| lista abierta | una lista que termina en una variable libre: se amplía ligándola, y se cierra con `[]` |
| lista diferencia | un par `L-F`, con F al final de L, que representa los elementos anteriores a F; se concatena en una unificación y se usa una sola vez |
| verificación de ocurrencias | una variable no se liga a un término que la contiene; SWI-Prolog la omite, y sin ella se crean términos cíclicos |
| `unify_with_occurs_check/2` | unificar con la verificación de ocurrencias |
| `cyclic_term/1` | el término es cíclico, infinito |
| opción `occurs_check` | `true` o `error` activan la verificación en todas las unificaciones |
| cola con contador | `cola(N, Frente, Fondo)`: encolar y desencolar en un paso; la cantidad reconoce la cola vacía |
| diccionario incompleto | una lista o un árbol con el final abierto; buscar consulta y agrega, y el valor se liga cuando se conoce |
| gramática y lista diferencia | los dos argumentos de la traducción de una regla son una lista diferencia; una gramática construye listas |
| tabla de símbolos en una pasada | las direcciones de las etiquetas, ligadas cuando aparece la marca |
| **Patrones 47, 48** | lista diferencia para agregar al final; diccionario incompleto |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La traducción de las gramáticas, escrita en Prolog | [capítulo 36](../capitulo-36-transformacion-de-programas-y-compilacion/index.md) |
| La cola diferencia en la búsqueda en anchura | [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) |
| Las sumas en forma normal, asociadas a izquierda | [capítulo 44](../capitulo-44-proyecto-resolver-ecuaciones/index.md) |
| Las respuestas de una aventura de texto construidas con gramáticas | [capítulo 45](../capitulo-45-proyecto-aventura-de-texto/index.md) |
| La tabla de símbolos de un compilador completo | [capítulo 46](../capitulo-46-proyecto-compilador/index.md) |

## Referencias

- Feliks Kluźniak y Stanisław Szpakowicz, *Prolog for Programmers*,
  Academic Press, 1985 — apartados «Open Lists and Trees» y «Difference
  Lists».
  [Edición en línea](https://www.site.uottawa.ca/~szpak/pub/P4P/Prolog_for_Programmers_neat.pdf).
  Esta página toma la tabla de símbolos de un traductor con las direcciones
  como variables que se ligan al ensamblar.

El código del capítulo es propio, escrito para el curso: las fuentes aportan
ideas y problemas, no código.
