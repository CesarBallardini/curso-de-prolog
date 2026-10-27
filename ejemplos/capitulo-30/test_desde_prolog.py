"""Las pruebas de desde_prolog.pl, dentro del proceso de Python.

Prolog se ejecuta dentro de Python, y py_call/2 llama a ese mismo Python: no
hace falta que la biblioteca de Python esté en el PATH, como cuando se ejecuta
swipl solo.
"""

from pathlib import Path

import janus_swi as janus

AQUI = Path(__file__).parent


def test_plunit_de_desde_prolog():
    janus.consult(str(AQUI / 'desde_prolog.pl'))
    janus.consult(str(AQUI / 'desde_prolog.plt'))
    assert janus.query_once('run_tests(desde_prolog)')['truth']


def test_raiz_desde_python():
    janus.consult(str(AQUI / 'desde_prolog.pl'))
    assert janus.query_once('raiz(16, R)')['R'] == 4.0
