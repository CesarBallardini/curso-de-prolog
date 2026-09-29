# Soluciones del capítulo 56 — Proyecto: órdenes en castellano

El código de esta página está en `ejemplos/capitulo-56/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `ordenes.pl`, que carga a
su vez las demás versiones, y `fechas.pl` del
[capítulo 21](../capitulo-21-gramaticas-dcg/index.md). Ninguna solución
modifica los archivos del capítulo: agregan cláusulas a los predicados que
el capítulo declara `multifile` —`verbo/2`, `pedido//1`, `objeto//2` y
`reservada/1` en la gramática; `plan/3` y `seleccion/3` en el planificador;
`realizar/6` en la ejecución; `oracion/2` en las respuestas— o definen
predicados nuevos que usan los del capítulo. Es `% solo-local`, porque
carga otros archivos. Los ejercicios 1, 2, 3 y 7 se resuelven con los
archivos del capítulo.

## 1

Con `gramatica.pl` cargado:

<!-- ejemplo: capitulo-56/gramatica.pl predicado: entender/2 -->
```prolog
%!  entender(+Texto:string, -Orden) is semidet.
%
%   Orden es el significado de la primera lectura de Texto como orden.
%   Falla si Texto no es una orden de la gramática.
entender(Texto, Orden) :-
    palabras(Texto, Palabras),
    once(phrase(orden(Orden), Palabras)).
```

```prolog
?- entender("Muestra los archivos .pdf de informes", O).
O = listar("informes", patron("*.pdf")).

?- entender("Borra el archivos viejo.log", O).
false.

?- entender("¿Cuánto ocupan notas.txt?", O).
false.

?- entender("Copia todos los archivos a respaldo", O).
O = copiar(archivos(".", todos), a("respaldo")).

?- entender("Lista los archivos que empiezan con acta de informes", O).
O = listar("informes", patron("acta*")).

?- entender("¿Cuántos archivos hay en respaldo, por favor?", O).
O = contar("respaldo", todos).
```

«el archivos» no concuerda en número, y «ocupan» pide un objeto en plural;
las dos fallan en la gramática. «Copia todos los archivos a respaldo» copia
los archivos de la carpeta de trabajo, porque la carpeta de origen omitida
es `"."`. En la quinta, «que empiezan con acta» es el filtro y «de
informes», la carpeta: el orden de `conjunto//2` es cuantificador,
artículo, nombre, filtro y carpeta. La última termina con «por favor», que
`cortesia//0` admite al final de cualquier orden.

## 2

`palabras/2` da `["que", "archivos", "hay", "en", "la", "carpeta",
"informes"]`, y `simplificar/2` la reescribe de izquierda a derecha:

| Posición | Regla que se aplica | Lista desde esa posición |
|---|---|---|
| «que» | `["que", "archivos", "hay"]` → `["lista"]` | `["lista", "en", "la", "carpeta", "informes"]` |
| «lista» | ninguna | se conserva «lista» |
| «en» | `["en"]` → `["de"]` | `["de", "la", "carpeta", "informes"]` |
| «de» | ninguna | se conserva «de» |
| «la» | `["la"]` → `[]` | `["carpeta", "informes"]` |
| «carpeta» | `["carpeta"]` → `[]` | `["informes"]` |
| «informes» | ninguna | se conserva «informes» |

El resultado, `["lista", "de", "informes"]`, es la plantilla
`["lista", "de", C]`, con el significado `listar("informes", todos)`.

Si `simplifica(["archivos"], [])` estuviera antes que la regla de «que
archivos hay», el resultado sería el mismo. El orden de las reglas decide
entre las que se aplican **en la misma posición**, y en la posición de
«que» solo se aplica la regla larga: la de «archivos» empieza en la
posición siguiente, y a esa posición no se llega, porque la regla larga ya
consumió la palabra. El orden importaría con dos reglas que empiezan con la
misma palabra, como lo muestra Covington con «disk in drive» y «disk».

