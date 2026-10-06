# Soluciones del capítulo 17 — Todas las soluciones

El código de esta página está en `ejemplos/capitulo-17/soluciones.pl` y pasa sus
pruebas. La familia de las soluciones tiene una nieta más que la del texto,
sofia, hija de ana, y una persona más con la mayor edad, marta.

## 1

```prolog
?- findall(X, member(X, [c, a, b, a]), L).
L = [c, a, b, a].

?- setof(X, member(X, [c, a, b, a]), L).
L = [a, b, c].

?- bagof(X, member(X, []), L).
false.

?- findall(X-Y, member(X-Y, [1-a, 2-b]), L).
L = [1-a, 2-b].
```

`findall/3` conserva el orden y los repetidos; `setof/3` ordena y los elimina;
`bagof/3` falla sin respuestas. La cuarta muestra que la plantilla puede ser un
término compuesto.

## 2

<!-- ejemplo: capitulo-17/soluciones.pl predicado: nietos_de/2 consulta: nietos_de(juan, Nietos). -->
```prolog
%!  nietos_de(+Abuelo, -Nietos:list) is det.
%
%   Nietos es la lista de los nietos de Abuelo.
nietos_de(Abuelo, Nietos) :-
    findall(N, ( padre(Abuelo, P), padre(P, N) ), Nietos).
```

El objetivo es una conjunción entre paréntesis: el hijo de un hijo. La lista
sigue el orden de las respuestas: primero los hijos de ana, después los de pedro.

## 3

<!-- ejemplo: capitulo-17/soluciones.pl predicado: abuelos_con_nietos/2 consulta: abuelos_con_nietos(A, Nietos). -->
```prolog
%!  abuelos_con_nietos(?Abuelo, -Nietos:list) is nondet.
%
%   Una respuesta por abuelo, con la lista de sus nietos. P^ hace que el
%   progenitor intermedio no agrupe.
abuelos_con_nietos(Abuelo, Nietos) :-
    bagof(N, P^( padre(Abuelo, P), padre(P, N) ), Nietos).
```

```prolog
?- abuelos_con_nietos(A, Nietos).
A = juan,
Nietos = [sofia, luis, eva].
```

Sin `P^`, el progenitor intermedio también agrupa, y juan aparece dos veces: una
con los hijos de ana, `[sofia]`, y otra con los de pedro, `[luis, eva]`. Con
`findall/3` y el abuelo libre, en cambio, todos los nietos de todos los abuelos
quedan en una sola lista, sin decir de quién es cada uno; `findall/3` sirve
cuando el abuelo llega ligado, como en `nietos_de/2`.

## 4

<!-- ejemplo: capitulo-17/soluciones.pl predicado: edades_ordenadas/1 edades_ordenadas_2/1 consulta: edades_ordenadas(E). -->
```prolog
%!  edades_ordenadas(-Edades:list(integer)) is semidet.
%
%   Edades es la lista ordenada y sin repetidos de las edades de la base.
edades_ordenadas(Edades) :-
    setof(E, P^edad(P, E), Edades).

%!  edades_ordenadas_2(-Edades:list(integer)) is det.
%
%   La misma lista con findall/3 y sort/2, que también elimina los repetidos.
%   Con la base vacía da la lista vacía, en lugar de fallar.
edades_ordenadas_2(Edades) :-
    findall(E, edad(_, E), Todas),
    sort(Todas, Edades).
```

Las dos dan `[3, 8, 12, 39, 41, 68]`: `sort/2` también elimina los repetidos, y
el 68 de juan y marta queda una vez. La diferencia está en el caso sin datos:
`setof/3` falla, y la versión con `findall/3` da la lista vacía, y es `det`.

## 5

<!-- ejemplo: capitulo-17/soluciones.pl predicado: materia_de_anio/2 consulta: materia_de_anio(1, Materias). -->
```prolog
%!  materia_de_anio(+Anio:integer, -Materias:list(atom)) is det.
%
%   Materias son los códigos de las materias de Anio, en el orden en que
%   aparecen en la base; la lista vacía si no hay ninguna.
materia_de_anio(Anio, Materias) :-
    findall(M, materia(M, _, Anio), Materias).
```

