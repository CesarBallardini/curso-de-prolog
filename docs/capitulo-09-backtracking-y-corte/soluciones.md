# Soluciones del capítulo 9 — Backtracking y corte

El código de esta página está en `ejemplos/capitulo-09/soluciones.pl` y pasa sus
pruebas.

## 1

```prolog
?- categoria(luis, C).
C = chico.

?- categoria_sin_corte(luis, C).
C = chico ;
C = adulto.
```

Luis tiene 12 años: no cumple la condición de bebé, cumple la de chico, y cumple
también la tercera cláusula, que no tiene condición. Con corte se conserva la
primera categoría que corresponde; sin corte se obtienen las dos.

## 2

El `!` de `un_mayor_de_edad/1` hace que el predicado produzca **una sola
respuesta**. Sin él, el predicado entrega todas las personas mayores de edad,
una por cada respuesta solicitada.

Es un uso adecuado del corte: no modifica quiénes son mayores de edad; solo
establece que la primera respuesta es suficiente.

## 3

<!-- ejemplo: capitulo-09/soluciones.pl predicado: categoria_sin_ningun_corte/2 consulta: categoria_sin_ningun_corte(eva, C). -->
```prolog
% categoria_sin_ningun_corte(P, C): las condiciones completas, sin corte.
categoria_sin_ningun_corte(P, bebe) :-
    edad(P, A),
    A < 4.
categoria_sin_ningun_corte(P, chico) :-
    edad(P, A),
    A >= 4,
    A < 13.
categoria_sin_ningun_corte(P, adulto) :-
    edad(P, A),
    A >= 13.
```

Cada cláusula establece su intervalo completo, de modo que ninguna se superpone
con las demás. Es más extensa que la versión del capítulo y repite los límites,
pero no depende del orden: las tres cláusulas se pueden reordenar sin que cambien
las respuestas.

## 4

La versión del ejercicio 3:

```prolog
?- categoria_sin_ningun_corte(sofia, adulto).
false.
```

La versión del capítulo responde `true` a la misma consulta: es el corte rojo de
la sección 9.5. En esta versión no hay ningún corte cuyo efecto dependa de la
unificación de la cabeza: la tercera cláusula exige `A >= 13`, sofía no cumple
esa condición, y la consulta falla, como corresponde.

Es la conclusión general del capítulo: el corte reduce la extensión del
programa, y su costo es que el predicado deja de funcionar en todos los
sentidos.

## 5

<!-- ejemplo: capitulo-09/soluciones.pl predicado: primer_par/2 consulta: primer_par([3, 7, 4, 8], X). -->
```prolog
% primer_par(L, X): X es el primer número par de L.
primer_par([X|_], X) :-
    0 =:= X mod 2,
    !.
primer_par([X|Resto], P) :-
    0 =\= X mod 2,
    primer_par(Resto, P).
```

El corte de la primera cláusula garantiza que la respuesta sea **el primer**
número par: sin él, al solicitar más respuestas se obtendrían todos los pares de
la lista.

La condición `0 =\= X mod 2` de la segunda cláusula es necesaria por la misma
razón que en el capítulo 7: sin ella, un número par se resolvería también por la
cláusula que continúa la búsqueda.

## 6

<!-- ejemplo: capitulo-09/soluciones.pl predicado: hay_algun_menor/1 consulta: hay_algun_menor([41, 12, 68]). -->
```prolog
% hay_algun_menor(L): algún número de L es menor que 18. No requiere corte: es
% suficiente que exista uno, y la consulta se cumple al encontrarlo.
hay_algun_menor(L) :-
    member(X, L),
    X < 18.
```

No requiere corte. La consulta pregunta si **existe** algún elemento que cumpla
la condición, y para ello es suficiente encontrar el primero: en ese momento
Prolog responde `true`.

Un corte solo serviría para eliminar las alternativas pendientes, en caso de que
se soliciten más respuestas. Su efecto se limita a la forma de la respuesta
(`true.` en lugar de `true ;`); agregarlo es opcional.

## 7

Produce dos respuestas, `ana-eva` y `eva-ana`, porque la regla no establece el
orden de las dos personas. Ambas cumplen todas las condiciones: son personas
distintas y sus edades suman 49.

Para obtener una sola respuesta, la solución más adecuada no es un corte sino
**una condición de orden**: exigir, por ejemplo, que la edad de la primera
persona sea mayor que la de la segunda. De ese modo, de cada par se conserva una
sola de las dos formas, y el predicado sigue funcionando en todos los sentidos.

