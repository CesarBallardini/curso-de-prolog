# Capítulo 20 — Base de datos dinámica

Todos los programas del curso, hasta aquí, tienen un contenido fijo: los hechos
y las reglas que se cargan son los que el programa usa hasta terminar. Muchos
programas reales necesitan recordar algo entre una consulta y la siguiente: una
inscripción nueva, un contador de operaciones, un resultado que costó calcular,
lo que un agente ya observó. Prolog permite agregar y quitar cláusulas durante
la ejecución, y con eso el programa guarda un **estado**.

Este capítulo presenta los predicados dinámicos y las operaciones que los
modifican, la regla que decide qué ve una consulta cuando la base cambia
mientras se ejecuta, los contadores y las variables globales, y tres usos del
estado: memorizar resultados, un sistema experto que razona hacia adelante y
el agente del mundo del Wumpus. El estado tiene un costo —las respuestas de un
predicado dejan de depender solo de sus argumentos— y el capítulo dice también
cuándo no conviene usarlo. El proyecto inscribe y da de baja alumnos durante la
ejecución.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- declarar un predicado dinámico y modificarlo con `assertz/1`, `asserta/1`,
  `retract/1` y `retractall/1`;
- predecir qué ve una consulta cuando la base cambia durante su ejecución;
- llevar un contador, y elegir entre un hecho dinámico, `flag/3` y una variable
  global;
- memorizar resultados y construir una base de conocimiento que crece hasta un
  punto fijo;
- esconder el estado detrás de unos pocos predicados, y escribir pruebas que
  dejan la base como la encontraron.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:23 h**.
    Resolver los 7 ejercicios marcados con ★: **2:11 h**.
    Resolver los 15 ejercicios del final: **4:57 h**.

## 20.1 `:- dynamic`

Un predicado es **dinámico** cuando el programa puede agregarle o quitarle
cláusulas durante la ejecución. Se declara con la directiva `dynamic`, antes de
sus cláusulas:

<!-- ejemplo: capitulo-20/dinamica.pl fragmento: :- dynamic padre/2 .. % visita(P, Q) consulta: nace(sofia, pedro), padre(pedro, Hijo). -->
```prolog
:- dynamic padre/2, edad/2, visita/2, numero/1.

% padre(P, H): P es el padre de H.
padre(juan, ana).
padre(juan, pedro).
padre(pedro, luis).
padre(pedro, eva).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

% visita(P, Q): P visita a Q. Ningún hecho todavía.
```

Un predicado dinámico puede empezar con hechos, como `padre/2` y `edad/2`, o sin
ninguno, como `visita/2`. La declaración tiene un segundo efecto: un predicado
dinámico sin cláusulas **falla**, mientras que uno que no está definido produce
un error.

```prolog
?- visita(ana, X).
false.
```

La consulta `vive_en(ana, X)`, con un predicado que el programa no define,
responde:

```text
ERROR: Unknown procedure: vive_en/2 (DWIM could not correct goal)
```

La diferencia es la del [capítulo 13](../capitulo-13-el-entorno-de-trabajo/index.md), donde `check/0` advertía sobre un
predicado sin definir: el error protege de un nombre mal escrito. Declararlo
dinámico le dice a Prolog que el predicado existe aunque todavía no tenga
hechos, y que la consulta sin respuestas es legítima.

## 20.2 `assertz/1`, `asserta/1`, `retract/1`, `retractall/1`

Cuatro predicados modifican la base:

- `assertz(Clausula)` agrega la cláusula **al final** del predicado;
- `asserta(Clausula)` la agrega **al principio**;
- `retract(Clausula)` quita la primera cláusula que unifica con la dada, y al
  volver atrás quita la siguiente;
- `retractall(Cabeza)` quita todas las cláusulas cuya cabeza unifica con la
  dada, y se cumple aunque no haya ninguna.

<!-- ejemplo: capitulo-20/dinamica.pl predicado: nace/2 cumple_anios/1 olvidar/1 consulta: cumple_anios(eva), edad(eva, Edad). -->
```prolog
%!  nace(+Hijo, +Padre) is det.
%
%   Registra el nacimiento de Hijo, hijo de Padre, con edad 0.
nace(Hijo, Padre) :-
    assertz(padre(Padre, Hijo)),
    assertz(edad(Hijo, 0)).

%!  cumple_anios(+P) is semidet.
%
%   P cumple un año más: su edad se reemplaza por la siguiente. Falla si P no
%   tiene edad registrada.
cumple_anios(P) :-
    retract(edad(P, E)),
    E1 is E + 1,
    assertz(edad(P, E1)).

%!  olvidar(+P) is det.
%
%   Quita todo lo que la base registra de P: su edad y sus relaciones.
olvidar(P) :-
    retractall(edad(P, _)),
    retractall(padre(P, _)),
    retractall(padre(_, P)).
```

