# Soluciones del capítulo 71 — Proyecto: grafos Y/O

El código de esta página está en `ejemplos/capitulo-71/soluciones.pl`,
con sus pruebas en `soluciones.plt`. El archivo carga `juego.pl`, que
carga las búsquedas de las versiones 2, 4 y 5 y los problemas del mapa,
las torres de Hanoi y el ta-te-ti, sin modificarlos. Los problemas nuevos
agregan cláusulas a `primitivo/2`, `expansion/4` y `estimacion/3`, que son
multifile. Es `% solo-local`, porque carga otros archivos. Las consultas
usan también `viaje/6`, `mostrar_viaje/3` y `pueblos/2` de `mapa.pl`,
`costo/2` de `arboles.pl`, `mejor/5` de `mejor.pl` y `compartido/4` de
`compartidos.pl`.

## 1

dique está al oeste y jardin al este: `ruta(dique, jardin)` es un nodo O
con un hijo por puente. La estimación de cada cruce es la distancia en
línea recta de dique al puente más la del puente a jardin: 158 por molino,
91 por paso y 66 por barca. La búsqueda empieza por barca, y como dique y
barca, y barca y jardin, están unidos por caminos directos de 33 y 37 km,
el árbol queda resuelto con 70 km; ningún otro cruce puede costar menos,
porque su estimación ya supera 70.

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- expansion(rio(distancia), ruta(dique, jardin), Tipo, Hijos).
Tipo = o,
Hijos = [cruce(dique, molino, jardin)-0, cruce(dique, paso, jardin)-0, cruce(dique, barca, jardin)-0] ;
false.

?- estimacion(rio(distancia), cruce(dique, barca, jardin), H).
H = 66.

?- viaje(mejor(distancia), dique, jardin, Pueblos, Km, Expandidos).
Pueblos = [dique, barca, jardin],
Km = 70,
Expandidos = 4.
```

El `false.` final viene de la segunda cláusula de `expansion/4` del mapa,
la de los cruces, que la consulta también intenta. Las cuatro expansiones
son `ruta(dique, jardin)`, el cruce por barca y sus
dos tramos, cada uno de un solo camino.

## 2

La raíz es el nodo O `ruta(bosque, fuente)`; su hijo elegido es el nodo Y
`cruce(bosque, molino, fuente)`, con arco de costo 0; sus dos hijos son los
nodos O `ruta(bosque, molino)` y `ruta(molino, fuente)`, cada uno resuelto
por un camino directo, de 27 y de 22 km, que lleva a un nodo primitivo
`ruta(molino, molino)` o `ruta(fuente, fuente)`. El costo es 27 + 22 = 49.

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- mostrar_viaje(mejor(distancia), bosque, fuente).
ruta(bosque,fuente)  o
  +0 cruce(bosque,molino,fuente)  y
    +0 ruta(bosque,molino)  o
      +27 ruta(molino,molino)
    +0 ruta(molino,fuente)  o
      +22 ruta(fuente,fuente)
true.
```

## 3

El límite reemplaza a la lista de ancestros: un ciclo agota el límite, y
la búsqueda termina. `resolver_limitado/4` es `nondet`, porque el
backtracking de `member/2` y `maplist/3` recorre los árboles alternativos;
`profundizando/4` prueba límites crecientes y se queda con el primero.

