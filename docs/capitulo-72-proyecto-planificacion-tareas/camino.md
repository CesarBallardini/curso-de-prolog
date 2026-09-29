# El camino crítico

Esta página contiene la sección [72.6](index.md#726-version-4-el-camino-critico)
del [capítulo 72](index.md): la heurística del camino crítico, su
combinación con la del reparto, la tabla de estados expandidos con cada
heurística y la comparación entre A\* y la búsqueda voraz. El ejemplo está
en `camino.pl`, en `ejemplos/capitulo-72/`, con sus pruebas; es
`% solo-local`, porque carga otros archivos.

## Versión 4: el camino crítico

La otra relajación conserva las precedencias y supone procesadores de
sobra. La **cola** de una tarea es su duración más la mayor cola de las
tareas que la esperan: el tiempo mínimo entre el inicio de la tarea y el
final de la última de sus sucesoras, aunque cada tarea tenga su propio
procesador. La cadena de colas máximas es el **camino crítico** del
proyecto.

<!-- ejemplo: capitulo-72/camino.pl predicado: cola/3 -->
```prolog
%!  cola(+Proyecto, +Tarea, -Cola:integer) is det.
%
%   Cola es la duración de Tarea más la mayor cola de sus sucesoras en
%   Proyecto, o solo su duración si no tiene sucesoras. Las precedencias
%   de Proyecto no pueden formar un ciclo: si lo forman, no termina.
cola(Proyecto, Tarea, Cola) :-
    tarea(Proyecto, Tarea, Duracion),
    findall(C,
            ( precede(Proyecto, Tarea, Siguiente),
              cola(Proyecto, Siguiente, C) ),
            Colas),
    max_list([0|Colas], Mayor),
    Cola is Duracion + Mayor.
```

<!-- contexto: capitulo-72/camino.pl -->
```prolog
?- colas(coffman, Colas).
Colas = [t1-24, t2-22, t3-22, t4-20, t5-20, t6-11, t7-11].
```

En un estado, una tarea pendiente no puede empezar antes de que se libere
el primer procesador ni antes de que terminen sus predecesoras ya
empezadas; desde ese momento, su cola es una cota inferior de lo que
falta. `camino/3` toma la mayor de esas cotas para todas las tareas
pendientes. Las dos heurísticas miden cosas distintas —la carga de los
procesadores y la longitud de las cadenas—, y ninguna domina a la otra.
El máximo de dos heurísticas que nunca estiman de más tampoco estima de
más, y es al menos tan bueno como cada una: es `combinada/3`.

<!-- ejemplo: capitulo-72/camino.pl predicado: camino/3 inicio_minimo/5 combinada/3 -->
```prolog
%!  camino(+Proyecto, +Estado, -H:integer) is det.
%
%   H es cuánto le falta al calendario de Estado para que termine la tarea
%   pendiente de mayor cola, empezada lo antes posible, o 0 si nada falta.
camino(Proyecto, e(Pendientes, [Primero|Libres], Fines), H) :-
    max_list([Primero|Libres], D),
    findall(Fin,
            ( member(Tarea, Pendientes),
              inicio_minimo(Proyecto, Tarea, Primero, Fines, Inicio),
              cola(Proyecto, Tarea, Cola),
              Fin is Inicio + Cola ),
            Finales),
    max_list([D|Finales], Mayor),
    H is Mayor - D.

%!  inicio_minimo(+Proyecto, +Tarea, +Primero:integer, +Fines:list,
%!                -Inicio:integer) is det.
%
%   Inicio es el mayor entre Primero y el fin de cada predecesora de Tarea
%   que ya empezó.
inicio_minimo(Proyecto, Tarea, Primero, Fines, Inicio) :-
    findall(F,
            ( precede(Proyecto, Antes, Tarea),
              memberchk(Antes-F, Fines) ),
            Fs),
    max_list([Primero|Fs], Inicio).

%!  combinada(+Proyecto, +Estado, -H:integer) is det.
%
%   H es la mayor de las estimaciones de reparto/3 y camino/3.
combinada(Proyecto, Estado, H) :-
    reparto(Proyecto, Estado, H1),
    camino(Proyecto, Estado, H2),
    H is max(H1, H2).
```

```prolog
?- estimacion_inicial(casa, camino, H).
H = 27.

?- medir(casa, camino, D, K).
D = 28,
K = 16.

?- medir(coffman, combinada, D, K).
D = 24,
K = 9.
```

La tabla resume los estados expandidos por A\* con cada heurística. Las
celdas sin número son búsquedas que pasaron de cien millones de
inferencias o que agotaron la memoria de la pila:

| Proyecto | `cero` | `reparto` | `camino` | `combinada` |
|---|---|---|---|---|
| `coffman` | 803 | 21 | 26 | 9 |
| `casa` | 381 | 231 | 16 | 16 |
| `taller(6)` | 1 036 | 93 | 71 | 29 |
| `taller(8)` | 38 145 | 1 047 | 114 | 9 |
| `taller(10)` | más de 10⁸ inferencias | 15 | 25 318 | 11 |
| `taller(12)` | sin memoria | 295 | más de 10⁸ inferencias | 43 |
| `taller(14)` | sin memoria | 58 130 | más de 10⁸ inferencias | 8 932 |
| `taller(16)` | sin memoria | 303 | más de 10⁸ inferencias | 28 |

Dos observaciones. Primera: en los proyectos con pocas precedencias,
como los `taller(N)`, el reparto es la heurística que importa, y en la
obra, el camino crítico; la combinada es la mejor o empata con la mejor
en todas las filas. Segunda: el costo no crece de manera uniforme con N,
porque depende de cuántos estados tienen una estimación que no pasa del
óptimo. A\* expande todos los de estimación menor antes de terminar, y
entre los que empatan con el óptimo el montículo no distingue cuál está
más cerca de completar el calendario. En `taller(14)` la estimación
inicial de la combinada, 30, ya es la duración óptima, y aun así la
búsqueda recorre 8 932 estados, casi diez millones de inferencias, entre
los muchos que empatan en ese valor.

**Óptimo y voraz.** La búsqueda voraz del
[capítulo 40](../capitulo-40-busqueda-y-planificacion/heuristicas.md#heuristicas-a-e-ida) sigue siempre el
estado de menor estimación, sin mirar el costo acumulado. `voraz/4` la
usa con la misma heurística:

```prolog
?- medir_voraz(coffman, reparto, D, K).
D = 33,
K = 8.

?- medir_voraz(coffman, combinada, D, K).
D = 24,
K = 8.
```

Con `reparto` la búsqueda voraz llega a 33, como la planificación por
lista; con `combinada`, que es más informada, llega a 24 en este
proyecto. Nada lo asegura: la búsqueda voraz no garantiza el óptimo con
ninguna heurística, y el ejercicio 5 mide la diferencia en los proyectos
`taller(N)`.
