# Capítulo 11 — Texto

Hasta este capítulo, los nombres de un programa fueron átomos: `juan`, `ana`,
`'Ana Paz'`. Los átomos alcanzan para nombrar, pero un programa también necesita
tratar el texto como material: tomar la primera letra de un nombre, buscar una
palabra dentro de otra, dividir una línea en campos, alinear columnas en la
salida.

Este capítulo presenta las cuatro maneras de representar texto en SWI-Prolog,
las conversiones entre ellas, `format/2` en detalle, y los predicados
predefinidos que buscan, dividen, unen, normalizan y escriben texto. Todo lo que
se construye con ellos usa las herramientas de los capítulos anteriores:
recursión sobre listas, acumuladores y la ubicación correcta de cada objetivo.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- distinguir un átomo, una cadena, una lista de códigos y una lista de
  caracteres, y elegir la representación adecuada para cada uso;
- convertir texto de una representación a otra, y un número en texto y
  viceversa;
- escribir una salida con `format/2`: valores, números, columnas y alineación;
- buscar dentro de un átomo, dividir un texto en partes y unir partes en un
  texto;
- normalizar mayúsculas y espacios antes de comparar, y escribir un término de
  la manera que corresponde a cada propósito.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **1:29 h**.
    Resolver los 6 ejercicios marcados con ★: **1:12 h**.
    Resolver los 15 ejercicios del final: **4:04 h**.

## 11.1 Cuatro maneras de escribir texto

SWI-Prolog admite cuatro representaciones de un mismo texto:

| Se escribe | Es | Ejemplo de uso |
|---|---|---|
| `ana`, `'Ana Paz'` | un **átomo** | nombres, identificadores, constantes del programa |
| `"ana"` | una **cadena** (*string*) | texto que llega de afuera o que se va a modificar |
| `` `ana` `` | una **lista de códigos**: `[97, 110, 97]` | recorrer el texto con la recursión del [capítulo 7](../capitulo-07-listas/index.md) |
| `[a, n, a]` | una **lista de caracteres** | lo mismo, con elementos más legibles |

Cada código es el número que identifica a un carácter; cada carácter es un átomo
de una sola letra. Los cuatro son términos distintos, y la unificación los trata
como tales:

```prolog
?- atom(ana).
true.

?- string("ana").
true.

?- atom("ana").
false.

?- "ana" == ana.
false.

?- X = `ana`.
X = [97, 110, 97].
```

El significado de las comillas dobles depende de una bandera del sistema,
`double_quotes`. En SWI-Prolog su valor es `string`, y por eso `"ana"` es una
cadena:

```prolog
?- current_prolog_flag(double_quotes, F).
F = string.
```

En otros sistemas Prolog, y en programas escritos para ellos, `"ana"` puede ser
una lista de códigos o de caracteres. Un programa que usa comillas dobles
depende de esa bandera; un texto que llega de un libro escrito para otro sistema
puede requerir cambiarla con `set_prolog_flag/2`.

La elección entre las cuatro formas sigue una regla práctica:

- **átomos** para los nombres que el programa compara y usa como datos: se
  comparan en un solo paso y sirven como argumento de los hechos;
- **cadenas** para el texto que el programa recibe, divide o compone;
- **listas de caracteres o de códigos** cuando el texto se recorre de a un
  elemento, con los predicados de listas.

!!! question "Actividad"
    Antes de ejecutarlas, predecir la respuesta de estas consultas:
    `atom('Ana Paz').` · `string('ana').` · `` `ab` == [97, 98]. `` ·
    `"ab" = [a, b].` Ejecutarlas después, y explicar cada resultado a partir de
    la tabla de esta sección.

## 11.2 Conversiones

Los predicados de conversión relacionan dos representaciones, y la mayoría
funciona en los dos sentidos:

```prolog
?- atom_codes(ana, C).
C = [97, 110, 97].

?- atom_codes(A, [101, 118, 97]).
A = eva.

?- atom_chars(ana, L).
L = [a, n, a].

?- atom_string(A, "luis").
A = luis.

?- string_chars(S, [h, o, l, a]).
S = "hola".
```

Los números tienen sus propias conversiones. `atom_number/2` responde `false.`
cuando el átomo no representa un número, lo que permite usarlo también como
prueba:

