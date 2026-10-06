# La vuelta del Wumpus y el Buscaminas

Esta página contiene las secciones [40.7](index.md#407-la-vuelta-a-casa-del-wumpus)
y [40.8](index.md#408-el-buscaminas-como-busqueda) del [capítulo 40](index.md):
dos problemas de capítulos anteriores planteados como búsqueda. Los
ejemplos están en `wumpus.pl` y `buscaminas.pl`, en `ejemplos/capitulo-40/`,
con sus pruebas, y corren en SWISH.

## La vuelta a casa del Wumpus

El agente del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#207-el-agente-del-mundo-del-wumpus) explora la cueva
hasta encontrar el oro, y después tiene que volver a la entrada, (1, 1),
pasando solo por celdas ya establecidas como seguras. El problema `vuelta(Desde,
Seguras)` lleva esas celdas dentro del término: la búsqueda no consulta
ningún hecho dinámico, y el mismo problema sirve para cualquier cueva.

<!-- ejemplo: capitulo-40/wumpus.pl predicado: seguras/2 inicial/2 meta/2 sucesor/5 heuristica/3 consulta: seguras(chica, S), buscar(mejor(a_estrella), vuelta(2-3, S), P, C, K). -->
```prolog
%!  seguras(+Cueva, -Seguras:list) is det.
%
%   Seguras son las celdas X-Y establecidas como seguras en Cueva: en
%   chica, las que visitó el agente del capítulo 20 hasta encontrar el oro;
%   en grande, las de una cueva de 5 x 5 con cinco celdas desconocidas.
seguras(chica, [1-1, 1-2, 2-1, 2-2, 2-3, 3-2]).
seguras(grande, Seguras) :-
    findall(X-Y,
            ( between(1, 5, X),
              between(1, 5, Y),
              \+ memberchk(X-Y, [2-2, 2-3, 2-4, 4-2, 4-3]) ),
            Seguras).

%!  inicial(+Problema, -Celda) is det.
%
%   Celda es donde está el agente al empezar la vuelta.
inicial(vuelta(Desde, _), Desde).

%!  meta(+Problema, +Celda) is semidet.
%
%   Celda es la entrada de la cueva.
meta(vuelta(_, _), 1-1).

%!  sucesor(+Problema, +Celda, -Accion, -Siguiente, -Costo) is nondet.
%
%   Accion lleva al agente de Celda a Siguiente, una celda vecina segura,
%   con costo 1. Las vecinas se prueban en el orden del capítulo 20.
sucesor(vuelta(_, Seguras), X-Y, ir(Siguiente), Siguiente, 1) :-
    member(DX-DY, [1-0, -1-0, 0-1, 0-(-1)]),
    VX is X + DX,
    VY is Y + DY,
    Siguiente = VX-VY,
    memberchk(Siguiente, Seguras).

%!  heuristica(+Problema, +Celda, -H:integer) is det.
%
%   H es la distancia de Manhattan de Celda a la entrada.
heuristica(vuelta(_, _), X-Y, H) :-
    H is X - 1 + Y - 1.
```

La cueva `chica` tiene las celdas que visita el agente del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md) antes de encontrar el oro en (2, 3), en el orden de
`recorrido/1`; la `grande` es una cueva de 5 × 5 en la que el agente
conoce todas las celdas salvo cinco. La heurística es la **distancia de
Manhattan** a la entrada: la cantidad de pasos si no hubiera celdas
peligrosas, que nunca estima de más. El bucle es el de A\* de
`puzzle8.pl`, sin cambios.

```prolog
?- seguras(chica, S), buscar(mejor(a_estrella), vuelta(2-3, S), Plan, Costo, K).
S = [1-1, 1-2, 2-1, 2-2, 2-3, 3-2],
Plan = [ir(2-2), ir(2-1), ir(1-1)],
Costo = 3,
K = 3.

?- seguras(grande, S), buscar(mejor(a_estrella), vuelta(1-5, S), Plan, Costo, K).
S = [1-1, 1-2, 1-3, 1-4, 1-5, 2-1, 2-5, 3-1, 3-2, 3-3, 3-4, 3-5, 4-1, 4-4, 4-5, 5-1, 5-2, 5-3, 5-4, 5-5],
Plan = [ir(1-4), ir(1-3), ir(1-2), ir(1-1)],
Costo = 4,
K = 4.
```

En la cueva chica, el camino de vuelta de las soluciones del
[capítulo 20](../capitulo-20-base-de-datos-dinamica/soluciones.md), una búsqueda en profundidad con la lista
de las celdas recorridas, ya era uno de los más cortos. No es así en
general. `primer_camino/2` es esa misma búsqueda, con las vecinas en el
orden del [capítulo 20](../capitulo-20-base-de-datos-dinamica/index.md#207-el-agente-del-mundo-del-wumpus):

<!-- ejemplo: capitulo-40/wumpus.pl predicado: primer_camino/2 sin_ciclos/4 consulta: seguras(grande, S), primer_camino(vuelta(1-5, S), P), length(P, L). -->
```prolog
%!  primer_camino(+Problema, -Plan:list) is semidet.
%
%   Plan es el primer plan que encuentra la búsqueda en profundidad sin
%   repetir celdas: no es necesariamente el más corto.
primer_camino(Problema, Plan) :-
    inicial(Problema, Celda),
    once(sin_ciclos(Problema, Celda, [Celda], Plan)).

%!  sin_ciclos(+Problema, +Celda, +Rastro:list, -Plan:list) is nondet.
%
%   Plan lleva de Celda a la entrada sin pasar por las celdas de Rastro.
sin_ciclos(Problema, Celda, _, []) :-
    meta(Problema, Celda).
sin_ciclos(Problema, Celda, Rastro, [Accion|Plan]) :-
    sucesor(Problema, Celda, Accion, Siguiente, _),
    \+ memberchk(Siguiente, Rastro),
    sin_ciclos(Problema, Siguiente, [Siguiente|Rastro], Plan).
```

```prolog
?- seguras(grande, S), primer_camino(vuelta(1-5, S), Plan), length(Plan, N).
S = [1-1, 1-2, 1-3, 1-4, 1-5, 2-1, 2-5, 3-1, 3-2, 3-3, 3-4, 3-5, 4-1, 4-4, 4-5, 5-1, 5-2, 5-3, 5-4, 5-5],
Plan = [ir(2-5), ir(3-5), ir(4-5), ir(5-5), ir(5-4), ir(4-4), ir(3-4), ir(3-3), ir(3-2), ir(3-1), ir(2-1), ir(1-1)],
N = 12.
```

Desde (1, 5), la primera vecina que se prueba es la de la derecha, y la
búsqueda en profundidad recorre la cueva de lado a lado: doce pasos donde
alcanzan cuatro. A\* expande solo las cuatro celdas del camino, porque la
heurística es exacta cuando el camino recto está libre; la búsqueda en
anchura expande 11 nodos y la de costo uniforme 9, y las dos devuelven un
camino de cuatro pasos. En una cueva de 5 × 5 la diferencia es de
milisegundos; en las grillas de cientos de celdas del
[capítulo 76](../capitulo-76-proyecto-robots-laberintos-caballo/index.md) es lo que separa una búsqueda
posible de una que no lo es.

## El Buscaminas como búsqueda

El resolvedor del [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md#2314-buscaminas-deducir-donde-estan-las-minas) deduce qué
celdas ocultas son seguras con restricciones: una variable 0 o 1 por celda
oculta, y una suma por cada número visible. La misma deducción es una
búsqueda: una **configuración** asigna 0 o 1 a cada celda oculta que toca
algún número, y es consistente si cada número tiene exactamente esa
cantidad de minas vecinas. Una celda es segura si ninguna configuración
consistente le pone mina.

<!-- ejemplo: capitulo-40/buscaminas.pl predicado: tablero/2 leer/3 configuracion/3 asignar/4 posible/2 contar/6 deducir/3 consulta: tablero(chico, T), deducir(T, Seguras, Minas). -->
```prolog
% tablero(Nombre, Lineas): un tablero visible. chico es el del capítulo 23;
% grande es un tablero de 9 x 9 con 10 minas después de 30 jugadas de
% jugar/6.
tablero(chico, ["#100", "1211", "01##", "01##"]).
tablero(grande, ["01#112#10", "12111#210", "#10133311", "1101##2#1",
                 "0########", "#########", "#########", "#########",
                 "#########"]).

%!  leer(+Lineas:list(string), -Ocultas:list, -Numeros:list(pair)) is det.
%
%   Ocultas son las celdas Fila-Columna ocultas que tocan algún número, y
%   Numeros los pares N-Vecinas: un número N y sus vecinas ocultas.
leer(Lineas, Ocultas, Numeros) :-
    length(Lineas, Filas),
    Lineas = [Primera|_],
    string_length(Primera, Columnas),
    findall((F-C)-X,
            ( nth1(F, Lineas, Linea),
              string_chars(Linea, Xs),
              nth1(C, Xs, X) ),
            Celdas),
    findall(N-Vecinas,
            ( member(Celda-X, Celdas),
              atom_number(X, N),
              findall(V, ( vecina(Filas, Columnas, Celda, V),
                           memberchk(V-'#', Celdas) ),
                      Vecinas) ),
            Numeros),
    pairs_values(Numeros, Listas),
    append(Listas, Todas),
    sort(Todas, Ocultas).

%!  configuracion(+Lineas:list(string), +Fijas:list(pair), -Asignacion)
%!      is nondet.
%
%   Asignacion es un assoc de cada celda oculta que toca un número a 0 o 1,
%   consistente con los números de Lineas y con los pares Celda-B de
%   Fijas.
configuracion(Lineas, Fijas, Asignacion) :-
    leer(Lineas, Ocultas, Numeros),
    list_to_assoc(Fijas, Asignacion0),
    maplist(posible(Asignacion0), Numeros),
    asignar(Ocultas, Numeros, Asignacion0, Asignacion).

%!  asignar(+Celdas:list, +Numeros:list(pair), +Asignacion0, -Asignacion)
%!      is nondet.
%
%   Asignacion extiende Asignacion0 con un valor para cada celda de Celdas
%   que no lo tenga, y después de cada valor los Numeros se pueden cumplir.
asignar([], _, Asignacion, Asignacion).
asignar([Celda|Celdas], Numeros, Asignacion0, Asignacion) :-
    (   get_assoc(Celda, Asignacion0, _)
    ->  Asignacion1 = Asignacion0
    ;   member(B, [0, 1]),
        put_assoc(Celda, Asignacion0, B, Asignacion1),
        maplist(posible(Asignacion1), Numeros)
    ),
    asignar(Celdas, Numeros, Asignacion1, Asignacion).

%!  posible(+Asignacion, +Numero:pair) is semidet.
%
%   El Numero N-Vecinas todavía se puede cumplir: las vecinas con mina no
%   pasan de N, y con las que no tienen valor alcanzan a N.
posible(Asignacion, N-Vecinas) :-
    contar(Vecinas, Asignacion, 0, 0, Minas, Libres),
    Minas =< N,
    N =< Minas + Libres.

%!  contar(+Vecinas:list, +Asignacion, +M0, +L0, -Minas, -Libres) is det.
%
%   Minas es M0 más las Vecinas con mina en Asignacion, y Libres es L0 más
%   las que todavía no tienen valor.
contar([], _, Minas, Libres, Minas, Libres).
contar([V|Vs], Asignacion, M0, L0, Minas, Libres) :-
    (   get_assoc(V, Asignacion, B)
    ->  M1 is M0 + B,
        L1 = L0
    ;   M1 = M0,
        L1 is L0 + 1
    ),
    contar(Vs, Asignacion, M1, L1, Minas, Libres).

%!  deducir(+Lineas:list(string), -Seguras:list, -Minas:list) is semidet.
%
%   Seguras son las celdas ocultas que tocan un número y no tienen mina en
%   ninguna configuración; Minas, las que la tienen en todas. Falla si no
%   hay ninguna configuración.
deducir(Lineas, Seguras, Minas) :-
    configuracion(Lineas, [], _),
    !,
    leer(Lineas, Ocultas, _),
    findall(C, ( member(C, Ocultas),
                 \+ configuracion(Lineas, [C-1], _) ),
            Seguras),
    findall(C, ( member(C, Ocultas),
                 \+ configuracion(Lineas, [C-0], _) ),
            Minas).
```

`leer/3` reduce el tablero a lo que la búsqueda necesita: las celdas
ocultas que tocan algún número, y cada número con la lista de sus vecinas
ocultas. `asignar/4` es una búsqueda en profundidad con la recursión de
Prolog: da un valor a cada celda, y después de cada valor comprueba con
`posible/2` que ningún número quedó imposible, ni con más minas que las
que indica ni sin celdas suficientes para completarlas. Una rama se
abandona en cuanto un número deja de poder cumplirse, que es lo que hace la
propagación de restricciones, aplicada a mano y solo hacia atrás.
`deducir/3` pregunta, para cada celda, si existe una configuración con la
celda fijada en 1 (o en 0): no enumera las configuraciones, busca la
primera. Las celdas que no tocan ningún número no se asignan: podrían tener
mina o no, y cada una duplicaría la cantidad de configuraciones.

```prolog
?- tablero(chico, T), deducir(T, Seguras, Minas).
T = ["#100", "1211", "01##", "01##"],
Seguras = [3-4, 4-3],
Minas = [1-1, 3-3].

?- tablero(chico, T), configuracion(T, [], A), assoc_to_list(A, L).
T = ["#100", "1211", "01##", "01##"],
A = t(3-3, 1, >, t(1-1, 1, -, t, t), t(3-4, 0, >, t, t(4-3, 0, -, t, t))),
L = [1-1-1, 3-3-1, 3-4-0, 4-3-0] ;
false.
```

El resultado es el del [capítulo 23](../capitulo-23-programacion-con-restricciones/index.md#2314-buscaminas-deducir-donde-estan-las-minas), y el tablero
chico tiene una sola configuración consistente. Sobre el tablero `grande`,
de 9 × 9 con 10 minas después de treinta jugadas, los dos resolvedores
deducen las mismas 10 celdas seguras y 7 minas; en esta máquina, en la
primera consulta de cada proceso:

```text
% búsqueda (buscaminas.pl)
% 350,833 inferences, 0.062 CPU in 0.104 seconds (60% CPU, 5613328 Lips)
% restricciones (capítulo 23)
% 140,382 inferences, 0.016 CPU in 0.014 seconds (113% CPU, 8984448 Lips)
```

Después de cincuenta jugadas, la diferencia crece: 558 454 inferencias
contra 42 919. La búsqueda comprueba todos los números después de cada
asignación; la propagación de `clpfd` revisa solo las restricciones de la
variable que cambió, y además reduce los dominios de las otras.

**Una partida sin adivinar.** El otro problema de búsqueda del Buscaminas es
la partida misma: un estado es el conjunto de celdas descubiertas, una
acción descubre una celda deducida segura, y la meta es haber descubierto
todas las celdas sin mina. `jugar/6` conoce las minas, para mostrar el
número de cada celda descubierta, y solo las usa para eso: cada jugada proviene
de `deducir/3` sobre el tablero visible.

<!-- ejemplo: capitulo-40/buscaminas.pl predicado: jugar/6 seguir/6 visible/5 simbolo/6 consulta: jugar(4, 4, [1-1, 3-3], 1-4, Jugadas, Final). -->
```prolog
%!  jugar(+Filas:integer, +Columnas:integer, +Minas:list, +Inicio:pair,
%!        -Jugadas:list, -Final) is det.
%
%   Jugadas son las celdas descubiertas, en orden, empezando por Inicio,
%   que no tiene mina: cada una se dedujo segura con lo visible hasta ese
%   momento. Final es ganada si se descubrieron todas las celdas sin mina,
%   o trabada(Lineas) si quedan celdas y ninguna es segura.
jugar(Filas, Columnas, Minas, Inicio, [Inicio|Jugadas], Final) :-
    seguir(Filas, Columnas, Minas, [Inicio], Jugadas, Final).

%!  seguir(+Filas, +Columnas, +Minas:list, +Vistas:list, -Jugadas:list,
%!         -Final) is det.
%
%   Con Vistas descubiertas, Jugadas son las que siguen hasta Final.
seguir(Filas, Columnas, Minas, Vistas, Jugadas, Final) :-
    visible(Filas, Columnas, Minas, Vistas, Lineas),
    length(Vistas, NV),
    length(Minas, NM),
    (   NV + NM =:= Filas * Columnas
    ->  Jugadas = [],
        Final = ganada
    ;   deducir(Lineas, [Celda|_], _)
    ->  Jugadas = [Celda|Jugadas1],
        seguir(Filas, Columnas, Minas, [Celda|Vistas], Jugadas1, Final)
    ;   Jugadas = [],
        Final = trabada(Lineas)
    ).

%!  visible(+Filas:integer, +Columnas:integer, +Minas:list, +Vistas:list,
%!          -Lineas:list(string)) is det.
%
%   Lineas es el tablero visible con las celdas de Vistas descubiertas:
%   cada una muestra cuántas de sus vecinas están en Minas.
visible(Filas, Columnas, Minas, Vistas, Lineas) :-
    findall(Linea,
            ( between(1, Filas, F),
              findall(X, ( between(1, Columnas, C),
                           simbolo(Filas, Columnas, Minas, Vistas, F-C, X) ),
                      Xs),
              string_chars(Linea, Xs) ),
            Lineas).

%!  simbolo(+Filas, +Columnas, +Minas:list, +Vistas:list, +Celda, -X)
%!      is det.
%
%   X es lo que muestra Celda: # si está oculta, o su número de minas
%   vecinas si está en Vistas.
simbolo(Filas, Columnas, Minas, Vistas, Celda, X) :-
    (   memberchk(Celda, Vistas)
    ->  aggregate_all(count,
                      ( vecina(Filas, Columnas, Celda, V),
                        memberchk(V, Minas) ),
                      N),
        atom_number(X, N)
    ;   X = '#'
    ).
```

```prolog
?- jugar(4, 4, [1-1, 3-3], 1-4, Jugadas, Final).
Jugadas = [1-4, 1-3, 1-2, 2-2, 2-3, 2-4, 3-2, 2-1, 3-1, 3-4, 4-1, 4-2, 4-3, 4-4],
Final = ganada.

?- jugar(2, 4, [1-2, 2-1], 1-1, Jugadas, Final).
Jugadas = [1-1],
Final = trabada(["2###", "####"]).
```

La búsqueda no necesita frontera ni retroceso: descubrir una celda segura
solo agrega información, y una celda segura sigue siéndolo después de
cualquier otra jugada. Todas las jugadas seguras llevan, en cualquier
orden, al mismo final, y `seguir/6` toma la primera sin dejar alternativas.
La celda (4, 4), que en el tablero chico no se podía deducir, se descubre
al final, cuando sus vecinas ya muestran sus números. En el segundo
tablero, el 2 de la celda de partida no dice cuáles de sus tres vecinas
ocultas tienen mina, y la partida queda trabada: ganarla exige adivinar.
Con las diez minas del tablero `grande`, la partida empezada en (1, 1) se
gana en 71 jugadas y tarda unos 6 segundos en esta máquina, casi todo en
las deducciones. `sugerencia/2`, en el Buscaminas del
[capítulo 31](../capitulo-31-ejecutables-y-distribucion/index.md), da un solo paso de esta búsqueda, con
el resolvedor de restricciones.
