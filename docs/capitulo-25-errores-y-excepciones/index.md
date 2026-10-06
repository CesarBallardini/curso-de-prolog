# Capítulo 25 — Errores y excepciones

Una consulta de Prolog termina de tres formas, no de dos: tiene éxito, falla,
o produce un **error**. La parte I casi no se ocupó de la tercera, porque los
programas del curso recibían siempre los datos que esperaban. Un programa que
otros usan no puede suponerlo: recibe un texto donde esperaba un número, un
legajo que no existe, una lista vacía donde hacía falta al menos un elemento.
Si responde `false.` en esos casos, quien lo usa no puede distinguir «no» de
«no entendí la pregunta».

Este capítulo presenta los errores de Prolog: los términos que los describen,
`catch/3` para capturarlos, `throw/1` y `library(error)` para producirlos, la
decisión entre fallar y producir un error, `setup_call_cleanup/3` para liberar
recursos pase lo que pase, y los mensajes para el usuario. El proyecto valida
sus argumentos y convierte los errores en respuestas del lenguaje de comandos.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- leer un término de error ISO y un mensaje de error de SWI-Prolog;
- capturar un error con `catch/3`, solo el que corresponde, y dejar pasar los
  demás;
- producir errores bien formados con `must_be/2` y `library(error)`;
- decidir, para cada predicado, cuándo fallar y cuándo producir un error;
- liberar un recurso con `setup_call_cleanup/3`, y escribir mensajes propios.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **0:51 h**.
    Resolver los 6 ejercicios marcados con ★: **1:53 h**.
    Resolver los 14 ejercicios del final: **3:41 h**.

## 25.1 El tercer desenlace

```prolog
?- X is 1/0.
ERROR: Arithmetic: evaluation error: `zero_divisor'
ERROR: In:
ERROR:   [12] _15340 is 1/0
```

`is/2` no puede fallar aquí —fallar diría que no existe ningún `X` igual a
1/0, lo que tampoco es cierto— y no puede dar una respuesta. Produce un
**error**: una **excepción** que interrumpe la ejecución, deshace todo hasta
el primer `catch/3` que la capture, y, si ninguno la captura, llega al
toplevel, que la muestra. El error no es una respuesta: después de él, el
toplevel no ofrece alternativas.

Los predicados predefinidos producen errores en los casos que el
[capítulo 8](../capitulo-08-aritmetica/index.md) mostró: una expresión con una variable sin valor, un átomo donde
iba un número. El [capítulo 14](../capitulo-14-estilo-y-documentacion/index.md) planteó el criterio C5 —error, no falla
silenciosa— para los predicados propios; este capítulo da las herramientas
para cumplirlo.

## 25.2 Los términos de error ISO

Un error es un término, de la forma `error(Formal, Contexto)`. La parte
**formal** dice qué ocurrió, con uno de los términos del estándar ISO; el
**contexto** dice dónde, y su forma depende de la implementación.

| Término formal | Significa | Ejemplo |
|---|---|---|
| `instantiation_error` | un argumento debía estar ligado | `atom_length(X, L)` |
| `type_error(Tipo, Valor)` | Valor no es del tipo esperado | `atom_length(f(x), L)` |
| `domain_error(Dominio, Valor)` | Valor es del tipo, pero está fuera del dominio | una edad de 200 años |
| `existence_error(Clase, Valor)` | no existe | un predicado sin definir |
| `permission_error(Accion, Tipo, Valor)` | la operación no está permitida | redefinir `,`, en el [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md) |
| `evaluation_error(Error)` | una operación aritmética no tiene resultado | `1/0` |
| `representation_error(Limite)` | un valor excede un límite de la implementación | un código de carácter fuera de rango |
| `resource_error(Recurso)` | se agotó un recurso | la pila, en el [capítulo 16](../capitulo-16-rendimiento/index.md) |
| `syntax_error(Descripcion)` | un texto no se puede leer como término | `number_codes(N, "12a")` |

```prolog
?- catch(X is 1/0, E, true).
E = error(evaluation_error(zero_divisor), context((/)/2, _)).
```

## 25.3 `catch/3`

`catch(Objetivo, Patron, Recuperacion)` ejecuta `Objetivo`. Si produce un error
que **unifica** con `Patron`, se ejecuta `Recuperacion` en su lugar; si el
error no unifica, sigue su camino hacia el `catch/3` anterior. Si `Objetivo`
tiene éxito o falla, `catch/3` hace lo mismo: es transparente para las
respuestas y para el retroceso.

<!-- ejemplo: capitulo-25/errores.pl predicado: con_valor_por_omision/3 consulta: catch(edad_de(zoe, E), Error, true). -->
```prolog
%!  con_valor_por_omision(:Objetivo, +PorOmision, -Valor) is det.
%
%   Valor es la primera respuesta de call(Objetivo, Valor), o PorOmision si
%   Objetivo produce un error de existencia. Los demás errores se propagan.
con_valor_por_omision(Objetivo, PorOmision, Valor) :-
    catch(once(call(Objetivo, Valor)),
          error(existence_error(_, _), _),
          Valor = PorOmision).
