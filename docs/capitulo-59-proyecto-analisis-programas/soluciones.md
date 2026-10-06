# Soluciones del capítulo 59 — Proyecto: análisis de programas

Las soluciones de los ejercicios 2, 3 y 11 están en
`ejemplos/capitulo-59/soluciones.pl`, que carga `problemas.pl`; las de los
ejercicios 5 y 10, en `soluciones_revision.pl`, que carga `analisis.pl`; las
de los ejercicios 6 y 7, en `soluciones_meta.pl`, que carga `leer.pl`; y la
del ejercicio 9, en `soluciones_perfil.pl`, que carga `perfil.pl` y
`llamadas.pl`. Cada archivo tiene sus pruebas en el `.plt` del mismo nombre.
Los ejercicios 1, 4 y 8 se responden con consultas a los archivos del
capítulo.

## Ejercicio 1

`mejor/1` llama a `promedo/2` dentro de la negación, que se atraviesa, y a
dos comparaciones. `llamadas_de/3` no deja alternativas cuando el predicado
llega ligado:

<!-- ejemplo: capitulo-59/llamadas.pl predicado: llama_de/3 -->
```prolog
%!  llama_de(+Clausulas:list, ?P, ?Q) is nondet.
%
%   El predicado P, definido en Clausulas, llama a Q: el arco P-Q del grafo
%   de llamadas.
llama_de(Clausulas, P, Q) :-
    llamadas_de(Clausulas, P, Qs),
    member(Q, Qs).
```

```prolog
?- llamadas(notas, mejor/1, Qs).
Qs = [notas/2, promedio/2, (\==)/2, promedo/2, (>)/2].

?- llama(notas, P, notas/2).
P = alumnos/1 ;
P = mejor/1 ;
P = mostrar/1 ;
false.

?- llamadas(notas, notas/2, Qs).
Qs = [].
```

La segunda consulta recorre los predicados definidos en orden, y
`alumnos/1` llama a `notas/2` solo dentro de `findall/3`. Después de la
tercera respuesta quedan predicados por examinar, y ninguno llama a
`notas/2`: la consulta termina en `false.`. Un hecho no llama a nada, y la
lista vacía no es una falla: `notas/2` está definido.

## Ejercicio 2

`llamadas.pl` declara `meta_argumento/3` como `multifile`, de modo que otro
archivo le agrega cláusulas sin redefinirla:

<!-- ejemplo: capitulo-59/soluciones.pl predicado: meta_argumento/3 -->
```prolog
%!  meta_argumento(+Meta, -G, -Extra:integer) is nondet.
%
%   Cláusulas agregadas: with_output_to/2 ejecuta su segundo argumento;
%   setup_call_cleanup/3, los tres; call_cleanup/2, los dos; not/1, el
%   único.
meta_argumento(with_output_to(_, G), G, 0).
meta_argumento(setup_call_cleanup(S, _, _), S, 0).
meta_argumento(setup_call_cleanup(_, G, _), G, 0).
meta_argumento(setup_call_cleanup(_, _, C), C, 0).
meta_argumento(call_cleanup(G, _), G, 0).
meta_argumento(call_cleanup(_, C), C, 0).
meta_argumento(not(G), G, 0).
```

```prolog
?- metas((with_output_to(string(_), p), not(q)), Ms).
Ms = [with_output_to(string(_), p), p, not(q), q].
```

## Ejercicio 3

<!-- ejemplo: capitulo-59/soluciones.pl predicado: sin_llamadas_de/3 sin_llamadas_hasta_el_fin_de/3 sin_llamadas/2 -->
```prolog
%!  sin_llamadas_de(+Clausulas:list, +Raices:list, -Ps:list) is det.
%
%   Ps son los predicados definidos en Clausulas que no están en Raices y
%   que ningún otro predicado llama, ordenados.
sin_llamadas_de(Clausulas, Raices, Ps) :-
    definidos(Clausulas, Ds),
    findall(P, ( member(P, Ds),
                 \+ memberchk(P, Raices),
                 \+ ( llama_de(Clausulas, Q, P),
                      Q \== P ) ),
            Ps).

%!  sin_llamadas_hasta_el_fin_de(+Clausulas, +Raices, -Ps:list) is det.
%
%   Ps son los predicados que se quitan si se borran, una y otra vez, las
%   cláusulas de los que no tienen llamadas, hasta que no queda ninguno.
sin_llamadas_hasta_el_fin_de(Clausulas, Raices, Ps) :-
    sin_llamadas_de(Clausulas, Raices, Ps0),
    (   Ps0 == []
    ->  Ps = []
    ;   exclude(de_alguno(Ps0), Clausulas, Resto),
        sin_llamadas_hasta_el_fin_de(Resto, Raices, Ps1),
        append(Ps0, Ps1, Ps2),
        sort(Ps2, Ps)
    ).

%!  sin_llamadas(+Programa, -Ps:list) is det.
%
%   sin_llamadas_de/3 sobre las cláusulas y los puntos de entrada del
%   programa llamado Programa.
sin_llamadas(Programa, Ps) :-
    clausulas(Programa, Clausulas),
    raices(Programa, Raices),
    sin_llamadas_de(Clausulas, Raices, Ps).
```

