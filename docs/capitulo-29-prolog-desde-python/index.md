# Capítulo 29 — Prolog desde Python

Un programa grande rara vez está escrito en un solo lenguaje. Las reglas de
inscripción, las correlatividades y los informes del proyecto se expresan bien
en Prolog; una aplicación de escritorio, un análisis de datos o un servicio
que ya existe suelen estar escritos en Python. Este capítulo conecta los dos:
un programa de Python carga las reglas de Prolog, las consulta y recibe las
respuestas como datos de Python.

La biblioteca es **Janus**, el puente oficial entre SWI-Prolog y Python,
mantenido por el equipo de SWI-Prolog. Funciona en las dos direcciones: Python
consulta a Prolog, y Prolog llama a funciones de Python. El capítulo presenta
la instalación, las consultas, la forma en que cruzan los datos y los errores,
y las pruebas de los dos lados. El proyecto recibe un informe escrito en
Python sobre las reglas del proyecto.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- instalar Janus y cargar un programa de Prolog desde Python;
- hacer consultas con una respuesta, con todas, y con valores de entrada
  pasados como ligaduras;
- predecir cómo cruzan los datos entre los dos lenguajes, y preparar en
  Prolog los que no cruzan solos;
- convertir las fallas y los errores de Prolog en excepciones de Python;
- probar las reglas con plunit y el programa de Python con pytest, en un solo
  comando;
- llamar a funciones de Python desde Prolog.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:13 h**.
    Resolver los 6 ejercicios marcados con ★: **1:53 h**.
    Resolver los 13 ejercicios del final: **3:35 h**.

## 29.1 Por qué

Conviene dejar una parte de un programa de Python en Prolog cuando esa parte
es un conjunto de reglas: condiciones de una beca, correlatividades,
permisos, validaciones de una configuración. Las reglas cambian con más
frecuencia que el resto del programa, y en Prolog se leen como se enuncian. También
cuando una consulta tiene varias respuestas —todos los alumnos que pueden
inscribirse—, o cuando el problema es una búsqueda: un horario, un
rompecabezas, un camino.

Lo demás queda en Python: la interfaz, los archivos, las bibliotecas de
análisis de datos. La frontera entre los dos es estrecha: unas pocas
consultas, con datos simples de ida y de vuelta. La mayor parte de este
capítulo trata de esa frontera.

## 29.2 Instalación

Janus tiene dos partes. La de Prolog, `library(janus)`, viene con SWI-Prolog
9. La de Python es el paquete `janus-swi`, que se instala en el entorno de
Python:

```text
$ uv add janus-swi
```

o con `pip install janus-swi`. El paquete se compila contra el SWI-Prolog
instalado, que tiene que estar en el `PATH`; la versión de Janus y la de
SWI-Prolog deben ser compatibles, y conviene instalar las dos juntas. En
Windows, además, Janus necesita la variable de entorno `SWI_HOME_DIR` con el
directorio de SWI-Prolog, como `C:/Program Files/swipl`: sin ella, el Prolog
que Janus inicia no encuentra sus archivos y se detiene con el mensaje
`Could not find system resources`.

En el curso, Janus está en el grupo de dependencias `apendice-a`, y los
ejemplos del capítulo se ejecutan con `make appendix`, que usa pytest.
`conftest.py`, el archivo de configuración de pytest del capítulo, define
`SWI_HOME_DIR` si falta, tomándolo de la salida de
`swipl --dump-runtime-variables`:

<!-- ejemplo: capitulo-29/conftest.py fragmento: def _directorio_de_swipl .. os.environ['SWI_HOME_DIR'] = directorio -->
```python
def _directorio_de_swipl():
    """Devuelve el directorio de SWI-Prolog, o None si swipl no está en el PATH."""
    swipl = shutil.which('swipl')
    if swipl is None:
        return None
    variables = [swipl, '--dump-runtime-variables']
    hecho = subprocess.run(variables, capture_output=True, text=True, check=True)  # noqa: S603
    salida = hecho.stdout
    encontrado = re.search(r'^PLBASE="(.*)";', salida, re.M)
    return encontrado.group(1) if encontrado else None


if 'SWI_HOME_DIR' not in os.environ and (directorio := _directorio_de_swipl()):
    os.environ['SWI_HOME_DIR'] = directorio
```

