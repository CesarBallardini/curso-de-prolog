# Soluciones del capítulo 84 — Proyecto: análisis de registros

El código de esta página está en `ejemplos/capitulo-84/soluciones.pl`, con
sus pruebas en `soluciones.plt`. El archivo carga `aprendido.pl`, que
carga las versiones 1, 3 y 4 (`registro.pl`, `informes.pl` y
`umbrales.pl`) y el perceptrón del
[capítulo 69](../capitulo-69-proyecto-perceptron/index.md), `comun.pl` y
`paralelo.pl`, sin modificarlos. Es `% solo-local`, porque lee archivos y
carga otros archivos.

## 1

El pedido 5 existe en las dos corridas del jueves, y cada uno tiene su
respuesta: la regla junta cada pedido con las dos, cuatro pares en total.
El 397, el pedido pendiente de la primera corrida, no tiene respuesta, y
la segunda corrida terminó en el 23, así que `sin_respuesta_hechos/2` lo
encuentra:

<!-- contexto: capitulo-84/soluciones.pl -->
```prolog
?- cargar_hechos(registros('2026-10-01.log'), M), findall(C, par_hechos(M, 5, C), Cs).
M = '2026-10-01',
Cs = [200, 200, 200, 200].

?- cargar_hechos(registros('2026-10-01.log'), M), sin_respuesta_hechos(M, 397).
M = '2026-10-01'.
```

El caso que la carga como programa no ve es un pedido pendiente cuyo
número se repite, con respuesta, en la corrida siguiente.
`pendientes_de/2` aplica `paso/4` a una lista de términos y conserva los
pendientes; la lista de `registro_enganoso/1` tiene ese caso:

<!-- ejemplo: capitulo-84/soluciones.pl predicado: pendientes_de/2 paso_pendientes/3 registro_enganoso/1 -->
```prolog
%!  pendientes_de(+Terminos:list, -Pendientes:list) is det.
%
%   Pendientes son los pedidos sin respuesta de los Terminos de un
%   registro, leídos en orden con paso/4 de la versión 1.
pendientes_de(Terminos, Pendientes) :-
    empty_assoc(A0),
    foldl(paso_pendientes, Terminos, A0-[], A-P0),
    cerrar(A, P1),
    append(P0, P1, Pendientes).

% paso_pendientes(T, A0-P0, A-P): paso/4 que guarda solo los pendientes.
paso_pendientes(Termino, A0-P0, A-P) :-
    paso(Termino, A0, A, Producidos),
    include(es_pendiente, Producidos, Nuevos),
    append(P0, Nuevos, P).

% registro_engañoso(Terminos): dos corridas en las que el pedido 1 de la
% primera queda sin respuesta, y el de la segunda la tiene.
registro_enganoso([ server(started, 0),
                    request(1, 1.0, [peer(a), method(get), path('/x')]),
                    server(started, 5),
                    request(1, 6.0, [peer(b), method(get), path('/y')]),
                    completed(1, 0.1, 10, 200, ok),
                    server(stopped, 9) ]).
```

```prolog
?- registro_enganoso(Ts), pendientes_de(Ts, P).
Ts = [server(started, 0), request(1, 1.0, [peer(a), method(get), path('/x')]), server(started, 5), request(1, 6.0, [peer(b), method(get), path('/y')]), completed(1, 0.1, 10, 200, ok), server(stopped, 9)],
P = [pendiente(1.0, a, get, '/x')].
```

Cargados como hechos, esos términos tienen un `completed(1, …)`, y la
consulta de Triska no encuentra ningún pedido sin respuesta. El
`server(started, 5)` es lo que los separa, y solo la lectura en orden lo
tiene en cuenta.

## 2

