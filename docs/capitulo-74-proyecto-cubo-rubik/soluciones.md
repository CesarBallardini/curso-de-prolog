# Soluciones del capítulo 74 — Proyecto: el cubo de Rubik

El código de esta página está en `ejemplos/capitulo-74/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `mejoras.pl` (y con él
`etapas.pl`, `macros.pl`, `vista.pl` y `cubo.pl`) y `descubrir.pl`, sin
modificarlos. Es `% solo-local`, porque carga otros archivos.

## 1

R R es media vuelta: repetida dos veces es la identidad. R y L giran
capas disjuntas, así que conmutan: [r, l] repetido cuatro veces es R⁴ L⁴.
Por la misma razón el conmutador R L R' L' se reduce a R R' L L', la
identidad, y su efecto es la lista vacía:

<!-- contexto: capitulo-74/soluciones.pl -->
```prolog
?- orden([r, r], A), orden([r, l], B), cambiadas([r, l, -r, -l], C).
A = 2,
B = 4,
C = 0.

?- efecto_de("R L R' L'", P).
P = [].
```

## 2

La capa del medio perpendicular a una cara es la de coordenada 0 en la
dirección de esa cara. `destino_capa/4` generaliza `destino/3` a
cualquier coordenada, y `capa_calculada/4` arma el par de términos para
una lista de capas: con `[0]` es el giro medio, y con `[-1, 0, 1]`, la
rotación del cubo entero, que usa el ejercicio 7. `term_expansion/2`
genera los dos juegos de hechos al cargar:

<!-- ejemplo: capitulo-74/soluciones.pl predicado: destino_capas/4 term_expansion/2 -->
```prolog
%!  destino_capas(+Eje, +Ks:list(integer), +I:integer, -J:integer) is det.
%
%   J es el destino de la casilla I si su capa está en Ks; si no, I.
destino_capas(Eje, Ks, I, J) :-
    casilla(I, _, p(X, Y, Z), _),
    cara(Eje, _, p(A, B, C)),
    K is A * X + B * Y + C * Z,
    (   memberchk(K, Ks)
    ->  destino_capa(Eje, K, I, J)
    ;   J = I
    ).

%!  term_expansion(+Termino, -Hechos:list) is semidet.
%
%   generar_capas se reemplaza por un hecho giro_medio/3 y un hecho
%   rotacion/3 por cada eje u, r y f.
term_expansion(generar_capas, Hechos) :-
    findall(giro_medio(Eje, A, D),
            ( member(Eje, [u, r, f]), capa_calculada(Eje, [0], A, D) ),
            Medios),
    findall(rotacion(Eje, A, D),
            ( member(Eje, [u, r, f]), capa_calculada(Eje, [-1, 0, 1], A, D) ),
            Rotaciones),
    append(Medios, Rotaciones, Hechos).
```

Girar U, la capa del medio del mismo eje y D' mueve las tres capas en el
mismo sentido: es rotar el cubo entero, y el resultado tiene cada cara de
un solo color, aunque no en su lugar:

```prolog
?- resuelto(C), giro(u, C, C1), giro_medio(u, C1, C2), mover(-d, C2, C3), rotacion(u, C, R), R == C3.
C = c(u, u, u, u, u, u, u, u, u, r, r, r, r, r, r, r, r, r, f, f, f, f, f, f, f, f, f, d, d, d, d, d, d, d, d, d, l, l, l, l, l, l, l, l, l, b, b, b, b, b, b, b, b, b),
C1 = c(u, u, u, u, u, u, u, u, u, b, b, b, r, r, r, r, r, r, r, r, r, f, f, f, f, f, f, d, d, d, d, d, d, d, d, d, f, f, f, l, l, l, l, l, l, l, l, l, b, b, b, b, b, b),
C2 = c(u, u, u, u, u, u, u, u, u, b, b, b, b, b, b, r, r, r, r, r, r, r, r, r, f, f, f, d, d, d, d, d, d, d, d, d, f, f, f, f, f, f, l, l, l, l, l, l, l, l, l, b, b, b),
C3 = R, R = c(u, u, u, u, u, u, u, u, u, b, b, b, b, b, b, b, b, b, r, r, r, r, r, r, r, r, r, d, d, d, d, d, d, d, d, d, f, f, f, f, f, f, f, f, f, l, l, l, l, l, l, l, l, l).
```

`tres_capas/2` hace la misma verificación para cualquier eje:

<!-- ejemplo: capitulo-74/soluciones.pl predicado: tres_capas/2 -->
```prolog
%!  tres_capas(+Cara, +Opuesta) is semidet.
%
%   Girar Cara, la capa del medio de su eje y Opuesta en sentido inverso
%   da la rotación del cubo entero sobre el eje de Cara.
tres_capas(Cara, Opuesta) :-
    resuelto(C0),
    mover(Cara, C0, C1),
    giro_medio(Cara, C1, C2),
    mover(-Opuesta, C2, C3),
    rotacion(Cara, C0, R),
    C3 == R,
    caras_uniformes(R).
