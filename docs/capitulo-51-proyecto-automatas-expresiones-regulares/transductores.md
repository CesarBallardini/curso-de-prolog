# Transductores

Esta página contiene la [sección 51.7](index.md#517-transductores) del
[capítulo 51](index.md): los transductores finitos, las máquinas de Mealy, y los
circuitos secuenciales del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md) ejecutados como máquinas de Mealy. Los
ejemplos están en `transductores.pl` y `secuencial.pl`, en `ejemplos/capitulo-51/`,
con sus pruebas; son módulos, y se ejecutan localmente. El
[capítulo 53](../capitulo-53-proyecto-morfologia-castellano/index.md) carga el
módulo `transductores`.

## Transductores

Un **transductor** es un autómata que escribe mientras lee. `transductores.pl`
lo describe con las mismas relaciones del módulo `automatas`, con un
símbolo que es un par `Entrada:Salida` de listas: la cadena que la
transición lee y la que escribe. `[a]:[b]` cambia a por b, `[a]:[]` borra
a, `[]:[e, s]` inserta es. Como cada par es un símbolo, todo lo anterior
—el determinista, la intersección, el mínimo— se aplica a un transductor
sin cambios. Lo propio es `transducir/3`, que relaciona una palabra de
entrada con una de salida:

<!-- ejemplo: capitulo-51/transductores.pl predicado: transducir/3 traducir/5 -->
```prolog
%!  transducir(+T, ?Entrada:list, ?Salida:list) is nondet.
%
%   El transductor T transforma la palabra Entrada en la palabra Salida:
%   hay un camino desde su estado inicial hasta uno final cuyas entradas,
%   concatenadas, son Entrada, y cuyas salidas son Salida. Una de las dos
%   palabras debe llegar ligada. Da cada par una vez, y termina si T no
%   tiene ciclos que lean nada en el sentido consultado.
transducir(T, Entrada, Salida) :-
    inicial(T, Q0),
    traducir(T, Q0, Entrada, Salida, Q),
    final(T, Q).

%!  traducir(+T, +Q0, ?Entrada:list, ?Salida:list, -Q) is nondet.
%
%   T pasa de Q0 a Q leyendo Entrada y escribiendo Salida. Tabulada: los
%   ciclos de transiciones ε no impiden que termine, y cada respuesta
%   aparece una vez.
traducir(_T, Q, [], [], Q).
traducir(T, Q0, Entrada, Salida, Q) :-
    epsilon(T, Q0, Q1),
    traducir(T, Q1, Entrada, Salida, Q).
traducir(T, Q0, Entrada, Salida, Q) :-
    delta(T, Q0, E:S, Q1),
    E-S \== []-[],
    append(E, Entrada1, Entrada),
    append(S, Salida1, Salida),
    traducir(T, Q1, Entrada1, Salida1, Q).
```

`append/3` consume la entrada si llega ligada, y la construye si llega
libre; lo mismo con la salida. Por eso `transducir/3` se consulta en los dos
sentidos, y la tabla asegura que termina aunque haya ciclos ε y que cada
par aparece una vez.

Una **máquina de Mealy** es el caso en que cada transición lee un símbolo y
escribe uno: la salida depende del estado y de la entrada. `gray` convierte
un número binario en su código Gray, y su estado es el bit anterior; en el
sentido inverso, decodifica:

```prolog
?- transducir(gray, [1, 0, 1, 1], G).
G = [1, 1, 1, 0].

?- transducir(gray, B, [1, 1, 1, 0]).
B = [1, 0, 1, 1].
```

`plural` escribe el plural de un sustantivo: agrega s después de una
vocal, es después de una consonante, y cambia una z final por c. Para
saber si una z es la última letra, el transductor no mira hacia adelante:
al leerla, **elige**. Si la escribe como c, pasa a un estado que solo puede
terminar agregando es; si la copia, a uno que no puede terminar allí. El
no determinismo se resuelve al final de la palabra, como en `termina_ab`:

<!-- ejemplo: capitulo-51/transductores.pl fragmento: automatas:inicial(plural, inicio). .. automatas:delta(plural, z_final, []:[e, s], fin). -->
```prolog
automatas:inicial(plural, inicio).
automatas:final(plural, fin).
automatas:delta(plural, Q, [L]:[L], Q1) :-
    member(Q, [inicio, vocal, consonante, z]),
    letra(L),
    L \== z,
    (   vocal(L)
    ->  Q1 = vocal
    ;   Q1 = consonante
    ).
automatas:delta(plural, Q, [z]:[z], z) :-
    member(Q, [inicio, vocal, consonante, z]).
automatas:delta(plural, Q, [z]:[c], z_final) :-
    member(Q, [inicio, vocal, consonante, z]).
automatas:delta(plural, vocal, []:[s], fin).
automatas:delta(plural, consonante, []:[e, s], fin).
automatas:delta(plural, z_final, []:[e, s], fin).
```