```prolog
?- sin_llamadas(notas, Ps).
Ps = [varianza/2].

?- sin_llamadas_hasta_el_fin(notas, Ps).
Ps = [desvio2/3, varianza/2].
```

`desvio2/3` tiene una llamada, desde `varianza/2`, y por eso no aparece en
la primera respuesta. Borrada `varianza/2`, `desvio2/3` queda sin llamadas,
y la segunda ronda lo encuentra: el resultado final es el de `no_usados/2`.
`sin_llamadas_hasta_el_fin/2` es la forma de `sin_llamadas_hasta_el_fin_de/3`
que recibe el nombre del programa, como `sin_llamadas/2`.
El borrado repetido no alcanza cuando los predicados no usados forman un
ciclo: cada uno llama al otro, y ninguno queda nunca sin llamadas.

```prolog
?- sin_llamadas_de([p, (a :- b), (b :- a)], [p/0], Ps), no_usados_de([p, (a :- b), (b :- a)], [p/0], Us).
Ps = [],
Us = [a/0, b/0].
```

La alcanzabilidad desde los puntos de entrada es la pregunta correcta; «nadie
lo llama» es la aproximación que se calcula mirando un predicado por vez.

## Ejercicio 4

`leer.pl` agrega a `clausulas/2` el programa `inscripciones`, leído de sus
archivos, y `escribir_arbol/2` lo recibe por su nombre:

<!-- ejemplo: capitulo-59/leer.pl predicado: clausulas/2 -->
```prolog
%!  clausulas(+Programa, -Clausulas:list) is semidet.
%
%   Cláusula agregada: las cláusulas de inscripciones, leídas de sus
%   archivos.
clausulas(inscripciones, Clausulas) :-
    archivos(inscripciones, Archivos),
    leer_programa(Archivos, Clausulas, _).
```

```prolog
?- escribir_arbol(inscripciones, ejecutar/2).
   1 ejecutar/2
   2    palabras/3
   3       palabra/3
           palabras/3 (ver 2)
   4    comando/3
   5       legajo/3
   6          alumno/4
   7       materia_por_nombre/3
   8          materia/3
   9    realizar/2
  10       inscribir/3
  11          inscripcion_posible/3
                 alumno/4 (ver 6)
                 materia/3 (ver 8)
  12             aprobada/3
  13                inscripcion/3
  14                nota_minima/1
  15             cursa/2
                    inscripcion/3 (ver 13)
  16             correlativa/2
  17             vacantes/2
  18          agregar_inscripcion/3
  19          cambiar_vacantes/2
  20          contar_operacion/0
  21       dar_de_baja/2
  22          quitar_inscripcion/3
              cambiar_vacantes/2 (ver 19)
              contar_operacion/0 (ver 20)
  23       inscriptos/2
              inscripcion/3 (ver 13)
  24       promedio_de_alumno/2
              alumno/4 (ver 6)
              inscripcion/3 (ver 13)
  25          promedio/2
  26             contar_y_sumar/3
true.
```

Una línea `(ver N)` es un ciclo cuando `N` es un antepasado de la línea en
el árbol: `palabras/3 (ver 2)` está debajo de la línea 2, porque
`palabras//1` es recursiva. Las demás son repeticiones: `alumno/4`,
`materia/3`, `inscripcion/3`, `cambiar_vacantes/2` y `contar_operacion/0`
se llaman desde varias ramas, y su subárbol se escribe una sola vez. Las
reglas de gramática aparecen con dos argumentos más, `legajo/3` y
`palabra/3`, y `contar_y_sumar/3` aparece porque `foldl/4` le agrega tres
argumentos.

