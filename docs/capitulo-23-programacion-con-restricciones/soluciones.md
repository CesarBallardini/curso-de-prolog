# Soluciones del capítulo 23 — Programación con restricciones

El código de esta página está en `ejemplos/capitulo-23/soluciones.pl`,
`soluciones_buscaminas.pl` y `soluciones_proyecto.pl`, en el mismo directorio, y
pasa sus pruebas.

## 1

| Consulta | Respuesta |
|---|---|
| `X #= 2 * 3.` | `X = 6.` |
| `6 #= 2 * X.` | `X = 3.` |
| `X #> 3, X #< 6, label([X]).` | `X = 4 ;` y después `X = 5.` |
| `X #= Y + 1, Y = 4.` | `X = 5, Y = 4.` |
| `X in 1..3, X #\= 2, fd_dom(X, D).` | `D = 1\/3, X in 1\/3.` |

La segunda resuelve la ecuación; la quinta muestra un dominio con un agujero:
`1\/3` es la unión de 1 y 3, sin el 2 que la restricción quitó. Las consultas
usan solo `library(clpfd)`, que `soluciones.pl` carga.

## 2

<!-- ejemplo: capitulo-23/soluciones.pl predicado: celsius_fahrenheit/2 consulta: celsius_fahrenheit(C, 212). -->
```prolog
%!  celsius_fahrenheit(?C:integer, ?F:integer) is nondet.
%
%   C grados Celsius son F grados Fahrenheit: F = C * 9 / 5 + 32, con los
%   dos enteros.
celsius_fahrenheit(C, F) :-
    5 * F #= 9 * C + 160.
```

```prolog
?- celsius_fahrenheit(C, 212).
C = 100.

?- celsius_fahrenheit(100, F).
F = 212.
```

La relación se escribe sin divisiones: `5 * F #= 9 * C + 160` es la fórmula
multiplicada por 5. Con una división entera, `//`, perdería los dos sentidos.
Una temperatura sin equivalente entero, como 213 °F, falla.

## 3

<!-- ejemplo: capitulo-23/soluciones.pl predicado: cambio/2 consulta: cambio(37, Monedas). -->
```prolog
%!  cambio(+Monto:integer, -Monedas:list(integer)) is semidet.
%
%   Monedas es [U, C, D]: U monedas de 1, C de 5 y D de 10 que suman Monto,
%   con la menor cantidad de monedas.
cambio(Monto, [U, C, D]) :-
    [U, C, D] ins 0..Monto,
    U + 5 * C + 10 * D #= Monto,
    Total #= U + C + D,
    once(labeling([min(Total)], [U, C, D])).
```

```prolog
?- cambio(37, Monedas).
Monedas = [2, 1, 3].
```

`labeling([min(Total)], …)` busca primero la combinación con menos monedas:
tres de 10, una de 5 y dos de 1. `once/1` se queda con esa, la mejor; sin él,
al volver atrás aparecerían las demás, cada vez con más monedas.

## 4

<!-- ejemplo: capitulo-23/soluciones.pl predicado: cuadrado_magico/1 consulta: cuadrado_magico(Filas). -->
```prolog
%!  cuadrado_magico(-Filas:list(list(integer))) is nondet.
%
%   Filas son las tres filas de un cuadrado mágico de 3 x 3 con los números
%   del 1 al 9: filas, columnas y diagonales suman 15.
cuadrado_magico([[A, B, C], [D, E, F], [G, H, I]]) :-
    Vs = [A, B, C, D, E, F, G, H, I],
    Vs ins 1..9,
    all_different(Vs),
    maplist([X, Y, Z]>>(X + Y + Z #= 15),
            [A, D, G, A, B, C, A, C], [B, E, H, D, E, F, E, E],
            [C, F, I, G, H, I, I, G]),
    label(Vs).
```

```prolog
?- aggregate_all(count, cuadrado_magico(_), N).
N = 8.
```

Hay ocho cuadrados, y son uno solo con sus rotaciones y reflexiones: el
primero es `[[2, 7, 6], [9, 5, 1], [4, 3, 8]]`. `maplist/4` con una lambda
escribe las ocho sumas —tres filas, tres columnas, dos diagonales— como tres
listas paralelas.

## 5

