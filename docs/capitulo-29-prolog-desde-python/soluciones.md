# Soluciones del capítulo 29 — Prolog desde Python

El código de esta página está en `ejemplos/capitulo-29/`: `soluciones.py`,
`soluciones.pl`, `soluciones_proyecto.pl` y el paquete `buscaminas/`, con sus
pruebas en `test_soluciones.py` y `test_buscaminas.py`. `make appendix` las
ejecuta junto con las del capítulo.

## 1

<!-- ejemplo: capitulo-29/soluciones.py fragmento: def hijos_de .. return [respuesta['H'] for respuesta in janus.query('padre(P, H)', {'P': persona})] -->
```python
def hijos_de(persona):
    """Devuelve la lista de los hijos de persona, en el orden de los hechos."""
    return [respuesta['H'] for respuesta in janus.query('padre(P, H)', {'P': persona})]
```

`soluciones.hijos_de('ana')` da `['luis', 'eva']`, y `hijos_de('eva')`, la
lista vacía: `janus.query` no devuelve ninguna respuesta.

## 2

```python
janus.query_once('padre(juan, X), X = pedro')  # {'truth': True, 'X': 'pedro'}
janus.query_once('padre(juan, X), X = luis')  # {'truth': False}
```

`query_once` devuelve la primera respuesta de la conjunción completa: el
backtracking pasa de `ana` a `pedro` antes de responder. Cuando la consulta no
se cumple, el diccionario solo tiene `truth`, sin las variables.

## 3

<!-- ejemplo: capitulo-29/soluciones.py fragmento: HERMANO = r .. return [respuesta['H'] for respuesta in janus.query('hermano(P, H)', {'P': persona})] -->
```python
HERMANO = r"""
hermano(A, B) :-
    padre(P, A),
    padre(P, B),
    A \== B.
"""


def hermanos_de(persona):
    """Devuelve los hermanos de persona, con la regla hermano/2 cargada desde el texto."""
    janus.consult('hermanos', HERMANO)
    return [respuesta['H'] for respuesta in janus.query('hermano(P, H)', {'P': persona})]
```

`janus.consult('hermanos', HERMANO)` carga el texto como si fuera un archivo
llamado `hermanos`, y cargarlo otra vez reemplaza sus cláusulas: llamar dos
veces a `hermanos_de` no duplica la regla. La cadena es `r"""…"""`, sin
secuencias de escape, para que `\==` llegue a Prolog tal como está escrito.

## 4

<!-- ejemplo: capitulo-29/soluciones.py fragmento: def edad_o_cero .. return janus.apply_once('user', 'edad_de', persona, fail=0) -->
```python
def edad_o_cero(persona):
    """Devuelve la edad de persona, o 0 si no se conoce."""
    return janus.apply_once('user', 'edad_de', persona, fail=0)
```

Sin `fail=0`, `apply_once` lanza `janus.PrologError` con el texto
`apply_once(): goal failed` cuando el predicado falla.

## 5

El texto de la consulta queda `edad_de(juan), halt(, E)`, que no se puede leer:
la consulta produce un error de sintaxis. Con otro texto, la consulta sí se
leería, y ejecutaría lo que el texto diga: `'juan, E), halt, edad_de(juan'`
arma `edad_de(juan, E), halt, edad_de(juan, E)`, que termina el proceso de
Python. Como ligadura, en cambio, el texto entero es un solo átomo, que no
está en la base: `edad` lanza `PersonaDesconocidaError`. Las dos pruebas están
en `test_soluciones.py`:

```python
def test_texto_pegado_con_parentesis():
    # Ejercicio 5: el texto armado es edad_de(juan), halt(, E), que no se puede leer.
    with pytest.raises(janus.PrologError, match='Syntax error'):
        consultas.edad_armando_el_texto('juan), halt(')
```

## 6

<!-- ejemplo: capitulo-29/soluciones.py fragmento: def mayores_de_edad .. return [respuesta['N'] for respuesta in janus.query(consulta, {'L': personas})] -->
```python
def mayores_de_edad(personas):
    """Devuelve los nombres de las personas, diccionarios con nombre y edad, de 18 o más."""
    consulta = 'member(_D, L), get_dict(edad, _D, _E), _E >= 18, get_dict(nombre, _D, N)'
    return [respuesta['N'] for respuesta in janus.query(consulta, {'L': personas})]
```

La lista de diccionarios de Python llega a Prolog como una lista de dicts, y
`get_dict/3` lee sus campos. `_D` y `_E` empiezan con `_`: no forman parte de
las respuestas, que solo traen el nombre.

## 7