```prolog
?- nace(sofia, pedro), padre(pedro, Hijo).
Hijo = luis ;
Hijo = eva ;
Hijo = sofia.

?- cumple_anios(eva), edad(eva, Edad).
Edad = 9.

?- assertz(padre(juan, x)), asserta(padre(ana, y)), findall(P-H, padre(P, H), L).
L = [ana-y, juan-ana, juan-pedro, pedro-luis, pedro-eva, juan-x].
```

`cumple_anios/1` es la forma habitual de **cambiar** un hecho: `retract/1`
quita el valor anterior y lo liga en su argumento, y `assertz/1` agrega el
nuevo. Entre las dos operaciones el hecho no existe; un programa con varios
hilos necesita más cuidado, y el [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md) lo trata. `olvidar/1` usa
`retractall/1`, que no falla aunque no haya nada que quitar.

Los cambios no forman parte del archivo: al terminar la sesión se pierden, y
recargar el archivo con `make.` restituye los hechos que tiene escritos, como
advertía el Patrón 1. El [capítulo 16](../capitulo-16-rendimiento/index.md) ya usó `assertz/1` para generar datos
de prueba: 5 000 alumnos que no estaban en ningún archivo.

## 20.3 La vista lógica de actualización

Si un objetivo recorre las cláusulas de un predicado mientras otro las
modifica, ¿qué cláusulas ve? SWI-Prolog, como el estándar ISO, aplica la
**vista lógica de actualización**: una llamada ve las cláusulas que había
**cuando empezó**, sin importar lo que se agregue o se quite después.

<!-- ejemplo: capitulo-20/dinamica.pl predicado: multiplicar_por_diez/0 consulta: multiplicar_por_diez, findall(N, numero(N), L). -->
```prolog
%!  multiplicar_por_diez is det.
%
%   Agrega el décuplo de cada número que había al empezar. La vista lógica
%   de actualización hace que el recorrido no vea los números que agrega.
multiplicar_por_diez :-
    forall(numero(N),
           ( M is N * 10,
             assertz(numero(M)) )).
```

```prolog
?- multiplicar_por_diez, findall(N, numero(N), L).
L = [1, 2, 10, 20].
```

`forall(numero(N), …)` empezó con dos números, 1 y 2, y ve solo esos dos,
aunque el cuerpo agrega 10 y 20. Sin esa regla, el recorrido encontraría el 10,
agregaría el 100, y no terminaría nunca. La llamada siguiente, el `findall/3`,
empieza después, y ve los cuatro.

!!! question "Actividad"
    Predecir el contenido de `numero/1` después de
    `forall(numero(N), retract(numero(N)))` y después de
    `forall(numero(N), assertz(numero(N)))`. ¿Termina la segunda? Comprobarlo.

## 20.4 Contadores y estado global

Un contador es el estado más simple: un número que cambia en cada operación.
Hay tres formas de llevarlo, con propiedades distintas.

**Un hecho dinámico.** `contador/1` guarda el valor; cambiarlo es retirar el
anterior y agregar el nuevo. Es la forma general: se ve con `listing/1`, se
puede guardar en un archivo, y funciona en SWISH.

**`flag/3`.** `flag(Clave, Anterior, Nuevo)` lee el valor asociado a `Clave` y
lo reemplaza por el resultado de evaluar `Nuevo`, en un solo paso. Solo admite
números y átomos, y es más rápido que un hecho dinámico.

**Variables globales.** `b_setval(Clave, Valor)` y `nb_setval(Clave, Valor)`
asocian un término a una clave, y `b_getval/2` y `nb_getval/2` lo leen. La
diferencia está en el retroceso: el valor de `b_setval/2` se deshace al volver
atrás, como la ligadura de una variable; el de `nb_setval/2` permanece.

<!-- ejemplo: capitulo-20/contadores.pl predicado: siguiente_con_hecho/1 siguiente_numero/1 global_con_retroceso/1 global_sin_retroceso/1 consulta: global_con_retroceso(X), global_sin_retroceso(Y). -->
```prolog
%!  siguiente_con_hecho(-N:integer) is det.
%
%   N es el número siguiente al último entregado. El estado es un hecho
%   dinámico: se retira el valor anterior y se agrega el nuevo.
siguiente_con_hecho(N) :-
    retract(contador(N0)),
    N is N0 + 1,
    assertz(contador(N)).

%!  siguiente_numero(-N:integer) is det.
%
%   N es el número siguiente al último entregado. El estado es la bandera
%   numero, que flag/3 lee y reemplaza en un solo paso.
siguiente_numero(N) :-
    flag(numero, N0, N0 + 1),
    N is N0 + 1.

%!  global_con_retroceso(-X) is det.
%
%   X es el valor de la variable global v después de un intento fallido de
%   cambiarlo: b_setval/2 se deshace al retroceder, y X es 1.
global_con_retroceso(X) :-
    b_setval(v, 1),
    (   b_setval(v, 2),
        fail
    ;   b_getval(v, X)
    ).

%!  global_sin_retroceso(-X) is det.
%
%   Lo mismo con nb_setval/2, que no se deshace al retroceder: X es 2.
global_sin_retroceso(X) :-
    nb_setval(v, 1),
    (   nb_setval(v, 2),
        fail
    ;   nb_getval(v, X)
    ).
```

