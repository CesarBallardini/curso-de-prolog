# Soluciones del capítulo 2 — Hechos, consultas y variables

El código de esta página está en `ejemplos/capitulo-02/soluciones.pl` y pasa sus
pruebas.

## 1

```prolog
mujer(sofia).
madre(marta, ana).
gusta(luis, futbol).
```

Un hecho por línea, en minúscula y con punto final.

## 2

La única línea válida es `padre(juan, ana).`

- `padre(Juan, ana).` es sintácticamente válida, pero no expresa lo que
  aparenta: `Juan` comienza con mayúscula, por lo que es una variable. Como
  hecho, afirmaría que *cualquier objeto* es padre de ana.
- `padre(juan, ana)`, sin punto, no termina la cláusula, y Prolog continúa
  leyendo la línea siguiente como parte de ella.
- `Padre(juan, ana).` no es válida: el nombre de un predicado debe ser un átomo,
  y un nombre con mayúscula inicial no lo es.

## 3

| | |
|---|---|
| `ana` | átomo |
| `Ana` | variable |
| `_hijo` | variable (los nombres que comienzan con `_` también lo son) |
| `39` | ninguna de las dos: es un número |
| `mi amigo` | no es un término válido: el espacio lo separa en dos |
| `mi_amigo` | átomo (el guion bajo está permitido) |

## 4

```prolog
?- varon(juan).
?- madre(Quien, pedro).
?- gusta(eva, Que).
```

## 5

- `madre(marta, ana).` → `true.`; el hecho está en la base.
- `madre(ana, marta).` → `false.`; los argumentos están en orden inverso.
- `padre(pedro, eva).` → `true.`
- `mujer(pedro).` → `false.`; `pedro` figura como varón.

## 6

`padre(juan, sofia)` usa una relación definida en el programa, `padre/2`. Prolog
la examina, no encuentra ese hecho y responde `false.`: *no se puede probar*.

`hermana(ana, eva)` usa una relación que el programa no define. Prolog no tiene
cláusulas que examinar, y por eso informa un error en lugar de responder.

## 7

<!-- ejemplo: capitulo-02/soluciones.pl predicado: regala/3 consulta: regala(Quien, Que, ana). -->
```prolog
% --- Ejercicio 7: una relación de tres argumentos -------------------------
% regala(Quien, Que, AQuien): Quien le regala Que a AQuien.
regala(juan, libro, ana).
regala(ana, pelota, luis).
regala(marta, planta, eva).
```

El comentario es la parte más importante del ejercicio: sin él, al cabo de poco
tiempo no es posible determinar si el segundo argumento es el objeto regalado o
el destinatario.

## 8

```prolog
?- gusta(Quien, futbol).
Quien = juan ;
Quien = luis.

?- gusta(_, futbol).
true ;
true.
```

## 9

Ambas plantean la misma pregunta, pero la primera informa el valor y la segunda
no. `gusta(ana, Que)` responde `Que = prolog`; `gusta(ana, _)` responde `true.`,
porque no solicita el valor.

El uso de `_` cuando el valor no interesa no es solo una abreviatura: comunica a
quien lee el programa que esa posición no es relevante.

## 10

Es necesario indicar quién es el padre, porque Prolog no puede deducirlo:

```prolog
varon(diego).
padre(diego, sofia).
```

Con esos hechos:

```prolog
?- padre(_, sofia).
true.
```

Antes de agregarlos, la misma consulta respondía `false.`, aunque sofia tenía
padre. No cambió la realidad descripta: cambió la información contenida en el
programa.

## 11

Por el momento, los dos hechos son necesarios.

Que `eva` sea madre de `sofia` implica, para una persona, que `eva` es mujer.
Prolog no dispone de esa información: `madre/2` y `mujer/1` son dos relaciones
independientes, sin otra conexión que la que se escriba en el programa.

Esa conexión se puede escribir: es precisamente una regla, el tema del capítulo
3.

## 12

<!-- ejemplo: capitulo-02/soluciones.pl predicado: cursa/2 dicta/2 consulta: cursa(ana, Materia). -->
```prolog
% --- Ejercicio 12: una base que no es una familia -------------------------
% cursa(P, M): P cursa la materia M.
cursa(ana, logica).
cursa(ana, algebra).
cursa(luis, logica).
cursa(eva, analisis).

% dicta(D, M): D dicta la materia M.
dicta(garcia, logica).
dicta(garcia, algebra).
dicta(pereyra, analisis).
```

Tres consultas con sentido sobre esa base:

```prolog
?- cursa(ana, logica).
true ;
false.

?- cursa(luis, analisis).
false.

?- dicta(Quien, logica).
Quien = garcia.
```

## 13

<!-- ejemplo: capitulo-02/soluciones.pl predicado: nacio_en/2 horas_semanales/2 companiero/2 consulta: companiero(luis, Quien). -->
```prolog
% --- Ejercicio 13: representar enunciados como hechos ---------------------
% nacio_en(P, A): P nació en el año A.
nacio_en(ana, 1985).

% horas_semanales(M, H): la materia M tiene H horas por semana.
horas_semanales(logica, 4).

% companiero(A, B): A y B son compañeros de trabajo.
% La relación es simétrica, y por eso se escriben los dos hechos: Prolog no
% deduce uno del otro.
companiero(ana, luis).
companiero(luis, ana).
```

