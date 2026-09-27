"""Configuración de pytest para los ejemplos del capítulo 28.

Janus inicia un Prolog dentro del proceso de Python. En Windows necesita la
variable SWI_HOME_DIR con el directorio de SWI-Prolog; si no está definida, se
toma de `swipl --dump-runtime-variables` antes de importar Janus.
"""

import os
import re
import shutil
import subprocess


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
