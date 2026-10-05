# Soluciones del capítulo 77 — Proyecto: el mundo del Wumpus

El código de esta página está en `ejemplos/capitulo-77/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `cueva.pl`,
`enfoques.pl` (que carga `agente.pl` y `grilla.pl`), `riesgo.pl` y
`cazador.pl`, sin modificarlos; los predicados que no exportan
se llaman con el nombre del módulo delante, como `enfoques:sin_pozo/2`.
Es `% solo-local`, porque carga otros archivos.

## 1

La frontera son las dos vecinas de (1, 1), (1, 2) y (2, 1), y la brisa
exige al menos un pozo entre ellas: hay tres mundos. Con el peso
$(1/5)^k (4/5)^{2-k}$, el de dos pozos pesa 1/25 y cada uno de los de un
pozo, 4/25. (1, 2) está en el de dos pozos y en uno de los otros, así que
su probabilidad es (1/25 + 4/25) / (9/25) = 5/9. Ninguna celda es segura
ni tiene un pozo probado: las tres son desconocidas, y (3, 3), fuera de
la frontera, conserva la probabilidad 1/5.

<!-- contexto: capitulo-77/soluciones.pl -->
```prolog
?- conocer(4, [1-1-[brisa]], K), mundos_pozos(K, M), probabilidad_pozo(K, 1-2, P), clasificar(K, 1-2, C12), clasificar(K, 2-2, C22).
K = c(4, 1-1, [1-1-[brisa]], no, si, vivo([]), []),
M = [[1-2, 2-1], [1-2], [2-1]],
P = 0.5555555555555555,
C12 = C22, C22 = desconocida.
```

## 2

Una búsqueda en anchura por niveles: el nivel siguiente son las salas
vecinas de las del nivel actual que todavía no se vieron.

<!-- ejemplo: capitulo-77/soluciones.pl predicado: distancia/3 distancia_/5 mayor_distancia/1 -->
```prolog
%!  distancia(+A, +B, -D:integer) is det.
%
%   D es la cantidad mínima de túneles de la sala A a la sala B.
distancia(A, B, D) :-
    distancia_([A], [A], B, 0, D).

%!  distancia_(+Nivel:list, +Vistas:list, +B, +D0:integer, -D:integer)
%!      is det.
%
%   Búsqueda en anchura por niveles: Nivel son las salas a distancia D0.
distancia_(Nivel, Vistas, B, D0, D) :-
    (   memberchk(B, Nivel)
    ->  D = D0
    ;   findall(V,
                ( member(S, Nivel), tunel(S, V), \+ memberchk(V, Vistas) ),
                Vs0),
        sort(Vs0, Siguiente),
        append(Vistas, Siguiente, Vistas1),
        D1 is D0 + 1,
        distancia_(Siguiente, Vistas1, B, D1, D)
    ).

%!  mayor_distancia(-D:integer) is det.
%
%   D es la mayor distancia entre dos salas de la cueva.
mayor_distancia(D) :-
    aggregate_all(max(X), ( sala(A), sala(B), distancia(A, B, X) ), D).
```

```prolog
?- mayor_distancia(D).
D = 5.
```

Desde cualquier sala, todas las demás están a cinco túneles o menos. Una
flecha que recorre cinco salas por túneles puede llegar a cualquier sala
de la cueva: con la ruta correcta, el jugador puede alcanzar al wumpus
esté donde esté. Cinco es el máximo útil.

## 3

<!-- ejemplo: capitulo-77/soluciones.pl predicado: jugada_estricta/5 -->
```prolog
%!  jugada_estricta(+Orden, +E0, -E, -Resultado, -Mensajes:list) is det.
%
%   Como jugada/5, pero una ruta que pasa por la sala del jugador o repite
%   la sala de dos pasos antes se rechaza con el mensaje ruta_invalida.
jugada_estricta(disparar(Ruta), E0, E, Resultado, Mensajes) :-
    E0 = j(J, _, _, _, _, _),
    (   memberchk(J, Ruta)
    ;   append(_, [A, _, A|_], [J|Ruta])
    ),
    !,
    E = E0,
    Resultado = sigue,
    Mensajes = [ruta_invalida].