<!-- ejemplo: capitulo-71/soluciones.pl predicado: resolver_limitado/4 limitado/6 arco_limitado/4 profundizando/4 -->
```prolog
%!  resolver_limitado(+Problema, +Nodo, +Limite:integer, -Arbol) is nondet.
%
%   Arbol es un árbol solución de Nodo en el que ningún camino de la raíz a
%   una hoja pasa por más de Limite nodos expandidos. No lleva ancestros:
%   el límite basta para que la búsqueda termine.
resolver_limitado(Problema, Nodo, _, meta(Nodo)) :-
    primitivo(Problema, Nodo).
resolver_limitado(Problema, Nodo, Limite, Arbol) :-
    Limite > 0,
    expansion(Problema, Nodo, Tipo, Hijos),
    L1 is Limite - 1,
    limitado(Tipo, Problema, Nodo, Hijos, L1, Arbol).

%!  limitado(+Tipo, +Problema, +Nodo, +Hijos:list, +Limite:integer,
%!           -Arbol) is nondet.
%
%   Arbol es un árbol solución de Nodo, de Tipo o o y, con los hijos
%   resueltos dentro de Limite.
limitado(o, Problema, Nodo, Hijos, L, o(Nodo, A-C)) :-
    member(Hijo-C, Hijos),
    resolver_limitado(Problema, Hijo, L, A).
limitado(y, Problema, Nodo, Hijos, L, y(Nodo, Arcos)) :-
    maplist(arco_limitado(Problema, L), Hijos, Arcos).

%!  arco_limitado(+Problema, +Limite:integer, +Hijo, -Arco) is nondet.
%
%   Arco es A-C con un árbol A del hijo Hijo-C dentro de Limite.
arco_limitado(Problema, L, Hijo-C, A-C) :-
    resolver_limitado(Problema, Hijo, L, A).

%!  profundizando(+Problema, +Nodo, -Arbol, -Limite:integer) is semidet.
%
%   Arbol es el primer árbol solución de Nodo con el menor Limite posible,
%   hasta 20. Falla si no hay ninguno con ese límite.
profundizando(Problema, Nodo, Arbol, Limite) :-
    between(1, 20, Limite),
    resolver_limitado(Problema, Nodo, Limite, Arbol),
    !.
```

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- profundizando(rio(cero), ruta(alamos, islas), A, L), costo(A, C), pueblos(A, Ps).
A = o(ruta(alamos, islas), y(cruce(alamos, molino, islas), [o(ruta(alamos, molino), o(ruta(bosque, molino), meta(...)-27)-40)-0, o(ruta(molino, islas), o(ruta(..., ...), ... - ...)-22)-0])-0),
L = 4,
C = 131,
Ps = [alamos, bosque, molino, fuente, islas].
```

El límite 4 alcanza para la raíz, el cruce y dos tramos de un camino cada
uno. El árbol es el de menor profundidad cuyo primer puente en el orden
de la lista funciona: cruza en molino y recorre 131 km. No es el de la
versión 2, porque el límite corta el recorrido por el este que aquella
encontraba primero, ni el de menor costo, porque la profundidad cuenta
nodos, no kilómetros.

## 4

En un nodo O, cada árbol de un hijo es un árbol del nodo: se suman. En un
nodo Y, un árbol del nodo elige un árbol de cada hijo: se multiplican.

<!-- ejemplo: capitulo-71/soluciones.pl predicado: contar_arboles/3 contar/4 contar_hijo/4 -->
```prolog
%!  contar_arboles(+Problema, +Nodo, -N:integer) is det.
%
%   N es la cantidad de árboles solución de Nodo que no repiten un nodo en
%   un mismo camino desde la raíz.
contar_arboles(Problema, Nodo, N) :-
    contar(Problema, Nodo, [], N).

%!  contar(+Problema, +Nodo, +Ancestros:list, -N:integer) is det.
%
%   N es la cantidad de árboles solución de Nodo que no pasan por ninguno
%   de Ancestros: la suma de los de sus hijos en un nodo O, y el producto
%   en un nodo Y.
contar(Problema, Nodo, Ancestros, N) :-
    (   memberchk(Nodo, Ancestros)
    ->  N = 0
    ;   primitivo(Problema, Nodo)
    ->  N = 1
    ;   expansion(Problema, Nodo, Tipo, Hijos)
    ->  maplist(contar_hijo(Problema, [Nodo|Ancestros]), Hijos, Ns),
        (   Tipo == o
        ->  sum_list(Ns, N)
        ;   foldl(multiplicar, Ns, 1, N)
        )
    ;   N = 0
    ).

