# Curso de Prolog

Curso de SWI-Prolog en castellano, de estudio autónomo, destinado a estudiantes
de segundo año sin conocimientos previos de Prolog. Se publica como sitio web
con MkDocs en **https://katra.ballardini.com.ar/curso-de-prolog/**, con un PDF
por capítulo.

**Todos los ejemplos se abren y se ejecutan en el navegador**: cada bloque de
código del texto proviene de un archivo de `ejemplos/`, tiene sus pruebas
plunit, e incluye un enlace «▶ Abrir en SWISH» que transporta el código fuente
completo dentro de la URL. No se requiere ninguna instalación para seguir el
curso, ni ningún servicio propio para que los ejemplos funcionen.

El curso se distribuye bajo la licencia MIT. Los libros, cursos y colecciones de
ejercicios que se citan conservan su propia licencia: se los enlaza y se los
cita, y no se los reproduce.

## Estado

**Las partes I y II (capítulos 1 a 31) están completas**: texto, ejercicios,
soluciones, ejemplos con sus pruebas y PDF de cada capítulo. Los capítulos 7 a
31 están en revisión.

Las partes III (capítulos 32 a 42, con Prolog y SQL en el 42) y IV (proyectos,
capítulos 43 a 87) se están escribiendo, un capítulo por vez: los capítulos
ya escritos tienen texto, ejercicios, soluciones y pruebas; los demás tienen
una página inicial sin contenido.

## Requisitos

