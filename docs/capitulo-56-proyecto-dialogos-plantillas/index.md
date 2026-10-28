# Capítulo 56 — Proyecto: diálogos por plantillas

Un programa puede sostener una conversación en castellano sin analizar las
frases con una gramática completa: le alcanza con reconocer ciertos patrones
de palabras y responder con una plantilla. «Estoy cansada» sigue el patrón
«… estoy X», y la respuesta «¿Por qué estás X?» repite el segmento X. Así
funcionaba ELIZA, el programa de Joseph Weizenbaum (1966) que conversaba
como un psicoterapeuta y que muchos de sus usuarios tomaron por alguien que
los entendía. Este capítulo construye en cinco versiones un programa de ese
tipo: plantillas con segmentos, el cambio de persona (lo que el usuario dice
de sí mismo vuelve en boca del programa: «mi jefe me odia» pasa a «tu jefe
te odia»), una ELIZA con prioridades, turnos y memoria, y una agenda que
anota citas dictadas en castellano y responde preguntas sobre ellas. Dos
programas más aplican la misma idea —el patrón es un término y la
unificación hace el emparejamiento— a otros datos: ANALOGY, que resuelve
analogías geométricas, y un aplicador de guiones al estilo de McSAM, que
completa los pasos que una historia omite.

![Una terminal con el nombre ELIZA en letras grandes y una conversación en inglés: las líneas de ELIZA alternan con las del usuario, YOU](eliza.png)

Una conversación con una versión de ELIZA escrita por Norbert Landsteiner
en 2005, en inglés: empieza con las frases del artículo de Weizenbaum («Men
are all alike», «Well, my boyfriend made me come here») y cada respuesta
devuelve una parte de la frase anterior con la persona cambiada («your
boyfriend made you come here»). Imagen: autor desconocido, dominio público,
vía [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:ELIZA_conversation.png).

