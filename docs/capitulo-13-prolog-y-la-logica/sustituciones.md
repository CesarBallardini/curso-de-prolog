# Sustituciones y unificadores

Esta página continúa la página
[Qué afirma un programa y cómo se prueba](inferencia.md#137-como-prueba-prolog)
del [capítulo 13](index.md), con las secciones [13.8](#138-sustituciones) y
[13.9](#139-unificadores-y-el-unificador-mas-general): qué es una
sustitución, cómo se aplica a un término y
cómo se componen dos de ellas, y qué es el unificador más general de dos
términos, el que Prolog calcula en cada arco del árbol de derivación. Las
consultas con `=` de la página están en `unificadores.pl`, en
`ejemplos/capitulo-13/`, con sus pruebas.

## 13.8 Sustituciones

Las etiquetas de los árboles de derivación llevan, desde la
[sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion),
conjuntos como `{ A/juan, N/Quien }`. Esta sección les da nombre y define las
dos operaciones que el curso hizo con ellos sin enunciarlas: aplicarlos y
juntarlos.

Una **sustitución** es un conjunto finito de pares `Variable/término`, con a lo
sumo un par por variable. Tres ejemplos:

| Sustitución | Qué liga |
|---|---|
| `{ X/juan, Y/noe }` | dos variables a dos constantes |
| `{ W/Z, R/empleado(T, 1200) }` | una variable a otra variable, y una a un término compuesto con una variable adentro |
| `{ Q/[], X/[Y, Z] }` | una variable a la lista vacía, y otra a la lista de dos elementos `[Y, Z]`, que no es `[Y\|Z]` |

El término de un par puede ser cualquier término: una constante, una variable,
un término compuesto. No son sustituciones `{ X/a, X/b }`, porque tiene dos
pares para `X`, ni `{ a/X }`, porque `a` no es una variable. El conjunto sin
pares, `{ }`, también es una sustitución: la **sustitución vacía**, que se
escribe ε y que etiqueta cada paso de la refutación sin
variables de la [sección 13.7](inferencia.md#una-refutacion-sin-variables): un programa
sin variables no liga nada.

**Aplicación.** Aplicar una sustitución θ a un término o a una fórmula $P$,
lo que se escribe $P\theta$, consiste en reemplazar cada aparición de cada
variable ligada por su término, todas a la vez; las variables que θ no liga
quedan como están. Con θ₁ = `{ A/juan, N/Quien }`, el paso 1 del árbol de la
[sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion) es una aplicación:

| $P$ | $P\theta_1$ |
|---|---|
| `abuelo(A, N)` | `abuelo(juan, Quien)` |
| `padre(A, P), padre(P, N)` | `padre(juan, P), padre(P, Quien)` |
| `padre(P, N)` | `padre(P, Quien)` |

«Todas a la vez» importa cuando el término de un par contiene una variable que
otro par liga: con θ = `{ X/Y, Y/a }`, `p(X, Y)θ` es `p(Y, a)`, y no
`p(a, a)`. La `Y` que introduce el primer par no se vuelve a reemplazar en la
misma aplicación.

Prolog no muestra nunca una sustitución: muestra su efecto sobre los términos
de la consulta. La consulta siguiente construye el mismo término que el paso 1
del árbol, ligando las variables de a una:

<!-- contexto: capitulo-13/unificadores.pl -->
```prolog
?- T = abuelo(A, N), A = juan, N = Quien.
T = abuelo(juan, Quien),
A = juan,
N = Quien.
```

**Instancia.** $Q$ es una **instancia** de $P$ cuando existe una sustitución
θ con $P\theta = Q$. `padre(juan, ana)` es instancia de `padre(X, Y)`, con
θ = `{ X/juan, Y/ana }`; de `padre(juan, Y)`, con `{ Y/ana }`; y de sí mismo,
con ε. No es instancia de `padre(X, X)`: una sola variable no puede ser a la
vez juan y ana. Una variable sola tiene a todo término como instancia. Cuando
$Q$ es instancia de $P$ se dice que $P$ es **más general** que $Q$; la
sección siguiente usa la palabra. El modus ponens de la
[sección 13.7](inferencia.md#137-como-prueba-prolog) se aplicó a una instancia de la
regla de `madre/2`, la que resulta de `{ M/marta }`.

**Composición.** Las ramas del árbol aplican una sustitución tras otra, y la
respuesta las junta. La **composición** θσ de dos sustituciones es la
sustitución que hace en un solo paso lo que hacen θ y después σ, y se calcula
así:

1. se aplica σ a los términos de los pares de θ;
2. se agregan los pares de σ cuya variable θ no liga;
3. se eliminan los pares que hayan quedado de la forma `X/X`.

Con θ = `{ X/f(W), Y/X }` y σ = `{ Y/Z, X/a, W/g(a) }`:

| Paso | Resultado |
|---|---|
| 1. σ aplicada a `f(W)` y a `X` | `{ X/f(g(a)), Y/a }` |
| 2. los pares de σ que θ no liga: solo `W/g(a)`, porque θ liga `X` e `Y` | `{ X/f(g(a)), Y/a, W/g(a) }` |
| 3. ningún par es trivial | θσ = `{ X/f(g(a)), Y/a, W/g(a) }` |

La composición en el otro orden, σθ, aplica θ a los términos `Z`, `a` y
`g(a)`, que no cambian, y no agrega ningún par de θ porque σ ya liga `X` e
`Y`: σθ = σ. El orden importa: θσ y σθ son distintas. Una comprobación sobre
un término muestra que la regla hace lo que promete: `p(X, Y, W)θ` es
`p(f(W), X, W)`, que con σ queda `p(f(g(a)), a, g(a))`; y `p(X, Y, W)` con θσ
directamente da el mismo término. En general $(P\theta)\sigma = P(\theta\sigma)$,
la composición es asociativa, $(\theta\sigma)\gamma = \theta(\sigma\gamma)$, y
la sustitución vacía no cambia nada: $\theta\varepsilon = \varepsilon\theta =
\theta$.

!!! question "Actividad"
    Con θ = `{ X/g(Y), Y/b }` y σ = `{ Y/c, Z/X }`, calcular θσ y σθ, y
    aplicar las dos a `p(X, Y, Z)`. Comprobar que `p(X, Y, Z)` con θ y después
    con σ da el mismo término que con θσ, y que con σθ da otro.

**Para qué sirve.** La respuesta de una rama de éxito es la composición de las
sustituciones de sus arcos, restringida a las variables de la consulta. En la
rama de éxito de la [sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion), θ₁θ₃θ₄ se calcula de a dos:

| | |
|---|---|
| θ₁θ₃ = `{ A/juan, N/Quien }{ P/pedro }` | `{ A/juan, N/Quien, P/pedro }` |
| (θ₁θ₃)θ₄ = `{ A/juan, N/Quien, P/pedro }{ Quien/luis }` | `{ A/juan, N/luis, P/pedro, Quien/luis }` |

Restringida a `Quien`, la única variable de la consulta, la composición es
`{ Quien/luis }`: la respuesta `Quien = luis`. Es lo que la [sección 5.2](../capitulo-05-como-responde-prolog/index.md#52-el-arbol-de-derivacion) llamó
«juntar todas las sustituciones», y lo que la hoja de éxito del árbol de la
[sección 6.4](../capitulo-06-recursion/index.md#64-la-suma) muestra: allí la
primera sustitución liga `Cuanto` a `s(C)`, un término con una variable
adentro, y la última liga esa `C`, de modo que
`{ Cuanto/s(C) }{ C/s(s(cero)) }` es `{ Cuanto/s(s(s(cero))), C/s(s(cero)) }`
y la respuesta es `Cuanto = s(s(s(cero)))`. El
[capítulo 39](../capitulo-39-semantica-de-los-programas-logicos/resolucion.md#resolucion-sld)
llama a esa composición restringida la respuesta calculada.

## 13.9 Unificadores y el unificador más general

Una sustitución θ es un **unificador** de dos términos, o de dos fórmulas
atómicas, $E_1$ y $E_2$ cuando $E_1\theta = E_2\theta$: aplicada a los dos,
los vuelve idénticos. Cinco pares, con un unificador o la razón de que no
exista:

| $E_1$ | $E_2$ | Unificador |
|---|---|---|
| `padre(Z, diego)` | `padre(jorge, diego)` | `{ Z/jorge }` |
| `tio(X, diego)` | `tio(W, diego)` | `{ X/W }`; también `{ W/X }` y `{ X/guillermo, W/guillermo }` |
| `p(q(X, Y), X, h(4))` | `p(q(3, Z), W, h(Z))` | `{ X/3, Z/4, W/3, Y/4 }` |
| `r([X\|Y])` | `r([[a, b], c, d])` | `{ X/[a, b], Y/[c, d] }` |
| `r([X\|Y])` | `r([])` | ninguno: `[]` es una constante y `[X\|Y]` un término compuesto |

El tercer par se arma argumento por argumento, como en la
[sección 4.8](../capitulo-04-terminos-y-unificacion/index.md#48-la-unificacion-paso-a-paso):
`q(X, Y)` con `q(3, Z)` da `X/3` e `Y/Z`; `X` con `W`, ya con `X` ligada a 3,
da `W/3`; `h(4)` con `h(Z)` da `Z/4`, y con ella `Y/4`. Aplicado a los dos
términos, el unificador produce `p(q(3, 4), 3, h(4))` en ambos casos.

El segundo par muestra que un par de términos puede tener **muchos**
unificadores: `{ X/W }`, `{ W/X }`, `{ X/guillermo, W/guillermo }`,
`{ X/a, W/a }`, y uno por cada término que se quiera. Los dos primeros vuelven
idénticos a los términos sin decidir nada más; los demás deciden, además, quién
es el tío. Esa diferencia tiene un nombre: θ es **más general** que σ cuando
σ = θγ para alguna sustitución γ, es decir cuando σ se obtiene de θ ligando
algo más. En el ejemplo, `{ X/guillermo, W/guillermo }` = `{ X/W }{ W/guillermo }`
—la regla de la composición aplica `{ W/guillermo }` al término `W` del primer
par y agrega el par `W/guillermo`—, de modo que `{ X/W }` es más general. Y
`{ W/X }` = `{ X/W }{ W/X }`: el par `X/W` se vuelve `X/X` y se elimina, y se
agrega `W/X`. Cada uno de los dos es más general que el otro: difieren solo en
el nombre que conservan.

Un **unificador más general** de $E_1$ y $E_2$ es un unificador θ tal que
todo unificador σ de los dos términos es una instancia suya: σ = θγ para alguna
γ. Cuando existe un unificador, existe uno más general, y es único salvo el
nombre de las variables. Es lo que las cuatro reglas de la
[sección 4.7](../capitulo-04-terminos-y-unificacion/index.md#47-unificacion-las-cuatro-reglas)
calculan: la observación de la
[sección 4.8](../capitulo-04-terminos-y-unificacion/index.md#48-la-unificacion-paso-a-paso),
«la unificación liga lo mínimo indispensable», es exactamente esta propiedad.
`=` muestra el unificador más general de los dos lados, o informa que no
existe:

```prolog
?- padre(Z, diego) = padre(jorge, diego).
Z = jorge.

?- tio(X, diego) = tio(W, diego).
X = W.

?- p(q(X, Y), X, h(4)) = p(q(3, Z), W, h(Z)).
X = W, W = 3,
Y = Z, Z = 4.

?- r([X|Y]) = r([[a, b], c, d]).
X = [a, b],
Y = [c, d].

?- r([X|Y]) = r([]).
false.
```

En la tercera respuesta SWI-Prolog escribe el unificador como dos cadenas,
`X = W, W = 3` e `Y = Z, Z = 4`, que muestran qué variables quedaron ligadas
entre sí antes de recibir un valor; es la misma sustitución
`{ X/3, W/3, Y/4, Z/4 }`. La consulta siguiente, con dos listas, muestra lo que
el unificador más general deja sin ligar:

```prolog
?- [[X, 2], [Y]] = [A|[B|C]].
A = [X, 2],
B = [Y],
C = [].
```

`[A|[B|C]]` es `[A, B|C]`, y el lado izquierdo tiene dos elementos: `A` queda
ligada al primero, `B` al segundo y `C` al resto, que es la lista vacía. `X` e
`Y` siguen libres, porque nada obliga a ligarlas; `{ A/[X, 2], B/[Y], C/[],
X/1, Y/a }` también es un unificador, pero es una instancia de ese.

**Por qué el más general.** Cada arco del árbol de derivación lleva el
unificador más general del objetivo con la cabeza de la cláusula, y no otro.
En el árbol de `?- tiene_hijos(P).` de la
[sección 13.4](index.md#134-las-variables-y-los-cuantificadores), el primer
arco unifica `tiene_hijos(P)` con `tiene_hijos(P₁)` mediante `{ P₁/P }`. La
sustitución `{ P/juan, P₁/juan }` también unifica a los dos, pero decide quién
es `P` antes de mirar los hechos, y la rama perdería a marta y a pedro. Con el
más general, cada rama liga solo lo que la cláusula elegida obliga, y las
respuestas que se obtienen son todas las que existen: la completitud de la
[sección 13.7](inferencia.md#137-como-prueba-prolog) depende de esa elección.

Queda un caso que la definición excluye y Prolog acepta: `X` con `padre(X)` no
tiene unificador, porque ninguna sustitución vuelve idénticos a una variable y
a un término que la contiene, y `=` responde de todos modos. Es la diferencia
de la [sección 13.13](evaluacion.md#1313-lo-que-excede-la-logica), y la página
«Resolución SLD y SLDNF» del
[capítulo 39](../capitulo-39-semantica-de-los-programas-logicos/resolucion.md)
muestra la unificación que la comprueba.

El capítulo continúa en la página
[La evaluación de un programa y los límites de la lógica](evaluacion.md#1310-los-cuatro-pasos), que usa
el unificador más general en cada paso.
