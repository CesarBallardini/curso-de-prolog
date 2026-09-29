# Soluciones del capítulo 64 — Proyecto: el algoritmo Rete

El código de esta página está en `ejemplos/capitulo-64/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `pruebas.pl`, que carga
las demás versiones, y no modifica ningún archivo del capítulo: los
programas nuevos son cláusulas de `programa/2`, que el
[capítulo 60](../capitulo-60-proyecto-interprete-dirigido-patrones/index.md)
declara `multifile`, y las variantes de la red se construyen con los
predicados del capítulo. Los ejercicios 5 y 8 se resuelven con los archivos
del capítulo: `cuentas/4` está en `negacion.pl`, y `mostrar_red/1`, que usa
también el ejercicio 2, en `red.pl`. Es `% solo-local`, porque carga otros archivos.

## 1

`aviso` es un prefijo de `oferta`: las dos reglas comparten el nodo del
patrón y el de la prueba, y `aviso` cuelga del segundo. `venta` empieza con
`producto(Q, _)`, una variante de `producto(P, C)`, y comparte el primer
nodo; su segundo prefijo, `[producto(Q, _), cliente(_, Q)]`, no es una
variante de ningún prefijo de `oferta`, que tiene la prueba en el medio.
Los dos patrones de `cliente/2` son variantes como patrones sueltos y
comparten el nodo alfa. Quedan dos nodos alfa y cuatro nodos beta, contra
siete condiciones:

<!-- ejemplo: capitulo-64/soluciones.pl fragmento: programa(tienda, .. ]). -->
```prolog
programa(tienda,
    [ oferta :: [producto(P, C), {C > 100}, cliente(_, P)] ---> [],
      aviso :: [producto(_, C), {C > 100}] ---> [],
      venta :: [producto(Q, _), cliente(_, Q)] ---> []
    ]).
```

```prolog
?- mostrar_programa(tienda).
alfa 1: producto(A,B) -> [1]
alfa 2: cliente(A,B) -> [4,3]
beta 1 (de 0, union(1)): producto(A,B)
beta 2 (de 1, prueba): {B>100} => [aviso]
beta 3 (de 2, union(2)): cliente(C,A) => [oferta]
beta 4 (de 1, union(2)): cliente(C,A) => [venta]
true.
```

## 2

<!-- ejemplo: capitulo-64/soluciones.pl fragmento: programa(hermanos_variantes, .. ]). -->
```prolog
programa(hermanos_variantes,
    [ antepasado_1 :: [progenitor(A, D)] ---> [agregar(antepasado(A, D))],
      temprana :: [progenitor(P, A), {A \== B}, progenitor(P, B)]
           ---> [agregar(hermanos(A, B))],
      invertida :: [progenitor(P, B), progenitor(P, A), {A \== B}]
           ---> [agregar(hermanos(A, B))],
      hermanos :: [progenitor(P, A), progenitor(P, B), {A \== B}]
           ---> [agregar(hermanos(A, B))]
    ]).
