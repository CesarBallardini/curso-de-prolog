# Tres maneras de decidir, un modelo y el conjunto de soporte

Esta página continúa la página
[La lógica de predicados](primer-orden.md#637-version-6-resolucion-con-variables)
del [capítulo 63](index.md), con las secciones
[63.8](#638-tres-maneras-de-decidir) a
[63.10](#6310-el-conjunto-de-soporte): la versión 7, `comparacion.pl`, que
compara el demostrador por resolución con dos procedimientos que deciden la
lógica proposicional, la construcción de un modelo cuando no hay
refutación, en `modelos.pl`, y la estrategia de conjunto de soporte, en
`soporte.pl`. Los archivos están en `ejemplos/capitulo-63/`, con sus
pruebas, y cargan las versiones anteriores.

## 63.8 Tres maneras de decidir

En la lógica de predicados, un demostrador puede no terminar ante una
fórmula que no es un teorema. En la lógica proposicional hay
procedimientos que siempre terminan, porque una fórmula con n átomos tiene
$2^n$ asignaciones de valores. `tautologia/2` recibe el método como
argumento: `quine`, `clpb` o `resolucion(Max)`.

**El método de Quine.** Hein lo presenta así: una fórmula con un átomo
$p$ es una tautología si lo son la fórmula con $p$ reemplazado por
verdadero y la fórmula con $p$ reemplazado por falso. `quine/2` aplica la
regla a cada átomo, y cuando no quedan átomos, evalúa. `sustituir/4`
reemplaza un átomo por `val(1)` o `val(0)`, con la fórmula como primer
argumento para que la indexación elija la cláusula:

<!-- ejemplo: capitulo-63/comparacion.pl predicado: quine/2 -->
```prolog
%!  quine(+As:list, +F) is semidet.
%
%   F es verdadera con todos los valores de los átomos As, que son todos
%   los que tiene: con el primero verdadero y con el primero falso.
quine([], F) :-
    valor(F, 1).
quine([A|As], F) :-
    sustituir(F, A, 1, F1),
    quine(As, F1),
    sustituir(F, A, 0, F0),
    quine(As, F0).
```

**`library(clpb)`.** La traducción es directa: cada fórmula atómica es una
variable booleana, y cada conectivo, un operador de la biblioteca —`~`,
`*`, `+`, `=<` para la implicación y `=:=` para la equivalencia—. `taut/2`
decide si la expresión vale 1 para toda asignación, sobre el diagrama de
decisión binario que la biblioteca construye
([sección 49.4](../capitulo-49-proyecto-circuitos-logicos/verificacion.md#494-verificar-con-libraryclpb)):

<!-- ejemplo: capitulo-63/comparacion.pl predicado: expresion/3 -->
```prolog
%!  expresion(+F, +Vars:list, -E) is det.
%
%   E es la expresión de library(clpb) de F, con las variables de Vars.
expresion(at(A), Vars, X) :-
    memberchk(A-X, Vars).
expresion(no(F), Vars, ~E) :-
    expresion(F, Vars, E).
expresion(y(A, B), Vars, EA * EB) :-
    expresion(A, Vars, EA),
    expresion(B, Vars, EB).
expresion(o(A, B), Vars, EA + EB) :-
    expresion(A, Vars, EA),
    expresion(B, Vars, EB).
expresion(si(A, B), Vars, EA =< EB) :-
    expresion(A, Vars, EA),
    expresion(B, Vars, EB).
expresion(sii(A, B), Vars, EA =:= EB) :-
    expresion(A, Vars, EA),
    expresion(B, Vars, EB).
```

Los tres métodos coinciden: las pruebas de `comparacion.plt` los aplican a
ocho fórmulas, teoremas y no teoremas, y comparan los veredictos.

```prolog
?- leer_formula("((p → q) → p) → p", F), tautologia(quine, F), tautologia(clpb, F), tautologia(resolucion(5), F).
F = si(si(si(at(p), at(q)), at(p)), at(p)).
```

### Lo que produce cada método

Los tres dan el mismo veredicto, pero no el mismo resultado. Cuando la
fórmula no es un teorema, la resolución solo dice que no encontró una
refutación. `library(clpb)` da más: `sat(~E)` restringe las variables a
las asignaciones que hacen falsa la fórmula, y `labeling/1` elige una.
Esa asignación es un **modelo** de la negación, la contracara de la
refutación: Flach construye modelos de cláusulas indefinidas por
encadenamiento hacia adelante, y aquí la biblioteca lo hace sobre la
fórmula entera:

<!-- ejemplo: capitulo-63/comparacion.pl predicado: contraejemplo/2 -->
```prolog
%!  contraejemplo(+F, -Asignacion:list) is nondet.
%
%   Asignacion, una lista de pares Átomo-Valor, hace falsa la fórmula sin
%   cuantificadores F. Si F es una tautología, no hay ninguna.
contraejemplo(F, Asignacion) :-
    booleana(F, E, Asignacion),
    sat(~E),
    pairs_values(Asignacion, Vs),
    labeling(Vs).
```

```prolog
?- leer_formula("(p → q) → (q → p)", F), contraejemplo(F, A).
F = si(si(at(p), at(q)), si(at(q), at(p))),
A = [p-0, q-1].
```

Con `p` falso y `q` verdadero, `p → q` es verdadera y `q → p` es falsa.
El contraejemplo se comprueba evaluando la fórmula, y una de las pruebas
lo hace con el método de Quine. Cuando la fórmula es un teorema,
`taut/2` responde que sí, pero no da ninguna razón que se pueda comprobar
fuera de la biblioteca; la resolución da la prueba, y el verificador la
comprueba sin confiar en el demostrador. Los dos resultados se completan:
un contraejemplo justifica un no, una refutación justifica un sí. El
[ejercicio 10](#ejercicios) los reúne en un solo predicado.

### El principio del palomar

![Diez palomas blancas en un casillero de madera de nueve compartimentos; uno de ellos tiene dos palomas](palomas.jpg)

Diez palomas en nueve casilleros: alguno tiene que alojar a dos.
Imagen: BenFrantzDale y McKay,
[CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/), vía
[Wikimedia Commons](https://commons.wikimedia.org/wiki/File:TooManyPigeons.jpg).

La familia de fórmulas con que se mide es el **principio del palomar**:
n + 1 palomas no caben en n agujeros, uno por paloma. `palomar/2` la
construye con los átomos `en(I, J)`, «la paloma I está en el agujero J»:
no puede ser que cada paloma esté en algún agujero y que ningún agujero
tenga dos palomas:

<!-- ejemplo: capitulo-63/comparacion.pl predicado: palomar/2 -->
```prolog
%!  palomar(+N:integer, -F) is det.
%
%   F afirma que N + 1 palomas no caben en N agujeros, uno por paloma:
%   no puede ser que cada paloma esté en algún agujero y que ningún
%   agujero tenga dos palomas. La fórmula atómica en(I, J) dice que la
%   paloma I está en el agujero J. F es una tautología para todo N.
palomar(N, no(y(Todas, Ninguno))) :-
    N1 is N + 1,
    numlist(1, N1, Palomas),
    numlist(1, N, Agujeros),
    findall(D,
            ( member(I, Palomas),
              findall(at(en(I, J)), member(J, Agujeros), Ds),
              disyuncion(Ds, D)
            ),
            Cada),
    conjuncion(Cada, Todas),
    findall(no(y(at(en(I, J)), at(en(K, J)))),
            ( member(J, Agujeros),
              member(I, Palomas),
              member(K, Palomas),
              I < K
            ),
            Pares),
    conjuncion(Pares, Ninguno).
```

La fórmula es una tautología para todo n, y es conocida por ser difícil
para la resolución: toda refutación de su negación tiene una longitud que
crece en forma exponencial con n, como demostró Haken
([Referencias](#referencias)). La tabla da las inferencias de
`tautologia/2` con cada método; «más de» indica que la búsqueda se
interrumpió con `call_with_inference_limit/3` en esa cantidad:

| Palomas | Cláusulas | Átomos | Quine | `clpb` | Resolución lineal |
|---|---|---|---|---|---|
| 2 | 3 | 2 | 145 | 1 052 | 416 |
| 3 | 9 | 6 | 9 704 | 5 462 | 6 296 663 |
| 4 | 22 | 12 | 1 679 264 | 38 950 | más de 100 000 000 |
| 5 | 45 | 20 | 903 872 291 | 226 578 | — |
| 6 | 81 | 30 | — | 1 117 318 | — |
| 7 | 133 | 42 | — | 4 814 719 | — |

```prolog
?- time(tautologia_palomar(clpb, 3)).
% 40,718 inferences, 0.000 CPU in 0.015 seconds (0% CPU, Infinite Lips)
true.

?- time(tautologia_palomar(quine, 3)).
% 1,679,579 inferences, 0.297 CPU in 0.312 seconds (95% CPU, 5657529 Lips)
true.

?- time(tautologia_palomar(resolucion(20), 2)).
% 6,296,829 inferences, 1.641 CPU in 1.694 seconds (97% CPU, 3838067 Lips)
true.
```

El segundo argumento de `tautologia_palomar/2` es la cantidad de
agujeros. El método de Quine recorre todas las asignaciones: con cada
átomo nuevo el trabajo se duplica, y de 12 a 20 átomos se multiplica por
538. `library(clpb)` crece mucho más despacio en esta familia, porque el
diagrama de decisión binario de Bryant, sobre el que está construida,
comparte las subfórmulas iguales; para otras
fórmulas el diagrama también crece en forma exponencial, y el orden de las
variables decide su tamaño. La resolución es la más lenta de las tres:
con 3 palomas, la refutación lineal más corta tiene 11 pasos, y la
profundización iterativa examina todas las más cortas antes de
encontrarla; con 4 palomas no termina en 100 millones de inferencias. El
demostrador de la versión 3, sin la estrategia lineal, tampoco resuelve
el caso de 3 palomas en esa cantidad.

La refutación de 11 pasos muestra además por qué la estrategia lineal
permite usar un centro anterior y no solo las cláusulas iniciales: su
último paso resuelve el centro 19 con el centro 14, un antecesor.

```prolog
?- forall((palomar(2, F), clausulas_fo(no(F), Cs), refutar_fo(Cs, 20, P)), escribir_prueba(prueba(Cs, P))).
  1.  en(1, 1) ∨ en(1, 2)             premisa
  2.  en(2, 1) ∨ en(2, 2)             premisa
  3.  en(3, 1) ∨ en(3, 2)             premisa
  4.  ¬en(1, 1) ∨ ¬en(2, 1)           premisa
  5.  ¬en(1, 1) ∨ ¬en(3, 1)           premisa
  6.  ¬en(2, 1) ∨ ¬en(3, 1)           premisa
  7.  ¬en(1, 2) ∨ ¬en(2, 2)           premisa
  8.  ¬en(1, 2) ∨ ¬en(3, 2)           premisa
  9.  ¬en(2, 2) ∨ ¬en(3, 2)           premisa
 10.  en(1, 2) ∨ ¬en(2, 1)            resolvente de 1 y 4
 11.  en(1, 2) ∨ en(2, 2)             resolvente de 2 y 10
 12.  en(2, 2) ∨ ¬en(3, 2)            resolvente de 8 y 11
 13.  ¬en(3, 2)                       resolvente de 9 y 12
 14.  en(3, 1)                        resolvente de 3 y 13
 15.  ¬en(1, 1)                       resolvente de 5 y 14
 16.  en(1, 2)                        resolvente de 1 y 15
 17.  ¬en(2, 2)                       resolvente de 7 y 16
 18.  en(2, 1)                        resolvente de 2 y 17
 19.  ¬en(3, 1)                       resolvente de 6 y 18
 20.  □                               resolvente de 14 y 19
true.
```

La conclusión no es que la resolución sea peor: es el único de los tres
métodos que se extiende a la lógica de predicados, donde no hay
asignaciones que recorrer, y el único que produce una prueba verificable.
Para la lógica proposicional, un procedimiento de decisión como el de
`library(clpb)` es la herramienta adecuada.

## 63.9 Construir un modelo

Cuando una fórmula no es un teorema, la resolución no termina sin un
máximo, y `clpb` da el contraejemplo sin decir cómo lo obtuvo. Flach
construye el contraejemplo con un programa de encadenamiento hacia
adelante, adaptado del demostrador SATCHMO de Manthey y Bry: un **modelo**
de un conjunto de cláusulas es un conjunto de fórmulas atómicas sin
variables, las verdaderas, que hace verdadera cada cláusula. Una cláusula
está **violada** cuando todos sus literales negativos son verdaderos y
ninguno de los positivos lo es; el programa busca una, agrega al modelo
uno de sus literales positivos, y repite hasta que no queda ninguna. Si la
cláusula violada no tiene literales positivos, vuelve atrás y elige otro.
`modelos.pl` lo escribe sobre las cláusulas del capítulo:

<!-- ejemplo: capitulo-63/modelos.pl predicado: modelo/3 violada/3 -->
```prolog
%!  modelo(+Clausulas:list, +Modelo0:list, -Modelo:list) is nondet.
%
%   Modelo extiende Modelo0 hasta que ninguna de las Clausulas está
%   violada.
modelo(Clausulas, Modelo0, Modelo) :-
    (   member(C, Clausulas),
        violada(C, Modelo0, Positivos)
    ->  member(A, Positivos),
        ord_add_element(Modelo0, A, Modelo1),
        modelo(Clausulas, Modelo1, Modelo)
    ;   Modelo = Modelo0
    ).

%!  violada(+C:list, +Modelo:list, -Positivos:list) is semidet.
%
%   Una copia de la cláusula C está violada en Modelo: sus literales
%   negativos son verdaderos, con las variables ligadas por el modelo, y
%   ninguno de sus Positivos, ya sin variables, lo es. Una variable que
%   queda libre en un literal positivo produce un error de dominio: la
%   cláusula no es de rango restringido.
violada(C, Modelo, Positivos) :-
    copy_term(C, D),
    signos(D, Negativos, Positivos),
    maplist(verdadera(Modelo), Negativos),
    (   ground(Positivos)
    ->  true
    ;   domain_error(clausula_de_rango_restringido, C)
    ),
    \+ ( member(A, Positivos),
         ord_memberchk(A, Modelo)
       ),
    !.
```

Las cláusulas pueden tener variables, siempre que sean de **rango
restringido**: cada variable de un literal positivo aparece en uno
negativo. Al hacer verdaderos los negativos con fórmulas del modelo, que
no tienen variables, los positivos quedan sin variables también. Una
cláusula como `hombre(X) ∨ mujer(X)` no lo es, y `violada/3` lo señala con
un error de dominio; Flach la corrige con un predicado `persona/1` que
enumera los valores de `X`. El ejemplo de Flach da sus dos modelos
mínimos:

```prolog
?- modelo([[+casado(X), +soltero(X), -hombre(X), -adulto(X)], [+tiene_esposa(Y), -casado(Y), -hombre(Y)], [+hombre(pablo)], [+adulto(pablo)]], M).
M = [adulto(pablo), casado(pablo), hombre(pablo), tiene_esposa(pablo)] ;
M = [adulto(pablo), hombre(pablo), soltero(pablo)].
```

No todo modelo que el programa construye es mínimo: el orden en que se
satisfacen las cláusulas puede agregar una fórmula que otra elección hace
innecesaria. Un conjunto de cláusulas tiene un modelo si y solo si no
tiene refutación, así que un modelo de la negación de una fórmula es un
contraejemplo. `contramodelo/2` lo busca para una fórmula escrita como
texto; los átomos del modelo son los verdaderos, y los demás, falsos:

```prolog
?- contramodelo("(p → q) → (q → p)", M).
M = [q].

?- contramodelo("p ∨ ¬p", M).
false.
```

Con q verdadera y p falsa, `p → q` es verdadera y `q → p` es falsa. El
programa no termina si todo modelo de las cláusulas es infinito; Flach
propone para ese caso un recorrido por niveles con una profundidad
máxima, que el capítulo no escribe.

## 63.10 El conjunto de soporte

Rowe describe la estrategia de **conjunto de soporte**: las cláusulas se
separan en las hipótesis, que se suponen consistentes, y el soporte, la
negación de lo que se quiere probar. Cada paso usa al menos una cláusula
del soporte, y cada resolvente pasa a formar parte de él; dos hipótesis
nunca se resuelven entre sí, porque de hipótesis consistentes no se deriva
la cláusula vacía. `soporte.pl` numera las hipótesis primero, y como cada
paso `r(I, J, R)` tiene `I =< J`, le basta con exigir que `J` sea del
soporte:

<!-- ejemplo: capitulo-63/soporte.pl predicado: paso_soporte/4 -->
```prolog
%!  paso_soporte(+NH:integer, +Clausulas:list, -Paso, -R:list) is nondet.
%
%   Paso es un paso de resolución o de factorización sobre las Clausulas
%   cuya cláusula de número mayor es del soporte, de número mayor que NH;
%   R es la cláusula que agrega.
paso_soporte(NH, Clausulas, r(I, J, R), R) :-
    nth1(J, Clausulas, C2),
    J > NH,
    nth1(I, Clausulas, C1),
    I =< J,
    resolvente_fo(unify_with_occurs_check, C1, C2, R).
paso_soporte(NH, Clausulas, f(I, R), R) :-
    nth1(I, Clausulas, C),
    I > NH,
    factor(unify_with_occurs_check, C, R).
```

`comparar_estrategias/3` mide las tres estrategias sobre un problema con
una cadena de implicaciones útil, de `a` a `e`, y otra que no interviene en
la prueba, de `x` a `z`:

```prolog
?- comparar_estrategias([[-a, +b], [-b, +c], [-c, +d], [-d, +e], [+a], [-x, +y], [-y, +z], [+x]], [[-e]], I).
I = [general-1544090, lineal-18840, soporte-6162].
```

La estrategia general resuelve también la cadena que no interviene; la
lineal la evita una vez elegido el centro, pero puede empezar por
cualquier par de cláusulas; el soporte empieza siempre por `¬e`. El
precio es la completitud: si las hipótesis son inconsistentes, la
estrategia no lo descubre, y `refutar_soporte([[+p], [-p]], [], 3, P)`
falla aunque las dos cláusulas tengan una refutación de un paso. La
búsqueda **en anchura**, la tercera estrategia de Rowe, es la saturación
por niveles del [ejercicio 11](#ejercicios).

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación: `demostrar/3` y `refutar_fo/3` son `semidet` porque devuelven solo la refutación más corta, y los generadores de pasos, `resolvente/3` y `factor/3`, son `nondet` |
    | C2 | la representación es limpia: fórmulas con un functor por conectivo, literales `+A` y `-A`, y la prueba como un término, que el verificador recibe sin conocer al demostrador |
    | C4 | las cláusulas de `fnn/2`, `sustituir/4` y la escritura empiezan por el functor de la fórmula, `signo//2` por el carácter y `opuestos/3` por el literal, de modo que la indexación no deja alternativas; las pruebas lo confirman |
    | C5 | un texto que no es una fórmula produce un error de sintaxis, y una fórmula con cuantificadores en la forma clausal proposicional, un error de tipo, en lugar de una falla silenciosa |
    | C7 | 143 pruebas en nueve archivos; cada refutación que el demostrador encuentra, con cada combinación de opciones, pasa por el verificador, y los tres métodos de decisión dan el mismo veredicto sobre ocho fórmulas |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

9. **(2)** Escribir `clasificar(Texto, Clase)`: Clase es `tautologia`,
   `contradiccion` o `contingente`, decidido con `tautologia/2` de
   `comparacion.pl` y el método `clpb`. Clasificar
   `"p ∨ ¬p"`, `"p ∧ ¬p"`, `"p → q"` y `"(p → q) ∨ (q → p)"`.
10. ★ **(2)** Escribir `decidir(Texto, Veredicto)` para fórmulas sin
    cuantificadores: `teorema(Prueba)`, con una refutación de
    `demostrar/3` de a lo sumo 10 pasos, o `contraejemplo(A)`, con una
    asignación de `contraejemplo/2`. Verificar la prueba con
    `verificar/1` y el contraejemplo evaluando la fórmula con él.
11. **(3)** La **saturación por niveles** calcula todos los resolventes de
    las cláusulas, los agrega, y repite hasta obtener □ o hasta que no
    aparece ninguno nuevo. Escribir `saturar(Cs, Niveles, Resultado)` con
    `resolvente/3`, donde Resultado es `refutada` o `saturada`, y medir
    con `time/1` las inferencias para el principio del palomar con 3
    palomas, comparadas con las de `refutar_fo/3`.
12. **(2)** El primer modelo que `modelo/2` construye para el segundo
    ejemplo de Flach no es mínimo. Escribir `modelo_minimo(Cs, M)`, que da
    solo los modelos de `modelo/2` de los que ningún subconjunto propio es
    un modelo, y comprobarlo con ese ejemplo. Explicar por qué no alcanza
    con quitar una fórmula por vez.

## Resumen

| | |
|---|---|
| **representación limpia de una fórmula** | un functor por conectivo y por cuantificador, y otro para las fórmulas atómicas, leída de texto por un analizador léxico y una gramática por niveles |
| **entorno de la lectura** | los pares `Nombre-Variable` de los cuantificadores que rodean el punto leído: cada cuantificador liga una variable de Prolog nueva |
| **forma normal negada** | sin → ni ↔, con la negación delante de las fórmulas atómicas y los cuantificadores negados cambiados por su dual |
| **forma clausal** | una lista de cláusulas, cada una una lista ordenada de literales `+A` o `-A`; la distribución puede multiplicar las cláusulas por 2 en cada disyunción |
| **forma prenexa, skolemización** | los cuantificadores al frente; cada variable existencial ligada a un término nuevo de las universales anteriores |
| **refutación** | una lista de pasos `r(I, J, R)` y `f(I, R)` que termina en □; la más corta se busca con profundización iterativa sobre su longitud |
| **factorización** | unir dos literales del mismo signo de una cláusula; sin ella, la resolución binaria es incompleta |
| **comprobación de ocurrencia** | sin ella, la unificación crea términos cíclicos y el demostrador «prueba» fórmulas que no son teoremas |
| **estrategia lineal** | desde el segundo paso, cada uno usa la cláusula que agregó el anterior |
| **verificador** | un programa independiente que rehace cada paso; para confiar en una prueba alcanza con confiar en él |
| **modelo** | un conjunto de fórmulas atómicas sin variables que hace verdadera cada cláusula; existe si y solo si no hay refutación |
| **rango restringido** | cada variable de un literal positivo aparece en uno negativo, de modo que el modelo la liga |
| **conjunto de soporte** | la negación de lo que se prueba y sus descendientes; cada paso usa uno, y dos hipótesis no se resuelven entre sí |
| `leer_formula/2`, `formula_texto/2` | la lectura y la escritura |
| `fnn/2`, `fnc/2`, `clausulas/2`, `clausulas_fo/2` | la forma clausal |
| `demostrar/3`, `demostrar_fo/3`, `refutar_con/4`, `escribir_prueba/1` | el demostrador |
| `verificar/1` | el verificador |
| `tautologia/2`, `contraejemplo/2`, `palomar/2` | la comparación |
| `modelo/2`, `contramodelo/2` | la construcción de un modelo |
| `refutar_soporte/4`, `comparar_estrategias/3` | la estrategia de conjunto de soporte |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Reglas con excepciones, que la lógica clásica de este capítulo no puede expresar sin contradicción | [capítulo 66](../capitulo-66-proyecto-razonamiento-rebatible/index.md) |
| La subsunción entre cláusulas como orden de generalidad, para aprender reglas | [capítulo 68](../capitulo-68-proyecto-aprender-reglas-ejemplos/index.md) |
| La saturación de abajo hacia arriba, restringida a cláusulas de Horn sin funciones | [capítulo 86](../capitulo-86-proyecto-motor-datalog/index.md) |

## Referencias

- James L. Hein, *Prolog Experiments in Discrete Mathematics, Logic, and
  Computability*, Jones and Bartlett, 2009 — apartado «Tautology Tester».
  [Edición en línea](https://samples.jbpub.com/9780763772062/PrologLabBook09.pdf).
  Esta página toma el método de Quine para decidir tautologías.
- Markus Triska, *The Power of Prolog* — «Theorem Proving with Prolog».
  [Edición en línea](https://www.metalevel.at/prolog/theoremproving).
  Esta página toma la comparación del demostrador con `library(clpb)`.
- Peter Flach, *Simply Logical: Intelligent Reasoning by Example*, John
  Wiley, 1994 — apartado 5.4, «Forward chaining».
  [Edición en línea](https://book.simply-logical.space/src/text/2_part_ii/5.4.html).
  Esta página toma la búsqueda de un modelo de cláusulas indefinidas como
  la contracara de la refutación, que en la comparación es el
  contraejemplo de `library(clpb)`, y, en la
  [sección 63.9](#639-construir-un-modelo), el algoritmo de construcción:
  satisfacer una cláusula violada con uno de sus literales positivos, las
  cláusulas de rango restringido con un predicado de dominio, y sus
  ejemplos de modelos mínimos y no mínimos. El programa de Flach se
  escribe aquí de nuevo, sobre las cláusulas como listas de literales.
- Neil C. Rowe, *Artificial Intelligence through Prolog*, Prentice-Hall,
  1988 — capítulo «A more general logic programming», apartado
  «Resolution search strategies».
  [Edición en línea](https://faculty.nps.edu/ncrowe/book/chap14.html).
  Esta página toma la estrategia de conjunto de soporte de la
  [sección 63.10](#6310-el-conjunto-de-soporte) y la búsqueda en anchura
  del ejercicio 11.
- Rainer Manthey y François Bry, «SATCHMO: A Theorem Prover Implemented in
  Prolog», *9th International Conference on Automated Deduction*,
  Springer, 1988. El programa de construcción de modelos de Flach está
  adaptado de este demostrador; el capítulo toma de ahí la idea de un
  modelo como respuesta cuando no hay refutación, que la
  [sección 63.9](#639-construir-un-modelo) construye.
- Armin Haken, «The Intractability of Resolution», *Theoretical Computer
  Science* 39, 1985. La demostración de que toda refutación por
  resolución del principio del palomar crece en forma exponencial, el
  resultado que la comparación de la versión 7 mide.
- Randal E. Bryant, «Graph-Based Algorithms for Boolean Function
  Manipulation», *IEEE Transactions on Computers* C-35(8), 1986.
  [Copia del autor](https://www.cs.cmu.edu/~bryant/pubdir/ieeetc86.pdf).
  Los diagramas de decisión binarios ordenados sobre los que está
  construida `library(clpb)`; el capítulo toma de ahí la explicación de
  por qué `clpb` crece despacio con el palomar y por qué el orden de las
  variables decide el tamaño del diagrama.

El código del capítulo es propio, escrito para el curso: ninguno de los
programas de esos libros se copió, y la verificación independiente, la
estrategia lineal y la comparación medida no tienen equivalente en ellos.
