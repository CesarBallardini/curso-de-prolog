# Soluciones del capítulo 49 — Proyecto: diagnóstico por abducción

Las soluciones de los ejercicios 2 a 4, 6 a 11 y 13 están en
`ejemplos/capitulo-49/soluciones.pl`, que carga los módulos del proyecto
(`fallas.pl`, `abduccion.pl`, `minimos.pl`, `modelos.pl` y `medicion.pl`) y
agrega reglas a la teoría y circuitos con cláusulas `multifile`; la del
ejercicio 5, en `soluciones_copia.pl`, porque cambia el modelo fuerte y,
cargada junto con las demás, cambiaría sus resultados. La del ejercicio
12, en `soluciones_negacion.pl`, carga `negacion.pl`, que define otra
teoría. Cada archivo tiene
sus pruebas en el `.plt` del mismo nombre.

## Ejercicio 1

Con `diagnostico.pl` cargado:

```prolog
?- abducir(salida(fuerte, [g], or, [0, 0], 1), S).
S = [[g]-pegada(1)|_] ;
S = [[g]-invertida|_] ;
false.

?- mas_simples(fuerte, sumador, [[1, 1, 0]-[0, 0]], Ds).
Ds = [[[m1, y1]-invertida], [[m1, y1]-pegada(0)], [[o1]-invertida], [[o1]-pegada(0)]].

?- mas_simples(debil, sumador, [[1, 1, 0]-[0, 0]], Ds).
Ds = [[[m1, y1]-desconocida], [[o1]-desconocida]].

?- diagnostico(fuerte, semisumador, [[0, 0]-[0, 0]], D).
D = [] ;
D = [[y1]-pegada(0)] ;
D = [[x1]-pegada(0)] ;
D = [[x1]-pegada(0), [y1]-pegada(0)] ;
false.
```