Los dos primeros no tienen dificultad: un año y una cantidad de horas son
números, y ocupan la posición de un argumento como cualquier otro objeto.

El tercero es el que enseña algo. "Ana y Luis son compañeros" no distingue un
primer argumento de un segundo: la relación vale en los dos sentidos. Prolog no
lo sabe, y con un solo hecho `companiero(ana, luis)` la consulta
`companiero(luis, Quien).` responde `false.`, que es incorrecto. Escribir los
dos hechos resuelve el problema para este caso; el [capítulo 3](../capitulo-03-reglas-y-conjunciones/index.md) muestra la manera
de expresarlo con una regla, sin repetir cada par.

## 14

Ninguno de los tres es un hecho, y cada uno por un motivo distinto:

a. **"Ana es mayor que Luis"** afirma algo que se **deduce** de otros datos, las
   dos edades. Escribirlo como hecho sería registrar dos veces la misma
   información, y quedaría desactualizado. Corresponde a una regla, y es
   exactamente el `mayor_que/2` del [capítulo 1](../capitulo-01-la-primera-hora/index.md).
b. **"Toda persona tiene madre"** habla de **todas** las personas a la vez. Un
   hecho afirma algo sobre objetos determinados, y no hay manera de nombrar
   "todas" escribiendo un hecho. Los enunciados de esta forma se escriben como
   reglas, y el [capítulo 11](../capitulo-11-prolog-y-la-logica/index.md) explica por qué.
c. **"Ana no tiene hijos"** es una **negación**. Un programa Prolog está formado
   por afirmaciones, y no hay forma de escribir la ausencia de una. Lo que se
   hace es no escribir ningún hecho que diga lo contrario, y dejar que Prolog
   responda `false.` por no poder probarlo; la [sección 2.5](index.md#25-lo-que-no-se-puede-probar) ya mostró ese
   mecanismo, y el [capítulo 10](../capitulo-10-negacion-como-falla/index.md) está dedicado a él.

## 15

Cuatro, dos, una y dos respuestas:

```prolog
?- mujer(Quien).
Quien = marta ;
Quien = ana ;
Quien = eva ;
Quien = sofia.

?- madre(marta, Quien).
Quien = ana ;
Quien = pedro.

?- padre(Quien, ana).
Quien = juan.

?- padre(juan, Quien).
Quien = ana ;
Quien = pedro.
```

La cantidad de respuestas es la cantidad de hechos que unifican con la consulta.
Ninguna de las cuatro termina en `false.`, porque en todas el último hecho que
unifica es también el último que Prolog examina.

## 16

```prolog
?- regala(juan, Que, ana).
Que = libro.

?- regala(Quien, _, luis).
Quien = ana.

?- regala(_, Que, _).
Que = libro ;
Que = pelota ;
Que = planta.
```

La tercera consulta muestra para qué sirve `_`: interesa el objeto regalado y no
quiénes participaron. Cada `_` es una variable distinta, de modo que no exigen
que quien regala y quien recibe sean la misma persona.

## 17

| Consulta | Forma de uso | Respuestas |
|---|---|---|
| `gusta(ana, Que).` | `gusta(+P, -C)` | cualquier cantidad: `nondet` |
| `gusta(Quien, prolog).` | `gusta(-P, +C)` | cualquier cantidad: `nondet` |
| `gusta(juan, futbol).` | `gusta(+P, +C)` | una o ninguna: `semidet` |
| `gusta(Quien, Que).` | `gusta(-P, -C)` | cualquier cantidad: `nondet` |

Con la base de `variables.pl`, `gusta(ana, Que)` tiene una sola respuesta, pero
la forma de uso no la garantiza: bastaría un hecho `gusta(ana, futbol)` para que
tuviera dos. La cantidad que se declara es la que admite la relación, no la que
resulta de los hechos cargados en un momento dado.

## 18

```prolog
%!  abuelo(+A, +N) is semidet.
%!  abuelo(+A, -N) is nondet.
%!  abuelo(?A, ?N) is nondet.
%
%   A es abuelo de N.
```

Con los dos argumentos ligados, la consulta pregunta si una afirmación
determinada se deduce del programa: la respuesta es `true` o `false`, y no puede
haber dos respuestas distintas. Con `N` libre, la consulta pregunta por los
nietos de `A`, y una persona puede tener cualquier cantidad de nietos, incluso
ninguno.

Ejecutada en SWI-Prolog, `abuelo(juan, luis)` responde `true ;` y después
`false.`: Prolog queda en espera aunque no haya otra respuesta. No contradice el
encabezado, que describe cuántas respuestas existen y no la forma en que Prolog
termina de mostrarlas; el [capítulo 5](../capitulo-05-como-responde-prolog/index.md) explica ese `;`.
