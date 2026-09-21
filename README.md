# Curso de Prolog

Un curso de SWI-Prolog en castellano, autoguiado, para estudiantes de segundo
año que nunca vieron Prolog. Se publica como libro web con MkDocs en
**https://katra.ballardini.com.ar/curso-de-prolog/**, con un PDF por capítulo.

**Todos los ejemplos se abren y se corren en el navegador**: cada bloque de
código del texto viene de un archivo de `ejemplos/`, tiene sus pruebas plunit, y
lleva debajo un enlace «▶ Abrir en SWISH» que arrastra el fuente completo dentro
de la URL. No hay nada que instalar para seguir el curso, y nada que hostear
para que los ejemplos anden.

El libro es MIT. Los libros, cursos y colecciones de ejercicios que se citan
mantienen su licencia: se los enlaza y se los cita, nunca se los copia.

## Estado

En construcción. Está la infraestructura y el esqueleto de los 34 capítulos más
el apéndice; el contenido se escribe por hitos.

## Qué hace falta

- [uv](https://docs.astral.sh/uv/) con Python 3.14. Todo el herramental de
  Python vive en `.venv` y se declara en `pyproject.toml`: no hay nada instalado
  globalmente.
- [SWI-Prolog](https://www.swi-prolog.org/) 9 o posterior, con `swipl` en el
  PATH. Es lo que carga los ejemplos, corre sus pruebas y le pregunta al sandbox
  de SWISH.
- GNU make.

```bash
make install     # arma .venv desde uv.lock e instala los hooks de git
make browser     # el Chromium headless que necesitan los PDF
make             # lista todo lo que se puede hacer
```

## Cómo está armado

```text
docs/                     el libro; un directorio por capítulo, con su index.md
ejemplos/                 los ejemplos, un directorio por capítulo
  capitulo-01/familia.pl    el programa
  capitulo-01/familia.plt   sus pruebas plunit
tools/                    el herramental (en inglés)
references/               material de consulta: cursos, banco de ejercicios
books/                    las conversiones a Markdown de los libros fuente
```

### Un ejemplo

Cada ejemplo es un `.pl` con su `.plt` al lado. La cabecera del `.pl` declara lo
que el libro necesita saber:

```prolog
:- encoding(utf8).

% Capítulo 1 - Hechos y reglas.
% Un árbol genealógico mínimo.
%?- abuelo(juan, Quien).

padre(juan, ana).
```

- `:- encoding(utf8).` va siempre: el SWI-Prolog local de Windows lee los
  fuentes en la codificación del sistema, y sin esa línea un átomo con acento es
  un error de sintaxis que voltea el archivo entero.
- `%?- <consulta>` es una consulta del ejemplo. La primera abre el enlace a
  SWISH; todas se verifican contra el sandbox.
- `% solo-local: <motivo>` marca el ejemplo que no puede correr en SWISH
  (archivos, hilos, interfaz, compilación). El texto muestra el motivo en vez
  del enlace.

### Un bloque de código del texto

El texto no repite el código a mano: lo declara, y `make sync` lo copia.

````markdown
<!-- ejemplo: capitulo-01/familia.pl predicado: abuelo/2 -->
```prolog
```
````

La marca pide un pedazo del archivo: `archivo` entero, `predicado: padre/2`
(todas sus cláusulas, con sus comentarios) o `fragmento: A .. B`.

## Verificación

`make check` es lo que tiene que estar verde antes de un commit, y es lo que
corre CI en cada pull request:

| | |
|---|---|
| `make part-1` | los capítulos 1 a 11 no usan nada de la parte II (sin `findall`, `maplist`, `assertz`…) |
| `make test` | cada ejemplo carga con su `.plt` y pasa sus pruebas plunit |
| `make swish` | cada ejemplo pasa el sandbox de SWISH, o declara por qué no puede |
| `make sync` | el texto coincide con los archivos de `ejemplos/` |
| `make docs` | el sitio construye con `--strict`: un aviso es un error |
| `make lint` | ruff sobre el herramental |

`make pdf` arma el PDF de cada capítulo. Los PDF no se versionan: los rehace CI
y salen publicados con el sitio.