## 29.3 Cargar

`import janus_swi as janus` inicia un Prolog dentro del proceso de Python,
uno solo por proceso. `janus.consult/1` le carga un archivo, como
`consult/1` desde el toplevel:

<!-- ejemplo: capitulo-29/consultas.py fragmento: from pathlib import Path .. janus.consult(str(AQUI / 'familia.pl')) -->
```python
from pathlib import Path

import janus_swi as janus

AQUI = Path(__file__).parent


def cargar():
    """Carga familia.pl en el Prolog del proceso."""
    janus.consult(str(AQUI / 'familia.pl'))
```

`familia.pl` es un programa de Prolog común, con sus pruebas de plunit:

<!-- ejemplo: capitulo-29/familia.pl predicado: abuelo/2 edad_de/2 ficha/2 consulta: ficha(ana, Ficha). -->
```prolog
%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
abuelo(A, N) :-
    padre(A, P),
    padre(P, N).

%!  edad_de(+Persona:atom, -Anios:integer) is semidet.
%
%   Anios es la edad de Persona. Falla si no se conoce.
%
%   @error type_error(atom, Persona) si Persona no es un átomo.
edad_de(Persona, Anios) :-
    must_be(atom, Persona),
    edad(Persona, Anios).

%!  ficha(+Persona:atom, -Ficha:dict) is semidet.
%
%   Ficha es un dict con el nombre, la edad y la lista de hijos de Persona.
%   Falla si no se conoce su edad.
ficha(Persona, _{nombre: Persona, edad: Anios, hijos: Hijos}) :-
    edad_de(Persona, Anios),
    findall(H, padre(Persona, H), Hijos).
```

`janus.consult('nombre', texto)`, con dos argumentos, carga el texto como si
fuera el archivo `nombre`; sirve para reglas cortas, o armadas por el propio
programa de Python. Volver a cargar el mismo archivo reemplaza sus
cláusulas, como en el toplevel. Como hay un solo Prolog por proceso, todo lo
que se carga comparte la base de datos: dos archivos que definen el mismo
predicado se superponen.

## 29.4 Consultar

`janus.query_once(consulta, entrada)` hace una consulta y devuelve su primera
respuesta, como un diccionario: la clave `truth` dice si la consulta se
cumplió, y cada variable de la consulta es otra clave, con su valor.
`janus.query(consulta, entrada)` devuelve un iterador de todas las respuestas:

<!-- ejemplo: capitulo-29/consultas.py fragmento: def es_abuelo .. return respuesta['N'] if respuesta['truth'] else None -->
```python
def es_abuelo(abuelo, nieto):
    """Devuelve True si abuelo es abuelo de nieto."""
    return janus.query_once('abuelo(A, N)', {'A': abuelo, 'N': nieto})['truth']


def nietos_de(abuelo):
    """Devuelve la lista de los nietos de abuelo, en el orden de las respuestas."""
    return [respuesta['N'] for respuesta in janus.query('abuelo(A, N)', {'A': abuelo})]


def primer_nieto(abuelo):
    """Devuelve el primer nieto de abuelo, o None si no tiene."""
    respuesta = janus.query_once('abuelo(A, N)', {'A': abuelo})
    return respuesta['N'] if respuesta['truth'] else None
```

```python
consultas.es_abuelo('juan', 'luis')  # True
consultas.nietos_de('juan')  # ['luis', 'eva']
consultas.primer_nieto('eva')  # None
```

Son las mismas respuestas que da el toplevel:

```prolog
?- abuelo(juan, N).
N = luis ;
N = eva ;
false.
```