jugada_estricta(Orden, E0, E, Resultado, Mensajes) :-
    jugada(Orden, E0, E, Resultado, Mensajes).
```

`append(_, [A, _, A|_], [J|Ruta])` busca en la ruta, con la sala del
jugador adelante, una sala igual a la de dos pasos antes. El corte deja
la primera cláusula como la única cuando la ruta se rechaza.

```prolog
?- nueva_partida(7, E0), jugada_estricta(disparar([4, 14, 4]), E0, E, R, Ms).
E0 = E, E = j(5, 3, [17, 16], [6, 9], 5, 220562521),
R = sigue,
Ms = [ruta_invalida].
```

## 4

El agente prudente sale sin el oro en las semillas 1, 2, 3, 5, 6, 7, 9 y
10. `conocimiento_final/2` reconstruye su conocimiento al salir a partir
de las acciones de la partida:

<!-- ejemplo: capitulo-77/soluciones.pl predicado: conocimiento_final/2 -->
```prolog
%!  conocimiento_final(+Semilla:integer, -K) is det.
%
%   K es el conocimiento del agente prudente al terminar su partida en el
%   mundo sembrado con Semilla: las celdas que visitó, en orden, con sus
%   percepciones.
conocimiento_final(Semilla, K) :-
    mundo_sembrado(Semilla, M),
    jugar(M, final(_, _, Acciones)),
    findall(C, member(ir(C), Acciones), Cs),
    foldl(enfoques:agregar_nueva, Cs, [1-1], Celdas),
    maplist(enfoques:con_percepciones(M), Celdas, Vs),
    conocer(4, Vs, K).
```

```prolog
?- conocimiento_final(2, K), frontera(K, F).
K = c(4, 2-1, [1-1-[], 1-2-[], 1-3-[brisa, hedor], 2-2-[brisa], 2-1-[brisa]], no, si, vivo([]), []),
F = [1-4, 2-3, 3-1, 3-2].

?- conocimiento_final(6, K), frontera(K, F).
K = c(4, 2-1, [1-1-[], 1-2-[brisa], 2-1-[brisa]], no, si, vivo([]), []),
F = [1-3, 2-2, 3-1].
```

En las semillas 1, 5 y 10 hay brisa en (1, 1): las dos vecinas tienen
probabilidad 5/9 de pozo, como en el ejercicio 1, y el agente sale sin
moverse. En la semilla 6 el conocimiento es el de la sección «The Wumpus
World Revisited»: cada celda de la frontera está en algún mundo
consistente con pozo. En la semilla 2, (1, 4) puede tener el wumpus,
porque (1, 3) tuvo hedor y (1, 4) no tiene ninguna vecina visitada sin
hedor, y (2, 3), (3, 1) y (3, 2) son vecinas de celdas con brisa y
aparecen con pozo en algún mundo. En todos los casos `clasificar/3` da
`desconocida` para cada celda de la frontera: ningún mundo consistente
la excluye.

## 5

La regla nueva busca dos celdas con hedor y sus vecinas comunes sin
visitar que ninguna vecina visitada sin hedor descarta; si queda una
sola, el wumpus está allí:

<!-- ejemplo: capitulo-77/soluciones.pl predicado: segura2/2 dos_hedores/2 -->
```prolog
%!  segura2(+K, +C) is semidet.
%
%   Las reglas, con la de dos hedores, prueban que C es segura.
segura2(K, C) :-
    enfoques:sin_pozo(K, C),
    (   enfoques:sin_wumpus(K, C)
    ->  true
    ;   dos_hedores(K, W),
        W \== C
    ).

