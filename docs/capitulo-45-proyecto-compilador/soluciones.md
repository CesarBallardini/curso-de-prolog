# Soluciones del capítulo 45 — Proyecto: un compilador

El código de esta página está en `ejemplos/capitulo-45/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `compilador.pl`, y con él
todas las versiones del capítulo: `sintaxis.pl`, `interprete.pl`,
`generador.pl`, `maquina.pl`, `optimizador.pl` y `especializar.pl`. Los ejercicios 2, 3 y 4 agregan cláusulas
a predicados de esos archivos: para que dos archivos definan cláusulas del
mismo predicado, `soluciones.pl` los declara `multifile`, como en el
[capítulo 24](../capitulo-24-modulos-y-organizacion/index.md), **antes** de cargarlos, y las cláusulas nuevas quedan después
de las originales. Los ejercicios 1, 8 y 11 se resuelven con los archivos
del capítulo.

<!-- ejemplo: capitulo-45/soluciones.pl fragmento: :- multifile .. :- ensure_loaded(compilador). -->
```prolog
:- multifile
    factor//1,
    reservada/1,
    sentencia//1,
    ejecutar_sentencia//3,
    codigo_sentencia//1,
    paso//3,
    clase/2.

:- ensure_loaded(compilador).
```

## 1

La resta y la multiplicación agrupan a la izquierda y el producto antes que
la resta: `8 - 2 - 1 * 3` es `(8 - 2) - (1 * 3)`, que vale 3. Como `3 > 3`
no se cumple, se ejecuta la rama `sino`, que escribe `0 - 3`:

<!-- ejemplo: capitulo-45/interprete.pl predicado: ejecutar/2 -->
```prolog
%!  ejecutar(+Texto, -Salida:list(integer)) is semidet.
%
%   Salida es lo que escribe el programa Mini de Texto, interpretado. Falla
%   si Texto no es un programa Mini.
ejecutar(Texto, Salida) :-
    analizar(Texto, Programa),
    interpretar(Programa, Salida).
```

```prolog
?- analizar("x := 8 - 2 - 1 * 3; si x > 3 entonces escribir x sino escribir 0 - x fin", P).
P = [asignar(x, bin(-, bin(-, num(8), num(2)), bin(*, num(1), num(3)))), si(rel(>, id(x), num(3)), [escribir(id(x))], [escribir(bin(-, num(0), id(x)))])].

?- ejecutar("x := 8 - 2 - 1 * 3; si x > 3 entonces escribir x sino escribir 0 - x fin", S).
S = [-3].
```

La actividad de la [sección 45.3](index.md#453-el-interprete) se resuelve igual: `z` vale 0 al
empezar, porque `entorno_inicial/2` da 0 a cada variable del programa, y
`7 / 2` es la división entera:

```prolog
?- ejecutar("escribir z; z := z + 1; si z = 1 entonces escribir 7 / 2 sino escribir 0 fin", S).
S = [0, 3].
```

## 2

`-x` se representa como `0 - x`, así que ni el intérprete ni el generador
cambian. La cláusula nueva de `factor//1` lee un `-` y otro factor; como el
factor puede ser otro menos, `- - x` también se lee:

<!-- ejemplo: capitulo-45/soluciones.pl fragmento: factor(bin(-, num(0), F)) .. factor(F). -->
```prolog
factor(bin(-, num(0), F)) -->
    [-],
    factor(F).
```

```prolog
?- ejecutar("x := -3 * 2; escribir 2 - -x", S).
S = [-4].

?- analizar("escribir - - x", P).
P = [escribir(bin(-, num(0), bin(-, num(0), id(x))))].
```

`-3 * 2` es `(0 - 3) * 2`: el menos se aplica al factor, antes que el
producto.

## 3

La sentencia necesita dos palabras reservadas y una cláusula de
`sentencia//1`. El intérprete no necesita un caso nuevo: `repetir B hasta
C` es `B` seguido de `mientras` con la condición contraria, y así se
escribe. El generador, en cambio, produce un código más corto que ese: el
cuerpo, la condición y un salto hacia atrás si la condición da 0:

