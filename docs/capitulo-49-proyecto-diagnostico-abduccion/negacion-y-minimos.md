# Abducción con negación y mínimos sin presupuesto

Esta página contiene las secciones [49.7](index.md#497-abduccion-con-negacion) y
[49.8](index.md#498-diagnosticos-minimos-a-partir-de-diagnosticos) del
[capítulo 49](index.md): un intérprete abductivo que también supone que algo
es falso, y una manera de obtener los diagnósticos mínimos del modelo débil
sin generar los demás ni fijar un presupuesto de fallas. Los ejemplos están en
`negacion.pl` e `incremental.pl`, en `ejemplos/capitulo-49/`, con sus pruebas;
son módulos, y se ejecutan localmente.

## Abducción con negación

El intérprete `abducir/2` de la
[sección 49.3](index.md#493-version-2-el-interprete-abductivo) prueba metas
positivas: cada supuesto afirma que una compuerta está en un estado. Una
teoría con negación necesita algo más. Flach, en el mismo apartado 8.3 de
*Simply Logical*, la escribe con reglas por defecto: un ave vuela si no es
anormal, y un pingüino o un ave muerta es anormal. Explicar que un ave
vuela obliga a suponer que es un ave, y también que **no** es un pingüino ni
está muerta. Si la explicación solo registra lo que supone verdadero, nada
impide que otra parte de la prueba suponga después lo contrario.

`negacion.pl` escribe la teoría con `regla/2` y la negación como `no(A)`, y
declara qué átomos se pueden suponer con `abducible/1`. Los supuestos
vuelven a ser un diccionario incompleto de la
[sección 34.4](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#344-diccionarios-incompletos),
ahora de pares `Abducible-Valor`, con el valor `verdadero` o `falso`.
`suponer/2` prueba una meta y `refutar/2` prueba que es falsa; las dos
amplían el mismo diccionario:

<!-- ejemplo: capitulo-49/negacion.pl predicado: suponer/2 refutar/2 refutar_todos/2 -->
```prolog
%!  suponer(+Meta, ?Supuestos:list) is nondet.
%
%   Meta se prueba con la teoría y los Supuestos, un diccionario
%   incompleto de pares Abducible-Valor, que la prueba amplía: un
%   abducible que hace falta verdadero se supone verdadero, y no(A) se
%   prueba refutando A.
suponer(true, _).
suponer((A, B), Supuestos) :-
    suponer(A, Supuestos),
    suponer(B, Supuestos).
suponer(no(A), Supuestos) :-
    refutar(A, Supuestos).
suponer(A, Supuestos) :-
    abducible(A),
    buscar(A, Supuestos, verdadero).
suponer(A, Supuestos) :-
    regla(A, Cuerpo),
    suponer(Cuerpo, Supuestos).

%!  refutar(+Meta, ?Supuestos:list) is nondet.
%
%   Meta, sin variables, es falsa con la teoría y los Supuestos, que la
%   refutación amplía: una conjunción es falsa si lo es alguna de sus
%   partes, no(A) si A se prueba, un abducible si se supone falso, y un
%   átomo con reglas si se refuta el cuerpo de cada una. Un átomo sin
%   reglas que no es abducible es falso sin suponer nada.
refutar((A, B), Supuestos) :-
    !,
    (   refutar(A, Supuestos)
    ;   refutar(B, Supuestos)
    ).
refutar(no(A), Supuestos) :-
    !,
    suponer(A, Supuestos).
refutar(A, Supuestos) :-
    abducible(A),
    !,
    buscar(A, Supuestos, falso).
refutar(A, Supuestos) :-
    A \== true,
    findall(Cuerpo, regla(A, Cuerpo), Cuerpos),
    refutar_todos(Cuerpos, Supuestos).

%!  refutar_todos(+Cuerpos:list, ?Supuestos:list) is nondet.
%
%   Cada cuerpo de Cuerpos se refuta con los mismos Supuestos.
refutar_todos([], _).
refutar_todos([Cuerpo|Cuerpos], Supuestos) :-
    refutar(Cuerpo, Supuestos),
    refutar_todos(Cuerpos, Supuestos).
```

Las cláusulas de `refutar/2` son las de `suponer/2` dadas vuelta: una
conjunción es falsa si lo es alguna parte, `no(A)` es falsa si `A` se
prueba, un abducible es falso si se lo supone falso, y un átomo con reglas
es falso si cada cuerpo lo es. La última condición recorre todos los
cuerpos con `findall/3`, y por eso la meta que se refuta tiene que llegar
sin variables, y las reglas, tener sus variables en la cabeza. Es la
estructura de `abduce/3` y `abduce_not/3` de Flach; la diferencia está en
la consistencia. Flach verifica, antes de agregar un abducible, que la
explicación no pruebe su negación, y para eso vuelve a ejecutar la prueba
opuesta. Aquí el diccionario hace esa verificación con una unificación:
`buscar/3` encuentra el abducible ya supuesto con el otro valor, y falla.

```prolog
?- suponer(vuela(piolin), S), cerrar(S).
S = [gorrion(piolin)-verdadero, pinguino(piolin)-falso, muerto(piolin)-falso] ;
false.
```

La primera regla de `ave/1` supone que Piolín es un pingüino; la
refutación de `anormal(piolin)` necesita que no lo sea, `buscar/3` falla, y
el intérprete retrocede hasta la segunda regla. La explicación que queda
dice qué se supone verdadero y qué se supone falso, y es la que Flach
obtiene. La misma teoría describe un diagnóstico: la luz enciende si hay
corriente, la llave está cerrada y la lámpara está sana, y la radio suena
si hay corriente. Una luz apagada tiene dos explicaciones; si además la
radio suena, una sola:

```prolog
?- suponer(no(enciende), S), cerrar(S).
S = [hay_corriente-falso] ;
S = [lampara_sana-falso] ;
false.

?- suponer((no(enciende), suena_la_radio), S), cerrar(S).
S = [lampara_sana-falso, hay_corriente-verdadero] ;
false.
```

La llave cerrada es un hecho, una regla de cuerpo `true`, y no se puede
refutar: no aparece como explicación. Una observación contradictoria no
tiene explicación:

```prolog
?- suponer((enciende, no(suena_la_radio)), S).
false.
```

La negación también produce explicaciones no mínimas. Que Piolín sea un ave
que no vuela tiene cuatro:

```prolog
?- suponer((no(vuela(piolin)), ave(piolin)), S), cerrar(S).
S = [pinguino(piolin)-verdadero] ;
S = [pinguino(piolin)-verdadero, gorrion(piolin)-verdadero] ;
S = [muerto(piolin)-verdadero, pinguino(piolin)-verdadero] ;
S = [muerto(piolin)-verdadero, gorrion(piolin)-verdadero] ;
false.
```

La segunda y la tercera contienen a la primera; el filtro de la
[sección 49.4](index.md#494-version-3-diagnosticos-minimos) se aplica igual.
El intérprete tiene un límite que Flach señala en su ejercicio 8.4: una
regla que depende de su propia negación, como «es sabio quien no es
maestro» junto con «Pedro es maestro si es sabio», hace que la refutación
llame a la prueba y la prueba a la refutación sin fin.

## Diagnósticos mínimos a partir de diagnósticos

La [sección 49.4](index.md#494-version-3-diagnosticos-minimos) obtiene los
mínimos de dos maneras: generando todos los diagnósticos y filtrando, o
con un presupuesto de K fallas que hay que fijar de antemano. Flach remite,
para hacerlo mejor, al algoritmo de Igor Mozetič (1992), que Mozetič y
Holzbaur desarrollaron después con el nombre IDA: calcula los
diagnósticos mínimos a partir de diagnósticos, no de conflictos, y cada
uno con una cantidad de verificaciones polinomial en la cantidad de
componentes. `incremental.pl` es una versión simple de esa idea, escrita
para el curso, y no reproduce el algoritmo del artículo.

La idea se apoya en la propiedad del modelo débil que señala la
[sección 49.5](index.md#495-version-4-modelos-de-falla-y-conducta-desconocida):
agregar una compuerta a un diagnóstico da otro diagnóstico. Una
**verificación** responde, sin suponer nada, si un conjunto de compuertas
es diagnóstico: esas en el estado `desconocida` y las demás en `ok`. Con
eso, un diagnóstico se reduce a uno mínimo probando de sacar cada compuerta
una vez:

<!-- ejemplo: capitulo-49/incremental.pl predicado: es_diagnostico/3 reducir/4 probar_sacar/5 -->
```prolog
%!  es_diagnostico(+Circuito, +Observaciones:list(pair), +Rutas:list)
%!      is semidet.
%
%   Con las compuertas de Rutas en el estado desconocida del modelo débil
%   y las demás en ok, Circuito reproduce todas las Observaciones: una
%   sola verificación, sin suponer nada.
es_diagnostico(Circuito, Observaciones, Rutas) :-
    findall(Ruta, compuerta_en(Circuito, Ruta, _), Todas),
    maplist(estado_de(Rutas), Todas, Supuestos),
    once(explicar(debil, Circuito, Observaciones, Supuestos)).

%!  reducir(+Circuito, +Observaciones:list(pair), +Diagnostico:list,
%!      -Minimo:list) is det.
%
%   Minimo es un diagnóstico mínimo contenido en Diagnostico, una lista
%   ordenada de rutas que es diagnóstico: se prueba sacar cada compuerta,
%   en orden, y se la deja fuera si lo que queda sigue siendo diagnóstico.
reducir(Circuito, Observaciones, Diagnostico, Minimo) :-
    foldl(probar_sacar(Circuito, Observaciones), Diagnostico,
          Diagnostico, Minimo).

%!  probar_sacar(+Circuito, +Observaciones:list(pair), +Ruta, +D0:list,
%!      -D:list) is det.
%
%   D es D0 sin Ruta si eso sigue siendo diagnóstico, y D0 si no.
probar_sacar(Circuito, Observaciones, Ruta, D0, D) :-
    ord_del_element(D0, Ruta, D1),
    (   es_diagnostico(Circuito, Observaciones, D1)
    ->  D = D1
    ;   D = D0
    ).
```

Si sacar una compuerta deja algo que no es diagnóstico, ningún subconjunto
de lo que queda lo es, y la compuerta queda en el resultado para siempre:
al terminar, sacar cualquiera de las que quedan rompe el diagnóstico, que
es la definición de mínimo. Son n verificaciones para n compuertas.

```prolog
?- reducir(sumador, [[0, 0, 1]-[0, 1]], [[m1, x1], [m2, x1], [o1]], D).
D = [[m2, x1], [o1]].
```

Para encontrar otro mínimo se usan los que ya se conocen. Un mínimo nuevo
no contiene a ninguno de ellos, así que deja fuera al menos una compuerta
de cada uno. `siguiente_minimo/4` elige esas compuertas de a una, con
`excluir/6`, y verifica cada elección en el momento: si lo que queda ya no
es diagnóstico, sacar más compuertas no lo arregla, y la rama se abandona.
Lo que queda al final se reduce con `reducir/4`:

<!-- ejemplo: capitulo-49/incremental.pl predicado: siguiente_minimo/4 excluir/6 minimos_incrementales/3 -->
```prolog
%!  siguiente_minimo(+Circuito, +Observaciones:list(pair),
%!      +Conocidos:list(list), -Minimo:list) is semidet.
%
%   Minimo es un diagnóstico mínimo que no está en Conocidos, una lista
%   de diagnósticos mínimos: se deja fuera una compuerta de cada uno, y lo
%   que queda, si es diagnóstico, se reduce. Falla si Conocidos los tiene
%   a todos, o si ni todas las compuertas desconocidas explican las
%   observaciones.
siguiente_minimo(Circuito, Observaciones, Conocidos, Minimo) :-
    findall(Ruta, compuerta_en(Circuito, Ruta, _), Todas0),
    sort(Todas0, Todas),
    excluir(Conocidos, Circuito, Observaciones, Todas, [], Fuera),
    ord_subtract(Todas, Fuera, Candidato),
    es_diagnostico(Circuito, Observaciones, Candidato),
    !,
    reducir(Circuito, Observaciones, Candidato, Minimo).

%!  excluir(+Conocidos:list(list), +Circuito, +Observaciones:list(pair),
%!      +Todas:list, +Fuera0:list, -Fuera:list) is nondet.
%
%   Fuera es Fuera0 con una compuerta más de cada diagnóstico de Conocidos
%   que Fuera0 todavía no toca, de modo que Todas sin Fuera sigue siendo
%   diagnóstico. Cada compuerta que se deja fuera se verifica en el
%   momento: si lo que queda ya no es diagnóstico, menos compuertas
%   tampoco lo son, y la rama se abandona.
excluir([], _, _, _, Fuera, Fuera).
excluir([D|Ds], Circuito, Observaciones, Todas, Fuera0, Fuera) :-
    (   ord_intersect(D, Fuera0)
    ->  excluir(Ds, Circuito, Observaciones, Todas, Fuera0, Fuera)
    ;   member(Ruta, D),
        ord_add_element(Fuera0, Ruta, Fuera1),
        ord_subtract(Todas, Fuera1, Quedan),
        es_diagnostico(Circuito, Observaciones, Quedan),
        excluir(Ds, Circuito, Observaciones, Todas, Fuera1, Fuera)
    ).

%!  minimos_incrementales(+Circuito, +Observaciones:list(pair),
%!      -Minimos:list(list)) is det.
%
%   Minimos son todos los diagnósticos mínimos del modelo débil, como
%   listas ordenadas de rutas, en el orden en que se encuentran.
minimos_incrementales(Circuito, Observaciones, Minimos) :-
    minimos_desde(Circuito, Observaciones, [], Minimos).
```

```prolog
?- minimos_incrementales(sumador, [[0, 0, 1]-[0, 1]], Ds).
Ds = [[[m2, x1], [o1]], [[m1, x1]], [[m2, x1], [m2, y1]], [[m1, y1], [m2, x1]]].
```

Son los cuatro conjuntos de Flach, los mismos que da
`sospechosas(debil, …)`, en otro orden. La diferencia es el costo. Sobre el
sumador de tres bits, con la observación de 3 + 5 y el acarreo final en 0,
las mediciones con `time/1` dan:

```text
?- time(minimos_incrementales(sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]], Ds)).
% 1,017,944 inferences, 0.172 CPU in 0.182 seconds (95% CPU, 5922583 Lips)

?- time(sospechosas(debil, sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]], 12, Rs)).
% 118,194,936 inferences, 18.172 CPU in 18.336 seconds (99% CPU, 6504279 Lips)
```

Las dos dan los mismos 13 diagnósticos mínimos, con entre una y tres
compuertas. El filtro con un presupuesto igual a la cantidad de compuertas
enumera todas las explicaciones; la versión incremental hizo 264
verificaciones, contadas con `wrap_predicate/4`. El filtro con el
presupuesto justo, K = 3, cuesta 525 077 inferencias, menos todavía, pero
hay que saber de antemano que ningún mínimo tiene más de tres compuertas.
La poda de `excluir/6` es la que hace práctica la versión incremental: sin
ella, probando todas las combinaciones de compuertas excluidas, la misma
consulta hace 37 453 verificaciones y 182 millones de inferencias. La
cantidad de combinaciones crece con el producto de los tamaños de los
mínimos conocidos; el algoritmo de Mozetič acota ese trabajo, y esta
versión simple no lo hace en el peor caso.
