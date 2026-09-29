# Soluciones del capítulo 52 — Proyecto: un intérprete perezoso de reescritura de términos

Las soluciones de los ejercicios 2 a 11 están en
`ejemplos/capitulo-52/soluciones.pl`, que carga el programa terminado
(`numeros.pl`, que vuelve a exportar las versiones anteriores) y agrega
máquinas con cláusulas de `plana:fila/5` y `perezosa:alias/3`. Sus pruebas
están en `soluciones.plt`. Las consultas usan predicados de las versiones:
`resolver/4`, `seleccionar/7` y `sucesion/4`, de `perezosa.pl`; `medir/4`,
de `traza.pl`; `transicion/5`, de `completa.pl`, y `contenido/2`, de
`plana.pl`.

## Ejercicio 1

<!-- ejemplo: capitulo-52/proyecto.pl archivo -->
```prolog
:- use_module(numeros).
```

```prolog
?- resolver(alterna, emite(b, 0), Q, N).
Q = emite(b, 0),
N = 0.

?- seleccionar(ii, p, x, Qr, N, Ops, Q1).
Qr = p,
N = 0,
Ops = [e, r],
Q1 = q.

?- seleccionar(ii, o, blanco, Qr, N, Ops, Q1).
false.

?- transicion(biblioteca, c1(fin), 1, Ops, Q1).
Ops = [],
Q1 = pe(fin, 1).

?- cuantas(i, c, [0, 1], 10, N).
N = 4.
```

- `emite(b, 0)` no es un alias sino una tabla: `resolver/4` la deja como
  está, con cero reescrituras.
- En la configuración p, con x bajo el cabezal, se aplica la fila que
  borra la marca y avanza.
- La configuración o de la máquina II tiene filas para 0 y para 1, y
  ninguna para el blanco: la consulta falla. En una ejecución,
  `ejecutar/5` informaría `detenida(o, Cinta)`.
- `c1(fin)` lee el 1 con la condición `simbolo(Be)` y pasa a `pe(fin, 1)`:
  la configuración siguiente queda sin resolver, y `pe` se reescribe con
  sus alias recién en el paso siguiente. Esa es la reescritura perezosa.
- Desde c se alcanzan las mismas cuatro configuraciones que desde b,
  porque la máquina I es un ciclo.

Todas terminan en `.`: el intérprete elige la fila con `once/1` y no deja
alternativas pendientes.

## Ejercicio 2

<!-- ejemplo: capitulo-52/soluciones.pl fragmento: plana:fila(tres, b, blanco, [p(0), r, r], c). .. plana:fila(tres, d, blanco, [p(1), r, r], b). -->
```prolog
plana:fila(tres, b, blanco, [p(0), r, r], c).
plana:fila(tres, c, blanco, [p(0), r, r], d).
plana:fila(tres, d, blanco, [p(1), r, r], b).
```

```prolog
?- tabla_estandar(tres, b, [0, 1], tabla(Es, _)).
Es = [b, resto([r], c), c, resto([r], d), d, resto([r], b)].
```

Cada fila imprime y mueve dos casillas; la forma estándar admite un solo
movimiento por instrucción, y la segunda R va en una configuración
auxiliar. La tabla estándar tiene seis configuraciones, y el número de
descripción, 178 dígitos. Si cada fila imprimiera y moviera una sola vez,
con una configuración más que avanzara sin imprimir, la tabla ya estaría
en forma estándar: es lo que hace la máquina I de Turing.

## Ejercicio 3