```prolog
?- atom_number('12', N).
N = 12.

?- atom_number(ana, N).
false.

?- atom_number(A, 12).
A = '12'.

?- number_codes(N, "42").
N = 42.
```

`term_to_atom/2` convierte un término completo en el átomo que lo escribe, y
también el átomo en el término:

```prolog
?- term_to_atom(padre(juan, ana), A).
A = 'padre(juan,ana)'.

?- term_to_atom(T, 'padre(juan, ana)').
T = padre(juan, ana).
```

Con estas conversiones, un recorrido de lista del [capítulo 7](../capitulo-07-listas/index.md) se aplica al
texto. `inicial/2` toma la primera letra de un nombre, y `iniciales/2` aplica
la plantilla 12 a una lista de nombres:

<!-- ejemplo: capitulo-11/texto.pl predicado: inicial/2 iniciales/2 consulta: iniciales([juan, ana, eva], L). -->
```prolog
%!  inicial(+Nombre, -Inicial) is semidet.
%
%   Inicial es el primer carácter del átomo Nombre. Falla con el átomo vacío.
inicial(Nombre, Inicial) :-
    atom_chars(Nombre, [Inicial|_]).

%!  iniciales(+Nombres, -Iniciales) is semidet.
%
%   Iniciales es la lista de los primeros caracteres de los nombres de la
%   lista Nombres, en el mismo orden.
iniciales([], []).
iniciales([Nombre|Resto], [Inicial|Iniciales]) :-
    inicial(Nombre, Inicial),
    iniciales(Resto, Iniciales).
```

```prolog
?- inicial(juan, I).
I = j.

?- iniciales([juan, ana, eva], L).
L = [j, a, e].
```

`inicial/2` no recorre nada: la unificación con `[Inicial|_]` toma el primer
elemento de la lista de caracteres, y el resto se ignora. Con el átomo vacío,
`''`, la lista de caracteres es `[]` y la unificación falla, que es lo que el
encabezado declara con `semidet`.

!!! question "Actividad"
    Ejecutar `inicial(I, j).` y explicar el resultado a partir del encabezado
    de `inicial/2`. ¿Qué argumento de `atom_chars/2` llega libre en esa
    consulta?

## 11.3 `format/2` en detalle

El [capítulo 1](../capitulo-01-la-primera-hora/index.md) usó `format/2` con dos directivas, `~w` y `~n`. El texto de formato
admite muchas más; estas son las que el curso usa:

| Directiva | Escribe |
|---|---|
| `~w` | el término siguiente, como lo escribe `write/1` |
| `~a` | el átomo siguiente |
| `~q` | el término siguiente, con comillas donde hacen falta, como `writeq/1` |
| `~d` | el entero siguiente; un número que no es entero produce un error |
| `~2f` | el número siguiente con dos decimales (cualquier cantidad) |
| `~e` | el número siguiente en notación exponencial |
| `~s` | la lista de códigos o la cadena siguiente |
| `~n` | un salto de línea |
| `~t` | relleno: los espacios que hagan falta para completar la columna |
| `~10\|` | una columna que termina en la posición 10 de la línea |
| `~8+` | una columna de 8 posiciones a partir de la columna anterior |

<!-- ejemplo: capitulo-11/formato.pl predicado: edad/2 ficha/1 consulta: ficha(juan). -->
```prolog
% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 39).
edad(luis, 12).
edad(eva, 8).

%!  ficha(?P) is nondet.
%
%   Escribe una línea con el nombre y la edad de P.
ficha(P) :-
    edad(P, E),
    format("~w tiene ~d años~n", [P, E]).
```

```prolog
?- ficha(juan).
juan tiene 68 años
true.
```

`~d` exige un entero. Con otro número, `format/2` no escribe nada y produce un
error:

```prolog
?- format("~d~n", [3.5]).
ERROR: Illegal argument to format sequence ~d: 3.5
```

Para los números con decimales se usa `~f` con la cantidad de decimales, o
`~e`:

```prolog
?- format("~2f ~e~n", [3.14159, 1000.0]).
3.14 1.000000e+03
true.
```

Las columnas se construyen con `~t` y una marca de columna. `~t` indica dónde va
el relleno: antes del valor, lo alinea a la derecha; después, a la izquierda.