## 3

```prolog
%!  comodin(+Patron:list(char), +Nombre:list(char)) is nondet.
%!  pasa(+F, +N:string) is semidet.
```

`comodin/2` tiene una respuesta por cada manera de repartir el nombre entre
los asteriscos. Para el patrón `*a*` y el nombre «banana», la `a` del
patrón puede ser cualquiera de las tres de «banana»:

<!-- ejemplo: capitulo-56/plan.pl predicado: pasa/2 comodin/2 -->
```prolog
%!  pasa(+F, +N:string) is semidet.
%
%   El nombre N pasa el filtro F: todos, o patron(P) con * en lugar de
%   cualquier secuencia de caracteres.
pasa(todos, _).
pasa(patron(P), N) :-
    string_chars(P, Ps),
    string_chars(N, Ns),
    once(comodin(Ps, Ns)).

%!  comodin(+Patron:list(char), +Nombre:list(char)) is nondet.
%
%   Nombre sigue Patron: cada * cubre cero o más caracteres, y cada otro
%   carácter se cubre a sí mismo.
comodin([], []).
comodin(['*'|Ps], Ns) :-
    append(_, Resto, Ns),
    comodin(Ps, Resto).
comodin([C|Ps], [C|Ns]) :-
    C \== '*',
    comodin(Ps, Ns).
```

```prolog
?- string_chars("*a*", P), string_chars("banana", N), aggregate_all(count, comodin(P, N), K).
P = [*, a, *],
N = [b, a, n, a, n, a],
K = 3.
```

Por eso `comodin/2` es `nondet`. `pasa/2` solo pregunta si el nombre sigue
el patrón: la primera manera alcanza, y `once/1` descarta las demás. Sin
`once/1`, `archivos_en/4` seguiría dando una única respuesta, porque la
recoge `findall/3`, pero un archivo aparecería tres veces en la lista, una
por cada manera de repartir su nombre. Con `once/1`, `pasa/2` es
`semidet`: tiene éxito una vez o falla.

## 4

<!-- ejemplo: capitulo-56/soluciones.pl fragmento: verbo(listar, "enumera"). .. verbo(mover, "traslada"). -->
```prolog
verbo(listar, "enumera").
verbo(copiar, "duplica").
verbo(mover, "traslada").
```

```prolog
?- entender("Enumera los archivos de informes", O).
O = listar("informes", todos).
```

Basta con `verbo/2` porque la gramática no nombra formas de verbos en sus
reglas: `verbo//1` busca la forma en ese predicado, y cada regla de
`pedido//1` llama a `verbo(listar)`, `verbo(copiar)` o `verbo(mover)`. Las
cláusulas nuevas quedan al final de `verbo/2`, así que la gramática sigue
generando «lista», «copia» y «mueve»: al generar, la primera forma de cada
verbo es la que se usa.

## 5

El objeto fechado reutiliza las piezas de la gramática —el artículo, el
nombre en plural y la carpeta— y lee la fecha con `fecha//1` del
[capítulo 21](../capitulo-21-gramaticas-dcg/index.md), que valida el día y
el mes. `format_time/3` la escribe como `2026-09-01`, la forma del modelo:

<!-- ejemplo: capitulo-56/soluciones.pl predicado: objeto//2 relacion_temporal//1 -->
```prolog
objeto(fechados(C, Rel, F), pl) -->
    determinante(G, pl),
    sustantivo(archivo, G, pl),
    relacion_temporal(Rel),
    [Texto],
    { string_codes(Texto, Cs),
      phrase(fecha(fecha(A, M, D)), Cs),
      format_time(string(F), '%F', date(A, M, D)) },
    de_carpeta(C).

%!  relacion_temporal(?Rel)// is semidet.
%
%   «anteriores al» (antes) o «posteriores al» (despues).
relacion_temporal(antes) -->
    ["anteriores", "al"].
relacion_temporal(despues) -->
    ["posteriores", "al"].
```

