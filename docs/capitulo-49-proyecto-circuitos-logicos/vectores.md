# Los productos como vectores de signos y los retardos en cascada

Esta página continúa la página
[Circuitos secuenciales](secuenciales.md#496-los-estados-alcanzables) del
[capítulo 49](index.md), con las secciones
[49.7](#497-los-productos-como-vectores-de-signos) y
[49.8](#498-retardos-en-cascada): la representación de los productos de una
suma de productos como vectores de signos, la absorción y la combinación
posición por posición, y los implicantes primos de una salida; y, de vuelta
en los circuitos secuenciales, los retardos en cascada. Los ejemplos están en
`vectores.pl` y `retardos.pl`, en `ejemplos/capitulo-49/`, con sus pruebas;
cargan los módulos `circuitos`, `formulas` y `secuenciales`, y se ejecutan
localmente.

## 49.7 Los productos como vectores de signos

La suma de productos de la [sección 49.3](index.md#493-que-calcula-un-circuito)
escribe cada producto como una lista de literales, y `simplificar/2` tiene
que buscar en ella un literal y su negación, o un producto contenido en
otro. Clocksin, en el apartado 7.5 de *Clause and Effect*, «Alternative
Representation», observa que cuando las variables son pocas y se conocen de
antemano conviene otra estructura: un signo por variable, en un orden fijo,
`+` si la variable aparece, `-` si aparece negada y `0` si no aparece. Con
las variables a, b y ci, el producto a · ci · ¬b es `[+, -, +]`. Clocksin lo
escribe como un término `p(+, -, +)`; una lista sirve para cualquier
cantidad de variables. `vectores.pl` traduce entre las dos
representaciones:

<!-- ejemplo: capitulo-49/vectores.pl predicado: vector/3 signo/3 producto_de_vector/3 literal_de/4 -->
```prolog
%!  vector(+Nombres:list(atom), +Producto:list, -Signos:list) is det.
%
%   Signos tiene un signo por cada nombre de Nombres: + si el nombre
%   aparece en Producto, - si aparece negado, y 0 si no aparece. Producto
%   no es contradictorio.
vector(Nombres, Producto, Signos) :-
    maplist(signo(Producto), Nombres, Signos).

%!  signo(+Producto:list, +Nombre:atom, -S) is det.
%
%   S es el signo de Nombre en Producto.
signo(Producto, Nombre, S) :-
    (   memberchk(Nombre, Producto)
    ->  S = (+)
    ;   memberchk(~Nombre, Producto)
    ->  S = (-)
    ;   S = 0
    ).

%!  producto_de_vector(+Nombres:list(atom), +Signos:list,
%!                     -Producto:list) is det.
%
%   Producto es la lista de literales del vector Signos, en el orden de
%   Nombres: el nombre si el signo es +, su negación si es -, y nada si
%   es 0.
producto_de_vector([], [], []).
producto_de_vector([N|Ns], [S|Ss], Producto) :-
    literal_de(S, N, Producto, Resto),
    producto_de_vector(Ns, Ss, Resto).

%!  literal_de(+S, +Nombre:atom, -Producto:list, ?Resto:list) is det.
%
%   Producto es Resto precedido por el literal de Nombre con el signo S, o
%   Resto si S es 0.
literal_de(0, _, Resto, Resto).
literal_de(+, N, [N|Resto], Resto).
literal_de(-, N, [~N|Resto], Resto).
```

```prolog
?- vector([a, b, ci], [a, ci, ~b], V).
V = [+, -, +].

?- producto_de_vector([a, b, ci], [-, 0, +], P).
P = [~a, ci].
```

En un vector, un producto contradictorio no se puede escribir: cada variable
tiene un solo signo. La absorción P + P · Q = P se decide posición por
posición: un vector **cubre** a otro si en cada posición tiene `0` o el
mismo signo. Y la ley X · Y + X · ¬Y = X, que en la lista de literales
obliga a buscar el par, en los vectores es la comparación de dos listas que
difieren en una sola posición, con `+` en una y `-` en la otra:

<!-- ejemplo: capitulo-49/vectores.pl predicado: cubre/2 cubre_signo/2 combinar/3 opuestos/2 -->
```prolog
%!  cubre(+V:list, +W:list) is semidet.
%
%   Cada literal del producto V está en el producto W: en una suma, V
%   absorbe a W (P + P·Q = P). En cada posición, el signo de V es 0 o el
%   mismo que el de W.
cubre(V, W) :-
    maplist(cubre_signo, V, W).

%!  cubre_signo(+S, +T) is semidet.
%
%   El signo S cubre al signo T: S es 0, o los dos son iguales.
cubre_signo(0, _).
cubre_signo(+, +).
cubre_signo(-, -).

%!  combinar(+V:list, +W:list, -C:list) is semidet.
%
%   V y W difieren solo en una posición, con + en uno y - en el otro, y C
%   es el vector con 0 en esa posición: X·Y + X·¬Y = X.
combinar([S|Vs], [T|Ws], [C|Cs]) :-
    (   S == T
    ->  C = S,
        combinar(Vs, Ws, Cs)
    ;   opuestos(S, T),
        C = 0,
        Vs == Ws,
        Cs = Vs
    ).

%!  opuestos(?S, ?T) is nondet.
%
%   S y T son los signos de una variable y de su negación.
opuestos(+, -).
opuestos(-, +).
```

Repetir esa combinación es el primer paso del método de Quine y McCluskey.
`unos/3` da un vector por cada fila de la tabla de verdad en la que la
salida vale 1, con `+` para cada entrada en 1 y `-` para cada una en 0;
`implicantes_primos/2` combina los vectores de a dos, se queda con los que
no se combinan con ningún otro, y repite con los combinados hasta que no
quedan pares:

<!-- ejemplo: capitulo-49/vectores.pl predicado: unos/3 signo_de_bit/2 implicantes_primos/2 -->
```prolog
%!  unos(+Circuito, +Salida, -Vectores:list(list)) is semidet.
%
%   Vectores tiene un vector por cada fila de la tabla de verdad de
%   Circuito en la que Salida vale 1: + para una entrada en 1 y - para
%   una en 0, en el orden de las entradas. Falla si Salida no es una
%   salida de Circuito.
unos(Circuito, Salida, Vectores) :-
    circuito(Circuito, _, Salidas),
    nth1(I, Salidas, Salida),
    !,
    tabla_de_verdad(Circuito, Filas),
    findall(V,
            ( member(Es-Ss, Filas),
              nth1(I, Ss, 1),
              maplist(signo_de_bit, Es, V) ),
            Vectores).

%!  signo_de_bit(?Bit, ?S) is nondet.
%
%   S es el signo de una entrada con el valor Bit.
signo_de_bit(1, +).
signo_de_bit(0, -).

%!  implicantes_primos(+Vectores:list(list), -Primos:list(list)) is det.
%
%   Primos son los vectores que se obtienen combinando los de Vectores de
%   a dos, mientras se pueda, y que ya no se combinan con ningún otro: los
%   implicantes primos de la suma, en el orden estándar.
implicantes_primos(Vectores0, Primos) :-
    sort(Vectores0, Vectores),
    findall(C-[V, W],
            ( member(V, Vectores),
              member(W, Vectores),
              V @< W,
              combinar(V, W, C) ),
            Pares),
    (   Pares == []
    ->  Primos = Vectores
    ;   pairs_keys_values(Pares, Combinados, Usados0),
        append(Usados0, Usados1),
        sort(Usados1, Usados),
        ord_subtract(Vectores, Usados, Restantes),
        implicantes_primos(Combinados, Primos1),
        ord_union(Restantes, Primos1, Primos)
    ).
```

```prolog
?- unos(sumador, co, Vs), implicantes_primos(Vs, Ps).
Vs = [[-, +, +], [+, -, +], [+, +, -], [+, +, +]],
Ps = [[0, +, +], [+, 0, +], [+, +, 0]].

?- unos(sumador, s, Vs), implicantes_primos(Vs, Ps).
Vs = [[-, -, +], [-, +, -], [+, -, -], [+, +, +]],
Ps = [[+, +, +], [+, -, -], [-, +, -], [-, -, +]].
```

Los implicantes primos del acarreo son b · ci, a · ci y a · b: el acarreo es
la mayoría de las tres entradas, la forma del circuito `sumador_mayoria` de
la [sección 49.4](verificacion.md#494-verificar-con-libraryclpb). La suma de productos de
`suma_de_productos/2` para la misma salida, `[[a, b], [a, ci, ~b], [b, ci,
~a]]`, es correcta pero no mínima, porque la absorción no reduce un producto
con la ley de la combinación. La salida s no se reduce: en la suma de tres
bits, dos filas en 1 nunca difieren en una sola entrada. Elegir, entre los
implicantes primos, los que hacen falta para cubrir todas las filas es el
segundo paso del método, y lo pide el [ejercicio 11](#ejercicios).

!!! question "Actividad"
    Predecir los implicantes primos de la salida de `xor_nand` y de la
    salida `c` del semisumador, y comprobarlo con `unos/3` e
    `implicantes_primos/2`. Explicar por qué uno de los dos resultados tiene
    un solo vector.

## 49.8 Retardos en cascada

Un **retardo unitario** es el circuito secuencial más simple: su salida es
la entrada del pulso anterior. Es un biestable D sin lógica alrededor, y una
etapa del registro de desplazamiento. Clocksin, en el apartado 8.5 de
*Clause and Effect*, «Specification of Cascaded Components», conecta N
retardos en serie sin escribir N: la cascada es una recursión sobre la lista
de los estados de sus etapas, y la cantidad de etapas es la longitud de esa
lista. `retardo/4` es esa recursión, con el estado como primer argumento:

<!-- ejemplo: capitulo-49/retardos.pl predicado: retardo/4 retardar/3 retardo_en_pulso/4 -->
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
de desplazamiento de la [sección 49.5](secuenciales.md#495-circuitos-secuenciales) con N etapas.
La descripción no puede ser un hecho, porque la lista de cables depende de
N, pero puede ser una regla: `circuitos:circuito/3` y
`secuenciales:secuencial/3` admiten cláusulas con cuerpo, y la de
`desplazamiento_c(N)` genera los nombres `q1`, …, `qN` con `etapas/2`:

<!-- ejemplo: capitulo-49/retardos.pl fragmento: %!  etapas(+N .. append(Previas, [Ultima], Qs). -->
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

El capítulo continúa en la página
[Compuertas hechas con transistores](transistores.md#499-compuertas-hechas-con-transistores),
con las compuertas construidas a partir de los transistores que las forman.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y el [capítulo 50](../capitulo-50-proyecto-diagnostico-abduccion/index.md) los da por hechos.

11. ★ **(3)** Escribir `cobertura(Unos, Primos, Elegidos)`: Elegidos es la
    menor cantidad de vectores de Primos que cubre todos los vectores de
    Unos, el segundo paso del método de Quine y McCluskey. Aplicarlo al
    acarreo del sumador, y a la salida que vale 1 en las filas a · ¬b · ¬c,
    a · ¬b · c, a · b · c y ¬a · b · c, cuyos implicantes primos son tres y
    de los que basta con dos.
12. **(1)** Predecir, sin ejecutarlas, las respuestas de
    `retardar([1, 0, 1, 1], [0, 0], Qs)` y de
    `retardar(Es, [0, 0], [0, 0, 1, 0])`, y comprobarlo. ¿Cuántos estados
    alcanza `desplazamiento(N)` desde N ceros, y por qué?

## Referencias

- William F. Clocksin, *Clause and Effect: Prolog Programming for the
  Working Programmer*, Springer, 1997. Del apartado 7.5, «Alternative
  Representation», esta página toma los productos como vectores de signos
  de la [sección 49.7](#497-los-productos-como-vectores-de-signos), y del
  apartado 8.5, «Specification of Cascaded Components», los retardos en
  cascada de la [sección 49.8](#498-retardos-en-cascada).
- W. V. Quine, «The problem of simplifying truth functions», *The American
  Mathematical Monthly* 59 (8), 1952, págs. 521–531, y E. J. McCluskey,
  «Minimization of Boolean functions», *The Bell System Technical Journal*
  35 (6), 1956, págs. 1417–1444. Son el origen del método que combina
  productos que difieren en una variable para obtener los implicantes
  primos, cuyo primer paso escribe la
  [sección 49.7](#497-los-productos-como-vectores-de-signos) y cuyo segundo
  paso pide el [ejercicio 11](#ejercicios). No tienen edición en línea
  gratuita.
