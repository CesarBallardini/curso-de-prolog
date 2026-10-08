# Soluciones del capítulo 14 — Estilo y documentación

El código de esta página está en `ejemplos/capitulo-14/soluciones.pl` y pasa sus
pruebas.

## 1

Las primeras líneas del manual, que se leen con `help/1`:

| Predicado | Encabezado | Por qué |
|---|---|---|
| `atom_length/2` | `atom_length(+Atom, -Length)` | el átomo debe tener valor; la longitud es de salida y, si llega ligada, se comprueba |
| `msort/2` | `msort(+List, -Sorted)` | la lista debe estar; sus elementos pueden ser cualquier término, incluso variables |
| `==/2` | `@Term1 == @Term2` | compara sin ligar nada |
| `once/1` | `once(:Goal)` | el argumento es un objetivo que se va a llamar |
| `between/3` | `between(+Low, +High, ?Value)` | los extremos deben tener valor; `Value` se genera o se comprueba |

`between/3` declara `?Value` y no `-Value`: con `Value` ligado no calcula nada,
solo comprueba que esté en el intervalo. `-` también admitiría un valor ligado,
pero dice que el uso principal es obtenerlo; `?` dice que los dos usos son
igualmente propios.

## 2

| Llamada | Determinación |
|---|---|
| `fail/0` | `failure`: nunca tiene respuesta |
| `true/0` | `det`: exactamente una |
| `member(X, L)` con `L` ligada | `nondet`: una por cada elemento, ninguna con la lista vacía |
| `between(1, 5, N)` | cinco respuestas; el predicado en general es `nondet`, porque `between(5, 1, N)` no tiene ninguna |
| `throw(error)` | `erroneous`: siempre produce un error |
| `repeat/0` | `multi`: tiene infinitas respuestas, y al menos una |

La determinación es una propiedad del predicado en un modo, no de una llamada
particular: `between(1, 5, N)` responde cinco veces, pero el encabezado de
`between/3` debe cubrir también los intervalos vacíos.

## 3

<!-- ejemplo: capitulo-14/soluciones.pl predicado: sacar/3 consulta: sacar(a, [a, b, a], R). -->
```prolog
%!  sacar(+X, +L:list, -R:list) is semidet.
%
%   R es L sin la primera aparición de X; falla si X no está en L.
sacar(X, [X|Resto], Resto).
sacar(X, [Otro|Resto], [Otro|RestoR]) :-
    Otro \== X,
    sacar(X, Resto, RestoR).
```

Un modo, `sacar(+X, +L, -R) is semidet`: una respuesta, o ninguna si `X` no está.
Las pruebas cubren las dos posibilidades del modo y el caso con `R` ligada:

<!-- ejemplo: capitulo-14/soluciones.plt fragmento: % Ejercicio 3 .. sacar(a, [a, b, a], [b, a]). -->
```prolog
% Ejercicio 3: una prueba por modo de sacar(+X, +L, -R) is semidet, y los
% casos límite. Una respuesta como mucho, pero la implementación deja una
% alternativa pendiente (la segunda cláusula), y por eso las pruebas que se
% cumplen declaran nondet; los capítulos 15 y 16 muestran cómo quitarla.
test(sacar_la_primera_aparicion, [nondet, true(R == [b, a])]) :-
    sacar(a, [a, b, a], R).

test(sacar_lo_que_no_esta, [fail]) :-
    sacar(z, [a, b], _).

test(sacar_con_resultado_ligado, [nondet]) :-
    sacar(a, [a, b, a], [b, a]).
```

Las pruebas que se cumplen declaran `[nondet]`. Sin esa opción, plunit advierte
que terminan con una alternativa pendiente: después de la primera cláusula queda
por probar la segunda, que falla recién al comparar `Otro \== X`. El predicado
es `semidet` por el conteo lógico —tiene una respuesta como mucho—, pero la
implementación no puede descartar la segunda cláusula de antemano. El comentario de las pruebas lo registra,
y los capítulos [15](../capitulo-15-control/index.md) y [16](../capitulo-16-rendimiento/index.md) muestran cómo quitar esa alternativa.

## 4

