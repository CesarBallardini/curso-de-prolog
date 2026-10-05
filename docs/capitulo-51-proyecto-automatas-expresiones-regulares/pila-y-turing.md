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

## Aceptación por pila vacía

Un autómata de pila tiene una segunda manera de aceptar: por **pila
vacía**. Acepta W si, leída toda la palabra, la pila quedó vacía, en el
estado que sea; los estados finales no intervienen. Hein lo propone como
experimento en el apartado «Pushdown Automata», con un autómata para
aⁿbⁿ. `cintas.pl`, en el mismo directorio, carga `maquinas.pl` y agrega el
intérprete: solo cambia el caso base, que ahora pide la pila vacía en lugar
de un estado final.

<!-- ejemplo: capitulo-51/cintas.pl predicado: acepta_vacia/2 vaciar/4 -->
```prolog
%!  acepta_vacia(+M, ?W:list) is nondet.
%
%   El autómata de pila M acepta W por pila vacía: una respuesta por cada
%   cómputo que lee W y vacía la pila.
acepta_vacia(M, W) :-
    inicial(M, Q0),
    fondo(M, Z),
    vaciar(M, Q0, W, [Z]).

%!  vaciar(+M, +Q, ?W:list, +Pila:list) is nondet.
%
%   Desde el estado Q con la Pila, M lee W y termina con la pila vacía.
vaciar(_M, _Q, [], []).
vaciar(M, Q, W, [X|Pila]) :-
    pila(M, Q, Lee, X, Apila, Q1),
    append(Lee, W1, W),
    append(Apila, Pila, Pila1),
    vaciar(M, Q1, W1, Pila1).
```

`anbn` apila una a por cada a, desapila una por cada b y, sin leer, quita
el fondo, lo que solo puede hacer cuando ya no quedan a apiladas:

<!-- ejemplo: capitulo-51/cintas.pl fragmento: inicial(anbn, q0). .. member(Q, [q0, q1]). -->
```prolog
inicial(anbn, q0).
fondo(anbn, z).
pila(anbn, q0, [a], X, [a, X], q0) :-
    member(X, [z, a]).
pila(anbn, q0, [b], a, [], q1).
pila(anbn, q1, [b], a, [], q1).
pila(anbn, Q, [], z, [], Q) :-
    member(Q, [q0, q1]).
```

```prolog
?- acepta_vacia(anbn, [a, a, b, b]).
true ;
false.

?- length(W, 4), acepta_vacia(anbn, W).
W = [a, a, b, b] ;
false.
```

Las dos maneras de aceptar reconocen los mismos lenguajes. De estado final
a pila vacía, la construcción es otro nombre de autómata, como `det(M)`:
`vacia(M)` hace lo mismo que M y, en un estado final de M, puede pasar sin
leer al estado `vaciar`, que desapila todo. La construcción supone que M
nunca desapila el fondo, como ocurre con los autómatas de este capítulo;
si pudiera hacerlo, vaciaría la pila en un estado no final y aceptaría una
palabra que M rechaza.

<!-- ejemplo: capitulo-51/cintas.pl fragmento: inicial(vacia(M), Q0) :- .. pila(vacia(_), vaciar, [], _X, [], vaciar). -->
```prolog
inicial(vacia(M), Q0) :-
    inicial(M, Q0).
fondo(vacia(M), Z) :-
    fondo(M, Z).
pila(vacia(M), Q, Lee, X, Apila, Q1) :-
    pila(M, Q, Lee, X, Apila, Q1).
pila(vacia(M), Q, [], _X, [], vaciar) :-
    final(M, Q).
pila(vacia(_), vaciar, [], _X, [], vaciar).
```

```prolog
?- acepta_pila(parentesis, ['(', ')']), acepta_vacia(vacia(parentesis), ['(', ')']).
true ;
false.

?- acepta_vacia(parentesis, ['(', ')']).
false.
```

`parentesis` no acepta nada por pila vacía, porque nunca quita el fondo;
`vacia(parentesis)` acepta lo mismo que `parentesis` por estado final, y
las pruebas lo verifican con todas las palabras de longitud 4 de
`parentesis` y de `palindromo`. La construcción inversa agrega un fondo
nuevo debajo del de M y un estado final al que se pasa al verlo aparecer:
la pila de M quedó vacía.

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

## Máquinas de varias cintas

