# El llamado a examen

Esta página arma el llamado a examen de *Inscripciones* con el
planificador del [capítulo 72](../capitulo-72-proyecto-planificacion-tareas/index.md)
y después con restricciones, como continuación del
[capítulo 73](index.md#739-el-llamado-a-examen). Todo está en
`examenes.pl`, que carga los datos y los conflictos del
[capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md#318-el-proyecto-inscripciones-se-entrega)
y el planificador del [capítulo 72](../capitulo-72-proyecto-planificacion-tareas/index.md), sin copiarlos.

## El llamado como proyecto de tareas

Cada materia tiene un examen que dura un día. Cada día hay tantas aulas
como indica el llamado, y cada aula toma un examen por día. Y un examen
va después del de cada una de sus correlativas, para que un alumno pueda
rendir las dos en el mismo llamado: primero la correlativa, y la otra
cuando ya la aprobó. Así planteado, el llamado es un proyecto de
`tareas.pl`: los exámenes son las tareas, las aulas los procesadores y las
correlativas las precedencias.

<!-- ejemplo: capitulo-73/examenes.pl predicado: proyecto_examenes/2 llamado_72/3 -->
```prolog
%!  proyecto_examenes(+Aulas:integer, -Proyecto) is det.
%
%   Proyecto es el llamado a examen como proyecto del capítulo 72: una
%   tarea de duración 1 por materia, una precedencia antes(R, M) por cada
%   correlativa R de M, y Aulas procesadores.
proyecto_examenes(Aulas, proyecto(Tareas, Precedencias, Aulas)) :-
    must_be(positive_integer, Aulas),
    findall(tarea(M, 1), materia(M, _, _), Tareas),
    findall(antes(R, M), correlativa(M, R), Precedencias).

%!  llamado_72(+Aulas:integer, -Calendario:list, -Garantia) is det.
%
%   Calendario es el llamado más corto con Aulas aulas por día según el
%   planificador del capítulo 72, con la Garantia que este da.
llamado_72(Aulas, Calendario, Garantia) :-
    proyecto_examenes(Aulas, Proyecto),
    planificar(Proyecto, 1000000, Calendario, Garantia).
```

`planificar/4` del [capítulo 72](../capitulo-72-proyecto-planificacion-tareas/index.md#727-version-5-el-planificador)
devuelve el llamado más corto y su garantía, y `mostrar_llamado/1` lo
escribe un día por línea, con los exámenes en el orden de las aulas:

<!-- contexto: capitulo-73/examenes.pl -->
```prolog
?- ver_llamado_72(2).
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

## Lo que el modelo de tareas no expresa

El llamado no sirve: Análisis 1 y Álgebra rinden el mismo día, y ana
(legajo 101), que está inscripta en las dos, no puede rendir ambas. Los
**conflictos** son los pares de materias con un alumno inscripto en
común, los de `conflicto/2` del módulo `horarios` del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md), y el
proyecto de tareas no tiene cómo representarlos: los procesadores son
idénticos, y una precedencia ordena dos tareas pero no puede pedir que
caigan en días distintos sin imponer cuál va primero.
`conflictos_violados/2` los busca en un calendario cualquiera:

<!-- ejemplo: capitulo-73/examenes.pl predicado: conflictos_violados/2 -->
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
?- ver_llamado_72(3).
día 1: am1 alg log
día 2: am2 pp ssl
día 3: bd
garantía: optima(por_lista)
conflictos: [am1-log,alg-am1,alg-log,am2-pp]
true.
```

## El llamado con restricciones

`llamado_clpfd/3` usa el modelo del
[capítulo 23](../capitulo-23-programacion-con-restricciones/index.md#2313-el-proyecto-el-calendario-de-examenes),
con los dos agregados del [capítulo 72](../capitulo-72-proyecto-planificacion-tareas/index.md): una variable por examen con su
día; una desigualdad estricta por correlativa; una diferencia por
conflicto; y `global_cardinality/2`, que limita los exámenes de cada día
a la cantidad de aulas. El etiquetado con `min(Dias)` devuelve el llamado
más corto, y `repartir/3` del [capítulo 72](../capitulo-72-proyecto-planificacion-tareas/index.md) asigna las aulas, de modo que
el resultado es otra vez un calendario que `valido/2` puede verificar:

<!-- ejemplo: capitulo-73/examenes.pl predicado: llamado_clpfd/3 precedencia/2 dia_distinto/2 -->
```prolog
%!  llamado_clpfd(+Aulas:integer, -Calendario:list, -Dias:integer) is semidet.
%
%   Calendario es un llamado de Aulas aulas por día que respeta las
%   correlativas y los conflictos, con la menor cantidad de días, Dias. Es
%   un calendario del capítulo 72: el examen de M el día D (desde 0) es
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
    `llamado_72/3` y con `llamado_clpfd/3`, y si el primero respeta los
    conflictos. Comprobarlo con `ver_llamado_72(1)` y `ver_llamado(1)`.
