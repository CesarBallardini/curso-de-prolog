# Optimización

Esta página contiene la sección [45.6](index.md#456-optimizacion) del
[capítulo 45](index.md): el plegado de constantes con el simplificador del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md), el reordenamiento de los operandos y el optimizador de mirilla,
con el caso de las etiquetas que una regla unifica sin querer. El código
está en `optimizador.pl`, en `ejemplos/capitulo-45/`, con sus pruebas en
`optimizador.plt`.

## Optimización

`optimizador.pl` agrega tres mejoras de *Clause and Effect*: dos sobre el
árbol, antes de generar el código, y una sobre el código simbólico, antes
de ensamblarlo.

**Plegar constantes.** `d * (24 * 60)` calcula cada vez un producto que se
conoce al compilar. El simplificador de la
[sección 32.7](../capitulo-32-inspeccion-de-terminos/index.md#327-un-simplificador-de-expresiones) ya calcula las operaciones entre
números y aplica identidades como `x - x = 0`, pero trabaja sobre
expresiones aritméticas de Prolog, con los números como números y las
incógnitas como átomos. `a_termino/2` y `de_termino/2` pasan de la sintaxis
abstracta a esa representación y a la inversa. La conversión inversa
necesita `integer/1` y `atom/1`, porque en la representación de Prolog nada
más distingue un número de una variable: es el costo de una representación
que no es limpia, pagado en un solo lugar:

<!-- ejemplo: capitulo-45/optimizador.pl predicado: plegar_expresion/2 de_termino/2 -->
```prolog
%!  plegar_expresion(+E0, -E) is det.
%
%   E es la expresión E0 simplificada por simplificar/2 del capítulo 32.
plegar_expresion(E0, E) :-
    a_termino(E0, T0),
    simplificar(T0, T),
    de_termino(T, E).

%!  de_termino(+T, -E) is det.
%
%   E es la expresión de Mini que corresponde a la expresión aritmética T
%   de Prolog. Sin un functor que lo diga, la clase de una hoja se averigua
%   con integer/1 y atom/1.
de_termino(T, E) :-
    (   integer(T)
    ->  E = num(T)
    ;   atom(T)
    ->  E = id(T)
    ;   compound_name_arguments(T, F, [TA, TB]),
        operador_prolog(Op, F),
        de_termino(TA, A),
        de_termino(TB, B),
        E = bin(Op, A, B)
    ).
```

```prolog
?- plegar_expresion(bin(*, id(d), bin(*, num(24), num(60))), E).
E = bin(*, num(1440), id(d)).

?- analizar("x := x + 2 + 3", [asignar(x, E0)]), plegar_expresion(E0, E).
E0 = E, E = bin(+, bin(+, id(x), num(2)), num(3)).
```

La segunda no se pliega: `x + 2 + 3` es `(x + 2) + 3`, y el 2 y el 3 no son
operandos de la misma operación. Clocksin señala el caso; el
[ejercicio 7](index.md#ejercicios) lo resuelve reasociando la suma antes de simplificar.

**Reordenar operandos.** La máquina evalúa el operando izquierdo, lo deja en
la pila y evalúa el derecho. `a + (b + (c + d))` apila las cuatro variables
antes de la primera suma; `((c + d) + b) + a`, el mismo valor, nunca tiene
más de dos valores en la pila. En `+` y `*`, que son conmutativas, conviene
evaluar primero el operando que más pila necesita. `reordenar/3` calcula esa
necesidad al mismo tiempo que reordena, como el `rot/3` de Clocksin:

<!-- ejemplo: capitulo-45/optimizador.pl predicado: reordenar/3 -->
```prolog
%!  reordenar(+E0, -E, -N:integer) is det.
%
%   E es E0 reordenada, y N es la pila que necesita la máquina para
%   evaluarla.
reordenar(num(N), num(N), 1).
reordenar(id(X), id(X), 1).
reordenar(bin(Op, A0, B0), E, N) :-
    reordenar(A0, A, NA),
    reordenar(B0, B, NB),
    (   conmutativa(Op),
        NB > NA
    ->  E = bin(Op, B, A),
        N is max(NB, NA + 1)
    ;   E = bin(Op, A, B),
        N is max(NA, NB + 1)
    ).
```

```prolog
?- E0 = bin(+, id(a), bin(+, id(b), bin(+, id(c), id(d)))), reordenar_expresion(E0, E), pila(E0, N0), pila(E, N).
E0 = bin(+, id(a), bin(+, id(b), bin(+, id(c), id(d)))),
E = bin(+, bin(+, bin(+, id(c), id(d)), id(b)), id(a)),
N0 = 4,
N = 2.
```

La resta y la división no se reordenan: `a - (b - c)` no vale lo mismo que
`(b - c) - a`.

**La mirilla.** El generador trabaja nodo por nodo y no ve lo que dejó el
nodo anterior. Un **optimizador de mirilla** recorre el código y reemplaza
secuencias cortas por otras equivalentes. `modismo/2` es la tabla de esas
secuencias, y `mirilla/2` aplica la primera que encuentra y vuelve a
empezar, así que un reemplazo puede habilitar otro; como cada reemplazo
acorta el código, termina:

<!-- ejemplo: capitulo-45/optimizador.pl predicado: mirilla/3 reescribir/3 modismo/2 -->
```prolog
%!  mirilla(:M, +Codigo0:list, -Codigo:list) is det.
%
%   Aplica la primera reescritura de call(M, _, _) que encuentra, contando
%   desde el principio del código, y vuelve a empezar, hasta que no queda
%   ninguna. Cada reescritura acorta el código, así que termina.
mirilla(M, Codigo0, Codigo) :-
    (   reescribir(M, Codigo0, Codigo1)
    ->  mirilla(M, Codigo1, Codigo)
    ;   Codigo = Codigo0
    ).

%!  reescribir(:M, +Codigo0:list, -Codigo:list) is nondet.
%
%   Codigo es Codigo0 con un modismo reemplazado, en cualquier posición.
reescribir(M, Codigo0, Codigo) :-
    call(M, Codigo0, Codigo).
reescribir(M, [I|Codigo0], [I|Codigo]) :-
    reescribir(M, Codigo0, Codigo).

%!  modismo(+Codigo0:list, -Codigo:list) is semidet.
%
%   Codigo0 empieza con una secuencia que se reemplaza, y Codigo es el
%   resultado. Las etiquetas se comparan con ==, salvo dos marcas seguidas,
%   que están en la misma dirección y se unifican.
modismo([apilar(X), apilar(Y), I|R], [apilar(V)|R]) :-
    constante(I, X, Y, V).
modismo([apilar(N), saltar_si_cero(L)|R], Codigo) :-
    (   N =:= 0
    ->  Codigo = [saltar(L)|R]
    ;   Codigo = R
    ).
modismo([saltar(L), I|R], [saltar(L)|R]) :-
    I \= etiqueta(_).
modismo([etiqueta(L), etiqueta(L)|R], [etiqueta(L)|R]).
modismo([saltar(L1), etiqueta(L2)|R], [etiqueta(L2)|R]) :-
    L1 == L2.
```

Los modismos son cinco: una operación entre dos constantes se calcula; un
salto condicional sobre una constante se vuelve incondicional o
desaparece; lo que sigue a un salto incondicional, hasta la próxima marca,
nunca se ejecuta; dos marcas seguidas están en la misma dirección; y un
salto a la instrucción siguiente sobra. Con la condición `2 > 1`, los dos
primeros se encadenan hasta no dejar nada:

```prolog
?- mirilla([apilar(2), apilar(1), comparar(>), saltar_si_cero(L)], C).
C = [].
```

!!! warning "Etiquetas que se unifican sin querer"
    Las etiquetas del código simbólico son variables, y una cabeza de
    cláusula las compara por unificación. El modismo del salto a la
    instrucción siguiente parece natural escrito así:

    ```prolog
    modismo_ingenuo([saltar(L), etiqueta(L)|R], [etiqueta(L)|R]).
    ```

    Pero con dos etiquetas distintas y todavía libres, la cabeza no las
    compara: las **unifica**. En un bucle de cuerpo vacío, el salto hacia
    atrás queda junto a la marca del final, y la regla lo borra y convierte
    las dos etiquetas en una:

    ```prolog
    ?- mirilla_ingenua([etiqueta(A), cargar(n), saltar_si_cero(B), saltar(A), etiqueta(B)], C).
    A = B,
    C = [etiqueta(B), cargar(n), saltar_si_cero(B), etiqueta(B)].
    ```

    `modismo/2` compara las etiquetas con `==`, que no liga nada, y deja el
    código como está. La marca doble es el caso opuesto: dos marcas seguidas
    están en la misma dirección, y unificarlas es correcto. La otra salida
    es optimizar después de ensamblar, cuando las etiquetas ya son números
    y unificar dos números es compararlos.

El ejemplo `cuenta` tiene un `mientras` al final del bloque de un `si`, y
por lo tanto un salto hacia atrás junto a una marca. Con la regla ingenua,
el código se optimiza sin error y el error aparece después: todas las
etiquetas terminan unificadas en una sola, marcada en dos direcciones, y el
ensamblado falla. Con `modismo/2`, la mirilla une las tres marcas del
final, que están en la misma dirección, y quita el salto que el `si` ya no
necesita:

```prolog
?- codigo_ejemplo(cuenta, C0), mirilla_ingenua(C0, C), ensamblar(C, O, T).
false.

?- codigo_ejemplo(cuenta, C0), mirilla(C0, C), length(C0, N0), length(C, N).
C0 = [apilar(3), guardar(n), cargar(n), apilar(0), comparar(>), saltar_si_cero(_A), etiqueta(_B), cargar(n), apilar(...)|...],
C = [apilar(3), guardar(n), cargar(n), apilar(0), comparar(>), saltar_si_cero(_A), etiqueta(_B), cargar(n), apilar(...)|...],
N0 = 22,
N = 19.
```

`compilar_optimizado/2` encadena las tres mejoras, y `correr_optimizado/2`
ejecuta el resultado; la prueba `como_el_interprete` de `optimizador.plt`
verifica que cada ejemplo escriba lo mismo que con el intérprete.

!!! question "Actividad"
    Predecir el código objeto de `compilar_optimizado("si 2 > 1 entonces
    escribir 1 sino escribir 2 fin", O)` y comprobarlo. ¿Por qué quedan
    `apilar(2)` y `escribir`, que nunca se ejecutan? ¿Qué modismo haría
    falta para quitarlos? (Es el [ejercicio 9](index.md#ejercicios).)
