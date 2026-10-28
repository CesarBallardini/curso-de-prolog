# Las palabras de la pregunta, la gramática y la forma lógica

Esta página continúa el [capítulo 88](index.md) después de la [sección
88.3](index.md#883-version-1-palabras-clave), con las secciones
[88.4](#884-las-palabras-de-la-pregunta) y
[88.5](#885-version-2-la-gramatica-y-la-forma-logica): los tres módulos que
preparan las palabras de una pregunta antes de la gramática, y la versión 2,
la gramática que construye la forma lógica de la pregunta. El código está en
`palabras.pl`, `lemas.pl`, `nombres.pl`, `costos.pl` y `gramatica.pl`, en
`ejemplos/capitulo-88/`, con sus pruebas.

## 88.4 Las palabras de la pregunta

Antes de la gramática, tres módulos preparan las palabras. `palabras.pl`
separa el texto, pasa todo a minúsculas y quita los signos de
puntuación, con `split_string/4` del
[capítulo 55](../capitulo-55-proyecto-traduccion-castellanoingles/index.md):

<!-- contexto: capitulo-88/palabras.pl -->
```prolog
?- palabras("¿Quién cursa Lógica?", Ps).
Ps = ["quién", "cursa", "lógica"].

?- sin_tildes("análisis", S).
S = "analisis".
```

**Los lemas.** `lemas.pl` carga el analizador del
[capítulo 54](../capitulo-54-proyecto-morfologia-castellano/dos-niveles.md#546-version-4-las-reglas-en-paralelo),
`paralelo.pl`, sin copiarlo, y agrega a su léxico los lemas que las
preguntas necesitan. El léxico del [capítulo 54](../capitulo-54-proyecto-morfologia-castellano/index.md) declara sus predicados
`multifile` para eso: las entradas nuevas son cláusulas de
`lexico:verbo/2` y `lexico:nombre/2` escritas en este archivo. «aprobar»
es de la clase `o_ue`, porque la *o* de la raíz cambia por *ue* cuando
recibe el acento: *aprueba*.

<!-- ejemplo: capitulo-88/lemas.pl fragmento: lexico:verbo("cursar", regular). .. forma(Palabra, Analisis). -->
```prolog
lexico:verbo("cursar", regular).
lexico:verbo("aprobar", o_ue).
lexico:verbo("necesitar", regular).
lexico:nombre("alumno", masculino).
lexico:nombre("materia", femenino).
lexico:nombre("carrera", femenino).

:- table analisis/2.

%!  analisis(+Palabra:string, -Analisis) is nondet.
%
%   Analisis es un análisis de Palabra según el capítulo 54: por ejemplo
%   verbo(Lema, Tiempo, Persona, Numero) o nombre(Lema, Genero, Numero).
%   Falla si Palabra no es una forma de ningún lema del léxico.
analisis(Palabra, Analisis) :-
    forma(Palabra, Analisis).
```

<!-- contexto: capitulo-88/lemas.pl -->
```prolog
?- analisis("aprobaron", A).
A = verbo("aprobar", preterito, 3, plural).

?- findall(A, analisis("aprueba", A), As).
As = [verbo("aprobar", presente, 3, singular)].
```

`forma/2` analiza la palabra con un transductor, y el análisis de una
palabra nueva cuesta miles de inferencias. La gramática vuelve atrás y
prueba la misma palabra varias veces, como verbo y como nombre, en cada
regla que podría empezar por ella. Por eso `analisis/2` está tabulado,
como las funciones del
[capítulo 40](../capitulo-40-tabulacion/index.md#402-memorizacion-sin-estado-escrito-a-mano):
cada palabra se analiza una vez en toda la sesión.
`dos_veces/3`, de `costos.pl`, analiza unas preguntas con las tablas
vacías y otra vez con las tablas llenas:

<!-- contexto: capitulo-88/costos.pl -->
```prolog
?- dos_veces(["¿Cuántos alumnos de sistemas aprobaron álgebra?"], N1, N2).
N1 = 279371,
N2 = 512.
```

La primera vez, el análisis de esa pregunta cuesta unas 279 000
inferencias, casi todas del analizador morfológico; la segunda, unas 500.
Las dieciséis preguntas de ejemplo del capítulo cuestan juntas unas
391 000 inferencias la primera vez y unas 22 800 la segunda: las palabras
se repiten de una pregunta a otra, y cada una se analiza una sola vez
(pruebas `costos:una_pregunta` y `costos:dieciseis`, con una banda del
10 %). La tabla tiene una consecuencia que conviene conocer: si se agrega
una palabra al léxico después de analizarla, la tabla conserva el
análisis viejo, y hay que vaciarla con `abolish_all_tables/0`.

La tabla de `analisis/2` es el patrón 101:

!!! example "Patrón 101 — Tabla para lo que la gramática prueba varias veces"
    **Problema.** Una gramática con vuelta atrás vuelve a examinar las
    mismas palabras: cada regla que podría empezar por una palabra la
    prueba, como verbo, como nombre, como nombre propio. Si examinar una
    palabra es caro, como el análisis morfológico del
    [capítulo 54](../capitulo-54-proyecto-morfologia-castellano/index.md),
    el costo se multiplica por las alternativas.

    **Versión ingenua.** Llamar al analizador desde cada regla de la
    gramática, o analizar de antemano todas las palabras de la oración en
    todas sus lecturas posibles, aunque la gramática use pocas.

    **Patrón.** Envolver el cálculo caro en un predicado que solo lo
    llama, `analisis/2`, y declararlo `:- table`. La primera llamada con
    una palabra la analiza y guarda todas sus respuestas; las siguientes,
    en la misma pregunta o en otra de la sesión, las leen de la tabla. La
    gramática no cambia. Una pregunta cuesta unas 279 000 inferencias la
    primera vez y unas 500 la segunda. Es el
    [Patrón 53](../patrones.md#53-tabular-la-relacion-recursiva) con otro
    motivo: aquí la relación no es recursiva, y la tabla no hace falta
    para terminar sino para no repetir, como la memorización del
    [Patrón 17](../patrones.md#17-memorizacion-con-assertz) sin programarla
    de manera explícita.

    **Cuándo no usarlo.** Cuando lo que se repite es barato, como una
    búsqueda indexada en un hecho: la tabla cuesta más que la llamada.
    Y cuando lo que el cálculo consulta cambia durante la sesión, como un
    léxico al que se agregan palabras: la tabla conserva el análisis
    viejo hasta que se la vacía, o hasta que los predicados de los que
    depende se declaran incrementales.

**Los nombres propios.** Pereira y Shieber señalan que el vocabulario de
`talk` está fijo en la gramática. Aquí los nombres propios vienen de la
base: un alumno se nombra por su nombre en `alumno/4`, una carrera por su
nombre, y una materia por su nombre escrito, con tildes y espacios, que
`nombres.pl` da en `escrita/2`. La forma lógica no usa los nombres sino las
**claves** de la base, el legajo y el código: dos alumnos pueden llamarse
igual, y la clave no se repite.

<!-- ejemplo: capitulo-88/nombres.pl predicado: nombre_propio//2 nombre/3 -->
```prolog
%!  nombre_propio(?Tipo, ?Entidad)// is nondet.
%
%   Las palabras nombran a Entidad, de Tipo alumno, materia o carrera.
%   Entidad es una clave de la base: un legajo, un código o una carrera.
nombre_propio(Tipo, Entidad) -->
    palabras_iguales(Palabras),
    { nombre(Tipo, Entidad, Palabras) }.

%!  nombre(?Tipo, ?Entidad, ?Palabras:list(string)) is nondet.
%
%   Palabras, sin tildes, nombran a Entidad, de Tipo.
nombre(alumno, Legajo, [Palabra]) :-
    alumno(Legajo, Nombre, _, _),
    atom_string(Nombre, Palabra).
nombre(materia, Codigo, Palabras) :-
    escrita(Codigo, Texto),
    sin_tildes(Texto, Simple),
    split_string(Simple, " ", "", Palabras).
nombre(carrera, Carrera, [Palabra]) :-
    distinct(Carrera, alumno(_, _, Carrera, _)),
    atom_string(Carrera, Palabra).
```

<!-- contexto: capitulo-88/nombres.pl -->
```prolog
?- phrase(nombre_propio(T, E), ["bases", "de", "datos"]).
T = materia,
E = bd ;
false.

?- phrase(nombre_propio(T, E), ["analisis", "1"]).
T = materia,
E = am1 ;
false.
```

La comparación es sin tildes, de modo que «analisis» nombra a análisis 1
igual que «análisis». El `false.` final viene de `palabras_iguales//1`,
que prueba primero el nombre de una palabra y después los más largos.

## 88.5 Versión 2: la gramática y la forma lógica

**La forma lógica.** La pregunta se representa con los cuantificadores
del [capítulo 55](../capitulo-55-proyecto-traduccion-castellanoingles/interlingua.md#558-version-6-una-interlingua-con-cuantificadores),
`todo(X, R, A)` y `alguno(X, R, A)`, donde R es la **restricción** («los
alumnos de civil») y A el **alcance** («cursan análisis 1»), con
`y(A, B)` para la conjunción y `no(F)` para la negación. Los predicados
son los de la base, con los lemas castellanos: `alumno/1`, `materia/1`,
`carrera/2`, `cursar/2`, `aprobar/2` y `necesitar/2`. Una pregunta es una
de tres formas:

| Pregunta | Forma lógica |
|---|---|
| «¿quién cursa lógica?» | `cual(X, y(alumno(X), cursar(X, log)))` |
| «¿cuántos aprobaron álgebra?» | `cuantos(X, y(alumno(X), aprobar(X, alg)))` |
| «¿ana aprobó lógica?» | `si_no(aprobar(101, log))` |
| «¿todos los alumnos de civil cursan análisis 1?» | `si_no(todo(X, y(alumno(X), carrera(X, civil)), cursar(X, am1)))` |
| «¿ningún alumno aprobó sintaxis?» | `si_no(no(alguno(X, alumno(X), aprobar(X, ssl))))` |

Es la traducción de Chat-80. Warren y Pereira traducen «a» y «some» con
`exists(X, R & S)`, «no» con `\+exists(X, R & S)`, «every» con
`\+exists(X, R & \+S)`, «which» con `answer(X) <= R & S` y «how many» con
`answer(N) <= numberof(X, R & S, N)`. `cual/2` es su `answer/1`,
`cuantos/2` su `numberof/3`, y `todo/3` se evaluará como su doble
negación. Pereira y Shieber escriben las preguntas de `talk` del mismo
modo, como una condición seguida de `answer(X)`.

**Los sintagmas nominales.** La dificultad está en el sujeto. En «todo
alumno aprueba», el verbo aporta `aprobar(X, …)`, pero la fórmula
completa empieza con el cuantificador, que aporta el sujeto. Pereira y
Shieber (apartado 4.1.4) adoptan la solución de Montague: el sintagma
nominal es una función que recibe la propiedad que el resto de la
oración dice de él, `X^P`, y devuelve la fórmula. En Prolog, la función es
el término `(X^P)^F`, y aplicarla es unificar. Un nombre propio aplica la
propiedad a su constante; un determinante la pone como alcance de su
cuantificador:

<!-- ejemplo: capitulo-88/gramatica.pl predicado: oracion//1 sn//3 -->
```prolog
%!  oracion(?F)// is nondet.
%
%   Una oración con sujeto y predicado cuya fórmula es F: el sujeto
%   recibe la propiedad del predicado.
oracion(F) -->
    sn(Numero, Tipo, (X^P)^F),
    sv(Numero, Tipo, X^P).

%!  sn(?Numero, ?Tipo, ?SN)// is nondet.
%
%   Un sintagma nominal de Numero, que nombra algo de Tipo. SN es
%   (X^P)^F: aplicado a la propiedad X^P, da la fórmula F.
sn(singular, Tipo, (E^P)^P) -->
    nombre_propio(Tipo, E),
    { Tipo \== carrera }.
sn(plural, Tipo, (X^P)^todo(X, R, P)) -->
    todos(Genero),
    nucleo(plural, Genero, Tipo, X^R).
sn(singular, Tipo, (X^P)^alguno(X, R, P)) -->
    alguno(Genero),
    nucleo(singular, Genero, Tipo, X^R).
sn(singular, Tipo, (X^P)^no(alguno(X, R, P))) -->
    ninguno(Genero),
    nucleo(singular, Genero, Tipo, X^R).
```

`sn(singular, Tipo, (E^P)^P)` es el «relativamente poco intuitivo»
`(shrdlu^S)^S` de Pereira y Shieber: la posición de la variable la ocupa
la constante, porque la aplicación ya está hecha por unificación. El
predicado verbal es la propiedad: el verbo transitivo aplica el objeto a
la propiedad «el sujeto X hace Lema con Y».

<!-- ejemplo: capitulo-88/gramatica.pl predicado: sv//3 verbo//4 verbo_tipos/3 -->
```prolog
%!  sv(?Numero, ?Tipo, ?P)// is nondet.
%
%   Un sintagma verbal en Numero cuyo sujeto es de Tipo. P es X^F, la
%   propiedad que el predicado dice de X. El átomo del verbo se arma
%   antes de analizar el objeto, que lo recibe ya construido.
sv(Numero, Tipo, X^no(F)) -->
    palabra("no"),
    sv(Numero, Tipo, X^F).
sv(Numero, Tipo, X^F) -->
    verbo(Numero, Lema, Tipo, TipoO),
    { A =.. [Lema, X, Y] },
    sn(_, TipoO, (Y^A)^F).

%!  verbo(?Numero, ?Lema, ?TipoS, ?TipoO)// is nondet.
%
%   Una forma de tercera persona de un verbo transitivo cuyo sujeto es de
%   TipoS y su objeto de TipoO.
verbo(Numero, Lema, TipoS, TipoO) -->
    [Palabra],
    { analisis(Palabra, verbo(LemaS, _, 3, Numero)),
      atom_string(Lema, LemaS),
      verbo_tipos(Lema, TipoS, TipoO) }.

% verbo_tipos(Lema, TipoS, TipoO): el sujeto de Lema es de TipoS y su
% objeto de TipoO.
verbo_tipos(cursar, alumno, materia).
verbo_tipos(aprobar, alumno, materia).
verbo_tipos(necesitar, materia, materia).
```

El orden de `sv//3`, el átomo antes que el objeto, es el patrón 102:

!!! example "Patrón 102 — Construir la propiedad antes de aplicarla"
    **Problema.** En una gramática que construye la forma lógica mientras
    analiza, el significado de un sintagma depende de otro: el
    cuantificador del sujeto necesita la propiedad que el predicado dice
    de él, y el objeto, el átomo del verbo del que es argumento.

    **Versión ingenua.** Analizar primero y construir la forma lógica
    después, en una segunda pasada sobre el árbol sintáctico que
    reordena los cuantificadores; o hacer que cada sintagma nominal dé
    solo su variable, y agregar su cuantificador desde afuera, donde ya
    no se sabe cuál es su alcance.

    **Patrón.** Representar lo que falta como una **propiedad**, el
    término `X^P`, y pasarla al sintagma que la aplica: un sintagma
    nominal es `(X^P)^F`, y aplicarlo es unificar. Un nombre propio pone
    su constante en lugar de X; un determinante pone P como alcance de
    su cuantificador. `sv//3` arma el átomo del verbo con `=..` **antes**
    de analizar el objeto, que recibe `(Y^A)^F` con la propiedad ya
    construida. Construida antes, la propiedad es un término que el
    sintagma puede examinar y copiar: la coordinación del
    [ejercicio 3](soluciones.md#3) la aplica una vez a cada nombre, lo
    que no se puede hacer con una variable. Como en el
    [Patrón 75](../patrones.md#75-dos-representaciones-unidas-por-un-hecho-que-comparte-las-variables),
    las variables compartidas unen las dos partes sin ningún paso de
    conversión.

    **Cuándo no usarlo.** Cuando la propiedad no se puede construir
    antes de que se aplique: en `oracion//1` el sujeto se analiza antes
    que el verbo, y recibe `X^P` con P todavía libre. La aplicación por
    unificación sigue funcionando, pero nada que examine la propiedad:
    «¿Ana y diego cursan lógica?» no se analiza. Ahí hace falta un
    término que represente la aplicación pendiente, como los árboles de
    cuantificadores del apartado 4.1.6 de Pereira y Shieber. Y cuando el
    significado de un sintagma no depende de ningún otro, como en las
    plantillas de la [versión 1](index.md#883-version-1-palabras-clave).

**Los tipos.** Cada verbo declara el tipo de su sujeto y de su objeto, y
cada nombre propio y cada nombre común tienen el suyo. Es la propuesta de
Veronica Dahl para sus sistemas de consulta en castellano: los tipos
descartan durante el análisis, por unificación, las lecturas que no
tienen sentido, y evitan consultar la base con preguntas absurdas. Chat-80
hace lo mismo con los tipos de las plantillas de su diccionario.

**Las preguntas.** Una pregunta con «quién» es un sintagma verbal cuyo
sujeto es un alumno. Una con «qué» o «cuántos» puede llevar un núcleo
nominal, «qué materias», «cuántos alumnos de sistemas», y lo que sigue es
el sintagma verbal, si lo interrogado es el sujeto, o el verbo con su
sujeto pospuesto, si es el objeto: «¿qué materias cursa ana?». Una
pregunta sin palabra interrogativa es una oración.

<!-- ejemplo: capitulo-88/gramatica.pl predicado: pregunta//1 resto_interrogativo//3 -->
```prolog
%!  pregunta(?Forma)// is nondet.
%
%   Una pregunta con forma lógica Forma: con «quién», con «qué» o
%   «cuántos» seguidos o no de un nombre, o de sí o no.
pregunta(cual(X, y(alumno(X), F))) -->
    quien(Numero),
    sv(Numero, alumno, X^F).
pregunta(Forma) -->
    interrogativo(Clase, Genero),
    nucleo(Numero, Genero, Tipo, X^R),
    resto_interrogativo(Numero, Tipo, X^F),
    { forma_pregunta(Clase, X, y(R, F), Forma) }.
pregunta(Forma) -->
    interrogativo(Clase, _),
    resto_interrogativo(_, Tipo, X^F),
    { restriccion(Tipo, X, R),
      forma_pregunta(Clase, X, y(R, F), Forma) }.
pregunta(si_no(F)) -->
    oracion(F).

%!  resto_interrogativo(?Numero, ?Tipo, ?P)// is nondet.
%
%   Lo que sigue a la palabra interrogativa: el verbo con su sujeto, si
%   lo interrogado es el objeto, o el sintagma verbal, si es el sujeto. P
%   es X^F, la propiedad que se pregunta de X, de Tipo.
resto_interrogativo(_, Tipo, X^F) -->
    verbo(NumeroV, Lema, TipoS, Tipo),
    { A =.. [Lema, Y, X] },
    sn(NumeroV, TipoS, (Y^A)^F).
resto_interrogativo(Numero, Tipo, X^F) -->
    sv(Numero, Tipo, X^F).
```

Los modificadores del núcleo son dos: «de» con el nombre de una carrera,
solo después de un nombre de alumnos, y una relativa, «que» con un
sintagma verbal del que el núcleo es el sujeto:

<!-- ejemplo: capitulo-88/gramatica.pl predicado: nucleo//4 de_carrera//4 relativa//5 -->
```prolog
%!  nucleo(?Numero, ?Genero, ?Tipo, ?P)// is nondet.
%
%   Un nombre común con sus modificadores: «alumnos de sistemas»,
%   «materias que cursa ana». P es X^R, lo que el núcleo dice de X.
nucleo(Numero, Genero, Tipo, X^R) -->
    nombre_comun(Numero, Genero, Tipo, X^R0),
    de_carrera(Tipo, X, R0, R1),
    relativa(Numero, Tipo, X, R1, R).

%!  de_carrera(?Tipo, ?X, ?R0, ?R)// is nondet.
%
%   «de sistemas» después de un nombre de alumnos agrega la carrera a R0;
%   sin ese complemento, R es R0.
de_carrera(alumno, X, R0, y(R0, carrera(X, C))) -->
    palabra("de"),
    nombre_propio(carrera, C).
de_carrera(_, _, R, R) -->
    [].

%!  relativa(?Numero, ?Tipo, ?X, ?R0, ?R)// is nondet.
%
%   «que» y un sintagma verbal del que X es el sujeto agregan una
%   condición a R0; sin relativa, R es R0.
relativa(Numero, Tipo, X, R0, y(R0, F)) -->
    palabra("que"),
    sv(Numero, Tipo, X^F).
relativa(_, _, _, R, R) -->
    [].
```

<!-- contexto: capitulo-88/gramatica.pl -->
```prolog
?- analizar("¿Cuántos aprobaron álgebra?", F).
F = cuantos(_A, y(alumno(_A), aprobar(_A, alg))).

?- analizar("¿Qué materias cursa ana?", F).
F = cual(_A, y(materia(_A), cursar(101, _A))).

?- analizar("¿Todos los alumnos de civil cursan análisis 1?", F).
F = si_no(todo(_A, y(alumno(_A), carrera(_A, civil)), cursar(_A, am1))).
```

En «¿qué materias cursa ana?», la lectura con «materias» como sujeto no
llega a formarse por dos motivos: el verbo está en singular y «materias»
en plural, y el sujeto de *cursar* es un alumno. Basta uno de los dos:

```prolog
?- lecturas("¿Qué materias cursan ana?", Fs).
Fs = [].
```

**La ambigüedad.** Cuando ni la concordancia ni los tipos deciden, la
pregunta tiene dos lecturas. En «¿qué necesita bases de datos?», «qué»
puede ser el objeto (lo que bases de datos necesita) o el sujeto (lo que
necesita bases de datos): las dos son materias, y «qué» no tiene número.

```prolog
?- lecturas("¿Qué necesita bases de datos?", Fs).
Fs = [cual(_A, y(materia(_A), necesitar(bd, _A))), cual(_B, y(materia(_B), necesitar(_B, bd)))].
```

`analizar/2` se queda con la primera, porque la gramática prueba el
objeto antes que el sujeto, y en castellano esa es la lectura habitual.
Chat-80 tampoco pregunta: resuelve el alcance de los cuantificadores con
reglas sobre el orden de las palabras. La segunda lectura es la que
responde «¿qué materias necesitan bases de datos?», con el verbo en
plural.

!!! question "Actividad"
    Predecir la forma lógica de «¿Qué alumnos que cursan paradigmas
    aprobaron lógica?» y de «¿Ningún alumno de civil aprobó álgebra?».
    Comprobarlas con `analizar/2`, y explicar por qué «¿Cuántas alumnos
    aprobaron lógica?» no tiene ninguna.

El capítulo continúa en la página [La forma lógica en
SQL](sql.md#886-version-3-evaluar-y-explicar), con la versión 3, que evalúa
la forma lógica y explica la respuesta, y la versión 4, que la traduce a una
sentencia SQL.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos, agregando cláusulas a sus
predicados `multifile` cuando hace falta.

1. ★ **(1)** Predecir la forma lógica y la respuesta de «¿Quiénes cursan
   análisis 2?» y de «¿Cuántas materias cursa carla?». Comprobarlas con
   `analizar/2` y `preguntar/1`.
2. **(1)** Escribir tres preguntas sobre *Inscripciones* que la
   gramática no analiza, cada una por un motivo distinto, y decir qué
   regla falta en cada caso.
3. **(3)** Agregar la coordinación de nombres propios: «¿Quién cursa
   lógica y álgebra?» pide los alumnos que cursan las dos. Escribir una
   cláusula de `sn//3` que aplica la propiedad a cada nombre y une las
   dos fórmulas con `y/2`. Explicar por qué `copy_term/2` sobre la
   propiedad entera da una respuesta incorrecta en «¿Qué materias
   cursan ana y diego?», y cómo se evita.

## Referencias

- Fernando C. N. Pereira y Stuart M. Shieber, *Prolog and Natural-Language
  Analysis*, CSLI, 1987; reedición digital de Microtome Publishing, 2002 —
  apartado 4.1.4, «Quantified Noun Phrases», y apartado 5.2, «A Simple Dialogue
  Program». [Edición digital de
  Microtome](http://www.mtome.com/Publications/PNLA/pnla-digital.html). Esta
  página toma de allí la técnica de Montague para los sintagmas nominales y la
  forma de las preguntas como condición y respuesta ([sección
  88.5](#885-version-2-la-gramatica-y-la-forma-logica)), y la observación de que
  el vocabulario de `talk` está fijo en la gramática ([sección
  88.4](#884-las-palabras-de-la-pregunta)).
- David H. D. Warren y Fernando C. N. Pereira, «An Efficient Easily
  Adaptable System for Interpreting Natural Language Queries»,
  *American Journal of Computational Linguistics* 8 (3–4), 1982,
  páginas 110–122. [ACL Anthology](https://aclanthology.org/J82-3002/).
  Describe Chat-80.
  Esta página toma de allí la traducción de los determinantes a la lógica
  de primer orden, con «every» como doble negación y «how many» como
  `numberof/3`, los tipos de las plantillas de su diccionario y la
  resolución del alcance de los cuantificadores por el orden de las
  palabras ([sección 88.5](#885-version-2-la-gramatica-y-la-forma-logica)).
- Veronica Dahl, «Translating Spanish into Logic through Logic»,
  *American Journal of Computational Linguistics* 7 (3), 1981, páginas
  149–164. [ACL Anthology](https://aclanthology.org/J81-3002/). Los
  sistemas de consulta de bases de datos en castellano, escritos en
  Prolog en la Universidad de Buenos Aires desde 1976, de los que partió
  Chat-80.
  Esta página toma de allí los tipos de los argumentos que descartan las
  lecturas sin sentido ([sección 88.5](#885-version-2-la-gramatica-y-la-forma-logica)).
- William A. Woods, *Semantics and Quantification in Natural Language
  Question Answering*, informe 3687, Bolt Beranek and Newman, 1977.
  [Copia en Wikimedia Commons, dominio público](https://commons.wikimedia.org/wiki/File:Semantics_and_Quantification_in_Natural_Language_Question_Answering,_November_1977.pdf).
  Lo citan Pereira y Shieber y Warren y Pereira como el origen de las
  formas lógicas con cuantificadores para responder preguntas, en el
  sistema LUNAR.
- Alain Colmerauer, «Metamorphosis grammars», en L. Bolc (ed.),
  *Natural Language Communication with Computers*, Springer, 1978. Sin
  edición en línea de acceso libre verificada. Las gramáticas de las que
  vienen las DCG, con un programa de diálogo comparable a `talk`, según
  Pereira y Shieber; sus cuantificadores de tres ramas son el
  antecedente de `todo/3` y `alguno/3`.