```prolog
?- siguiente_numero(A), siguiente_numero(B).
A = 1,
B = 2.

?- global_con_retroceso(X), global_sin_retroceso(Y).
X = 1,
Y = 2.
```

Las variables globales tienen limitaciones propias:

- leer una clave que nunca se asignó produce un error, no una falla;
- `nb_setval/2` guarda una **copia** del término: si el valor tiene variables,
  ligarlas después no cambia lo guardado;
- son del hilo que las asigna ([capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md)), no se ven con `listing/1`, y
  no se pueden guardar en un archivo;
- el sandbox de SWISH no permite ni `flag/3` ni las variables globales: este
  ejemplo es solo local.

Contar las respuestas de un objetivo con una variable global y un bucle por
falla funciona, pero el [capítulo 17](../capitulo-17-todas-las-soluciones/index.md) ya tiene la herramienta sin estado:
`aggregate_all(count, Objetivo, N)`. El estado global se justifica cuando el
valor debe sobrevivir entre consultas, no para calcular un resultado dentro de
una.

## 20.5 Memorización

Algunas relaciones recalculan los mismos valores muchas veces. `fib/2`, la
sucesión de Fibonacci, calcula `fib(N)` a partir de `fib(N-1)` y `fib(N-2)`, y
cada uno de esos vuelve a calcular los anteriores:

<!-- ejemplo: capitulo-20/memo.pl predicado: fib/2 fib_memo/2 olvidar_fib/0 consulta: fib_memo(25, F). -->
```prolog
%!  fib(+N:integer, -F:integer) is det.
%
%   F es el N-ésimo número de Fibonacci: fib(0) = 0, fib(1) = 1, y cada uno
%   de los siguientes es la suma de los dos anteriores.
fib(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib(N1, F1),
        fib(N2, F2),
        F is F1 + F2
    ).

%!  fib_memo(+N:integer, -F:integer) is det.
%
%   La misma relación que fib/2. Cada valor calculado se guarda en
%   fib_guardado/2, y se busca allí antes de calcularlo.
fib_memo(N, F) :-
    (   fib_guardado(N, F0)
    ->  F = F0
    ;   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib_memo(N1, F1),
        fib_memo(N2, F2),
        F0 is F1 + F2,
        assertz(fib_guardado(N, F0)),
        F = F0
    ).

%!  olvidar_fib is det.
%
%   Borra los valores guardados por fib_memo/2.
olvidar_fib :-
    retractall(fib_guardado(_, _)).
```

`fib_memo/2` busca primero el valor en `fib_guardado/2`; si no está, lo calcula
y lo guarda. Cada valor se calcula una sola vez:

```text
?- time(fib(25, F)).
% 728,353 inferences, 0.016 CPU in 0.027 seconds (58% CPU, 46614592 Lips)
F = 75025.

?- olvidar_fib, time(fib_memo(25, F)).
% 222 inferences, 0.000 CPU in 0.000 seconds (0% CPU, Infinite Lips)
F = 75025.
```

Con 25, la versión que memoriza usa unas 3 000 veces menos inferencias, y la
diferencia crece con N: la primera es exponencial, la segunda lineal. Una
segunda llamada a `fib_memo(25, F)` encuentra el valor guardado y usa menos de
diez inferencias.

La tabla guardada es estado, con dos consecuencias. Las pruebas deben
empezar y terminar sin valores guardados —`setup(olvidar_fib)` y
`cleanup(olvidar_fib)` en `memo.plt`—, o una prueba mediría el trabajo que hizo
otra. Y un valor guardado solo es correcto mientras no cambie nada de lo que se
usó para calcularlo: `fib/2` no depende de ningún dato, y por eso su tabla
nunca queda vieja.

SWI-Prolog ofrece la misma técnica sin escribir el estado a mano: con la
directiva `:- table fib/2.`, la **tabulación** guarda las respuestas
automáticamente. El [capítulo 39](../capitulo-39-tabulacion/index.md) la presenta.

!!! example "Patrón 17 — Memorización con `assertz`"
    **Problema.** Un cálculo costoso se repite con los mismos argumentos.

    **Versión ingenua.** Recalcularlo cada vez, o guardar los resultados en un
    argumento que se pasa por todo el programa.

    **Patrón.** Un predicado dinámico con los resultados; el predicado busca
    primero allí, y si no encuentra, calcula y guarda con `assertz/1`. Un
    predicado que borra la tabla, para las pruebas y para cuando los datos
    cambian.

    **Cuándo no usarlo.** Cuando el resultado depende de datos que cambian
    durante la ejecución y no hay un punto claro donde invalidar lo guardado; y
    cuando `:- table` resuelve lo mismo ([capítulo 39](../capitulo-39-tabulacion/index.md)).

