# El plan sobre una carpeta real, el programa completo y los propietarios

Esta página continúa el [capítulo 57](index.md) después de la
[sección 57.4](index.md#574-version-3-del-significado-al-plan), con las
secciones [57.5](#575-version-4-el-plan-sobre-una-carpeta-real) a
[57.7](#577-propietarios-y-archivos-compartidos): la versión 4 de las órdenes,
`sistema.pl`, que lee el modelo de una carpeta real y realiza el plan sobre
ella; la versión 5, el programa completo, que conversa en la terminal; y los
propietarios y los archivos compartidos. `sistema.pl` está en
`ejemplos/capitulo-57/`, con sus pruebas, y carga `plan.pl` y `procesos.pl`
del [capítulo 29](../capitulo-29-programas-de-linea-de-comandos/index.md).

## 57.5 Versión 4: el plan sobre una carpeta real

`sistema.pl` agrega los bordes con el disco. `leer_modelo/2` recorre la
carpeta de trabajo con los predicados de archivos del
[capítulo 28](../capitulo-28-archivos-streams-y-formatos/index.md#284-archivos-y-directorios)
y construye el modelo: `directory_files/2` da los nombres de cada carpeta,
`exists_directory/1` separa las subcarpetas, que se recorren a su vez, y
`size_file/2` y `time_file/2` dan el tamaño y la fecha de cada archivo, que
`format_time/3` escribe como `2026-09-20`:

<!-- ejemplo: capitulo-57/sistema.pl predicado: leer_modelo/2 entrada/3 -->
```prolog
%!  leer_modelo(+Raiz, -Modelo:list) is det.
%
%   Modelo son las carpetas y los archivos que hay debajo de la carpeta
%   Raiz, ordenados, con rutas relativas a Raiz. La fecha de un archivo es
%   la de su última modificación, en la zona horaria local.
leer_modelo(Raiz, Modelo) :-
    findall(E, entrada(Raiz, ".", E), Es),
    msort(Es, Modelo).

%!  entrada(+Raiz, +Rel:string, -E) is nondet.
%
%   E es una carpeta o un archivo que está debajo de la carpeta Rel.
entrada(Raiz, Rel, E) :-
    ruta_real(Raiz, Rel, Dir),
    directory_files(Dir, Nombres),
    member(N0, Nombres),
    \+ memberchk(N0, ['.', '..']),
    atom_string(N0, N),
    dentro(Rel, N, R),
    directory_file_path(Dir, N0, Abs),
    (   exists_directory(Abs)
    ->  (   E = carpeta(R)
        ;   entrada(Raiz, R, E)
        )
    ;   size_file(Abs, B),
        time_file(Abs, T),
        format_time(string(F), '%F', T),
        E = archivo(R, B, F)
    ).
```

Cada ruta del plan se convierte en una ruta absoluta con `ruta_real/3`,
que la resuelve con `absolute_file_name/3` relativa a la carpeta de trabajo
y comprueba que el resultado quede dentro de ella. Es una segunda
verificación, independiente de la del planificador: si una ruta insegura
llegara hasta aquí por un error del planificador o de quien lo extienda,
se detiene con un error de permiso antes de tocar el disco:

<!-- ejemplo: capitulo-57/sistema.pl predicado: ruta_real/3 -->
```prolog
%!  ruta_real(+Raiz, +R:string, -Abs:atom) is det.
%
%   Abs es la ruta absoluta de R dentro de la carpeta Raiz.
%
%   @error permission_error(acceder, ruta, R) si Abs queda fuera de Raiz.
ruta_real(Raiz, R, Abs) :-
    absolute_file_name(Raiz, RaizAbs, [file_type(directory)]),
    absolute_file_name(R, Abs, [relative_to(RaizAbs)]),
    atom_concat(RaizAbs, '/', Prefijo),
    (   (   Abs == RaizAbs
        ;   sub_atom(Abs, 0, _, _, Prefijo)
        )
    ->  true
    ;   permission_error(acceder, ruta, R)
    ).
```

`ejecutar_plan/6` realiza cada acción y devuelve un resultado por acción.
Las copias usan `copy_file/2`, de `library(filesex)`, y las mudanzas,
`rename_file/2`. Antes de borrar, pregunta; la respuesta es la línea que
devuelve `call(Leer, Linea)`, y así las pruebas le pasan una cadena y el
programa terminado, el teclado. `ejecutar/1` corre un programa Prolog en
otro proceso con `salida_de/4`, del
[capítulo 29](../capitulo-29-programas-de-linea-de-comandos/index.md#296-procesos-externos),
que usa `process_create/3`; la opción `-t halt` hace que `swipl` termine
aunque el programa no lo haga. En modo `simulacion`, ninguna acción
modifica el disco: cada una se devuelve descrita, `simulada(Accion)`. Es
la idea del ejercicio de Covington que muestra el comando antes de
ejecutarlo, llevada a no ejecutarlo. Cada cláusula del modo `real` corta
después de la cabeza: la acción ya eligió la cláusula, y como `realizar/6`
es `multifile` y otros archivos le agregan cláusulas, sin el corte quedaría
pendiente la alternativa de probarlas:

<!-- ejemplo: capitulo-57/sistema.pl predicado: realizar/6 -->
```prolog
%!  realizar(+Modo, +Raiz, +Leer, +Salida, +Accion, -Resultado) is det.
%
%   Resultado dice qué pasó al realizar Accion.
realizar(_, _, _, _, informar(Hecho), Hecho) :-
    !.
realizar(_, _, _, _, rechazo(Motivo), rechazo(Motivo)) :-
    !.
realizar(_, _, _, _, salir, salir) :-
    !.
realizar(simulacion, _, _, _, Accion, simulada(Accion)) :-
    !.
realizar(real, Raiz, _, _, copiar(R, D), copiado(R, D)) :-
    !,
    ruta_real(Raiz, R, De),
    ruta_real(Raiz, D, A),
    copy_file(De, A).
realizar(real, Raiz, _, _, mover(R, D), movido(R, D)) :-
    !,
    ruta_real(Raiz, R, De),
    ruta_real(Raiz, D, A),
    rename_file(De, A).
realizar(real, Raiz, Leer, Out, borrar(R), Resultado) :-
    !,
    ruta_real(Raiz, R, Abs),
    format(Out, "¿Quieres borrar ~s? (s/n) ", [R]),
    flush_output(Out),
    call(Leer, Respuesta),
    (   afirmativa(Respuesta)
    ->  delete_file(Abs),
        Resultado = borrado(R)
    ;   Resultado = conservado(R)
    ).
realizar(real, Raiz, _, _, ejecutar(R), salida(R, Estado, Lineas)) :-
    !,
    ruta_real(Raiz, R, Abs),
    salida_de(swipl, ['-t', halt, Abs], Texto, Estado),
    split_string(Texto, "\n", "\r", Lineas0),
    exclude(==(""), Lineas0, Lineas).
```

Las pruebas no pueden usar una carpeta fija: la ejecución la modifica, y
las fechas de los archivos dependerían del momento en que se copiaron.
`crear_muestra/2` hace lo inverso de `leer_modelo/2`: escribe un modelo en
una carpeta, con el tamaño exacto de cada archivo y su fecha fijada con
`set_time_file/3`. Cada prueba de `sistema.plt` crea una carpeta nueva con
`tmp_file/2` y `make_directory/1`, escribe en ella `modelo_ejemplo/1` y la
borra al terminar con `delete_directory_and_contents/1`. La primera prueba
comprueba que leer lo escrito devuelve exactamente el modelo de ejemplo:

```prolog
test(ida_y_vuelta, [ setup(muestra(D)),
                     cleanup(delete_directory_and_contents(D)) ]) :-
    leer_modelo(D, M),
    modelo_ejemplo(M).
```

**Lo que falta.** Los resultados son términos, y el programa todavía no
conversa.

## 57.6 Versión 5: el programa completo

`ordenes/4` es el bucle: escribe `> `, lee una línea con `leer_linea/4` y la
atiende. `atender/6` pasa la línea por las tres versiones anteriores; si la
gramática no la entiende, responde con un ejemplo y, con la opción
`registro(Archivo)`, agrega la línea a ese archivo: es el ejercicio de
Covington que guarda las frases no reconocidas para ampliar la gramática
después con las que los usuarios escriben de verdad:

<!-- ejemplo: capitulo-57/ordenes.pl predicado: atender/6 -->
```prolog
%!  atender(+Raiz, +Opciones:list, +Entrada, +Salida, +Linea:string,
%!          -Seguir) is det.
%
%   Entiende Linea, la cumple y escribe las respuestas; Seguir es no
%   después de «salir», y si en otro caso.
atender(Raiz, Opciones, In, Out, Linea, Seguir) :-
    (   entender(Linea, Orden)
    ->  leer_modelo(Raiz, Modelo),
        planificar(Orden, Modelo, Plan),
        (   option(simulacion(true), Opciones)
        ->  Modo = simulacion
        ;   Modo = real
        ),
        ejecutar_plan(Modo, Raiz, Plan, leer_linea(Opciones, In, Out), Out,
                      Resultados),
        forall(member(R, Resultados), decir(Out, R)),
        (   memberchk(salir, Resultados)
        ->  Seguir = no
        ;   Seguir = si
        )
    ;   registrar(Opciones, Linea),
        format(Out, "La orden no se entiende. Prueba, por ejemplo, con ~s~n",
               ["«lista los archivos» o «copia notas.txt a respaldo»."]),
        Seguir = si
    ).
```

Cada resultado se redacta con `oracion/2`. Las respuestas concuerdan con
lo que cuentan, y otra vez la concordancia sale del
[capítulo 55](../capitulo-55-proyecto-traduccion-castellanoingles/index.md):
`cantidad/4` escribe «1 archivo», «3 archivos» o «ningún archivo»
—«ninguna carpeta», si el nombre es femenino— con `numero_es/3`, y
`coincide/2` elige «coincide» o «coinciden» con `numero_verbo/4`. Después
de «no hay ningún archivo que…», el verbo va en subjuntivo, «coincida»:

<!-- ejemplo: capitulo-57/ordenes.pl predicado: coincide/2 cantidad/4 -->
```prolog
%!  coincide(+K:integer, -V:string) is det.
%
%   V es la forma de «coincidir» que concuerda con K archivos: en
%   subjuntivo después de «no hay ningún archivo», y en singular o en
%   plural según K en los demás casos.
coincide(K, V) :-
    (   K =:= 0
    ->  V = "coincida"
    ;   K =:= 1
    ->  numero_verbo(sg, "coincide", "coinciden", V)
    ;   numero_verbo(pl, "coincide", "coinciden", V)
    ).

%!  cantidad(+K:integer, +Lema:atom, +G, -Texto:string) is det.
%
%   Texto es K seguido del nombre Lema, de género G, en el número que
%   corresponde: «ningún archivo», «1 archivo», «3 archivos».
cantidad(0, Lema, G, Texto) :-
    !,
    (   G == m
    ->  D = "ningún"
    ;   D = "ninguna"
    ),
    format(string(Texto), "~s ~w", [D, Lema]).
cantidad(1, Lema, _, Texto) :-
    !,
    format(string(Texto), "1 ~w", [Lema]).
cantidad(K, Lema, _, Texto) :-
    atom_string(Lema, Singular),
    numero_es(pl, Singular, Plural),
    format(string(Texto), "~d ~s", [K, Plural]).
```

Con la opción `simulacion(true)`, el programa lee la carpeta, planifica y
responde las preguntas, pero cada acción que modificaría algo se describe
en condicional. La prueba `simulacion` de `ordenes.plt` comprueba que,
después de esta sesión, el modelo leído del disco sigue siendo el de
ejemplo:

```text
Escribe una orden en castellano; «salir» termina.
Modo simulación: ningún archivo se modifica.
> Mueve los archivos de informes a respaldo
informes/acta.txt pasaría a ser respaldo/acta.txt.
informes/notas.txt pasaría a ser respaldo/notas.txt.
informes/resumen.pdf pasaría a ser respaldo/resumen.pdf.
> Borra todos los archivos
Se borraría borrador.tmp, después de confirmarlo.
Se borraría hola.pl, después de confirmarlo.
Se borraría notas.txt, después de confirmarlo.
> Ejecuta hola.pl
Se ejecutaría hola.pl.
```

«Borra todos los archivos» borra solo los de la carpeta de trabajo, no los
de sus subcarpetas: `archivos(".", todos)` nombra lo que está directamente
en ella. El modo simulación es la manera de averiguar qué hará una orden
antes de darla.

## 57.7 Propietarios y archivos compartidos

El proyecto 16 de Clocksin y Mellish pide más que el tamaño y la fecha de
un archivo: pregunta de quién es —«How many files does David own?»— y si
dos personas lo comparten —«Does Chris share PROG.MAC with David?»—. Las
versiones anteriores no pueden responder porque el modelo no registra
dueños, y SWI-Prolog no tiene un predicado portable que lea el dueño de un
archivo: en Windows y en Unix los permisos se representan de maneras
distintas. `propietarios.pl` responde esas preguntas sobre un modelo que
los registra, con dos clases de términos nuevas:

<!-- ejemplo: capitulo-57/propietarios.pl predicado: modelo_con_usuarios/1 -->
```prolog
%!  modelo_con_usuarios(-Modelo:list) is det.
%
%   Modelo es el modelo de ejemplo con los dueños de sus archivos y los
%   permisos que comparten algunos de ellos.
modelo_con_usuarios(Modelo) :-
    modelo_ejemplo(M0),
    append(M0,
           [ propietario("borrador.tmp", "david"),
             propietario("hola.pl", "chris"),
             propietario("informes/acta.txt", "david"),
             propietario("informes/notas.txt", "david"),
             propietario("informes/resumen.pdf", "bill"),
             propietario("notas.txt", "chris"),
             compartido("notas.txt", "david"),
             compartido("informes/acta.txt", "bill")
           ],
           Modelo).
```

El archivo no modifica ningún otro: agrega cláusulas a `pedido//1`,
`plan/3` y `oracion/2`, que la gramática, el planificador y las respuestas
declaran `multifile`. La gramática gana cuatro preguntas; los nombres de
las personas los reconoce `nombre//1`, como los de los archivos:

<!-- ejemplo: capitulo-57/propietarios.pl fragmento: pedido(contar_de(U)) .. nombre(U2). -->
```prolog
pedido(contar_de(U)) -->
    ["cuantos"],
    sustantivo(archivo, _, pl),
    ["tiene"],
    nombre(U).
pedido(listar_de(U)) -->
    ["que"],
    sustantivo(archivo, _, pl),
    ["tiene"],
    nombre(U).
pedido(propietario(archivo(R))) -->
    ["de", "quien", "es"],
    nombre(R).
pedido(comparten(archivo(R), U1, U2)) -->
    ["comparte"],
    nombre(U1),
    nombre(R),
    ["con"],
    nombre(U2).
```

El planificador responde con un hecho para `informar/1`, como en las demás
preguntas. Una persona que no aparece en el modelo es un rechazo, y un
archivo que no existe también, por `seleccion/3`. Dos personas comparten un
archivo cuando las dos tienen **acceso** a él: una es la dueña y el archivo
se comparte con la otra, o se comparte con las dos:

<!-- ejemplo: capitulo-57/propietarios.pl predicado: usuario/2 acceso/3 -->
```prolog
%!  usuario(+U:string, +Modelo:list) is det.
%
%   U es el dueño de un archivo de Modelo, o alguien con quien se comparte
%   uno.
%
%   @throws rechazo(no_es_usuario(U)) si U no aparece en Modelo.
usuario(U, M) :-
    (   (   memberchk(propietario(_, U), M)
        ;   memberchk(compartido(_, U), M)
        )
    ->  true
    ;   throw(rechazo(no_es_usuario(U)))
    ).

%!  acceso(+R:string, +U:string, +Modelo:list) is semidet.
%
%   U puede usar el archivo R: es su dueño, o R se comparte con U.
acceso(R, U, M) :-
    (   memberchk(propietario(R, U), M)
    ->  true
    ;   memberchk(compartido(R, U), M)
    ).
```

`responder_modelo/2` encadena las tres etapas sobre el modelo con usuarios:

```prolog
?- responder_modelo("¿Cuántos archivos tiene David?", R).
R = "David tiene 3 archivos.".

?- responder_modelo("¿Comparte Chris notas.txt con David?", R).
R = "Sí: Chris y David pueden usar notas.txt.".

?- responder_modelo("¿Comparte Bill notas.txt con David?", R).
R = "No: Bill y David no comparten notas.txt.".

?- responder_modelo("¿Cuántos archivos tiene Ana?", R).
R = "Ana no tiene archivos ni permisos en la carpeta.".
```

Cargado junto con el programa terminado, `propietarios.pl` entiende las
mismas preguntas en `ordenes/1`, pero el modelo que `leer_modelo/2` lee del
disco no tiene dueños: «¿De quién es notas.txt?» responde que no tiene
dueño registrado. La separación entre el modelo y el disco de la
[sección 57.4](index.md#574-version-3-del-significado-al-plan) hace que el
planificador no cambie si los dueños se leen de otra fuente, como un
archivo de texto o un comando del sistema operativo; solo cambia el
predicado que arma el modelo.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; `planificar/3`, `leer_modelo/2` y `ejecutar_plan/6` son `det`, `entender/2` y `traducir/2` son `semidet`, y las gramáticas y `comodin/2` son `nondet` |
    | C4 | las elecciones del planificador y de la redacción usan `->` o cortan después de decidir, y cada cláusula de `realizar/6` en modo `real` corta después de la cabeza; `pasa/2` envuelve con `once/1` el `comodin/2` no determinista, y las pruebas, que fallan si queda una alternativa pendiente, lo confirman |
    | C5 | una orden imposible produce un rechazo con su motivo, no un fallo; una ruta que sale de la carpeta produce un error de permiso en `ruta_real/3` |
    | C6 | la gramática y el planificador son puros; el disco solo se toca en `sistema.pl`, y la lectura y la escritura están en `ordenes.pl` y en la confirmación de `sistema.pl`, que reciben los streams como argumentos |
    | C7 | 139 pruebas en seis archivos, y 39 más en las soluciones: cada orden con su significado, las concordancias rechazadas, cada plan y cada rechazo, y una carpeta temporal creada y borrada por cada prueba que toca el disco |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios extienden los programas: cada solución es un
archivo que carga los del capítulo, sin modificarlos, y agrega cláusulas a
los predicados que el capítulo declara `multifile`.

9. ★ **(1)** Predecir en qué etapa se detiene cada orden (la gramática, el
   planificador o `ruta_real/3`) y con qué mensaje: «Copia notas.txt a ..» ·
   «Lista los archivos de informes/../..» · «Borra /etc/passwd» · «Copia
   notas.txt a c:/x» · «Busca ../*.txt» · «Copia notas.txt de .. a
   respaldo». ¿Hay alguna orden que la gramática acepte, el planificador
   deje pasar y `ruta_real/3` detenga?
10. **(2)** Agregar la pregunta «¿Cuántos archivos hay en total?», que
    cuenta los archivos de todas las subcarpetas. ¿Por qué hay que declarar
    «total» como palabra reservada?
11. **(2)** Al estilo del proyecto 16 de Clocksin y Mellish, agregar la
    pregunta «¿Cuál es el archivo más grande de informes?», con su plan y su
    respuesta. ¿Qué responde para una carpeta vacía?
12. **(2)** Agregar «Ejecuta eco.pl con uno dos», que pasa argumentos al
    programa, con su plan, su realización y su descripción en modo
    simulación. Probarla con un programa que escribe los argumentos que
    recibe.
13. **(2)** Agregar a `propietarios.pl`, en un archivo aparte, la pregunta
    «¿Qué archivos comparte Chris con David?», que responde con la lista de
    los archivos a los que las dos personas tienen acceso.

## Resumen

| | |
|---|---|
| **sistema de plantillas** | reglas de simplificación sobre partes de la frase y plantillas que reconocen la frase entera |
| **significado** | el término que dice qué pide la orden, independiente de cómo se dijo y de lo que hay en el disco |
| **plan** | la lista de acciones que cumplen la orden sobre un modelo de la carpeta, o un rechazo con su motivo |
| **carpeta de trabajo** | la única carpeta que el programa puede tocar; se verifica al planificar y al resolver cada ruta |
| **modo simulación** | el plan se describe en lugar de realizarse |
| **dueños y permisos** | términos nuevos del modelo, `propietario/2` y `compartido/2`, y preguntas agregadas por los predicados `multifile` |
| `palabras/2`, `simplifica/2`, `plantilla/2`, `traducir/2` | la versión 1: las palabras, las reglas de simplificación, las plantillas |
| `entender/2`, `orden//1`, `objeto//2`, `nombre//1` | la gramática de órdenes |
| `planificar/3`, `seleccion/3`, `destino/5`, `comodin/2` | el planificador |
| `leer_modelo/2`, `ruta_real/3`, `ejecutar_plan/6`, `crear_muestra/2` | el modelo leído del disco y la ejecución |
| `ordenes/1`, `ordenes/4`, `oracion/2`, `cantidad/4` | el bucle y las respuestas |
| `modelo_con_usuarios/1`, `acceso/3`, `responder_modelo/2` | los propietarios y los archivos compartidos |
| `sub_term/2` | cada subtérmino de un término, por retroceso |
| `copy_file/2`, `set_time_file/3` | de `library(filesex)`: copiar un archivo, cambiar su fecha de modificación |
| `size_file/2`, `time_file/2`, `rename_file/2` | el tamaño y la fecha de modificación de un archivo; cambiar su nombre |
| `flush_output/1` | escribe lo que un stream tiene pendiente, antes de esperar una respuesta |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Reglas de condición y acción sobre una base de datos | [capítulo 61](../capitulo-61-proyecto-interprete-dirigido-patrones/index.md) |
| Herramientas de texto al estilo de los programas de la terminal | [capítulo 84](../capitulo-84-proyecto-procesamiento-textos/index.md) |
| Preguntas en castellano sobre una base de datos, traducidas a formas lógicas | [capítulo 88](../capitulo-88-proyecto-preguntas-en-castellano/index.md) |

## Referencias

- Michael A. Covington, *Natural Language Processing for Prolog Programmers*,
  Prentice Hall, 1994; edición digital del autor,
  <https://www.covingtoninnovations.com/books/NLPPP.pdf>. Apartado 2.2, «DOS
  Commands in English»: los ejercicios que muestran el comando antes de
  ejecutarlo y guardan las frases no reconocidas en un archivo, de donde vienen
  el modo simulación y el registro.
- William F. Clocksin y Christopher S. Mellish, *Programming in Prolog*, 5.ª
  edición, Springer, 2003. Apartado 11.2, «Advanced Projects», proyecto 16: una
  interfaz en lengua natural al sistema de archivos que responde preguntas sobre
  sus propiedades, como la cantidad de archivos y la fecha de un cambio. El
  [ejercicio 11](#ejercicios) toma esa idea, y la
  [sección 57.7](#577-propietarios-y-archivos-compartidos), sus preguntas sobre
  el dueño de un archivo y los archivos compartidos; el libro no tiene edición
  legal en línea.
- SWI-Prolog, *Manual de referencia*, las secciones
  [«File System Interaction»](https://www.swi-prolog.org/pldoc/man?section=files)
  y
  [«library(filesex): Extended operations on files»](https://www.swi-prolog.org/pldoc/man?section=filesex).
  La versión 4 lee el modelo de la carpeta y ejecuta el plan con los predicados
  que documentan: `directory_files/2`, `size_file/2`, `time_file/2`,
  `copy_file/2`, `rename_file/2` y `delete_file/1`.

El código del capítulo es propio del curso: las plantillas, la gramática,
el planificador, la ejecución y las respuestas se escribieron para él; de
las fuentes se toman las ideas, no los programas.
