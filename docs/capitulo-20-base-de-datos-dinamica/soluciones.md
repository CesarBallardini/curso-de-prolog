# Soluciones del capítulo 20 — Base de datos dinámica

El código de esta página está en `ejemplos/capitulo-20/soluciones.pl`,
`ejemplos/capitulo-20/soluciones_wumpus.pl` y
`ejemplos/capitulo-20/soluciones_proyecto.pl`, y pasa sus pruebas. Cada archivo
reúne los ejercicios de un dominio: la familia, la cueva del Wumpus y el
proyecto, porque los tres definen predicados con el mismo nombre, como
`reiniciar/0`.

## 1

Después de la primera consulta, `q/2` tiene tres hechos: `asserta/1` puso
`q(x, y)` al principio. La segunda quita `q(1, 2)` y agrega una regla a `p/1`.
La tercera quita un hecho de `q/2`, falla, y al volver atrás `retract/1` quita
el siguiente, hasta que no queda ninguno; la consulta responde `false`, pero
los hechos ya no están. `listing(q/2), listing(p/1)` escribe, al final:

```text
:- dynamic q/2.


:- dynamic p/1.

p(X) :-
    h(X).
```

La prueba `ejercicio_1` de `soluciones.plt` repite la secuencia y verifica el
contenido después de cada paso. La regla de `p/1` se agrega localmente; en
SWISH, `assertz/1` de una regla no está permitido
([sección 20.9](index.md#209-reglas-dinamicas-y-swish)).

## 2

`vive_cerca_del_agua/1` no tiene ninguna cláusula ni ninguna declaración, y
para Prolog no existe: la consulta produce `existence_error`. Declararlo
dinámico dice que existe, aunque todavía no tenga hechos:

<!-- ejemplo: capitulo-20/soluciones.pl fragmento: nada_bien(?P) .. sabe_nadar(luis). consulta: nada_bien(X). -->
```prolog
%!  nada_bien(?P) is nondet.
%
%   P nada bien: vive cerca del agua y sabe nadar. vive_cerca_del_agua/1 es
%   dinámico y todavía no tiene hechos: la consulta falla en lugar de
%   producir un error.
nada_bien(P) :-
    vive_cerca_del_agua(P),
    sabe_nadar(P).

% sabe_nadar(P): P sabe nadar.
sabe_nadar(ana).
sabe_nadar(luis).
```

La declaración está en la directiva `dynamic` del principio del archivo, junto
con los demás predicados dinámicos.

```prolog
?- nada_bien(X).
false.
```

## 3

```prolog
?- forall(numero(N), (M is N + 1, assertz(numero(M)))), findall(N, numero(N), L).
L = [1, 2, 3, 2, 3, 4].

?- forall(numero(N), retract(numero(N))), findall(N, numero(N), L).
L = [].
```

`forall/2` ve los tres números del comienzo, y agrega su siguiente a cada uno:
los números nuevos, 2, 3 y 4, no se recorren. La segunda consulta quita los
tres: `retract/1` quita el que `numero(N)` acaba de encontrar, y el recorrido
sigue con los que había al empezar. Las dos terminan.

## 4

<!-- ejemplo: capitulo-20/soluciones.pl predicado: aleatorio/2 primeros_aleatorios/3 consulta: iniciar_cuenta, depositar(100), extraer(30), saldo(S). -->
```prolog
%!  aleatorio(+R:integer, -N:integer) is det.
%
%   N es un número entre 1 y R calculado a partir de la semilla, que se
%   reemplaza por la siguiente: (125 * S + 1) mod 4096.
aleatorio(R, N) :-
    retract(semilla(S)),
    N is S mod R + 1,
    S1 is (125 * S + 1) mod 4096,
    assertz(semilla(S1)).

%!  primeros_aleatorios(+Cantidad:integer, +R:integer, -L:list) is det.
%
%   L son los próximos Cantidad números de aleatorio(R, N).
primeros_aleatorios(Cantidad, R, L) :-
    length(L, Cantidad),
    maplist(aleatorio(R), L).
```

```prolog
?- primeros_aleatorios(6, 10, L).
L = [4, 7, 8, 5, 6, 9].
```

La semilla es estado: cada llamada la reemplaza, y la siguiente da otro
número. Por eso la secuencia se repite si se vuelve a empezar con la misma
semilla, que es lo que permite probarla. SWI-Prolog tiene su propio generador,
`random_between/3`, que el [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md) usa.

## 5

<!-- ejemplo: capitulo-20/soluciones.pl predicado: iniciar_cuenta/0 cerrar_cuenta/0 depositar/1 extraer/1 saldo/1 consulta: iniciar_cuenta, depositar(100), extraer(30), saldo(S). -->
```prolog
%!  iniciar_cuenta is det.
%
%   Abre una cuenta con saldo 0, o la vuelve a abrir si ya estaba abierta.
iniciar_cuenta :-
    retractall(cuenta(_)),
    assertz(cuenta(0)).

%!  cerrar_cuenta is semidet.
%
%   Cierra la cuenta. Falla si no hay una cuenta abierta.
cerrar_cuenta :-
    retract(cuenta(_)).

%!  depositar(+Monto:number) is semidet.
%
%   Suma Monto al saldo. Falla si la cuenta está cerrada o si Monto no es
%   positivo.
depositar(Monto) :-
    Monto > 0,
    retract(cuenta(Saldo0)),
    Saldo is Saldo0 + Monto,
    assertz(cuenta(Saldo)).

%!  extraer(+Monto:number) is semidet.
%
%   Resta Monto del saldo. Falla si la cuenta está cerrada, si Monto no es
%   positivo o si el saldo no alcanza; en esos casos el saldo no cambia.
extraer(Monto) :-
    Monto > 0,
    cuenta(Saldo0),
    Saldo0 >= Monto,
    retract(cuenta(Saldo0)),
    Saldo is Saldo0 - Monto,
    assertz(cuenta(Saldo)).

%!  saldo(-Saldo:number) is semidet.
%
%   Saldo es el saldo de la cuenta. Falla si la cuenta está cerrada.
saldo(Saldo) :-
    cuenta(Saldo).
```

```prolog
?- iniciar_cuenta, depositar(100), extraer(30), saldo(S).
S = 70.

?- iniciar_cuenta, depositar(100), \+ extraer(500), saldo(S).
S = 100.
```

`extraer/1` comprueba el saldo **antes** de retirarlo: si se retirara primero,
una extracción insuficiente fallaría con el saldo ya quitado, porque
`retract/1` no se deshace al volver atrás. Es el [Patrón 19](../patrones.md#19-estado-detras-de-una-interfaz): la cuenta solo se
modifica en estos cinco predicados, y cada uno deja la base en un estado
válido.

## 6

<!-- ejemplo: capitulo-20/soluciones.pl predicado: suma_hasta/2 olvidar_sumas/0 consulta: olvidar_sumas, suma_hasta(100, S). -->
```prolog
%!  suma_hasta(+N:integer, -S:integer) is det.
%
%   S es la suma de los enteros de 1 a N, con N mayor o igual que 1. Cada
%   suma calculada se guarda en suma_guardada/2.
suma_hasta(N, S) :-
    (   suma_guardada(N, S0)
    ->  S = S0
    ;   N =:= 1
    ->  S = 1
    ;   N1 is N - 1,
        suma_hasta(N1, S1),
        S0 is S1 + N,
        assertz(suma_guardada(N, S0)),
        S = S0
    ).

%!  olvidar_sumas is det.
%
%   Borra las sumas guardadas.
olvidar_sumas :-
    retractall(suma_guardada(_, _)).
```

```prolog
?- olvidar_sumas, suma_hasta(100, S), aggregate_all(count, suma_guardada(_, _), N).
S = 5050,
N = 99.
```

Quedan guardadas las sumas de 2 a 100: la de 1 es el caso base y no se guarda.
Con `:- table suma_hasta/2.` y sin `suma_guardada/2`, la tabulación del
[capítulo 39](../capitulo-39-tabulacion/index.md) haría lo mismo.

## 7

El predicado de la [sección 20.4](index.md#204-contadores-y-estado-global), en `contadores.pl`:

<!-- ejemplo: capitulo-20/contadores.pl predicado: contar_respuestas/2 consulta: global_con_retroceso(X), global_sin_retroceso(Y). -->
```prolog
%!  contar_respuestas(:Objetivo, -N:integer) is det.
%
%   N es la cantidad de respuestas de Objetivo, contadas con una variable
%   global en un bucle por falla. aggregate_all(count, Objetivo, N) hace lo
%   mismo sin estado.
contar_respuestas(Objetivo, N) :-
    nb_setval(cuenta, 0),
    forall(call(Objetivo),
           ( nb_getval(cuenta, C0),
             C is C0 + 1,
             nb_setval(cuenta, C) )),
    nb_getval(cuenta, N).
```

```prolog
?- contar_respuestas((member(_, [a, b]), contar_respuestas(member(_, [1, 2, 3]), _)), N).
N = 4.
```

Las respuestas son 2, pero `contar_respuestas/2` responde 4. La llamada
interior usa la misma variable global, `cuenta`: la pone en 0, cuenta sus tres
respuestas y la deja en 3. La exterior suma 1 sobre ese 3. En la segunda
respuesta ocurre lo mismo, y el resultado es 3 + 1 = 4. Una variable global
es una sola para todo el programa: dos usos anidados interfieren entre sí.
`aggregate_all(count, …)` no guarda nada fuera de la llamada, y cada llamada
tiene su propio conteo:

```prolog
?- aggregate_all(count, (member(_, [a, b]), aggregate_all(count, member(_, [1, 2, 3]), _)), N).
N = 2.
```

## 8

<!-- ejemplo: capitulo-20/soluciones.pl predicado: como/1 como/2 consulta: reiniciar, encadenar, como(abuelo(juan, sofia)). -->
```prolog
%!  como(+Hecho) is semidet.
%
%   Escribe cómo se obtuvo Hecho: la regla y, debajo, cómo se obtuvo cada
%   una de sus condiciones, hasta los hechos iniciales. Falla si Hecho no
%   está en la base.
como(Hecho) :-
    hecho(Hecho),
    como(Hecho, 0).

%!  como(+Hecho, +Sangria:integer) is det.
%
%   Escribe la explicación de Hecho a partir de la columna Sangria.
como(A \== B, Sangria) :-
    format("~t~*|~w \\== ~w: se cumple~n", [Sangria, A, B]).
como(Hecho, Sangria) :-
    Hecho \= ( _ \== _ ),
    (   derivado(Hecho, Regla, Condiciones)
    ->  format("~t~*|~w: por ~w~n", [Sangria, Hecho, Regla]),
        Siguiente is Sangria + 2,
        forall(member(C, Condiciones), como(C, Siguiente))
    ;   format("~t~*|~w: dato inicial~n", [Sangria, Hecho])
    ).
```

```prolog
?- reiniciar, encadenar, como(abuelo(juan, sofia)).
abuelo(juan,sofia): por abuelo
  padre(juan,ana): dato inicial
  progenitor(ana,sofia): por progenitor_m
    madre(ana,sofia): dato inicial
true.
```

`derivado/3` guarda las condiciones ya ligadas, y la explicación las recorre:
cada condición es un hecho derivado, con su propia explicación, o un dato
inicial, que no tiene `derivado/3`. A diferencia del sistema del
[capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md), el árbol no se construye al probar sino que está en la base,
repartido en los hechos `derivado/3`.

## 9

Las dos reglas se agregan a la lista, sin cambiar el intérprete:

<!-- ejemplo: capitulo-20/soluciones.pl fragmento: regla(tio_o_tia .. primos(A, B)). consulta: reiniciar, encadenar, como(abuelo(juan, sofia)). -->
```prolog
regla(tio_o_tia,    [hermanos(T, P), progenitor(P, S)], tio_o_tia(T, S)).
regla(primos,       [progenitor(P, A), hermanos(P, Q), progenitor(Q, B)],
                                                     primos(A, B)).
```

```prolog
?- reiniciar, encadenar, aggregate_all(count, hecho(_), N).
N = 41.
```

De 34 hechos a 41: tres de `tio_o_tia/2` y cuatro de `primos/2`, en los dos
sentidos. `tio_o_tia` usa `hermanos`, que es a su vez una conclusión: el
encadenamiento no depende del orden de las reglas, porque sigue buscando hasta
que ninguna agrega nada.

## 10

<!-- ejemplo: capitulo-20/soluciones.pl predicado: encadenar_por_rondas/1 por_rondas/2 agregar/3 consulta: reiniciar, encadenar, como(abuelo(juan, sofia)). -->
```prolog
%!  encadenar_por_rondas(-Rondas:integer) is det.
%
%   Agrega las conclusiones por rondas: en cada una, todas las que las reglas
%   producen con los hechos del comienzo de la ronda. Rondas es la cantidad
%   de rondas que agregaron algún hecho.
encadenar_por_rondas(Rondas) :-
    por_rondas(0, Rondas).

%!  por_rondas(+Hechas:integer, -Rondas:integer) is det.
%
%   Rondas es Hechas más las rondas que todavía agregan algún hecho.
por_rondas(Hechas, Rondas) :-
    findall(Conclusion-Nombre-Condiciones,
            ( regla(Nombre, Condiciones, Conclusion),
              maplist(se_cumple, Condiciones),
              \+ hecho(Conclusion) ),
            Nuevos),
    (   Nuevos == []
    ->  Rondas = Hechas
    ;   forall(member(Conclusion-Nombre-Condiciones, Nuevos),
               agregar(Conclusion, Nombre, Condiciones)),
        Siguiente is Hechas + 1,
        por_rondas(Siguiente, Rondas)
    ).

%!  agregar(+Conclusion, +Nombre, +Condiciones:list) is det.
%
%   Agrega Conclusion a la base, si todavía no estaba: dos reglas, o dos
%   formas de cumplir la misma, pueden producir el mismo hecho en una ronda.
agregar(Conclusion, Nombre, Condiciones) :-
    (   hecho(Conclusion)
    ->  true
    ;   assertz(hecho(Conclusion)),
        assertz(derivado(Conclusion, Nombre, Condiciones))
    ).
```

```prolog
?- reiniciar, encadenar_por_rondas(R), aggregate_all(count, hecho(_), N).
R = 3,
N = 41.
```

Tres rondas: los progenitores; los abuelos, los hermanos y los antepasados
directos; y el resto, que depende de los anteriores. La base final es la misma
que con `encadenar/0`, y la prueba `mismos_hechos` lo verifica. Con esta base,
`encadenar/0` usa unas 20 700 inferencias y `encadenar_por_rondas/1` unas
26 000: cada ronda vuelve a probar todas las reglas con todos los hechos, y
encuentra de nuevo conclusiones que ya estaban. `agregar/3` evita agregarlas
dos veces, porque dos formas de cumplir la misma regla producen el mismo hecho
en una ronda. La versión por rondas tiene otra ventaja: cada ronda es un
«paso» del razonamiento, y su número dice cuán lejos de los datos está cada
conclusión.

## 11

<!-- ejemplo: capitulo-20/soluciones_wumpus.pl predicado: camino_de_vuelta/2 camino/3 consulta: explorar(oro(C)), camino_de_vuelta(C, Camino). -->
```prolog
%!  camino_de_vuelta(+Desde, -Camino:list) is semidet.
%
%   Camino es una lista de celdas visitadas, vecinas de a pares, que va de
%   Desde a la entrada, (1, 1), sin repetir ninguna. Falla si no hay camino
%   por celdas visitadas.
camino_de_vuelta(Desde, Camino) :-
    once(camino(Desde, [Desde], Invertido)),
    reverse(Invertido, Camino).

%!  camino(+Celda, +Recorridas:list, -Invertido:list) is nondet.
%
%   Invertido es Recorridas, la última celda primero, extendida por celdas
%   visitadas hasta la entrada. Recorridas evita volver a pasar por una celda.
camino(1-1, Recorridas, Recorridas).
camino(Celda, Recorridas, Invertido) :-
    Celda \== 1-1,
    vecina(Celda, Siguiente),
    visitada(Siguiente),
    \+ memberchk(Siguiente, Recorridas),
    camino(Siguiente, [Siguiente|Recorridas], Invertido).
```

```prolog
?- explorar(oro(C)), camino_de_vuelta(C, Camino).
C = 2-3,
Camino = [2-3, 2-2, 1-2, 1-1].
```

`camino/3` es una búsqueda en profundidad por las celdas visitadas, con la
lista de las recorridas para no pasar dos veces por la misma. Las celdas
visitadas son seguras por definición, y por eso el camino también lo es.
`once/1` se queda con el primer camino, que no es necesariamente el más corto;
el [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md) presenta la búsqueda a lo ancho, que sí lo encuentra, y el
[capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) vuelve sobre este problema.

## 12

<!-- ejemplo: capitulo-20/soluciones_wumpus.pl predicado: posible_pozo/1 consulta: explorar(_), findall(C, posible_pozo(C), L). -->
```prolog
%!  posible_pozo(?C) is nondet.
%
%   C puede tener un pozo: no se visitó, es vecina de una celda visitada con
%   brisa, y ninguna vecina visitada sin brisa lo descarta.
posible_pozo(C) :-
    setof(C0, V^( visitada(V),
                  percibio(V, brisa),
                  vecina(V, C0),
                  \+ visitada(C0),
                  \+ sin_pozo(C0) ), Celdas),
    member(C, Celdas).
```

```prolog
?- explorar(_), findall(C, posible_pozo(C), L).
L = [2-4, 3-1, 3-3, 4-2].
```

Cuatro celdas pueden tener un pozo; en la cueva, solo (3, 1) y (3, 3) lo tienen.
El agente no puede deducir más con lo que percibió: la brisa de (3, 2) viene de
(3, 1), de (3, 3) o de (4, 2). `setof/3` elimina las celdas repetidas, que
aparecen una vez por cada vecina con brisa.

## 13

<!-- ejemplo: capitulo-20/soluciones_proyecto.pl predicado: registrar_nota/3 consulta: registrar_nota(101, pp, 9), promedio_memo(101, P). -->
```prolog
%!  registrar_nota(+Legajo:integer, +Materia:atom, +Nota:integer) is semidet.
%
%   Registra la nota final Nota, de 1 a 10, del alumno Legajo en Materia,
%   que debe estar cursando. Falla si no la está cursando o si la nota no es
%   válida. Borra el promedio guardado del alumno (ejercicio 15).
registrar_nota(Legajo, Materia, Nota) :-
    integer(Nota),
    between(1, 10, Nota),
    retract(inscripcion(Legajo, Materia, cursando)),
    assertz(inscripcion(Legajo, Materia, nota(Nota))),
    retractall(promedio_guardado(Legajo, _)),
    contar_operacion(registrar_nota(Legajo, Materia, Nota)).
```

```prolog
test(registrar_nota, [ setup(estado(E)), cleanup(restaurar(E)),
                       true(N == 9) ]) :-
    registrar_nota(101, pp, 9),
    aprobada(101, pp, N).

test(nota_invalida, [ setup(estado(E)), cleanup(restaurar(E)), fail ]) :-
    registrar_nota(101, pp, 11).
```

Las comprobaciones van antes de `retract/1`: una nota inválida falla sin tocar
la base, y la prueba `nota_no_cambia_la_base` lo verifica. Cada prueba guarda
y restaura el estado con los predicados del programa.

## 14

<!-- ejemplo: capitulo-20/soluciones_proyecto.pl predicado: contar_operacion/1 historial/1 consulta: inscribir(104, ssl, _), dar_de_baja(104, ssl), historial(H). -->
```prolog
%!  contar_operacion(+Operacion) is det.
%
%   Suma uno al contador de operaciones y registra Operacion en el historial
%   con ese número (ejercicio 14).
contar_operacion(Operacion) :-
    retract(operaciones(N0)),
    N is N0 + 1,
    assertz(operaciones(N)),
    assertz(registro(N, Operacion)).

%!  historial(-Operaciones:list) is det.
%
%   Operaciones son las operaciones registradas, en el orden en que se
%   hicieron, como pares Numero-Operacion.
historial(Operaciones) :-
    findall(N-Op, registro(N, Op), Operaciones).
```

```prolog
?- inscribir(104, ssl, _), dar_de_baja(104, ssl), historial(H).
H = [1-inscribir(104, ssl, aceptada), 2-dar_de_baja(104, ssl)].
```

El contador y el historial cambian juntos, en el único predicado que cuenta
operaciones: `inscribir/3` y `dar_de_baja/2` le pasan la operación. `estado/1`
y `restaurar/1` incluyen el historial, para que las pruebas lo dejen como
estaba.

## 15

<!-- ejemplo: capitulo-20/soluciones_proyecto.pl predicado: promedio_memo/2 consulta: registrar_nota(101, pp, 9), promedio_memo(101, P). -->
```prolog
%!  promedio_memo(+Legajo:integer, -Promedio:number) is semidet.
%
%   El promedio de promedio_de_alumno/2, guardado en promedio_guardado/2 la
%   primera vez que se calcula. registrar_nota/3 lo borra, porque deja de
%   ser correcto.
promedio_memo(Legajo, Promedio) :-
    (   promedio_guardado(Legajo, Guardado)
    ->  Promedio = Guardado
    ;   promedio_de_alumno(Legajo, Calculado),
        assertz(promedio_guardado(Legajo, Calculado)),
        Promedio = Calculado
    ).
```

```prolog
?- promedio_memo(101, P0), registrar_nota(101, pp, 9), promedio_memo(101, P).
P0 = 8.5,
P = 8.6.
```

El valor guardado depende de las notas del alumno, y solo `registrar_nota/3`
las cambia: ese predicado borra el promedio guardado del alumno. La prueba
`sin_invalidar` cambia la nota directamente, con `retract/1` y `assertz/1`, y
`promedio_memo/2` responde el valor viejo, 8.5. La memoria es correcta solo si
**todo** cambio de los datos pasa por el predicado que la invalida: otra razón
para el Patrón 19.