## Ejercicio 5

<!-- ejemplo: capitulo-59/soluciones_revision.pl predicado: encabezados_ajenos_de/2 declarado/2 -->
```prolog
%!  encabezados_ajenos_de(+Leidos:list, -Avisos:list) is det.
%
%   Avisos tiene un aviso aviso(P, encabezado_ajeno, D) por cada predicado
%   cuya primera cláusula, en P, va precedida por encabezados %! y ninguno
%   declara ese predicado: D es el que declara el primero.
encabezados_ajenos_de(Leidos, Avisos) :-
    findall(PI, clausula_leida(Leidos, _, PI), PIs0),
    list_to_set(PIs0, PIs),
    findall(aviso(P, encabezado_ajeno, D),
            ( member(PI, PIs),
              once(clausula_leida(Leidos, leido(_, P, _, Cs), PI)),
              findall(D0, ( member(C, Cs),
                            declarado(C, D0) ),
                      [D|Ds]),
              \+ memberchk(PI, [D|Ds]) ),
            Avisos).

%!  declarado(+Comentario:string, -PI) is nondet.
%
%   PI es el predicado que declara una línea %! de Comentario: el texto que
%   sigue a %!, hasta " is ", leído como un término; un no terminal
%   termina en // y tiene dos argumentos más, y el módulo de un predicado
%   de otro módulo no cuenta. Una línea que no se puede leer no declara
%   nada, ni una línea que continúa la anterior.
declarado(Comentario, Nombre/Aridad) :-
    split_string(Comentario, "\n", "", Lineas),
    member(Linea, Lineas),
    string_concat("%!", Resto, Linea),
    (   sub_string(Resto, Antes, _, _, " is ")
    ->  sub_string(Resto, 0, Antes, _, Cabeza0)
    ;   Cabeza0 = Resto
    ),
    normalize_space(string(Cabeza1), Cabeza0),
    Cabeza1 \== "",
    (   string_concat(Cabeza, "//", Cabeza1)
    ->  Mas = 2
    ;   Cabeza = Cabeza1,
        Mas = 0
    ),
    catch(term_string(Termino, Cabeza), error(syntax_error(_), _), fail),
    callable(Termino),
    sin_calificar(Termino, Cabeza2),
    functor(Cabeza2, Nombre, Aridad0),
    Aridad is Aridad0 + Mas.
```

```prolog
?- encabezados_ajenos(encabezado_ajeno, Avisos).
Avisos = [aviso(texto:4, encabezado_ajeno, suma/3)].
```

`encabezados_ajenos/2` recibe el nombre de un texto de `texto/2`, al que
`soluciones_revision.pl` agrega `encabezado_ajeno`, un programa cuyo
encabezado de `suma/2` dice `suma/3`.

Las pruebas verifican que los once archivos de *Inscripciones* no producen
avisos. Un encabezado de dos líneas, como `%!  p(+X)` seguido de
`%!      is det.`, deja en la segunda un texto vacío antes de `is`, que
`term_string/2` leería como `end_of_file`: esa línea se descarta.

## Ejercicio 6

Una declaración `meta_predicate` no basta: `predicate_property/2` no informa
la declaración de un predicado que no existe en el módulo, y
`declarar_meta/1` lo declara `dynamic` antes:

<!-- ejemplo: capitulo-59/soluciones_meta.pl predicado: declarar_metas/1 declarar_meta/1 -->
```prolog
%!  declarar_metas(+Leidos:list) is det.
%
%   Declara en el módulo externo cada declaración meta_predicate de
%   Leidos.
declarar_metas(Leidos) :-
    forall(( member(leido((:- meta_predicate(E)), _, _, _), Leidos),
             lista_de_especificaciones(E, Ds),
             member(D, Ds) ),
           declarar_meta(D)).

%!  declarar_meta(+Declaracion) is det.
%
%   Declara Declaracion en el módulo externo. El predicado se declara
%   dynamic antes: predicate_property/2 no informa la declaración de un
%   predicado que no existe.
declarar_meta(Declaracion) :-
    functor(Declaracion, Nombre, Aridad),
    dynamic(externo:Nombre/Aridad),
    meta_predicate(externo:Declaracion).
```

