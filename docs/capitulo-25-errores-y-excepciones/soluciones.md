# Soluciones del capítulo 25 — Errores y excepciones

El código de esta página está en `ejemplos/capitulo-25/soluciones.pl` y
`ejemplos/capitulo-25/soluciones_proyecto.pl`, y pasa sus pruebas.

## 1

| Consulta | Resultado |
|---|---|
| `X is 1/0.` | `evaluation_error(zero_divisor)` |
| `atom_length(X, L).` | `instantiation_error` |
| `atom_length(123, L).` | `L = 3.`: no es un error |
| `atom_length(f(x), L).` | `type_error(text, f(x))` |
| `X is a + 1.` | `type_error(evaluable, a/0)` |

`atom_length/2` acepta un número y lo convierte en texto: el tipo que exige es
«texto», y un número se puede escribir como texto; un término compuesto, no.
`X is a + 1` dice que `a/0` no es una función que se pueda evaluar: para `is/2`,
un átomo en una expresión es una función sin argumentos.

## 2

La parte formal es `domain_error(edad, "200")`, y la primera línea del mensaje
la escribe en palabras. La pila de llamadas tiene una sola línea, la del
`throw/1` que produjo `domain_error/2` de `library(error)`, y muestra el término
completo: `error(domain_error(edad,"200"),_19114)`, con el contexto todavía sin
completar.

## 3

<!-- ejemplo: capitulo-25/soluciones.pl predicado: leer_nota/2 consulta: leer_nota("7", N). -->
```prolog
%!  leer_nota(+Texto:text, -Nota:integer) is det.
%
%   Nota es la nota escrita en Texto. Produce domain_error(nota, Texto) si
%   el texto no es un entero entre 1 y 10.
leer_nota(Texto, Nota) :-
    must_be(text, Texto),
    text_to_string(Texto, Cadena),
    (   number_string(N, Cadena),
        integer(N),
        between(1, 10, N)
    ->  Nota = N
    ;   domain_error(nota, Texto)
    ).
```

```prolog
?- leer_nota("7", N).
N = 7.

?- leer_nota("11", N).
ERROR: Domain error: `nota' expected, found `"11"'
ERROR: In:
ERROR:   [14] throw(error(domain_error(nota,"11"),_19070))
```

`must_be(text, Texto)` rechaza un número: `leer_nota(7, N)` produce un error
de tipo, porque el encabezado pide un texto. `text_to_string/2` lleva ese
texto, sea un átomo, una cadena o una lista, a una cadena.
`number_string/2` falla con un texto que no es un número, y esa falla, como un
número fuera de rango, lleva al `domain_error/2`.

## 4

<!-- ejemplo: capitulo-25/soluciones.pl predicado: seguro/2 consulta: seguro(member(3, [1, 2]), R). -->
```prolog
%!  seguro(:Objetivo, -Resultado) is det.
%
%   Resultado es ok si Objetivo tiene éxito, falla si falla, y error(Formal)
%   si produce un error, con la parte formal del término.
seguro(Objetivo, Resultado) :-
    catch(( once(Objetivo)
          ->  Resultado = ok
          ;   Resultado = falla
          ),
          error(Formal, _),
          Resultado = error(Formal)).
```

```prolog
?- seguro(member(3, [1, 2]), R).
R = falla.

?- seguro(X is 1/0, R).
R = error(evaluation_error(zero_divisor)).
```

`once/1` dentro del `catch/3` hace que `seguro/2` sea `det`. El patrón
`error(Formal, _)` captura los errores con la forma ISO; un `throw/1` con otro
término, como el que produce Ctrl-C, se propaga.

## 5

<!-- ejemplo: capitulo-25/soluciones.pl predicado: promedio_seguro/2 consulta: promedio_seguro([], P). -->
```prolog
%!  promedio_seguro(+L:list(number), -P) is det.
%
%   P es el promedio de L, o sin_datos si L está vacía. Solo se captura la
%   división por cero; cualquier otro error, como un elemento que no es un
%   número, se propaga.
promedio_seguro(L, P) :-
    catch(( sum_list(L, S),
            length(L, N),
            P is S / N ),
          error(evaluation_error(zero_divisor), _),
          P = sin_datos).