La selección es una cláusula más de `seleccion/3`. Las fechas del modelo
están en la forma año-mes-día, con dos cifras para el mes y el día, y en esa
forma el orden de los textos es el orden de las fechas:

<!-- ejemplo: capitulo-56/soluciones.pl predicado: seleccion/3 comparar_fecha/3 -->
```prolog
seleccion(fechados(C, Rel, F), M, Rs) :-
    carpeta_existente(C, M),
    findall(R, ( member(archivo(R, _, FR), M),
                 en_carpeta(R, C, _),
                 comparar_fecha(Rel, FR, F) ),
            Rs),
    (   Rs == []
    ->  throw(rechazo(ninguno_fechado(C, Rel, F)))
    ;   true
    ).

%!  comparar_fecha(+Rel, +FR:string, +F:string) is semidet.
%
%   La fecha FR es anterior (antes) o posterior (despues) a F. Las dos
%   están en la forma AAAA-MM-DD, que se ordena como el texto.
comparar_fecha(antes, FR, F) :-
    FR @< F.
comparar_fecha(despues, FR, F) :-
    FR @> F.
```

```prolog
?- entender("Borra los archivos anteriores al 1/9/2026", O).
O = borrar(fechados(".", antes, "2026-09-01")).

?- entender("¿Cuánto ocupan los archivos posteriores al 11/9/2026 de informes?", O), planificar_ejemplo(O, P).
O = tamano(fechados("informes", despues, "2026-09-11")),
P = [informar(tamano(["informes/notas.txt", "informes/resumen.pdf"], 2168))].
```

Como `plan/3` obtiene los archivos de cualquier objeto con `seleccion/3`,
las órdenes de borrar, copiar, mover, tamaño y fecha aceptan el objeto
nuevo sin cambios. Una fecha imposible, como el 31/2/2026, hace fallar a
`fecha//1`, y la orden no se entiende. El rechazo nuevo,
`ninguno_fechado/3`, tiene su oración en `oracion/2`.

## 6

<!-- ejemplo: capitulo-56/soluciones.pl predicado: ejemplos_de_ordenes/1 -->
```prolog
%!  ejemplos_de_ordenes(-Textos:list(string)) is det.
%
%   Textos son las oraciones que la gramática genera para una orden de
%   cada clase.
ejemplos_de_ordenes(Textos) :-
    findall(T,
            ( member(O, [ listar(".", todos),
                          contar("informes", patron("*.txt")),
                          copiar(archivo("notas.txt"), a("respaldo")),
                          mover(archivos(".", patron("*.tmp")), a("viejos")),
                          borrar(archivo("borrador.tmp")),
                          tamano(archivos("informes", todos)),
                          fecha(archivo("notas.txt")),
                          buscar(patron("*.pl")),
                          ejecutar(archivo("hola.pl")),
                          salir ]),
              once(phrase(orden(O), Ps)),
              atomic_list_concat(Ps, ' ', A),
              atom_string(A, T) ),
            Textos).
```

La prueba `ejemplos` de `soluciones.plt` compara los diez textos, de «lista
los archivos» a «salir», y `ejemplos_se_entienden` comprueba que cada uno
tiene significado. Al generar, la gramática toma la primera alternativa de
cada regla. Para la carpeta, la primera de `de_carpeta//1` es «de», que es
la natural después de «los archivos» pero no después de «hay»: la gramática
acepta las dos preposiciones en todos los lugares, y la oración generada es
correcta para la gramática aunque no sea la que se diría. Para generar «hay
en informes» habría que distinguir, en la regla de `contar`, la preposición
que va después de «hay».

## 7

