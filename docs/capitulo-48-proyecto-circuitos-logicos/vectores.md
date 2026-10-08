# Los productos como vectores de signos

Esta página contiene la sección
[48.7](index.md#487-los-productos-como-vectores-de-signos) del
[capítulo 48](index.md): la representación de los productos de una suma de
productos como vectores de signos, la absorción y la combinación posición
por posición, y los implicantes primos de una salida. El ejemplo está en
`vectores.pl`, en `ejemplos/capitulo-48/`, con sus pruebas; carga los
módulos `circuitos` y `formulas`, y se ejecuta localmente.

## Los productos como vectores de signos

La suma de productos de la [sección 48.3](index.md#483-que-calcula-un-circuito)
escribe cada producto como una lista de literales, y `simplificar/2` tiene
que buscar en ella un literal y su negación, o un producto contenido en
otro. Clocksin, en el apartado 7.5 de *Clause and Effect*, «Alternative
Representation», observa que cuando las variables son pocas y se conocen de
antemano conviene otra estructura: un signo por variable, en un orden fijo,
`+` si la variable aparece, `-` si aparece negada y `0` si no aparece. Con
las variables a, b y ci, el producto a · ci · ¬b es `[+, -, +]`. Clocksin lo
escribe como un término `p(+, -, +)`; una lista sirve para cualquier
cantidad de variables. `vectores.pl` traduce entre las dos
representaciones:

<!-- ejemplo: capitulo-48/vectores.pl predicado: vector/3 signo/3 producto_de_vector/3 literal_de/4 -->
```prolog
%!  vector(+Nombres:list(atom), +Producto:list, -Signos:list) is det.
%
%   Signos tiene un signo por cada nombre de Nombres: + si el nombre
%   aparece en Producto, - si aparece negado, y 0 si no aparece. Producto
%   no es contradictorio.
vector(Nombres, Producto, Signos) :-
    maplist(signo(Producto), Nombres, Signos).

%!  signo(+Producto:list, +Nombre:atom, -S) is det.
%
%   S es el signo de Nombre en Producto.
signo(Producto, Nombre, S) :-
    (   memberchk(Nombre, Producto)
    ->  S = (+)
    ;   memberchk(~Nombre, Producto)
    ->  S = (-)
    ;   S = 0
    ).

%!  producto_de_vector(+Nombres:list(atom), +Signos:list,
%!                     -Producto:list) is det.
%
%   Producto es la lista de literales del vector Signos, en el orden de
%   Nombres: el nombre si el signo es +, su negación si es -, y nada si
%   es 0.
producto_de_vector([], [], []).
producto_de_vector([N|Ns], [S|Ss], Producto) :-
    literal_de(S, N, Producto, Resto),
    producto_de_vector(Ns, Ss, Resto).

%!  literal_de(+S, +Nombre:atom, -Producto:list, ?Resto:list) is det.
%
%   Producto es Resto precedido por el literal de Nombre con el signo S, o
%   Resto si S es 0.
literal_de(0, _, Resto, Resto).
literal_de(+, N, [N|Resto], Resto).
literal_de(-, N, [~N|Resto], Resto).
```

```prolog
?- vector([a, b, ci], [a, ci, ~b], V).
V = [+, -, +].

?- producto_de_vector([a, b, ci], [-, 0, +], P).
P = [~a, ci].
```

En un vector, un producto contradictorio no se puede escribir: cada variable
tiene un solo signo. La absorción P + P · Q = P se decide posición por
posición: un vector **cubre** a otro si en cada posición tiene `0` o el
mismo signo. Y la ley X · Y + X · ¬Y = X, que en la lista de literales
obliga a buscar el par, en los vectores es la comparación de dos listas que
difieren en una sola posición, con `+` en una y `-` en la otra:

<!-- ejemplo: capitulo-48/vectores.pl predicado: cubre/2 cubre_signo/2 combinar/3 opuestos/2 -->
```prolog
%!  cubre(+V:list, +W:list) is semidet.
%
%   Cada literal del producto V está en el producto W: en una suma, V
%   absorbe a W (P + P·Q = P). En cada posición, el signo de V es 0 o el
%   mismo que el de W.
cubre(V, W) :-
    maplist(cubre_signo, V, W).

%!  cubre_signo(+S, +T) is semidet.
%
%   El signo S cubre al signo T: S es 0, o los dos son iguales.
cubre_signo(0, _).
cubre_signo(+, +).
cubre_signo(-, -).

%!  combinar(+V:list, +W:list, -C:list) is semidet.
%
%   V y W difieren solo en una posición, con + en uno y - en el otro, y C
%   es el vector con 0 en esa posición: X·Y + X·¬Y = X.
combinar([S|Vs], [T|Ws], [C|Cs]) :-
    (   S == T
    ->  C = S,
        combinar(Vs, Ws, Cs)
    ;   opuestos(S, T),
        C = 0,
        Vs == Ws,
        Cs = Vs
    ).

%!  opuestos(?S, ?T) is nondet.
%
%   S y T son los signos de una variable y de su negación.
opuestos(+, -).
opuestos(-, +).
```

Repetir esa combinación es el primer paso del método de Quine y McCluskey.
`unos/3` da un vector por cada fila de la tabla de verdad en la que la
salida vale 1, con `+` para cada entrada en 1 y `-` para cada una en 0;
`implicantes_primos/2` combina los vectores de a dos, se queda con los que
no se combinan con ningún otro, y repite con los combinados hasta que no
quedan pares:

<!-- ejemplo: capitulo-48/vectores.pl predicado: unos/3 signo_de_bit/2 implicantes_primos/2 -->
```prolog
%!  unos(+Circuito, +Salida, -Vectores:list(list)) is semidet.
%
%   Vectores tiene un vector por cada fila de la tabla de verdad de
%   Circuito en la que Salida vale 1: + para una entrada en 1 y - para
%   una en 0, en el orden de las entradas. Falla si Salida no es una
%   salida de Circuito.
unos(Circuito, Salida, Vectores) :-
    circuito(Circuito, _, Salidas),
    nth1(I, Salidas, Salida),
    !,
    tabla_de_verdad(Circuito, Filas),
    findall(V,
            ( member(Es-Ss, Filas),
              nth1(I, Ss, 1),
              maplist(signo_de_bit, Es, V) ),
            Vectores).

%!  signo_de_bit(?Bit, ?S) is nondet.
%
%   S es el signo de una entrada con el valor Bit.
signo_de_bit(1, +).
signo_de_bit(0, -).

%!  implicantes_primos(+Vectores:list(list), -Primos:list(list)) is det.
%
%   Primos son los vectores que se obtienen combinando los de Vectores de
%   a dos, mientras se pueda, y que ya no se combinan con ningún otro: los
%   implicantes primos de la suma, en el orden estándar.
implicantes_primos(Vectores0, Primos) :-
    sort(Vectores0, Vectores),
    findall(C-[V, W],
            ( member(V, Vectores),
              member(W, Vectores),
              V @< W,
              combinar(V, W, C) ),
            Pares),
    (   Pares == []
    ->  Primos = Vectores
    ;   pairs_keys_values(Pares, Combinados, Usados0),
        append(Usados0, Usados1),
        sort(Usados1, Usados),
        ord_subtract(Vectores, Usados, Restantes),
        implicantes_primos(Combinados, Primos1),
        ord_union(Restantes, Primos1, Primos)
    ).
```

```prolog
?- unos(sumador, co, Vs), implicantes_primos(Vs, Ps).
Vs = [[-, +, +], [+, -, +], [+, +, -], [+, +, +]],
Ps = [[0, +, +], [+, 0, +], [+, +, 0]].

?- unos(sumador, s, Vs), implicantes_primos(Vs, Ps).
Vs = [[-, -, +], [-, +, -], [+, -, -], [+, +, +]],
Ps = [[+, +, +], [+, -, -], [-, +, -], [-, -, +]].
```

Los implicantes primos del acarreo son b · ci, a · ci y a · b: el acarreo es
la mayoría de las tres entradas, la forma del circuito `sumador_mayoria` de
la [sección 48.4](index.md#484-verificar-con-libraryclpb). La suma de productos de
`suma_de_productos/2` para la misma salida, `[[a, b], [a, ci, ~b], [b, ci,
~a]]`, es correcta pero no mínima, porque la absorción no reduce un producto
con la ley de la combinación. La salida s no se reduce: en la suma de tres
bits, dos filas en 1 nunca difieren en una sola entrada. Elegir, entre los
implicantes primos, los que hacen falta para cubrir todas las filas es el
segundo paso del método, y lo pide el [ejercicio 12](index.md#ejercicios).

!!! question "Actividad"
    Predecir los implicantes primos de la salida de `xor_nand` y de la
    salida `c` del semisumador, y comprobarlo con `unos/3` e
    `implicantes_primos/2`. Explicar por qué uno de los dos resultados tiene
    un solo vector.
