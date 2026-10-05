# Soluciones del capítulo 79 — Proyecto: un lenguaje de consejos para el ajedrez

El código de esta página está en `ejemplos/capitulo-79/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo es un módulo que carga los del
capítulo sin modificarlos y exporta también el intérprete de
`consejos.pl`, la verificación de `verificar.pl` y la búsqueda de
`busqueda.pl`. Las tablas de consejos de los ejercicios 4, 9 y 11 son
módulos propios, `ciega`, `sin_cuidado` y `meta_mejor`: sus cláusulas se
escriben en `soluciones.pl` con el nombre del módulo delante, y toman de
`krk.pl` la biblioteca del final. Es `% solo-local`, porque carga otros
archivos.

## 1

La torre en c6 divide el tablero por la columna c y la fila 6; el rey
negro en f8 está a la derecha de la columna y arriba de la fila: 5
columnas (d a h) por 2 filas (7 y 8), 10 casillas. La casilla crítica es
la vecina diagonal de la torre hacia el rey negro: d7. La torre divide a
los reyes por las filas: el rey blanco está en la 5, la torre en la 6 y el
rey negro en la 8.

<!-- contexto: capitulo-79/krk.pl -->
```prolog
?- espacio(pos(blancas, 5-5, 3-6, 6-8), E), casilla_critica(pos(blancas, 5-5, 3-6, 6-8), C).
E = 10,
C = 4-7.

?- P = pos(blancas, 5-5, 3-6, 6-8), cumple(krk, torre_divide, P, P).
P = pos(blancas, 5-5, 3-6, 6-8).
```

## 2

`y` es `xfy` con precedencia 780 y `o` tiene 785: sin paréntesis,
`torre_divide o patron_l y espacio_mayor_que_2` se leería
`o(torre_divide, y(patron_l, espacio_mayor_que_2))`, porque el operador de
mayor precedencia queda como principal. Los paréntesis hacen de cada
disyunción una sola condición de la conjunción:

<!-- contexto: capitulo-79/krk.pl -->
```prolog
?- consejo(acercamiento, M, _, _, _), write_canonical(M), nl.
y(acerca_casilla_critica,y(no(torre_expuesta),y(o(torre_divide,patron_l),o(espacio_mayor_que_2,no(rey_blanco_en_borde)))))
M = (acerca_casilla_critica y no torre_expuesta y (torre_divide o patron_l)y(espacio_mayor_que_2 o no rey_blanco_en_borde)).
```

## 3

El rey negro en a1 tiene una sola casilla libre, b1: a2 y b2 están junto
al rey blanco de c3. El consejo prueba primero las jugadas del rey en
diagonal; el rey a b3 deja libre b1 y, después de Rb1, la torre de d2 da
mate en d1, porque el rey en b3 cubre a2, b2 y c2. El árbol tiene una sola
respuesta de las negras: después de Rb3, la única jugada legal del rey
negro es b1.

<!-- contexto: capitulo-79/krk.pl -->
```prolog
?- satisfacible(krk, mate_en_2, pos(blancas, 3-3, 4-2, 1-1), A).
A = juega(rey(3-3, 2-3), responde([rey(1-1, 2-1)-juega(torre(4-2, 4-1), hoja)])).
```

## 4

El mate en N jugadas de las blancas permite jugadas de las blancas en las
profundidades 0, 2, …, 2N − 2 y de las negras en 1, 3, …, 2N − 3; para
N = 3, las nuestras con `profundidad < 5` y las suyas con
`profundidad < 4`. La meta a mantener, `no torre_perdida`, deja fuera
las respuestas que capturan la torre, como `pierde/2`:

<!-- ejemplo: capitulo-79/soluciones.pl fragmento: ciega:consejo(mate_en_3, .. krk:jugadas(N, P, J, S). -->
```prolog
ciega:consejo(mate_en_3, mate, no torre_perdida,
                 profundidad < 5 y legal, profundidad < 4 y legal).
ciega:mueve(P, B) :-
    krk:mueve(P, B).
ciega:meta(M, P, R) :-
    krk:meta(M, P, R).
ciega:jugadas(N, P, J, S) :-
    krk:jugadas(N, P, J, S).
