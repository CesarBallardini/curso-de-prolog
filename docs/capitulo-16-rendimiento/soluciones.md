# Soluciones del capítulo 16 — Rendimiento

El código de esta página está en `ejemplos/capitulo-16/soluciones.pl` y, el
del ejercicio 12, en `soluciones_proyecto.pl`; los dos pasan sus pruebas. Los segundos que figuran aquí son los de una ejecución en particular;
las inferencias son las que se repiten en cualquier máquina.

## 1

Se repetiría la cantidad de inferencias, 501 642: depende del programa, de los
datos y de la versión de SWI-Prolog, no de la máquina. El tiempo de procesador,
el tiempo total, el porcentaje de uso y las *Lips* dependen de la máquina y de lo
que esté haciendo en ese momento, y cambian incluso entre dos ejecuciones en la
misma. Por eso las pruebas comparan inferencias: una prueba basada en segundos
fallaría en una máquina más lenta o cargada sin que el programa haya cambiado.

## 2

| Predicado | ¿Espacio constante? | Por qué |
|---|---|---|
| `largo/2` | no | la suma se hace después de la llamada recursiva |
| `largo_acc/2` | sí | la llamada recursiva es el último objetivo, sin alternativas |
| `suma_lista/2` ([capítulo 8](../capitulo-08-aritmetica/index.md)) | no | como `largo/2`: `is` después de la llamada |
| `suma_con_acumulador/2` ([capítulo 8](../capitulo-08-aritmetica/index.md)) | sí | acumulador; la llamada es lo último |
| `pegar/3` ([capítulo 7](../capitulo-07-listas/index.md)) | sí | la llamada recursiva es el único objetivo del cuerpo, y el resultado se construye en la cabeza |

`pegar/3` no tiene acumulador y aun así corre en espacio constante: la condición
no es tener un acumulador, sino que no quede nada por hacer después de la
llamada recursiva. La plantilla 12 construye el resultado en la cabeza, antes de
la llamada.

## 3

<!-- ejemplo: capitulo-16/soluciones.pl predicado: suma_lista_acc/2 sumando/3 consulta: suma_lista_acc([3, 1, 4], S). -->
```prolog
%!  suma_lista_acc(+L:list(number), -S:number) is det.
%
%   S es la suma de los números de L, con un acumulador: la llamada recursiva
%   es el último objetivo, y la pila no crece con el largo de la lista.
suma_lista_acc(L, S) :-
    sumando(L, 0, S).

%!  sumando(+L:list(number), +Hasta:number, -S:number) is det.
%
%   S es Hasta más la suma de los números de L.
sumando([], S, S).
sumando([X|Resto], Hasta, S) :-
    Ahora is Hasta + X,
    sumando(Resto, Ahora, S).
```

Con `swipl --stack-limit=64m` y una lista de un millón de números,
`suma_lista_acc/2` responde, y `suma_lista/2` del [capítulo 8](../capitulo-08-aritmetica/index.md) se detiene con
*Stack limit (64.0Mb) exceeded* y `last-call: 0%` en el mensaje, como `largo/2`
en la sección 16.2.

## 4

El acumulador es el primer argumento: en las dos cláusulas es un número, y la
tabla del primer argumento no las distingue. Al llegar a la lista vacía, la
primera cláusula responde y la segunda queda pendiente: `contar(0, [a, b, c], N)`
responde `N = 3 ;` y después `false.` SWI-Prolog construye a pedido una tabla
para el segundo argumento, y por eso las alternativas no se acumulan en cada
paso; queda solo la del final, que alcanza para que el predicado no cumpla su
`det`.

<!-- ejemplo: capitulo-16/soluciones.pl predicado: contar_bien/2 contar_desde/3 consulta: contar_bien([a, b, c], N). -->
```prolog
%!  contar_bien(+L:list, -N:integer) is det.
%
%   N es la cantidad de elementos de L. La lista es el primer argumento del
%   auxiliar, que se distingue en [] y [_|_].
contar_bien(L, N) :-
    contar_desde(L, 0, N).

%!  contar_desde(+L:list, +Hasta:integer, -N:integer) is det.
%
%   N es Hasta más la cantidad de elementos de L.
contar_desde([], N, N).
contar_desde([_|Resto], Hasta, N) :-
    Ahora is Hasta + 1,
    contar_desde(Resto, Ahora, N).
```