%!  contar_hijo(+Problema, +Ancestros:list, +Hijo, -N:integer) is det.
%
%   N es la cantidad de árboles del hijo Hijo-C.
contar_hijo(Problema, Ancestros, Hijo-_, N) :-
    contar(Problema, Hijo, Ancestros, N).
```

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- contar_arboles(rio(cero), ruta(alamos, paso), N).
N = 177.

?- contar_arboles(rio(cero), ruta(alamos, islas), N).
N = 315323765.
```

De alamos a paso, en una orilla, hay 177 recorridos sin ciclos; de alamos
a islas, cada cruce multiplica los recorridos de un lado por los del
otro, y el total pasa de trescientos millones. La versión 3 no arma cada
uno de esos árboles, porque en cada nodo Y combina solo el mejor de cada
hijo, pero resuelve cada nodo una vez por cada camino sin ciclos desde la
raíz: sus 255 103 expansiones son la cantidad de nodos del árbol
desplegado, que crece con la misma explosión.

## 5

El problema nuevo delega en `rio/1` y solo cambia los costos de los arcos
de los cruces por barca.

<!-- ejemplo: capitulo-71/soluciones.pl predicado: cobrar/3 -->
```prolog
%!  cobrar(+Peaje:number, +Hijo0, -Hijo) is det.
%
%   Hijo es Hijo0 con Peaje sumado al costo del arco si cruza en barca.
cobrar(Peaje, Hijo-C0, Hijo-C) :-
    (   Hijo = cruce(_, barca, _)
    ->  C is C0 + Peaje
    ;   C = C0
    ).
```

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- mejor(peaje(distancia, 36), ruta(dique, jardin), A, Km, _), pueblos(A, Ps).
A = o(ruta(dique, jardin), y(cruce(dique, barca, jardin), [o(ruta(dique, barca), meta(ruta(barca, barca))-33)-0, o(ruta(barca, jardin), meta(ruta(jardin, jardin))-37)-0])-36),
Km = 106,
Ps = [dique, barca, jardin].

?- mejor(peaje(distancia, 37), ruta(dique, jardin), _, Km, _).
Km = 107.
```

Sin peaje, la ruta por barca cuesta 70 km; la mejor sin barca pasa por
ermita, paso y huerta y cuesta 107. Con un peaje de 37 los dos cuestan
107, y la búsqueda elige paso, que está antes en la lista de puentes; con
un peaje mayor, paso es la única ruta óptima. La estimación sigue siendo
admisible, porque el peaje solo aumenta costos.

## 6

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- comparar_doble(Distintos, Exceso, K1, K2).
Distintos = 15,
Exceso = 65,
K1 = 566,
K2 = 434.
```

Con el doble de la distancia, 15 de los 169 pares reciben un recorrido
más largo que el mínimo, en total 65 km de más, y la búsqueda expande 434
nodos en lugar de 566. La estimación exagera: un hijo cuyo F está inflado
queda relegado aunque su costo verdadero sea el menor, y la búsqueda da
por resuelto el nodo O con otro hijo. El óptimo solo está garantizado si
ninguna estimación supera el costo verdadero; una estimación mayor
expande menos a cambio de perder esa garantía.

## 7

Los subárboles repetidos son el mismo término, de modo que el nodo de la
raíz de un subárbol basta como clave: dos apariciones del mismo nodo
tienen el mismo árbol.