%!  dos_hedores(+K, -W) is semidet.
%
%   Dos celdas visitadas con hedor tienen una sola vecina común sin
%   visitar que no está descartada por una vecina visitada sin hedor: el
%   wumpus está en W.
dos_hedores(K, W) :-
    K = c(N, _, _, _, _, _, _),
    once(( enfoques:percibio(K, A, hedor),
           enfoques:percibio(K, B, hedor),
           A @< B,
           findall(D,
                   ( vecina(N, A, D),
                     vecina(N, B, D),
                     \+ enfoques:visitada(K, D),
                     \+ ( vecina(N, D, E),
                          enfoques:visitada(K, E),
                          \+ enfoques:percibio(K, E, hedor) ) ),
                   [W]) )).
```

```prolog
?- numlist(1, 20, Ss), comparar_reglas2(Ss, R).
Ss = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
R = r(192, 0).
```

Las reglas prueban ahora las 192 celdas, y coinciden con los mundos
consistentes en las 85 instantáneas. En otros mundos pueden aparecer
combinaciones que ninguna de las reglas prevé, como un hedor cuya
segunda candidata queda descartada por la ubicación de un pozo; los
mundos consistentes las cubren sin cambios.

## 6

`satisfacible/1` aplica primero la propagación unitaria: una cláusula de
un solo literal lo hace verdadero. Si no hay ninguna, separa casos con
el primer literal de la primera cláusula. `asignar/3` quita las
cláusulas que el literal satisface y el literal opuesto de las demás:

<!-- ejemplo: capitulo-77/soluciones.pl predicado: satisfacible/1 asignar/3 -->
```prolog
%!  satisfacible(+Clausulas:list) is semidet.
%
%   Las Clausulas, listas de literales +A y -A sin variables, tienen un
%   modelo: DPLL con propagación unitaria y separación de casos.
satisfacible(Clausulas) :-
    (   Clausulas == []
    ->  true
    ;   memberchk([], Clausulas)
    ->  fail
    ;   member([L], Clausulas)
    ->  asignar(L, Clausulas, Resto),
        satisfacible(Resto)
    ;   Clausulas = [[L|_]|_],
        (   asignar(L, Clausulas, Resto)
        ;   opuesto(L, M),
            asignar(M, Clausulas, Resto)
        ),
        satisfacible(Resto)
    ->  true
    ).

%!  asignar(+L, +Clausulas:list, -Resto:list) is det.
%
%   Resto son las Clausulas con L verdadero: sin las que contienen L, y
%   sin el opuesto de L en las demás.
asignar(L, Clausulas, Resto) :-
    opuesto(L, M),
    exclude(memberchk(L), Clausulas, Sin),
    maplist(quitar(M), Sin, Resto).
