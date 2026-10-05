# Soluciones del capítulo 81 — Proyecto: una colección de problemas

El código de esta página está en `ejemplos/capitulo-81/soluciones.pl`,
con sus pruebas en `soluciones.plt`. El archivo carga `triangulo.pl`,
`moleculas.pl`, `estampillas.pl`, `transito.pl`, `marcos.pl` y
`rimas.pl` sin modificarlos. Los problemas nuevos del triángulo se
escriben `user:Problema` y se resuelven con `buscar/5` del
[capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md), que
`triangulo.pl` reexporta; sus `inicial/2`, `meta/2` y `sucesor/5` están
en el archivo de las soluciones. Es `% solo-local`, porque carga otros
archivos.

## 1

El agujero 5 es uno de los tres de adentro. Un salto que lo llena tiene
que venir de dos agujeros más allá en línea recta, y desde el 5 solo hay
dos líneas de tres que terminan en él: hacia abajo por la columna
izquierda (12, 8, 5) y por la derecha (14, 9, 5). Hacia arriba no hay
lugar, y la fila del 5 tiene solo tres agujeros, con el 5 en el medio.
La posición es ya su propia forma: ninguna imagen tiene el agujero vacío
antes del quinto lugar, porque las imágenes del 5 son el 8 y el 9.

<!-- contexto: capitulo-81/soluciones.pl -->
```prolog
?- inicio(5, T), findall(S, salto(S, T, _), Ss).
T = t(1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
Ss = [s(12, 8, 5), s(14, 9, 5)].

?- inicio(5, T), forma(T, F).
T = F, F = t(1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1).
```

## 2

El problema nuevo cambia solo la meta: una clavija, en el agujero del
comienzo. Las simetrías no sirven tal como están porque la meta ya no es
la misma para todas las imágenes de una posición: una forma pierde el
dato de dónde estaba el agujero del comienzo. Se podrían usar solo las
simetrías que dejan fijo ese agujero, que con el agujero 1 son la
identidad y un espejo.

<!-- ejemplo: capitulo-81/soluciones.pl fragmento: inicial(en_su_agujero(V), T) :- .. buscar(profundidad, user:en_su_agujero(Vacio), Saltos, _, Expandidos). -->
```prolog
inicial(en_su_agujero(V), T) :-
    inicio(V, T).
inicial(bloqueada(V, _), T) :-
    inicio(V, T).

%!  meta(+Problema, +T) is semidet.
%
%   Con en_su_agujero(V), T tiene una sola clavija, en el agujero V. Con
%   bloqueada(_, K), T tiene K clavijas y ningún salto.
meta(en_su_agujero(V), T) :-
    clavijas(T, 1),
    arg(V, T, 1).
meta(bloqueada(_, K), T) :-
    clavijas(T, K),
    \+ salto(_, T, _).

%!  sucesor(+Problema, +T0, -Salto, -T, -Costo:integer) is nondet.
%
%   Salto lleva de T0 a T, con costo 1, en los dos problemas.
sucesor(en_su_agujero(_), T0, S, T, 1) :-
    salto(S, T0, T).
sucesor(bloqueada(_, _), T0, S, T, 1) :-
    salto(S, T0, T).

% --- Ejercicio 2: terminar en el agujero del comienzo -------------------

%!  terminar_en(+Vacio:integer, -Saltos:list, -Expandidos:integer)
%!      is semidet.
%
%   Saltos empieza con el agujero Vacio sin clavija y deja una sola, en
%   ese mismo agujero; Expandidos son las posiciones que expandió la
%   búsqueda en profundidad con registro de visitados.
terminar_en(Vacio, Saltos, Expandidos) :-
    buscar(profundidad, user:en_su_agujero(Vacio), Saltos, _, Expandidos).
```

```prolog
?- terminar_en(1, Saltos, K).
Saltos = [s(4, 2, 1), s(6, 5, 4), s(1, 3, 6), s(7, 4, 2), s(10, 6, 3), s(13, 8, 4), s(2, 4, 7), s(11, 7, 4), s(15, 14, 13), s(12, 13, 14), s(14, 9, 5), s(4, 5, 6), s(6, 3, 1)],
K = 740.

?- terminar_en(5, Saltos, K).
false.
```

