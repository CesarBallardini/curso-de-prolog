# Capítulo 10 — Negación como falla

El capítulo 2 estableció que `false.` no significa "la afirmación es falsa" sino
"la afirmación no se puede probar con el contenido del programa". Este capítulo
desarrolla esa idea, la convierte en un operador —`\+`— y describe los tres
casos en que ese operador produce resultados incorrectos.

Es el último capítulo sobre el modelo de ejecución de Prolog. El capítulo
siguiente analiza todo lo anterior desde el punto de vista de la lógica.

## Objetivos del capítulo

Al terminar el capítulo, el lector puede:

- usar `\+` para exigir que un objetivo **no** se pueda probar;
- explicar por qué `\+` no equivale exactamente a la negación de la lógica;
- ubicar `\+` en la posición correcta de una regla, y reconocer el efecto de una
  ubicación incorrecta;
- elegir entre `=`, `\=`, `==`, `\==`, `=:=` y `=\=` según la pregunta que plantea
  cada uno.

!!! info "Tiempo estimado"
    Leer el capítulo, ejecutar sus ejemplos y hacer las actividades: **0:30 h**.
    Resolver los 7 ejercicios marcados con ★: **1:45 h**.
    Resolver los 15 ejercicios del final: **4:50 h**.

## 10.1 El supuesto de mundo cerrado

Prolog responde `false.` cuando no puede probar una consulta. La respuesta no
indica que la afirmación sea falsa: indica que la información disponible no es
suficiente para probarla.

Este criterio se denomina **hipótesis del mundo cerrado**. Consiste en suponer
que el programa contiene **toda la información relevante** sobre el dominio, y
que toda afirmación que no está escrita ni se deduce no es cierta.

Es un supuesto fuerte, y se lo debe tener presente, porque en él se apoya todo
el contenido de este capítulo. Si el programa no indica quién es el padre de
sofía, Prolog se comporta como si sofía no tuviera padre. Para la base de datos
de una empresa el supuesto suele ser adecuado: si un empleado no figura en la
nómina, no trabaja en la empresa. Para el mundo en general, casi nunca lo es.

## 10.2 `\+`: no se puede probar

`\+` se antepone a un objetivo, y se cumple **cuando ese objetivo falla**:

```prolog
?- \+ padre(ana, juan).
true.

?- \+ padre(juan, ana).
false.
```

En la primera consulta no se puede probar que ana sea el padre de juan, por lo
que `\+` se cumple. En la segunda, juan es el padre de ana, el objetivo se
prueba, y por lo tanto `\+` falla.

El operador se denomina **negación como falla**, y el nombre describe con
exactitud su funcionamiento: no demuestra que una afirmación sea falsa, sino que
**no logra demostrar que sea cierta**, e interpreta ese resultado como una
negación.

Su definición interna es simple: se intenta probar el objetivo; si se cumple,
`\+` falla; si falla, `\+` se cumple. El corte del capítulo 9 forma parte de esa
definición.

## 10.3 Por qué no es la negación de la lógica

En lógica, "no P" es cierto cuando P es falso. En Prolog, `\+ P` se cumple cuando
P no se puede **probar**, que es una condición distinta.

La diferencia se manifiesta cuando falta información:

```prolog
?- \+ padre(pedro, sofia).
true.
```

En la base del ejemplo, sofía no figura en ningún hecho. Prolog no puede probar
que pedro sea su padre, de modo que `\+` se cumple: el programa afirma que pedro
**no** es el padre de sofía. Sin embargo, lo único que ocurre en realidad es que
el programa no contiene información sobre sofía.

Regla práctica: **`\+` es confiable en la medida en que el programa es
completo**. Sobre la información que el programa contiene, opera correctamente.
Sobre la información que no contiene, responde como si no existiera.

Hay una segunda diferencia, más silenciosa. La hipótesis de la sección 10.1 dice
"lo que el programa no puede deducir"; `\+` es más estricto: exige que la
búsqueda **fracase en una cantidad finita de pasos**. Por eso el nombre completo
del mecanismo es *negación como falla finita*. Si el objetivo negado corresponde
a una búsqueda que no termina —como las ramas infinitas de la sección 5.6—, `\+`
no responde `true.` ni `false.`: no responde nunca. Es el tercer caso en que el
operador no se comporta como la negación que aparenta, y a diferencia de los
otros dos no produce una respuesta incorrecta sino ninguna respuesta.