```

```prolog
?- mostrar_red(hermanos_variantes).
alfa 1: progenitor(A,B) -> [4,3,1]
beta 1 (de 0, union(1)): progenitor(A,B) => [antepasado_1]
beta 2 (de 1, prueba): {B\==C}
beta 3 (de 2, union(1)): progenitor(A,C) => [temprana]
beta 4 (de 1, union(1)): progenitor(A,C)
beta 5 (de 4, prueba): {C\==B} => [invertida]
beta 6 (de 4, prueba): {B\==C} => [hermanos]
true.
```

Las tres versiones comparten con `antepasado_1` el nodo 1, porque todas
empiezan con un patrón de `progenitor/2` con dos variables distintas.
`temprana` se separa en el segundo paso, la prueba. Esa prueba se cumple
siempre, porque `B` está libre y una variable libre no es idéntica a `A`:
la regla agrega también `hermanos(ana, ana)`. `invertida` comparte además
el nodo 4: `[progenitor(P, B), progenitor(P, A)]` es una variante de
`[progenitor(P, A), progenitor(P, B)]`, porque los nombres de las variables
no cuentan. Se separa en la prueba, `{A \== B}`, que en su prefijo compara
la variable del segundo patrón con la del primero, y en `hermanos` la del
primero con la del segundo: los términos no son variantes, aunque la
prueba signifique lo mismo. La red compara la forma de las condiciones, no
su significado.

## 3

Una tabla de `library(assoc)` se recorre en orden ascendente de clave. Con
`K-Inversos`, dentro de una regla la instanciación de sellos más altos
tiene la clave menor y sale primero, como en `conjunto_conflicto/3`, que
recorre la memoria del hecho más reciente al más antiguo. Con `K-Sellos`,
la primera sería la de los hechos más antiguos.

LEX y MEA calculan su clave a partir de los sellos y no dependen del orden
de la lista, salvo en los empates; la estrategia que cambia es `orden`, que
elige la primera. Se nota en cualquier programa con dos instanciaciones de
la misma regla, como `familia`:

<!-- ejemplo: capitulo-64/soluciones.pl predicado: primera_ascendente/3 -->
```prolog
%!  primera_ascendente(+Programa, +Hechos:list, -Elegida) is det.
%
%   Elegida es la instanciación que elige orden si el conjunto de conflicto
%   de la red, con los Hechos, se ordena por la clave K-Sellos: por la
%   regla y, dentro de ella, del hecho más antiguo al más reciente.
primera_ascendente(Programa, Hechos, Elegida) :-
    red_de(Programa, Red),
    cargar(Red, Hechos, _, Rete),
    conjunto_rete(Rete, Is),
    Red = red(_, _, _, Terminales),
    findall((K-Sellos)-I,
            ( member(I, Is),
              I = instanciacion(Nombre, Sellos, _, _),
              once(gen_assoc(K, Terminales, regla(Nombre, _, _, _))) ),
            Pares),
    keysort(Pares, [_-Elegida|_]).
```

```prolog
?- primera_ascendente(familia, [padre(juan, ana), madre(ana, sofia), padre(juan, pedro)], I).
I = instanciacion(progenitor_p, [1], 1, [agregar(progenitor(juan, ana))]).

?- primera_descendente(familia, [padre(juan, ana), madre(ana, sofia), padre(juan, pedro)], I).
I = instanciacion(progenitor_p, [3], 1, [agregar(progenitor(juan, pedro))]).
```

## 4

`propagar/6` ordena las activaciones con `sort/4` antes de ejecutarlas, así
que invertir las listas de sucesores de la red no cambia nada: hay que
cambiar el orden en la carga. `cargar_con/5` recibe el orden y la
activación como argumentos:

<!-- ejemplo: capitulo-64/soluciones.pl predicado: cargar_con/5 entrar_con/6 conjunto_invertido/3 -->
```prolog
%!  cargar_con(+Orden, :Activar, +Red, +Hechos:list, -Rete) is det.
%
%   Como cargar/4, sin la memoria de trabajo: los Hechos, que son
%   distintos, entran con los sellos 1, 2, ..., y los sucesores de sus
%   nodos alfa se ordenan con sort/4 y Orden, y se activan con
%   call(Activar, Sello, Red, Nodo-Paso, Rete0, Rete).
cargar_con(Orden, Activar, Red, Hechos, Rete) :-
    rete_vacio(Red, Rete0),
    foldl(entrar_con(Orden, Activar, Red), Hechos, Rete0-1, Rete-_).

%!  entrar_con(+Orden, :Activar, +Red, +Hecho, +Rete0S0, -ReteS) is det.
%
%   Hecho entra con el sello S0, y S es el sello siguiente.
entrar_con(Orden, Activar, Red, Hecho, rete(Alfas0, Betas, C)-S0,
           Rete-S) :-
    entrar_alfa(mas, S0, Hecho, Red, Alfas0, Alfas, Entradas),
    Red = red(_, Info, _, _),
    findall(B-Paso,
            ( member(A-Paso, Entradas),
              get_assoc(A, Info, a(_, Sucesores)),
              member(B, Sucesores) ),
            Activaciones0),
    sort(1, Orden, Activaciones0, Activaciones),
    foldl(call(Activar, S0, Red), Activaciones, rete(Alfas, Betas, C),
          Rete),
    S is S0 + 1.