Es posible desde los agujeros 1, 2 y 4, y desde sus imágenes; desde el 5
no: la búsqueda recorre todas las posiciones alcanzables y ninguna de
una clavija la tiene en el 5.

## 3

<!-- ejemplo: capitulo-81/soluciones.pl predicado: bloqueo/3 mayor_bloqueo/2 -->
```prolog
%!  bloqueo(+Vacio:integer, +K:integer, -Saltos:list) is semidet.
%
%   Saltos empieza con el agujero Vacio sin clavija y deja K clavijas sin
%   ningún salto posible.
bloqueo(Vacio, K, Saltos) :-
    buscar(profundidad, user:bloqueada(Vacio, K), Saltos, _, _).

%!  mayor_bloqueo(+Vacio:integer, -K:integer) is det.
%
%   K es la mayor cantidad de clavijas que pueden quedar sin ningún salto
%   posible, empezando con el agujero Vacio sin clavija.
mayor_bloqueo(Vacio, K) :-
    once(( between(1, 13, I),
           K is 14 - I,
           bloqueo(Vacio, K, _) )).
```

`mayor_bloqueo/2` prueba de mayor a menor cantidad de clavijas y se
queda con la primera que tiene solución:

```prolog
?- bloqueo(1, 8, Saltos).
Saltos = [s(4, 2, 1), s(13, 8, 4), s(10, 9, 8), s(7, 8, 9), s(6, 9, 13), s(1, 3, 6)].

?- maplist(mayor_bloqueo, [1, 2, 4, 5], Ks).
Ks = [8, 8, 7, 10].
```

La variante del libro, ocho clavijas bloqueadas, se puede desde un
vértice o desde un agujero vecino de un vértice, pero no desde el medio
de un lado ni desde adentro. Desde el 5 se puede algo más extremo: diez
clavijas sin ningún salto después de solo cuatro saltos.

## 4

La cantidad de soluciones desde una posición es la suma de las de las
posiciones que deja cada salto, y es la misma para todas las imágenes de
la posición. La tabla se lleva sobre las formas, así que un cálculo sirve
para las seis imágenes, y los quince comienzos comparten la tabla:

<!-- ejemplo: capitulo-81/soluciones.pl predicado: cuenta_desde/2 cuenta/2 cuenta_forma/2 -->
```prolog
%!  cuenta_desde(+Vacio:integer, -N:integer) is det.
%
%   N es la cantidad de soluciones, sucesiones de saltos que dejan una
%   sola clavija, cuando se empieza con el agujero Vacio sin clavija.
cuenta_desde(Vacio, N) :-
    inicio(Vacio, T),
    cuenta(T, N).

%!  cuenta(+T, -N:integer) is det.
%
%   N es la cantidad de soluciones desde la posición T. Las imágenes de
%   una posición tienen las mismas, así que la tabla se lleva por formas.
cuenta(T, N) :-
    forma(T, F),
    cuenta_forma(F, N).

%!  cuenta_forma(+F, -N:integer) is det.
%
%   cuenta/2 para una forma: 1 con una sola clavija; si no, la suma de
%   las soluciones desde cada posición que deja un salto.
cuenta_forma(F, N) :-
    (   clavijas(F, 1)
    ->  N = 1
    ;   aggregate_all(sum(K), ( salto(_, F, T), cuenta(T, K) ), N)
    ).
```

```prolog
?- maplist(cuenta_desde, [1, 2, 4, 5], Ns).
Ns = [29760, 14880, 85258, 1550].

?- aggregate_all(sum(K), (between(1, 15, V), cuenta_desde(V, K)), N).
N = 438984.
```

`cuenta_desde(4, N)` tarda 0,17 segundos con la tabla vacía, y
`aggregate_all(count, resolver(T, _), N)` desde la misma posición, 27
segundos. El total de los quince comienzos es 3 × 29 760 + 6 × 14 880 +
3 × 85 258 + 3 × 1 550 = 438 984: tres vértices, seis agujeros vecinos de
un vértice, tres medios de lado y tres de adentro.

## 5

Con un conjunto ordenado de agujeros, un salto es posible si `De` y
`Sobre` están y `Hasta` no, y la posición siguiente se obtiene quitando
dos agujeros y agregando uno. Para cuatro filas las líneas son nueve.