```prolog
?- format("~w~t~10|~w~n", [juan, 68]).
juan      68
true.

?- format("~t~w~10|~n", [68]).
        68
true.
```

`tabla/1` recorre una lista de personas y escribe una fila por cada una: el
nombre alineado a la izquierda en una columna de diez posiciones, y la edad
alineada a la derecha en una columna de cuatro posiciones a continuación:

<!-- ejemplo: capitulo-11/formato.pl predicado: tabla/1 consulta: tabla([juan, ana, luis]). -->
```prolog
%!  tabla(+Personas) is semidet.
%
%   Escribe una fila por persona de la lista: el nombre en una columna de
%   diez caracteres y la edad alineada a la derecha en la columna siguiente.
%   Falla si alguna persona no tiene edad registrada.
tabla([]).
tabla([P|Resto]) :-
    edad(P, E),
    format("~w~t~10|~t~d~4+~n", [P, E]),
    tabla(Resto).
```

```prolog
?- tabla([juan, ana, luis]).
juan        68
ana         41
luis        12
true.
```

Finalmente, `format/3` con `atom(A)` como primer argumento no escribe: deja el
resultado en el átomo `A`. Es la forma habitual de componer un texto a partir de
varios valores:

<!-- ejemplo: capitulo-11/formato.pl predicado: etiqueta/2 consulta: etiqueta(ana, E). -->
```prolog
%!  etiqueta(?P, -Etiqueta) is nondet.
%
%   Etiqueta es un átomo con el nombre de P y su edad entre paréntesis.
etiqueta(P, Etiqueta) :-
    edad(P, E),
    format(atom(Etiqueta), "~w (~d)", [P, E]).
```

```prolog
?- etiqueta(ana, E).
E = 'ana (41)'.
```

!!! question "Actividad"
    Predecir la salida de `format("~a|~q|~w~n", ['Ana Paz', 'Ana Paz', 'Ana Paz']).`
    y comprobarla. Después agregar a `tabla/1` una línea de encabezado con los
    títulos `Nombre` y `Edad`, alineados con las columnas de las filas.

## 11.4 Buscar dentro de un átomo

`atom_length/2` da la cantidad de caracteres de un átomo, y también de un
número, que convierte antes de contar:

```prolog
?- atom_length(prolog, N).
N = 6.

?- atom_length(12345, N).
N = 5.
```

`atom_concat/3` relaciona dos átomos con su concatenación. Con los dos primeros
argumentos ligados, concatena; con el tercero ligado, enumera todas las maneras
de partirlo en dos:

```prolog
?- atom_concat(pro, log, X).
X = prolog.

?- atom_concat(X, log, prolog).
X = pro.

?- atom_concat(X, Y, ana).
X = '',
Y = ana ;
X = a,
Y = na ;
X = an,
Y = a ;
X = ana,
Y = ''.
```

`sub_atom/5` es el predicado general para buscar dentro de un átomo.
`sub_atom(Atomo, Antes, Largo, Despues, Sub)` relaciona un átomo con cada uno de
sus fragmentos: `Antes` es la cantidad de caracteres que preceden al fragmento,
`Largo` su largo, y `Despues` la cantidad de caracteres que lo siguen. Cada
argumento puede llegar ligado o libre, y según cuáles lleguen ligados la
consulta hace una pregunta distinta:

```prolog
?- sub_atom(prolog, 0, 3, _, S).
S = pro.

?- sub_atom(prolog, B, _, 0, log).
B = 3.

?- sub_atom(banana, B, _, _, na).
B = 2 ;
B = 4.
```

La primera toma los tres primeros caracteres; la segunda pregunta en qué
posición empieza `log` si termina al final del átomo; la tercera enumera las
posiciones en que aparece `na`. Con esos modos se escriben las dos preguntas
más frecuentes sobre una palabra:

<!-- ejemplo: capitulo-11/palabras.pl predicado: empieza_con/2 termina_con/2 consulta: empieza_con(ana, P). -->
```prolog
%!  empieza_con(+Palabra, ?Prefijo) is nondet.
%
%   Prefijo es un comienzo de Palabra. Con Prefijo libre, enumera todos los
%   comienzos, del vacío a la palabra entera.
empieza_con(Palabra, Prefijo) :-
    sub_atom(Palabra, 0, _, _, Prefijo).

%!  termina_con(+Palabra, ?Sufijo) is nondet.
%
%   Sufijo es un final de Palabra.
termina_con(Palabra, Sufijo) :-
    sub_atom(Palabra, _, _, 0, Sufijo).
```