## 10.4 Dónde ubicar `\+`

Esta sección describe el error más frecuente del capítulo. Conviene observarlo
en ejecución.

Se requieren las personas que no tienen hijos. La siguiente definición es
correcta:

<!-- ejemplo: capitulo-10/negacion.pl predicado: no_tiene_hijos/1 consulta: no_tiene_hijos(Quien). -->
```prolog
% no_tiene_hijos(P): P no es padre de nadie.
% Primero se genera una persona; después se evalúa la negación sobre ella.
no_tiene_hijos(P) :-
    persona(P),
    \+ padre(P, _).
```

```prolog
?- no_tiene_hijos(Quien).
Quien = ana ;
Quien = luis ;
Quien = eva.
```

La siguiente, que aparenta ser equivalente con los objetivos en orden inverso,
no lo es:

<!-- ejemplo: capitulo-10/negacion.pl predicado: mal_no_tiene_hijos/1 consulta: mal_no_tiene_hijos(Quien). -->
```prolog
% mal_no_tiene_hijos(P): la misma regla con los objetivos en orden inverso. Es
% incorrecta; la sección 10.4 explica la causa.
mal_no_tiene_hijos(P) :-
    \+ padre(P, _),
    persona(P).
```

```prolog
?- mal_no_tiene_hijos(Quien).
false.
```

**No produce ninguna respuesta**, ni siquiera las correctas.

La causa es la siguiente. Cuando la ejecución llega a `\+ padre(P, _)`, la
variable `P` todavía está libre. La pregunta que se plantea no es "¿P no tiene
hijos?" sino **"¿es imposible probar que alguien tiene hijos?"**. Como juan
tiene hijos, el objetivo negado se prueba, `\+` falla, y con él falla toda la
regla.

La diferencia se resume en una línea: **con una variable libre, `\+` no pregunta
si existe algún valor que falle, sino si fallan todos.**

Conviene ser preciso sobre lo que ocurre, porque no es que `\+` ignore las
variables libres. El objetivo interno sí las liga mientras intenta la
demostración —`padre(P, _)` liga `P` a `juan` y se prueba—, pero `\+` descarta
esas ligaduras al terminar: lo único que conserva es si el objetivo se pudo
probar o no. Por eso `\+` nunca deja una variable con valor, y solo puede
responder `true.` o `false.`, nunca `P = ...`.

Prolog no verifica esta situación ni emite ninguna advertencia. La consecuencia
no es solo que falten respuestas: el programa afirma cosas que no se siguen de
lo que tiene escrito.

Por eso la versión correcta escribe `persona(P)` en primer lugar: ese objetivo
instancia `P`, y a partir de ese punto `\+` opera sobre un valor concreto.

La versión incorrecta **funciona** cuando se le provee el argumento:

```prolog
?- mal_no_tiene_hijos(ana).
true.
```

Con `ana` instanciada desde el comienzo, `\+` tiene un valor que verificar. El
predicado funciona en un sentido y no en el otro, igual que el corte rojo del
capítulo 9, y por la misma razón de fondo: su comportamiento depende de qué
argumentos llegan instanciados.

!!! warning "Regla de ubicación de `\+`"
    `\+` se escribe **después** de los objetivos que instancian sus variables.
    Un `\+` cuyo objetivo contiene una variable libre es, en la mayoría de los
    casos, un error.

!!! question "Actividad"
    Los dos predicados de esta sección están en `negacion.pl`. Antes de
    ejecutar nada, determinar cuál de los dos responde `false.` sin nombrar a
    nadie. Ejecutar después `no_tiene_hijos(Quien).` y
    `mal_no_tiene_hijos(Quien).` y explicar la diferencia a partir del orden de
    los objetivos. Conviene además ejecutar `mal_no_tiene_hijos(ana).`, que sí
    responde: el mismo predicado funciona o no según qué argumentos lleguen con
    valor.

## 10.5 Los seis operadores de igualdad y desigualdad

En los capítulos anteriores se presentaron varios operadores de igualdad, de a
uno por vez. Esta sección los reúne.

