# Soluciones del capítulo 1 — La primera hora

Todos los predicados de esta página están en `ejemplos/capitulo-01/` y pasan sus
pruebas. Una solución distinta de la que figura aquí no es necesariamente
incorrecta: el criterio es que produzca las mismas respuestas.

## 1

`padre(luis, clara).` se agrega como un hecho más. Con ese hecho, `pedro` es
abuelo de `clara`, porque `pedro` es padre de `luis` y `luis` es padre de
`clara`:

```prolog
?- abuelo(pedro, clara).
true ;
false.
```

La respuesta termina en `false.` y no en punto, por la razón que estudia el
ejercicio 13: `luis` es el **primero** de los dos hijos de `pedro`, de modo que
al encontrar la respuesta todavía queda `padre(pedro, eva)` por examinar.

Conviene no elegir a `sofia` para este ejercicio: el capítulo 2 deja sin padre
a `sofia` de manera deliberada, y usa esa ausencia para explicar qué significa
`false.`

## 2

```prolog
?- padre(pedro, Quien).
Quien = luis ;
Quien = eva.
```

El nombre de la variable es indistinto; el único requisito es que comience con
mayúscula. Como `pedro` tiene dos hijos, la segunda respuesta se solicita con
`;`.

## 3

- `padre(juan, ana).` pregunta por dos objetos concretos y responde `true.`.
- `padre(ana, juan).` plantea la relación inversa y responde `false.`, porque
  ese hecho no está en el programa: el orden de los argumentos tiene
  significado.
- `padre(juan, Quien).` deja una posición sin especificar, de modo que la
  respuesta consiste en valores para la variable, uno por cada solución.

## 4

```prolog
?- etapa(eva, Etapa).
Etapa = chico ;
false.

?- edad(Quien, 41).
Quien = ana.
```

## 5

<!-- ejemplo: capitulo-01/soluciones.pl predicado: nieto/2 consulta: nieto(N, juan). -->
```prolog
% --- Ejercicio 5: nieto(N, A): N es nieto de A ----------------------------
nieto(N, A) :-
    padre(A, P),
    padre(P, N).
```

Es `abuelo/2` con los argumentos en orden inverso: los mismos dos objetivos,
consultados desde el otro extremo de la relación.

## 6

<!-- ejemplo: capitulo-01/soluciones.pl predicado: propietario_de_perro/1 tiene_mascota/1 consulta: tiene_mascota(Quien). -->
```prolog
propietario_de_perro(P) :-
    tiene(P, mascota(perro, _)).

tiene_mascota(P) :-
    tiene(P, _).
```

En `tiene_mascota/1`, el `_` ocupa la posición de la mascota completa: no
interesa la especie ni el nombre.

## 7

<!-- ejemplo: capitulo-01/soluciones.pl predicado: menor_que/2 consulta: menor_que(eva, luis). -->
```prolog
% Se puede definir de manera independiente, o a partir de mayor_que/2 con los
% argumentos en orden inverso.
menor_que(A, B) :-
    mayor_que(B, A).
```

Sí, se puede definir a partir de `mayor_que/2`: "A es menor que B" equivale a "B
es mayor que A". También se puede definir de manera independiente, repitiendo
los tres objetivos con `<` en lugar de `>`. Las dos definiciones son correctas;
la que se muestra expresa de manera explícita la relación entre ambos
predicados.

## 8

<!-- ejemplo: capitulo-01/soluciones.pl predicado: triple/2 consulta: triple(11, T). -->
```prolog
% --- Ejercicio 8: triple ---------------------------------------------------
triple(N, T) :-
    T is N * 3.
```

`triple(X, 33).` no responde `X = 11`: produce el error de la sección 1.10,
porque `is` requiere que la expresión de la derecha se pueda evaluar, y `X` no
tiene valor.

## 9

<!-- ejemplo: capitulo-01/soluciones.pl predicado: cuenta_al_reves/2 consulta: cuenta_al_reves(5, 1). -->
```prolog
% --- Ejercicio 9: cuenta descendente --------------------------------------
cuenta_al_reves(Desde, Hasta) :-
    Desde >= Hasta,
    format("~w~n", [Desde]),
    Siguiente is Desde - 1,
    cuenta_al_reves(Siguiente, Hasta).
cuenta_al_reves(Desde, Hasta) :-
    Desde < Hasta.
```

Es `cuenta/2` con tres modificaciones: `>=` en lugar de `=<`, una resta en lugar
de una suma, y `<` en el caso base.

## 10