Una máquina de Turing de **varias cintas** tiene un cabezal en cada una.
Una transición lee un símbolo en cada cinta, escribe uno en cada una y
mueve cada cabezal por separado, a la izquierda, a la derecha o a
ninguna parte: `turing_k(M, Q, Leidos, Escritos, Movimientos, Q1)`, con una
lista por cinta en los tres argumentos del medio. La entrada se escribe en
la primera cinta, y las demás empiezan en blanco. Hein propone el
intérprete como experimento del apartado «Turing Machines»; el de
`cintas.pl` reutiliza la representación de la cinta y `mover_cabezal/4` de
la sección anterior, aplicados con `maplist/4` y `maplist/5` a la lista de
cintas:

<!-- ejemplo: capitulo-51/cintas.pl predicado: ejecutar_cintas/5 mover_cinta/4 -->
```prolog
%!  ejecutar_cintas(+M, +Q, +Cintas:list, +Limite:integer, -R) is det.
%
%   R es el resultado de continuar desde el estado Q con las Cintas, con
%   a lo sumo Limite pasos más.
ejecutar_cintas(M, Q, Cintas, Limite, R) :-
    maplist(bajo_cabezal, Cintas, Leidos),
    (   turing_k(M, Q, Leidos, Escritos, Movimientos, Q1)
    ->  (   Limite =:= 0
        ->  maplist(contenido, Cintas, Contenidos),
            R = limite(Q, Contenidos)
        ;   maplist(mover_cinta, Movimientos, Escritos, Cintas, Cintas1),
            Limite1 is Limite - 1,
            ejecutar_cintas(M, Q1, Cintas1, Limite1, R)
        )
    ;   maplist(contenido, Cintas, Contenidos),
        (   final(M, Q)
        ->  R = acepta(Contenidos)
        ;   R = rechaza(Contenidos)
        )
    ).

%!  mover_cinta(+Mov, +E, +Cinta0, -Cinta) is det.
%
%   Cinta es Cinta0 con E escrito bajo el cabezal y el cabezal movido
%   según Mov: izq, der o quieto.
mover_cinta(quieto, E, c(I, _, D), c(I, E, D)) :-
    !.
mover_cinta(Mov, E, Cinta0, Cinta) :-
    mover_cabezal(Mov, E, Cinta0, Cinta).
```

`palindromo_2c` reconoce los palíndromos sobre {a, b} con dos cintas:
copia la entrada en la segunda mientras avanza por la primera, vuelve con
el primer cabezal al comienzo y compara la primera cinta, hacia la
derecha, con la segunda, hacia la izquierda: leída desde el final, la
copia es la palabra al revés.

<!-- ejemplo: capitulo-51/cintas.pl fragmento: turing_k(palindromo_2c, copiar, [S, blanco], [S, S], [der, der], copiar) :- .. [quieto, quieto], acepta). -->
```prolog
turing_k(palindromo_2c, copiar, [S, blanco], [S, S], [der, der], copiar) :-
    member(S, [a, b]).
turing_k(palindromo_2c, copiar, [blanco, blanco], [blanco, blanco],
         [izq, izq], volver).
turing_k(palindromo_2c, volver, [S, T], [S, T], [izq, quieto], volver) :-
    member(S, [a, b]),
    member(T, [a, b, blanco]).
turing_k(palindromo_2c, volver, [blanco, T], [blanco, T], [der, quieto],
         comparar) :-
    member(T, [a, b, blanco]).
turing_k(palindromo_2c, comparar, [S, S], [S, S], [der, izq], comparar) :-
    member(S, [a, b]).
turing_k(palindromo_2c, comparar, [blanco, blanco], [blanco, blanco],
         [quieto, quieto], acepta).
```

```prolog
?- turing_cintas(palindromo_2c, [a, b, b, a], 100, R).
R = acepta([[a, b, b, a], [a, b, b, a]]).

?- turing_cintas(palindromo_2c, [a, b, a, b], 100, R).
R = rechaza([[a, b, a, b], [a, b, a, b]]).

?- findall(N-P, (member(N, [4, 8, 16, 32]), length(W, N), maplist(=(a), W), pasos_cintas(palindromo_2c, W, P)), Ps).
Ps = [4-15, 8-27, 16-51, 32-99].
```

