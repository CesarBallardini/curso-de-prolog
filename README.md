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

**La parte I (capítulos 1 a 11) está completa**: texto, ejercicios, soluciones,
ejemplos con sus pruebas y PDF de cada capítulo. Se puede usar en el dictado.

Las partes II y III, el capítulo 34 y el apéndice A están en preparación: tienen
la estructura de directorios y una página inicial por capítulo, sin contenido.
El contenido se escribe por hitos, según `2026-09-18-plan-guide-prolog.md`.

## Requisitos

- [uv](https://docs.astral.sh/uv/) con Python 3.14. Todas las herramientas de
  Python residen en `.venv` y se declaran en `pyproject.toml`: no se instala
  nada de manera global.
- [SWI-Prolog](https://www.swi-prolog.org/) 9 o posterior, con `swipl` en el
  PATH. Se usa para cargar los ejemplos, ejecutar sus pruebas y consultar el
  sandbox de SWISH.
- GNU make. En Windows, los comandos se ejecutan desde Git Bash.

```bash
make install     # construye .venv desde uv.lock e instala los hooks de git
make browser     # descarga el Chromium headless que requieren los PDF
make             # lista todos los objetivos disponibles
```

## Organización del repositorio

```text
docs/                     el curso; un directorio por capítulo, con index.md y soluciones.md
  plantillas.md             las formas de programa que se repiten, reunidas
ejemplos/                 los ejemplos, un directorio por capítulo
  capitulo-01/familia.pl    el programa
  capitulo-01/familia.plt   sus pruebas plunit
tools/                    las herramientas (en inglés)
references/               material de consulta: cursos, banco de ejercicios
books/                    las conversiones a Markdown de los libros fuente
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

## Verificación

`make check` debe terminar sin errores antes de cada commit. Ejecuta, en este
orden:

| | |
|---|---|
| `make part-1` | los capítulos 1 a 11 no usan ningún predicado de la parte II (`findall`, `maplist`, `assertz`…) |
| `make test` | cada ejemplo se carga con su `.plt` y pasa sus pruebas plunit; un `Warning:` también es una falla |
| `make swish` | cada ejemplo es aceptado por el sandbox de SWISH, o declara por qué no puede serlo |
| `make transcripts` | cada consulta `?- …` del texto se ejecuta y se comparan la cantidad de respuestas y el terminador |
| `make math` | cada fórmula se parsea con el mismo KaTeX que carga el sitio |
| `make time` | las tres cifras de tiempo de cada capítulo se recalculan y se comparan con las publicadas |
| comparación de bloques | el texto coincide con los archivos de `ejemplos/` (sin modificar nada) |
| `make docs` | el sitio se construye con `--strict`: una advertencia es un error |

`make test`, `make swish`, `make transcripts`, `make math` y `make time`
aceptan `e=` para limitarse a un ejemplo o a un capítulo:

```bash
make test e=familia        # un ejemplo, por nombre de archivo
make test e=capitulo-09    # un capítulo completo
make transcripts e=capitulo-07
```

`make lint` ejecuta ruff sobre todos los archivos Python del repositorio, sin
exclusiones. `make pdf` genera el PDF de cada capítulo. Los PDF no se versionan:
CI los regenera y los publica junto con el sitio.

En cada pull request, CI ejecuta `make pdf`, `make check` y `make lint`; la
publicación en GitHub Pages se realiza solo desde `main`.

## Flujo de trabajo con git

Los hooks instalados por `make install` impiden los commits directos en `main`,
exigen mensajes con formato Conventional Commits y, al hacer push, verifican que
la rama se llame `<tipo>/<descripcion>` con los mismos tipos (`docs`, `feat`,
`fix`…). El título del pull request debe respetar el mismo formato, porque en un
squash merge se convierte en el mensaje del commit.