%!  conjunto_invertido(+Programa, +Hechos:list, -Sellos:list) is det.
%
%   Sellos son los de las instanciaciones del conjunto de conflicto de la
%   red del Programa con los Hechos, cargados activando los sucesores de
%   cada nodo alfa del menos profundo al más profundo.
conjunto_invertido(Programa, Hechos, Sellos) :-
    red_de(Programa, Red),
    cargar_con(@=<, activar_derecha(mas), Red, Hechos, Rete),
    conjunto_rete(Rete, Is),
    findall(S, member(instanciacion(_, S, _, _), Is), Sellos).
```

```prolog
?- conjunto_invertido(pares, [p(1), p(2)], S).
S = [[2, 2], [2, 2], [2, 1], [1, 2], [1, 1], [1, 1]].
```

Los pares de un hecho consigo mismo aparecen dos veces. Cuando entra
`p(1)`, el nodo 1 se activa primero por la derecha: forma el token `[1]` y
lo entrega al nodo 2, que se activa por la izquierda y lo une con la
memoria alfa, donde `p(1)` ya está: forma `[1, 1]`. Después el nodo 2 se
activa por la derecha con el mismo hecho, encuentra `[1]` en la memoria de
su padre y vuelve a formar `[1, 1]`. En el orden de `propagar/6`, el nodo 2
se activa por la derecha antes de que exista el token `[1]`, y el par se
forma una sola vez.

En `hermanos` el mismo error ocurre en el nodo 5, que guarda tokens
repetidos, pero no llega al conjunto de conflicto: la prueba `{A \== B}`
descarta cada par de un hecho consigo mismo. Por eso las pruebas de
`tokens.plt` con `familia` no lo detectan, y hace falta un programa sin
esa prueba.

## 5

El nodo 11 recibe un token por cada meta `despejar`: el de `a`, sello 1, y
el de `b`, sello 2. `sobre(b, a)` bloquea el primero y `sobre(c, b)`, el
segundo:

```prolog
?- cuentas(cajas, [meta(despejar(a)), meta(despejar(b)), sobre(b, a), sobre(c, b)], 11, C).
C = [[1]-1, [2]-1].

?- reconocer_rete(cajas, [meta(despejar(a)), meta(despejar(b)), sobre(b, a), sobre(c, b)], Is).
Is = [instanciacion(despejar_encima, [2, 4], 2, [agregar(meta(despejar(c)))]), instanciacion(despejar_encima, [1, 3], 2, [agregar(meta(despejar(b)))])].

?- cambios_rete(cajas, [meta(despejar(a)), meta(despejar(b)), sobre(b, a), sobre(c, b)], [menos(sobre(b, a))], Is).
Is = [instanciacion(despejar_encima, [2, 4], 2, [agregar(meta(despejar(c)))]), instanciacion(despejada, [1], 2, [quitar(meta(despejar(a)))])].
```

Al quitar `sobre(b, a)`, la cuenta del token de `a` baja a cero, y el de
`b` sigue en uno. Sale `despejar_encima` con los sellos `[1, 3]`, que usaba
el hecho quitado, y entra `despejada` con `[1]`: `a` ya no tiene nada
encima. `bajar` no entra, porque no hay ningún `sobre(a, Y)`: `a` está en el
piso por omisión.

## 6

<!-- ejemplo: capitulo-64/soluciones.pl predicado: sin_registro/7 -->
```prolog
%!  sin_registro(+Red, +Estrategia, +Limite:integer, +N:integer, +Estado,
%!               -Memoria, -Resultado) is det.
%
%   Sigue el ciclo después de N ciclos, desde el par Memoria-Rete Estado.
sin_registro(Red, Estrategia, Limite, N, Mt0-Rete0, Mt, Resultado) :-
    conjunto_rete(Rete0, Is),
    (   Is == []
    ->  Mt = Mt0,
        Resultado = nada_aplicable
    ;   N >= Limite
    ->  Mt = Mt0,
        Resultado = limite(Limite)
    ;   preferida(Estrategia, Is, Elegida),
        Elegida = instanciacion(_, _, _, Acciones),
        quitar_elegida(Red, Elegida, Rete0, Rete1),
        acciones_rete(Acciones, Red, Mt0-Rete1, Estado, Fin),
        (   Fin = parar(R)
        ->  Estado = Mt-_,
            Resultado = R
        ;   N1 is N + 1,
            sin_registro(Red, Estrategia, Limite, N1, Estado, Mt, Resultado)
        )
    ).