## 20.6 Un sistema experto con encadenamiento hacia adelante

El sistema experto del [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) razona hacia atrás: parte de una
conclusión y busca las reglas que la prueban. El **encadenamiento hacia
adelante** hace el camino inverso: parte de los hechos conocidos, aplica todas
las reglas que se puedan aplicar, agrega sus conclusiones como hechos nuevos, y
repite hasta que ninguna regla agrega nada. La base de conocimiento **crece**, y
por eso sus hechos son dinámicos.

<!-- ejemplo: capitulo-20/experto_adelante.pl fragmento: regla(Nombre, Condiciones .. antepasado(H, D)], antepasado(A, D)). consulta: reiniciar, encadenar, hecho(abuelo(juan, N)). -->
```prolog
% regla(Nombre, Condiciones, Conclusion): si se cumplen todas las
% Condiciones, Conclusion es un hecho.
regla(progenitor_p, [padre(P, H)],                   progenitor(P, H)).
regla(progenitor_m, [madre(M, H)],                   progenitor(M, H)).
regla(abuelo,       [padre(A, P), progenitor(P, N)], abuelo(A, N)).
regla(hermanos,     [progenitor(P, A), progenitor(P, B), A \== B],
                                                     hermanos(A, B)).
regla(antepasado_1, [progenitor(A, D)],              antepasado(A, D)).
regla(antepasado_2, [progenitor(A, H), antepasado(H, D)], antepasado(A, D)).
```

Los hechos iniciales, en `inicial/1`, son los de la familia: padres y madres.
Las reglas son datos, como en el [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md), con las condiciones en una lista.
`hermanos` tiene una condición que no es un hecho, `A \== B`, que el
intérprete evalúa con su propia cláusula:

<!-- ejemplo: capitulo-20/experto_adelante.pl predicado: reiniciar/0 encadenar/0 se_cumple/1 consulta: reiniciar, encadenar, hecho(abuelo(juan, N)). -->
```prolog
%!  reiniciar is det.
%
%   Deja en la base solo los hechos iniciales.
reiniciar :-
    retractall(hecho(_)),
    retractall(derivado(_, _, _)),
    forall(inicial(F), assertz(hecho(F))).

%!  encadenar is det.
%
%   Agrega a la base las conclusiones de las reglas, de a una, hasta que
%   ninguna regla produce un hecho nuevo.
encadenar :-
    (   regla(Nombre, Condiciones, Conclusion),
        maplist(se_cumple, Condiciones),
        \+ hecho(Conclusion)
    ->  assertz(hecho(Conclusion)),
        assertz(derivado(Conclusion, Nombre, Condiciones)),
        encadenar
    ;   true
    ).

%!  se_cumple(+Condicion) is nondet.
%
%   Condicion es un hecho de la base, o una comparación A \== B que se
%   cumple.
se_cumple(A \== B) :-
    A \== B.
se_cumple(Condicion) :-
    Condicion \= ( _ \== _ ),
    hecho(Condicion).
```

```prolog
?- reiniciar, encadenar, aggregate_all(count, hecho(_), N).
N = 34.

?- reiniciar, encadenar, hecho(abuelo(juan, N)).
N = sofia ;
N = luis ;
N = eva.

?- reiniciar, encadenar, derivado(abuelo(juan, sofia), Regla, Condiciones).
Regla = abuelo,
Condiciones = [padre(juan, ana), progenitor(ana, sofia)].
```

`encadenar/0` busca una regla cuyas condiciones se cumplen —`maplist/2` sobre
la lista— y cuya conclusión todavía no es un hecho; `\+ hecho(Conclusion)` es
lo que garantiza que termina, porque cada paso agrega un hecho nuevo y los
hechos posibles son finitos. Cuando no hay ninguna, la base llegó a su **punto
fijo**: de los 7 hechos iniciales a 34. `derivado/3` guarda, para cada hecho
agregado, la regla y las condiciones ya ligadas: la explicación de cómo se
obtuvo.

Las dos estrategias responden preguntas distintas. Hacia atrás conviene cuando
hay una pregunta concreta —¿es un guepardo?— y muchas conclusiones posibles que
no interesan. Hacia adelante conviene cuando interesan **todas** las
consecuencias de los datos, o cuando los datos llegan de a poco y cada uno
puede disparar conclusiones nuevas.

!!! example "Patrón 18 — Base de conocimiento que crece"
    **Problema.** Hay que obtener todas las consecuencias de un conjunto de
    hechos y reglas, y conservarlas para consultarlas después.

    **Versión ingenua.** Probar cada conclusión posible hacia atrás, cada vez
    que se la consulta, repitiendo las mismas pruebas.

    **Patrón.** Los hechos en un predicado dinámico; un paso que agrega una
    conclusión nueva de una regla cuyas condiciones se cumplen, comprobando con
    `\+` que no estaba; repetir hasta el punto fijo. Registrar con cada hecho
    la regla que lo produjo.

    **Cuándo no usarlo.** Cuando solo interesan unas pocas conclusiones de
    muchas posibles: el encadenamiento hacia atrás, o las reglas de Prolog,
    calculan solo lo que se pregunta.

