# Soluciones del capítulo 11 — Texto

El código de esta página está en `ejemplos/capitulo-11/soluciones.pl` y pasa sus
pruebas.

## 1

| Término | Es |
|---|---|
| `ana` | un átomo |
| `'Ana'` | un átomo: las comillas simples permiten la mayúscula inicial |
| `"ana"` | una cadena |
| `` `ana` `` | una lista de códigos, `[97, 110, 97]` |
| `[a, n, a]` | una lista de caracteres |

```prolog
?- ana == 'ana'.
true.

?- "ana" == ana.
false.

?- `ana` == [97, 110, 97].
true.

?- [a, n, a] == "ana".
false.
```

`ana` y `'ana'` son el mismo átomo: las comillas simples solo son necesarias
cuando el nombre no se puede escribir sin ellas, y aquí no cambian nada. Las
comillas invertidas producen directamente la lista de códigos, y por eso la
tercera se cumple. La cadena `"ana"` no es igual ni al átomo ni a la lista de
caracteres: son términos de tipos distintos.

## 2

```prolog
?- atom_codes(hola, C).
C = [104, 111, 108, 97].

?- atom_chars(X, [s, i]).
X = si.

?- atom_number('3.5', N).
N = 3.5.

?- atom_number(tres, N).
false.
```

`atom_number/2` reconoce la escritura de un número, no las palabras que lo
nombran; con `tres` responde `false.`, sin error.

`term_to_atom(f(X, b), A).` responde con un átomo como `'f(_15564,b)'`. La
variable `X` no tiene nombre dentro del átomo: se escribe con el nombre interno
que le asigna el sistema, un guion bajo seguido de un número que cambia de una
ejecución a otra.

## 3

<!-- ejemplo: capitulo-11/soluciones.pl predicado: ultima_letra/2 consulta: ultima_letra(prolog, L). -->
```prolog
%!  ultima_letra(+Palabra, ?L) is semidet.
%
%   L es el último carácter del átomo Palabra. sub_atom/5 con Despues = 0 y
%   Largo = 1 toma el fragmento de un carácter que termina al final.
ultima_letra(Palabra, L) :-
    sub_atom(Palabra, _, 1, 0, L).
```

```prolog
?- ultima_letra(prolog, L).
L = g.
```

`sub_atom/5` con `Despues` igual a 0 y `Largo` igual a 1 pregunta por el
fragmento de un carácter que termina al final del átomo. Otra solución convierte
el átomo en lista de caracteres y busca el último elemento con una recursión del
[capítulo 7](../capitulo-07-listas/index.md).

El encabezado es `ultima_letra(+Palabra, ?L) is semidet`. `Palabra` debe llegar
ligada: con `Palabra` libre, `sub_atom/5` produce un error de argumentos sin
instanciar. `L` puede llegar libre, y recibe la letra, o ligada, y el predicado
comprueba: `ultima_letra(ana, a)` responde `true.` Es `semidet` porque hay a lo
sumo una respuesta, y ninguna para el átomo vacío.

## 4

<!-- ejemplo: capitulo-11/soluciones.pl predicado: mas_largo/3 consulta: mas_largo(ana, pedro, M). -->
```prolog
%!  mas_largo(+A, +B, -M) is det.
%
%   M es el más largo de los átomos A y B; con el mismo largo, M es A. Las
%   condiciones de las dos cláusulas son complementarias.
mas_largo(A, B, A) :-
    atom_length(A, LA),
    atom_length(B, LB),
    LA >= LB.
mas_largo(A, B, B) :-
    atom_length(A, LA),
    atom_length(B, LB),
    LA < LB.
```

```prolog
?- mas_largo(ana, pedro, M).
M = pedro.
```

Las dos cláusulas tienen condiciones complementarias, `LA >= LB` y `LA < LB`,
de modo que para cualquier par de átomos exactamente una de ellas se cumple. El
empate va a la primera, que devuelve `A`, como pide el enunciado.

## 5

```prolog
?- format("~w y ~w~n", [ana, eva]).
ana y eva
true.

?- format("~d~n", [7]).
7
true.

?- format("~d~n", [7.0]).
ERROR: Illegal argument to format sequence ~d: 7.0

?- format("~3f~n", [2]).
2.000
true.

?- format("[~t~w~6|]~n", [ana]).
[  ana]
true.

?- format("[~w~t~6|]~n", [ana]).
[ana  ]
true.
```