<!-- ejemplo: capitulo-81/soluciones.pl predicado: agujero4/3 linea4/3 salto4/3 triangulo4/2 resolver4/2 -->
```prolog
%!  agujero4(?N:integer, ?F:integer, ?C:integer) is nondet.
%
%   El agujero N, de 1 a 10, es el C-ésimo de la fila F, de 1 a 4.
agujero4(N, F, C) :-
    between(1, 4, F),
    between(1, F, C),
    N is F * (F - 1) // 2 + C.

%!  linea4(?A:integer, ?B:integer, ?C:integer) is nondet.
%
%   A, B y C son tres agujeros seguidos en línea recta en el triángulo de
%   cuatro filas.
linea4(A, B, C) :-
    agujero4(A, F, K),
    member(DF-DK, [0-1, 1-0, 1-1]),
    F1 is F + DF,
    K1 is K + DK,
    F2 is F1 + DF,
    K2 is K1 + DK,
    agujero4(B, F1, K1),
    agujero4(C, F2, K2).

%!  salto4(+P0:list, -Salto, -P:list) is nondet.
%
%   P0 y P son los conjuntos ordenados de los agujeros con clavija antes y
%   después de Salto, s(De, Sobre, Hasta).
salto4(P0, s(De, Sobre, Hasta), P) :-
    (   linea4(De, Sobre, Hasta)
    ;   linea4(Hasta, Sobre, De)
    ),
    ord_memberchk(De, P0),
    ord_memberchk(Sobre, P0),
    \+ ord_memberchk(Hasta, P0),
    list_to_ord_set([De, Sobre], Saltadas),
    ord_subtract(P0, Saltadas, P1),
    ord_add_element(P1, Hasta, P).

%!  triangulo4(+Vacio:integer, -Saltos:list) is nondet.
%
%   Saltos resuelve el triángulo de diez agujeros que empieza con el
%   agujero Vacio sin clavija.
triangulo4(Vacio, Saltos) :-
    numlist(1, 10, Todos),
    ord_del_element(Todos, Vacio, P),
    resolver4(P, Saltos).

%!  resolver4(+P:list, -Saltos:list) is nondet.
%
%   Saltos lleva del conjunto de clavijas P a una sola clavija.
resolver4([_], []).
resolver4(P0, [S|Ss]) :-
    P0 = [_, _|_],
    salto4(P0, S, P),
    resolver4(P, Ss).
```

```prolog
?- findall(V, (between(1, 10, V), once(triangulo4(V, _))), Vs).
Vs = [2, 3, 4, 6, 8, 9].

?- aggregate_all(count, triangulo4(2, _), N).
N = 14.
```

El triángulo de diez agujeros tiene solución solo si empieza con uno de
los seis agujeros del medio de los lados vacío, con catorce soluciones
cada uno; desde los vértices y desde el agujero central, ninguna.

## 6

El naftaleno tiene dos anillos de seis, uno a cada lado del enlace
`c9-c10`, y además el contorno de los dos, un ciclo de diez carbonos que
no pasa por ese enlace: `anillo/3` busca ciclos, no anillos «químicos»,
y el contorno es un ciclo. Las estructuras de Kekulé son tres: el enlace
compartido es doble en una y simple en dos.

<!-- ejemplo: capitulo-81/soluciones.pl fragmento: molecula(naftaleno, .. c1-h1, c2-h2, c3-h3, c4-h4, c5-h5, c6-h6, c7-h7, c8-h8 ]). -->
```prolog
molecula(naftaleno,
         [ carbono-[c1, c2, c3, c4, c5, c6, c7, c8, c9, c10],
           hidrogeno-[h1, h2, h3, h4, h5, h6, h7, h8]
         ],
         [ c1-c2, c2-c3, c3-c4, c4-c9, c9-c10, c10-c1,
           c9-c5, c5-c6, c6-c7, c7-c8, c8-c10,
           c1-h1, c2-h2, c3-h3, c4-h4, c5-h5, c6-h6, c7-h7, c8-h8 ]).
```

```prolog
?- findall(A, anillo(naftaleno, 6, A), As).
As = [[c1, c10, c9, c4, c3, c2], [c10, c8, c7, c6, c5, c9]].

?- anillo(naftaleno, 10, A).
A = [c1, c10, c8, c7, c6, c5, c9, c4, c3, c2] ;
false.

?- aggregate_all(count, ordenes(naftaleno, _), N).
N = 3.
```