## 20.7 El agente del mundo del Wumpus

El mundo del Wumpus es un problema clásico de la inteligencia artificial, del
libro de Russell y Norvig. Una cueva de 4 × 4 celdas tiene pozos, un monstruo
—el wumpus— y oro. El agente entra por la celda (1, 1) sin conocer la
ubicación de cada cosa; solo percibe **brisa** en las celdas vecinas de un
pozo, **hedor** en las vecinas del wumpus y **brillo** en la del oro. Tiene que encontrar el oro
sin entrar nunca en una celda peligrosa.

La cueva está en el archivo como hechos (`pozo/1`, `wumpus/1`, `oro/1`), pero el
agente no los consulta: solo usa `percepcion/2`, que dice qué se percibe en una
celda. Lo que el agente **conoce** es estado, y crece a medida que explora:

<!-- ejemplo: capitulo-20/wumpus.pl predicado: reiniciar/0 visitar/1 sin_pozo/1 sin_wumpus/1 segura/1 consulta: explorar(Resultado), recorrido(Celdas). -->
```prolog
%!  reiniciar is det.
%
%   Borra el conocimiento del agente: ninguna celda visitada, ninguna
%   percepción.
reiniciar :-
    retractall(visitada(_)),
    retractall(percibio(_, _)).

%!  visitar(+C) is det.
%
%   El agente entra en la celda C y registra lo que percibe allí.
visitar(C) :-
    assertz(visitada(C)),
    forall(percepcion(C, P), assertz(percibio(C, P))).

%!  sin_pozo(+C) is semidet.
%
%   Está probado que C no tiene pozo: alguna vecina visitada no tuvo brisa.
sin_pozo(C) :-
    once(( vecina(C, V),
           visitada(V),
           \+ percibio(V, brisa) )).

%!  sin_wumpus(+C) is semidet.
%
%   Está probado que el wumpus no está en C: alguna vecina visitada no
%   tuvo hedor.
sin_wumpus(C) :-
    once(( vecina(C, V),
           visitada(V),
           \+ percibio(V, hedor) )).

%!  segura(+C) is semidet.
%
%   C es segura: se visitó, o está probado que no tiene pozo ni wumpus.
segura(C) :-
    (   visitada(C)
    ->  true
    ;   sin_pozo(C),
        sin_wumpus(C)
    ).
```

Una celda no tiene pozo si alguna vecina visitada no tuvo brisa: si hubiera un
pozo, esa vecina lo habría percibido. Lo mismo con el wumpus y el hedor. Una
celda es segura cuando las dos cosas están probadas. `\+ percibio(V, brisa)` es
correcto aquí porque `V` está visitada: el agente registró todo lo que percibió
allí, y lo que no registró no estaba. Es la hipótesis de mundo cerrado del
[capítulo 10](../capitulo-10-negacion-como-falla/index.md), aplicada solo donde vale.

El agente repite un paso: si percibió el brillo, terminó; si no, visita la
primera celda segura sin visitar vecina de una visitada; si no queda ninguna,
se detiene.

<!-- ejemplo: capitulo-20/wumpus.pl predicado: explorar/1 explorar_/1 consulta: explorar(Resultado), recorrido(Celdas). -->
```prolog
%!  explorar(-Resultado) is det.
%
%   El agente explora la cueva desde (1, 1). Resultado es oro(C) si encuentra
%   el oro en C, o sin_celdas_seguras si no queda adónde ir.
explorar(Resultado) :-
    reiniciar,
    visitar(1-1),
    explorar_(Resultado).

%!  explorar_(-Resultado) is det.
%
%   Un paso de la exploración: termina si ya percibió el brillo, o visita la
%   siguiente celda segura y continúa.
explorar_(Resultado) :-
    (   percibio(C, brillo)
    ->  Resultado = oro(C)
    ;   siguiente(C)
    ->  visitar(C),
        explorar_(Resultado)
    ;   Resultado = sin_celdas_seguras
    ).
```

```prolog
?- explorar(Resultado), recorrido(Celdas).
Resultado = oro(2-3),
Celdas = [1-1, 2-1, 1-2, 2-2, 3-2, 2-3].
```

En (2, 1) percibe brisa y en (1, 2) hedor; ninguna de las dos permite avanzar
por sí sola. (2, 2) es segura por la combinación: (2, 1) no tuvo hedor, y
descarta el wumpus; (1, 2) no tuvo brisa, y descarta el pozo.

