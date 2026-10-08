# Soluciones del capítulo 26 — Pruebas y depuración

El código de esta página está en `ejemplos/capitulo-26/soluciones.pl`,
`soluciones_proyecto.pl` y `soluciones_buscaminas.pl`, con sus archivos de
pruebas, y pasa sus pruebas. En este capítulo, muchas soluciones son pruebas:
están en los archivos `.plt`.

## 1

| Se espera que la prueba… | Opción |
|---|---|
| falle | `fail` |
| produzca un error de tipo | `error(type_error(_, _))` |
| tenga tres respuestas conocidas | `all(X == [a, b, c])` |
| deje alternativas | `nondet` |
| recorra una tabla de casos | `forall(caso(Entrada, Esperado))` |

## 2

Con el módulo y sus pruebas cargados, `run_tests(reglas)` ejecuta la unidad
completa y `run_tests(reglas:legajo_libre)` solo esa prueba. La salida de la
segunda está en la [sección 26.1](index.md#261-plunit-en-detalle).

## 3

```prolog
% (-, +, -): quiénes aprobaron una materia.
test(alumnos_de_una_materia, all(L == [101, 102, 104])) :-
    aprobada(L, log, _).

% Caso límite: la nota mínima aprueba; una menos, no.
test(nota_minima_aprueba) :-
    aprobada(106, am1, 6).

test(nota_menor_no_aprueba, [fail]) :-
    aprobada(106, log, _).
```

La unidad `aprobada_por_modo` de `soluciones_proyecto.plt` tiene una prueba por
cada modo del encabezado de `aprobada/3` y tres casos límite: la nota mínima,
una nota menor y una materia que se está cursando. Los modos `nondet` se prueban
con `all/1`, que verifica también el orden de las respuestas.

## 4

```prolog
caso(104, ssl, aceptada).
caso(102, alg, aceptada).
caso(999, am1, rechazada(alumno_inexistente)).
caso(101, quimica, rechazada(materia_inexistente)).
caso(101, log, rechazada(ya_aprobada)).
caso(101, pp, rechazada(ya_la_cursa)).
caso(102, am2, rechazada(falta(am1))).
caso(105, log, rechazada(sin_vacantes)).

test(inscripcion_posible,
     [forall(caso(L, M, Esperado)), true(R == Esperado)]) :-
    inscripcion_posible(L, M, R).
```

Una prueba con ocho filas: plunit informa cada fila como una subprueba, y si
una falla dice cuál. Agregar un caso es agregar un hecho.

## 5

```prolog
:- dynamic advertido/1.

user:message_hook(inscripcion_sin_datos(L, M), warning, _) :-
    assertz(plunit_cobertura:advertido(L-M)).

test(advertencia, [ setup(estado(E)),
                    cleanup(( restaurar(E), retractall(advertido(_)) )),
                    true(A == [999-am1]) ]) :-
    agregar_inscripcion(999, am1, cursando),
    comprobar_datos,
    findall(X, advertido(X), A).
```

`message_hook/3` intercepta el mensaje antes de que se escriba, y lo registra en
un hecho del módulo de la unidad. La prueba agrega una inscripción de un alumno
inexistente, ejecuta la comprobación y restaura el estado. Con ella, `datos.pl`
llega al 100 % de cobertura.

## 6

Skip, en el primer `Call` de `padre/2`, ejecuta esa llamada completa: la traza
pasa directamente a `Exit: (11) padre(juan, ana)`, sin los puertos internos,
que en un hecho no hay. Retry, en el `Fail` de `padre(ana, _)`, vuelve a su
`Call`, que falla otra vez: retry repite una llamada, no cambia los datos.

Respuesta a la actividad de la
[sección 26.3](index.md#263-el-depurador-en-la-terminal): en el `Fail` de
`padre(ana, _)`, `g` muestra dos llamadas, `padre(ana, _)` a profundidad 11 y,
debajo, `abuelo(juan, _)` a profundidad 10, la llamada que la contiene. Las
llamadas del toplevel no aparecen.

## 7

<!-- ejemplo: capitulo-26/soluciones_proyecto.pl predicado: inscribir_registrado/3 consulta: vacantes_no_negativas. -->
```prolog
%!  inscribir_registrado(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Como inscribir/3, y además escribe, con el tema de depuración
%   inscripcion, el pedido y su resultado.
inscribir_registrado(Legajo, Materia, Resultado) :-
    debug(inscripcion, "inscribir ~w en ~w", [Legajo, Materia]),
    inscribir(Legajo, Materia, Resultado),
    debug(inscripcion, "resultado: ~w", [Resultado]).
```

```text
% inscribir 104 en ssl
% resultado: aceptada
```

Esas dos líneas aparecen solo después de `debug(inscripcion)`. Sin el tema
activado, `inscribir_registrado/3` se comporta como `inscribir/3`, y los
mensajes pueden quedar en el código.

## 8

<!-- ejemplo: capitulo-26/soluciones_proyecto.pl predicado: vacantes_no_negativas/0 consulta: vacantes_no_negativas. -->
```prolog
%!  vacantes_no_negativas is det.
%
%   Comprueba con assertion/1 que ninguna materia tiene vacantes negativas:
%   es un invariante del programa, que inscribir/3 debe mantener.
vacantes_no_negativas :-
    forall(vacantes(_, N),
           assertion(N >= 0)),
    debug(inscripcion, "vacantes verificadas", []).
```

Con los datos del proyecto, el invariante se cumple. Después de
`cambiar_vacantes(log, -1)`, que deja lógica en −1, la aserción produce
`Assertion failed: user:(-1>=0)`, con la pila de llamadas.

## 9

<!-- ejemplo: capitulo-26/soluciones.pl predicado: largo_mal/2 largo/2 consulta: largo_mal([a, b], N). -->
```prolog
%!  largo_mal(+L:list, -N:integer) is det.
%
%   Debería ser la cantidad de elementos de L; tiene un error plantado en el
%   caso base.
largo_mal([], 1).
largo_mal([_|Resto], N) :-
    largo_mal(Resto, N0),
    N is N0 + 1.

%!  largo(+L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L: largo_mal/2 corregido.
largo([], 0).
largo([_|Resto], N) :-
    largo(Resto, N0),
    N is N0 + 1.
```

```prolog
?- largo_mal([], N).
N = 1.
```

Se pregunta a las partes, empezando por la más simple: la lista vacía debería
tener largo 0, y `largo_mal/2` responde 1. El caso recursivo, con esa respuesta
incorrecta como base, suma bien: el error está en el caso base, y no es
necesario examinar el recursivo. `largo/2` es la versión corregida.

## 10

<!-- ejemplo: capitulo-26/soluciones.pl predicado: hermanos_mal/2 hermanos_recortado/2 hermanos/2 consulta: hermanos(ana, H). -->
```prolog
%!  hermanos_mal(?A, ?B) is nondet.
%
%   Debería ser: A y B son hermanos, hijos del mismo padre y distintos. El
%   error: el último objetivo compara con == en lugar de \==.
hermanos_mal(A, B) :-
    padre(P, A),
    padre(P, B),
    A == B.

%!  hermanos_recortado(?A, ?B) is nondet.
%
%   hermanos_mal/2 con el último objetivo tachado: responde, y por eso el
%   error está en el objetivo tachado.
hermanos_recortado(A, B) :-
    padre(P, A),
    padre(P, B),
    * A == B.

%!  hermanos(?A, ?B) is nondet.
%
%   A y B son hermanos: hermanos_mal/2 corregido.
hermanos(A, B) :-
    padre(P, A),
    padre(P, B),
    A \== B.
```

Con el último objetivo tachado, `hermanos_recortado(ana, pedro)` se cumple: el
error está en `A == B`, que exige que los dos sean el mismo, en lugar de
distintos. Tachar el primero o el segundo no alcanza, porque el tercero sigue
fallando.

Respuesta a la actividad de la
[sección 26.6](index.md#266-depuracion-declarativa): con el primer objetivo de
`abuelo_mal/2` tachado, el cuerpo queda en `padre(N, P)`, y
`abuelo_mal(juan, luis)` pide `padre(luis, P)`, que no tiene respuesta: luis no
tiene hijos en el programa. La generalización todavía falla, de modo que el
objetivo tachado no era el responsable.

## 11

<!-- ejemplo: capitulo-26/soluciones_buscaminas.pl predicado: minas_al_azar/4 tablero_al_azar/4 consulta: tablero_al_azar(5, 5, 4, T), valor(T, 1-1, V). -->
```prolog
%!  minas_al_azar(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                -Minas:list) is det.
%
%   Minas son Cantidad celdas distintas del tablero, elegidas al azar, en
%   orden.
minas_al_azar(Filas, Columnas, Cantidad, Minas) :-
    Total is Filas * Columnas,
    randseq(Cantidad, Total, Numeros),
    maplist(celda_numero(Columnas), Numeros, Celdas),
    sort(Celdas, Minas).

%!  tablero_al_azar(+Filas:integer, +Columnas:integer, +Cantidad:integer,
%!                  -Tablero) is det.
%
%   Tablero es un tablero de Filas por Columnas con Cantidad minas al azar.
tablero_al_azar(Filas, Columnas, Cantidad, Tablero) :-
    minas_al_azar(Filas, Columnas, Cantidad, Minas),
    tablero(Filas, Columnas, Minas, Tablero).
```

```prolog
test(semilla_fija, [ setup(set_random(seed(42))),
                     true(M == [2-3, 3-2, 3-4, 5-1]) ]) :-
    minas_al_azar(5, 5, 4, M).

test(cantidad_de_minas, [forall(between(1, 20, S)), true(N == 10)]) :-
    set_random(seed(S)),
    tablero_al_azar(9, 9, 10, tablero(_, _, Celdas)),
    assoc_to_values(Celdas, Vs),
    aggregate_all(count, member(mina, Vs), N).

test(numeros_correctos, [forall(between(1, 20, S)), fail]) :-
    set_random(seed(S)),
    tablero_al_azar(6, 6, 6, T),
    valor(T, F-C, N),
    integer(N),
    aggregate_all(count, ( vecina(6, 6, F-C, V), valor(T, V, mina) ), M),
    M =\= N.
```

La primera prueba fija la semilla y compara con un resultado conocido: detecta
cualquier cambio en cómo se eligen las minas. Las de propiedades recorren
veinte semillas y verifican lo que vale para cualquier tablero: la cantidad de
minas, y que cada número cuenta sus minas vecinas. La segunda propiedad se
escribe al revés, con `fail`: ninguna celda numerada cuenta una cantidad de
minas vecinas distinta de su número.

Es el [Patrón 34](../patrones.md#34-azar-reproducible), de la [sección 26.2](index.md#262-la-bateria-completa-y-su-cobertura).

## 12

<!-- ejemplo: capitulo-26/soluciones.pl predicado: resumen_con_error/1 consulta: hermanos(ana, H). -->
```prolog
%!  resumen_con_error(-Texto:string) is det.
%
%   Llama a promedo/2, que no existe: el nombre está mal escrito. Cargar el
%   archivo no lo detecta; check/0 sí.
resumen_con_error(Texto) :-
    promedo([6, 9], P),
    format(string(Texto), "Promedio: ~w", [P]).
```

La carga no dice nada: una cláusula puede llamar a un predicado que todavía no
existe, porque podría definirse después. `check.` examina el programa completo y
lo informa, con el archivo, la línea y la cláusula; la salida está en la
[sección 26.7](index.md#267-check0-list_undefined0-y-gxref0).

## 13

`inferencias(G, I)` mide con `statistics(inferences, I)` antes y después de
`once(G)`:

```prolog
inferencias(G, I) :-
    statistics(inferences, I0),
    once(G),
    statistics(inferences, I1),
    I is I1 - I0.
```

```prolog
test(segunda_llamada_mas_barata) :-
    retractall(reglas:requisitos_guardados(_, _)),
    inferencias(requisitos_de(bd, _), Primera),
    inferencias(requisitos_de(bd, _), Segunda),
    Segunda < Primera,
    Segunda < 10.
```

La primera llamada calcula y guarda, con unas 37 inferencias; la segunda
encuentra el valor guardado, con 3. La prueba vacía la tabla primero, para que
el orden de las pruebas no importe, y usa cotas en lugar de cantidades exactas.

## 14

<!-- ejemplo: capitulo-26/soluciones.pl predicado: natural/1 consulta: hermanos(ana, H). -->
```prolog
%!  natural(?N) is nondet.
%
%   N es un número natural. Con N libre, genera 0, 1, 2, … sin terminar.
natural(0).
natural(N) :-
    natural(N0),
    N is N0 + 1.
```

```prolog
test(no_termina, true(R == inference_limit_exceeded)) :-
    call_with_inference_limit(natural(-1), 100000, R).
```

`natural(-1)` no termina: genera naturales sin encontrar nunca −1. Un límite de
inferencias la detiene, independiente de la velocidad de la máquina. La opción
`timeout(Segundos)` de plunit también la detendría, pero con un límite de
tiempo.

## 15

Con `spy(padre/2)` y `l` en cada puerto, la sesión muestra siete puertos,
todos de `padre/2`: `Call` y `Exit` de `padre(juan, _)` con `ana`, `Call` y
`Fail` de `padre(ana, _)`, `Exit` de `padre(juan, _)` con `pedro`, y `Call` y
`Exit` de `padre(pedro, _)` con `luis`; la sesión está en la
[sección 26.3](index.md#263-el-depurador-en-la-terminal). Frente a la traza
completa, no aparecen los puertos de `abuelo/2` ni el `Redo` de
`padre(juan, _)`: leap avanza de un punto espía al siguiente, y lo que ocurre
entre ellos no se muestra. `nospy(padre/2)` quita el punto espía, y la
consulta siguiente corre sin detenerse.
