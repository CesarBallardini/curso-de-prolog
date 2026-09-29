# Un demostrador por resolución

Esta página contiene la sección
[60.6](index.md#606-version-4-un-demostrador-por-resolucion) del
[capítulo 60](index.md): la versión 4, `resolucion.pl`, un programa
dirigido por patrones que demuestra fórmulas de la lógica proposicional. El
archivo está en `ejemplos/capitulo-60/`, con sus pruebas, y carga la
versión 3, `conflictos.pl`.

## Un demostrador por resolución

Una fórmula es un **teorema** si es verdadera cualquiera que sea el valor de
sus átomos. El método de resolución lo prueba por el absurdo: niega la
fórmula, la escribe como un conjunto de **cláusulas** —disyunciones de
literales, un átomo o su negación— y combina cláusulas hasta obtener la
cláusula vacía, que ninguna asignación satisface. Si la cláusula vacía
aparece, la negación es contradictoria y la fórmula es un teorema. El paso
de resolución toma dos cláusulas, una con un literal `P` y otra con `-P`, y
produce el **resolvente**: la disyunción de los demás literales de las dos.

Las fórmulas se escriben con `-` (negación, predefinido), `&`, `v` y `==>`,
con precedencias crecientes, de modo que la negación liga más que la
conjunción, y esta más que la disyunción y la implicación. Una cláusula es
una lista ordenada de literales, y `clausulas/2` pasa una fórmula a forma
clausal: primero lleva la negación hasta los átomos y elimina `==>`, después
distribuye la disyunción sobre la conjunción:

<!-- ejemplo: capitulo-60/resolucion.pl predicado: clausulas/2 fnc/2 -->
```prolog
%!  clausulas(+Formula, -Clausulas:list) is det.
%
%   Clausulas es la forma clausal de Formula, sin repeticiones: cada
%   cláusula es una lista ordenada de literales.
clausulas(Formula, Clausulas) :-
    fnn(Formula, F),
    fnc(F, Cs),
    sort(Cs, Clausulas).

%!  fnc(+F, -Clausulas:list) is det.
%
%   Clausulas es la lista de cláusulas de F, una fórmula en forma normal
%   negada: una conjunción de disyunciones de literales.
fnc(P, [[P]]) :-
    atom(P).
fnc(A & B, Cs) :-
    fnc(A, CA),
    fnc(B, CB),
    append(CA, CB, Cs).
fnc(A v B, Cs) :-
    fnc(A, CA),
    fnc(B, CB),
    findall(C, ( member(X, CA), member(Y, CB), ord_union(X, Y, C) ), Cs).
fnc(-P, [[-P]]).
```

```prolog
?- clausulas(-((a ==> b) & (b ==> c) ==> (a ==> c)), Cs).
Cs = [[a], [b, -a], [c, -b], [-c]].
```

El demostrador es un programa de cuatro módulos, y cada cláusula es un hecho
`clausula(C)` de la memoria:

<!-- ejemplo: capitulo-60/resolucion.pl fragmento: programa(resolucion, .. ]). -->
```prolog
programa(resolucion,
    [ contradiccion :: [clausula([])]
           ---> [parar(contradiccion)],
      tautologia :: [clausula(C), {tautologica(C)}]
           ---> [quitar(clausula(C))],
      resolver :: [clausula(C1), clausula(C2),
                   {resolvente(C1, C2, R), \+ tautologica(R)},
                   no(clausula(R))]
           ---> [agregar(clausula(R))],
      agotado :: []
           ---> [parar(sin_contradiccion)]
    ]).
```

`contradiccion` termina cuando aparece la cláusula vacía. `tautologia` quita
las cláusulas que tienen un literal y su opuesto, que son verdaderas y no
sirven para llegar a una contradicción. `resolver` agrega un resolvente que
no es tautológico y que todavía no está en la memoria; esa última condición,
`no(clausula(R))`, cumple el papel del registro `done` de Bratko: sin ella,
el mismo resolvente se agregaría una y otra vez. `agotado`, sin condiciones,
se aplica siempre, y por eso va al final: con `primera`, solo se elige cuando
ningún otro módulo se puede aplicar. Las cláusulas como listas ordenadas
hacen innecesario el módulo de Bratko que quita literales repetidos:
`ord_union/3` no los repite.

<!-- ejemplo: capitulo-60/resolucion.pl predicado: resolvente/3 -->
```prolog
%!  resolvente(+C1:list, +C2:list, -R:list) is nondet.
%
%   R es un resolvente de las cláusulas C1 y C2: C1 tiene un literal L,
%   C2 su opuesto, y R reúne los demás literales de las dos.
resolvente(C1, C2, R) :-
    select(L, C1, R1),
    opuesto(L, M),
    selectchk(M, C2, R2),
    ord_union(R1, R2, R).
```

La estrategia no cambia el veredicto, pero sí el trabajo. Con `especifica`,
`resolver` —cuatro condiciones— se prefiere a `contradiccion` —una—, y el
programa sigue resolviendo después de haber encontrado la cláusula vacía:

```prolog
?- trazar_demostracion((a ==> b) & (b ==> c) ==> (a ==> c), especifica, V).
1: resolver de 7, con [clausula([a]),clausula([b,-a])]
2: resolver de 7, con [clausula([b]),clausula([c,-b])]
3: resolver de 7, con [clausula([c]),clausula([-c])]
4: resolver de 6, con [clausula([b,-a]),clausula([c,-b])]
5: resolver de 6, con [clausula([c,-a]),clausula([-c])]
6: resolver de 4, con [clausula([c,-b]),clausula([-c])]
7: contradiccion de 2, con [clausula([])]
V = teorema.
```

Una fórmula que no es teorema deja la memoria sin resolventes nuevos, y
`agotado` termina:

```prolog
?- demostrar((p ==> q) ==> (q ==> p), primera, V).
V = no_teorema.

?- demostrar(((p ==> q) ==> p) ==> p, primera, V).
V = teorema.
```

El demostrador es pequeño a propósito: trabaja con la lógica proposicional,
compara todas las cláusulas con todas y no quita las cláusulas que otras
subsumen. Termina porque con una cantidad finita de átomos hay una cantidad
finita de cláusulas sin literales repetidos, y ninguna se agrega dos veces.
El [capítulo 62](../capitulo-62-proyecto-demostrador-teoremas/index.md)
construye un demostrador completo, con un lector de fórmulas, la forma
clausal de la lógica de predicados y refutaciones que se pueden verificar.

**Lo que falta.** Los tres programas de ejemplo terminan, pero nada en el
intérprete lo garantiza: un módulo mal escrito puede hacer que el ciclo no
termine nunca.