El segundo argumento, `entrada`, es un diccionario de **ligaduras**: las
variables de la consulta que ya tienen valor antes de empezar. Los valores de
entrada se pasan siempre así, y nunca se pegan en el texto de la consulta.
`edad_armando_el_texto/1` muestra por qué:

<!-- ejemplo: capitulo-29/consultas.py fragmento: def edad_armando_el_texto .. return janus.query_once(f'edad_de({persona}, E)') -->
```python
def edad_armando_el_texto(persona):
    """Consulta la edad pegando el nombre en el texto: la forma que no se debe usar."""
    return janus.query_once(f'edad_de({persona}, E)')
```

Con `'ana'` funciona. Con `'Ana'`, el texto de la consulta es
`edad_de(Ana, E)`, y `Ana` es una variable de Prolog: `must_be/2` produce un
error de instanciación. Con un nombre que contiene una coma o un paréntesis,
la consulta ni siquiera se lee. Como ligadura, en cambio, `'Ana'` llega a
Prolog como el átomo `'Ana'`, sea cual sea su texto, y la consulta
`edad_de(P, E)` no cambia.

`janus.apply_once(modulo, predicado, *entradas)` llama a un predicado con los
argumentos de entrada, y devuelve el valor del último, que queda libre:
`janus.apply_once('user', 'edad_de', 'ana')` da `41`. Si el predicado falla,
lanza una excepción, salvo que se le dé un valor para ese caso con
`fail=`. `janus.apply(…)` es el iterador de todas las respuestas.

## 29.5 Cómo cruzan los datos

Cada valor se convierte al cruzar, según su tipo:

| Prolog | Python |
|---|---|
| entero, incluso los grandes | `int` |
| número de punto flotante | `float` |
| átomo | `str` |
| cadena | `str` |
| lista | `list` |
| par `A-B` | tupla `(A, B)` |
| dict | `dict` |
| `@(true)`, `@(false)`, `@(none)` | `True`, `False`, `None` |
| `prolog(T)`, cualquier término | un objeto `janus.Term` |
| otro término compuesto | error: `py_term` esperado |
| variable libre en la respuesta | error de instanciación |

Hacia Prolog, un `str` de Python llega como **átomo**, no como cadena:
`janus.query_once('atom(S)', {'S': 'hola'})` se cumple. Un término compuesto
como `f(x)` o `rechazada(falta(am1))` no tiene un equivalente en Python, y la
consulta que lo devuelve produce un error. Hay dos formas de resolverlo, las
dos del lado de Prolog: convertirlo en un dato que cruce —un dict, una lista,
un texto—, o envolverlo en `prolog/1`. Un término envuelto llega a Python
como un objeto `janus.Term`, cuyo contenido Python no examina, pero que
puede guardar y devolver a Prolog, donde vuelve a ser el término original:

```python
termino = janus.query_once('X = prolog(f(x, [a]))')['X']
str(termino)  # 'f(x,[a])'
janus.query_once('T = f(x, L)', {'T': termino})['L']  # ['a']
```

Las variables cuyo nombre empieza con `_` no forman parte de la respuesta,
como en el toplevel: sirven para valores intermedios que no deben cruzar. El
dict de `ficha/2` cruza completo:

```prolog
?- ficha(ana, F).
F = _{edad:41, hijos:[luis, eva], nombre:ana}.
```

```python
consultas.ficha('ana')  # {'nombre': 'ana', 'edad': 41, 'hijos': ['luis', 'eva']}
```

!!! question "Actividad"
    Consultar desde Python `X = [hola, "hola", 3, 2.5, a-1, _{a: 1}]` y
    examinar el tipo de cada elemento de la respuesta. Consultar después
    `X = f(x)`, `X = f(_)` y `X = _`. ¿Qué error produce cada una, y qué
    cambio en la consulta evita el error?

## 29.6 Errores

