# Soluciones del capítulo 15 — Control

El código de esta página está en `ejemplos/capitulo-15/soluciones.pl` y pasa sus
pruebas. Las soluciones 10 y 15 usan `library(reif)` y están en
`soluciones_puras.pl`.

## 1

```prolog
?- ( 1 < 2 -> X = si ; X = no ).
X = si.

?- ( member(X, [1, 2, 3]), X > 1 -> Y = X ; Y = 0 ).
X = Y, Y = 2.

?- ( fail -> X = a ).
false.

?- ( true ; X = b ).
true ;
X = b.
```

La segunda muestra qué poda el condicional: la condición es la conjunción
`member(X, [1, 2, 3]), X > 1`, que tiene dos respuestas, 2 y 3; el condicional
usa la primera. La tercera falla porque no hay rama `Si_no`. La cuarta es una
disyunción sin condicional: da una respuesta por cada alternativa.

## 2

<!-- ejemplo: capitulo-15/soluciones.pl predicado: no/1 una_vez/1 ignorar/1 consulta: una_vez(member(X, [a, b])). -->
```prolog
%!  no(:Objetivo) is semidet.
%
%   Objetivo no se puede probar: la definición de \+/1.
no(Objetivo) :-
    (   call(Objetivo)
    ->  fail
    ;   true
    ).

%!  una_vez(:Objetivo) is semidet.
%
%   La primera respuesta de Objetivo: la definición de once/1.
una_vez(Objetivo) :-
    (   call(Objetivo)
    ->  true
    ).

%!  ignorar(:Objetivo) is det.
%
%   Ejecuta Objetivo si puede, y se cumple igual: la definición de ignore/1.
ignorar(Objetivo) :-
    (   call(Objetivo)
    ->  true
    ;   true
    ).
```