<!-- ejemplo: capitulo-23/soluciones.pl predicado: sudoku/1 consulta: sudoku([[1, _, _, _], [_, _, 3, _], [_, 4, _, _], [_, _, _, 2]]). -->
```prolog
%!  sudoku(?Filas:list(list(integer))) is nondet.
%
%   Filas es un sudoku de 4 x 4 resuelto: cada fila, cada columna y cada
%   cuadro de 2 x 2 tienen los números del 1 al 4.
sudoku(Filas) :-
    Filas = [[A, B, C, D], [E, F, G, H], [I, J, K, L], [M, N, O, P]],
    append(Filas, Vs),
    Vs ins 1..4,
    maplist(all_different, Filas),
    transpose(Filas, Columnas),
    maplist(all_different, Columnas),
    maplist(all_different, [[A, B, E, F], [C, D, G, H],
                            [I, J, M, N], [K, L, O, P]]),
    label(Vs).
```

```prolog
?- S = [[1, _, _, _], [_, _, 3, _], [_, 4, _, _], [_, _, _, 2]], sudoku(S).
S = [[1, 3, 2, 4], [4, 2, 3, 1], [2, 4, 1, 3], [3, 1, 4, 2]].
```

El modelo es una restricción `all_different/1` por fila, por columna y por
cuadro. `transpose/2`, de `library(clpfd)`, da las columnas. Los números dados
son valores de las variables desde el principio, y la propagación resuelve
este sudoku casi sin etiquetar.

## 6

<!-- ejemplo: capitulo-23/soluciones.pl predicado: dos_de_cada/1 consulta: dos_de_cada(Xs). -->
```prolog
%!  dos_de_cada(-Xs:list(integer)) is nondet.
%
%   Xs son seis valores entre 1 y 3, con exactamente dos de cada uno.
dos_de_cada(Xs) :-
    length(Xs, 6),
    Xs ins 1..3,
    global_cardinality(Xs, [1-2, 2-2, 3-2]),
    label(Xs).
```

Hay 90 listas: 6! / (2! · 2! · 2!), las permutaciones de `[1, 1, 2, 2, 3, 3]`
sin repetir las que solo intercambian valores iguales.

## 7

<!-- ejemplo: capitulo-23/soluciones.pl predicado: exactamente/3 dados_con_dos_seis/1 consulta: dados_con_dos_seis(N). -->
```prolog
%!  exactamente(?N:integer, ?Xs:list(integer), +V:integer) is nondet.
%
%   Exactamente N elementos de Xs son iguales a V.
exactamente(N, Xs, V) :-
    maplist({V}/[X, B]>>(B #<==> (X #= V)), Xs, Bs),
    sum(Bs, #=, N).

%!  dados_con_dos_seis(-Cantidad:integer) is det.
%
%   Cantidad es la cantidad de resultados de tirar tres dados en los que
%   salen exactamente dos seis.
dados_con_dos_seis(Cantidad) :-
    Dados = [_, _, _],
    Dados ins 1..6,
    exactamente(2, Dados, 6),
    aggregate_all(count, label(Dados), Cantidad).
```

```prolog
?- dados_con_dos_seis(N).
N = 15.
```