<!-- ejemplo: capitulo-01/hermanos.pl predicado: hermano/2 consulta: hermano(lot, Quien). -->
```prolog
% Ejercicio 10: la regla directa. Su defecto se corrige en el ejercicio 11.
hermano(A, B) :-
    padre(P, A),
    padre(P, B).
```

```prolog
?- hermano(lot, Quien).
Quien = lot ;
Quien = milca ;
Quien = isca.
```

La primera respuesta es `lot`. Según esta regla, toda persona es hermana de sí
misma, y la deducción es correcta: `haran` es padre de `lot`, y `haran` es padre
de `lot`. Los dos objetivos se cumplen con la misma persona en ambas posiciones.

## 11

Se agrega la condición de que las dos personas sean distintas:

<!-- ejemplo: capitulo-01/hermanos.pl predicado: hermano_de_verdad/2 consulta: hermano_de_verdad(lot, Quien). -->
```prolog
% Ejercicio 11: se agrega la condición de que no sean la misma persona.
hermano_de_verdad(A, B) :-
    padre(P, A),
    padre(P, B),
    \+ A = B.
```

```prolog
?- hermano_de_verdad(lot, Quien).
Quien = milca ;
Quien = isca.
```

Este error es conocido: la misma regla, definida para hermanas, aparece en
Clocksin y Mellish con el mismo defecto.

## 12

<!-- ejemplo: capitulo-01/soluciones.pl predicado: cuantos_invitados_mas/2 consulta: cuantos_invitados_mas(pedro, N). -->
```prolog
cuantos_invitados_mas(P, N) :-
    invitados(Invitados),
    append(Invitados, [P], Con),
    length(Con, N).
```

`append/3` construye una lista nueva que incluye al invitado adicional, y
`length/2` determina la longitud de esa lista. La lista original no cambia: en
Prolog los términos no se modifican; se construyen términos nuevos.

## 13

`abuelo(juan, eva).` responde `true.` y `abuelo(juan, luis).` responde `true ;`
y, al solicitar otra respuesta, `false.`

La regla es `abuelo(A, N) :- padre(A, P), padre(P, N).` Para llegar a `luis`,
Prolog toma `padre(juan, P)` y encuentra primero `ana`; con `P = ana` el
segundo objetivo falla, retrocede y encuentra `pedro`, y con `P = pedro`
prueba `padre(pedro, luis)`. En ese punto todavía **quedaba** un hecho de
`padre/2` por examinar, `padre(pedro, eva)`, de modo que la alternativa sigue
abierta. Para `eva` no queda ninguna, porque es el último hecho.

El punto y coma no indica que haya otra respuesta, sino que Prolog todavía no
descartó la posibilidad de que la haya.

## 14

<!-- ejemplo: capitulo-01/soluciones.pl predicado: mayor_de/2 en_edad_escolar/1 consulta: mayor_de(Quien, 40). -->
```prolog
% --- Ejercicio 14: mayor de N años, y en edad escolar ---------------------
% mayor_de(P, N): P tiene más de N años.
mayor_de(P, N) :-
    edad(P, A),
    A > N.

% en_edad_escolar(P): P tiene más de 5 años y menos de 18.
en_edad_escolar(P) :-
    mayor_de(P, 5),
    edad(P, A),
    A < 18.
```

```prolog
?- mayor_de(Quien, 40).
Quien = juan ;
Quien = ana ;
false.

?- en_edad_escolar(Quien).
Quien = luis ;
Quien = eva.
```

La parte **c** es la importante. `mayor_de/2` admite la consulta con la persona
sin especificar porque su primer objetivo, `edad(P, A)`, **genera** personas de
a una por vez, y la comparación se aplica a cada una. No hay ninguna búsqueda
inversa: hay una enumeración seguida de una comprobación.

`triple(X, 33)` no puede hacer lo mismo porque `T is N * 3` no enumera nada:
exige que `N` ya tenga valor. La diferencia no está en la aritmética sino en si
existe un objetivo que produzca candidatos antes de la comparación.

## 15

```prolog
?- mascota(gato, felix) = mascota(Especie, felix).
Especie = gato.

?- 2 + 5 = 7.
false.

?- X = 2 * 8.
X = 2*8.
```

La primera unifica dos términos compuestos del mismo nombre y aridad, y liga la
única variable. Las otras dos son el mismo caso visto de dos maneras: `2 + 5`
es un término, no el número 7, de modo que no unifica con `7`; y al unificar
`2 * 8` con una variable, esa variable queda con el término, sin evaluar.
