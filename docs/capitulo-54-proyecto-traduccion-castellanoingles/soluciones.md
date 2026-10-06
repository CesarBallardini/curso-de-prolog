# Soluciones del capítulo 54 — Proyecto: traducción castellano–inglés

El código de esta página está en `ejemplos/capitulo-54/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `traductor.pl`, y con él
las dos gramáticas y la transferencia. Los ejercicios 2, 3, 4, 9 y 12
agregan cláusulas a predicados de esos archivos: para que dos archivos
definan cláusulas del mismo predicado, `soluciones.pl` los declara
`multifile`, como en el [capítulo 24](../capitulo-24-modulos-y-organizacion/index.md), **antes** de cargarlos, y las
cláusulas nuevas quedan después de las originales. Todas las consultas de
esta página se hacen con `soluciones.pl` cargado, así que las traducciones
incluyen las palabras que agregan los ejercicios.

<!-- ejemplo: capitulo-54/soluciones.pl fragmento: :- multifile .. :- ensure_loaded(traductor). -->
```prolog
:- multifile
    nombre_es/2,
    adjetivo_es/2,
    verbo_es/4,
    nombre_en/3,
    adjetivo_en/2,
    verbo_en/4,
    nombre/2,
    adjetivo/2,
    verbo/2,
    oracion_es//1,
    oracion_en//1,
    sujeto_es//2,
    sujeto_en//2,
    sn_es//2,
    sn_en//2,
    transferir/2,
    sujeto/2,
    sn/2.

:- ensure_loaded(traductor).
```

## 1

«Ellas» es un pronombre femenino plural, y en inglés el único pronombre de
tercera persona plural es *they*: una sola traducción. En sentido inverso,
«the white dogs» tiene artículo, así que no hay lectura genérica que
agregar; «a red book» es singular, y el artículo castellano toma el género
de «libro»:

```prolog
?- traducciones("Ellas corren.", Ts).
Ts = ["They run."].

?- traducciones("The white dogs have a red book.", Ts).
Ts = ["Los perros blancos tienen un libro rojo."].
```

## 2

Las palabras nuevas son hechos: el nombre y su género, el adjetivo y su
clase, el verbo con sus dos formas en cada lengua, y los tres pares del
léxico bilingüe. Ninguna regla cambia. «Mujeres» sale de la regla de
`numero_es/3` para las palabras terminadas en consonante, que agrega *es*;
«azul» es invariable, así que su singular es el lema y su plural,
«azules», sale de la misma regla. «Women» y «watches» no siguen ninguna
regla: por eso el léxico inglés guarda las dos formas.

<!-- ejemplo: capitulo-54/soluciones.pl fragmento: nombre_es(mujer, f). .. verbo(mirar, watch). -->
```prolog
nombre_es(mujer, f).
nombre_en(woman, "woman", "women").
nombre(mujer, woman).
adjetivo_es(azul, invariable).
adjetivo_en(blue, "blue").
adjetivo(azul, blue).
verbo_es(mirar, transitivo, "mira", "miran").
verbo_en(watch, transitivo, "watches", "watch").
verbo(mirar, watch).
```

```prolog
?- traducciones("The women watch the blue houses.", Ts).
Ts = ["Las mujeres miran las casas azules."].

?- traducciones("La mujer vieja lee un libro azul.", Ts).
Ts = ["The old woman reads a blue book."].
```

## 3

Basta con dos hechos:

<!-- ejemplo: capitulo-54/soluciones.pl fragmento: nombre_es(gata, f). .. nombre(gata, cat). -->
```prolog
nombre_es(gata, f).
nombre(gata, cat).
```

```prolog
?- traducciones("The black cat sleeps.", Ts).
Ts = ["El gato negro duerme.", "La gata negra duerme."].
```

La transferencia da dos árboles castellanos, uno con `gato` y otro con
`gata`, y ninguno lleva género: el género es un dato del léxico. Al generar
el segundo, `sn_es//2` toma el género femenino de `nombre_es(gata, f)` y lo
pasa al artículo y al adjetivo, que dan «la» y «negra».

## 4