Con la lista primero, `contar_bien([a, b, c], N)` responde `N = 3.`, y su prueba
no declara `nondet`.

## 5

<!-- ejemplo: capitulo-16/soluciones.pl predicado: esta_en/2 todos_estan_corte/2 consulta: todos_estan_corte([a, b], [a, b, c]). -->
```prolog
%!  esta_en(?X, ?L:list) is nondet.
%
%   X es uno de los elementos de L.
esta_en(X, [X|_]).
esta_en(X, [_|Resto]) :-
    esta_en(X, Resto).

%!  todos_estan_corte(+Buscados:list, +L:list) is semidet.
%
%   Todos los elementos de Buscados están en L. El corte descarta las demás
%   apariciones de X en L: alcanza con encontrarlo una vez.
todos_estan_corte([], _).
todos_estan_corte([X|Resto], L) :-
    esta_en(X, L),
    !,
    todos_estan_corte(Resto, L).
```

Con 300 000 elementos buscados, `todos_estan_corte/2` no ocupa memoria adicional,
contra los 131 MB de `todos_estan/2`. El corte es **verde**: el conjunto de
respuestas es el mismo —la relación se cumple o no—, y lo que desaparece son las
repeticiones que `todos_estan/2` producía cuando un elemento aparecía varias
veces en la lista. Es la misma solución que `memberchk/2`, escrita a mano.

## 6

La versión lenta recorre las inscripciones de la materia: si con 500 alumnos
usaba unas 750 inferencias y con 5 000 unas 7 500, con 50 000 debería usar unas
75 000. La rápida no depende de la cantidad de alumnos: 7.

```prolog
?- generar(50000), comparar(alumno_25000, bd).
```

```text
aprobada_lenta: 75,006 inferencias
aprobada_rapida: 7 inferencias
```

La predicción se cumple: el costo de la lenta crece en proporción a los datos,
y el de la rápida es constante.

## 7

<!-- ejemplo: capitulo-16/soluciones.pl predicado: aplanar_izq/2 aplanando/3 aplanar_der/2 consulta: aplanar_der([[a, b], [c], [d, e]], L). -->
```prolog
%!  aplanar_izq(+Listas:list(list), -L:list) is det.
%
%   L es la concatenación de las listas de Listas. Acumula por la izquierda:
%   cada append/3 recorre todo lo acumulado.
aplanar_izq(Listas, L) :-
    aplanando(Listas, [], L).

%!  aplanando(+Listas:list(list), +Hasta:list, -L:list) is det.
%
%   L es Hasta seguida de la concatenación de Listas.
aplanando([], L, L).
aplanando([X|Resto], Hasta, L) :-
    append(Hasta, X, Ahora),
    aplanando(Resto, Ahora, L).

%!  aplanar_der(+Listas:list(list), -L:list) is det.
%
%   La misma relación, pegando cada lista delante del resto ya aplanado: cada
%   append/3 recorre solo la lista que agrega.
aplanar_der([], []).
aplanar_der([X|Resto], L) :-
    aplanar_der(Resto, RestoAplanado),
    append(X, RestoAplanado, L).
```

Con mil listas de diez elementos, `aplanar_izq/2` usa unas 5 000 000 de
inferencias y `aplanar_der/2` unas 12 000. `append/3` recorre solo su **primer**
argumento. La versión de la izquierda pasa como primer argumento todo lo
acumulado, que crece en cada paso; la de la derecha pasa la lista que agrega,
que siempre tiene diez elementos. Las dos usan `append/3` en cada paso: lo que
cuesta no es `append/3`, sino qué lista recibe primero.

## 8

La alternativa que deja `ultimo/2` aparece recién en la última llamada, cuando
la lista tiene un solo elemento. Mientras la recursión avanza, cada llamada
elige una sola cláusula —la de la lista con más de un elemento—, no queda nada
pendiente, y la optimización de la última llamada descarta la llamada anterior.

`todos_estan/2` deja una alternativa en **cada** paso: `esta_en/2` encuentra el
elemento y queda pendiente la búsqueda en el resto. Con una alternativa
pendiente, la llamada no se puede descartar, porque al volver atrás habría que
retomarla. Las llamadas se acumulan, una por elemento, y con ellas la memoria.