Una OR con las entradas en 0 debería dar 0: si dio 1, está pegada a 1 o
invertida. En el sumador, con las entradas 1, 1 y 0, la suma es correcta y
el acarreo debería ser 1: lo pierde la AND del primer semisumador, que es
la única que da 1, o la OR. Las XOR no pueden explicarlo, porque cambiarían
también la suma. El modelo débil sospecha de las mismas dos compuertas, sin
decir cómo fallan. La última consulta observa un semisumador que funciona:
la primera explicación es la vacía, pero hay otras tres, porque una
compuerta pegada a 0 que debería dar 0 no cambia nada. Son las
explicaciones redundantes que la [sección 49.4](index.md#494-version-3-diagnosticos-minimos) elimina.

## Ejercicio 2

```prolog
?- mas_simples(fuerte, xor_nand, [[1, 0]-[0]], Ds).
Ds = [[[g1]-invertida], [[g1]-pegada(0)], [[g2]-invertida], [[g2]-pegada(1)], [[g4]-invertida], [[g4]-pegada(0)]].

?- mas_simples(debil, xor_nand, [[1, 0]-[0]], Ds).
Ds = [[[g1]-desconocida], [[g2]-desconocida], [[g4]-desconocida]].
```

Con x = 1 e y = 0, los cables valen t = 1, u = 0, v = 1 y z = 1. Cambiar t
cambia u y, por ella, z; cambiar u o z cambia z directamente. La compuerta
g3 no aparece: si v pasa a 0, la NAND g4 recibe dos ceros y sigue dando 1.
Con la segunda observación, que es correcta:

```prolog
?- mas_simples(fuerte, xor_nand, [[1, 0]-[0], [0, 0]-[0]], Ds).
Ds = [[[g1]-invertida], [[g1]-pegada(0)], [[g2]-pegada(1)], [[g4]-pegada(0)]].

?- mas_simples(debil, xor_nand, [[1, 0]-[0], [0, 0]-[0]], Ds).
Ds = [[[g1]-desconocida], [[g2]-desconocida], [[g4]-desconocida]].
```

El modelo fuerte descarta dos estados: con las entradas en 0, u normal es
1, y g2 invertida daría 0, con lo que z pasaría a 1; g4 invertida daría
directamente 1. El modelo débil no descarta nada, porque una compuerta
desconocida puede funcionar bien en la segunda medición. Las compuertas
sospechosas son las mismas en los dos modelos: la segunda observación solo
precisa cómo fallan.

## Ejercicio 3

<!-- ejemplo: capitulo-49/soluciones.pl predicado: abducir_mal/2 -->
```prolog
%!  abducir_mal(+Meta, ?Supuestos:list) is nondet.
%
%   Como abducir/2, con memberchk/2 en lugar de buscar/3: un error.
abducir_mal(true, _).
abducir_mal((A, B), Supuestos) :-
    abducir_mal(A, Supuestos),
    abducir_mal(B, Supuestos).
abducir_mal(estado(Componente, Estado), Supuestos) :-
    memberchk(Componente-Estado, Supuestos).
abducir_mal(Meta, Supuestos) :-
    abduccion:regla(Meta, Cuerpo),
    abducir_mal(Cuerpo, Supuestos).
```

`memberchk/2` compara el par entero. Si el componente ya tiene un estado y
la prueba pide otro, el par no unifica con la entrada existente, y
`memberchk/2` sigue hasta el final abierto del diccionario y agrega una
entrada nueva con la misma clave. `repetida/1` busca un diagnóstico así:

```prolog
?- once((diagnostico_mal(sumador, [[0, 0, 1]-[0, 1], [1, 0, 0]-[1, 0]], D), repetida(D))).
D = [[m2, x1]-pegada(0), [o1]-pegada(0), [o1]-pegada(1)].
```

La OR aparece pegada a 1 para explicar la primera observación y pegada a 0
para la segunda: no es una asignación de estados, porque una compuerta
tiene uno solo. Deja de cumplirse la condición que el diccionario
incompleto de la [sección 34.4](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md#344-diccionarios-incompletos) garantiza: las claves son distintas.
`buscar/3` compara solo la clave, y si la encuentra, unifica el valor o
falla. La diferencia es exactamente la que esa sección señala entre
`memberchk/2` y `buscar/3`.

## Ejercicio 4

<!-- ejemplo: capitulo-49/soluciones.pl fragmento: abduccion:regla(salida(flach, .. estado(Ruta, pegada(V)))). -->
```prolog
abduccion:regla(salida(flach, Ruta, Tipo, Es, V),
                (tabla(Tipo, Es, S0), negacion(S0, V),
                 estado(Ruta, pegada(V)))).
```

La regla del estado `ok` de la teoría vale para cualquier modelo, así que
solo hace falta la de la falla, con la condición antes del supuesto:

```prolog
?- aggregate_all(count, diagnostico(flach, sumador, [[0, 0, 1]-[0, 1]], _), N).
N = 8.

?- por_filtro(flach, sumador, [[0, 0, 1]-[0, 1]], Ds).
Ds = [[[m1, x1]-pegada(1)], [[m1, y1]-pegada(1), [m2, x1]-pegada(0)], [[m2, x1]-pegada(0), [m2, y1]-pegada(1)], [[m2, x1]-pegada(0), [o1]-pegada(1)]].
```

Son los ocho diagnósticos del libro y sus cuatro mínimos. La condición
elimina las explicaciones redundantes de la [sección 49.3](index.md#493-version-2-el-interprete-abductivo) sin
filtrar: una compuerta que daría el bit al que está pegada no se supone en
falla. Pero lo hace en cada observación por separado. Con dos
observaciones, una compuerta pegada a 1 da 1 también cuando su tabla da 1,
y el modelo tiene que suponerla `ok` en esa medición, lo que el diccionario
rechaza porque ya está supuesta en falla:

```prolog
?- mas_simples(flach, sumador, [[0, 0, 1]-[0, 1], [1, 0, 0]-[1, 0]], Ds).
false.
```

El circuito con `[m1, x1]` pegada a 1 produce esas dos observaciones, y el
modelo fuerte lo diagnostica; el de Flach, pensado para una sola
observación, no encuentra ninguna explicación.

## Ejercicio 5

<!-- ejemplo: capitulo-49/soluciones_copia.pl fragmento: abduccion:regla(salida(fuerte, .. nth1(I, Es, S). -->
```prolog
abduccion:regla(salida(fuerte, Ruta, _, Es, S),
                (estado(Ruta, copia(I)), entrada(I, Es, S))).
abduccion:regla(entrada(I, Es, S), true) :-
    nth1(I, Es, S).
```

```prolog
?- mas_simples(fuerte, sumador, [[1, 1, 1]-[0, 0]], Ds), length(Ds, N).
Ds = [[[m1, x1]-invertida, [o1]-invertida], [[m1, x1]-invertida, [o1]-pegada(0)], [[m1, x1]-copia(1), [o1]-invertida], [[m1, x1]-copia(1), [o1]-pegada(0)], [[m1, x1]-copia(2), [o1]-invertida], [[m1|...]-copia(2), [...]-pegada(...)], [[...|...]-pegada(...), ... - ...], [... - ...|...], [...|...]|...],
N = 23.
```

Sigue sin haber explicaciones de una sola falla, y las compuertas
sospechosas son los mismos tres pares de la [sección 49.2](index.md#492-version-1-una-falla-por-simulacion); lo que
cambia son los estados, de 12 a 23 diagnósticos. Con las entradas en 1, una
XOR que copia una entrada da 1, lo mismo que pegada a 1; y la OR que copia
su segunda entrada, `[o1]-copia(2)`, da el acarreo del segundo
semisumador, que con `[m2, x1]` en falla puede ser 0. Un modelo con más
estados explica más observaciones, y separa menos los diagnósticos.

## Ejercicio 6

<!-- ejemplo: capitulo-49/soluciones.pl fragmento: circuitos:circuito(sumador_sondas, .. circuitos:componente(sumador, Id, Tipo, Es, Ss). -->
```prolog
circuitos:circuito(sumador_sondas, [a, b, ci], [s, co, c1, c2]).
circuitos:componente(sumador_sondas, Id, Tipo, Es, Ss) :-
    circuitos:componente(sumador, Id, Tipo, Es, Ss).
```

Una cláusula con cuerpo copia los componentes del sumador; la interfaz
agrega c1 y c2 como salidas, que son los cables que las sondas miden.

```prolog
?- A = [[m1, y1]-pegada(1), [m2, x1]-pegada(0)], predecir(sumador_sondas, [0, 0, 1], A, Ss), localizar(sumador_sondas, A, [[0, 0, 1]-Ss], Obs, Ds).
A = [[m1, y1]-pegada(1), [m2, x1]-pegada(0)],
Ss = [0, 1, 1, 0],
Obs = [[1, 1, 0]-[0, 1, 1, 0], [0, 0, 1]-[0, 1, 1, 0]],
Ds = [[[m1, y1]-pegada(1), [m2, x1]-pegada(0)]].
```

Con las sondas, la primera medición ya muestra que c1 vale 1 con las
entradas 0, 0 y 1, cuando la AND `[m1, y1]` debería dar 0, y una medición
más deja un solo diagnóstico, donde sin sondas quedaban tres después de
tres mediciones.

## Ejercicio 7

<!-- ejemplo: capitulo-49/soluciones.pl predicado: sanas/2 -->
```prolog
%!  sanas(+Supuestos:list(pair), -Rutas:list) is det.
%
%   Rutas son las rutas a las que Supuestos, un diccionario cerrado, asigna
%   el estado ok, en el orden del diccionario.
sanas(Supuestos, Rutas) :-
    include([_-Estado]>>(Estado == ok), Supuestos, Pares),
    pairs_keys(Pares, Rutas).
```

El primer argumento es `+` porque el diccionario tiene que llegar cerrado:
`include/3` sobre una lista abierta recorre su final libre y genera listas
cada vez más largas. El segundo es `-`, y el predicado es `det`: para un
diccionario cerrado hay exactamente una lista de rutas. Si `Rutas` llega
ligada, se compara, y el predicado sigue siendo correcto; el modo `-` lo
admite, como dice la [sección 2.8](../capitulo-02-hechos-consultas-y-variables/index.md#28-como-se-documenta-el-uso-de-un-predicado).

```prolog
?- once(explicar(fuerte, sumador, [[1, 0, 1]-[0, 1]], S)), sanas(S, R).
S = [[m1, x1]-ok, [m1, y1]-ok, [m2, x1]-ok, [m2, y1]-ok, [o1]-ok],
R = [[m1, x1], [m1, y1], [m2, x1], [m2, y1], [o1]].
```

## Ejercicio 8

<!-- ejemplo: capitulo-49/soluciones.pl fragmento: abduccion:regla(motor(arranca), .. abduccion:regla(luces(apagadas), estado(bateria, mala)). -->
```prolog
abduccion:regla(motor(arranca),
                (estado(bateria, bien), estado(arranque, bien),
                 estado(combustible, bien))).
abduccion:regla(motor(no_arranca), estado(bateria, mala)).
abduccion:regla(motor(no_arranca), estado(arranque, malo)).
abduccion:regla(motor(no_arranca), estado(combustible, vacio)).
abduccion:regla(luces(encendidas), estado(bateria, bien)).
abduccion:regla(luces(apagadas), estado(bateria, mala)).
```

```prolog
?- abducir((motor(no_arranca), luces(encendidas)), S).
S = [arranque-malo, bateria-bien|_] ;
S = [combustible-vacio, bateria-bien|_] ;
false.
```

La batería descargada explicaría que el motor no arranque, pero no que las
luces enciendan: `buscar/3` la rechaza porque la segunda observación supone
`bateria-bien`. El intérprete no depende de los circuitos: la teoría es
cualquier conjunto de reglas cuyos abducibles son estados de componentes.

## Ejercicio 9

<!-- ejemplo: capitulo-49/soluciones.pl predicado: mas_probables/4 con_probabilidad/3 multiplicar/3 -->
```prolog
%!  mas_probables(+Circuito, +Observaciones:list(pair), +K:integer,
%!      -Ordenados:list(pair)) is det.
%
%   Ordenados son los diagnósticos mínimos con a lo sumo K fallas, como
%   pares Probabilidad-Diagnostico, de mayor a menor probabilidad. Una
%   compuerta sana tiene probabilidad 1 - 0.021, el complemento de sus tres
%   estados de falla.
mas_probables(Circuito, Observaciones, K, Ordenados) :-
    minimos(fuerte, Circuito, Observaciones, K, Ds),
    compuertas(Circuito, N),
    maplist(con_probabilidad(N), Ds, Pares),
    sort(1, @>=, Pares, Ordenados).

%!  con_probabilidad(+N:integer, +Fallas:list(pair), -Par:pair) is det.
%
%   Par es P-Fallas, con P la probabilidad de que las compuertas de Fallas
%   estén en sus estados y las demás de las N, sanas.
con_probabilidad(N, Fallas, P-Fallas) :-
    foldl(multiplicar, Fallas, 1, P0),
    length(Fallas, F),
    P is P0 * (1 - 0.021) ** (N - F).

%!  multiplicar(+Falla:pair, +P0:number, -P:number) is det.
%
%   P es P0 por la probabilidad del estado de Falla.
multiplicar(_-Estado, P0, P) :-
    probabilidad(Estado, Q),
    P is P0 * Q.
```

```prolog
?- mas_probables(sumador3, [[1, 1, 0, 1, 0, 1]-[0, 0, 0, 0]], 2, [P1-D1, P2-D2|_]).
P1 = P2, P2 = 0.007917892659111239,
D1 = [[s2, m2, y1]-pegada(0)],
D2 = [[s2, o1]-pegada(0)].
```

Las dos fallas simples pegadas a 0 encabezan la lista; siguen las
invertidas, diez veces menos probables, y después los veinte diagnósticos
dobles, cuya probabilidad es el producto de dos probabilidades de falla.
Los diagnósticos más simples son también los más probables cuando las
fallas son raras e independientes: esa es la justificación de
`mas_simples/4`.

## Ejercicio 10

<!-- ejemplo: capitulo-49/soluciones.pl predicado: cono/3 depende/5 unir/5 toca_los_conos/3 -->
```prolog
%!  cono(+Circuito, +Salida, -Rutas:list) is det.
%
%   Rutas son las rutas de las compuertas de las que depende la salida
%   Salida de Circuito, como conjunto ordenado.
cono(Circuito, Salida, Rutas) :-
    depende(Circuito, [], Salida, Rutas, _).

%!  depende(+Circuito, +Ruta:list, +Cable, -Rutas:list, -Entradas:list)
%!      is det.
%
%   El Cable de Circuito, que está en Ruta dentro del exterior, depende de
%   las compuertas Rutas y de las entradas de Circuito Entradas, las dos
%   como conjuntos ordenados.
depende(Circuito, _Ruta, Cable, [], [Cable]) :-
    circuito(Circuito, Nombres, _),
    memberchk(Cable, Nombres),
    !.
depende(Circuito, Ruta, Cable, Rutas, Entradas) :-
    componente(Circuito, Id, Tipo, CEs, CSs),
    nth1(I, CSs, Cable),
    !,
    append(Ruta, [Id], RutaId),
    (   circuito(Tipo, TEs, TSs)
    ->  nth1(I, TSs, Interna),
        depende(Tipo, RutaId, Interna, Rutas0, Usadas),
        findall(C, ( member(U, Usadas), nth1(J, TEs, U), nth1(J, CEs, C) ),
                Cables)
    ;   Rutas0 = [RutaId],
        Cables = CEs
    ),
    foldl(unir(Circuito, Ruta), Cables, Rutas0-[], Rutas1-Entradas0),
    sort(Rutas1, Rutas),
    sort(Entradas0, Entradas).

%!  unir(+Circuito, +Ruta:list, +Cable, +Acumulado:pair, -Unido:pair)
%!      is det.
%
%   Unido agrega a los pares Rutas-Entradas de Acumulado los del Cable.
unir(Circuito, Ruta, Cable, Rs0-Es0, Rs-Es) :-
    depende(Circuito, Ruta, Cable, Rs1, Es1),
    append(Rs0, Rs1, Rs),
    append(Es0, Es1, Es).

%!  toca_los_conos(+Circuito, +Observacion:pair, +Diagnostico:list(pair))
%!      is semidet.
%
%   Diagnostico tiene al menos una compuerta en el cono de cada salida
%   que la Observacion tiene distinta de la del circuito sano.
toca_los_conos(Circuito, Entradas-Salidas, Diagnostico) :-
    circuito(Circuito, _, Nombres),
    predecir(Circuito, Entradas, [], Sanas),
    rutas(Diagnostico, Rutas),
    forall(( nth1(I, Nombres, Nombre),
             nth1(I, Salidas, S),
             nth1(I, Sanas, S0),
             S \== S0 ),
           ( cono(Circuito, Nombre, Cono),
             ord_intersect(Cono, Rutas) )).
```

`depende/5` recorre la descripción desde un cable hacia las entradas. Si el
cable lo produce un subcircuito, baja por la salida correspondiente, y las
entradas del subcircuito que alcanza se traducen de vuelta a los cables del
circuito que lo contiene, por su posición.

```prolog
?- cono(sumador3, s1, C).
C = [[m0, y1], [s1, m1, x1], [s1, m2, x1]].

?- O = [1, 1, 0, 1, 0, 1]-[1, 0, 0, 0], minimos(fuerte, sumador3, [O], 2, Ds), forall(member(D, Ds), toca_los_conos(sumador3, O, D)).
O = [1, 1, 0, 1, 0, 1]-[1, 0, 0, 0],
Ds = [[[m0, x1]-invertida, [s2, m2, y1]-invertida], [[m0, x1]-invertida, [s2, m2, y1]-pegada(0)], [[m0, x1]-invertida, [s2, o1]-invertida], [[m0, x1]-invertida, [s2, o1]-pegada(0)], [[m0, x1]-pegada(1), [s2|...]-invertida], [[m0|...]-pegada(1), [...|...]-pegada(...)], [[...|...]-invertida, ... - ...], [... - ...|...]].
```

La observación tiene equivocados el bit s0 y el acarreo final, y cada uno
de los ocho diagnósticos mínimos toca los dos conos. Es la idea de los **conflictos** en
el diagnóstico basado en la consistencia: cada salida equivocada da un
conjunto de compuertas del que al menos una falla, y los diagnósticos
mínimos son los conjuntos mínimos que tocan a todos.

## Ejercicio 11

<!-- ejemplo: capitulo-49/soluciones.pl predicado: detecta/3 conjunto_de_pruebas/3 elegir/5 -->
```prolog
%!  detecta(+Circuito, +Entradas:list, +Falla:pair) is semidet.
%
%   Con Entradas, Circuito con la Falla da otras salidas que sano.
detecta(Circuito, Entradas, Falla) :-
    predecir(Circuito, Entradas, [], Sanas),
    predecir(Circuito, Entradas, [Falla], ConFalla),
    Sanas \== ConFalla.

%!  conjunto_de_pruebas(+Circuito, -Pruebas:list,
%!      -NoDetectadas:list(pair)) is det.
%
%   Pruebas son entradas elegidas con el criterio voraz, en orden, hasta
%   que ninguna detecta una falla simple más; NoDetectadas son las fallas
%   simples que ninguna entrada detecta.
conjunto_de_pruebas(Circuito, Pruebas, NoDetectadas) :-
    fallas_simples(Circuito, Fallas),
    circuito(Circuito, Nombres, _),
    same_length(Nombres, Es),
    findall(Es, maplist(bit, Es), Entradas),
    elegir(Circuito, Entradas, Fallas, Pruebas, NoDetectadas).

%!  elegir(+Circuito, +Entradas:list, +Fallas:list(pair), -Pruebas:list,
%!      -NoDetectadas:list(pair)) is det.
%
%   Pruebas son las entradas elegidas para detectar Fallas.
elegir(Circuito, Entradas, Fallas, Pruebas, NoDetectadas) :-
    findall(N-Es,
            ( member(Es, Entradas),
              aggregate_all(count,
                            ( member(F, Fallas), detecta(Circuito, Es, F) ),
                            N),
              N > 0 ),
            Puntajes),
    (   Puntajes == []
    ->  Pruebas = [],
        NoDetectadas = Fallas
    ;   sort(1, @>=, Puntajes, [_-Mejor|_]),
        exclude(detecta(Circuito, Mejor), Fallas, Restantes),
        Pruebas = [Mejor|Pruebas1],
        elegir(Circuito, Entradas, Restantes, Pruebas1, NoDetectadas)
    ).
```

```prolog
?- conjunto_de_pruebas(sumador, P, U).
P = [[0, 0, 0], [0, 1, 1], [1, 1, 1]],
U = [].

?- conjunto_de_pruebas(sumador3, P, U).
P = [[0, 0, 0, 0, 0, 0], [1, 0, 0, 1, 1, 1], [0, 1, 1, 1, 1, 1], [0, 0, 0, 0, 1|...]],
U = [].
```

Tres entradas detectan las quince fallas simples del sumador, y cuatro las
treinta y seis del sumador de tres bits; en los dos circuitos toda falla
simple es detectable. El criterio voraz no garantiza el conjunto más pequeño.
En el sumador, tres es el mínimo: recorriendo los 64 pares de entradas con
`detecta/3`, ninguno detecta las quince fallas.

## Ejercicio 12

Las cláusulas nuevas van en `soluciones_negacion.pl`, porque
`negacion.pl` declara `multifile` su teoría:

<!-- ejemplo: capitulo-49/soluciones_negacion.pl fragmento: negacion:abducible(herido(_)). .. negacion:regla(anormal(X), herido(X)). -->
```prolog
negacion:abducible(herido(_)).
negacion:regla(anormal(X), herido(X)).
```

```prolog
?- suponer(vuela(piolin), S), cerrar(S).
S = [gorrion(piolin)-verdadero, pinguino(piolin)-falso, muerto(piolin)-falso, herido(piolin)-falso] ;
false.

?- suponer((no(vuela(piolin)), ave(piolin)), S), cerrar(S).
S = [pinguino(piolin)-verdadero] ;
S = [pinguino(piolin)-verdadero, gorrion(piolin)-verdadero] ;
S = [muerto(piolin)-verdadero, pinguino(piolin)-verdadero] ;
S = [muerto(piolin)-verdadero, gorrion(piolin)-verdadero] ;
S = [herido(piolin)-verdadero, pinguino(piolin)-verdadero] ;
S = [herido(piolin)-verdadero, gorrion(piolin)-verdadero] ;
false.
```

La explicación de que vuela suma un supuesto: para refutar `anormal`, cada
una de sus tres reglas tiene que refutarse, y la nueva pide que Piolín no
esté herido. La explicación de que no vuela suma dos, una por cada manera
de ser ave: la regla nueva es una causa más de anormalidad, y se combina
con cada una. Las explicaciones mínimas pasan de tres a cuatro conjuntos:
ser pingüino, o ser gorrión y estar muerto, o ser gorrión y estar herido;
las combinaciones con pingüino y otra causa contienen a la primera.

## Ejercicio 13

<!-- ejemplo: capitulo-49/soluciones.pl predicado: conjunto_fuerte/3 -->
```prolog
%!  conjunto_fuerte(+Circuito, +Observaciones:list(pair), +Rutas:list)
%!      is semidet.
%
%   Algún diagnóstico del modelo fuerte tiene en falla exactamente las
%   compuertas de Rutas, una lista ordenada.
conjunto_fuerte(Circuito, Observaciones, Rutas) :-
    diagnostico(fuerte, Circuito, Observaciones, Diagnostico),
    rutas(Diagnostico, Rutas),
    !.
```

```prolog
?- conjunto_fuerte(sumador, [[0, 0, 1]-[0, 1], [0, 0, 0]-[1, 0]], [[m1, x1]]).
true.

?- conjunto_fuerte(sumador, [[0, 0, 1]-[0, 1], [0, 0, 0]-[1, 0]], [[m1, x1], [o1]]).
false.
```

Con la XOR `[m1, x1]` pegada a 1 o invertida, el cable t vale 1 en las dos
mediciones, y el circuito las reproduce con la OR sana: con las entradas
0, 0, 1 la OR recibe 0 y 1 y da el acarreo 1 medido; con 0, 0, 0 recibe 0
y 0 y da el 0 medido. Si la OR también está en falla, tiene que dar
esos mismos dos acarreos, y ningún estado de falla lo hace: pegada a 0
falla la primera medición, pegada a 1 la segunda, e invertida las dos. En
el modelo fuerte, entonces, un superconjunto de un diagnóstico no es
siempre un diagnóstico, y `minimos_incrementales/3` pierde las dos razones
en que se apoya: `reducir/4` supone que, si sacar una compuerta rompe el
diagnóstico, sacarla de un conjunto más chico también lo rompe, y la poda
de `excluir/6` supone que lo que no es diagnóstico tampoco lo es con menos
compuertas. En el modelo débil una compuerta en falla puede comportarse
como sana, y las dos suposiciones valen siempre.