`texto_con_meta/1` es un programa donde `p/0` llama a `q/1` solo a través de
`aplicar/2`, declarada `aplicar(1, ?)`. `soluciones_meta.pl` lo agrega a
`clausulas/2` y a `raices/2` con el nombre `con_meta`, con `p/0` como punto
de entrada; sus cláusulas se obtienen después de declarar sus metallamadas.
Sin la declaración, `q/1` no se alcanza desde `p/0`; con ella, sí:

```prolog
?- no_usados(con_meta, Ps).
Ps = [].
```

La prueba `ejercicio_6` mide los dos casos en el mismo proceso, antes y
después de declarar: `[q/1]` y `[]`.

## Ejercicio 7

<!-- ejemplo: capitulo-59/soluciones_meta.pl predicado: metaargumentos/3 variable_llamada/3 -->
```prolog
%!  metaargumentos(+Clausulas:list, +PI, -Declaracion) is semidet.
%
%   Declaracion es la cabeza de PI con un entero en cada argumento que una
%   cláusula de PI llama como meta, el número de argumentos que le agrega,
%   y ? en los demás. Falla si PI no llama a ninguno de sus argumentos.
metaargumentos(Clausulas, Nombre/Aridad, Declaracion) :-
    findall(I-Extra, ( member(C, Clausulas),
                       cabeza_cuerpo(C, Cabeza, Cuerpo),
                       functor(Cabeza, Nombre, Aridad),
                       variable_llamada(Cuerpo, V, Extra),
                       arg(I, Cabeza, A),
                       A == V ),
            Pares),
    Pares \== [],
    numlist(1, Aridad, Is),
    maplist(tipo(Pares), Is, Tipos),
    Declaracion =.. [Nombre|Tipos].

%!  variable_llamada(+Cuerpo, -V, -Extra:integer) is nondet.
%
%   Cuerpo llama como meta a la variable V con Extra argumentos más:
%   directamente, dentro de una construcción de control o como argumento de
%   una metallamada. Como en llamado_por_meta/2, distinct/2 descarta lo que
%   dos cláusulas de meta_argumento/3 repiten.
variable_llamada(G, V, Extra) :-
    (   var(G)
    ->  V = G,
        Extra = 0
    ;   partes_de_control(G, Partes)
    ->  member(P, Partes),
        variable_llamada(P, V, Extra)
    ;   distinct(A-E0, meta_argumento(G, A, E0)),
        (   var(A)
        ->  V = A,
            Extra = E0
        ;   E0 == 0,
            variable_llamada(A, V, Extra)
        )
    ).
```

```prolog
?- metas_inferidas(inscripciones, Ds).
Ds = [responder(0)].

?- declarar_inferidas(inscripciones), no_usados(inscripciones, Ps).
Ps = [].
```

`metas_inferidas/2` y `declarar_inferidas/1` son las formas de
`metas_inferidas_de/2` y `declarar_inferidas_de/1` que reciben el nombre del
programa. La declaración inferida es la que el curso agregó después al
`api.pl` del [capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md); el análisis lee la copia anterior, en
`ejemplos/capitulo-59/caso/`.

`responder/1` llama a su argumento como la condición de un condicional
dentro de `catch/3`: `variable_llamada/3` entra en el argumento de
`catch/3` porque es una metallamada, y en el condicional porque es una
construcción de control. La inferencia mira un nivel: un predicado que pasa
su argumento a otro predicado inferido como metallamada no se infiere hasta
repetir el cálculo, y un argumento que se llama dentro de una expresión
lambda de `library(yall)`, como el de `informe/3` en `informes.pl`, no se
ve. `informe/3` tiene su declaración escrita.

## Ejercicio 8

Un predicado espiado escribe su línea `+` al terminar la prueba de su
cuerpo, de modo que las llamadas internas terminan antes:

```prolog
?- espiar(inversa/2), perfil(inversa([a, b], R), X, _).
+ inversa([], [])
+ inversa([b], [b])
+ inversa([a, b], [b, a])
R = [b, a],
X = exito.
```

## Ejercicio 9

