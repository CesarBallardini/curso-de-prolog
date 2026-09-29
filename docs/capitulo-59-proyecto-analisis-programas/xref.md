# Comparación con prolog_xref

Esta página contiene la [sección 59.6](index.md#596-comparacion-con-libraryprolog_xref) del
[capítulo 59](index.md): el análisis del capítulo comparado con
`library(prolog_xref)`, el de SWI-Prolog, sobre los archivos de *Inscripciones*.
El ejemplo es `comparar.pl`, en `ejemplos/capitulo-59/`, con sus pruebas; lee
archivos, y se ejecuta localmente.

## Comparación con `library(prolog_xref)`

SWI-Prolog incluye su propio analizador, `library(prolog_xref)`, que usan
`gxref/0` y el entorno de desarrollo. `xref_source/2` lee un archivo y
registra lo que define, lo que exporta y lo que llama; `xref_defined/3`,
`xref_exported/2` y `xref_called/3` lo consultan. `comparar.pl` pregunta a
los dos análisis por los predicados que no son puntos de entrada y que ningún
otro predicado llama: `sin_llamadas_analisis/2` con el grafo del capítulo, y
`sin_llamadas_xref_de/2` con `prolog_xref`, sobre una lista de archivos;
`sin_llamadas_xref/2` y `comparar/3` reciben el nombre del programa:

<!-- ejemplo: capitulo-59/comparar.pl predicado: sin_llamadas_xref_de/2 consulta: comparar(inscripciones, Nuestros, DeXref). -->
```prolog
%!  sin_llamadas_xref_de(+Archivos:list, -Ps:list) is det.
%
%   Ps son los predicados definidos en Archivos que ningún módulo exporta
%   y que ningún otro predicado llama, según prolog_xref, ordenados. Una
%   cláusula para otro módulo, como prolog:message//1, no cuenta: la llama
%   el sistema.
sin_llamadas_xref_de(Archivos, Ps) :-
    forall(member(A, Archivos), xref_source(A, [silent(true)])),
    findall(N/Ar, ( member(A, Archivos),
                    xref_defined(A, Cabeza, local(_)),
                    Cabeza \= _:_,
                    \+ xref_exported(A, Cabeza),
                    \+ ( xref_called(_, Cabeza, Otro),
                         Otro \=@= Cabeza ),
                    functor(Cabeza, N, Ar) ),
            Ps0),
    sort(Ps0, Ps).
```

```prolog
?- comparar(inscripciones, Nuestros, DeXref).
Nuestros = DeXref, DeXref = [legajo/2, resultado_json/3].
```

Coinciden, y por la misma razón. `prolog_xref` conoce las metallamadas de las
bibliotecas por los ganchos `prolog:called_by/2` que cada biblioteca define:
el de `http_handler/3` y los de `library(main)` cumplen el papel de las dos
entradas agregadas en la [sección 59.3](index.md#593-el-programa-leido-de-sus-archivos). Esos ganchos existen solo si la
biblioteca está cargada, y `comparar/3` lee primero los archivos con
`leer_programa/3`, que las carga. En un proceso nuevo, sin esa lectura
previa, `prolog_xref` informa siete predicados más: los seis manejadores y
`main/1`, los falsos positivos que explicó la misma sección:

```prolog
?- sin_llamadas_xref(inscripciones, Ps), subtract(Ps, [legajo/2, resultado_json/3], Otros).
Ps = [alumno/2, alumnos/1, inscripciones/1, legajo/2, main/1, materias/1, promedio_http/2, ranking_http/1, ... / ...],
Otros = [alumno/2, alumnos/1, inscripciones/1, main/1, materias/1, promedio_http/2, ranking_http/1].
```

Los dos análisis leen el programa sin ejecutarlo, y los dos dependen de lo
que saben de las bibliotecas; ninguno ve una metallamada que el programa no
declara. `prolog_xref` es más completo: conoce las declaraciones de cada
módulo y de las bibliotecas, los predicados dinámicos y los operadores de
cada archivo. `check/0` usa otra biblioteca, `library(prolog_codewalk)`,
que no lee los archivos: recorre las cláusulas del programa ya cargado. El
analizador del capítulo es más
corto y se cambia en el mismo lenguaje que analiza: la revisión de las
convenciones del curso o el árbol de llamadas numerado se agregan con unas
pocas cláusulas.