El recurso es el primer segmento de la ruta. `split_string/4` divide la
ruta por las barras; como empieza con una, el primer elemento es la
cadena vacía. Las filas se ordenan de más a menos pedidos decorándolas
con la cantidad cambiada de signo, el
[patrón 23](../patrones.md#23-decorar-ordenar-desdecorar):

<!-- ejemplo: capitulo-84/soluciones.pl predicado: por_recurso/2 recurso_cpu/2 recurso/2 fila/2 menos_pedidos/2 escribir_por_recurso/1 -->
```prolog
%!  por_recurso(+Archivo, -Filas:list) is det.
%
%   Filas tiene una fila(Recurso, Pedidos, Cpu) por recurso del registro
%   Archivo, el primer segmento de la ruta: la cantidad de pedidos y el
%   tiempo de CPU medio, de más a menos pedidos.
por_recurso(Archivo, Filas) :-
    leer_registro(Archivo, Pedidos),
    maplist(recurso_cpu, Pedidos, Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    maplist(fila, Grupos, Filas0),
    map_list_to_pairs(menos_pedidos, Filas0, Decoradas),
    keysort(Decoradas, PorPedidos),
    pairs_values(PorPedidos, Filas).

% recurso_cpu(Pedido, Recurso-Cpu): el recurso del Pedido y su CPU.
recurso_cpu(pedido(_, _, _, Ruta, _, Cpu), Recurso-Cpu) :-
    recurso(Ruta, Recurso).

%!  recurso(+Ruta:atom, -Recurso:atom) is det.
%
%   Recurso es el primer segmento de la Ruta, con la barra: el de
%   '/alumnos/123' es '/alumnos'.
recurso(Ruta, Recurso) :-
    split_string(Ruta, "/", "", ["", Primero|_]),
    atom_concat('/', Primero, Recurso).

% fila(Ruta-Cpus, Fila): la fila de una ruta.
fila(Ruta-Cpus, fila(Ruta, N, Media)) :-
    length(Cpus, N),
    sum_list(Cpus, Suma),
    Media is Suma / N.

% menos_pedidos(Fila, K): K es la cantidad de pedidos con el signo
% cambiado, para ordenar de más a menos.
menos_pedidos(fila(_, N, _), K) :-
    K is -N.

%!  escribir_por_recurso(+Filas:list) is det.
%
%   Escribe las Filas en una tabla alineada, con el tiempo medio en
%   milisegundos.
escribir_por_recurso(Filas) :-
    format("recurso              pedidos  cpu (ms)~n"),
    forall(member(fila(R, N, C), Filas),
           ( Ms is C * 1000,
             format("~w~t~20|~t~d~28|~t~2f~38|~n", [R, N, Ms]) )).
```

```text
?- por_recurso(registros('2026-10-01.log'), _F), escribir_por_recurso(_F).
recurso              pedidos  cpu (ms)
/sesion                  158     60.06
/materias                122      3.42
/mis-inscripciones        59      3.26
/alumnos                  46      2.57
/ranking                  34      3.92
```

`/sesion` es el recurso más pedido del jueves por los dos ataques, y el
más caro: cada inicio de sesión calcula el resumen de la contraseña. Su
media, 60 milisegundos, es más alta que las 45 de un inicio de sesión
normal porque incluye la hora lenta de las 12.

## 3

La gramática repite la del formato común, con los no terminales de
`comun.pl` llamados con el módulo delante, y agrega antes del final los
dos campos, que pueden faltar juntos:

<!-- ejemplo: capitulo-84/soluciones.pl predicado: linea_combinada//1 agregados//0 entre_comillas//0 -->
```prolog
%!  linea_combinada(-Pedido)// is semidet.
%
%   Una línea del formato común, o del combinado, que agrega la página de
%   origen y el programa del cliente entre comillas.
linea_combinada(pedido(Instante, Ip, Metodo, Ruta, Codigo, sin_medir)) -->
    comun:ip(Ip), " ", comun:campo, " ", comun:campo, " [",
    comun:fecha(Instante), "] \"", comun:metodo(Metodo), " ",
    comun:ruta(Ruta), " HTTP/", comun:version, "\" ",
    integer(Codigo), " ", comun:bytes, agregados, eos.

% agregados//: los dos campos del formato combinado, o nada.
agregados -->
    " ", entre_comillas, " ", entre_comillas,
    !.
agregados -->
    [].

% entre_comillas//: un texto entre comillas, sin comillas dentro.
entre_comillas -->
    "\"", string_without(`"`, _), "\"".
```

```prolog
?- phrase(linea_combinada(P), `1.2.3.4 - - [01/Oct/2026:08:00:00 -0300] "GET /a HTTP/1.1" 200 9 "-" "curl/8.0"`).
P = pedido(1790852400.0, ip(1, 2, 3, 4), get, '/a', 200, sin_medir).
```

El corte de `agregados//0` no cambia las respuestas: en una línea con los
dos campos, la segunda cláusula fallaría igual en `eos//0`. Lo que evita
es la alternativa pendiente. Una línea con un solo campo
agregado no es de ninguno de los dos formatos, y la gramática falla.

## 4

<!-- ejemplo: capitulo-84/soluciones.pl predicado: metricas_presentes/2 sin_pedidos/1 anomalias_presentes/3 metricas_anomalas/3 -->
```prolog
%!  metricas_presentes(+Pedidos:list, -Horas:list) is det.
%
%   Como metricas/2, pero solo con las horas en las que hubo pedidos: las
%   que aparecen en los Pedidos.
metricas_presentes(Pedidos, Horas) :-
    metricas(Pedidos, Todas),
    exclude(sin_pedidos, Todas, Horas).

% sin_pedidos(Hora): la hora no tiene pedidos.
sin_pedidos(hora(_, m(0, _, _, _))).

%!  anomalias_presentes(+Archivo, +Umbrales:list, -Anomalias:list) is det.
%
%   Anomalias son las anomalia/4 de las horas con pedidos del registro
%   Archivo, con los Umbrales.
anomalias_presentes(Archivo, Umbrales, Anomalias) :-
    leer_registro(Archivo, Pedidos),
    metricas_presentes(Pedidos, Horas),
    findall(A, anomalia(Umbrales, Horas, A), Anomalias).

%!  metricas_anomalas(+Modelo, +Archivo, -Pares:list) is det.
%
%   Pares son los pares Hora-Metrica de las anomalías de las horas con
%   pedidos del registro Archivo, con los umbrales de referencia
%   ajustados con el Modelo.
metricas_anomalas(Modelo, Archivo, Pares) :-
    umbrales_de_referencia(Modelo, Umbrales),
    anomalias_presentes(Archivo, Umbrales, Anomalias),
    findall(H-M, member(anomalia(H, M, _, _), Anomalias), Pares).
```

```prolog
?- metricas_anomalas(mediana_mad(3.5), registros('2026-10-01.log'), P).
P = [10-pedidos, 10-fallos, 10-cpu, 12-cpu, 14-fallos, 14-cpu].
```

Desaparecen las dos horas de la caída, las 17 y las 18: sin pedidos, no
aparecen en ningún pedido, y una métrica que recorre solo las horas de
los pedidos no las examina. La anomalía más grave del día, que el
servicio no atendió durante casi dos horas, es justo la que una métrica
sin ceros no puede ver. Es la advertencia de Denning: los períodos sin
eventos tienen que contarse, o lo que se mide queda sesgado hacia los
períodos con actividad.

## 5

Con 35 ceros de 36, la mediana es 0, y la mediana de las distancias a 0
también: la MAD es 0, y el intervalo se reduce al punto 0.

```prolog
?- valores_de_referencia(no_encontradas, Vs), ajustar(mediana_mad(3.5), Vs, I).
Vs = [0, 0, 0, 0, 0, 0, 0, 0, 0|...],
I = entre(0.0, 0.0).
```

Con ese intervalo, una sola ruta inexistente, un error de tipeo en el
navegador de un alumno, es una anomalía. La solución es una dispersión
mínima: la MAD, o el mínimo, el que sea mayor.

<!-- ejemplo: capitulo-84/soluciones.pl predicado: ajustar_con_minimo/4 -->
```prolog
%!  ajustar_con_minimo(+Z, +Minimo, +Valores:list(number), -Intervalo)
%!      is det.
%
%   Como ajustar(mediana_mad(Z), Valores, Intervalo), con la MAD
%   reemplazada por Minimo cuando es menor: una dispersión mínima para que
%   el intervalo no se reduzca a un punto.
ajustar_con_minimo(Z, Minimo, Valores, entre(Inferior, Superior)) :-
    mad(Valores, Mediana, Mad),
    Dispersion is max(Mad, Minimo),
    Ancho is Z * Dispersion / 0.6745,
    Inferior is Mediana - Ancho,
    Superior is Mediana + Ancho.
```

```prolog
?- valores_de_referencia(no_encontradas, Vs), ajustar_con_minimo(3.5, 1, Vs, I).
Vs = [0, 0, 0, 0, 0, 0, 0, 0, 0|...],
I = entre(-5.189028910303929, 5.189028910303929).
```

Con un mínimo de 1, el límite es 5,2: hasta cinco rutas inexistentes en
una hora son normales, y las diez del miércoles no. El mínimo es la
resolución de la métrica: con contadores enteros, una diferencia de 1 es
la menor posible, y un modelo que la considera grande es demasiado
sensible.

## 6

<!-- ejemplo: capitulo-84/soluciones.pl predicado: ajustar_cuantil/3 umbrales_cuantil/2 -->
```prolog
%!  ajustar_cuantil(+P:number, +Valores:list(number), -Limite) is det.
%
%   Limite es el valor de la posición ceiling(P · N), desde 1, de los N
%   Valores ordenados: deja por debajo, o igual, al menos una fracción P.
%   P está entre 0 y 1, y Valores no es vacía.
ajustar_cuantil(P, Valores, Limite) :-
    msort(Valores, Ordenados),
    length(Ordenados, N),
    K is max(1, ceiling(P * N)),
    nth1(K, Ordenados, Limite).

%!  umbrales_cuantil(+P:number, -Umbrales:list) is det.
%
%   Los umbrales superiores de los fallos y de la CPU, y el inferior de
%   los pedidos con 1 - P, con los cuantiles de los días de referencia.
umbrales_cuantil(P, [pedidos-menor(PI), fallos-mayor(FS), cpu-mayor(CS)]) :-
    Q is 1 - P,
    valores_de_referencia(pedidos, Ps),
    ajustar_cuantil(Q, Ps, PI),
    valores_de_referencia(fallos, Fs),
    ajustar_cuantil(P, Fs, FS),
    valores_de_referencia(cpu, Cs),
    ajustar_cuantil(P, Cs, CS).
```

```prolog
?- umbrales_cuantil(0.95, U).
U = [pedidos-menor(20), fallos-mayor(10), cpu-mayor(0.7764370000000003)].
```

Con 36 horas, el cuantil 0,95 es el valor de la posición 35: deja por
encima una sola hora. Los límites son valores observados, no
estimaciones: los fallos dan 10, el límite fijo de Denning, porque el
segundo valor más alto de los días de referencia es 10, y el 28 del
martes queda por encima. Con esos límites, el informe del jueves tiene
siete líneas: las de la mediana, salvo el exceso de pedidos de las 10,
porque los pedidos no tienen límite superior. La diferencia está en lo que el
cuantil supone: que una fracción fija de las horas, aquí una de cada
veinte, es anómala, aunque no lo sea ninguna; con días de referencia sin
incidentes, el cuantil pone el límite en el valor normal más alto.

## 7

Un perfil es de atacante si −18 − 56·N + 70·F ≥ 0. Para `[1, 1]`,
−18 − 56 + 70 = −4: normal. Para `[4, 4]`, −18 − 224 + 280 = 38: atacante.
Para `[12, 10]`, −18 − 672 + 700 = 10: atacante. Para `[40, 31]`,
−18 − 2240 + 2170 = −88: normal.

```prolog
?- salida([-18, -56, 70], [1, 1], C1), salida([-18, -56, 70], [4, 4], C2), salida([-18, -56, 70], [12, 10], C3), salida([-18, -56, 70], [40, 31], C4).
C1 = C4, C4 = -1,
C2 = C3, C3 = 1.
```

La recta que separa es F = 0,8·N + 0,257, que pasa por `[0, 0.26]` y por
`[40, 32.26]`: en el plano, los atacantes quedan encima, cerca de la
diagonal F = N. Un único fallo no alcanza, porque el sesgo pide algo más
que el 80 % con pocos pedidos; dos fallos sin otra cosa, sí.

## 8

<!-- ejemplo: capitulo-84/soluciones.pl predicado: perfiles_diarios/2 cliente/2 perfil_diario/2 sumar_perfil/3 ejemplos_diarios/1 ejemplos_diarios_de/2 ejemplo_diario/3 sospechosos_diarios/3 sospechoso_diario/2 entrenamiento_diario/3 -->
```prolog
%!  perfiles_diarios(+Pedidos:list, -Perfiles:list) is det.
%
%   Perfiles tiene un perfil(Ip, dia, N, F) por cliente: sus N pedidos del
%   día, F de ellos inicios de sesión rechazados.
perfiles_diarios(Pedidos, Perfiles) :-
    perfiles(Pedidos, PorHora),
    map_list_to_pairs(cliente, PorHora, Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    maplist(perfil_diario, Grupos, Perfiles).

% cliente(Perfil, Ip): el cliente del Perfil.
cliente(perfil(Ip, _, _, _), Ip).

% perfil_diario(Ip-Perfiles, Perfil): la suma de los perfiles por hora.
perfil_diario(Ip-Ps, perfil(Ip, dia, N, F)) :-
    foldl(sumar_perfil, Ps, 0-0, N-F).

% sumar_perfil(Perfil, N0-F0, N-F): suma los pedidos y los fallos.
sumar_perfil(perfil(_, _, N1, F1), N0-F0, N-F) :-
    N is N0 + N1,
    F is F0 + F1.

%!  ejemplos_diarios(-Ejemplos:list) is det.
%
%   Los perfiles diarios de los días de referencia, marcados con
%   atacante/2.
ejemplos_diarios(Ejemplos) :-
    dias_de_referencia(Archivos),
    maplist(ejemplos_diarios_de, Archivos, Listas),
    append(Listas, Ejemplos).

% ejemplos_diarios_de(Archivo, Ejemplos): los de un día.
ejemplos_diarios_de(Archivo, Ejemplos) :-
    leer_registro(Archivo, Pedidos),
    perfiles_diarios(Pedidos, Perfiles),
    maplist(ejemplo_diario(Archivo), Perfiles, Ejemplos).

% ejemplo_diario(Archivo, Perfil, Ejemplo): el Perfil marcado.
ejemplo_diario(Archivo, perfil(Ip, _, N, F), ej([N, F], Clase)) :-
    (   atacante(Archivo, Ip)
    ->  Clase = 1
    ;   Clase = -1
    ).

%!  sospechosos_diarios(+Pesos:list, +Archivo, -Sospechosos:list) is det.
%
%   Los perfiles diarios del registro Archivo a los que el perceptrón con
%   Pesos da la clase 1.
sospechosos_diarios(Pesos, Archivo, Sospechosos) :-
    leer_registro(Archivo, Pedidos),
    perfiles_diarios(Pedidos, Perfiles),
    include(sospechoso_diario(Pesos), Perfiles, Sospechosos).

% sospechoso_diario(Pesos, Perfil): el perceptrón da la clase 1.
sospechoso_diario(Pesos, perfil(_, _, N, F)) :-
    salida(Pesos, [N, F], 1).

%!  entrenamiento_diario(-N:integer, -Pesos:list, -Curva:list) is semidet.
%
%   N es la cantidad de ejemplos diarios de referencia, y Pesos y Curva
%   los del perceptrón entrenado con ellos, con tasa 1 desde pesos nulos.
entrenamiento_diario(N, Pesos, Curva) :-
    ejemplos_diarios(Ejemplos),
    length(Ejemplos, N),
    entrenar(1, Ejemplos, [0, 0, 0], Pesos, Curva).
```

```prolog
?- entrenamiento_diario(N, P, C).
N = 108,
P = [-6, -50, 78],
C = [6, 2, 1, 0].

?- sospechosos_diarios([-6, -50, 78], registros('2026-09-30.log'), S).
S = [perfil(ip(198, 51, 100, 40), dia, 8, 8)].
```

Por día hay menos perfiles, 108, y dos de atacantes, `[25, 25]` y
`[8, 8]`: el atacante lento del miércoles queda en un solo perfil con sus
ocho intentos. El entrenamiento termina en cuatro épocas, y la recta,
F ≥ 0,64·N + 0,08, es más permisiva con los fallos que la de la versión
5. Encuentra a los mismos atacantes el miércoles y el jueves. Lo que se
pierde es la hora: el perfil diario dice que hubo un ataque, no cuándo,
y un alumno que olvidó su contraseña por la mañana y volvió a olvidarla
por la tarde suma sus fallos en un solo perfil.

## 9

<!-- ejemplo: capitulo-84/soluciones.pl predicado: repetidos/2 -->
```prolog
%!  repetidos(+K:integer, -Archivos:list) is det.
%
%   Archivos es la lista de los cuatro días repetida K veces.
repetidos(K, Archivos) :-
    Dias = [ registros('2026-09-28.log'), registros('2026-09-29.log'),
             registros('2026-09-30.log'), registros('2026-10-01.log') ],
    length(Copias, K),
    maplist(=(Dias), Copias),
    append(Copias, Archivos).
```

```text
?- repetidos(10, _As), time(resumir_en_serie(fallos, _As, R1)), time(resumir_en_paralelo(fallos, _As, R2)), R1 == R2.
% 625,701 inferences, 0.328 CPU in 0.331 seconds (99% CPU, 1906898 Lips)
% 634,199 inferences, 0.312 CPU in 0.065 seconds (483% CPU, 2029437 Lips)
```

Con cuarenta archivos, la versión en paralelo tarda la quinta parte: hay
cuarenta tareas para dieciséis hilos, y la CPU usada pasa del 480 %. La
CPU total es la misma, porque el trabajo es el mismo; lo que cambia es
cuánto de él se hace a la vez. El resumen tiene 480 horas porque cada
archivo de la lista se resume aunque esté repetido: el resumen combinable
no sabe de dónde vino cada valor, y combinar dos veces el mismo día pesa
doble sus horas. Si los archivos pudieran repetirse, la lista debería
pasar antes por `sort/2`.

## 10

La media ponderada se actualiza con cada valor nuevo X:
M ← M + α·(X − M), y la varianza, V ← (1 − α)·(V + α·(X − M)²), con la
diferencia tomada antes de actualizar la media.
`limites_ponderados/4` da el límite superior después de cada valor:

<!-- ejemplo: capitulo-84/soluciones.pl predicado: limites_ponderados/4 paso_ponderado/6 ajustar_ponderado/4 -->
```prolog
%!  limites_ponderados(+D, +Alfa, +Valores:list(number),
%!                     -Limites:list(number)) is det.
%
%   Limites son los límites superiores, media más D desvíos, después de
%   cada uno de los Valores, con la media y la varianza exponencialmente
%   ponderadas: el primer valor inicia la media con varianza 0, y cada
%   valor siguiente X pesa Alfa.
limites_ponderados(D, Alfa, [X|Xs], [L|Ls]) :-
    L is X,
    foldl(paso_ponderado(D, Alfa), Xs, Ls, X-0, _).

% paso_ponderado(D, Alfa, X, Limite, M0-V0, M-V): un paso de la media y la
% varianza ponderadas, y el límite que dejan.
paso_ponderado(D, Alfa, X, Limite, M0-V0, M-V) :-
    Delta is X - M0,
    M is M0 + Alfa * Delta,
    V is (1 - Alfa) * (V0 + Alfa * Delta * Delta),
    Limite is M + D * sqrt(V).

%!  ajustar_ponderado(+D, +Alfa, +Valores:list(number), -Intervalo) is det.
%
%   Intervalo es entre(Inferior, Superior) con la media y el desvío
%   ponderados después del último de los Valores.
ajustar_ponderado(D, Alfa, [X|Xs], entre(Inferior, Superior)) :-
    foldl(paso_ponderado(D, Alfa), Xs, _, X-0, M-V),
    Desvio is sqrt(V),
    Inferior is M - D * Desvio,
    Superior is M + D * Desvio.
```

```prolog
?- valores_de_referencia(fallos, Vs), ajustar_ponderado(3, 0.1, Vs, I).
Vs = [5, 5, 3, 6, 8, 7, 3, 9, 6|...],
I = entre(-8.885380425784572, 18.174731561743034).
```

De la hora 8 a la 19 de las 36 de referencia, el límite se mueve entre
10,1 y 11,6. Con el valor 28, el ataque del martes, salta a 28,9: el valor
mismo entra en la media y en la varianza. Después baja despacio, un 4 %
por hora: nueve horas más tarde todavía es 20,4, y al final de los tres
días, 18,2. Pesar más lo reciente adapta el límite a un servicio cuyo
tráfico cambia, pero también a un ataque: un atacante que sube su
actividad de a poco arrastra el límite con él. Por eso el límite
ponderado se calcula con los valores que no resultaron anómalos.

## 11

El registro anota el cliente, el método, la ruta y el código, pero no el
cuerpo del pedido, y el legajo que se intenta está en el cuerpo de
`POST /sesion`. Para el registro, sesenta intentos contra un legajo y
sesenta intentos contra sesenta legajos distintos son el mismo perfil,
`[60, 60]`. Denning propone para el segundo caso un perfil por cuenta y el
agregado de todas las cuentas: un ataque con una contraseña contra muchas
cuentas no es anómalo en ninguna cuenta, y sí en el total. Para que
`causa/3` lo distinga, el servicio debería anotar el legajo de cada
intento, por ejemplo con un término más en el registro, y nunca la
contraseña. Con ese dato, una regla nueva de `causa/5` daría
`cuentas(Ip, K)`: la cantidad de legajos distintos que un cliente probó
en la hora.
