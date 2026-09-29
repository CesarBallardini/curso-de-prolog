# Capítulo 54 — Proyecto: traducción castellano–inglés

Traducir una oración no es reemplazar cada palabra por la de otra lengua. «El
gato negro come una manzana» tiene el adjetivo después del nombre; «the black
cat eats an apple», antes. «Come manzanas» no dice quién come, y el inglés
necesita un sujeto. «The» sirve para «el», «la», «los» y «las», y el
castellano exige elegir según el nombre. Un traductor tiene que conocer la
estructura de las dos oraciones, no solo sus palabras.

El capítulo construye un traductor entre el castellano y el inglés para un
vocabulario pequeño, en los dos sentidos. Sigue el esquema clásico de la
traducción automática por **transferencia**: el **análisis** convierte la
oración de origen en un árbol, la **transferencia** convierte ese árbol en
el árbol de una oración de la otra lengua, y la **generación** convierte el
segundo árbol en palabras. Las dos gramáticas son gramáticas DCG del
[capítulo 21](../capitulo-21-gramaticas-dcg/index.md), y cada una sirve para analizar y para generar; la transferencia es
una relación entre dos términos que se usa también en los dos sentidos. El
capítulo empieza con el traductor terminado y lo construye después en
cinco versiones: la traducción palabra por palabra y sus fallas; las dos
gramáticas; la transferencia; la generación, con el lugar donde una
gramática deja de funcionar al revés; y el traductor completo, que elige el
sentido de la traducción examinando sus argumentos, como enseña el
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md).