```prolog
?- empieza_con(prolog, pro).
true.

?- empieza_con(ana, P).
P = '' ;
P = a ;
P = an ;
P = ana.
```

Para contar cuántas veces aparece una letra, la conversión a lista de
caracteres permite usar un recorrido con acumulador en la forma del
[capítulo 8](../capitulo-08-aritmetica/index.md):

<!-- ejemplo: capitulo-11/palabras.pl predicado: contar_letra/3 contar/3 consulta: contar_letra(a, banana, N). -->
```prolog
%!  contar_letra(+Letra, +Palabra, -N) is det.
%
%   N es la cantidad de veces que el carácter Letra aparece en el átomo
%   Palabra.
contar_letra(Letra, Palabra, N) :-
    atom_chars(Palabra, Letras),
    contar(Letra, Letras, N).

%!  contar(+X, +L, -N) is det.
%
%   N es la cantidad de veces que X aparece en la lista L.
contar(_, [], 0).
contar(X, [X|Resto], N) :-
    contar(X, Resto, N0),
    N is N0 + 1.
contar(X, [Y|Resto], N) :-
    X \== Y,
    contar(X, Resto, N).
```

```prolog
?- contar_letra(a, banana, N).
N = 3 ;
false.
```

El `false.` final corresponde a la tercera cláusula de `contar/3`, que queda
pendiente después de la segunda y falla al comprobar `X \== Y` con el último
carácter. La respuesta es una sola, como declara el encabezado.

Las cadenas tienen sus propias versiones de los dos predicados, que responden
con cadenas aunque reciban átomos. `string_concat/3` relaciona dos cadenas con
su concatenación, en los dos sentidos, como `atom_concat/3`: con los dos
primeros argumentos ligados, concatena; con el tercero ligado y los dos
primeros libres, enumera todas las maneras de partirlo en dos. `sub_string/5`
es la relación general entre una cadena y sus fragmentos, con los mismos
argumentos y los mismos modos que `sub_atom/5`:

```prolog
?- string_concat("pro", "log", S).
S = "prolog".

?- string_concat(X, Y, "ab").
X = "",
Y = "ab" ;
X = "a",
Y = "b" ;
X = "ab",
Y = "".

?- sub_string(prolog, 0, 3, _, S).
S = "pro".
```

Con el primero y el tercero ligados, `string_concat/3` quita un comienzo
conocido; con el fragmento ligado, `sub_string/5` da cada posición en que
aparece:

<!-- ejemplo: capitulo-11/palabras.pl predicado: sin_prefijo/3 aparece_en/3 consulta: aparece_en("banana", "na", P). -->
```prolog
%!  sin_prefijo(?Prefijo, +Texto, ?Resto) is nondet.
%!  sin_prefijo(+Prefijo, +Texto, -Resto) is semidet.
%
%   Texto es la cadena Prefijo seguida de la cadena Resto.
sin_prefijo(Prefijo, Texto, Resto) :-
    string_concat(Prefijo, Resto, Texto).

%!  aparece_en(+Texto, +Buscado, -Posicion) is nondet.
%
%   Buscado aparece en Texto después de sus primeros Posicion caracteres.
%   Una respuesta por aparición.
aparece_en(Texto, Buscado, Posicion) :-
    sub_string(Texto, Posicion, _, _, Buscado).
```

```prolog
?- sin_prefijo("ERROR: ", "ERROR: falta el archivo", R).
R = "falta el archivo".

?- aparece_en("banana", "na", P).
P = 2 ;
P = 4.
```

`aparece_en/3` responde una vez por aparición. Por eso
`sub_string(Texto, _, _, _, Buscado)`, usado como prueba de que `Texto`
contiene a `Buscado`, puede tener éxito más de una vez.

## 11.5 Dividir y unir

`split_string/4` divide un texto en partes. El segundo argumento son los
caracteres que separan las partes; el tercero, los caracteres que se quitan del
comienzo y del final de cada parte:

```prolog
?- split_string("ana,luis,eva", ",", "", L).
L = ["ana", "luis", "eva"].

?- split_string("  ana , luis ,eva ", ",", " ", L).
L = ["ana", "luis", "eva"].
```

