# Soluciones del capítulo 73 — Proyecto: horarios para Inscripciones

El código de esta página está en `ejemplos/capitulo-73/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `web.pl` (que reexporta
`optimo.pl`, `restricciones.pl` y la representación, `oferta.pl`),
`construir.pl`, `generar.pl` y `examenes.pl`, sin modificarlos, y es
`% solo-local`, porque carga otros archivos. Las consultas usan predicados
que reciben el nombre de la oferta, para no mostrar la oferta completa.

## 1

`alg-2` en el momento 2 cae el lunes, el mismo día que `alg-1`, en el
momento 1: es un choque `mismo_dia`. `log-2` en el momento 5 coincide con
`log-1`, en el mismo momento y en la misma aula `a2`: son clases del mismo
año, así que hay un choque `mismo_momento`, y como son de la misma
materia, también `mismo_dia`. `tareas:valido/2` no conoce años ni
materias, pero ve dos tareas en el mismo procesador al mismo tiempo, y
responde que el calendario no es válido.

<!-- ejemplo: capitulo-73/soluciones.pl predicado: proyecto_de/2 ejercicio_1/2 -->
```prolog
%!  proyecto_de(+Oferta, -Proyecto) is det.
%
%   Proyecto es el proyecto de tareas.pl de Oferta: una tarea de duración
%   1 por clase, sin precedencias, y un procesador por aula.
proyecto_de(Oferta, proyecto(Tareas, [], NA)) :-
    Oferta = oferta(_, _, Aulas, _),
    findall(tarea(C, 1), clase(Oferta, C, _, _, _, _), Tareas),
    length(Aulas, NA).

%!  ejercicio_1(-Choques:list, -Tareas) is det.
%
%   Choques son los choques del horario de ejemplo con alg-2 en el
%   momento 2 y log-2 en el momento 5, y Tareas es valido o invalido según
%   lo que responde tareas:valido/2 sobre ese horario.
ejercicio_1(Choques, Tareas) :-
    oferta(cuatrimestre, O),
    horario_ejemplo(H0),
    selectchk(asignada(alg-2, 1, 9, 10), H0, asignada(alg-2, 1, 2, 3), H1),
    selectchk(asignada(log-2, 2, 13, 14), H1, asignada(log-2, 2, 5, 6), H),
    findall(C, choque(O, H, C), Choques),
    proyecto_de(O, P),
    (   tareas:valido(P, H)
    ->  Tareas = valido
    ;   Tareas = invalido
    ).
```

<!-- contexto: capitulo-73/soluciones.pl -->
```prolog
?- ejercicio_1(Choques, Tareas).
Choques = [mismo_momento(log-1, log-2), mismo_dia(alg-1, alg-2), mismo_dia(log-1, log-2)],
Tareas = invalido.
```

## 2

Siete clases y nueve momentos con tres aulas dan 27⁷ candidatos. Al ritmo
de la versión 1, unos veinte mil ensayos por segundo, recorrerlos todos
llevaría más de quinientos mil segundos: casi seis días.

```prolog
?- candidatos(materias([am1, alg, log], 3, 3), K), Dias is K / 20000 / 86400.
K = 10460353203,
Dias = 6.0534451406250005.
```

El primer horario válido puede aparecer mucho antes, pero nada lo
asegura: la búsqueda no terminó en dos minutos.

## 3

El grado se calcula una vez, antes de construir, con `aggregate_all/3`
sobre las clases incompatibles; el resto es `ubicar_todas/4` de la versión
2 con otro orden de entrada:

<!-- ejemplo: capitulo-73/soluciones.pl predicado: construir_por_grado/2 clases_por_grado/2 en_orden/4 -->
```prolog
%!  construir_por_grado(+Oferta, -Horario:list) is nondet.
%
%   Horario es un horario válido de Oferta, construido como en la versión
%   2 con las clases ordenadas de más a menos clases incompatibles.
construir_por_grado(Oferta, Horario) :-
    clases_por_grado(Oferta, Clases),
    en_orden(Oferta, Clases, [], Horario0),
    msort(Horario0, Horario).

%!  clases_por_grado(+Oferta, -Clases:list) is det.
%
%   Clases son las clases de Oferta de más a menos clases incompatibles
%   con ellas; con el mismo grado, en el orden de la oferta.
clases_por_grado(Oferta, Clases) :-
    findall(G-C,
            ( clase(Oferta, C, _, _, _, _),
              aggregate_all(count,
                            ( clase(Oferta, C2, _, _, _, _),
                              C2 \== C,
                              incompatibles_en_orden(Oferta, C, C2) ),
                            N),
              G is -N ),
            Pares0),
    keysort(Pares0, Pares),
    pairs_values(Pares, Clases).

