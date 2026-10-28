# El mundo del capítulo 41

Esta página continúa el [capítulo 71](index.md) después de la
[sección 71.5](index.md#715-version-3-el-robot-de-strips), con la versión
4, la [sección 71.6](#716-version-4-el-mundo-del-capitulo-41): los operadores STRIPS del
[capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) traducidos a la descripción que usa WARPLAN, y la
comparación de los dos planificadores sobre el mismo mundo. Los ejemplos
son `pinza.pl` y `sin_pinza.pl`, en `ejemplos/capitulo-71/`, con sus
pruebas; cargan archivos de ese capítulo y se ejecutan en una instalación
local.

## 71.6 Versión 4: el mundo del capítulo 41

La cuarta versión no cambia el planificador: traduce a la descripción de
WARPLAN los operadores STRIPS del
[capítulo 41](../capitulo-41-busqueda-y-planificacion/planificacion.md#416-planificacion-operadores-strips-y-analisis-de-medios-y-fines),
cargando sus archivos, y
compara los dos planificadores sobre el mismo mundo. Con pinza dan el
mismo plan de seis acciones; sin pinza, WARPLAN da el de tres que el
análisis de medios y fines no construye, y cuesta menos.

`strips.pl`, del [capítulo 41](../capitulo-41-busqueda-y-planificacion/planificacion.md#416-planificacion-operadores-strips-y-analisis-de-medios-y-fines),
describe el mundo de bloques con pinza de otra manera: cada acción es un
operador STRIPS con sus precondiciones y las listas de lo que agrega y lo
que borra, y las acciones se generan sin variables. `pinza.pl` carga ese
archivo en un módulo propio, `mf`, con `load_files/2`, como la
[sección 44.2](../capitulo-44-proyecto-resolver-ecuaciones/index.md#442-version-1-el-aislamiento), y traduce: una acción agrega los hechos
de su lista `Agrega` y borra los de su lista `Borra`. El mundo no se copia;
el planificador de medios y fines del mismo archivo queda disponible como
`medios_fines/3`:

<!-- ejemplo: capitulo-71/pinza.pl predicado: agrega/2 borra/2 puede/2 dado/2 medios_fines/3 -->
```prolog
%!  agrega(?Hecho, ?Accion) is nondet.
%
%   Hecho está en la lista de lo que agrega el operador de Accion.
agrega(Hecho, Accion) :-
    mf:operador(Accion, _, Agrega, _),
    member(Hecho, Agrega).

%!  borra(?Hecho, ?Accion) is nondet.
%
%   Hecho está en la lista de lo que borra el operador de Accion.
borra(Hecho, Accion) :-
    mf:operador(Accion, _, _, Borra),
    member(Hecho, Borra).

%!  puede(?Accion, -Precondiciones:list) is nondet.
%
%   Precondiciones son las del operador de Accion.
puede(Accion, Pre) :-
    mf:operador(Accion, Pre, _, _).

%!  dado(?Inicio, ?Hecho) is nondet.
%
%   Hecho vale en el estado inicial Inicio; sussman es el estado inicial
%   de la anomalía en el capítulo 41.
dado(sussman, Hecho) :-
    mf:sussman(Estado),
    member(Hecho, Estado).

%!  medios_fines(+Inicio, +Metas:list, -Plan:list) is semidet.
%
%   Plan es el primer plan que da el planificador de medios y fines del
%   capítulo 41, con su cota de longitud, desde el estado inicial Inicio.
medios_fines(sussman, Metas, Plan) :-
    mf:sussman(Estado),
    once(mf:planificar(Estado, Metas, Plan)).
```

Con pinza, los dos planificadores dan el mismo plan de seis acciones:

<!-- contexto: capitulo-71/pinza.pl -->
```prolog
?- once(planificar(pinza, sussman, [sobre(a, b), sobre(b, c)], 6, Plan)).
Plan = [desapilar(c, a), soltar(c), tomar(b), apilar(b, c), tomar(a), apilar(a, b)].

?- medios_fines(sussman, [sobre(a, b), sobre(b, c)], Plan).
Plan = [desapilar(c, a), soltar(c), tomar(b), apilar(b, c), tomar(a), apilar(a, b)].
```

`sin_pinza.pl` hace lo mismo con el mundo sin pinza de la solución del
[ejercicio 10 del capítulo 41](../capitulo-41-busqueda-y-planificacion/soluciones.md#10), que es el de los cubos con
otra descripción. Allí aparece la diferencia:

<!-- contexto: capitulo-71/sin_pinza.pl -->
```prolog
?- once(planificar(sin_pinza, sussman, [sobre(a, b), sobre(b, c)], 6, Plan)).
Plan = [mover(c, a, mesa), mover(b, mesa, c), mover(a, mesa, b)].

?- medios_fines(sussman, [sobre(a, b), sobre(b, c)], Plan).
Plan = [mover(c, a, mesa), mover(b, mesa, a), mover(b, a, c), mover(a, mesa, b)].
```

Las mediciones, en esta máquina y con las bibliotecas ya cargadas:

| Mundo | Metas | WARPLAN | Medios y fines |
|---|---|---|---|
| con pinza | `sobre(a, b)`, `sobre(b, c)` | 6 acciones, 115 765 inferencias | 6 acciones, 130 827 inferencias |
| sin pinza | `sobre(a, b)`, `sobre(b, c)` | 3 acciones, 11 530 inferencias | 4 acciones, 17 076 inferencias |
| sin pinza | `sobre(b, c)`, `sobre(a, b)` | 3 acciones, 10 640 inferencias | 4 acciones, 13 786 inferencias |
| cubos (con variables) | `sobre(a, b)`, `sobre(b, c)` | 3 acciones, 5 455 inferencias | — |

Con pinza, la intercalación no hace falta: el plan de medios y fines ya es
el más corto, y los dos cuestan lo mismo. Sin pinza, WARPLAN da el plan de
tres acciones que el análisis de medios y fines no puede construir, y
cuesta menos. La última fila es el mismo mundo y el mismo planificador con
la descripción de `cubos.pl`: menos de la mitad de las inferencias. Los operadores del
[capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) generan cada acción sin variables, y para lograr
`libre(a)` el planificador prueba cada bloque y cada destino; con
`mover(U, a, W)`, la precondición `sobre(U, a)` liga U al cubo que
realmente está sobre a. Sin la cota, con los operadores de ese capítulo,
con pinza y sin ella, la búsqueda de WARPLAN agota la pila: la
descripción con variables es la que el algoritmo de Warren supone.

!!! example "Patrón 69 — Descripción del mundo como parámetro"
    **Problema.** Un planificador tiene que servir para más de un mundo
    —los cubos, el robot de STRIPS, el mundo con pinza del
    [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md)—, y algunos de esos mundos ya están descritos
    en otro formato.

    **Versión ingenua.** Escribir las acciones del mundo dentro del
    planificador, como cláusulas de la regresión, o copiar el planificador
    para cada mundo; y, para un mundo que ya existe, reescribir su
    descripción, cláusula por cláusula, en el formato nuevo, con dos copias que hay que
    mantener iguales.

    **Patrón.** El planificador recibe el nombre del módulo del mundo como
    primer argumento de `planificar/5` y solo llama a un conjunto fijo de
    predicados descriptivos: `agrega/2`, `borra/2`, `puede/2`,
    `imposible/1`, `siempre/1`, `prueba/1` y `dado/2`, siempre como
    `Mundo:agrega(H, A)`. Otro mundo es otro módulo con los mismos siete
    predicados: `robot.pl` los define en parte con reglas, y el mismo
    código planifica en los dos. Una descripción existente se reutiliza con
    una traducción pequeña: `pinza.pl` carga los operadores STRIPS del
    [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) en un módulo propio y define `agrega/2`, `borra/2`,
    `puede/2` y `dado/2` con una o dos líneas cada uno, sin copiar el
    mundo. Se diferencia del
    [Patrón 54](../patrones.md#54-la-frontera-decide-la-estrategia), en el
    que el problema es fijo y la estrategia de búsqueda es el parámetro, y
    del [Patrón 60](../patrones.md#60-interprete-con-conducta-como-parametro),
    en el que la estructura es fija y el parámetro da el significado de sus
    piezas: aquí el algoritmo y su significado son fijos, y lo que varía
    son los datos sobre los que razona, una descripción de varias
    relaciones y no una sola función de sucesores.

    **Cuándo no usarlo.** Cuando hay un solo mundo y no se espera otro: la
    llamada calificada y la interfaz fija agregan una indirección sin
    beneficio. Cuando la traducción deja de ser pequeña: la versión 4 mide
    que los operadores sin variables del
    [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) cuestan más del doble
    de inferencias que `cubos.pl`, y sin la cota agotan la pila; un mundo
    que el planificador recorre mal se describe de nuevo, con variables.
    Y cuando el mundo necesita algo que la interfaz no expresa, como
    acciones con costo o efectos que dependen del estado: entonces cambia
    la interfaz, y con ella todos los mundos.

El capítulo continúa en la página
[Más allá de WARPLAN](extensiones.md#717-mas-alla-de-warplan), con tres
partes de sus fuentes que las cuatro versiones no cubren: los planes
condicionales, el control de ciclos y el mundo de las llaves y las cajas.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

11. **(2)** Declarar combinaciones imposibles para el mundo con pinza —la
    pinza vacía y sosteniendo un bloque, dos bloques sostenidos, un bloque
    sostenido y apoyado, un bloque en dos lugares, un bloque con algo encima
    y libre— y medir cómo cambian las inferencias de la versión 2 en la
    anomalía, en los dos órdenes de las metas.

## Referencias

- David H. D. Warren, *WARPLAN: a system for generating plans*, Memo 76
  del Department of Computational Logic, Universidad de Edimburgo, 1974 —
  apartados «The 3 blocks problem», «Specifying a problem»,
  «Implementation of the system», «Deficiencies of the system» y
  «Completeness and irredundancy».
  [Copia del Software Preservation Group](https://www.softwarepreservation.org/projects/prolog/edinburgh/doc/Warren-WARPLAN_A_System_for_Generating_Plans-1974_06.pdf/view).
  Es el planificador que esta página compara con el análisis de medios y
  fines; la descripción con variables es la que su algoritmo supone.
- Richard E. Fikes y Nils J. Nilsson, «STRIPS: a new approach to the
  application of theorem proving to problem solving», *Artificial
  Intelligence* 2, 1971.
  [Copia del autor](https://ai.stanford.edu/~nilsson/OnlinePubs-Nils/PublishedPapers/strips.pdf).
  Origen de los operadores con precondiciones, lista de agregados y lista
  de borrados; el formalismo es el del
  [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md), que esta
  página traduce.