```

```prolog
?- ciclo_sin_registro(reingreso, orden, 20, [], M, R).
M = [ocupado, aviso],
R = limite(20).
```

Después de `liberar`, `avisar` y `ocupar` vuelven al conjunto con los
sellos `[]` y `[1]`, porque la negación que las bloqueaba se cumple otra
vez. `avisar` no cambia nada, porque `aviso` ya está; `ocupar` agrega
`ocupado` con un sello nuevo, `liberar` lo quita, y el ciclo se repite sin
fin. Con `familia` y con el configurador los resultados son los del
[capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), como comprueban dos pruebas: sin negaciones que se deshagan,
una instanciación disparada solo podría volver con un hecho nuevo, que
tendría otro sello.

## 7

<!-- ejemplo: capitulo-64/soluciones.pl predicado: carga_siempre/2 siempre_derecha/5 -->
```prolog
%!  carga_siempre(+K:integer, -Inferencias:integer) is det.
%
%   Inferencias son las de cargar pedido_ampliado(K, _) en la red del
%   configurador activando por la derecha cada sucesor, aunque su padre no
%   tenga tokens.
carga_siempre(K, Inferencias) :-
    red_de(configurador, Red),
    pedido_ampliado(K, Hechos),
    inferencias(cargar_con(@>=, siempre_derecha, Red, Hechos, _),
                Inferencias).

%!  siempre_derecha(+Sello:integer, +Red, +Activacion, +Rete0, -Rete)
%!      is det.
%
%   Como activar_derecha/6 con el signo mas, sin mirar la memoria del
%   padre.
siempre_derecha(Sello, Red, Nodo-Paso, Rete0, Rete) :-
    Red = red(_, _, Nodos, _),
    get_assoc(Nodo, Nodos, beta(Tipo, Padre, Prefijo, _, _)),
    derecha(Tipo, mas, Sello-Paso, Padre-Nodo, Prefijo, Red, Rete0, Rete).
```

```prolog
?- carga_normal(0, A), carga_siempre(0, B).
A = 7851,
B = 13343.

?- carga_normal(400, A), carga_siempre(400, B).
A = 169978,
B = 315870.
```

Sin el control, la carga cuesta casi el doble. Mientras se carga el
catálogo, la fase todavía no está en la memoria —es el último hecho de la
memoria inicial—, así que ningún nodo beta que lee `objeto/3` tiene tokens
en su padre. Cada objeto activa igual los doce nodos que leen su memoria
alfa, y cada activación copia el prefijo y recorre una memoria vacía: unas
365 inferencias por objeto que no producen nada.

## 8

La tabla de `red_de/2` guarda la red de cada programa, y la red guarda las
condiciones copiadas, no los predicados que llaman. Si cambia un marco
—por ejemplo, una clase nueva de `marco/3` con `procesador` como padre—, la
red de la versión 5 sigue siendo correcta, porque las pruebas de clase se
ejecutan cada vez que un token llega a su nodo. En la versión 7 la prueba
`es_de_clase(C, procesador)` se ejecuta en el nodo alfa, **cuando el hecho
entra**: los objetos que ya están en la memoria alfa se aceptaron o
rechazaron con los marcos anteriores. La red compilada sigue siendo la
misma; lo que queda desactualizado es el estado de las memorias alfa, que
hay que volver a cargar. Cambiar las reglas de un programa, en cambio,
desactualiza la tabla: `abolish_all_tables/0`, del
[capítulo 39](../capitulo-39-tabulacion/index.md), la vacía, y la consulta
siguiente vuelve a compilar.

## 9

<!-- ejemplo: capitulo-64/soluciones.pl predicado: con_cambios/6 -->
```prolog
%!  con_cambios(+Red, +Estrategia, +N:integer, +Disparadas:list, +Estado,
%!              -Resultado) is det.
%
%   Hace el ciclo N con un_ciclo/9 y escribe sus cambios.
con_cambios(Red, Estrategia, N, Disparadas0, Estado0, Resultado) :-
    Estado0 = _-Rete0,
    identidades(Rete0, Antes),
    un_ciclo(Red, Estrategia, breve, N, Disparadas0, Disparadas, Estado0,
             Estado, Fin),
    (   Fin == nada_aplicable
    ->  Resultado = nada_aplicable
    ;   Estado = _-Rete,
        identidades(Rete, Despues),
        ord_subtract(Despues, Antes, Entraron),
        ord_subtract(Antes, Despues, Salieron0),
        ord_subtract(Salieron0, Disparadas, Salieron),
        format("   entran ~w, salen ~w~n", [Entraron, Salieron]),
        (   Fin = parar(R)
        ->  Resultado = R
        ;   N1 is N + 1,
            con_cambios(Red, Estrategia, N1, Disparadas, Estado, Resultado)
        )
    ).