<!-- ejemplo: capitulo-45/soluciones.pl fragmento: reservada(repetir). .. [saltar_si_cero(Inicio)]. -->
```prolog
reservada(repetir).
reservada(hasta).

sentencia(repetir(Cuerpo, C)) -->
    [repetir],
    bloque(Cuerpo),
    [hasta],
    condicion(C).

% El intérprete ejecuta el cuerpo una vez y sigue como un mientras con la
% condición contraria.
ejecutar_sentencia(repetir(Cuerpo, rel(Op, A, B)), E0, E) -->
    { contraria(Op, No) },
    ejecutar_bloque(Cuerpo, E0, E1),
    ejecutar_sentencia(mientras(rel(No, A, B), Cuerpo), E1, E).

% El generador pone la condición al final: si no se cumple, vuelve.
codigo_sentencia(repetir(Cuerpo, C)) -->
    [etiqueta(Inicio)],
    codigo_bloque(Cuerpo),
    codigo_condicion(C),
    [saltar_si_cero(Inicio)].
```

```prolog
?- ejecutar("i := 1; repetir escribir i; i := i + 1 hasta i = 6", S).
S = [1, 2, 3, 4, 5].

?- correr("i := 1; repetir escribir i; i := i + 1 hasta i = 6", S).
S = [1, 2, 3, 4, 5].

?- analizar("repetir escribir i hasta i = 1", P), generar(P, C).
P = [repetir([escribir(id(i))], rel(=, id(i), num(1)))],
C = [etiqueta(_A), cargar(i), escribir, cargar(i), apilar(1), comparar(=), saltar_si_cero(_A)].
```

Las pruebas `repetir` y `repetir_compilado` ejecutan el programa del
enunciado, que escribe de 1 a 10. El cuerpo se ejecuta al menos una vez:
`repetir escribir i hasta i = 0` escribe 0 aunque la condición ya se cumpla.
`optimizar/2` y el especializador no conocen la sentencia nueva; extenderlos
es agregar una cláusula a `sentencia_transformada/3` y a `compuesta/1`.

## 4

La instrucción nueva necesita su clase para el ensamblador y su paso en la
máquina; el modismo va en una tabla propia, `modismo_fusion/2`, que agrega
el reemplazo a los de `modismo/2`:

<!-- ejemplo: capitulo-45/soluciones.pl fragmento: clase(saltar_si_no(_, _), fija). .. ensamblar(Simbolico, Objeto, _). -->
```prolog
clase(saltar_si_no(_, _), fija).

paso(saltar_si_no(Op, D), s(PC, [Y, X|P], M), s(PC1, P, M)) -->
    {   comparar(Op, X, Y)
    ->  PC1 is PC + 1
    ;   PC1 = D
    }.

%!  modismo_fusion(+Codigo0:list, -Codigo:list) is semidet.
%
%   Los modismos de modismo/2, y una comparación seguida de un salto si
%   cero reemplazada por un salto si la comparación no se cumple.
modismo_fusion([comparar(Op), saltar_si_cero(L)|R], [saltar_si_no(Op, L)|R]).
modismo_fusion(Codigo0, Codigo) :-
    modismo(Codigo0, Codigo).

%!  compilar_fusion(+Texto, -Objeto:list) is semidet.
%
%   Como compilar_optimizado/2, con modismo_fusion/2 en la mirilla.
compilar_fusion(Texto, Objeto) :-
    analizar(Texto, Programa0),
    optimizar(Programa0, Programa),
    generar(Programa, Simbolico0),
    mirilla(modismo_fusion, Simbolico0, Simbolico),
    ensamblar(Simbolico, Objeto, _).
```

Con `medir_ejemplo/5` y la máquina del ejercicio 5:

```prolog
?- medir_ejemplo(factorial, compilar_optimizado, N, Pasos, Max).
N = 19,
Pasos = 75,
Max = 2.

?- medir_ejemplo(factorial, compilar_fusion, N, Pasos, Max).
N = 18,
Pasos = 69,
Max = 2.
```

La fusión ahorra una instrucción en el código, la comparación del bucle, y
un paso por cada vez que se evalúa la condición: seis, cinco iteraciones y la
evaluación que sale del bucle.

## 5

`ciclo_medido//4` es `ciclo//2` con dos contadores más, que viajan en un par
`Pasos-Maxima`; cada paso lo da el mismo `paso//3` de la máquina:

<!-- ejemplo: capitulo-45/soluciones.pl predicado: maquina_medida/4 ciclo_medido//4 medir_ejemplo/5 -->
```prolog
%!  maquina_medida(+Objeto, -Salida, -Pasos, -Maxima) is det.
%
%   Como maquina/2; Pasos es la cantidad de instrucciones ejecutadas y
%   Maxima la mayor cantidad de valores que tuvo la pila.
maquina_medida(Objeto, Salida, Pasos, Maxima) :-
    compound_name_arguments(Codigo, codigo, Objeto),
    empty_assoc(Memoria),
    phrase(ciclo_medido(Codigo, s(0, [], Memoria), 0-0, Pasos-Maxima),
           Salida).

%!  ciclo_medido(+Codigo, +Estado, +Medida0, -Medida)// is det.
%
%   Como ciclo//2; Medida0 y Medida son pares Pasos-Maxima, antes y al
%   terminar.
ciclo_medido(Codigo, s(PC, P, M), N0-H0, Medida) -->
    (   { K is PC + 1,
          arg(K, Codigo, I) }
    ->  paso(I, s(PC, P, M), s(PC1, P1, M1)),
        { N1 is N0 + 1,
          length(P1, Altura),
          H1 is max(H0, Altura) },
        ciclo_medido(Codigo, s(PC1, P1, M1), N1-H1, Medida)
    ;   { Medida = N0-H0 }
    ).

%!  medir_ejemplo(+Nombre, :Compilar, -N, -Pasos, -Maxima) is semidet.
%
%   Compila el programa de ejemplo Nombre con call(Compilar, Texto,
%   Objeto): N es la cantidad de instrucciones de Objeto, y Pasos y Maxima
%   las de maquina_medida/4 al ejecutarlo.
medir_ejemplo(Nombre, Compilar, N, Pasos, Maxima) :-
    fuente_ejemplo(Nombre, Texto),
    call(Compilar, Texto, Objeto),
    length(Objeto, N),
    maquina_medida(Objeto, _, Pasos, Maxima).
```

```prolog
?- compilar("x := a + (b + (c + d))", O), maquina_medida(O, _, Pasos, Max).
O = [cargar(0), cargar(1), cargar(2), cargar(3), sumar, sumar, sumar, guardar(4)],
Pasos = 8,
Max = 4.

?- compilar_optimizado("x := a + (b + (c + d))", O), maquina_medida(O, _, Pasos, Max).
O = [cargar(0), cargar(1), sumar, cargar(2), sumar, cargar(3), sumar, guardar(4)],
Pasos = 8,
Max = 2.
```

Las dos versiones ejecutan las mismas ocho instrucciones; cambia el orden,
y con él la pila: cuatro lugares sin optimizar, dos con los operandos
reordenados, como predijo `pila/2`.

## 6

Una comparación no es conmutativa, pero cada una tiene su espejo: `A < B` se
cumple si y solo si se cumple `B > A`. `=` y `<>` son su propio espejo,
porque no dependen del orden. La prueba `espejo` lo comprueba para las seis
relaciones con tres pares de valores:

<!-- ejemplo: capitulo-45/soluciones.pl predicado: condicion_reordenada/2 espejo/2 -->
```prolog
%!  condicion_reordenada(+C0, -C) is det.
%
%   C es la condición C0 con sus lados reordenados y, si el derecho
%   necesita más pila, intercambiados, con la relación espejada.
condicion_reordenada(rel(Op, A0, B0), C) :-
    reordenar(A0, A, NA),
    reordenar(B0, B, NB),
    (   NB > NA
    ->  espejo(Op, Op1),
        C = rel(Op1, B, A)
    ;   C = rel(Op, A, B)
    ).

% espejo(Op, Op1): A Op B se cumple si y solo si B Op1 A se cumple.
espejo(=, =).
espejo(<>, <>).
espejo(<, >).
espejo(>, <).
espejo(<=, >=).
espejo(>=, <=).
```

```prolog
?- analizar("si 1 < a + (b + c) entonces escribir 1 fin", P0), reordenar_condiciones(P0, P).
P0 = [si(rel(<, num(1), bin(+, id(a), bin(+, id(b), id(c)))), [escribir(num(1))], [])],
P = [si(rel(>, bin(+, bin(+, id(b), id(c)), id(a)), num(1)), [escribir(num(1))], [])].
```

La condición original necesita tres lugares de pila: el 1 queda abajo
mientras se evalúa la suma, que necesita dos. La reordenada necesita dos.

## 7

