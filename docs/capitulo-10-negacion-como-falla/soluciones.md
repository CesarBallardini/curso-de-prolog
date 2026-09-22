# Soluciones del capítulo 10 — Negación como falla

El código de esta página está en `ejemplos/capitulo-10/soluciones.pl` y pasa sus
pruebas.

## 1

```prolog
?- \+ padre(pedro, luis).
false.

?- \+ padre(luis, pedro).
true.
```

La primera falla porque el hecho está en el programa: pedro **es** el padre de
luis, de modo que el objetivo negado se prueba y `\+` no se cumple. La segunda se
cumple porque ese hecho no figura en el programa ni se deduce de él.

## 2

| | |
|---|---|
| `ana == ana` | **true**: es el mismo término |
| `ana = ana` | **true**: unifican, sin instanciar ninguna variable |
| `ana \== eva` | **true**: son términos distintos |
| `X == ana` | **false**: una variable libre no *es* el átomo `ana` |
| `X = ana` | **true**, y liga `X` a `ana` |

Las dos últimas filas resumen la diferencia entre `=` y `==`: el primero puede
instanciar variables; el segundo solo compara.

## 3

<!-- ejemplo: capitulo-10/soluciones.pl predicado: no_es_hijo_de/2 consulta: no_es_hijo_de(H, juan). -->
```prolog
% no_es_hijo_de(H, P): H es una persona que no es hijo de P.
% persona(H) se escribe primero para que \+ opere sobre un valor instanciado.
no_es_hijo_de(H, P) :-
    persona(H),
    \+ padre(P, H).
```

El aspecto relevante es el orden. Con `\+` en primer lugar, `H` llegaría libre, y
la pregunta sería "¿es imposible probar que juan tiene hijos?", que es falsa; el
predicado no produciría ninguna respuesta.

juan figura entre las respuestas, y es correcto: no es hijo de sí mismo.

## 4

<!-- ejemplo: capitulo-10/soluciones.pl predicado: tiene_hermano/1 sin_hermanos/1 consulta: sin_hermanos(Quien). -->
```prolog
% tiene_hermano(P): P tiene algún hermano.
tiene_hermano(P) :-
    padre(Padre, P),
    padre(Padre, Otro),
    Otro \== P.

% sin_hermanos(P): P no tiene hermanos.
sin_hermanos(P) :-
    persona(P),
    \+ tiene_hermano(P).
```

Se requieren los dos predicados; la razón es el tema del ejercicio 5.

## 5

Porque `\+` no permite expresar "no existe **otro**". Solo permite expresar "este
objetivo no se puede probar".

Para determinar que P no tiene hermanos, se debe establecer que es imposible
probar que existe una persona que es hija del mismo padre y distinta de P. Esa
condición —una persona que cumple tres objetivos a la vez— es un objetivo
compuesto con su propia variable, y la forma de negarlo como una unidad es darle
un nombre: un predicado auxiliar.

Si los tres objetivos se escribieran directamente dentro de `\+`, se estaría
negando la conjunción completa, con variables libres en su interior, lo que
dificulta la lectura y favorece los errores de la sección 10.4. El predicado
auxiliar deja explícito qué condición se niega.

## 6

<!-- ejemplo: capitulo-10/soluciones.pl predicado: nadie_tiene/1 consulta: nadie_tiene(tortuga). -->
```prolog
% nadie_tiene(Cosa): nadie tiene Cosa. Es correcto con Cosa instanciada.
nadie_tiene(Cosa) :-
    \+ tiene(_, Cosa).
```

Funciona correctamente con `Cosa` **instanciada**: `nadie_tiene(tortuga)`
responde `true` y `nadie_tiene(gato)` responde `false`, que son las respuestas
correctas.

Con `Cosa` libre no es útil: `nadie_tiene(X)` pregunta si es imposible probar
que alguien tiene algo, y como ana tiene un gato, responde siempre `false`. No
enumera los objetos que nadie tiene, porque `\+` no genera valores.

## 7

El problema es el orden de los objetivos, igual que en la sección 10.4. Con `\+`
en primer lugar, `P` está libre, de modo que la pregunta es "¿es imposible probar
que alguien está casado?". Como juan está casado, la respuesta es negativa, y
`soltero/1` no produce ninguna respuesta.

<!-- ejemplo: capitulo-10/soluciones.pl predicado: soltero/1 consulta: soltero(Quien). -->
```prolog
% soltero(P): P no está casado. Con los objetivos en el orden correcto.
soltero(P) :-
    persona(P),
    \+ casado(P, _).
```

