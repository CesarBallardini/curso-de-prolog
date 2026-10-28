# La notación de Bratko y la búsqueda ascendente

Esta página continúa el [capítulo 72](index.md) después de la
[sección 72.8](index.md#728-version-6-estrategias-de-juego), con la
[sección 72.9](#729-la-notacion-de-bratko-y-la-busqueda-ascendente), que
lo termina: tres partes de sus fuentes que las seis versiones no cubren,
la notación con la que Bratko escribe los grafos Y/O, los **puntos
clave** de su formulación de la ruta, y el método **ascendente** de
Martelli y Montanari, que calcula costos desde los problemas primitivos
hacia arriba. Los ejemplos son `bratko.pl` y `ascendente.pl`, en
`ejemplos/capitulo-72/`, con sus pruebas; cargan otros archivos del
capítulo y se ejecutan en una instalación local.

## 72.9 La notación de Bratko y la búsqueda ascendente

`bratko.pl` escribe grafos Y/O con el operador `--->` del libro,
`Nodo ---> or:Hijos`, y los traduce a `expansion/4`, de modo que todas las
búsquedas del capítulo sirven para ellos; el grafo de la figura 13.4 de
Bratko da 9 en profundidad y 8 con la búsqueda mejor primero. El mismo
archivo escribe la ruta con los **puntos clave** de Bratko, una relación
aparte que dice por dónde tiene que pasar toda ruta entre dos pueblos.
`ascendente.pl` programa el método **ascendente** de Martelli y
Montanari, que extiende el algoritmo de Dijkstra: resuelve los nodos desde
los primitivos hacia arriba, en orden de costo, y en las torres de Hanoi
cuenta cada subproblema una sola vez.

### La notación de Bratko

El capítulo describe cada problema con `expansion/4`, que da el tipo del
nodo y sus hijos. Bratko, en el apartado «Basic AND/OR search
procedures», escribe el grafo con un operador: `a ---> or:[b, c]` dice que
a es un nodo O con los hijos b y c, y `b ---> and:[d, e]` que b es un nodo
Y. Con costos en los arcos, cada hijo se escribe `Hijo/Costo`, y los
problemas triviales se declaran aparte. `bratko.pl` escribe así el grafo
de la figura 13.4 del libro:

<!-- ejemplo: capitulo-72/bratko.pl fragmento: % N --- .. trivial(X-X). -->
```prolog
% N ---> T:Hijos: el nodo N es un nodo T, or o and, con los Hijos, cada
% uno escrito Hijo/Costo.
a ---> or:[b/1, c/3].
b ---> and:[d/1, e/1].
c ---> and:[f/2, g/1].
e ---> or:[h/6].
f ---> or:[h/2, i/3].

% trivial(N): el problema N se resuelve sin descomponerlo.
trivial(d).
trivial(g).
trivial(h).
trivial(X-X).
```

Bratko declara `--->` con prioridad 600 y redefine `:` con 500. En
SWI-Prolog `:` ya es un operador de prioridad 600, el de los módulos, y
redefinirlo cambiaría la lectura de todo el programa; `bratko.pl` declara
`--->` con prioridad 700, que admite `T:Hijos` a su derecha. El problema
`bratko(E)` traduce esas cláusulas a `expansion/4`, y con eso todas las
búsquedas del capítulo sirven para ellas:

<!-- ejemplo: capitulo-72/bratko.pl predicado: expansion/4 arco_bratko/2 -->
```prolog
%!  expansion(+Problema, +Nodo, -Tipo, -Hijos:list) is semidet.
%
%   Con Problema igual a bratko(E), Nodo se reduce según --->/2: or es un
%   nodo o, and un nodo y, y cada Hijo/Costo es Hijo-Costo.
expansion(bratko(_), Nodo, Tipo, Hijos) :-
    \+ trivial(Nodo),
    once(Nodo ---> T:Lista),
    tipo_bratko(T, Tipo),
    maplist(arco_bratko, Lista, Hijos).

%!  arco_bratko(+HijoCosto, -Arco) is det.
%
%   Arco es Hijo-Costo para HijoCosto igual a Hijo/Costo.
arco_bratko(Hijo/Costo, Hijo-Costo).
```

La figura tiene dos árboles solución, uno por b de costo 9 y otro por c de
costo 8. La búsqueda en profundidad de la
[sección 72.4](index.md#724-version-2-el-arbol-solucion-en-profundidad)
da el primero que encuentra; la búsqueda mejor primero de la
[sección 72.6](index.md#726-version-4-busqueda-mejor-primero), el de menor
costo:

<!-- contexto: capitulo-72/bratko.pl -->
```prolog
?- resolver(bratko(cero), a, A, K), costo(A, C).
A = o(a, y(b, [meta(d)-1, o(e, meta(h)-6)-1])-1),
K = 3,
C = 9.

?- mejor(bratko(cero), a, A, C, K).
A = o(a, y(c, [o(f, meta(h)-2)-2, meta(g)-1])-3),
C = 8,
K = 5.
```

### Los puntos clave

En su apartado «Example of problem-defining relations: route finding»,
Bratko no fija los puentes en el programa: declara una relación de
**puntos clave**, lugares por los que tiene que pasar toda ruta entre dos
ciudades, y escribe dos reglas generales. Si hay puntos clave entre X y Z,
`X-Z` es un nodo O con un hijo `X-Z via Y` por cada uno, y cada uno de
esos es un nodo Y con los tramos `X-Y` e `Y-Z`; si no los hay, `X-Z` sale
por uno de los caminos de X. `bratko.pl` escribe esas reglas sobre el mapa
de `mapa.pl`, con los tres pueblos del río como puntos clave entre dos
pueblos de orillas opuestas:

<!-- ejemplo: capitulo-72/bratko.pl fragmento: %!  clave( .. and:[(X-Y)/0 -->
```prolog
%!  clave(+Problema, -Y) is nondet.
%
%   Y es un punto clave entre X y Z, con Problema igual a X-Z: si X y Z
%   están en orillas opuestas del río, los tres pueblos sobre el río.
clave(X-Z, Y) :-
    separados(X, Z),
    pueblo(Y, rio, _, _).

%!  --->(+Nodo, -Reduccion) is semidet.
%
%   Las reglas de Bratko para la ruta: con puntos clave, un nodo O con un
%   hijo via por cada uno; sin ellos, un nodo O con un hijo por camino;
%   un nodo via es un nodo Y con los dos tramos.
X-Z ---> or:Hijos :-
    findall((X-Z via Y)/0, clave(X-Z, Y), Hijos),
    Hijos \== [],
    !.
X-Z ---> or:Hijos :-
    findall((Y-Z)/D, tramo(X, Y, D), Hijos).
X-Z via Y ---> and:[(X-Y)/0, (Y-Z)/0].
```

El grafo resultante es el mismo que el de `rio(E)`, escrito con otros
nombres, y las búsquedas dan los mismos costos y expanden los mismos
nodos. La diferencia está en dónde vive el conocimiento: en `mapa.pl` los
cruces están en `expansion/4`; aquí, en una relación aparte que se puede
cambiar sin tocar las reglas, por ejemplo para agregar un paso de montaña
que toda ruta entre dos valles tiene que cruzar.

```prolog
?- mejor(bratko(distancia), alamos-islas, _, C, K).
C = 106,
K = 6.

?- expansion(bratko(cero), alamos-islas, T, Hs).
T = o,
Hs = [(alamos-islas via molino)-0, (alamos-islas via paso)-0, (alamos-islas via barca)-0].
```

### La búsqueda ascendente

Martelli y Montanari (1973) proponen dos métodos para buscar el árbol de
costo mínimo en un grafo Y/O sin ciclos: uno descendente, que extiende el
de Nilsson y del que la búsqueda mejor primero del capítulo es pariente, y
uno **ascendente**, que extiende el algoritmo de Dijkstra. El ascendente
no baja desde el problema inicial: sube desde los problemas primitivos.

`ascendente.pl` lo programa así. Primero recorre el grafo desde el nodo
inicial para conocer todos los nodos y, para cada uno, sus padres; por
eso el grafo tiene que ser finito. Después mantiene un montón con costos
provisorios, que empieza con los primitivos en 0. En cada paso saca el
nodo de menor costo provisorio: ese costo es exacto, porque los costos
de los arcos no son negativos. Al resolverse, el nodo avisa a sus padres:
un padre O entra al montón con el costo del arco más el del hijo; un
padre Y descuenta un hijo pendiente, acumula su costo y entra al montón
cuando no le falta ninguno.

<!-- ejemplo: capitulo-72/ascendente.pl predicado: subir/7 avisar/5 avisar_tipo/6 -->
```prolog
%!  subir(+Problema, +Meta, +Padres, +H, +Pendientes, +R0, -R) is semidet.
%
%   R es R0 con el costo exacto de cada nodo que se resuelve, en orden de
%   costo, hasta resolver Meta. Falla si el montón se vacía antes.
subir(Problema, Meta, Padres, H0, P0, R0, R) :-
    get_from_heap(H0, Costo, Nodo, H1),
    (   get_assoc(Nodo, R0, _)
    ->  subir(Problema, Meta, Padres, H1, P0, R0, R)
    ;   put_assoc(Nodo, R0, Costo, R1),
        (   Nodo == Meta
        ->  R = R1
        ;   (   get_assoc(Nodo, Padres, Ps)
            ->  true
            ;   Ps = []
            ),
            foldl(avisar(Costo, R1), Ps, H1-P0, H2-P1),
            subir(Problema, Meta, Padres, H2, P1, R1, R)
        )
    ).

%!  avisar(+Costo:number, +R, +Padre, +S0, -S) is det.
%
%   S0 y S son pares Monton-Pendientes. Un hijo de costo Costo se acaba
%   de resolver: un Padre O entra al montón con ese costo más el del arco;
%   un Padre Y descuenta un hijo, y entra al montón con la suma cuando no
%   le falta ninguno.
avisar(Costo, R, Padre-Tipo-C, S0, S) :-
    (   get_assoc(Padre, R, _)
    ->  S = S0
    ;   avisar_tipo(Tipo, Padre, Costo, C, S0, S)
    ).

%!  avisar_tipo(+Tipo, +Padre, +Costo:number, +C:number, +S0, -S) is det.
%
%   Como avisar/5, para un Padre de Tipo o o y que todavía no está
%   resuelto; C es el costo del arco.
avisar_tipo(o, Padre, Costo, C, H0-P, H-P) :-
    F is Costo + C,
    add_to_heap(H0, F, Padre, H).
avisar_tipo(y, Padre, Costo, C, H0-P0, H-P) :-
    get_assoc(Padre, P0, f(K0, S0)),
    K is K0 - 1,
    S is S0 + Costo + C,
    put_assoc(Padre, P0, f(K, S), P),
    (   K =:= 0
    ->  add_to_heap(H0, S, Padre, H)
    ;   H = H0
    ).
```

Para ir de alamos a islas, el método resuelve 56 de los 67 nodos que se
alcanzan desde `ruta(alamos, islas)`. La búsqueda mejor primero con la
estimación `cero` expande 76 nodos, y con `distancia`, 6: el método
ascendente no usa ninguna estimación, y su ventaja es otra. Cada costo que
calcula es exacto y queda en la memoria, así que un grafo con subproblemas
compartidos, como el de las torres de Hanoi, se resuelve contando cada
subproblema una vez: 66 nodos para veinte discos, donde el árbol tiene más
de un millón de hojas.

<!-- contexto: capitulo-72/ascendente.pl -->
```prolog
?- ascendente(rio(cero), ruta(alamos, islas), C, R).
C = 106,
R = 56.

?- ascendente(hanoi, torre(20, a, c), C, R).
C = 1048575,
R = 66.
```

Una prueba de `ascendente.plt` comprueba que el método da el mismo costo
que la búsqueda mejor primero en los 169 pares de pueblos. El grafo del
mapa tiene ciclos, que el artículo excluye: ir de un pueblo a otro y
volver. Con costos no negativos el método los tolera, como el algoritmo de
Dijkstra, porque un nodo ya resuelto no vuelve a entrar al montón. Lo que
`ascendente.pl` no construye es el árbol: da solo los costos, y para
armar el árbol habría que recordar, en cada nodo O, qué hijo dio su costo.

!!! success "Criterios de calidad"
    | Criterio | En este capítulo |
    |---|---|
    | C1 | cada predicado declara modos y determinación; las búsquedas son `det` hacia adentro, con el resultado `si(Arbol)` o `no`, y `semidet` hacia afuera |
    | C2 | representaciones limpias: el árbol solución, el árbol de búsqueda y el problema son términos con un functor por caso; lo imposible es el átomo `inf`, no un número grande |
    | C4 | `expandir/4` recibe el árbol en su primer argumento y las estimaciones despachan por un predicado auxiliar, de modo que la indexación elige la cláusula y las pruebas no encuentran alternativas pendientes |
    | C6 | las búsquedas no conocen los problemas: el mapa, las torres y el ta-te-ti solo agregan cláusulas a `primitivo/2`, `expansion/4` y `estimacion/3` |
    | C7 | 150 pruebas en catorce archivos; las del mapa y de la versión 4 verifican que la estimación es admisible camino por camino y que las dos estimaciones dan el mismo costo en los 169 pares |

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

13. **(2)** Con `ascendente/4`, calcular el costo de `ruta(bosque, jardin)`
    y la cantidad de nodos resueltos para `torre(N, a, c)` con N de 1 a 6.
    Explicar por qué, a partir de cuatro discos, cada disco más agrega
    tres nodos.

## Resumen

| | |
|---|---|
| **grafo Y/O** | un grafo cuyos nodos son problemas: un nodo O se resuelve con uno de sus hijos, un nodo Y con todos, un nodo primitivo sin descomponerlo |
| **árbol solución** | el nodo inicial, un hijo por nodo O y todos los hijos por nodo Y, hasta nodos primitivos; su costo es la suma de los costos de sus arcos |
| **Prolog como búsqueda Y/O** | las cláusulas de una cabeza son un nodo O, el cuerpo de una cláusula un nodo Y y los hechos nodos primitivos; la búsqueda es en profundidad, sin árbol, sin costos y sin protección contra los ciclos |
| **ancestros** | un nodo que repite a uno de sus ancestros no se expande: una solución que pasara por él contendría un ciclo |
| **búsqueda mejor primero en grafos Y/O** | un árbol de búsqueda con costos estimados que se recalculan desde la punta expandida hacia la raíz; con una estimación admisible, el árbol que encuentra es el de menor costo |
| **puntos clave**, **búsqueda ascendente** | lugares por los que pasa toda ruta, en una relación aparte; resolver los nodos desde los primitivos hacia arriba, en orden de costo, como el algoritmo de Dijkstra |
| **subproblemas compartidos** | el resultado de un nodo ya resuelto se recuerda y se reutiliza sin copiarlo; correcto solo si no depende del camino por el que se llegó al nodo |
| **[Patrón 70](../patrones.md#70-resultado-recordado-sin-copiar)** | resultado recordado, sin copiar |
| **estrategia ganadora** | un árbol solución del juego visto desde un jugador: una jugada en sus posiciones, todas las respuestas en las del rival |
| `primitivo/2`, `expansion/4`, `estimacion/3` | la interfaz de un problema, multifile |
| **operaciones sobre árboles solución** | `arboles.pl` suma los costos de los arcos, lista las hojas y escribe el árbol sangrado, un nodo por línea |
| **búsquedas de las versiones 2 a 5** | en profundidad, exhaustiva, mejor primero y con subproblemas compartidos, cada una en su archivo |
| **resultados de las búsquedas** | `mapa.pl`, `compartidos.pl` y `juego.pl` resumen el recorrido, la cantidad de movimientos o la estrategia, con los nodos expandidos |
| `call_with_inference_limit/3` | ejecuta una meta hasta un número de inferencias, y responde `inference_limit_exceeded` si lo alcanza |
| `call_time/2` | el tiempo y las inferencias que consume un objetivo (en las soluciones) |

## Temas que se retoman

| Tema | Se retoma en |
|---|---|
| La estrategia ganadora de Nim, calculada con la suma de Nim en lugar de buscarla en el grafo Y/O del juego | [capítulo 79](../capitulo-79-proyecto-kalah-mastermind-nim/index.md) |

## Referencias

- Ivan Bratko, *Prolog Programming for Artificial Intelligence*,
  Addison-Wesley, 1986 — capítulo «Problem Reduction and AND/OR Graphs»,
  con las secciones «AND/OR graph representation of problems», «Examples
  of AND/OR representation» (la ruta por un mapa con un río, las torres de
  Hanoi y el juego como grafo Y/O), «Basic AND/OR search procedures» y
  «Best-first AND/OR search». Sin edición en línea de acceso libre. Esta
  página toma la notación `--->` de «Basic AND/OR search procedures», el
  grafo de la figura 13.4 y los puntos clave de «Example of
  problem-defining relations: route finding».
- Alberto Martelli y Ugo Montanari, «Additive AND/OR graphs»,
  *Proceedings of the Third International Joint Conference on Artificial
  Intelligence* (IJCAI), 1973, pp. 1–11.
  [Edición de IJCAI](https://www.ijcai.org/Proceedings/73/Papers/001.pdf).
  Define los grafos Y/O aditivos, árboles Y/O plegados en los que un
  subproblema común se resuelve una sola vez y su costo se cuenta en cada
  aparición, y da dos métodos de búsqueda óptimos para ellos. Esta página
  toma de allí el método ascendente que programa `ascendente.pl`.

El código del capítulo es propio, escrito para el curso: ningún programa
de la fuente se copió. El mapa, la representación de los árboles de
búsqueda con cinco functores, el bucle que baja desde la raíz y
recalcula al volver, la memoria de subproblemas compartidos, la
estrategia del ta-te-ti y las mediciones no tienen equivalente en ella.