El estado del agente se modifica solo en `reiniciar/0` y `visitar/1`, y se
consulta con `segura/1` y `recorrido/1`. El resto del programa, y las pruebas,
no tocan `visitada/1` ni `percibio/2` directamente.

!!! example "Patrón 19 — Estado detrás de una interfaz"
    **Problema.** Un programa necesita estado, y cualquier parte que lo
    modifique puede dejarlo inconsistente.

    **Versión ingenua.** `assertz/1` y `retract/1` repartidos por el programa y
    por las pruebas, cada uno con su propia idea de qué hechos van juntos.

    **Patrón.** Los predicados dinámicos se modifican solo en unos pocos
    predicados con nombre —iniciar, registrar, reiniciar— que mantienen juntos
    los hechos relacionados; el resto consulta. Las pruebas usan esos mismos
    predicados para preparar el estado y para restaurarlo.

    **Cuándo no usarlo.** Cuando el estado se puede evitar: un valor que se
    calcula dentro de una consulta va en un argumento, no en la base.

## 20.8 Cuándo no usarla

El estado hace que un predicado responda distinto a la misma consulta según lo
que pasó antes. Eso tiene costos concretos:

- **Las pruebas dependen del orden.** Una prueba que agrega un hecho y no lo
  quita cambia el resultado de la siguiente. Cada prueba que modifica la base
  debe restaurarla en su `cleanup`.
- **Se pierde el retroceso.** Lo que agrega `assertz/1` no se deshace al volver
  atrás. Un programa que agrega hechos y después falla deja la base a medio
  modificar.
- **Se pierden los modos.** `cumple_anios/1` no tiene sentido con el argumento
  libre, ni en sentido inverso: una acción no es una relación.
- **Es más lento que un argumento.** Agregar y quitar una cláusula cuesta
  bastante más que pasar un valor.

La regla práctica: si el valor se calcula y se usa dentro de una misma
consulta, va en un argumento, como los acumuladores del
[capítulo 8](../capitulo-08-aritmetica/index.md). La base dinámica es para lo que debe sobrevivir entre consultas:
los datos que el usuario cargó, lo que el programa aprendió, lo que costó
calcular.

## 20.9 Reglas dinámicas y SWISH

`assertz/1` también agrega reglas: `assertz((abuelo(A, N) :- padre(A, P),
padre(P, N)))`, con la regla entre paréntesis. Localmente funciona, pero un
programa que escribe sus propias reglas es difícil de leer y de probar, y el
sandbox de SWISH no lo permite: acepta `assertz/1` de hechos, no de reglas.