```

<!-- contexto: capitulo-79/soluciones.pl -->
```prolog
?- satisfacible(ciega, mate_en_3, pos(blancas, 1-3, 4-2, 2-1), juega(J, _)), mate_forzado(pos(blancas, 1-3, 4-2, 2-1), 3, J2).
J = J2, J2 = rey(1-3, 2-3).
```

Las dos búsquedas dan la misma primera jugada en las tres posiciones de la
[sección 79.2](index.md#792-version-2-buscar-el-mate-sin-conocimiento), como comprueba la prueba `ciega`. Las inferencias, medidas
con `statistics(inferences, I)` antes y después de cada llamada con
N = 3:

| Posición | Consejo | `mate_forzado/3` |
|---|---|---|
| mate en 1 (b3, d2, b1) | 61 247 | 171 584 |
| mate en 2 (a3, a4, b1) | 22 182 | 107 441 |
| mate en 3 (a3, d2, b1) | 22 176 | 48 660 |

Las cifras son del mismo orden: el consejo sin restricciones es la misma
búsqueda Y/O. Ninguna de las dos busca el mate más corto: las dos aceptan
el primero que encuentran dentro del límite. Lo que distingue a un consejo
útil de esta búsqueda son sus restricciones y sus metas intermedias.

## 5

<!-- ejemplo: capitulo-79/soluciones.pl predicado: por_que/2 probar/3 -->
```prolog
%!  por_que(+Tabla, +Posicion) is semidet.
%
%   Escribe la regla de Tabla que se aplica en Posicion y, para cada
%   consejo de su lista hasta el primero satisfacible, si lo es. Falla si
%   ninguno lo es.
por_que(Tabla, Posicion) :-
    once(( Tabla:regla(Regla, si Condicion entonces Consejos),
           cumple(Tabla, Condicion, Posicion, Posicion) )),
    format("regla ~w~n", [Regla]),
    probar(Consejos, Tabla, Posicion).

%!  probar(+Consejos:list, +Tabla, +Posicion) is semidet.
%
%   Escribe, para cada consejo hasta el primero satisfacible, si lo es.
probar([C|Cs], Tabla, Posicion) :-
    (   satisfacible(Tabla, C, Posicion, juega(J, _))
    ->  notacion(J, T),
        format("  ~w: satisfacible, juega ~w~n", [C, T])
    ;   format("  ~w: no satisfacible~n", [C]),
        probar(Cs, Tabla, Posicion)
    ).
```

<!-- contexto: capitulo-79/soluciones.pl -->
```prolog
?- por_que(krk, pos(blancas, 5-5, 1-1, 4-7)).
regla resto
  encierro: no satisfacible
  acercamiento: no satisfacible
  mantener_espacio: no satisfacible
  dividir_en_2: satisfacible, juega Tc1
true.
```

Como la pregunta «¿cómo?» del [capítulo 19](../capitulo-19-operadores-y-reglas-como-datos/index.md#194-el-interprete-y-la-pregunta-como), la explicación se obtiene del
mismo intérprete que decide: `por_que/2` repite lo que hace
`estrategia/4`, pero escribe cada paso.

## 6

Una defensa recibe solo la posición, así que no puede llevar el estado
del generador de una jugada a la siguiente. La semilla se combina con el
código de la posición en un único paso del generador: la misma posición
con la misma semilla da siempre la misma respuesta, y las pruebas son
repetibles.

<!-- ejemplo: capitulo-79/soluciones.pl predicado: azar/3 medir_en/4 -->
```prolog
%!  azar(+Semilla:integer, +Posicion, -Jugada) is semidet.
%
%   Jugada es una respuesta legal de las negras elegida con un paso del
%   generador congruencial del capítulo 77, a partir de Semilla y del código
%   de Posicion: la misma posición con la misma semilla da siempre la misma
%   respuesta.
azar(Semilla, Posicion, Jugada) :-
    findall(J, jugada(Posicion, J, _), Js),
    length(Js, N),
    N > 0,
    Posicion = pos(_, RB, T, RN),
    codigo(pos(blancas, RB, T, RN), C),
    X is (1103515245 * (Semilla + C) + 12345) mod 2147483648,
    I is (X >> 16) mod N,
    nth0(I, Js, Jugada).

