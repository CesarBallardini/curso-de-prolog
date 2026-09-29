# Soluciones del capítulo 61 — Proyecto: una máquina de Prolog

El código de esta página está en `ejemplos/capitulo-61/soluciones.pl`, con
sus pruebas en `soluciones.plt`; las versiones de los ejercicios 6 y 9 están
en `soluciones_traza.pl` y `soluciones_sin_rastro.pl`, cada una con sus
pruebas. `soluciones.pl` carga la máquina terminada, `maquina.pl`, y con
ella las cinco versiones. Los programas objeto de los ejercicios son listas
de cláusulas que se pasan a `medir_clausulas/4` y a `resolver_clausulas/3`
de `almacen.pl`; `nativas/3` los ejecuta con Prolog en un módulo temporal.
Como carga otros archivos, se ejecuta en una instalación local:

<!-- ejemplo: capitulo-61/soluciones.pl fragmento: :- ensure_loaded(maquina). .. :- ensure_loaded(maquina). -->
```prolog
:- ensure_loaded(maquina).
```

## 1

```prolog
?- resolver(resolvente, listas, suma([1, 2], S)).
S = 3 ;
false.

?- resolver(almacen, listas, suma([1, 2], S)).
S = 3 ;
false.

?- resolver(indice, listas, suma([1, 2], S)).
S = 3.
```

Las tres dan la misma respuesta. En la versión 1 queda pendiente el
`member/2` que eligió la cláusula recursiva de `suma/3`, porque detrás está
la cláusula de la lista vacía; en la versión 3, el punto de elección de la
máquina con esa misma cláusula. La versión 5 calcula la clave `'[|]'/2` del
primer argumento, descarta `suma([], S, S)` y no apila nada; al final, con
`[]`, descarta la recursiva. Es lo que hace SWI-Prolog con el mismo programa.

```prolog
?- resolver(resolvente, maximo, maximo(3, 4, M)).
M = 4.

?- resolver(almacen, maximo, maximo(3, 4, M)).
M = 4.

?- resolver(indice, maximo, maximo(3, 4, M)).
M = 4.
```

