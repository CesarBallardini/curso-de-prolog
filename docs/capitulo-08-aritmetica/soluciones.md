# Soluciones del capítulo 8 — Aritmética

El código de esta página está en `ejemplos/capitulo-08/soluciones.pl` y pasa sus
pruebas.

## 1

```prolog
?- X is 10 / 4.
X = 2.5.

?- X is 10 // 4.
X = 2.

?- X is 10 mod 4.
X = 2.
```

Las dos últimas producen `2` por razones distintas: `//` es el cociente de la
división, sin la parte decimal, y `mod` es el resto. En este caso los dos
valores coinciden.

## 2

<!-- ejemplo: capitulo-08/soluciones.pl predicado: triple/2 consulta: triple(5, T). -->
```prolog
% triple(N, T): T es el triple de N.
triple(N, T) :-
    T is N * 3.
```

```prolog
?- triple(5, T).
T = 15.

?- triple(N, 15).
ERROR: Arguments are not sufficiently instantiated
```

La segunda consulta corresponde a la sección 8.3: `is/2` no despeja incógnitas.
Para evaluar `N * 3` requiere el valor de `N`, y `N` está libre. Que el
resultado esperado sea 15 no aporta ninguna información a la evaluación.

## 3

| | |
|---|---|
| `3 + 4 = 7` | **falsa**: `3+4` y `7` son términos distintos |
| `3 + 4 =:= 7` | verdadera: las dos expresiones tienen el mismo valor |
| `7 = 7` | verdadera: es el mismo término |
| `7 =:= 7.0` | verdadera: tienen el mismo valor numérico |
| `7 = 7.0` | **falsa**: un entero y un número de punto flotante no son el mismo término |

Respuesta a la actividad de la sección 8.2:

```prolog
?- luis = luis.
true.

?- luis =:= luis.
ERROR: Arithmetic: `luis/0' is not a function
```

`=:=` compara **valores numéricos**, por lo que primero intenta evaluar ambos
lados, y `luis` no es una expresión aritmética. El mensaje lo indica de manera
explícita.

## 4

<!-- ejemplo: capitulo-08/soluciones.pl predicado: es_par/1 consulta: es_par(8). -->
```prolog
% es_par(N): N es par.
es_par(N) :-
    0 =:= N mod 2.
```

Se puede escribir `0 =:= N mod 2` o `N mod 2 =:= 0`: el orden es indistinto,
porque ambos lados se evalúan antes de la comparación.

## 5

<!-- ejemplo: capitulo-08/soluciones.pl predicado: mayor_de_los_dos/3 consulta: mayor_de_los_dos(3, 9, M). -->
```prolog
% mayor_de_los_dos(A, B, M): M es el mayor de los dos números.
mayor_de_los_dos(A, B, A) :-
    A >= B.
mayor_de_los_dos(A, B, B) :-
    A < B.
```

Tiene dos cláusulas, de acuerdo con la plantilla 4. Las dos condiciones son
mutuamente excluyentes —una es `>=` y la otra, `<`—, de modo que nunca se
obtienen dos respuestas. Si en la primera se hubiera escrito `>`, con dos
números iguales no se cumpliría ninguna de las dos cláusulas.

## 6

<!-- ejemplo: capitulo-08/soluciones.pl predicado: cuantos_mayores/2 consulta: cuantos_mayores([12, 41, 8, 68], N). -->
```prolog
% cuantos_mayores(L, N): N es la cantidad de números de L mayores que 18.
cuantos_mayores([], 0).
cuantos_mayores([X|Resto], N) :-
    X > 18,
    cuantos_mayores(Resto, Faltan),
    N is Faltan + 1.
cuantos_mayores([X|Resto], N) :-
    X =< 18,
    cuantos_mayores(Resto, N).
```

Tiene tres cláusulas: la lista vacía, el caso en que el número se cuenta, y el
caso en que no. La condición de la tercera, `X =< 18`, es imprescindible: sin
ella, cada número mayor que 18 se resolvería por las dos cláusulas recursivas, y
se obtendrían respuestas de más.

## 7

<!-- ejemplo: capitulo-08/soluciones.pl predicado: promedio/2 recorriendo/5 consulta: promedio([10, 20, 30], P). -->
```prolog
% promedio(L, P): P es el promedio de los números de L.
% Un único recorrido con dos acumuladores: la suma y la cantidad.
promedio(L, P) :-
    recorriendo(L, 0, 0, Suma, Cuantos),
    Cuantos > 0,
    P is Suma / Cuantos.