<!-- ejemplo: capitulo-10/comparar.pl predicado: mismo_termino/2 mismo_valor/2 consulta: mismo_termino(2 + 1, 3). -->
```prolog
% mismo_termino(A, B): A y B son el mismo término, en su estado actual.
mismo_termino(A, B) :-
    A == B.

% mismo_valor(A, B): las expresiones A y B tienen el mismo valor.
mismo_valor(A, B) :-
    A =:= B.
```

| | Pregunta | Ejemplo que responde `true` |
|---|---|---|
| `=` | ¿pueden unificar? | `X = ana` |
| `\=` | ¿no pueden unificar? | `ana \= eva` |
| `==` | ¿son el mismo término, en su estado actual? | `ana == ana` |
| `\==` | ¿no son el mismo término? | `2 + 1 \== 3` |
| `=:=` | ¿las dos expresiones tienen el mismo valor? | `2 + 1 =:= 3` |
| `=\=` | ¿tienen distinto valor? | `2 + 1 =\= 4` |

La diferencia entre las dos filas centrales y las dos últimas se aprecia con un
ejemplo:

```prolog
?- 2 + 1 == 3.
false.

?- 2 + 1 =:= 3.
true.
```

`2+1` y `3` **no son el mismo término** —uno es un término compuesto y el otro,
un número—, pero **tienen el mismo valor**. `==` compara la estructura; `=:=`
compara el valor.

Respecto de `=` y `==`: el primero puede instanciar variables; el segundo no
modifica nada. `X = ana` se cumple y liga `X` a `ana`; `X == ana` falla, porque
una variable libre no **es** el átomo `ana`, aunque pueda quedar ligada a él.

## 10.6 `\=` con variables libres

`\=` presenta el mismo problema que `\+`, por la misma razón:

```prolog
?- ana \= eva.
true.

?- X \= ana.
false.
```

El segundo resultado requiere explicación. `X` está libre, por lo que **puede**
unificar con `ana`; en consecuencia, "no unifican" es falso. La lectura "X es
cualquier otro término" no corresponde a la pregunta que plantea `\=`.

La solución es la misma de la sección 10.4: instanciar la variable antes de la
comparación.

<!-- ejemplo: capitulo-10/negacion.pl predicado: distinto_de/2 consulta: distinto_de(Quien, ana). -->
```prolog
% distinto_de(P, Otro): P es una persona que no es Otro.
distinto_de(P, Otro) :-
    persona(P),
    P \= Otro.
```

Primero `persona(P)` instancia la variable, y después `P \= Otro` compara dos
términos concretos.

Cuando ninguno de los dos operandos contiene variables, `\=` y `\==` producen el
mismo resultado, y se puede usar cualquiera de los dos. La condición es que no
haya variables en ninguna parte del término, y no solamente que los dos
operandos tengan valor: `f(A)` y `f(B)` tienen valor, y sin embargo

```prolog
?- X = f(A), Y = f(B), X \= Y.
false.

?- X = f(A), Y = f(B), X \== Y.
X = f(A),
Y = f(B).
```

`X \= Y` responde `false` porque los dos términos **pueden** hacerse idénticos,
ligando `A` con `B`. `X \== Y`, en cambio, se cumple, porque tal como están
escritos son términos distintos; la respuesta no es `true.` sino las ligaduras
de `X` e `Y`, que son las que estableció el primer objetivo de la consulta.

La convención es usar `\==` cuando el propósito es comparar, porque indica de
manera explícita que no se espera ninguna instanciación.

!!! question "Actividad"
    Sobre `comparar.pl`, ejecutar `pueden_ser_el_mismo(X, ana).` y después
    `X = eva, pueden_ser_el_mismo(X, ana).` El mismo objetivo cambia de
    respuesta según si la variable ya tiene valor cuando se lo evalúa. Escribir
    en una línea la conclusión: `\=` y `\+` consultan el estado **actual** de
    los términos, no todos los valores que podrían tomar.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio, y los capítulos siguientes los dan por hechos.

1. ★ **(1)** ¿Qué responde `\+ padre(pedro, luis).`? ¿Y `\+ padre(luis, pedro).`?
2. **(1)** ¿Cuáles de las siguientes responden `true`? `ana == ana` ·
   `ana = ana` · `ana \== eva` · `X == ana` · `X = ana`