La oración negada es un nodo `neg(O)` alrededor de la oración afirmativa.
En castellano, «no» va antes del verbo; en inglés, el auxiliar *do*
concuerda con el sujeto y el verbo va en su forma base, que en el léxico es
la del plural: *eat*, *have*. La transferencia de una negación es la
negación de la transferencia:

<!-- ejemplo: capitulo-54/soluciones.pl predicado: oracion_es//1 oracion_en//1 auxiliar//1 transferir/2 -->
```prolog
%!  oracion_es(?Arbol)// is nondet.
%
%   La oración negada: «no» antes del verbo.
oracion_es(neg(o(S, V))) -->
    sujeto_es(S, N),
    ["no"],
    verbo_es(V, intransitivo, N).
oracion_es(neg(o(S, V, O))) -->
    sujeto_es(S, N),
    ["no"],
    verbo_es(V, transitivo, N),
    sn_es(O, _).

%!  oracion_en(?Arbol)// is nondet.
%
%   La oración negada: el auxiliar do concuerda con el sujeto, y el verbo
%   va en su forma base, que es la del plural.
oracion_en(neg(o(S, V))) -->
    sujeto_en(S, N),
    auxiliar(N),
    ["not"],
    verbo_en(V, intransitivo, pl).
oracion_en(neg(o(S, V, O))) -->
    sujeto_en(S, N),
    auxiliar(N),
    ["not"],
    verbo_en(V, transitivo, pl),
    sn_en(O, _).

%!  auxiliar(?N)// is det.
%
%   La forma del auxiliar do con un sujeto de número N.
auxiliar(sg) -->
    ["does"].
auxiliar(pl) -->
    ["do"].

%!  transferir(?Es, ?En) is nondet.
%
%   Una oración negada se traduce por la negación de su traducción.
transferir(neg(A), neg(B)) :-
    transferir(A, B).
```

```prolog
?- traducciones("El gato no come manzanas.", Ts).
Ts = ["The cat does not eat apples."].

?- traducciones("They do not sleep.", Ts).
Ts = ["No duermen.", "Ellos no duermen.", "Ellas no duermen."].
```

La segunda consulta muestra que la ambigüedad de *they* pasa intacta a
través de la negación: el nodo nuevo no interviene en el sujeto.

## 5

Las restricciones de selección se comprueban sobre el árbol castellano,
entre el análisis y la transferencia. Un pronombre o un sujeto tácito no
dicen de qué se habla, así que no se rechazan:

<!-- ejemplo: capitulo-54/soluciones.pl predicado: sensata/1 sujeto_posible/2 traducir_sensato/2 -->
```prolog
%!  sensata(+Arbol) is semidet.
%
%   El árbol castellano Arbol respeta las restricciones de selección: si
%   el verbo pide un sujeto animado, un sujeto nominal lo es.
sensata(neg(A)) :-
    sensata(A).
sensata(o(S, V)) :-
    sujeto_posible(S, V).
sensata(o(S, V, _)) :-
    sujeto_posible(S, V).

%!  sujeto_posible(+S, +V) is semidet.
%
%   El sujeto S puede acompañar al verbo V. Un pronombre o un sujeto
%   tácito siempre puede.
sujeto_posible(sn(_, L, _, _), V) :-
    (   pide_animado(V)
    ->  animado(L)
    ;   true
    ).
sujeto_posible(y(A, B), V) :-
    sujeto_posible(A, V),
    sujeto_posible(B, V).
sujeto_posible(pron(_, _), _).
sujeto_posible(tacito(_), _).

%!  traducir_sensato(+Es:string, -En:string) is nondet.
%
%   Como traducir/2 al inglés, solo para las oraciones sensatas.
traducir_sensato(Es, En) :-
    palabras(Es, PalabrasEs),
    phrase(oracion_es(A), PalabrasEs),
    sensata(A),
    transferir(A, B),
    phrase(oracion_en(B), PalabrasEn),
    texto(PalabrasEn, En).
```

```prolog
?- traducir_sensato("El libro come una manzana.", En).
false.

?- traducir_sensato("La casa tiene un libro.", En).
En = "The house has a book." ;
false.
```