## 7

<!-- ejemplo: capitulo-81/soluciones.pl predicado: valor_total/2 sumar_valor/3 por_pais/1 -->
```prolog
%!  valor_total(?Patron, -Total:integer) is det.
%
%   Total es la suma de los valores de los sellos del álbum que unifican
%   con Patron.
valor_total(Patron, Total) :-
    coleccion(Patron, Sellos),
    foldl(sumar_valor, Sellos, 0, Total).

%!  sumar_valor(+Sello, +T0:integer, -T:integer) is det.
%
%   T es T0 más el valor de Sello.
sumar_valor(sello(_, _, _, V), T0, T) :-
    T is T0 + V.

%!  por_pais(-Pares:list) is det.
%
%   Pares tiene un par Pais-Total por cada país del álbum, en orden, con
%   el valor total de sus sellos.
por_pais(Pares) :-
    coleccion(sello(_, _, _, _), Sellos),
    findall(P, member(sello(P, _, _, _), Sellos), Paises0),
    sort(Paises0, Paises),
    findall(P-T,
            ( member(P, Paises),
              valor_total(sello(P, _, _, _), T) ),
            Pares).
```

```prolog
?- valor_total(sello(_, _, _, _), T).
T = 586.

?- por_pais(Ps).
Ps = [alemania-195, reino_unido-391].
```

## 8

Los sellos de 1885 son el de 50 de los kaiser y los de 10 y 60 de los
castillos: las cuatro series quedan, la de los castillos con un solo
sello. El `sell/1` del libro falla, porque exige el país y la serie.

```prolog
?- vender(sello(_, _, 1885, _)), coleccion(sello(alemania, _, _, _), Ss).
Ss = [sello(alemania, kaiser, 1882, 5), sello(alemania, kaiser, 1879, 20), sello(alemania, castillos, 1879, 50)].
```

## 9

<!-- ejemplo: capitulo-81/soluciones.pl predicado: conflictos/2 cuenta_conflictos/3 -->
```prolog
%!  conflictos(+Quien, -Conflictos:list) is det.
%
%   Conflictos son las situaciones con dos luces para los autos, de tipos
%   distintos, en las que accion/3 da a Quien detenerse y también una
%   acción que avanza, con Frenar si o no. Cada conflicto es
%   Luz1+Luz2-Frenar-Acciones.
conflictos(Quien, Conflictos) :-
    findall(luz(T1, E1)+luz(T2, E2)-F-As,
            ( vehicular(T1, E1),
              vehicular(T2, E2),
              T1 @< T2,
              member(F, [si, no]),
              situacion(luz(T1, E1), F, S0),
              S = [luz(T2, E2)|S0],
              findall(A, accion(S, Quien, A), As),
              memberchk(detenerse, As),
              once(( member(A1, As),
                     A1 \== detenerse,
                     A1 \== detenerse_y_avanzar )) ),
            Conflictos).

%!  cuenta_conflictos(+Quien, -N:integer, -K:integer) is det.
%
%   N es la cantidad de conflictos de Quien, y K la de aquellos en los que
%   la primera acción, la que elige decision/3, no es detenerse.
cuenta_conflictos(Quien, N, K) :-
    conflictos(Quien, Conflictos),
    length(Conflictos, N),
    aggregate_all(count,
                  ( member(_-_-[A|_], Conflictos),
                    A \== detenerse ),
                  K).
```

```prolog
?- conflictos(auto, [C|_]).
C = luz(rojo, fija)+luz(verde, fija)-si-[detenerse, ceder_y_avanzar].

?- cuenta_conflictos(auto, N, K).
N = 44,
K = 30.
```

En 44 de las situaciones con dos luces el auto puede a la vez detenerse
y avanzar de algún modo, y en 30 la primera acción no es detenerse. Rowe
pone primero las reglas de detenerse dentro de cada grupo, pensando en
las fallas del semáforo, pero los grupos van en orden: una flecha verde
manda sobre una luz roja, que es lo que el manual quiere, y una luz
amarilla manda sobre una flecha roja, que no lo es. El orden de las
reglas es una decisión de prioridad entre grupos que el texto del manual
no toma; con dos luces el programa decide algo que nadie escribió.

## 10

