# El llamado a examen

Esta página continúa el [capítulo 74](index.md) después de la
[sección 74.8](optimo.md#748-version-6-la-grilla-web), con la
[sección 74.9](#749-el-llamado-a-examen), que lo termina: el llamado a
examen de *Inscripciones* armado con el planificador del
[capítulo 73](../capitulo-73-proyecto-planificacion-tareas/index.md) y
después con restricciones. Todo está en `examenes.pl`, que carga los
datos y los conflictos del
[capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md#328-el-proyecto-inscripciones-se-entrega)
y el planificador del [capítulo 73](../capitulo-73-proyecto-planificacion-tareas/index.md), sin copiarlos.

## 74.9 El llamado a examen

El [capítulo 24](../capitulo-24-programacion-con-restricciones/index.md#2413-el-proyecto-el-calendario-de-examenes)
armó el calendario de exámenes con restricciones. El
[capítulo 73](../capitulo-73-proyecto-planificacion-tareas/index.md)
dejó un planificador de tareas sobre procesadores, y el llamado a examen
también es un proyecto de ese tipo: los exámenes son tareas de un día,
las aulas son los procesadores y las correlativas son precedencias, porque
un alumno que rinde las dos materias necesita rendir antes la correlativa.
Esta sección lo resuelve con el planificador del
[capítulo 73](../capitulo-73-proyecto-planificacion-tareas/index.md) y
muestra lo que ese modelo no puede expresar: los conflictos de los
alumnos que rinden dos materias.

### El llamado como proyecto de tareas

Cada materia tiene un examen que dura un día. Cada día hay tantas aulas
como indica el llamado, y cada aula toma un examen por día. Y un examen
va después del de cada una de sus correlativas, para que un alumno pueda
rendir las dos en el mismo llamado: primero la correlativa, y la otra
cuando ya la aprobó. Así planteado, el llamado es un proyecto de
`tareas.pl`: los exámenes son las tareas, las aulas los procesadores y las
correlativas las precedencias.

<!-- ejemplo: capitulo-74/examenes.pl predicado: proyecto_examenes/2 llamado_73/3 -->
```prolog
%!  proyecto_examenes(+Aulas:integer, -Proyecto) is det.
%
%   Proyecto es el llamado a examen como proyecto del capítulo 73: una
%   tarea de duración 1 por materia, una precedencia antes(R, M) por cada
%   correlativa R de M, y Aulas procesadores.
proyecto_examenes(Aulas, proyecto(Tareas, Precedencias, Aulas)) :-
    must_be(positive_integer, Aulas),
    findall(tarea(M, 1), materia(M, _, _), Tareas),
    findall(antes(R, M), correlativa(M, R), Precedencias).

%!  llamado_73(+Aulas:integer, -Calendario:list, -Garantia) is det.
%
%   Calendario es el llamado más corto con Aulas aulas por día según el
%   planificador del capítulo 73, con la Garantia que este da.
llamado_73(Aulas, Calendario, Garantia) :-
    proyecto_examenes(Aulas, Proyecto),
    planificar(Proyecto, 1000000, Calendario, Garantia).
```

`planificar/4` del [capítulo 73](../capitulo-73-proyecto-planificacion-tareas/camino.md#737-version-5-el-planificador)
devuelve el llamado más corto y su garantía, y `mostrar_llamado/1` lo
escribe un día por línea, con los exámenes en el orden de las aulas:

<!-- contexto: capitulo-74/examenes.pl -->
```prolog
?- ver_llamado_73(2).
día 1: am1 alg
día 2: log am2
día 3: pp ssl
día 4: bd
garantía: optima(por_lista)
conflictos: [alg-am1,am2-log]
true.
```

Con dos aulas, el llamado dura cuatro días, el mínimo posible: la cadena
de correlativas Lógica, Paradigmas, Bases de datos ya ocupa tres días, y
siete exámenes en dos aulas necesitan al menos cuatro. La garantía dice
que el calendario por lista alcanzó la cota inferior y no hizo falta
buscar.

### Lo que el modelo de tareas no expresa

El llamado no sirve: Análisis 1 y Álgebra rinden el mismo día, y ana
(legajo 101), que está inscripta en las dos, no puede rendir ambas. Los
**conflictos** son los pares de materias con un alumno inscripto en
común, los de `conflicto/2` del módulo `horarios` del [capítulo 32](../capitulo-32-ejecutables-y-distribucion/index.md), y el
proyecto de tareas no tiene cómo representarlos: los procesadores son
idénticos, y una precedencia ordena dos tareas pero no puede pedir que
caigan en días distintos sin imponer cuál va primero.
`conflictos_violados/2` los busca en un calendario cualquiera:

<!-- ejemplo: capitulo-74/examenes.pl predicado: conflictos_violados/2 -->
```prolog
%!  conflictos_violados(+Calendario:list, -Pares:list) is det.
%
%   Pares son los pares M1-M2 de materias en conflicto que Calendario pone
%   el mismo día.
conflictos_violados(Calendario, Pares) :-
    findall(M1-M2,
            ( conflicto(M1, M2),
              memberchk(asignada(M1, _, Dia, _), Calendario),
              memberchk(asignada(M2, _, Dia, _), Calendario) ),
            Pares).
```

Con tres aulas, el planificador acorta el llamado a tres días, y los
conflictos aumentan:

```prolog
?- ver_llamado_73(3).
día 1: am1 alg log
día 2: am2 pp ssl
día 3: bd
garantía: optima(por_lista)
conflictos: [am1-log,alg-am1,alg-log,am2-pp]
true.
```

### El llamado con restricciones

`llamado_clpfd/3` usa el modelo del
[capítulo 24](../capitulo-24-programacion-con-restricciones/index.md#2413-el-proyecto-el-calendario-de-examenes),
con los dos agregados del [capítulo 73](../capitulo-73-proyecto-planificacion-tareas/index.md): una variable por examen con su
día; una desigualdad estricta por correlativa; una diferencia por
conflicto; y `global_cardinality/2`, que limita los exámenes de cada día
a la cantidad de aulas. El etiquetado con `min(Dias)` devuelve el llamado
más corto, y `repartir/3` del [capítulo 73](../capitulo-73-proyecto-planificacion-tareas/index.md) asigna las aulas, de modo que
el resultado es otra vez un calendario que `valido/2` puede verificar:

<!-- ejemplo: capitulo-74/examenes.pl predicado: llamado_clpfd/3 precedencia/2 dia_distinto/2 -->
```prolog
%!  llamado_clpfd(+Aulas:integer, -Calendario:list, -Dias:integer) is semidet.
%
%   Calendario es un llamado de Aulas aulas por día que respeta las
%   correlativas y los conflictos, con la menor cantidad de días, Dias. Es
%   un calendario del capítulo 73: el examen de M el día D (desde 0) es
%   asignada(M, Aula, D, D + 1). Falla si no hay ninguno.
llamado_clpfd(Aulas, Calendario, Dias) :-
    proyecto_examenes(Aulas, proyecto(Tareas, _, _)),
    length(Tareas, N),
    findall(M-_, member(tarea(M, _), Tareas), Pares),
    pairs_values(Pares, Ds),
    Ultimo is N - 1,
    Ds ins 0..Ultimo,
    Dias in 1..N,
    maplist(antes_de(Dias), Ds),
    findall(R-M, correlativa(M, R), Correlativas),
    maplist(precedencia(Pares), Correlativas),
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(dia_distinto(Pares), Conflictos),
    numlist(0, Ultimo, Todos),
    findall(D-_, member(D, Todos), Cuentas),
    pairs_values(Cuentas, Cs),
    Cs ins 0..Aulas,
    global_cardinality(Ds, Cuentas),
    once(labeling([min(Dias), ff], [Dias|Ds])),
    findall(tramo(M, D, F), ( member(M-D, Pares), F is D + 1 ), Tramos),
    repartir(Aulas, Tramos, Calendario).

%!  precedencia(+Pares:list, +Correlativa:pair) is det.
%
%   El examen de la correlativa R va un día antes que el de M, por lo
%   menos, para un par R-M.
precedencia(Pares, R-M) :-
    memberchk(R-DR, Pares),
    memberchk(M-DM, Pares),
    DR #< DM.

%!  dia_distinto(+Pares:list, +Conflicto:pair) is det.
%
%   Las dos materias del Conflicto rinden en días distintos.
dia_distinto(Pares, M1-M2) :-
    memberchk(M1-D1, Pares),
    memberchk(M2-D2, Pares),
    D1 #\= D2.
```

```prolog
?- ver_llamado(2).
día 1: alg
día 2: log
día 3: am1 ssl
día 4: pp
día 5: am2 bd
días: 5
true.
```

Con los conflictos, el llamado dura cinco días, y una tercera aula no lo
acorta: ana está inscripta en cinco materias, todas en conflicto entre
sí, y necesita cinco días distintos. El límite ya no lo ponen las aulas
sino los alumnos. El modelo de tareas sirvió para lo que sabía expresar,
y el de restricciones agregó lo que le faltaba sin cambiar el formato del
resultado: los dos calendarios se verifican con el mismo `valido/2`.

!!! question "Actividad"
    Predecir cuántos días dura el llamado con una sola aula, con
    `llamado_73/3` y con `llamado_clpfd/3`, y si el primero respeta los
    conflictos. Comprobarlo con `ver_llamado_73(1)` y `ver_llamado(1)`.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `clase/6` es `nondet` en general y, con el identificador instanciado del todo, usa `memberchk/2`; con un identificador parcial, como `M-K`, enumera |
    | C2 | representaciones limpias: la oferta, la clase, el horario y la garantía son términos con un functor cada uno; el horario es un calendario del [capítulo 73](../capitulo-73-proyecto-planificacion-tareas/index.md), y `horario_valido/2` verifica el resultado de cualquier versión |
    | C3 | las versiones 3 a 5 no modifican la base de datos; el único estado global es el contador de pasos de las mediciones, con `nb_setval/2` |
    | C4 | `optimo/4`, `costo/3` y las mediciones no dejan alternativas pendientes; `hueco/3` separa la lista con `length/2` y `append/3` en un solo sentido |
    | C6 | el núcleo es puro: `lineas_anio/4` y `cuerpo_anio/4` devuelven la grilla como cadenas o como término, y solo `mostrar_anio/3` y los manejadores escriben |
    | C7 | 94 pruebas en ocho archivos, incluidos horarios con cada clase de choque, ofertas sin horario, los dominios después de propagar y pedidos HTTP reales |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

11. ★ **(2)** Escribir `llamado_separado(Aulas, Calendario, Dias)`, que
    además deja al menos un día libre entre dos exámenes en conflicto.
    Obtener cuántos días hacen falta con dos aulas.

## Resumen

| | |
|---|---|
| **oferta** | la semana, las clases con su materia, año, docente y cupo, las aulas y la disponibilidad de los docentes |
| **horario como calendario** | cada clase es una tarea de duración 1 y cada aula un procesador; `tareas:valido/2` verifica la parte común |
| **clases incompatibles** | mismo docente o mismo año: armar el horario es colorear su grafo |
| **generar y probar** | correcto, pero examina (momentos × aulas) elevado a la cantidad de clases |
| **probar al construir** | cada paso verifica la clase nueva contra el horario parcial |
| **lo más restringido primero** | el orden fijo de lo difícil primero, o el dominio más chico elegido en cada paso |
| **poda hacia adelante** | quitar de los dominios pendientes lo que choca con cada asignación; un dominio vacío abandona la rama |
| **restricción redundante** | no excluye soluciones nuevas pero propaga más; `global_cardinality/2` cuenta las clases por momento |
| **qué etiquetar** | la variable que combina las decisiones (el par momento-aula) evita fijar una sin la otra |
| **cota inferior y garantía** | acotar el costo desde la cota da el óptimo; con un límite, `entre(Cota, C)` |
| **carrera de estrategias** | `first_solution/3` corre varios etiquetados y se queda con el primero que termina |
| `horario_valido/2`, `choque/3`, `lineas_anio/4` | la representación, en `oferta.pl` |
| `generar_y_probar/2`, `construir/3`, `resolver/2` | las versiones 1 a 3 |
| `horario_clpfd/3`, `conteo/2` | el modelo de restricciones |
| **[Patrón 73](../patrones.md#73-restriccion-redundante-que-cuenta)** | restricción redundante que cuenta |
| `cota_inferior/2`, `mejor_con_limite/4`, `carrera/3` | la versión 5 |
| `cuerpo_anio/4` | la grilla web |
| `nb_delete/1` | borra una variable global |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Consultas en castellano sobre *Inscripciones*, entre ellas el horario de una materia | [capítulo 88](../capitulo-88-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- Ivan Bratko, *Prolog Programming for Artificial Intelligence*,
  Addison-Wesley, 1986 — capítulo «Best-first: A Heuristic Search
  Principle», apartado «Best-first search applied to scheduling». Sin
  edición en línea de acceso libre. A través del planificador del
  [capítulo 73](../capitulo-73-proyecto-planificacion-tareas/index.md),
  esta página toma el modelo de tareas sobre procesadores idénticos con
  precedencias que usa el llamado a examen.
- E. G. Coffman y P. J. Denning, *Operating Systems Theory*,
  Prentice-Hall, 1973, citado por Bratko como origen del problema de
  planificación de tareas. Sin edición en línea de acceso libre.

El código del capítulo es propio, escrito para el curso: la oferta, las
seis versiones, las restricciones de conteo, el costo de días y huecos con
su cota inferior, la garantía, la carrera de estrategias, la grilla web y
el llamado a examen son nuevos; de las fuentes se toman las ideas, no los
programas.