```

```prolog
?- tres_capas(u, d).
true.
```

Las pruebas verifican además que cuatro giros medios de cada eje son la
identidad.

## 3

Un grupo es una secuencia entre paréntesis seguida de un dígito, o un
giro de la gramática de `vista.pl`. La secuencia se copia tantas veces
como indica el dígito:

<!-- ejemplo: capitulo-74/soluciones.pl predicado: grupos//1 grupo//1 veces//1 -->
```prolog
%!  grupos(-Ms:list)// is det.
%
%   Ms son los movimientos de una sucesión de grupos separados por
%   blancos: giros sueltos o secuencias entre paréntesis con repeticiones.
grupos(Ms) -->
    blancos,
    grupo(G),
    !,
    grupos(Resto),
    { append(G, Resto, Ms) }.
grupos([]) --> blancos.

%!  grupo(-Ms:list)// is semidet.
%
%   Ms son los movimientos de un grupo: una secuencia entre paréntesis,
%   repetida tantas veces como dice el dígito que la sigue, o un giro
%   escrito en la notación de Singmaster.
grupo(Ms) -->
    "(", grupos(Interior), ")", !,
    veces(N),
    { length(Copias, N),
      maplist(=(Interior), Copias),
      append(Copias, Ms) }.
grupo(Ms) --> escrito(Ms).

%!  veces(-N:integer)// is det.
%
%   N es el dígito, de 1 a 9, que sigue a un paréntesis; 1 si no hay
%   dígito.
veces(N) --> [C], { code_type(C, digit(N)), N > 0 }, !.
veces(1) --> [].
```

```prolog
?- leer_notacion_rep("(R' D' R D)2 U", Ms).
Ms = [-r, -d, r, d, -r, -d, r, d, u].
```

Una prueba compara `"(R' D' R D)2"` con el texto de la macro
`giro_esquina`.

## 4

Las esquinas tienen nombres de tres letras y las aristas, de dos:

<!-- ejemplo: capitulo-74/soluciones.pl predicado: tipo_efecto/3 capa_de_abajo_movida/1 -->
```prolog
%!  tipo_efecto(+Texto, -Esquinas:integer, -Aristas:integer) is semidet.
%
%   Esquinas y Aristas son las esquinas y las aristas que mueve la
%   secuencia de Texto.
tipo_efecto(Texto, Esquinas, Aristas) :-
    efecto_de(Texto, Piezas),
    aggregate_all(count, ( member(P, Piezas), atom_length(P, 3) ), Esquinas),
    aggregate_all(count, ( member(P, Piezas), atom_length(P, 2) ), Aristas).

%!  capa_de_abajo_movida(+Texto) is semidet.
%
%   La secuencia de Texto mueve alguna pieza de la capa de abajo.
capa_de_abajo_movida(Texto) :-
    efecto_de(Texto, Piezas),
    member(P, Piezas),
    sub_atom(P, 0, 1, _, 'D'),
    !.
```

```prolog
?- tipo_efecto("R U R' U'", E, A).
E = 4,
A = 3.