`~d` exige un entero, y `7.0` es un número de punto flotante aunque su valor sea
entero. `~3f` acepta un entero y lo escribe con tres decimales.

En las dos últimas, la columna termina en la posición 6 de la línea, contada
desde el comienzo: el corchete ocupa la primera posición, y quedan cinco para
`ana` y el relleno. Con `~t` antes del valor, el relleno va a la izquierda y
`ana` queda alineado a la derecha; con `~t` después, al revés.

## 6

<!-- ejemplo: capitulo-11/soluciones.pl predicado: tabla_con_titulos/1 tabla/1 consulta: tabla_con_titulos([juan, ana, luis]). -->
```prolog
%!  tabla_con_titulos(+Personas) is semidet.
%
%   Escribe los títulos, una línea de guiones de 14 caracteres y las filas
%   de tabla/1.
tabla_con_titulos(Personas) :-
    format("~w~t~10|~t~w~4+~n", ['Nombre', 'Edad']),
    format("~`-t~14|~n"),
    tabla(Personas).

%!  tabla(+Personas) is semidet.
%
%   Una fila por persona: el nombre en diez posiciones y la edad alineada a
%   la derecha en las cuatro siguientes.
tabla([]).
tabla([P|Resto]) :-
    edad(P, E),
    format("~w~t~10|~t~d~4+~n", [P, E]),
    tabla(Resto).
```

```prolog
?- tabla_con_titulos([juan, ana, luis]).
Nombre    Edad
--------------
juan        68
ana         41
luis        12
true.
```

Los títulos usan las mismas columnas que las filas: diez posiciones para el
nombre y cuatro para la edad. La línea de guiones usa una variante de `~t`:
`` ~`-t `` rellena con el carácter que sigue a la comilla invertida, en lugar del
espacio, hasta la columna 14.

## 7

<!-- ejemplo: capitulo-11/soluciones.pl predicado: palindromo/1 consulta: palindromo(neuquen). -->
```prolog
%!  palindromo(+Palabra) is semidet.
%
%   Palabra se lee igual en los dos sentidos: su lista de caracteres es igual
%   a la lista invertida.
palindromo(Palabra) :-
    atom_chars(Palabra, Letras),
    reverse(Letras, Letras).
```

```prolog
?- palindromo(neuquen).
true.
```

La condición es que la lista de caracteres sea igual a su inversa, y
`reverse(Letras, Letras)` la expresa con una sola variable: la lista invertida
debe unificar con la original.

## 8

<!-- ejemplo: capitulo-11/soluciones.pl predicado: sin_prefijo/3 consulta: sin_prefijo(prolog, pro, R). -->
```prolog
%!  sin_prefijo(+Palabra, ?Prefijo, ?Resto) is nondet.
%
%   Palabra empieza con Prefijo, y Resto es lo que sigue.
sin_prefijo(Palabra, Prefijo, Resto) :-
    atom_concat(Prefijo, Resto, Palabra).
```

```prolog
?- sin_prefijo(prolog, pro, R).
R = log.
```

El encabezado es `sin_prefijo(+Palabra, ?Prefijo, ?Resto) is nondet`. Con
`Palabra` ligada, `atom_concat/3` funciona con los otros dos argumentos libres:
`sin_prefijo(prolog, P, R).` enumera las siete maneras de partir `prolog` en un
comienzo y un resto, desde `P = ''`, `R = prolog` hasta `P = prolog`, `R = ''`.
Por eso el predicado es `nondet`, aunque con `Prefijo` ligado dé una sola
respuesta.

## 9

<!-- ejemplo: capitulo-11/soluciones.pl predicado: contar_vocales/2 vocales/2 consulta: contar_vocales(murcielago, N). -->
```prolog
%!  contar_vocales(+Palabra, -N) is det.
%
%   N es la cantidad de vocales de Palabra, sin distinguir mayúsculas.
contar_vocales(Palabra, N) :-
    downcase_atom(Palabra, Minusculas),
    atom_chars(Minusculas, Letras),
    vocales(Letras, N).

%!  vocales(+Letras, -N) is det.
%
%   N es la cantidad de vocales de la lista de caracteres Letras. El corte
%   de la segunda cláusula es rojo: la tercera acepta cualquier carácter.
vocales([], 0).
vocales([C|Resto], N) :-
    vocal(C),
    !,
    vocales(Resto, N0),
    N is N0 + 1.
vocales([_|Resto], N) :-
    vocales(Resto, N).
```