- [uv](https://docs.astral.sh/uv/) con Python 3.14. Todas las herramientas de
  Python residen en `.venv` y se declaran en `pyproject.toml`: no se instala
  nada de manera global.
- [SWI-Prolog](https://www.swi-prolog.org/) 9, con `swipl` en el PATH. Se usa
  para cargar los ejemplos, ejecutar sus pruebas y consultar el sandbox de
  SWISH. La versión 10 modificó la indexación de cláusulas, y con ella las
  consultas que dejan una alternativa pendiente: varias transcripciones del
  texto terminan en `true.` donde el libro muestra `true ;`, y a la inversa.
  `make transcripts` las informa como errores, de modo que el curso se escribe
  y se verifica con la versión 9.
- GNU make. En Windows, los comandos se ejecutan desde Git Bash.
- El pack `reif` de SWI-Prolog, que usa el capítulo 15 (`if_/3`). Se instala
  una vez, como lo instala cada lector (sección 15.9 del curso) y como lo hace
  CI.
- Opcionales: Docker (capítulo 31, la imagen del servicio) y `swipl-win` con
  XPCE (capítulo 36, las ventanas; viene con la instalación de SWI-Prolog en
  Windows).

La preparación, una sola vez después de clonar el repositorio:

```bash
make install        # .venv desde uv.lock y los hooks de git
make browser        # Chromium headless: los PDF y las pruebas de páginas web
swipl -g "pack_install(reif, [interactive(false)])" -t halt   # el pack del capítulo 15
make                # la lista de objetivos, con una línea cada uno
```

## Organización del repositorio

```text
docs/                     el curso; un directorio por capítulo, con index.md y soluciones.md
  plantillas.md             las formas de programa de la parte I, reunidas
  patrones.md               los patrones de las partes II y III (se regenera con make patterns w=1)
  lecturas.md               las lecturas complementarias
  pdf.md                    el apéndice B: los enlaces a los PDF de cada capítulo
ejemplos/                 los ejemplos, un directorio por capítulo
  capitulo-01/familia.pl    el programa
  capitulo-01/familia.plt   sus pruebas plunit
tools/                    las herramientas (en inglés)
references/               material de consulta: cursos, banco de ejercicios, pares SQL/Prolog
books/                    las conversiones a Markdown de los libros fuente (los PDF no se versionan)
.github/workflows/        la integración continua y la publicación del sitio
```

### Un ejemplo

Cada ejemplo es un archivo `.pl` acompañado de su `.plt`. El encabezado del
`.pl` declara la información que el curso requiere:

```prolog
:- encoding(utf8).

% Capítulo 1 - Hechos y reglas.
% Un árbol genealógico mínimo.
%?- abuelo(juan, Quien).

padre(juan, ana).
```

- `:- encoding(utf8).` es obligatoria: SWI-Prolog en Windows lee los archivos
  fuente con la codificación del sistema, y sin esa línea un carácter acentuado
  produce un error de sintaxis que impide cargar el archivo completo.
- `%?- <consulta>` declara una consulta del ejemplo. La primera se usa en el
  enlace a SWISH; todas se verifican contra el sandbox.
- `% solo-local: <motivo>` identifica un ejemplo que no se puede ejecutar en
  SWISH (archivos, hilos, interfaz, compilación). El texto muestra el motivo en
  lugar del enlace.

### Un bloque de código del texto

El texto no reproduce el código de manera manual: lo declara con una marca, y la
herramienta de sincronización lo copia desde `ejemplos/`.

````markdown
<!-- ejemplo: capitulo-01/familia.pl predicado: abuelo/2 -->
```prolog
```
````

La marca selecciona una parte del archivo: `archivo` completo,
`predicado: padre/2` (todas sus cláusulas, con sus comentarios) o
`fragmento: A .. B`. En consecuencia, para modificar un bloque se edita el
archivo `.pl`, nunca el bloque del texto.

```bash
make sync                                                       # todos los capítulos
uv run --frozen tools/sync-examples.py --write docs/capitulo-09-backtracking-y-corte/
```

La segunda forma sincroniza solo las páginas indicadas, y es la adecuada cuando
más de una persona edita el curso al mismo tiempo. Los bloques sin marca
—consultas con sus respuestas, trazas, fragmentos de pruebas— se mantienen de
manera manual.

`make transcripts` ejecuta cada consulta de un bloque con el archivo de la marca
`ejemplo:` más cercana hacia arriba. Donde no corresponde mostrar código, un
comentario de contexto indica ese archivo sin generar ningún bloque:

```markdown
<!-- contexto: capitulo-67/subsuncion.pl -->
```

## Criterios de redacción

El texto del curso y los comentarios de los programas de ejemplo usan un
registro descriptivo y técnico:

- redacción impersonal y en presente («se escribe», «la consulta responde»), sin
  segunda persona;
- ejercicios y actividades en infinitivo («Escribir…», «Explicar…»);
- sin expresiones coloquiales ni emotivas, y sin atribuir a Prolog acciones
  humanas;
- los predicados se nombran siempre con su aridad (`padre/2`), y las respuestas
  se muestran tal como las imprime SWI-Prolog 9;
- Prolog no se compara con otros lenguajes.

Todos los capítulos tienen la misma estructura: objetivos, secciones numeradas
con actividades intercaladas, ejercicios con nivel de dificultad, resumen y una
tabla de los temas que se retoman.

## Tareas frecuentes

Cada tarea, con la secuencia de comandos que la resuelve. Los objetivos se
describen uno por uno en la sección siguiente.

### Ver el curso en el navegador, en la computadora propia

```bash
make docs-serve
```

Abre el sitio en <http://localhost:8000/curso-de-prolog/> y lo reconstruye cada
vez que se guarda un archivo de `docs/` o de `ejemplos/`. Escucha en todas las
interfaces (`0.0.0.0:8000`), de modo que también se ve desde otra máquina de la
red; para cambiar la dirección: `make docs-serve DIRECCION=127.0.0.1:8001`.

El sitio se sirve sin los PDF: los enlaces del apéndice B a los PDF aparecen
solo para los que ya existen. Para verlo completo, con todos los enlaces a los
PDF funcionando, primero se generan los PDF:

```bash
make browser     # una sola vez: el Chromium headless
make pdf         # los PDF de cada capítulo y de sus soluciones
make docs-serve  # o make docs, para construir site/
```

### Escribir o modificar un ejemplo

```bash
# 1. editar el .pl y su .plt, por ejemplo ejemplos/capitulo-09/soluciones.pl
make test e=capitulo-09                     # las pruebas del capítulo
make swish e=capitulo-09                    # ¿lo acepta SWISH?
uv run --frozen tools/sync-examples.py --write docs/capitulo-09-backtracking-y-corte/
make transcripts e=capitulo-09              # las consultas del texto
make time e="capitulo-09 -v"                # las cifras de tiempo
```

El código se edita siempre en `ejemplos/`, nunca en el bloque del texto: la
sincronización lo copia (la tercera línea; `make sync` sincroniza todos los
capítulos). Si el ejemplo agrega un predicado que el capítulo presenta, va
también en la tabla «Resumen» del capítulo, que es de donde `make part-2` sabe
qué presenta cada capítulo.

### Revisar todo antes de un commit

```bash
make check       # las reglas del curso, las pruebas, SWISH, las transcripciones y el sitio estricto
make lint        # ruff, si se tocó algún archivo Python
make appendix    # si se tocó un capítulo con Python (29 a 31, 36)
make windows     # si se tocó el capítulo 36: las ventanas, solo en la máquina propia
```

### Corregir el formato del código Python

```bash
make format      # aplica el formato de ruff y las correcciones automáticas
make lint        # verifica que no quede nada
```

### Generar el sitio completo, como se publica

```bash
make pdf         # primero los PDF (solo los que cambiaron)
make docs        # después el sitio en site/, ya con los enlaces a los PDF
```

El orden importa: `make docs` no genera los PDF, y deja sin enlace los que no
encuentra.

### Publicar el curso

El sitio se publica desde `main`, en
<https://katra.ballardini.com.ar/curso-de-prolog/>, y nunca desde la máquina
propia:

```bash
git checkout -b docs/<descripcion>    # los hooks impiden los commits en main
git add …
git commit -m "docs: …"               # formato Conventional Commits
git push -u origin docs/<descripcion>
```

Después se abre el pull request, con un título en el mismo formato. CI ejecuta
la verificación completa (ver «Verificación»); al hacer el merge en `main`, el
mismo workflow genera los PDF, construye el sitio y lo publica en GitHub Pages.
También se puede ejecutar a mano desde la pestaña *Actions* del repositorio
(`workflow_dispatch`).

### Otras tareas

```bash
make pldoc       # regenerar la documentación PlDoc que enlaza el capítulo 14
make sql         # verificar los pares SQL/Prolog del banco de ejercicios
make clean       # borrar site/ y los restos de Python
make clean-pdf   # borrar los PDF generados
```

## Objetivos de make

`make` sin argumentos lista todos los objetivos. Qué hace cada uno:

| Objetivo | Qué hace |
|---|---|
| **Entorno** | |
| `make install` | Crea `.venv` exactamente desde `uv.lock` e instala los hooks de git (pre-commit, mensaje del commit, nombre de la rama). |
| `make browser` | Descarga el Chromium headless que usan los PDF y las pruebas de páginas web con Playwright. |
| **Ejemplos y texto** | |
| `make test` | Carga cada `.pl` con su `.plt` y ejecuta sus pruebas plunit; un `Warning:` cuenta como falla. `e=familia` o `e=capitulo-09` limita la corrida. |
| `make swish` | Verifica con `library(sandbox)` que cada ejemplo se puede ejecutar en SWISH, o que declara con `% solo-local:` por qué no. |
| `make sync` | Copia al texto todos los bloques que declaran que vienen de `ejemplos/`. |
| `make transcripts` | Ejecuta cada consulta `?- …` del texto y compara la cantidad de respuestas y el terminador con lo que muestra la página. |
| `make time` | Recalcula las tres cifras de tiempo de cada capítulo y avisa cuáles se apartan de las publicadas; con `-v`, muestra las del modelo. |
| `make math` | Analiza cada fórmula con el mismo KaTeX que carga el sitio. |
| `make appendix` | Ejecuta las pruebas de pytest de los capítulos con Python: 29 (Janus), 30 y 31 (los clientes de los servicios) y 36 (las páginas web, con Playwright). |
| `make windows` | Ejecuta las pruebas de las ventanas XPCE del capítulo 36 con `swipl-win`. Solo en la máquina propia: CI no tiene XPCE. |
| `make sql` | Ejecuta los pares de consultas SQL y Prolog del banco (`references/ejercicios/sql-prolog/`) y compara los resultados. |
| **Reglas del curso** | |
| `make part-1` | Verifica que los capítulos 1 a 12 no usan ningún predicado de la parte II. |
| `make part-2` | Verifica que las partes II y III no usan un predicado antes del capítulo que lo presenta (lo declara su tabla «Resumen»). |
| `make shown` | Verifica que cada predicado que consulta una transcripción se muestra en su página, o que la página nombra su archivo. |
| `make links` | Verifica que cada mención de un capítulo, una sección o un patrón en el texto es un enlace. |
| `make patterns` | Verifica que `docs/patrones.md` coincide con los recuadros «Patrón» de los capítulos; `make patterns w=1` lo regenera. |
| **Sitio y PDF** | |
| `make docs` | Construye el sitio en `site/` con `--strict`: una advertencia es un error. No genera los PDF: enlaza solo los que ya existen. |
| `make docs-serve` | Sirve el sitio en la máquina propia y lo recarga con cada cambio; `DIRECCION=` cambia la dirección. |
| `make pdf` | Genera el PDF de cada capítulo y de sus soluciones, solo los que cambiaron. Se ejecuta antes de `make docs` para un sitio con todos los PDF. |
| `make pldoc` | Regenera las páginas PlDoc de los ejemplos que enlaza el capítulo 14. |
| **Python** | |
| `make lint` | Ejecuta ruff (reglas y formato) sobre todo el Python del repositorio, sin modificar nada. |
| `make format` | Aplica el formato de ruff y las correcciones que ruff hace solo. |
| **Conjunto y limpieza** | |
| `make check` | Todo lo que tiene que estar verde antes de un commit (detalle en «Verificación»). |
| `make clean` | Borra `site/` y los restos de Python. |
| `make clean-pdf`, `make clean-pldoc` | Borran los PDF y las páginas PlDoc generados. |

## Verificación

`make check` debe terminar sin errores antes de cada commit. Ejecuta, en este
orden, de lo más barato a lo más costoso:

| | |
|---|---|
| `make part-1`, `make part-2` | ningún capítulo usa un predicado antes del capítulo que lo presenta |
| `make shown`, `make links`, `make patterns` | lo que muestran las transcripciones, los enlaces y el catálogo de patrones |
| `make test` | cada ejemplo se carga con su `.plt` y pasa sus pruebas plunit |
| `make swish` | cada ejemplo es aceptado por el sandbox de SWISH, o declara por qué no puede serlo |
| `make transcripts` | cada consulta `?- …` del texto se ejecuta y se comparan la cantidad de respuestas y el terminador |
| `make math`, `make time` | las fórmulas y las cifras de tiempo |
| comparación de bloques | el texto coincide con los archivos de `ejemplos/` (sin modificar nada) |
| `make docs` | el sitio se construye con `--strict` |

`make test`, `make swish`, `make part-2`, `make shown`, `make links`,
`make transcripts`, `make math` y `make time` aceptan `e=` para limitarse a un
ejemplo o a un capítulo:

```bash
make test e=familia        # un ejemplo, por nombre de archivo
make test e=capitulo-09    # un capítulo completo
make transcripts e=capitulo-07
```

`make check` no incluye `make lint`, `make appendix` ni `make windows`: se
ejecutan aparte, cuando se tocó Python, un capítulo con Python o las ventanas.
Los PDF no se versionan: CI los regenera y los publica junto con el sitio.

En cada pull request, CI instala SWI-Prolog 9, el pack `reif` y Chromium, y
ejecuta `make pdf`, `make check`, `make lint` y `make appendix`; la publicación
en GitHub Pages se realiza solo desde `main`.

## Flujo de trabajo con git

Los hooks instalados por `make install` impiden los commits directos en `main`,
exigen mensajes con formato Conventional Commits y, al hacer push, verifican que
la rama se llame `<tipo>/<descripcion>` con los mismos tipos (`docs`, `feat`,
`fix`…). El título del pull request debe respetar el mismo formato, porque en un
squash merge se convierte en el mensaje del commit.
