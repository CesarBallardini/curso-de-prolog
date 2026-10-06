# Cinco ampliaciones: probabilidades, certezas y aprendizaje

Esta página continúa el [capítulo 66](index.md) con cinco temas que las
fuentes del capítulo tratan y las cinco versiones dejan afuera. Los dos
primeros vienen del capítulo de Rowe sobre la incertidumbre: la regla de Bayes, que obtiene una
probabilidad de otras, y la conjunción de **entropía máxima**, que
justifica el método independiente. El tercero reúne la evidencia en
contra: la diferencia entre la evidencia a favor y la evidencia en contra
que Rowe describe, y los factores de certeza con signo y el umbral de
MYCIN, que Merritt implementa en Clam. El cuarto viene de Quinlan: ID3
aprende el árbol de ejemplos, con una ventana, con una prueba contra el
ruido y con la razón de ganancia. El quinto vuelve a Rowe: un árbol cuyos
subárboles repetidos se guardan una sola vez es un **reticulado**. Los
ejemplos están en `ejemplos/capitulo-66/`: `bayes.pl`, `entropia.pl` e
`id3.pl` no cargan nada y se ejecutan en SWISH; `certeza.pl` y
`compartido.pl` cargan las versiones del capítulo y se ejecutan en una
instalación local.

## 66.7 La regla de Bayes