Cada separador produce un corte. Dos separadores seguidos producen, entre ellos,
una cadena vacía:

```prolog
?- split_string("hola  mundo", " ", "", L).
L = ["hola", "", "mundo"].
```

`contar_palabras/2` usa esa propiedad: divide por espacios y descarta las
cadenas vacías con un recorrido:

<!-- ejemplo: capitulo-11/palabras.pl predicado: contar_palabras/2 no_vacias/2 consulta: contar_palabras("el  perro   ladra", N). -->
```prolog
%!  contar_palabras(+Texto, -N) is det.
%
%   N es la cantidad de palabras de Texto, separadas por uno o más espacios.
contar_palabras(Texto, N) :-
    split_string(Texto, " ", " ", Partes),
    no_vacias(Partes, N).

%!  no_vacias(+Cadenas, -N) is det.
%
%   N es la cantidad de cadenas de la lista que no son la cadena vacía.
no_vacias([], 0).
no_vacias([""|Resto], N) :-
    no_vacias(Resto, N).
no_vacias([Cadena|Resto], N) :-
    Cadena \== "",
    no_vacias(Resto, N0),
    N is N0 + 1.
```

```prolog
?- contar_palabras("el  perro   ladra", N).
N = 3.
```

`atomic_list_concat/3` une una lista de átomos, números o cadenas con un
separador, y en el sentido inverso divide un átomo por un separador:

```prolog
?- atomic_list_concat([ana, luis, eva], ', ', A).
A = 'ana, luis, eva'.

?- atomic_list_concat(L, '-', 'a-b-c').
L = [a, b, c].

?- atomic_list_concat([juan, 68], A).
A = juan68.
```

La tercera consulta usa `atomic_list_concat/2`, que une sin separador.
`string_code/3` da el código del carácter que está en una posición, contando
desde 1:

```prolog
?- string_code(1, "ana", C).
C = 97.
```

<!-- ejemplo: capitulo-11/palabras.pl predicado: nombre_completo/3 consulta: nombre_completo(ana, paz, C). -->
```prolog
%!  nombre_completo(+Nombre, +Apellido, -Completo) is det.
%
%   Completo es el átomo formado por Nombre y Apellido separados por un
%   espacio.
nombre_completo(Nombre, Apellido, Completo) :-
    atomic_list_concat([Nombre, Apellido], ' ', Completo).
```

```prolog
?- nombre_completo(ana, paz, C).
C = 'ana paz'.
```

!!! question "Actividad"
    Ejecutar `nombre_completo(N, A, 'ana paz').` y explicar la respuesta a
    partir del encabezado de `nombre_completo/3`. ¿Qué consulta a
    `atomic_list_concat/3` obtiene el nombre y el apellido a partir del nombre
    completo?

## 11.6 Mayúsculas, espacios y comparación

`upcase_atom/2` y `downcase_atom/2` pasan un átomo a mayúsculas o a minúsculas.
`normalize_space/2` reduce cada grupo de espacios a uno solo y quita los del
comienzo y el final; su primer argumento indica en qué forma se quiere el
resultado:

```prolog
?- upcase_atom('ana paz', X).
X = 'ANA PAZ'.

?- downcase_atom('JUAN', X).
X = juan.

?- normalize_space(atom(A), "  hola    mundo  ").
A = 'hola mundo'.
```

Dos textos que una persona considera iguales pueden diferir en mayúsculas o en
espacios. Para compararlos, se normalizan los dos y se compara el resultado:

<!-- ejemplo: capitulo-11/palabras.pl predicado: mismo_nombre/2 normalizado/2 consulta: mismo_nombre('  Ana   Paz ', 'ana paz'). -->
```prolog
%!  mismo_nombre(+A, +B) is semidet.
%
%   A y B son el mismo nombre si se ignoran las mayúsculas y los espacios
%   sobrantes.
mismo_nombre(A, B) :-
    normalizado(A, Normal),
    normalizado(B, Normal).

%!  normalizado(+Texto, -Normal) is det.
%
%   Normal es Texto en minúsculas, con un solo espacio entre palabras y sin
%   espacios al comienzo ni al final.
normalizado(Texto, Normal) :-
    normalize_space(atom(Espaciado), Texto),
    downcase_atom(Espaciado, Normal).
```