La alternativa es la del [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) y la [sección 20.6](#206-un-sistema-experto-con-encadenamiento-hacia-adelante): las reglas como
**datos**, en hechos como `regla/3`, y un intérprete fijo que las aplica. Así
se pueden agregar reglas durante la ejecución —son hechos—, se pueden explicar,
y el programa corre en SWISH.

## 20.10 Persistir hechos

Lo que se agrega con `assertz/1` se pierde al terminar la sesión. `listing/1`
escribe las cláusulas actuales de un predicado en la forma en que se leen.
Después de `nace(sofia, pedro)`, `listing(edad/2)` escribe:

```text
:- dynamic edad/2.

edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).
edad(sofia, 0).
```

Escrita en un archivo, esa salida se vuelve a cargar con `consult/1`. El
[capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) presenta la escritura en archivos y `library(persistency)`, que
guarda cada cambio de los predicados dinámicos que se le indican y los
recupera al iniciar el programa.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C6 | el estado se modifica en pocos predicados con nombre: `visitar/1` y `reiniciar/0` en el agente; `inscribir/3`, `dar_de_baja/2`, `restaurar/1` en el proyecto; el resto del programa solo consulta |
    | C7 | cada prueba que modifica la base la restaura: `setup(estado(E))` y `cleanup(restaurar(E))` en `inscripciones.plt`, `setup(olvidar_fib)` en `memo.plt`; la prueba `estado_intacto`, al final, verifica que la base quedó como estaba |

## 20.11 El proyecto: inscribir y dar de baja

La versión de *Inscripciones* de este capítulo declara dinámicos
`inscripcion/3` y `vacantes/2`, y agrega las operaciones que los modifican:

<!-- ejemplo: capitulo-20/inscripciones.pl predicado: inscribir/3 dar_de_baja/2 consulta: inscribir(104, ssl, R), inscriptos(ssl, L). -->
```prolog
%!  inscribir(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Si inscripcion_posible/3 acepta la inscripción, la registra con estado
%   cursando y descuenta una vacante. Resultado es el de
%   inscripcion_posible/3. Cuenta la operación en los dos casos.
inscribir(Legajo, Materia, Resultado) :-
    inscripcion_posible(Legajo, Materia, Resultado),
    (   Resultado == aceptada
    ->  assertz(inscripcion(Legajo, Materia, cursando)),
        cambiar_vacantes(Materia, -1)
    ;   true
    ),
    contar_operacion.

%!  dar_de_baja(+Legajo:integer, +Materia:atom) is semidet.
%
%   Quita la inscripción del alumno Legajo en Materia, que debe estar
%   cursando, y devuelve la vacante. Falla si no la está cursando.
dar_de_baja(Legajo, Materia) :-
    retract(inscripcion(Legajo, Materia, cursando)),
    cambiar_vacantes(Materia, 1),
    contar_operacion.
```

`inscribir/3` reutiliza `inscripcion_posible/3` del [capítulo 15](../capitulo-15-control/index.md): la
validación no cambia, y solo una inscripción aceptada modifica la base.
`cambiar_vacantes/2` y `contar_operacion/0` siguen la forma de
`cumple_anios/1`: retirar el valor y agregar el nuevo. `operaciones/1` es el
contador, un hecho dinámico que funciona en SWISH.

```prolog
?- inscribir(104, ssl, R), inscriptos(ssl, L), vacantes(ssl, V).
R = aceptada,
L = [104],
V = 19.

?- inscribir(102, am2, R), operaciones(N).
R = rechazada(falta(am1)),
N = 1.
```

`requisitos_de/2` calcula todas las correlativas de una materia, directas e
indirectas, y guarda el resultado con el [Patrón 17](../patrones.md#17-memorizacion-con-assertz):

```prolog
?- requisitos_de(bd, Requisitos).
Requisitos = [alg, log, pp, ssl].
```

Memorizar es correcto aquí porque las correlatividades no cambian durante la
ejecución. Memorizar `aprobada/3`, en cambio, sería un error: una nota nueva
dejaría viejo el valor guardado. El ejercicio 15 memoriza un promedio y lo
invalida en el único predicado que cambia las notas.

Las pruebas de las operaciones guardan el estado antes de cada una y lo
restauran después, con dos predicados del programa:

<!-- ejemplo: capitulo-20/inscripciones.pl predicado: estado/1 restaurar/1 consulta: inscribir(104, ssl, R), inscriptos(ssl, L). -->
```prolog
%!  estado(-Estado) is det.
%
%   Estado reúne los datos que cambian durante la ejecución: las
%   inscripciones, las vacantes y el contador de operaciones.
estado(estado(Inscripciones, Vacantes, Operaciones)) :-
    findall(inscripcion(L, M, E), inscripcion(L, M, E), Inscripciones),
    findall(vacantes(M, N), vacantes(M, N), Vacantes),
    operaciones(Operaciones).

%!  restaurar(+Estado) is det.
%
%   Reemplaza los datos que cambian durante la ejecución por los de Estado,
%   obtenido antes con estado/1.
restaurar(estado(Inscripciones, Vacantes, Operaciones)) :-
    retractall(inscripcion(_, _, _)),
    retractall(vacantes(_, _)),
    retractall(operaciones(_)),
    maplist(assertz, Inscripciones),
    maplist(assertz, Vacantes),
    assertz(operaciones(Operaciones)).
```

```prolog
test(dar_de_baja, [ setup(estado(E)), cleanup(restaurar(E)),
                    true(L-V == [101, 102, 103, 106]-31) ]) :-
    dar_de_baja(105, am1),
    inscriptos(am1, L),
    vacantes(am1, V).
```

`estado/1` y `restaurar/1` están en el programa y no en el archivo de pruebas
por una razón concreta: plunit ejecuta cada unidad de pruebas en su propio
módulo, y un `assertz/1` escrito en el `.plt` agrega el hecho a **ese** módulo,
no al del programa. La prueba vería un hecho que el programa no ve. Llamar a
los predicados del programa —el [Patrón 19](../patrones.md#19-estado-detras-de-una-interfaz)— evita el problema; cuando una
prueba necesita modificar un hecho directamente, lo califica con `user:`, como
`assertz(user:padre(z, w))` en `dinamica.plt`. El [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) explica
los módulos.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Con `q/2` y `p/1` dinámicos y sin hechos, decir qué contiene la
   base después de cada una de estas consultas, ejecutadas en orden:
   `assertz(q(a, b)), assertz(q(1, 2)), asserta(q(x, y)).` ·
   `retract(q(1, 2)), assertz((p(X) :- h(X))).` · `retract(q(_, _)), fail.`
   Comprobarlo con `listing/1`.
2. **(1)** El programa `nada_bien(P) :- vive_cerca_del_agua(P), sabe_nadar(P).`
   con algunos hechos `sabe_nadar/1` y ninguno de `vive_cerca_del_agua/1`
   produce un error en la consulta `nada_bien(X)`. Explicar por qué y
   corregirlo para que falle.
3. ★ **(2)** Con los hechos `numero(1)`, `numero(2)` y `numero(3)`, predecir el
   contenido de `numero/1` después de
   `forall(numero(N), (M is N + 1, assertz(numero(M))))`, y después de
   `forall(numero(N), retract(numero(N)))` sobre la base original.
4. **(2)** Escribir `aleatorio(R, N)`: N es un número entre 1 y R calculado con
   una semilla guardada en el hecho dinámico `semilla/1`, que después se
   reemplaza por `(125 * S + 1) mod 4096`. Con semilla 13 y R = 10, ¿cuáles son
   los seis primeros números?
5. ★ **(2)** Escribir una cuenta bancaria: `iniciar_cuenta/0`,
   `cerrar_cuenta/0`, `depositar/1`, `extraer/1` y `saldo/1`. Una operación
   inválida —la cuenta cerrada, un monto no positivo, un saldo insuficiente—
   falla y deja el saldo como estaba.
6. ★ **(2)** Escribir `suma_hasta(N, S)`, la suma de 1 a N, memorizando cada
   suma calculada. ¿Cuántos valores quedan guardados después de
   `suma_hasta(100, S)`?
7. **(2)** `contar_respuestas/2` de la [sección 20.4](#204-contadores-y-estado-global) usa la variable global
   `cuenta`. Predecir qué responde
   `contar_respuestas((member(_, [a, b]), contar_respuestas(member(_, [1, 2, 3]), _)), N)`,
   y explicar por qué `aggregate_all/3` no tiene ese problema.
8. ★ **(2)** Escribir `como(Hecho)` para el sistema de la [sección 20.6](#206-un-sistema-experto-con-encadenamiento-hacia-adelante): escribe
   la regla que produjo el hecho y, sangradas debajo, las explicaciones de sus
   condiciones, hasta los hechos iniciales.
9. **(2)** Agregar al sistema de la [sección 20.6](#206-un-sistema-experto-con-encadenamiento-hacia-adelante) las reglas `tio_o_tia/2` y
   `primos/2`. ¿Cuántos hechos tiene la base en su punto fijo?
10. **(3)** Escribir `encadenar_por_rondas(Rondas)`: en cada ronda agrega todas
    las conclusiones que las reglas producen con los hechos del comienzo de la
    ronda, hasta que una ronda no agrega nada. Comparar el resultado y la
    cantidad de inferencias con `encadenar/0`.
11. ★ **(3)** Después de encontrar el oro, el agente del Wumpus debe volver a la
    entrada pasando solo por celdas visitadas. Escribir
    `camino_de_vuelta(Desde, Camino)`.
12. **(2)** Escribir `posible_pozo(C)` para el agente: C no se visitó, es
    vecina de una celda con brisa, y nada descarta un pozo en C. ¿Qué celdas
    responde después de la exploración?
13. ★ **(2)** Escribir `registrar_nota(Legajo, Materia, Nota)` para el
    proyecto: la nota final de una materia que se está cursando, con sus
    pruebas, que dejan la base como estaba.
14. **(2)** Agregar al proyecto un historial: cada operación queda registrada
    con su número, y `historial(L)` da la lista en orden.
15. **(3)** Memorizar el promedio de un alumno en `promedio_memo/2`. ¿Qué
    predicado debe borrar el valor guardado, y qué muestra una prueba que
    cambia una nota sin pasar por él?

## Resumen

| | |
|---|---|
| `:- dynamic` | el predicado se puede modificar; sin cláusulas, falla en lugar de dar un error |
| `assertz/1`, `asserta/1` | agregan una cláusula al final o al principio |
| `retract/1`, `retractall/1` | quitan una cláusula que unifica (con retroceso), o todas |
| vista lógica de actualización | una llamada ve las cláusulas que había cuando empezó |
| `flag/3` | un contador numérico o atómico, leído y reemplazado en un paso |
| `b_setval/2`, `nb_setval/2`, `b_getval/2`, `nb_getval/2` | variables globales: la primera se deshace al retroceder, la segunda no; las otras dos leen su valor |
| memorización | guardar lo calculado y buscar antes de calcular |
| encadenamiento hacia adelante | aplicar reglas y agregar conclusiones hasta el punto fijo |
| pruebas con estado | `setup` guarda, `cleanup` restaura, con los predicados del programa |
| **Patrones 17, 18, 19** | memorización con `assertz`; base de conocimiento que crece; estado detrás de una interfaz |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Un lenguaje de comandos para inscribir y dar de baja | [capítulo 21](../capitulo-21-gramaticas-dcg/index.md) |
| Los módulos y la calificación `user:` | [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) |
| Guardar la base en archivos; `library(persistency)` | [capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) |
| La base de datos y los hilos | [capítulo 37](../capitulo-37-concurrencia-y-paralelismo/index.md) |
| La tabulación, que memoriza sin estado escrito a mano | [capítulo 39](../capitulo-39-tabulacion/index.md) |
| El camino de vuelta del Wumpus como búsqueda | [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) |
| El juego del Wumpus completo y un agente que prueba seguras las celdas con los mundos consistentes con lo percibido | [capítulo 77](../capitulo-77-proyecto-mundo-wumpus/index.md) |