El proyecto parte de *Natural Language Processing for Prolog Programmers*,
de Michael A. Covington, que el autor publica en
<https://www.covingtoninnovations.com/books/NLPPP.pdf>. Su apartado 8.2,
«Language Translation», toma de la historia de la traducción automática las
tres etapas —análisis, transferencia y generación— y la distinción entre
transferir de una lengua a la otra y pasar por una **interlingua**, una
representación común a todas; propone aprovechar que una gramática escrita
en Prolog puede ser **reversible**, y traduce un puñado de oraciones del
inglés al latín analizando con una gramática y generando con la otra. De
allí toma el capítulo esas ideas, la pregunta sobre qué hace que un programa
deje de ser reversible y la lista de dificultades del final del apartado,
entre ellas el sujeto omitido del castellano. Covington usa fórmulas
lógicas como interlingua; este capítulo usa transferencia entre árboles, y
el [ejercicio 11](#ejercicios) construye la variante con interlingua. Las
gramáticas, el vocabulario y el código son propios. La forma de las
respuestas del [capítulo 44](../capitulo-44-proyecto-aventura-de-texto/index.md) —el artículo que concuerda en género con el
nombre, en su página [Órdenes y respuestas en castellano](../capitulo-44-proyecto-aventura-de-texto/lenguaje.md#ordenes-y-respuestas-en-castellano)— reaparece aquí
en una gramática que además analiza.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- explicar por qué la traducción palabra por palabra falla, con ejemplos de
  orden, concordancia y sujeto omitido;
- escribir una gramática que relaciona una oración con su árbol, con
  concordancia de género y número, y que sirve para analizar y para
  generar;
- escribir la transferencia entre los árboles de dos lenguas como una
  relación que funciona en los dos sentidos;
- reconocer dónde una gramática o una relación deja de funcionar en sentido
  inverso —una condición que examina lo que todavía no existe, una
  recursión sin límite— y corregirlo;
- enumerar las traducciones de una oración ambigua y explicar de dónde sale
  cada una;
- elegir el orden de las etapas según el argumento instanciado.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:35 h**.
    Resolver los 5 ejercicios marcados con ★: **1:25 h**.
    Resolver los 12 ejercicios del final: **3:20 h**.

## 54.1 El traductor terminado

`traductor.pl` carga las gramáticas y la transferencia. `traducir/2`
relaciona un texto castellano con su traducción inglesa; cualquiera de los
dos puede ser el dato:

<!-- ejemplo: capitulo-54/traductor.pl predicado: traducir/2 -->
```prolog
%!  traducir(+Es:string, ?En:string) is nondet.
%!  traducir(-Es:string, +En:string) is nondet.
%
%   En es una traducción al inglés del texto castellano Es. Cada texto es
%   una oración, con o sin mayúscula inicial y punto final; la traducción
%   lleva los dos.
traducir(Es, En) :-
    (   nonvar(Es)
    ->  palabras(Es, PalabrasEs),
        es_en(PalabrasEs, PalabrasEn),
        texto(PalabrasEn, En)
    ;   palabras(En, PalabrasEn),
        en_es(PalabrasEn, PalabrasEs),
        texto(PalabrasEs, Es)
    ).
```

```prolog
?- traducir("El gato negro come una manzana.", En).
En = "The black cat eats an apple." ;
false.

?- traducir(Es, "The big black dog sees an old house.").
Es = "El perro negro grande ve una casa vieja." ;
false.
```

La primera traducción cambia el orden del adjetivo y elige «an» porque
«apple» empieza con vocal; la segunda invierte el orden de los dos
adjetivos, da a «house» el artículo femenino y concuerda «vieja» con
«casa». Cuando la oración admite más de una traducción, `traducciones/2`
las reúne; el texto puede estar en cualquiera de las dos lenguas:

```prolog
?- traducciones("Come manzanas.", Ts).
Ts = ["He eats apples.", "She eats apples.", "It eats apples."].

?- traducciones("Los gatos negros comen manzanas.", Ts).
Ts = ["The black cats eat apples.", "Black cats eat apples."].

?- traducciones("They read books.", Ts).
Ts = ["Leen libros.", "Ellos leen libros.", "Ellas leen libros."].
```

El camino de una oración por el traductor es este:

| Etapa | Predicado | De | A | Sección |
|---|---|---|---|---|
| palabras | `palabras/2` | texto | lista de palabras | 54.7 |
| análisis | `oracion_es//1`, `oracion_en//1` | palabras | árbol de la lengua de origen | 54.3 |
| transferencia | `transferir/2` | árbol de una lengua | árbol de la otra | 54.4 |
| generación | `oracion_en//1`, `oracion_es//1` | árbol | palabras | 54.5 |
| texto | `texto/2` | lista de palabras | texto | 54.7 |

El vocabulario es pequeño a propósito: cinco nombres, cinco adjetivos
castellanos, seis verbos y los pronombres de tercera persona. Alcanza para
mostrar los problemas de la traducción y los ejercicios lo amplían.

## 54.2 Versión 1: palabra por palabra

La traducción más simple es un diccionario de formas y un recorrido que
reemplaza cada palabra por su equivalente. Las palabras son strings, no
átomos: así «él», con tilde, es una palabra distinta de «el», y ningún
átomo del programa lleva tilde:

<!-- ejemplo: capitulo-54/palabra.pl fragmento: equivalente("el", "the"). .. equivalente("una", "an"). -->
```prolog
equivalente("el", "the").
equivalente("la", "the").
equivalente("los", "the").
equivalente("las", "the").
equivalente("un", "a").
equivalente("una", "a").
equivalente("una", "an").
```

<!-- ejemplo: capitulo-54/palabra.pl predicado: palabra_por_palabra/2 -->
```prolog
%!  palabra_por_palabra(?Es:list(string), ?En:list(string)) is nondet.
%
%   En es la lista de los equivalentes de las palabras de Es, en el mismo
%   orden. Una de las dos listas debe tener largo conocido.
palabra_por_palabra(Es, En) :-
    maplist(equivalente, Es, En).
```

```prolog
?- palabra_por_palabra(["el", "gato", "negro", "come", "una", "manzana"], En).
En = ["the", "cat", "black", "eats", "a", "apple"] ;
En = ["the", "cat", "black", "eats", "an", "apple"].

?- palabra_por_palabra(["come", "manzanas"], En).
En = ["eats", "apples"].
```

Las dos respuestas fallan de maneras distintas. La primera deja el
adjetivo después del nombre y no puede elegir entre «a» y «an» para «una»: la elección
depende de la palabra siguiente, que el diccionario no ve. La segunda no
tiene sujeto: el castellano lo omite y el verbo lo indica, pero en inglés
es obligatorio. En sentido inverso el problema es la cantidad:

!!! question "Actividad"
    Predecir cuántas traducciones castellanas da `palabra_por_palabra/2`
    para `["the", "black", "cats"]` y cuántas de ellas son correctas.
    Comprobarlo con `aggregate_all(count, palabra_por_palabra(Es, ["the",
    "black", "cats"]), N)` y con la consulta inversa.

«The» tiene cuatro equivalentes y «black» otros cuatro, y cada combinación
es una respuesta: 16, todas con el adjetivo antes del nombre y, salvo una,
sin concordancia. Ninguna es «los gatos negros». Lo que falta es la
estructura: qué palabra es el núcleo del sintagma, cuáles concuerdan con
cuál, y en qué orden van en cada lengua.

## 54.3 Versión 2: dos gramáticas

Cada lengua tiene su gramática, en su archivo, y cada gramática relaciona
una oración con un árbol que conserva el orden de esa lengua. Los árboles
siguen la representación limpia de la [sección 32.6](../capitulo-32-inspeccion-de-terminos/index.md#326-representaciones-limpias): un functor por
clase de nodo, y los rasgos que la traducción necesita como argumentos:

| Nodo | Castellano | Inglés |
|---|---|---|
| oración intransitiva | `o(Sujeto, Verbo)` | `o(Sujeto, Verbo)` |
| oración transitiva | `o(Sujeto, Verbo, Objeto)` | `o(Sujeto, Verbo, Objeto)` |
| sintagma nominal | `sn(Art, Nombre, Num, Adjs)` | `sn(Art, Adjs, Nombre, Num)` |
| pronombre | `pron(Genero, Num)`: él, ella, ellos, ellas | `pron(P)`: he, she, it, they |
| sujeto omitido | `tacito(Num)` | — |

`Art` es `el`, `un` o `sin` en castellano, y `the`, `a` o `sin` en inglés;
`Num` es `sg` o `pl`; los nombres, adjetivos y verbos aparecen por su lema
(`gato`, `negro`, `comer`), no por su forma. El género de un nombre no está
en el árbol: es un dato del léxico, y la gramática lo usa para la
concordancia. La gramática castellana empieza así:

<!-- ejemplo: capitulo-54/castellano.pl predicado: oracion_es//1 sujeto_es//2 sn_es//2 -->
```prolog
%!  oracion_es(?Arbol)// is nondet.
%
%   Una oración castellana con su árbol Arbol. El verbo concuerda en número
%   con el sujeto.
oracion_es(o(S, V)) -->
    sujeto_es(S, N),
    verbo_es(V, intransitivo, N).
oracion_es(o(S, V, O)) -->
    sujeto_es(S, N),
    verbo_es(V, transitivo, N),
    sn_es(O, _).

%!  sujeto_es(?S, ?N)// is nondet.
%
%   El sujeto S, de número N: omitido, un pronombre o un sintagma nominal
%   con artículo; «gatos comen» no es una oración.
sujeto_es(tacito(N), N) -->
    [].
sujeto_es(pron(G, N), N) -->
    [F],
    { pronombre_es(G, N, F) }.
sujeto_es(sn(A, L, N, As), N) -->
    sn_es(sn(A, L, N, As), N),
    { A \== sin }.

%!  sn_es(?SN, ?N)// is nondet.
%
%   Un sintagma nominal de número N: el artículo, el nombre y los
%   adjetivos, que concuerdan en género y número. Sin artículo, solo en
%   plural: «manzanas».
sn_es(sn(A, L, N, As), N) -->
    articulo_es(A, G, N),
    nombre_es(L, G, N),
    adjetivos_es(As, G, N).
```

`sn_es//2` hace la concordancia pasando el género `G` y el número `N` del
artículo al nombre y a los adjetivos: los tres comparten las variables, y
la unificación rechaza «la gato» o «el gato negra». El sujeto sin artículo
se rechaza en `sujeto_es//2`: «gatos comen manzanas» no es una oración,
aunque «manzanas» sea un objeto correcto. Las formas salen del léxico con
reglas pequeñas:

<!-- ejemplo: capitulo-54/castellano.pl predicado: nombre_es//3 adjetivo_es//3 numero_es/3 -->
```prolog
%!  nombre_es(?L, ?G, ?N)// is nondet.
%
%   La forma del nombre L, de género G, en número N.
nombre_es(L, G, N) -->
    [F],
    { nombre_es(L, G),
      atom_string(L, Singular),
      numero_es(N, Singular, F) }.

%!  adjetivo_es(?L, ?G, ?N)// is nondet.
%
%   La forma del adjetivo L en género G y número N.
adjetivo_es(L, G, N) -->
    [F],
    { adjetivo_es(L, C),
      singular_adjetivo(C, L, G, Singular),
      numero_es(N, Singular, F) }.

%!  numero_es(?N, +Singular:string, ?Forma:string) is semidet.
%
%   Forma es Singular en número N. El plural agrega s después de vocal y
%   es después de consonante: «gatos», «mujeres».
numero_es(sg, Singular, Singular).
numero_es(pl, Singular, Plural) :-
    sub_string(Singular, _, 1, 0, Ultima),
    (   sub_string("aeiou", _, 1, _, Ultima)
    ->  string_concat(Singular, "s", Plural)
    ;   string_concat(Singular, "es", Plural)
    ).
```

```prolog
?- phrase(oracion_es(A), ["el", "gato", "negro", "come", "una", "manzana"]).
A = o(sn(el, gato, sg, [negro]), comer, sn(un, manzana, sg, [])) ;
false.

?- phrase(oracion_es(A), ["come", "manzanas"]).
A = o(tacito(sg), comer, sn(sin, manzana, pl, [])) ;
false.

?- phrase(oracion_es(A), ["la", "gato", "duerme"]).
false.

?- phrase(oracion_es(A), ["gatos", "comen", "manzanas"]).
false.
```

La gramática inglesa, en `ingles.pl`, tiene la misma forma. Sus nombres y
verbos guardan las dos formas en el léxico, porque «has» y «women» no
siguen una regla; los adjetivos no concuerdan, y el sintagma pone los
adjetivos antes del nombre:

<!-- ejemplo: capitulo-54/ingles.pl predicado: oracion_en//1 -->
```prolog
%!  oracion_en(?Arbol)// is nondet.
%
%   Una oración inglesa con su árbol Arbol. El verbo concuerda en número
%   con el sujeto.
oracion_en(o(S, V)) -->
    sujeto_en(S, N),
    verbo_en(V, intransitivo, N).
oracion_en(o(S, V, O)) -->
    sujeto_en(S, N),
    verbo_en(V, transitivo, N),
    sn_en(O, _).
```

```prolog
?- phrase(oracion_en(A), ["the", "big", "black", "cat", "eats", "an", "apple"]).
A = o(sn(the, [big, black], cat, sg), eat, sn(a, [], apple, sg)) ;
false.
```

## 54.4 Versión 3: la transferencia

Con los dos árboles definidos, traducir es relacionarlos. `transferir/2` no
ve palabras: cambia cada lema por su equivalente, conserva el número, e
invierte el orden de los adjetivos, porque en «un gato negro grande» el
adjetivo más cercano al nombre es el último y en «a big black cat» es el
primero. El sujeto tácito pasa a un pronombre inglés, que en singular puede
ser cualquiera de tres:

<!-- ejemplo: capitulo-54/transferencia.pl predicado: transferir/2 sujeto/2 sn/2 adjetivos/2 -->
```prolog
%!  transferir(?Es, ?En) is nondet.
%
%   En es un árbol de oración inglesa que traduce el árbol castellano Es.
%   Uno de los dos debe llegar instanciado.
transferir(o(S1, V1), o(S2, V2)) :-
    sujeto(S1, S2),
    verbo(V1, V2).
transferir(o(S1, V1, O1), o(S2, V2, O2)) :-
    sujeto(S1, S2),
    verbo(V1, V2),
    sn(O1, O2).

%!  sujeto(?Es, ?En) is nondet.
%
%   El sujeto inglés En traduce el sujeto castellano Es. El sujeto tácito
%   pasa a un pronombre: en singular, he, she o it. El plural con artículo
%   definido tiene además la lectura genérica, sin artículo en inglés:
%   «los gatos comen» es «the cats eat» o «cats eat».
sujeto(tacito(sg), pron(he)).
sujeto(tacito(sg), pron(she)).
sujeto(tacito(sg), pron(it)).
sujeto(tacito(pl), pron(they)).
sujeto(pron(m, sg), pron(he)).
sujeto(pron(f, sg), pron(she)).
sujeto(pron(m, pl), pron(they)).
sujeto(pron(f, pl), pron(they)).
sujeto(sn(A1, L1, N, As1), sn(A2, As2, L2, N)) :-
    sn(sn(A1, L1, N, As1), sn(A2, As2, L2, N)).
sujeto(sn(el, L1, pl, As1), sn(sin, As2, L2, pl)) :-
    nombre(L1, L2),
    adjetivos(As1, As2).

%!  sn(?Es, ?En) is nondet.
%
%   El sintagma nominal inglés En traduce el castellano Es: mismo número,
%   artículo, nombre y adjetivos equivalentes, los adjetivos en orden
%   inverso.
sn(sn(A1, L1, N, As1), sn(A2, As2, L2, N)) :-
    articulo(A1, A2),
    nombre(L1, L2),
    adjetivos(As1, As2).

%!  adjetivos(?Es:list, ?En:list) is nondet.
%
%   En son los equivalentes de los adjetivos Es, en orden inverso: «un
%   gato negro grande» es «a big black cat». Una de las dos listas debe
%   tener largo conocido; same_length/2 fija el de la otra antes de
%   invertir.
adjetivos(As1, As2) :-
    same_length(As1, As2),
    reverse(As1, Invertidos),
    maplist(adjetivo, Invertidos, As2).
```

El léxico bilingüe son hechos como `nombre(gato, cat)` y
`adjetivo(grande, big)`; «grande» tiene dos equivalentes, `big` y `large`.
La última cláusula de `sujeto/2` agrega la lectura genérica del plural: «los
gatos comen manzanas» puede hablar de ciertos gatos, «the cats», o de los
gatos en general, «cats», sin artículo en inglés. Como la relación no usa
nada que dependa del sentido, sirve con cualquiera de los dos árboles
instanciado:

```prolog
?- transferir(o(sn(el, gato, sg, [negro, grande]), dormir), En).
En = o(sn(the, [big, black], cat, sg), sleep) ;
En = o(sn(the, [large, black], cat, sg), sleep) ;
false.

?- transferir(Es, o(pron(she), eat, sn(sin, [red], apple, pl))).
Es = o(tacito(sg), comer, sn(sin, manzana, pl, [rojo])) ;
Es = o(pron(f, sg), comer, sn(sin, manzana, pl, [rojo])).
```

`adjetivos/2` llama a `same_length/2` antes de `reverse/2`, y no es un
detalle. `reverse/2` con el primer argumento libre da la inversa y, pedida
otra respuesta, prueba listas cada vez más largas sin terminar nunca.
`adjetivos_ingenuo/2` es la versión sin `same_length/2`; con un límite de
inferencias, `call_with_inference_limit/3` muestra que la búsqueda de
todas sus respuestas no termina:

```prolog
?- call_with_inference_limit(findall(Es, adjetivos_ingenuo(Es, [big, black]), L), 100000, R).
R = inference_limit_exceeded.

?- adjetivos(Es, [big, black]).
Es = [negro, grande].
```

`same_length/2` fija el largo de la lista libre con el de la instanciada, y
desde allí `reverse/2` tiene una sola respuesta. Una relación que se va a
usar en los dos sentidos se prueba en los dos: con el sentido castellano
este defecto no aparece, porque la lista de adjetivos llega instanciada.

!!! question "Actividad"
    Predecir el árbol inglés que da `transferir/2` para el árbol castellano
    de «unas casas viejas grandes tienen libros rojos», y cuántas respuestas
    hay. Obtener primero ese árbol con `phrase(oracion_es(A), …)` y
    comprobar la predicción.

## 54.5 Versión 4: la generación

Generar es usar la gramática con el árbol instanciado y la lista de
palabras libre. Las gramáticas de la [sección 54.3](#543-version-2-dos-gramaticas) lo permiten sin
cambios. El no terminal del verbo, por ejemplo, busca el lema en el léxico y
elige la forma por el número, en cualquiera de los dos sentidos:

<!-- ejemplo: capitulo-54/castellano.pl predicado: verbo_es//3 -->
```prolog
%!  verbo_es(?L, ?C, ?N)// is nondet.
%
%   La forma de tercera persona del verbo L, de clase C, en número N.
verbo_es(L, C, N) -->
    [F],
    { verbo_es(L, C, Singular, Plural),
      numero_verbo(N, Singular, Plural, F) }.
```

```prolog
?- phrase(oracion_es(o(sn(un, casa, pl, [viejo, grande]), tener, sn(sin, libro, pl, [rojo]))), Ps).
Ps = ["unas", "casas", "viejas", "grandes", "tienen", "libros", "rojos"] ;
false.
```

Funciona porque cada regla consulta el léxico antes de calcular una forma.
En `nombre_es//3`, `nombre_es(L, G)` va primero: al analizar, recorre el
léxico hasta el nombre cuya forma coincide con la palabra; al generar, el
lema llega instanciado y la regla calcula su forma. Si `atom_string/2` fuera
primero, el análisis lo llamaría con los dos argumentos libres y terminaría
en un error. El artículo, que en la oración va antes del nombre, se genera
también antes de conocer el género: `articulo_es/4` propone «un», y si el
nombre es femenino la unificación del género falla y la vuelta atrás
propone «una».

Ese mecanismo no alcanza para el artículo indefinido inglés, que es «a» o
«an» según la palabra **siguiente**. La forma natural de escribirlo en un
analizador es mirar esa palabra con el pushback de la [sección 21.9](../capitulo-21-gramaticas-dcg/index.md#219-pushback),
elegir la forma y devolver la palabra a la entrada. `articulo.pl` lo hace
así:

<!-- ejemplo: capitulo-54/articulo.pl predicado: sn_ingenuo//2 articulo_ingenuo//2 -->
```prolog
%!  sn_ingenuo(?SN, ?N)// is nondet.
%
%   Como sn_en//2, con la forma del artículo elegida antes de los
%   adjetivos y el nombre. Solo analiza: para generar, SN instanciado
%   produce un error de instanciación.
sn_ingenuo(sn(A, As, L, N), N) -->
    articulo_ingenuo(A, N),
    adjetivos_en(As, _, Nombre),
    nombre_en(L, N, Nombre).

%!  articulo_ingenuo(?A, ?N)// is nondet.
%
%   El artículo A en número N, con la forma que corresponde a la palabra
%   siguiente, que se examina y se devuelve a la entrada.
articulo_ingenuo(sin, pl) -->
    [].
articulo_ingenuo(A, N), [P] -->
    [F, P],
    { articulo_en(A, N, F),
      antes_de(F, P) }.
```

```prolog
?- phrase(sn_ingenuo(SN, N), ["an", "old", "book"]).
SN = sn(a, [old], book, sg),
N = sg ;
false.

?- phrase(sn_ingenuo(sn(a, [], apple, sg), sg), Ps).
ERROR: Arguments are not sufficiently instantiated
ERROR: In:
ERROR:   [19] sub_string(_194,0,1,_200,_202)
```

Al analizar, la palabra siguiente está en la entrada. Al generar, la
entrada es la lista libre que la gramática está construyendo: cuando
`articulo_ingenuo//2` pide la palabra siguiente, esa palabra es una
variable, y `antes_de/2` la examina con `sub_string/5`. El defecto es de
orden: la condición se evalúa antes de que exista lo que examina. La
corrección, en `sn_en//2` de `ingles.pl`, pone en la lista una forma
propuesta del artículo, genera los adjetivos y el nombre, y recién al
final comprueba la condición, cuando la palabra siguiente ya se conoce en
los dos sentidos:

<!-- ejemplo: capitulo-54/ingles.pl predicado: sn_en//2 antes_de/2 adjetivos_en//3 -->
```prolog
%!  sn_en(?SN, ?N)// is nondet.
%
%   Un sintagma nominal de número N: el artículo, los adjetivos y el
%   nombre. Sin artículo, solo en plural: «apples». Siguiente es la
%   primera palabra después del artículo, y la forma del artículo se
%   comprueba contra ella al final.
sn_en(sn(A, As, L, N), N) -->
    articulo_en(A, N, F),
    adjetivos_en(As, Siguiente, Nombre),
    nombre_en(L, N, Nombre),
    { antes_de(F, Siguiente) }.

%!  antes_de(+Articulo, +Palabra:string) is semidet.
%
%   La forma Articulo puede ir antes de Palabra: «an» antes de una vocal,
%   «a» antes de una consonante, las demás antes de cualquier palabra.
antes_de("an", P) :-
    !,
    empieza_con_vocal(P).
antes_de("a", P) :-
    !,
    \+ empieza_con_vocal(P).
antes_de(_, _).

%!  adjetivos_en(?As:list, ?Primera:string, ?Nombre:string)// is nondet.
%
%   Los adjetivos As. Primera es la primera palabra que escriben, o
%   Nombre, la forma del nombre que los sigue, si As es vacía.
adjetivos_en([], Nombre, Nombre) -->
    [].
adjetivos_en([A|As], F, Nombre) -->
    [F],
    { adjetivo_en(A, F) },
    adjetivos_en(As, _, Nombre).
```

`adjetivos_en//3` devuelve la primera palabra que escribe, o la del nombre
si no hay adjetivos, y esa es la que `antes_de/2` examina. Que la lista de
palabras pueda contener un hueco que se completa después es la idea de las
estructuras incompletas del [capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md): una gramática DCG construye
su salida como una lista diferencia, y lo que ya se puso en ella todavía
puede terminar de ligarse.

```prolog
?- phrase(sn_en(sn(a, [old], book, sg), N), Ps).
N = sg,
Ps = ["an", "old", "book"] ;
false.
```

La regla general que deja esta sección: en una gramática reversible, una
condición entre llaves debe ir después de todo lo que examina, contando
en los dos sentidos. Los predicados que solo funcionan con un argumento
instanciado —`sub_string/5`, `atom_string/2`, la aritmética— son los
lugares donde verificarlo.

## 54.6 La ambigüedad

Una oración puede tener varias traducciones correctas, y el traductor las
da todas por vuelta atrás. Las ambigüedades del vocabulario del capítulo
vienen de cuatro fuentes:

| Fuente | Ejemplo | Traducciones |
|---|---|---|
| sujeto tácito | «Come manzanas.» | he, she o it |
| pronombre inglés sin género | «They read books.» | tácito, ellos o ellas |
| plural genérico | «Los gatos negros comen manzanas.» | the black cats o black cats |
| sinónimos | «La casa grande tiene un gato.» | big o large |

Las ambigüedades se multiplican: una oración con un sujeto tácito y un
adjetivo «grande» tiene seis traducciones. El orden de las respuestas es el
de las cláusulas, así que la primera es la preferida: `sujeto/2` pone el
sujeto tácito antes que el pronombre explícito, porque en castellano es lo
habitual. Algunas propuestas de la transferencia no llegan al resultado.
«Cats eat apples» se transfiere a un árbol con el sujeto sin artículo y a
otro con el genérico `el`; la gramática castellana rechaza el primero al
generar, y queda una traducción. `traducciones/2` reúne las traducciones
distintas, y prueba los dos sentidos: el que no corresponde a la lengua del
texto falla en el análisis.

<!-- ejemplo: capitulo-54/traductor.pl predicado: traducciones/2 -->
```prolog
%!  traducciones(+Texto:string, -Ts:list(string)) is det.
%
%   Ts son las traducciones distintas de Texto, en el orden en que salen:
%   al inglés si Texto es una oración castellana, al castellano si es una
%   oración inglesa, ninguna si no es ni una ni otra.
traducciones(Texto, Ts) :-
    findall(T, ( traducir(Texto, T) ; traducir(T, Texto) ), Ts0),
    list_to_set(Ts0, Ts).
```

```prolog
?- traducciones("Cats eat apples.", Ts).
Ts = ["Los gatos comen manzanas."].

?- traducciones("La casa grande tiene un gato.", Ts).
Ts = ["The big house has a cat.", "The large house has a cat."].
```

Así se reparte el trabajo: la transferencia propone todo lo que la
correspondencia entre las lenguas admite, y la gramática de destino
descarta lo que la lengua no dice. Covington señala, al final del apartado
8.2, que elegir entre «he» y «she» para traducir un verbo castellano
requiere conocer el contexto; el traductor de una sola oración no lo tiene,
y por eso da las tres.

!!! question "Actividad"
    Predecir las traducciones de «He sleeps.» y su orden, y las de «Ellos
    leen libros.». Explicar por qué una da dos y la otra una sola, y
    comprobarlo con `traducciones/2`.

## 54.7 Versión 5: los dos sentidos

Las tres etapas encadenadas dan un traductor en una cláusula:

<!-- ejemplo: capitulo-54/traductor.pl predicado: traducir_ingenuo/2 -->
```prolog
%!  traducir_ingenuo(+Es:list(string), ?En:list(string)) is nondet.
%
%   Como es_en/2, y pensado para los dos sentidos. Con Es libre, genera
%   oraciones castellanas una tras otra y no termina cuando la traducción
%   tiene un sujeto con artículo.
traducir_ingenuo(Es, En) :-
    phrase(oracion_es(ArbolEs), Es),
    transferir(ArbolEs, ArbolEn),
    phrase(oracion_en(ArbolEn), En).
```

Del castellano al inglés funciona. En sentido inverso, con la lista
castellana libre, la primera meta ya no analiza: **genera** oraciones
castellanas una tras otra, y la transferencia y la gramática inglesa
comprueban cada una contra la oración dada. Ese recorrido no es completo.
Las oraciones con sujeto nominal empiezan por el artículo `sin`, que
`sujeto_es//2` rechaza recién después de generar el sintagma, y los
adjetivos de ese sintagma son una lista que crece sin límite: la búsqueda
se queda allí y nunca llega a «el gato duerme».

```prolog
?- call_with_inference_limit(findall(Es, traducir_ingenuo(Es, ["the", "cat", "sleeps"]), L), 100000, R).
R = inference_limit_exceeded.
```

Covington plantea en su apartado 8.2 si su traductor inglés–latín traduce
también del latín al inglés, y si es igual de eficiente en los dos
sentidos. La respuesta, aquí, es que la lógica es la misma pero el orden de
las metas no: la etapa que recibe la oración dada tiene que analizarla. Por
eso hay un predicado por sentido, y los dos analizan primero:

<!-- ejemplo: capitulo-54/traductor.pl predicado: es_en/2 en_es/2 -->
```prolog
%!  es_en(+Es:list(string), ?En:list(string)) is nondet.
%
%   En es una traducción al inglés de la oración castellana Es.
es_en(Es, En) :-
    phrase(oracion_es(ArbolEs), Es),
    transferir(ArbolEs, ArbolEn),
    phrase(oracion_en(ArbolEn), En).

%!  en_es(+En:list(string), ?Es:list(string)) is nondet.
%
%   Es es una traducción al castellano de la oración inglesa En.
en_es(En, Es) :-
    phrase(oracion_en(ArbolEn), En),
    transferir(ArbolEs, ArbolEn),
    phrase(oracion_es(ArbolEs), Es).
```

`traducir/2` elige entre ellos con `nonvar/1`, la inspección de términos
del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md): si el texto castellano está instanciado traduce al
inglés, y si no, al castellano. Con los dos textos instanciados comprueba
que uno traduce al otro; con los dos libres, `palabras/2` termina en un
error de instanciación, que es la respuesta correcta a una consulta sin
dato. Las palabras se obtienen del texto con `split_string/4`, y el texto
de las palabras con `atomic_list_concat/3`: son dos predicados, uno por
sentido, porque pasar a minúsculas y quitar el punto no se deshace.

<!-- ejemplo: capitulo-54/traductor.pl predicado: palabras/2 texto/2 -->
```prolog
%!  palabras(+Texto:string, -Palabras:list(string)) is det.
%
%   Palabras son las palabras de Texto en minúsculas, sin los blancos ni
%   el punto final.
palabras(Texto, Palabras) :-
    string_lower(Texto, Minusculas),
    split_string(Minusculas, " ", " .", Partes),
    exclude(==(""), Partes, Palabras).

%!  texto(+Palabras:list(string), -Texto:string) is det.
%
%   Texto es la oración de Palabras separadas por un blanco, con la
%   primera letra en mayúscula y un punto al final.
texto(Palabras, Texto) :-
    atomic_list_concat(Palabras, ' ', Frase),
    sub_atom(Frase, 0, 1, _, Inicial),
    sub_atom(Frase, 1, _, 0, Resto),
    upcase_atom(Inicial, Mayuscula),
    atomic_list_concat([Mayuscula, Resto, '.'], Oracion),
    atom_string(Oracion, Texto).
```

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara sus modos; los que se usan en los dos sentidos (`oracion_es//1`, `oracion_en//1`, `transferir/2`) declaran `?` y dicen qué argumento debe llegar instanciado, y `traducir/2` declara sus dos modos por separado |
    | C2 | los árboles son representaciones limpias, un functor por clase de nodo; la transferencia elige la cláusula por la cabeza, sin examinar tipos |
    | C3 | los no terminales y la transferencia no tienen cortes ni efectos: por eso funcionan en los dos sentidos; los cortes de `antes_de/2` y `empieza_con_vocal/1`, y el si-entonces-sino de `numero_es/3`, actúan sobre argumentos que llegan instanciados en los dos sentidos |
    | C7 | 78 pruebas en siete archivos; cada gramática y la transferencia se prueban en los dos sentidos, y los dos defectos del capítulo están probados: el error de `sn_ingenuo//2` al generar y la búsqueda sin fin de `adjetivos_ingenuo/2` y `traducir_ingenuo/2`, detenida con un límite de inferencias |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir las traducciones de «Ellas corren.» y de «The white
   dogs have a red book.», cuántas son y en qué orden salen, y comprobarlo
   con `traducciones/2`.
2. **(1)** Agregar al vocabulario el nombre «mujer» (*woman*, plural
   *women*), el adjetivo «azul» (*blue*) y el verbo transitivo «mirar»
   (*watch*, tercera persona *watches*), sin cambiar ninguna regla.
   Traducir «The women watch the blue houses.» y explicar de dónde salen
   «mujeres» y «azules».
3. **(1)** Agregar el nombre «gata», femenino, como otra traducción de
   *cat*. ¿Cuántas traducciones tiene ahora «The black cat sleeps.», y por
   qué la segunda dice «negra»?
4. ★ **(2)** Agregar la negación: «el gato no come manzanas» es «the cat
   does not eat apples». Representar la oración negada como `neg(O)`,
   extender las dos gramáticas y la transferencia, y comprobar que «They
   do not sleep.» tiene tres traducciones. ¿Qué forma del verbo inglés va
   después de *not*, y dónde está en el léxico?
5. **(2)** Escribir `traducir_sensato/2`, que traduce al inglés solo las
   oraciones que respetan las **restricciones de selección**: comer, ver,
   leer, dormir y correr piden un sujeto animado. «El libro come una
   manzana.» no debe tener traducción; «La casa tiene un libro.», sí.
6. ★ **(1)** Explicar por qué `traducir_ingenuo/2` termina con la oración
   castellana instanciada y no termina con la inglesa. Predecir qué hace
   `traducir_ingenuo(Es, ["he", "sleeps"])`: ¿da una respuesta? ¿termina
   si se pide otra?
7. **(2)** Determinar los modos en que `adjetivos/2` y
   `adjetivos_ingenuo/2` terminan, y escribir sus encabezados PlDoc con
   una línea por modo útil. ¿Por qué el modo `(-, +)` no se declara para
   `adjetivos_ingenuo/2`?
8. ★ **(2)** Escribir `al_castellano_por_largo(En, Es)`, que llama a
   `length(Es, _)` antes de `traducir_ingenuo/2`. Comprobar que encuentra
   «el gato duerme» para `["the", "cat", "sleeps"]`, explicar por qué, y
   explicar por qué no termina después de la última traducción.
9. **(2)** Agregar sujetos coordinados: «el gato y el perro duermen» es
   «the cat and the dog sleep». El sujeto coordinado es plural. ¿Qué
   traducciones tiene «Cats and dogs sleep.»?
10. **(2)** Escribir `inferencias(Meta, N)`, que cuenta las inferencias de
    la primera solución de `Meta` con `statistics/2`, y comparar `es_en/2`
    con `en_es/2` para «el gato negro come una manzana» y su traducción.
    ¿Qué sentido cuesta más, y qué etapa explica la diferencia: el análisis,
    la transferencia o la generación?
11. ★ **(3)** Traducir por **interlingua**, como Covington: escribir
    `interlingua_es/2` e `interlingua_en/2`, que relacionan cada árbol con
    una representación común —un evento con la acción, el agente y el
    paciente—, y `es_en_interlingua/2`. Comprobar que da las mismas
    traducciones que `es_en/2`. ¿Cuántas relaciones hacen falta para
    traducir entre cuatro lenguas con transferencia, y cuántas con una
    interlingua?
12. **(3)** Agregar el complemento de posesión en el objeto: «ella lee el
    libro del gato» es «she reads the cat's book», y «el libro de las
    mujeres» es «the women's book». En castellano, «de el» se contrae en
    «del»; en inglés, el poseedor ocupa el lugar del artículo, y un plural
    terminado en *s* recibe solo el apóstrofo: «the dogs' house».

## Resumen

| | |
|---|---|
| **traducción por transferencia** | análisis de la oración de origen en un árbol, transferencia a un árbol de la otra lengua, generación de la oración de destino |
| **interlingua** | una representación común a todas las lenguas; la traducción es análisis a ella y generación desde ella |
| **gramática reversible** | una gramática que sirve para analizar y para generar: sin cortes ni efectos, y con cada condición después de lo que examina |
| **sujeto tácito** | el sujeto que el castellano omite; se traduce por un pronombre inglés, con tantas traducciones como pronombres posibles |
| **plural genérico** | «los gatos» en general; en inglés, el plural sin artículo |
| **restricción de selección** | la condición que un verbo impone a su sujeto o a su objeto, como ser animado |
| `palabra_por_palabra/2` | la traducción de cada forma por su equivalente |
| `oracion_es//1`, `oracion_en//1` | las gramáticas: oración y árbol |
| `transferir/2`, `sujeto/2`, `sn/2`, `adjetivos/2` | la transferencia entre los árboles |
| `sn_ingenuo//2` | el artículo elegido antes de conocer la palabra siguiente: analiza pero no genera |
| `es_en/2`, `en_es/2`, `traducir/2`, `traducciones/2` | el traductor en cada sentido y sobre textos |
| `call_with_inference_limit/3` | ejecuta una meta con un límite de inferencias; `R` dice si lo alcanzó |
| `split_string/4`, `atomic_list_concat/3` | de un texto a sus palabras, y de las palabras a un texto |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Plantillas de diálogo sobre oraciones en castellano | [capítulo 55](../capitulo-55-proyecto-dialogos-plantillas/index.md) |
| Oraciones en castellano traducidas a operaciones del sistema | [capítulo 56](../capitulo-56-proyecto-ordenes-castellano/index.md) |
| Una gramática del castellano que produce formas lógicas, una interlingua para consultar una base de datos | [capítulo 87](../capitulo-87-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- Michael A. Covington, *Natural Language Processing for Prolog
  Programmers*, Prentice-Hall, 1994; edición digital del autor, 2013,
  <https://www.covingtoninnovations.com/books/NLPPP.pdf>. Apartado 8.2,
  «Language Translation»: las tres etapas de análisis, transferencia y
  generación, la distinción entre transferencia e interlingua, la gramática
  reversible como traductor en los dos sentidos, la pregunta sobre qué hace
  que un programa deje de ser reversible, y las dificultades de la
  traducción, entre ellas el sujeto omitido del castellano; el
  [ejercicio 11](#ejercicios) toma la idea de su traductor por interlingua.
  Apartado 8.3, «Word-Sense Disambiguation»: la idea de las restricciones
  de selección del [ejercicio 5](#ejercicios).

El código del capítulo es propio del curso: las gramáticas, el vocabulario,
la transferencia y el traductor se escribieron para él; de la fuente se
toman las ideas, no los programas.
