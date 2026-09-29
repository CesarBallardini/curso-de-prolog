# Tres maneras de decidir

Esta página contiene la sección
[62.8](index.md#628-tres-maneras-de-decidir) del [capítulo 62](index.md):
la versión 7, `comparacion.pl`, que compara el demostrador por resolución
con dos procedimientos que deciden la lógica proposicional. El archivo está
en `ejemplos/capitulo-62/`, con sus pruebas, y carga las versiones
anteriores.

## Tres maneras de decidir

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

<!-- ejemplo: capitulo-62/comparacion.pl predicado: quine/2 -->
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
([sección 48.4](../capitulo-48-proyecto-circuitos-logicos/index.md#484-verificar-con-libraryclpb)):

<!-- ejemplo: capitulo-62/comparacion.pl predicado: expresion/3 -->
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

## Lo que produce cada método

Los tres dan el mismo veredicto, pero no el mismo resultado. Cuando la
fórmula no es un teorema, la resolución solo dice que no encontró una
refutación. `library(clpb)` da más: `sat(~E)` restringe las variables a
las asignaciones que hacen falsa la fórmula, y `labeling/1` elige una.
Esa asignación es un **modelo** de la negación, la contracara de la
refutación: Flach construye modelos de cláusulas indefinidas por
encadenamiento hacia adelante, y aquí la biblioteca lo hace sobre la
fórmula entera:

<!-- ejemplo: capitulo-62/comparacion.pl predicado: contraejemplo/2 -->
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
[ejercicio 10](index.md#ejercicios) los reúne en un solo predicado.

## El principio del palomar

La familia de fórmulas con que se mide es el **principio del palomar**:
n + 1 palomas no caben en n agujeros, uno por paloma. `palomar/2` la
construye con los átomos `en(I, J)`, «la paloma I está en el agujero J»:
no puede ser que cada paloma esté en algún agujero y que ningún agujero
tenga dos palomas:

<!-- ejemplo: capitulo-62/comparacion.pl predicado: palomar/2 -->
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
crece en forma exponencial con n. La tabla da las inferencias de
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
diagrama de decisión comparte las subfórmulas iguales; para otras
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
