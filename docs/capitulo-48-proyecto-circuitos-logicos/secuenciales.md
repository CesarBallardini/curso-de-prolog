# Circuitos secuenciales

Esta página contiene las secciones [48.5](index.md#485-circuitos-secuenciales),
[48.6](index.md#486-los-estados-alcanzables) y
[48.8](index.md#488-retardos-en-cascada) del [capítulo 48](index.md): los
circuitos secuenciales, ejecutados pulso a pulso, el grafo de sus estados
alcanzables, tabulado, y los retardos en cascada. Los ejemplos están en
`secuenciales.pl`, `estados.pl` y `retardos.pl`, en
`ejemplos/capitulo-48/`, con sus pruebas; cargan el módulo `circuitos`, y se
ejecutan localmente.

## Circuitos secuenciales

Un circuito **secuencial** sincrónico separa la memoria de la lógica: un
**registro** de biestables D guarda el estado, una lista de bits, y un
circuito combinacional calcula, a partir de las entradas y del estado
actual, las salidas y el estado siguiente. Todos los biestables comparten el
reloj, y en cada pulso el registro copia el estado siguiente, que se vuelve
el actual. Entre dos pulsos no ocurre nada que el modelo necesite ver; como
en Clocksin («Manipulation of Clocked Sequential Circuits»), cada componente tarda un pulso y todos van
sincronizados.

`secuenciales.pl` representa un circuito secuencial con un hecho que nombra
su parte combinacional y la cantidad de bits de estado, y la parte
combinacional es un circuito más del módulo `circuitos`, cuyas entradas son
las externas seguidas del estado actual, y sus salidas, las externas
seguidas del estado siguiente:

<!-- ejemplo: capitulo-48/secuenciales.pl fragmento: secuencial(divisor, divisor_c, 1). .. circuitos:circuito(registro4_c, [x, q1, q2, q3, q4], [q4, x, q1, q2, q3]). -->
```prolog
secuencial(divisor, divisor_c, 1).
secuencial(paridad, paridad_c, 1).
secuencial(registro4, registro4_c, 4).
secuencial(contador_gray, contador_gray_c, 3).

% Divisor por dos: la salida es el estado, que se invierte en cada pulso.
circuitos:circuito(divisor_c, [q], [q, d]).
circuitos:componente(divisor_c, i1, inv, [q], [d]).

% Paridad: el estado siguiente es el anterior XOR la entrada, y la salida
% es el estado siguiente: 1 si llegó una cantidad impar de unos.
circuitos:circuito(paridad_c, [x, p], [n, n]).
circuitos:componente(paridad_c, x1, xor, [x, p], [n]).

% Registro de desplazamiento de cuatro etapas: solo cables. La entrada
% pasa a la primera etapa, cada etapa a la siguiente, y la salida es la
% cuarta.
circuitos:circuito(registro4_c, [x, q1, q2, q3, q4], [q4, x, q1, q2, q3]).
```

El divisor por dos tiene un bit de estado que se invierte en cada pulso, y
su salida es el estado: cambia cada dos pulsos. El verificador de paridad
acumula la disyunción exclusiva de los bits que recibe. El registro de
desplazamiento no tiene compuertas: sus salidas son sus entradas en otro
orden, y el nombre de un cable de entrada puede aparecer como salida. Un paso
del reloj es una simulación de la parte combinacional, y ejecutar el
circuito es recorrer la lista de entradas, una por pulso, llevando el estado:
un `foldl/6` ([sección 18.3](../capitulo-18-orden-superior/index.md#183-foldl46)) cuyo acumulador es el estado.

<!-- ejemplo: capitulo-48/secuenciales.pl predicado: paso/5 ejecutar/4 pulso/5 -->
```prolog
%!  paso(+Nombre, +Estado0:list, ?Entradas:list, ?Salidas:list,
%!       ?Estado:list) is nondet.
%
%   En un pulso del reloj, el circuito secuencial Nombre, en el estado
%   Estado0 y con las Entradas, da las Salidas y pasa al Estado.
paso(Nombre, Estado0, Entradas, Salidas, Estado) :-
    secuencial(Nombre, Combinacional, K),
    length(Estado0, K),
    length(Estado, K),
    circuito(Combinacional, NEs, NSs),
    length(NEs, NE),
    length(NSs, NS),
    NEntradas is NE - K,
    NSalidas is NS - K,
    length(Entradas, NEntradas),
    length(Salidas, NSalidas),
    append(Entradas, Estado0, Es),
    append(Salidas, Estado, Ss),
    simular(Combinacional, Es, Ss).

%!  ejecutar(+Nombre, +Estado0:list, ?Pulsos:list(list),
%!           ?Salidas:list(list)) is nondet.
%
%   Salidas son las salidas del circuito secuencial Nombre en cada pulso,
%   a partir del Estado0, cuando Pulsos son sus entradas en cada pulso.
%   Una de las dos listas debe tener longitud conocida.
ejecutar(Nombre, Estado0, Pulsos, Salidas) :-
    foldl(pulso(Nombre), Pulsos, Salidas, Estado0, _).

%!  pulso(+Nombre, +Entradas:list, -Salidas:list, +Estado0:list,
%!        -Estado:list) is nondet.
%
%   Un paso, con los argumentos en el orden de foldl/6.
pulso(Nombre, Entradas, Salidas, Estado0, Estado) :-
    paso(Nombre, Estado0, Entradas, Salidas, Estado).
```

```prolog
?- ejecutar(divisor, [0], [[], [], [], [], []], Ss).
Ss = [[0], [1], [0], [1], [0]].

?- ejecutar(paridad, [0], [[1], [0], [0], [1], [1], [0]], Ss).
Ss = [[1], [1], [1], [0], [1], [1]] ;
false.

?- ejecutar(registro4, [0, 0, 0, 0], [[1], [0], [0], [1], [1], [0], [0], [1]], Ss).
Ss = [[0], [0], [0], [0], [1], [0], [0], [1]].
```

El divisor no tiene entradas externas: cada pulso es una lista vacía. La
paridad es 1 después de los tres primeros pulsos, porque hasta ahí llegó
un solo 1, y es 0 después del cuarto, que trae el segundo. El registro repite
su entrada cuatro pulsos después. Como `paso/5` es una simulación, y la
simulación es una relación, el recorrido también se hace en sentido inverso:
dadas las salidas de la paridad, se obtienen las entradas que las producen.

```prolog
?- ejecutar(paridad, [0], Ps, [[1], [1], [0]]).
Ps = [[1], [0], [1]] ;
false.
```

La jerarquía de la segunda versión también sirve aquí. El contador en código
Gray combina dos circuitos: `incremento3` suma 1 a un número de tres bits, y
`gray3` convierte un número a su código Gray, en el que dos números
consecutivos difieren en un solo bit. El estado es un contador binario, y la
salida, su código:

<!-- ejemplo: capitulo-48/secuenciales.pl fragmento: % Incremento de un número .. [g0, g1, g2]). -->
```prolog
% Incremento de un número de tres bits, el menos significativo primero,
% módulo 8.
circuitos:circuito(incremento3, [b0, b1, b2], [n0, n1, n2]).
circuitos:componente(incremento3, i1, inv, [b0], [n0]).
circuitos:componente(incremento3, x1, xor, [b1, b0], [n1]).
circuitos:componente(incremento3, y1, and, [b1, b0], [c1]).
circuitos:componente(incremento3, x2, xor, [b2, c1], [n2]).

% El código Gray de un número de tres bits: cada bit XOR el siguiente, y
% el más significativo sin cambios.
circuitos:circuito(gray3, [b0, b1, b2], [g0, g1, b2]).
circuitos:componente(gray3, x1, xor, [b0, b1], [g0]).
circuitos:componente(gray3, x2, xor, [b1, b2], [g1]).

% Contador Gray: un contador binario de tres bits cuya salida es el código
% Gray del estado.
circuitos:circuito(contador_gray_c, [b0, b1, b2], [g0, g1, g2, n0, n1, n2]).
circuitos:componente(contador_gray_c, inc, incremento3, [b0, b1, b2],
                     [n0, n1, n2]).
circuitos:componente(contador_gray_c, cod, gray3, [b0, b1, b2],
                     [g0, g1, g2]).
```

```prolog
?- ejecutar(contador_gray, [0, 0, 0], [[], [], [], [], [], []], Ss).
Ss = [[0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0], [0, 1, 1], [1, 1, 1]] ;
false.
```

Leídas con el bit más significativo a la izquierda, las salidas son 000,
001, 011, 010, 110 y 111: entre cada una y la siguiente cambia un bit. Seis
pulsos lo muestran para seis estados; que valga para todos, y para toda
sucesión de entradas en los circuitos que las tienen, es una pregunta que
ninguna ejecución responde.

## Los estados alcanzables

Los estados de un circuito secuencial y los pasos entre ellos forman un
grafo: un arco por cada estado, cada combinación de entradas y el estado
siguiente. `estados.pl` enumera los arcos con `transicion/5`, que es
`paso/5` con las entradas enumeradas cuando llegan libres, y define los
estados alcanzables desde uno inicial como la clausura del grafo. El grafo
tiene ciclos —el divisor vuelve a 0, el contador vuelve a empezar—, y la
definición con la recursión a la izquierda no termina sin tabla:

<!-- ejemplo: capitulo-48/estados.pl predicado: alcanzable_sin_tabla/3 -->
```prolog
%!  alcanzable_sin_tabla(+Nombre, +Estado0:list, ?Estado:list) is nondet.
%
%   El circuito Nombre pasa de Estado0 a Estado en uno o más pulsos. Sin
%   tabla, la recursión a la izquierda no termina.
alcanzable_sin_tabla(Nombre, Estado0, Estado) :-
    transicion(Nombre, Estado0, _, _, Estado).
alcanzable_sin_tabla(Nombre, Estado0, Estado) :-
    alcanzable_sin_tabla(Nombre, Estado0, Estado1),
    transicion(Nombre, Estado1, _, _, Estado).
```

```prolog
?- findall(E, limit(6, alcanzable_sin_tabla(divisor, [0], E)), Es).
Es = [[1], [0], [1], [0], [1], [0]].

?- call_with_inference_limit(findall(E, alcanzable_sin_tabla(divisor, [0], E), _), 1000000, R).
R = inference_limit_exceeded.
```

Las mismas cláusulas con la directiva `table` de la
[sección 39.1](../capitulo-39-tabulacion/index.md#391-table-recursion-a-la-izquierda-y-ciclos) dan cada estado una vez y terminan:

<!-- ejemplo: capitulo-48/estados.pl fragmento: :- table alcanzable/3. .. transicion(Nombre, Estado1, _, _, Estado). -->
```prolog
:- table alcanzable/3.

%!  alcanzable(+Nombre, +Estado0:list, ?Estado:list) is nondet.
%
%   La misma relación, tabulada: cada estado una vez, y la consulta
%   termina.
alcanzable(Nombre, Estado0, Estado) :-
    transicion(Nombre, Estado0, _, _, Estado).
alcanzable(Nombre, Estado0, Estado) :-
    alcanzable(Nombre, Estado0, Estado1),
    transicion(Nombre, Estado1, _, _, Estado).
```

```prolog
?- alcanzable(divisor, [0], E).
E = [1] ;
E = [0].

?- aggregate_all(count, alcanzable(registro4, [0, 0, 0, 0], _), N).
N = 16.
```

El registro de cuatro etapas alcanza sus 16 estados, porque cualquier
sucesión de cuatro bits puede entrar en él. `grafo/3` reúne los arcos que
salen de los estados alcanzables, y `siempre/3` verifica una condición sobre
cada uno: la propiedad vale para toda entrada, en todo estado al que el
circuito puede llegar.

<!-- ejemplo: capitulo-48/estados.pl predicado: grafo/3 siempre/3 -->
```prolog
%!  grafo(+Nombre, +Estado0:list, -Arcos:list) is det.
%
%   Arcos son los arcos E-Entradas/Salidas-E1 que salen de los estados
%   alcanzables desde Estado0, incluido él.
grafo(Nombre, Estado0, Arcos) :-
    alcanzables(Nombre, Estado0, Estados),
    findall(E-Es/Ss-E1,
            ( member(E, Estados),
              transicion(Nombre, E, Es, Ss, E1) ),
            Arcos).

%!  siempre(+Nombre, +Estado0:list, :Condicion) is semidet.
%
%   Cada arco E-Entradas/Salidas-E1 alcanzable desde Estado0 cumple
%   call(Condicion, E, Entradas, Salidas, E1).
siempre(Nombre, Estado0, Condicion) :-
    grafo(Nombre, Estado0, Arcos),
    forall(member(E-Es/Ss-E1, Arcos),
           call(Condicion, E, Es, Ss, E1)).
```

```prolog
?- grafo(paridad, [0], Arcos).
Arcos = [[0]-[0]/[0]-[0], [0]-[1]/[1]-[1], [1]-[0]/[1]-[1], [1]-[1]/[0]-[0]].

?- siempre(paridad, [0], [[P], [X], _, [N]]>>(N =:= P xor X)).
true.

?- siempre(contador_gray, [0, 0, 0], [_, _, S, E1]>>(transicion(contador_gray, E1, _, S1, _), distancia(S, S1, 1))).
true.
```

El arco `[0]-[1]/[1]-[1]` dice que desde el estado 0, con la entrada 1, la
salida es 1 y el estado pasa a 1. La segunda consulta verifica la definición
de la paridad en los cuatro arcos. La tercera es la propiedad del código
Gray: para cada arco del contador, la salida del estado siguiente difiere de
la actual en un bit, con `distancia/3` como la cantidad de posiciones
distintas. Es la pregunta que la [sección 48.5](#circuitos-secuenciales) no podía responder
ejecutando el circuito, y la tabla la hace terminar aunque el contador
vuelva a su estado inicial.

!!! question "Actividad"
    Predecir cuántos estados alcanza el contador Gray desde `[1, 0, 1]`, y
    cuántos alcanzaría si `incremento3` tuviera la compuerta `x2` conectada
    a `[b2, b0]` en lugar de `[b2, c1]`. Comprobarlo en una copia de
    `secuenciales.pl`, y verificar si con ese error la propiedad del código
    Gray sigue valiendo.

Un circuito secuencial con un grafo de estados finito es un autómata finito
con salidas, y la verificación de una propiedad sobre todos sus estados
alcanzables es, en pequeño, lo que hacen las herramientas de verificación de
hardware.

## Retardos en cascada

Un **retardo unitario** es el circuito secuencial más simple: su salida es
la entrada del pulso anterior. Es un biestable D sin lógica alrededor, y una
etapa del registro de desplazamiento. Clocksin, en el apartado 8.5 de
*Clause and Effect*, «Specification of Cascaded Components», conecta N
retardos en serie sin escribir N: la cascada es una recursión sobre la lista
de los estados de sus etapas, y la cantidad de etapas es la longitud de esa
lista. `retardo/4` es esa recursión, con el estado como primer argumento:

<!-- ejemplo: capitulo-48/retardos.pl predicado: retardo/4 retardar/3 retardo_en_pulso/4 -->
```prolog
%!  retardo(?Estado0:list, ?A, ?Q, ?Estado:list) is det.
%
%   Una cascada de tantos retardos unitarios como elementos tiene Estado0:
%   con la entrada A, la salida es Q, el estado de la última etapa, y
%   Estado es el estado del pulso siguiente: la primera etapa toma A, y
%   cada una de las demás, el estado de la anterior. Sin etapas, Q es A.
%   Estado0 o Estado debe tener longitud conocida. El estado va primero,
%   para que la indexación distinga la lista vacía de la que no lo es.
retardo([], A, A, []).
retardo([S|Ss], A, Q, [A|Zs]) :-
    retardo(Ss, S, Q, Zs).

%!  retardar(?Entradas:list, +Estado0:list, ?Salidas:list) is det.
%
%   Salidas son las salidas de la cascada de retardo/4 en cada pulso,
%   desde el Estado0, cuando Entradas son sus entradas. Una de las dos
%   listas debe tener longitud conocida.
retardar(Entradas, Estado0, Salidas) :-
    foldl(retardo_en_pulso, Entradas, Salidas, Estado0, _).

%!  retardo_en_pulso(?A, ?Q, +Estado0:list, -Estado:list) is det.
%
%   retardo/4 con los argumentos en el orden de foldl/6.
retardo_en_pulso(A, Q, Estado0, Estado) :-
    retardo(Estado0, A, Q, Estado).
```

En cada pulso, la primera etapa toma la entrada, cada una de las demás toma
el estado de la anterior, y la salida es el estado de la última. Sin etapas,
la salida es la entrada. Con los mismos ocho pulsos que usa Clocksin, tres
retardos dan la entrada desplazada tres pulsos; en sentido inverso, las
salidas determinan las entradas de todos los pulsos menos los últimos, que
todavía no salieron de la cascada:

```prolog
?- retardar([1, 1, 0, 0, 1, 1, 0, 0], [0, 0, 0], Qs).
Qs = [0, 0, 0, 1, 1, 0, 0, 1].

?- retardo([S1, S2], A, Q, E).
S2 = Q,
E = [A, S1].

?- retardar(Es, [0, 0], [0, 0, 1, 0]).
Es = [1, 0, _, _].
```

La segunda consulta muestra la cascada entera de una vez, con variables en
lugar de valores: la salida es el estado de la última etapa, y el estado
siguiente es la entrada seguida de los estados de las etapas anteriores a la
última.

El mismo circuito, descrito para el simulador del capítulo, es el registro
de desplazamiento de la [sección 48.5](#circuitos-secuenciales) con N etapas.
La descripción no puede ser un hecho, porque la lista de cables depende de
N, pero puede ser una regla: `circuitos:circuito/3` y
`secuenciales:secuencial/3` admiten cláusulas con cuerpo, y la de
`desplazamiento_c(N)` genera los nombres `q1`, …, `qN` con `etapas/2`:

<!-- ejemplo: capitulo-48/retardos.pl fragmento: %!  etapas(+N .. append(Previas, [Ultima], Qs). -->
```prolog
%!  etapas(+N:integer, -Nombres:list(atom)) is det.
%
%   Nombres son los nombres de los cables de estado de un registro de N
%   etapas: q1, q2, ..., qN.
etapas(N, Nombres) :-
    findall(Q,
            ( between(1, N, I),
              atom_concat(q, I, Q) ),
            Nombres).

% desplazamiento(N): un registro de desplazamiento de N etapas, para
% cualquier N positivo. La parte combinacional son solo cables: la salida
% es la última etapa, la entrada pasa a la primera y cada etapa a la
% siguiente.
secuenciales:secuencial(desplazamiento(N), desplazamiento_c(N), N) :-
    integer(N),
    N > 0.

circuitos:circuito(desplazamiento_c(N), [x|Qs], [Ultima, x|Previas]) :-
    integer(N),
    N > 0,
    etapas(N, Qs),
    N1 is N - 1,
    length(Previas, N1),
    append(Previas, [Ultima], Qs).
```

`integer(N)` hace que la regla no se aplique a un nombre con N libre, y así
una consulta que recorre todos los circuitos no genera infinitos registros.
`ejecutar/4` acepta `desplazamiento(3)` como cualquier otro circuito
secuencial, y da las salidas de la cascada:

```prolog
?- ejecutar(desplazamiento(3), [0, 0, 0], [[1], [1], [0], [0], [1], [1], [0], [0]], Ss).
Ss = [[0], [0], [0], [1], [1], [0], [0], [1]].
```

Las pruebas de `retardos.plt` comparan las dos versiones para N de 1 a 5,
comparan `desplazamiento(4)` con `registro4`, y cuentan con `alcanzable/3`
los 8 estados de `desplazamiento(3)`. La recursión de Clocksin da un circuito
de cualquier tamaño en pocas líneas; la descripción como datos lo hace
visible para las demás preguntas del capítulo, desde la simulación en
sentido inverso hasta el grafo de estados.

!!! question "Actividad"
    Escribir con `retardo/4` un detector de flancos: su salida es 1 en el
    pulso en que la entrada pasa de 0 a 1, y para eso necesita una sola
    etapa. Comprobarlo con la entrada `[0, 1, 1, 0, 1]`.