Una fuerza se puede estimar con datos, como pide el
[ejercicio 12](index.md#ejercicios), pero los datos de la dirección que
interesa pueden ser pocos. La regla de Bayes obtiene una probabilidad
condicional a partir de la inversa. Por la definición de probabilidad
condicional,
$p(A \mid B) \, p(B) = p(A \land B) = p(B \mid A) \, p(A)$, y despejando:

$$p(A \mid B) = \frac{p(B \mid A) \, p(A)}{p(B)}$$

Rowe la recomienda cuando A causa B: entonces $p(B \mid A) = 1$. Un auto
con la batería descargada no arranca nunca, así que la probabilidad de
que la batería esté descargada cuando el auto no arranca es el cociente
de las dos probabilidades generales:

<!-- ejemplo: capitulo-66/bayes.pl predicado: bayes/4 -->
```prolog
%!  bayes(+PBdadoA:float, +PA:float, +PB:float, -PAdadoB:float) is det.
%
%   PAdadoB es p(A dado B) = p(B dado A) p(A) / p(B), con cuatro
%   decimales. Error de dominio si PB no es positiva.
bayes(PBdadoA, PA, PB, PAdadoB) :-
    must_be(number, PB),
    (   PB > 0
    ->  true
    ;   domain_error(probabilidad_positiva, PB)
    ),
    P is PBdadoA * PA / PB,
    PAdadoB is round(P * 10000) / 10000.0.
```

```prolog
?- bayes(1.0, 0.02, 0.05, P).
P = 0.4.
```

Si el 2 % de los autos tiene la batería descargada y el 5 % no arranca,
cuatro de cada diez autos que no arrancan tienen la batería descargada.
Cuando las probabilidades las da una persona, la misma igualdad sirve
para controlarlas. Rowe deriva de ella cuatro desigualdades, como
$p(A) \ge p(A \mid B) \, p(B)$, que cuatro números cualesquiera pueden no
cumplir; `inconsistencias/5` dice cuáles fallan, y si falla la igualdad:

```prolog
?- inconsistencias(0.1, 0.5, 0.6, 0.9, F).
F = [1, igualdad].
```

Con $p(A) = 0{,}1$, $p(B) = 0{,}5$ y $p(A \mid B) = 0{,}6$, la
probabilidad de A y B sería 0,3, más que la de A sola.

La regla se aplica también a la identificación. Con la frecuencia de
cada animal entre los consultados, la del [ejercicio 9](index.md#ejercicios),
y las observaciones que presenta un animal típico de cada clase, la
probabilidad de un animal dadas unas observaciones es proporcional a su
frecuencia por la probabilidad de registrar esas observaciones en él.
`posterior/3` supone que cada observación se registra mal con una
probabilidad de error y que los errores son independientes, de modo que
la probabilidad de las observaciones es un producto, y divide por la suma
sobre todos los animales:

<!-- ejemplo: capitulo-66/bayes.pl predicado: verosimilitud/4 conjunta/4 posterior/3 -->
```prolog
%!  verosimilitud(+H, +O, +Error:float, -P:float) is det.
%
%   P es la probabilidad de registrar la observación O en un animal de la
%   clase H: 1 - Error si lo presenta, Error si no.
verosimilitud(H, O, Error, P) :-
    (   presenta(H, O)
    ->  P is 1 - Error
    ;   P = Error
    ).

%!  conjunta(+Observaciones:list, +Error:float, ?H, -P:float) is nondet.
%
%   P es la probabilidad de que el animal sea H y se registren las
%   Observaciones: la frecuencia de H por la verosimilitud de cada una.
conjunta(Observaciones, Error, H, P) :-
    frecuencia(H, F),
    foldl(por_verosimilitud(H, Error), Observaciones, F / 100, P0),
    P is P0.

%!  posterior(+Observaciones:list, +Error:float, -Ranking:list) is det.
%
%   Ranking tiene un par H-P por animal, de mayor a menor P: la
%   probabilidad de H dadas las Observaciones, por la regla de Bayes, con
%   cuatro decimales. El denominador, la probabilidad de las
%   Observaciones, es la suma de las conjuntas de todos los animales.
posterior(Observaciones, Error, Ranking) :-
    findall(H-P, conjunta(Observaciones, Error, H, P), Pares),
    pairs_values(Pares, Ps),
    sum_list(Ps, Total),
    maplist(normalizar(Total), Pares, Normalizados),
    sort(2, @>=, Normalizados, Ranking).
```

<!-- contexto: capitulo-66/bayes.pl -->
```prolog
?- posterior([manchas_oscuras], 0.01, R).
R = [guepardo-0.6306, jirafa-0.3153, pinguino-0.0255, avestruz-0.0127, cebra-0.0096, tigre-0.0064].

?- posterior([tiene_pelo, manchas_oscuras, cuello_largo], 0.01, R).
R = [jirafa-0.9797, guepardo-0.0198, cebra-0.0003, tigre-0.0002, pinguino-0.0, avestruz-0.0].
```

Las manchas solas apuntan al guepardo, que se consulta el doble de veces
que la jirafa; con el cuello largo, a la jirafa. Los pingüinos, que son el
40 % de las consultas, conservan un 2,5 % aunque no tienen manchas: es lo
que deja el error de registro. A diferencia de los grados de la
[versión 1](index.md#662-version-1-probabilidades-en-las-reglas), las
probabilidades de todos los animales suman 1, porque la regla supone que
el animal es exactamente uno de ellos.

## 66.8 La conjunción de entropía máxima

Conocidas $p(A)$ y $p(B)$, la probabilidad $x$ de A y B fija las de los
cuatro casos que se excluyen: A y B, $x$; B sin A, $p(B) - x$; A sin B,
$p(A) - x$; y ninguno, $1 - p(A) - p(B) + x$. Para que ninguna sea
negativa, $x$ tiene que estar entre $\max(0, p(A) + p(B) - 1)$ y
$\min(p(A), p(B))$: las cotas conservadora y liberal de la
[sección 66.3](index.md#663-version-2-cotas-conservadora-y-liberal). Rowe
propone elegir, entre esos valores, el que **maximiza la entropía** de los
cuatro casos, el que menos información agrega a lo que se sabe:

$$H(x) = -\sum_{i=1}^{4} p_i \log_2 p_i$$

`entropia.pl` busca ese máximo numéricamente. La entropía es una función
cóncava de $x$, así que una **búsqueda ternaria** la encuentra: divide el
intervalo en tres, descarta el tercio del extremo de menor entropía, y
repite:

<!-- ejemplo: capitulo-66/entropia.pl predicado: y_maxima_entropia/3 ternaria/6 -->
```prolog
%!  y_maxima_entropia(+PA:float, +PB:float, -X:float) is det.
%
%   X es el valor de p(A y B) entre las cotas que maximiza la entropía de
%   los cuatro casos, con cuatro decimales. La entropía es cóncava en X,
%   así que una búsqueda ternaria de 100 pasos la encuentra.
y_maxima_entropia(PA, PB, X) :-
    intervalo_y(PA, PB, Inf, Sup),
    ternaria(100, PA, PB, Inf, Sup, X0),
    X is round(X0 * 10000) / 10000.0.

%!  ternaria(+N:integer, +PA, +PB, +A:float, +B:float, -X:float) is det.
%
%   X es el punto medio del intervalo [A, B] después de reducirlo N veces
%   a sus dos tercios, descartando el tercio de menor entropía.
ternaria(0, _, _, A, B, X) :-
    !,
    X is (A + B) / 2.
ternaria(N, PA, PB, A, B, X) :-
    M1 is A + (B - A) / 3,
    M2 is B - (B - A) / 3,
    entropia_y(PA, PB, M1, H1),
    entropia_y(PA, PB, M2, H2),
    (   H1 < H2
    ->  A1 = M1,
        B1 = B
    ;   A1 = A,
        B1 = M2
    ),
    N1 is N - 1,
    ternaria(N1, PA, PB, A1, B1, X).
```

```prolog
?- comparar([0.9-0.8, 0.7-0.4, 0.5-0.5, 0.2-0.3], Filas).
Filas = [f(0.9, 0.8, 0.7, 0.8, 0.72, 0.72), f(0.7, 0.4, 0.1, 0.4, 0.28, 0.28), f(0.5, 0.5, 0.0, 0.5, 0.25, 0.25), f(0.2, 0.3, 0.0, 0.2, 0.06, 0.06)].
```

Cada fila tiene $p(A)$, $p(B)$, las dos cotas, la estimación de entropía
máxima y el producto. La búsqueda llega al producto en todos los casos.
Rowe lo demuestra derivando: la derivada de $H$ se anula cuando
$x \, (1 - p(A) - p(B) + x) = (p(A) - x)(p(B) - x)$, y de ahí
$x = p(A) \, p(B)$. El método independiente de la
[versión 1](index.md#662-version-1-probabilidades-en-las-reglas), que
parecía una suposición entre otras, es la estimación que no supone nada
más que lo que se sabe.

## 66.9 Evidencia a favor y en contra

Las reglas de la versión 1 solo dan evidencia a favor de una conclusión.
Rowe describe otra manera de trabajar: reunir por separado la evidencia a
favor y la evidencia en contra, combinar cada una con el método de
siempre, y restar. El resultado va de $-1$, seguro que no, a $1$, seguro
que sí, con el $0$ como la indecisión. `certeza.pl` agrega cuatro reglas
en contra: unas rayas negras hablan en contra de un guepardo, y unas
manchas oscuras, en contra de un tigre.

<!-- ejemplo: capitulo-66/certeza.pl fragmento: % en_contra(Regla, Condicion, Meta, Fuerza): .. en_contra(c4, vuela, avestruz, 0.95). -->
```prolog
% en_contra(Regla, Condicion, Meta, Fuerza): si Condicion, la Meta es
% falsa con probabilidad Fuerza.
en_contra(c1, rayas_negras, guepardo, 0.9).
en_contra(c2, manchas_oscuras, tigre, 0.9).
en_contra(c3, tiene_plumas, mamifero, 0.95).
en_contra(c4, vuela, avestruz, 0.95).
```

<!-- ejemplo: capitulo-66/certeza.pl predicado: contra/4 balance/4 -->
```prolog
%!  contra(+Meta, +Observaciones:list, +Metodo, -P:float) is det.
%
%   P es el grado de la evidencia en contra de Meta: la combinación con o,
%   según Metodo, de lo que aporta cada regla de en_contra/4 con la
%   condición observada, redondeada a cuatro decimales.
contra(Meta, Observaciones, Metodo, P) :-
    findall(P1,
            ( en_contra(_, Condicion, Meta, F),
              member(Condicion-PC, Observaciones),
              y(Metodo, F, PC, P1) ),
            Ps),
    combinar(o, Metodo, Ps, P0),
    P is round(P0 * 10000) / 10000.0.

%!  balance(+Meta, +Observaciones:list, +Metodo, -B:float) is det.
%
%   B es el grado a favor de Meta menos el grado en contra, con cuatro
%   decimales.
balance(Meta, Observaciones, Metodo, B) :-
    grado(Meta, Observaciones, Metodo, A),
    contra(Meta, Observaciones, Metodo, C),
    B is round((A - C) * 10000) / 10000.0.
```

```prolog
?- tabla_balance(Filas).
Filas = [f(independiente, -0.0849, -0.442), f(conservador, -0.2, -0.5), f(liberal, 0.3, -0.3)].
```

Para el animal del atardecer, que el guepardo encabezaba en la
[sección 66.2](index.md#662-version-1-probabilidades-en-las-reglas), la
evidencia en contra cambia el signo: con el método independiente y con el
conservador, las rayas pesan más que todo lo que apoya al guepardo. Con el
liberal, el guepardo queda arriba. El tigre queda en contra con los tres.

Los factores de certeza de MYCIN, que Merritt implementa en Clam, tienen
signo desde el principio: una regla concluye con un factor entre $-1$ y
$1$. La premisa vale el **mínimo** de sus condiciones, y la regla no se
aplica si la premisa no llega a un **umbral**, 0,2 en Clam: sin él, una
evidencia muy débil dispararía todas las reglas. Dos aportes a la misma
conclusión se combinan con una fórmula de tres casos, que el curso
escribe con factores entre $-1$ y $1$ en lugar de los $-100$ a $100$ de
Clam:

<!-- ejemplo: capitulo-66/certeza.pl predicado: aporte/4 cf_combinar/3 -->
```prolog
%!  aporte(+Meta, +Observaciones:list, +Umbral:float, -A:float) is nondet.
%
%   A es lo que aporta a Meta una observación, una regla a favor, la
%   fuerza por la premisa, o una regla en contra, con signo negativo. La
%   premisa debe alcanzar el Umbral.
aporte(Meta, Observaciones, _, A) :-
    observable(Meta),
    member(Meta-A, Observaciones).
aporte(Meta, Observaciones, Umbral, A) :-
    regla(Regla, si Condiciones entonces Meta),
    premisa(Condiciones, Observaciones, Umbral, P),
    P >= Umbral,
    fuerza(Regla, F),
    A is F * P.
aporte(Meta, Observaciones, Umbral, A) :-
    en_contra(_, Condicion, Meta, F),
    premisa(Condicion, Observaciones, Umbral, P),
    P >= Umbral,
    A is -F * P.

%!  cf_combinar(+X:float, +Y:float, -Z:float) is det.
%
%   Z combina dos factores de certeza, como en MYCIN: si los dos son
%   positivos, X + Y(1 - X); si los dos son negativos, el opuesto de
%   combinar sus opuestos; si tienen signos distintos,
%   (X + Y) / (1 - min(|X|, |Y|)).
cf_combinar(X, Y, Z) :-
    (   X >= 0, Y >= 0
    ->  Z is X + Y * (1 - X)
    ;   X < 0, Y < 0
    ->  Z is X + Y * (1 + X)
    ;   Z is (X + Y) / (1 - min(abs(X), abs(Y)))
    ).
```

```prolog
?- tabla_factor([0.2, 0.4, 0.6], Filas).
Filas = [f(0.2, 0.2822, -0.3699), f(0.4, 0.476, -0.54), f(0.6, 0.0, -0.54)].
```

Con el umbral de Clam, el guepardo recibe 0,476 a favor, el factor de la
regla r7 por el de su premisa, y $-0{,}27$ en contra, por las rayas de
grado 0,3; con signos distintos, la fórmula da
$(0{,}476 - 0{,}27) / (1 - 0{,}27) = 0{,}2822$. Con umbral 0,4, las rayas
no llegan y la evidencia en contra desaparece; con 0,6, tampoco llega la
premisa del guepardo, cuyo carnívoro tiene factor 0,56. El umbral decide
qué evidencia cuenta, y el resultado depende de él tanto como de las
observaciones. La fórmula de signos distintos no está definida para dos
certezas opuestas, $1$ y $-1$: `cf_combinar/3` lanza entonces un error
de evaluación, la división por cero.

## 66.10 Aprender el árbol de ejemplos

La [versión 4](arbol.md#version-4-el-arbol-de-preguntas) construye el
árbol a partir de reglas que alguien escribió. ID3, de Quinlan, lo
**aprende** de ejemplos: objetos descritos por los valores de unos
atributos, cada uno ya clasificado. La tabla 1 de su artículo tiene
catorce mañanas de sábado, con el estado del cielo, la temperatura, la
humedad y el viento, y la clase: `p` si la mañana sirve para cierta
actividad, `n` si no. `id3.pl` la guarda en hechos:

<!-- ejemplo: capitulo-66/id3.pl fragmento: % sabado(N, Cielo, Temperatura, Humedad, Viento, Clase): .. sabado(14, lluvia,  templado, alta,   si, n). -->
```prolog
% sabado(N, Cielo, Temperatura, Humedad, Viento, Clase): el ejemplo N de la
% tabla 1 de Quinlan; la clase p es una mañana apta para una actividad, la
% n, una que no lo es.
sabado(1,  soleado, calor,    alta,   no, n).
sabado(2,  soleado, calor,    alta,   si, n).
sabado(3,  nublado, calor,    alta,   no, p).
sabado(4,  lluvia,  templado, alta,   no, p).
sabado(5,  lluvia,  fresco,   normal, no, p).
sabado(6,  lluvia,  fresco,   normal, si, n).
sabado(7,  nublado, fresco,   normal, si, p).
sabado(8,  soleado, templado, alta,   no, n).
sabado(9,  soleado, fresco,   normal, no, p).
sabado(10, lluvia,  templado, normal, no, p).
sabado(11, soleado, templado, normal, si, p).
sabado(12, nublado, templado, alta,   si, p).
sabado(13, nublado, calor,    normal, no, p).
sabado(14, lluvia,  templado, alta,   si, n).
```

En cada nodo, ID3 elige el atributo que más información gana, como la
estrategia `informacion` de la versión 4, y divide los ejemplos por sus
valores. La ganancia es la entropía de las clases menos la media de la
entropía de cada grupo. Quinlan observa que favorece a los atributos con
muchos valores, que dividen los ejemplos en grupos chicos y puros sin
explicar nada, y propone la **razón de ganancia**: la ganancia dividida
por el **valor intrínseco**, la entropía de los tamaños de los grupos,
elegida entre los atributos de ganancia media o mayor:

<!-- ejemplo: capitulo-66/id3.pl predicado: ganancia_exacta/3 valor_intrinseco/3 razon/3 -->
```prolog
%!  ganancia_exacta(+Ejemplos:list, +Atributo, -G:float) is det.
%
%   G es la ganancia sin redondear.
ganancia_exacta(Ejemplos, Atributo, G) :-
    info(Ejemplos, I),
    length(Ejemplos, N),
    particion(Ejemplos, Atributo, Grupos),
    foldl(esperada(N), Grupos, 0.0, E),
    G is I - E.

%!  valor_intrinseco(+Ejemplos:list, +Atributo, -IV:float) is det.
%
%   IV es la información de conocer el valor del Atributo: la entropía de
%   los tamaños de los grupos, sin contar los vacíos.
valor_intrinseco(Ejemplos, Atributo, IV) :-
    length(Ejemplos, N),
    particion(Ejemplos, Atributo, Grupos),
    findall(V-K,
            ( member(V-S, Grupos),
              length(S, K),
              K > 0 ),
            Cuentas),
    foldl(menos_plogp(N), Cuentas, 0.0, IV).

%!  razon(+Ejemplos:list, +Atributo, -R:float) is det.
%
%   R es la razón de ganancia, la ganancia sobre el valor intrínseco, con
%   tres decimales; 0 si el valor intrínseco es 0.
razon(Ejemplos, Atributo, R) :-
    ganancia_exacta(Ejemplos, Atributo, G),
    valor_intrinseco(Ejemplos, Atributo, IV),
    (   IV =:= 0
    ->  R = 0.0
    ;   R is round(G / IV * 1000) / 1000.0
    ).
```

```prolog
?- medidas_atributos(Filas).
Filas = [cielo-0.247-0.156, temperatura-0.029-0.019, humedad-0.152-0.152, viento-0.048-0.049].
```

Son los números de Quinlan, salvo el tercer decimal de dos ganancias, que
él calcula restando valores ya redondeados. La razón deja a la humedad,
con dos valores, casi empatada con el cielo, que tiene tres, pero el cielo
sigue arriba. El árbol se construye recursivamente; una rama sin
ejemplos recibe la clase más frecuente del nodo, la mejora que Quinlan
sugiere a la hoja vacía de ID3:

<!-- ejemplo: capitulo-66/id3.pl predicado: id3/4 rama/5 -->
```prolog
%!  id3(+Criterio, +Ejemplos:list, +Atributos:list, -Arbol) is det.
%
%   Arbol clasifica los Ejemplos: hoja(Clase) si todos tienen la misma
%   Clase o no queda atributo que elegir, con la clase mayoritaria; si no,
%   nodo(Atributo, Ramas), con un par Valor-Subarbol por cada valor. Una
%   rama sin ejemplos es una hoja con la clase mayoritaria del nodo.
id3(Criterio, Ejemplos, Atributos, Arbol) :-
    cuentas(Ejemplos, Cuentas),
    (   Cuentas = [Clase-_]
    ->  Arbol = hoja(Clase)
    ;   elegir(Criterio, Ejemplos, Atributos, A)
    ->  mayoritaria(Ejemplos, Mayoritaria),
        selectchk(A, Atributos, Resto),
        particion(Ejemplos, A, Grupos),
        maplist(rama(Criterio, Resto, Mayoritaria), Grupos, Ramas),
        Arbol = nodo(A, Ramas)
    ;   mayoritaria(Ejemplos, Clase),
        Arbol = hoja(Clase)
    ).

%!  rama(+Criterio, +Atributos:list, +Mayoritaria, +Grupo, -Rama) is det.
%
%   Rama es Valor-Subarbol para el Grupo Valor-Ejemplos.
rama(_, _, Mayoritaria, Valor-[], Valor-hoja(Mayoritaria)) :-
    !.
rama(Criterio, Atributos, _, Valor-Ejemplos, Valor-Subarbol) :-
    id3(Criterio, Ejemplos, Atributos, Subarbol).
```

```prolog
?- mostrar_aprendido(ganancia, tabla).
cielo = soleado
|   humedad = alta: n
|   humedad = normal: p
cielo = nublado: p
cielo = lluvia
|   viento = si: n
|   viento = no: p
nodos: 8
true.
```

Es el árbol de la figura 2 del artículo, el mismo con la ganancia y con la
razón. La temperatura no aparece: el árbol usa solo los atributos que
necesita.

El **ruido** es el problema de los datos reales: un atributo mal medido o
un ejemplo mal clasificado. Quinlan cambia la clase del ejemplo 3, y el
árbol que explica ese caso especial crece:

```prolog
?- mostrar_aprendido(ganancia, corrompido(3)).
humedad = alta
|   cielo = soleado: n
|   cielo = nublado
|   |   temperatura = calor: n
|   |   temperatura = templado: p
|   |   temperatura = fresco: n
|   cielo = lluvia
|   |   viento = si: n
|   |   viento = no: p
humedad = normal
|   cielo = soleado: p
|   cielo = nublado: p
|   cielo = lluvia
|   |   viento = si: n
|   |   viento = no: p
nodos: 16
true.
```

Un solo error duplica el árbol, y el árbol nuevo clasifica mal uno de los
ejemplos verdaderos. Quinlan propone no usar un atributo si una prueba de
**chi-cuadrado** no rechaza, con una confianza alta, que sea independiente
de la clase. El criterio `ruido(Confianza)` lo hace con `chi_cuadrado/4`
y una tabla de valores críticos:

<!-- ejemplo: capitulo-66/id3.pl predicado: chi_cuadrado/4 relevante/3 -->
```prolog
%!  chi_cuadrado(+Ejemplos:list, +Atributo, -X2:float, -GL:integer) is det.
%
%   X2 es el estadístico de chi-cuadrado de la hipótesis de que la clase
%   es independiente del Atributo, sumado sobre los grupos no vacíos y las
%   clases, con tres decimales; GL son sus grados de libertad, la cantidad
%   de grupos no vacíos menos uno, por la de clases menos uno.
chi_cuadrado(Ejemplos, Atributo, X2, GL) :-
    length(Ejemplos, N),
    cuentas(Ejemplos, Totales),
    particion(Ejemplos, Atributo, Grupos),
    exclude(vacio, Grupos, NoVacios),
    findall(T,
            ( member(_-S, NoVacios),
              length(S, NS),
              cuentas(S, CS),
              member(C-NC, Totales),
              (   memberchk(C-O, CS)
              ->  true
              ;   O = 0
              ),
              Esperado is NC * NS / N,
              T is (O - Esperado) ** 2 / Esperado ),
            Ts),
    sum_list(Ts, X0),
    X2 is round(X0 * 1000) / 1000.0,
    length(NoVacios, G),
    length(Totales, K),
    GL is (G - 1) * (K - 1).

%!  relevante(+Confianza, +Ejemplos:list, +Atributo) is semidet.
%
%   La prueba de chi-cuadrado rechaza, con la Confianza, que la clase sea
%   independiente del Atributo.
relevante(Confianza, Ejemplos, Atributo) :-
    chi_cuadrado(Ejemplos, Atributo, X2, GL),
    GL > 0,
    critico(Confianza, GL, X),
    X2 > X.
```

```prolog
?- mostrar_aprendido(ruido(0.99), corrompido(3)).
p
nodos: 1
true.

?- mostrar_aprendido(ruido(0.90), corrompido(3)).
humedad = alta: n
humedad = normal: p
nodos: 3
true.
```

Con catorce ejemplos la prueba es demasiado exigente: al 99 % de
confianza, que Quinlan usa para miles de objetos, ningún atributo pasa y
el árbol es una hoja; al 90 %, solo pasa la humedad, y el árbol se
equivoca en tres ejemplos. La prueba protege contra el ruido cuando hay
datos suficientes para distinguirlo de la estructura.

Para conjuntos grandes, ID3 no aprende de todos los ejemplos a la vez.
Elige una **ventana**, aprende de ella, clasifica el resto con el árbol, y
agrega a la ventana los ejemplos mal clasificados, hasta que no queda
ninguno. Quinlan elige la ventana al azar; `ventana/5` toma los primeros
ejemplos, para que el resultado sea reproducible:

<!-- ejemplo: capitulo-66/id3.pl predicado: ventana/5 iterar/6 -->
```prolog
%!  ventana(+Criterio, +Ejemplos:list, +Tamano:integer, -Arbol,
%!          -Iteraciones:integer) is det.
%
%   Arbol se aprende de una ventana que empieza con los primeros Tamano
%   Ejemplos y crece con los que el árbol de la iteración anterior
%   clasifica mal, hasta que clasifica bien todos; Iteraciones son los
%   árboles construidos.
ventana(Criterio, Ejemplos, Tamano, Arbol, Iteraciones) :-
    length(Ventana, Tamano),
    append(Ventana, Resto, Ejemplos),
    iterar(Criterio, Ventana, Resto, 1, Arbol, Iteraciones).

%!  iterar(+Criterio, +Ventana:list, +Resto:list, +I:integer, -Arbol,
%!         -Iteraciones:integer) is det.
%
%   Aprende de Ventana; si clasifica mal alguno del Resto, los pasa a la
%   Ventana y sigue.
iterar(Criterio, Ventana, Resto, I, Arbol, Iteraciones) :-
    findall(At, valores(At, _), Atributos),
    id3(Criterio, Ventana, Atributos, A),
    errores(A, Resto, Mal),
    (   Mal == []
    ->  Arbol = A,
        Iteraciones = I
    ;   append(Ventana, Mal, Ventana1),
        subtract(Resto, Mal, Resto1),
        I1 is I + 1,
        iterar(Criterio, Ventana1, Resto1, I1, Arbol, Iteraciones)
    ).
```

```prolog
?- ventana_tabla(4, I, N).
I = 4,
N = 8.
```

Con una ventana de cuatro ejemplos hacen falta cuatro árboles, y el
último es otra vez el de la figura 2. Quinlan cita a O'Keefe: el método
no garantiza llegar a un árbol final sin que la ventana crezca hasta
contener todos los ejemplos, aunque en la práctica converge en pocas
iteraciones.

## 66.11 Del árbol al reticulado

Rowe llama **reticulados de decisión** a estas estructuras, porque dos
ramas que se separan pueden volver a juntarse: si dos preguntas distintas
llevan a la misma continuación, basta con guardarla una vez. Los árboles
de la versión 4 repiten mucho, porque una respuesta negativa descarta
reglas y las ramas que quedan se parecen. `compartido.pl` recorre el
árbol desde las hojas y da a cada subárbol un número, el mismo para dos
subárboles iguales, con los hijos ya reemplazados por sus números:

<!-- ejemplo: capitulo-66/compartido.pl predicado: reticulado/3 compartir/4 numerar/4 -->
```prolog
%!  reticulado(+Arbol, -Raiz, -Nodos:list) is det.
%
%   Nodos son los nodos distintos de Arbol, numerados desde 1 en el orden
%   en que se completan, de las hojas a la raíz; Raiz es el número del
%   nodo de la raíz.
reticulado(Arbol, Raiz, Nodos) :-
    empty_assoc(T0),
    compartir(Arbol, T0-[], _-Inversos, Raiz),
    reverse(Inversos, Nodos).

%!  compartir(+Arbol, +Estado0, -Estado, -Id) is det.
%
%   Estado0 y Estado son pares Tabla-Nodos: la Tabla lleva cada nodo, con
%   los hijos ya reemplazados por sus números, a su número, y Nodos son
%   los pares número-nodo creados, el último primero. Id es el número del
%   nodo de Arbol, nuevo si no estaba en la Tabla.
compartir(hoja(H), Estado0, Estado, Id) :-
    numerar(hoja(H), Estado0, Estado, Id).
compartir(pregunta(P, Si, No), Estado0, Estado, Id) :-
    compartir(Si, Estado0, Estado1, IdSi),
    compartir(No, Estado1, Estado2, IdNo),
    numerar(pregunta(P, IdSi, IdNo), Estado2, Estado, Id).

%!  numerar(+Nodo, +Estado0, -Estado, -Id) is det.
%
%   Id es el número de Nodo en la tabla de Estado0, o uno nuevo, el
%   siguiente al último, que Estado agrega.
numerar(Nodo, T0-Ns0, Estado, Id) :-
    (   get_assoc(Nodo, T0, Id)
    ->  Estado = T0-Ns0
    ;   length(Ns0, K),
        Id is K + 1,
        put_assoc(Nodo, T0, Id, T1),
        Estado = T1-[n(Id)-Nodo|Ns0]
    ).
```

```prolog
?- tamanos(Filas).
Filas = [orden-331-26, frecuente-357-48, informacion-419-46].
```

El árbol `orden`, de 331 nodos, se guarda en 26: 19 preguntas y 7 hojas
distintas. `consultar_reticulado/4` lo recorre como `consultar/4` recorre
el árbol, y las pruebas comprueban que los dos dan la misma hipótesis en
los prototipos; la misma comparación sobre los 24 576 animales de la
versión 4 no encuentra ninguna diferencia. El reticulado conserva la
cantidad de preguntas de cada consulta, porque recorre los mismos
caminos, y solo reduce la memoria. Rowe enumera las ventajas de estas
estructuras, que son rápidas y pueden hacer la menor cantidad de
preguntas, y sus desventajas: no admiten variables ni retroceso, son
difíciles de modificar porque cada pregunta supone las respuestas
anteriores, y no guardan las respuestas para reusarlas. Por esas
limitaciones, dice, los sistemas expertos avanzaron cuando las dejaron de
lado como estructura principal y las usaron como una compilación, que es
lo que hace la [versión 5](arbol.md#version-5-el-arbol-compilado).

!!! example "Patrón 65 — Una tabla de valores como conjunto de nodos compartidos"
    **Problema.** Un término grande, como un árbol de decisión, repite
    muchas veces los mismos subtérminos, y cada repetición ocupa memoria
    aunque describa lo mismo que las demás.

    **Versión ingenua.** Guardar el árbol tal como lo construye la
    versión 4, con una copia de cada subárbol repetido: el árbol `orden`
    tiene 331 nodos. O detectar las repeticiones comparando cada subárbol
    con los ya vistos, guardados en una lista, de modo que cada
    comparación recorre subárboles enteros.

    **Patrón.** Recorrer el término desde las hojas y dar a cada nodo
    distinto un número, con una tabla que lleva cada nodo a su número.
    Antes de crear un nodo, sus hijos se reemplazan por sus números y el
    nodo así reducido se busca en la tabla con `get_assoc/3`: si está, se
    usa su número; si no, recibe el siguiente y se agrega con
    `put_assoc/4` (`numerar/4`). Como los hijos ya son números, cada
    clave tiene tamaño fijo, `pregunta(P, IdSi, IdNo)` u `hoja(H)`, y dos
    subárboles iguales dan la misma clave sin compararse enteros. La
    tabla, al terminar, es el conjunto de los nodos distintos:
    `reticulado/3` guarda el árbol `orden` en 26 nodos, 19 preguntas y 7
    hojas, y los de 357 y 419 nodos de las otras dos estrategias en 48 y
    46. Se parece al
    [Patrón 70](../patrones.md#70-resultado-recordado-sin-copiar) del
    [capítulo 71](../capitulo-71-proyecto-grafos-o/index.md#717-version-5-subproblemas-compartidos),
    que también lleva un assoc en el estado y comparte los subárboles
    repetidos, pero lo hace durante la búsqueda, para no resolver dos
    veces el mismo subproblema; aquí el término ya está construido, y la
    tabla, con los nodos como claves
    ([Patrón 24](../patrones.md#24-tabla-de-busqueda-con-assoc)), lo
    comprime después.

    **Cuándo no usarlo.** Cuando los subtérminos casi no se repiten: la
    tabla agrega una búsqueda por nodo y no ahorra nada. Cuando el
    resultado se modifica después: un nodo compartido por varios caminos
    no se puede cambiar para uno solo de ellos, que es la dificultad de
    modificar que señala Rowe. Cuando los nodos contienen variables: dos
    subtérminos que solo difieren en el nombre de sus variables dan
    claves distintas, y una ligadura posterior cambia una clave ya
    guardada. Y cuando lo que importa es la velocidad de la consulta: el
    reticulado hace las mismas preguntas que el árbol, y
    `consultar_reticulado/4` busca cada nodo con `memberchk/2` en la
    lista, en lugar de bajar directamente a un hijo.