Con `persona(P)` en primer lugar, la negación se evalúa para cada persona por
separado.

## 8

<!-- ejemplo: capitulo-10/soluciones.pl predicado: solo_en_la_primera/3 consulta: solo_en_la_primera([ana, luis, eva], [luis], R). -->
```prolog
% solo_en_la_primera(L1, L2, R): los elementos de L1 que no están en L2.
% El corte descarta las demás soluciones de member/2: es suficiente que X
% aparezca una vez en L2.
solo_en_la_primera([], _, []).
solo_en_la_primera([X|Resto], L2, [X|RestoR]) :-
    \+ member(X, L2),
    solo_en_la_primera(Resto, L2, RestoR).
solo_en_la_primera([X|Resto], L2, R) :-
    member(X, L2),
    !,
    solo_en_la_primera(Resto, L2, R).
```

Tiene tres cláusulas, como varios ejercicios anteriores: la lista vacía, el caso
en que el elemento se conserva y el caso en que se descarta. Las condiciones de
las dos últimas son complementarias —`\+ member(...)` y `member(...)`—, de modo
que no se superponen.

El corte de la tercera cláusula es verde, como el de `sin_repetidos/2` del
capítulo 9. `member(X, L2)` se cumple una vez por cada aparición de `X` en `L2`;
sin el corte, un elemento repetido en `L2` produciría la misma respuesta más de
una vez. Para descartar el elemento es suficiente la primera solución, y el
corte elimina las demás.

En este predicado `\+` está correctamente ubicado: cuando se lo evalúa, `X` ya
está instanciada, porque proviene de la descomposición de la lista en la cabeza
de la cláusula.

## 9

Con los elementos vistos hasta este capítulo, no es posible.

"P no tiene hijos" es una afirmación sobre **todos** los hijos posibles de P: se
debe verificar que no existe ninguno. Prolog puede recorrer todas las respuestas
de un objetivo, pero los elementos vistos hasta aquí solo permiten examinarlas de
a una, a medida que se producen.

`\+` es, precisamente, la única construcción de la parte I que evalúa un objetivo
completo —con todas sus respuestas— y produce un resultado sobre el conjunto.

El elemento que falta es la posibilidad de reunir todas las respuestas en una
lista y operar sobre ella. Es el tema del capítulo 15, que presenta también
`forall/2`, un predicado que expresa "para todos" de manera directa y sin los
problemas de orden de este capítulo.

## 10

```prolog
?- ana = ana.
true.

?- ana == ana.
true.

?- X = ana.
X = ana.

?- X == ana.
false.

?- 2 + 1 == 3.
false.

?- 2 + 1 =:= 3.
true.

?- 2 + 1 = 3.
false.
```

`X = ana.` es la única cuya respuesta no es `true.` ni `false.`: es una
ligadura, porque `=` puede **hacer** que los dos términos coincidan, e informa
con qué valor. `X == ana.` responde `false.` porque pregunta si ya son el mismo
término, y una variable sin valor no lo es.

Las tres últimas separan las tres preguntas distintas que se pueden hacer sobre
`2 + 1` y `3`: si son el mismo término escrito (`==`, no), si valen lo mismo
(`=:=`, sí), y si pueden hacerse idénticos (`=`, no, porque ninguno de los dos
tiene variables que ligar).

## 11

```prolog
?- ana \= eva.
true.

?- ana \== eva.
true.

?- X \= ana.
false.

?- X \== ana.
true.

?- 2 + 1 \== 3.
true.

?- 2 + 1 =\= 3.
false.
```

Las dos que responden de manera distinta de lo que sugiere su lectura en
castellano son **`X \= ana.`** y **`2 + 1 =\= 3.`**

`X \= ana` se lee "X no es ana" y responde `false.`, porque lo que pregunta es
si los dos términos **no pueden** unificar, y sí pueden: basta con ligar `X` a
`ana`. Es el tema de la sección 10.6.

`2 + 1 =\= 3` se lee "dos más uno es distinto de tres" y responde `false.`
porque es correcto: los dos **valen** lo mismo. La confusión viene de compararla
con `2 + 1 \== 3`, que responde `true.` y es igual de correcta: son términos
distintos con el mismo valor.

## 12

