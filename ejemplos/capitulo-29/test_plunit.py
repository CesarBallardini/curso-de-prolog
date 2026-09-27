"""Las pruebas de plunit del capítulo, ejecutadas desde pytest.

Cada archivo .pl con su .plt se carga en un proceso de swipl, como lo hace
`make test` con los demás capítulos: así un solo comando, pytest, ejecuta las
pruebas de los dos lados. desde_prolog.pl necesita Python, y sus pruebas se
ejecutan dentro de este proceso, en test_desde_prolog.py.
"""

import re
import shutil
import subprocess
from pathlib import Path

import pytest

AQUI = Path(__file__).parent
CON_PYTHON = {'desde_prolog.pl', 'soluciones.pl'}
PROBLEMA = re.compile(r'^(ERROR|Warning):', re.M)


def _con_pruebas_en_swipl(programa):
    """Devuelve True si programa tiene su .plt y sus pruebas no necesitan Python."""
    return programa.with_suffix('.plt').exists() and programa.name not in CON_PYTHON


EJEMPLOS = sorted(filter(_con_pruebas_en_swipl, AQUI.rglob('*.pl')))


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