El simplificador del [capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md#327-un-simplificador-de-expresiones) no tiene una regla para `(x + 2) + 3`,
porque el 2 y el 3 no son operandos de la misma operación. `reasociar/2`
aplica, de abajo hacia arriba, reglas que juntan las dos constantes, y el
simplificador hace el resto:

<!-- ejemplo: capitulo-45/soluciones.pl predicado: plegar_asociando/2 regla_asociar/2 -->
```prolog
%!  plegar_asociando(+E0, -E) is det.
%
%   Como plegar_expresion/2, pero antes de simplificar agrupa las
%   constantes de las sumas y restas encadenadas: (X + A) + B pasa a
%   X + (A + B).
plegar_asociando(E0, E) :-
    a_termino(E0, T0),
    simplificar(T0, T1),
    reasociar(T1, T2),
    simplificar(T2, T),
    de_termino(T, E).

%!  regla_asociar(+T0, -T) is semidet.
%
%   T es T0 con dos constantes de una suma o resta encadenada sumadas.
regla_asociar((X + A) + B, X + C) :-
    number(A),
    number(B),
    C is A + B.
regla_asociar((X + A) - B, X + C) :-
    number(A),
    number(B),
    C is A - B.
regla_asociar((X - A) + B, X + C) :-
    number(A),
    number(B),
    C is B - A.
regla_asociar((X - A) - B, X - C) :-
    number(A),
    number(B),
    C is A + B.
```

```prolog
?- plegar_asociando(bin(+, bin(+, id(x), num(2)), num(3)), E).
E = bin(+, id(x), num(5)).
```

La prueba `asociar_resta` comprueba que `x + 2 - 2` queda en `x`: la regla
da `x + 0`, y el simplificador quita el 0.

## 8

Dos marcas seguidas están en la misma dirección, sin ninguna instrucción
entre ellas: las dos etiquetas valen lo mismo, y unificarlas solo adelanta
lo que el ensamblador haría. Un salto seguido de una marca no dice nada
sobre la dirección a la que salta: la etiqueta del salto puede estar
marcada en cualquier otro lugar. Si son la misma variable, el salto sobra;
si son distintas, la cabeza de la regla las unifica igual, y el salto
desaparece de un lugar donde hacía falta. `==` pregunta si son la misma
variable sin ligar ninguna.

El error aparece al ensamblar porque al optimizar no hay nada que
contradecir: unificar dos variables libres siempre funciona. Recién el
ensamblador intenta ligar esa única variable a las dos direcciones de sus
dos marcas, y la segunda unificación falla. Si el ensamblador no lo
comprobara —si, por ejemplo, reemplazara las etiquetas por números sin
unificar—, el código saltaría a una de las dos marcas: en `cuenta`, el
bucle perdería el salto hacia atrás y escribiría 3 una sola vez. Que el
ensamblador falle es lo que convierte un código equivocado en un error
visible.

## 9

Una marca que ningún salto usa no es un destino, y quitarla deja al
descubierto el código muerto que la seguía, que la mirilla puede quitar.
Por eso las dos cosas se repiten hasta que el código no cambia. La
condición «ningún salto usa la etiqueta» depende de todo el código, no una
secuencia corta: no es un modismo, y por eso va fuera de la mirilla:

<!-- ejemplo: capitulo-45/soluciones.pl predicado: mirilla_completa/2 quitar_marcas/2 marca_sin_uso/2 -->
```prolog
%!  mirilla_completa(+Codigo0:list, -Codigo:list) is det.
%
%   Codigo es Codigo0 pasado por la mirilla y sin las marcas de etiquetas
%   que ningún salto usa, repetido hasta que no cambia.
mirilla_completa(Codigo0, Codigo) :-
    mirilla(Codigo0, Codigo1),
    quitar_marcas(Codigo1, Codigo2),
    (   Codigo2 == Codigo1
    ->  Codigo = Codigo1
    ;   mirilla_completa(Codigo2, Codigo)
    ).

%!  quitar_marcas(+Codigo0:list, -Codigo:list) is det.
%
%   Codigo es Codigo0 sin las marcas de etiquetas que ninguna instrucción
%   de Codigo0 usa como destino.
quitar_marcas(Codigo0, Codigo) :-
    exclude(marca_sin_uso(Codigo0), Codigo0, Codigo).

%!  marca_sin_uso(+Codigo:list, +I) is semidet.
%
%   I es una marca de una etiqueta que ningún salto de Codigo usa.
marca_sin_uso(Codigo, etiqueta(L)) :-
    \+ ( member(I, Codigo),
         destino(I, D),
         D == L ).
```

```prolog
?- analizar("si 2 > 1 entonces escribir 1 sino escribir 2 fin", P), generar(P, C0), mirilla_completa(C0, C).
P = [si(rel(>, num(2), num(1)), [escribir(num(1))], [escribir(num(2))])],
C0 = [apilar(2), apilar(1), comparar(>), saltar_si_cero(_A), apilar(1), escribir, saltar(_B), etiqueta(_A), apilar(...)|...],
C = [apilar(1), escribir].
```

## 10

`a_texto/2` recorre el árbol y escribe cada nodo; los paréntesis dependen de
la precedencia de cada operador y de su lado. El operando izquierdo admite
un operador de la misma precedencia, porque la gramática agrupa a la
izquierda; el derecho necesita una precedencia mayor, y si no, lleva
paréntesis: `a - (b - c)` los necesita, `(a - b) - c` no.

<!-- ejemplo: capitulo-45/soluciones.pl predicado: a_texto/2 expresion_texto/3 -->
```prolog
%!  a_texto(+Programa:list, -Texto:atom) is det.
%
%   Texto es un texto de Programa que analizar/2 lee como Programa: las
%   sentencias separadas por punto y coma y cada expresión con los
%   paréntesis que su forma necesita. Los números deben ser naturales, como
%   los que produce analizar/2.
a_texto(Programa, Texto) :-
    bloque_texto(Programa, Texto).

%!  expresion_texto(+E, +Minima:integer, -T:atom) is det.
%
%   T es el texto de la expresión E; va entre paréntesis si la precedencia
%   de su operador es menor que Minima. El operando derecho exige una
%   precedencia mayor que la del operador, porque se agrupa a la
%   izquierda: a - (b - c) necesita los paréntesis.
expresion_texto(num(N), _, N).
expresion_texto(id(X), _, X).
expresion_texto(bin(Op, A, B), Minima, T) :-
    precedencia(Op, P),
    expresion_texto(A, P, TA),
    P1 is P + 1,
    expresion_texto(B, P1, TB),
    format(atom(T0), "~w ~w ~w", [TA, Op, TB]),
    (   P < Minima
    ->  format(atom(T), "(~w)", [T0])
    ;   T = T0
    ).
```

```prolog
?- analizar("x := (a - (b - c)) * d / 2", P), a_texto(P, T).
P = [asignar(x, bin(/, bin(*, bin(-, id(a), bin(-, id(b), id(c))), id(d)), num(2)))],
T = 'x := (a - (b - c)) * d / 2'.
```

El encabezado declara `a_texto(+Programa, -Texto) is det`: con un árbol,
hay un solo texto. No declara el modo inverso, porque para eso está
`analizar/2`. Tampoco alcanza con usar `programa//1` en sentido inverso: con
el árbol dado y la lista de componentes libre, `expresion//1` llama primero a
`termino(T)` con `T` libre, que genera términos sin relación con el árbol, y
`mas_terminos//2` construye el resultado recién al final. La gramática está
escrita para leer, no para escribir. La prueba `ida_y_vuelta` comprueba, con
cada programa de ejemplo, que `analizar/2` lee el texto como el mismo árbol.

## 11

El `si` es `si_1/4`: sus argumentos son `n` antes y después y la salida. Su
primera cláusula llama al bucle, `mientras_2/4`, que agrega `n` a la salida
en la cabeza misma, `[A|C]`, porque el `escribir n` se desplegó en una
unificación:

```prolog
principal(A, B) :-
    si_1(3, _, A, B).
si_1(A, B, C, D) :-
    A>0,
    mientras_2(A, B, C, D).
si_1(A, A, B, B) :-
    A=<0.
mientras_2(A, B, [A|C], D) :-
    A>0,
    E is A-1,
    mientras_2(E, B, C, D).
mientras_2(A, A, B, B) :-
    A=<0.
```

Con `n := 100000`, las cuatro formas miden:

```text
?- time(interpretar(P, S)).
% 3,600,203 inferences, 0.406 CPU in 0.427 seconds (95% CPU, 8862038 Lips)

?- time(maquina(O, S)).
% 7,600,064 inferences, 1.078 CPU in 1.090 seconds (99% CPU, 7049335 Lips)

?- time(maquina(O2, S)).
% 7,600,063 inferences, 1.188 CPU in 1.213 seconds (98% CPU, 6400053 Lips)

?- time(correr_especializado(P, S)).
% 309,119 inferences, 0.062 CPU in 0.058 seconds (108% CPU, 4945904 Lips)
```

`P` es el árbol del programa, `O` su código compilado y `O2` el optimizado.
Las inferencias son cien veces las de `n := 1000`, salvo en la versión
especializada, donde el costo fijo de especializar pesa menos: 36 por iteración
en el intérprete, 76 en la máquina y 3 en la versión especializada. La
proporción de los tiempos es parecida.

## 12

Primero se cuentan las subexpresiones compuestas de la expresión, con
`msort/2` y `clumped/2`, y se guardan las que aparecen más de una vez.
Después se reemplazan de abajo hacia arriba: cada una se busca en el
diccionario incompleto con `buscar/3`, que la agrega la primera vez con un
nombre libre y la encuentra las siguientes. Como los hijos se reemplazan
antes que el padre, el diccionario queda en un orden en que cada
subexpresión aparece después de las que usa, y las asignaciones salen en
ese orden. Los nombres se dan al final, como `numerar/2` da los números en
el [capítulo 34](../capitulo-34-estructuras-incompletas-y-listas-diferencia/index.md):

<!-- ejemplo: capitulo-45/soluciones.pl predicado: compartir_expresion/5 repetidas/2 reemplazar/4 definiciones/4 -->
```prolog
%!  compartir_expresion(+E0, +N0, -N, -Temporales, -E) is det.
%
%   E es E0 con cada subexpresión repetida reemplazada por una variable
%   nueva; Temporales son las asignaciones de esas variables, las internas
%   primero. El diccionario incompleto (buscar/3 del capítulo 34) asocia
%   cada subexpresión repetida con su nombre y su definición: la primera
%   aparición la agrega, las siguientes la encuentran.
compartir_expresion(E0, N0, N, Temporales, E) :-
    repetidas(E0, Repetidas),
    reemplazar(E0, Repetidas, Dic, E),
    definiciones(Dic, N0, N, Temporales).

%!  repetidas(+E, -Repetidas:list) is det.
%
%   Repetidas son las subexpresiones compuestas de E que aparecen más de
%   una vez.
repetidas(E, Repetidas) :-
    findall(S, ( sub_term(S, E), S = bin(_, _, _) ), Ss0),
    msort(Ss0, Ss),
    clumped(Ss, Pares),
    findall(S, ( member(S-K, Pares), K > 1 ), Repetidas).

%!  reemplazar(+E0, +Repetidas:list, ?Dic, -E) is det.
%
%   E es E0 con cada subexpresión de Repetidas reemplazada, de abajo hacia
%   arriba, por id(Nombre), con Nombre libre hasta definiciones/4. Dic es
%   el diccionario incompleto de pares Subexpresion-t(Nombre, Cuerpo).
reemplazar(num(N), _, _, num(N)).
reemplazar(id(X), _, _, id(X)).
reemplazar(bin(Op, A0, B0), Repetidas, Dic, E) :-
    reemplazar(A0, Repetidas, Dic, A),
    reemplazar(B0, Repetidas, Dic, B),
    Nodo = bin(Op, A, B),
    (   memberchk(bin(Op, A0, B0), Repetidas)
    ->  buscar(bin(Op, A0, B0), Dic, t(Nombre, Nodo)),
        E = id(Nombre)
    ;   E = Nodo
    ).

%!  definiciones(?Dic, +N0:integer, -N:integer, -Temporales:list) is det.
%
%   Da nombre a las entradas del diccionario incompleto Dic, en orden,
%   desde t_N0, y Temporales son sus asignaciones.
definiciones(Dic, N, N, []) :-
    var(Dic),
    !.
definiciones([_-t(Nombre, Cuerpo)|Dic], N0, N, [asignar(Nombre, Cuerpo)|Ts]) :-
    format(atom(Nombre), "t_~w", [N0]),
    N1 is N0 + 1,
    definiciones(Dic, N1, N, Ts).
```

```prolog
?- analizar("x := (a + b) * (a + b) - (a + b)", P0), compartir(P0, P).
P0 = [asignar(x, bin(-, bin(*, bin(+, id(a), id(b)), bin(+, id(a), id(b))), bin(+, id(a), id(b))))],
P = [asignar(t_1, bin(+, id(a), id(b))), asignar(x, bin(-, bin(*, id(t_1), id(t_1)), id(t_1)))].
```

La prueba `compartir_anidadas` comprueba que `(a + b) * c + (a + b) * c`
calcula primero `t_1 := a + b` y después `t_2 := t_1 * c`. Compartir es
correcto porque una expresión de Mini no tiene efectos: calcularla una vez o
dos da lo mismo. El resultado ya no es un árbol sino un grafo, en el que un
nodo tiene varios padres; el [capítulo 50](../capitulo-50-proyecto-fft-simbolica/index.md) construye grafos así.
