# Curso de Prolog

[![Ejemplos](https://github.com/CesarBallardini/curso-de-prolog/actions/workflows/ejemplos.yml/badge.svg?branch=main)](https://github.com/CesarBallardini/curso-de-prolog/actions/workflows/ejemplos.yml)
[![Texto](https://github.com/CesarBallardini/curso-de-prolog/actions/workflows/texto.yml/badge.svg?branch=main)](https://github.com/CesarBallardini/curso-de-prolog/actions/workflows/texto.yml)
[![PDF y sitio](https://github.com/CesarBallardini/curso-de-prolog/actions/workflows/sitio.yml/badge.svg?branch=main)](https://github.com/CesarBallardini/curso-de-prolog/actions/workflows/sitio.yml)
[![Diapositivas](https://github.com/CesarBallardini/curso-de-prolog/actions/workflows/diapositivas.yml/badge.svg?branch=main)](https://github.com/CesarBallardini/curso-de-prolog/actions/workflows/diapositivas.yml)
[![Sitio](https://img.shields.io/badge/sitio-katra.ballardini.com.ar-blue)](https://katra.ballardini.com.ar/curso-de-prolog/)
[![SWI-Prolog 9.2.9](https://img.shields.io/badge/SWI--Prolog-9.2.9-orange)](https://www.swi-prolog.org/)
[![Licencia: MIT](https://img.shields.io/badge/licencia-MIT-green)](LICENSE)

Curso de SWI-Prolog en castellano, de estudio autónomo, destinado a estudiantes
de segundo año sin conocimientos previos de Prolog. Se publica como sitio web
con MkDocs en **<https://katra.ballardini.com.ar/curso-de-prolog/>**, con un PDF
por capítulo.

Cada bloque de código del texto proviene de un archivo de `ejemplos/` y tiene
sus pruebas plunit. El que SWISH puede ejecutar incluye un enlace «▶ Abrir en
SWISH» que transporta el código fuente completo dentro de la URL, sin ningún
servicio propio; el que no, muestra en su lugar el motivo. La parte I y la
mayor parte de la II se siguen en el navegador, sin ninguna instalación. Desde
el capítulo 24, que presenta los módulos, muchos ejemplos requieren una
instalación local de SWI-Prolog, y también la mayor parte de los de la parte
IV, cuyos proyectos cargan módulos y archivos de otros capítulos.

El curso se distribuye bajo la licencia MIT. Los libros, cursos y colecciones de
ejercicios que se citan conservan su propia licencia: se los enlaza y se los
cita, y no se los reproduce.

## Estado

**El curso está completo**: 87 capítulos en cuatro partes —I, Introducción
(1 a 12); II, Prolog para programadores (13 a 31); III, Lo avanzado (32 a 42,
con Prolog y SQL en el 42); IV, Proyectos (43 a 87)—, cada uno con texto,
ejercicios, soluciones, ejemplos con sus pruebas y PDF. El catálogo reúne 103
patrones, y hay diapositivas de los capítulos 1 a 7. El autor revisó los
capítulos 1 a 7; los demás están en revisión.

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
- El Chromium headless que descarga `make browser`: genera los PDF y, con
  Playwright, ejecuta las pruebas de las páginas web del capítulo 36.
- Opcionales:
  - Docker (capítulo 31, la imagen del servicio);
  - `swipl-win` con XPCE (las ventanas del capítulo 36, `make windows`, y las
    herramientas gráficas de los capítulos 16 y 26; viene con la instalación
    de SWI-Prolog en Windows, no con el paquete `swi-prolog-nox` de Linux);
  - una terminal que interprete las secuencias ANSI, para los programas a
    pantalla completa de los capítulos 36, 41 y 44;
  - el controlador ODBC de SQLite, para las pruebas que ejecutan SQL de los
    capítulos 42 y 87: en Linux, `unixodbc`, `libsqliteodbc` y
    `swi-prolog-odbc`; en Windows, el instalador que describe la sección «El
    controlador ODBC en Windows» del capítulo 42. Sin él, esas pruebas quedan
    bloqueadas con un aviso.

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
  patrones.md               los patrones de las partes II a IV (se regenera con make patterns w=1)
  lecturas.md               las lecturas complementarias
  asistente.md              «Preguntar al curso»: qué hace el panel de preguntas y cómo busca
  javascripts/assistant/    el panel de preguntas, que corre en el navegador de quien lee
  vendor/                   KaTeX (fórmulas) y mermaid (diagramas), con sus licencias MIT: el sitio y los PDF no dependen de un CDN
  pdf.md                    el apéndice B: los enlaces a los PDF de cada capítulo
ejemplos/                 los ejemplos, un directorio por capítulo
  capitulo-01/familia.pl    el programa
  capitulo-01/familia.plt   sus pruebas plunit
diapositivas/             las diapositivas de cada capítulo: capitulo-01.md (fuente) y capitulo-01.odp
  imagenes/capitulo-01/     sus ilustraciones; imagenes/CREDITOS.md, las fotografías y sus licencias
tools/                    las herramientas (en inglés)
  assistant/                el panel de preguntas: sus palabras de búsqueda (keywords.json), la herramienta
                            que las prepara y reúne (keywords.py), el hook que escribe el índice del sitio
                            (index_hook.py), la evaluación de la búsqueda y las pruebas del panel (tests/)
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
  SWISH: usa archivos, hilos o motores, una interfaz (la terminal, las
  ventanas de XPCE) o puertos, compila o modifica el programa, define o carga
  módulos propios, carga otro archivo, o necesita ODBC. El texto muestra el
  motivo en lugar del enlace.

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
tabla de los temas que se retoman. Desde el capítulo 32 cada capítulo termina
con sus «Referencias», y el 87 reemplaza la tabla por el cierre del curso.

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

### Generar las diapositivas de un capítulo

```bash
make slides      # diapositivas/capitulo-NN.odp de cada capitulo-NN.md que cambió
make slides-pdf  # además, diapositivas/capitulo-NN.pdf exportado de cada .odp
```

Las diapositivas no repiten el texto del capítulo: llevan lo que es difícil de
escribir en un pizarrón (ilustraciones, código, ejecuciones, recorridos paso a
paso), y la explicación va en las notas del orador. La fuente de cada capítulo,
`diapositivas/capitulo-NN.md`, está escrita en Markdown de Pandoc:

- una diapositiva por cada título `##`; un título `#` inicial es la portada;
- las notas del orador, un bloque `::: notes` por diapositiva, en castellano
  para ser leído en voz alta: sin código ni símbolos de Prolog;
- dos columnas con `:::: columns` y `::: column`;
- las imágenes, sin texto alternativo (`![](imagenes/capitulo-NN/x.svg)`: con
  texto, Pandoc lo pone como epígrafe), en `diapositivas/imagenes/capitulo-NN/`.
  Las ilustraciones son SVG dibujados para el curso; las fotografías se toman
  de Wikimedia Commons, verificando la licencia en su página, y se registran
  en `diapositivas/imagenes/CREDITOS.md` y en la diapositiva «Créditos».

El código sale de `ejemplos/` con los mismos marcadores `<!-- ejemplo: … -->`
del texto, y cada ejecución es una transcripción real: `make check` verifica
unos y otras en las diapositivas igual que en los capítulos, y
`uv run --frozen tools/sync-examples.py --write diapositivas/capitulo-NN.md`
copia el código. El capítulo se toma del nombre del archivo. Un comentario
`<!-- … -->` nunca va entre un título y un bloque `:::: columns`, porque Pandoc
parte ahí la diapositiva en dos: va dentro de la primera columna.

El código se ve en Consolas de 16 puntos: entran 15 líneas, de hasta 70
caracteres a todo el ancho o 35 en una columna. Pandoc genera un `.pptx`
intermedio con los estilos de `diapositivas/plantilla.pptx` (la produce
`tools/slides-template.py` a partir de la plantilla de Pandoc),
`tools/slides-breaks.py` corrige los saltos de línea de los bloques sin
resaltado, y LibreOffice lo convierte en el `.odp` que se versiona. Requiere
Pandoc y LibreOffice; si `soffice` no está en el PATH, se toma de
`C:\Program Files\LibreOffice\program` o de la variable `SOFFICE`. CI no tiene
LibreOffice, y `make check` no genera las diapositivas.

### Generar el video narrado de un capítulo

```bash
make video c=01  # diapositivas/capitulo-01.mp4; sin c=, el de cada capítulo con diapositivas
```

Cada diapositiva del `.odp` se muestra mientras una voz lee sus notas.
`tools/video.py` extrae las notas del propio `.odp`, adapta la notación de
Prolog para la lectura en voz alta (`padre/2` se lee «padre de aridad 2»; `:-`,
«si») y sintetiza la voz con Piper, sin conexión, con la voz argentina
`es_AR-daniela-high`. LibreOffice exporta las diapositivas a imágenes y ffmpeg
arma el video. Cada diapositiva permanece 1,5 s en pantalla antes de que empiece
la voz y 2 s después de que termina, con medio segundo adicional por línea de
código visible y un mínimo de 6 s. Los parámetros están al comienzo de la
herramienta.

Requiere LibreOffice y ffmpeg. La primera vez descarga el modelo de la voz
(unos 110 MB) en `%LOCALAPPDATA%\piper-voices`, o en la carpeta que indique
`PIPER_VOICES`. Los `.mp4` no se versionan, y ni CI ni `make check` los generan.
`uv run tools/video.py diapositivas/capitulo-01.odp --text` muestra el texto que
se envía a la voz, sin generar el video.

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

Después se abre el pull request, con un título en el mismo formato. CI verifica
los capítulos que el cambio puede afectar, y el libro completo cuando cambian
las herramientas (ver «Verificación»); al hacer el merge en `main`, el flujo
PDF y sitio genera todos los PDF, construye el sitio y lo publica en GitHub
Pages. También se puede ejecutar a mano desde la pestaña *Actions* del repositorio
(`workflow_dispatch`).

### Otras tareas

```bash
make pldoc       # regenerar la documentación PlDoc que enlaza el capítulo 14
make sql         # verificar los pares SQL/Prolog del banco de ejercicios
make clean       # borrar site/ y los restos de Python
make clean-pdf   # borrar los PDF generados
```

## Objetivos de make

`make` sin argumentos, o `make help`, lista todos los objetivos. Qué hace cada uno:

| Objetivo | Qué hace |
|---|---|
| **Entorno** | |
| `make install` | Crea `.venv` exactamente desde `uv.lock` e instala los hooks de git (pre-commit, mensaje del commit, nombre de la rama). |
| `make browser` | Descarga el Chromium headless que usan los PDF y las pruebas de páginas web con Playwright. |
| `make vendor` | Descarga de npm las bibliotecas que el sitio sirve por su cuenta, KaTeX y mermaid, en las versiones que fija `tools/vendor.toml`, verifica su integridad y las copia en `docs/vendor/`. Ya están en el repositorio: hace falta solo para cambiar una versión o restaurar los archivos. Requiere red. |
| **Ejemplos y texto** | |
| `make test` | Carga cada `.pl` con su `.plt` y ejecuta sus pruebas plunit; un `Warning:` cuenta como falla. `e=familia` o `e=capitulo-09` limita la corrida. |
| `make swish` | Verifica con `library(sandbox)` que cada ejemplo se puede ejecutar en SWISH, o que declara con `% solo-local:` por qué no. |
| `make sync` | Copia al texto todos los bloques que declaran que vienen de `ejemplos/`. |
| `make transcripts` | Ejecuta cada consulta `?- …` del texto y compara la cantidad de respuestas y el terminador con lo que muestra la página. |
| `make time` | Recalcula las tres cifras de tiempo de cada capítulo y avisa cuáles se apartan de las publicadas; con `-v`, muestra las del modelo. |
| `make math` | Analiza cada fórmula con el mismo KaTeX que carga el sitio, el que está en `docs/vendor/katex-0.16.11/` (los PDF usan esos mismos archivos). |
| `make appendix` | Ejecuta las pruebas de pytest de los capítulos con Python: 29 (Janus), 30 y 31 (los clientes de los servicios) y 36 (las páginas web, con Playwright). |
| `make windows` | Ejecuta las pruebas de las ventanas XPCE del capítulo 36 con `swipl-win`. Solo en la máquina propia: CI no tiene XPCE. |
| `make sql` | Ejecuta los pares de consultas SQL y Prolog del banco (`references/ejercicios/sql-prolog/`) y compara los resultados. |
| **Reglas del curso** | |
| `make part-1` | Verifica que los capítulos 1 a 12 no usan ningún predicado de la parte II. |
| `make part-2` | Verifica que los capítulos 13 a 87 no usan un predicado antes del capítulo que lo presenta (lo declara su tabla «Resumen»). |
| `make shown` | Verifica que cada predicado que consulta una transcripción se muestra en su página, o que la página nombra su archivo. |
| `make links` | Verifica que cada mención de un capítulo, una sección o un patrón en el texto es un enlace. |
| `make patterns` | Verifica que `docs/patrones.md` coincide con los recuadros «Patrón» de los capítulos; `make patterns w=1` lo regenera. |
| **Sitio y PDF** | |
| `make docs` | Construye el sitio en `site/` con `--strict`: una advertencia es un error. No genera los PDF: enlaza solo los que ya existen. |
| `make mermaid` | Construye el sitio y dibuja cada diagrama mermaid en Chromium, como lo ve un lector: falla si un diagrama no se dibuja, sale vacío o muestra `<br/>` o una entidad HTML como texto, y avisa si un rótulo queda cortado, dos nodos se superponen o el diagrama se achica tanto que no se lee. `e=capitulo-05` limita la corrida; `--shots DIR`, por línea de comandos, guarda una imagen de cada diagrama. Usa el mermaid que el sitio incluye en `docs/vendor/`, sin red. |
| `make assistant-test` | Construye el sitio y ejecuta las pruebas del panel «Preguntar al curso»: unitarias, de integración sobre el sitio construido, y e2e con Playwright en un navegador real (el módulo de búsqueda y las especificaciones Gherkin del panel). `m=unit`, `m=integration`, `m=e2e` o `m=bdd` elige un grupo; `b=firefox` cambia de navegador; `k=` filtra por nombre. |
| `make assistant-evaluate` | Mide la búsqueda del panel con un conjunto de preguntas a ciegas (`s=` el directorio con `truth.json` y `out.json`; `k=` otro archivo de palabras de búsqueda): aciertos en el primer lugar y entre los cinco primeros, con y sin palabras de búsqueda. |
| `make docs-serve` | Sirve el sitio en la máquina propia y lo recarga con cada cambio; `DIRECCION=` cambia la dirección. |
| `make pdf` | Genera el PDF de cada capítulo y de sus soluciones, solo los que cambiaron. Se ejecuta antes de `make docs` para un sitio con todos los PDF. |
| `make pldoc` | Regenera las páginas PlDoc de los ejemplos que enlaza el capítulo 14. |
| `make slides` | Genera las diapositivas de cada capítulo (`diapositivas/capitulo-NN.odp`) desde su fuente Markdown. Requiere Pandoc y LibreOffice; no forma parte de `make check`. |
| `make slides-pdf` | Exporta cada juego de diapositivas a PDF (`diapositivas/capitulo-NN.pdf`), después de regenerar el `.odp` si hace falta. |
| `make slides-check` | Verifica que el `.odp` y el `.pdf` de cada mazo coincidan con su fuente (las mismas diapositivas, con los mismos títulos, y una página por diapositiva) y que sus transcripciones coincidan con SWI-Prolog. No requiere Pandoc ni LibreOffice. |
| `make video` | Genera el video narrado de las diapositivas de cada capítulo (`c=01`: uno solo). Requiere LibreOffice y ffmpeg; no forma parte de `make check`. |
| **Python** | |
| `make lint` | Ejecuta ruff (reglas y formato) sobre todo el Python del repositorio, sin modificar nada. |
| `make format` | Aplica el formato de ruff y las correcciones que ruff hace solo. |
| `make types` | Verifica los tipos de las herramientas del panel de preguntas (`tools/assistant/`) con pyright y pyrefly. |
| **Conjunto y limpieza** | |
| `make check` | Todo lo que tiene que estar verde antes de un commit (detalle en «Verificación»). |
| `make vendor-check` | Verifica, sin red, que `docs/vendor/` coincide con `tools/vendor.toml` y `tools/vendor.lock.json` y que `mkdocs.yml` carga esas versiones. Forma parte de `make check`. |
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
| `make vendor-check` | `docs/vendor/` coincide con lo que fijan `tools/vendor.toml` y `tools/vendor.lock.json`, y `mkdocs.yml` carga esas versiones (sin red) |
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

`make check` no incluye `make lint`, `make types`, `make appendix`,
`make assistant-test` ni `make windows`: se ejecutan aparte, cuando se tocó
Python, el panel de preguntas, un capítulo con Python o las ventanas.
Los PDF no se versionan: CI los regenera y los publica junto con el sitio.

La integración continua se divide en cuatro flujos, cada uno con su insignia
al comienzo de este archivo. Los cuatro corren en cada pull request y en
`main`, con SWI-Prolog 9 y el pack `reif`; la publicación en GitHub Pages se
realiza solo desde `main`.

Ejemplos y la construcción de los PDF de un pull request verifican solo los
capítulos que un cambio puede afectar. `tools/ci-parts.py` asigna cada archivo
modificado a su capítulo y agrega los capítulos cuyos ejemplos o páginas cargan
archivos de uno modificado; esas dependencias se leen de las fuentes en cada
ejecución. Un cambio en `tools/` (salvo `tools/assistant/`, que solo leen la
construcción del sitio y las pruebas del panel), `.github/`, el `Makefile`,
`pyproject.toml`, `uv.lock` o `ruff.toml` selecciona todos los capítulos, y uno que no pertenece a
ningún capítulo (`docs/licencia.md`, `mkdocs.yml`, este archivo) no selecciona
ninguno. Ejemplos corre un trabajo por parte del libro, en paralelo, y el
trabajo `resultado` resume todos en una sola verificación. Los lunes, y a mano
desde la pestaña *Actions*, Ejemplos verifica el libro completo.

```bash
uv run tools/ci-parts.py --files ejemplos/capitulo-42/base.pl   # qué se verificaría
make pdf e="capitulo-05 capitulo-07"                            # los PDF de dos capítulos
```

| Flujo | Qué verifica |
|---|---|
| **Ejemplos** | `make test`, `make transcripts` y `make swish` de los capítulos seleccionados, un trabajo por parte; `make appendix` cuando se selecciona el capítulo 29, 30, 31 o 36; `make lint` siempre |
| **Texto** | `make part-1`, `check-part-2 --strict`, `make shown`, `make links`, `make patterns`, `make math`, `make time`, la comparación de bloques, `make docs` y el dibujo de cada diagrama mermaid (`tools/check-mermaid.py`) |
| **PDF y sitio** | `make pdf` y el sitio, con los PDF de cada capítulo y las diapositivas, y las pruebas del panel «Preguntar al curso» (`tools/assistant`); en un pull request, solo los PDF de los capítulos seleccionados; en `main`, todos y la publicación |
| **Diapositivas** | `make slides-check`; solo cuando cambia algo de lo que dependen los mazos |

## Flujo de trabajo con git

Los hooks instalados por `make install` impiden los commits directos en `main`,
exigen mensajes con formato Conventional Commits y, al hacer push, verifican que
la rama se llame `<tipo>/<descripcion>` con los mismos tipos (`docs`, `feat`,
`fix`…). El título del pull request debe respetar el mismo formato, porque en un
squash merge se convierte en el mensaje del commit.
