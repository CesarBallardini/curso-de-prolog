# Lectura de los registros

Esta página es parte del
[capítulo 84](index.md): sus versiones 1 y 2, las que leen los registros.
La [sección 84.3](index.md#843-version-1-el-registro-como-hechos) y la
[sección 84.4](index.md#844-version-2-el-formato-comun) las resumen.

## Versión 1: el registro como hechos

Triska observa que un registro escrito como hechos de Prolog se carga y
se consulta sin escribir un lector: la pregunta «¿algún pedido quedó sin
respuesta?» es `request(R, _, _), \+ completed(R, _, _, _, _)`.
`cargar_hechos/2` carga un archivo en un módulo propio, que se llama como
el archivo, para que dos días no se mezclen, y dos reglas lo consultan:

<!-- ejemplo: capitulo-84/registro.pl predicado: cargar_hechos/2 par_hechos/3 sin_respuesta_hechos/2 -->
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
[sección 25.6](../capitulo-25-errores-y-excepciones/index.md#256-setup_call_cleanup3).
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
[sección 27.2](../capitulo-27-archivos-streams-y-formatos/index.md#272-leer-terminos-y-lineas),
y llevar como estado los pedidos que llegaron y todavía no tienen
respuesta. El estado es un `assoc` del
[capítulo 22](../capitulo-22-estructuras-de-datos-de-la-biblioteca/index.md#225-libraryassoc-y-libraryrbtrees)
con el número de pedido como clave; `paso/4` dice qué hace cada término
con él y qué produce:

<!-- ejemplo: capitulo-84/registro.pl predicado: paso/4 cerrar/2 -->
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
[capítulo 83](../capitulo-83-proyecto-procesamiento-textos/index.md#835-el-filtro-version-3-un-programa-para-la-terminal),
con términos en lugar de líneas:

<!-- ejemplo: capitulo-84/registro.pl predicado: leer_registro/3 recorrer/3 contar_registro/3 -->
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

## Versión 2: el formato común

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
[sección 21.6](../capitulo-21-gramaticas-dcg/index.md#216-librarydcgbasics-y-librarydcghigh_order):

<!-- ejemplo: capitulo-84/comun.pl predicado: linea//1 ip//1 campo//0 fecha//1 zona//1 signo/2 -->
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
del [capítulo 83](../capitulo-83-proyecto-procesamiento-textos/index.md#835-el-filtro-version-3-un-programa-para-la-terminal).
La diferencia está en lo que hace con una línea que no tiene el formato.
Una marca mal puesta en un examen es un error de quien lo escribió, y el
filtro se detiene para que lo corrija; un registro lo escribe un servidor
que puede caerse a mitad de una línea o recibir basura, y detenerse en
la primera línea defectuosa impediría analizar el resto. El paso produce
la línea defectuosa, con su número, como un dato más:

<!-- ejemplo: capitulo-84/comun.pl predicado: paso_comun/3 recorrer_comun/3 contar_comun/3 -->
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

<!-- ejemplo: capitulo-84/comun.pl predicado: comparar/4 clave/2 -->
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