Una consulta que falla y una que produce un error llegan a Python de forma
distinta. La que falla devuelve `truth` en `False`, con `None` en cada
variable de la consulta; la que produce un error lanza la excepción
`janus.PrologError`, cuyo atributo `term` es el término de
error de Prolog, como un `janus.Term`, y cuyo texto es el mensaje:

```python
janus.query_once('X is 1/0')
# janus.PrologError: //2: Arithmetic: evaluation error: `zero_divisor'
```

El resto del programa de Python no debería depender de ninguna de las dos
formas. `edad/1` las convierte en excepciones propias de Python: la falla, en
`PersonaDesconocidaError`; el error de tipo, en `TypeError`:

<!-- ejemplo: capitulo-29/consultas.py fragmento: class PersonaDesconocidaError .. return respuesta['E'] -->
```python
class PersonaDesconocidaError(LookupError):
    """La persona no está en la base de familia.pl."""


def edad(persona):
    """Devuelve la edad de persona.

    Una falla de Prolog se convierte en PersonaDesconocidaError, y un error de tipo
    de Prolog, en TypeError de Python.
    """
    try:
        respuesta = janus.query_once('edad_de(P, E)', {'P': persona})
    except janus.PrologError as error:
        raise TypeError(str(error)) from error
    if not respuesta['truth']:
        raise PersonaDesconocidaError(persona)
    return respuesta['E']
```

Quien llama a `edad/1` usa `try` y `except` como con cualquier otra función
de Python, y no necesita saber que la respuesta viene de Prolog. Es la misma
idea del [Patrón 37](../patrones.md#37-convertir-en-el-borde), aplicada a la frontera entre dos lenguajes:

!!! example "Patrón 39 — Frontera Python–Prolog"
    **Problema.** Un programa de Python usa reglas de Prolog. Los datos que
    cruzan no siempre tienen equivalente del otro lado, y las fallas y los
    errores de Prolog no son excepciones de Python.

    **Versión ingenua.** Hacer consultas con Janus desde cualquier lugar del
    programa de Python, armar el texto de las consultas con los valores de
    entrada, y examinar `truth` y `PrologError` en cada llamada.

    **Patrón.** Un solo módulo de Python usa Janus, y un solo módulo de Prolog
    le responde. El de Prolog convierte las respuestas en datos que cruzan
    —dicts con claves fijas, listas, textos— y envuelve en `prolog/1` lo que
    Python solo guarda. El de Python pasa los valores como ligaduras,
    convierte las fallas y los errores en excepciones propias, y ofrece
    funciones comunes al resto del programa.

    **Cuándo no usarlo.** En un script de pocas líneas que hace una sola
    consulta: la frontera sería más larga que el script.

## 29.7 Pruebas de los dos lados

Las reglas de Prolog se prueban con plunit, como en todo el curso:
`familia.plt` acompaña a `familia.pl`. El programa de Python se prueba con
pytest, que es a Python lo que plunit a Prolog: una función `test_…` por
prueba, con `assert` para las condiciones y `pytest.raises` para las
excepciones:

<!-- ejemplo: capitulo-29/test_consultas.py fragmento: def test_persona_desconocida .. consultas.edad_armando_el_texto('Ana') -->
```python
def test_persona_desconocida():
    with pytest.raises(consultas.PersonaDesconocidaError):
        consultas.edad('zoe')


def test_error_de_tipo():
    with pytest.raises(TypeError, match='atom'):
        consultas.edad(3)


def test_texto_armado_con_mayuscula():
    # 'Ana' pegado en el texto es una variable de Prolog, no un átomo.
    with pytest.raises(janus.PrologError, match='not sufficiently instantiated'):
        consultas.edad_armando_el_texto('Ana')