<!-- ejemplo: capitulo-59/soluciones_perfil.pl predicado: resolver_desde/2 sin_recorrer/3 -->
```prolog
%!  resolver_desde(+Meta, +Desde) is nondet.
%
%   Meta se prueba como con resolver/1 de perfil.pl, dentro de una cláusula
%   del predicado Desde, y se anota cada arco que se recorre.
resolver_desde(true, _).
resolver_desde((A, B), Desde) :-
    resolver_desde(A, Desde),
    resolver_desde(B, Desde).
resolver_desde((C -> T ; E), Desde) :-
    (   resolver_desde(C, Desde)
    ->  resolver_desde(T, Desde)
    ;   resolver_desde(E, Desde)
    ).
resolver_desde((A ; B), Desde) :-
    A \= (_ -> _),
    (   resolver_desde(A, Desde)
    ;   resolver_desde(B, Desde)
    ).
resolver_desde(\+ A, Desde) :-
    \+ resolver_desde(A, Desde).
resolver_desde(G, _) :-
    sistema(G),
    ejecutar(G).
resolver_desde(G, Desde) :-
    del_programa(G),
    indicador(G, P),
    anotar(Desde, P),
    clause(G, Cuerpo),
    resolver_desde(Cuerpo, P).

%!  sin_recorrer(+Meta, +PIs:list, -Arcos:list(pair)) is det.
%
%   Arcos son los arcos entre los predicados PIs que el programa tiene y la
%   ejecución de Meta no recorre.
sin_recorrer(Meta, PIs, Arcos) :-
    clausulas_del_programa(PIs, Clausulas),
    findall(P-Q, ( llama_de(Clausulas, P, Q),
                   memberchk(Q, PIs) ),
            Estaticos0),
    sort(Estaticos0, Estaticos),
    arcos_usados(Meta, Usados),
    ord_subtract(Estaticos, Usados, Arcos).
```

```prolog
?- arcos_usados(inversa([a], R), Arcos).
R = [a],
Arcos = ['<consulta>'-inversa/2, inversa/2-concatenar/3, inversa/2-inversa/2].

?- sin_recorrer(inversa([a], _), [inversa/2, concatenar/3], Arcos).
Arcos = [concatenar/3-concatenar/3].
```

Con un elemento, la única concatenación es `concatenar([], [a], R)`, que
usa la primera cláusula: la llamada recursiva de la segunda no se recorre.
Una prueba que solo invirtiera listas de un elemento dejaría esa cláusula
sin probar; con dos elementos, todos los arcos se recorren. El grafo
estático dice lo que el programa puede hacer; el dinámico, lo que una
ejecución hizo, y la diferencia es lo que las pruebas no cubren.

## Ejercicio 10

<!-- ejemplo: capitulo-59/soluciones_revision.pl predicado: raices_consultadas_de/2 no_usados_del_ejemplo/2 -->
```prolog
%!  raices_consultadas_de(+Leidos:list, -Raices:list) is det.
%
%   Raices son los predicados que llaman las consultas escritas en los
%   comentarios %?- de Leidos, ordenados.
raices_consultadas_de(Leidos, Raices) :-
    findall(PI, ( member(leido(_, _, _, Cs), Leidos),
                  member(C, Cs),
                  split_string(C, "\n", "", Lineas),
                  member(Linea, Lineas),
                  string_concat("%?- ", Texto, Linea),
                  catch(term_string(Consulta, Texto, [module(externo)]),
                        error(syntax_error(_), _), fail),
                  metas(Consulta, Metas),
                  member(M, Metas),
                  indicador(M, PI) ),
            PIs),
    sort(PIs, Raices).

%!  no_usados_del_ejemplo(+Archivo, -Ps:list) is det.
%
%   Ps son los predicados de Archivo, una ruta o una especificación, que no
%   se alcanzan ni desde sus puntos de entrada ni desde sus consultas %?-.
no_usados_del_ejemplo(Archivo, Ps) :-
    absolute_file_name(Archivo, Ruta, [file_type(prolog), access(read)]),
    leer_archivo(Ruta, Leidos),
    programa(Leidos, Clausulas, Raices0),
    raices_consultadas_de(Leidos, Raices1),
    append(Raices0, Raices1, Raices),
    no_usados_de(Clausulas, Raices, Ps).
```

```prolog
?- raices_consultadas(ejemplos('capitulo-33/experto.pl'), Rs).
Rs = [caso/2, como/2, identificar/2, por_que_no/2].

?- no_usados_del_ejemplo(ejemplos('capitulo-33/experto.pl'), Ps).
Ps = [consultar/1].
```