?- findall(T, (familia(3, T), capa_de_abajo_movida(T)), Ts).
Ts = [].
```

Las inserciones de la etapa 3 giran R o F, que tocan la capa de abajo,
pero cada giro de R o F se deshace dentro de la misma secuencia con U de
por medio: son conmutadores de un giro lateral con U, y U no toca la capa
de abajo. Lo que mueven de esa capa vuelve a su lugar.

## 5

`leer_red/2` separa cada línea en palabras y, según el número de línea,
sabe a qué cara o caras pertenece cada grupo de tres; cada letra liga
una casilla del cubo:

<!-- ejemplo: capitulo-74/soluciones.pl predicado: leer_red/2 leer_linea/4 -->
```prolog
%!  leer_red(+Lineas:list(string), -Cubo) is semidet.
%
%   Cubo es el cubo que red/2 escribe como Lineas. Falla si Lineas no
%   tienen la forma de red/2.
leer_red(Lineas, Cubo) :-
    length(Lineas, 9),
    functor(Cubo, c, 54),
    foldl(leer_linea(Cubo), Lineas, 0, 9).

%!  leer_linea(+Cubo, +Linea:string, +F0:integer, -F:integer) is semidet.
%
%   La línea F0 del cubo desplegado liga las casillas que muestra; F es
%   F0 + 1. Las líneas 0 a 2 son la cara u, 3 a 5 las caras del medio y
%   6 a 8 la cara d.
leer_linea(Cubo, Linea, F0, F) :-
    split_string(Linea, " ", " ", Palabras0),
    exclude(==(""), Palabras0, Palabras),
    Fila is F0 mod 3,
    (   F0 < 3
    ->  Caras = [u]
    ;   F0 < 6
    ->  Caras = [l, f, r, b]
    ;   Caras = [d]
    ),
    length(Caras, NC),
    NL is 3 * NC,
    length(Palabras, NL),
    ligar_filas(Caras, Palabras, Cubo, Fila),
    F is F0 + 1.
