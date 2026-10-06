# Una colección de estampillas

Esta página contiene la
[sección 81.6](index.md#816-una-coleccion-de-estampillas) del
[capítulo 81](index.md): el álbum de estampillas de Csenki, primero
guardado en la base de datos dinámica y después como un valor que pasan
de una relación a otra. El programa es `estampillas.pl`, en
`ejemplos/capitulo-81/`, con sus pruebas.

## El álbum

Un sello es `sello(Pais, Serie, Anio, Valor)`, y cada hecho `album/1`
guarda una serie: los sellos de un mismo país y una misma serie, en orden
creciente de valor. `album/1` se declara `dynamic`, porque vender y
comprar lo cambian. El álbum es el del ejemplo de Csenki, con los
nombres en castellano:

<!-- ejemplo: capitulo-81/estampillas.pl predicado: album/1 -->
```prolog
% album(Sellos): Sellos es una serie del álbum, en orden de valor.
album([ sello(reino_unido, reina, 1965, 20),
        sello(reino_unido, reina, 1967, 50),
        sello(reino_unido, reina, 1963, 120)
      ]).
album([ sello(reino_unido, poetas, 1978, 19),
        sello(reino_unido, poetas, 1979, 20),
        sello(reino_unido, poetas, 1978, 22),
        sello(reino_unido, poetas, 1977, 40),
        sello(reino_unido, poetas, 1978, 100)
      ]).
album([ sello(alemania, kaiser, 1882, 5),
        sello(alemania, kaiser, 1879, 20),
        sello(alemania, kaiser, 1885, 50)
      ]).
album([ sello(alemania, castillos, 1885, 10),
        sello(alemania, castillos, 1879, 50),
        sello(alemania, castillos, 1885, 60)
      ]).
```

## Versión 1: el álbum en la base de datos

Un **patrón** es un sello con variables, y elige los sellos con los que
unifica. `coleccion/2` devuelve la lista de esos sellos; la plantilla del
`findall/3` es el patrón mismo, que cada sello liga en una solución y que
`findall/3` copia antes de deshacer la ligadura, así que el patrón queda
libre al terminar. `coleccion/3` agrega una condición que se prueba con
el patrón ya ligado:

<!-- ejemplo: capitulo-81/estampillas.pl predicado: coleccion/2 coleccion/3 -->
```prolog
%!  coleccion(?Patron, -Sellos:list) is det.
%
%   Sellos son los sellos del álbum que unifican con Patron, serie por
%   serie y en el orden de cada serie. Patron no queda ligado.
coleccion(Patron, Sellos) :-
    findall(Patron, ( album(Serie), member(Patron, Serie) ), Sellos).

%!  coleccion(?Patron, :Condicion, -Sellos:list) is det.
%
%   Como coleccion/2, pero solo los sellos con los que, ligado Patron,
%   Condicion se cumple.
coleccion(Patron, Condicion, Sellos) :-
    findall(Patron,
            ( album(Serie),
              member(Patron, Serie),
              call(Condicion) ),
            Sellos).
```

```prolog
?- coleccion(sello(_, _, _, 50), Sellos).
Sellos = [sello(reino_unido, reina, 1967, 50), sello(alemania, kaiser, 1885, 50), sello(alemania, castillos, 1879, 50)].

?- coleccion(sello(_, _, Anio, _), between(1875, 1883, Anio), Sellos).
Sellos = [sello(alemania, kaiser, 1882, 5), sello(alemania, kaiser, 1879, 20), sello(alemania, castillos, 1879, 50)].
```

Vender quita del álbum los sellos que unifican con un patrón, en todas
las series; comprar agrega un sello en su serie, en el lugar que le da su
valor, o en una serie nueva. `quitar_todos/3` usa `\+ Patron \= Sello`,
que comprueba que los dos términos unifican sin dejar ligado ninguno,
para que el patrón sirva para el sello siguiente:

<!-- ejemplo: capitulo-81/estampillas.pl predicado: quitar_todos/3 unifica/2 vender/1 vender_de/2 misma_serie/2 insertar/3 en_orden/3 comprar/1 -->
```prolog
%!  quitar_todos(?Patron, +Sellos0:list, -Sellos:list) is det.
%
%   Sellos es Sellos0 sin los sellos que unifican con Patron, en el mismo
%   orden. Patron no queda ligado.
quitar_todos(Patron, Sellos0, Sellos) :-
    exclude(unifica(Patron), Sellos0, Sellos).

%!  unifica(?Patron, ?Sello) is semidet.
%
%   Patron y Sello unifican; ninguno de los dos queda ligado.
unifica(Patron, Sello) :-
    \+ Patron \= Sello.

%!  vender(?Patron) is det.
%
%   Quita del álbum todos los sellos que unifican con Patron, en todas las
%   series; una serie que queda vacía desaparece.
vender(Patron) :-
    findall(Serie, album(Serie), Series),
    maplist(vender_de(Patron), Series).

%!  vender_de(?Patron, +Serie:list) is det.
%
%   Reemplaza en el álbum la serie Serie por la misma serie sin los sellos
%   que unifican con Patron.
vender_de(Patron, Serie) :-
    quitar_todos(Patron, Serie, Resto),
    (   Resto == Serie
    ->  true
    ;   retract(album(Serie)),
        (   Resto == []
        ->  true
        ;   assertz(album(Resto))
        )
    ).

%!  misma_serie(+Sello1, +Sello2) is semidet.
%
%   Los dos sellos son del mismo país y de la misma serie.
misma_serie(sello(Pais, Serie, _, _), sello(Pais, Serie, _, _)).

%!  insertar(+Sello, +Serie0:list, -Serie:list) is semidet.
%
%   Serie es Serie0 con Sello agregado en el lugar que le da su valor.
%   Falla si Sello no es de la misma serie que los sellos de Serie0.
insertar(Sello, Serie0, Serie) :-
    en_orden(Serie0, Sello, Serie).

%!  en_orden(+Serie0:list, +Sello, -Serie:list) is semidet.
%
%   Lo mismo que insertar/3, con la lista primero, para que la indexación
%   distinga la lista vacía de la que no lo es.
en_orden([], Sello, [Sello]).
en_orden([S|Ss], Sello, Serie) :-
    misma_serie(Sello, S),
    Sello = sello(_, _, _, V),
    S = sello(_, _, _, V1),
    (   V =< V1
    ->  Serie = [Sello, S|Ss]
    ;   Serie = [S|Serie1],
        en_orden(Ss, Sello, Serie1)
    ).

%!  comprar(+Sello) is det.
%
%   Agrega Sello al álbum: en su serie, si el álbum ya la tiene, o en una
%   serie nueva.
comprar(Sello) :-
    (   album(Serie),
        Serie = [S|_],
        misma_serie(Sello, S)
    ->  insertar(Sello, Serie, Serie1),
        retract(album(Serie)),
        assertz(album(Serie1))
    ;   assertz(album([Sello]))
    ).
```

```prolog
?- insertar(sello(alemania, castillos, 1890, 30), [sello(alemania, castillos, 1885, 10), sello(alemania, castillos, 1879, 50)], Serie).
Serie = [sello(alemania, castillos, 1885, 10), sello(alemania, castillos, 1890, 30), sello(alemania, castillos, 1879, 50)].

?- insertar(sello(alemania, kaiser, 1890, 30), [sello(alemania, castillos, 1885, 10)], Serie).
false.

?- vender(sello(_, poetas, 1977, _)), coleccion(sello(_, poetas, _, _), Sellos).
Sellos = [sello(reino_unido, poetas, 1978, 19), sello(reino_unido, poetas, 1979, 20), sello(reino_unido, poetas, 1978, 22), sello(reino_unido, poetas, 1978, 100)].
```

El `sell/1` del libro, ejecutado con el mismo pedido, falla: exige que
el patrón traiga el país y la serie, y unifica el patrón con la *primera*
estampilla de cada serie, que en los poetas es de 1978. Solo vende cuando
el primer sello de la serie cumple el patrón, y solo en la primera serie
que lo cumple.

## Versión 2: el álbum como valor

`vender/1` y `comprar/1` mezclan dos cosas: qué álbum resulta de una
operación, y el cambio de la base de datos. La primera se puede escribir
como una relación entre un álbum, una lista de series, y el siguiente; la
base de datos queda reducida a leer el álbum, aplicar la relación y
guardarlo, en un solo lugar:

<!-- ejemplo: capitulo-81/estampillas.pl predicado: album_actual/1 guardar/1 vender/3 comprar/3 operar/1 -->
```prolog
%!  album_actual(-Album:list) is det.
%
%   Album es la lista de las series de la base de datos, en su orden.
album_actual(Album) :-
    findall(Serie, album(Serie), Album).

%!  guardar(+Album:list) is det.
%
%   Reemplaza las series de la base de datos por las de Album.
guardar(Album) :-
    retractall(album(_)),
    forall(member(Serie, Album), assertz(album(Serie))).

%!  vender(?Patron, +Album0:list, -Album:list) is det.
%
%   Album es Album0 sin los sellos que unifican con Patron, sin las
%   series que quedan vacías.
vender(Patron, Album0, Album) :-
    maplist(quitar_todos(Patron), Album0, Album1),
    exclude(==([]), Album1, Album).

%!  comprar(+Sello, +Album0:list, -Album:list) is det.
%
%   Album es Album0 con Sello agregado en su serie, o en una serie nueva
%   al final si Album0 no la tiene.
comprar(Sello, Album0, Album) :-
    (   append(Antes, [Serie|Despues], Album0),
        Serie = [S|_],
        misma_serie(Sello, S)
    ->  insertar(Sello, Serie, Serie1),
        append(Antes, [Serie1|Despues], Album)
    ;   append(Album0, [[Sello]], Album)
    ).

%!  operar(+Operacion) is det.
%
%   Aplica al álbum de la base de datos Operacion, que es vender(Patron)
%   o comprar(Sello), a través de las relaciones de la versión 2.
operar(vender(Patron)) :-
    album_actual(A0),
    vender(Patron, A0, A),
    guardar(A).
operar(comprar(Sello)) :-
    album_actual(A0),
    comprar(Sello, A0, A),
    guardar(A).
```

```prolog
?- vender(sello(_, _, 1885, _), [[sello(a, s, 1885, 1), sello(a, s, 1886, 2)], [sello(b, t, 1885, 3)]], A).
A = [[sello(a, s, 1886, 2)]].

?- comprar(sello(b, t, 1990, 2), [[sello(a, s, 1885, 1)], [sello(b, t, 1885, 3)]], A).
A = [[sello(a, s, 1885, 1)], [sello(b, t, 1990, 2), sello(b, t, 1885, 3)]].
```

Las relaciones de la versión 2 se prueban sin preparar ni restaurar la
base de datos, con álbumes escritos en la prueba; las pruebas de la
versión 1 tienen que guardar el álbum antes y devolverlo después. Las
pruebas de `operar/1` comprueban que la capa da el mismo álbum que la
relación. Es la separación del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#208-cuando-no-usarla):
el estado en la base de datos solo donde hace falta que persista entre
consultas.

!!! example "Patrón 86 — El estado como valor, la base de datos como capa"
    **Problema.** Un programa guarda su estado en la base de datos y lo
    cambia con operaciones, como vender y comprar sellos del álbum; cada
    operación decide a la vez qué estado resulta y qué hechos se quitan
    o se agregan.

    **Versión ingenua.** Operaciones que calculan y modifican la base en
    el mismo paso, como `vender/1`, `vender_de/2` y `comprar/1` de la
    versión 1, con `retract/1` y `assertz/1` en medio del cálculo. Sus
    pruebas tienen que guardar el álbum antes y restaurarlo después.

    **Patrón.** Escribir cada operación como una relación pura entre un
    estado y el siguiente, con el estado como valor: `vender/3` y
    `comprar/3` reciben un álbum, una lista de series, y dan otro. La
    base de datos queda en una capa de un solo predicado, `operar/1`,
    que lee el estado con `album_actual/1`, aplica la relación y lo
    guarda con `guardar/1`. Las relaciones se prueban con álbumes
    escritos en la prueba, y las pruebas de la capa comprueban solo que
    da el mismo álbum que la relación. Es el
    [Patrón 29](../patrones.md#29-nucleo-puro-bordes-impuros) a la
    escala de una operación, y `operar/1` es la interfaz única del
    [Patrón 19](../patrones.md#19-estado-detras-de-una-interfaz).

    **Cuándo no usarlo.** Cuando el estado es grande y cada operación
    cambia una parte pequeña: `guardar/1` reescribe todas las series
    aunque la venta toque una sola, y una lista se recorre donde la base
    de datos indexaría los hechos. Y cuando el estado no tiene que
    persistir entre consultas: entonces no hace falta la capa, y el
    valor pasa de una relación a otra en los argumentos.