```

```prolog
?- promedio_seguro([], P).
P = sin_datos.

?- promedio_seguro([6, a], P).
ERROR: Arithmetic: `a/0' is not a function
ERROR: In:
ERROR:   [18] _21178 is 6+a
```

Con `[6, a]`, el error es de tipo, y el patrón `evaluation_error(zero_divisor)`
no unifica con él: se propaga. Una lista con un elemento que no es un número es
un error del que llama, y `sin_datos` lo ocultaría.

## 6

<!-- ejemplo: capitulo-25/soluciones.pl predicado: rango/3 consulta: rango(3, 5, L). -->
```prolog
%!  rango(+Desde:integer, +Hasta:integer, -L:list(integer)) is det.
%
%   L son los enteros de Desde a Hasta. Produce un error de tipo si alguno
%   no es un entero, y domain_error(rango, Desde-Hasta) si Desde > Hasta.
rango(Desde, Hasta, L) :-
    must_be(integer, Desde),
    must_be(integer, Hasta),
    (   Desde =< Hasta
    ->  numlist(Desde, Hasta, L)
    ;   domain_error(rango, Desde-Hasta)
    ).
```

```prolog
?- rango(5, 3, L).
ERROR: Domain error: `rango' expected, found `5-3'
ERROR: In:
ERROR:   [14] throw(error(domain_error(rango,...),_19030))
```

`numlist(5, 3, L)` falla; `rango/3` decide que un rango invertido es un error,
no una lista vacía. Es una decisión de interfaz, y el encabezado la declara.

## 7

<!-- ejemplo: capitulo-25/soluciones.pl predicado: primera_linea/2 consulta: primera_linea("uno\ndos", L). -->
```prolog
%!  primera_linea(+Texto:string, -Linea:string) is det.
%
%   Linea es la primera línea de Texto, o la cadena vacía si Texto está
%   vacío. El stream se cierra aunque quede texto sin leer.
primera_linea(Texto, Linea) :-
    setup_call_cleanup(open_string(Texto, Stream),
                       read_line_to_string(Stream, Leida),
                       close(Stream)),
    (   Leida == end_of_file
    ->  Linea = ""
    ;   Linea = Leida
    ).
```

`read_line_to_string/2` lee una sola línea, y `setup_call_cleanup/3` cierra el
stream aunque quede texto sin leer. El objetivo es `det`, y la limpieza ocurre
en cuanto termina. Con la cadena vacía, `read_line_to_string/2` da
`end_of_file`, que el predicado traduce a la cadena vacía.

La Actividad de la [sección 25.6](index.md#256-setup_call_cleanup3) muestra
el desenlace de falla: `usar(r1, fail)` falla y `abierto(R)` no tiene
respuesta, porque `cerrar/1` se ejecutó; `usar_sin_limpieza(r1, fail)` también
falla, y `abierto(R)` responde `R = r1`, porque `cerrar/1` no llegó a
ejecutarse.

## 8

<!-- ejemplo: capitulo-25/soluciones.pl fragmento: :- multifile prolog:message//1. .. debe ser un entero de 1 a 10'-[N] ]. consulta: phrase(prolog:message(nota_invalida(11)), L). -->
```prolog
:- multifile prolog:message//1.

%!  prolog:message(+Mensaje)// is semidet.
%
%   El texto del mensaje nota_invalida(N).
prolog:message(nota_invalida(N)) -->
    [ 'La nota ~w no es válida: debe ser un entero de 1 a 10'-[N] ].