%!  en_orden(+Oferta, +Clases:list, +Parcial:list, -Horario:list) is nondet.
%
%   Horario agrega a Parcial una ubicación compatible para cada clase de
%   Clases, en ese orden.
en_orden(_, [], Horario, Horario).
en_orden(Oferta, [C|Cs], Parcial, Horario) :-
    ubicacion(Oferta, C, Asignada),
    compatible(Oferta, Asignada, Parcial),
    contar_paso,
    en_orden(Oferta, Cs, [Asignada|Parcial], Horario).
```

```prolog
?- medir_grado(facultad(6), K).
K = 15.
```

En `facultad(6)` el grado necesita 15 pasos, como `dificiles`. En
`facultad(9)` y `facultad(12)` no termina en un minuto, mientras que
`dificiles` necesita 23 y 817 pasos. En estas ofertas lo escaso no son
los momentos sino las aulas grandes: casi todas las clases tienen el
mismo grado, porque las incompatibilidades de un año y de un docente se
reparten de manera pareja, y el grado no distingue las clases de cupo
grande, que solo caben en una o dos aulas. `dificiles` cuenta las
ubicaciones, que sí reflejan las aulas.

## 4

`reparar/3` toma el primer choque, intenta mover la segunda clase y, si no
puede, la primera, a una ubicación compatible con todas las demás. Cada
movimiento deja sin choques a la clase movida y no crea choques nuevos,
así que la cantidad de choques baja en cada paso y el predicado termina.
Si ninguna de las dos clases tiene adónde ir, devuelve el horario
alcanzado: como el `improve_schedule` de Covington, es una heurística.

<!-- ejemplo: capitulo-73/soluciones.pl predicado: reparar/3 -->
```prolog
%!  reparar(+Oferta, +Horario0:list, -Horario:list) is det.
%
%   Horario es Horario0 después de mover, mientras haya un choque, una de
%   sus dos clases a una ubicación compatible con todas las demás. Si
%   ninguna de las dos se puede mover, Horario es el horario alcanzado,
%   que puede tener todavía choques.
reparar(Oferta, Horario0, Horario) :-
    (   choque(Oferta, Horario0, Choque),
        arg(I, Choque, C),
        I =< 2,
        selectchk(asignada(C, _, _, _), Horario0, Resto),
        ubicacion(Oferta, C, Nueva),
        compatible(Oferta, Nueva, Resto)
    ->  reparar(Oferta, [Nueva|Resto], Horario)
    ;   msort(Horario0, Horario)
    ).
```

```prolog
?- ver_reparacion(Cambios).
Cambios = [asignada(am1-1, 1, 2, 3), asignada(am2-1, 2, 0, 1)].
```

El choque es `mismo_momento(am1-1, am2-1)`: las dos clases son de
`perez`. `arg/3` toma primero el argumento 1, `am1-1`, que pasa al
momento 2, la tercera franja del lunes, la primera libre en el aula `a1`
que no choca con nada; `am2-1` se queda en el momento 0.

## 5

Las restricciones nuevas se agregan al modelo antes de etiquetar: cada
clase de M1 tiene un momento distinto del de cada clase de M2.

<!-- ejemplo: capitulo-73/soluciones.pl predicado: horario_con_recursantes/3 separar_materias/2 distinto_de_todos/2 -->
```prolog
%!  horario_con_recursantes(+Oferta, +Pares:list, -Horario:list) is semidet.
%
%   Horario es el primer horario válido de Oferta en que, además, las
%   clases de las dos materias de cada par M1-M2 de Pares ocupan momentos
%   distintos.
horario_con_recursantes(Oferta, Pares, Horario) :-
    modelo(Oferta, conteo, Horario, vars(_, _, Ps)),
    maplist(separar_materias(Horario), Pares),
    once(labeling([ff], Ps)).

%!  separar_materias(+Horario:list, +Par) is det.
%
%   Cada clase de M1 tiene un momento distinto del de cada clase de M2,
%   para el par M1-M2.
separar_materias(Horario, M1-M2) :-
    include(de_la_materia(M1), Horario, H1),
    include(de_la_materia(M2), Horario, H2),
    maplist(momento_de, H1, Ss1),
    maplist(momento_de, H2, Ss2),
    maplist(distinto_de_todos(Ss2), Ss1).

