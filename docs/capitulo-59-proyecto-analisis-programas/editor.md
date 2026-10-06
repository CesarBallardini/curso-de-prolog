# Un editor de cláusulas

Esta página contiene la [sección 59.7](index.md#597-un-editor-de-clausulas) del
[capítulo 59](index.md): el primero de los tres programas del apéndice de
Kluźniak y Szpakowicz, un editor de las cláusulas de un predicado, escrito con
lo que SWI-Prolog ofrece hoy. El ejemplo es `editor.pl`, en
`ejemplos/capitulo-59/`, con sus pruebas; lee comandos de un stream y cambia la
base dinámica, y se ejecuta localmente.

## Un editor de cláusulas

El editor del libro se invoca con `edit(Nombre/Aridad)` y trabaja sobre las
cláusulas que el intérprete tiene en memoria. Cada invocación tiene un
**cursor**, el número de una cláusula, que empieza en 0, antes de la primera.
Los comandos mueven el cursor (`+`, `-`, `t` al principio, `b` al final),
listan el predicado (`l`), borran la cláusula del cursor (`d`), insertan
después de ella las cláusulas que se escriben a continuación (`i`, hasta
`end.`) o las de un archivo, abren otra instancia del editor para otro
predicado (`e`), abren un intérprete anidado (`p`) y terminan (`x`). El libro
lee los comandos carácter por carácter, con primitivas de su intérprete, y
borra e inserta cláusulas por su número, con primitivas que SWI-Prolog no
tiene.

La versión del curso separa el estado del editor de la base de datos. El
estado es un término `editor(PI, Cursor, Clausulas)`, con las cláusulas del
predicado como una lista de términos `Cabeza :- Cuerpo`, y cada comando que lo
cambia es una cláusula de `comando/3`, una relación pura entre el estado
anterior y el siguiente:

<!-- ejemplo: capitulo-59/editor.pl predicado: comando/3 -->
```prolog
%!  comando(+Comando, +Estado0, -Estado) is semidet.
%
%   Estado es Estado0 después del Comando. b borra la cláusula del cursor,
%   que queda en la siguiente, o en la nueva última si borró la última; con
%   el cursor en 0 no borra nada. i(Cs) inserta Cs después del cursor, que
%   queda en la última insertada. Falla si Comando no es un comando que
%   cambia el estado.
comando(s, editor(PI, C0, Cs), editor(PI, C, Cs)) :-
    length(Cs, N),
    C is min(C0 + 1, N).
comando(a, editor(PI, C0, Cs), editor(PI, C, Cs)) :-
    C is max(C0 - 1, 0).
comando(p, editor(PI, _, Cs), editor(PI, 0, Cs)).
comando(u, editor(PI, _, Cs), editor(PI, N, Cs)) :-
    length(Cs, N).
comando(b, editor(PI, C0, Cs0), editor(PI, C, Cs)) :-
    (   C0 > 0
    ->  nth1(C0, Cs0, _, Cs),
        length(Cs, N),
        C is min(C0, N)
    ;   C = C0,
        Cs = Cs0
    ).
comando(i(Nuevas), editor(PI, C0, Cs0), editor(PI, C, Cs)) :-
    length(Antes, C0),
    append(Antes, Despues, Cs0),
    append([Antes, Nuevas, Despues], Cs),
    length(Nuevas, K),
    C is C0 + K.
```

Los comandos son términos de Prolog leídos con `read_term/3`, de modo que cada
uno termina con un punto. Por eso las letras reemplazan a los símbolos del
libro: `+.` no se lee como el átomo `+` seguido del punto final, sino como el
átomo `'+.'`, porque `+` y `.` son los dos caracteres simbólicos y se
agrupan en un solo nombre. Quedan `s` y `a` para la cláusula siguiente y la
anterior, `p` y `u` para el principio y la última, `b` para borrar, y `l`,
`i`, `e(PI)` y `x` como en el libro. `abrir/2` arma el estado con `clause/2`,
y `grabar/1` escribe la lista en la base:

<!-- ejemplo: capitulo-59/editor.pl predicado: grabar/1 -->
```prolog
%!  grabar(+Estado) is det.
%
%   Reemplaza en la base las cláusulas del predicado del Estado por las del
%   Estado, en una sola transacción.
grabar(editor(Nombre/Aridad, _, Clausulas)) :-
    functor(Cabeza, Nombre, Aridad),
    transaction(( retractall(Cabeza),
                  forall(member(C, Clausulas), assertz(C)) )).
```

`transaction/1`, presentado en la
[sección 37.3](../capitulo-37-concurrencia-y-paralelismo/index.md#373-estado-compartido),
hace que el reemplazo sea atómico: si una aserción fallara, las cláusulas
viejas seguirían en su lugar, y otro hilo nunca ve el predicado a medio
cambiar. La sesión lee un comando, lo ejecuta y muestra el cursor con
`portray_clause/1`, que escribe una cláusula como la escribiría `listing/1`.
`editar/1` lee de la entrada estándar; `editar_texto/2` lee los comandos de
un texto, y sirve para mostrar una sesión completa. La consulta
`editar_texto("s. s. b. l. i. nota(rosa, 10). end. x.", nota/2)` escribe, y
después responde `true`:

```text
nota/2 0: (antes de la primera)
nota/2 1: nota(ana, 7).
nota/2 2: nota(luis, 5).
nota/2 2: nota(eva, 8).
   1  nota(ana, 7).
>  2  nota(eva, 8).
nota/2 2: nota(eva, 8).
nota/2 3: nota(rosa, 10).
```

El cursor avanza a `luis`, el comando `b` lo borra y queda en `eva`, que
ocupa ahora su lugar; `l` lista el predicado con el cursor marcado, e `i`
inserta `nota(rosa, 10)` después de `eva` y deja el cursor en ella. Al
terminar, `nota/2` tiene las cláusulas de `ana`, `eva` y `rosa`, en ese
orden. Un comando `e(PI)` abre un editor anidado sobre el mismo stream; al
volver, el editor de afuera relee su predicado, porque el anidado pudo
cambiarlo, y deja el cursor donde estaba, o en la última cláusula si ahora
hay menos: es la regla del libro, «el cursor queda en su lugar salvo que el
procedimiento se modifique en una instancia anidada».

El intérprete anidado del libro, el comando `p`, no hace falta: el editor se
llama desde el toplevel de SWI-Prolog, que sigue disponible. Y para los
programas que están en archivos, SWI-Prolog ya trae lo que el editor del
libro suplía: `edit/1` abre el archivo en la línea de la primera cláusula
del predicado, y `make/0` vuelve a cargar lo que cambió, como explica la
[sección 13.1](../capitulo-13-el-entorno-de-trabajo/index.md#131-el-toplevel-como-herramienta).
El editor de cláusulas sirve para lo que no está en un archivo: los
predicados dinámicos que un programa construye mientras se ejecuta. El
[ejercicio 12](index.md#ejercicios) agrega el comando del libro que inserta
las cláusulas de un archivo.

!!! question "Actividad"
    Predecir lo que escribe `editar_texto("u. a. b. b. b. l. x.", nota/2)`
    con los tres hechos originales de `nota/2`: dónde queda el cursor después
    de cada `b`, y qué hace el tercero. Comprobarlo, y volver a cargar
    `editor.pl` para recuperar los hechos.