```

Para que un solo comando ejecute las dos baterías, `test_plunit.py` hace que
pytest ejecute también las pruebas de plunit: por cada archivo `.pl` del
capítulo con su `.plt`, un proceso de `swipl` carga los dos y ejecuta
`run_tests`, y la prueba de pytest falla si plunit informa un error:

<!-- ejemplo: capitulo-29/test_plunit.py fragmento: @pytest.mark.parametrize .. assert not PROBLEMA.search(salida), salida -->
```python
@pytest.mark.parametrize('programa', EJEMPLOS, ids=lambda p: p.relative_to(AQUI).as_posix())
def test_plunit(programa):
    swipl = shutil.which('swipl')
    assert swipl is not None, 'swipl no está en el PATH'
    archivos = f"'{programa.as_posix()}', '{programa.with_suffix('.plt').as_posix()}'"
    hecho = subprocess.run(  # noqa: S603
        [swipl, '-g', f'consult([{archivos}]), run_tests, halt', '-t', 'halt'],
        capture_output=True,
        text=True,
        errors='replace',
        timeout=120,
        check=False,
    )
    salida = hecho.stdout + hecho.stderr
    assert hecho.returncode == 0, salida
    assert not PROBLEMA.search(salida), salida
```

`make appendix` ejecuta pytest sobre el directorio del capítulo, con los
ejemplos y las soluciones: 63 pruebas, trece de ellas baterías completas de
plunit.

## 29.8 Python desde Prolog

La otra dirección es `py_call/2`, de `library(janus)`: llama a una función de
Python y convierte el resultado a Prolog, con las mismas reglas de la
[sección 29.5](#295-como-cruzan-los-datos) al revés:

<!-- ejemplo: capitulo-29/desde_prolog.pl predicado: raiz/2 mediana/2 palabras_frecuentes/3 consulta: raiz(16, R). -->
```prolog
%!  raiz(+X:number, -R:float) is det.
%
%   R es la raíz cuadrada de X, calculada con el módulo math de Python.
raiz(X, R) :-
    py_call(math:sqrt(X), R).

%!  mediana(+Numeros:list(number), -Mediana:number) is det.
%
%   Mediana es la mediana de Numeros, calculada con el módulo statistics de
%   Python.
mediana(Numeros, Mediana) :-
    py_call(statistics:median(Numeros), Mediana).

%!  palabras_frecuentes(+Texto:string, +N:integer, -Pares:list(pair)) is det.
%
%   Pares son las N palabras más frecuentes de Texto, como pares
%   Palabra-Cantidad, contadas con collections.Counter de Python. La opción
%   py_object(true) conserva el contador como objeto de Python, en lugar de
%   convertirlo en un dict; las tuplas de dos elementos que devuelve
%   most_common() llegan como pares.
palabras_frecuentes(Texto, N, Pares) :-
    split_string(Texto, " ", " ", Palabras),
    py_call(collections:'Counter'(Palabras), Contador, [py_object(true)]),
    py_call(Contador:most_common(N), Pares).