```prolog
?- mismo_nombre('  Ana   Paz ', 'ana paz').
true.
```

`mismo_nombre/2` normaliza `A`, y después exige que la normalización de `B` sea
el **mismo** átomo: la variable `Normal` aparece en los dos objetivos, y la
segunda aparición llega con valor.

Además de la igualdad, dos textos se pueden ordenar. `compare/3` informa si el
primero va antes, es igual o va después; `@<`, `@>`, `@=<` y `@>=` hacen la
pregunta correspondiente:

```prolog
?- compare(O, ana, eva).
O = (<).

?- ana @< eva.
true.

?- 'Zoe' @< ana.
true.
```

La última muestra que el orden no es el del diccionario: los átomos se comparan
carácter por carácter según sus códigos, y el código de una mayúscula es menor
que el de cualquier minúscula. Ese orden, que se extiende a todos los términos,
es el orden estándar del [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md).

## 11.7 Escribir términos

`write/1` escribe un término de la manera más legible; otros predicados lo
escriben de manera que se pueda volver a leer:

| Predicado | Escribe |
|---|---|
| `write/1` | sin comillas: para mostrar texto a una persona |
| `print/1` | como `writeq/1`, y respeta las reglas de presentación que el programa defina |
| `writeq/1` | con comillas donde hacen falta: el resultado se puede leer como el mismo término |
| `write_canonical/1` | sin operadores ni notaciones abreviadas: la estructura del término |
| `portray_clause/1` | una cláusula, con la disposición del curso y variables con nombre |

```prolog
?- write('Ana Paz'), nl.
Ana Paz
true.

?- writeq('Ana Paz'), nl.
'Ana Paz'
true.

?- writeq("ana"), nl.
"ana"
true.

?- write_canonical(2 + 3), nl.
+(2,3)
true.
```

`portray_clause/1` escribe la cláusula que recibe con la disposición de un
archivo:

```prolog
?- portray_clause((abuelo(X, Z) :- padre(X, Y), padre(Y, Z))).
```

```text
abuelo(A, B) :-
    padre(A, C),
    padre(C, B).
true.
```

`write_canonical/1` muestra lo que el [capítulo 4](../capitulo-04-terminos-y-unificacion/index.md) explicó sobre los operadores:
`2 + 3` es el término `+(2,3)`. `portray_clause/1` renombra las variables en el
orden en que aparecen: `A`, `B`, `C`.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** Para cada término, indicar si es un átomo, una cadena, una lista de
   códigos o una lista de caracteres: `ana` · `'Ana'` · `"ana"` · `` `ana` `` ·
   `[a, n, a]`. Después predecir cuáles de estas consultas responden `true.`:
   `ana == 'ana'.` · `"ana" == ana.` · `` `ana` == [97, 110, 97]. `` ·
   `[a, n, a] == "ana".`
2. **(1)** Predecir qué responde cada consulta: `atom_codes(hola, C).` ·
   `atom_chars(X, [s, i]).` · `atom_number('3.5', N).` ·
   `atom_number(tres, N).` · `term_to_atom(f(X, b), A).`
3. ★ **(2)** Escribir `ultima_letra(Palabra, L)`: L es el último carácter del
   átomo Palabra. Escribir también su encabezado: qué argumentos deben llegar
   ligados y cuántas respuestas produce.
4. **(2)** Escribir `mas_largo(A, B, M)`: M es el más largo de los átomos A y B;
   si tienen el mismo largo, M es A. Su encabezado es
   `%! mas_largo(+A, +B, -M) is det.`
5. ★ **(1)** Predecir la salida de cada llamada y comprobarla:
   `format("~w y ~w~n", [ana, eva]).` · `format("~d~n", [7]).` ·
   `format("~d~n", [7.0]).` · `format("~3f~n", [2]).` ·
   `format("[~t~w~6|]~n", [ana]).` · `format("[~w~t~6|]~n", [ana]).`
6. **(2)** Escribir `tabla_con_titulos(Personas)`, que escribe una línea de
   títulos (`Nombre` y `Edad`), una línea de guiones del ancho de la tabla, y
   después las filas de `tabla/1`.
