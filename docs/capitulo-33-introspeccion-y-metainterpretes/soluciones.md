# Soluciones del capítulo 33 — Introspección y metaintérpretes

El código de esta página está en `ejemplos/capitulo-33/soluciones.pl`,
`soluciones_diagnostico.pl` y `soluciones_experto.pl`, en el mismo directorio,
y pasa sus pruebas. `soluciones.pl` repite el programa de `programa.pl` y de
las secciones siguientes, y el intérprete de `limpio.pl` con la disyunción, el
condicional y la negación del ejercicio 4; los otros dos contienen el
diagnóstico de `diagnostico.pl` y el sistema experto de `experto.pl`, para que
cada archivo se cargue solo.

## 1

```prolog
?- clause(antepasado(juan, D), C).
C = padre(juan, D) ;
C = (padre(juan, _A), antepasado(_A, D)).

?- clause(visita(P), C).
P = ana,
C = true.

?- clause(X, true).
ERROR: Arguments are not sufficiently instantiated

?- clause(no_definido(X), C).
false.

?- current_predicate(abuelo/A).
A = 2 ;
false.
```

`clause/2` da las dos cláusulas de `antepasado/2` en el orden del programa,
con la cabeza unificada con `antepasado(juan, D)`: por eso el cuerpo de la
primera es `padre(juan, D)`, y la variable intermedia de la segunda aparece
renombrada. El predicado dinámico `visita/1` se lee igual que uno estático.
Con la cabeza libre, `clause/2` no tiene un predicado que leer y produce un error
de instanciación; con un predicado que no existe, falla sin error.
`current_predicate/1` con la aridad libre la averigua.

## 2

<!-- ejemplo: capitulo-33/soluciones.pl predicado: reglas/2 consulta: reglas(antepasado/2, N). -->
```prolog
%!  reglas(+Indicador, -N:integer) is semidet.
%
%   N es la cantidad de cláusulas del predicado Nombre/Aridad que son
%   reglas: su cuerpo no es true. Falla si el predicado no está definido.
reglas(Nombre/Aridad, N) :-
    current_predicate(Nombre/Aridad),
    functor(Cabeza, Nombre, Aridad),
    aggregate_all(count,
                  ( clause(Cabeza, Cuerpo),
                    Cuerpo \== true ),
                  N).
```

```prolog
?- reglas(antepasado/2, N).
N = 2.

?- reglas(maximo/3, N).
N = 1.
```

`aggregate_all/3`, del [capítulo 17](../capitulo-17-todas-las-soluciones/index.md), cuenta sin construir la lista, y
`\==` compara el cuerpo con `true` sin ligarlo. `current_predicate/1` hace que
un predicado inexistente falle, en lugar de dar `N = 0`: un predicado sin
reglas y uno que no existe son casos distintos. La segunda cláusula de
`maximo/3` es un hecho, y no se cuenta.

## 3