```

`Modulo:Funcion(Argumentos)` importa el módulo de Python si hace falta y
llama a la función. Un objeto de Python que no tiene equivalente en Prolog
llega como una referencia; la opción `py_object(true)` pide la referencia
aunque el objeto se pueda convertir, como el `Counter` de
`palabras_frecuentes/3`, que de otro modo llegaría convertido en un dict. Los
argumentos con nombre se escriben `Nombre=Valor`:
`py_call(textwrap:wrap(Texto, width=9), Lineas)`. Una excepción de Python
llega a Prolog como el error `python_error(Clase, Objeto)`: la raíz de −1 es
`error(python_error('ValueError', _), _)`. `raiz/2` es solo un ejemplo del
cruce: Prolog tiene su propia raíz cuadrada, la función aritmética `sqrt/1`,
que `is/2` evalúa: `R is sqrt(16)` liga `R` a `4.0`.

Cuando Prolog se ejecuta dentro de Python, `py_call/2` usa ese mismo Python.
Cuando se ejecuta `swipl` solo, `library(janus)` tiene que encontrar la
biblioteca de Python: en Linux la encuentra si Python está instalado; en
Windows, el directorio de la instalación de Python tiene que estar en el
`PATH`, o la carga falla con `source_sink path('python3.dll') does not
exist`. Las pruebas de `desde_prolog.pl` se ejecutan dentro de pytest, por
eso, y no en un proceso de `swipl`.

!!! question "Actividad"
    Ejecutar `py_call(math:sqrt(2), X)` en el toplevel de `swipl`, sin
    Python de por medio. ¿Qué responde en la máquina propia? Si la carga de
    `library(janus)` falla, agregar al `PATH` el directorio de la instalación
    de Python y repetir la consulta en una terminal nueva.

## 29.9 Otras bibliotecas, en una nota

Hay otras formas de usar lógica desde Python. **pyswip** es un envoltorio
anterior a Janus, que solo consulta a Prolog desde Python. **kanren** y
**minikanren** implementan miniKanren, un lenguaje de programación lógica
distinto de Prolog, escrito en Python: no necesitan SWI-Prolog, pero no
ejecutan programas de Prolog. **pyDatalog** implementa Datalog, un
subconjunto de Prolog sin términos compuestos, también en Python. Para usar
programas de Prolog, como los de este curso, Janus es la opción: es la
oficial, admite todos los tipos de SWI-Prolog y funciona en las dos
direcciones.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C5 | las fallas y los errores de Prolog llegan a Python como excepciones propias —`PersonaDesconocidaError`, `InscripcionRechazadaError`, `DatoInvalidoError`— y las pruebas de pytest verifican cada una con `pytest.raises` |
    | C7 | las dos baterías se ejecutan con un comando: pytest ejecuta sus pruebas y las de plunit de cada archivo de Prolog del capítulo, 63 en total |

## 29.10 El proyecto: un informe en Python

*Inscripciones* recibe un programa de Python: `informes.py` escribe el
ranking y la cantidad de inscriptos por materia, con las reglas de Prolog y
el formato de Python:

```text
$ uv run --group apendice-a python ejemplos/capitulo-29/informes.py
Ranking

 1. ana         101   8.50
 2. diego       104   8.00
 3. carla       103   6.00
 4. facundo     106   4.50
 5. bruno       102   4.00

Inscriptos por materia

am1  analisis_1         5
alg  algebra            4
…
bd   bases_de_datos     0
```

La frontera sigue el [Patrón 39](../patrones.md#39-frontera-pythonprolog). Del lado de Prolog, el módulo nuevo `puente`
convierte las respuestas del programa en datos que cruzan:

<!-- ejemplo: capitulo-29/inscripciones/puente.pl predicado: ranking_py/1 fila_del_ranking/2 inscribir_py/3 resultado_py/2 consulta: ranking_py(Filas). -->
```prolog
%!  ranking_py(-Filas:list(dict)) is det.
%
%   Filas es el ranking, de mayor a menor promedio: un dict por alumno, con
%   las claves legajo, nombre y promedio.
ranking_py(Filas) :-
    ranking(Ranking),
    maplist(fila_del_ranking, Ranking, Filas).

%!  fila_del_ranking(+Par:pair, -Fila:dict) is det.
%
%   Fila es el dict del par Legajo-Promedio del ranking.
fila_del_ranking(Legajo-Promedio,
                 _{legajo: Legajo, nombre: Nombre, promedio: Promedio}) :-
    alumno(Legajo, Nombre, _, _).

%!  inscribir_py(+Legajo:integer, +Materia:atom, -Resultado:dict) is det.
%
%   Inscribe al alumno Legajo en Materia, como inscribir/3. Resultado es
%   _{aceptada: true} o _{aceptada: false, motivo: Texto}; true y false se
%   escriben @(true) y @(false), que Janus convierte en los booleanos de
%   Python.
inscribir_py(Legajo, Materia, Resultado) :-
    inscribir(Legajo, Materia, Respuesta),
    resultado_py(Respuesta, Resultado).