7. ★ **(2)** Escribir `palindromo(Palabra)`: Palabra se lee igual de izquierda
   a derecha que de derecha a izquierda. Usar la lista de caracteres y la
   inversión del [capítulo 7](../capitulo-07-listas/index.md).
8. **(2)** Escribir `sin_prefijo(Palabra, Prefijo, Resto)`: Palabra empieza con
   Prefijo, y Resto es lo que sigue. Escribir su encabezado, y explicar qué
   responde `sin_prefijo(prolog, P, R).`
9. **(3)** Escribir `contar_vocales(Palabra, N)`: N es la cantidad de vocales
   del átomo Palabra, en minúscula o en mayúscula.
10. ★ **(1)** Predecir qué responde cada consulta:
    `split_string("a,b,,c", ",", "", L).` ·
    `split_string("  hola  ", "", " ", L).` ·
    `split_string("a b", " ", "", L).` ·
    `atomic_list_concat(L, ', ', 'a, b').`
11. **(2)** Escribir `campos(Linea, Campos)`: Linea es una cadena con campos
    separados por comas y espacios opcionales, y Campos es la lista de esos
    campos como átomos. Por ejemplo, `campos("juan, 68, 1957", C)` responde
    `C = [juan, '68', '1957']`.
12. **(2)** Modificar `campos/2` para que los campos que representan números
    queden como números: `C = [juan, 68, 1957]`.
13. ★ **(2)** Escribir `mismo_texto(A, B)`, que compara dos cadenas sin
    distinguir mayúsculas, espacios sobrantes ni la representación: `A` y `B`
    pueden ser átomos o cadenas. Escribir también su encabezado.
14. **(1)** Predecir la salida de `write/1`, `writeq/1`, `print/1` y
    `write_canonical/1` para cada término: `'Ana Paz'` · `"hola"` · `2 + 3` ·
    `[x, 'Y']` · `- 1`.
15. **(3)** Escribir `iniciales_de(NombreCompleto, Iniciales)`: a partir de
    `'juan carlos perez'`, Iniciales es `'JCP'`. Escribir después sus pruebas:
    una con tres palabras, una con espacios sobrantes y una con una sola
    palabra.

## Resumen

| | |
|---|---|
| átomo, cadena | `ana` y `"ana"`: términos distintos; los átomos para nombres, las cadenas para texto que se procesa |
| listas de códigos y de caracteres | `` `ana` `` y `[a, n, a]`: el texto como lista, para recorrerlo |
| `double_quotes` | la bandera que decide qué significan las comillas dobles; en SWI-Prolog, `string` |
| `atom_codes/2`, `atom_chars/2`, `atom_string/2`, `string_chars/2` | conversiones entre representaciones, en los dos sentidos |
| `atom_number/2`, `number_codes/2`, `term_to_atom/2` | conversiones entre texto, números y términos |
| `format/2`, `format/3` | salida compuesta: `~w ~a ~q ~d ~f ~e ~s ~n`, columnas con `~t ~\| ~+`; `atom(A)` deja el resultado en un átomo |
| `atom_length/2`, `atom_concat/3`, `sub_atom/5` | largo, concatenación y búsqueda de fragmentos |
| `string_concat/3`, `sub_string/5` | concatenación y búsqueda de fragmentos de cadenas |
| `split_string/4`, `atomic_list_concat/2,3` | dividir un texto en partes y unir partes en un texto |
| `upcase_atom/2`, `downcase_atom/2`, `normalize_space/2` | normalizar antes de comparar |
| `compare/3`, `@<` | orden de los textos por códigos de caracteres |
| `write/1`, `writeq/1`, `print/1`, `write_canonical/1`, `portray_clause/1` | escribir un término para una persona o para volver a leerlo |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Analizar un texto con una gramática, en lugar de encadenar `sub_atom/5` | [capítulo 21](../capitulo-21-gramaticas-dcg/index.md) |
| El orden estándar de todos los términos; ordenar listas | [capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md) |
| Leer y escribir texto en archivos; CSV y JSON | [capítulo 27](../capitulo-27-archivos-streams-y-formatos/index.md) |
| Mensajes al usuario con `print_message/2` | [capítulo 25](../capitulo-25-errores-y-excepciones/index.md) |
| Leer texto del teclado en un programa de línea de comandos | [capítulo 28](../capitulo-28-programas-de-linea-de-comandos/index.md) |