<!-- ejemplo: capitulo-71/soluciones.pl predicado: costo_compartido/2 costo_m/4 costo_nodo/4 costo_arco/3 -->
```prolog
%!  costo_compartido(+Arbol, -Costo:number) is det.
%
%   Costo es el costo de Arbol, calculado una sola vez por nodo: sirve para
%   los árboles de compartido/4, en los que un mismo nodo tiene siempre el
%   mismo subárbol.
costo_compartido(Arbol, Costo) :-
    empty_assoc(M0),
    costo_m(Arbol, Costo, M0, _).

%!  costo_m(+Arbol, -Costo:number, +M0, -M) is det.
%
%   Costo es el costo de Arbol; M0 y M asocian cada nodo ya calculado con
%   su costo.
costo_m(Arbol, Costo, M0, M) :-
    raiz(Arbol, Nodo),
    (   get_assoc(Nodo, M0, Costo)
    ->  M = M0
    ;   costo_nodo(Arbol, Costo, M0, M1),
        put_assoc(Nodo, M1, Costo, M)
    ).

%!  costo_nodo(+Arbol, -Costo:number, +M0, -M) is det.
%
%   Costo es el costo de Arbol, con sus hijos calculados por costo_m/4.
costo_nodo(meta(_), 0, M, M).
costo_nodo(o(_, A-C), Costo, M0, M) :-
    costo_m(A, CA, M0, M),
    Costo is C + CA.
costo_nodo(y(_, Arcos), Costo, M0, M) :-
    foldl(costo_arco, Arcos, 0-M0, Costo-M).

%!  costo_arco(+Arco, +S0, -S) is det.
%
%   S0 y S son Suma-Memoria; S suma el costo del arco A-C y el de A.
costo_arco(A-C, S0-M0, S-M) :-
    costo_m(A, CA, M0, M),
    S is S0 + C + CA.
```

`costo/2` hace 14 680 192 inferencias en la torre de 20 discos, una por
cada nodo del árbol desplegado; `costo_compartido/2` hace 3 285, porque
calcula cada uno de los 57 nodos distintos una vez. Los dos dan
1 048 575. En un árbol sin nodos repetidos, como los del mapa, el
resultado es el mismo que el de `costo/2`.

## 8

`mostrar_estrategia/2` busca la estrategia y la escribe con `mostrar/1`:

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- mostrar_estrategia(mejor, [x,o,v, v,x,v, v,v,o]).
mueve(pos([x,o,v,v,x,v,v,v,o],x))  o
  +1 responde(pos([x,o,v,x,x,v,v,v,o],o))  y
    +1 mueve(pos([x,o,o,x,x,v,v,v,o],x))  o
      +1 responde(pos([x,o,o,x,x,x,v,v,o],o))
    +1 mueve(pos([x,o,v,x,x,o,v,v,o],x))  o
      +1 responde(pos([x,o,v,x,x,o,x,v,o],o))
    +1 mueve(pos([x,o,v,x,x,v,o,v,o],x))  o
      +1 responde(pos([x,o,v,x,x,x,o,v,o],o))
    +1 mueve(pos([x,o,v,x,x,v,v,o,o],x))  o
      +1 responde(pos([x,o,v,x,x,x,v,o,o],o))
true.
```

La raíz es el nodo O de la posición inicial, y su único hijo en el árbol
es la jugada de x en 4. El nodo Y
`responde(…)` tiene un hijo por cada respuesta de o: las casillas 3, 6, 7
y 8. Cada hoja es una posición en la que x completó una línea. Hay cuatro
hojas, y cada una es una partida posible contra esta estrategia: las
cuatro respuestas de o, cada una seguida por la jugada ganadora de x.

## 9

<!-- ejemplo: capitulo-71/soluciones.pl predicado: respuestas_a_la_esquina/1 posicion_esquina/2 casilla_esquina/4 -->
```prolog
%!  respuestas_a_la_esquina(-Rs:list) is det.
%
%   Rs tiene un R-Resultado por cada respuesta R de o a x en la casilla 1:
%   Resultado es el tamaño de la menor estrategia ganadora de x, o
%   ninguna.
respuestas_a_la_esquina(Rs) :-
    findall(R-Resultado,
            ( between(2, 9, R),
              posicion_esquina(R, P),
              (   mejor(gana(tateti(3), x), mueve(P), _, C, _)
              ->  Resultado = C
              ;   Resultado = ninguna
              ) ),
            Rs).

%!  posicion_esquina(+R:integer, -P) is det.
%
%   P es la posición con x en 1 y o en R, en la que mueve x.
posicion_esquina(R, pos(T, x)) :-
    length(T, 9),
    foldl(casilla_esquina(R), T, 1, _).