```

`clausulas_conocimiento/2` escribe el conocimiento directamente en forma
clausal: una brisa da una cláusula con los pozos vecinos, la falta de
brisa una cláusula unitaria negativa por vecina, y el wumpus una cláusula
con todas las celdas y una de dos literales por cada par. Una celda es
segura si el conocimiento más `pozo(C)` no tiene modelo, y tampoco más
`wumpus(C)`.

```prolog
?- comparar_dpll([1, 2, 3, 4, 5], R).
R = r(83, 0, 5839444).
```

El DPLL coincide con los mundos consistentes en todas las instantáneas de
las semillas 1 a 5 y usa 5,8 millones de inferencias; `clpb`, con las
mismas instantáneas, usa 70 millones, y tarda 14 segundos, fuera del
límite de una consulta del curso. La diferencia está en que el DPLL no
construye nada: la propagación unitaria resuelve casi todo, porque la
mayor parte del conocimiento son cláusulas unitarias, y separa casos
solo sobre la frontera.

## 7

`barrer_umbrales/2` mide los nueve umbrales. Los resultados, con las
semillas 1 a 100:

| Umbral | Oro | Muertes | Sin oro | Puntaje medio |
|---|---|---|---|---|
| 0,1 | 29 | 0 | 71 | 275 |
| 0,2 y 0,3 | 29 | 2 | 69 | 255 |
| 0,4 | 37 | 12 | 51 | 233 |
| 0,5 | 37 | 15 | 48 | 203 |
| 0,6 a 0,9 | 47 | 47 | 6 | −19 |

```prolog
?- numlist(1, 100, Ss), medir(riesgo(0.1), Ss, R).
Ss = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
R = r(29, 0, 71, 275).
```

El mayor puntaje es el del umbral 0,1: gana cuatro oros más que el agente
prudente, gracias a la flecha y a celdas con un riesgo muy bajo, sin
ninguna muerte. El mayor número de oros, 47, es el de los umbrales de
0,6 en adelante, con 47 muertes. No coinciden porque una muerte resta
mil puntos, lo mismo que suma un oro: un umbral alto gana oros en los
mundos donde acierta, pero en los mismos mundos, con otra ubicación de
los pozos, pierde otro tanto. Los resultados cambian por saltos, porque
los riesgos de la frontera toman pocos valores, como 5/9 o 25/29.

## 8

`mundo_sembrado/3` repite `mundo_sembrado/2` con el tamaño como
argumento; con N = 4 da los mismos mundos, y una prueba lo verifica.
`medir_tamano/3` juega el agente prudente en 20 mundos:

```prolog
?- medir_tamano(5, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], R).
R = r(7, 54909, 7).

?- medir_tamano(6, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], R).
R = r(3, 85950, 8).
```

En 5 × 5 gana 7 de 20, con 55 000 inferencias por partida y una frontera
de a lo sumo 7 celdas; en 6 × 6, 3 de 20, con 86 000 y una frontera de 8.
El costo crece poco, porque el agente prudente se detiene pronto: el oro
está en promedio más lejos, y el camino hasta él cruza más celdas donde
ninguna vecina es segura. La frontera, no la cueva,
decide el costo: 2 elevado a su tamaño. Con 8 celdas son 256
subconjuntos; con 20, más de un millón por decisión, que es el tamaño en
que conviene podar mientras se genera, comprobando cada celda visitada en
cuanto todas sus vecinas tienen valor, en lugar de generar primero y
probar después.

## 9

`decidir_k/3` dispara si hay a lo sumo K salas posibles y, si no, delega
en `decidir/2` de `cazador.pl`; `cazar_k/4` repite el ciclo de jugadas
de `cazar/3` con esa decisión:

<!-- ejemplo: capitulo-77/soluciones.pl predicado: decidir_k/3 -->
```prolog
%!  decidir_k(+Kmax:integer, +K, -Orden) is det.
%
%   Dispara hacia la primera sala posible del wumpus si hay a lo sumo Kmax;
%   si no, decide como el agente de cazador.pl.
decidir_k(Kmax, K, Orden) :-
    K = k(Sala, _, _, _, Flechas),
    mundos(K, wumpus, 1, Wumpus),
    append(Wumpus, Ws0),
    sort(Ws0, Ws),
    length(Ws, NW),
    (   Flechas > 0,
        NW > 0,
        NW =< Kmax
    ->  Ws = [Blanco|_],
        once(cazador:camino(Sala, Blanco, _, Ruta)),
        Orden = disparar(Ruta)
    ;   cazador:decidir(K, Orden)
    ).
```

```prolog
?- numlist(1, 100, Ss), medir_caza_k(2, Ss, R).
Ss = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
R = [gana-75, pierde(pozo)-16, pierde(sin_flechas)-2, pierde(wumpus)-7].
```

Con las semillas 101 a 300, K = 1 gana 152 partidas, K = 2 gana 127 y
K = 3, 123. Disparar con dudas multiplica las muertes por el wumpus, de
3 a 26 y 36: una flecha que falla lo despierta, el agente descarta sus
observaciones del wumpus, y este puede moverse a la sala del agente.

## 10

`soluble/1` busca en anchura, desde (1, 1), un camino al oro que no pase
por pozos; el wumpus no cuenta como obstáculo, porque la flecha puede
matarlo:

<!-- ejemplo: capitulo-77/soluciones.pl predicado: soluble/1 alcanzable/5 -->
```prolog
%!  soluble(+M) is semidet.
%
%   En el mundo M, el oro está en una celda sin pozo a la que se llega
%   desde (1, 1) sin pasar por pozos.
soluble(mundo(N, Pozos, _, Oro)) :-
    \+ memberchk(Oro, Pozos),
    alcanzable(N, Pozos, [1-1], [1-1], Oro).