%!  resultado_py(+Respuesta, -Resultado:dict) is det.
%
%   Resultado es el dict de una respuesta de inscribir/3.
resultado_py(aceptada, _{aceptada: @(true)}).
resultado_py(rechazada(Motivo), _{aceptada: @(false), motivo: Texto}) :-
    term_string(Motivo, Texto).
```

```prolog
?- inscribir_py(105, log, R).
R = _{aceptada: @(false), motivo:"sin_vacantes"}.
```

Del lado de Python, `inscripciones_py.py` es el único módulo que usa Janus:

<!-- ejemplo: capitulo-29/inscripciones_py.py fragmento: class InscripcionRechazadaError .. raise InscripcionRechazadaError(legajo, materia, resultado['motivo']) -->
```python
class InscripcionRechazadaError(Exception):
    """Las reglas no permiten la inscripción; motivo dice por qué."""

    def __init__(self, legajo, materia, motivo):
        """Guarda el pedido y el motivo del rechazo."""
        super().__init__(f'{legajo} en {materia}: {motivo}')
        self.motivo = motivo


class DatoInvalidoError(ValueError):
    """Un dato no tiene el tipo que esperan las reglas de Prolog."""


def cargar():
    """Carga el programa de Prolog en el proceso."""
    janus.consult(str(PROGRAMA))


def _consultar(consulta, entrada=None):
    """Hace una consulta; un error de Prolog se convierte en DatoInvalidoError."""
    try:
        return janus.query_once(consulta, entrada or {})
    except janus.PrologError as error:
        raise DatoInvalidoError(str(error)) from error


def ranking():
    """Devuelve el ranking: una lista de diccionarios con legajo, nombre y promedio."""
    return _consultar('ranking_py(R)')['R']


def materias():
    """Devuelve las materias: diccionarios con codigo, nombre, anio e inscriptos."""
    return _consultar('materias_py(M)')['M']


def inscribir(legajo, materia):
    """Inscribe al alumno legajo en materia, o lanza InscripcionRechazadaError."""
    resultado = _consultar('inscribir_py(L, M, R)', {'L': legajo, 'M': materia})['R']
    if not resultado['aceptada']:
        raise InscripcionRechazadaError(legajo, materia, resultado['motivo'])
```

`informes.py` solo llama a `ranking()` y a `materias()`, y no depende de
Prolog. Las pruebas que inscriben guardan el estado antes y lo restauran
después, con `estado()` y `restaurar()`: el estado cruza envuelto en
`prolog/1`, y Python lo devuelve sin examinarlo:

<!-- ejemplo: capitulo-29/test_inscripciones.py fragmento: @pytest.fixture .. assert rechazo.value.motivo == 'sin_vacantes' -->
```python
@pytest.fixture
def estado_intacto():
    """Guarda el estado del programa de Prolog y lo restaura al terminar la prueba."""
    guardado = inscripciones.estado()
    yield
    inscripciones.restaurar(guardado)


def test_ranking():
    ranking = inscripciones.ranking()
    assert ranking[0] == {'legajo': 101, 'nombre': 'ana', 'promedio': 8.5}
    assert [fila['legajo'] for fila in ranking] == [101, 104, 103, 106, 102]


def test_materias():
    materias = inscripciones.materias()
    assert len(materias) == 7
    assert materias[0] == {'codigo': 'am1', 'nombre': 'analisis_1', 'anio': 1, 'inscriptos': 5}


def test_inscribir(estado_intacto):
    inscripciones.inscribir(104, 'ssl')
    ssl = next(m for m in inscripciones.materias() if m['codigo'] == 'ssl')
    assert ssl['inscriptos'] == 1


def test_rechazada(estado_intacto):
    with pytest.raises(inscripciones.InscripcionRechazadaError) as rechazo:
        inscripciones.inscribir(105, 'log')
    assert rechazo.value.motivo == 'sin_vacantes'