<!-- ejemplo: capitulo-81/soluciones.pl predicado: peaton_v3/2 accion_v3/3 -->
```prolog
%!  peaton_v3(+Situacion:list, ?Accion) is nondet.
%
%   Como peaton/2, pero la señal de paso deja cruzar cediendo el paso
%   también cuando está intermitente, como pide el ejemplo de Rowe.
peaton_v3(S, A) :-
    (   peaton(S, A)
    ;   paso_peaton(S, intermitente),
        A = ceder_y_avanzar
    ).

%!  accion_v3(+Situacion:list, +Quien, ?Accion) is nondet.
%
%   Como accion/3, con peaton_v3/2 en lugar de peaton/2.
accion_v3(S, auto, A) :-
    accion(S, auto, A).
accion_v3(S, peaton, A) :-
    (   peaton_v3(S, _)
    ->  peaton_v3(S, A)
    ;   \+ senales_peaton(S),
        \+ verde_de_frente(S)
    ->  accion(S, auto, A)
    ;   A = avanzar
    ).
```

```prolog
?- accion_v3([cruce_horario, luz(verde, fija), luz(silueta, intermitente)], peaton, A).
A = ceder_y_avanzar.
```

## 11

<!-- ejemplo: capitulo-81/soluciones.pl predicado: partes/2 -->
```prolog
%!  partes(+Objeto, -Partes:list) is det.
%
%   Partes son las partes del marco Objeto: las propias y las de las
%   clases más generales por es_un, sin repetir y en orden.
partes(O, Partes) :-
    findall(P,
            ( es_un_de(O, Clase),
              propio(Clase, tiene_parte, P) ),
            Ps),
    sort(Ps, Partes).
```

```prolog
?- partes(auto, Ps).
Ps = [sistema_de_propulsion, sistema_electrico].

?- partes(rabbit_de_juan, Ps).
Ps = [bateria_de_juan, sistema_de_propulsion, sistema_electrico].
```

Las partes heredadas son clases de partes: el auto de Juan tiene *un*
sistema eléctrico, que no es el marco `sistema_electrico` sino un caso
de él. Rowe distingue por eso la herencia de partes de la de valores: un
sistema heredado necesita su propio marco para tener datos propios, como
`bateria_de_juan` los tiene.

## 12

<!-- ejemplo: capitulo-81/soluciones.pl predicado: esqueleto/2 estrofa_segar/2 hombres/2 fue/2 -->
```prolog
%!  esqueleto(+N:integer, -Lista:list) is det.
%
%   Lista es [N, N-1, ..., 1].
esqueleto(N, Lista) :-
    numlist(1, N, Ascendente),
    reverse(Ascendente, Lista).

%!  estrofa_segar(+N:integer, -Lineas:list) is semidet.
%
%   Lineas son los versos de la estrofa N, de 1 a 99, de la canción en la
%   que N hombres fueron a segar: el tercer verso cuenta hacia atrás desde
%   N hasta un hombre y su perro.
estrofa_segar(N, [L1, L2, L3, L4]) :-
    hombres(N, Hombres0),
    mayuscula_inicial(Hombres0, Hombres),
    numero_gramatical(N, Num),
    fue(Num, Fue),
    format(string(L1), "~w ~w a segar,", [Hombres, Fue]),
    format(string(L2), "~w a segar un prado;", [Fue]),
    esqueleto(N, Cuenta),
    maplist(hombres, Cuenta, Grupos),
    atomic_list_concat(Grupos, ', ', Lista0),
    mayuscula_inicial(Lista0, Lista),
    format(string(L3), "~w y su perro", [Lista]),
    format(string(L4), "~w a segar un prado.", [Fue]).

%!  hombres(+N:integer, -Texto:string) is semidet.
%
%   Texto es «un hombre», «dos hombres» y así.
hombres(N, Texto) :-
    ante_sustantivo(N, Numero),
    (   N =:= 1
    ->  format(string(Texto), "~w hombre", [Numero])
    ;   format(string(Texto), "~w hombres", [Numero])
    ).

% fue(Num, Verbo): el verbo ir en pasado, en singular y en plural.
fue(singular, "fue").
fue(plural, "fueron").
```

```prolog
?- estrofa_segar(3, Ls).
Ls = ["Tres hombres fueron a segar,", "fueron a segar un prado;", "Tres hombres, dos hombres, un hombre y su perro", "fueron a segar un prado."].
```