%!  alcanzable(+N:integer, +Pozos:list, +Frontera:list, +Vistas:list,
%!             +Meta) is semidet.
%
%   Meta se alcanza desde las celdas de Frontera sin pasar por Pozos.
alcanzable(N, Pozos, Frontera, Vistas, Meta) :-
    (   memberchk(Meta, Frontera)
    ->  true
    ;   findall(V,
                ( member(C, Frontera),
                  vecina(N, C, V),
                  \+ memberchk(V, Pozos),
                  \+ memberchk(V, Vistas) ),
                Vs0),
        sort(Vs0, Siguiente),
        Siguiente \== [],
        append(Vistas, Siguiente, Vistas1),
        alcanzable(N, Pozos, Siguiente, Vistas1, Meta)
    ).
```

```prolog
?- numlist(1, 100, Ss), contar_solubles(Ss, N).
Ss = [1, 2, 3, 4, 5, 6, 7, 8, 9|...],
N = 77.
```

De los 77 mundos solubles, el agente prudente gana 25 y el que siempre
arriesga 47. Ningún agente puede ganar todos: un agente solo conoce lo
que percibió, y en muchos mundos el camino al oro pasa por una celda que,
con lo percibido, tiene la misma probabilidad de pozo que otra que sí lo
tiene. Con brisa en (1, 1), por ejemplo, las dos vecinas son
indistinguibles para cualquier agente: entre los mundos con ese
comienzo, uno que entra en (1, 2) muere en todos los que tienen el pozo
allí, aunque sean solubles por (2, 1).

## 11

`jugar_humano/2` muestra las percepciones de la celda con mensajes de tú,
lee una acción con la gramática `accion//1` y la ejecuta con `actuar/6`
de la versión 2; una celda que no es vecina, que `actuar/6` rechaza con
un error de dominio, se trata como una orden no entendida. Una partida
que gana la cueva de la figura 7.2:

```text
Estás en la celda 1-1.
> ir 1 2
Estás en la celda 1-2.
Sientes un hedor.
> ir 2 2
Estás en la celda 2-2.
> ir 2 3
Estás en la celda 2-3.
Sientes un hedor.
Sientes una brisa.
Ves un brillo.
> tomar
Estás en la celda 2-3.
Sientes un hedor.
Sientes una brisa.
> ir 2 2
Estás en la celda 2-2.
> ir 1 2
Estás en la celda 1-2.
Sientes un hedor.
> ir 1 1
Estás en la celda 1-1.
> salir
Sales de la cueva con el oro. Tu puntaje es 992.
```

