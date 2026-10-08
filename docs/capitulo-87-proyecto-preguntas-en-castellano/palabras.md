# Las palabras de la pregunta

Esta página contiene la [sección 87.4](index.md#874-las-palabras-de-la-pregunta)
del [capítulo 87](index.md): los tres módulos que preparan las palabras
de una pregunta antes de la gramática. El código está en `palabras.pl`,
`lemas.pl`, `nombres.pl` y `costos.pl`, en `ejemplos/capitulo-87/`, con
sus pruebas.

## Las palabras, los lemas y los nombres

Antes de la gramática, tres módulos preparan las palabras. `palabras.pl`
separa el texto, pasa todo a minúsculas y quita los signos de
puntuación, con `split_string/4` del
[capítulo 54](../capitulo-54-proyecto-traduccion-castellanoingles/index.md):

<!-- contexto: capitulo-87/palabras.pl -->
```prolog
?- palabras("¿Quién cursa Lógica?", Ps).
Ps = ["quién", "cursa", "lógica"].

?- sin_tildes("análisis", S).
S = "analisis".
```

**Los lemas.** `lemas.pl` carga el analizador del
[capítulo 53](../capitulo-53-proyecto-morfologia-castellano/index.md#536-version-4-las-reglas-en-paralelo),
`paralelo.pl`, sin copiarlo, y agrega a su léxico los lemas que las
preguntas necesitan. El léxico del [capítulo 53](../capitulo-53-proyecto-morfologia-castellano/index.md) declara sus predicados
`multifile` para eso: las entradas nuevas son cláusulas de
`lexico:verbo/2` y `lexico:nombre/2` escritas en este archivo. «aprobar»
es de la clase `o_ue`, porque la *o* de la raíz cambia por *ue* cuando
recibe el acento: *aprueba*.

<!-- ejemplo: capitulo-87/lemas.pl fragmento: lexico:verbo("cursar", regular). .. forma(Palabra, Analisis). -->
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
%   Analisis es un análisis de Palabra según el capítulo 53: por ejemplo
%   verbo(Lema, Tiempo, Persona, Numero) o nombre(Lema, Genero, Numero).
%   Falla si Palabra no es una forma de ningún lema del léxico.
analisis(Palabra, Analisis) :-
    forma(Palabra, Analisis).
```

<!-- contexto: capitulo-87/lemas.pl -->
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
[capítulo 39](../capitulo-39-tabulacion/index.md#392-memorizacion-sin-estado-escrito-a-mano):
cada palabra se analiza una vez en toda la sesión.
`dos_veces/3`, de `costos.pl`, analiza unas preguntas con las tablas
vacías y otra vez con las tablas llenas:

<!-- contexto: capitulo-87/costos.pl -->
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

La tabla de `analisis/2` es el patrón 102:

!!! example "Patrón 102 — Tabla para lo que la gramática prueba varias veces"
    **Problema.** Una gramática con vuelta atrás vuelve a examinar las
    mismas palabras: cada regla que podría empezar por una palabra la
    prueba, como verbo, como nombre, como nombre propio. Si examinar una
    palabra es caro, como el análisis morfológico del
    [capítulo 53](../capitulo-53-proyecto-morfologia-castellano/index.md),
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

<!-- ejemplo: capitulo-87/nombres.pl predicado: nombre_propio//2 nombre/3 -->
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

<!-- contexto: capitulo-87/nombres.pl -->
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