%!  casilla_esquina(+R:integer, -M, +I0:integer, -I:integer) is det.
%
%   M es la marca de la casilla I0: x en 1, o en R y v en las demás.
casilla_esquina(R, M, I0, I) :-
    (   I0 =:= 1
    ->  M = x
    ;   I0 =:= R
    ->  M = o
    ;   M = v
    ),
    I is I0 + 1.
```

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- respuestas_a_la_esquina(Rs).
Rs = [2-21, 3-21, 4-21, 5-ninguna, 6-21, 7-21, 8-21, 9-21].
```

Solo la respuesta en el centro, la casilla 5, evita la derrota de o. Con
cualquier otra, x tiene una estrategia ganadora de 21 jugadas: la menor
en todas tiene el mismo tamaño, como la de la
[sección 71.8](index.md#718-version-6-estrategias-de-juego), que es la
de la respuesta 2.

## 10

`compartido/4` no lleva la lista de ancestros, y en el mapa los caminos
van en los dos sentidos: `ruta(alamos, molino)` pasa por
`ruta(cantera, molino)`, que pasa por `ruta(alamos, molino)` otra vez. La
memoria no ayuda, porque un nodo se registra al terminar su expansión, y
el ciclo la repite antes. La búsqueda no termina:

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- call_with_inference_limit(compartido(rio(cero), ruta(alamos, islas), _, _), 1000000, R).
R = inference_limit_exceeded.
```

Agregar los ancestros la haría terminar, pero la haría incorrecta: el
resultado de `ruta(C, B)` depende de qué pueblos ya están en el camino
desde la raíz, y guardarlo con el nodo como clave lo aplicaría también a
otros caminos. Un nodo que no tuvo solución porque todos sus vecinos eran
ancestros quedaría marcado como imposible para siempre. La memoria es
correcta cuando el resultado de un nodo depende solo del nodo, es decir,
en grafos sin ciclos.

## 11

<!-- ejemplo: capitulo-71/soluciones.pl predicado: medir_esquina/1 -->
```prolog
%!  medir_esquina(-Rs:list) is det.
%
%   Rs tiene un R-[K1, K2, K3] por cada respuesta R de o a x en la casilla
%   1: los nodos que expanden la búsqueda en profundidad, la de
%   subproblemas compartidos y la de mejor primero.
medir_esquina(Rs) :-
    findall(R-Ks,
            ( between(2, 9, R),
              posicion_esquina(R, pos(T, x)),
              findall(K,
                      ( member(B, [profundidad, compartido, mejor]),
                        estrategia(B, T, _, K) ),
                      Ks) ),
            Rs).
```

| Respuesta de o | Profundidad | Compartidos | Mejor primero |
|---|---|---|---|
| 2 | 170 | 102 | 73 |
| 3 | 129 | 91 | 73 |
| 4 | 28 | 24 | 66 |
| 5 (sin estrategia) | 431 | 170 | 362 |
| 6 | 73 | 61 | 85 |
| 7 | 26 | 23 | 68 |
| 8 | 92 | 69 | 85 |
| 9 | 84 | 67 | 80 |

La búsqueda con subproblemas compartidos nunca expande más que la de
profundidad, porque sigue el mismo orden y solo se ahorra las
repeticiones. La de mejor primero expande menos solo con las respuestas
2 y 3, en las que la búsqueda en profundidad se adentra en jugadas que
llevan a estrategias grandes; en las demás, el orden de las casillas lleva
pronto a la búsqueda en profundidad a una estrategia, y la de mejor
primero, que busca la estrategia más pequeña, examina además las
alternativas cuyo costo estimado es menor. Sin estrategia (5), ninguna evita
examinar todas las jugadas de x.

## 12

Cada transformación es un nodo Y con las integrales que deja; la
primitiva se arma recorriendo el árbol, con la regla que corresponde a
cada transformación.

<!-- ejemplo: capitulo-71/soluciones.pl predicado: inmediata/2 transformacion/2 primitiva/2 -->
```prolog
%!  inmediata(+E, -F) is semidet.
%
%   F es una primitiva de E que se escribe sin transformar E.
inmediata(K, K*x) :-
    number(K).
inmediata(x, x^2/2).
inmediata(x^N, x^N1/N1) :-
    number(N),
    N =\= -1,
    N1 is N + 1.
inmediata(sin(x), -cos(x)).
inmediata(cos(x), sin(x)).
inmediata(exp(x), exp(x)).

%!  transformacion(+E, -T) is nondet.
%
%   T es una transformación aplicable a E: separar una suma, sacar un
%   factor constante o distribuir un producto sobre una suma.
transformacion(A+B, suma(A, B)).
transformacion(K*F, factor(K, F)) :-
    number(K).
transformacion(A*(B+C), distribuir(A*B+A*C)).
transformacion((A+B)*C, distribuir(A*C+B*C)).

%!  primitiva(+Arbol, -F) is det.
%
%   F es la primitiva que describe Arbol, un árbol solución de int(E).
primitiva(meta(int(E)), F) :-
    inmediata(E, F).
primitiva(o(int(_), A-_), F) :-
    primitiva(A, F).
primitiva(y(suma(_, _), [A-_, B-_]), FA + FB) :-
    primitiva(A, FA),
    primitiva(B, FB).
primitiva(y(factor(K, _), [A-_]), K * F) :-
    primitiva(A, F).
primitiva(y(distribuir(_), [A-_]), F) :-
    primitiva(A, F).
```

<!-- contexto: capitulo-71/soluciones.pl -->
```prolog
?- mejor(integral, int(3*x^2 + 2*(sin(x) + cos(x))), A, C, K), primitiva(A, F).
A = o(int(3*x^2+2*(sin(x)+cos(x))), y(suma(3*x^2, 2*(sin(x)+cos(x))), [o(int(3*x^2), y(factor(3, ... ^ ...), [... - ...])-1)-0, o(int(2*(... + ...)), y(factor(..., ...), [...])-1)-0])-1),
C = 4,
K = 10,
F = 3*(x^3/3)+2*(-cos(x)+sin(x)).
```

El árbol aplica cuatro transformaciones: separar la suma, sacar el 3,
sacar el 2 y separar `sin(x) + cos(x)`. `2*(sin(x)+cos(x))` también se
podía distribuir, y la búsqueda mejor primero prefiere el árbol de menos
transformaciones. La primitiva no está simplificada: `3*(x^3/3)` es `x^3`,
y el simplificador del
[capítulo 32](../capitulo-32-inspeccion-de-terminos/index.md#327-un-simplificador-de-expresiones) la
reduciría. Una integral que ninguna transformación reduce a inmediatas,
como la de `x*sin(x)`, que requiere integración por partes, no tiene
solución en este grafo.

## 13

<!-- contexto: capitulo-71/ascendente.pl -->
```prolog
?- ascendente(rio(cero), ruta(bosque, jardin), C, R).
C = 105,
R = 55.

?- findall(N-R, (between(1, 6, N), ascendente(hanoi, torre(N, a, c), _, R)), L).
L = [1-4, 2-9, 3-14, 4-18, 5-21, 6-24].
```

En las torres, el método resuelve todos los nodos que se alcanzan desde
`torre(N, a, c)`, porque la raíz es el nodo de mayor costo y sale del
montón al final. Esos nodos son los seis movimientos `mover(X, Y)` posibles
y los problemas `torre(K, X, Y)` que aparecen en la reducción. En cada
nivel K hay a lo sumo tres: la reducción alterna entre los tres pares de
postes que giran en un sentido y los tres que giran en el otro. Con seis
discos, los niveles 0 a 4 tienen tres problemas cada uno, el nivel 5 tiene
dos y el 6 uno: 18 problemas y 6 movimientos, 24 nodos. Cada disco más
agrega un nivel completo de tres; con menos de cuatro discos los niveles
superiores todavía no están completos y el aumento es mayor.