La causa es la de la sección 10.4: cuando se evalúa `\+ tiene(P, _)`, la
variable `P` todavía está libre, de modo que la pregunta no es "¿P no tiene
mascota?" sino "¿es imposible que **alguien** tenga mascota?". Como ana tiene
un gato, el objetivo negado se prueba, `\+` falla, y la regla completa falla
para todos.

<!-- ejemplo: capitulo-10/soluciones.pl predicado: sin_mascota_correcto/1 consulta: sin_mascota_correcto(Quien). -->
```prolog
% sin_mascota(P): P es una persona que no tiene ninguna mascota.
% persona(P) se escribe primero, para que \+ opere sobre un valor concreto.
sin_mascota_correcto(P) :-
    persona(P),
    \+ tiene(P, _).
```

```prolog
?- sin_mascota_correcto(Quien).
Quien = juan ;
Quien = pedro ;
Quien = eva.
```

## 13

<!-- ejemplo: capitulo-10/soluciones.pl predicado: ninguno_es/2 esta_en_lista/2 ninguno_es_recorriendo/2 consulta: ninguno_es(sofia, [ana, luis]). -->
```prolog
% ninguno_es(X, L): ningún elemento de L es X. Con \+ sobre la pertenencia.
ninguno_es(X, L) :-
    \+ esta_en_lista(X, L).

esta_en_lista(X, [X|_]).
esta_en_lista(X, [_|Resto]) :-
    esta_en_lista(X, Resto).

% ninguno_es_recorriendo(X, L): lo mismo, sin \+, con la plantilla 11.
ninguno_es_recorriendo(_, []).
ninguno_es_recorriendo(X, [Otro|Resto]) :-
    X \== Otro,
    ninguno_es_recorriendo(X, Resto).
```

Con `X` instanciada las dos versiones coinciden. Con `X` libre responden cosas
opuestas, y ninguna de las dos responde lo que la lectura en castellano
sugeriría:

- `ninguno_es(X, [ana, luis]).` **falla**. `\+` pregunta si es imposible que
  `X` pertenezca a la lista, y no lo es: `X` puede ser `ana`. Además, aunque
  tuviera éxito, `\+` no dejaría ninguna ligadura.
- `ninguno_es_recorriendo(X, [ana, luis]).` **se cumple**, dejando `X` sin
  valor. `X \== ana` es cierto, porque una variable sin valor y `ana` son
  términos distintos; y lo mismo con `luis`. El predicado afirma entonces algo
  que no se sostiene: que hay un `X` que no es ninguno de los dos, sin decir
  cuál.

Las dos fallas son la misma de fondo: `\+` y `\==` consultan el estado actual de
los términos, no todos los valores posibles.

## 14

```prolog
?- \+ \+ padre(juan, H).
true.

?- padre(juan, H).
H = ana ;
H = pedro.
```

La primera responde `true.` **sin informar ningún valor de `H`**, aunque por
dentro haya encontrado uno.

El objetivo interno `padre(juan, H)` se prueba y liga `H` a `ana`. El primer
`\+` lo ve cumplirse, de modo que falla, y al fallar **descarta la ligadura**.
El segundo `\+` ve fallar al primero, y por lo tanto se cumple. El resultado es
un objetivo que tiene éxito exactamente cuando el original lo tenía, pero que
no deja ninguna ligadura.

Es la manera más directa de comprobar lo que dice la sección 10.4: `\+` es una
prueba, y una prueba no produce valores. La doble negación se usa justamente
para eso, cuando se quiere saber si un objetivo se cumple sin conservar lo que
haya ligado.

## 15

El predicado se escribe invirtiendo las dos listas al invocar el del ejercicio
8, y eso alcanza mientras las dos listas estén completas:

```prolog
solo_en_la_segunda(L1, L2, R) :-
    solo_en_la_primera(L2, L1, R).
```

Lo que el ejercicio pide justificar es el caso en que no lo están.
`solo_en_la_primera/3` recorre su **primera** lista y consulta la pertenencia en
la segunda con `\+`. Si la segunda lista contiene variables sin valor, ese `\+`
opera sobre términos que todavía no son lo que van a ser, y decide que un
elemento "no pertenece" cuando en realidad podría pertenecer.

Al invertir los argumentos se invierte también cuál de las dos listas queda bajo
el `\+`, de modo que las dos versiones no son intercambiables en ese caso: cada
una exige que esté completa una lista distinta. Conviene anotarlo en el
comentario de cada predicado.