Los tres reciben un objetivo, y por eso su modo es `:`, el de la
[sección 14.3](../capitulo-14-estilo-y-documentacion/index.md#143-el-encabezado-completo). `call/1` ejecuta un término como objetivo; el
[capítulo 18](../capitulo-18-orden-superior/index.md) lo presenta junto con los demás predicados que reciben objetivos.

## 3

<!-- ejemplo: capitulo-15/soluciones.pl predicado: maximo/3 descuento/2 consulta: maximo(3, 1, M). -->
```prolog
%!  maximo(+X:number, +Y:number, -M:number) is det.
%!  maximo(+X:number, +Y:number, +M:number) is semidet.
%
%   M es el mayor de X e Y.
maximo(X, Y, M) :-
    (   X >= Y
    ->  M = X
    ;   M = Y
    ).

%!  descuento(+Edad:integer, -D:integer) is det.
%!  descuento(+Edad:integer, +D:integer) is semidet.
%
%   D es el descuento que corresponde a Edad.
descuento(Edad, D) :-
    (   Edad < 12
    ->  D = 50
    ;   Edad >= 65
    ->  D = 30
    ;   D = 0
    ).
```

Las dos son estables: `maximo(3, 1, 1)` y `descuento(8, 0)` fallan, porque la
salida se liga dentro de la rama que eligió la condición. La `descuento/2` de la
[solución 9 del capítulo 9](../capitulo-09-backtracking-y-corte/soluciones.md#9) ya era correcta, porque escribía las condiciones
completas; la versión con condicional evalúa cada condición una sola vez y no
deja alternativas pendientes.

## 4

<!-- ejemplo: capitulo-15/soluciones.pl predicado: valor_absoluto/2 consulta: valor_absoluto(-5, A). -->
```prolog
%!  valor_absoluto(+X:number, -A:number) is det.
%!  valor_absoluto(+X:number, +A:number) is semidet.
%
%   A es el valor absoluto de X.
valor_absoluto(X, A) :-
    (   X < 0
    ->  A is -X
    ;   A = X
    ).
```

Un modo, `valor_absoluto(+X, ?A) is semidet`: con `A` libre hay una respuesta, y
con `A` ligada se comprueba. Las pruebas de `soluciones.plt` cubren un número
negativo y uno positivo.

## 5

Con 4 responde `P = par ;` y después `false.`; con 3 responde `false.` La
disyunción es la causa. Con 4, la primera alternativa se cumple y `P = par`
también; al pedir otra respuesta, la segunda alternativa liga `P = impar` y
después `P = par` falla. Con 3, la primera alternativa falla, la segunda liga
`P = impar`, y `P = par` falla: no queda ninguna respuesta. El `P = par` después
de la disyunción se aplica a las dos ramas, y contradice a la segunda.

<!-- ejemplo: capitulo-15/soluciones.pl predicado: paridad/2 consulta: paridad(3, P). -->
```prolog
%!  paridad(+N:integer, -P:atom) is det.
%!  paridad(+N:integer, +P:atom) is semidet.
%
%   P es par o impar, según N.
paridad(N, P) :-
    (   0 =:= N mod 2
    ->  P = par
    ;   P = impar
    ).
```

```prolog
?- paridad(3, P).
P = impar.
```

## 6

<!-- ejemplo: capitulo-15/soluciones.pl predicado: primera_aprobada/2 consulta: primera_aprobada(101, Materia). -->
```prolog
%!  primera_aprobada(+Legajo:integer, -Materia:atom) is semidet.
%
%   Materia es la primera materia aprobada del alumno Legajo. once/1 va en
%   este predicado, que promete una respuesta, y no en aprobada/3.
primera_aprobada(Legajo, Materia) :-
    once(aprobada(Legajo, Materia, _Nota)).
```

`once/1` va en `primera_aprobada/2`, el predicado cuyo nombre promete una
respuesta. Dentro de `aprobada/3` cambiaría la relación para todos los que la
usan: `aprobada(101, M, N)` dejaría de enumerar las materias aprobadas, y
`inscripcion_posible/3`, que pregunta por una materia en particular, no se vería
afectada, pero cualquier informe que necesite todas sí. Es el [Patrón 6](../patrones.md#6-una-respuesta-en-el-borde).

## 7

<!-- ejemplo: capitulo-15/soluciones.pl predicado: listar_aprobadas/1 consulta: listar_aprobadas(104). -->
```prolog
%!  listar_aprobadas(+Legajo:integer) is det.
%
%   Escribe una línea por cada materia aprobada del alumno, con su nota.
listar_aprobadas(Legajo) :-
    (   aprobada(Legajo, Materia, Nota),
        format("~w: ~d~n", [Materia, Nota]),
        fail
    ;   true
    ).
```

```prolog
?- listar_aprobadas(104).
log: 9
alg: 7
pp: 8
true.
```

## 8

La orden nueva es una cláusula más de `ejecutar/1`, antes de la que atiende las
órdenes desconocidas:

```prolog
ejecutar(todas) :-
    !,
    listar_edades.
```

El orden de las cláusulas importa: la última de `ejecutar/1` acepta cualquier
orden, y si `todas` se agregara después, nunca se alcanzaría. La versión
completa del menú, con esta orden y la del ejercicio 14, está en
`soluciones.pl`.

## 9

<!-- ejemplo: capitulo-15/soluciones.pl predicado: contar_hasta/1 contar_hasta_rec/1 contando/2 suma_hasta/2 sumando/4 consulta: suma_hasta(4, S). -->
```prolog
%!  contar_hasta(+N:integer) is det.
%
%   Escribe los números de 1 a N, con un bucle por falla.
contar_hasta(N) :-
    (   between(1, N, I),
        format("~d~n", [I]),
        fail
    ;   true
    ).

%!  contar_hasta_rec(+N:integer) is det.
%
%   Escribe los números de 1 a N, con una recursión.
contar_hasta_rec(N) :-
    contando(1, N).

%!  contando(+I:integer, +N:integer) is det.
%
%   Escribe los números de I a N.
contando(I, N) :-
    (   I > N
    ->  true
    ;   format("~d~n", [I]),
        I1 is I + 1,
        contando(I1, N)
    ).

%!  suma_hasta(+N:integer, -S:integer) is det.
%
%   S es la suma de 1 a N: con la recursión, porque el resultado se construye
%   durante el recorrido.
suma_hasta(N, S) :-
    sumando(1, N, 0, S).

%!  sumando(+I:integer, +N:integer, +Hasta:integer, -S:integer) is det.
%
%   S es Hasta más la suma de I a N.
sumando(I, N, Hasta, S) :-
    (   I > N
    ->  S = Hasta
    ;   Ahora is Hasta + I,
        I1 is I + 1,
        sumando(I1, N, Ahora, S)
    ).
```

Las dos versiones escriben lo mismo. Solo la recursión sirve para
`suma_hasta/2`: un bucle por falla deshace las ligaduras en cada vuelta, y no hay
dónde ir acumulando la suma. La recursión lleva el acumulador de vuelta en
vuelta, como en el [capítulo 8](../capitulo-08-aritmetica/index.md). Es el límite que señala el [Patrón 7](../patrones.md#7-bucle-por-falla): el bucle
por falla sirve para efectos, no para resultados.

## 10

<!-- ejemplo: capitulo-15/soluciones_puras.pl predicado: sin_repetidos_puro/2 sin_los_vistos_puro/3 consulta: sin_repetidos_puro([a, X], R). -->
```prolog
%!  sin_repetidos_puro(?L:list, ?R:list) is nondet.
%
%   R es L sin repetidos; conserva la primera aparición de cada elemento.
%   Con elementos libres, considera los dos casos para cada comparación.
sin_repetidos_puro(L, R) :-
    sin_los_vistos_puro(L, [], R).

%!  sin_los_vistos_puro(?L:list, +Vistos:list, ?R:list) is nondet.
%
%   R es L sin los elementos de Vistos y sin repetidos.
sin_los_vistos_puro([], _, []).
sin_los_vistos_puro([X|Resto], Vistos, R) :-
    if_(memberd_t(X, Vistos),
        R = R0,
        R = [X|R0]),
    sin_los_vistos_puro(Resto, [X|Vistos], R0).
```

`memberd_t/3` es la pertenencia reificada de `library(reif)`: decide si un
elemento está en una lista, y con elementos libres considera los dos casos. La
consulta con un elemento libre muestra la diferencia:

```prolog
?- sin_repetidos([a, X], R).
X = a,
R = [a].

?- sin_repetidos_puro([a, X], R).
X = a,
R = [a] ;
R = [a, X],
dif(X, a).
```

La versión de `condicional.pl` da una sola respuesta, y además **liga** `X`:
`memberchk/2` unifica `X` con `a` para decidir que ya estaba. Es lo que declara
su `++L`: la lista debe llegar completa. La versión pura da las dos respuestas
que la relación tiene: `X` es `a` y se descarta, o es distinto de `a` y se
conserva.

## 11

<!-- ejemplo: capitulo-15/soluciones.pl predicado: requisitos/2 requisitos_faltantes/3 no_aprobados/3 consulta: requisitos_faltantes(102, am2, F). -->
```prolog
% requisitos(Materia, Lista): los requisitos de Materia, en una lista. Repite
% la información de correlativa/2: el capítulo 17 evita esa repetición.
requisitos(am1, []).
requisitos(alg, []).
requisitos(log, []).
requisitos(am2, [am1, alg]).
requisitos(pp,  [log]).
requisitos(ssl, [log, alg]).
requisitos(bd,  [pp, ssl]).

%!  requisitos_faltantes(+Legajo:integer, +Materia:atom, -Faltan:list) is det.
%
%   Faltan son los requisitos de Materia que el alumno Legajo no aprobó.
requisitos_faltantes(Legajo, Materia, Faltan) :-
    requisitos(Materia, Requisitos),
    no_aprobados(Requisitos, Legajo, Faltan).

%!  no_aprobados(+Materias:list, +Legajo:integer, -Faltan:list) is det.
%
%   Faltan son las materias de la lista que el alumno Legajo no aprobó. La
%   lista va primero: SWI-Prolog distingue [] de [_|_] por el primer
%   argumento, y así el recorrido no deja alternativas pendientes.
no_aprobados([], _, []).
no_aprobados([Materia|Resto], Legajo, Faltan) :-
    (   aprobada(Legajo, Materia, _)
    ->  Faltan = Faltan0
    ;   Faltan = [Materia|Faltan0]
    ),
    no_aprobados(Resto, Legajo, Faltan0).
```

```prolog
?- requisitos_faltantes(102, am2, F).
F = [am1, alg].
```

Es necesario repetir las correlatividades en una lista por materia,
`requisitos/2`, porque con las herramientas vistas no se pueden reunir las
respuestas de `correlativa(am2, R)` en una lista. El [capítulo 17](../capitulo-17-todas-las-soluciones/index.md) presenta `findall/3`, que las
reúne a partir de los hechos, y `requisitos/2` deja de ser necesario.

`no_aprobados/3` recibe la lista como **primer** argumento. Con el legajo
primero, la primera versión dejaba una alternativa pendiente en cada paso: el
legajo es el mismo en todas las llamadas, y SWI-Prolog, que distingue las
cláusulas por el primer argumento, no podía descartar la de la lista vacía. El
[capítulo 16](../capitulo-16-rendimiento/index.md) explica ese mecanismo, la indexación, y el [Patrón 9](../patrones.md#9-el-argumento-que-indexa-primero) lo convierte en
regla.

## 12

<!-- ejemplo: capitulo-15/soluciones.pl predicado: inscripcion_posible_por_anio/3 consulta: inscripcion_posible_por_anio(105, bd, R). -->
```prolog
%!  inscripcion_posible_por_anio(+Legajo:integer, +Materia:atom,
%!                               -Resultado) is det.
%
%   Como inscripcion_posible/3, con un motivo más: un alumno que ingresó en
%   2025 no puede cursar materias de tercer año. La condición va después de
%   verificar que el alumno y la materia existen, y antes de los requisitos.
inscripcion_posible_por_anio(Legajo, Materia, Resultado) :-
    (   \+ alumno(Legajo, _, _, _)
    ->  Resultado = rechazada(alumno_inexistente)
    ;   \+ materia(Materia, _, _)
    ->  Resultado = rechazada(materia_inexistente)
    ;   alumno(Legajo, _, _, 2025),
        materia(Materia, _, 3)
    ->  Resultado = rechazada(anio_no_permitido)
    ;   inscripcion_posible(Legajo, Materia, Resultado)
    ).
```

```prolog
?- inscripcion_posible_por_anio(105, bd, R).
R = rechazada(anio_no_permitido).
```

La condición necesita que el alumno y la materia existan, y por eso va después
de esas dos ramas. Antes o después de los requisitos cambia el motivo que se
informa, no si se acepta: elena, que ingresó en 2025, tampoco aprobó
paradigmas, y con la condición después de los requisitos el resultado sería
`rechazada(falta(pp))`. Ubicada antes, el motivo es el más general: aunque
aprobara los requisitos, no podría cursar la materia. Las pruebas del proyecto
no cambian, porque ninguna pide una materia de tercer año para un alumno de
2025.

## 13

| Consulta | Resultado | Por qué |
|---|---|---|
| `categoria(luis, C).` | `C = chico.` | el condicional no deja alternativas, y `edad/2` se distingue por el primer argumento |
| `sacar(b, [a, b], R).` | `R = [a].` | el condicional elige una rama y descarta la otra |
| `member(a, [a, b]).` | `true ;` y después `false.` | `member/2` puede encontrar `a` otra vez en el resto |
| `memberchk(a, [a, b]).` | `true.` | se cumple a lo sumo una vez |

## 14

Con `edad(X)` y `X` libre, el menú responde `juan tiene 68 años`: `edad(P, A)`
liga `P` con la primera persona de la base, y la orden, que debía preguntar por
alguien en particular, responde por cualquiera. Es la situación de la
[sección 10.4](../capitulo-10-negacion-como-falla/index.md#104-donde-ubicar), con un objetivo que genera en lugar de verificar. La corrección
agrega una cláusula antes de la que responde, que reconoce la orden incompleta
con `var/1`, que se cumple cuando su argumento es una variable libre (el
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md) presenta estas pruebas de tipo):

```prolog
ejecutar(edad(P)) :-
    var(P),
    !,
    format("Orden incompleta: falta el nombre~n").
```

Con la cláusula nueva, el menú de `soluciones.pl` informa la orden incompleta
en lugar de responder por otra persona; la prueba `menu_orden_incompleta` de
`soluciones.plt` comprueba esta salida:

```prolog
?- open_string("edad(X). salir.", In), menu(In).
Orden incompleta: falta el nombre
Fin
In = <stream>(...).
```

## 15

<!-- ejemplo: capitulo-15/soluciones_puras.pl predicado: menor_t/3 categoria_pura/2 consulta: categoria_pura(sofia, C). -->
```prolog
%!  menor_t(+X:number, +Y:number, -T:boolean) is det.
%!  menor_t(+X:number, +Y:number, +T:boolean) is semidet.
%
%   T es true si X < Y, y false si no. No es una condición reificada pura:
%   compara con </2, que exige que X e Y tengan valor.
menor_t(X, Y, T) :-
    (   X < Y
    ->  T = true
    ;   T = false
    ).

%!  categoria_pura(?P, ?C) is nondet.
%
%   C es la categoría de P según su edad, con if_/3.
categoria_pura(P, C) :-
    edad(P, A),
    if_(menor_t(A, 4),
        C = bebe,
        if_(menor_t(A, 13),
            C = chico,
            C = adulto)).
```

`library(reif)` reifica la igualdad y la pertenencia, pero no las comparaciones
aritméticas: `menor_t/3` las reifica a mano, con `</2`, y por eso no es pura.
Con `A` libre, `A < 4` produce un error de instanciación en lugar de considerar
los dos casos. `categoria_pura/2` funciona porque `edad(P, A)` siempre liga `A`
antes de la comparación, pero el predicado no gana nada respecto de la versión
con `->`.

Una comparación aritmética que considera los dos casos necesita una
**restricción**: `A #< 4` afirma que `A` es menor que 4 sin exigir su valor, y
la reificación `#<==>` la convierte en verdadera o falsa. Son las herramientas
del [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md).

## 16

<!-- ejemplo: capitulo-15/soluciones.pl predicado: tomada_en_dos/3 consulta: tomada_en_dos(101, M, A). -->
```prolog
%!  tomada_en_dos(?Legajo:integer, ?Materia:atom, ?Anio:integer) is nondet.
%
%   La misma relación que tomada/3, con una cláusula por alternativa. El
%   objetivo que seguía a la disyunción se repite en las dos.
tomada_en_dos(Legajo, Materia, Anio) :-
    cursa(Legajo, Materia),
    materia(Materia, _, Anio).
tomada_en_dos(Legajo, Materia, Anio) :-
    aprobada(Legajo, Materia, _),
    materia(Materia, _, Anio).
```

Cada alternativa de la disyunción pasa a ser el comienzo del cuerpo de una
cláusula, y el objetivo que la seguía, `materia(Materia, _, Anio)`, se repite en
las dos. Es el costo que menciona la
[sección 15.1](index.md#151-en-el-cuerpo): con un solo objetivo compartido la
repetición es menor, y las dos cláusulas se leen sin paréntesis; con un
cuerpo compartido más largo, la disyunción evita copiarlo.

```prolog
?- tomada_en_dos(101, M, A).
M = pp,
A = 2 ;
M = am1,
A = 1 ;
M = alg,
A = 1 ;
M = log,
A = 1 ;
M = am2,
A = 2 ;
false.
```

Las pruebas enumeran las respuestas completas de las dos versiones, con todos
los argumentos libres, y la misma lista en el mismo orden. `all` compara la
lista de respuestas tal como se producen, de modo que las dos pruebas verifican
a la vez las respuestas y su orden:

```prolog
test(tomada_con_disyuncion,
     all(L-M-A == [101-pp-2, 103-am2-2, 105-am1-1,
                   101-am1-1, 101-alg-1, 101-log-1, 101-am2-2, 102-log-1,
                   103-am1-1, 104-log-1, 104-alg-1, 104-pp-2, 106-am1-1])) :-
    tomada(L, M, A).

test(tomada_con_dos_clausulas,
     all(L-M-A == [101-pp-2, 103-am2-2, 105-am1-1,
                   101-am1-1, 101-alg-1, 101-log-1, 101-am2-2, 102-log-1,
                   103-am1-1, 104-log-1, 104-alg-1, 104-pp-2, 106-am1-1])) :-
    tomada_en_dos(L, M, A).
```

Las tres primeras respuestas son las de `cursa/2`, en el orden de los hechos de
`inscripcion/3`, y las diez siguientes, las de `aprobada/3`.

El orden se conserva porque la disyunción es el primer objetivo del cuerpo: al
volver atrás, Prolog agota las respuestas de `cursa/2` antes de pasar a las de
`aprobada/3`, igual que agota la primera cláusula antes de pasar a la segunda.

Con `materia(Materia, _, Anio)` antes de la disyunción, el orden cambia. La
versión con `;` recorre las materias, y para cada una da primero quien la cursa
y después quienes la aprobaron: para `am1`, elena (105) y después ana, carla y
facundo (101, 103, 106). La versión con dos cláusulas recorre todas las
materias en la primera cláusula, con los alumnos que las cursan, y recién
después vuelve a recorrerlas en la segunda, con los que las aprobaron: sus
tres primeras respuestas son elena en `am1`, carla en `am2` y ana en `pp`. Las
dos versiones siguen dando el mismo conjunto de respuestas, pero ya no en el
mismo orden, y las dos pruebas ya no podrían compartir la misma lista.

## 17

El bucle no tiene condición de salida. `read/2` da los dos términos, y al
llegar al final del stream da `end_of_file`, y lo sigue dando cada vez que se
lo llama. Después de cada término, `fail` obliga a volver atrás; la única
alternativa pendiente es la de `repeat`, que siempre tiene otra respuesta. El
predicado escribe `a`, `b` y después `end_of_file` indefinidamente, sin
cumplirse ni fallar nunca.

El límite de inferencias lo confirma sin esperar: la consulta escribe `a`, `b`
y 63 líneas `end_of_file` antes de agotar las 200 inferencias.
`call_with_inference_limit/3` es el de las pruebas de rendimiento de la
[sección 26.8](../capitulo-26-pruebas-y-depuracion/index.md#268-el-proyecto-la-bateria-completa).

<!-- ejemplo: capitulo-15/soluciones.pl predicado: eco/1 eco_hasta_el_final/1 escribir_termino/1 consulta: open_string("a. b.", In), eco_hasta_el_final(In). -->
```prolog
%!  eco(+In) is det.
%
%   Escribe, uno por línea, los términos que lee del stream In. El bucle no
%   tiene condición de salida: al final del stream, read/2 da end_of_file
%   cada vez, y el ciclo no termina nunca.
eco(In) :-
    repeat,
    read(In, Termino),
    format("~w~n", [Termino]),
    fail.

%!  eco_hasta_el_final(+In) is det.
%
%   Escribe, uno por línea, los términos que lee del stream In, hasta llegar
%   al final del stream.
eco_hasta_el_final(In) :-
    repeat,
    read(In, Termino),
    escribir_termino(Termino),
    Termino == end_of_file,
    !.

%!  escribir_termino(+Termino) is det.
%
%   Escribe Termino en una línea, salvo la marca de fin del stream.
escribir_termino(Termino) :-
    (   Termino == end_of_file
    ->  true
    ;   format("~w~n", [Termino])
    ).
```

```prolog
?- open_string("a. b.", In), call_with_inference_limit(eco(In), 200, R).
a
b
end_of_file
end_of_file
...
In = <stream>(...),
R = inference_limit_exceeded.
```

La corrección es la forma del [Patrón 7](../patrones.md#7-bucle-por-falla) para un ciclo: leer, ejecutar,
comprobar la condición de salida y cortar. `escribir_termino/1` no escribe la
marca de fin del stream, y la condición `Termino == end_of_file` hace fallar
el ciclo, y volver a `repeat`, mientras quedan términos por leer. Al llegar al
final, la condición se cumple y el corte descarta la alternativa de `repeat`:

```prolog
?- open_string("a. b.", In), eco_hasta_el_final(In).
a
b
In = <stream>(...).
```

Con el mismo límite de 200 inferencias, la versión corregida termina y
`call_with_inference_limit/3` liga `R` con `!`: el objetivo se cumplió sin
dejar alternativas.