%!  distinto_de_todos(+Ss:list, +S) is det.
%
%   S es distinto de cada variable de Ss.
distinto_de_todos(Ss, S) :-
    maplist(#\=(S), Ss).
```

```prolog
?- ver_recursantes([am1-am2, alg-pp], 1).
   lun       mar       mie       jue       vie
F1 am1/a1    am1/a1    am1/a1    -         -
F2 -         log/a2    log/a2    -         -
F3 alg/a1    alg/a1    -         -         -
F4 -         -         -         -         -
true.

?- ver_recursantes([am1-am2, alg-pp], 2).
   lun       mar       mie       jue       vie
F1 ssl/a2    pp/a2     pp/a2     -         -
F2 am2/a1    am2/a1    am2/a1    -         -
F3 -         -         -         -         -
F4 -         ssl/a1    -         -         -
true.
```

Análisis 1 y Análisis 2 ocupan las dos primeras franjas de los mismos
días sin coincidir, y Álgebra, en la tercera, no se superpone con
Paradigmas.

## 6

<!-- ejemplo: capitulo-73/soluciones.pl predicado: medir_etiquetado/3 -->
```prolog
%!  medir_etiquetado(+Nombre, +Opcion, -Resultado) is det.
%
%   Resultado es r(si, I) si el etiquetado del par momento-aula con la
%   opción Opcion de labeling/2 encuentra un horario de la oferta de
%   ejemplo Nombre (modelo simple) con I inferencias, o limite si pasa de
%   veinte millones de inferencias.
medir_etiquetado(Nombre, Opcion, Resultado) :-
    oferta(Nombre, Oferta),
    modelo(Oferta, simple, _, vars(_, _, Ps)),
    statistics(inferences, I0),
    call_with_inference_limit(once(labeling([Opcion], Ps)), 20000000, R),
    statistics(inferences, I1),
    (   R == inference_limit_exceeded
    ->  Resultado = limite
    ;   I is I1 - I0,
        Resultado = r(si, I)
    ).
```

```prolog
?- medir_etiquetado(facultad(13), ff, R).
R = r(si, 1903223).

?- medir_etiquetado(facultad(13), ffc, R).
R = r(si, 1937596).

?- medir_etiquetado(facultad(13), leftmost, R).
R = limite.
```

En `facultad(14)` los resultados son parecidos: 1 764 449 inferencias con
`ff`, 1 803 016 con `ffc` y el límite con `leftmost`. `ff` y `ffc` eligen
la variable de dominio más chico, y `ffc` desempata por la cantidad de
restricciones en que participa; en este modelo casi todas las variables
participan en las mismas, y el desempate solo cuesta el cálculo. Las
cifras son menores que las de `medir_clpfd/3` porque no incluyen la
construcción del modelo. `leftmost` toma las variables en el orden de la
lista: ubica primero las clases de las primeras materias aunque otras
tengan muchas menos ubicaciones, y repite el problema del orden fijo de
la versión 2.

## 7

Un docente viene un día si tiene alguna clase ese día: una variable 0/1
por docente y día, reificada sobre la suma de las comparaciones de los
días de sus clases. La cota inferior es la de `optimo/4` con docentes en
lugar de años: cada docente viene al menos tantos días como clases tiene
su materia de más clases.

<!-- ejemplo: capitulo-73/soluciones.pl predicado: costo_docentes/3 viene/5 ese_dia/4 optimo_docentes/3 cota_docentes/2 -->
```prolog
%!  costo_docentes(+Oferta, +Horario:list, -Costo) is det.
%
%   Costo es la variable de la cantidad de días que viene cada docente,
%   sumada sobre todos los docentes de Oferta.
costo_docentes(Oferta, Horario, Costo) :-
    Oferta = oferta(semana(Dias, Franjas), _, _, _),
    findall(D, grupo(Oferta, docente(D)), Docentes),
    numlist(1, Dias, Ds),
    findall(D-Dia, ( member(D, Docentes), member(Dia, Ds) ), Claves),
    maplist(viene(Oferta, Horario, Franjas), Claves, Bs),
    sum(Bs, #=, Costo).

%!  viene(+Oferta, +Horario:list, +Franjas:integer, +Clave, -B) is det.
%
%   B es 1 si el docente de Clave, un par Docente-Dia, tiene alguna clase
%   ese día, y 0 si no.
viene(Oferta, Horario, Franjas, D-Dia, B) :-
    include(en_grupo(Oferta, docente(D)), Horario, Suyas),
    maplist(momento_de, Suyas, Ss),
    maplist(ese_dia(Franjas, Dia), Ss, Bs),
    sum(Bs, #=, N),
    B #<==> (N #>= 1).

%!  ese_dia(+Franjas:integer, +Dia:integer, +S, -B) is det.
%
%   B es 1 si el momento S cae el día Dia, y 0 si no.
ese_dia(Franjas, Dia, S, B) :-
    B #<==> (S // Franjas #= Dia - 1).

%!  optimo_docentes(+Oferta, -Horario:list, -Costo:integer) is semidet.
%
%   Horario es un horario válido de Oferta con la menor cantidad de días
%   de docentes, Costo, acotada desde cota_docentes/2 hacia arriba.
optimo_docentes(Oferta, Horario, Costo) :-
    modelo(Oferta, conteo, Horario, vars(_, _, Ps)),
    costo_docentes(Oferta, Horario, Costo),
    cota_docentes(Oferta, Minimo),
    fd_sup(Costo, Maximo),
    between(Minimo, Maximo, Cota),
    Costo #=< Cota,
    once(labeling([ff], Ps)),
    !.

%!  cota_docentes(+Oferta, -Cota:integer) is det.
%
%   Ningún horario de Oferta tiene menos de Cota días de docentes: cada
%   docente viene al menos tantos días como clases tiene la materia suya
%   de más clases, porque van en días distintos.
cota_docentes(Oferta, Cota) :-
    findall(N,
            ( grupo(Oferta, docente(D)),
              aggregate_all(max(K), clase(Oferta, _-K, _, _, D, _), N) ),
            Ns),
    sum_list(Ns, Cota).
```

```prolog
?- comparar_costos(Docentes, Alumnos).
Docentes = r(9, 10),
Alumnos = r(10, 8).
```

El horario que minimiza los días de los docentes alcanza su cota, 9, y
cuesta 10 a los alumnos; el de `optimo/4` cuesta 8 a los alumnos y hace
venir a los docentes 10 días. Los dos costos se oponen: juntar las clases
de un docente en pocos días separa las de un año, y al revés. Un costo
combinado, como la suma de los dos con pesos, elige entre esos extremos.

## 8

<!-- ejemplo: capitulo-73/soluciones.pl predicado: primero_de_varios/3 mejor_de_varios/4 -->
```prolog
%!  primero_de_varios(+Oferta, -Horario:list, -Costo:integer) is semidet.
%
%   Horario es el de menor costo entre los primeros horarios de Oferta con
%   cuatro opciones de etiquetado del par momento-aula: ff, ffc, leftmost
%   y ff con los valores de mayor a menor.
primero_de_varios(Oferta, Horario, Costo) :-
    findall(C-H,
            ( member(Opciones, [[ff], [ffc], [leftmost], [ff, down]]),
              modelo(Oferta, conteo, H, vars(_, _, Ps)),
              once(labeling(Opciones, Ps)),
              evaluar(Oferta, H, C) ),
            Pares),
    keysort(Pares, [Costo-Horario|_]).

%!  mejor_de_varios(+Oferta, +Limite:integer, -Horario:list, -Garantia)
%!      is semidet.
%
%   Como mejor_con_limite/4, pero la mejora empieza por el horario de
%   primero_de_varios/3.
mejor_de_varios(Oferta, Limite, Horario, Garantia) :-
    cota_inferior(Oferta, Cota),
    primero_de_varios(Oferta, Primero, C0),
    mejorar(Oferta, Limite, Cota, Primero, C0, Horario, Garantia).
```

```prolog
?- costos_de_varios(facultad(6), Costos).
Costos = [[ff]-11, [ffc]-11, [leftmost]-11, [ff, down]-11].
```

Los cuatro etiquetados dan un primer horario de costo 11, y la garantía
sigue siendo `entre(9, 11)`. Ninguna opción de etiquetado tiene en cuenta
el costo: cambian el orden en que se recorren los horarios, no qué tan
buenos son los primeros. Para empezar más cerca del óptimo hace falta que
la búsqueda mire el costo, como `min(Costo)`, o una cota más ajustada, que
acorte el intervalo desde abajo.

## 9

La ruta se agrega en el archivo de la solución con `http_handler/3`, y el
servidor de `iniciar_web/1` la sirve junto a las de `web.pl`, porque
despacha todas las rutas registradas:

<!-- ejemplo: capitulo-73/soluciones.pl predicado: cuerpo_aula/4 fila_aula/6 celda_aula/6 -->
```prolog
%!  cuerpo_aula(+Oferta, +Horario:list, +Nombre, -Cuerpo:list) is semidet.
%
%   Cuerpo es la página de la ocupación del aula Nombre en Horario: una
%   tabla con una columna por día, una fila por franja y, en cada casilla,
%   la clase que usa el aula. Falla si no hay un aula con ese nombre.
cuerpo_aula(Oferta, Horario, Nombre,
            [h1(Titulo), table([tr([th('Franja')|Encabezados])|Filas])]) :-
    once(aula(Oferta, Numero, Nombre, _)),
    Oferta = oferta(semana(Dias, Franjas), _, _, _),
    format(atom(Titulo), "Aula ~w", [Nombre]),
    numlist(1, Dias, Ds),
    maplist(nombre_del_dia, Ds, Encabezados),
    numlist(1, Franjas, Fs),
    maplist(fila_aula(Oferta, Horario, Numero, Ds), Fs, Filas).

%!  fila_aula(+Oferta, +Horario:list, +Numero:integer, +Dias:list,
%!            +Franja:integer, -Tr) is det.
%
%   Tr es la fila de la franja Franja en la ocupación del aula Numero.
fila_aula(Oferta, Horario, Numero, Dias, Franja, tr([th(Franja)|Celdas])) :-
    maplist(celda_aula(Oferta, Horario, Numero, Franja), Dias, Celdas).

%!  celda_aula(+Oferta, +Horario:list, +Numero:integer, +Franja:integer,
%!             +Dia:integer, -Td) is det.
%
%   Td muestra la clase que usa el aula Numero en ese día y franja, o
%   está vacía.
celda_aula(Oferta, Horario, Numero, Franja, Dia, Td) :-
    momento(Oferta, S, Dia, Franja),
    (   memberchk(asignada(M-K, Numero, S, _), Horario)
    ->  format(atom(Texto), "~w-~w", [M, K]),
        Td = td(Texto)
    ;   Td = td([])
    ).
```

La prueba `cuerpo_aula` verifica la primera fila de la ocupación del aula
`a1` en el horario de ejemplo: Análisis 1 en la primera franja del lunes,
el martes y el miércoles.

## 10

El modelo es el de `llamado_clpfd/3` con la diferencia de conflicto
reemplazada por `abs(D1 - D2) #>= 2`; los días posibles llegan hasta el
doble de la cantidad de exámenes, porque puede hacer falta un día libre
entre cada par:

<!-- ejemplo: capitulo-73/soluciones.pl predicado: llamado_separado/3 separados/2 -->
```prolog
%!  llamado_separado(+Aulas:integer, -Calendario:list, -Dias:integer)
%!      is semidet.
%
%   Como llamado_clpfd/3, pero entre dos exámenes en conflicto queda al
%   menos un día libre.
llamado_separado(Aulas, Calendario, Dias) :-
    proyecto_examenes(Aulas, proyecto(Tareas, _, _)),
    length(Tareas, N),
    findall(M-_, member(tarea(M, _), Tareas), Pares),
    pairs_values(Pares, Ds),
    Ultimo is 2 * N,
    Ds ins 0..Ultimo,
    Tope is Ultimo + 1,
    Dias in 1..Tope,
    maplist(#>(Dias), Ds),
    findall(R-M, correlativa(M, R), Correlativas),
    maplist(antes(Pares), Correlativas),
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(separados(Pares), Conflictos),
    numlist(0, Ultimo, Todos),
    findall(D-_, member(D, Todos), Cuentas),
    pairs_values(Cuentas, Cs),
    Cs ins 0..Aulas,
    global_cardinality(Ds, Cuentas),
    once(labeling([min(Dias), ff], [Dias|Ds])),
    findall(tramo(M, D, F), ( member(M-D, Pares), F is D + 1 ), Tramos),
    repartir(Aulas, Tramos, Calendario).

%!  separados(+Pares:list, +Conflicto:pair) is det.
%
%   Entre los exámenes de las dos materias del Conflicto queda al menos un
%   día libre.
separados(Pares, M1-M2) :-
    memberchk(M1-D1, Pares),
    memberchk(M2-D2, Pares),
    abs(D1 - D2) #>= 2.
```

```prolog
?- ver_llamado_separado(2).
día 1: alg
día 2:
día 3: log
día 4: ssl
día 5: am1
día 6:
día 7: pp
día 8: bd
día 9: am2
días: 9
true.
```

Con dos aulas hacen falta nueve días, y con una también: las cinco
materias de ana están en conflicto entre sí, y cinco exámenes con un día
libre entre cada dos necesitan nueve días.

## 11

En `facultad(30)` hay 25 clases de un mismo año y quince momentos. La
restricción `all_distinct/1` sobre los momentos de ese año falla al
imponerse, antes de etiquetar nada, y la respuesta llega con unas
doscientas mil inferencias, casi todas de la construcción del modelo:

<!-- contexto: capitulo-73/restricciones.pl -->
```prolog
?- medir_clpfd(facultad(30), [modelo(simple)], R).
R = r(no, 210746).
```