<!-- ejemplo: capitulo-29/soluciones.py fragmento: def clase_de_error .. return respuesta['Nombre'] if respuesta['truth'] else None -->
```python
def clase_de_error(error):
    """Devuelve el nombre del error formal de un janus.PrologError, o None si no es error/2."""
    consulta = 'E = error(_Formal, _), functor(_Formal, Nombre, _)'
    respuesta = janus.query_once(consulta, {'E': error.term})
    return respuesta['Nombre'] if respuesta['truth'] else None
```

El error formal, como `existence_error(procedure, no_existe/0)`, es un
término compuesto que no cruza a Python; su nombre, un átomo, sí. `_Formal`
queda fuera de la respuesta por empezar con `_`, y `error.term`, el
`janus.Term` de la excepción, vuelve a Prolog como el término original.

## 8

```python
def test_inscribir_dos_veces():
    guardado = inscripciones.estado()
    try:
        inscripciones.inscribir(104, 'ssl')
        with pytest.raises(inscripciones.InscripcionRechazadaError) as rechazo:
            inscripciones.inscribir(104, 'ssl')
        assert rechazo.value.motivo == 'ya_la_cursa'
    finally:
        inscripciones.restaurar(guardado)
```

`try` y `finally` hacen lo mismo que el fixture `estado_intacto` de
`test_inscripciones.py`: el estado se restaura aunque la prueba falle.

## 9

La prueba `test_plunit[familia.pl]` falla, y pytest muestra, como mensaje de
la aserción, la salida completa de plunit: el nombre de la prueba que falló,
lo esperado y lo obtenido. Las demás pruebas de pytest se siguen ejecutando.

## 10

<!-- ejemplo: capitulo-29/soluciones.pl predicado: envolver/3 consulta: envolver("uno dos tres cuatro cinco", 9, Lineas). -->
```prolog
%!  envolver(+Texto:text, +Ancho:integer, -Lineas:list(atom)) is det.
%
%   Lineas son las líneas de Texto, de Ancho caracteres como máximo, cortadas
%   entre palabras por textwrap.wrap de Python. Las cadenas de Python llegan
%   como átomos.
envolver(Texto, Ancho, Lineas) :-
    py_call(textwrap:wrap(Texto, width = Ancho), Lineas).
```

Con `"uno dos tres cuatro cinco"` y un ancho de 9, las líneas son
`['uno dos', tres, cuatro, cinco]`: las cadenas de Python llegan a Prolog como
átomos. El argumento con nombre se escribe `width = Ancho`.

## 11

<!-- ejemplo: capitulo-29/soluciones.pl predicado: a_json/2 consulta: envolver("uno dos tres cuatro cinco", 9, Lineas). -->
```prolog
%!  a_json(+Dict:dict, -Texto:atom) is det.
%
%   Texto es Dict escrito en JSON por json.dumps de Python, con las claves
%   en orden alfabético.
a_json(Dict, Texto) :-
    py_call(json:dumps(Dict, sort_keys = @(true)), Texto).
```

`sort_keys = @(true)` lleva los espacios alrededor del `=`: escrito junto,
`=@` se lee como un solo símbolo, y la cláusula tiene un error de sintaxis.
`@(true)` es el `True` de Python.

## 12

<!-- ejemplo: capitulo-29/soluciones_proyecto.pl predicado: inscriptos_py/2 alumno_py/2 consulta: inscriptos_py(log, Alumnos). -->
```prolog
%!  inscriptos_py(+Materia:atom, -Alumnos:list(dict)) is det.
%
%   Alumnos son los inscriptos en Materia, en orden de legajo: un dict por
%   alumno, con las claves legajo y nombre.
inscriptos_py(Materia, Alumnos) :-
    inscriptos(Materia, Legajos),
    maplist(alumno_py, Legajos, Alumnos).

%!  alumno_py(+Legajo:integer, -Alumno:dict) is det.
%
%   Alumno es el dict del alumno Legajo.
alumno_py(Legajo, _{legajo: Legajo, nombre: Nombre}) :-
    alumno(Legajo, Nombre, _, _).
```

<!-- ejemplo: capitulo-29/soluciones.py fragmento: def inscriptos .. return janus.query_once('inscriptos_py(M, A)', {'M': materia})['A'] -->
```python
def inscriptos(materia):
    """Devuelve los inscriptos en materia: diccionarios con legajo y nombre."""
    janus.consult(str(AQUI / 'soluciones_proyecto.pl'))
    return janus.query_once('inscriptos_py(M, A)', {'M': materia})['A']
```