```

```prolog
?- con_valor_por_omision(edad_de(zoe), 0, V).
V = 0.

?- con_valor_por_omision(edad_de(ana), 0, V).
V = 41.
```

El patrón `error(existence_error(_, _), _)` captura solo los errores de
existencia. Un error de instanciación —`con_valor_por_omision(edad_de(_), 0, V)`—
no unifica con el patrón, y llega hasta el toplevel: es un error del programa
que llama, y ocultarlo detrás de un valor por omisión lo volvería invisible.

!!! example "Patrón 30 — Capturar lo justo y relanzar"
    **Problema.** Un error esperable —un dato que falta, una conversión que
    no se puede hacer— tiene una respuesta razonable, y los demás errores no.

    **Versión ingenua.** `catch(Objetivo, _, Recuperacion)`: captura todo,
    incluidos los errores de programación y la interrupción con Ctrl-C, y los
    convierte en la misma respuesta.

    **Patrón.** Un patrón que describe exactamente el error esperado,
    `error(existence_error(persona, _), _)`, y ninguna captura para los
    demás. Si la recuperación depende de más detalles, capturar con un
    patrón más amplio, examinar el término, y relanzar con `throw/1` lo que no
    corresponde.

    **Cuándo no usarlo.** En el borde más externo de un programa —el bucle
    de un servidor, el `main` de una herramienta—, donde capturar todo,
    informarlo y seguir es exactamente lo que se quiere.

## 25.4 `throw/1`, `must_be/2` y `library(error)`

`throw(Termino)` produce una excepción con cualquier término. Para errores, el
término debe tener la forma `error(Formal, Contexto)`, y `library(error)` tiene
un predicado para cada término formal: `type_error(Tipo, Valor)`,
`domain_error(Dominio, Valor)`, `existence_error(Clase, Valor)`, … Y tiene
`must_be(Tipo, Valor)`, que verifica un tipo y produce el error que
corresponde si no se cumple:

<!-- ejemplo: capitulo-25/errores.pl predicado: edad_de/2 meses/2 consulta: catch(edad_de(zoe, E), Error, true). -->
```prolog
%!  edad_de(+P, -E:integer) is det.
%
%   E es la edad de P. Produce existence_error(persona, P) si P no tiene
%   edad registrada, y un error de instanciación si P no está ligado.
edad_de(P, E) :-
    must_be(atom, P),
    (   edad(P, E0)
    ->  E = E0
    ;   existence_error(persona, P)
    ).

%!  meses(+Anios:integer, -Meses:integer) is det.
%
%   Meses es la cantidad de meses de Anios años. Anios debe ser un entero no
%   negativo.
meses(Anios, Meses) :-
    must_be(nonneg, Anios),
    Meses is Anios * 12.
