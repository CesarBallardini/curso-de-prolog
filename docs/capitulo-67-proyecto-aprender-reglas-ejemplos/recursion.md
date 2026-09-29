# La mejor cláusula y la recursión

Esta página contiene la sección
[67.6](index.md#676-version-5-la-mejor-clausula-y-la-recursion) del
[capítulo 67](index.md): la búsqueda que elige la cláusula que cubre más
ejemplos, el aprendizaje de una definición recursiva y dos maneras de
obtener una hipótesis equivocada. El ejemplo está en `recursion.pl`, en
`ejemplos/capitulo-67/`, con sus pruebas; carga las versiones anteriores y
se ejecuta localmente.

## La mejor cláusula

La búsqueda de la versión 4 termina con la primera cláusula consistente
que encuentra, y el orden del lenguaje decide cuál es. La versión 5
recorre el grafo de especialización **por niveles**: el nivel D son las
cláusulas a D refinamientos de la más general que todavía cubren el
ejemplo que se explica. En el primer nivel que tiene cláusulas
consistentes, elige la que cubre más positivos de los que faltan; ante un
empate, la primera generada:

<!-- ejemplo: capitulo-67/recursion.pl predicado: nivel/7 -->
```prolog
%!  nivel(+D:integer, +Max:integer, +Frontera:list, +Problema, -R,
%!        +N0:integer, -N:integer) is det.
%
%   Frontera son las cláusulas del nivel D. Si alguna es consistente, R
%   es la mejor; si no, se pasa al nivel siguiente, hasta Max.
nivel(D, Max, Frontera, E-Pos-Negs-M-L, R, N0, N) :-
    include(consistente_con(Negs, M), Frontera, Consistentes),
    (   Consistentes = [_|_]
    ->  maplist(puntuar(Pos, M), Consistentes, Puntuadas),
        sort(1, @>=, Puntuadas, [_-C|_]),
        R = encontrada(C),
        N = N0
    ;   D < Max
    ->  findall(S, ( member(C0, Frontera),
                     refinar(L, C0, S) ),
                Todos),
        length(Todos, K),
        N1 is N0 + K,
        include(cubre_ejemplo(E, M), Todos, Siguiente),
        D1 is D + 1,
        nivel(D1, Max, Siguiente, E-Pos-Negs-M-L, R, N1, N)
    ;   R = ninguna,
        N = N0
    ).
```

Recorrer por niveles guarda el nivel entero en memoria, lo que la
profundización iterativa evita; a cambio, no repite los niveles
anteriores y ve todas las cláusulas del nivel antes de elegir. Con los
ejemplos de `abuelo/2`, la cláusula elegida es la regla esperada:

```prolog
?- aprender_rec(abuelo, H, N).
H = [(abuelo(_A, _B):-[padre(_A, _C), progenitor(_C, _B)])],
N = 640.
```

Las 640 cláusulas generadas son más que las 334 de la versión 4, porque
el nivel 2 se genera completo. Pero la hipótesis tiene una sola cláusula,
que cubre los tres positivos: en el nivel 2, «padre de un progenitor»
cubre tres, y «padre de un padre», dos.

## Una definición recursiva

`antepasado/2` se define con `progenitor/2` y consigo misma, como en el
[capítulo 6](../capitulo-06-recursion/index.md). Para que el programa pueda proponer una cláusula
recursiva, la relación entra en el lenguaje de hipótesis. Queda por
decidir cómo se cubre un ejemplo con una cláusula como

```prolog
antepasado(A, B) :-
    progenitor(A, C),
    antepasado(C, B).
```

cuando la definición de `antepasado/2` todavía no existe. La cobertura
extensional responde con los ejemplos: el literal `antepasado(C, B)` es
verdadero si es un ejemplo positivo. `aprender_rec/3` agrega los
positivos al modelo de fondo:

<!-- ejemplo: capitulo-67/recursion.pl predicado: aprender_rec/3 -->
```prolog
%!  aprender_rec(+Relacion, -H:list, -N:integer) is det.
%
%   H es la hipótesis para Relacion con la relación misma en el lenguaje,
%   los positivos agregados al modelo de fondo y a lo sumo tres
%   refinamientos por cláusula; N es la cantidad de cláusulas generadas.
aprender_rec(Relacion, H, N) :-
    ejemplos(Relacion, Pos, Negs),
    modelo_fondo(Fondo),
    ord_union(Fondo, Pos, M),
    lenguaje(L0),
    append(L0, [Relacion/2], L),
    inductivo(Pos, Negs, M, L, 3, H, N).
```

```prolog
?- aprender_rec(antepasado, H, N).
H = [(antepasado(_A, _B):-[progenitor(_A, _B)]), (antepasado(_C, _D):-[progenitor(_C, _E), antepasado(_E, _D)])],
N = 743.
```

El primer positivo, `antepasado(eva, sofia)`, se explica en el nivel 1:
`madre(A, B)` es consistente y cubre tres positivos, pero
`progenitor(A, B)` cubre siete. El primer positivo que queda,
`antepasado(juan, eva)`, necesita el nivel 2, y allí la cláusula
recursiva cubre los siete restantes. El resultado es la definición del
[capítulo 6](../capitulo-06-recursion/index.md).

La cobertura extensional supone que todos los positivos están dados: la
cláusula recursiva cubre `antepasado(juan, sofia)` porque
`antepasado(pedro, sofia)` es un ejemplo. Si faltara, la cláusula no lo
cubriría, aunque la definición completa sí lo deduzca. Por eso, la
hipótesis terminada se prueba sin los ejemplos, en forma **intensional**.
Hay dos maneras. La primera es la de la versión 3: el modelo mínimo del
fondo con las cláusulas aprendidas, calculado de abajo hacia arriba como
en la [sección 38.6](../capitulo-38-semantica-de-los-programas-logicos/index.md#386-evaluacion-de-abajo-hacia-arriba):

```prolog
?- aprender_rec(antepasado, H, _), evaluar(antepasado, H, A, FP, FN).
H = [(antepasado(_A, _B):-[progenitor(_A, _B)]), (antepasado(_C, _D):-[progenitor(_C, _E), antepasado(_E, _D)])],
A = 14,
FP = FN, FN = 0.
```

La segunda prueba cada par de personas de arriba hacia abajo, con el
intérprete vainilla del [capítulo 33](../capitulo-33-introspeccion-y-metainterpretes/index.md#332-el-interprete-vainilla) sobre las cláusulas de la
hipótesis y los hechos del fondo. Una hipótesis puede tener cláusulas
circulares, como `antepasado(A, B) :- antepasado(A, C), antepasado(C, B)`,
con las que la resolución no termina; por eso el intérprete lleva un
límite de profundidad, como el de la [sección 33.5](../capitulo-33-introspeccion-y-metainterpretes/index.md#335-limites-de-profundidad-y-profundizacion-iterativa):

<!-- ejemplo: capitulo-67/recursion.pl predicado: probar/4 -->
```prolog
%!  probar(+D:integer, +H:list, +Fondo:list, ?Meta) is nondet.
%
%   Meta se deduce de las cláusulas de H y de los átomos de Fondo con a
%   lo sumo D pasos de resolución con cláusulas de H.
probar(_, _, Fondo, Meta) :-
    member(Meta, Fondo).
probar(D, H, Fondo, Meta) :-
    D > 0,
    D1 is D - 1,
    member(C, H),
    copy_term(C, (Meta :- Cuerpo)),
    maplist(probar(D1, H, Fondo), Cuerpo).
```

```prolog
?- aprender_rec(antepasado, H, _), extension_intensional(antepasado, H, 5, As), length(As, K).
H = [(antepasado(_A, _B):-[progenitor(_A, _B)]), (antepasado(_C, _D):-[progenitor(_C, _E), antepasado(_E, _D)])],
As = [antepasado(eva, sofia), antepasado(juan, ana), antepasado(juan, eva), antepasado(juan, luis), antepasado(juan, pedro), antepasado(juan, sofia), antepasado(marta, ana), antepasado(marta, eva), antepasado(..., ...)|...],
K = 14.
```

Las dos pruebas dan los 14 antepasados, que son los esperados. El modelo
mínimo no necesita límite, porque la evaluación de abajo hacia arriba
termina con cualquier programa sin símbolos de función; el intérprete lo
necesita, y el límite 5 alcanza porque ninguna cadena de la familia tiene
más de tres generaciones.

!!! question "Actividad"
    Predecir qué hipótesis aprende `aprender_rec/3` para `abuela/2`, que
    no es recursiva, y si la relación en el lenguaje cambia algo.
    Comprobarlo, y comparar la cantidad de cláusulas generadas con la de
    `abuelo/2`.

## Cuando la cobertura extensional engaña

Con la relación en el lenguaje, la cobertura extensional puede aceptar
una cláusula que no define nada. `hermano/2` necesita cuatro literales sin
la relación; con ella, en el nivel 3 aparece otra cosa:

```prolog
?- aprender_rec(hermano, H, N).
H = [(hermano(_A, _B):-[hermano(_A, _C), hermano(_D, _B), hermano(_D, _C)])],
N = 14922.

?- aprender_rec(hermano, H, _), extension_intensional(hermano, H, 5, As).
H = [(hermano(_A, _B):-[hermano(_A, _C), hermano(_D, _B), hermano(_D, _C)])],
As = [].
```

La cláusula cubre `hermano(pedro, ana)` con C = ana y D = pedro: los tres
literales del cuerpo son el mismo ejemplo. Es una tautología disfrazada,
que `refinar/3` no reconoce porque ningún literal es igual a la cabeza.
No cubre ningún negativo, porque para eso haría falta que los ejemplos
positivos se combinaran de otra manera, y cubre los dos positivos: para la
cobertura extensional es una hipótesis completa y consistente. Probada en
forma intensional, sin los ejemplos, no deduce ningún hermano. La
cobertura extensional es la que permite aprender cada cláusula por
separado, y la intensional es la que dice si la hipótesis define la
relación; un programa que aprende necesita las dos.

## Pocos negativos

Los negativos son lo único que impide generalizar de más. Con la regla
más general, `abuelo(A, B)`, todo par de personas es un abuelo y su
nieto, y solo un negativo cubierto obliga a especializarla.
`con_negativos/4` aprende `abuelo/2` con todos los positivos y solo los
primeros K negativos, en el orden de la lista, y cuenta los falsos
positivos de la hipótesis entre los 49 pares:

<!-- ejemplo: capitulo-67/recursion.pl predicado: con_negativos/4 -->
```prolog
%!  con_negativos(+Relacion, +K:integer, -H:list, -FP:integer) is det.
%
%   H es la hipótesis que inductivo/7 aprende para Relacion con todos los
%   positivos y solo los primeros K negativos, en su orden, sin la
%   relación en el lenguaje; FP es la cantidad de falsos positivos de su
%   extensión entre los pares de personas.
con_negativos(Relacion, K, H, FP) :-
    ejemplos(Relacion, Pos, Negs),
    length(Primeros, K),
    append(Primeros, _, Negs),
    modelo_fondo(M),
    lenguaje(L),
    inductivo(Pos, Primeros, M, L, 3, H, _),
    evaluar_en(Relacion, H, M, _, FP, _).
```

```prolog
?- con_negativos(abuelo, 0, H, FP).
H = [(abuelo(_, _):-[])],
FP = 46.

?- con_negativos(abuelo, 14, H, FP).
H = [(abuelo(_A, _):-[varon(_A)])],
FP = 18.

?- con_negativos(abuelo, 15, H, FP).
H = [(abuelo(_A, _B):-[padre(_A, _C), progenitor(_C, _B)])],
FP = 0.
```

| Negativos | Hipótesis | Falsos positivos |
|---|---|---|
| 0 | `abuelo(A, B)` | 46 |
| 1 a 14 | `abuelo(A, B) :- varon(A)` | 18 |
| 15 a 46 | `abuelo(A, B) :- padre(A, C), progenitor(C, B)` | 0 |

Los negativos están ordenados por la primera persona: los 7 primeros
tienen a ana en el lugar del abuelo y los 7 siguientes a eva. Todos los
descarta `varon(A)`, que afirma que cada varón es abuelo de todos: 21
pares, 18 de ellos falsos. El negativo 15 es `abuelo(juan, ana)`: juan es
varón y no es abuelo de ana, y `varon(A)` deja de ser consistente. Desde
ahí la hipótesis es la esperada. Catorce negativos no enseñan nada que
`varon(A)` no cumpla, y el decimoquinto enseña lo que faltaba: lo que
cuenta es qué negativos se dan, no cuántos. El
[ejercicio 8](index.md#ejercicios) muestra que uno solo, bien elegido,
alcanza, y que otro, solo, lleva a una hipótesis peor que `varon(A)`.
