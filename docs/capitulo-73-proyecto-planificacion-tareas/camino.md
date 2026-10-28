# El camino crítico y el planificador

Esta página continúa el [capítulo 73](index.md) después de la
[sección 73.5](index.md#735-version-3-repartir-el-trabajo), con las
secciones [73.6](#736-version-4-el-camino-critico) y
[73.7](#737-version-5-el-planificador): la heurística del camino crítico,
su combinación con la del reparto, la tabla de estados expandidos con
cada heurística y la comparación entre A\* y la búsqueda voraz, y después
el planificador terminado, que combina las versiones anteriores y
acompaña su resultado con una garantía. Los ejemplos están en `camino.pl`
y `planificador.pl`, en `ejemplos/capitulo-73/`, con sus pruebas; son
`% solo-local`, porque cargan otros archivos.

## 73.6 Versión 4: el camino crítico

La otra relajación conserva las precedencias y supone procesadores de
sobra. La **cola** de una tarea es su duración más la mayor cola de las
tareas que la esperan: el tiempo mínimo entre el inicio de la tarea y el
final de la última de sus sucesoras, aunque cada tarea tenga su propio
procesador. La cadena de colas máximas es el **camino crítico** del
proyecto.

<!-- ejemplo: capitulo-73/camino.pl predicado: cola/3 -->
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

<!-- contexto: capitulo-73/camino.pl -->
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

<!-- ejemplo: capitulo-73/camino.pl predicado: camino/3 inicio_minimo/5 combinada/3 -->
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
[capítulo 41](../capitulo-41-busqueda-y-planificacion/heuristicas.md#415-heuristicas-a-e-ida) sigue siempre el
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
ninguna heurística, y el ejercicio 8 mide la diferencia en los proyectos
`taller(N)`.

## 73.7 Versión 5: el planificador

La versión 4 resuelve los proyectos chicos, pero el costo de A\* puede
crecer de un proyecto al siguiente sin aviso. El planificador terminado
combina las versiones anteriores y empieza por lo barato:

1. arma tres calendarios por lista, con las prioridades `orden`, `larga`
   y la de mayor cola primero, y se queda con el más corto;
2. calcula la estimación de la heurística combinada en el estado inicial:
   una **cota inferior** de la duración óptima;
3. si el calendario por lista llega a la cota, es óptimo y no hace falta
   buscar;
4. si no, ejecuta A\* con la heurística combinada dentro de
   `call_with_inference_limit/3`
   ([capítulo 16](../capitulo-16-control/index.md)), y si termina dentro
   del límite, el calendario es óptimo;
5. si la búsqueda pasa del límite, devuelve el calendario por lista con
   la garantía `entre(Cota, D)`: la duración óptima está entre la cota y
   la del calendario.

Antes de todo eso, `orden_topologico/2` rechaza los proyectos cuyas
precedencias forman un ciclo, para los que `cola/3` no termina.

<!-- ejemplo: capitulo-73/planificador.pl predicado: planificar/4 cota_inferior/2 -->
```prolog
%!  planificar(+Proyecto, +Limite:integer, -Calendario:list, -Garantia)
%!      is semidet.
%
%   Calendario es un calendario de Proyecto. Garantia es optima(Metodo)
%   si es óptimo, con Metodo por_lista cuando el mejor calendario por
%   lista llega a la cota inferior y a_estrella cuando lo halló A* sin
%   pasar de Limite inferencias. Si A* pasa del límite, Garantia es
%   entre(Cota, D): Calendario es el mejor calendario por lista, dura D, y
%   ningún calendario dura menos que Cota. Falla si las precedencias
%   forman un ciclo.
planificar(Proyecto, Limite, Calendario, Garantia) :-
    orden_topologico(Proyecto, _),
    mejor_por_lista(Proyecto, PorLista),
    duracion(PorLista, D),
    cota_inferior(Proyecto, Cota),
    (   D =:= Cota
    ->  Calendario = PorLista,
        Garantia = optima(por_lista)
    ;   call_with_inference_limit(optimo(Proyecto, combinada, Optimo, _),
                                  Limite, Resultado),
        Resultado \== inference_limit_exceeded
    ->  Calendario = Optimo,
        Garantia = optima(a_estrella)
    ;   Calendario = PorLista,
        Garantia = entre(Cota, D)
    ).

%!  cota_inferior(+Proyecto, -Cota:integer) is det.
%
%   Cota es lo que estima la heurística combinada en el estado inicial:
%   ningún calendario de Proyecto dura menos.
cota_inferior(Proyecto, Cota) :-
    inicial(datos(Proyecto, combinada), Estado),
    combinada(Proyecto, Estado, Cota).
```

<!-- contexto: capitulo-73/planificador.pl -->
```prolog
?- informe_de(taller(14), 1000).
P1 t1----------------------t10---------t12---------------------
P2 t3--------------t8----------------------t2----t4--------t11-
P3 t6--------------t14-------------t5--------t7----t13---t9--
duración: 30
es la duración óptima (por_lista)
true.

?- planificar_ejemplo(taller(13), 1000000, D, G).
D = 28,
G = entre(27, 28).

?- planificar_ejemplo(taller(13), 3000000, D, G).
D = 27,
G = optima(a_estrella).
```

`taller(14)`, que a A\* le cuesta casi diez millones de inferencias, se
resuelve sin buscar: el mejor calendario por lista dura 30, lo mismo que
la cota, y la respuesta completa cuesta 3 757 inferencias. En
`taller(13)` la lista da 28 y la cota 27; con un millón de inferencias
A\* no termina, y el planificador responde con la garantía; con tres
millones encuentra un calendario de 27 y prueba que es óptimo. Las
mediciones de la versión 5 con un límite de un millón de inferencias:

| Proyecto | Duración | Garantía | Inferencias |
|---|---|---|---|
| `coffman` | 24 | óptima, por A\* | 16 532 |
| `casa` | 28 | óptima, por A\* | 23 517 |
| `taller(13)` | 28 | entre 27 y 28 | 1 003 519 |
| `taller(14)` | 30 | óptima, por lista | 3 757 |
| `taller(20)` | 42 | óptima, por lista | 5 661 |
| `taller(40)` | 82 | entre 81 y 82 | 1 013 216 |

El planificador nunca gasta más que el límite, más lo que cuestan los
calendarios por lista y la cota, y cuando no puede probar el óptimo dice
cuánto puede faltar. Bratko cierra su capítulo recordando, con la obra de
Garey y Johnson sobre problemas intratables, que para muchos problemas de
planificación ninguna heurística general asegura a la vez la eficiencia y
la admisibilidad en todos los casos; la garantía es la manera de informar
lo que se sabe cuando el límite corta la búsqueda.

!!! example "Patrón 71 — Resultado con garantía"
    **Problema.** Una búsqueda exacta, como A\* con una heurística
    admisible, da el óptimo, pero su costo puede crecer de un caso al
    siguiente sin aviso, y es necesario responder siempre dentro de un
    presupuesto.

    **Versión ingenua.** Ejecutar la búsqueda exacta sin límite, como
    `optimo/4`, que en `taller(14)` cuesta casi diez millones de
    inferencias; o cortarla con un límite y, si se alcanza, fallar o
    devolver una solución heurística sin decir cuánto puede alejarse del
    óptimo.

    **Patrón.** Empezar por lo barato: una solución rápida, el mejor
    calendario por lista, y una **cota inferior** probada, la estimación
    admisible en el estado inicial que calcula `cota_inferior/2`. Si
    coinciden, la solución es óptima sin buscar. Si no, la búsqueda exacta
    corre dentro de `call_with_inference_limit/3`; si termina, su
    resultado es óptimo, y si pasa del límite, `planificar/4` devuelve la
    solución rápida junto con `entre(Cota, D)`. La respuesta dice qué se
    sabe: en `taller(13)`, con un millón de inferencias, un calendario de
    28 que no puede mejorarse en más de una unidad; con tres millones,
    el de 27, `optima(a_estrella)`. La garantía es un término que el
    llamador examina, no un mensaje.

    **Cuándo no usarlo.** Cuando no hay una cota inferior barata y
    probada: una estimación que no es admisible convierte la garantía en
    una afirmación falsa. Cuando la cota es tan débil que el intervalo no
    informa nada. Y cuando el costo de la búsqueda exacta está acotado de
    antemano, como en los proyectos chicos: el límite y la cota agregan
    trabajo a una respuesta que igual llega.

El capítulo continúa en la página
[Anomalías, consistencia y holguras](extensiones.md#738-anomalias-consistencia-y-holguras),
con tres temas de las fuentes que las cinco versiones no desarrollan: las
anomalías de la planificación por lista, la consistencia de las
heurísticas y las holguras de las tareas.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

6. ★ **(1)** Con la obra `casa` y tres cuadrillas en lugar de dos,
   predecir la estimación de `reparto/3` y de `camino/3` en el estado
   inicial, la cota inferior y la duración óptima. Comprobarlo con un
   predicado `con_procesadores(Proyecto0, N, Proyecto)` y con
   `planificar/4`, y decir qué garantía da y por qué.
7. **(2)** La **cabeza** de una tarea es el momento más temprano en que
   puede empezar si sobran procesadores. Escribir `cabeza/3` y
   `criticas(Proyecto, Tareas)`, las tareas cuya cabeza más cola es la
   mayor cola del proyecto, con sus cabeceras PlDoc: modos, determinación
   y una descripción que diga qué significa que una tarea sea crítica.
   Obtener las tareas críticas de `coffman` y de `casa`.
8. **(2)** Escribir `comparar_voraz(Ns, Filas)`, que compara la búsqueda
   voraz con A\* sobre `taller(N)` para cada N de `Ns`, las dos con la
   heurística combinada: duración y estados expandidos. Medir con N = 6 y
   N = 12 y explicar el resultado.
9. **(3)** El [capítulo 41](../capitulo-41-busqueda-y-planificacion/index.md) también escribió IDA\*. Escribir
   `optimo_ida(Proyecto, Heuristica, D, K)` con `ida_estrella/4` y
   `busqueda.pl`, y comparar sus estados expandidos con los de A\* para
   `reparto` y `combinada` en `coffman` y en `casa`. Explicar por qué IDA\*
   expande menos en un caso y muchos más en otro.
10. ★ **(2)** Escribir `curva(Proyecto, Ns, Duraciones)`, la duración
    óptima con cada cantidad de procesadores de `Ns`. Obtenerla para `casa`
    y para `coffman` con uno a cuatro procesadores y explicar a partir de
    qué cantidad la duración deja de bajar.
11. **(1)** Predecir qué garantía da `planificar/4` para `casa` con límites
    de 1 000, 10 000 y 100 000 inferencias, y comprobarlo con
    `planificar_ejemplo/4`.

## Referencias

- Ivan Bratko, *Prolog Programming for Artificial Intelligence*,
  Addison-Wesley, 1986 — capítulo «Best-first: A Heuristic Search
  Principle», apartado «Best-first search applied to scheduling». Sin
  edición en línea de acceso libre. Esta página
  toma de allí la propuesta final de buscar heurísticas mejores, que la
  versión 4 desarrolla con el camino crítico, y la observación con la que
  el capítulo de Bratko cierra, sobre los límites de las heurísticas en
  la planificación.
- Peter E. Hart, Nils J. Nilsson y Bertram Raphael, «A formal basis for
  the heuristic determination of minimum cost paths», *IEEE Transactions
  on Systems Science and Cybernetics* SSC-4(2), 1968, pp. 100–107.
  [Copia de Nilsson](https://ai.stanford.edu/~nilsson/OnlinePubs-Nils/PublishedPapers/astar.pdf).
  El artículo de A\* y del teorema de admisibilidad, al que Bratko
  remite: con una estimación que nunca supera el costo restante, la
  búsqueda da el óptimo. Esta página lo usa para justificar que las
  heurísticas de la versión 4, obtenidas por relajación, dan calendarios
  óptimos, y que la estimación en el estado inicial es una cota inferior
  que el planificador puede informar.
- Michael R. Garey y David S. Johnson, *Computers and Intractability: A
  Guide to the Theory of NP-Completeness*, W. H. Freeman, 1979. Sin
  edición en línea de acceso libre. Bratko remite a esta obra para los
  límites de las heurísticas en los problemas de planificación; el
  capítulo la cita en la
  [sección 73.7](#737-version-5-el-planificador) como razón del
  planificador con garantía.
- E. G. Coffman y P. J. Denning, *Operating Systems Theory*,
  Prentice-Hall, 1973 — el ejemplo de siete tareas y tres procesadores,
  tomado a través de Bratko, que lo cita. Sin edición en línea de acceso
  libre.