```

```prolog
?- edad_de(zoe, E).
ERROR: persona `zoe' does not exist
ERROR: In:
ERROR:   [14] throw(error(existence_error(persona,zoe),_19022))

?- meses(tres, M).
ERROR: Type error: `nonneg' expected, found `tres' (an atom)
ERROR: In:
ERROR:   [16] throw(error(type_error(nonneg,tres),_19174))
```

`must_be/2` conoce muchos tipos: `integer`, `atom`, `text`, `list`, `boolean`,
`positive_integer`, `nonneg`, `between(Min, Max)`, `oneof(Lista)`,
`list(Tipo)`, … Una variable sin valor produce un error de instanciación. En
SWI-Prolog 9, un valor del tipo base pero fuera del rango —`must_be(nonneg, -1)`,
`must_be(between(1, 10), 11)`— produce también un `type_error`, no un
`domain_error`; cuando el dominio importa, se verifica aparte y se produce con
`domain_error/2`, como `leer_edad/2`.

!!! example "Patrón 31 — Validar al entrar"
    **Problema.** Un predicado público recibe argumentos de otros módulos o de
    otras personas, y un argumento mal formado produce una falla, o un error
    lejos de su causa.

    **Versión ingenua.** No validar, y dejar que el primer predicado
    predefinido que tropiece con el valor produzca un error que habla de
    `is/2` o de `atom_length/2`.

    **Patrón.** Al principio de cada predicado público, `must_be/2` para cada
    argumento de entrada, según el encabezado; `domain_error/2` o
    `existence_error/2` para lo que el tipo no alcanza a decir. Los predicados
    internos no se validan: confían en el que los llama.

    **Cuándo no usarlo.** En los predicados que funcionan en varios modos: una
    validación de `+` rompe el modo `-`. Y en las relaciones puras, donde un
    tipo incorrecto es simplemente un caso en que la relación no se cumple.

## 25.5 Fallo o error

La decisión entre fallar y producir un error es parte de la interfaz de cada
predicado. SWI-Prolog mismo no es uniforme:

<!-- ejemplo: capitulo-25/errores.pl predicado: leer_edad/2 consulta: leer_edad("41", E). -->
```prolog
%!  leer_edad(+Texto:string, -E:integer) is det.
%
%   E es la edad escrita en Texto. Produce domain_error(edad, Texto) si el
%   texto no es un entero entre 0 y 150.
leer_edad(Texto, E) :-
    string_codes(Texto, Codigos),
    catch(number_codes(N, Codigos), error(syntax_error(_), _),
          N = no_es_un_numero),
    (   integer(N),
        between(0, 150, N)
    ->  E = N
    ;   domain_error(edad, Texto)
    ).
```

```prolog
?- number_string(N, "cuarenta").
false.

?- number_codes(N, `cuarenta`).
ERROR: Syntax error: Illegal number
ERROR: In:
ERROR:   [12] number_codes(_19364,[99,117|...])

