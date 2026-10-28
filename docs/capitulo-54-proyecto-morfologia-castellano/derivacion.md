# Notación de dos niveles y derivación

Esta página continúa la página
[Dos niveles con transductores](dos-niveles.md#546-version-4-las-reglas-en-paralelo) del
[capítulo 54](index.md), con las secciones [54.7](#547-version-5-reglas-en-notacion-de-dos-niveles) y
[54.8](#548-version-6-la-derivacion-y-los-prefijos): la versión 5, `kimmo.pl`, que escribe las reglas en
la notación de Koskenniemi y las compila a patrones prohibidos, y la versión
6, `derivacion.pl`, que agrega la derivación y los prefijos. Las dos cargan
la versión 4.

## 54.7 Versión 5: reglas en notación de dos niveles

Las reglas de la [sección 54.5](dos-niveles.md#545-version-3-dos-niveles-con-los-transductores-del-capitulo-52)
son listas de patrones prohibidos, escritas a mano. Koskenniemi las escribe
de otra manera: un par Subyacente:Escrita, un operador y un contexto, con un
guion bajo en el lugar del par. Covington da como ejemplo la regla de la e
final del inglés:

```text
e:0 => C:C _ +:0 V:V
```

La e subyacente se borra (`e:0`) solo entre una consonante y un límite
seguido de una vocal. Los operadores son tres. Con `=>`, la
**restricción de contexto**, el par solo puede aparecer en ese contexto.
Con `<=`, la **coerción**, en ese contexto la letra subyacente del par solo
puede escribirse así. Con `<=>` valen las dos. KIMMO compila cada regla en
un transductor finito. `kimmo.pl` la compila en la lista de patrones de la
versión 3, y la registra como una regla más: la versión 4 la aplica en
paralelo con las otras, sin cambios. Una regla se escribe con
`regla_dos_niveles/5`, con el contexto izquierdo como una lista de clases y
los derechos como una lista de alternativas:

<!-- ejemplo: capitulo-54/kimmo.pl fragmento: % regla_dos_niveles(Nombre, Par, Operador, Izquierda, Derechas): una regla .. [[limite, frontal], [frontal]]). -->
```prolog
% regla_dos_niveles(Nombre, Par, Operador, Izquierda, Derechas): una regla
% en la notación de dos niveles. Otros archivos pueden agregar reglas.
:- multifile regla_dos_niveles/5.

regla_dos_niveles(nasal, ['N']:[m], '<=>', [],
                  [[limite, o(par([p]:[p]), par([b]:[b]))]]).
regla_dos_niveles(nasal_n, ['N']:[n], '=>', [], [[limite]]).
regla_dos_niveles(z_k, [z]:[c], '<=>', [],
                  [[limite, frontal], [frontal]]).
```

La restricción prohíbe el par cuando falta el contexto: delante, cada clase
de la izquierda, de la más cercana a la más lejana; detrás, las
alternativas de la derecha, recorridas juntas mientras empiezan con la
misma clase, como en un árbol de letras. La coerción prohíbe, dentro del
contexto, los otros pares con la misma letra subyacente, que `par/1`
enumera:

<!-- ejemplo: capitulo-54/kimmo.pl predicado: compilar/5 restriccion/4 a_la_derecha/3 coercion/4 -->
```prolog
%!  compilar(+Par, +Op, +Izquierda:list, +Derechas:list, -Patrones:list)
%!      is semidet.
%
%   Patrones son los patrones prohibidos de la regla Par Op Izquierda _
%   Derechas. '=>' prohíbe el Par fuera del contexto; '<=' prohíbe, en el
%   contexto, otro par con la misma letra subyacente; '<=>' junta los dos.
compilar(Par, Op, Izquierda, Derechas, Patrones) :-
    (   Op == '=>'
    ->  restriccion(Par, Izquierda, Derechas, Patrones)
    ;   Op == '<='
    ->  coercion(Par, Izquierda, Derechas, Patrones)
    ;   Op == '<=>'
    ->  restriccion(Par, Izquierda, Derechas, Ps1),
        coercion(Par, Izquierda, Derechas, Ps2),
        append(Ps1, Ps2, Patrones)
    ).

%!  restriccion(+Par, +Izquierda:list, +Derechas:list, -Patrones:list)
%!      is det.
%
%   Patrones prohíben el Par cuando no lo precede Izquierda o cuando no lo
%   sigue ninguna de las Derechas.
restriccion(Par, Izquierda, Derechas, Patrones) :-
    reverse(Izquierda, Inversa),
    a_la_izquierda(Inversa, [par(Par)], Ps1),
    (   Derechas == []
    ->  Ps2 = []
    ;   a_la_derecha(Derechas, [par(Par)], Ps2)
    ),
    append(Ps1, Ps2, Patrones).

%!  a_la_derecha(+Derechas:list, +Visto:list, -Patrones:list) is det.
%
%   Patrones prohíben que después de Visto no siga ninguna de las
%   Derechas. Las alternativas que empiezan con la misma clase se
%   recorren juntas, como en un árbol de letras.
a_la_derecha(Derechas, Visto, Patrones) :-
    (   memberchk([], Derechas)
    ->  Patrones = []
    ;   primeras(Derechas, Clases),
        disyuncion(Clases, O),
        append(Visto, [no(O)], P1),
        findall(Ps,
                ( member(C, Clases),
                  findall(Resto, member([C|Resto], Derechas), Restos),
                  append(Visto, [C], Visto1),
                  a_la_derecha(Restos, Visto1, Ps) ),
                Pss),
        append(Pss, Ps2),
        Patrones = [P1-medio, Visto-final|Ps2]
    ).

%!  coercion(+Par, +Izquierda:list, +Derechas:list, -Patrones:list)
%!      is det.
%
%   Patrones prohíben, en cada contexto Izquierda _ Derecha, los otros
%   pares con la misma letra subyacente que Par.
coercion(Par, Izquierda, Derechas, Patrones) :-
    Par = Subyacente:_,
    findall(par(Otro),
            ( dos_niveles:par(Otro), Otro = Subyacente:_, Otro \== Par ),
            Otros),
    (   Otros == []
    ->  Patrones = []
    ;   disyuncion(Otros, O),
        findall(P-medio,
                ( member(Derecha, Derechas),
                  append([Izquierda, [O], Derecha], P) ),
                Patrones)
    ).
```

```prolog
?- compilar(['N']:[n], '=>', [], [[limite]], Ps).
Ps = [[par(['N']:[n]), no(limite)]-medio, [par(['N']:[n])]-final].

?- compilar([z]:[c], '<=>', [], [[limite, frontal], [frontal]], Ps).
Ps = [[par([z]:[c]), no(o(limite, frontal))]-medio, [par([z]:[c])]-final, [par([z]:[c]), limite, no(frontal)]-medio, [par([z]:[c]), limite]-final, [par([z]:[z]), limite, frontal]-medio, [par([z]:[z]), frontal]-medio].
```

La segunda es la regla z de la versión 3, escrita como
`[z]:[c] <=> _ (+:0) frontal`: compila exactamente a los patrones que la
[sección 54.5](dos-niveles.md#545-version-3-dos-niveles-con-los-transductores-del-capitulo-52)
escribe con `solo_ante_frontal/2` y `no_ante_frontal/2`, y las pruebas lo
verifican. Lo que en la versión 3 había que deducir para cada regla —qué
sucesiones quedan prohibidas— ahora lo deduce el compilador a partir de la
regla tal como se enuncia.

La regla nueva, `nasal`, escribe la N del prefijo in-: m ante un límite y
una p o una b, y n en los demás casos. `nasal_n` solo admite la N escrita n
ante un límite, así que la N no aparece fuera del prefijo, y la forma
subyacente de un lema no la propone:

```prolog
?- reglas(Rs), findall(E, transducir(paralelo(Rs), [i, 'N', +, p, o, s, i, b, l, e], E), Es).
Rs = [limite, k, u, g, z, jota, epentesis, quitar_tilde, poner_tilde, nasal, nasal_n],
Es = [[i, m, p, o, s, i, b, l, e]].
```

Con las dos reglas nuevas, las pruebas generan de nuevo las 328 formas del
léxico y verifican que no cambian.

!!! example "Patrón 61 — Compilar reglas desde una notación declarativa"
    **Problema.** Un dominio tiene su propia notación para las reglas,
    como la de Koskenniemi para la ortografía, y el programa que las
    aplica necesita otra representación, como las listas de patrones
    prohibidos que la versión 4 convierte en autómatas. La traducción de
    una a otra es mecánica, pero larga y fácil de equivocar.

    **Versión ingenua.** Hacer la traducción explícita de cada regla, como
    la versión 3 escribe `regla/2` con `solo_ante_frontal/2` y
    `no_ante_frontal/2`: quien agrega una regla tiene que deducir qué
    sucesiones de pares quedan prohibidas, y la regla tal como se enuncia
    no aparece en ningún lugar del programa.

    **Patrón.** Escribir las reglas en la notación del dominio, como
    hechos (`regla_dos_niveles/5`), y un compilador que las traduce a la
    representación que el resto del programa ya consume (`compilar/5`,
    con `restriccion/4` para `=>` y `coercion/4` para `<=`). Las reglas
    compiladas se agregan como cláusulas de `regla/2`, y la versión 4 las
    aplica sin cambios. Una regla escrita en las dos formas, `z_k` y `z`,
    prueba el compilador: las pruebas verifican que da exactamente los
    mismos patrones. Cuándo se compila es una decisión aparte: `kimmo.pl`
    compila en cada llamada a `regla/2`, 4 263 veces al generar
    «imposible», que cuesta 2 535 280 inferencias; con las reglas
    compiladas al cargar, con `term_expansion/2` como en el
    [Patrón 49](../patrones.md#49-expandir-al-cargar), la misma
    generación cuesta 1 006 077. `kimmo_contado.pl` mide la primera
    forma y `kimmo_al_cargar.pl` la segunda, que carga `kimmo.pl` sin
    la cláusula de `regla/2` que compila en cada llamada: esa cláusula
    se probaría, sin éxito, también en las llamadas a las demás reglas.
    Las pruebas `kimmo_contado:compilaciones`, `kimmo_contado:costo` y
    `kimmo_al_cargar:costo` verifican las compilaciones con su valor
    exacto y las inferencias dentro de un 10 %. Aquel patrón describe el
    momento de la traducción; este, la separación entre la notación en
    que se escriben las reglas y la forma en que se ejecutan.

    **Cuándo no usarlo.** Cuando las reglas son pocas y su forma
    ejecutable se lee tan bien como la notación: el compilador es un
    programa más, con sus propias pruebas. Cuando solo una parte de las
    reglas pasa a la notación, como en `kimmo.pl`, donde las nueve reglas
    de la versión 3 siguen escritas como patrones: el programa tiene
    entonces dos formas de escribir una regla. Y la compilación al cargar
    no sirve cuando las reglas se agregan durante la ejecución: una regla
    agregada después no se compila.

## 54.8 Versión 6: la derivación y los prefijos

La flexión produce las formas de una palabra; la **derivación** produce
palabras nuevas: «elección» de «elegir», «rápidamente» de «rápido»,
«casita» de «casa», «deshacer» de «hacer». Covington observa que en la
derivación lo regular es la excepción: «rotate» y «rotation», «create» y
«creation» siguen el mismo patrón, pero solo el léxico dice qué significa
cada nombre, y solo conviene escribir como reglas los procesos regulares.
`derivacion.pl` hace las dos cosas.

**Lo que se lista.** Los nombres en -ción y los verbos con des- y re- son
entradas del léxico. Un verbo con prefijo hereda de su base la clase y las
formas irregulares, y la versión 4 lo flexiona sin cambios: «deshacer» da
«deshago» y «deshizo», y «recontar» diptonga como «contar». `clause/2`
toma solo los hechos del léxico, así que un verbo con prefijo no recibe
otro prefijo:

<!-- ejemplo: capitulo-54/derivacion.pl fragmento: prefijo_verbal("des", "hacer"). .. string_concat(Prefijo, Preterito0, Preterito). -->
```prolog
prefijo_verbal("des", "hacer").
prefijo_verbal("des", "proteger").
prefijo_verbal("re", "contar").
prefijo_verbal("re", "elegir").

% Un verbo con prefijo hereda la clase, las formas irregulares y el
% pretérito de raíz propia de su base. clause/2 toma solo los hechos del
% léxico, así que un verbo con prefijo no recibe otro prefijo.
lexico:verbo(Verbo, Clase) :-
    prefijo_verbal(Prefijo, Base),
    clause(lexico:verbo(Base, Clase), true),
    string_concat(Prefijo, Base, Verbo).
lexico:irregular(Verbo, Tiempo, Persona, Numero, Forma) :-
    prefijo_verbal(Prefijo, Base),
    clause(lexico:irregular(Base, Tiempo, Persona, Numero, Forma0), true),
    string_concat(Prefijo, Base, Verbo),
    string_concat(Prefijo, Forma0, Forma).
lexico:preterito_fuerte(Verbo, Preterito) :-
    prefijo_verbal(Prefijo, Base),
    clause(lexico:preterito_fuerte(Base, Preterito0), true),
    string_concat(Prefijo, Base, Verbo),
    string_concat(Prefijo, Preterito0, Preterito).
```

```prolog
?- findall(P, forma(P, verbo("deshacer", preterito, 3, singular)), Ps).
Ps = ["deshizo"].

?- findall(A, forma("recuento", A), As).
As = [verbo("recontar", presente, 1, singular)].
```

**Lo que se escribe como regla.** El adverbio en -mente agrega el sufijo al
femenino del adjetivo, que conserva su tilde: «fácilmente», «rápidamente».
Es un compuesto más que un sufijo, y ninguna regla de dos niveles actúa en
la unión. La regla sobregenera, como las que Covington discute en su
sección sobre el control de la sobregeneración: el léxico no sabe qué
adverbios se usan, y `derivada/2` acepta «jovenmente». El diminutivo es el
caso opuesto. El sufijo depende de la forma del nombre, y las reglas
ortográficas resuelven el resto:

<!-- ejemplo: capitulo-54/derivacion.pl predicado: sufijo/5 -->
```prolog
%!  sufijo(+S:list, +Ultima, +V, -Raiz:list, -Sufijo:list) is det.
%
%   Raiz y Sufijo forman el diminutivo de la forma subyacente S, sin
%   tildes, cuya última letra escrita es Ultima; V es la vocal del género.
sufijo(S, Ultima, V, Raiz, Sufijo) :-
    last(S, L),
    include(reglas:vocal, S, Vocales),
    length(Vocales, Silabas),
    (   reglas:vocal(Ultima),
        \+ reglas:tilde(_, Ultima)
    ->  once(append(Raiz, [L], S)),
        Sufijo = [i, t, V]
    ;   reglas:vocal(Ultima)
    ->  Raiz = S,
        Sufijo = [z, i, t, V]
    ;   Silabas =:= 1
    ->  Raiz = S,
        Sufijo = [e, z, i, t, V]
    ;   memberchk(L, [n, r])
    ->  Raiz = S,
        Sufijo = [z, i, t, V]
    ;   Raiz = S,
        Sufijo = [i, t, V]
    ).
```

«Luz» es una sílaba terminada en consonante: luz+ecita, y la regla z
escribe c ante e: «lucecita». «Saco» pierde la vocal final: sak+ito, y la
regla k escribe qu ante i: «saquito». La raíz pierde la tilde, porque el
acento pasa al sufijo: «arbolito», «lapicito», «camioncito». El prefijo
in- usa la regla `nasal`: su forma subyacente es i, N, un límite y la
base.

```prolog
?- findall(P, derivada(P, diminutivo(_)), Ps).
Ps = ["casita", "librito", "sofacito", "mesecito", "arbolito", "lucecita", "lapicito", "pececito", "camioncito", "cancioncita", "examencito", "imagencita", "saquito", "laguito", "eleccioncita", "proteccioncita"].

?- findall(D, derivada("lucecita", D), Ds).
Ds = [diminutivo("luz")].

?- findall(P, derivada(P, prefijo("in", _)), Ps).
Ps = ["infeliz", "imposible", "inútil"].

?- findall(D, derivada("jovenmente", D), Ds).
Ds = [adverbio("joven")].
```

`derivada/2` analiza el diminutivo por síntesis, como la versión 2 analiza
las formas: genera el diminutivo de cada nombre y lo compara. Los
adjetivos con in- entran al léxico con su forma escrita, y la versión 4 los
flexiona y analiza: «imposibles», «infelices». Lo que la derivación no
resuelve es el significado: «eleccioncita» y «proteccioncita» salen de la
misma regla que «casita», y solo el uso dice cuáles se emplean.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara sus modos; `escribir/2` declara `?` en los dos argumentos y dice cuál debe llegar ligado, y `forma/2` de las versiones 1 y 4 dice qué argumento decide el sentido |
    | C2 | las reglas son datos: listas de patrones de clases de pares, con un functor por clase; agregar una regla es agregar una cláusula de `regla/2`, y ningún otro predicado cambia |
    | C3 | `escribir/2` evalúa cada condición después de la llamada recursiva y por eso funciona en los dos sentidos; los si-entonces-sino de `tildes/2` y `lexica/2` actúan sobre argumentos que llegan instanciados |
    | C5 | las formas irregulares se listan y bloquean la regular; lo regular no se lista |
    | C7 | 119 pruebas en diez archivos, y 36 en los de las soluciones; la versión 4 se compara con la 2 en las 328 formas del léxico y en sus análisis, y los defectos de la versión 1 están probados |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que agregan palabras o reglas lo hacen desde un
archivo propio, con cláusulas como `lexico:verbo("empezar", e_ie).`: el léxico
declara `multifile` sus predicados, la versión 2 su tabla `diptongo/3` y la
versión 3 `regla/2` y `par/1`.

13. ★ **(1)** Con `derivacion.pl` cargado, predecir qué responden
    `findall(D, derivada("lapicito", D), Ds)`,
    `findall(A, forma("desprotejo", A), As)` y
    `findall(P, derivada(P, adverbio("inglés")), Ps)`, comprobarlo, y
    nombrar la regla o la entrada del léxico que explica cada letra que
    cambia respecto de la base.
14. **(2)** Escribir la regla `jota` de la versión 3 en la notación de dos
    niveles, como dos reglas: una para la `'J'` escrita g y otra para la j
    escrita j. Comprobar con `compilar/5` que sus patrones, juntos, son
    los de `regla(jota, Ps)`. ¿Por qué la segunda solo necesita `=>`?
15. **(3)** El prefijo in- se escribe ir- ante r («irreal») e i- ante l
    («ilegal»). Agregar los adjetivos «real» y «legal», y dos reglas en
    notación de dos niveles, sin cambiar las otras. ¿Qué par hace falta
    para «ilegal», que no tiene ninguna letra en lugar de la N?

## Resumen

| | |
|---|---|
| **morfología, flexión** | la estructura de las palabras; la flexión produce las formas de una misma palabra según sus rasgos |
| **lema** | la forma que representa a todas las de una palabra: el singular, el masculino, el infinitivo |
| **forma subyacente** | la palabra con una letra por sonido y los límites entre raíz y terminación marcados con `+` |
| **regla ortográfica** | la relación entre la forma subyacente y la escrita en un contexto: `k` se escribe qu ante e, i |
| **epéntesis** | una letra que aparece al unir las partes: la e de «luces» |
| **bloqueo** | una forma listada en el léxico impide que se calcule la regular |
| **morfología de dos niveles** | las reglas relacionan directamente la forma subyacente con la escrita, par por par, y se aplican a la vez |
| **patrón prohibido** | una sucesión de clases de pares que ninguna palabra puede contener; una regla es una lista de ellos |
| **sobregeneración** | las formas subyacentes que las reglas admiten sin que el léxico las tenga |
| **árbol de letras** | el léxico como autómata cuyos estados son los prefijos de sus formas |
| **[Patrón 61](../patrones.md#61-compilar-reglas-desde-una-notacion-declarativa)** | compilar reglas desde una notación declarativa |
| `forma/2` | la relación entre una palabra y su análisis, en las cuatro versiones |
| `partes/3` | la raíz y la terminación de un análisis, en la versión 1 |
| `escribir/2`, `subyacente/2` | la ortografía en los dos sentidos, y la forma subyacente de un lema |
| `lexica/2`, `superficie/2` | la forma subyacente de un análisis, y las cuatro pasadas que la escriben |
| `raiz_verbal/7` | el cambio de la vocal de la raíz cuando recibe el acento |
| `regla/2`, `contiene(R)` | las reglas como patrones, y el autómata que los encuentra |
| `ortografia(Rs)`, `paralelo(Rs)` | las reglas en paralelo: como intersección de sus autómatas, y sin construir el producto |
| `compuesta(lexico, …)`, `inversa/1`, `identidad/1` | el léxico compuesto con las reglas, el analizador como inverso, y la forma subyacente de un lema |
| **derivación** | la formación de palabras nuevas: sufijos como -ción, -mente, -ito, y prefijos como des-, re-, in- |
| **restricción de contexto, coerción** | `=>`: el par solo aparece en el contexto; `<=`: en el contexto, la letra subyacente solo se escribe así |
| `regla_dos_niveles/5`, `compilar/5` | una regla en la notación de Koskenniemi, y su traducción a patrones prohibidos |
| `derivada/2` | la relación entre una palabra derivada y su base |
| `:- table P as subsumptive` | tabulación por subsunción: una consulta más particular usa la tabla completa de una más general |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Las formas de los nombres y los verbos de una pregunta, reducidas a su lema con `forma/2` | [capítulo 88](../capitulo-88-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- Michael A. Covington, *Natural Language Processing for Prolog Programmers*,
  Prentice-Hall, 1994; edición digital del autor, 2013,
  <https://www.covingtoninnovations.com/books/NLPPP.pdf>. Capítulo «Morphology
  and the Lexicon»: de «The Nature of Morphology», que la derivación es en gran
  parte irregular y se lista; de «Controlling Overgeneration», la
  sobregeneración de una regla productiva, como -mente; y de «Rules and
  Transducers», la notación `e:0 => C:C _ +:0 V:V`.
- Kimmo Koskenniemi, *Two-Level Morphology: A General Computational Model for
  Word-Form Recognition and Production*, Publicación 11 del Departamento de
  Lingüística General, Universidad de Helsinki, 1983; y su resumen en «A General
  Computational Model for Word-Form Recognition and Production», *COLING 1984*
  ([ACL Anthology P84-1038](https://aclanthology.org/P84-1038/)). Covington toma
  de allí la morfología de dos niveles; el capítulo, a través de él, la notación
  de las reglas, un par, un operador y un contexto, de la versión 5.
- Lauri Karttunen, «KIMMO: A General Morphological Processor», *Texas Linguistic
  Forum* 22, 1983, pp. 165–186. Es la implementación de la morfología de dos
  niveles que Covington describe; el capítulo compara con ella la compilación de
  las reglas escritas en notación de dos niveles, que la versión 5 hace a
  patrones prohibidos.

El código del capítulo es propio del curso: el léxico, las reglas del
castellano, la escritura de las reglas como patrones prohibidos, su
compilación desde la notación de dos niveles y las seis versiones se
escribieron para él; de la fuente se toman las ideas,
no los programas.
