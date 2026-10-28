# Verificar la tabla de consejos

Esta página continúa el [capítulo 80](index.md) después de la
[sección 80.6](index.md#806-version-6-la-tabla-de-finales), con las
secciones [80.7](#807-version-7-verificar-la-tabla) y
[80.8](#808-version-8-la-tabla-corregida): la verificación de la tabla de
consejos contra todas las defensas en todas las posiciones, las posiciones
en que ahoga al rey negro y la tabla corregida. Los ejemplos están en
`verificar.pl` y `corregida.pl`, en `ejemplos/capitulo-80/`, con sus
pruebas; los dos son `% solo-local`.

## 80.7 Versión 7: verificar la tabla

Las partidas de la [sección 80.5](index.md#805-version-5-jugar-con-la-tabla) prueban la tabla contra dos defensas,
una partida por posición. La versión 7 aplica el método de Bramer: el
conjunto de las posiciones desde las que el programa da mate contra
**cualquier** defensa, construido hacia atrás desde los mates, con un
árbol forzante entero como paso. Sobre las 175 168 posiciones con las
blancas a mover, la tabla de Bratko asegura el mate en 175 120, en a lo
sumo 34 jugadas; en las otras 48, un árbol termina en ahogado. Esta
sección desarrolla la versión, con dos de esas posiciones jugada por
jugada y los consejos que las producen.

!!! example "Patrón 82 — Verificar la estrategia hacia atrás"
    **Problema.** Hay que saber si una estrategia gana desde todas las
    posiciones contra cualquier defensa, y las partidas de prueba solo
    examinan las respuestas que alguna defensa elige.

    **Versión ingenua.** Jugar una partida por posición con unas pocas
    defensas: en las 27 352 posiciones normales, dos defensas encuentran
    10 ahogados, y las otras 38 posiciones en que la tabla ahoga quedan
    ocultas.

    **Patrón.** Construir hacia atrás, desde las posiciones terminales
    ganadas, el conjunto de las posiciones desde las que la estrategia
    gana contra todas las respuestas: una posición entra cuando todas sus
    salidas son victorias o posiciones que ya entraron. Si la estrategia
    tiene memoria, el paso es todo lo que juega sin volver a decidir, como
    un árbol forzante entero. Las posiciones que nunca entran son sus
    errores, y las pasadas dan también la partida más larga. Sobre las
    175 168 posiciones del final, `verificar/2` tarda dos minutos y medio
    y encuentra las 48.

    **Cuándo no usarlo.** Cuando el espacio de posiciones no cabe en
    memoria o no se puede enumerar: entonces solo queda probar la
    estrategia con partidas o demostrar su corrección.

Bramer propone verificar una estrategia sin jugar partidas, como dice el
[Patrón 82](../patrones.md#82-verificar-la-estrategia-hacia-atras): construir hacia
atrás, desde los mates, el conjunto de todas las posiciones desde las que
la estrategia gana contra cualquier defensa, como la tabla de finales,
pero con las blancas obligadas a jugar lo que la estrategia elige. Las
posiciones que quedan afuera son sus errores.

El programa de la [sección 80.5](index.md#805-version-5-jugar-con-la-tabla) tiene memoria: juega por un árbol hasta que
se termina. Por eso el paso de la verificación no es una jugada sino un
árbol entero. `salidas/3` recorre el árbol que la tabla da en una posición
contra **todas** las respuestas legales de las negras, no solo las que el
árbol prevé, y devuelve cómo termina cada camino: en mate, en una
falla, o en una posición nueva en la que se pedirá otro árbol, con la
cantidad de jugadas de las blancas:

<!-- ejemplo: capitulo-80/verificar.pl predicado: salidas/3 recorrer/4 respuesta/4 -->
```prolog
%!  salidas(+Tabla, +Posicion, -Salidas:list) is det.
%
%   Salidas son las maneras en que termina el árbol forzante que Tabla da
%   en Posicion, una por cada camino según las respuestas de las negras:
%   N-mate, si el camino termina en mate después de N jugadas de las
%   blancas; N-nueva(P), si termina en la posición P, con las blancas a
%   mover y sin árbol; N-falla(F), si termina en un ahogado o con la torre
%   capturada. Si la tabla no da ningún árbol, Salidas es
%   [0-falla(sin_consejo)].
salidas(Tabla, Posicion, Salidas) :-
    (   estrategia(Tabla, Posicion, _, Arbol)
    ->  findall(S, recorrer(Posicion, Arbol, 0, S), Salidas)
    ;   Salidas = [0-falla(sin_consejo)]
    ).

%!  recorrer(+Posicion, +Arbol, +N0:integer, -Salida) is nondet.
%
%   Salida es una de las maneras en que termina Arbol, que empieza en
%   Posicion, con las blancas a mover y N0 jugadas hechas.
recorrer(P, juega(J, A), N0, S) :-
    jugada(P, J, P1),
    N is N0 + 1,
    respuesta(P1, A, N, S).

%!  respuesta(+Posicion, +Arbol, +N:integer, -Salida) is nondet.
%
%   Salida es una manera en que termina la partida por el árbol desde
%   Posicion, con las negras a mover; cada jugada legal de las negras da
%   una, esté o no en el árbol.
respuesta(P, _, N, N-mate) :-
    mate(P),
    !.
respuesta(P, _, N, N-falla(ahogado)) :-
    ahogado(P),
    !.
respuesta(P, A, N, S) :-
    jugada(P, R, P2),
    (   P2 = pos(_, _, capturada, _)
    ->  S = N-falla(torre_perdida)
    ;   A = responde(Ramas),
        memberchk(R-A2, Ramas),
        A2 = juega(_, _)
    ->  recorrer(P2, A2, N, S)
    ;   S = N-nueva(P2)
    ).
```

Una posición queda **asegurada** cuando todas sus salidas son mates o
posiciones ya aseguradas; su valor es el camino más largo. Las pasadas se
repiten hasta que ninguna posición nueva queda asegurada. Una posición
que forma parte de un ciclo, o que lleva a una falla, no queda asegurada
nunca. `verificar_desde/3` aplica el método a las posiciones a las que
puede llegar la partida desde una dada:

```prolog
?- verificar_desde(krk, pos(blancas, 5-5, 1-1, 4-7), R).
R = r(145, 145, 14).
```

Desde la posición de la [introducción](index.md) la partida puede pasar por 145
posiciones en que se pide un árbol nuevo; todas quedan aseguradas, y
contra la peor defensa el mate llega en 14 jugadas. Las dos defensas de la
[sección 80.5](index.md#805-version-5-jugar-con-la-tabla) dieron 12 y 9. `verificar/2` hace lo mismo con las
175 168 posiciones con las blancas a mover, sin reducirlas por simetría,
porque el orden en que se prueban las jugadas no es simétrico y el
programa puede jugar distinto en dos posiciones que son espejo una de la
otra. La corrida de
`time(verificar(krk, R)), no_aseguradas(krk, Ps), length(Ps, N)` tardó dos
minutos y medio:

```text
% 800,073,421 inferences, 148.859 CPU in 151.168 seconds (98% CPU, 5374693 Lips)
R = r(175120, 175168, 34),
N = 48.
```

La tabla asegura el mate en 175 120 posiciones, y el más largo tarda 34
jugadas, por debajo de las 50 que el reglamento permite antes de reclamar
tablas. En las otras 48 no lo asegura, y en todas la causa es la misma:
un árbol del primer consejo satisfacible termina, por algún camino, en
**ahogado**. Son tres consejos:

| Consejo | Posiciones | Situación |
|---|---|---|
| `acercamiento` | 24 | rey negro en un rincón, torre en la casilla vecina en diagonal |
| `mantener_espacio` | 16 | ídem |
| `dividir_en_2` | 8 | rey negro en g8 o h7, torre en su columna o su fila, rey blanco en g5 o e7 |

La más simple es una de las diez de la [sección 80.5](index.md#805-version-5-jugar-con-la-tabla). Mueven las
blancas: el rey blanco en a3, la torre en b2 defendida por él, el rey
negro en a1. La tabla elige `mantener_espacio`:

```prolog
?- estrategia(krk, pos(blancas, 1-3, 2-2, 1-1), C, A).
C = mantener_espacio,
A = juega(rey(1-3, 2-3), hoja).
```

El rey a b3 cumple la meta mejor de `mantener_espacio` —mueven las
negras, la torre no está expuesta, divide a los reyes, el rey blanco no
se alejó de ella— y deja al rey negro sin jugadas: a2 y b2 están junto al
rey blanco, y b1 lo ataca la torre. `mostrar(pos(negras, 2-3, 2-2, 1-1))`
dibuja la posición:

```text
8 . . . . . . . .
7 . . . . . . . .
6 . . . . . . . .
5 . . . . . . . .
4 . . . . . . . .
3 . R . . . . . .
2 . T . . . . . .
1 r . . . . . . .
  a b c d e f g h
```

```prolog
?- ahogado(pos(negras, 2-3, 2-2, 1-1)).
true.
```

Ninguna de las metas de `mantener_espacio` habla del ahogado; solo la de
`encierro` lo excluye. En la posición de partida el rey negro ya no tiene
jugadas, de modo que cualquier jugada de espera que conserve la red
ahoga; el mate en 3 que da la tabla de finales empieza por soltarla. Las
ocho posiciones de `dividir_en_2` necesitan dos jugadas, y una respuesta
precisa de las negras. Con el rey blanco en g5, la torre en g1 y el rey
negro en g8:

```prolog
?- estrategia(krk, pos(blancas, 7-5, 7-1, 7-8), C, A).
C = dividir_en_2,
A = juega(rey(7-5, 8-6), responde([rey(7-8, 6-7)-juega(rey(8-6, 8-7), hoja), rey(7-8, 8-8)-juega(torre(7-1, 7-7), hoja), rey(7-8, 6-8)-juega(rey(8-6, 8-7), hoja)])).
```

El rey blanco va a h6. Si el rey negro va a h8, el árbol responde torre a
g7: la torre divide a los reyes, defendida por el rey de h6, y mueven las
negras, que es la meta mejor de `dividir_en_2`. Pero el rey en h8 no
tiene jugadas, como muestra `mostrar(pos(negras, 8-6, 7-7, 8-8))`:

```text
8 . . . . . . . r
7 . . . . . . T .
6 . . . . . . . R
5 . . . . . . . .
4 . . . . . . . .
3 . . . . . . . .
2 . . . . . . . .
1 . . . . . . . .
  a b c d e f g h
```

```prolog
?- ahogado(pos(negras, 8-6, 7-7, 8-8)).
true.
```

Ninguna de las dos defensas de la [sección 80.5](index.md#805-version-5-jugar-con-la-tabla) encontró esta
respuesta, y por eso esas mediciones dieron 10 ahogados y no 48: la
verificación examina todas las respuestas, también las que nadie elige al
jugar. Bratko cita una prueba formal de que una tabla «en efecto la
misma» que esta da mate desde cualquier posición; la de su libro, tal
como este capítulo la escribe a partir de la figura que la presenta, no
lo asegura en 48 de las 175 168. El hallazgo es de este curso: la tabla
probada por Bratko en 1978 no está en el libro, y puede diferir en
justamente estos detalles.

## 80.8 Versión 8: la tabla corregida

La corrección es una condición más en la meta a mantener de todos los
consejos: no ahogar al rey negro. La tabla corregida es otro módulo, que
carga la biblioteca y las reglas de `krk.pl` sin copiarlas y cambia solo
los consejos:

<!-- ejemplo: capitulo-80/corregida.pl predicado: regla/2 consejo/5 -->
```prolog
%!  regla(?Nombre, ?Regla) is nondet.
%
%   Las reglas de la tabla original.
regla(Nombre, Regla) :-
    krk:regla(Nombre, Regla).

%!  consejo(?Nombre, ?Mejor, ?Mantener, ?Nuestras, ?Suyas) is nondet.
%
%   Los consejos de la tabla original, con no ahogado agregado a la meta a
%   mantener.
consejo(Nombre, Mejor, Mantener y no ahogado, Nuestras, Suyas) :-
    krk:consejo(Nombre, Mejor, Mantener, Nuestras, Suyas).
```

Con `no ahogado` en la meta a mantener, un árbol que pasa por un ahogado
fracasa en ese nodo, y el intérprete busca otra jugada u otro consejo.
En la posición del rey en a1, `mantener_espacio` deja de ser
satisfacible, y la tabla elige `dividir_en_2`:

```prolog
?- verificar_desde(corregida, pos(blancas, 1-3, 2-2, 1-1), R).
R = r(25, 25, 14).

?- verificar_desde(corregida, pos(blancas, 7-5, 7-1, 7-8), R).
R = r(44, 44, 17).
```

La verificación completa de la tabla corregida, sobre las 175 168
posiciones, con
`time(verificar(corregida, R)), no_aseguradas(corregida, Ps), length(Ps, N)`:

```text
% 1,263,851,044 inferences, 214.172 CPU in 217.434 seconds (98% CPU, 5901107 Lips)
R = r(175168, 175168, 34),
N = 0.
```

Todas las posiciones quedan aseguradas: contra cualquier defensa, la tabla
corregida da mate desde cualquier posición del final, en a lo sumo 34
jugadas. La más larga empieza con el rey blanco en a1, la torre en d4 y
el rey negro en c3 (o su espejo, a8, d5 y c6), donde el óptimo es 14. Las
mediciones de la [sección 80.5](index.md#805-version-5-jugar-con-la-tabla)
con la tabla corregida dan mate en las 27 342 partidas de antes y en las
diez que terminaban en ahogado, con los mismos máximos: 26 jugadas contra
`primera`, 27 contra `resistente` y 31 contra `optima`.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `forzar/5` es `nondet` porque da un árbol por cada estrategia, y `satisfacible/4` toma el primero con `once/1` |
    | C2 | `jugada/3` con la jugada libre enumera las jugadas legales y con la jugada ligada la comprueba (pruebas `escape` y `captura`); los predicados que necesitan la posición ligada, como `estrategia/4`, lo declaran con `+` |
    | C4 | `partida/5` es `det`: las jugadas elegidas se ejecutan con `once/1`, y las pruebas no encuentran alternativas pendientes |
    | C6 | las reglas, el intérprete y la tabla no escriben ni modifican la base de datos; solo `mostrar/1` y `narrar/3` escriben, y solo `calcular/0`, `verificar/2` y `verificar_desde/3` guardan resultados con `assertz/1`; la posición, la jugada y el árbol forzante son términos con un functor por forma |
    | C7 | 99 pruebas en ocho archivos; `finales.plt` reproduce las cifras de Bramer y `verificar.plt` comprueba la posición del ahogado y su corrección |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

8. **(2)** Escribir una defensa `azar(Semilla, Posicion, Jugada)` que
   elige una respuesta legal con un paso del generador congruencial del
   [capítulo 78](../capitulo-78-proyecto-mundo-wumpus/index.md), aplicado
   a la semilla más el código de la posición. Medir la tabla corregida con
   `azar(7)` y con `primera` sobre las posiciones normales con el rey negro
   en d4.
9. ★ **(2)** Jugar la tabla corregida contra la defensa `optima/2` desde
   la posición de la introducción y desde la de a1, d4 y c3. Comparar las
   jugadas con el óptimo de la tabla de finales y con lo que asegura la
   verificación.
10. **(3)** Una política sin memoria pide un árbol nuevo en cada jugada y
    juega solo su primera jugada. Escribir su verificación sobre las
    posiciones normales y mostrar que deja posiciones sin asegurar que la
    tabla con memoria asegura. Explicar por qué.
11. ★ **(2)** Quitar `no torre_expuesta` de la meta mejor de `encierro`,
    en una tabla propia que carga la de `krk.pl`, y predecir si la tabla
    puede llegar a perder la torre. Comprobarlo con `salidas/3` sobre las
    27 352 posiciones normales, y explicar el resultado con la meta a
    mantener.
12. **(3)** Corregir la tabla de otra manera: agregar `no ahogado` solo a
    la meta mejor de los tres consejos que ahogan. Verificar la nueva
    tabla desde las 48 posiciones y comparar con la corrección de la
    [sección 80.8](#808-version-8-la-tabla-corregida).

## Resumen

| | |
|---|---|
| **consejo** | meta mejor, meta a mantener y restricciones de las jugadas de los dos bandos |
| **árbol forzante** | una jugada nuestra en cada posición en que movemos, todas las respuestas permitidas del rival, hojas que cumplen la meta mejor; la prueba de que un consejo es satisfacible |
| **tabla de consejos** | reglas `si Condicion entonces Consejos`: la primera regla que se cumple y su primer consejo satisfacible |
| **tabla de finales** | el número de jugadas hasta el mate con juego óptimo, calculado hacia atrás desde los mates |
| **verificación de una estrategia** | el conjunto de las posiciones que gana contra cualquier defensa, construido hacia atrás; las que quedan fuera son sus errores |
| `jugada/3`, `jaque/1`, `mate/1`, `ahogado/1`, `legal/1` | las reglas del final |
| `mate_forzado/3`, `menor_mate/4` | el mate buscado sin conocimiento |
| `estrategia/4`, `satisfacible/4`, `cumple/4`, `jugada_con/6` | el intérprete de consejos |
| `meta/3`, `jugadas/4`, `espacio/2`, `casilla_critica/2` | la biblioteca del final |
| `partida/5`, `narrar/3`, `medir/3` | jugar con la tabla |
| `calcular/0`, `mate_en/2`, `normal/2`, `optima/2` | la tabla de finales |
| `salidas/3`, `verificar/2`, `verificar_desde/3` | la verificación |
| **[Patrón 81](../patrones.md#81-conocimiento-como-restricciones-de-la-busqueda)** | conocimiento como restricciones de la búsqueda |
| **[Patrón 82](../patrones.md#82-verificar-la-estrategia-hacia-atras)** | verificar la estrategia hacia atrás |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La tabla de finales como un punto fijo calculado de abajo hacia arriba, como la evaluación de un programa Datalog | [capítulo 86](../capitulo-86-proyecto-motor-datalog/index.md) |

## Referencias

- Max A. Bramer, «Testing Correctness of Strategies in Game-Playing
  Programs», *Proceedings of the Sixth International Joint Conference on
  Artificial Intelligence*, Tokio, 1979, pp. 91–94.
  [Actas en el sitio de IJCAI (volumen 1, autores A–M)](https://www.ijcai.org/Proceedings/79-1/Papers/004.pdf).
  Esta página toma de allí la verificación de una estrategia construyendo
  hacia atrás el conjunto de las posiciones que gana.
- Ivan Bratko, *Prolog Programming for Artificial Intelligence*,
  Addison-Wesley, 1986 — capítulo «Game Playing», sección «A chess endgame
  program in Advice Language 0» (figura 15.10). Sin edición en línea de
  acceso libre. Es la tabla que esta página verifica y corrige, y la
  mención de la prueba formal de una tabla «en efecto la misma».
- Ivan Bratko, «Proving correctness of strategies in the AL1 assertional
  language», *Information Processing Letters* 7(5), 1978, sin edición en
  línea de acceso libre: la prueba formal de la tabla de rey y torre que
  cita el libro.

El código del capítulo es propio, escrito para el curso: ninguno de los
programas de las fuentes se copió. La verificación exhaustiva de la tabla
con su programa de juego, las 48 posiciones en que la tabla de Bratko
ahoga al rey negro y la corrección que las elimina son resultados de este
capítulo.