medir_en(Tabla, Defensa, ReyNegro, r(Finales, Mayor)) :-
    posiciones(blancas, Ps),
    findall(F-N,
            ( member(P, Ps),
              P = pos(_, _, _, ReyNegro),
              partida(Tabla, Defensa, P, Js, F),
              include(de_blancas, Js, Bs),
              length(Bs, N) ),
            FNs),
    pairs_keys(FNs, Fs0),
    msort(Fs0, Fs),
    clumped(Fs, Finales),
    aggregate_all(max(N), member(mate-N, FNs), Mayor).
```

Las dos mediciones, de unos 25 segundos cada una, sobre las 2 658
posiciones normales con el rey negro en d4:

```text
medir_en(corregida, azar(7), 4-4, R):  R = r([mate-2658], 24)
medir_en(corregida, primera, 4-4, R):  R = r([mate-2658], 26)
```

La tabla corregida da mate en todas, en a lo sumo 24 jugadas contra la
defensa al azar y 26 contra `primera`.

## 7

Con la tabla de finales calculada, `jugadas_hasta_mate(corregida, optima,
P, N)` y `mate_en(P, K)` dan:

```text
pos(blancas, 5-5, 1-1, 4-7):  N = 12,  K = 8
pos(blancas, 1-1, 4-4, 3-3):  N = 30,  K = 14
```

Contra la defensa óptima, la tabla tarda 12 jugadas donde el óptimo es 8,
y 30 donde es 14. La verificación asegura 14 y 34 en esas posiciones: la
defensa óptima según la tabla de finales no es la peor contra la tabla de
consejos. `optima/2` elige la respuesta que más demora el mate **óptimo**;
la que más demora el mate de la tabla de consejos puede ser otra, y la
verificación, que examina todas, la encuentra.

## 8

Sin memoria, el paso es una jugada de las blancas, y la verificación es la
de la tabla de finales con las blancas restringidas a la primera jugada
del árbol de cada posición:

<!-- ejemplo: capitulo-79/soluciones.pl predicado: politica_sin_memoria/2 elegir/2 propagar/2 -->
```prolog
%!  politica_sin_memoria(+Tabla, -R) is det.
%
%   R es r(Aseguradas, Total, Mayor) para la política que en cada jugada
%   pide un árbol nuevo a Tabla y juega solo su primera jugada, sobre las
%   posiciones normales. Calcula la tabla de finales si hace falta.
politica_sin_memoria(Tabla, r(Aseguradas, Total, Mayor)) :-
    (   nodo(_, _, _)
    ->  true
    ;   calcular
    ),
    retractall(elige(Tabla, _, _)),
    retractall(asegura(Tabla, _, _)),
    retractall(cae(Tabla, _, _)),
    forall(nodo(blancas, C, _), elegir(Tabla, C)),
    forall(( nodo(negras, C, []), decodificar(negras, C, P), jaque(P) ),
           assertz(cae(Tabla, C, 0))),
    propagar(Tabla, 1),
    aggregate_all(count, nodo(blancas, _, _), Total),
    aggregate_all(count, asegura(Tabla, _, _), Aseguradas),
    aggregate_all(max(K), asegura(Tabla, _, K), Mayor).

%!  elegir(+Tabla, +C:integer) is det.
%
%   Registra adónde lleva la primera jugada del árbol que Tabla da en la
%   posición de las blancas de código C.
elegir(Tabla, C) :-
    decodificar(blancas, C, P),
    (   estrategia(Tabla, P, _, juega(J, _))
    ->  jugada(P, J, S),
        (   ahogado(S)
        ->  C1 = fin(ahogado)
        ;   sucesora(S, C1)
        )
    ;   C1 = fin(sin_consejo)
    ),
    assertz(elige(Tabla, C, C1)).

%!  propagar(+Tabla, +K:integer) is det.
%
%   Marca las posiciones de las blancas desde las que la política da mate
%   en K jugadas y las de las negras que lo reciben en K, y sigue mientras
%   alguna cambie.
propagar(Tabla, K) :-
    findall(C,
            ( elige(Tabla, C, C1),
              \+ asegura(Tabla, C, _),
              cae(Tabla, C1, _) ),
            Ganan),
    forall(member(C, Ganan), assertz(asegura(Tabla, C, K))),
    findall(C,
            ( nodo(negras, C, Cs),
              Cs \== [],
              \+ cae(Tabla, C, _),
              \+ memberchk(captura, Cs),
              forall(member(C1, Cs), asegura(Tabla, C1, _)) ),
            Caen),
    forall(member(C, Caen), assertz(cae(Tabla, C, K))),
    (   Ganan == [],
        Caen == []
    ->  true
    ;   K1 is K + 1,
        propagar(Tabla, K1)
    ).