<!-- ejemplo: capitulo-52/soluciones.pl fragmento: plana:fila(ceros_unos, inicio, siempre, [p(schwa), r, p(schwa)], .. perezosa:alias(ceros_unos, unos(s(K), C), pe(unos(K, C), 1)). -->
```prolog
plana:fila(ceros_unos, inicio, siempre, [p(schwa), r, p(schwa)],
           bloque(s(cero))).
perezosa:alias(ceros_unos, bloque(K), ceros(K, unos(K, bloque(s(K))))).
perezosa:alias(ceros_unos, ceros(cero, C), C).
perezosa:alias(ceros_unos, ceros(s(K), C), pe(ceros(K, C), 0)).
perezosa:alias(ceros_unos, unos(cero, C), C).
perezosa:alias(ceros_unos, unos(s(K), C), pe(unos(K, C), 1)).
```

```prolog
?- sucesion(ceros_unos, inicio, 12, S).
S = '010011000111'.

?- cuantas(ceros_unos, inicio, [0, 1, schwa], 500, N).
N = mas_de(500).
```

`bloque(K)` se reescribe en K llamadas a `pe` con 0 y K con 1, y pasa a
`bloque(s(K))`. Como en `contador`, la cuenta está en la configuración, y
las configuraciones alcanzables son infinitas.

## Ejercicio 4

<!-- ejemplo: capitulo-52/soluciones.pl fragmento: perezosa:alias(_, cr(C, B, Al), c(re(C, B, Al, a), B, Al)). .. perezosa:alias(_, cr(B, Al), cr(cr(B, Al), re(B, a, Al), Al)). -->
```prolog
perezosa:alias(_, cr(C, B, Al), c(re(C, B, Al, a), B, Al)).
perezosa:alias(_, cr(B, Al), cr(cr(B, Al), re(B, a, Al), Al)).
```

```prolog
?- cinta_de([schwa, schwa, 1, x, 0, x], 0, C0), ejecutar(biblioteca, cr(fin, x), C0, 10000, detenida(Q, C)), contenido(C, Ss).
C0 = c([], schwa, [schwa, 1, x, 0, x]),
Q = fin,
C = c([blanco, blanco, 0, blanco, 1, x, 0, x|...], blanco, []),
Ss = [schwa, schwa, 1, x, 0, x, 1, blanco, 0].
```

`cr(C, B, Al)` copia la primera figura marcada con Al y cambia su marca
por a, de modo que la próxima búsqueda encuentra la siguiente. Cuando no
quedan, `cr(B, Al)` pasa a `re(B, a, Al)`, que devuelve todas las marcas a
Al. La letra a tiene que ser distinta de Al y no aparecer en la cinta: es
la condición que Turing expresa al decir que cr se toma cuando no hay
letras a en la cinta. El átomo `a` de la regla es esa letra, no un
parámetro.

## Ejercicio 5

<!-- ejemplo: capitulo-52/soluciones.pl predicado: resolver_seguro/4 resolver_seguro/6 -->
```prolog
%!  resolver_seguro(+M, +Q0, -Q, -N:integer) is det.
%
%   Como resolver/4, pero lanza error(ciclo_de_alias(Q1), _) si la
%   reescritura vuelve a una configuración Q1 por la que ya pasó.
resolver_seguro(M, Q0, Q, N) :-
    resolver_seguro(M, Q0, [Q0], Q, 0, N).

%!  resolver_seguro(+M, +Q0, +Vistas:list, -Q, +N0, -N) is det.
%
%   Como resolver_seguro/4, con las configuraciones Vistas y N0
%   reescrituras hechas antes.
resolver_seguro(M, Q0, Vistas, Q, N0, N) :-
    (   alias(M, Q0, Q1)
    ->  (   memberchk(Q1, Vistas)
        ->  throw(error(ciclo_de_alias(Q1), _))
        ;   N1 is N0 + 1,
            resolver_seguro(M, Q1, [Q1|Vistas], Q, N1, N)
        )
    ;   Q = Q0,
        N = N0
    ).
```

<!-- ejemplo: capitulo-52/soluciones.pl fragmento: perezosa:alias(circular, uno, dos(x)). .. perezosa:alias(circular, dos(x), uno). -->
```prolog
perezosa:alias(circular, uno, dos(x)).
perezosa:alias(circular, dos(x), uno).
```

```prolog
?- catch(resolver_seguro(circular, uno, Q, N), E, true).
E = error(ciclo_de_alias(uno), _).
```

La lista de las configuraciones vistas crece con cada reescritura, y
`memberchk/2` compara términos básicos. Un ciclo de alias no es la única
forma de no terminar: un alias que se reescribe en un término cada vez
mayor, como `alias(m, p(X), p(s(X)))`, nunca repite una configuración, y
`resolver_seguro/4` tampoco lo detecta. Para ese caso hace falta un límite
de reescrituras.

## Ejercicio 6

<!-- ejemplo: capitulo-52/soluciones.pl fragmento: :- table alcanzable/4. .. transicion(M, Q1, S, _, Q). -->
```prolog
:- table alcanzable/4.

%!  alcanzable(+M, +Q0, +Alfabeto:list, ?Q) is nondet.
%
%   Q es una configuración a la que M llega desde Q0 con los símbolos
%   del Alfabeto y el blanco. No termina si son infinitas.
alcanzable(_, Q0, _, Q0).
alcanzable(M, Q0, Alfabeto, Q) :-
    alcanzable(M, Q0, Alfabeto, Q1),
    member(S, [blanco|Alfabeto]),
    transicion(M, Q1, S, _, Q).
```

```prolog
?- findall(X, alcanzable(ii, b, [0, 1, schwa, x], X), Xs).
Xs = [o, q, f, b, p].
```

Las configuraciones son las mismas cinco, en otro orden: una tabla guarda
un conjunto de respuestas, y el orden en que las devuelve no es el del
recorrido. Las pruebas comparan las dos listas ordenadas. La recursión por
la izquierda termina porque la tabla no vuelve a buscar una configuración
que ya tiene. Con `contador`, la relación tabulada no termina: la tabla
tendría que completar infinitas respuestas antes de devolver la primera, y
no hay un límite que la corte. `completa/5` sí termina, con
`incompleta(Estados)`, y da además lo que la tabla no da: el orden de
aparición, que el número de descripción necesita, y las instrucciones.

## Ejercicio 7

```prolog
?- cinta_de([schwa, schwa, 1, blanco, 0, blanco, 0], 0, C0), ejecutar(biblioteca, re(fin, 0, 1), C0, 1000, detenida(Q, C)), contenido(C, Ss).
C0 = c([], schwa, [schwa, 1, blanco, 0, blanco, 0]),
Q = fin,
C = c([blanco, blanco, 1, blanco, 1, blanco, 1, schwa|...], blanco, []),
Ss = [schwa, schwa, 1, blanco, 1, blanco, 1].
```

`re(B, Al, Be)` se reescribe en `re(re(B, Al, Be), B, Al, Be)`: reemplazar
la primera Al y volver a empezar, o pasar a B si no hay ninguna. El
término contiene a `re/3`, pero cada vuelta reemplaza un 0 de la cinta, y
cuando no quedan, `f` pasa a B. La reescritura no termina por sí sola; lo
que termina es el cómputo, porque la cinta tiene finitos 0. La
reescritura perezosa construye `re/4` una vez por cada 0.

## Ejercicio 8

<!-- ejemplo: capitulo-52/soluciones.pl predicado: sd_numero/2 instrucciones_sd//1 instruccion_sd//1 cuenta//2 -->
```prolog
%!  sd_numero(?SD:string, ?N:integer) is det.
%
%   N es el número de descripción de la descripción estándar SD. Uno de
%   los dos tiene que llegar instanciado.
sd_numero(SD, N) :-
    (   nonvar(SD)
    ->  string_codes(SD, Letras),
        maplist(letra_digito, Letras, Digitos),
        number_codes(N, Digitos)
    ;   number_codes(N, Digitos),
        maplist(letra_digito, Letras, Digitos),
        string_codes(SD, Letras)
    ).

%!  instrucciones_sd(-Is:list)// is nondet.
%
%   Is son las instrucciones i(I, J, K, Mov, M) de una descripción
%   estándar: las configuraciones y los símbolos son números.
instrucciones_sd([I|Is]) -->
    instruccion_sd(I),
    instrucciones_sd(Is).
instrucciones_sd([]) -->
    [].

%!  instruccion_sd(-I)// is nondet.
%
%   I es una instrucción de la descripción estándar.
instruccion_sd(i(I, J, K, Mov, M)) -->
    "D", cuenta(0'A, I),
    "D", cuenta(0'C, J),
    "D", cuenta(0'C, K),
    mov_sd(Mov),
    "D", cuenta(0'A, M),
    ";".

%!  cuenta(+C, -N:integer)// is nondet.
%
%   N repeticiones del carácter de código C; primero la más larga.
cuenta(C, N) -->
    [C],
    cuenta(C, N0),
    { N is N0 + 1 }.
cuenta(_, 0) -->
    [].
```

```prolog
?- sd_numero(SD, 31332531173113353111731113322531111731111335317).
SD = "DADDCRDAA;DAADDRDAAA;DAAADDCCRDAAAA;DAAAADDRDA;".

?- instrucciones_de("DADDCRDAA;DAADDRDAAA;DAAADDCCRDAAAA;DAAAADDRDA;", Is).
Is = [i(1, 0, 1, r, 2), i(2, 0, 0, r, 3), i(3, 0, 2, r, 4), i(4, 0, 0, r, 1)].
```

`sd_numero/2` usa la misma relación entre letras y dígitos en los dos
sentidos; `maplist/3` la recorre con la lista conocida de uno u otro lado.
La gramática lee cada repetición con `cuenta//2`, que prueba primero la
más larga; la letra D que sigue la obliga a tomar todas. `instrucciones_de/2`
toma la primera lectura con `once/1`. La prueba de ida y vuelta convierte
el número de la máquina II en su descripción y la descripción de nuevo en
el número.

## Ejercicio 9

<!-- ejemplo: capitulo-52/soluciones.pl predicado: instrucciones_de/2 figuras_dn/3 instruccion_estandar/2 simbolo_numero/2 -->
```prolog
%!  instrucciones_de(+SD:string, -Is:list) is semidet.
%
%   Is son las instrucciones de la descripción estándar SD.
instrucciones_de(SD, Is) :-
    string_codes(SD, Codigos),
    once(phrase(instrucciones_sd(Is), Codigos)).

%!  figuras_dn(+DN:integer, +N:integer, -Fs:list) is semidet.
%
%   Fs son las primeras N figuras que imprime la máquina cuyo número de
%   descripción es DN, desde la configuración 1 con la cinta en blanco.
%   El símbolo 0 es el blanco, el 1 es la figura 0, el 2 es la figura 1,
%   y el j, para j mayor que 2, es s(j).
figuras_dn(DN, N, Fs) :-
    sd_numero(SD, DN),
    instrucciones_de(SD, Is0),
    maplist(instruccion_estandar, Is0, Is),
    figuras_estandar(tabla([1], Is), N, Fs).

%!  instruccion_estandar(+I0, -I) is det.
%
%   I es la instrucción numerada I0 con los símbolos del programa.
instruccion_estandar(i(Q, J, K, Mov, Q1), i(Q, S, e(W, Mov), Q1)) :-
    simbolo_numero(S, J),
    simbolo_numero(W, K).

%!  simbolo_numero(-S, +J:integer) is det.
%
%   S es el símbolo número J.
simbolo_numero(S, J) :-
    (   J =:= 0
    ->  S = blanco
    ;   J =:= 1
    ->  S = 0
    ;   J =:= 2
    ->  S = 1
    ;   S = s(J)
    ).
```

```prolog
?- figuras_dn(31332531173113353111731113322531111731111335317, 8, Fs).
Fs = [0, 1, 0, 1, 0, 1, 0, 1].
```

El número se convierte en la descripción, la descripción en instrucciones
numeradas, y cada número de símbolo en un símbolo; `figuras_estandar/3`
de `numeros.pl` ejecuta las instrucciones con las configuraciones 1, 2, …
como nombres. Los símbolos que no son figuras no necesitan su nombre
original: el 3 de la máquina II, que era ə, pasa a ser `s(3)`, y la
máquina se comporta igual. La prueba verifica las primeras 20 figuras de
la máquina II contra `figuras/4`. Es, dentro de Prolog, lo que hace la
máquina universal de la sección 6 del artículo: ejecutar una máquina a
partir de su descripción.

## Ejercicio 10

```prolog
?- cinta_de([schwa, schwa, 1, a, 0, a, 1], 0, C0), ejecutar(biblioteca, e(fin), C0, 1000, detenida(Q, C)), contenido(C, Ss).
C0 = c([], schwa, [schwa, 1, a, 0, a, 1]),
Q = fin,
C = c([blanco, a, blanco, a, blanco, schwa, schwa], blanco, []),
Ss = [schwa, schwa, blanco, a, blanco, a].

?- cinta_de([schwa, schwa, 1, a, 0, a, 1], 0, C0), ejecutar(biblioteca, q(e(fin)), C0, 1000, detenida(Q, C)), contenido(C, Ss).
C0 = c([], schwa, [schwa, 1, a, 0, a, 1]),
Q = fin,
C = c([blanco, 1, blanco, 0, blanco, 1, schwa, schwa], blanco, []),
Ss = [schwa, schwa, 1, blanco, 0, blanco, 1].
```

`e(C)` retrocede hasta encontrar ə y avanza una casilla: supone que el
cabezal está a la derecha de ə ə, y que la primera ə que encuentra es la
segunda. Desde la casilla 0 encuentra la primera, avanza a la casilla 1, y
desde allí borra las casillas pares: las figuras. `q(C)` lleva primero el
cabezal al final de la cinta, y desde allí `e(fin)` hace lo que Turing
describe.

## Ejercicio 11

<!-- ejemplo: capitulo-52/soluciones.pl fragmento: plana:fila(rapido, inicio, siempre, [p(schwa), r, p(schwa), r], bloque(cero)). .. perezosa:alias(rapido, unos(cero, C), C). -->
```prolog
plana:fila(rapido, inicio, siempre, [p(schwa), r, p(schwa), r], bloque(cero)).
plana:fila(rapido, bloque(K), siempre, [p(0), r, r], unos(K, bloque(s(K)))).
plana:fila(rapido, unos(s(K), C), siempre, [p(1), r, r], unos(K, C)).
perezosa:alias(rapido, unos(cero, C), C).
```

```prolog
?- sucesion(rapido, inicio, 15, S).
S = '001011011101111'.

?- medir(rapido, inicio, 120, M).
M = medida(121, 14, 33).
```

| Figuras | II | `contador` | `rapido` |
|---:|---:|---:|---:|
| 15 | 116 | 362 | 16 |
| 30 | 398 | 1 397 | 31 |
| 60 | 1 121 | 5 492 | 61 |
| 120 | 3 281 | 21 782 | 121 |

`rapido` hace un paso por figura, más el inicial: el cabezal queda siempre
al final, y `unos(K, C)` imprime los K unos sin buscar nada. Lo consigue
porque la cuenta de los unos está en la configuración, que tiene infinitos
valores posibles: `cuantas(rapido, inicio, [0, 1, schwa], 500, N)` da
`mas_de(500)`. Una máquina de Turing tiene finitas configuraciones m, y
todo lo que no cabe en ellas tiene que ir en la cinta; la máquina II lo
paga con los pasos que da para recorrerla.