recorriendo([], Suma, Cuantos, Suma, Cuantos).
recorriendo([X|Resto], SumaHasta, CuantosHasta, Suma, Cuantos) :-
    SumaAhora is SumaHasta + X,
    CuantosAhora is CuantosHasta + 1,
    recorriendo(Resto, SumaAhora, CuantosAhora, Suma, Cuantos).
```

Es un único recorrido con **dos acumuladores**: la suma y la cantidad. No existe
restricción sobre la cantidad de acumuladores; cada uno agrega argumentos al
predicado auxiliar.

La condición `Cuantos > 0` contempla la lista vacía: sin ella, el promedio de
`[]` produciría una división por cero. Con la condición, `promedio([], P)`
falla, que es el comportamiento adecuado.

Se debe tener en cuenta el tipo del resultado: `promedio([10, 20, 30], P)`
produce `20`, y no `20.0`, porque el cociente es exacto. Es el comportamiento
descripto en la sección 8.1.

## 8

<!-- ejemplo: capitulo-08/soluciones.pl predicado: maximo/2 buscando_maximo/3 consulta: maximo([3, 9, 4], M). -->
```prolog
% maximo(L, M): M es el mayor de L. La lista vacía no tiene máximo, por lo que
% el predicado falla para ella.
maximo([X|Resto], M) :-
    buscando_maximo(Resto, X, M).

buscando_maximo([], M, M).
buscando_maximo([X|Resto], Hasta, M) :-
    X > Hasta,
    buscando_maximo(Resto, X, M).
buscando_maximo([X|Resto], Hasta, M) :-
    X =< Hasta,
    buscando_maximo(Resto, Hasta, M).
```

El valor inicial del acumulador es el **primer elemento** de la lista, y no
cero. Con cero como valor inicial, el máximo de una lista de números negativos
sería cero, que no pertenece a la lista.

Respecto de la lista vacía, la decisión de diseño adoptada es que
`maximo([], M)` falle. La cabeza exige `[X|Resto]`, de modo que la lista vacía
no unifica con ninguna cláusula. Es el mismo comportamiento de `last/2`, y es
preferible a devolver un valor arbitrario.

## 9

<!-- ejemplo: capitulo-08/soluciones.pl predicado: factorial/2 consulta: factorial(5, F). -->
```prolog
% factorial(N, F): F es el factorial de N.
factorial(0, 1).
factorial(N, F) :-
    N > 0,
    Anterior is N - 1,
    factorial(Anterior, FactorialAnterior),
    F is N * FactorialAnterior.
```

El rango de funcionamiento es mayor que el previsible. Los enteros de Prolog
**no tienen un tamaño máximo**, de modo que el factorial no produce
desbordamiento:

```prolog
?- factorial(25, F).
F = 15511210043330985984000000 ;
false.
```

El límite no está dado por la magnitud del número sino por la profundidad de la
recursión: cada llamada deja una multiplicación pendiente hasta el retorno, y
esa operación pendiente ocupa memoria. Con un acumulador, ese límite se extiende
de manera considerable; el capítulo 14 trata el tema.

## 10

<!-- ejemplo: capitulo-08/soluciones.pl predicado: cuenta_atras/2 consulta: cuenta_atras(3, L). -->
```prolog
% cuenta_atras(N, L): L es la lista de los enteros de N a 1, en ese orden.
cuenta_atras(0, []).
cuenta_atras(N, [N|Resto]) :-
    N > 0,
    Anterior is N - 1,
    cuenta_atras(Anterior, Resto).
```

Esta versión no requiere acumulador, por la siguiente razón: la lista se
construye **en la cabeza**, con `[N|Resto]`, de acuerdo con la plantilla 12. El
número mayor ocupa la primera posición y la recursión completa el resto, de modo
que la lista se obtiene en el orden pedido sin transportar ningún resultado
parcial.

Con acumulador, la lista se obtendría en orden inverso —de 1 a N—, y sería
necesario invertirla al final. El ejemplo muestra que el acumulador no es
siempre la mejor alternativa: resulta adecuado cuando se acumula un valor, y
menos adecuado cuando se construye una lista que ya se obtiene en el orden
requerido.

## 11

```prolog
?- X is 5 + 3.
X = 8.

?- 8 is 5 + 3.
true.

?- 9 is 5 + 3.
false.

?- X is 5 + dos.
ERROR: Arithmetic: `dos/0' is not a function

?- X = 5 + 3.
X = 5+3.
```

`X is 5 + Y.` produce el otro error, el de argumentos sin instanciar.

Las tres primeras muestran que `is/2` **evalúa y después unifica**: con una
variable libre la unificación siempre se cumple; con un número, se cumple o no
según el valor; y el resultado de esa unificación es la respuesta del objetivo.

