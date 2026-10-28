# Lectura de los registros, métricas e informes

Esta página continúa el [capítulo 85](index.md) después de la
[sección 85.2](index.md#852-el-programa-terminado), con las secciones
[85.3](#853-version-1-el-registro-como-hechos),
[85.4](#854-version-2-el-formato-comun) y
[85.5](#855-version-3-metricas-por-hora-e-informes): las versiones 1 y 2,
las que leen los registros, y la versión 3, que resume los pedidos leídos en métricas por
hora, busca las anomalías con límites fijos y escribe los informes.

## 85.3 Versión 1: el registro como hechos

Triska observa que un registro escrito como hechos de Prolog se carga y
se consulta sin escribir un lector: la pregunta «¿algún pedido quedó sin
respuesta?» es `request(R, _, _), \+ completed(R, _, _, _, _)`.
`cargar_hechos/2` carga un archivo en un módulo propio, que se llama como
el archivo, para que dos días no se mezclen, y dos reglas lo consultan:

<!-- ejemplo: capitulo-85/registro.pl predicado: cargar_hechos/2 par_hechos/3 sin_respuesta_hechos/2 -->
```prolog
%!  cargar_hechos(+Archivo, -Modulo) is det.
%
%   Carga el registro Archivo como un programa, en un módulo propio, Modulo,
%   que se llama como el archivo sin la extensión. Los términos request/3,
%   completed/5 y server/2 se alternan en el archivo, y la carga no avisa
%   por cada uno porque ese aviso se desactiva mientras dura.
cargar_hechos(Archivo, Modulo) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    file_base_name(Ruta, Base),
    file_name_extension(Modulo, _, Base),
    setup_call_cleanup(style_check(-discontiguous),
                       load_files(Modulo:Ruta, []),
                       style_check(+discontiguous)).

%!  par_hechos(+Modulo, ?Id, ?Codigo) is nondet.
%
%   El pedido Id del registro cargado en Modulo tiene una respuesta con
%   Codigo: la regla junta request/3 y completed/5 por el número de pedido.
par_hechos(Modulo, Id, Codigo) :-
    Modulo:request(Id, _, _),
    Modulo:completed(Id, _, _, Codigo, _).

%!  sin_respuesta_hechos(+Modulo, ?Id) is nondet.
%
%   El pedido Id del registro cargado en Modulo no tiene respuesta: la
%   consulta de Triska, request/3 sin completed/5.
sin_respuesta_hechos(Modulo, Id) :-
    Modulo:request(Id, _, _),
    \+ Modulo:completed(Id, _, _, _, _).
```

Los términos `request/3` y `completed/5` se alternan en el archivo, y
SWI-Prolog avisa, por cada cláusula, que las de un mismo predicado no
están juntas; la carga desactiva ese aviso con `style_check/1` mientras
dura, y lo restablece con `setup_call_cleanup/3`, como en la
[sección 26.6](../capitulo-26-errores-y-excepciones/index.md#266-setup_call_cleanup3).
El lunes no quedó ningún pedido sin respuesta:

```prolog
?- cargar_hechos(registros('2026-09-28.log'), M), findall(Id, sin_respuesta_hechos(M, Id), Ids).
M = '2026-09-28',
Ids = [].
```

El jueves el servidor dejó de responder a las 17:10 y volvió a arrancar a
las 19:05. El número de pedido lo asigna el servidor en cada corrida,
desde 1, así que después del arranque los números se repiten, y la regla
que junta pedido y respuesta por número junta pedidos de una corrida con
respuestas de la otra. El pedido 1 de cada corrida tiene una sola
respuesta, pero `par_hechos/3` encuentra cuatro:

```prolog
?- cargar_hechos(registros('2026-10-01.log'), M), findall(C, par_hechos(M, 1, C), Cs).
M = '2026-10-01',
Cs = [200, 401, 200, 401].
```

Con 23 pedidos en la segunda corrida, `par_hechos/3` da 465 pares donde
hay 419 pedidos respondidos. La consulta de los pedidos sin respuesta
acierta por casualidad: el pedido pendiente es el 397, y la segunda
corrida no llegó a ese número. Si hubiera llegado, su `completed/5` haría
creer que el pedido de la primera corrida tuvo respuesta. Cargar el
registro como programa trata el archivo como un conjunto de hechos sin
orden, y el orden es lo que dice a qué corrida pertenece cada término.

### Leer el registro como datos

La alternativa es leer el archivo término por término, como en la
[sección 28.2](../capitulo-28-archivos-streams-y-formatos/index.md#282-leer-terminos-y-lineas),
y llevar como estado los pedidos que llegaron y todavía no tienen
respuesta. El estado es un `assoc` del
[capítulo 23](../capitulo-23-estructuras-de-datos-de-la-biblioteca/index.md#235-libraryassoc-y-libraryrbtrees)
con el número de pedido como clave; `paso/4` dice qué hace cada término
con él y qué produce:

<!-- ejemplo: capitulo-85/registro.pl predicado: paso/4 cerrar/2 -->
```prolog
%!  paso(+Termino, +Abiertos0, -Abiertos, -Producidos:list) is det.
%
%   Leído Termino con los pedidos Abiertos0 sin respuesta, quedan Abiertos,
%   y se producen los pedidos de la lista Producidos. Un pedido se abre con
%   request/3 y se cierra con el completed/5 de su número; server/2 marca el
%   final de una corrida, y los pedidos abiertos quedan pendientes. Una
%   respuesta sin pedido, de una corrida que empezó antes del archivo, no
%   produce nada.
paso(request(Id, Instante, Campos), A0, A, []) :-
    memberchk(peer(Ip), Campos),
    memberchk(method(Metodo), Campos),
    memberchk(path(Ruta), Campos),
    put_assoc(Id, A0, abierto(Instante, Ip, Metodo, Ruta), A).
paso(completed(Id, Cpu, _, Codigo, _), A0, A, Producidos) :-
    (   del_assoc(Id, A0, abierto(Instante, Ip, Metodo, Ruta), A)
    ->  Producidos = [pedido(Instante, Ip, Metodo, Ruta, Codigo, Cpu)]
    ;   A = A0,
        Producidos = []
    ).
paso(server(_, _), A0, t, Pendientes) :-
    cerrar(A0, Pendientes).

%!  cerrar(+Abiertos, -Pendientes:list) is det.
%
%   Pendientes son los pedidos de Abiertos, que ya no tendrán respuesta,
%   en el orden de sus números.
cerrar(Abiertos, Pendientes) :-
    assoc_to_values(Abiertos, Valores),
    maplist(pendiente, Valores, Pendientes).
```

Un `server/2` cierra la corrida: los pedidos abiertos ya no tendrán
respuesta, y el estado vuelve a ser el `assoc` vacío, `t`. Así, los
números repetidos de la corrida siguiente no encuentran nada abierto de
la anterior.

```prolog
?- empty_assoc(A0), paso(request(1, 10.5, [peer(ip(10, 1, 0, 7)), method(get), path('/materias')]), A0, A1, S1), paso(completed(1, 0.002, 412, 200, ok), A1, A2, S2).
A0 = A2, A2 = t,
A1 = t(1, abierto(10.5, ip(10, 1, 0, 7), get, '/materias'), -, t, t),
S1 = [],
S2 = [pedido(10.5, ip(10, 1, 0, 7), get, '/materias', 200, 0.002)].
```

El recorrido lee un término, da un paso y sigue, y al final del archivo
cierra lo que quedó abierto. Es la forma de `cribar_stream/6` del
[capítulo 84](../capitulo-84-proyecto-procesamiento-textos/index.md#845-el-filtro-version-3-un-programa-para-la-terminal),
con términos en lugar de líneas:

<!-- ejemplo: capitulo-85/registro.pl predicado: leer_registro/3 recorrer/3 contar_registro/3 -->
```prolog
%!  leer_registro(+Archivo, -Pedidos:list, -Pendientes:list) is det.
%
%   Pedidos son los pedidos respondidos del registro Archivo, como
%   pedido(Instante, Ip, Metodo, Ruta, Codigo, Cpu), en el orden de las
%   respuestas, y Pendientes los que no tienen respuesta, como
%   pendiente(Instante, Ip, Metodo, Ruta). Lee el archivo como datos, de a
%   un término, y junta cada pedido con su respuesta dentro de la corrida
%   del servidor en la que llegó.
leer_registro(Archivo, Pedidos, Pendientes) :-
    absolute_file_name(Archivo, Ruta, [access(read)]),
    setup_call_cleanup(open(Ruta, read, In, [encoding(utf8)]),
                       recorrer(In, t, Salida),
                       close(In)),
    partition(es_pedido, Salida, Pedidos, Pendientes).

%!  recorrer(+In, +Abiertos, -Salida:list) is det.
%
%   Salida es lo que producen los términos que quedan en In, con Abiertos
%   los pedidos sin respuesta todavía: un assoc del número de pedido.
recorrer(In, Abiertos0, Salida) :-
    read_term(In, Termino, []),
    (   Termino == end_of_file
    ->  cerrar(Abiertos0, Salida)
    ;   paso(Termino, Abiertos0, Abiertos, Producidos),
        append(Producidos, Resto, Salida),
        recorrer(In, Abiertos, Resto)
    ).

%!  contar_registro(+Archivo, -Respondidos:integer, -Pendientes:list) is det.
%
%   Respondidos es la cantidad de pedidos respondidos del registro Archivo,
%   y Pendientes los pedidos sin respuesta, como en leer_registro/3.
contar_registro(Archivo, Respondidos, Pendientes) :-
    leer_registro(Archivo, Pedidos, Pendientes),
    length(Pedidos, Respondidos).
```

```prolog
?- contar_registro(registros('2026-10-01.log'), N, P).
N = 419,
P = [pendiente(1790884523.107, ip(10, 1, 0, 58), get, '/ranking')].
```

El pedido pendiente es una consulta del ranking hecha a las 16:55:23, un
cuarto de hora antes de la caída. `pedido(Instante, Ip, Metodo, Ruta,
Codigo, Cpu)` es la representación con la que trabajan todas las
versiones siguientes; `leer_registro/2` da esos pedidos ordenados por
instante, porque `msort/2` ordena por el primer argumento.

!!! question "Actividad"
    Predecir cuántas respuestas tiene `par_hechos(M, 30, C)` con el
    registro del jueves cargado, y cuántas `par_hechos(M, 300, C)`.
    Comprobarlo, y explicar por qué `leer_registro/3` no tiene ese
    problema aunque los números se repitan.

## 85.4 Versión 2: el formato común

No todos los servidores escriben términos de Prolog. El formato común
de los servidores web, el de la documentación del servidor del W3C, es
una línea de texto por pedido respondido:

```text
10.1.0.28 - - [01/Oct/2026:08:04:26 -0300] "POST /sesion HTTP/1.1" 401 36
```

Los campos son el cliente, dos identidades que casi nunca se registran
(un guion), la fecha con su zona horaria, la línea del pedido entre
comillas, el código y los bytes de la respuesta. No hay tiempo de CPU, y
no hay pedidos sin respuesta: la línea se escribe al responder. Denning
recomienda traducir los registros de cada sistema a un formato uniforme
con un filtro; aquí el formato uniforme es `pedido/6`, con `sin_medir` en
lugar del tiempo de CPU. La gramática usa los no terminales de
`library(dcg/basics)` de la
[sección 22.6](../capitulo-22-gramaticas-dcg/index.md#226-librarydcgbasics-y-librarydcghigh_order):

<!-- ejemplo: capitulo-85/comun.pl predicado: linea//1 ip//1 campo//0 fecha//1 zona//1 signo/2 -->
```prolog
%!  linea(-Pedido)// is semidet.
%
%   Una línea del formato común: Ip, dos campos que no se usan, [Fecha],
%   "METODO Ruta HTTP/Version", el código de la respuesta y los bytes.
linea(pedido(Instante, Ip, Metodo, Ruta, Codigo, sin_medir)) -->
    ip(Ip), " ", campo, " ", campo, " [", fecha(Instante), "] \"",
    metodo(Metodo), " ", ruta(Ruta), " HTTP/", version, "\" ",
    integer(Codigo), " ", bytes, eos.

% ip(Ip)//: cuatro enteros separados por puntos.
ip(ip(A, B, C, D)) -->
    integer(A), ".", integer(B), ".", integer(C), ".", integer(D).

% campo//: un guion o una palabra sin blancos.
campo -->
    nonblanks(Cs),
    { Cs \== [] }.

%!  fecha(-Instante:float)// is semidet.
%
%   Dia/Mes/Anio:Hora:Minuto:Segundo Zona, con el mes en tres letras en
%   inglés y la zona como +HHMM o -HHMM. Instante es el instante Unix.
fecha(Instante) -->
    integer(D), "/", mes(M), "/", integer(A), ":",
    integer(H), ":", integer(Mi), ":", integer(S), " ", zona(Zona),
    { date_time_stamp(date(A, M, D, H, Mi, S, Zona, -, -), Instante) }.

% zona(Z)//: -HHMM o +HHMM; Z son los segundos al oeste de UTC, como en
% date/9.
zona(Z) -->
    [C], digits([H1, H2, M1, M2]),
    { signo(C, S),
      number_codes(H, [H1, H2]),
      number_codes(M, [M1, M2]),
      Z is S * (H * 3600 + M * 60) }.

% signo(C, S): el signo de una zona, de código C, es S: 1 al oeste de UTC
% y -1 al este.
signo(0'-, 1).
signo(0'+, -1).
```

`date_time_stamp/2` convierte la fecha en un instante Unix; su séptimo
argumento son los segundos al oeste de UTC, así que la zona `-0300` es
10 800. El mes se lee con una tabla de hechos, `numero_de_mes/2`, indexada
por el nombre: con `nth1/3` y el número libre, la búsqueda dejaría una
alternativa pendiente en cada línea.

```prolog
?- phrase(linea(P), `10.1.0.28 - - [01/Oct/2026:08:04:26 -0300] "POST /sesion HTTP/1.1" 401 36`).
P = pedido(1790852666.0, ip(10, 1, 0, 28), post, '/sesion', 401, sin_medir).
```

El archivo se lee de a una línea, con un paso por línea como el filtro
del [capítulo 84](../capitulo-84-proyecto-procesamiento-textos/index.md#845-el-filtro-version-3-un-programa-para-la-terminal).
La diferencia está en lo que hace con una línea que no tiene el formato.
Una marca mal puesta en un examen es un error de quien lo escribió, y el
filtro se detiene para que lo corrija; un registro lo escribe un servidor
que puede caerse a mitad de una línea o recibir basura, y detenerse en
la primera línea defectuosa impediría analizar el resto. El paso produce
la línea defectuosa, con su número, como un dato más:

<!-- ejemplo: capitulo-85/comun.pl predicado: paso_comun/3 recorrer_comun/3 contar_comun/3 -->
```prolog
%!  paso_comun(+N:integer, +Linea:string, -Producidos:list) is det.
%
%   Producidos es la lista con el pedido de la línea N, Linea, o con
%   defectuosa(N, Linea) si la línea no tiene el formato común.
paso_comun(N, Linea, Producidos) :-
    string_codes(Linea, Codigos),
    (   phrase(linea(Pedido), Codigos)
    ->  Producidos = [Pedido]
    ;   Producidos = [defectuosa(N, Linea)]
    ).

%!  recorrer_comun(+In, +N:integer, -Salida:list) is det.
%
%   Salida es lo que producen las líneas que quedan en In, con la próxima
%   numerada N.
recorrer_comun(In, N, Salida) :-
    read_line_to_string(In, Linea),
    (   Linea == end_of_file
    ->  Salida = []
    ;   paso_comun(N, Linea, Producidos),
        append(Producidos, Resto, Salida),
        N1 is N + 1,
        recorrer_comun(In, N1, Resto)
    ).

%!  contar_comun(+Archivo, -N:integer, -Defectuosas:list) is det.
%
%   N es la cantidad de pedidos del registro Archivo, en el formato común,
%   y Defectuosas sus líneas defectuosas, como en leer_comun/3.
contar_comun(Archivo, N, Defectuosas) :-
    leer_comun(Archivo, Pedidos, Defectuosas),
    length(Pedidos, N).
```

```prolog
?- contar_comun(registros('2026-10-01-comun.log'), N, D).
N = 418,
D = [defectuosa(23, "203.0.113.50 - - [01/Oct/2026:08:41:07 -0300] \"\\x16\\x03\\x01\" 400 0"), defectuosa(397, "10.1.0.58 - - [01/Oct/2026:16:55:11 -0")].
```

Las dos líneas defectuosas son anomalías por sí mismas. La 23 es un
cliente que abrió una conexión cifrada con TLS contra el puerto HTTP: su
pedido empieza con los bytes 16, 03 y 01, que el servidor anota como
`\x16\x03\x01`, y la gramática no los reconoce como método. La 397 está
cortada: es la última que el servidor alcanzó a escribir antes de caerse.
Los dos registros del jueves, leídos por las dos versiones, deben
coincidir en todo lo que el formato común registra. `comparar/4` los
reduce a ese contenido y los compara como conjuntos ordenados:

<!-- ejemplo: capitulo-85/comun.pl predicado: comparar/4 clave/2 -->
```prolog
%!  comparar(+Comun:list, +Registro:list, -Faltan:list, -Sobran:list)
%!      is det.
%
%   Faltan son los pedidos de Registro, leídos con la versión 1, que no
%   están en Comun, y Sobran los de Comun que no están en Registro. Se
%   comparan el segundo del instante, el cliente, el método, la ruta y el
%   código.
comparar(Comun, Registro, Faltan, Sobran) :-
    maplist(clave, Comun, C0),
    maplist(clave, Registro, R0),
    msort(C0, C),
    msort(R0, R),
    ord_subtract(R, C, Faltan),
    ord_subtract(C, R, Sobran).

% clave(Pedido, Clave): lo que el formato común registra de un pedido.
clave(pedido(T, Ip, M, R, Codigo, _), clave(S, Ip, M, R, Codigo)) :-
    S is truncate(T).
```

```prolog
?- diferencias(registros('2026-10-01-comun.log'), registros('2026-10-01.log'), F, S).
F = [clave(1790884511, ip(10, 1, 0, 58), get, '/alumnos/158', 200)],
S = [].
```

Falta un solo pedido, el de la línea cortada, y no sobra ninguno.

!!! question "Actividad"
    Predecir qué responde `phrase(linea(P), Cs)` cuando la línea termina
    con un blanco después de los bytes, y cuando los bytes son `-`.
    Comprobarlo, y decir qué no terminal decide cada caso.

## 85.5 Versión 3: métricas por hora e informes

Un pedido aislado dice poco; lo que tiene sentido comparar son totales
por período. Denning llama **métrica** a una cantidad acumulada en un
período, y distingue tres clases: un contador de eventos (los inicios de
sesión rechazados en una hora), un temporizador (el tiempo entre dos
eventos) y una medida de recursos (el tiempo de CPU usado en una hora).
`medir/2` calcula cuatro métricas sobre los pedidos de una hora, y
`metricas/2` agrupa los pedidos de un día por hora con los pares de la
[sección 23.4](../capitulo-23-estructuras-de-datos-de-la-biblioteca/index.md#234-pares-y-keysort2):

<!-- ejemplo: capitulo-85/informes.pl predicado: hora/2 metricas/2 metricas_de_la_hora/3 medir/2 metrica/3 -->
```prolog
%!  hora(+Instante:number, -Hora:integer) is det.
%
%   Hora es la hora del Instante en Buenos Aires, UTC-3: el último
%   argumento de stamp_date_time/3 son los segundos al oeste de UTC.
hora(Instante, Hora) :-
    stamp_date_time(Instante, date(_, _, _, Hora, _, _, _, _, _), 10800).

%!  metricas(+Pedidos:list, -Horas:list) is det.
%
%   Horas tiene un elemento hora(H, Metricas) por cada hora de servicio,
%   con las métricas de medir/2 sobre los Pedidos que llegaron en esa
%   hora; una hora sin pedidos tiene todas las métricas en cero.
metricas(Pedidos, Horas) :-
    map_list_to_pairs(hora_del_pedido, Pedidos, Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    horas_de_servicio(Desde, Hasta),
    numlist(Desde, Hasta, Hs),
    maplist(metricas_de_la_hora(Grupos), Hs, Horas).

% metricas_de_la_hora(Grupos, H, hora(H, Ms)): las métricas de la hora H.
metricas_de_la_hora(Grupos, H, hora(H, Metricas)) :-
    (   memberchk(H-Pedidos, Grupos)
    ->  true
    ;   Pedidos = []
    ),
    medir(Pedidos, Metricas).

%!  medir(+Pedidos:list, -Metricas) is det.
%
%   Metricas es m(N, Fallos, NoEncontradas, Cpu): la cantidad de Pedidos,
%   los inicios de sesión rechazados, los pedidos con código 404 y el
%   tiempo de CPU sumado, en segundos, de los pedidos que lo registran.
medir(Pedidos, m(N, Fallos, NoEncontradas, Cpu)) :-
    length(Pedidos, N),
    aggregate_all(count,
                  member(pedido(_, _, post, '/sesion', 401, _), Pedidos),
                  Fallos),
    aggregate_all(count,
                  member(pedido(_, _, _, _, 404, _), Pedidos),
                  NoEncontradas),
    aggregate_all(sum(C),
                  ( member(pedido(_, _, _, _, _, C), Pedidos),
                    number(C) ),
                  Cpu).

%!  metrica(?Nombre, +Metricas, -Valor:number) is nondet.
%
%   Valor es la métrica Nombre de Metricas: pedidos, fallos,
%   no_encontradas o cpu.
metrica(pedidos, m(N, _, _, _), N).
metrica(fallos, m(_, F, _, _), F).
metrica(no_encontradas, m(_, _, X, _), X).
metrica(cpu, m(_, _, _, C), C).
```

`metricas/2` recorre las doce horas de servicio, no las horas que
aparecen en los pedidos. Una hora sin pedidos está en la lista, con todas
sus métricas en cero. Denning lo advierte: si los períodos sin eventos no
se cuentan, los valores observados quedan sesgados hacia arriba, y un
período sin actividad, que puede ser la anomalía, no se ve.

```prolog
?- hora_del_dia(registros('2026-10-01.log'), 10, M).
M = m(98, 62, 0, 3.173641000000001).
```

Los informes siguen la idea de Triska: los datos no cambian, y cada
informe es un predicado nuevo sobre ellos. `escribir_metricas/1` escribe
la tabla con las columnas de `format/2`: `~t` rellena y `~N|` fija la
columna donde termina el campo, así que los números quedan alineados a
la derecha.

<!-- ejemplo: capitulo-85/informes.pl predicado: escribir_metricas/1 informe/1 -->
```prolog
%!  escribir_metricas(+Horas:list) is det.
%
%   Escribe una tabla con las métricas de cada hora.
escribir_metricas(Horas) :-
    format("hora  pedidos  fallos  404    cpu~n"),
    forall(member(hora(H, m(N, F, X, C)), Horas),
           format("~t~d~2| h~t~d~13|~t~d~21|~t~d~26|~t~2f~33|~n",
                  [H, N, F, X, C])).

%!  informe(+Archivo) is det.
%
%   Escribe la tabla de las métricas por hora del registro Archivo.
informe(Archivo) :-
    leer_registro(Archivo, Pedidos),
    metricas(Pedidos, Horas),
    escribir_metricas(Horas).
```

```text
?- informe(registros('2026-10-01.log')).
hora  pedidos  fallos  404    cpu
 8 h       30       3    0   0.37
 9 h       30       0    0   0.23
10 h       98      62    0   3.17
11 h       29       5    0   0.46
12 h       25       2    0   2.86
13 h       43       6    0   0.57
14 h       46      24    0   1.32
15 h       59       8    0   0.74
16 h       36       5    0   0.46
17 h        0       0    0   0.00
18 h        0       0    0   0.00
19 h       23       1    0   0.16
true.
```

### Anomalías con límites fijos

El modelo más simple de Denning es el **operacional**: un valor es
anómalo si pasa un límite fijo, que la experiencia asocia con un
problema. Su ejemplo es el de las contraseñas: más de 10 fallos en un
período breve, «digamos», sugieren un intento de intrusión. Los límites
son una lista de pares `Metrica-Limite`, y una anomalía es una hora en la
que alguna métrica queda fuera de su límite:

<!-- ejemplo: capitulo-85/informes.pl predicado: umbrales_fijos/1 anomalia/3 fuera/2 -->
```prolog
%!  umbrales_fijos(-Umbrales:list) is det.
%
%   Los límites de cada métrica, escritos a mano: Metrica-mayor(L) si los
%   valores mayores que L son anómalos, Metrica-menor(L) si lo son los
%   menores.
umbrales_fijos([ fallos-mayor(10),
                 no_encontradas-mayor(5),
                 pedidos-menor(5),
                 cpu-mayor(1.5)
               ]).

%!  anomalia(+Umbrales:list, +Horas:list, -Anomalia) is nondet.
%
%   Anomalia es anomalia(H, Metrica, Valor, Limite): en la hora H, la
%   Metrica vale Valor, fuera del Limite que le da Umbrales.
anomalia(Umbrales, Horas, anomalia(H, Metrica, Valor, Limite)) :-
    member(hora(H, Metricas), Horas),
    member(Metrica-Limite, Umbrales),
    metrica(Metrica, Metricas, Valor),
    fuera(Limite, Valor).

% fuera(Limite, Valor): Valor pasa el Limite.
fuera(mayor(L), V) :-
    V > L.
fuera(menor(L), V) :-
    V < L.
```

Una anomalía dice qué hora y qué métrica, pero no por qué. Las reglas de
`causa/3` la explican con los pedidos de esa hora: el cliente con más
fallos, la ruta que más CPU usó. Son las reglas de actividad de Denning,
que se disparan con un registro de anomalía y lo relacionan con una
intrusión posible. `causa/3` despacha por la métrica a `causa/5`, cuyo
primer argumento la indexa, para no dejar alternativas pendientes:

<!-- ejemplo: capitulo-85/informes.pl predicado: causa/3 causa/5 causa_pedidos/4 mayor_cliente/5 anomalias/3 -->
```prolog
%!  causa(+Pedidos:list, +Anomalia, -Causa) is semidet.
%
%   Causa explica la Anomalia con los Pedidos del día: para los fallos, las
%   rutas inexistentes y el exceso de pedidos, cliente(Ip, K), el cliente
%   con más pedidos de esa clase en la hora, K; para el tiempo de CPU,
%   ruta(R, Segundos), la ruta que más tiempo usó; para una hora con pocos
%   pedidos, sin_trafico.
causa(Pedidos, anomalia(H, Metrica, _, Limite), Causa) :-
    causa(Metrica, Limite, Pedidos, H, Causa).

% causa(Metrica, Limite, Pedidos, H, Causa): causa/3 para la Metrica.
causa(fallos, _, Pedidos, H, cliente(Ip, K)) :-
    mayor_cliente(Pedidos, H, pedido(_, _, post, '/sesion', 401, _), Ip, K).
causa(no_encontradas, _, Pedidos, H, cliente(Ip, K)) :-
    mayor_cliente(Pedidos, H, pedido(_, _, _, _, 404, _), Ip, K).
causa(cpu, _, Pedidos, H, ruta(Ruta, Segundos)) :-
    findall(R-C,
            ( member(pedido(I, _, _, R, _, C), Pedidos),
              number(C),
              hora(I, H) ),
            Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    maplist(sumar_grupo, Grupos, Sumas),
    transpose_pairs(Sumas, PorSegundos),
    last(PorSegundos, Segundos-Ruta).
causa(pedidos, Limite, Pedidos, H, Causa) :-
    causa_pedidos(Limite, Pedidos, H, Causa).

% causa_pedidos(Limite, Pedidos, H, Causa): causa/3 para los pedidos.
causa_pedidos(mayor(_), Pedidos, H, cliente(Ip, K)) :-
    mayor_cliente(Pedidos, H, pedido(_, _, _, _, _, _), Ip, K).
causa_pedidos(menor(_), _, _, sin_trafico).

% mayor_cliente(Pedidos, H, Patron, Ip, K): Ip es el cliente con más
% pedidos que unifican con Patron en la hora H, K pedidos. Falla si no hay
% ninguno.
mayor_cliente(Pedidos, H, Patron, Ip, K) :-
    findall(I,
            ( member(Patron, Pedidos),
              Patron = pedido(Instante, I, _, _, _, _),
              hora(Instante, H) ),
            Ips),
    msort(Ips, Ordenadas),
    clumped(Ordenadas, Cuentas),
    transpose_pairs(Cuentas, PorCuenta),
    last(PorCuenta, K-Ip).

%!  anomalias(+Pedidos:list, +Umbrales:list, -Registros:list) is det.
%
%   Registros son las anomalías de los Pedidos de un día con los
%   Umbrales, cada una con su causa: anomalia(H, M, V, L)-Causa, en el
%   orden de las horas. Una anomalía sin causa conocida lleva desconocida.
anomalias(Pedidos, Umbrales, Registros) :-
    metricas(Pedidos, Horas),
    findall(A-C,
            ( anomalia(Umbrales, Horas, A),
              (   causa(Pedidos, A, C0)
              ->  C = C0
              ;   C = desconocida
              ) ),
            Registros).
```

`escribir_anomalias/1` escribe una línea por anomalía, e
`informe_anomalias/2` lee un día y las escribe. Con los límites fijos, el
jueves:

```text
?- umbrales_fijos(_U), informe_anomalias(registros('2026-10-01.log'), _U).
10 h  fallos 62 > 10          203.0.113.7, 60 pedidos
10 h  cpu 3.17 > 1.50         /sesion, 3.11 s
12 h  cpu 2.86 > 1.50         /sesion, 2.49 s
14 h  fallos 24 > 10          198.51.100.61, 17 pedidos
17 h  pedidos 0 < 5           sin tráfico
18 h  pedidos 0 < 5           sin tráfico
```

A las 10, 203.0.113.7 probó 60 contraseñas; a las 14, 198.51.100.61 probó
17; entre las 17 y las 19 el servidor estuvo caído. Las dos horas de
fallos son también horas de mucha CPU, y la causa es la misma:
`/sesion` calcula el resumen de la contraseña con PBKDF2, que el
[capítulo 83](../capitulo-83-proyecto-criptografia/index.md#834-version-2-las-contrasenas)
eligió costoso a propósito, y cada intento le cuesta al servidor 45
milésimas de segundo. La hora de las 12 es distinta: tiene pocos pedidos y
mucha CPU, y `/sesion` es la ruta que más usó solo porque es la más cara;
todos los pedidos de esa hora tardaron nueve veces lo normal. El
miércoles, los límites encuentran un cliente que pidió diez rutas
inexistentes, como `/wp-login.php` y `/.env`, en dos minutos:

```text
?- umbrales_fijos(_U), informe_anomalias(registros('2026-09-30.log'), _U).
11 h  no_encontradas 10 > 5   203.0.113.50, 10 pedidos
```

Los límites fijos tienen dos problemas. El primero es de dónde salen: el
10 de Denning es un ejemplo, y 1,5 segundos de CPU por hora dependen de la
máquina; con un servidor el doble de rápido, el límite deja de detectar
la hora lenta. El segundo es lo que no ven. El miércoles, entre las 16 y
las 17, un cliente probó ocho contraseñas, cinco en una hora y tres en la
siguiente, y esas horas tienen 10 fallos cada una: justo en el límite, sin
pasarlo.

!!! example "Patrón 92 — Límites como argumento"
    **Problema.** Una regla decide si el valor de una métrica es anómalo
    comparándolo con un límite, y los límites tienen varios orígenes: se
    fijan de manera explícita, se ajustan con días anteriores o con el mismo día
    que se examina, o se aprenden de incidentes ya investigados. La
    regla, y las que buscan la causa, son las mismas para todos.

    **Versión ingenua.** Escribir el límite dentro de la regla, como
    `Fallos > 10`, o un predicado de anomalías por cada origen de los
    límites: cambiar de límite obliga a reescribir la regla, y comparar
    dos orígenes sobre el mismo día obliga a mantener dos copias.

    **Patrón.** Las reglas reciben las métricas y un argumento con los
    límites, una lista de pares `Metrica-mayor(L)` o `Metrica-menor(L)`:
    `anomalia/3` toma un par de la lista y `fuera/2` lo aplica. La lista
    dice también qué métricas se examinan, y quien la produce queda
    afuera de las reglas: `umbrales_fijos/1` aquí, y
    `umbrales_de_referencia/2` y `umbrales_del_dia/3` en la
    [sección 85.6](aprendido.md#856-version-4-umbrales-ajustados-a-partir-de-los-datos).
    `anomalias/3` e `informe_anomalias/2` las usan sin cambios, y el
    jueves se examina con los tres juegos de límites, una consulta cada
    uno. Los pesos del perceptrón de la versión 5 no caben en la forma
    `mayor(L)`, porque son una recta sobre dos métricas, pero siguen la
    misma idea: `sospechosos/3` los recibe como argumento. Es pariente
    del [Patrón 64](../patrones.md#64-superioridad-como-parametro), en
    el que una lista argumento da el criterio que resuelve los conflictos
    entre reglas, y del
    [Patrón 69](../patrones.md#69-descripcion-del-mundo-como-parametro),
    en el que el algoritmo es fijo y lo que varía son los datos sobre los
    que razona: aquí lo que varía es la frontera entre lo normal y lo
    anómalo.

    **Cuándo no usarlo.** Cuando el límite es uno solo y lo fija una
    especificación que no cambia, como un tiempo de respuesta acordado:
    el argumento agrega una indirección sin beneficio. Y cuando el límite
    depende del período, como un tráfico normal distinto a las 8 y a las
    15: una sola lista para todas las horas no lo expresa, y los pares
    necesitan la hora en la clave, o el argumento pasa a ser un predicado
    que da el límite de cada hora.

!!! question "Actividad"
    Predecir qué anomalías informa `informe_anomalias/2` el martes,
    `registros('2026-09-29.log')`, con los límites fijos. Comprobarlo, y
    explicar con `hora_del_dia/3` por qué la hora de la CPU queda tan cerca
    de su límite.

El capítulo continúa en la página
[Umbrales ajustados a los datos y un umbral aprendido](aprendido.md#856-version-4-umbrales-ajustados-a-partir-de-los-datos),
con la pregunta que los límites fijos dejan abierta, de dónde salen: la
versión 4 los ajusta a partir de los datos, y la versión 5 los aprende
con el perceptrón.

## Ejercicios

Las soluciones están en [la página de soluciones](soluciones.md). La dificultad
va de 1 (se resuelve consultando el capítulo) a 3 (requiere elaboración propia).
Los marcados con ★ son los que no conviene saltear: cubren lo que el capítulo
tiene de propio. Los ejercicios que piden código se resuelven en archivos
que cargan los del capítulo, sin modificarlos.

1. ★ **(1)** Con el registro del jueves cargado por `cargar_hechos/2`,
   predecir cuántas respuestas tiene `par_hechos(M, 5, C)` y cuántas
   `sin_respuesta_hechos(M, 397)`. Comprobarlo. Construir después, con
   `paso/4` y una lista de términos escrita a mano, un caso en que
   `sin_respuesta_hechos/2` no encuentra un pedido pendiente que
   `leer_registro/3` sí encuentra.
2. ★ **(2)** Escribir `por_recurso(+Archivo, -Filas)`: una fila
   `fila(Recurso, Pedidos, Cpu)` por recurso del registro, el primer
   segmento de la ruta (`/alumnos` para `/alumnos/123`), con la cantidad
   de pedidos y el tiempo de CPU medio, ordenadas de más a menos pedidos, y
   `escribir_por_recurso/1`, que las escribe en una tabla alineada como la
   de `escribir_metricas/1`. Aplicarlo al jueves.
3. **(2)** El formato combinado agrega al formato común dos campos entre
   comillas: la página de la que viene el pedido y el programa del
   cliente. Escribir `linea_combinada//1`, que reconozca las dos formas y
   dé el mismo `pedido/6`, y comprobar que acepta
   `1.2.3.4 - - [01/Oct/2026:08:00:00 -0300] "GET /a HTTP/1.1" 200 9 "-" "curl/8.0"`.
4. **(1)** Denning distingue el ataque que prueba muchas contraseñas
   contra una cuenta del que prueba una contraseña contra muchas
   cuentas. Explicar por qué los registros del capítulo no permiten
   distinguirlos, y qué campo debería registrar el servicio para que
   `causa/3` lo hiciera.

## Referencias

- Markus Triska, *The Power of Prolog*, capítulo «Prolog Business Cases»,
  secciones «Analyzing events and anomalies» y «Rule-based reporting».
  [Edición en línea](https://www.metalevel.at/prolog/business). Esta
  página toma de allí el registro de `library(http/http_log)` como una
  serie de hechos, la consulta de los pedidos sin respuesta, la idea de
  convertir cualquier otro formato en hechos, y los informes como reglas
  sobre datos que no cambian, escritos con las columnas de `format/2`. La
  carga como programa y su problema con los rearranques del servidor no
  están en la fuente.
- Dorothy E. Denning, «An Intrusion-Detection Model», *IEEE Transactions
  on Software Engineering*, volumen SE-13, número 2, 1987, páginas
  222–232. [Copia de la autora](https://faculty.nps.edu/dedennin/publications/IDS%20model.pdf).
  Esta página toma de allí las métricas por período (contadores de
  eventos y medidas de recursos); el modelo operacional, con el límite de
  diez contraseñas fallidas de su ejemplo; la advertencia de contar los
  períodos sin eventos; los registros de anomalía y las reglas que buscan
  su causa; y la traducción de cada formato a uno uniforme con un filtro.
- Attila Csenki, *Applications of Prolog*, Ventus Publishing (Bookboon),
  2009 — capítulo «Text Processing».
  [Página de la editorial, copia de archivo](https://web.archive.org/web/20260216182045/https://bookboon.com/en/applications-of-prolog-ebook).
  La editorial ya no ofrece el libro;
  [Google Libros](https://books.google.com/books?id=copBGLD4LKwC) muestra
  páginas seleccionadas. Esta página lo toma a través del
  [capítulo 84](../capitulo-84-proyecto-procesamiento-textos/index.md),
  del que viene la forma del paso por línea.
- W3C, «Logging in W3C httpd», sección «Common Logfile Format»:
  [documentación en línea](https://www.w3.org/Daemon/User/Config/Logging.html#common-logfile-format);
  y Apache Software Foundation, *Apache HTTP Server Documentation*,
  «Log Files», sección «Common Log Format»:
  [documentación en línea](https://httpd.apache.org/docs/2.4/logs.html#common).
  De allí vienen los campos de la versión 2, la forma de la fecha y el
  guion para un dato que falta.
- *SWI-Prolog Reference Manual* y la documentación de
  `library(http/http_log)`:
  [manual en línea](https://www.swi-prolog.org/pldoc/man?section=httplog).
  El formato de `request/3`, `completed/5` y `server/2` se verificó con un
  servidor de prueba en SWI-Prolog 9.2.9.