El proyecto parte principalmente de tres libros. El apartado 2.1, «Template matching», de
*Natural Language Processing for Prolog Programmers* de Michael Covington,
presenta ELIZA como un sistema de plantillas; el ejercicio de proyecto
«ELIZA in Prolog» del apartado 2.2.4 enumera lo que una versión en Prolog
necesita, y el capítulo lo sigue punto por punto: variables que abarcan
varias palabras, el cambio entre primera y segunda persona sin caer en un
ciclo, la palabra más importante como criterio para elegir entre plantillas
y respuestas que varían. Del apartado 11.2, «Advanced Projects», de
*Programming in Prolog* de William Clocksin y Christopher Mellish, se toman
dos enunciados: el proyecto 14, un psiquiatra simulado que responde según
palabras clave, y el 15, un analizador de frases sobre citas en una oficina
que resume quién, qué, dónde y cuándo, las guarda y responde preguntas; es
la agenda de la versión 4. El apartado 14.3, «Artificial Intelligence
Classics: ANALOGY, ELIZA, and McSAM», de *The Art of Prolog* de Leon Sterling
y Ehud Shapiro
([préstamo en el Internet Archive](https://archive.org/details/artofprologadvan00ster)),
reconstruye los tres programas clásicos: de él vienen los pares de estímulo y
respuesta con ranuras, la analogía como una operación que se encuentra y se
aplica con el mismo predicado, y el guion que se activa por una palabra de la
historia y se empareja con ella como una subsucesión; sus ejercicios proponen
corregir el cambio de persona y reescribir McSAM con estructuras, que es lo
que hace este capítulo. Las reglas, los textos y el código son propios, en
castellano.

El capítulo reutiliza las gramáticas del
[capítulo 22](../capitulo-22-gramaticas-dcg/index.md) —de su archivo
`fechas.pl` carga `fecha_valida/3`— y la separación en palabras del
[capítulo 45](../capitulo-45-proyecto-aventura-de-texto/index.md), cuyo
`palabras/2` importa, con su técnica para redactar respuestas con
gramáticas. Cumple así el anuncio del
[capítulo 45](../capitulo-45-proyecto-aventura-de-texto/colossal-cave.md#temas-que-se-retoman): diálogos en castellano
con plantillas de respuesta. Las cinco versiones del diálogo son módulos que
cargan archivos de otros capítulos, y se ejecutan en una instalación local;
ANALOGY y los guiones corren también en SWISH. Los bucles de conversación
leen de un stream que reciben como argumento, y las pruebas les pasan
cadenas, nunca el teclado.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- escribir patrones con variables que abarcan segmentos de una frase y
  emparejarlos con `append/3`;
- cambiar la persona de una frase en castellano con una gramática de una
  sola pasada que mira el contexto de cada palabra;
- elegir entre varias reglas por prioridad, turnar respuestas y recordar
  frases, con el estado de la conversación en argumentos;
- escribir una gramática de citas con complementos en cualquier orden, y
  otra que redacta las respuestas;
- combinar dos programas de diálogo en un solo bucle que recibe como
  argumento el predicado que responde;
- representar diagramas e historias como términos y resolver con
  unificación analogías y guiones.
- escribir un guion de palabras clave como el DOCTOR de Weizenbaum, con
  rangos, descomposiciones y reensamblados por turnos.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **3:10 h**.
    Resolver los 5 ejercicios marcados con ★: **1:35 h**.
    Resolver los 13 ejercicios del capítulo: **3:50 h**.

## 56.1 El programa terminado

El programa terminado se carga con `swipl ejemplos/capitulo-56/dialogo.pl` y
se ejecuta con `dialogo.`. Cada frase pasa primero por la agenda y, si no es
una cita ni una pregunta sobre citas, por ELIZA. Así se ve una conversación,
con las frases del usuario después de `> `, tal como la terminal las muestra
al escribirlas. El programa se dirige al usuario en segunda persona, con
«tú»; el texto del curso que lo rodea sigue siendo impersonal:

```text
Hola. Cuéntame qué te preocupa, o dime qué citas tienes.
> Estoy cansada.
¿Por qué estás cansada?
> Mi jefe me dice que trabajo poco.
¿Qué piensas de que tu jefe te diga que trabajas poco?
> Tengo una reunión con Pérez el martes a las 10 en la oficina.
Anotado: el martes a las 10:00, una reunión con Pérez en la oficina.
> Tengo miedo de esa reunión.
¿Qué te asusta de esa reunión?
> Tengo un almuerzo con Ana el martes a las 1 y media de la tarde.
Anotado: el martes a las 13:30, un almuerzo con Ana.
> ¿Qué tengo el martes?
El martes: a las 10:00, una reunión con Pérez en la oficina; a las 13:30, un almuerzo con Ana.
> Creo que eres una computadora.
¿Te preocupan las máquinas?
> Bueno.
Antes dijiste que tu jefe te dice que trabajas poco. ¿Tiene algo que ver con esto?
> ¿Dónde estoy el martes a las 10?
El martes a las 10:00 estás en la oficina.
> Adiós.
Adiós. Gracias por conversar.
```

Cada respuesta sale de una pieza distinta del programa. «trabajo poco» vuelve
como «trabajas poco» por el cambio de persona; «Creo que eres una
computadora» sigue dos patrones, el de «creo que» y el de las máquinas, y
gana el de las máquinas, que tiene más prioridad; «Bueno.» no sigue ningún
patrón, y el programa vuelve sobre una frase anterior que empezaba con «mi».
La prueba `sesion` de `dialogo.plt` compara esta conversación, línea por
línea, con lo que escribe el programa.

| Versión | Archivo | Agrega | Lo que no puede hacer todavía |
|---|---|---|---|
| 1 | `plantillas.pl` | patrones con segmentos y respuestas que los repiten | devuelve «mi trabajo» en lugar de «tu trabajo» |
| 2 | `persona.pl` | el cambio de persona, las tildes recuperadas | la primera regla escrita gana, y responde siempre igual |
| 3 | `eliza.pl` | prioridades, turnos, memoria y el bucle | no guarda lo que se le dice |
| 4 | `agenda.pl` | citas en castellano, preguntas sobre ellas | es un programa aparte |
| 5 | `dialogo.pl` | la agenda y ELIZA en una conversación | — |

El recorrido de una frase por el programa terminado:

```mermaid
flowchart TD
    F["frase del usuario"] --> P["palabras/2"]
    P --> A{"¿la agenda<br/>la reconoce?"}
    A -- "sí" --> AG["atender/4:<br/>anotar o responder"]
    A -- "no" --> R["elegir_regla/3:<br/>mayor rango"]
    R --> C["coincide/2:<br/>segmentos"]
    C --> PE["persona//1:<br/>cambio de persona"]
    PE --> T["turno y plantilla"]
    AG --> S["respuesta"]
    T --> S
```

Las secciones [56.7](analogia.md#567-analogy-analogias-geometricas) y
[56.8](guiones.md#568-guiones-completar-una-historia) presentan ANALOGY y los guiones,
y la [56.9](guiones.md#569-el-guion-doctor-de-weizenbaum), el guion DOCTOR tal como lo
describe Weizenbaum.

## 56.2 Versión 1: plantillas con segmentos

Las palabras de una frase salen de `palabras/2`, del
[capítulo 45](../capitulo-45-proyecto-aventura-de-texto/lenguaje.md#ordenes-en-castellano-el-bucle-del-juego-y-la-pantalla-completa),
que pasa el texto a minúsculas, quita las tildes y separa las palabras; el
módulo la importa con `use_module('../capitulo-45/lenguaje', [palabras/2])`
y no carga nada más en su espacio de nombres. Un patrón es una lista de esas
palabras y de variables. En la unificación, una variable ocupa el lugar de
un solo elemento; aquí cada variable del patrón representa un **segmento**,
una lista de cero o más palabras. `coincide/2` recorre el patrón y, al
encontrar una variable, la liga a un prefijo de lo que queda de la frase con
`append/3`:

<!-- ejemplo: capitulo-56/plantillas.pl predicado: coincide/2 -->
```prolog
%!  coincide(+Patron:list, +Palabras:list(atom)) is nondet.
%
%   Palabras sigue el Patron: cada palabra del patrón aparece en su lugar,
%   y cada variable del patrón queda ligada a la lista de palabras que
%   ocupa su lugar, que puede ser vacía. Las alternativas dan segmentos
%   cada vez más largos a las primeras variables.
coincide([], []).
coincide([E|Es], Palabras) :-
    (   var(E)
    ->  append(E, Resto, Palabras)
    ;   Palabras = [E|Resto]
    ),
    coincide(Es, Resto).
```

```prolog
?- coincide([X, estoy, Y], [hoy, estoy, muy, cansado]).
X = [hoy],
Y = [muy, cansado] ;
false.

?- coincide([X, y, Y], [a, y, b, y, c]).
X = [a],
Y = [b, y, c] ;
X = [a, y, b],
Y = [c] ;
false.
```

El segundo patrón sigue la frase de dos maneras, y el retroceso las da a las
dos: primero los segmentos más cortos para las primeras variables. Es la
«nondeterministic use of `append`» con que Sterling y Shapiro describen su
ELIZA, que representa las ranuras con números y registra con qué palabras se
llena cada una en un diccionario incompleto; con variables de Prolog, el
diccionario es innecesario: la ligadura de cada variable es la entrada. La
ELIZA de Peter Norvig, que Covington cita, llama a estas variables
*segment variables* y las prueba con prefijos cada vez más largos, el mismo
orden en que `append/3` los genera.

Una regla empareja un patrón con una respuesta. La respuesta es una lista de
textos y de las mismas variables, y `rellenar/2` la convierte en un texto:
cada texto tal como está, cada segmento con sus palabras separadas por un
blanco. Las reglas se prueban en el orden en que están escritas, y la última
tiene el patrón `[_]`, que coincide con cualquier frase:

<!-- ejemplo: capitulo-56/plantillas.pl fragmento: regla([_, estoy, X], ["¿Por qué estás ", X, "?"]). .. regla([_], ["Continúa, por favor."]). -->
```prolog
regla([_, estoy, X], ["¿Por qué estás ", X, "?"]).
regla([_, necesito, X], ["¿Qué harías si consiguieras ", X, "?"]).
regla([_, madre, _], ["Háblame más de tu familia."]).
regla([_, padre, _], ["Háblame más de tu familia."]).
regla([_, porque, _], ["¿Es esa la verdadera razón?"]).
regla([_], ["Continúa, por favor."]).
```

<!-- ejemplo: capitulo-56/plantillas.pl predicado: responder/2 -->
```prolog
%!  responder(+Frase:string, -Respuesta:string) is det.
%
%   Respuesta es la respuesta de la primera regla cuyo patrón sigue Frase.
responder(Frase, Respuesta) :-
    palabras(Frase, Palabras),
    once(( regla(Patron, Plantilla),
           coincide(Patron, Palabras) )),
    rellenar(Plantilla, Respuesta).
```

```prolog
?- responder("Hoy estoy muy cansado.", R).
R = "¿Por qué estás muy cansado?".

?- responder("Estoy triste por mi trabajo", R).
R = "¿Por qué estás triste por mi trabajo?".
```

!!! question "Actividad"
    Predecir qué hace `coincide(P, [hola])` con `P` libre, antes de
    ejecutarlo con `call_with_inference_limit(coincide(P, [hola]), 100000,
    R)`. Explicar con las dos cláusulas de `coincide/2` por qué la regla por
    omisión tiene el patrón `[_]` y no una variable sola.

**Lo que falta.** La respuesta repite las palabras del usuario tal como las
dijo: «mi trabajo», dicho por el usuario, vuelve como «mi trabajo», dicho por
el programa.

## 56.3 Versión 2: el cambio de persona

Al devolver una frase, lo que el usuario dice de sí mismo tiene que pasar a
la segunda persona, y lo que dice del programa, a la primera: «yo» pasa a
«tú», «mi» a «tu», «me» a «te», y al revés. En castellano cambian además los
verbos: «estoy» pasa a «estás», «quiero» a «quieres», «eres» a «soy». La
conjugación de un verbo regular sigue una regla: la primera persona del
singular del presente es la raíz seguida de *o*, y la segunda, la raíz
seguida de *as* o de *es* según la clase del verbo. Los verbos que cambian la
vocal de la raíz («quiero», «puedo», «siento») la cambian igual en las dos
personas, así que para esta regla también son regulares si la raíz se
escribe con el cambio. Los que no la siguen son hechos:

<!-- ejemplo: capitulo-56/persona.pl fragmento: verbo(necesit, ar). .. irregular(he, has). -->
```prolog
verbo(necesit, ar).
verbo(odi, ar).
verbo(trabaj, ar).
verbo(estudi, ar).
verbo(llor, ar).
verbo(piens, ar).
verbo(recuerd, ar).
verbo(quier, er).
verbo(pued, er).
verbo(entiend, er).
verbo(cre, er).
verbo(tem, er).
verbo(sient, ir).
verbo(viv, ir).

% irregular(Primera, Segunda): las dos personas de un verbo que no sigue
% la regla de verbo/2.
irregular(soy, eres).
irregular(estoy, estas).
irregular(voy, vas).
irregular(tengo, tienes).
irregular(digo, dices).
irregular(hago, haces).
irregular(he, has).
```

<!-- ejemplo: capitulo-56/persona.pl predicado: conjugada/2 -->
```prolog
%!  conjugada(?Primera:atom, ?Segunda:atom) is nondet.
%
%   Primera y Segunda son la primera y la segunda persona del singular del
%   presente de un mismo verbo, sin tildes.
conjugada(Primera, Segunda) :-
    irregular(Primera, Segunda).
conjugada(Primera, Segunda) :-
    verbo(Raiz, Clase),
    atom_concat(Raiz, o, Primera),
    segunda(Clase, Terminacion),
    atom_concat(Raiz, Terminacion, Segunda).
```

```prolog
?- conjugada(quiero, S).
S = quieres ;
false.

?- conjugada(P, entiendes).
P = entiendo ;
false.
```

`conjugada/2` funciona en los dos sentidos porque `atom_concat/3` separa un
átomo en sus prefijos cuando el primer argumento está ligado por `verbo/2`.
La conjugación completa, con reglas ortográficas, es tema del
[capítulo 54](../capitulo-54-proyecto-morfologia-castellano/index.md); aquí
alcanza con las dos personas del presente.

**Palabra por palabra no alcanza.** `palabra/2` cambia una palabra aislada:
un pronombre o un posesivo según la tabla `cambio/2`, un verbo según
`conjugada/2`. Aplicada a cada palabra con `maplist/3`, como el `alter/2` del
apartado 3.4, «Mapping», de Clocksin y Mellish, al que remite su proyecto 14,
se equivoca con los sustantivos que tienen la forma de un verbo:

```prolog
?- palabra_a_palabra([tengo, miedo, de, mi, trabajo], Q).
Q = [tienes, miedo, de, "tu", trabajas].
```

«trabajo» es aquí un sustantivo, y lo indica la palabra anterior: después de
un determinante («mi», «el», «una») viene un sustantivo. Del mismo modo,
«tu» es el posesivo delante de un sustantivo y el pronombre «tú» delante de
un verbo. Decidir por la palabra vecina es trabajo de una gramática.
`persona//1` recorre la frase una sola vez, con dos reglas de contexto antes
de la regla general:

<!-- ejemplo: capitulo-56/persona.pl predicado: persona//1 tras_tu/1 -->
```prolog
%!  persona(-Cambiadas:list)// is det.
%
%   Las palabras de la lista de entrada, con la persona cambiada en una
%   sola pasada. Cada palabra se cambia una vez: tú no vuelve a pasar a yo.
persona(["yo", Q|Qs]) -->
    [tu, P],
    { tras_tu(P) },
    !,
    { palabra(P, Q) },
    persona(Qs).
persona([Q, N|Qs]) -->
    [D, N],
    { determinante(D) },
    !,
    { palabra(D, Q) },
    persona(Qs).
persona([Q|Qs]) -->
    [P],
    !,
    { palabra(P, Q) },
    persona(Qs).
persona([]) -->
    [].

%!  tras_tu(+P:atom) is semidet.
%
%   Después de P, tu es el pronombre tú: P es me, te, no o un verbo en
%   segunda persona.
tras_tu(me).
tras_tu(te).
tras_tu(no).
tras_tu(P) :-
    conjugada(_, P),
    !.
```

```prolog
?- reflejar([tengo, miedo, de, mi, trabajo], Q).
Q = [tienes, miedo, de, "tu", trabajo].

?- reflejar([tu, no, me, entiendes], Q).
Q = ["yo", no, "te", entiendo].
```

Las palabras cambiadas son cadenas con su forma escrita, «tú» o «estás», con
tilde. Que la pasada sea una sola evita el ciclo contra el que previene
Covington: si las reglas de cambio se aplicaran a la frase hasta que ninguna
coincidiera, «yo» pasaría a «tú», «tú» otra vez a «yo», y la reescritura no
terminaría. En `persona//1` cada palabra se consume una vez y su reemplazo va
a la salida, donde ninguna regla lo vuelve a mirar.

**Las tildes.** `palabras/2` quita las tildes para que «estás» y «estas»
coincidan con el mismo patrón, pero la respuesta tiene que escribirlas.
`escritura/3` busca cada palabra de la respuesta en la frase original y
toma de ahí su forma escrita:

<!-- ejemplo: capitulo-56/persona.pl predicado: escritura/3 -->
```prolog
%!  escritura(+Frase:string, +Palabras:list, -Escritas:list) is det.
%
%   Escritas son las Palabras con la escritura que tienen en Frase, en
%   minúsculas y con sus tildes. Una palabra que no está en Frase, como las
%   que cambian de persona, queda como está.
escritura(Frase, Palabras, Escritas) :-
    string_lower(Frase, Minusculas),
    split_string(Minusculas, " ", " .,;:¿?¡!\"«»()", Partes),
    maplist(escrita_en(Partes), Palabras, Escritas).
```

`responder/2` es el de la versión 1 con un paso más: antes de rellenar la
plantilla, cada segmento pasa por `reflejar/2` y por `escritura/3`:

```prolog
?- responder("Creo que mi jefe no me entiende.", R).
R = "¿Por qué crees que tu jefe no te entiende?".
```

!!! question "Actividad"
    Predecir qué da `reflejar/2` con `[me, dices, que, tu, eres, mi,
    amigo]` y con `[la, odio]`, y comprobarlo. Explicar el segundo
    resultado con la regla del determinante: ¿qué palabra de la lista
    `determinante/1` tiene dos funciones en castellano?

**Lo que falta.** Cuando una frase sigue dos patrones, gana el primero que
está escrito, y cada regla responde siempre lo mismo: una conversación larga
se vuelve repetitiva enseguida.

## 56.4 Versión 3: ELIZA

La versión 3 agrega los tres recursos que distinguen a ELIZA de una tabla de
respuestas. El primero es la **prioridad**. Covington propone elegir la
plantilla que reconoce la palabra más importante de la frase («computer is
more important than mother, which is more important than why»); Sterling y
Shapiro marcan las palabras importantes con un predicado aparte. Aquí cada
regla lleva un identificador, un rango y una lista de respuestas, y
`elegir_regla/3` prueba los rangos de mayor a menor:

<!-- ejemplo: capitulo-56/eliza.pl predicado: elegir_regla/3 -->
```prolog
%!  elegir_regla(+Palabras:list(atom), -Id, -Plantillas:list) is det.
%
%   Id es la regla de mayor rango cuyo patrón siguen Palabras; entre las
%   de igual rango, la primera escrita. Sus variables quedan ligadas a las
%   palabras de la frase en Plantillas.
elegir_regla(Palabras, Id, Plantillas) :-
    aggregate_all(set(R), regla(_, R, _, _), Rangos),
    reverse(Rangos, Descendentes),
    once(( member(Rango, Descendentes),
           regla(Id, Rango, Patron, Plantillas),
           coincide(Patron, Palabras) )).
```

Una regla con cuerpo genera un patrón por cada palabra de una clase: la regla
de las máquinas tiene el patrón `[_, M, _]`, y su cuerpo liga `M` a cada
palabra de `maquina/1` antes de que `coincide/2` pruebe el patrón. El
retroceso recorre la clase sin que el emparejamiento tenga que saber de
clases:

<!-- ejemplo: capitulo-56/eliza.pl fragmento: regla(maquinas, 5, [_, M, _], .. maquina(M). -->
```prolog
regla(maquinas, 5, [_, M, _],
      [ ["¿Te preocupan las máquinas?"],
        ["¿Por qué mencionas las computadoras?"],
        ["¿Qué tienen que ver las máquinas con lo que te pasa?"]
      ]) :-
    maquina(M).
```

```prolog
?- eliza:elegir_regla([mi, hermano, me, dice, que, estoy, loco], Id, _).
Id = me_dice.
```

La frase sigue tres patrones —el de la familia (rango 2), el de «estoy»
(rango 3) y el de «me dice que» (rango 4)— y gana el último.

El segundo recurso son los **turnos**: cada regla tiene varias respuestas y
las usa en orden, una por vez. El tercero es la **memoria**: una frase que
sigue el patrón de `memoria/2` («… mi X») se guarda como una respuesta para
más adelante, y cuando la única regla que coincide es la de rango 0 el
programa usa el recuerdo más antiguo. Weizenbaum lo describe como el
mecanismo que produce, al final de la conversación de su artículo, la
respuesta que vuelve sobre «my boyfriend made me come here».

Los turnos y los recuerdos son el estado de la conversación. En lugar de la
base de datos dinámica, viajan en un argumento: un término
`eliza(Turnos, Recuerdos)`, con los turnos en un árbol AVL de
`library(assoc)`, de la
[sección 23.5](../capitulo-23-estructuras-de-datos-de-la-biblioteca/index.md#235-libraryassoc-y-libraryrbtrees),
que asocia cada regla con la cantidad de veces que se usó:

<!-- ejemplo: capitulo-56/eliza.pl predicado: responder/4 turno/5 -->
```prolog
%!  responder(+Frase:string, +Estado0, -Estado, -Respuesta:string) is det.
%
%   Respuesta es la respuesta a Frase en el estado Estado0, y Estado el
%   estado que queda: el turno de la regla elegida avanza y, si Frase se
%   recuerda, su recuerdo queda al final. Si solo coincide la regla
%   ninguna y hay recuerdos, la respuesta es el primero, que se descarta.
responder(Frase, eliza(Turnos0, Recuerdos0), eliza(Turnos, Recuerdos),
          Respuesta) :-
    palabras(Frase, Palabras),
    elegir_regla(Palabras, Id, Plantillas),
    (   Id == ninguna,
        Recuerdos0 = [Recuerdo|Recuerdos1]
    ->  Respuesta = Recuerdo,
        Turnos = Turnos0
    ;   turno(Id, Plantillas, Turnos0, Turnos, Plantilla),
        texto(Frase, Plantilla, Respuesta),
        Recuerdos1 = Recuerdos0
    ),
    recordar(Frase, Palabras, Recuerdos1, Recuerdos).

%!  turno(+Id, +Plantillas:list, +Turnos0, -Turnos, -Plantilla) is det.
%
%   Plantilla es la plantilla de Plantillas a la que le toca el turno en la
%   regla Id, y Turnos registra que la regla se usó una vez más.
turno(Id, Plantillas, Turnos0, Turnos, Plantilla) :-
    (   get_assoc(Id, Turnos0, Usos)
    ->  true
    ;   Usos = 0
    ),
    length(Plantillas, Cantidad),
    I is Usos mod Cantidad,
    nth0(I, Plantillas, Plantilla),
    Usos1 is Usos + 1,
    put_assoc(Id, Turnos0, Usos1, Turnos).
```

```prolog
?- estado_inicial(E0), responder("Estoy triste", E0, E1, R1), responder("Estoy triste", E1, _, R2).
E0 = eliza(t, []),
E1 = eliza(t(estoy, 1, -, t, t), []),
R1 = "¿Por qué estás triste?",
R2 = "¿Desde cuándo estás triste?".
```

`t` es el árbol vacío, y `t(estoy, 1, -, t, t)` un árbol con la clave
`estoy` asociada a 1. Como el estado es un valor, una prueba puede repetir
una conversación desde cualquier punto sin preparar ni limpiar nada.

**El bucle.** `conversar/3` lee una línea, la responde y sigue, hasta una
despedida o el fin de la entrada. Recibe el stream y también el predicado que
responde, que llama con `call/5`; su declaración `meta_predicate` hace que el
nombre se resuelva en el módulo de quien llama, y así la versión 5 lo usa con
otro predicado:

<!-- ejemplo: capitulo-56/eliza.pl predicado: conversar/3 -->
```prolog
%!  conversar(+In, :Responder, +Estado0) is det.
%
%   Lee frases de In, una por línea, y escribe la respuesta que da
%   call(Responder, Frase, Estado0, Estado, Respuesta), hasta que la frase
%   es una despedida o In se termina.
conversar(In, Responder, Estado0) :-
    format("> "),
    read_line_to_string(In, Linea),
    (   (   Linea == end_of_file
        ;   despedida(Linea)
        )
    ->  format("Adiós. Gracias por conversar.~n")
    ;   call(Responder, Linea, Estado0, Estado, Respuesta),
        format("~w~n", [Respuesta]),
        conversar(In, Responder, Estado)
    ).
```

!!! question "Actividad"
    Predecir las tres respuestas de ELIZA, desde el estado inicial, a «Mi
    novio me trajo aquí.», «Bueno.» y «Nada.». Comprobarlo con
    `responder/4`, y explicar por qué la tercera no es «Continúa, por
    favor.», que es la primera respuesta de la regla `ninguna`.

**Lo que falta.** ELIZA no guarda nada de lo que se le dice, salvo para
repetirlo. Una agenda tiene que entender la frase lo bastante para
guardar sus datos y responder preguntas sobre ellos.

El capítulo continúa en la página
[Una agenda en castellano y una conversación con ELIZA](agenda.md#565-version-4-una-agenda-en-castellano), con la agenda de la
versión 4 y la versión 5, que la reúne con ELIZA en una conversación.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden los programas: cada solución es un
archivo que carga los del capítulo, sin modificarlos.

1. **(1)** Escribir el encabezado PlDoc de `coincide/2` con todos sus modos
   útiles y su determinación. ¿Por qué el primer argumento tiene que llegar
   instanciado como una lista completa? Relacionarlo con la primera
   actividad.
2. ★ **(2)** Agregar a ELIZA, en un archivo aparte y con cláusulas
   `eliza:regla(…)`, una regla para «no puedo X» («¿Qué te impide X?») y una
   de rango 4 para la palabra «siempre» («¿Puedes pensar en un ejemplo
   concreto?»). Comprobar que «Siempre estoy cansado» elige la segunda
   aunque la regla de «estoy» esté escrita antes.
3. ★ **(2)** Después de una preposición, «mí» es un pronombre y pasa a
   «ti»: «para mí es difícil» debe volver como «para ti es difícil».
   Escribir `reflejar_prep/2`, una variante de `reflejar/2` que lo hace
   después de «para», «por», «sin» y «a», y explicar por qué la regla no se
   puede aplicar después de «de».
4. **(1)** Escribir `verbo_regular/1` para declarar los verbos regulares por
   su infinitivo (`verbo_regular(caminar)`), y `conjugada_inf/2`, que los
   conjuga como `conjugada/2` a partir del infinitivo.

## Referencias

- Michael A. Covington, *Natural Language Processing for Prolog Programmers*,
  Prentice Hall, 1994 — apartado 2.1, «Template matching», y el ejercicio de
  proyecto «ELIZA in Prolog» del apartado 2.2.4.
  [Edición en línea](https://www.covingtoninnovations.com/books/NLPPP.pdf). El
  capítulo toma la presentación de ELIZA como un sistema de plantillas y los
  requisitos que el ejercicio enumera: variables de varias palabras, el cambio
  de persona sin ciclos, la palabra más importante como criterio de elección y
  respuestas que varían.
- William F. Clocksin y Christopher S. Mellish, *Programming in Prolog*, 5.ª
  edición, Springer, 2003 — apartado 11.2, «Advanced Projects», proyecto 14, y
  apartado 3.4, «Mapping», al que remite el proyecto 14. El capítulo toma de
  allí el enunciado del psiquiatra simulado que responde según palabras clave.
  Del apartado 3.4 toma el cambio de una frase palabra por palabra con una tabla
  de reemplazos, que `palabra_a_palabra/2` reproduce para mostrar su límite; el
  libro no tiene edición legal en línea.
- Leon Sterling y Ehud Shapiro, *The Art of Prolog: Advanced Programming
  Techniques*, 2.ª edición, MIT Press, 1994 — apartado 14.3, «Artificial
  Intelligence Classics: ANALOGY, ELIZA, and McSAM». 1.ª edición (1986) en
  [préstamo en el Internet Archive](https://archive.org/details/artofprologadvan00ster).
  El capítulo toma los pares de estímulo y respuesta con ranuras, y el ejercicio
  que propone corregir el cambio de persona.
- Joseph Weizenbaum, «ELIZA—a computer program for the study of natural language
  communication between man and machine», *Communications of the ACM* 9 (1),
  1966, pp. 36–45. [Edición en línea](https://doi.org/10.1145/365153.365168). Es
  la fuente que citan Covington y Sterling y Shapiro. El capítulo toma de este
  artículo la memoria de ELIZA y el ejemplo de conversación en que la usa.
- Peter Norvig, *Paradigms of Artificial Intelligence Programming: Case Studies
  in Common Lisp*, Morgan Kaufmann, 1992 — el capítulo «ELIZA: Dialog with a
  Machine».
  [Edición en línea](https://github.com/norvig/paip-lisp/blob/main/docs/chapter5.md).
  Covington lo cita como la descripción de una ELIZA programada; de él viene la
  variable de segmento, que abarca una sucesión de palabras y se prueba con
  prefijos cada vez más largos, la misma estrategia que `coincide/2` obtiene de
  `append/3`.
