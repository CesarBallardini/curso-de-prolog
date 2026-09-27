"""Capítulo 29 - Un informe de Inscripciones, escrito en Python.

    uv run --group apendice-a python ejemplos/capitulo-29/informes.py

Las reglas y los datos están en Prolog; el formato del informe, en Python. El
programa solo usa las funciones de inscripciones_py.
"""

import inscripciones_py as inscripciones


def informe():
    """Devuelve el texto del informe: el ranking y los inscriptos por materia."""
    lineas = ['Ranking', '']
    for posicion, fila in enumerate(inscripciones.ranking(), start=1):
        nombre, legajo, promedio = fila['nombre'], fila['legajo'], fila['promedio']
        lineas.append(f'{posicion:>2}. {nombre:<10} {legajo:>4} {promedio:>6.2f}')
    lineas += ['', 'Inscriptos por materia', '']
    for materia in inscripciones.materias():
        lineas.append(f'{materia["codigo"]:<4} {materia["nombre"]:<16} {materia["inscriptos"]:>3}')
    return '\n'.join(lineas)


def main():
    """Carga el programa de Prolog y escribe el informe."""
    inscripciones.cargar()
    print(informe())


if __name__ == '__main__':
    main()