```prolog
?- contar_vocales(murcielago, N).
N = 5.
```

`downcase_atom/2` resuelve las mayúsculas antes de recorrer: después de esa
conversión, alcanza con reconocer las cinco vocales minúsculas. Los hechos
`vocal/1` no incluyen las vocales con tilde; agregarlas es agregar cinco
hechos.

El corte de la segunda cláusula de `vocales/2` es rojo, en el sentido de la
[sección 9.5](../capitulo-09-backtracking-y-corte/index.md#95-corte-verde-y-corte-rojo): la tercera cláusula no comprueba que el carácter no sea una
vocal, y sin el corte daría, al volver atrás, cuentas menores.

## 10

```prolog
?- split_string("a,b,,c", ",", "", L).
L = ["a", "b", "", "c"].

?- split_string("  hola  ", "", " ", L).
L = ["hola"].

?- split_string("a b", " ", "", L).
L = ["a", "b"].

?- atomic_list_concat(L, ', ', 'a, b').
L = [a, b].
```

En la primera, las dos comas seguidas producen una cadena vacía entre ellas. En
la segunda no hay separadores, de modo que el texto completo es una sola parte,
a la que se le quitan los espacios de los bordes: es la manera de usar
`split_string/4` para recortar espacios. La cuarta usa `atomic_list_concat/3`
en el sentido inverso, con el separador de dos caracteres `', '`.

## 11

<!-- ejemplo: capitulo-11/soluciones.pl predicado: campos/2 a_atomos/2 consulta: campos("juan, 68, 1957", C). -->
```prolog
%!  campos(+Linea, -Campos) is det.
%
%   Campos es la lista de los campos de Linea, separados por comas y con los
%   espacios de los bordes quitados, como átomos.
campos(Linea, Campos) :-
    split_string(Linea, ",", " ", Partes),
    a_atomos(Partes, Campos).

%!  a_atomos(+Cadenas, -Atomos) is det.
%
%   Atomos es la lista de las cadenas convertidas en átomos.
a_atomos([], []).
a_atomos([Cadena|Resto], [Atomo|Atomos]) :-
    atom_string(Atomo, Cadena),
    a_atomos(Resto, Atomos).
```

```prolog
?- campos("juan, 68, 1957", C).
C = [juan, '68', '1957'].
```

`split_string/4` divide por comas y quita los espacios de los bordes de cada
campo; `a_atomos/2` convierte cada cadena en átomo con la plantilla 12. Los
números quedan como átomos, `'68'`: son texto que representa un número, no
números.

## 12

<!-- ejemplo: capitulo-11/soluciones.pl predicado: campos_con_numeros/2 a_valores/2 valor/2 consulta: campos_con_numeros("juan, 68, 1957", C). -->
```prolog
%!  campos_con_numeros(+Linea, -Campos) is det.
%
%   Como campos/2, pero los campos que representan números quedan como
%   números.
campos_con_numeros(Linea, Campos) :-
    split_string(Linea, ",", " ", Partes),
    a_valores(Partes, Campos).

%!  a_valores(+Cadenas, -Valores) is det.
%
%   Valores es la lista de los valores de las cadenas.
a_valores([], []).
a_valores([Cadena|Resto], [Valor|Valores]) :-
    valor(Cadena, Valor),
    a_valores(Resto, Valores).

%!  valor(+Cadena, -Valor) is det.
%
%   Valor es el número que representa Cadena, o el átomo con su texto si no
%   representa un número. El corte es rojo: la segunda cláusula acepta
%   cualquier cadena.
valor(Cadena, Numero) :-
    atom_string(Atomo, Cadena),
    atom_number(Atomo, Numero),
    !.
valor(Cadena, Atomo) :-
    atom_string(Atomo, Cadena).
```

```prolog
?- campos_con_numeros("juan, 68, 1957", C).
C = [juan, 68, 1957].
```

`valor/2` usa `atom_number/2` como prueba, que es el uso que muestra la
[sección 11.2](index.md#112-conversiones): si el campo representa un número, la primera cláusula lo
convierte y el corte descarta la segunda; si no, `atom_number/2` falla y la
segunda cláusula deja el campo como átomo.

## 13

<!-- ejemplo: capitulo-11/soluciones.pl predicado: mismo_texto/2 en_forma_normal/2 consulta: mismo_texto('  Ana   PAZ', "ana paz"). -->
```prolog
%!  mismo_texto(+A, +B) is semidet.
%
%   A y B, átomos o cadenas, son el mismo texto si se ignoran las mayúsculas
%   y los espacios sobrantes.
mismo_texto(A, B) :-
    en_forma_normal(A, Normal),
    en_forma_normal(B, Normal).

%!  en_forma_normal(+Texto, -Normal) is det.
%
%   Normal es el átomo de Texto en minúsculas y con los espacios
%   normalizados. normalize_space/2 acepta un átomo o una cadena.
en_forma_normal(Texto, Normal) :-
    normalize_space(atom(Espaciado), Texto),
    downcase_atom(Espaciado, Normal).
```

```prolog
?- mismo_texto('  Ana   PAZ', "ana paz").
true.
```

La solución lleva los dos textos a una forma normal y exige que sea la misma.
`normalize_space/2` acepta un átomo o una cadena y, con `atom(Espaciado)`,
produce siempre un átomo, de modo que la diferencia de representación
desaparece en el primer paso.

El encabezado es `mismo_texto(+A, +B) is semidet`: los dos argumentos deben
llegar ligados, porque `normalize_space/2` necesita el texto, y hay una
respuesta o ninguna.

## 14

| Término | `write/1` | `writeq/1` y `print/1` | `write_canonical/1` |
|---|---|---|---|
| `'Ana Paz'` | `Ana Paz` | `'Ana Paz'` | `'Ana Paz'` |
| `"hola"` | `hola` | `"hola"` | `"hola"` |
| `2 + 3` | `2+3` | `2+3` | `+(2,3)` |
| `[x, 'Y']` | `[x,Y]` | `[x,'Y']` | `[x,'Y']` |
| `- 1` | `- 1` | `- 1` | `-(1)` |

`write/1` es el único que pierde información: `[x,Y]` se podría leer como una
lista con una variable, y `hola` como un átomo. Los demás escriben un texto que,
leído de nuevo, produce el mismo término.

La última fila muestra un caso que conviene conocer: `- 1`, con un espacio, no
es el número −1 sino el término compuesto `-(1)`, y los tres predicados que
permiten volver a leerlo lo escriben de manera que no se confunda con el
número.

## 15

<!-- ejemplo: capitulo-11/soluciones.pl predicado: iniciales_de/2 primeras_letras/2 consulta: iniciales_de('juan carlos perez', I). -->
```prolog
%!  iniciales_de(+NombreCompleto, -Iniciales) is det.
%
%   Iniciales es el átomo formado por las iniciales de las palabras de
%   NombreCompleto, en mayúscula.
iniciales_de(NombreCompleto, Iniciales) :-
    split_string(NombreCompleto, " ", " ", Palabras),
    primeras_letras(Palabras, Letras),
    atomic_list_concat(Letras, Minusculas),
    upcase_atom(Minusculas, Iniciales).

%!  primeras_letras(+Palabras, -Letras) is det.
%
%   Letras es la lista de los primeros caracteres de las cadenas no vacías
%   de Palabras.
primeras_letras([], []).
primeras_letras([""|Resto], Letras) :-
    primeras_letras(Resto, Letras).
primeras_letras([Palabra|Resto], [Letra|Letras]) :-
    Palabra \== "",
    string_chars(Palabra, [Letra|_]),
    primeras_letras(Resto, Letras).
```

```prolog
?- iniciales_de('juan carlos perez', I).
I = 'JCP'.
```

La solución encadena cuatro pasos de este capítulo: dividir en palabras,
tomar la primera letra de cada una con un recorrido, unir las letras y pasarlas
a mayúsculas. `primeras_letras/2` descarta las cadenas vacías que producen los
espacios sobrantes, del mismo modo que `no_vacias/2` en la [sección 11.5](index.md#115-dividir-y-unir).

Las pruebas que pide el enunciado:

<!-- ejemplo: capitulo-11/soluciones.plt fragmento: % Ejercicio 15 .. iniciales_de(ana, I). -->
```prolog
% Ejercicio 15: las tres pruebas que pide el enunciado.
test(iniciales_de_tres_palabras, all(I == ['JCP'])) :-
    iniciales_de('juan carlos perez', I).

test(iniciales_con_espacios_sobrantes, all(I == ['JCP'])) :-
    iniciales_de('  juan   carlos perez ', I).

test(iniciales_de_una_palabra, all(I == ['A'])) :-
    iniciales_de(ana, I).
```