?- leer_edad("cuarenta", E).
ERROR: Domain error: `edad' expected, found `"cuarenta"'
ERROR: In:
ERROR:   [14] throw(error(domain_error(edad,"cuarenta"),_19284))
```

`number_string/2`, que convierte entre un número y su texto, falla con un
texto que no es un número; `number_codes/2`, con el mismo texto, produce un
error de sintaxis. `leer_edad/2` captura el error de
sintaxis y lo reemplaza por uno del dominio del programa: quien la llama no
necesita saber qué predicado usó para convertir.

Un criterio práctico para decidir:

- **falla** una consulta sobre los datos que no tiene respuesta: `edad(zoe, E)`
  es una pregunta, y «no hay tal edad» es una respuesta válida;
- **error** un argumento que no cumple el encabezado —un tipo equivocado, una
  variable donde iba un valor— o un dato que el programa necesitaba y no
  existe: `edad_de(zoe, E)` promete una edad, y no puede cumplirlo.

!!! question "Actividad"
    Clasificar como falla o error, y comprobarlo: `atom_number(abc, N).` ·
    `succ(X, 0).` · `arg(x, f(a), A).` · `atom_length(123, L).` ¿Cuál no hace ni
    una cosa ni la otra?

## 25.6 `setup_call_cleanup/3`

Un programa que abre un archivo, una conexión o cualquier recurso debe
cerrarlo, tanto si el trabajo termina bien como si falla o produce un error.
`setup_call_cleanup(Preparar, Objetivo, Limpiar)` lo garantiza: ejecuta
`Preparar`, después `Objetivo`, y `Limpiar` siempre que `Preparar` se haya
cumplido, pase lo que pase con `Objetivo`.

<!-- ejemplo: capitulo-25/limpieza.pl predicado: usar/2 usar_sin_limpieza/2 contar_lineas/2 consulta: contar_lineas("uno\ndos\ntres", N). -->
```prolog
%!  usar(+Recurso, :Objetivo) is semidet.
%
%   Abre Recurso, ejecuta Objetivo una vez y cierra Recurso, pase lo que pase
%   con Objetivo: éxito, falla o error.
usar(Recurso, Objetivo) :-
    setup_call_cleanup(abrir(Recurso),
                       once(Objetivo),
                       cerrar(Recurso)).

%!  usar_sin_limpieza(+Recurso, :Objetivo) is semidet.
%
%   La versión ingenua: si Objetivo falla o produce un error, cerrar/1 no se
%   ejecuta y el recurso queda abierto.
usar_sin_limpieza(Recurso, Objetivo) :-
    abrir(Recurso),
    once(Objetivo),
    cerrar(Recurso).

%!  contar_lineas(+Texto:string, -N:integer) is det.
%
%   N es la cantidad de líneas de Texto, leídas de un stream que se cierra al
%   terminar.
contar_lineas(Texto, N) :-
    setup_call_cleanup(open_string(Texto, Stream),
                       contar_lineas_de(Stream, 0, N),
                       close(Stream)).
```

```prolog
?- catch(usar(r1, X is 1/0), _, true), findall(R, abierto(R), A).
A = [].

?- catch(usar_sin_limpieza(r1, X is 1/0), _, true), findall(R, abierto(R), A).
A = [r1].

?- contar_lineas("uno\ndos\ntres", N).
N = 3.
```

`abrir/1` y `cerrar/1` simulan un recurso con un hecho dinámico. Sin
`setup_call_cleanup/3`, el error de `X is 1/0` salta por encima de `cerrar/1`,
y el recurso queda abierto. `contar_lineas/2` usa un stream de verdad, sobre
una cadena. `open_string/2`, que la [sección 15.7](../capitulo-15-control/index.md#157-bucles-por-falla) usa para probar el menú, abre
el stream; `read_line_to_string(Stream, Linea)` lee la línea siguiente, sin el
salto de línea, y da el átomo `end_of_file` cuando no quedan líneas;
`close(Stream)` cierra el stream y libera lo que ocupa. Con un archivo, el
stream lo da `open(Archivo, read, Stream)`, y el resto no cambia. El
[capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) trata a fondo los streams, los archivos y sus opciones. Como los
streams no están permitidos en SWISH, este ejemplo es solo local.

!!! example "Patrón 32 — Recurso con limpieza garantizada"
    **Problema.** Un recurso —un archivo, un stream, una conexión, un estado
    temporal— se abre, se usa y se cierra, y el uso puede fallar o producir un
    error.

    **Versión ingenua.** Abrir, usar y cerrar en secuencia: si el uso falla o
    produce un error, el cierre no se ejecuta.

    **Patrón.** `setup_call_cleanup(Abrir, Usar, Cerrar)`, con `Usar`
    envuelto en `once/1` si se espera una sola respuesta, para que el recurso
    se cierre al terminar y no quede abierto esperando otra.

    **Cuándo no usarlo.** Cuando la biblioteca ya ofrece un predicado que lo
    hace: `read_file_to_string/3`, `with_output_to/2`, `phrase_from_file/2`.

## 25.7 Mensajes para el usuario

`print_message(Nivel, Termino)` escribe un mensaje en el canal de mensajes, con
un nivel: `error`, `warning`, `informational`. El texto sale del término, a
través de `prolog:message//1`, una gramática a la que cada programa agrega sus
propias reglas. El proyecto lo usa para su advertencia al cargar, que en el
[capítulo 24](../capitulo-24-modulos-y-organizacion/index.md) se escribía con `format/3` en la salida de errores:

<!-- ejemplo: capitulo-25/inscripciones/datos.pl fragmento: comprobar_datos is det .. el alumno o la materia no existen'-[L, M] ]. consulta: alumno(101, Nombre, Carrera, Ingreso). -->
```prolog
%!  comprobar_datos is det.
%
%   Escribe una advertencia por cada inscripción de un alumno o de una
%   materia que no existen. Se ejecuta al cargar el programa.
comprobar_datos :-
    forall(( inscripcion(L, M, _),
             \+ ( alumno(L, _, _, _),
                  materia(M, _, _) ) ),
           print_message(warning, inscripcion_sin_datos(L, M))).

:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto de los mensajes propios de Inscripciones.
prolog:message(inscripcion_sin_datos(L, M)) -->
    [ 'Inscripción de ~w en ~w: el alumno o la materia no existen'-[L, M] ].
```

Separar el término del texto tiene dos ventajas. Las pruebas comparan
términos, que no cambian si se corrige la redacción. Y el texto se puede
traducir o cambiar en un solo lugar: `prolog:message//1` es `multifile`, y
cualquier módulo puede agregarle reglas. Un error no capturado se escribe con
el mismo mecanismo, que es el que produce las líneas `ERROR:` del toplevel.

## 25.8 Leer un mensaje de SWI-Prolog

Un error no capturado se muestra así:

```text
ERROR: Domain error: `edad' expected, found `"200"'
ERROR: In:
ERROR:   [14] throw(error(domain_error(edad,"200"),_19114))
```

La primera línea es el texto del término formal: aquí, `domain_error(edad,
"200")`. Las siguientes, después de `In:`, son la **pila de llamadas** en el
momento del error, de la más reciente a la más antigua, con su profundidad
entre corchetes. En un error producido con `throw/1`, la primera línea de la
pila es el `throw/1` mismo, y el término completo aparece allí. Las llamadas
que la optimización de la última llamada eliminó no aparecen, y SWI-Prolog lo
advierte al final; el [capítulo 26](../capitulo-26-pruebas-y-depuracion/index.md) muestra cómo obtener una pila completa.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C5 | desde aquí, se exige: los predicados públicos del proyecto validan sus argumentos con `must_be/2`, y las pruebas verifican el error con la opción `error(Formal)` de plunit (`legajo_no_entero`, `texto_no_es_texto`) |
    | C2 | la consulta más general produce un error de instanciación, no una falla ni una respuesta incorrecta: `inscripcion_posible(_, am1, _)` lo verifica |

## 25.9 El proyecto: validación y errores

La versión de *Inscripciones* de este capítulo valida los argumentos de sus
operaciones y convierte los errores en respuestas del lenguaje de comandos:

<!-- ejemplo: capitulo-25/inscripciones/reglas.pl predicado: inscripcion_posible/3 consulta: inscripcion_posible(102, am2, Resultado). -->
```prolog
%!  inscripcion_posible(+Legajo:integer, +Materia:atom, -Resultado) is det.
%
%   Resultado es aceptada si el alumno Legajo se puede inscribir en Materia,
%   o rechazada(Motivo) con el primer motivo que lo impide: alumno_inexistente,
%   materia_inexistente, ya_aprobada, ya_la_cursa, falta(Requisito) o
%   sin_vacantes. Una materia desaprobada se puede volver a cursar.
%   Produce un error de instanciación o de tipo si Legajo no es un entero o
%   Materia no es un átomo.
inscripcion_posible(Legajo, Materia, Resultado) :-
    must_be(integer, Legajo),
    must_be(atom, Materia),
    (   \+ alumno(Legajo, _, _, _)
    ->  Resultado = rechazada(alumno_inexistente)
    ;   \+ materia(Materia, _, _)
    ->  Resultado = rechazada(materia_inexistente)
    ;   aprobada(Legajo, Materia, _)
    ->  Resultado = rechazada(ya_aprobada)
    ;   cursa(Legajo, Materia)
    ->  Resultado = rechazada(ya_la_cursa)
    ;   correlativa(Materia, Requisito),
        \+ aprobada(Legajo, Requisito, _)
    ->  Resultado = rechazada(falta(Requisito))
    ;   vacantes(Materia, 0)
    ->  Resultado = rechazada(sin_vacantes)
    ;   Resultado = aceptada
    ).