```

La prueba `leer_red` recorre las mezclas de las semillas 1 a 20: cada cubo
escrito con `red/2` y leído con `leer_red/2` es el mismo. Una línea con
una letra que no es de ninguna cara, o con otra cantidad de palabras,
hace fallar la lectura.

## 6

La parte pura arma cada fila con una secuencia de escape de color de
fondo por casilla y la secuencia `\e[0m` al final; `mostrar_color/1` solo
escribe las líneas:

<!-- ejemplo: capitulo-74/soluciones.pl predicado: fila_color/4 mostrar_color/1 -->
```prolog
%!  fila_color(+Cubo, +Cara, +F, -Fila:string) is det.
%
%   Fila son las tres casillas de la fila F de Cara, con sus colores, y
%   la secuencia que vuelve al color normal.
fila_color(Cubo, Cara, F, Fila) :-
    cara(Cara, K, _),
    findall(S,
            ( between(0, 2, C),
              I is 9 * K + 3 * F + C + 1,
              arg(I, Cubo, Color),
              fondo(Color, Codigo),
              format(string(S), "\e[~dm  ", [Codigo]) ),
            Casillas),
    atomic_list_concat(Casillas, A),
    string_concat(A, "\e[0m", Fila).

%!  mostrar_color(+Cubo) is det.
%
%   Escribe Cubo desplegado, en colores.
mostrar_color(Cubo) :-
    red_color(Cubo, Lineas),
    forall(member(L, Lineas), writeln(L)).
```

La prueba compara la primera línea del cubo resuelto con la cadena
esperada: seis blancos y tres casillas blancas, `"\e[47m  "`.

## 7

`orientar/3` cambia F por L, L por B, B por R y R por F. Hacer una
secuencia con esas caras equivale a deshacer la rotación del cubo sobre
el eje vertical, hacer la secuencia original y rotar de nuevo:

<!-- ejemplo: capitulo-74/soluciones.pl predicado: conjugada_por_rotacion/3 orientar_es_conjugar/1 -->
```prolog
%!  conjugada_por_rotacion(+Ms:list, -Antes, -Despues) is det.
%
%   Antes-Despues es la macro de deshacer la rotación del cubo entero
%   sobre el eje vertical, aplicar Ms y volver a rotar: rotacion(u, C1,
%   Antes) lleva C1 a Antes, así que leído en sentido inverso deshace la
%   rotación.
conjugada_por_rotacion(Ms, Antes, Despues) :-
    rotacion(u, C1, Antes),
    aplicar(Ms, C1, C2),
    rotacion(u, C2, Despues).

%!  orientar_es_conjugar(+Ms:list) is semidet.
%
%   orientar(1, Ms, Ms1) y Ms conjugada por la rotación del cubo sobre
%   el eje vertical son la misma macro.
orientar_es_conjugar(Ms) :-
    orientar(1, Ms, Ms1),
    compilar(Ms1, A-D1),
    conjugada_por_rotacion(Ms, A, D2),
    D1 == D2.
```

La prueba `orientar_es_conjugar` verifica las 30 familias de `etapas.pl`.
El sentido importa: con la rotación aplicada primero, ninguna familia
coincide, porque ese conjugado corresponde a `orientar(3, …)`.

## 8

<!-- ejemplo: capitulo-74/soluciones.pl predicado: por_etapa/2 -->
```prolog
%!  por_etapa(+Semillas:integer, -Tabla:list) is det.
%
%   Tabla tiene, por cada etapa, E-media(M)-maximo(X): la media y el
%   máximo de cuartos de vuelta que usa resolver/2 en esa etapa sobre las
%   mezclas de 25 giros de las semillas 1 a Semillas.
por_etapa(Semillas, Tabla) :-
    findall(E-N,
            ( between(1, Semillas, S),
              mezcla(S, 25, Ms),
              resuelto(C),
              aplicar(Ms, C, C1),
              resolver(C1, Pasos),
              etapa(E, _),
              aggregate_all(sum(L), ( member(paso(E, _, G), Pasos),
                                      length(G, L) ), N) ),
            Pares),
    findall(E-media(M)-maximo(X),
            ( etapa(E, _),
              findall(N, member(E-N, Pares), Ns),
              sum_list(Ns, Suma),
              M is Suma / Semillas,
              max_list(Ns, X) ),
            Tabla).
```

```prolog
?- por_etapa(50, T).
T = [1-media(10.8)-maximo(16), 2-media(32.52)-maximo(47), 3-media(48.06)-maximo(67), 4-media(23.98)-maximo(42), 5-media(52.04)-maximo(90)].
```

La etapa 5 es la más larga, con 52 cuartos de vuelta en promedio y hasta
90: sus macros tienen entre 8 y 20 giros, y cada esquina pide una o dos.
La 3 le sigue, porque cada inserción de arista tiene 8 giros y a menudo
hace falta sacar primero una arista mal colocada. La cruz de abajo, con
giros sueltos, cuesta once.

## 9

Para medir la poda, las dos búsquedas tienen que ser la misma salvo por
ella: `colocar_propio/6` es una profundización iterativa sobre los
candidatos de la etapa, con la poda activada o no por su primer
argumento, y `podada/6` recuerda si el candidato anterior giraba solo U:

<!-- ejemplo: capitulo-74/soluciones.pl predicado: colocar_propio/6 podada/6 -->
```prolog
%!  colocar_propio(+Podar, +Etapa, +Cubo, +Criterio, -Movimientos:list,
%!                 -Cubo1) is det.
%
%   Profundización iterativa sobre los candidatos de Etapa; con Podar =
%   si, sin dos candidatos de solo U seguidos.
colocar_propio(Podar, Etapa, Cubo, Criterio, Movimientos, Cubo1) :-
    length(Plan, _),
    podada(Plan, Podar, Etapa, no, Cubo, Cubo1),
    Cubo1 = Criterio,
    !,
    append(Plan, Movimientos).

%!  podada(?Plan:list, +Podar, +Etapa, +AnteriorU, +Cubo, -Cubo1)
%!      is nondet.
%
%   Cubo1 es Cubo con los candidatos de Plan aplicados; con Podar = si,
%   sin dos candidatos de solo U seguidos. AnteriorU dice si el candidato
%   anterior era de solo U.
podada([], _, _, _, Cubo, Cubo).
podada([Ms|Plan], Podar, Etapa, AnteriorU, Cubo0, Cubo) :-
    candidato(Etapa, Ms, Cubo0, Cubo1),
    (   solo_u(Ms)
    ->  \+ ( Podar == si, AnteriorU == si ),
        EsU = si
    ;   EsU = no
    ),
    podada(Plan, Podar, Etapa, EsU, Cubo1, Cubo).
```

```prolog
?- inferencias_resolver(colocar_sin_poda, 50, I1), inferencias_resolver(colocar_podado, 50, I2).
I1 = 4422071,
I2 = 4330307.
```

La poda ahorra un 2 %. En las etapas 2 a 5 hay tres candidatos de U
entre 11 y 20, de modo que los pares de dos giros de U son menos del 5 %
de los pares, y la mayoría de las piezas se colocan con uno o dos
candidatos; la prueba `solo_u/1`, además, se hace en cada nodo. La
búsqueda del [capítulo 40](../capitulo-40-busqueda-y-planificacion/index.md),
que usa `colocar/5`, hace unos 2,34 millones de inferencias con las
mismas mezclas: la manera de escribir la búsqueda pesa más que la poda.

## 10

Se reemplaza la condición final de `descubrir/3` y B se limita a U y U':

<!-- ejemplo: capitulo-74/soluciones.pl predicado: aristas_descubiertas/2 -->
```prolog
%!  aristas_descubiertas(-Probadas:integer, -N:integer) is det.
%
%   N es la cantidad de conmutadores de A, de 1 a 3 cuartos de vuelta, con
%   un cuarto de vuelta de U, que mueven exactamente tres aristas de la
%   cara de arriba y nada más; Probadas, los conmutadores examinados.
aristas_descubiertas(Probadas, N) :-
    findall(Sirve,
            ( between(1, 3, L),
              length(A, L),
              reducida(A),
              member(B, [u, -u]),
              conmutador(A, [B], S),
              compilar(S, M),
              efecto(M, Piezas),
              (   tres_aristas_de_arriba(Piezas)
              ->  Sirve = si
              ;   Sirve = no
              ) ),
            Todas),
    length(Todas, Probadas),
    aggregate_all(count, member(si, Todas), N).
```

```prolog
?- aristas_descubiertas(P, N).
P = 2664,
N = 0.
```

No hay ninguno. Un conmutador con U mueve solo lo que A lleva a la capa
de arriba y lo que eso desplaza, y A, hecho con giros de caras, lleva a
la capa de arriba esquinas junto con cada arista: un giro de una cara
lateral mueve dos esquinas y una arista de la capa de arriba. Separar las
aristas de las esquinas exige giros de las capas del medio, como los del
ejercicio 2, o secuencias más largas.

## 11

`colocar_aprendiendo/5` busca entre los candidatos de la etapa y los
aprendidos, y guarda con `assertz/1` las secuencias de tres o más
candidatos:

<!-- ejemplo: capitulo-74/soluciones.pl predicado: colocar_aprendiendo/5 aprender/4 -->
```prolog
%!  colocar_aprendiendo(+Etapa, +Cubo, +Criterio, -Movimientos:list,
%!                      -Cubo1) is det.
%
%   Como colocar/5, con los candidatos de Etapa más los aprendidos. Si
%   la secuencia hallada tiene tres o más candidatos, se agrega compilada
%   como un candidato aprendido de Etapa.
colocar_aprendiendo(Etapa, Cubo, Criterio, Movimientos, Cubo1) :-
    length(Plan, _),
    con_aprendidos(Plan, Etapa, Cubo, Cubo1),
    Cubo1 = Criterio,
    !,
    append(Plan, Movimientos),
    length(Plan, L),
    (   L >= 3
    ->  compilar(Movimientos, A-D),
        assertz(aprendido(Etapa, Movimientos, A, D))
    ;   true
    ).

%!  aprender(+Semillas:integer, -Aprendidos:integer, -Giros:integer,
%!           -Inferencias:integer) is det.
%
%   Resuelve en orden las mezclas de 25 giros de las semillas 1 a
%   Semillas, aprendiendo. Aprendidos es la cantidad de candidatos nuevos,
%   Giros el total de cuartos de vuelta e Inferencias el total de
%   inferencias.
aprender(Semillas, Aprendidos, Giros, Inferencias) :-
    retractall(aprendido(_, _, _, _)),
    statistics(inferences, I0),
    findall(N, ( between(1, Semillas, S),
                 mezcla(S, 25, Ms),
                 resuelto(C),
                 aplicar(Ms, C, C1),
                 resolver_con(colocar_aprendiendo, C1, Pasos),
                 giros(Pasos, G),
                 length(G, N) ), Ns),
    statistics(inferences, I1),
    Inferencias is I1 - I0,
    sum_list(Ns, Giros),
    aggregate_all(count, aprendido(_, _, _, _), Aprendidos).
```

```prolog
?- aprender(50, A, G, I).
A = 29,
G = 9556,
I = 434012.
```

Con las semillas 1 a 50, el programa aprende 29 secuencias. Las
inferencias bajan de 4 422 071, las de la misma búsqueda sin aprender
(`colocar_sin_poda/5` del ejercicio 9), a 434 012, porque una secuencia aprendida
reemplaza tres niveles de búsqueda por uno; los cuartos de vuelta suben
de 8 370 a 9 556, porque la búsqueda prefiere un candidato aprendido
largo a dos o tres candidatos que suman menos giros: cuenta candidatos,
no giros. Es el equilibrio que Merritt describe entre conocimiento y
búsqueda: lo aprendido acelera y alarga.

## Ejercicio 12

<!-- contexto: capitulo-74/piezas.pl -->
```prolog
?- donde_tras([f], 'DF', L, E).
L = 'FL',
E = fuera.

?- donde_tras([d], 'DF', L, E).
L = 'DR',
E = fuera.

?- donde_tras([f, f, d, d, -f, -f], 'DF', L, E).
L = 'DF',
E = en_su_lugar.

?- pieza_tras([u], 'UF', P).
P = p(u, r).
```

Un cuarto de vuelta de F, en el sentido de las agujas del reloj visto de
frente, lleva la casilla de abajo a la izquierda: la arista DF pasa al
lugar FL. Uno de D, visto desde abajo, lleva el frente a la derecha: DF
pasa a DR. En la tercera secuencia, F2 sube la arista a UF, D2 no toca
la capa de arriba, y F2 la devuelve a su lugar con los colores en el
mismo orden. La última consulta pregunta qué pieza ocupa el lugar UF
después de U: es la arista que estaba en UR, con su casilla de arriba
todavía arriba y la de la derecha ahora adelante, `p(u, r)`.

## Ejercicio 13

<!-- ejemplo: capitulo-74/soluciones_piezas.pl predicado: por_etapa/3 -->
```prolog
%!  por_etapa(+Metodo, +Semillas:integer, -Pares:list(pair)) is det.
%
%   Pares tiene un par E-N por etapa: N son los cuartos de vuelta que
%   Metodo usa en la etapa E, sumados sobre las mezclas de 25 giros de
%   las semillas 1 a Semillas.
por_etapa(Metodo, Semillas, Pares) :-
    findall(Pasos, ( between(1, Semillas, S),
                     mezcla(S, 25, Ms),
                     resuelto(C),
                     aplicar(Ms, C, C1),
                     call(Metodo, C1, Pasos) ),
            Todas),
    append(Todas, Pasos),
    findall(E-N, ( etapa(E, _),
                   aggregate_all(sum(L), ( member(paso(E, _, G), Pasos),
                                           length(G, L) ), N) ),
            Pares).
```

```prolog
?- por_etapa(resolver, 50, Sin), por_etapa(resolver_con_ayuda, 50, Con).
Sin = [1-540, 2-1626, 3-2403, 4-1199, 5-2602],
Con = [1-617, 2-1738, 3-2352, 4-1303, 5-2466].
```

La ayuda actúa solo en las etapas 1 y 2, y en las dos agrega giros: 77 y
112 cuartos de vuelta más en las cincuenta mezclas. Las etapas 3, 4 y 5
también cambian, unas a mejor y otras a peor, aunque la ayuda no actúa
en ellas. La razón es que la ayuda cambia el cubo con el que termina la
etapa 2: la capa de abajo queda igual, pero las piezas de las capas de
arriba quedan en otros lugares, y las búsquedas siguientes parten de
otro estado. La suma de esos cambios es aleatoria, y en estas mezclas
apenas compensa una parte de lo que la ayuda agrega.
