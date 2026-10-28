# Números de descripción y la máquina universal

Esta página continúa el [capítulo 53](index.md) después de la
[sección 53.5](index.md#535-la-tabla-completa), con las secciones
[53.6](#536-numeros-de-descripcion) y [53.7](#537-la-maquina-universal): la
forma estándar de una máquina, su descripción estándar y su número de
descripción, de la sección 5 del artículo de Turing, y la máquina universal
de sus secciones 6 y 7. Los ejemplos de la [sección 53.6](#536-numeros-de-descripcion) están en
`numeros.pl`, en `ejemplos/capitulo-53/`, con sus pruebas; el módulo carga
la versión 5, `completa.pl`, y usa su expansión.

## 53.6 Números de descripción

### La forma estándar

En la sección 5 Turing lleva cada tabla a una **forma estándar**, en la
que cada instrucción imprime un símbolo —el mismo que lee, si no cambia
nada— y después mueve el cabezal a la izquierda, a la derecha o no lo
mueve. Una fila con más operaciones se parte en varias, con
configuraciones nuevas. `numeros.pl` escribe la instrucción estándar como
`e(W, Mov)` y nombra cada configuración auxiliar con un término,
`resto(Ops, Q1)`: la que todavía tiene que ejecutar las operaciones Ops y
después pasar a Q1. La expansión de la versión 5 la trata como a
cualquier otra, con `estandar/5` como relación de paso:

<!-- ejemplo: capitulo-53/numeros.pl predicado: estandar/5 grupo/5 -->
```prolog
%!  estandar(+M, +Q, +S, -Accion, -Q1) is semidet.
%
%   Desde Q leyendo S, la máquina M ejecuta la instrucción estándar
%   Accion = e(W, Mov) y pasa a Q1. Q puede ser una configuración de M o
%   una auxiliar resto(Ops, Q2).
estandar(M, Q, S, e(W, Mov), Q1) :-
    (   Q = resto(Ops, Q2)
    ->  true
    ;   transicion(M, Q, S, Ops, Q2)
    ),
    grupo(Ops, S, W, Mov, Resto),
    (   Resto == []
    ->  Q1 = Q2
    ;   Q1 = resto(Resto, Q2)
    ).

%!  grupo(+Ops0:list, +S, -W, -Mov, -Ops:list) is det.
%
%   La primera instrucción estándar de las operaciones Ops0, leyendo S,
%   imprime W y mueve Mov; quedan las operaciones Ops.
grupo(Ops0, S, W, Mov, Ops) :-
    (   Ops0 = [p(X)|Ops1]
    ->  W = X
    ;   Ops0 = [e|Ops1]
    ->  W = blanco
    ;   W = S,
        Ops1 = Ops0
    ),
    (   Ops1 = [l|Ops]
    ->  Mov = l
    ;   Ops1 = [r|Ops]
    ->  Mov = r
    ;   Mov = n,
        Ops = Ops1
    ).
```

### La descripción estándar y el número

La tabla estándar de la máquina II tiene 15 configuraciones y 70
instrucciones: la fila inicial, de diez operaciones, se parte en seis.
Después, Turing numera las configuraciones desde q₁, la inicial, y los
símbolos desde S₀, el blanco, con S₁ = 0 y S₂ = 1; escribe cada
instrucción con la letra D seguida de A repetida i veces para qᵢ y de C
repetida j veces para Sⱼ, y obtiene la **descripción estándar**. Una
gramática del [capítulo 22](../capitulo-22-gramaticas-dcg/index.md) la
escribe:

<!-- ejemplo: capitulo-53/numeros.pl predicado: instrucciones//3 letras//2 -->
```prolog
%!  instrucciones(+Is:list, +Es:list, +Ss:list)// is det.
%
%   Las instrucciones Is escritas en la descripción estándar, con las
%   configuraciones numeradas por su posición en Es y los símbolos por
%   su posición en Ss, desde 0.
instrucciones([], _, _) -->
    [].
instrucciones([i(Q, S, e(W, Mov), Q1)|Is], Es, Ss) -->
    { once(nth1(I, Es, Q)),
      once(nth0(J, Ss, S)),
      once(nth0(K, Ss, W)),
      once(nth1(N, Es, Q1))
    },
    "D", letras(0'A, I), "D", letras(0'C, J), "D", letras(0'C, K),
    movimiento(Mov),
    "D", letras(0'A, N), ";",
    instrucciones(Is, Es, Ss).

%!  letras(+C, +N:integer)// is det.
%
%   N veces el carácter de código C.
letras(C, N) -->
    (   { N =:= 0 }
    ->  []
    ;   [C],
        { N1 is N - 1 },
        letras(C, N1)
    ).
```

Reemplazando A, C, D, L, R, N y ; por 1 a 7 se obtiene el **número de
descripción**, un entero que describe la máquina entera:

```prolog
?- descripcion(i, b, [0, 1], SD).
SD = "DADDCRDAA;DAADDRDAAA;DAAADDCCRDAAAA;DAAAADDRDA;".

?- numero(i, b, [0, 1], N).
N = 31332531173113353111731113322531111731111335317.
```

Los dos son los que Turing calcula para la máquina I al final de la
sección 5. Las configuraciones se numeran en el orden de la expansión, y
por eso el número depende también de él; Turing señala que una misma
sucesión tiene muchos números de descripción. La tabla de `contador` no
tiene número: `numero/4` falla, porque su tabla completa no termina. A
partir de aquí el artículo construye la máquina universal, que lee la
descripción estándar de otra máquina en su cinta y calcula lo mismo que
ella; el ejercicio 11 da un paso en esa dirección, en Prolog: ejecuta una
máquina a partir de su número.

## 53.7 La máquina universal

En la sección 6 del artículo Turing usa el número de descripción para
algo más que enumerar máquinas: describe una sola máquina 𝔘 que, con la
descripción estándar de otra máquina ℳ escrita al comienzo de la cinta,
calcula la misma sucesión que ℳ. 𝔘 escribe en las casillas F, una tras
otra y separadas por dos puntos, las configuraciones completas de ℳ en la
forma de la página 235 —la cinta con la configuración m escrita delante
del símbolo leído—, codificadas con las mismas letras de la descripción
estándar; y entre dos configuraciones escribe la figura que ℳ imprime,
seguida de dos puntos. La sección 7 da la tabla de 𝔘 escrita con las
funciones de configuración de la sección 4, más una nueva, 𝔠𝔬𝔫, que marca
una configuración. La versión 7, `universal.pl`, es esa tabla, con la
biblioteca de la [sección 53.3](index.md#533-la-biblioteca-de-funciones-de-configuracion)
y el intérprete de la versión 2: 𝔘 es una máquina más, escrita con alias
y tablas.

La cinta de 𝔘 empieza con ə ə; siguen, en las casillas F, las
instrucciones de ℳ, y el símbolo `'::'`, una sola casilla, que cierra la
descripción. Las letras son los átomos `'A'`, `'C'`, `'D'`, `'L'`, `'R'`,
`'N'` y `';'`, y las marcas de 𝔘 son u, v, w, x, y y z. Cada paso de ℳ le
cuesta a 𝔘 siete tareas, cada una con su configuración m:
`anf` marca con y la última configuración completa; `kom` busca hacia la
izquierda el punto y coma de una instrucción que todavía no probó, lo
marca con z y marca con x la configuración de esa instrucción; `kmp`
compara lo marcado con x y con y; `sim` marca lo que la instrucción
imprime y hacia dónde se mueve; `mk` parte la configuración completa en
cuatro trozos marcados; `sh` imprime la figura, si la hay; e `inst` copia
los trozos al final, en el orden que pide el movimiento:

<!-- ejemplo: capitulo-53/universal.pl fragmento: plana:fila(universal, kom, simbolo(';'), [r, p(z), l], con(kmp, x)). .. perezosa:alias(universal, kmp, cpe(e(e(anf, x), y), sim, x, y)). -->
```prolog
plana:fila(universal, kom, simbolo(';'), [r, p(z), l], con(kmp, x)).
plana:fila(universal, kom, simbolo(z), [l, l], kom).
plana:fila(universal, kom, no(z), [l], kom).
plana:fila(universal, kom, blanco, [l], kom).

% kmp: compara lo marcado con x y con y; -> sim si son iguales.
% CORRECCIÓN (Davies, p. 116; Petzold, p. 155): si son distintas, la
% comparación ya borró parte de las marcas y; se borran todas las x y las
% y y se vuelve a anf, que marca de nuevo la configuración; Turing vuelve
% a kom. kom sigue después del último punto y coma marcado con z.
perezosa:alias(universal, kmp, cpe(e(e(anf, x), y), sim, x, y)).
```

<!-- ejemplo: capitulo-53/universal.pl fragmento: plana:fila(universal, inst1, simbolo('L'), [r, e], ce5(ov, v, y, x, u, w)). .. plana:fila(universal, inst1, simbolo('N'), [r, e], ce5(ov, v, x, y, u, w)). -->
```prolog
plana:fila(universal, inst1, simbolo('L'), [r, e], ce5(ov, v, y, x, u, w)).
plana:fila(universal, inst1, simbolo('R'), [r, e], ce5(ov, v, x, u, y, w)).
plana:fila(universal, inst1, simbolo('N'), [r, e], ce5(ov, v, x, y, u, w)).
```

Con el movimiento a la izquierda, la configuración nueva es lo marcado
con v, la configuración m final (y), el símbolo que precedía a la
configuración m (x), el símbolo impreso (u) y el resto (w); con el
movimiento a la derecha, el símbolo impreso pasa antes de la
configuración m. `cinta_universal/2` prepara la cinta a partir de la
descripción estándar de la [sección 53.6](#536-numeros-de-descripcion), y
`figuras_universal/3` ejecuta 𝔘 hasta que imprime N figuras:

```prolog
?- descripcion(i, b, [0, 1], SD), figuras_universal(SD, 4, Fs).
SD = "DADDCRDAA;DAADDRDAAA;DAAADDCCRDAAAA;DAAAADDRDA;",
Fs = [0, 1, 0, 1].

?- universal(i_bis, b, [0, 1], 4, Fs), figuras(i_bis, b, 4, Gs).
Fs = Gs, Gs = [0, 1, 0, 1].

?- escrito_universal(i, b, [0, 1], 50000, T).
T = ":DAD:0:DCDAAD:DCDDAAAD:1:DCDDCCDAAAAD".
```

`escrito_universal/5` muestra lo que 𝔘 escribió después de `::` en los
primeros 50 000 pasos. La primera configuración completa es `DAD`: la
configuración m q₁ (`DA`) leyendo un blanco (`D`). La instrucción
`DADDCRDAA` imprime el símbolo 1, la figura 0, y mueve a la derecha, así
que 𝔘 escribe `0:` y la configuración siguiente, `DCDAAD`: la figura 0
(`DC`) y después q₂ leyendo un blanco. Así sigue: `DCDDAAAD` es 0, un
blanco y q₃.

**Las correcciones.** La tabla publicada no se ejecuta tal como está.
La corrección que Turing publicó en 1937 trata de la demostración de la
sección 11 y no toca la tabla de 𝔘. Los errores de la tabla los enumera
Emil Post en la nota 11 del apéndice de su artículo de 1947 (p. 7; p. 97
de la reimpresión en *The Essential Turing*); Donald W. Davies, que los
encontró en 1947 mientras trabajaba en el equipo de Turing, publicó sus
correcciones en 2004, en ese mismo libro; y Petzold las reúne en el
capítulo «The Universal Machine» de *The Annotated Turing*. `universal.pl`
señala cada corrección con un comentario `CORRECCIÓN` que nombra la
fuente; las páginas de Davies son las de *The Essential Turing*:

- 𝔠𝔬𝔫₁ no prevé una configuración que termina en la configuración m, es
  decir, que lee un blanco más allá del final; la fila que falta escribe
  la `D` (Post, nota 11; Petzold, p. 152). Davies corrige el mismo defecto
  de otro modo, en 𝔟₁ y en 𝔦𝔫𝔰𝔱₁(R) (pp. 116–117).
- Si la comparación de `kmp` falla, ya borró parte de las marcas y; se
  borran todas las x y las y y se vuelve a `anf`, que marca de nuevo la
  configuración. Turing vuelve a `kom`, y la comparación siguiente
  encontraría la configuración sin sus marcas y (Davies, p. 116;
  Petzold, p. 155).
- La segunda fila de `sim2` empieza con L y no con R: 𝔠𝔬𝔫 deja el cabezal
  en la casilla F que sigue a la `D` del símbolo impreso, y `sim2` marca
  la casilla F anterior a la que lee (Post, nota 11; Davies, p. 118;
  Petzold, p. 157).
- `mk` sigue en `mk1`, no en `mk` (Post, nota 11; Davies, p. 118;
  Petzold, p. 157), y `sh2`, al leer una `D`, sigue en `sh3`, no en
  `sh2` (Post, nota 11; Petzold, p. 159).
- La descripción estándar empieza con punto y coma y no termina con él,
  porque `kom` reconoce una instrucción por el punto y coma que la precede
  (Post, nota 11; Davies, pp. 113 y 118; Petzold, p. 150).

Además, la tabla escribe 𝔤 donde corresponde 𝔮, la función que busca el
último símbolo, y usa 𝔠𝔢₅ sin definirla (Davies, pp. 118 y 123; Petzold,
pp. 154 y 160); `universal.pl` usa `q` y define `ce4` y `ce5` como `ce3`.

**El costo.** Medidos con `medir/6` de la versión 4, con la cinta de 𝔘:

| Máquina simulada | Letras de la descripción | Figuras | Pasos de 𝔘 | Inferencias |
|---|---:|---:|---:|---:|
| una instrucción, `DADDCRDA;` | 9 | 6 | 30 428 | 8,0 millones |
| I | 47 | 2 | 39 927 | 12,8 millones |
| I | 47 | 4 | 145 286 | 44,7 millones |
| I | 47 | 8 | 774 746 | 229 millones |
| II | 1 825 | 1 | 27 308 856 | 8 291 millones |

Cada paso de ℳ obliga a 𝔘 a recorrer la cinta varias veces: `kom` va de
la última configuración hasta las instrucciones, y cada comparación de
`cpe` vuelve a buscar las marcas desde ə. Como la cinta crece con cada
configuración escrita, el costo por figura crece también. La descripción
de la máquina II tiene 1 825 letras, y 𝔘 necesita más de 27 millones de
pasos, casi veinticinco minutos en esta máquina, para imprimir su primera
figura: cada instrucción que `kom` prueba y descarta cuesta un recorrido
de toda la descripción.

!!! question "Actividad"
    Escribir la cinta inicial de 𝔘 para la máquina de una instrucción
    `DADDCRDA;` y predecir las tres primeras configuraciones completas que
    escribe. Comprobarlo con `cinta_universal/2`, `ejecutar/5` y
    `escrito/2`.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `paso/6`, `seleccionar/7` y `figuras/4` son `semidet` porque una máquina puede detenerse, y `ejecutar/5`, que informa la detención, es `det` |
    | C2 | la unificación liga los parámetros de las reglas: una fila con una variable libre en la condición es la «totalidad de líneas» de Turing, sin código aparte; `configuraciones/5` es pura, y solo `traza/4` escribe |
    | C4 | el intérprete elige la primera fila con `once/1` y sigue la máquina con `->`: no deja alternativas pendientes, y las pruebas lo verifican |
    | C5 | cada condición y cada resultado tiene su functor (`blanco`, `simbolo/1`, `no/1`, `siempre`; `detenida/2`, `limite/2`; `tabla/2`, `incompleta/1`), y las configuraciones auxiliares de la forma estándar son términos, no nombres generados |
    | C7 | 128 pruebas en nueve archivos, con los casos de los escenarios del repositorio del autor, la traza de la página 235, el número de descripción de la sección 5, y la tabla completa comparada con la ejecución perezosa |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio.

9. **(1)** Escribir la tabla de una máquina `tres` que calcule
   001001001…, con tres configuraciones sin parámetros, y obtener su
   número de descripción. Explicar por qué su tabla estándar tiene más
   de tres configuraciones.
10. **(2)** Escribir `sd_numero/2`, que convierte una descripción estándar
   en su número y un número en su descripción, y una gramática
   `instrucciones_sd//1` que lee una descripción estándar y da la lista
   de instrucciones `i(I, J, K, Mov, M)` con números. Verificar la ida y
   la vuelta con la máquina II.
11. ★ **(3)** Escribir `figuras_dn(DN, N, Fs)`, que ejecuta la máquina
   cuyo número de descripción es DN y da sus primeras N figuras, sin
   conocer la máquina: el símbolo 0 es el blanco, el 1 es la figura 0 y
   el 2 es la figura 1. Verificarlo con el número de la máquina I y con
   el de la máquina II.
12. ★ **(2)** Escribir una máquina `reimprime` que imprima un 0 en una
    casilla en blanco, imprima un 1 sobre ese 0 sin moverse, avance dos
    casillas y vuelva a empezar. Comparar sus primeras cuatro figuras según
    `figuras/4` y según `universal/5`, y explicar la diferencia con las
    filas `sh2` a `sh5` de la [sección 53.7](#537-la-maquina-universal).
13. **(2)** La máquina `corta` imprime un 0, avanza y pasa a una
    configuración sin filas: se detiene. Predecir qué hace 𝔘 con su
    descripción estándar, comprobarlo con `ejecutar/5` y un límite de
    pasos, y explicar por qué 𝔘 no puede informar que la máquina
    simulada se detuvo.

## Resumen

| | |
|---|---|
| **configuración m** | el estado de la máquina; aquí, cualquier término |
| **fila** | `fila(M, Q, Condicion, Operaciones, Q1)`; condiciones `blanco`, `simbolo(S)`, `no(S)`, `siempre`; operaciones `p(S)`, `e`, `l`, `r`; se aplica la primera que se cumple |
| **función de configuración m** | una tabla con parámetros, como `f(C, B, Al)`; la unificación los liga |
| **alias** | `alias(M, Q, Q1)`: reescribe una configuración sin tocar la cinta |
| **reescritura perezosa** | resolver la configuración con los alias al dar cada paso; se construyen solo los términos que el cómputo visita |
| **tabla completa** | la tabla sin parámetros, por sustitución repetida; su expansión termina solo si las configuraciones alcanzables son finitas |
| **forma estándar** | cada instrucción imprime un símbolo y mueve a lo sumo una casilla; las filas largas se parten con configuraciones `resto(Ops, Q1)` |
| **descripción estándar, número de descripción** | la tabla estándar escrita con D, A, C, L, R, N y ;, y ese texto con dígitos |
| **cinta** | `c(Izquierda, Actual, Derecha)`, con la parte izquierda al revés |
| `figuras/4`, `sucesion/4`, `paso/6`, `ejecutar/5`, `cinta_de/3`, `contenido/2` | ejecutar una máquina |
| `resolver/4`, `seleccionar/7` | los alias y la elección de la fila |
| `configuraciones/5`, `traza/3`, `medir/4`, `tamano/2` | la traza y la medida |
| `completa/5`, `cuantas/5`, `expandir/5`, `figuras_tabla/3` | la tabla completa |
| `estandar/5`, `tabla_estandar/4`, `descripcion/4`, `numero/4` | la sección 5 |
| **máquina universal** | 𝔘: con la descripción estándar de ℳ en la cinta, escribe las configuraciones completas de ℳ y calcula su sucesión |
| `cinta_universal/2`, `figuras_universal/3`, `universal/5`, `escrito/2`, `escrito_universal/5` | las secciones 6 y 7 |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Un intérprete de un lenguaje funcional, cuyas expresiones se evalúan reescribiendo términos | [capítulo 58](../capitulo-58-proyecto-interprete-funcional/index.md) |
| Reglas elegidas por un patrón que se unifica con el estado, sobre una base de datos en lugar de una cinta | [capítulo 61](../capitulo-61-proyecto-interprete-dirigido-patrones/index.md) |

## Referencias

- A. M. Turing, «On Computable Numbers, with an Application to the
  Entscheidungsproblem», *Proceedings of the London Mathematical Society*
  (2) 42, 1936–37, pp. 230–265
  ([DOI 10.1112/plms/s2-42.1.230](https://doi.org/10.1112/plms/s2-42.1.230)),
  §5 «Enumeration of computable sequences», §6 «The universal computing
  machine» y §7 «Detailed description of the universal machine». Esta
  página toma de §5 la forma estándar, la descripción estándar y el número
  de descripción de la máquina I; y de §6 y §7, la máquina universal: la
  cinta con la descripción estándar y las configuraciones completas
  separadas por dos puntos, y su tabla, con la función 𝔠𝔬𝔫.
- Cesar Ballardini, *turing-lazy-term-rewriting-interpreter*, repositorio
  en GitHub, 2026, licencia MIT
  ([github.com/CesarBallardini/turing-lazy-term-rewriting-interpreter](https://github.com/CesarBallardini/turing-lazy-term-rewriting-interpreter)),
  en particular `docs/lazy-term-rewriting-interpreter.md`, «The lazy
  term-rewriting interpreter». Esta página toma de allí la expansión de las
  filas largas a instrucciones estándar y la codificación a partir de la
  tabla expandida.
- A. M. Turing, «On Computable Numbers, with an Application to the
  Entscheidungsproblem. A Correction», *Proceedings of the London
  Mathematical Society* (2) 43, 1937, pp. 544–546
  ([DOI 10.1112/plms/s2-43.6.544](https://doi.org/10.1112/plms/s2-43.6.544)),
  reimpreso en *The Essential Turing*, pp. 94–96. Corrige la demostración
  de la sección 11 y la representación de los números computables; no
  trata la tabla de la máquina universal. La
  [sección 53.7](#537-la-maquina-universal) lo menciona para dejar
  constancia de que las correcciones de 𝔘 no son de Turing.
- Charles Petzold, *The Annotated Turing: A Guided Tour through Alan
  Turing's Historic Paper on Computability and the Turing Machine*, Wiley,
  2008, ISBN 978-0-470-22905-7, los capítulos «Everything Is a Number»
  (pp. 127–142) y «The Universal Machine» (pp. 143–161). Es la lectura
  comentada, línea por línea, del artículo. Del capítulo «The Universal
  Machine», esta página toma la lectura de la tabla de 𝔘 y las
  correcciones que la [sección 53.7](#537-la-maquina-universal) aplica, con
  la página de cada una.
- Emil L. Post, «Recursive Unsolvability of a Problem of Thue», *The
  Journal of Symbolic Logic* 12(1), marzo de 1947, pp. 1–11
  ([DOI 10.2307/2267170](https://doi.org/10.2307/2267170)). El apéndice,
  pp. 7–11, es la primera crítica publicada del artículo de Turing, y su
  nota 11, en la p. 7, enumera los errores de la tabla de la máquina
  universal; el apéndice está reimpreso, con la nota incorporada al texto,
  en *The Essential Turing*, pp. 97–101. Esta página toma de allí las
  correcciones de 𝔠𝔬𝔫₁, `sim2`, `mk` y `sh2`, y el punto y coma delante de
  cada instrucción.
- Donald W. Davies, «Corrections to Turing's Universal Computing
  Machine», en B. Jack Copeland (ed.), *The Essential Turing*, Oxford
  University Press (Clarendon Press), 2004, ISBN 0-19-825080-0,
  pp. 103–124. Davies encontró los errores en 1947 y probó en una
  computadora una versión corregida de la máquina universal. Esta página
  toma de allí la corrección de `kmp` (§8, p. 116), la otra forma de
  agregar la `D` del blanco (pp. 116–117) y la lista de errores menores
  (§10, p. 118, y §14, pp. 122–124).

El código del capítulo es propio del curso, escrito en Prolog siguiendo el
diseño del intérprete en Python del autor.