3. **(2)** Escribir `no_es_hijo_de(H, P)`: H es una persona que no es hijo de P.
   Prestar atención al orden de los objetivos.
4. **(2)** Escribir `sin_hermanos(P)`: P no tiene ningún hermano. Se requiere un
   predicado auxiliar, como en `hijo_unico/1` del ejemplo.
5. ★ **(2)** ¿Por qué `hijo_unico/1` del ejemplo requiere el predicado auxiliar
   `otro_hijo/2`? ¿No es suficiente escribir `\+` dentro de la regla?
6. **(2)** Escribir `nadie_tiene(Cosa)` sobre una base de hechos `tiene/2`, y
   explicar con qué argumentos funciona correctamente.
7. ★ **(3)** El siguiente predicado produce respuestas incorrectas. Explicar la
   causa y corregirlo:

    ```prolog
    soltero(P) :-
        \+ casado(P, _),
        persona(P).
    ```

8. **(3)** Escribir `solo_en_la_primera(L1, L2, R)`: `R` contiene los elementos
   de `L1` que no pertenecen a `L2`.
9. **(3)** ¿Se puede escribir `no_tiene_hijos/1` sin usar `\+`? Intentarlo y, si
   no es posible con los elementos vistos, explicar qué elemento falta.
10. ★ **(1)** Predecir qué responde cada consulta, con los seis operadores de la
    sección 10.5. Cuando la respuesta no sea `true.` ni `false.`, indicar qué es:
    `ana = ana.` · `ana == ana.` · `X = ana.` · `X == ana.` ·
    `2 + 1 == 3.` · `2 + 1 =:= 3.` · `2 + 1 = 3.`
11. ★ **(1)** El mismo ejercicio con las formas negadas:
    `ana \= eva.` · `ana \== eva.` · `X \= ana.` · `X \== ana.` ·
    `2 + 1 \== 3.` · `2 + 1 =\= 3.`

    Dos de estas seis responden de manera distinta de lo que sugiere su lectura
    en castellano. Identificarlas.
12. ★ **(2)** El predicado siguiente pretende hallar las personas que no tienen
    mascota, y produce respuestas incorrectas. Explicar la causa con la regla de
    ubicación de la sección 10.4 y corregirlo:

    ```prolog
    sin_mascota(P) :-
        \+ tiene(P, _),
        persona(P).
    ```
13. **(2)** Escribir `ninguno_es(X, L)`, que se cumple cuando ningún elemento de
    `L` es `X`, de dos maneras: con `\+` sobre la pertenencia, y sin `\+`,
    recorriendo la lista con la plantilla 11. Comparar qué ocurre con cada una
    al consultar `ninguno_es(X, [ana, luis]).` con `X` libre.
14. ★ **(2)** Determinar qué responde `\+ \+ padre(juan, H).` y compararlo con
    `padre(juan, H).` Explicar la diferencia: ¿qué ocurre con las ligaduras que
    el objetivo interno produjo?
15. **(3)** Escribir `solo_en_la_segunda(L1, L2, R)`, análogo al ejercicio 8
    pero con las listas invertidas, y después explicar por qué no alcanza con
    consultar `solo_en_la_primera(L2, L1, R)` cuando alguna de las dos listas
    tiene elementos sin instanciar.

## Resumen

| | |
|---|---|
| `\+ Objetivo` | se cumple cuando Objetivo **no** se puede probar |
| **negación como falla** | no demuestra que una afirmación sea falsa: no logra demostrar que sea cierta |
| **mundo cerrado** | lo que el programa no puede deducir se considera no cierto |
| ubicación de `\+` | después de los objetivos que instancian sus variables |
| `=` `\=` | pueden unificar, o no pueden unificar |
| `==` `\==` | son el mismo término, o no lo son |
| `=:=` `=\=` | tienen el mismo valor numérico, o distinto |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| Todo el capítulo, desde el punto de vista de la lógica | capítulo 11 |
| `->` y `;`, construcciones relacionadas con `\+` | capítulo 13 |
| `forall/2`, que expresa "para todos" sin los problemas de `\+` | capítulo 15 |
| Verificación del tipo de un término antes de compararlo | capítulo 24 |
| `dif/2`, equivalente a `\==` que se posterga hasta que las variables tengan valor | capítulo 32 |