Con `!` también se obtiene una sola respuesta, pero es la primera que se
encuentra, y cuál sea depende del orden de los hechos.

## 8

<!-- ejemplo: capitulo-09/soluciones.pl predicado: primer_cuadrado_mayor/2 consulta: primer_cuadrado_mayor(50, C). -->
```prolog
% primer_cuadrado_mayor(N, C): el primer número cuyo cuadrado supera a N.
primer_cuadrado_mayor(N, C) :-
    between(1, 10000, C),
    C * C > N,
    !.
```

Es una aplicación directa de generar y probar: `between/3` produce los
candidatos en orden y la condición los verifica. El corte detiene la búsqueda en
el primer candidato que cumple la condición.

Para 50 la respuesta es 8, porque 7 × 7 = 49, que no supera a 50.

## 9

El corte rojo está en las dos primeras cláusulas, y se manifiesta en una consulta
con el descuento instanciado: `descuento(8, 0)` responde `true`, porque la
tercera cláusula, `descuento(_, 0)`, unifica con cualquier edad y no tiene
condición.

Es exactamente el caso de la sección 9.5: las cláusulas con `!` no llegan a
ejecutarse, porque sus cabezas no unifican con `0`.

<!-- ejemplo: capitulo-09/soluciones.pl predicado: descuento/2 consulta: descuento(8, D). -->
```prolog
% descuento(Edad, D): el corte rojo corregido, con las condiciones completas.
descuento(Edad, 50) :-
    Edad < 12.
descuento(Edad, 30) :-
    Edad >= 65.
descuento(Edad, 0) :-
    Edad >= 12,
    Edad < 65.
```

La corrección usa las condiciones completas y ningún corte. Con esta versión,
`descuento(8, 0)` responde `false`, que es la respuesta correcta.

## 10

<!-- ejemplo: capitulo-09/soluciones.pl predicado: sin_repetidos/2 consulta: sin_repetidos([a, b, a, c, b], R). -->
```prolog
% sin_repetidos(L, R): R es L sin repetidos; conserva la última aparición de
% cada elemento. El corte descarta las demás soluciones de member/2: es
% suficiente que X aparezca una vez en Resto.
sin_repetidos([], []).
sin_repetidos([X|Resto], [X|RestoR]) :-
    \+ member(X, Resto),
    sin_repetidos(Resto, RestoR).
sin_repetidos([X|Resto], R) :-
    member(X, Resto),
    !,
    sin_repetidos(Resto, R).
```

La segunda cláusula conserva el elemento cuando **no** vuelve a aparecer en el
resto de la lista; la tercera lo descarta cuando sí aparece. En consecuencia, se
conserva la **última** aparición de cada elemento, y el enunciado pedía la
primera.

El corte de la tercera cláusula es verde. `member(X, Resto)` se cumple una vez
por cada aparición de `X` en `Resto`; sin el corte, un elemento que aparece tres
veces o más produciría la misma respuesta repetida, una por cada una de esas
soluciones. Para descartar el elemento es suficiente la primera, y el corte
elimina las demás. No modifica cuáles respuestas son ciertas: la condición
`\+ member(X, Resto)` de la segunda cláusula sigue siendo completa, de modo que
las dos cláusulas no se superponen.

```prolog
?- sin_repetidos([a, b, a, c, b], R).
R = [a, c, b] ;
false.
```

El resultado es `[a, c, b]` y no `[a, b, c]`. Ambos criterios son válidos; lo
importante es identificar cuál de los dos implementa el programa. Para conservar
la primera aparición se debe registrar qué elementos ya se incluyeron, lo que
requiere un acumulador, como en el capítulo 8.

## 11

| Consulta | Respuestas |
|---|---|
| `color(C).` | tres: `rojo`, `verde`, `azul` |
| `primero(C).` | una: `rojo` |
| `primero(verde).` | **una**, es decir, se cumple |
| `primero(rojo).` | una |

La tercera es la que enseña algo, y responde `true.` aunque `verde` no sea el
primer color. La causa es la de la sección 9.5: al consultar `primero(verde)`,
la cabeza `primero(C)` unifica con `C = verde`, de modo que el objetivo del
cuerpo ya no es "dame el primer color" sino `color(verde)`, que se cumple de
manera directa. El `!` se ejecuta después, cuando ya no hay nada que podar.

`primero/1` es entonces un corte rojo: funciona con el argumento libre y
responde mal con el argumento instanciado.

## 12