<!-- ejemplo: capitulo-14/soluciones.pl predicado: padre/2 abuelo/2 consulta: abuelo(ana, Nieto). -->
```prolog
% padre(P, H): P es el padre de H.
padre(ana, luis).
padre(luis, eva).

%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N: A es padre de alguien que es padre de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).
```

`calc` no dice qué calcula; los hechos `f/2` relacionan una persona con otra, y
la regla recorre dos generaciones. Con esos nombres, la cabeza `abuelo(A, N)` se
lee «A es abuelo de N», y el cuerpo, «A es padre de alguien que es padre de N».
`Z` pasa a `P`, por su papel en la relación.

## 5

`signo(-3, positivo).` responde `true.` con la versión del enunciado: la primera
cláusula no se elige, porque su cabeza exige `negativo`; la segunda tampoco,
porque exige `0`; y la tercera acepta cualquier valor. Es el defecto de
`mal_maximo/3`: la salida está en la cabeza, antes del corte. Con el [Patrón 3](../patrones.md#3-salida-despues-del-compromiso):

<!-- ejemplo: capitulo-14/soluciones.pl predicado: signo/2 consulta: signo(-3, S). -->
```prolog
%!  signo(+N:number, -S:atom) is det.
%!  signo(+N:number, +S:atom) is semidet.
%
%   S es negativo, cero o positivo, según N. Cada salida se liga después del
%   corte, de modo que el resultado no depende de que S llegue ligada.
signo(N, S) :-
    N < 0,
    !,
    S = negativo.
signo(N, S) :-
    N =:= 0,
    !,
    S = cero.
signo(_, positivo).
```

```prolog
?- signo(-3, positivo).
false.
```

La segunda cláusula también cambia: `signo(0, S) :- !, S = cero.` todavía
depende de la cabeza, porque `0` en la cabeza no unifica con `0.0`. `N =:= 0`
compara el valor.

## 6

`signo(5, S).` responde `S = positivo.` sin error. La directiva confirma que la
implementación es determinista en todos los casos: las dos primeras cláusulas
terminan con un corte, y la tercera es la última, de modo que ninguna llamada
deja alternativas. El encabezado `det` y el código coinciden, y `det/1` lo
verifica en cada llamada.

## 7

<!-- ejemplo: capitulo-14/soluciones.pl predicado: aprobadas_de/2 consulta: aprobadas_de(101, Materia). -->
```prolog
%!  aprobadas_de(?Legajo:integer, ?Materia:atom) is nondet.
%
%   El alumno Legajo aprobó Materia, con cualquier nota.
aprobadas_de(Legajo, Materia) :-
    aprobada(Legajo, Materia, _Nota).
```

```prolog
?- aprobadas_de(101, Materia).
Materia = am1 ;
Materia = alg ;
Materia = log ;
Materia = am2 ;
false.
```

Se verifican C1 (el encabezado, con pruebas para legajo ligado, materia ligada y
los dos ligados), C2 (con todo libre enumera todos los pares), C3 (con los dos
ligados comprueba, y `aprobadas_de(102, alg)` falla, como corresponde), C6 (no
tiene efectos laterales) y C7 (las pruebas). C4 no corresponde, porque no es
`det`.
C5 queda como restricción: con un legajo que no es un número, falla en lugar de
producir un error.

`_Nota` documenta qué se ignora sin producir la advertencia de variable única.

## 8

<!-- ejemplo: capitulo-14/soluciones.pl predicado: prestamo_por_defecto/3 vencido_por_defecto/1 prestamo/2 vencido/1 consulta: vencido(P). -->
```prolog
% prestamo_por_defecto(Id, Devuelto, Vencido): Devuelto es la fecha de
% devolución o no; Vencido es la fecha desde la que está vencido o no.
prestamo_por_defecto(p1, no,       no).
prestamo_por_defecto(p2, 20260910, no).
prestamo_por_defecto(p3, no,       20260901).

%!  vencido_por_defecto(?Id:atom) is nondet.
%
%   El préstamo Id está vencido, con la representación por defecto: es
%   necesario distinguir el valor especial no de una fecha.
vencido_por_defecto(Id) :-
    prestamo_por_defecto(Id, no, Desde),
    Desde \== no.

% prestamo(Id, Estado): Estado es en_curso, devuelto(Fecha) o
% vencido(Desde).
prestamo(p1, en_curso).
prestamo(p2, devuelto(20260910)).
prestamo(p3, vencido(20260901)).

%!  vencido(?Id:atom) is nondet.
%
%   El préstamo Id está vencido. El caso se selecciona por unificación.
vencido(Id) :-
    prestamo(Id, vencido(_Desde)).
```

La representación por defecto usa `no` como valor especial en dos posiciones, y
la regla debe excluirlo con `Desde \== no`: si se olvida esa comparación, los
préstamos en curso también aparecen como vencidos. La representación limpia
tiene un functor por estado, y `vencido/1` selecciona el suyo con
`vencido(_Desde)` en el segundo argumento, sin ninguna comparación.

La actividad de la [sección 14.6](index.md#146-representacion-de-los-datos) muestra el mismo defecto en *Inscripciones*.
Con el `inscripciones.pl` del [capítulo 13](../capitulo-13-el-entorno-de-trabajo/index.md) cargado, `inscripcion(L, M, N), N >= 6.`
da cuatro respuestas —las notas de `101` en `am1`, `alg`, `log` y `am2`— y en
la quinta inscripción, la de `pp`, produce ``ERROR: Arithmetic: `null/0' is not
a function``: la comparación recibe el átomo `null`. Es el error que
`integer(N)` evitaba en la regla de esa sección. Con la versión de este
capítulo, `aprobada(L, M, N)` enumera las diez aprobadas sin ninguna prueba de
tipo: `nota(Nota)` en la llamada a `inscripcion/3` deja fuera las inscripciones
en curso.

## 9

`sin_repetidos/2` de la solución 10 del [capítulo 9](../capitulo-09-backtracking-y-corte/soluciones.md#10):

| | Criterio | Resultado |
|---|---|---|
| C1 | Interfaz declarada | sí: `sin_repetidos(+L, -R) is det` |
| C2 | Consulta más general | con `L` libre enumera listas cada vez más largas, sin fin; las respuestas son correctas, y el `+L` del encabezado declara la restricción |
| C3 | Estabilidad | sí: `sin_repetidos([a, b, a], [b, a])` falla, como corresponde |
| C4 | Sin puntos de elección sobrantes | **no**: declara `det`, pero plunit advierte *Test succeeded with choicepoint* en una prueba sin `nondet`; la tercera cláusula queda pendiente después de la segunda |
| C5 | Error, no falla silenciosa | con una lista con variables, `member/2` las unifica: `sin_repetidos([X, a], R)` responde `X = a, R = [a]`, es decir, liga una variable de quien llama para quitar un «repetido» que no lo era; no hay error, y el `+L` no lo advierte |
| C6 | Núcleo puro, bordes impuros | sí |
| C7 | Probado | sí, con tres pruebas, que declaran `all(...)` y por eso no advierten las alternativas |

El incumplimiento de C4 se corrige con el condicional del [capítulo 15](../capitulo-15-control/index.md). El
de C5, declarando `++L` en lugar de `+L`: la lista debe llegar completa.

## 10

La página de `inscripciones.pl` muestra `nota_minima/1`, `aprobada/3` y
`cursa/2`, cada uno con su primera línea —modos, tipos y determinación— y su
descripción, con los nombres de los argumentos destacados. No muestra los
hechos `alumno/4`, `materia/3`, `correlativa/2` ni `inscripcion/3`: sus
comentarios de una línea empiezan con `%` y no con `%!`, y PlDoc solo lee los
segundos. Si se quiere que una tabla de hechos aparezca en la documentación, se
le escribe un encabezado `%!`, como a un predicado.

## 11

`suma_lista/2`, de `encabezados.pl`, necesita el valor de cada elemento para
sumarlo; `largo/2` solo cuenta cuántos hay:

```prolog
?- suma_lista([a, b], S).
ERROR: Arithmetic: `b/0' is not a function
```

`largo([a, b], N)` responde `N = 2`. Por eso `largo/2` declara `+L` —la lista
debe llegar instanciada, sus elementos pueden ser cualquier término— y
`suma_lista/2` declara `++L` con el tipo `list(number)`.

El encabezado completo que pide la actividad de la [sección 14.3](index.md#143-el-encabezado-completo) escribe esa
diferencia en el tipo: `list` sin parámetro, porque los elementos no se
examinan.

```prolog
%!  largo(+L:list, -N:integer) is det.
%!  largo(-L:list, -N:integer) is multi.
%
%   N es la cantidad de elementos de L. Con L libre, enumera listas de
%   variables de largo creciente.
```

El modo con `L` libre y `N` ligada no se declara: da la lista de `N` variables
y después no termina, como documenta el encabezado del [capítulo 7](../capitulo-07-listas/index.md#74-contar-durante-el-recorrido).

## 12

<!-- ejemplo: capitulo-14/soluciones.pl predicado: iguala/2 consulta: iguala(X, a). -->
```prolog
%!  iguala(?A, ?B) is semidet.
%
%   A y B unifican. Liga variables de los dos: sus argumentos son ?, no @.
iguala(A, B) :-
    A = B.
```

```prolog
?- iguala(X, a).
X = a.
```

`iguala(X, a)` liga `X`: el predicado instancia sus argumentos, y por eso le
corresponde `?`, no `@`. `mismo_termino(X, a)` falla sin ligar nada, porque
una variable libre no es el átomo `a`.

## 13

Con la directiva agregada:

- con `[a, b, c]`, `P = a, U = c`, sin error: `last/2` está implementado sin
  dejar alternativas, y la llamada es determinista;
- con `[]`, un error: *Deterministic procedure primero_y_ultimo/3 failed*. Para
  `det/1`, fallar también es no cumplir: `det` promete exactamente una
  respuesta;
- con la lista libre, un error: *Deterministic procedure primero_y_ultimo/3
  succeeded with a choicepoint*, y la traza del error señala `lists:last_/3`:
  `last/2` puede seguir generando listas.

El encabezado declara `?L ... is nondet` porque describe todos los modos, y en
dos de ellos el predicado no es `det`. `det/1` no admite matices: se aplica a
todas las llamadas.

## 14

El encabezado:

```prolog
%!  materia_de_anio(+Anio:integer, -Materias:list(atom)) is det.
%
%   Materias es la lista de los códigos de las materias de Anio, en el orden
%   en que aparecen en la base; la lista vacía si no hay ninguna.
```

Las pruebas que lo verificarían:

```prolog
test(las_de_primer_anio, true(M == [am1, alg, log])) :-
    materia_de_anio(1, M).

test(un_anio_sin_materias, true(M == [])) :-
    materia_de_anio(4, M).
```

Sin repetir los datos, la parte I no puede reunir las respuestas de
`materia(M, _, 1)` en una lista: solo puede recorrerlas de a una. El
[capítulo 17](../capitulo-17-todas-las-soluciones/index.md) presenta `findall/3`, que reúne todas las respuestas de un objetivo y
con el que el predicado ocupa una línea.

## 15

Leído solo como código, el predicado relaciona cuatro términos: el segundo y el
cuarto son listas que coinciden en todas las posiciones menos en una, donde el
segundo tiene el primer argumento y el cuarto tiene el tercero. La lectura es
simétrica: nada indica cuál de las dos listas es el dato y cuál el resultado.

El modo `p(+, +, +, -)` rompe esa simetría: la segunda lista es el resultado.
Con él, el predicado reemplaza una aparición del primer argumento en la primera
lista por el tercero; si el primero aparece varias veces, da una respuesta por
cada aparición, de izquierda a derecha, y si no aparece, falla. La consulta lo
confirma, con el predicado ya nombrado:

<!-- ejemplo: capitulo-14/soluciones.pl predicado: reemplazo/4 consulta: reemplazo(b, [a, b, c, b], z, L). -->
```prolog
%!  reemplazo(?Viejo, +Lista:list, ?Nuevo, -Resultado:list) is nondet.
%!  reemplazo(?Viejo, -Lista:list, ?Nuevo, +Resultado:list) is nondet.
%
%   Resultado es Lista con una aparición de Viejo reemplazada por Nuevo. Si
%   Viejo aparece varias veces, hay una respuesta por cada aparición.
reemplazo(Viejo, [Viejo|Resto], Nuevo, [Nuevo|Resto]).
reemplazo(Viejo, [Otro|Resto], Nuevo, [Otro|Resto2]) :-
    reemplazo(Viejo, Resto, Nuevo, Resto2).
```

```prolog
?- reemplazo(b, [a, b, c, b], z, L).
L = [a, z, c, b] ;
L = [a, b, c, z] ;
false.
```

El nombre sigue la [sección 14.1](index.md#141-nombres): `reemplazo/4` nombra la relación y no una
acción, porque el predicado también se usa en el otro sentido, que el
encabezado declara en una segunda línea de modo:

```prolog
?- reemplazo(b, L, z, [a, z, c]).
L = [a, b, c] ;
false.
```

Ninguno de los dos modos declara `?` en las listas: con las dos libres, el
predicado genera respuestas sin fin, con el reemplazo cada vez una posición más
adelante y el resto de las listas sin determinar. `Viejo` y `Nuevo`
pueden llegar libres, porque la unificación con los elementos de la lista los
liga.

`select/4` de la biblioteca define la misma relación, con los argumentos en el
mismo orden, y da las mismas respuestas en el mismo orden:

```prolog
?- select(b, [a, b, c, b], z, L).
L = [a, z, c, b] ;
L = [a, b, c, z] ;
false.
```

La única diferencia está en la definición: `select/4` pasa la lista a un
auxiliar como primer argumento, la disposición del [Patrón 9](../patrones.md#9-el-argumento-que-indexa-primero). La primera
lectura del ejercicio muestra por qué el encabezado importa: el código solo
dice qué términos se relacionan, y los modos dicen cuáles se dan y cuáles se
obtienen.

## 16

Con `$` en lugar del corte, y con los nombres `maximo_d/3` y `mal_maximo_d/3`
para distinguirlos de los predicados de `estilo.pl`:

<!-- ejemplo: capitulo-14/soluciones.pl predicado: maximo_d/3 mal_maximo_d/3 consulta: maximo_d(3, 1, 1). -->
```prolog
%!  maximo_d(+X, +Y, -M) is det.
%
%   M es el mayor de X e Y: maximo/3 de estilo.pl con $ en lugar del corte.
%   Con M ligada a un valor que no es el mayor, M = X falla después de $, y
%   SWI-Prolog lo informa como un error en lugar de responder false.
maximo_d(X, Y, M) :-
    X >= Y,
    $,
    M = X.
maximo_d(_, Y, Y).

%!  mal_maximo_d(+X, +Y, -M) is det.
%
%   M pretende ser el mayor de X e Y: mal_maximo/3 con $ en lugar del corte.
%   Sigue siendo incorrecta: con M ligada a un valor falso, la primera
%   cláusula no se elige y $ nunca se ejecuta. $ y . son caracteres de
%   símbolo, de modo que el $ final se escribe separado del punto.
mal_maximo_d(X, Y, X) :-
    X >= Y,
    $ .
mal_maximo_d(_, Y, Y).
```

```prolog
?- maximo_d(3, 1, M).
M = 3.

?- maximo_d(1, 3, M).
M = 3.

?- maximo_d(3, 1, 1).
ERROR: Procedure maximo_d/3 failed after $-guard

?- mal_maximo_d(3, 1, 1).
true.
```

Las dos primeras consultas responden igual que con el corte: `$` poda la segunda
cláusula, y lo que sigue, `M = X`, tiene éxito exactamente una vez. La tercera
cambia: con el corte, `maximo(3, 1, 1)` falla; con `$`, `M = X` falla después
de la poda, y SWI-Prolog lo informa como un error, porque `$` promete que el
resto de la cláusula tiene exactamente una respuesta.

`mal_maximo_d(3, 1, 1)` sigue respondiendo `true.`: la primera cláusula no se
elige, porque su cabeza exige que el tercer argumento sea igual al primero, de
modo que `$` nunca se ejecuta, y la segunda cláusula responde que 1 es el
mayor. `$` verifica la determinación de lo que sigue en la cláusula que lo
ejecuta; la estabilidad depende de qué cláusula se elige, y eso se decide
antes. La corrección sigue siendo el [Patrón 3](../patrones.md#3-salida-despues-del-compromiso).

Un detalle de sintaxis: `$` y `.` son caracteres de símbolo, y `$.` se lee como
un solo átomo; el `$` que cierra una cláusula se escribe `$ .`, con un espacio,
que es también como lo imprime `listing/1`.