```

`print_message(error, nota_invalida(11))` escribe
`ERROR: La nota 11 no es válida: debe ser un entero de 1 a 10`. La prueba del
ejercicio compara la lista de `prolog:message//1`, no el texto escrito: el
nivel y el canal no forman parte del mensaje.

## 9

<!-- ejemplo: capitulo-25/soluciones.pl predicado: limpiar_telefono/2 consulta: limpiar_telefono("(223) 456-7890", T). -->
```prolog
%!  limpiar_telefono(+Texto:text, -Numero:string) is det.
%
%   Numero son los diez dígitos del teléfono escrito en Texto, sin
%   espacios, guiones, puntos ni paréntesis. Produce domain_error(telefono,
%   Motivo) si el texto tiene letras, si no tiene diez dígitos, o si el
%   código de área empieza con 0 o 1.
limpiar_telefono(Texto, Numero) :-
    must_be(text, Texto),
    text_to_string(Texto, Cadena),
    string_chars(Cadena, Caracteres),
    (   member(C, Caracteres),
        char_type(C, alpha)
    ->  domain_error(telefono, letras)
    ;   true
    ),
    include([Ch]>>char_type(Ch, digit(_)), Caracteres, Digitos),
    length(Digitos, Cantidad),
    (   Cantidad =\= 10
    ->  domain_error(telefono, cantidad_de_digitos(Cantidad))
    ;   Digitos = [Primero|_],
        memberchk(Primero, ['0', '1'])
    ->  domain_error(telefono, codigo_de_area(Primero))
    ;   string_chars(Numero, Digitos)
    ).
```

```prolog
?- limpiar_telefono("(223) 456-7890", T).
T = "2234567890".

?- limpiar_telefono("123-456-7890", T).
ERROR: Domain error: `telefono' expected, found `codigo_de_area('1')'
ERROR: In:
ERROR:   [14] throw(error(domain_error(telefono,...),_27536))
```

`char_type(C, Tipo)` se cumple si el carácter `C` es del tipo indicado:
`alpha` para una letra, `digit(Peso)` para un dígito.

El segundo argumento de `domain_error/2` dice **por qué** el valor está fuera del
dominio: `letras`, `cantidad_de_digitos(9)`, `codigo_de_area('1')`. Quien llama
puede capturar el error y responder de forma distinta a cada motivo, sin
analizar un texto.

## 10

`last([], X)` falla: la lista vacía no tiene último elemento, y el predicado
lo responde con `false`. `atom_length(abc, foo)` produce
`type_error(integer, foo)`, y `char_code(C, N)` produce `instantiation_error`.
`last/2` responde una pregunta sin respuesta; `atom_length/2` recibe una
longitud que no es un entero; `char_code/2` no tiene ningún argumento ligado.
La primera es una falla; las otras dos son errores, porque reciben argumentos
que no cumplen la interfaz del predicado.

## 11

<!-- ejemplo: capitulo-25/soluciones_proyecto.pl predicado: registrar_nota/3 consulta: catch(registrar_nota(101, pp, 11), error(F, _), true). -->
```prolog
%!  registrar_nota(+Legajo:integer, +Materia:atom, +Nota:integer) is det.
%
%   Registra la nota final Nota del alumno Legajo en Materia, que debe estar
%   cursando. Produce un error de tipo si un argumento no es del tipo
%   declarado, domain_error(nota, Nota) si la nota no está entre 1 y 10, y
%   existence_error(cursada, Legajo-Materia) si el alumno no la cursa.
registrar_nota(Legajo, Materia, Nota) :-
    must_be(integer, Legajo),
    must_be(atom, Materia),
    must_be(integer, Nota),
    (   between(1, 10, Nota)
    ->  true
    ;   domain_error(nota, Nota)
    ),
    (   quitar_inscripcion(Legajo, Materia, cursando)
    ->  agregar_inscripcion(Legajo, Materia, nota(Nota))
    ;   existence_error(cursada, Legajo-Materia)
    ).