| Objetivo que se intenta | Qué hace Prolog | Alternativas que quedan |
|---|---|---|
| `categoria(luis, C)` | prueba la primera cláusula, `categoria(P, bebe)`; la cabeza unifica con `C` libre | las otras dos cláusulas |
| `edad(luis, A)` | encuentra `edad(luis, 12)` | ninguna otra edad de luis |
| `12 < 4` | falla | — |
| `categoria(luis, C)` | retrocede a la segunda cláusula, `categoria(P, chico)` | la tercera cláusula |
| `edad(luis, A)` | encuentra `edad(luis, 12)` | ninguna |
| `12 < 13` | se cumple | — |
| `!` | **se ejecuta** | ninguna: descarta la tercera cláusula y el reingreso a `edad/2` |

```prolog
?- categoria(luis, C).
C = chico.
```

El `!` se ejecuta en el sexto paso, y lo que descarta son dos cosas a la vez: la
tercera cláusula de `categoria/2`, que habría respondido `adulto`, y la
posibilidad de volver a `edad(luis, A)` para buscar otra edad. Por eso la
respuesta termina en punto y no en `;`.

## 13

El corte **no** afecta a las llamadas recursivas. Según la primera regla de la
sección 9.3, descarta las cláusulas siguientes **para la invocación que entró en
esa cláusula**, y cada llamada recursiva es una invocación distinta, con sus
propias alternativas.

```prolog
?- primer_par([1, 3, 4, 6], X).
X = 4.
```

Conviene seguir lo que ocurre: la llamada sobre `[1, 3, 4, 6]` no llega al corte
—1 es impar—, y pasa a la segunda cláusula, que llama sobre `[3, 4, 6]`. Esa
tampoco. La llamada sobre `[4, 6]` sí llega al `!`, y ahí descarta la segunda
cláusula **de esa llamada**, que habría seguido buscando pares en `[6]`. Las
llamadas externas no se ven afectadas: simplemente reciben la respuesta.

El efecto útil es exactamente ese: sin el corte, el predicado respondería
también `X = 6`.

## 14

<!-- ejemplo: capitulo-09/soluciones.pl predicado: clasificar/2 consulta: clasificar(5, C). -->
```prolog
% clasificar(N, C): C es negativo, cero o positivo, según N. Plantilla 14.
% Correcto con C libre; con C instanciado, el corte puede no ejecutarse.
clasificar(N, negativo) :-
    N < 0,
    !.
clasificar(0, cero) :-
    !.
clasificar(_, positivo).
```

Con el segundo argumento libre, el predicado responde bien:

```prolog
?- clasificar(5, C).
C = positivo.

?- clasificar(5, negativo).
false.
```

`clasificar(5, negativo)` responde `false.`, que es correcto: la primera
cláusula unifica con `negativo` pero `5 < 0` falla, la segunda exige un `0` en
el primer argumento, y la tercera exige `positivo` en el segundo.

El caso que falla es el opuesto:

```prolog
?- clasificar(-2, positivo).
true.
```

El programa afirma que −2 es positivo. Las dos primeras cláusulas se descartan
por la cabeza —`positivo` no unifica con `negativo` ni con `cero`—, de modo que
ningún `!` llega a ejecutarse, y la tercera cláusula unifica sin verificar nada.

La conclusión es la de la sección 9.5, y conviene enunciarla como regla de la
plantilla 14: la **última** cláusula es la peligrosa, porque no lleva condición
y afirma su caso para todo lo que llegue hasta ella. Si el predicado debe
admitir consultas con el resultado ya instanciado, hay que escribir las
condiciones completas en lugar de confiar en el orden.

## 15

Las pruebas van en `generar.plt`, junto al predicado:

```prolog
% Ejercicio 15 del capítulo: el corte de primer_multiplo/3 es rojo.
test(primer_multiplo_responde, all(N == [21])) :-
    primer_multiplo(7, 20, N).

% Con el tercer argumento instanciado el corte no llega a podar nada, y el
% predicado acepta un múltiplo que no es el primero.
test(primer_multiplo_acepta_uno_que_no_es_el_primero) :-
    primer_multiplo(7, 20, 28).
```

La primera prueba usa `all` con una lista de **un** elemento, y eso verifica dos
cosas a la vez: que la respuesta es 21 y que no hay una segunda. Sin el corte,
esa misma prueba fallaría, porque la lista tendría todos los múltiplos.

La segunda documenta el defecto en lugar de ocultarlo. Una prueba no está
solamente para comprobar que un predicado funciona: también sirve para dejar
escrito hasta dónde funciona.