Con `maximo(3, 4, M)`, la primera cláusula falla en `3 >= 4`, antes de
llegar al corte, y la segunda es la última: ninguna versión deja
alternativas. La versión 3 no produce el error de existencia de la
[sección 61.4](index.md#614-celdas-almacen-y-rastro), porque el `!` nunca llega a ser la primera meta de la
resolvente; y la versión 1 tampoco da una respuesta incorrecta, porque el
corte que ejecuta como `true` no se alcanza. Las dos versiones fallan solo
cuando el corte se ejecuta, como con `maximo(4, 3, M)`.

## 2

Una celda se crea cada vez que se usa una cláusula cuya cabeza unifica:
`usar/5` suma las `K` variables de la cláusula a la primera celda libre solo
si la unificación tiene éxito. Un intento fallido no consume celdas, porque
su estado se descarta. En `suma_hasta(200, _)`:

| Origen | Celdas |
|---|---|
| la consulta, `_` | 1 |
| `suma_hasta/2`, `lista_hasta/2` y `suma/2`, una vez cada una | 3 + 2 + 2 |
| la cláusula recursiva de `desde/3`, 200 veces, con 4 variables | 800 |
| `desde(0, L, L)`, una vez | 1 |
| la cláusula recursiva de `suma/3`, 200 veces, con 5 variables | 1 000 |
| `suma([], S, S)`, una vez | 1 |
| la recursiva de `desde/3` con `N` en 0, al volver atrás: la cabeza unifica y `0 > 0` falla | 4 |

El total es 1 814. La indexación evita intentos que fallan, y esos no crean
celdas; las cláusulas que se usan son las mismas en las dos versiones, así
que las celdas también.

## 3

```prolog
?- ejecutar_archivo(ejemplos('capitulo-07/recorrer'), ultimo([a, b], X)).
X = b ;
false.

?- ejecutar_archivo(ejemplos('capitulo-07/recorrer'), pegar(X, Y, [a])).
X = [],
Y = [a] ;
X = [a],
Y = [] ;
false.

?- ejecutar_archivo(ejemplos('capitulo-07/recorrer'), largo([a, b], N)).
N = 2.
```

SWI-Prolog, con `recorrer.pl` cargado, da las mismas respuestas en el mismo
orden, y también termina las dos primeras en `;` y `false.` y la tercera en
punto. Las claves lo explican. Las dos cláusulas de `ultimo/2` empiezan con
una lista no vacía, `'[|]'/2`, así que al llegar a `ultimo([b], X)` la
segunda sigue siendo compatible y queda pendiente, aunque después falle.
En `pegar(X, Y, [a])` el primer argumento es libre y ninguna cláusula se
descarta. En `largo/2` las claves `[]` y `'[|]'/2` separan las dos cláusulas
en cada llamada. SWI-Prolog puede construir tablas para otros argumentos
([sección 16.3](../capitulo-16-rendimiento/index.md#163-indexacion)), pero en estas consultas no le sirven: el argumento
que las distinguiría es una variable en alguna de las cabezas.

## 4

<!-- ejemplo: capitulo-61/soluciones.pl fragmento: tipos([ (tipo(1, entero) :- true), .. medir_clausulas(indice, Cs2, tipo(entero, _), Primero). -->
```prolog
tipos([ (tipo(1, entero) :- true),
        (tipo(2, entero) :- true),
        (tipo(3, entero) :- true),
        (tipo(a, atomo) :- true),
        (tipo(b, atomo) :- true)
      ]).

% tipos_invertidos(Cs): los mismos hechos, con el tipo primero.
tipos_invertidos([ (tipo(entero, 1) :- true),
                   (tipo(entero, 2) :- true),
                   (tipo(entero, 3) :- true),
                   (tipo(atomo, a) :- true),
                   (tipo(atomo, b) :- true)
                 ]).

%!  medir_tipos(-Segundo:list, -Primero:list) is det.
%
%   Segundo y Primero son las medidas, en la versión 5, de buscar los
%   enteros con el tipo en el segundo y en el primer argumento.
medir_tipos(Segundo, Primero) :-
    tipos(Cs1),
    medir_clausulas(indice, Cs1, tipo(_, entero), Segundo),
    tipos_invertidos(Cs2),
    medir_clausulas(indice, Cs2, tipo(entero, _), Primero).
```

```prolog
?- medir_tipos(S, P).
S = [respuestas-3, pasos-1, intentos-5, metas-1, elecciones-1, rastro-1, celdas-1],
P = [respuestas-3, pasos-1, intentos-3, metas-1, elecciones-1, rastro-1, celdas-1].
```

Con el tipo en el segundo argumento, la clave de la meta `tipo(X, entero)`
es `libre`: todas las cláusulas son candidatas, y después de la tercera
respuesta la máquina intenta todavía los dos hechos de `atomo`. Con el tipo
primero, la clave `entero` descarta esos dos hechos; la tercera respuesta
no deja punto de elección y la última termina en punto. La indexación de la
máquina solo mira el primer argumento: el orden de los argumentos decide
cuánto sirve.

## 5

<!-- ejemplo: capitulo-61/soluciones.pl predicado: unificar_con_prueba/5 ocurre/3 -->
```prolog
%!  unificar_con_prueba(+X, +Y, +Marca:integer, +Estado0, -Estado)
%!      is semidet.
%
%   Como unificar/5 de almacen.pl, con la prueba de ocurrencia: falla si
%   una celda se liga a un término que la contiene.
unificar_con_prueba(X0, Y0, Marca, Estado0, Estado) :-
    Estado0 = Almacen-_,
    desreferenciar(X0, Almacen, X),
    desreferenciar(Y0, Almacen, Y),
    (   X == Y
    ->  Estado = Estado0
    ;   X = '$v'(N)
    ->  \+ ocurre(N, Y, Almacen),
        ligar_celda(N, Y, Marca, Estado0, Estado)
    ;   Y = '$v'(N)
    ->  \+ ocurre(N, X, Almacen),
        ligar_celda(N, X, Marca, Estado0, Estado)
    ;   compound(X),
        compound(Y),
        compound_name_arity(X, Nombre, Aridad),
        compound_name_arity(Y, Nombre, Aridad),
        compound_name_arguments(X, Nombre, Xs),
        compound_name_arguments(Y, Nombre, Ys),
        foldl(unificar_con_prueba_argumento(Marca), Xs, Ys, Estado0, Estado)
    ).

%!  ocurre(+N:integer, +Termino, +Almacen) is semidet.
%
%   La celda N aparece en Termino, con las ligaduras del Almacen.
ocurre(N, Termino0, Almacen) :-
    desreferenciar(Termino0, Almacen, Termino),
    (   Termino = '$v'(M)
    ->  M =:= N
    ;   compound(Termino),
        arg(_, Termino, Argumento),
        ocurre(N, Argumento, Almacen)
    ).
```

`ocurre/3` desreferencia cada subtérmino, así que encuentra la celda
también a través de otras celdas ligadas. `unificar_con_prueba/5` falla con
`'$v'(0)` y `f('$v'(0))`, donde `unificar/5` liga la celda y deja un término
infinito, como `X = f(X)` en Prolog; `unify_with_occurs_check(X, f(X))`
falla igual que la versión con prueba. El costo es el que señala Spivey:
cada ligadura recorre el término entero.

## 6

<!-- ejemplo: capitulo-61/soluciones_traza.pl predicado: paso/5 volver/3 -->
```prolog
%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Escribe la altura de la pila y Meta, y da el paso de almacen.pl.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    Estado0 = m(_, Pila, Almacen, _, _, _),
    length(Pila, Altura),
    reconstruir(Meta, Almacen, Meta1),
    numbervars(Meta1, 0, _),
    format("~d ~W~n", [Altura, Meta1, [numbervars(true), quoted(true)]]),
    almacen:paso(Meta, Metas, Tabla, Estado0, Resultado).

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   Escribe que la máquina vuelve atrás, si hay a dónde, y vuelve con el
%   volver/3 de almacen.pl.
volver(Tabla, Estado0, Resultado) :-
    (   Estado0 = m(_, [_|_], _, _, _, _)
    ->  format("vuelve~n")
    ;   true
    ),
    almacen:volver(Tabla, Estado0, Resultado).
```

`traza` no define la máquina: la envuelve. `ejecutar/5` recibe el nombre
del módulo, como en el [patrón 59](../patrones.md#59-interprete-con-conducta-como-parametro), y llama a su `paso/5`. Con
`abuelo(juan, N)`, cada línea da la altura de la pila y la meta:

```text
0 abuelo(juan,A)
0 padre(juan,A)
1 padre(ana,A)
vuelve
1 padre(pedro,A)
vuelve
```

Después de `padre(ana, A)` llega la respuesta `N = luis`; al pedir otra, la
máquina vuelve al punto de elección de `padre(juan, A)`, que sigue arriba
con altura 1 porque la versión 3 no indexa y quedan los hechos de `ana` y
de `luis`.

## 7

<!-- ejemplo: capitulo-61/soluciones.pl predicado: transformar/2 transformar_cuerpo/6 auxiliar/5 -->
```prolog
%!  transformar(+Clausulas0:list, -Clausulas:list) is det.
%
%   Clausulas son las Clausulas0 con cada disyunción (A ; B) y cada
%   negación \+ G de los cuerpos reemplazadas por la llamada a un predicado
%   auxiliar nuevo, cuyas cláusulas siguen a la que lo usa.
transformar(Clausulas0, Clausulas) :-
    foldl(transformar_clausula, Clausulas0, Grupos, 0, _),
    append(Grupos, Clausulas).

%!  transformar_cuerpo(+Cuerpo0, -Cuerpo, -Auxiliares:list, ?Resto:list,
%!                     +N0:integer, -N:integer) is det.
%
%   Cuerpo es Cuerpo0 sin disyunciones ni negaciones; Auxiliares-Resto es
%   la lista diferencia de las cláusulas auxiliares creadas.
transformar_cuerpo(Cuerpo0, Cuerpo, Auxiliares, Resto, N0, N) :-
    (   var(Cuerpo0)
    ->  Cuerpo = Cuerpo0,
        Auxiliares = Resto,
        N = N0
    ;   Cuerpo0 = (A0, B0)
    ->  transformar_cuerpo(A0, A, Auxiliares, Medio, N0, N1),
        transformar_cuerpo(B0, B, Medio, Resto, N1, N),
        Cuerpo = (A, B)
    ;   Cuerpo0 = (A0 ; B0)
    ->  auxiliar(o, Cuerpo0, N0, N1, Cuerpo),
        transformar_cuerpo(A0, A, Auxiliares1, Medio, N1, N2),
        transformar_cuerpo(B0, B, Medio, Resto, N2, N),
        Auxiliares = [(Cuerpo :- A), (Cuerpo :- B)|Auxiliares1]
    ;   Cuerpo0 = (\+ G0)
    ->  auxiliar(no, Cuerpo0, N0, N1, Cuerpo),
        transformar_cuerpo(G0, G, Auxiliares1, Resto, N1, N),
        Auxiliares = [(Cuerpo :- G, !, fail), (Cuerpo :- true)|Auxiliares1]
    ;   Cuerpo = Cuerpo0,
        Auxiliares = Resto,
        N = N0
    ).

%!  auxiliar(+Prefijo:atom, +Meta, +N0:integer, -N:integer, -Llamada)
%!      is det.
%
%   Llamada es la llamada al auxiliar número N = N0 + 1, con las variables
%   de Meta como argumentos; su nombre es '$' seguido del Prefijo y de N.
auxiliar(Prefijo, Meta, N0, N, Llamada) :-
    N is N0 + 1,
    format(atom(Nombre), "$~w~d", [Prefijo, N]),
    term_variables(Meta, Variables),
    Llamada =.. [Nombre|Variables].
```

```prolog
?- transformado(disyuncion, signo(-2, S)).
S = negativo ;
S = positivo.

?- transformado(disyuncion, soltero(P)).
P = ana ;
false.
```

Las respuestas son las de Prolog con el programa sin transformar. La
negación funciona porque el corte del auxiliar solo quita la segunda
cláusula del auxiliar. Con la disyunción no pasa lo mismo: en Prolog, un
corte dentro de `(A ; B)` corta la cláusula que contiene la disyunción;
transformada, corta solo el auxiliar.

```prolog
?- transformado(corte_en_disyuncion, p(X)).
X = 1 ;
X = 3.
```

Prolog responde solo `X = 1`: el corte de `p(X) :- (X = 1, ! ; X = 2)`
descarta también la cláusula `p(3)`.

## 8

`invertir/2` concatena al final en cada llamada, y la concatenación recorre
lo invertido hasta ese momento: los pasos crecen con el cuadrado de `N`.
Con acumulador, cada elemento cuesta lo mismo.

| `N` | `invertir_hasta` | `invertir_acc_hasta` |
|---|---|---|
| 20 | 295 | 86 |
| 40 | 985 | 166 |
| 80 | 3 565 | 326 |

```prolog
?- pasos_de(invertir_hasta(40, _), P).
P = 985.
```

<!-- ejemplo: capitulo-61/soluciones.pl predicado: acumuladores/1 medir_con_acumuladores/2 -->
```prolog
% acumuladores(Cs): invertir/3 y longitud/3 con acumulador.
acumuladores([ (invertir_acc(L, R) :- invertir(L, [], R)),
               (invertir([], R, R) :- true),
               (invertir([X|Xs], R0, R) :- invertir(Xs, [X|R0], R)),
               (invertir_acc_hasta(N, R) :- lista_hasta(N, L),
                                            invertir_acc(L, R)),
               (longitud_acc(L, N) :- longitud(L, 0, N)),
               (longitud([], N, N) :- true),
               (longitud([_|Xs], N0, N) :- N1 is N0 + 1,
                                           longitud(Xs, N1, N)),
               (longitud_acc_hasta(N, K) :- lista_hasta(N, L),
                                            longitud_acc(L, K))
             ]).

%!  medir_con_acumuladores(+Meta, -Medidas:list) is det.
%
%   Medidas son las medidas de Meta en la versión 5, con el programa
%   listas y los predicados con acumulador.
medir_con_acumuladores(Meta, Medidas) :-
    programa(listas, Listas),
    acumuladores(Acumuladores),
    append(Listas, Acumuladores, Clausulas),
    medir_clausulas(indice, Clausulas, Meta, Medidas).
```

## 9

<!-- ejemplo: capitulo-61/soluciones_sin_rastro.pl predicado: llamar/5 volver/3 -->
```prolog
%!  llamar(+Clausulas:list, +Meta, +Metas:list, +Estado0, -Resultado)
%!      is det.
%
%   Como llamar/5 de almacen.pl; el punto de elección guarda el almacén.
llamar([Clausula|Clausulas], Meta, Metas, Estado0, Resultado) :-
    contar_intento(Estado0, Estado1),
    (   Clausulas == []
    ->  Estado2 = Estado1
    ;   Estado1 = m(Ms, Pila, A, R, L, M),
        Estado2 = m(Ms, [guardado([Meta|Metas], Clausulas, A)|Pila],
                    A, R, L, M)
    ),
    (   usar(Clausula, Meta, Metas, Estado2, Estado)
    ->  Resultado = sigue(Estado)
    ;   Clausulas == []
    ->  Resultado = falla(Estado1)
    ;   llamar(Clausulas, Meta, Metas, Estado1, Resultado)
    ).

%!  volver(+Tabla, +Estado0, -Resultado) is det.
%
%   Como volver/3 de almacen.pl: retoma el almacén guardado en el último
%   punto de elección.
volver(Tabla, Estado0, Resultado) :-
    (   Estado0 = m(_, [], _, _, _, _)
    ->  Resultado = fin(Estado0)
    ;   volver_desde(Tabla, Estado0, Resultado)
    ).
```

```prolog
?- medir(listas, suma_hasta(100, S), M).
M = [respuestas-1, pasos-506, intentos-407, metas-4, elecciones-101, rastro-0, celdas-914].
```

Las respuestas y las medidas son las de la versión 3, salvo el rastro, que
queda vacío: el rastro y la marca dejan de hacer falta. Guardar el almacén
no lo copia: el punto de elección conserva la raíz del árbol de ese
momento, y las ligaduras posteriores crean nodos nuevos sin modificar los
viejos. Una máquina con una memoria que se modifica en su lugar no puede
hacer esto.

## 10

<!-- ejemplo: capitulo-61/soluciones_aritmetica.pl predicado: compilar_llamada/2 codigo//1 paso/5 evaluar/4 -->
```prolog
%!  compilar_llamada(+Llamada0, -Llamada) is det.
%
%   Llamada es '$is'(X, Codigo) si Llamada0 es '$predefinida'(X is E), y
%   Llamada0 si no.
compilar_llamada(Llamada0, Llamada) :-
    (   Llamada0 = '$predefinida'(X is E)
    ->  codigo(E, Codigo),
        Llamada = '$is'(X, Codigo)
    ;   Llamada = Llamada0
    ).

%!  codigo(+Expresion)// is det.
%
%   Las instrucciones de la Expresion, con los operandos antes de la
%   operación.
codigo(Expresion) -->
    (   { Expresion = '$v'(_) }
    ->  [celda(Expresion)]
    ;   { number(Expresion) }
    ->  [numero(Expresion)]
    ;   { compound_name_arguments(Expresion, F, [A, B]),
          memberchk(F, [+, -, *, //, mod])
        }
    ->  codigo(A),
        codigo(B),
        [op(F)]
    ;   { type_error(evaluable, Expresion) }
    ).

%!  paso(+Meta, +Metas:list, +Tabla, +Estado0, -Resultado) is det.
%
%   Ejecuta '$is'(X, Codigo); las demás metas, con el paso de
%   compilado.pl.
paso(Meta, Metas, Tabla, Estado0, Resultado) :-
    (   Meta = '$is'(X, Codigo)
    ->  Estado0 = m(_, Pila, A0, R0, L, M),
        foldl(evaluar(A0), Codigo, [], [Valor]),
        marca(Pila, Marca),
        (   unificar(X, Valor, Marca, A0-R0, A-R)
        ->  Resultado = sigue(m(Metas, Pila, A, R, L, M))
        ;   Resultado = falla(Estado0)
        )
    ;   compilado:paso(Meta, Metas, Tabla, Estado0, Resultado)
    ).

%!  evaluar(+Almacen, +Instruccion, +Pila0:list, -Pila:list) is det.
%
%   Ejecuta una Instruccion de la máquina de pila. Una celda libre produce
%   un error de instanciación, como en Prolog.
evaluar(_, numero(N), Pila, [N|Pila]).
evaluar(Almacen, celda(C), Pila, [V|Pila]) :-
    desreferenciar(C, Almacen, V),
    (   number(V)
    ->  true
    ;   instantiation_error(V)
    ).
evaluar(_, op(F), [B, A|Pila], [V|Pila]) :-
    operar(F, A, B, V).
```

```prolog
?- codigo('$v'(0) + 2 * '$v'(1), C).
C = [celda('$v'(0)), numero(2), celda('$v'(1)), op(*), op(+)].

?- comparar(listas, suma_hasta(200, _), Compilado, Aritmetica).
Compilado = 179450,
Aritmetica = 190080.
```

La versión con la aritmética compilada da las mismas respuestas, y cuesta
un 6 % más. Las expresiones del programa son chicas, `S0 + X` o `N - 1`:
reconstruirlas es desreferenciar dos celdas y armar un término de tres
nodos, y la máquina de pila hace un trabajo parecido, instrucción por
instrucción, interpretada por Prolog. A eso se suma que el paso de
`aritmetica` examina cada meta antes de delegarla en el de la versión 6.
Compilar gana cuando el trabajo que se deja de hacer en cada ejecución es
grande comparado con el de interpretar las instrucciones, como en las
cabezas de la [sección 61.7](index.md#617-el-programa-compilado); con expresiones de dos
operandos, la reconstrucción ya era barata. La conclusión se mide, no se
supone.

## 11

| Elementos | `longitud_hasta` | `longitud_acc_hasta` |
|---|---|---|
| 50 | 51 | 4 |
| 100 | 101 | 4 |

La resolvente de `longitud/2` guarda un `N is N0 + 1` por cada elemento,
como la pila de SWI-Prolog de la [sección 16.2](../capitulo-16-rendimiento/index.md#162-la-pila-y-la-recursion); con acumulador, la
suma se hace antes de la llamada recursiva, que es la última meta, y la
resolvente no crece.