## 9

Con `dar_vuelta/2` y 3 000 elementos, el perfil está dominado por `append/3`,
llamado 3 000 veces, y por la recolección de memoria que producen las listas
intermedias. Con `dar_vuelta_acc/2` y un millón de elementos, el perfil muestra
`dando_vuelta/3` con **una** entrada y la totalidad del tiempo medido, unas
decenas de milisegundos: la optimización de la última llamada reutiliza la
misma llamada para todo el recorrido, y el profiler, que cuenta entradas a
predicados, ve una sola.

## 10

Con 1 000 elementos, `dar_vuelta/2` usa unas 501 000 inferencias, casi todas de
`append/3`, que recorre en total 1 + 2 + … + 1 000 elementos: la mitad de 1 000
por 1 000. Con el doble de elementos, esa suma se multiplica por cuatro: unas
2 000 000. Con `pila.pl` cargado:

```prolog
?- numlist(1, 2000, L), inferencias(dar_vuelta(L, _), I).
```

```text
I = 2003147.
```

## 11

Porque SWI-Prolog, además de la tabla del primer argumento, construye tablas
para otros argumentos la primera vez que una consulta las necesita. `edad(P, 41)`
llega con el segundo argumento ligado y el primero libre; SWI-Prolog construye
una tabla para el segundo argumento y la usa desde entonces. Esa indexación a
pedido (*just-in-time*) es propia de SWI-Prolog; otros sistemas indexan solo el
primer argumento.

## 12

La prueba genera 5 000 alumnos, mide la consulta por nombre y acota sus
inferencias. Con el orden correcto usa menos de 20; con el orden invertido,
unas 7 500:

<!-- ejemplo: capitulo-16/soluciones_proyecto.plt fragmento: % Ejercicio 12 .. inferencias(aprobada_por_nombre(alumno_2500, _), I). -->
```prolog
% Ejercicio 12: la prueba que protege el orden de aprobada_por_nombre/2. Con
% el orden invertido, la consulta usaría unas 7 500 inferencias.
test(aprobada_por_nombre_no_recorre_todo, true(I < 50)) :-
    generar(5000),
    inferencias(aprobada_por_nombre(alumno_2500, _), I).
```

La cota, 50, deja margen para las variaciones del conteo según el contexto de
la llamada y queda dos órdenes de magnitud por debajo de lo que costaría el
orden invertido: la prueba no falla por azar y sí falla si alguien invierte
los objetivos. Los datos del proyecto, siete alumnos, no alcanzan: con ellos
las dos versiones cuestan lo mismo. Por eso `soluciones_proyecto.pl` carga
`generar_datos.pl`, que genera los datos y define `inferencias/2`, y solo
agrega la versión del proyecto de `aprobada_por_nombre/2`.

## 13

No. Las vacantes son la condición más barata —un solo hecho—, pero el orden de
las ramas determina **qué motivo** informa el predicado. Con las vacantes
primero, ana (101) pidiendo lógica, que ya aprobó, recibiría
`rechazada(sin_vacantes)` en lugar de `rechazada(ya_aprobada)`, y un alumno sin
los requisitos de una materia llena no sabría que tampoco podría cursarla con
lugar. El orden de las condiciones es parte de la especificación del predicado.

El ahorro, además, sería mínimo: cada condición cuesta unas pocas inferencias,
y la de los requisitos recorre las correlativas de una sola materia. Es el caso
que el [Patrón 10](../patrones.md#10-medir-antes-de-cambiar) anticipa: sin una medición que muestre que pesa, la
optimización no justifica cambiar el comportamiento.

## 14

No deja alternativas: `no_aprobados/3` tiene la lista como primer argumento
(la corrección de la [solución 11 del capítulo 15](../capitulo-15-control/soluciones.md#11)), y el condicional elige una
rama sin dejar la otra pendiente; su prueba no declara `nondet`. La pila no
crece: la llamada recursiva es el último objetivo de la segunda cláusula,
después del condicional, y no quedan alternativas. Con la cantidad de
requisitos de una materia, unos pocos, no haría diferencia; con una lista larga,
la haría.
