# Aplicaciones: el Wumpus, los marcos y los registros

Esta página contiene la [sección 85.8](index.md#858-aplicaciones-el-wumpus-los-marcos-y-los-registros)
del [capítulo 85](index.md): el motor evalúa, sin cambiarlos, programas
y datos de otros capítulos. El código está en `wumpus.pl`, `marcos.pl` y
`metricas.pl`,
en `ejemplos/capitulo-85/`, con sus pruebas; los dos cargan los archivos
de su capítulo sin copiarlos.

## Las reglas de seguridad del Wumpus

El [capítulo 77](../capitulo-77-proyecto-mundo-wumpus/enfoques.md#el-mismo-conocimiento-seis-inferencias)
escribió las reglas con las que el agente decide qué celdas son seguras
como un programa Datalog, `programa_datalog/2`: los hechos de la cueva
(`celda/1`, `vecina/2`), lo que el agente sabe (`visitada/1`, `brisa/1`,
`hedor/1`) y siete reglas con negación, con las celdas numeradas 10X + Y.
Lo evaluó con `modelo_estandar_de/2` del
[capítulo 38](../capitulo-38-semantica-de-los-programas-logicos/index.md).
`wumpus.pl` evalúa el mismo programa con `evaluar/3`:

<!-- ejemplo: capitulo-85/wumpus.pl predicado: programa_wumpus/2 seguras_motor/2 celdas_seguras/2 -->
```prolog
%!  programa_wumpus(+K, -Clausulas:list) is det.
%
%   Clausulas son los hechos de la cueva y del conocimiento K y las reglas
%   de seguridad: programa_datalog/2 del capítulo 77.
programa_wumpus(K, Clausulas) :-
    enfoques:programa_datalog(K, Clausulas).

%!  seguras_motor(+K, -Seguras:list) is det.
%
%   Seguras son, en orden, las celdas sin visitar que las reglas de
%   seguridad prueban seguras con el conocimiento K del capítulo 77,
%   evaluadas con evaluar/3.
seguras_motor(K, Seguras) :-
    programa_wumpus(K, Clausulas),
    evaluar(Clausulas, Modelo, _),
    celdas_seguras(Modelo, Seguras).

%!  celdas_seguras(+Modelo:list, -Seguras:list) is det.
%
%   Seguras son, en orden, las celdas X-Y de los átomos segura(N) de
%   Modelo, con N = 10 * X + Y.
celdas_seguras(Modelo, Seguras) :-
    findall(C,
            ( member(segura(N), Modelo),
              enfoques:celda_numero(C, N) ),
            Cs),
    sort(Cs, Seguras).
```

<!-- contexto: capitulo-85/wumpus.pl -->
```prolog
?- conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K), seguras_motor(K, S).
K = c(4, 1-2, [1-1-[], 2-1-[brisa], 1-2-[hedor]], no, si, vivo([]), []),
S = [2-2].

?- conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K), programa_wumpus(K, Cs), componentes(Cs, Ks).
K = c(4, 1-2, [1-1-[], 2-1-[brisa], 1-2-[hedor]], no, si, vivo([]), []),
Cs = [(celda(11):-true), (celda(12):-true), (celda(13):-true), (celda(14):-true), (celda(21):-true), (celda(22):-true), (celda(23):-true), (celda(...):-true), (... :- ...)|...],
Ks = [[sin_wumpus_vecina/1], [otro_wumpus/2], [wumpus/1], [sin_wumpus/1], [sin_pozo/1], [segura/1]].
```

Es la situación de la figura 7.4 de Russell y Norvig: la única celda
segura sin visitar es (2, 2). Las reglas no son recursivas, y cada una de
las seis componentes tiene un solo predicado y se resuelve en un paso. El
orden lo imponen las negaciones: `wumpus/1` usa negados a
`sin_wumpus_vecina/1` y a `otro_wumpus/2`, y `sin_wumpus/1` usa
`wumpus/1`. `comparar/2` mide las dos evaluaciones sobre las 85
instantáneas del agente que el
[capítulo 77](../capitulo-77-proyecto-mundo-wumpus/enfoques.md#la-medicion)
usó para comparar sus seis enfoques:

<!-- ejemplo: capitulo-85/wumpus.pl predicado: comparar/2 -->
```prolog
%!  comparar(+Semillas:list, -Resultado) is det.
%
%   Resultado es r(Seguras, Distintas, I38, IMotor) sobre las instantáneas
%   de instantaneas/2 con esas Semillas: las celdas que el motor prueba
%   seguras en total, en cuántas instantáneas su respuesta difiere de la
%   del capítulo 38, y las inferencias de cada evaluación.
comparar(Semillas, r(Seguras, Distintas, I38, IMotor)) :-
    instantaneas(Semillas, Ks),
    inferencias(maplist(seguras_capitulo38, Ks, S38), I38),
    inferencias(maplist(seguras_motor, Ks, SMotor), IMotor),
    maplist(length, SMotor, Ls),
    sum_list(Ls, Seguras),
    aggregate_all(count,
                  ( nth1(I, S38, A), nth1(I, SMotor, B), A \== B ),
                  Distintas).
```

```prolog
?- numlist(1, 20, Ss), comparar(Ss, R).
Ss = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
R = r(188, 0, 3070780, 1977966).
```

Las dos evaluaciones prueban seguras las mismas 188 celdas, sin ninguna
diferencia, y el motor usa un tercio menos de inferencias. La prueba
`costos:wumpus` verifica las celdas con su valor exacto y las inferencias
dentro de un 10 %, porque cambian de una versión de SWI-Prolog a otra. La ganancia es
menor que la de la
[sección 85.4](index.md#854-version-2-relaciones-indexadas-y-la-evaluacion-semi-ingenua)
porque cada instantánea es un programa pequeño, de unos 80 hechos y 137
átomos en el modelo, y una parte fija del costo no depende del tamaño:
verificar que el programa es seguro, construir el grafo de dependencias y
sus componentes, y armar la base. Con una sola instantánea:

<!-- contexto: capitulo-85/wumpus.pl -->
```prolog
?- conocer(4, [1-1-[], 2-1-[brisa], 1-2-[hedor]], K), programa_wumpus(K, Cs), evaluar(Cs, M, C), length(M, N).
K = c(4, 1-2, [1-1-[], 2-1-[brisa], 1-2-[hedor]], no, si, vivo([]), []),
Cs = [(celda(11):-true), (celda(12):-true), (celda(13):-true), (celda(14):-true), (celda(21):-true), (celda(22):-true), (celda(23):-true), (celda(...):-true), (... :- ...)|...],
M = [brisa(21), celda(11), celda(12), celda(13), celda(14), celda(21), celda(22), celda(23), celda(...)|...],
C = costo(6, 104),
N = 137.
```

Seis pasos, uno por componente, y 104 derivaciones (prueba
`costos:wumpus_instantanea`). El agente agrega una
percepción en cada celda que visita, y sería natural mantener el modelo
con la versión 5 del motor en lugar de recalcularlo. No se puede: las
reglas tienen negación, y una brisa nueva quita la conclusión `sin_pozo`
de las celdas vecinas, lo que el paso semi-ingenuo, que solo agrega, no
hace. Es lo que la
[sección 85.7](index.md#857-version-5-los-hechos-que-llegan-despues)
dice de la negación y de la red Rete, que sí retira lo que un hecho
invalidó.

## La herencia de los marcos

Los marcos del
[capítulo 81](../capitulo-81-proyecto-coleccion-problemas/transito-y-marcos.md#marcos)
guardan lo que se sabe de cada objeto en ranuras, `valor(Objeto, Ranura,
Valor)`, y un objeto hereda el valor de una ranura por `es_un`, por
`parte_de` o por `intension` cuando no tiene uno propio. Rowe guarda las
partes en los dos sentidos, con dos reglas que derivan cada una de la
otra; ejecutadas por Prolog, se llaman sin fin cada vez que el dato no
está, y el [capítulo 81](../capitulo-81-proyecto-coleccion-problemas/index.md) las reemplazó por una sola dirección. `marcos.pl`
las escribe como Rowe, como reglas de Prolog sobre los hechos de ese
capítulo:

<!-- ejemplo: capitulo-85/marcos.pl predicado: parte_de_rowe/2 tiene_parte_rowe/2 -->
```prolog
%!  parte_de_rowe(?P, ?O) is nondet.
%
%   P es parte de O: lo dice el marco de P, o O tiene la parte P. Es la
%   regla de Rowe; con tiene_parte_rowe/2, cada una llama a la otra, y
%   Prolog no termina cuando el dato no está.
parte_de_rowe(P, O) :-
    marcos81:valor(P, parte_de, O).
parte_de_rowe(P, O) :-
    tiene_parte_rowe(O, P).

%!  tiene_parte_rowe(?O, ?P) is nondet.
%
%   O tiene la parte P: lo dice el marco de O, o P es parte de O.
tiene_parte_rowe(O, P) :-
    marcos81:valor(O, tiene_parte, P).
tiene_parte_rowe(O, P) :-
    parte_de_rowe(P, O).
```

<!-- contexto: capitulo-85/marcos.pl -->
```prolog
?- call_with_inference_limit(findall(P, tiene_parte_rowe(auto, P), Ps), 1000000, R).
R = inference_limit_exceeded.
```

`call_with_inference_limit/3` corta la consulta después de un millón de
inferencias, y responde `inference_limit_exceeded`: la búsqueda no habría
terminado. Las mismas dos reglas, como parte de un programa Datalog, no
tienen ese problema. `reglas_marcos/1` escribe toda la herencia: las
partes en los dos sentidos, los valores propios, guardados o derivados
(la edad se calcula a partir del año de fabricación, con `is/2`), y los
heredados, que valen solo si el objeto no tiene un valor propio en esa
ranura, una negación:

<!-- ejemplo: capitulo-85/marcos.pl predicado: reglas_marcos/1 -->
```prolog
%!  reglas_marcos(-Reglas:list) is det.
%
%   Las reglas de la herencia, en el orden en que el motor necesita las
%   variables ligadas.
reglas_marcos([
    (parte_de(P, O) :- valor(P, parte_de, O)),
    (parte_de(P, O) :- tiene_parte(O, P)),
    (tiene_parte(O, P) :- valor(O, tiene_parte, P)),
    (tiene_parte(O, P) :- parte_de(P, O)),
    (propio(O, R, V) :- valor(O, R, V)),
    (propio(O, tiene_parte, P) :- tiene_parte(O, P)),
    (propio(O, edad, E) :-
        valor(O, fabricado, A), anio_actual(Hoy), E is Hoy - A),
    (con_propio(O, R) :- propio(O, R, _)),
    (tiene_valor(O, R, V) :- propio(O, R, V)),
    (tiene_valor(O, R, V) :-
        hereda(R, Relacion), valor(O, Relacion, S), \+ con_propio(O, R),
        tiene_valor(S, R, V)),
    (tiene_valor(O, R, V) :-
        valor(O, intension, I), tiene_valor(I, R, V),
        \+ con_propio(O, R))
]).
```

```prolog
?- componentes_marcos(Ks).
Ks = [[parte_de/2, tiene_parte/2], [propio/3], [con_propio/2], [tiene_valor/3]].

?- consulta_marcos(tiene_parte(auto, P), Rs, C).
Rs = [tiene_parte(auto, sistema_electrico)],
C = costo(11, 147).
```

Las dos reglas de Rowe forman una componente recursiva, que se evalúa
hasta su punto fijo y termina. `tiene_valor/3` es otra componente
recursiva, que usa negada a `con_propio/2`, de una componente anterior:
el programa es estratificado. `comparar_marcos/1` compara, para cada
objeto y cada ranura heredable, más la edad y las partes, los valores del
modelo con los que da `tiene_valor/3` del [capítulo 81](../capitulo-81-proyecto-coleccion-problemas/index.md), y son los mismos:

```prolog
?- comparar_marcos(I).
I = true.
```

La transformación mágica no reduce aquí el trabajo: `con_propio/2` se
usa negado, y la transformación lo evalúa completo, junto con `propio/3`
y las partes, de los que depende; lo que queda por especializar es poco.
El [ejercicio 9](index.md#ejercicios) encuentra el mismo efecto en el
Wumpus.

## Las anomalías de los registros

Los informes del
[capítulo 84](../capitulo-84-proyecto-analisis-registros/index.md)
trabajan sobre datos que no cambian: los pedidos de un día, resumidos en
cuatro métricas por hora. Una hora es anómala cuando una métrica pasa un
límite, y `anomalia/3` de ese capítulo recorre las horas y los límites
con `member/2`. Escritas como hechos, las métricas y los límites son una
base extensional, y las anomalías, reglas: `metricas.pl` lee el mismo
día de registros con los predicados del [capítulo 84](../capitulo-84-proyecto-analisis-registros/index.md) y arma el programa:

<!-- ejemplo: capitulo-85/metricas.pl predicado: reglas_metricas/1 -->
```prolog
%!  reglas_metricas(-Reglas:list) is det.
%
%   Las reglas de las anomalías, en el orden en que el motor necesita las
%   variables ligadas.
reglas_metricas([
    (anomala(H, M, V) :- medida(H, M, V), umbral(M, mayor, L), V > L),
    (anomala(H, M, V) :- medida(H, M, V), umbral(M, menor, L), V < L),
    (hora_anomala(H) :- anomala(H, _, _)),
    (normal(H) :- medida(H, pedidos, _), \+ hora_anomala(H)),
    (racha(H, H) :- hora_anomala(H)),
    (racha(D, H1) :- racha(D, H), H1 is H + 1, hora_anomala(H1))
]).
```

Las reglas agregan dos cosas que el [capítulo 84](../capitulo-84-proyecto-analisis-registros/index.md) no calcula: las horas
normales, con una negación, y las **rachas** de horas anómalas seguidas,
con una recursión que usa `is/2` para pasar a la hora siguiente. La regla
es segura: `H1` queda ligada por `is/2` antes de `hora_anomala(H1)`.

<!-- contexto: capitulo-85/metricas.pl -->
```prolog
?- consulta_metricas(registros('2026-10-01.log'), racha(D, H), Rs, C).
Rs = [racha(10, 10), racha(12, 12), racha(14, 14), racha(17, 17), racha(17, 18), racha(18, 18)],
C = costo(6, 25).

?- anomalias_motor(registros('2026-10-01.log'), A), anomalias_capitulo84(registros('2026-10-01.log'), B), A == B.
A = B, B = [10-cpu-3.173641000000001, 10-fallos-62, 12-cpu-2.858283, 14-fallos-24, 17-pedidos-0, 18-pedidos-0].
```

Las anomalías son las mismas seis del [capítulo 84](../capitulo-84-proyecto-analisis-registros/index.md), en las horas 10, 12,
14, 17 y 18; la única racha de más de una hora va de las 17 a las 18, sin
pedidos. Como los datos del día no cambian, el modelo se calcula una vez
y responde todas las preguntas sobre ese día; con un registro que crece,
las reglas con negación impedirían usar la versión 5 del motor, como en
el Wumpus.