Tres posiciones posibles para el dado que no es seis, y cinco valores para él:
15. `exactamente/3` es el [Patrón 26](../patrones.md#26-contar-con-reificacion), y funciona en todos los sentidos: la prueba
`exactamente_inverso` fija la cantidad y deduce los valores.

## 8

<!-- ejemplo: capitulo-23/soluciones.pl predicado: to_go_out/1 soluciones_sin_ceros/2 send_more_money/1 consulta: to_go_out(L). -->
```prolog
%!  to_go_out(-Letras:list(integer)) is det.
%
%   Letras son los dígitos de T, O, G y U, distintos entre sí, tales que
%   TO + GO = OUT, sin ceros a la izquierda.
to_go_out([T, O, G, U]) :-
    Letras = [T, O, G, U],
    Letras ins 0..9,
    all_different(Letras),
    T #\= 0,
    G #\= 0,
    O #\= 0,
    10 * T + O + 10 * G + O #= 100 * O + 10 * U + T,
    label(Letras).

%!  soluciones_sin_ceros(-Con:integer, -Sin:integer) is det.
%
%   Con es la cantidad de soluciones de SEND + MORE = MONEY que exigen que S
%   y M no sean cero, y Sin la cantidad sin esa exigencia.
soluciones_sin_ceros(Con, Sin) :-
    aggregate_all(count, send_more_money(true), Con),
    aggregate_all(count, send_more_money(false), Sin).

%!  send_more_money(+SinCeros:boolean) is nondet.
%
%   Una solución de SEND + MORE = MONEY; con SinCeros en true, S y M no son
%   cero.
send_more_money(SinCeros) :-
    Letras = [S, E, N, D, M, O, R, Y],
    Letras ins 0..9,
    all_different(Letras),
    (   SinCeros == true
    ->  S #\= 0,
        M #\= 0
    ;   true
    ),
              1000 * S + 100 * E + 10 * N + D
    +         1000 * M + 100 * O + 10 * R + E
    #= 10000 * M + 1000 * O + 100 * N + 10 * E + Y,
    label(Letras).
```

```prolog
?- to_go_out(L).
L = [2, 1, 8, 0] ;
false.

?- soluciones_sin_ceros(Con, Sin).
Con = 1,
Sin = 25.
```

21 + 81 = 102. SEND + MORE = MONEY tiene una sola solución con la restricción
de los ceros a la izquierda, y 25 sin ella: las otras 24 empiezan con un cero,
y no son números bien escritos.

## 9

<!-- ejemplo: capitulo-23/soluciones.pl predicado: colorear_gyp/2 consulta: colorear_gyp(4, Colores). -->
```prolog
%!  colorear_gyp(+K:integer, -Colores:list(pair)) is nondet.
%
%   La relación de colorear/2 del capítulo, con generar y probar: a cada
%   provincia se le asigna un color con between/3, y después se comprueban
%   todos los límites.
colorear_gyp(K, Colores) :-
    findall(P-_, provincia(P), Colores),
    maplist({K}/[_-C]>>between(1, K, C), Colores),
    \+ ( limita(A, B),
         memberchk(A-X, Colores),
         memberchk(B-X, Colores) ).
```

`colorear_gyp/2` genera cada asignación completa con `between/3` y la descarta
si dos provincias vecinas tienen el mismo color. Da los mismos 480 coloreos.
Contarlos todos:

```text
% generar y probar
% 1,496,506 inferences, 0.141 CPU in 0.143 seconds (98% CPU, 10641820 Lips)
% restringir y etiquetar
% 135,260 inferences, 0.016 CPU in 0.009 seconds (165% CPU, 8656640 Lips)
```

Unas diez veces más inferencias y más tiempo, con solo ocho provincias: 4⁸ =
65 536 asignaciones completas, frente a las que la propagación descarta antes
de completarlas.

## 10

<!-- ejemplo: capitulo-23/soluciones.pl predicado: reinas/3 consulta: reinas([ff], 8, Qs). -->
```prolog
%!  reinas(+Opciones:list, +N:integer, -Qs:list(integer)) is nondet.
%
%   Las N reinas del capítulo, con las Opciones de labeling/2.
reinas(Opciones, N, Qs) :-
    length(Qs, N),
    Qs ins 1..N,
    seguras(Qs),
    labeling(Opciones, Qs).
```

Con `ff`, la primera solución de 30 reinas usa unas 325 000 inferencias y
0,016 segundos. Con `leftmost`, que etiqueta las variables en orden, la consulta
no terminó en 20 segundos, después de casi 500 millones de inferencias. El orden
del etiquetado no cambia las soluciones, pero decide qué parte del árbol de
búsqueda se recorre antes de encontrar la primera.

## 11

<!-- ejemplo: capitulo-23/soluciones.pl predicado: todos_distintos/1 consulta: todos_distintos([a, X, b]), X = c. -->
```prolog
%!  todos_distintos(+Xs:list) is semidet.
%
%   Los elementos de Xs son distintos entre sí, con dif/2: vale para
%   cualquier término, y con variables se posterga.
todos_distintos([]).
todos_distintos([X|Xs]) :-
    maplist(dif(X), Xs),
    todos_distintos(Xs).
```

```prolog
?- todos_distintos([a, X, b]), X = c.
X = c.

?- todos_distintos([a, X, b]), X = a.
false.
```

`all_different([a, b])` produce un error de tipo: `library(clpfd)` trabaja solo
con enteros. `dif/2` compara cualquier término, y la prueba
`all_different_con_atomos` verifica el error.

## 12

<!-- ejemplo: capitulo-23/soluciones_buscaminas.pl predicado: probabilidades/2 consulta: probabilidades(["#100", "1211", "01##", "01##"], P). -->
```prolog
%!  probabilidades(+Lineas:list(string), -Pares:list(pair)) is semidet.
%
%   Pares tiene un par Celda-P por cada celda oculta: P es la fracción de las
%   soluciones del tablero en las que Celda tiene mina. Falla si el tablero
%   no tiene ninguna solución.
probabilidades(Lineas, Pares) :-
    modelo(Lineas, Ocultas),
    pairs_values(Ocultas, Bs),
    findall(Bs, label(Bs), Soluciones),
    length(Soluciones, Total),
    Total > 0,
    pairs_keys(Ocultas, Celdas),
    transpose(Soluciones, PorCelda),
    maplist({Total}/[Celda, Valores, Celda-P]>>( sum_list(Valores, Minas),
                                                P is Minas / Total ),
            Celdas, PorCelda, Pares).
```

```prolog
?- probabilidades(["#100", "1211", "01##", "01##"], P).
P = [1-1-1, 3-3-1, 3-4-0, 4-3-0, 4-4-0.5].
```

El tablero tiene dos soluciones, que difieren en (4, 4): una mina en 1-1 y en
3-3 en las dos, y en 4-4 en una. `findall/3` reúne todas las soluciones como
listas de 0 y 1, `transpose/2` las agrupa por celda, y la suma de cada columna
dividida por la cantidad de soluciones es la probabilidad. Contar soluciones
así supone que todas son igualmente probables, lo que no es exacto cuando el
total de minas es conocido; con tableros grandes, además, las soluciones son
demasiadas para enumerarlas.

## 13

<!-- ejemplo: capitulo-23/soluciones_buscaminas.pl predicado: consistente/1 consulta: consistente(["#100", "1211", "01##", "01##"]). -->
```prolog
%!  consistente(+Lineas:list(string)) is semidet.
%
%   Los números de Lineas se pueden cumplir: hay al menos una ubicación de
%   las minas en las celdas ocultas que da esos números.
consistente(Lineas) :-
    modelo(Lineas, Ocultas),
    pairs_values(Ocultas, Bs),
    once(label(Bs)).
```

Un tablero es consistente si el modelo tiene al menos una solución. `once/1`
detiene el etiquetado en la primera. `["##1#", "1211", "0000"]` no lo es: las
únicas celdas ocultas que tocan a (2, 1) y a (2, 2) son (1, 1) y (1, 2); el 1 de
(2, 1) exige una mina entre las dos, y el 2 de (2, 2), dos minas.

## 14

<!-- ejemplo: capitulo-23/soluciones_proyecto.pl predicado: horario_minimo/3 consulta: horario_minimo(20, Dias, Horario). -->
```prolog
%!  horario_minimo(+Capacidad:integer, -Dias:integer, -Horario:list(pair))
%!      is semidet.
%
%   Dias es la menor cantidad de días con la que hay un horario, y Horario el
%   primero de esos horarios. Prueba 1, 2, … días, hasta la cantidad de
%   materias. Falla si no hay horario con ninguna cantidad de días.
horario_minimo(Capacidad, Dias, Horario) :-
    aggregate_all(count, materia(_, _, _), Materias),
    between(1, Materias, Dias),
    horario(Dias, Capacidad, Horario),
    !.
```

```prolog
?- horario_minimo(20, Dias, Horario).
Dias = 5,
Horario = [am1-1, alg-2, log-3, am2-4, pp-5, ssl-1, bd-1].
```

`between/3` prueba 1, 2, … días, y el corte se queda con el primero que tiene un
horario. Con la capacidad amplia, el mínimo lo decide ana: está en cinco
materias.

## 15

<!-- ejemplo: capitulo-23/soluciones_proyecto.pl predicado: horario_separado/3 dias_separados/2 consulta: horario_separado(9, 20, H). -->
```prolog
%!  horario_separado(+Dias:integer, +Capacidad:integer, -Horario:list(pair))
%!      is nondet.
%
%   Como horario/3, con dos días al menos entre los exámenes de dos materias
%   con un alumno en común.
horario_separado(Dias, Capacidad, Horario) :-
    findall(M-_, materia(M, _, _), Horario),
    pairs_values(Horario, Ds),
    Ds ins 1..Dias,
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(dias_separados(Horario), Conflictos),
    numlist(1, Dias, Todos),
    maplist(capacidad_del_dia(Horario, Capacidad), Todos),
    label(Ds).

%!  dias_separados(+Horario:list(pair), +Conflicto:pair) is semidet.
%
%   Los exámenes de las dos materias de Conflicto están a dos días o más.
dias_separados(Horario, M1-M2) :-
    memberchk(M1-D1, Horario),
    memberchk(M2-D2, Horario),
    abs(D1 - D2) #>= 2.
```

```prolog
?- horario_separado(9, 20, H).
H = [am1-1, alg-3, log-5, am2-7, pp-9, ssl-1, bd-1] ;
...
```

Hacen falta nueve días: las cinco materias de ana, separadas de a dos días,
ocupan los días 1, 3, 5, 7 y 9. Con ocho días, `horario_separado/3` falla. El
cambio respecto de `horario/3` es una sola restricción: `abs(D1 - D2) #>= 2`
en lugar de `D1 #\= D2`.

## 16

<!-- ejemplo: capitulo-23/soluciones_proyecto.pl predicado: horario_con_aulas/3 dominio_de_examen/4 examenes_en_dias_distintos/2 turnos_distintos/1 append_variables/2 consulta: horario_con_aulas([4, 6], 5, Horario). -->
```prolog
%!  horario_con_aulas(+Capacidades:list(integer), +Dias:integer,
%!                    -Horario:list) is nondet.
%
%   Horario tiene un término examen(Materia, Dia, Aula) por materia. Las
%   aulas son 1, 2, … con las Capacidades dadas: cada aula tiene un examen
%   por día como máximo, y los inscriptos de la materia caben en el aula.
%   Dos materias con un alumno en común rinden en días distintos.
horario_con_aulas(Capacidades, Dias, Horario) :-
    length(Capacidades, Aulas),
    findall(examen(M, _, _), materia(M, _, _), Horario),
    maplist(dominio_de_examen(Dias, Aulas, Capacidades), Horario),
    findall(M1-M2, conflicto(M1, M2), Conflictos),
    maplist(examenes_en_dias_distintos(Horario), Conflictos),
    turnos_distintos(Horario),
    append_variables(Horario, Vs),
    label(Vs).

%!  dominio_de_examen(+Dias, +Aulas, +Capacidades, +Examen) is semidet.
%
%   El día del Examen va de 1 a Dias, el aula de 1 a Aulas, y la capacidad
%   del aula elegida alcanza para los inscriptos de la materia.
dominio_de_examen(Dias, Aulas, Capacidades, examen(M, Dia, Aula)) :-
    Dia in 1..Dias,
    Aula in 1..Aulas,
    inscriptos(M, Legajos),
    length(Legajos, N),
    element(Aula, Capacidades, Capacidad),
    N #=< Capacidad.

%!  examenes_en_dias_distintos(+Horario:list, +Conflicto:pair) is det.
%
%   Las dos materias de Conflicto rinden en días distintos.
examenes_en_dias_distintos(Horario, M1-M2) :-
    memberchk(examen(M1, D1, _), Horario),
    memberchk(examen(M2, D2, _), Horario),
    D1 #\= D2.

%!  turnos_distintos(+Horario:list) is det.
%
%   Dos exámenes no ocupan la misma aula el mismo día: cada par Dia-Aula se
%   codifica como un número distinto.
turnos_distintos(Horario) :-
    maplist([examen(_, D, A), T]>>(T #= D * 100 + A), Horario, Turnos),
    all_different(Turnos).

%!  append_variables(+Horario:list, -Vs:list) is det.
%
%   Vs son las variables de día y aula de Horario, en orden.
append_variables(Horario, Vs) :-
    foldl([examen(_, D, A), V0, V]>>append(V0, [D, A], V), Horario, [], Vs).
```

```prolog
?- horario_con_aulas([4, 6], 5, H).
H = [examen(am1, 1, 2), examen(alg, 2, 1), examen(log, 3, 1), examen(am2, 4, 1), examen(pp, 5, 1), examen(ssl, 1, 1), examen(bd, 2, 2)] ;
...
```

Cada examen tiene dos variables, el día y el aula. `element(Aula, Capacidades,
Capacidad)` relaciona el aula elegida con su capacidad, y la restricción
`N #=< Capacidad` descarta las aulas de capacidad insuficiente: am1, con cinco
inscriptos, va al aula 2. `turnos_distintos/1` codifica cada par día-aula como
un número, `D * 100 + A`, y exige que sean distintos: dos exámenes no comparten
el aula el mismo día. Con dos aulas de 4, no hay horario: am1 no cabe en
ninguna.