```

```prolog
?- catch(registrar_nota(101, pp, 11), error(F, _), true).
F = domain_error(nota, 11).

?- catch(registrar_nota(101, am1, 9), error(F, _), true).
F = existence_error(cursada, 101-am1).
```

Las validaciones van antes de modificar nada: una nota inválida no modifica
la base. `existence_error(cursada, 101-am1)` dice qué falta —una cursada de ana en
análisis 1— aunque la inscripción existe: ana ya aprobó esa materia.

## 12

<!-- ejemplo: capitulo-25/soluciones_proyecto.pl predicado: ejecutar_ampliado/2 consulta: ejecutar_ampliado("nota de 101 en paradigmas 11", R). -->
```prolog
%!  ejecutar_ampliado(+Texto:text, -Respuesta) is det.
%
%   Como ejecutar/2, con el comando "nota de Legajo en Materia Nota". Un
%   error de registrar_nota/3 se convierte en la respuesta error(Formal), y
%   queda registrado en error_registrado/2.
ejecutar_ampliado(Texto, Respuesta) :-
    must_be(text, Texto),
    text_to_string(Texto, Cadena),
    string_codes(Cadena, Codigos),
    phrase(palabras(Palabras), Codigos),
    (   Palabras = [nota, de, L, en, Nombre, N],
        materia(M, Nombre, _)
    ->  catch(( registrar_nota(L, M, N),
                Respuesta = registrada ),
              error(Formal, _),
              ( assertz(error_registrado(Cadena, Formal)),
                Respuesta = error(Formal) ))
    ;   ejecutar(Cadena, Respuesta)
    ).
```

```prolog
?- ejecutar_ampliado("nota de 101 en paradigmas 11", R).
R = error(domain_error(nota, 11)).

?- ejecutar_ampliado("listar logica", R).
R = inscriptos([101, 102, 104, 106]).
```

El comando nuevo se reconoce sobre la lista de palabras que da `palabras//1`,
analizada primero con una variable libre y unificada después con la forma del
comando: si la lista se pasa parcialmente ligada, `palabras//1` genera en lugar
de analizar, y `integer//1` recibe el átomo `nota`. Los demás comandos se
delegan en `ejecutar/2`.

## 13

<!-- ejemplo: capitulo-25/soluciones_proyecto.pl predicado: errores/1 consulta: errores(L). -->
```prolog
%!  errores(-Errores:list(pair)) is det.
%
%   Errores son los errores registrados, como pares Texto-Formal, en el
%   orden en que ocurrieron.
errores(Errores) :-
    findall(T-F, error_registrado(T, F), Errores).
```

```prolog
?- ejecutar_ampliado("nota de 101 en paradigmas 11", _), ejecutar_ampliado("nota de 104 en logica 8", _), errores(L).
L = ["nota de 101 en paradigmas 11"-domain_error(nota, 11), "nota de 104 en logica 8"-existence_error(cursada, 104-log)].
```

El registro se hace en la recuperación del `catch/3`, junto con la respuesta.
Las pruebas lo vacían en su `setup` y al terminar la unidad, como el
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md) enseñó para todo estado.

## 14

`catch(member(X, [1, 2, 3]), _, true)` tiene tres respuestas: `catch/3` es
transparente al retroceso, y las alternativas de `member/2` siguen disponibles.
La prueba `catch_y_retroceso` lo verifica con `all(X == [1, 2, 3])`.

La Actividad de la [sección 25.3](index.md#253-catch3) pregunta por dos
consultas más. `con_valor_por_omision(edad(zoe), 0, V)` falla: `edad/2` no
tiene respuesta para `zoe` y no produce ningún error, y `catch/3` es
transparente a la falla; el valor por omisión reemplaza solo un error de
existencia. `catch(member(X, [1, 2]), _, true)` tiene dos respuestas, por la
misma transparencia.