Es el encabezado que proponía la [solución 14 del capítulo 14](../capitulo-14-estilo-y-documentacion/soluciones.md#14), y sus dos pruebas
pasan: `[am1, alg, log]` para el primer año y la lista vacía para un año sin
materias. `findall/3` es la elección, porque la lista vacía es una respuesta
válida.

## 6

<!-- ejemplo: capitulo-17/soluciones.pl predicado: requisitos_faltantes_2/3 consulta: requisitos_faltantes_2(102, am2, F). -->
```prolog
%!  requisitos_faltantes_2(+Legajo:integer, +Materia:atom,
%!                         -Faltan:list(atom)) is det.
%
%   Faltan son los requisitos de Materia que el alumno Legajo no aprobó, sin
%   repetir las correlatividades en una tabla aparte.
requisitos_faltantes_2(Legajo, Materia, Faltan) :-
    findall(R,
            ( correlativa(Materia, R),
              \+ aprobada(Legajo, R, _) ),
            Faltan).
```

La tabla `requisitos/2` del [capítulo 15](../capitulo-15-control/index.md) repetía las correlatividades; `findall/3`
las reúne desde `correlativa/2`. El `\+` está bien ubicado: `R` llega con valor
desde el objetivo anterior.

## 7

<!-- ejemplo: capitulo-17/soluciones.pl predicado: menor_edad/2 mayor_edad_2/2 consulta: menor_edad(Quien, Edad). -->
```prolog
%!  menor_edad(-Quien, -Edad:integer) is semidet.
%
%   Quien tiene la menor edad de la base.
menor_edad(Quien, Edad) :-
    aggregate_all(min(E, P), edad(P, E), min(Edad, Quien)).

%!  mayor_edad_2(-Quien, -Edad:integer) is semidet.
%
%   Quien tiene la mayor edad, con findall/3 y max_member/2. Con empate, el
%   mayor par Edad-Quien en el orden estándar: el nombre posterior.
mayor_edad_2(Quien, Edad) :-
    findall(E-P, edad(P, E), Pares),
    max_member(Edad-Quien, Pares).
```

Con juan y marta empatados en 68, `aggregate_all(max(E, P), …)` responde juan,
la primera persona que encuentra, y `mayor_edad_2/2` responde marta.
`max_member/2` compara los pares `Edad-Persona` en el orden estándar, y entre
`68-juan` y `68-marta` es mayor el segundo, por el nombre. Ninguno de los dos da
los dos empatados; para eso, `findall/3` con la edad máxima ya calculada, o la
forma de la [sección 10.7](../capitulo-10-negacion-como-falla/index.md#107-obtener-una-respuesta-por-negacion).

## 8

<!-- ejemplo: capitulo-17/soluciones.plt fragmento: % Ejercicio 8 .. 1 < N. -->
```prolog
% Ejercicio 8: la prueba que el capítulo 13 no podía escribir.
test(sin_inscripciones_repetidas, [fail]) :-
    inscripcion(L, M, E),
    aggregate_all(count, inscripcion(L, M, E), N),
    1 < N.
```

Para cada inscripción, cuenta cuántas veces está exactamente ese hecho. Un hecho
repetido se cuenta dos veces, que es lo que la [solución 11 del capítulo 13](../capitulo-13-el-entorno-de-trabajo/soluciones.md#11) no
podía distinguir: los dos hechos son el mismo término, pero `aggregate_all/3`
cuenta las **respuestas**, y cada hecho da una.

## 9

<!-- ejemplo: capitulo-17/soluciones.pl predicado: todos_aprobados/1 consulta: todos_aprobados(104). -->
```prolog
%!  todos_aprobados(+Legajo:integer) is semidet.
%
%   El alumno Legajo se inscribió en alguna materia y aprobó todas en las que
%   se inscribió. Sin la primera condición, forall/2 se cumpliría para un
%   alumno sin inscripciones.
todos_aprobados(Legajo) :-
    once(inscripcion(Legajo, _, _)),
    forall(inscripcion(Legajo, Materia, _),
           aprobada(Legajo, Materia, _)).
```

Sin la primera condición, `todos_aprobados(107)` se cumpliría: gabriela no se
inscribió en nada, y `forall/2` no encuentra ninguna inscripción sin aprobar. Es
la verdad vacía de la [sección 17.6](index.md#176-forall2), y aquí no corresponde: la especificación
no considera que un alumno sin inscripciones haya aprobado todas sus materias.
`once(inscripcion(Legajo, _, _))` exige al menos una, sin dejar alternativas.

## 10

<!-- ejemplo: capitulo-17/soluciones.pl predicado: cantidad_por_materia/2 consulta: cantidad_por_materia(Materia, N). -->
```prolog
%!  cantidad_por_materia(?Materia:atom, -N:integer) is nondet.
%
%   N es la cantidad de inscriptos en Materia, una respuesta por materia con
%   al menos uno.
cantidad_por_materia(Materia, N) :-
    aggregate(count, Legajo^Estado^inscripcion(Legajo, Materia, Estado), N).
```

`aggregate/3` agrupa como `bagof/3`. `Materia` no está marcada, y agrupa: una
respuesta por materia. `Legajo` y `Estado` se marcan con `^`, para que no
dividan los grupos. Una materia sin inscriptos no aparece; si hiciera falta
con 0, se usaría `materia/3` para generarlas y `aggregate_all/3` para contar.

## 11

<!-- ejemplo: capitulo-17/soluciones.pl predicado: mejor_de_materia/3 consulta: mejor_de_materia(log, L, N). -->
```prolog
%!  mejor_de_materia(+Materia:atom, -Legajo:integer, -Nota:integer) is semidet.
%
%   Legajo tiene la nota más alta de Materia. Con empate, el primero.
mejor_de_materia(Materia, Legajo, Nota) :-
    aggregate_all(max(N, L), inscripcion(L, Materia, nota(N)),
                  max(Nota, Legajo)).
```

`mejor_de_materia(log, L, N)` responde `L = 101, N = 10`. La diferencia con
`mejor_de/2` del [capítulo 10](../capitulo-10-negacion-como-falla/index.md) está en los empates: aquella daba todos los que
tienen la nota máxima, porque su condición era «no existe una mayor»; esta da
uno solo, el primero. Las dos formas son correctas para preguntas distintas.

## 12

`forall(member(X, []), X > 0).` responde `true.`: no hay ningún elemento que no
sea positivo. `forall(member(X, [1, -1]), X > 0).` responde `false.`, por el
−1. La primera es la verdad vacía: `forall/2` afirma que no existe un
contraejemplo, y en una lista vacía no existe ninguno.

## 13

<!-- ejemplo: capitulo-17/soluciones.pl predicado: listar_inscriptos/1 consulta: listar_inscriptos(pp). -->
```prolog
%!  listar_inscriptos(+Materia:atom) is det.
%
%   Escribe una línea por alumno inscripto en Materia, con su nombre.
listar_inscriptos(Materia) :-
    forall(( inscripcion(Legajo, Materia, _),
             alumno(Legajo, Nombre, _, _) ),
           format("~w ~w~n", [Legajo, Nombre])).
```

```prolog
?- listar_inscriptos(pp).
101 ana
104 diego
true.
```

La condición liga el legajo y el nombre, y la acción los escribe. Es el bucle
por falla del [capítulo 15](../capitulo-15-control/index.md) escrito con `forall/2`.

## 14

<!-- ejemplo: capitulo-17/soluciones.pl predicado: simbolo/3 tablero_texto/1 fila_texto/2 consulta: tablero_texto(L). -->
```prolog
%!  simbolo(+F:integer, +C:integer, -S) is det.
%
%   S es * si hay una mina en (F, C), y la cantidad de minas vecinas si no.
simbolo(F, C, S) :-
    (   mina(F, C)
    ->  S = '*'
    ;   minas_alrededor(F, C, S)
    ).

%!  tablero_texto(-Lineas:list(string)) is det.
%
%   Lineas son las filas del tablero como cadenas, una por fila.
tablero_texto(Lineas) :-
    tamanio(Filas, _),
    findall(Linea,
            ( between(1, Filas, F),
              fila_texto(F, Linea) ),
            Lineas).

%!  fila_texto(+F:integer, -Linea:string) is det.
%
%   Linea es la fila F del tablero, con un símbolo por celda.
fila_texto(F, Linea) :-
    tamanio(_, Columnas),
    findall(S, ( between(1, Columnas, C), simbolo(F, C, S) ), Simbolos),
    atomic_list_concat(Simbolos, Atomo),
    atom_string(Atomo, Linea).
```

```text
*2110
12*10
12221
1*11*
11111
```

Dos `findall/3` anidados: uno reúne los símbolos de una fila, y el otro las
filas. `simbolo/3` elige con un condicional entre la mina y el número, y
`atomic_list_concat/2` une los símbolos de una fila, que pueden ser átomos o
números.

## 15

<!-- ejemplo: capitulo-17/soluciones.pl predicado: los_mejores_de_cada_carrera/2 consulta: los_mejores_de_cada_carrera(C, L). -->
```prolog
%!  los_mejores_de_cada_carrera(?Carrera:atom, -Legajo:integer) is nondet.
%
%   Legajo tiene el mejor promedio de Carrera, una respuesta por carrera con
%   algún alumno con notas. aggregate/3 agrupa por Carrera; los demás
%   argumentos de alumno/4 se marcan con ^ para que no agrupen.
los_mejores_de_cada_carrera(Carrera, Legajo) :-
    aggregate(max(P, L),
              Nombre^Ingreso^( alumno(L, Nombre, Carrera, Ingreso),
                               promedio_de_alumno(L, P) ),
              max(_, Legajo)).
```

Hace falta agrupar por carrera y, en cada grupo, obtener el máximo con su
testigo: `aggregate/3` con `max(P, L)`. `Nombre` e `Ingreso` se marcan con `^`
para que no agrupen; sin eso, cada alumno sería un grupo. Las respuestas son
civil-103, industrial-106 y sistemas-101: en civil, elena (105) no tiene notas,
y `promedio_de_alumno/2` no da nada para ella.

## 16

<!-- ejemplo: capitulo-17/soluciones.pl predicado: mejores_2/2 primeros/3 consulta: mejores_2(3, R). -->
```prolog
%!  mejores_2(+Cantidad:integer, -Ranking:list(pair)) is det.
%
%   Como mejores/2, con findall/3, sort/4 y los primeros Cantidad elementos.
mejores_2(Cantidad, Ranking) :-
    findall(L-P, promedio_de_alumno(L, P), Pares),
    sort(2, @>=, Pares, Ordenados),
    primeros(Cantidad, Ordenados, Ranking).

%!  primeros(+N:integer, +L:list, -Primeros:list) is det.
%
%   Primeros son los N primeros elementos de L, o todos si tiene menos.
primeros(N, L, Primeros) :-
    (   N =< 0
    ->  Primeros = []
    ;   L = []
    ->  Primeros = []
    ;   L = [X|Resto],
        N1 is N - 1,
        Primeros = [X|Resto1],
        primeros(N1, Resto, Resto1)
    ).
```

`sort(2, @>=, Pares, Ordenados)` ordena por el segundo argumento de cada par, el
promedio, de mayor a menor, y conserva los repetidos (`@>=` y no `@>`), que en
un ranking son promedios iguales de alumnos distintos. `primeros/3` toma los `N`
primeros con un condicional.

Con 5 000 alumnos generados y los diez mejores, las dos dan el mismo ranking.
Contadas las inferencias, `mejores_2/2` usa unas 150 000 y `mejores/2` unas
275 000: las dos calculan todos los promedios y los ordenan, y `order_by/2`
agrega el trabajo de entregarlos de a uno. La diferencia es de un factor menor
que dos, y no crece con los datos; `mejores/2` es más breve y se lee como la
pregunta. Es la conclusión del [Patrón 10](../patrones.md#10-medir-antes-de-cambiar): sin una medición que muestre que pesa,
la versión más clara es la que corresponde.