La gramática acepta «el libro come una manzana»: es una oración bien
formada. Lo que la rechaza es un conocimiento del mundo, que en un
traductor real sirve sobre todo para elegir entre los sentidos de una
palabra ambigua; Covington lo trata en el apartado 8.3, «Word-Sense
Disambiguation».

## 6

Con la oración castellana instanciada, `phrase(oracion_es(A), Es)` analiza:
cada regla consume palabras de una lista finita, así que las respuestas son
finitas. Con la oración castellana libre, la misma meta genera: produce
oraciones castellanas en el orden de las cláusulas, y cada una pasa por la
transferencia y la generación inglesa para compararla con la dada. Las
oraciones con sujeto tácito y con pronombre son finitas y salen primero;
«he sleeps» se encuentra entre ellas, con «duerme»:

```prolog
?- call_with_inference_limit(traducir_ingenuo(Es, ["he", "sleeps"]), 100000, R).
Es = ["duerme"],
R = true ;
Es = ["él", "duerme"],
R = true ;
R = inference_limit_exceeded.
```

Después de «él duerme» vienen las oraciones con sujeto nominal. La primera
cláusula de `articulo_es//3` es la del artículo `sin`, y el sujeto sin
artículo se rechaza en `sujeto_es//2` recién después de generar el
sintagma completo; antes de ese rechazo, la vuelta atrás prueba otra lista
de adjetivos, una más larga cada vez, y no hay una última. La consulta da
las dos traducciones y, pedida una tercera, no termina: el límite de
inferencias la detiene.

## 7

`adjetivos/2` termina con cualquiera de las dos listas instanciada:
`same_length/2` fija el largo de la otra, y `reverse/2` y `maplist/3`
recorren listas de largo conocido. `adjetivos_ingenuo/2` termina solo con
la primera lista instanciada; con ella libre da la respuesta y, pedida
otra, `reverse/2` prueba listas cada vez más largas. Un modo que no termina
no se declara, así que su primer argumento es `+`:

```prolog
%!  adjetivos(+Es:list, -En:list) is nondet.
%!  adjetivos(-Es:list, +En:list) is nondet.
%!  adjetivos_ingenuo(+Es:list, -En:list) is nondet.
```

Los dos son `nondet` en el sentido lógico, porque un adjetivo puede tener
más de un equivalente: `[grande]` da `[big]` y `[large]`. El encabezado de
`transferencia.pl` escribe `adjetivos(?Es, ?En)` en una sola línea y dice
en la descripción que una de las dos listas debe tener largo conocido; las
dos formas son válidas, y la de dos líneas deja la condición en los modos.

## 8