```

```prolog
?- inscripcion_posible(ana, am1, R).
ERROR: Type error: `integer' expected, found `ana' (an atom)
ERROR: In:
ERROR:   [16] throw(error(type_error(integer,ana),_52536))

?- inscripcion_posible(999, am1, R).
R = rechazada(alumno_inexistente).
```

La diferencia entre las dos consultas es la del criterio de la [sección 25.5](#255-fallo-o-error).
Un legajo que no es un entero es un error del que llama: el encabezado pide un
entero. Un legajo que no existe es una respuesta del dominio: el programa sabe
qué contestar, y lo hace con `rechazada(Motivo)`.

`ejecutar/2`, en `comandos`, valida que recibe un texto y captura los errores
de las operaciones, para que el lenguaje de comandos siempre responda:

<!-- ejemplo: capitulo-25/inscripciones/comandos.pl predicado: ejecutar/2 consulta: ejecutar("listar analisis_1", Respuesta). -->
```prolog
%!  ejecutar(+Texto:string, -Respuesta) is det.
%
%   Analiza el comando Texto y lo ejecuta. Respuesta es el resultado:
%   aceptada o rechazada(Motivo) para una inscripción, baja o
%   rechazada(no_la_cursa) para una baja, inscriptos(Legajos) para un
%   listado, promedio(P) o sin_notas para un promedio, y no_entendido si el
%   texto no es un comando. Si realizar el comando produce un error,
%   Respuesta es error(Formal), con la parte formal del término de error.
%   Produce un error de tipo si Texto no es un texto.
ejecutar(Texto, Respuesta) :-
    must_be(text, Texto),
    string_codes(Texto, Codigos),
    (   phrase(palabras(Palabras), Codigos),
        phrase(comando(Comando), Palabras)
    ->  catch(realizar(Comando, Respuesta), error(Formal, _),
              Respuesta = error(Formal))
    ;   Respuesta = no_entendido
    ).
```

La gramática garantiza hoy que las operaciones reciben un entero y un átomo, y
ningún comando produce un error. La captura protege los comandos que se
agreguen: el ejercicio 12 agrega uno que sí puede producirlo. Las pruebas
nuevas verifican los errores con la opción `error(Formal)`:

```prolog
test(legajo_no_entero, [error(type_error(integer, ana))]) :-
    inscripcion_posible(ana, am1, _).
