# La notación de Bratko y la búsqueda ascendente

Esta página completa el [capítulo 71](index.md) con tres partes de sus
fuentes que las seis versiones no cubren: la notación con la que Bratko
escribe los grafos Y/O, los **puntos clave** de su formulación de la ruta,
y el método **ascendente** de Martelli y Montanari, que calcula costos
desde los problemas primitivos hacia arriba. Los ejemplos son
`bratko.pl` y `ascendente.pl`, en `ejemplos/capitulo-71/`, con sus
pruebas; cargan otros archivos del capítulo y se ejecutan en una
instalación local.

## La notación de Bratko

El capítulo describe cada problema con `expansion/4`, que da el tipo del
nodo y sus hijos. Bratko, en el apartado «Basic AND/OR search
procedures», escribe el grafo con un operador: `a ---> or:[b, c]` dice que
a es un nodo O con los hijos b y c, y `b ---> and:[d, e]` que b es un nodo
Y. Con costos en los arcos, cada hijo se escribe `Hijo/Costo`, y los
problemas triviales se declaran aparte. `bratko.pl` escribe así el grafo
de la figura 13.4 del libro:

<!-- ejemplo: capitulo-71/bratko.pl fragmento: % N --- .. trivial(X-X). -->
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

<!-- ejemplo: capitulo-71/bratko.pl predicado: expansion/4 arco_bratko/2 -->
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
[sección 71.4](index.md#714-version-2-el-arbol-solucion-en-profundidad)
da el primero que encuentra; la búsqueda mejor primero de la
[sección 71.6](index.md#716-version-4-busqueda-mejor-primero), el de menor
costo:

<!-- contexto: capitulo-71/bratko.pl -->
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

## Los puntos clave

En su apartado «Example of problem-defining relations: route finding»,
Bratko no fija los puentes en el programa: declara una relación de
**puntos clave**, lugares por los que tiene que pasar toda ruta entre dos
ciudades, y escribe dos reglas generales. Si hay puntos clave entre X y Z,
`X-Z` es un nodo O con un hijo `X-Z via Y` por cada uno, y cada uno de
esos es un nodo Y con los tramos `X-Y` e `Y-Z`; si no los hay, `X-Z` sale
por uno de los caminos de X. `bratko.pl` escribe esas reglas sobre el mapa
de `mapa.pl`, con los tres pueblos del río como puntos clave entre dos
pueblos de orillas opuestas:

<!-- ejemplo: capitulo-71/bratko.pl fragmento: %!  clave( .. and:[(X-Y)/0 -->
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

## La búsqueda ascendente

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

<!-- ejemplo: capitulo-71/ascendente.pl predicado: subir/7 avisar/5 avisar_tipo/6 -->
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

<!-- contexto: capitulo-71/ascendente.pl -->
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