<!-- ejemplo: capitulo-77/soluciones.pl predicado: jugar_humano/2 humano/5 accion//1 -->
```prolog
%!  jugar_humano(+In, +M) is det.
%
%   Juega el mundo M con las acciones que llegan, una por línea, por el
%   stream In, hasta que la partida termina o la entrada se acaba.
jugar_humano(In, M) :-
    estado_inicial(E),
    humano(In, M, E, [], 0).

%!  humano(+In, +M, +E, +Extras:list, +P0:integer) is det.
%
%   Muestra las percepciones del estado E, lee una acción y la ejecuta.
humano(In, M, E0, Extras, P0) :-
    E0 = e(C, _, _, _),
    percepciones(M, E0, Ps0),
    append(Ps0, Extras, Ps),
    format("Estás en la celda ~w.~n", [C]),
    forall(member(P, Ps), ( texto_percepcion(P, T), format("~w~n", [T]) )),
    format("> "),
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  true
    ;   string_codes(Linea, Codigos),
        phrase(accion(A), Codigos),
        catch(actuar(M, A, E0, E, Extras1, Fin),
              error(domain_error(celda_vecina, _), _), fail)
    ->  grilla:costo(A, Fin, Costo),
        P is P0 + Costo,
        (   Fin == sigue
        ->  humano(In, M, E, Extras1, P)
        ;   texto_fin(Fin, T),
            format("~w Tu puntaje es ~w.~n", [T, P])
        )
    ;   format("No entiendo. Escribe ir X Y, tomar, ~w~n",
               ["disparar y una dirección, o salir."]),
        humano(In, M, E0, Extras, P0)
    ).

%!  accion(-A)// is semidet.
%
%   Una acción escrita.
accion(ir(X-Y)) -->
    blanks, "ir", blank, blanks, integer(X), blank, blanks, integer(Y),
    blanks.
accion(tomar) -->
    blanks, "tomar", blanks.
accion(salir) -->
    blanks, "salir", blanks.
accion(disparar(D)) -->
    blanks, "disparar", blank, blanks, string_without(" ", Cs), blanks,
    { atom_codes(D, Cs),
      memberchk(D, [norte, sur, este, oeste]) }.
```

## 12

El axioma tiene la forma de los de `temporal.pl`: el fluente vale en T
si la acción de T − 1 lo produjo, o si valía en T − 1. `soluciones.pl`
reexporta `temporal.pl`, de modo que `hizo/3`, `percibio/3`, `traducir/4`
e `historia/3` están disponibles:

<!-- ejemplo: capitulo-77/soluciones.pl predicado: tiene_oro/2 -->
```prolog
%!  tiene_oro(+H, +T:integer) is semidet.
%
%   En el momento T de la historia H el agente lleva el oro: en un momento
%   anterior lo tomó mientras percibía el brillo. Ninguna acción lo suelta,
%   así que una vez tomado se conserva.
tiene_oro(H, T) :-
    T > 0,
    T0 is T - 1,
    (   hizo(H, tomar, T0),
        percibio(H, brillo, T0)
    ->  true
    ;   tiene_oro(H, T0)
    ).
```

<!-- contexto: capitulo-77/soluciones.pl -->
```prolog
?- mundo(figura_7_2, M), jugar(M, final(_, _, Plan)), traducir(Plan, p(1-1, este), As, _), historia(M, As, H), findall(T, (between(0, 18, T), tiene_oro(H, T)), Ts).
M = mundo(4, [3-1, 3-3, 4-4], 1-3, 2-3),
Plan = [ir(1-2), ir(1-1), ir(2-1), ir(2-2), ir(2-3), tomar, ir(2-2), ir(... - ...), ir(...)|...],
As = [girar(izquierda), avanzar, girar(izquierda), girar(izquierda), avanzar, girar(izquierda), avanzar, girar(izquierda), avanzar|...],
H = h(4, [[], [], [hedor], [hedor], [hedor], [], [], [...]|...], [girar(izquierda), avanzar, girar(izquierda), girar(izquierda), avanzar, girar(izquierda), avanzar, girar(...)|...]),
Ts = [11, 12, 13, 14, 15, 16, 17, 18].
```

La acción del momento 10 es `tomar`, en (2, 3), donde el agente percibe
el brillo: el fluente vale desde el momento 11 hasta el final. La
segunda rama de la condicional, `tiene_oro(H, T0)`, es la que resuelve el
problema del marco: dice que el oro se conserva mientras ninguna acción lo
suelta, y como entre las acciones del libro no hay ninguna que lo suelte,
no necesita ninguna condición. La condición `percibio(H, brillo, T0)`
impide que un `tomar` en una celda sin oro produzca el fluente.