```prolog
?- transducir(plural, [l, u, z], P).
P = [l, u, c, e, s] ;
false.

?- transducir(plural, W, [c, a, s, a]).
false.
```

Usado en sentido inverso, el transductor analiza: las palabras cuyo plural
es *luces* son *luz*, *luce* y *luc*, como mostró la consulta del
comienzo del [capítulo](index.md). Las tres respetan la ortografía; elegir la que
existe requiere un diccionario. Es la **morfología de dos niveles**, que
relaciona la forma léxica de una palabra con su forma escrita mediante
transductores de pares de letras, y que el
[capítulo 53](../capitulo-53-proyecto-morfologia-castellano/index.md)
desarrolla cargando este módulo. Para eso el módulo define tres
construcciones más: `inversa(T)`, que intercambia entrada y salida;
`compuesta(T1, T2)`, donde la salida de T1 es la entrada de T2; e
`identidad(Sigma)`, que copia los símbolos de Sigma.

```prolog
?- transducir(compuesta(gray, inversa(gray)), [1, 0, 1, 1], W).
W = [1, 0, 1, 1].

?- acepta(gray, [[1]:[1], [0]:[1]]).
true.
```

La segunda consulta usa `gray` como un autómata sobre pares: el par de
palabras 10 y 11 es una traducción de gray.

## Un circuito secuencial es una máquina de Mealy

Un circuito secuencial sincrónico del
[capítulo 48](../capitulo-48-proyecto-circuitos-logicos/secuenciales.md#circuitos-secuenciales)
tiene un conjunto finito de estados, los valores de su registro; en cada
pulso lee las entradas y, según el estado, da las salidas y pasa a otro
estado. Es una máquina de Mealy cuyos símbolos son las listas de bits de un
pulso. `secuencial.pl` carga los módulos `circuitos` y `estados` de ese
capítulo y define `circuito(Nombre, Estado0)`, el transductor de un circuito
desde un estado, con una transición por cada arco de `transicion/5`:

<!-- ejemplo: capitulo-51/secuencial.pl fragmento: automatas:alfabeto(circuito(Nombre, E0), Sigma) :- .. transicion(Nombre, E, Es, Ss, E1). -->
```prolog
automatas:alfabeto(circuito(Nombre, E0), Sigma) :-
    findall(P,
            ( alcanzable(circuito(Nombre, E0), E),
              delta(circuito(Nombre, E0), E, P, _) ),
            Sigma0),
    sort(Sigma0, Sigma).
automatas:inicial(circuito(_Nombre, E0), E0).
automatas:final(circuito(_Nombre, _E0), _E).
automatas:delta(circuito(Nombre, _E0), E, [Es]:[Ss], E1) :-
    transicion(Nombre, E, Es, Ss, E1).
```

```prolog
?- transducir(circuito(paridad, [0]), [[1], [0], [0], [1]], Ss).
Ss = [[1], [1], [1], [0]].

?- numero_estados(circuito(contador_gray, [0, 0, 0]), N).
N = 8.

?- numero_estados(min(circuito(registro4, [0, 0, 0, 0])), N).
N = 17.
```

La primera consulta da lo mismo que `ejecutar/4` del [capítulo 48](../capitulo-48-proyecto-circuitos-logicos/index.md), y la
segunda, los ocho estados que `alcanzables/3` encontraba allí. La tercera
minimiza el registro de desplazamiento: sus 16 estados son distinguibles,
porque cada uno recuerda cuatro entradas distintas que la salida mostrará,
y el mínimo agrega solo el sumidero de los pares que el circuito nunca
produce. Minimizar un circuito secuencial es minimizar su autómata.

El mismo archivo define un **sumador serie**, que suma dos números binarios
con un par de bits por pulso, el menos significativo primero: su estado es
el acarreo, y cada transición es el sumador completo del módulo
`circuitos`. Su estado final es el que no tiene acarreo, es decir, la suma
cabe en la misma cantidad de bits. En sentido inverso, enumera los pares de
números que suman un resultado dado:

```prolog
?- transducir(sumador_serie, [[1, 1], [0, 1], [0, 0]], S).
S = [0, 0, 1].

?- transducir(sumador_serie, Ps, [0, 1, 1]).
Ps = [[1, 1], [1, 1], [0, 0]] ;
Ps = [[1, 1], [0, 0], [1, 0]] ;
Ps = [[1, 1], [0, 0], [0, 1]] ;
Ps = [[0, 0], [1, 0], [1, 0]] ;
Ps = [[0, 0], [1, 0], [0, 1]] ;
Ps = [[0, 0], [0, 1], [1, 0]] ;
Ps = [[0, 0], [0, 1], [0, 1]].
```

1 + 3 = 4, y los siete pares de números de tres bits que suman 6: 3 + 3,
1 + 5, 5 + 1, 2 + 4, 6 + 0, 0 + 6 y 4 + 2, en el orden de la tabla.
