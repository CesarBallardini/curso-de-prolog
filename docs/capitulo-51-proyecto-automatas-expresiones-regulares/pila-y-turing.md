# Autómatas de pila y máquinas de Turing

Esta página contiene la
[sección 51.8](index.md#518-automatas-de-pila-y-maquinas-de-turing) del
[capítulo 51](index.md): un intérprete de autómatas de pila y uno de
máquinas de Turing, los dos modelos que siguen al autómata finito en la
jerarquía de los lenguajes. Los ejemplos están en `maquinas.pl`, en
`ejemplos/capitulo-51/`, con sus pruebas; el archivo no es un módulo, no
depende de los anteriores, y corre en SWISH. Los intérpretes siguen los de
Hein (*Prolog Experiments*, capítulo «Computability», apartados
«Pushdown Automata» y «Turing Machines»), con otra representación y otros
ejemplos.

## Autómatas de pila

Un autómata finito tiene una memoria acotada: sus estados. Para reconocer
las sucesiones de paréntesis bien anidadas hay que recordar cuántos quedan
abiertos, sin cota, y ningún autómata finito lo hace. Un **autómata de
pila** agrega una pila de símbolos. Cada transición mira el estado, el
símbolo de entrada —o ninguno, en una transición ε— y el símbolo del tope de
la pila, y reemplaza ese tope por una lista de símbolos:
`pila(M, Q, Lee, X, Apila, Q1)`, con `Lee` igual a `[S]` o `[]`. Apilar es
reemplazar X por `[Y, X]`; desapilar, por `[]`; dejar la pila como está,
por `[X]`. La pila empieza con un símbolo de fondo, `fondo(M, Z)`, y el
autómata acepta si, leída toda la palabra, está en un estado final.

<!-- ejemplo: capitulo-51/maquinas.pl predicado: acepta_pila/2 configuracion/4 -->
```prolog
%!  acepta_pila(+M, ?W:list) is nondet.
%
%   El autómata de pila M acepta W. Da una respuesta por cada cómputo que
%   acepta. No termina si M puede apilar sin fin con transiciones ε.
acepta_pila(M, W) :-
    inicial(M, Q0),
    fondo(M, Z),
    configuracion(M, Q0, W, [Z]).

%!  configuracion(+M, +Q, ?W:list, +Pila:list) is nondet.
%
%   Desde el estado Q con la Pila, M lee W y llega a un estado final.
configuracion(M, Q, [], _Pila) :-
    final(M, Q).
configuracion(M, Q, W, [X|Pila]) :-
    pila(M, Q, Lee, X, Apila, Q1),
    append(Lee, W1, W),
    append(Apila, Pila, Pila1),
    configuracion(M, Q1, W1, Pila1).
```

El intérprete lleva la **configuración**: el estado, lo que falta leer y
la pila, como una lista con el tope primero. `parentesis` apila una p por
cada paréntesis que abre y la desapila con el que la cierra; cuando en el
tope queda el fondo, puede pasar al estado final:

<!-- ejemplo: capitulo-51/maquinas.pl fragmento: pila(parentesis, p, ['('], z, [p, z], p). .. pila(parentesis, p, [], z, [z], fin). -->
```prolog
pila(parentesis, p, ['('], z, [p, z], p).
pila(parentesis, p, ['('], p, [p, p], p).
pila(parentesis, p, [')'], p, [], p).
pila(parentesis, p, [], z, [z], fin).
```

```prolog
?- string_chars("(())()", W), acepta_pila(parentesis, W).
W = ['(', '(', ')', ')', '(', ')'] ;
false.

?- string_chars("())", W), acepta_pila(parentesis, W).
false.
```

Los palíndromos de longitud par necesitan algo más que una pila: el
autómata tiene que saber dónde está la mitad de la palabra, y al leerla no
lo sabe. `palindromo` apila la primera mitad y, en cualquier momento, pasa
con una transición ε al estado en el que desapila comparando: **elige** la
mitad. El no determinismo se resuelve como en los autómatas finitos, por
retroceso; a diferencia de ellos, aquí no se puede eliminar, porque ningún
autómata de pila determinista reconoce ese lenguaje.

<!-- ejemplo: capitulo-51/maquinas.pl fragmento: pila(palindromo, q0, [S], X, [S, X], q0) :- .. pila(palindromo, q1, [], z, [z], fin). -->
```prolog
pila(palindromo, q0, [S], X, [S, X], q0) :-
    member(S, [a, b]),
    member(X, [z, a, b]).
pila(palindromo, q0, [], X, [X], q1) :-
    member(X, [z, a, b]).
pila(palindromo, q1, [S], S, [], q1) :-
    member(S, [a, b]).
pila(palindromo, q1, [], z, [z], fin).
```

```prolog
?- acepta_pila(palindromo, [a, b, b, a]).
true ;
false.

?- length(W, 4), acepta_pila(palindromo, W).
W = [a, a, a, a] ;
W = [a, b, b, a] ;
W = [b, a, a, b] ;
W = [b, b, b, b] ;
false.
```

Las reglas usan `member/2` para escribir una transición por cada símbolo
de entrada y cada tope, en lugar de seis hechos. El intérprete termina
porque ninguna transición ε de estos autómatas apila: una que apilara sin
leer podría repetirse sin fin, y la tabulación no ayuda, porque las
configuraciones posibles son infinitas. La pila de un autómata así es la
misma que usa Prolog al ejecutar una gramática del
[capítulo 21](../capitulo-21-gramaticas-dcg/index.md): una regla que se
llama a sí misma entre dos terminales, como `s --> "(", s, ")", s.`,
reconoce los paréntesis anidados con la pila de llamadas.

!!! question "Actividad"
    Predecir cuántas respuestas da `acepta_pila(palindromo, [a, a, a, a])`
    —cuántos cómputos lo aceptan— y cuántas da
    `acepta_pila(palindromo, [a, b, a, b])`. Comprobarlo con
    `aggregate_all(count, …, N)` y explicar el primer número.

## Máquinas de Turing

Un autómata de pila reconoce aⁿbⁿ, pero no aⁿbⁿcⁿ: la pila compara la
cantidad de a con la de b y, al hacerlo, la pierde. Una **máquina de
Turing** reemplaza la pila por una cinta infinita en los dos sentidos, con
un cabezal que lee, escribe y se mueve. Una transición
`turing(M, Q, Leido, Escrito, Movimiento, Q1)` se aplica en el estado Q con
el símbolo Leido bajo el cabezal: escribe Escrito, mueve el cabezal una
celda a la izquierda o a la derecha, y pasa a Q1. La máquina se detiene
cuando no hay transición, y acepta si se detiene en un estado final. Los
estados son átomos y δ es un conjunto de hechos, como en los autómatas
finitos.

`abc` reconoce aⁿbⁿcⁿ marcando: cambia una a por x, la primera b por y y la
primera c por z, vuelve a la izquierda hasta la x y repite; cuando no quedan
a, verifica que solo quedan y y z:

<!-- ejemplo: capitulo-51/maquinas.pl fragmento: turing(abc, q0, a, x, der, q1). .. turing(abc, q4, blanco, blanco, der, acepta). -->
```prolog
turing(abc, q0, a, x, der, q1).
turing(abc, q0, y, y, der, q4).
turing(abc, q0, blanco, blanco, der, acepta).
turing(abc, q1, a, a, der, q1).
turing(abc, q1, y, y, der, q1).
turing(abc, q1, b, y, der, q2).
turing(abc, q2, b, b, der, q2).
turing(abc, q2, z, z, der, q2).
turing(abc, q2, c, z, izq, q3).
turing(abc, q3, S, S, izq, q3) :-
    member(S, [a, b, y, z]).
turing(abc, q3, x, x, der, q0).
turing(abc, q4, S, S, der, q4) :-
    member(S, [y, z]).
turing(abc, q4, blanco, blanco, der, acepta).
```

La cinta es `c(Izquierda, Actual, Derecha)`: el símbolo bajo el cabezal, lo
que está a su derecha en orden, y lo que está a su izquierda al revés, de
modo que mover el cabezal es pasar un símbolo de una lista a la otra. Más
allá de los extremos hay celdas en blanco, que se crean al llegar a ellas:

<!-- ejemplo: capitulo-51/maquinas.pl predicado: mover_cabezal/4 izquierda/3 derecha/3 -->
```prolog
%!  mover_cabezal(+Mov, +E, +Cinta0, -Cinta) is det.
%
%   Cinta es Cinta0 con E escrito bajo el cabezal y el cabezal movido una
%   celda en el sentido Mov. Más allá del último símbolo hay un blanco.
mover_cabezal(izq, E, c(I, _, D), Cinta) :-
    izquierda(I, [E|D], Cinta).
mover_cabezal(der, E, c(I, _, D), Cinta) :-
    derecha(D, [E|I], Cinta).

%!  izquierda(+I:list, +D:list, -Cinta) is det.
%
%   Cinta tiene bajo el cabezal el último símbolo de la parte izquierda
%   I, o un blanco si I está vacía, y D a la derecha.
izquierda([], D, c([], blanco, D)).
izquierda([S|I], D, c(I, S, D)).

%!  derecha(+D:list, +I:list, -Cinta) is det.
%
%   Cinta tiene bajo el cabezal el primer símbolo de la parte derecha D,
%   o un blanco si D está vacía, e I a la izquierda.
derecha([], I, c(I, blanco, [])).
derecha([S|D], I, c(I, S, D)).
```

Una máquina de Turing puede no detenerse, y ninguna prueba decide de
antemano si lo hará: es el problema de la detención. `turing/4` recibe por
eso un límite de pasos, y distingue tres resultados: acepta, rechaza, o no
se detuvo dentro del límite.

<!-- ejemplo: capitulo-51/maquinas.pl predicado: turing/4 ejecutar/5 -->
```prolog
%!  turing(+M, +Entrada:list, +Limite:integer, -R) is det.
%
%   R es el resultado de ejecutar la máquina de Turing M con la Entrada
%   en la cinta y el cabezal en su primer símbolo, con a lo sumo Limite
%   pasos: acepta(Cinta) o rechaza(Cinta) si se detiene, en un estado
%   final o en otro, y limite(Q, Cinta) si no se detuvo. Cinta es el
%   contenido de la cinta, sin los blancos de los extremos.
turing(M, Entrada, Limite, R) :-
    inicial(M, Q0),
    (   Entrada = [S|Derecha]
    ->  true
    ;   S = blanco,
        Derecha = []
    ),
    ejecutar(M, Q0, c([], S, Derecha), Limite, R).

%!  ejecutar(+M, +Q, +Cinta, +Limite:integer, -R) is det.
%
%   R es el resultado de continuar desde el estado Q con la Cinta, con
%   a lo sumo Limite pasos más.
ejecutar(M, Q, Cinta, Limite, R) :-
    Cinta = c(_, S, _),
    (   turing(M, Q, S, E, Mov, Q1)
    ->  (   Limite =:= 0
        ->  contenido(Cinta, Contenido),
            R = limite(Q, Contenido)
        ;   mover_cabezal(Mov, E, Cinta, Cinta1),
            Limite1 is Limite - 1,
            ejecutar(M, Q1, Cinta1, Limite1, R)
        )
    ;   contenido(Cinta, Contenido),
        (   final(M, Q)
        ->  R = acepta(Contenido)
        ;   R = rechaza(Contenido)
        )
    ).
```

```prolog
?- turing(abc, [a, a, b, b, c, c], 1000, R).
R = acepta([x, x, y, y, z, z]).

?- turing(abc, [a, a, b, c, c], 1000, R).
R = rechaza([x, x, y, z, c]).

?- turing(abc, [a, a, a, b, b, b, c, c, c], 5, R).
R = limite(q2, [x, a, a, y, b, b, c, c|...]).
```

La segunda palabra se rechaza en el estado q1: después de marcar la
segunda a, la máquina busca una b a la derecha y encuentra una z, para la
que no tiene transición. La cinta queda con las marcas que alcanzó a
escribir. La tercera no llegó a
decidirse en cinco pasos. A diferencia de los intérpretes anteriores, este
es determinista y no deja alternativas: la máquina es una función de su
configuración, y el intérprete la sigue con `->`.

Con los cuatro intérpretes del capítulo quedan los cuatro niveles de la
jerarquía: los autómatas finitos reconocen los lenguajes regulares, los
autómatas de pila no deterministas los independientes del contexto —los
de las gramáticas del [capítulo 21](../capitulo-21-gramaticas-dcg/index.md)—,
y las máquinas de Turing, todo lo que se puede reconocer con un
procedimiento efectivo; aⁿbⁿ separa los dos primeros niveles, y aⁿbⁿcⁿ, los
dos siguientes.
