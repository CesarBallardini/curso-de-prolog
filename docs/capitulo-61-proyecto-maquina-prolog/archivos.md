# Los programas de otros capítulos

Esta página contiene la [sección 61.8](index.md#618-los-programas-de-otros-capitulos) del
[capítulo 61](index.md): la máquina ejecuta archivos de otros capítulos,
leídos sin cargarlos con el lector del [capítulo 59](../capitulo-59-proyecto-analisis-programas/index.md). El ejemplo es
`maquina.pl`, en `ejemplos/capitulo-61/`, con sus pruebas; lee archivos, y
se ejecuta localmente.

## Ejecutar un archivo

`ejecutar_archivo/2` lee un archivo de Prolog con `leer_archivo/2` y
`programa/3` del [capítulo 59](../capitulo-59-proyecto-analisis-programas/index.md), sin cargarlo, descarta las directivas y
ejecuta la consulta en la versión 5:

<!-- ejemplo: capitulo-61/maquina.pl predicado: ejecutar_archivo/2 -->
```prolog
%!  ejecutar_archivo(+Archivo, ?Meta) is nondet.
%
%   Meta se prueba en la versión 5 de la máquina con las cláusulas del
%   Archivo, una especificación como ejemplos('capitulo-06/antepasados'),
%   leídas con leer_archivo/2 y programa/3 del capítulo 59. Las directivas
%   del archivo no se ejecutan.
ejecutar_archivo(Archivo, Meta) :-
    absolute_file_name(Archivo, Ruta,
                       [file_type(prolog), access(read)]),
    leer_archivo(Ruta, Leidos),
    programa(Leidos, Clausulas0, _),
    exclude(directiva, Clausulas0, Clausulas1),
    maplist(con_cuerpo, Clausulas1, Clausulas),
    almacen:resolver_clausulas(indice, Clausulas, Meta).
```

`ejemplos(...)` es una especificación de archivo relativa al directorio de
los ejemplos del curso. Con los predicados de listas del [capítulo 7](../capitulo-07-listas/index.md):

```prolog
?- ejecutar_archivo(ejemplos('capitulo-07/recorrer'), pegar(X, Y, [a, b])).
X = [],
Y = [a, b] ;
X = [a],
Y = [b] ;
X = [a, b],
Y = [] ;
false.
```

## Comparar con Prolog

`igual_que_prolog/3` compara las respuestas de una versión con las que da
Prolog con el mismo programa cargado en un módulo temporal, en el mismo
orden:

```prolog
?- igual_que_prolog(indice, listas, invertir_hasta(20, _)).
true.

?- igual_que_prolog(compilado, familia, antepasado(_, _)).
true.
```

Las pruebas de cada versión hacen esta comparación con los programas del
capítulo; el [ejercicio 3](index.md#ejercicios) la hace con un archivo del [capítulo 7](../capitulo-07-listas/index.md).