`raices_consultadas/2` lee un archivo y llama a `raices_consultadas_de/2`;
como `no_usados_del_ejemplo/2`, recibe una ruta o una especificación de
archivo, como `ejemplos('capitulo-33/experto.pl')`.

Sin las consultas, el único punto de entrada de `experto.pl` es
`'<carga>'/0`, y ninguno de sus veinte predicados se alcanza. Con ellas,
queda `consultar/1`: la consulta interactiva que pregunta las
observaciones al usuario, que el archivo no incluye entre sus consultas de
ejemplo porque espera respuestas por la entrada.

## Ejercicio 11

<!-- ejemplo: capitulo-59/soluciones.pl predicado: capas_de/2 componente_de/3 -->
```prolog
%!  capas_de(+Clausulas:list, -Capas:list(list)) is det.
%
%   Capas son las componentes fuertemente conexas del grafo, todas, en un
%   orden en que cada una llama solo a las que vienen después: el orden
%   topológico del grafo condensado.
capas_de(Clausulas, Capas) :-
    grafo(Clausulas, Grafo),
    transitive_closure(Grafo, Clausura),
    vertices(Grafo, Vs),
    maplist(componente_de(Clausura), Vs, Cs0),
    sort(Cs0, Componentes),
    edges(Grafo, Arcos),
    findall(CP-CQ, ( member(P-Q, Arcos),
                     componente_de(Clausura, P, CP),
                     componente_de(Clausura, Q, CQ),
                     CP \== CQ ),
            ArcosC),
    vertices_edges_to_ugraph(Componentes, ArcosC, Condensado),
    top_sort(Condensado, Capas).

%!  componente_de(+Clausura, +P, -Componente:list) is det.
%
%   Componente es la lista ordenada de P y los predicados que P alcanza y
%   lo alcanzan, según la clausura transitiva del grafo.
componente_de(Clausura, P, Componente) :-
    neighbours(P, Clausura, SP),
    findall(Q, ( member(Q, SP),
                 neighbours(Q, Clausura, SQ),
                 ord_memberchk(P, SQ) ),
            Qs),
    sort([P|Qs], Componente).
```

```prolog
?- capas(notas, Capas), length(Capas, N), last(Capas, U).
Capas = [[informe/0], [varianza/2], [alumnos/1], [mejor/1], [mostrar/1], [desvio2/3], [promedo/2], [... / ...], [...]|...],
N = 12,
U = [suma/2].
```

El programa de notas tiene doce componentes: diez de un predicado y una de
dos, `longitud_impar/1` y `longitud_par/1`, que queda entre las últimas.
`informe/0` y `varianza/2` van primero porque nadie los llama, y `suma/2`,
que no llama a otro predicado del programa, va al final. El grafo sin
condensar hace fallar a `top_sort/2`, como verifica la prueba
`ejercicio_11_ciclos`: `suma/2` es su propio sucesor.

## Ejercicio 12

`insertar_archivo/3` lee las cláusulas con `leer_clausulas/2` del editor,
que se detiene en `end` o en el fin del archivo, y las inserta con el mismo
comando que `i`:

<!-- ejemplo: capitulo-59/soluciones_editor.pl predicado: insertar_archivo/3 -->
```prolog
%!  insertar_archivo(+Archivo, +Estado0, -Estado) is det.
%
%   Estado es Estado0 con las cláusulas de Archivo insertadas después del
%   cursor, como con el comando i, y guardadas en la base. Las cláusulas se
%   leen hasta end o hasta el fin del archivo.
insertar_archivo(Archivo, Estado0, Estado) :-
    setup_call_cleanup(open(Archivo, read, In, [encoding(utf8)]),
                       leer_clausulas(In, Clausulas),
                       close(In)),
    comando(i(Clausulas), Estado0, Estado),
    grabar(Estado).
```

Para usarlo en la sesión basta una cláusula más de `ejecutar_comando/4`,
antes de la última, que es la que trata los comandos de `comando/3`:

```prolog
ejecutar_comando(f(Archivo), _, Estado0, Estado) :-
    !,
    insertar_archivo(Archivo, Estado0, Estado).
```

Como en el libro, el nombre del archivo no se verifica antes de abrirlo: un
archivo que no existe produce el error de `open/4`. Las pruebas de
`soluciones_editor.plt` insertan dos cláusulas desde un archivo temporal,
con el cursor en la primera cláusula, y verifican el orden resultante y que
un archivo vacío no cambia nada.