```

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Escribir en Python `hijos_de(persona)`, la lista de los hijos de
   una persona de `familia.pl`.
2. **(1)** ¿Qué devuelve `janus.query_once('padre(juan, X), X = pedro')`? ¿Y
   `janus.query_once('padre(juan, X), X = luis')`?
3. ★ **(2)** Agregar a `familia.pl`, desde Python y con
   `janus.consult('hermanos', texto)`, la regla `hermano/2`, y escribir
   `hermanos_de(persona)`.
4. **(2)** Escribir `edad_o_cero(persona)` con `janus.apply_once`, que
   devuelve 0 para una persona desconocida.
5. ★ **(2)** Explicar qué hace `edad_armando_el_texto('juan), halt(')`, y por
   qué `edad('juan), halt(')` no tiene el mismo problema.
6. **(2)** Escribir `mayores_de_edad(personas)`: recibe una lista de
   diccionarios de Python con `nombre` y `edad`, y devuelve los nombres de los
   que tienen 18 o más, calculados por una consulta de Prolog.
7. ★ **(2)** Escribir `clase_de_error(error)`, que recibe un
   `janus.PrologError` y devuelve el nombre de su error formal, como
   `'existence_error'`, con una consulta que no devuelva términos compuestos.
8. **(2)** En el proyecto, escribir la prueba de pytest que inscribe dos veces
   al mismo alumno en la misma materia y verifica el motivo del segundo
   rechazo.
9. **(1)** ¿Qué informa `test_plunit.py` si una prueba de `familia.plt` falla?
10. ★ **(2)** Escribir en Prolog `envolver/3`, que divide un texto en líneas de
    un ancho máximo con `textwrap.wrap` de Python.
11. **(2)** Escribir en Prolog `a_json/2`, que convierte un dict en un texto
    JSON con `json.dumps` de Python, con las claves ordenadas.
12. **(2)** En el proyecto, escribir la función de Python `inscriptos(materia)`:
    la lista de los alumnos inscriptos, cada uno un diccionario con `legajo` y
    `nombre`.
13. ★ **(3)** Escribir en Python una interfaz de texto de pantalla completa
    para el Buscaminas del [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md), con `curses`: el tablero en un
    recuadro, un cursor que se mueve con las flechas, la barra espaciadora
    descubre y `m` marca. Las reglas del juego quedan en Prolog, y el estado
    de la partida viaja envuelto en `prolog/1`. Organizar el código de Python
    con puertos y adaptadores: la interfaz depende del dominio, y el dominio
    no depende de la interfaz ni de Janus.

## Resumen

| | |
|---|---|
| `janus-swi`, `SWI_HOME_DIR` | instalar Janus; en Windows, el directorio de SWI-Prolog |
| `janus.consult/1,2` | cargar un archivo, o un texto |
| `janus.query_once`, `janus.query` | la primera respuesta, o todas; `truth` dice si se cumplió |
| ligaduras | los valores de entrada, en un diccionario, nunca pegados en el texto |
| `janus.apply_once`, `janus.apply` | llamar a un predicado con argumentos de Python |
| `prolog(T)`, `janus.Term` | un término que Python guarda sin examinarlo |
| `janus.PrologError`, `.term` | un error de Prolog en Python |
| pytest, `test_plunit.py` | las dos baterías, con un comando |
| `py_call/2,3`, `py_object(true)` | Python desde Prolog |
| `sqrt/1` | la raíz cuadrada, función aritmética de `is/2`; `math:sqrt` es la de Python |
| **[Patrón 39](../patrones.md#39-frontera-pythonprolog)** | frontera Python–Prolog |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| El mismo núcleo, como servicio web con JSON | [capítulo 30](../capitulo-30-servicios-web-rest/index.md) |
| El cliente del Buscaminas, contra el servicio | [capítulo 30](../capitulo-30-servicios-web-rest/index.md) |
| Una base de datos SQL junto a Prolog | [capítulo 42](../capitulo-42-prolog-y-sql/index.md) |