La conversión a dicts está del lado de Prolog, como en el módulo `puente`, y
la función de Python solo consulta: es el [Patrón 39](../patrones.md#39-frontera-pythonprolog).

## 13

La solución es el paquete `buscaminas/`, organizado con **puertos y
adaptadores**. Las reglas del juego —el dominio— están en `buscaminas.pl`, las
del [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md). Del lado de Python, las dependencias apuntan hacia el
dominio:

| Módulo | Papel | Depende de |
|---|---|---|
| `dominio.py` | el puerto: lo que la aplicación necesita del juego | nada |
| `aplicacion.py` | el caso de uso: jugar con un cursor | el puerto |
| `adaptador_prolog.py` | implementa el puerto con Janus y `buscaminas.pl` | el puerto, Janus |
| `tui.py` | la interfaz de texto, con `curses` | la aplicación |
| `__main__.py` | arma las piezas y juega | todos |

El puerto describe una partida con protocolos de Python, sin decir cómo se
implementa:

<!-- ejemplo: capitulo-29/buscaminas/dominio.py fragmento: Estado = Literal .. Devuelve una partida nueva con minas al azar; la semilla la repite. -->
```python
Estado = Literal['sigue', 'gano', 'perdio']


class Partida(Protocol):
    """Una partida en curso, en un tablero de filas por columnas."""

    filas: int
    columnas: int
    estado: Estado

    def descubrir(self, fila: int, columna: int) -> None:
        """Descubre la celda; puede ganar o perder la partida."""

    def marcar(self, fila: int, columna: int) -> None:
        """Marca la celda, o le quita la marca."""

    def tablero(self, mostrar_minas: bool) -> list[str]:
        """Devuelve las filas del tablero, un carácter por celda.

        Los caracteres son: # oculta, M marcada, . sin minas vecinas, un dígito
        con la cantidad de minas vecinas, y * mina, visible solo con
        mostrar_minas o en una celda descubierta.
        """


class Reglas(Protocol):
    """La fábrica de partidas."""

    def partida_al_azar(self, filas: int, columnas: int, minas: int, semilla: int) -> Partida:
        """Devuelve una partida nueva con minas al azar; la semilla la repite."""
```

La aplicación agrega el cursor, y solo depende del puerto:

<!-- ejemplo: capitulo-29/buscaminas/aplicacion.py fragmento: class Juego .. return self.partida.tablero(mostrar_minas=self.terminado) -->
```python
class Juego:
    """Una partida y la posición del cursor, que empieza en la celda 1-1."""

    def __init__(self, partida: Partida):
        """Empieza a jugar la partida, con el cursor en la esquina 1-1."""
        self.partida = partida
        self.fila = 1
        self.columna = 1

    @property
    def terminado(self):
        """Devuelve True si la partida ya se ganó o se perdió."""
        return self.partida.estado != 'sigue'

    def mover(self, filas, columnas):
        """Mueve el cursor, sin salir del tablero; no hace nada si terminó."""
        if self.terminado:
            return
        self.fila = min(max(self.fila + filas, 1), self.partida.filas)
        self.columna = min(max(self.columna + columnas, 1), self.partida.columnas)

    def descubrir(self):
        """Descubre la celda del cursor; no hace nada si terminó."""
        if not self.terminado:
            self.partida.descubrir(self.fila, self.columna)

    def marcar(self):
        """Marca la celda del cursor; no hace nada si terminó."""
        if not self.terminado:
            self.partida.marcar(self.fila, self.columna)

    def tablero(self):
        """Devuelve las filas del tablero; al terminar, con las minas a la vista."""
        return self.partida.tablero(mostrar_minas=self.terminado)
```

El adaptador de Prolog cumple el puerto con las consultas del [Patrón 39](../patrones.md#39-frontera-pythonprolog): la
partida es un `janus.Term` que se guarda y se devuelve en cada jugada:

<!-- ejemplo: capitulo-29/buscaminas/adaptador_prolog.py fragmento: class PartidaEnProlog .. return janus.query_once('buscaminas:filas_py(J, M, T)', entrada)['T'] -->
```python
class PartidaEnProlog:
    """Una partida cuyas reglas están en Prolog; cumple dominio.Partida."""

    def __init__(self, filas, columnas, juego):
        """Guarda las dimensiones y la partida de Prolog, un janus.Term."""
        self.filas = filas
        self.columnas = columnas
        self.estado = 'sigue'
        self._juego = juego

    def _jugar(self, accion, fila, columna):
        """Aplica la jugada en Prolog; una celda fuera del tablero es un error."""
        entrada = {'J0': self._juego, 'A': accion, 'F': fila, 'C': columna}
        respuesta = janus.query_once('buscaminas:jugar_py(J0, A, F, C, J, E)', entrada)
        if respuesta['E'] == 'fuera':
            raise ValueError(f'La celda {fila}-{columna} está fuera del tablero.')
        self._juego = respuesta['J']
        self.estado = respuesta['E']

    def descubrir(self, fila, columna):
        """Descubre la celda."""
        self._jugar('descubrir', fila, columna)

    def marcar(self, fila, columna):
        """Marca la celda, o le quita la marca."""
        self._jugar('marcar', fila, columna)

    def tablero(self, mostrar_minas):
        """Devuelve las filas del tablero, un carácter por celda."""
        entrada = {'J': self._juego, 'M': mostrar_minas}
        return janus.query_once('buscaminas:filas_py(J, M, T)', entrada)['T']
```

La interfaz arma la pantalla en una función que devuelve líneas, y traduce las
teclas en órdenes para la aplicación; solo `ejecutar()` y lo que llama usan
`curses`:

<!-- ejemplo: capitulo-29/buscaminas/tui.py fragmento: def pantalla .. return True -->
```python
def pantalla(juego):
    """Devuelve las líneas de la pantalla: el tablero en un recuadro y el estado."""
    ancho = 3 * juego.partida.columnas
    lineas = ['Buscaminas', '┌' + '─' * ancho + '┐']
    for fila, texto in enumerate(juego.tablero(), start=1):
        celdas = []
        for columna, simbolo in enumerate(texto, start=1):
            en_el_cursor = (fila, columna) == (juego.fila, juego.columna)
            celdas.append(f'[{simbolo}]' if en_el_cursor else f' {simbolo} ')
        lineas.append('│' + ''.join(celdas) + '│')
    lineas.append('└' + '─' * ancho + '┘')
    lineas.append(MENSAJES[juego.partida.estado])
    lineas.append('q: salir' if juego.terminado else AYUDA)
    return lineas


def aplicar(juego, orden):
    """Aplica una orden, por su nombre; devuelve False si la orden es salir."""
    if orden == 'salir':
        return False
    if orden in ORDENES:
        ORDENES[orden](juego)
    return True
```

La raíz de composición es el único módulo que importa todas las piezas:

<!-- ejemplo: capitulo-29/buscaminas/__main__.py fragmento: def main .. tui.ejecutar(Juego(partida)) -->
```python
def main():
    """Lee los argumentos, crea la partida y la juega en la terminal."""
    argumentos = argparse.ArgumentParser(prog='buscaminas')
    argumentos.add_argument('filas', type=int)
    argumentos.add_argument('columnas', type=int)
    argumentos.add_argument('minas', type=int)
    argumentos.add_argument('--semilla', type=int, default=0)
    pedido = argumentos.parse_args()
    reglas = ReglasEnProlog()
    partida = reglas.partida_al_azar(pedido.filas, pedido.columnas, pedido.minas, pedido.semilla)
    tui.ejecutar(Juego(partida))
```

Una partida en la terminal, con el cursor en la celda 3-3 después de
descubrirla:

```text
Buscaminas
┌─────────┐
│ *  1  . │
│ 1  1  . │
│ .  . [.]│
└─────────┘
Todas las celdas libres están descubiertas: partida ganada.
q: salir
```

La separación se ve en las pruebas. La aplicación y la interfaz se prueban
con `PartidaDePrueba`, una partida escrita en Python que cumple el puerto y
registra las jugadas, sin Prolog ni terminal; el adaptador se prueba contra
las reglas de Prolog; y una prueba lee los `import` de cada módulo y falla si
una dependencia apunta hacia afuera:

<!-- ejemplo: capitulo-29/test_buscaminas.py fragmento: @pytest.mark.parametrize( .. assert not importados(modulo) & prohibidos -->
```python
@pytest.mark.parametrize(
    ('modulo', 'prohibidos'),
    [
        ('dominio', {'janus_swi', 'curses', 'buscaminas.aplicacion', 'buscaminas.tui'}),
        ('aplicacion', {'janus_swi', 'curses', 'buscaminas.tui', 'buscaminas.adaptador_prolog'}),
        ('adaptador_prolog', {'curses', 'buscaminas.aplicacion', 'buscaminas.tui'}),
        ('tui', {'janus_swi', 'buscaminas.adaptador_prolog'}),
    ],
)
def test_dependencias_hacia_el_dominio(modulo, prohibidos):
    assert not importados(modulo) & prohibidos
```

`python -m buscaminas 9 9 10`, desde `ejemplos/capitulo-29`, juega en la
terminal. `curses` viene con Python en Linux; en Windows, necesita el paquete
`windows-curses`, que el grupo `apendice-a` del curso instala. Cambiar la
interfaz —una ventana, un servicio web— es escribir otro adaptador de
entrada, sin tocar el dominio ni la aplicación.
