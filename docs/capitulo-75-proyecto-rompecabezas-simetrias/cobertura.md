# La cobertura del tablero

Esta página completa la
[sección 75.5](index.md#755-version-4-el-lazo-a-la-vista) del
[capítulo 75](index.md) con la exigencia de cobertura del rompecabezas
del lazo. El código está en `vista.pl`, en `ejemplos/capitulo-75/`, con
sus pruebas.

Csenki agrega una exigencia: que el lazo pase por
todas las casillas del tablero. En `csenki1` la cumple sin pedirla; en
`csenki2`, de los diez lazos, uno solo la cumple. `cubre/2` compara la
longitud del lazo con la cantidad de casillas, y `cobertura/3` cuenta:

<!-- ejemplo: capitulo-75/vista.pl predicado: cubre/2 cobertura/3 -->
```prolog
%!  cubre(+Nombre, +Lazo:list) is semidet.
%
%   Lazo pasa por todas las casillas del tablero Nombre.
cubre(Nombre, Lazo) :-
    problema(Nombre, Filas, Columnas, _),
    length(Lazo, N),
    N =:= Filas * Columnas.

%!  cobertura(+Nombre, -Distintos:integer, -Cubren:integer) is det.
%
%   Distintos es la cantidad de lazos distintos del tablero Nombre y
%   Cubren, cuántos de ellos pasan por todas sus casillas.
cobertura(Nombre, Distintos, Cubren) :-
    distintos(Nombre, Formas),
    length(Formas, Distintos),
    include(cubre(Nombre), Formas, Completos),
    length(Completos, Cubren).
```

```prolog
?- cobertura(cruz, D, C).
D = 5,
C = 0.
```

`cobertura(csenki2, D, C)` da `D = 10` y `C = 1` en unos cinco segundos.
El lazo que cubre las 72 casillas es este:

```text
#─────────#───#
│             │
└───────────O │
            │ │
┌─────────#─┘ #
│             │
│ O─────┐ │ │ │
│ │     │ │ │ │
│ │ O─┐ │ │ O │
│ │ │ │ │ │ │ │
│ │ │ #─# │ │ │
│ │ │     │ │ │
│ │ └─────# │ │
│ │         │ │
│ O─────────O │
│             │
O─────────────┘
```
