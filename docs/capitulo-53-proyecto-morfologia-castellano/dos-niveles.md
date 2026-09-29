# Dos niveles con transductores

Esta página contiene la [sección 53.5](index.md#535-version-3-dos-niveles-con-los-transductores-del-capitulo-51)
del [capítulo 53](index.md): la versión 3 del analizador, `dos_niveles.pl`,
que carga el módulo `transductores` del
[capítulo 51](../capitulo-51-proyecto-automatas-expresiones-regulares/transductores.md#transductores).

La morfología de dos niveles de Koskenniemi, que Covington presenta, elimina
los niveles intermedios: cada regla relaciona directamente la forma
subyacente con la escrita, y todas se aplican **a la vez**. La palabra se
describe como una sucesión de **pares** Subyacente:Escrita, con la notación
de los transductores del
[capítulo 51](../capitulo-51-proyecto-automatas-expresiones-regulares/transductores.md#transductores):
`[z]:[c]` escribe c por z, `[+]:[]` borra el límite, `[]:[e]` agrega una e.
«Luz+s» y «luces» se alinean así:

| l | u | z | + | | s |
|---|---|---|---|---|---|
| l | u | c | | e | s |

`dos_niveles.pl` define los pares que las reglas admiten, `par/1`, y cada
regla como una lista de **patrones prohibidos**: sucesiones de clases de
pares que no pueden aparecer en ninguna palabra, en cualquier lugar, al
comienzo o al final. La regla de la z dice que z se escribe c si y solo si
sigue una e o una i escritas, quizá después de un límite:

<!-- ejemplo: capitulo-53/dos_niveles.pl fragmento: regla(z, Ps) :- .. append(Ps1, Ps2, Ps). -->
```prolog
regla(z, Ps) :-
    solo_ante_frontal(par([z]:[c]), Ps1),
    no_ante_frontal(par([z]:[z]), Ps2),
    append(Ps1, Ps2, Ps).
```

<!-- ejemplo: capitulo-53/dos_niveles.pl predicado: solo_ante_frontal/2 no_ante_frontal/2 -->
```prolog
%!  solo_ante_frontal(+Clase, -Patrones:list) is det.
%
%   Patrones prohíben un par de la Clase que no esté seguido, quizá
%   después de un límite, por una e o una i escritas.
solo_ante_frontal(C, [ [C, no(o(limite, frontal))]-medio,
                       [C]-final,
                       [C, limite, no(frontal)]-medio,
                       [C, limite]-final ]).

%!  no_ante_frontal(+Clase, -Patrones:list) is det.
%
%   Patrones prohíben un par de la Clase seguido, quizá después de un
%   límite, por una e o una i escritas.
no_ante_frontal(C, [ [C, frontal]-medio,
                     [C, limite, frontal]-medio ]).
```

La epéntesis se escribe igual, con sus patrones a la vista: una e agregada
tiene que seguir a un límite precedido por una consonante y preceder a la s
final, y una consonante, un límite y la s final no pueden aparecer sin ella:

<!-- ejemplo: capitulo-53/dos_niveles.pl fragmento: regla(epentesis, .. ]). -->
```prolog
regla(epentesis,
      [ [no(limite), par([]:[e])]-medio,
        [par([]:[e])]-inicio,
        [no(consonante), limite, par([]:[e])]-medio,
        [limite, par([]:[e])]-inicio,
        [par([]:[e]), no(par([s]:[s]))]-medio,
        [par([]:[e])]-final,
        [par([]:[e]), par([s]:[s]), cualquiera]-medio,
        [consonante, limite, par([s]:[s])]-final
      ]).
```

Las nueve reglas son `limite` (sin dos límites seguidos, ni al comienzo ni
al final), `k`, `u` (la u agregada de «qu» y «gu»), `g`, `z`, `jota`,
`epentesis`, `quitar_tilde` y `poner_tilde`. Ninguna depende del orden de
las otras.

**De una regla a un autómata.** `contiene(R)` es un autómata no
determinista que acepta las sucesiones de pares donde aparece algún patrón
de R: un estado `bucle` que lee cualquier par y, desde él, un camino por
patrón, cuyos estados `p(N, I)` dicen que se leyeron las primeras I clases
del patrón N; al completarlo pasa a `hallado`, de donde ya no sale. El
autómata de la regla es su complemento: `complemento(contiene(R))`, del
[capítulo 51](../capitulo-51-proyecto-automatas-expresiones-regulares/index.md#513-construcciones-el-determinista-el-complemento-la-interseccion),
acepta las sucesiones donde ningún patrón aparece. Con las dos palabras
dadas, la regla acepta o rechaza el alineamiento, como el transductor de la
e final de Covington:

```prolog
?- acepta(complemento(contiene(z)), [[l]:[l], [u]:[u], [z]:[c], [+]:[], []:[e], [s]:[s]]).
true.

?- acepta(complemento(contiene(z)), [[l]:[l], [u]:[u], [z]:[z], [+]:[], []:[e], [s]:[s]]).
false.
```

`ortografia(Rs)` pone en paralelo las reglas de la lista `Rs` con
`interseccion/2`, y descarta las transiciones que llevan a un estado donde
alguna regla ya encontró un patrón: de ese estado no se sale, y sus
transiciones que agregan letras sin leer ninguna formarían ciclos sin fin.
Como es un transductor, `transducir/3` genera:

```prolog
?- transducir(ortografia([epentesis, u]), [l, u, z, +, s], E).
E = [l, ú, c, e, s] ;
E = [l, ú, z, e, s] ;
E = [l, u, c, e, s] ;
E = [l, u, z, e, s] ;
false.
```

Con solo dos reglas, nada impide escribir la z como c ante cualquier letra
ni poner una tilde; con las nueve, la salida es una.

**El léxico como autómata.** Para analizar, Covington recorre el árbol de
letras del léxico a la vez que las reglas: solo propone formas subyacentes
que empiezan como alguna palabra del léxico. `lexico` es ese árbol como
autómata: su estado es el prefijo leído, y cada transición copia una letra
que continúa alguna forma subyacente. Las formas subyacentes son las de
`lexica/2` de la versión 2, en `forma_lexica/2`, y el árbol son las
respuestas de `continuacion/2` con los dos argumentos libres:

<!-- ejemplo: capitulo-53/dos_niveles.pl fragmento: :- table forma_lexica/2 as subsumptive. .. append(Prefijo, [L], Prefijo1). -->
```prolog
:- table forma_lexica/2 as subsumptive.

%!  forma_lexica(?Subyacente:list, ?Analisis) is nondet.
%
%   Subyacente es la forma subyacente, con límites, de Analisis, para
%   cada análisis del léxico. Tabulada por subsunción: una vez completa
%   la tabla de la consulta con los dos argumentos libres, las consultas
%   más particulares toman de ella sus respuestas.
forma_lexica(Subyacente, Analisis) :-
    analisis(Analisis),
    lexica(Analisis, Subyacente).

:- table continuacion/2 as subsumptive.

%!  continuacion(?Prefijo:list, ?L) is nondet.
%
%   La letra L continúa Prefijo en alguna forma subyacente del léxico.
%   Con los dos argumentos libres, sus respuestas son el árbol de letras
%   del léxico; tabulada por subsunción, como forma_lexica/2.
continuacion(Prefijo, L) :-
    forma_lexica(Forma, _),
    append(Prefijo, [L|_], Forma).

% El léxico como autómata: el estado es el prefijo leído, y cada
% transición copia una letra que lo continúa. El estado inicial completa
% las dos tablas, y así cada paso es una consulta al árbol.

automatas:inicial(lexico, []) :-
    once(continuacion(_, _)).
automatas:final(lexico, Prefijo) :-
    forma_lexica(Prefijo, _),
    !.
automatas:delta(lexico, Prefijo, [L]:[L], Prefijo1) :-
    continuacion(Prefijo, L),
    append(Prefijo, [L], Prefijo1).
```

Las dos tablas son **por subsunción** (`as subsumptive`): una consulta
como `continuacion([k], L)`, más particular que `continuacion(_, _)`, toma
sus respuestas de la tabla de esta si ya está completa, en lugar de abrir
una tabla propia y recorrer el léxico otra vez; con la tabulación por
variantes del [capítulo 39](../capitulo-39-tabulacion/index.md), cada
prefijo nuevo recorría las 328 formas. El estado inicial completa la tabla
general, y desde ahí cada paso es una consulta al árbol.

`compuesta(lexico, ortografia(Rs))` lee con el léxico y escribe con las
reglas; en sentido inverso, de la palabra escrita a la subyacente, el
léxico descarta cada hipótesis en cuanto deja de ser el comienzo de una
palabra:

```prolog
?- transducir(compuesta(lexico, ortografia([epentesis, u])), S, [l, u, c, e, s]).
S = [l, u, z, +, s] ;
false.
```

!!! question "Actividad"
    Sin el léxico, ¿qué formas subyacentes admiten las reglas `epentesis` y
    `u` para [l, u, c, e, s]? Predecir si son finitas, y por qué la regla
    `limite` importa para esa pregunta. Contarlas después con la versión 4
    en la [sección 53.6](index.md#536-version-4-las-reglas-en-paralelo).

**Lo que no puede hacer: todas las reglas juntas.** `transducir/3` recorre
solo los estados que la palabra alcanza, pero para saber si un estado de
`interseccion/2` es final, el [capítulo 51](../capitulo-51-proyecto-automatas-expresiones-regulares/index.md) construye el autómata producto
entero, con `alcanzable/2`. Los estados del producto son combinaciones de
estados de las reglas, y su número se multiplica con cada regla que se
agrega. Generar «luces» desde «luz+s» mide:

| Reglas | Estados del producto | Tiempo | Inferencias |
|---|---|---|---|
| `epentesis`, `u` | 91 | 1,5 s | 7,3 millones |
| y `z` | 307 | 10,3 s | 38,6 millones |
| y `quitar_tilde` | 1 287 | 87 s | 299 millones |
| y `poner_tilde` | 4 465 | 525 s | 1 458 millones |

Cada regla multiplica los estados por tres o cuatro y el tiempo por seis a
nueve; con las nueve reglas, la construcción no es practicable. Covington,
al criticar la morfología de dos niveles, recuerda que su formalismo
alcanza para codificar problemas NP-completos; aquí el costo aparece antes,
en un producto que se construye entero para responder sobre una palabra de
cinco letras.