`resolver/1` de `vainilla.pl` absorbe la unificación y el retroceso, que hacen
`clause/2` y Prolog, y reifica la conjunción y la elección de la cláusula como
paso de la prueba. `resolver_lista/1` absorbe lo mismo, y reifica además la
**continuación**: la lista de los objetivos que quedan por probar, que
`resolver/1` deja en la pila de Prolog. Por eso sobre ella se puede escribir
otra estrategia, como la del [ejercicio 6](#6). `resolver_iterativo/1` absorbe
la unificación y el retroceso dentro de cada iteración, y el paso de una
iteración a la siguiente, que es el retroceso sobre `length(_, N)`; reifica la
conjunción y la profundidad, que es un argumento de cada llamada.

## 4

La conversión reconoce el condicional antes que la disyunción, porque
`(C -> T ; E)` es un término `;` cuyo primer argumento es `->`:

<!-- ejemplo: capitulo-33/soluciones.pl fragmento: limpiar((C0 .. limpiar(B0, B). consulta: resolver(signo(-3, S)). -->
```prolog
limpiar((C0 -> T0 ; E0), si(C, T, E)) :-
    !,
    limpiar(C0, C),
    limpiar(T0, T),
    limpiar(E0, E).
limpiar((A0 ; B0), o(A, B)) :-
    !,
    limpiar(A0, A),
    limpiar(B0, B).
```

<!-- ejemplo: capitulo-33/soluciones.pl fragmento: resolver_cuerpo(si(C, T, E)) :- .. \+ resolver_cuerpo(C). consulta: resolver(signo(-3, S)). -->
```prolog
resolver_cuerpo(si(C, T, E)) :-
    (   resolver_cuerpo(C)
    ->  resolver_cuerpo(T)
    ;   resolver_cuerpo(E)
    ).
resolver_cuerpo(o(A, B)) :-
    (   resolver_cuerpo(A)
    ;   resolver_cuerpo(B)
    ).
resolver_cuerpo(no(C)) :-
    \+ resolver_cuerpo(C).
```

`signo/2` usa el condicional y `pariente_directo/2` la disyunción:

```prolog
?- resolver(signo(-3, S)).
S = negativo.

?- resolver(pariente_directo(ana, X)).
X = luis ;
X = juan.
```

El condicional se absorbe porque lo que poda está dentro del intérprete: el
`->` de `resolver_cuerpo/1` descarta las otras pruebas de
`resolver_cuerpo(C)`, que son exactamente las otras pruebas de la condición
del programa. El corte de una cláusula, en cambio, debe descartar las otras
cláusulas del predicado, que son las alternativas de `clause/2` dentro de
`clausula/2`, dos llamadas más arriba del lugar donde el intérprete encuentra
el `!`. Ninguna construcción de Prolog corta desde una llamada interior hasta
una exterior: hay que reificar el corte, que es el problema que plantean
Pereira y Shieber en *Prolog and Natural-Language Analysis*, «An Interpreter for Cut».

## 5

```prolog
?- resolver(maximo(3, 5, M)).
M = 5.

?- resolver(maximo(5, 3, M)).
M = 5 ;
M = 3.
```

Con `maximo(3, 5, M)` la primera cláusula falla antes de llegar al corte, y la
segunda da la respuesta correcta. Con `maximo(5, 3, M)` la primera cláusula da
5, y el corte, que el intérprete ejecuta como `true`, no impide probar la
segunda, que da 3: una respuesta incorrecta. `maximo/3` depende del corte para
ser correcto, y el intérprete no lo reproduce. `call(!)` tampoco lo haría: el
corte dentro de `call/1` es local a esa llamada, y corta solo las
alternativas del mismo `call/1`, que no tiene ninguna. La versión con un
condicional, `( X >= Y -> M = X ; M = Y )`, es correcta con el intérprete del
[ejercicio 4](#4).

## 6

Cada elemento de la cola es un par `Respuesta-Resolvente`: la resolvente y la
copia del objetivo inicial que sus ligaduras van completando. `findall/3`
produce las resolventes hijas, cada una con sus propias variables, y las pone
al final de la cola:

<!-- ejemplo: capitulo-33/soluciones.pl predicado: resolver_anchura/1 anchura/2 paso/3 consulta: limit(2, resolver_anchura(camino(a, c, C))). -->
```prolog
%!  resolver_anchura(+Meta) is nondet.
%
%   Meta se prueba en anchura: las resolventes forman una cola, y se
%   expande siempre la más antigua. Las respuestas salen en orden de
%   cantidad de pasos; ninguna rama infinita impide llegar a las demás.
resolver_anchura(Meta) :-
    anchura([Meta-[prog(Meta)]], Meta).

%!  anchura(+Cola:list, ?Meta) is nondet.
%
%   Cola tiene pares Respuesta-Resolvente. Una resolvente vacía da su
%   Respuesta; una que no lo está se reemplaza, al final de la cola, por
%   las resolventes que resultan de su primer objetivo.
anchura([Respuesta-[]|Cola], Meta) :-
    (   Meta = Respuesta
    ;   anchura(Cola, Meta)
    ).
anchura([Respuesta-[G|Gs]|Cola], Meta) :-
    findall(Respuesta-Nueva, paso(G, Gs, Nueva), Hijas),
    append(Cola, Hijas, Cola1),
    anchura(Cola1, Meta).

%!  paso(+G, +Gs:list, -Resolvente:list) is nondet.
%
%   Resolvente resulta de resolver el objetivo G delante de Gs: una por
%   cada manera de hacerlo.
paso(true, Gs, Gs).
paso((A, B), Gs, [A, B|Gs]).
paso(si(C, T, E), Gs, [Rama|Gs]) :-
    (   resolver_cuerpo(C)
    ->  Rama = T
    ;   Rama = E
    ).
paso(o(A, _), Gs, [A|Gs]).
paso(o(_, B), Gs, [B|Gs]).
paso(no(C), Gs, Gs) :-
    \+ resolver_cuerpo(C).
paso(sis(G), Gs, Gs) :-
    ejecutar(G).
paso(prog(G), Gs, [Cuerpo|Gs]) :-
    clausula(G, Cuerpo).
```

```prolog
?- limit(3, resolver_anchura(antepasado_izq(A, eva))).
A = luis ;
A = ana ;
A = juan.

?- limit(3, resolver_anchura(camino(a, c, C))).
C = [a-b, b-c] ;
C = [a-b, b-a, a-b, b-c] ;
C = [a-b, b-c, c-b, b-c].
```

La búsqueda en anchura es completa: la rama infinita de la recursión a la
izquierda crece en la cola sin impedir que se expandan las demás. El costo es
la memoria, porque la cola guarda todas las resolventes de un nivel, y la
búsqueda sigue sin terminar después de la última respuesta. El
[capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md) compara las dos estrategias sobre espacios de estados.

## 7

Una hoja del árbol es un nodo sin hijos, que se probó con un hecho. La
indexación sobre la lista de hijos, en `hechos_nodo//2`, evita el punto de
elección que dejarían dos cláusulas `prueba(G, [])` y `prueba(_, [H|Hs])`:

<!-- ejemplo: capitulo-33/soluciones.pl predicado: hechos_usados/2 hechos//1 hechos_nodo//2 hechos_de//1 consulta: findall(H, (resolver_arbol(antepasado(juan, eva), A), hechos_usados(A, H)), Hs). -->
```prolog
%!  hechos_usados(+Arbol, -Hechos:list) is det.
%
%   Hechos son los hechos del programa que usa la prueba Arbol, en el orden
%   de izquierda a derecha, con repetidos.
hechos_usados(Arbol, Hechos) :-
    phrase(hechos(Arbol), Hechos).

%!  hechos(+Arbol)// is det.
%
%   La lista describe los hechos que usa Arbol.
hechos(sis(_)) -->
    [].
hechos(prueba(G, Hijos)) -->
    hechos_nodo(Hijos, G).

%!  hechos_nodo(+Hijos:list, +G)// is det.
%
%   La lista describe los hechos de un nodo G con esos Hijos: G mismo si no
%   tiene hijos, porque es un hecho, o los hechos de sus hijos.
hechos_nodo([], G) -->
    [G].
hechos_nodo([H|Hs], _) -->
    hechos(H),
    hechos_de(Hs).

%!  hechos_de(+Arboles:list)// is det.
%
%   La lista describe los hechos que usan los Arboles, en orden.
hechos_de([]) -->
    [].
hechos_de([A|As]) -->
    hechos(A),
    hechos_de(As).
```

```prolog
?- findall(H, (resolver_arbol(antepasado(juan, eva), A), hechos_usados(A, H)), Hs).
Hs = [[padre(juan, ana), padre(ana, luis), padre(luis, eva)]].
```

## 8

Las pruebas salen de `limite/2`, como en `profundidad.pl`. `alcanza/2` recorre
la misma búsqueda y se cumple si alguna rama llega a un objetivo del programa
sin niveles disponibles. La doble negación descarta sus ligaduras, y hace que
la respuesta `agotado` sea una sola:

<!-- ejemplo: capitulo-33/soluciones.pl predicado: resolver_acotado/3 alcanza/2 consulta: resolver_acotado(camino(a, d, C), 3, R). -->
```prolog
%!  resolver_acotado(+Meta, +Limite:integer, -Resultado) is nondet.
%
%   Resultado es si para cada prueba de Meta de altura no mayor que Limite,
%   con sus ligaduras; al final, una respuesta agotado, sin ligaduras, si
%   alguna rama llegó al límite. Sin prueba y sin llegar al límite, falla.
resolver_acotado(Meta, Limite, Resultado) :-
    (   limite(prog(Meta), Limite),
        Resultado = si
    ;   \+ \+ alcanza(prog(Meta), Limite),
        Resultado = agotado
    ).

%!  alcanza(+Cuerpo, +N:integer) is nondet.
%
%   Alguna rama de la búsqueda de Cuerpo llega a un objetivo del programa
%   sin niveles disponibles: la búsqueda con límite N lo cortó.
alcanza((A, B), N) :-
    (   alcanza(A, N)
    ;   limite(A, N),
        alcanza(B, N)
    ).
alcanza(prog(_), 0).
alcanza(prog(G), N) :-
    N > 0,
    N1 is N - 1,
    clausula(G, Cuerpo),
    alcanza(Cuerpo, N1).
```

```prolog
?- resolver_acotado(camino(a, d, C), 4, R).
C = [a-b, b-c, c-d],
R = si ;
R = agotado.

?- resolver_acotado(padre(eva, X), 3, R).
false.
```

Con `agotado`, `false.` recupera su significado: la última consulta no tiene
prueba y la búsqueda no llegó al límite, así que no hay prueba de ninguna
altura. `call_with_depth_limit/3` distingue los mismos casos para una
ejecución sin intérprete.

## 9

<!-- ejemplo: capitulo-33/soluciones.pl predicado: sin_ciclos/2 consulta: resolver_sin_ciclos(antepasado_izq(A, eva)). -->
```prolog
%!  sin_ciclos(+Cuerpo, +Antepasados:list) is nondet.
%
%   Cuerpo se prueba; Antepasados son los objetivos en curso.
sin_ciclos(true, _).
sin_ciclos((A, B), Antepasados) :-
    sin_ciclos(A, Antepasados),
    sin_ciclos(B, Antepasados).
sin_ciclos(sis(G), _) :-
    ejecutar(G).
sin_ciclos(prog(G), Antepasados) :-
    \+ ( member(A, Antepasados),
         A =@= G ),
    clausula(G, Cuerpo),
    sin_ciclos(Cuerpo, [G|Antepasados]).
```

```prolog
?- resolver_sin_ciclos(antepasado_izq(A, eva)).
A = luis ;
A = ana ;
false.
```

La búsqueda termina, pero falta juan. Para probar `antepasado_izq(A, eva)` con
la segunda cláusula, el intérprete llama a `antepasado_izq(A, H)`, y para
probar este con la segunda cláusula, a `antepasado_izq(A, H2)`, una variante
de su antepasado: la rama se abandona. Pero esa rama era necesaria, porque
juan está a tres generaciones de eva. Abandonar las variantes garantiza que la
búsqueda termina y pierde respuestas. Con `camino/3`, además, no alcanza: la
lista de aristas crece en cada llamada, y los objetivos del ciclo no son
variantes. La tabulación del [capítulo 39](../capitulo-39-tabulacion/index.md) resuelve el problema sin perder
respuestas: en lugar de abandonar la variante, espera las respuestas de su
antepasado.

## 10

<!-- ejemplo: capitulo-33/soluciones.pl predicado: entradas/2 consulta: rastrear_entradas(abuelo(juan, N)). -->
```prolog
%!  entradas(+Cuerpo, +Sangria:integer) is nondet.
%
%   Cuerpo se prueba, y sus objetivos se escriben en la columna Sangria.
entradas(true, _).
entradas((A, B), Sangria) :-
    entradas(A, Sangria),
    entradas(B, Sangria).
entradas(sis(G), Sangria) :-
    escribir_puerto(llama, G, Sangria),
    ejecutar(G),
    escribir_puerto(sale, G, Sangria).
entradas(prog(G), Sangria) :-
    escribir_puerto(llama, G, Sangria),
    Siguiente is Sangria + 2,
    clausula(G, Cuerpo),
    entradas(Cuerpo, Siguiente),
    escribir_puerto(sale, G, Sangria).
```

```prolog
?- rastrear_entradas(abuelo(juan, N)).
llama abuelo(juan, A)
  llama padre(juan, A)
  sale padre(juan, ana)
  llama padre(ana, A)
  sale padre(ana, luis)
sale abuelo(juan, luis)
N = luis ;
  sale padre(juan, pedro)
  llama padre(pedro, A)
false.
```

Sin los puertos de falla y de reintento, la búsqueda de otra respuesta se ve
solo en las líneas que produce: `sale padre(juan, pedro)` aparece sin que nada
diga que se volvió atrás hasta ese objetivo. Por eso el depurador del sistema
muestra los cuatro puertos.

## 11

El oráculo de `invertir_mal/3` dice que el resultado es la lista invertida
delante del acumulado:

<!-- ejemplo: capitulo-33/soluciones_diagnostico.pl predicado: invertir_mal/3 pretendido/1 consulta: respuesta_incorrecta(programa, invertir_mal([a, b, c], Ys), C). -->
```prolog
%!  invertir_mal(+Xs:list, +Acumulado:list, -Ys:list) is det.
%
%   Debería ser: Ys es Xs invertida delante de Acumulado. El error: la
%   segunda cláusula pierde el acumulado anterior.
invertir_mal([], Ys, Ys).
invertir_mal([X|Xs], _, Ys) :-
    invertir_mal(Xs, [X], Ys).

%!  pretendido(+Meta) is semidet.
%
%   Meta es verdadero en el significado que el programa debería tener.
pretendido(invertir_mal(Xs, Ys)) :-
    reverse(Xs, Ys).
pretendido(invertir_mal(Xs, Acumulado, Ys)) :-
    reverse(Xs, Rs),
    append(Rs, Acumulado, Ys).
```

```prolog
?- respuesta_incorrecta(programa, invertir_mal([a, b, c], Ys), C).
Ys = [c],
C = (invertir_mal([c], [b], [c]):-invertir_mal([], [c], [c])).
```

Invertir `[c]` delante de `[b]` debería dar `[c, b]`, y la cláusula da `[c]`
aunque su cuerpo es verdadero: la segunda cláusula descarta el acumulado.
Escrita `invertir_mal([X|Xs], A, Ys) :- invertir_mal(Xs, [X|A], Ys).`, es
correcta.

## 12

El oráculo pasa a ser un argumento: `programa` usa `pretendido/1`, y
`usuario` pregunta. Las respuestas quedan en `juicio/2`, como las
observaciones de `respondida/2` en `experto.pl`:

<!-- ejemplo: capitulo-33/soluciones_diagnostico.pl predicado: correcto/2 preguntar_juicio/1 consulta: respuesta_incorrecta(programa, invertir_mal([a, b, c], Ys), C). -->
```prolog
%!  correcto(+Oraculo, +Meta) is semidet.
%
%   Meta es verdadero según Oraculo: programa o usuario.
correcto(programa, Meta) :-
    pretendido(Meta).
correcto(usuario, Meta) :-
    preguntar_juicio(Meta).

%!  preguntar_juicio(+Meta) is semidet.
%
%   El usuario responde si a la pregunta de si Meta es correcto. Cada
%   pregunta se hace una sola vez.
preguntar_juicio(Meta) :-
    (   juicio(Pregunta, Respuesta),
        Pregunta =@= Meta
    ->  true
    ;   format("¿Es correcto ~q? ", [Meta]),
        read(Respuesta),
        assertz(juicio(Meta, Respuesta))
    ),
    Respuesta == si.
```

Una sesión, respondiendo `no` a las cuatro primeras preguntas y `si` a la
última:

```text
?- respuesta_incorrecta(usuario, invertir_mal([a, b, c], Ys), C).
¿Es correcto invertir_mal([a,b,c],[c])? no.
¿Es correcto invertir_mal([a,b,c],[],[c])? no.
¿Es correcto invertir_mal([b,c],[a],[c])? no.
¿Es correcto invertir_mal([c],[b],[c])? no.
¿Es correcto invertir_mal([],[c],[c])? si.
Ys = [c],
C = (invertir_mal([c], [b], [c]):-invertir_mal([], [c], [c])).
```

El usuario juzga cada objetivo por lo que el predicado debería hacer, sin
examinar el código: es la ventaja de la depuración algorítmica sobre la traza.
La prueba `usuario_sin_repetir` verifica que una segunda consulta no
pregunta nada.

## 13

La negación se declara `:- op(770, fy, no).`, como en el
[capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md), y agrega una cláusula a `demostrar/4` y un caso a
`explicacion/3`:

<!-- ejemplo: capitulo-33/soluciones_experto.pl fragmento: demostrar(no Meta, .. \+ demostrar(Meta, Fuente, Pila, _). consulta: identificar([tiene_plumas, peso(90)], Animal). -->
```prolog
demostrar(no Meta, Fuente, Pila, no Meta) :-
    \+ demostrar(Meta, Fuente, Pila, _).
```

<!-- ejemplo: capitulo-33/soluciones_experto.pl fragmento: Condicion = (no C) .. se_prueba(C) consulta: por_que_no([tiene_plumas, vuela, peso(90)], avestruz). -->
```prolog
    ;   Condicion = (no C)
    ->  Explicacion = se_prueba(C)
```

```prolog
?- identificar([tiene_plumas, peso(90)], Animal).
Animal = avestruz.

?- por_que_no([tiene_plumas, vuela, peso(90)], avestruz).
avestruz: no se prueba
  por r12:
    no vuela: se prueba vuela
true.
```

Cuando la condición negada se prueba, la explicación es esa prueba: `no vuela`
falla porque `vuela` está observado. `explicar/2` y `explicar_no/2` tienen una
cláusula más cada uno, para escribir el nodo `no`.

## 14

<!-- ejemplo: capitulo-33/soluciones_experto.pl predicado: motivo/2 consulta: motivo(tiene_pelo, [r1-mamifero, r5-carnivoro]). -->
```prolog
%!  motivo(+Meta, +Pila:list) is det.
%
%   Escribe para qué se pregunta Meta: cada regla en curso, completa, de la
%   más reciente a la que concluye la hipótesis.
motivo(Meta, Pila) :-
    format("~w se pregunta para aplicar:~n", [Meta]),
    forall(member(Regla-_, Pila),
           ( regla(Regla, Texto),
             format("  ~w: ~w~n", [Regla, Texto]) )).
```

```prolog
?- motivo(tiene_pelo, [r1-mamifero, r5-carnivoro, r7-guepardo]).
tiene_pelo se pregunta para aplicar:
  r1: si tiene_pelo entonces mamifero
  r5: si mamifero y come_carne entonces carnivoro
  r7: si carnivoro y color_leonado y manchas_oscuras entonces guepardo
true.
```

La pila guarda el nombre de cada regla, y `regla/2` da su texto. Los
operadores `si`, `entonces` e `y` hacen que `format/2` con `~w` escriba la
regla como se escribió.