```

Sobre las 27 352 posiciones normales, en 25 segundos:

```text
politica_sin_memoria(krk, R):        R = r(25570, 27352, 32)
politica_sin_memoria(corregida, R):  R = r(25580, 27352, 32)
```

Con la tabla corregida, que no ahoga, quedan 1 772 posiciones sin
asegurar: todas forman ciclos. Desde el rey blanco en a6, la torre en c2
y el rey negro en a1, el árbol de `dividir_en_2` es: rey a b7 y, contra
Rb1, torre a c4. La política juega Rb7, y después de Rb1 pide un árbol
nuevo, que empieza con otra jugada, torre a c3; el siguiente empieza con
una jugada del rey, y así sigue. Ningún árbol llega a su segunda jugada:
el rey blanco recorre la octava fila (Rc8, Rd7, Re8, Rf7, Rg8, Rh7) y
después alterna entre g8 y h7, mientras el rey negro va y viene entre a1,
b1 y a2. Con memoria, el programa juega el árbol entero. El árbol forzante no es solo una prueba de que
el consejo es satisfacible: es el plan, y descartarlo después de la
primera jugada es descartar el plan.

## 9

Sin `no torre_expuesta`, el encierro puede llevar la torre lejos de su
rey. Pero la meta a mantener de todos los consejos es `no torre_perdida`,
que se comprueba en cada nodo de cada árbol, incluidas las hojas: una
hoja con las negras a mover cumple que el rey negro no puede capturar la
torre. Ningún árbol termina con la torre capturada:

<!-- ejemplo: capitulo-79/soluciones.pl fragmento: sin_cuidado:regla(N, R) :- .. krk:jugadas(N, P, J, S). -->
```prolog
sin_cuidado:regla(N, R) :-
    krk:regla(N, R).
sin_cuidado:consejo(encierro,
                    espacio_menor y torre_divide y no ahogado,
                    no torre_perdida,
                    profundidad = 0 y torre,
                    ninguna) :-
    !.
sin_cuidado:consejo(N, B, M, U, T) :-
    krk:consejo(N, B, M, U, T),
    N \== encierro.
sin_cuidado:mueve(P, B) :-
    krk:mueve(P, B).
sin_cuidado:meta(M, P, R) :-
    krk:meta(M, P, R).
sin_cuidado:jugadas(N, P, J, S) :-
    krk:jugadas(N, P, J, S).
```

Recorrer las 27 352 posiciones normales con `salidas/3` y contar las que
tienen una salida `falla(torre_perdida)` da 0; la prueba
`sin_cuidado_no_pierde` hace lo mismo con las posiciones del rey negro en
a1.

La pérdida de la torre la impide la meta a mantener, no la meta mejor de
`encierro`. `no torre_expuesta` elige, entre las jugadas de torre que
reducen el espacio, las que no dejan la torre más cerca del rey negro que
del blanco; el ejercicio no mide si eso acorta las partidas.

## 10

<!-- ejemplo: capitulo-79/soluciones.pl predicado: cuantas/1 -->
```prolog
%!  cuantas(-Pares:list) is det.
%
%   Pares tiene un par K-N por cada K de 1 a 16: N posiciones normales de
%   las blancas dan mate en K jugadas. Calcula la tabla si hace falta.
cuantas(Pares) :-
    (   nodo(_, _, _)
    ->  true
    ;   calcular
    ),
    findall(K-N,
            ( between(1, 16, K),
              aggregate_all(count,
                            ( nodo(blancas, C, _),
                              decodificar(blancas, C, P),
                              mate_en(P, K) ),
                            N) ),
            Pares).