```

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Predecir el término formal de cada consulta, o su respuesta si no
   produce un error: `X is 1/0.` · `atom_length(X, L).` · `atom_length(123, L).`
   · `atom_length(f(x), L).` · `X is a + 1.`
2. **(1)** Identificar la parte formal y la pila de llamadas en el mensaje de la
   [sección 25.8](#258-leer-un-mensaje-de-swi-prolog). ¿Qué término produjo `throw/1`?
3. ★ **(2)** Escribir `leer_nota(Texto, Nota)`: la nota de 1 a 10 escrita en un
   texto, con `domain_error(nota, Texto)` si no lo es, y un error de tipo si
   `Texto` no es un texto.
4. **(2)** Escribir `seguro(Objetivo, Resultado)`, con `Resultado` igual a `ok`,
   `falla` o `error(Formal)`.
5. ★ **(2)** Escribir `promedio_seguro(L, P)`, que responde `sin_datos` con la
   lista vacía capturando solo la división por cero. ¿Qué ocurre con
   `[6, a]`?
6. **(2)** Escribir `rango(Desde, Hasta, L)` con `must_be/2` y un
   `domain_error/2` propio cuando `Desde > Hasta`.
7. ★ **(2)** Escribir `primera_linea(Texto, Linea)`, que lee solo la primera
   línea de un stream sobre una cadena y lo cierra con
   `setup_call_cleanup/3`.
8. **(2)** Escribir una regla de `prolog:message//1` para el término
   `nota_invalida(N)`, y usarla con `print_message/2`.
9. ★ **(3)** Escribir `limpiar_telefono(Texto, Numero)`: los diez dígitos de un
   teléfono escrito con espacios, guiones, puntos o paréntesis, con un
   `domain_error(telefono, Motivo)` distinto para las letras, la cantidad de
   dígitos y un código de área que empieza con 0 o 1.
10. **(1)** ¿Qué responden `atom_number(abc, N).`, `succ(X, 0).` y
    `arg(x, f(a), A).`? Clasificar cada una como falla o error.
11. ★ **(2)** Escribir `registrar_nota(Legajo, Materia, Nota)` para el proyecto,
    con validación de los tres argumentos, `domain_error(nota, Nota)` y
    `existence_error(cursada, Legajo-Materia)`.
12. **(2)** Agregar el comando «nota de 101 en paradigmas 9», que llama a
    `registrar_nota/3` y convierte sus errores en `error(Formal)`.
13. **(2)** Registrar cada error del ejercicio 12 en un hecho dinámico, y
    escribir `errores(L)`.
14. **(1)** ¿Cuántas respuestas tiene `catch(member(X, [1, 2, 3]), _, true)`?
    ¿Por qué?

## Resumen

| | |
|---|---|
| éxito, falla, error | los tres desenlaces de una consulta |
| `error(Formal, Contexto)` | la forma de los términos de error |
| términos formales ISO | `instantiation_error`, `type_error/2`, `domain_error/2`, `existence_error/2`, … |
| `catch/3` | captura los errores que unifican con el patrón; transparente al retroceso |
| `throw/1` | produce una excepción |
| `must_be/2` | valida un tipo; en SWI 9, también los rangos como `type_error` |
| `type_error/2`, `domain_error/2`, … | producen el error ISO correspondiente |
| fallo o error | una pregunta sin respuesta falla; un argumento o un dato imposible es un error |
| `setup_call_cleanup/3` | la limpieza se ejecuta siempre |
| `open/3`, `read_line_to_string/2`, `close/1` | abrir un archivo, leer una línea, cerrar el stream: lo mínimo para la limpieza; el [capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) los trata a fondo |
| `print_message/2`, `prolog:message//1` | mensajes con nivel, con el texto separado del término |
| `number_string/2` | convierte entre un número y su texto; falla con un texto que no es un número |
| `text_to_string/2`, `char_type/2` | un texto como cadena; el tipo de un carácter (en las soluciones) |
| **Patrones 30, 31, 32** | capturar lo justo y relanzar; validar al entrar; recurso con limpieza garantizada |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Pruebas de errores y pilas de llamadas completas | [capítulo 26](../capitulo-26-pruebas-y-depuracion/index.md) |
| Archivos y streams con `setup_call_cleanup/3` | [capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) |
| Errores y códigos de salida en un programa de línea de comandos | [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) |
| Errores de Prolog que llegan a Python | [capítulo 29](../capitulo-29-prolog-desde-python/index.md) |
| Errores como códigos de estado HTTP | [capítulo 30](../capitulo-30-servicios-web-rest/index.md) |
