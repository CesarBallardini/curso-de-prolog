# Los enfoques comparados

Esta página desarrolla la [sección 77.1](index.md#771-seis-maneras-de-programar-el-agente)
del [capítulo 77](index.md): el código de cada una de las seis maneras de
decidir qué celdas son seguras, y la medición que las compara. El archivo
es `enfoques.pl`, en `ejemplos/capitulo-77/`, con sus pruebas; carga el
agente de la versión 3, el evaluador del
[capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md) y
el demostrador del
[capítulo 62](../capitulo-62-proyecto-demostrador-teoremas/index.md).

## El mismo conocimiento, seis inferencias

Los seis enfoques reciben el mismo término: el conocimiento `c/7` del
agente de la versión 3, con las celdas visitadas y lo que se percibió en
cada una. Devuelven la lista de las celdas sin visitar que prueban
seguras, sin pozo y sin el wumpus. `seguras_con/3` recibe el nombre del
enfoque:

<!-- ejemplo: capitulo-77/enfoques.pl predicado: seguras_con/3 -->
```prolog
%!  seguras_con(+Enfoque, +K, -Seguras:list) is det.
%
%   Seguras son las celdas sin visitar que Enfoque prueba seguras con el
%   conocimiento K, en orden.
seguras_con(mundos, K, Seguras) :-
    seguras(K, Seguras).
seguras_con(reglas, K, Seguras) :-
    sin_visitar(K, Cs),
    include(segura_por_reglas(K), Cs, Seguras).
seguras_con(datalog, K, Seguras) :-
    programa_datalog(K, Clausulas),
    modelo_estandar_de(Clausulas, Modelo),
    findall(C, ( member(segura(N), Modelo), celda_numero(C, N) ), Cs),
    sort(Cs, Seguras).
seguras_con(resolucion, K, Seguras) :-
    sin_visitar(K, Cs),
    clausulas_primer_orden(K, Base),
    include(segura_por_resolucion(Base), Cs, Seguras).
seguras_con(clpb, K, Seguras) :-
    sin_visitar(K, Cs),
    formula(K, Base),
    include(segura_por_clpb(Base), Cs, Seguras).
seguras_con(clpfd, K, Seguras) :-
    sin_visitar(K, Cs),
    include(segura_por_clpfd(K), Cs, Seguras).
```

**Reglas resueltas por Prolog.** Son las reglas del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#207-el-agente-del-mundo-del-wumpus)
con una más: una celda no tiene pozo si una vecina visitada no tuvo brisa,
no tiene el wumpus si una vecina visitada no tuvo hedor, y el wumpus está
en una celda cuando es la única candidata de un hedor. Una vez ubicado, el
resto de las celdas queda libre de él:

<!-- ejemplo: capitulo-77/enfoques.pl predicado: sin_wumpus/2 wumpus_en/2 -->
```prolog
%!  sin_wumpus(+K, +C) is semidet.
%
%   Una vecina visitada de C no tuvo hedor, o el wumpus está probado en
%   otra celda.
sin_wumpus(K, C) :-
    K = c(N, _, _, _, _, _, _),
    (   vecina(N, C, V),
        visitada(K, V),
        \+ percibio(K, V, hedor)
    ->  true
    ;   wumpus_en(K, W),
        W \== C
    ->  true
    ).

%!  wumpus_en(+K, -W) is semidet.
%
%   Una celda visitada tuvo hedor y W es la única de sus vecinas donde el
%   wumpus puede estar.
wumpus_en(K, W) :-
    K = c(N, _, _, _, _, _, _),
    once(( percibio(K, V, hedor),
           findall(D,
                   ( vecina(N, V, D),
                     \+ visitada(K, D),
                     \+ ( vecina(N, D, E),
                          visitada(K, E),
                          \+ percibio(K, E, hedor) ) ),
                   [W]) )).
```

Es el enfoque más barato: 897 inferencias en la situación de la figura 7.4
de Russell y Norvig. Su límite es el de toda regla escrita a mano: cubre
los casos que se previeron. Con hedor en (1, 3) y en (2, 2), cada hedor
tiene dos candidatas, y la regla de la única candidata no se aplica,
aunque las dos juntas dejan una sola celda posible, (2, 3):

<!-- contexto: capitulo-77/enfoques.pl -->
```prolog
?- conocer(4, [1-1-[], 1-2-[], 1-3-[hedor], 2-2-[hedor]], K), seguras_con(reglas, K, S1), seguras_con(mundos, K, S2).
K = c(4, 2-2, [1-1-[], 1-2-[], 1-3-[hedor], 2-2-[hedor]], no, si, vivo([]), []),
S1 = [2-1],
S2 = [1-4, 2-1, 3-2].
```

Una regla para dos hedores resuelve este caso; el ejercicio 5 la
escribe. Otras combinaciones pedirían otras reglas.

**Las mismas reglas como datos.** `modelo_estandar_de/2`, de la
[sección 38.6](../capitulo-38-semantica-de-los-programas-logicos/index.md#386-evaluacion-de-abajo-hacia-arriba),
recibe un programa estratificado como una lista de cláusulas y calcula su
modelo estrato por estrato. El programa son los hechos de la cueva y del
conocimiento, y estas reglas; las celdas son números, 10X + Y, porque el
evaluador solo compara números, y cada negación está después de los
literales que ligan sus variables:

<!-- ejemplo: capitulo-77/enfoques.pl predicado: reglas_datalog/1 -->
```prolog
%!  reglas_datalog(-Reglas:list) is det.
%
%   Las reglas de seguridad, en el orden en que el evaluador necesita las
%   variables ligadas.
reglas_datalog([
    (sin_pozo(C) :- vecina(C, V), visitada(V), \+ brisa(V)),
    (sin_wumpus_vecina(C) :- vecina(C, V), visitada(V), \+ hedor(V)),
    (otro_wumpus(V, C) :-
        vecina(V, C), vecina(V, D), D =\= C, \+ visitada(D),
        \+ sin_wumpus_vecina(D)),
    (wumpus(C) :-
        hedor(V), vecina(V, C), \+ visitada(C), \+ sin_wumpus_vecina(C),
        \+ otro_wumpus(V, C)),
    (sin_wumpus(C) :- sin_wumpus_vecina(C)),
    (sin_wumpus(C) :- wumpus(W), celda(C), C =\= W),
    (segura(C) :- celda(C), \+ visitada(C), sin_pozo(C), sin_wumpus(C))
]).
```

La respuesta es la misma que la de las reglas de Prolog, con cincuenta
veces más inferencias: el evaluador calcula el modelo entero, todas las
celdas seguras y todos los hechos intermedios, aunque la pregunta sea por
una sola. La ventaja está en otra parte: el programa es un dato que se
puede examinar, y un motor que agrega hechos de a uno, como el
[sistema de producción](../capitulo-63-proyecto-sistema-produccion/index.md)
o el [algoritmo Rete](../capitulo-64-proyecto-algoritmo-rete/index.md),
propagaría solo lo que cambia con cada percepción nueva.

**Resolución de primer orden.** El mundo se escribe con dos cláusulas
universales, «un pozo da brisa en cada vecina» y «el wumpus da hedor en
cada vecina», más las vecindades y las percepciones como cláusulas
unitarias. Una celda es segura si el demostrador del
[capítulo 62](../capitulo-62-proyecto-demostrador-teoremas/index.md)
refuta, en a lo sumo tres pasos, tanto `pozo(C)` como `wumpus(C)`:

<!-- ejemplo: capitulo-77/enfoques.pl predicado: segura_por_resolucion/2 -->
```prolog
%!  segura_por_resolucion(+Base:list, +C) is semidet.
%
%   Hay refutaciones de a lo sumo tres pasos de Base con pozo(C) y de Base
%   con wumpus(C).
segura_por_resolucion(Base, C) :-
    refutar_fo([[+pozo(C)]|Base], 3, _),
    refutar_fo([[+wumpus(C)]|Base], 3, _).
```

Las dos cláusulas dicen solo la mitad del mundo: que un pozo produce
brisa, no que la brisa exige un pozo. La otra mitad necesita un
cuantificador existencial, «si hay brisa, hay un pozo en alguna vecina»,
que la forma clausal convierte en una función de Skolem, y además axiomas
que digan que dos celdas de nombre distinto son distintas. Sin ellos, el
demostrador prueba lo mismo que las reglas simples del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md), a un costo de
cuatro millones de inferencias por instantánea; con ellos, la búsqueda de
refutaciones crece más allá de lo que el límite de pasos permite.

**Lógica proposicional con `library(clpb)`.** Con una cueva finita, cada
afirmación sobre una celda es un átomo: `pozo(2-2)`, `brisa(2-1)`. El
conocimiento es una sola fórmula, en la sintaxis del [capítulo 62](../capitulo-62-proyecto-demostrador-teoremas/index.md): las
celdas visitadas no tienen peligros, cada brisa equivale a la disyunción
de los pozos vecinos, cada hedor a la del wumpus, y hay un wumpus y solo
uno. `tautologia/2`, de la
[página de comparación del capítulo 62](../capitulo-62-proyecto-demostrador-teoremas/comparacion.md#tres-maneras-de-decidir),
decide si la fórmula implica que la celda no tiene pozo ni wumpus:

<!-- ejemplo: capitulo-77/enfoques.pl predicado: segura_por_clpb/2 -->
```prolog
%!  segura_por_clpb(+Base, +C) is semidet.
%
%   Base implica que C no tiene pozo ni wumpus: la implicación es una
%   tautología.
segura_por_clpb(Base, C) :-
    tautologia(clpb, si(Base, y(no(at(pozo(C))), no(at(wumpus(C)))))).
```

Es la formulación de Russell y Norvig, y es completa: prueba todo lo que
se sigue del conocimiento. El costo está en la construcción: cada llamada
traduce la fórmula entera, con las 120 disyunciones que dicen que no hay
dos wumpus, a un diagrama de decisión binario. `formula/2` está en el
archivo.

**Restricciones sobre enteros.** Una variable 0/1 por celda para los
pozos y otra para el wumpus; cada percepción es una suma de vecinas,
positiva o nula, y la suma de las variables del wumpus es 1. Una celda es
segura si no existe un mundo que cumpla las restricciones con un peligro
en ella:

<!-- ejemplo: capitulo-77/enfoques.pl predicado: mundo_con/3 restringir/4 -->
```prolog
%!  mundo_con(+K, +Peligro, +C) is semidet.
%
%   Hay un mundo consistente con K que pone Peligro en C: una variable 0/1
%   por celda para los pozos y otra para el wumpus, las celdas visitadas
%   en 0, cada percepción como una suma de vecinas, un solo wumpus.
mundo_con(K, Peligro, C) :-
    K = c(N, _, Vs, _, _, _, _),
    findall(X-Y, ( between(1, N, X), between(1, N, Y) ), Todas),
    length(Todas, L),
    length(Pozos, L),
    length(Wumpus, L),
    Pozos ins 0..1,
    Wumpus ins 0..1,
    pairs_keys_values(PP, Todas, Pozos),
    pairs_keys_values(PW, Todas, Wumpus),
    sum(Wumpus, #=, 1),
    maplist(restringir(N, PP, PW), Vs),
    (   Peligro == pozo
    ->  memberchk(C-Var, PP)
    ;   memberchk(C-Var, PW)
    ),
    Var #= 1,
    append(Pozos, Wumpus, Vars),
    once(label(Vars)).

%!  restringir(+N:integer, +PP:list, +PW:list, +Visitada) is det.
%
%   Impone las restricciones de Visitada, un par V-Ps de una celda y sus
%   percepciones: sin peligros en V, y la suma de los peligros vecinos es
%   positiva si y solo si se percibió su señal. Las restricciones se
%   imponen con maplist/2, no con forall/2, que las desharía al terminar.
restringir(N, PP, PW, V-Ps) :-
    memberchk(V-P0, PP),
    memberchk(V-W0, PW),
    P0 #= 0,
    W0 #= 0,
    findall(Vec, vecina(N, V, Vec), Vecinas),
    maplist(variable_de(PP), Vecinas, XsP),
    maplist(variable_de(PW), Vecinas, XsW),
    senal(brisa, Ps, XsP),
    senal(hedor, Ps, XsW).
```

Las restricciones se imponen con `maplist/2`. Con `forall/2` se
desharían al terminar, porque `forall/2` prueba su objetivo dentro de una
doble negación: ningún mundo quedaría excluido, y ninguna celda resultaría
segura.

**Mundos consistentes.** Es el enfoque de la versión 3:
`mundos_pozos/2` genera los conjuntos de pozos de la frontera que
explican cada brisa, y `posiciones_wumpus/2` las celdas que explican cada
hedor. Como el anterior, busca mundos; a diferencia de él, los enumera
todos, y la misma lista sirve para probar la seguridad y para calcular
probabilidades.

## La medición

`instantaneas/2` toma el conocimiento del agente prudente de la versión 3
después de cada celda nueva que visita, en los mundos sembrados que se le
indican, y le agrega la situación de la figura 7.4. Con las semillas 1 a
20 son 85 instantáneas. `comparar_en/3` cuenta las celdas que cada
enfoque prueba seguras, en cuántas instantáneas su respuesta difiere de
la de los mundos consistentes y cuántas inferencias usa:

```prolog
?- numlist(1, 20, Ss), comparar_en(reglas, Ss, R).
Ss = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
R = r(188, 2, 62060).

?- numlist(1, 20, Ss), comparar_en(mundos, Ss, R).
Ss = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
R = r(192, 0, 283674).

?- numlist(1, 20, Ss), comparar_en(datalog, Ss, R).
Ss = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
R = r(188, 2, 3070526).

?- numlist(1, 20, Ss), comparar_en(clpfd, Ss, R).
Ss = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
R = r(192, 0, 14907623).
```

`clpb` y la resolución tardan más de lo que una consulta del curso debe
tardar, y se midieron fuera del texto con las mismas instantáneas:
`r(192, 0, 180756834)` en 34 segundos y `r(186, 4, 350199373)` en 84
segundos. Las diferencias de las reglas son las dos instantáneas con dos
hedores, en las que les faltan dos celdas cada vez; la resolución,
además, no usa la ubicación del wumpus para liberar las demás celdas.

!!! question "Actividad"
    Predecir qué responde `seguras_con(E, K, S)` para cada uno de los seis
    enfoques con el conocimiento `[1-1-[], 1-2-[hedor], 2-1-[hedor]]`, y
    comprobarlo. Explicar la respuesta de las reglas con la regla de la
    única candidata.