```

La consulta `cuantas(Pares)`, que calcula antes la tabla de finales,
tarda unos once segundos:

```text
Pares = [1-273, 2-718, 3-555, 4-346, 5-842, 6-1391, 7-1771, 8-2614,
         9-2851, 10-2950, 11-2996, 12-3135, 13-3004, 14-2714, 15-1005, 16-187]
```

Las 16 cantidades suman las 27 352 posiciones normales. Hay más
posiciones de mate en 12 que de cualquier otra longitud, y solo 187 en
16.

## 11

<!-- ejemplo: capitulo-79/soluciones.pl fragmento: meta_mejor:regla(N, R) :- .. krk:jugadas(N, P, J, S). -->
```prolog
meta_mejor:regla(N, R) :-
    krk:regla(N, R).
meta_mejor:consejo(N, B1, M, U, T) :-
    krk:consejo(N, B, M, U, T),
    (   memberchk(N, [acercamiento, mantener_espacio, dividir_en_2])
    ->  B1 = (B y no ahogado)
    ;   B1 = B
    ).
meta_mejor:mueve(P, B) :-
    krk:mueve(P, B).
meta_mejor:meta(M, P, R) :-
    krk:meta(M, P, R).
meta_mejor:jugadas(N, P, J, S) :-
    krk:jugadas(N, P, J, S).
```

`verificar_desde/3` desde cada una de las 48 posiciones que la tabla
original no asegura da `r(A, A, K)` en las 48: la otra corrección también
las asegura todas.

<!-- contexto: capitulo-79/soluciones.pl -->
```prolog
?- verificar_desde(meta_mejor, pos(blancas, 1-3, 2-2, 1-1), R).
R = r(25, 25, 14).
```

Las dos correcciones dan aquí el mismo resultado, pero no son
equivalentes: la de la [sección 79.8](index.md#798-version-8-la-tabla-corregida) excluye el ahogado de todos los
consejos, también de los que hoy no lo producen, y es la que la
verificación completa respalda; esta solo cubre los tres consejos en que
se encontró, y habría que verificarla sobre las 175 168 posiciones para
afirmar lo mismo.

## 12

`partida/5` no marca dónde empieza cada árbol. `historia/4` repite la
partida siguiendo el árbol en curso, como lo hace `partida/5`, y pide un
árbol nuevo cuando el anterior se termina:

<!-- ejemplo: capitulo-79/soluciones.pl predicado: historia/4 arboles/5 -->
```prolog
historia(Tabla, Defensa, Posicion, Consejos) :-
    partida(Tabla, Defensa, Posicion, Jugadas, _),
    arboles(Jugadas, Tabla, Posicion, ninguno, Consejos).

%!  arboles(+Jugadas:list, +Tabla, +Posicion, +Arbol, -Consejos:list)
%!      is det.
%
%   Recorre Jugadas desde Posicion con Arbol, el árbol en curso o ninguno,
%   y reúne el consejo de cada árbol nuevo.
arboles([], _, _, _, []).
arboles([blancas(J, C)|Js], Tabla, P, Arbol, Consejos) :-
    (   Arbol = juega(J, A1)
    ->  Consejos = Cs
    ;   estrategia(Tabla, P, C, juega(J, A1)),
        Consejos = [C|Cs]
    ),
    once(jugada(P, J, P1)),
    (   Js = [negras(R)|Js1]
    ->  once(jugada(P1, R, P2)),
        (   A1 = responde(Ramas),
            memberchk(R-A2, Ramas)
        ->  true
        ;   A2 = ninguno
        ),
        arboles(Js1, Tabla, P2, A2, Cs)
    ;   Cs = []
    ).
```

<!-- contexto: capitulo-79/soluciones.pl -->
```prolog
?- historia(krk, resistente, pos(blancas, 5-5, 1-1, 4-7), H).
H = [dividir_en_2, encierro, encierro, acercamiento, acercamiento, encierro, mate_en_2].

?- historia(krk, primera, pos(blancas, 5-5, 1-1, 4-7), H), length(H, N).
H = [dividir_en_2, encierro, encierro, encierro, acercamiento, encierro, acercamiento, mantener_espacio, acercamiento|...],
N = 10.
```

La partida de la introducción pide siete árboles para nueve jugadas: los
de `dividir_en_2` y `mate_en_2` duran dos jugadas cada uno, y los demás,
una.