```

```prolog
?- rastrear_cambios(cajas, orden, [meta(apilar([a, b])), sobre(a, piso), sobre(b, piso), sobre(c, a)], R).
1: despejar_base de 1
   entran [bajar-[5,4],despejada-[5]], salen []
2: bajar de 2
   entran [apilar-[1,3]], salen [despejada-[5]]
3: apilar de 1
   entran [terminada-[8]], salen []
4: terminada de 1
   entran [], salen []
R = nada_aplicable.
```

En el ciclo 1 entra la meta `despejar(c)`, con el sello 5, y con ella
entran `despejada` y `bajar`: las dos pasan por el nodo de negación porque
nada está sobre `c`. En el ciclo 2, `bajar` reemplaza `sobre(c, a)` por
`sobre(c, piso)` y quita la meta: sale `despejada`, que la usaba, y entra
`apilar`, que no usa ningún hecho nuevo. Entra por la negación: la cuenta
del token de la meta `apilar([a, b])` en el nodo de `no(sobre(_, a))` bajó
a cero cuando salió `sobre(c, a)`. Una salida de la memoria provocó una
entrada en el conjunto.

## 10

<!-- ejemplo: capitulo-64/soluciones.pl predicado: tokens_al_final/3 -->
```prolog
%!  tokens_al_final(+N:integer, -Tokens:integer, -Antepasados:integer)
%!      is det.
%
%   Tokens son los de todas las memorias beta de la red de familia al
%   terminar cadena(N, _) con orden, y Antepasados, los hechos
%   antepasado/2 de la memoria final.
tokens_al_final(N, Tokens, Antepasados) :-
    cadena(N, Hechos),
    red_de(familia, Red),
    cargar(Red, Hechos, Mt0, Rete0),
    ciclo_rete(Red, orden, sin_traza, 0, _, [], Mt0-Rete0, Mt-Rete, _),
    Red = red(_, _, Nodos, _),
    aggregate_all(sum(T),
                  ( gen_assoc(B, Nodos, _),
                    tokens(B, Rete, Ts),
                    length(Ts, T) ),
                  Tokens),
    aggregate_all(count, elemento(_, antepasado(_, _), Mt), Antepasados).
```

```prolog
?- tokens_al_final(10, T, A).
T = 85,
A = 55.

?- tokens_al_final(20, T, A).
T = 270,
A = 210.