`length(Es, _)` con `Es` libre da listas de largo 0, 1, 2… Con el largo
fijo, `phrase(oracion_es(A), Es)` genera solo oraciones de ese largo, y la
lista de adjetivos no puede crecer sin límite: cada largo tiene una
cantidad finita de oraciones, y el recorrido llega a todas. Es la
profundización iterativa de la [sección 40.4](../capitulo-40-busqueda-y-planificacion/index.md#404-profundidad-limitada-y-profundizacion-iterativa), con el largo de la
oración como profundidad:

<!-- ejemplo: capitulo-54/soluciones.pl predicado: al_castellano_por_largo/2 -->
```prolog
%!  al_castellano_por_largo(+En:list(string), -Es:list(string)) is nondet.
%
%   Es es una traducción de En, buscada entre las oraciones castellanas
%   de largo 0, 1, 2… Encuentra todas las traducciones, pero no termina
%   después de la última.
al_castellano_por_largo(En, Es) :-
    length(Es, _),
    traducir_ingenuo(Es, En).
```

```prolog
?- call_with_inference_limit(al_castellano_por_largo(["the", "cat", "sleeps"], Es), 100000, R).
Es = ["el", "gato", "duerme"],
R = true ;
Es = ["la", "gata", "duerme"],
R = true ;
R = inference_limit_exceeded.
```

«El gato duerme» y «la gata duerme», del ejercicio 3, tienen largo 3 y se
encuentran. Pedida otra respuesta, el
recorrido sigue con los largos 4, 5, 6…, y nada le dice que ya no hay
traducciones más largas: la búsqueda no termina. Además, cada largo genera
todas sus oraciones castellanas para compararlas con la dada; `en_es/2`
analiza la oración dada y genera solo sus traducciones.

## 9

El sujeto coordinado es un nodo `y(A, B)`, plural, con dos sintagmas. En
castellano cada uno necesita artículo, como cualquier sujeto; en inglés
pueden no tenerlo, y entonces la transferencia usa la lectura genérica de
cada miembro:

<!-- ejemplo: capitulo-54/soluciones.pl predicado: sujeto_es//2 sujeto_en//2 sujeto/2 -->
```prolog
%!  sujeto_es(?S, ?N)// is nondet.
%
%   Dos sintagmas con artículo unidos por «y»: el sujeto es plural.
sujeto_es(y(A, B), pl) -->
    sn_es(A, _),
    ["y"],
    sn_es(B, _),
    { A = sn(Art1, _, _, _),
      B = sn(Art2, _, _, _),
      Art1 \== sin,
      Art2 \== sin }.

%!  sujeto_en(?S, ?N)// is nondet.
%
%   Dos sintagmas unidos por «and»: el sujeto es plural.
sujeto_en(y(A, B), pl) -->
    sn_en(A, _),
    ["and"],
    sn_en(B, _).

%!  sujeto(?Es, ?En) is nondet.
%
%   Un sujeto coordinado se traduce miembro a miembro.
sujeto(y(A1, B1), y(A2, B2)) :-
    sujeto(A1, A2),
    sujeto(B1, B2).
```

```prolog
?- traducciones("El gato y el perro duermen.", Ts).
Ts = ["The cat and the dog sleep."].

?- traducciones("Cats and dogs sleep.", Ts).
Ts = ["Los gatos y los perros duermen.", "Las gatas y los perros duermen."].
```

La cláusula castellana llama a `sn_es//2` y no a `sujeto_es//2`: una
llamada a `sujeto_es//2` como primera meta de una de sus propias cláusulas
es una recursión a izquierda, que en el análisis no termina
([sección 21.7](../capitulo-21-gramaticas-dcg/index.md#217-recursion-a-izquierda)). La segunda traducción de «cats and dogs» viene
del ejercicio 3.

## 10

`statistics(inferences, I)` da la cantidad de inferencias hechas hasta el
momento. `inferencias/2` ejecuta la meta una vez antes de medir, porque la
primera ejecución carga bibliotecas por autocarga (`same_length/2`,
`list_to_set/2`) y esa carga también suma inferencias: la primera medida de
`es_en/2` da unas cuarenta mil. La doble negación deshace las ligaduras de
esa primera ejecución, para que la segunda empiece igual:

<!-- ejemplo: capitulo-54/soluciones.pl predicado: inferencias/2 -->
```prolog
%!  inferencias(:Meta, -N:integer) is semidet.
%
%   N es la cantidad de inferencias que usa la primera solución de Meta.
%   Meta se ejecuta dos veces y se mide la segunda: la primera carga las
%   bibliotecas que usa por primera vez, y esa carga también se contaría.
%   La doble negación deshace las ligaduras de la primera ejecución.
inferencias(Meta, N) :-
    \+ \+ once(Meta),
    statistics(inferences, I0),
    once(Meta),
    statistics(inferences, I),
    N is I - I0.
```

```prolog
?- inferencias(es_en(["el", "gato", "negro", "come", "una", "manzana"], _), N).
N = 501.

?- inferencias(en_es(["the", "black", "cat", "eats", "an", "apple"], _), N).
N = 322.
```

Medidas por separado, las etapas explican la diferencia: el análisis
castellano cuesta 433 inferencias y el inglés 257; la transferencia, 27 en
cada sentido; la generación, unas 40 en cada lengua. El análisis es la
etapa cara, y el castellano más que el inglés, por dos razones. Cada
palabra se busca recorriendo el léxico y calculando la forma de cada
candidato —`nombre_es//3` llama a `atom_string/2` y a `numero_es/3` para
cada nombre hasta encontrar el que coincide—, mientras el léxico inglés
tiene las formas escritas. Y la primera cláusula de `oracion_es//1` es la
intransitiva: analiza el sujeto, encuentra un verbo transitivo, y la
segunda cláusula analiza el sujeto otra vez. Al generar, el lema llega
instanciado y cada búsqueda en el léxico va directo al hecho.

## 11

La interlingua representa el contenido sin el orden ni las palabras de
ninguna lengua: un evento con su acción, su agente y su paciente. Una
entidad lleva su determinación (`definido`, `indefinido`, `generico`,
`ninguna`), su concepto, su número y sus propiedades; una persona, su
género y su número, y el género queda libre cuando la oración no lo dice.
Los conceptos se nombran con los lemas castellanos, para no escribir un
tercer léxico. `it` es la persona de género neutro, que ningún pronombre
castellano expresa:

<!-- ejemplo: capitulo-54/soluciones.pl predicado: interlingua_es/2 agente_es/2 entidad_es/2 interlingua_en/2 agente_en/2 entidad_en/2 es_en_interlingua/2 -->
```prolog
%!  interlingua_es(?Arbol, ?I) is nondet.
%
%   I es la representación común del árbol castellano Arbol: un evento
%   con la acción, el agente y el paciente. Los conceptos se nombran con
%   los lemas castellanos; los adjetivos, en el orden del castellano.
interlingua_es(o(S, V), evento(V, I)) :-
    agente_es(S, I).
interlingua_es(o(S, V, O), evento(V, I, J)) :-
    agente_es(S, I),
    entidad_es(O, J).

%!  agente_es(?S, ?I) is nondet.
%
%   I representa al sujeto castellano S. El sujeto tácito deja el género
%   sin determinar; el plural con artículo definido puede ser genérico.
agente_es(tacito(N), persona(_, N)).
agente_es(pron(G, N), persona(G, N)).
agente_es(S, I) :-
    entidad_es(S, I).
agente_es(sn(el, L, pl, As), ent(generico, L, pl, As)).

%!  entidad_es(?SN, ?I) is nondet.
%
%   I representa al sintagma nominal castellano SN.
entidad_es(sn(A, L, N, As), ent(D, L, N, As)) :-
    determinacion(A, D).

%!  interlingua_en(?Arbol, ?I) is nondet.
%
%   I es la representación común del árbol inglés Arbol.
interlingua_en(o(S, V), evento(C, I)) :-
    verbo(C, V),
    agente_en(S, I).
interlingua_en(o(S, V, O), evento(C, I, J)) :-
    verbo(C, V),
    agente_en(S, I),
    entidad_en(O, J).

%!  agente_en(?S, ?I) is nondet.
%
%   I representa al sujeto inglés S; it es la persona de género neutro.
agente_en(pron(he), persona(m, sg)).
agente_en(pron(she), persona(f, sg)).
agente_en(pron(it), persona(n, sg)).
agente_en(pron(they), persona(_, pl)).
agente_en(sn(sin, As, L, pl), ent(generico, C, pl, Ps)) :-
    nombre(C, L),
    adjetivos(Ps, As).
agente_en(sn(A, As, L, N), I) :-
    A \== sin,
    entidad_en(sn(A, As, L, N), I).

%!  entidad_en(?SN, ?I) is nondet.
%
%   I representa al sintagma nominal inglés SN; los adjetivos se invierten
%   con adjetivos/2 de transferencia.pl.
entidad_en(sn(A, As, L, N), ent(D, C, N, Ps)) :-
    determinacion_en(A, D),
    nombre(C, L),
    adjetivos(Ps, As).

%!  es_en_interlingua(+Es:list(string), ?En:list(string)) is nondet.
%
%   Como es_en/2, con la interlingua en lugar de la transferencia.
es_en_interlingua(Es, En) :-
    phrase(oracion_es(A), Es),
    interlingua_es(A, I),
    interlingua_en(B, I),
    phrase(oracion_en(B), En).
```

```prolog
?- findall(En, es_en_interlingua(["come", "manzanas"], En), Ts).
Ts = [["he", "eats", "apples"], ["she", "eats", "apples"], ["it", "eats", "apples"]].
```

La prueba `ej11_igual_que_transferencia` compara las traducciones de
cuatro oraciones por los dos caminos. Con transferencia, cada par de
lenguas necesita su relación: para cuatro lenguas, seis relaciones, o doce
si cada sentido se escribe aparte. Con una interlingua, cada lengua
necesita una: cuatro. La ventaja crece con la cantidad de lenguas; el
costo es diseñar una representación que exprese todo lo que alguna lengua
distingue, como el género neutro de *it* o el sujeto sin género de
«come».

## 12

En castellano, el poseedor es un complemento después del sintagma, y «de
el» se contrae en «del»; en inglés, el poseedor ocupa el lugar del artículo
y su nombre lleva la marca de posesión. El árbol castellano es `de(SN, P)`,
y el inglés, `gen(P, Adjs, Nombre, Num)`:

<!-- ejemplo: capitulo-54/soluciones.pl predicado: sn_es//2 poseedor_es//1 de_articulo//2 sn_en//2 poseedor_en//1 posesivo/4 sn/2 -->
```prolog
%!  sn_es(?SN, ?N)// is nondet.
%
%   Un sintagma con artículo definido y un complemento con de: «el libro
%   del gato». El poseedor lleva artículo definido.
sn_es(de(sn(el, L, N, As), P), N) -->
    sn_es(sn(el, L, N, As), N),
    poseedor_es(P).

%!  poseedor_es(?P)// is nondet.
%
%   El complemento «de» con un sintagma definido; de el se contrae en del.
poseedor_es(sn(el, L, N, As)) -->
    de_articulo(G, N),
    nombre_es(L, G, N),
    adjetivos_es(As, G, N).

%!  de_articulo(?G, ?N)// is nondet.
%
%   La preposición de con el artículo definido de género G y número N.
de_articulo(m, sg) -->
    ["del"].
de_articulo(G, N) -->
    ["de"],
    [F],
    { articulo_es(el, G, N, F),
      F \== "el" }.

%!  sn_en(?SN, ?N)// is nondet.
%
%   Un sintagma cuyo determinante es un poseedor: «the cat's black book».
sn_en(gen(P, As, L, N), N) -->
    poseedor_en(P),
    adjetivos_en(As, _, Nombre),
    nombre_en(L, N, Nombre).

%!  poseedor_en(?P)// is nondet.
%
%   Un sintagma definido con la marca de posesión en el nombre.
poseedor_en(sn(the, As, L, N)) -->
    ["the"],
    adjetivos_en(As, _, Marcado),
    [Marcado],
    { nombre_en(L, Singular, Plural),
      posesivo(N, Singular, Plural, Marcado) }.

%!  posesivo(?N, +Sg:string, +Pl:string, ?Marcado:string) is semidet.
%
%   Marcado es la forma posesiva, en número N, del nombre de formas Sg y
%   Pl: 's, o solo el apóstrofo después de la s de un plural regular.
posesivo(sg, Singular, _, Marcado) :-
    string_concat(Singular, "'s", Marcado).
posesivo(pl, _, Plural, Marcado) :-
    (   string_concat(_, "s", Plural)
    ->  string_concat(Plural, "'", Marcado)
    ;   string_concat(Plural, "'s", Marcado)
    ).

%!  sn(?Es, ?En) is nondet.
%
%   «el libro del gato» es «the cat's book»: el poseedor ocupa el lugar
%   del artículo.
sn(de(sn(el, L1, N, As1), P1), gen(P2, As2, L2, N)) :-
    nombre(L1, L2),
    adjetivos(As1, As2),
    sn(P1, P2).
```

```prolog
?- traducciones("Ella lee el libro del gato.", Ts).
Ts = ["She reads the cat's book."].

?- traducciones("Ella tiene la casa de los perros negros.", Ts).
Ts = ["She has the black dogs' house."].

?- traducciones("Él ve los libros de las mujeres.", Ts).
Ts = ["He sees the women's books."].
```

`de_articulo//2` genera «del» antes de conocer el género del nombre, como
el artículo de la [sección 54.5](index.md#545-version-4-la-generacion): si el nombre es femenino, la
unificación del género falla y la segunda cláusula propone «de la». La
condición `F \== "el"` excluye «de el», que la contracción reemplaza.
`posesivo/4` distingue el plural regular, que termina en *s* y recibe solo
el apóstrofo, de «women», que recibe *'s*.

## Ejercicio 13

```prolog
?- lecturas(["un", "alumno", "lee", "todo", "libro"], Ls).
Ls = [alguno(_A, alumno(_A), todo(_B, libro(_B), leer(_A, _B)))-falsa, todo(_C, libro(_C), alguno(_D, alumno(_D), leer(_D, _C)))-verdadera].
```

`lecturas/2` es de `cuantificadores.pl`. La primera lectura dice que hay un
alumno que leyó todos los libros, y es falsa: Ana leyó solo el Quijote y
Beto solo Rayuela. La segunda dice que cada libro tiene algún lector, y es
verdadera. La gramática da primero la del orden de las palabras, en la que
el cuantificador del sujeto contiene al del objeto, porque
`oracion_es_q//1` pasa al sintagma nominal del sujeto el alcance que arma
el verbo con su objeto; `alcance/2` agrega después la inversa. Es también
la lectura que se entiende primero en castellano, aunque el contexto puede
imponer la otra.

## Ejercicio 14

<!-- ejemplo: capitulo-54/soluciones_tratamiento.pl predicado: sujeto/2 traducir_con_trato_ingles/3 trato_ingles/3 -->
```prolog
% «Come manzanas» también puede dirigirse a usted.
sujeto(tacito(sg), pron(you)).

%!  traducir_con_trato_ingles(+Trato, -Es:string, +En:string) is nondet.
%
%   Como traducir_con_trato/3, pero el trato solo se exige cuando el
%   sujeto inglés es you: el sujeto omitido en tercera persona traduce
%   también he, she e it, que no se dirigen a nadie.
traducir_con_trato_ingles(Trato, Es, En) :-
    palabras(En, PalabrasEn),
    phrase(oracion_en(ArbolEn), PalabrasEn),
    transferir(ArbolEs, ArbolEn),
    arg(1, ArbolEs, SujetoEs),
    arg(1, ArbolEn, SujetoEn),
    trato_ingles(SujetoEs, SujetoEn, Trato),
    phrase(oracion_es(ArbolEs), PalabrasEs),
    texto(PalabrasEs, Es).

%!  trato_ingles(+SujetoEs, +SujetoEn, ?Trato) is semidet.
%
%   Con you, el sujeto castellano omitido en singular es usted; con
%   cualquier otro sujeto inglés, el trato no importa.
trato_ingles(SujetoEs, SujetoEn, Trato) :-
    (   SujetoEn == pron(you)
    ->  (   SujetoEs == tacito(sg)
        ->  Trato = usted
        ;   trato(SujetoEs, Trato)
        )
    ;   true
    ).
```

```prolog
?- traducciones("Come manzanas.", Ts).
Ts = ["He eats apples.", "She eats apples.", "It eats apples.", "You eat apples."].

?- findall(Es, traducir_con_trato(tu, Es, "You eat apples."), L).
L = ["Comes manzanas.", "Tú comes manzanas.", "Come manzanas."].

?- findall(Es, traducir_con_trato_ingles(tu, Es, "You eat apples."), L).
L = ["Comes manzanas.", "Tú comes manzanas."].
```

«Come manzanas.» tiene cuatro traducciones. `traducir_con_trato/3`
examina solo el árbol castellano, y el sujeto omitido en tercera persona
no fija el trato, porque también traduce *he*, *she* e *it*; por eso
acepta «Come manzanas.» para *you* con el trato de tú. El trato depende del
par de sujetos: `trato_ingles/3` lo exige solo cuando el sujeto inglés es
*you*, y entonces el sujeto omitido en tercera persona es usted.