Con n símbolos, la máquina hace 3n + 3 pasos: n para copiar, n para volver
y n para comparar, más los de los extremos. Una máquina de una sola cinta
que reconoce el mismo lenguaje tiene que ir y volver de un extremo al otro
por cada par de símbolos que compara; el
[ejercicio 11](index.md#ejercicios) la escribe, y el
[ejercicio 15](index.md#ejercicios) compara las dos. Las cintas adicionales
cambian la cantidad de pasos, pero no lo que se puede reconocer: una
máquina de una cinta simula k cintas escribiendo en cada celda una tupla de
k símbolos con la marca de dónde está cada cabezal, y cada paso de la
máquina simulada le cuesta un recorrido de la parte escrita de la cinta.
Hartmanis y Stearns, en el artículo de 1965 que define la complejidad
temporal sobre máquinas de varias cintas, probaron con esa simulación que
lo que k cintas hacen en T(n) pasos, una sola lo hace en a lo sumo T(n)²:
el costo de quitar cintas es, como mucho, elevar al cuadrado el tiempo.

## Algoritmos de Markov y sistemas de Post

Los dos últimos modelos del capítulo «Computability» de Hein no tienen
estados ni cabezal: transforman una palabra reescribiéndola, y tienen el
mismo poder que las máquinas de Turing. `reescritura.pl` los programa
sobre palabras escritas como listas de símbolos; no carga otros archivos, y
corre en SWISH.

Un **algoritmo de Markov** es una lista ordenada de reglas
Izquierda → Derecha, algunas marcadas como finales. En cada paso se toma
la primera regla, en el orden del programa, cuya Izquierda aparece en la
palabra, y se reemplaza su primera aparición, la de más a la izquierda,
por Derecha. Si la regla es final, el algoritmo se detiene; si no, vuelve
a empezar por la primera regla. Si ninguna regla se aplica, se detiene. Una
Izquierda vacía aparece al comienzo de cualquier palabra. Las reglas son
hechos `regla_markov(A, Izquierda, Derecha, Tipo)`, con `Tipo` igual a
`para` o `sigue`, y el orden de los hechos es el orden de las reglas. El
ejemplo de Hein intercambia las a y las b: la última regla pone una marca
`#` al comienzo, las dos primeras la hacen avanzar cambiando la letra que
saltan, y la tercera la borra cuando llega al final.

<!-- ejemplo: capitulo-51/reescritura.pl fragmento: regla_markov(intercambio, [#, a], [b, #], sigue). .. regla_markov(ordenar, [b, a], [a, b], sigue). -->
```prolog
regla_markov(intercambio, [#, a], [b, #], sigue).
regla_markov(intercambio, [#, b], [a, #], sigue).
regla_markov(intercambio, [#], [], para).
regla_markov(intercambio, [], [#], sigue).

% ordenar pone todas las a antes que las b: cada paso intercambia la
% primera b seguida de una a.
regla_markov(ordenar, [b, a], [a, b], sigue).
```

El intérprete lleva, como `turing/4`, un límite de pasos, porque un
algoritmo de Markov tampoco tiene por qué detenerse. La primera regla
aplicable se encuentra con `->`, que corta las demás: el algoritmo es
determinista. `reemplazar/4` encuentra la primera aparición con
`append/3`: el primer `append/3` recorre las divisiones de la palabra de
izquierda a derecha, y el segundo verifica que la Izquierda empieza ahí.

<!-- ejemplo: capitulo-51/reescritura.pl predicado: markov/4 reemplazar/4 -->
```prolog
%!  markov(+A, +W:list, +Limite:integer, -R) is det.
%
%   R es el resultado de aplicar el algoritmo de Markov A a la palabra W,
%   con a lo sumo Limite pasos: fin(W1), con la palabra final, o
%   limite(W1), si se agotaron los pasos.
markov(A, W, Limite, R) :-
    (   regla_markov(A, Izquierda, Derecha, Tipo),
        reemplazar(Izquierda, Derecha, W, W1)
    ->  (   Limite =:= 0
        ->  R = limite(W)
        ;   Tipo == para
        ->  R = fin(W1)
        ;   Limite1 is Limite - 1,
            markov(A, W1, Limite1, R)
        )
    ;   R = fin(W)
    ).

%!  reemplazar(+Izquierda:list, +Derecha:list, +W:list, -W1:list)
%!      is semidet.
%
%   W1 es W con la primera aparición de Izquierda reemplazada por
%   Derecha. Falla si Izquierda no aparece en W.
reemplazar(Izquierda, Derecha, W, W1) :-
    append(Antes, Resto, W),
    append(Izquierda, Despues, Resto),
    !,
    append([Antes, Derecha, Despues], W1).
```

```prolog
?- markov(intercambio, [a, b, b, a], 100, R).
R = fin([b, a, a, b]).

?- markov(ordenar, [b, a, b, a], 100, R).
R = fin([a, a, b, b]).
```

`ordenar`, con una sola regla, pone las a antes que las b: cada paso
intercambia el primer par ba. Hace un paso por cada par de una b y una a
que están desordenados, y por eso necesita n² pasos para n b seguidas de
n a; las pruebas lo verifican para n de 1 a 4.

Un **sistema de Post** reescribe con **producciones** que tienen variables.
Cada lado es una sucesión de segmentos: una palabra fija o una variable,
que representa una palabra cualquiera. La Izquierda tiene que coincidir con
la palabra entera, ligando las variables, y la palabra nueva es la Derecha
con las variables reemplazadas. En `produccion(P, Izquierda, Derecha, Tipo)`
cada lado es una lista de segmentos, y una variable de Prolog es una
variable de la producción. Coincidir es partir la palabra en tantas partes
como segmentos tiene la Izquierda, y eso lo hace `append/3` sin ayuda:

<!-- ejemplo: capitulo-51/reescritura.pl predicado: post/4 coincidir/2 -->
```prolog
%!  post(+P, +W:list, +Limite:integer, -R) is det.
%
%   R es el resultado de aplicar las producciones de Post de P a la
%   palabra W, con a lo sumo Limite pasos: fin(W1) o limite(W1), como en
%   markov/4.
post(P, W, Limite, R) :-
    (   produccion(P, Izquierda, Derecha, Tipo),
        coincidir(Izquierda, W)
    ->  append(Derecha, W1),
        (   Limite =:= 0
        ->  R = limite(W)
        ;   Tipo == para
        ->  R = fin(W1)
        ;   Limite1 is Limite - 1,
            post(P, W1, Limite1, R)
        )
    ;   R = fin(W)
    ).

%!  coincidir(?Segmentos:list, +W:list) is nondet.
%
%   La concatenación de los Segmentos es W: cada variable libre se liga a
%   una parte de W, en todas las maneras posibles.
coincidir([], []).
coincidir([S|Ss], W) :-
    append(S, Resto, W),
    coincidir(Ss, Resto).
```

`coincidir/2` es no determinista: `[X, [b], Y]` coincide con una palabra
de tantas maneras como b tiene. Hein define los sistemas de Post sin orden
entre las producciones, y por lo tanto no deterministas; `post/4` toma,
como un algoritmo de Markov, la primera producción y la primera manera de
coincidir, y Hein señala que todo sistema no determinista se puede
reescribir como uno determinista. `palindromo_p` decide si una palabra es
un palíndromo quitándole la primera y la última letra mientras sean
iguales, y escribe `[s, i]` si llega a una sola letra o a la palabra
vacía:

<!-- ejemplo: capitulo-51/reescritura.pl fragmento: produccion(palindromo_p, [[a], X, [a]], [X], sigue). .. produccion(palindromo_p, [], [[s, i]], para). -->
```prolog
produccion(palindromo_p, [[a], X, [a]], [X], sigue).
produccion(palindromo_p, [[b], X, [b]], [X], sigue).
produccion(palindromo_p, [[a]], [[s, i]], para).
produccion(palindromo_p, [[b]], [[s, i]], para).
produccion(palindromo_p, [], [[s, i]], para).
```

```prolog
?- post(palindromo_p, [a, b, b, a], 100, R).
R = fin([s, i]).

?- post(palindromo_p, [a, b, a, b], 100, R).
R = fin([a, b, a, b]).
```

Con [a, b, a, b] ninguna producción se aplica, porque las puntas son
distintas, y el sistema se detiene sin cambiar la palabra. La última
producción tiene la Izquierda vacía, la lista sin segmentos, que solo
coincide con la palabra vacía. Las variables de las producciones son las
mismas variables lógicas de las cláusulas de Prolog, y coincidir una
Izquierda con una palabra es lo que hace la unificación con una lista
parcial: la diferencia es que una variable de Post representa un segmento
de longitud cualquiera, y una variable de Prolog en una lista, un solo
elemento.