?- tokens_al_final(40, T, A).
T = 940,
A = 820.
```

Con `N` generaciones hay `(N + 1)N/2` hechos `antepasado/2`, y en las tres
mediciones los tokens son exactamente esa cantidad más `3N`. Los `3N` son
tokens de las reglas de una condición y de sus prefijos, que crecen con la
cadena; el resto crece como los hechos derivados, porque cada `antepasado/2`
deja un token en el nodo de `antepasado(B, C)` de `antepasado_2`: el par de
un progenitor con un antepasado de su hijo que lo produjo o que lo
confirma. La red ocupa, en tokens, algo más que la memoria de trabajo: es
la copia de las comparaciones que Merritt señala como el precio de la
velocidad.

## 11

<!-- ejemplo: capitulo-64/soluciones.pl predicado: forzar/2 configurar_forzado/2 -->
```prolog
%!  forzar(+Condiciones:list, -Pasos:list) is det.
%
%   Pasos son los de las Condiciones con todas las pruebas que siguen a un
%   patrón dentro de su paso alfa.
forzar([], []).
forzar([C|Cs], [Paso|Pasos]) :-
    (   ( C = {_} ; C = no(_) )
    ->  Paso = C,
        Resto = Cs
    ;   pruebas_siguientes(Cs, Pruebas, Resto),
        Paso = alfa(C, Pruebas)
    ),
    forzar(Resto, Pasos).

%!  configurar_forzado(+Pedido:list, -Resultado) is det.
%
%   Resultado es ok(Componentes) si el configurador con la red de
%   pasos_forzados/2 termina para el Pedido, o error(E) si lanza el
%   error E.
configurar_forzado(Pedido, Resultado) :-
    programa(configurador, Reglas),
    compilar_red(pasos_forzados, Reglas, Red),
    memoria_del_pedido(Pedido, Hechos),
    catch(( ejecutar_red(Red, mea, sin_traza, Hechos, _, Mt, _),
            hechos(Mt, Memoria),
            componentes(Memoria, Componentes, _),
            Resultado = ok(Componentes) ),
          E,
          Resultado = error(E)).
```

```prolog
?- configurar_forzado([pedido(nucleos, 8), pedido(memoria, 32), pedido(video, si)], R).
R = error(error(instantiation_error, context(system:(>=)/2, _))).
```

En `candidato_procesador`, la prueba `{N >= Minimo}` sigue al patrón
`objeto/3`, y `pasos_forzados/2` la lleva al nodo alfa. Allí se ejecuta
cuando entra cada objeto, antes de cualquier unión, con `Minimo` libre:
`Minimo` viene de `pedido(nucleos, Minimo)`, una condición anterior que el
hecho del objeto no liga. `solo_del_hecho/3` rechaza esa prueba porque
`Minimo` aparece en los pasos anteriores y no en `objeto(P, C, R)`. Una
prueba como `{A \== B}` con una variable de una condición anterior no
lanzaría un error: daría otro resultado en silencio, porque una variable
libre no es idéntica a ninguna otra.

## 12

<!-- ejemplo: capitulo-64/soluciones.pl predicado: ciclos_para_ganar/2 -->
```prolog
%!  ciclos_para_ganar(+K:integer, -C) is det.
%
%   C es la menor cantidad de ciclos para la cual la red con pruebas alfa
%   cuesta menos que el capítulo 63 en el configurador con
%   pedido_ampliado(K, _), si cada ciclo cuesta el promedio de los 21
%   medidos en cada intérprete, o nunca si el ciclo promedio de la red no
%   es más barato.
ciclos_para_ganar(K, C) :-
    comparar_con_pruebas(K, fila(_, I63, _, _, Carga, Ciclos)),
    Por63 is I63 / 21,
    PorRed is Ciclos / 21,
    (   Por63 > PorRed
    ->  C is floor(Carga / (Por63 - PorRed)) + 1
    ;   C = nunca
    ).
```

```prolog
?- ciclos_para_ganar(0, C).
C = nunca.

?- ciclos_para_ganar(800, C).
C = 49.
```

Con 828 hechos, el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) gasta en promedio 21 723 inferencias por
ciclo y la red con pruebas alfa 10 758, después de una carga de 527 796: la
red gana a partir del ciclo 49. Con el catálogo original, un ciclo de la
red cuesta más que uno del [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md), y la red no gana nunca. La
suposición es discutible en los dos sentidos: los ciclos agregados de un
configurador más largo serían de fases nuevas, cuyo costo depende de
cuántos objetos examinan; en la red cada fase examina su clase una vez, y en
el [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) cada ciclo examina toda la memoria, de modo que el promedio
favorece al [capítulo 63](../capitulo-63-proyecto-sistema-produccion/index.md) si las fases nuevas miran clases grandes, y a la red
si no las miran.