Los dos errores pertenecen a las dos clases de la sección 8.3: `dos` no es un
número y nunca lo será —hay que corregir el programa—; `Y` no tiene valor pero
podría tenerlo —hay que corregir el orden de los objetivos—.

La última no usa `is/2` y por eso no evalúa nada: construye el término.

## 12

La causa es la de la sección 8.3: al pasar de `s(s(0))` a los números
predefinidos se pierde la garantía de terminación que daba la unificación con la
estructura. El predicado tiene caso base y el caso recursivo avanza, pero nada
impide que siga avanzando **más allá** de `N`: después de alcanzar `N` con la
primera cláusula, el backtracking entra en la segunda y cuenta `N+1`, `N+2`, sin
fin.

Se corrige reponiendo a mano la condición que antes daba la estructura:

<!-- ejemplo: capitulo-08/soluciones.pl predicado: hasta/2 consulta: hasta(3, 1). -->
```prolog
% hasta(N, X): X recorre los enteros de X a N. Con los números predefinidos, la
% unificación ya no garantiza la terminación, y hay que reponer la guarda X < N
% que en s(s(0)) daba la estructura del término.
hasta(N, N).
hasta(N, X) :-
    X < N,
    Siguiente is X + 1,
    hasta(N, Siguiente).
```

La guarda `X < N` es exactamente lo que `s(N)` aportaba sin escribirlo: un
límite que la recursión no puede atravesar.

## 13

| Consulta | Resultado |
|---|---|
| `promedio([2, 4], P).` | `P = 3` |
| `promedio([2, 4], 3).` | `true` |
| `promedio([2, 4], 5).` | `false.` |
| `promedio(L, 3).` | **error** de argumentos sin instanciar |
| `promedio([], P).` | `false.` |

Las tres primeras funcionan porque el recorrido se hace sobre la lista, que está
completa; el segundo argumento solo participa de la unificación final, de modo
que da lo mismo que llegue con valor o sin él.

La cuarta falla porque el recorrido no tiene por dónde avanzar: `recorriendo/5`
intenta `SumaAhora is SumaHasta + X` con `X` sin valor. Es el error que el
predicado **debería** documentar en su comentario: la lista tiene que llegar
completa.

La quinta responde `false.` y no da error, por la condición `Cuantos > 0`: es la
decisión de diseño que evita dividir por cero, y hace que el promedio de la
lista vacía simplemente no exista.

## 14

<!-- ejemplo: capitulo-08/soluciones.pl predicado: suma_hasta_sin/2 suma_hasta_con/2 sumando_hasta/3 consulta: suma_hasta_con(5, S). -->
```prolog
% suma_hasta_sin(N, S): la suma de 1 a N, sin acumulador.
suma_hasta_sin(0, 0).
suma_hasta_sin(N, S) :-
    N > 0,
    Anterior is N - 1,
    suma_hasta_sin(Anterior, SumaAnterior),
    S is SumaAnterior + N.

% suma_hasta_con(N, S): la misma suma, con acumulador.
suma_hasta_con(N, S) :-
    sumando_hasta(N, 0, S).

sumando_hasta(0, Acumulado, Acumulado).
sumando_hasta(N, Hasta, S) :-
    N > 0,
    Ahora is Hasta + N,
    Anterior is N - 1,
    sumando_hasta(Anterior, Ahora, S).
```

Ninguna de las dos responde `suma_hasta(N, 6).`, y la razón es la misma en los
dos casos: las dos empiezan comparando `N` con `0` o evaluando `N > 0`, y `N` no
tiene valor. El error aparece antes de llegar a cualquier suma.

La pregunta del ejercicio sugiere que alguna de las dos podría hacerlo, y
conviene ver por qué no. Ninguna de las dos versiones **enumera** valores de
`N`: las dos lo reciben. Para responder en ese sentido habría que agregar un
objetivo que genere candidatos antes de la comparación, que es la plantilla 15
del capítulo 9, o usar la técnica del capítulo 32.

## 15

```prolog
test(maximo_de_varios, all(M == [9])) :-
    maximo([3, 9, 4], M).

test(maximo_de_uno, all(M == [7])) :-
    maximo([7], M).

test(la_lista_vacia_no_tiene_maximo, [fail]) :-
    maximo([], _).
```

La tercera prueba es la que vale la pena escribir, porque **documenta una
decisión**. `maximo/2` podría haberse definido de otra manera —dando error, o
devolviendo un valor convenido—, y la prueba deja registrado que la decisión
tomada fue que falle. Quien lea el programa más adelante no tiene que deducirla
del código: está escrita y se verifica sola.
