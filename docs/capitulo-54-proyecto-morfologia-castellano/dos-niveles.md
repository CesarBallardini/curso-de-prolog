# Dos niveles con transductores

Esta página continúa el [capítulo 54](index.md) después de la
[sección 54.4](index.md#544-version-2-forma-subyacente-y-reglas), con las
secciones [54.5](#545-version-3-dos-niveles-con-los-transductores-del-capitulo-52) y
[54.6](#546-version-4-las-reglas-en-paralelo): la versión 3 del analizador,
`dos_niveles.pl`, que carga el módulo `transductores` del
[capítulo 52](../capitulo-52-proyecto-automatas-expresiones-regulares/transductores.md#transductores)
y aplica las reglas a la vez como autómatas en paralelo, y la versión 4,
`paralelo.pl`, que hace lo mismo sin construir el autómata de todas las
reglas juntas.

## 54.5 Versión 3: dos niveles, con los transductores del capítulo 52

La morfología de dos niveles de Koskenniemi, que Covington presenta, elimina
los niveles intermedios: cada regla relaciona directamente la forma
subyacente con la escrita, y todas se aplican **a la vez**. La palabra se
describe como una sucesión de **pares** Subyacente:Escrita, con la notación
de los transductores del
[capítulo 52](../capitulo-52-proyecto-automatas-expresiones-regulares/transductores.md#transductores):
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

<!-- ejemplo: capitulo-54/dos_niveles.pl fragmento: regla(z, Ps) :- .. append(Ps1, Ps2, Ps). -->
```prolog
regla(z, Ps) :-
    solo_ante_frontal(par([z]:[c]), Ps1),
    no_ante_frontal(par([z]:[z]), Ps2),
    append(Ps1, Ps2, Ps).
```

<!-- ejemplo: capitulo-54/dos_niveles.pl predicado: solo_ante_frontal/2 no_ante_frontal/2 -->
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

<!-- ejemplo: capitulo-54/dos_niveles.pl fragmento: regla(epentesis, .. ]). -->
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
[capítulo 52](../capitulo-52-proyecto-automatas-expresiones-regulares/index.md#523-construcciones-el-determinista-el-complemento-la-interseccion),
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

<!-- ejemplo: capitulo-54/dos_niveles.pl fragmento: :- table forma_lexica/2 as subsumptive. .. append(Prefijo, [L], Prefijo1). -->
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
variantes del [capítulo 40](../capitulo-40-tabulacion/index.md), cada
prefijo nuevo recorría las 328 formas. El estado inicial completa la tabla
general, y desde ahí cada paso es una consulta al árbol.

`compuesta(lexico, ortografia(Rs))` lee con el léxico y escribe con las
reglas; en sentido inverso, de la palabra escrita a la subyacente, el
léxico descarta cada hipótesis en cuanto deja de ser el comienzo de una
palabra:

```prolog
?- findall(S, transducir(compuesta(lexico, ortografia([epentesis, u])), S, [l, u, c, e, s]), Ss).
Ss = [[l, u, z, +, s]].
```

!!! question "Actividad"
    Sin el léxico, ¿qué formas subyacentes admiten las reglas `epentesis` y
    `u` para [l, u, c, e, s]? Predecir si son finitas, y por qué la regla
    `limite` importa para esa pregunta. Contarlas después con la versión 4
    en la [sección 54.6](#546-version-4-las-reglas-en-paralelo).

**Lo que no puede hacer: todas las reglas juntas.** `transducir/3` recorre
solo los estados que la palabra alcanza, pero para saber si un estado de
`interseccion/2` es final, el [capítulo 52](../capitulo-52-proyecto-automatas-expresiones-regulares/index.md) construye el autómata producto
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

## 54.6 Versión 4: las reglas en paralelo

El producto de las reglas no hace falta. Para decidir si una sucesión de
pares es correcta basta con leerla con todas las reglas a la vez y
rechazarla en cuanto una encuentra un patrón prohibido; los estados que
importan son los que la palabra alcanza. `paralelo(Rs)` es ese
transductor: su estado es la lista de los estados de cada regla, y el
estado de una regla es el conjunto de estados de `contiene(R)` donde está la
lectura, como en el determinista del [capítulo 52](../capitulo-52-proyecto-automatas-expresiones-regulares/index.md), pero calculado solo al
pasar por él:

<!-- ejemplo: capitulo-54/paralelo.pl fragmento: automatas:alfabeto(paralelo(_), Pares) :- .. memberchk(hallado, D1). -->
```prolog
automatas:alfabeto(paralelo(_), Pares) :-
    findall(P, par(P), Pares0),
    sort(Pares0, Pares).
automatas:inicial(paralelo(Rs), Ds) :-
    maplist(inicial_regla, Rs, Ds).
automatas:final(paralelo(Rs), Ds) :-
    maplist(acepta_regla, Rs, Ds).
automatas:delta(paralelo(Rs), Ds, P, Ds1) :-
    par(P),
    maplist(paso(P), Rs, Ds, Ds1).

%!  inicial_regla(+R, -D:list) is det.
%
%   D es el conjunto de estados de contiene(R) antes de leer un par.
inicial_regla(R, D) :-
    inicial(contiene(R), Q0),
    clausura_conjunto(contiene(R), [Q0], D).

%!  acepta_regla(+R, +D:list) is semidet.
%
%   Ningún estado de D es final en contiene(R): la sucesión leída no
%   tiene un patrón prohibido por R.
acepta_regla(R, D) :-
    \+ ( member(Q, D), final(contiene(R), Q) ).

:- table paso/4.

%!  paso(+P, +R, +D:list, -D1:list) is semidet.
%
%   Leyendo el par P, la regla R pasa del conjunto D al D1, y no encuentra
%   un patrón prohibido en el medio de la palabra. Tabulada: cada paso se
%   calcula una vez.
paso(P, R, D, D1) :-
    mover(contiene(R), P, D, D1),
    \+ memberchk(hallado, D1).
```

Un paso de una regla que llega a `hallado` falla: la regla rechaza, y el
transductor no tiene estados muertos. `paso/4` está tabulado, como las
tablas de transiciones que KIMMO compila de antemano; aquí se llenan a
medida que las palabras las necesitan, y se reutilizan.

`forma/2`, en la [sección 54.1](index.md#541-el-programa-terminado), analiza con
`inversa/1` aplicado al léxico compuesto con las reglas: el analizador es el
transductor inverso del generador. Las tres construcciones de transductores
del [capítulo 52](../capitulo-52-proyecto-automatas-expresiones-regulares/index.md) aparecen en la versión 4; `identidad/1` sirve para la forma
subyacente de un lema, que la versión 2 obtenía con `escribir/2`: compuestas
con la identidad sobre las letras sin límite, las reglas en sentido inverso
no pueden proponer un `+`:

<!-- ejemplo: capitulo-54/paralelo.pl predicado: raiz/2 -->
```prolog
%!  raiz(+Palabra:string, -Subyacente:list) is nondet.
%
%   Subyacente es una forma subyacente sin límites cuya forma escrita es
%   Palabra: la de un lema, como subyacente/2 de la versión 2. La
%   identidad sobre las letras sin el límite + restringe el nivel
%   subyacente antes de las reglas.
raiz(Palabra, Subyacente) :-
    reglas(Rs),
    findall(L, ( par([L]:_), L \== + ), Ls0),
    sort(Ls0, Ls),
    string_chars(Palabra, Letras),
    transducir(inversa(compuesta(identidad(Ls), paralelo(Rs))), Letras,
               Subyacente).
```

```prolog
?- findall(S, raiz("proteger", S), Ss).
Ss = [[p, r, o, t, e, 'J', e, r]].

?- reglas(_Rs), findall(_S, transducir(paralelo(_Rs), _S, [l, u, c, e, s]), _Ss), length(_Ss, N).
N = 26.
```

Las reglas solas admiten 26 formas subyacentes para «luces»: «luz+s»,
«luz+es», «lu+z+s», «lúz+s» y otras, todas bien escritas y ninguna
descartable sin saber qué palabras existen. Es la sobregeneración que
Covington atribuye a las reglas que borran letras; el léxico la elimina, y
por eso analiza con él.

**Lo que se gana.** Las pruebas comparan la versión 4 con la 2 en todo el
léxico: las 328 formas generadas y los análisis de cada una son los mismos.
Las nueve reglas juntas responden en décimas de segundo. Medido en
inferencias, en un proceso nuevo, con el léxico del capítulo y con los 500
verbos de `grande.pl`:

| Inferencias | Versión 2 | Versión 4 |
|---|---|---|
| analizar «luces», la primera consulta | 68 296 | 191 549 |
| analizar «cuentas», después | 68 294 | 46 183 |
| con `grande.pl`: analizar «luces», la primera consulta | 1 072 796 | 761 612 |
| con `grande.pl`: analizar «cuentas», después | 1 072 794 | 14 994 |
| generar «cuento», después | 303 | 516 587 |

La primera consulta de la versión 4 completa las tablas de las formas
subyacentes y del árbol de letras, y ese costo crece con el léxico; es
una vez. Después, analizar una palabra cuesta lo que cuestan los caminos que
la palabra abre en el árbol y en las reglas, y no crece con el léxico: con
veinte veces más formas, «cuentas» cuesta menos, porque la primera consulta
dejó tabulados más pasos de las reglas. La versión 2 recorre el léxico en
cada análisis. Generar, en cambio, es más barato con la versión 2, que
aplica cuatro pasadas a una lista, que con el transductor, que en cada
posición prueba los 46 pares.

El capítulo continúa en la página
[Notación de dos niveles y derivación](derivacion.md#547-version-5-reglas-en-notacion-de-dos-niveles), con las
reglas escritas en la notación de Koskenniemi y la derivación.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que agregan palabras o reglas lo hacen desde un
archivo propio, con cláusulas como `lexico:verbo("empezar", e_ie).`: el léxico
declara `multifile` sus predicados, la versión 2 su tabla `diptongo/3` y la
versión 3 `regla/2` y `par/1`.

7. **(1)** Agregar al léxico los nombres «nariz» y «razón», femeninos, y
   «origen», masculino, y el adjetivo invariable «cortés», sin cambiar
   ninguna regla. Predecir sus plurales y comprobar que las versiones 2 y 4
   dan los mismos.
8. **(2)** Escribir `candidatos(Palabra, Subyacentes)`, las formas
   subyacentes que las reglas de la versión 4 admiten sin el léxico.
   Contarlas para «luces», «toqué» y «camiones», clasificar las de
   «toqué», y explicar qué pasaría sin la regla `limite`.
9. **(2)** Escribir `conjugacion(Lema, Tiempo, Formas)`, las seis formas de
   un verbo en un tiempo, en el orden de las personas, con la versión 4.
   Escribir su encabezado PlDoc y justificar la determinación que declara.
   ¿Qué debe hacer con un lema que no es un verbo?
10. ★ **(3)** «Leer» y «creer» escriben y la i de la terminación que queda
    entre vocales: «leyó», «creyeron». Agregar a la versión 4 una regla
    `ye` con el par `[i]:[y]`, y los dos verbos. Comprobar que las demás
    formas del léxico no cambian. ¿Qué escribe la versión 4 para la
    primera persona del plural del pretérito, y por qué no alcanza con
    agregar otra regla para ponerle la tilde? ¿Qué escribe la versión 2?
11. **(3)** «Averiguar» escribe ü la u que suena entre g y e: «averigüé».
    Agregar a la versión 4 una regla `dieresis` con el par `[u]:['ü']`.
    ¿Qué regla existente impide ya escribir «averigue», y por qué la
    versión 2 no genera ninguna forma para ese pretérito?
12. **(3)** Escribir `adivinar(Palabra, Analisis)`, que analiza formas de
    verbos regulares que el léxico no tiene: entre las formas subyacentes
    que las reglas admiten sin el léxico, se queda con las que son una
    raíz, un límite y una terminación, y escribe el infinitivo de esa raíz
    con las mismas reglas. Probarlo con «bloguearon», «tuiteé» y
    «chateamos». ¿Qué responde para «cuentas», y por qué?

## Referencias

- Michael A. Covington, *Natural Language Processing for Prolog Programmers*,
  Prentice-Hall, 1994; edición digital del autor, 2013,
  <https://www.covingtoninnovations.com/books/NLPPP.pdf>. Capítulo «Morphology
  and the Lexicon»: la morfología de dos niveles de Koskenniemi, con las reglas
  como transductores finitos que se aplican en paralelo y el léxico que guía el
  análisis («Two-Level Morphology», «Rules and Transducers»); la
  sobregeneración; y la crítica de su costo («Critique of Two-Level
  Morphology»).
- Kimmo Koskenniemi, *Two-Level Morphology: A General Computational Model for
  Word-Form Recognition and Production*, Publicación 11 del Departamento de
  Lingüística General, Universidad de Helsinki, 1983; y su resumen en «A General
  Computational Model for Word-Form Recognition and Production», *COLING 1984*
  ([ACL Anthology P84-1038](https://aclanthology.org/P84-1038/)). Covington toma
  de allí la morfología de dos niveles; el capítulo, a través de él, la palabra
  como sucesión de pares subyacente:escrita, las reglas que relacionan
  directamente los dos niveles sin niveles intermedios, y su aplicación en
  paralelo, de las versiones 3 y 4.
- Lauri Karttunen, «KIMMO: A General Morphological Processor», *Texas Linguistic
  Forum* 22, 1983, pp. 165–186. Es la implementación de la morfología de dos
  niveles que Covington describe; el capítulo compara con ella las tablas de
  transiciones que la versión 4 llena a medida que las palabras las necesitan.
- G. Edward Barton, Robert C. Berwick y Eric Sven Ristad, *Computational
  Complexity and Natural Language*, MIT Press, 1987; y G. Edward Barton,
  «Computational Complexity in Two-Level Morphology», *24th Annual Meeting of
  the Association for Computational Linguistics*, 1986
  ([ACL Anthology P86-1009](https://aclanthology.org/P86-1009/)). Covington los
  cita para la crítica de la morfología de dos niveles; el capítulo toma de allí
  que el formalismo alcanza para codificar problemas NP-completos, que la página
  de la versión 3 contrasta con el costo del autómata producto.
- Edward Fredkin, «Trie Memory», *Communications of the ACM* 3(9), 1960, pp.
  490–499; y René de la Briandais, «File Searching Using Variable Length Keys»,
  *Proceedings of the Western Joint Computer Conference*, 1959, pp. 295–298.
  Covington los cita para el árbol de letras; el capítulo toma de allí el léxico
  como árbol de prefijos, que la versión 3 convierte en autómata.