| Orden | Se detiene en | Resultado |
|---|---|---|
| «Copia notas.txt a ..» | el planificador | `ya_existe("notas.txt")`: el punto final de la oración se quita de «..», que queda «.», la carpeta de trabajo |
| «Lista los archivos de informes/../..» | el planificador | `fuera_de_la_carpeta("informes/../.")` |
| «Borra /etc/passwd» | el planificador | `fuera_de_la_carpeta("/etc/passwd")`: es una ruta absoluta |
| «Copia notas.txt a c:/x» | la gramática | `:` no puede estar en un nombre |
| «Busca ../*.txt» | la gramática | `*` no puede estar en un nombre, y el patrón con asteriscos solo va después de «los archivos» |
| «Copia notas.txt de .. a respaldo» | el planificador | `fuera_de_la_carpeta("../notas.txt")`: la ruta la arma la gramática con `atomics_to_string/2`, y el planificador la examina ya armada |

La prueba `seguridad` de `soluciones.plt` comprueba la tabla. Con el código
del capítulo, ninguna orden llega a `ruta_real/3` con una ruta que salga de
la carpeta: todas las rutas del plan salen de strings del significado, que
el planificador ya examinó, o de unir un nombre de esos strings a una
carpeta del modelo. La segunda verificación protege de lo que el
planificador no ve: una extensión que construya rutas dentro de `plan/3`,
como las de los ejercicios, o un error en el propio planificador.

## 8

<!-- ejemplo: capitulo-56/soluciones.pl fragmento: reservada("total"). .. format(string(T), "Hay ~s en total.", [Q]). -->
```prolog
reservada("total").

pedido(contar_todo) -->
    ["cuantos"],
    sustantivo(archivo, _, pl),
    ["hay", "en", "total"].

plan(contar_todo, M, [informar(total(N))]) :-
    aggregate_all(count, member(archivo(_, _, _), M), N).

oracion(total(0), "No hay ningún archivo.") :-
    !.
oracion(total(N), T) :-
    cantidad(N, archivo, m, Q),
    format(string(T), "Hay ~s en total.", [Q]).
```

```prolog
?- entender("¿Cuántos archivos hay en total?", O), planificar_ejemplo(O, P).
O = contar_todo,
P = [informar(total(6))].
```

Sin `reservada("total")`, la regla de `contar` del capítulo, que está antes
que la nueva, analiza «en total» como «en» y la carpeta «total»: el
significado sería `contar("total", todos)` y el plan, el rechazo
`no_existe("total")`. Declarar la palabra como reservada hace fallar a
`nombre//1`, y la orden llega a la regla nueva.

## 9

<!-- ejemplo: capitulo-56/soluciones.pl fragmento: pedido(mayor(C)) .. format(string(T), "El archivo más grande es ~s, con ~s.", [R, Q]). -->
```prolog
pedido(mayor(C)) -->
    ["cual", "es"],
    determinante(G, sg),
    sustantivo(archivo, G, sg),
    ["mas", "grande"],
    de_carpeta(C).

plan(mayor(C), M, [informar(mayor(R, B))]) :-
    seleccion(archivos(C, todos), M, Rs),
    findall(B0-R0, ( member(R0, Rs),
                     memberchk(archivo(R0, B0, _), M) ),
            Pares),
    max_member(B-R, Pares).

oracion(mayor(R, B), T) :-
    cantidad(B, byte, m, Q),
    format(string(T), "El archivo más grande es ~s, con ~s.", [R, Q]).
```

```prolog
?- entender("¿Cuál es el archivo más grande de informes?", O), planificar_ejemplo(O, P).
O = mayor("informes"),
P = [informar(mayor("informes/resumen.pdf", 2048))].
```

La selección usa `seleccion/3` con el objeto `archivos(C, todos)`, y
hereda su rechazo: para `respaldo`, que está vacía, el plan es
`[rechazo(ninguno("respaldo", todos))]`, y la respuesta, «En la carpeta
respaldo no hay archivos.».

## 10

<!-- ejemplo: capitulo-56/soluciones.pl predicado: entender_varias/2 varias//1 planificar_varias/3 planificar_varias_ejemplo/2 aplicar/3 aplicar_accion/3 -->
```prolog
%!  entender_varias(+Texto:string, -Ordenes:list) is semidet.
%
%   Ordenes son los significados de las órdenes de Texto, unidas por «y».
entender_varias(Texto, Ordenes) :-
    palabras(Texto, Palabras),
    once(phrase(varias(Ordenes), Palabras)).

%!  varias(?Ordenes:list)// is nondet.
%
%   Una o más órdenes separadas por «y».
varias([O|Os]) -->
    pedido(O),
    (   ["y"]
    ->  varias(Os)
    ;   { Os = [] }
    ).

%!  planificar_varias(+Ordenes:list, +Modelo:list, -Plan:list) is det.
%
%   Plan cumple las Ordenes en sucesión: cada una se planifica sobre el
%   modelo que deja el plan de la anterior. El primer rechazo detiene el
%   plan.
planificar_varias([], _, []).
planificar_varias([O|Os], M0, Plan) :-
    planificar(O, M0, P),
    (   memberchk(rechazo(_), P)
    ->  Plan = P
    ;   aplicar(P, M0, M1),
        planificar_varias(Os, M1, Resto),
        append(P, Resto, Plan)
    ).

%!  planificar_varias_ejemplo(+Ordenes:list, -Plan:list) is det.
%
%   Plan cumple las Ordenes en sucesión sobre el modelo de ejemplo.
planificar_varias_ejemplo(Ordenes, Plan) :-
    modelo_ejemplo(M),
    planificar_varias(Ordenes, M, Plan).

%!  aplicar(+Plan:list, +Modelo0:list, -Modelo:list) is det.
%
%   Modelo es Modelo0 después de realizar Plan, suponiendo que cada
%   borrado se confirma. Una copia conserva la fecha del original.
aplicar(Plan, M0, M) :-
    foldl(aplicar_accion, Plan, M0, M1),
    msort(M1, M).

%!  aplicar_accion(+Accion, +Modelo0:list, -Modelo:list) is det.
%
%   Modelo es Modelo0 después de Accion.
aplicar_accion(Accion, M0, M) :-
    (   Accion = copiar(R, D)
    ->  memberchk(archivo(R, B, F), M0),
        M = [archivo(D, B, F)|M0]
    ;   Accion = mover(R, D)
    ->  selectchk(archivo(R, B, F), M0, M1),
        M = [archivo(D, B, F)|M1]
    ;   Accion = borrar(R)
    ->  selectchk(archivo(R, _, _), M0, M)
    ;   M = M0
    ).
```

```prolog
?- entender_varias("Copia notas.txt a respaldo y borra respaldo/notas.txt", Os), planificar_varias_ejemplo(Os, P).
Os = [copiar(archivo("notas.txt"), a("respaldo")), borrar(archivo("respaldo/notas.txt"))],
P = [copiar("notas.txt", "respaldo/notas.txt"), borrar("respaldo/notas.txt")].
```

Sobre el modelo inicial, `respaldo/notas.txt` no existe, y la segunda orden
se rechazaría con `no_existe("respaldo/notas.txt")`. `aplicar/3` es el
planificador llevado un paso más: calcula, sin tocar el disco, el modelo que
deja un plan. Supone dos cosas que la ejecución real puede desmentir: que
cada borrado se confirma, y que una copia conserva la fecha del original,
cuando `copy_file/2` le da la fecha del momento de la copia. En «Renombra
notas.txt como apuntes.txt y borra notas.txt», el segundo paso se rechaza,
porque en el modelo actualizado `notas.txt` ya no existe; la prueba
`varias_rechazo` lo comprueba.

## 11

<!-- ejemplo: capitulo-56/soluciones.pl predicado: palabras_con_mayusculas/2 palabra_conservada/2 parece_nombre/1 entender_con_mayusculas/2 -->
```prolog
%!  palabras_con_mayusculas(+Texto:string, -Palabras:list(string)) is det.
%
%   Como palabras/2, pero las palabras con un punto interior, una barra o
%   un dígito se conservan tal como se escribieron: son nombres.
palabras_con_mayusculas(Texto, Palabras) :-
    split_string(Texto, " ", " ¿?¡!,;", Partes0),
    exclude(==(""), Partes0, Partes1),
    ultima_sin_punto(Partes1, Partes),
    maplist(palabra_conservada, Partes, Palabras0),
    exclude(==(""), Palabras0, Palabras).

%!  palabra_conservada(+P0:string, -P:string) is det.
%
%   P es P0 si es un nombre, y si no, P0 en minúsculas y sin tildes.
palabra_conservada(P1, P) :-
    (   parece_nombre(P1)
    ->  P = P1
    ;   palabras(P1, [P])
    ->  true
    ;   P = ""
    ).

%!  parece_nombre(+P:string) is semidet.
%
%   P tiene un punto, una barra o un dígito.
parece_nombre(P) :-
    string_chars(P, Cs),
    member(C, Cs),
    (   memberchk(C, ['.', '/'])
    ;   char_type(C, digit)
    ),
    !.

%!  entender_con_mayusculas(+Texto:string, -Orden) is semidet.
%
%   Como entender/2, con las palabras de palabras_con_mayusculas/2.
entender_con_mayusculas(Texto, Orden) :-
    palabras_con_mayusculas(Texto, Palabras),
    once(phrase(orden(Orden), Palabras)).
```

```prolog
?- entender_con_mayusculas("Copia Informe.PDF a respaldo.", O).
O = copiar(archivo("Informe.PDF"), a("respaldo")).
```

Siguen sin poder escribirse los nombres que no tienen punto, barra ni
dígito —una carpeta `Respaldo` se sigue leyendo como `respaldo`—, los que
llevan tilde o eñe fuera de esas condiciones, y los que contienen un blanco,
porque las palabras se separan por blancos.

## 12

<!-- ejemplo: capitulo-56/soluciones.pl fragmento: reservada("con"). .. format(string(T), "Se ejecutaría ~s con los argumentos ~w.", [R, A]). -->
```prolog
reservada("con").

pedido(ejecutar_con(archivo(R), Args)) -->
    verbo(ejecutar),
    objeto(archivo(R), sg),
    ["con"],
    argumentos(Args).

%!  argumentos(?Args:list(string))// is nondet.
%
%   Uno o más argumentos: nombres, números o palabras sueltas.
argumentos([A|As]) -->
    [A],
    (   argumentos(As)
    ;   { As = [] }
    ).

plan(ejecutar_con(archivo(R), Args), M, [ejecutar_con(R, Args)]) :-
    plan(ejecutar(archivo(R)), M, _).

realizar(real, Raiz, _, _, ejecutar_con(R, Args), salida(R, Estado, Lineas)) :-
    ruta_real(Raiz, R, Abs),
    salida_de(swipl, ['-t', halt, Abs|Args], Texto, Estado),
    split_string(Texto, "\n", "\r", Lineas0),
    exclude(==(""), Lineas0, Lineas).

oracion(simulada(ejecutar_con(R, Args)), T) :-
    atomic_list_concat(Args, ' ', A),
    format(string(T), "Se ejecutaría ~s con los argumentos ~w.", [R, A]).
```

`plan/3` reutiliza el plan de `ejecutar/1` para verificar que el archivo
exista y sea un `.pl`: si no, esa llamada lanza el rechazo, y
`planificar/3` lo captura como en cualquier otra orden. `swipl` pasa al
programa los argumentos que siguen al nombre del archivo, y el programa los
lee con `current_prolog_flag(argv, Args)`. La prueba `argumentos_real`
escribe en una carpeta temporal un programa que escribe esa lista, y
comprueba que la salida es `[uno,dos]`.
