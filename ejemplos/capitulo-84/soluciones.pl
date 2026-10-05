:- encoding(utf8).

% Capítulo 84 - Soluciones de los ejercicios.
%
% Carga aprendido.pl, que carga las versiones 1, 3 y 4 y el perceptrón del
% capítulo 69, comun.pl y paralelo.pl, sin modificarlos.
%
% solo-local: lee archivos y carga otros archivos.
%
%?- por_recurso(registros('2026-10-01.log'), Filas).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(library(assoc)).
:- use_module(library(dcg/basics)).
:- use_module(aprendido).
:- use_module(comun).
:- use_module(paralelo).

% Ejercicio 1

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

% es_pendiente(T): T es un pedido sin respuesta.
es_pendiente(pendiente(_, _, _, _)).

% registro_engañoso(Terminos): dos corridas en las que el pedido 1 de la
% primera queda sin respuesta, y el de la segunda la tiene.
registro_enganoso([ server(started, 0),
                    request(1, 1.0, [peer(a), method(get), path('/x')]),
                    server(started, 5),
                    request(1, 6.0, [peer(b), method(get), path('/y')]),
                    completed(1, 0.1, 10, 200, ok),
                    server(stopped, 9) ]).

% Ejercicio 2

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

% Ejercicio 3

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

% Ejercicio 4

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

% Ejercicio 5

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

% Ejercicio 6

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

% Ejercicio 8

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

% Ejercicio 9

%!  repetidos(+K:integer, -Archivos:list) is det.
%
%   Archivos es la lista de los cuatro días repetida K veces.
repetidos(K, Archivos) :-
    Dias = [ registros('2026-09-28.log'), registros('2026-09-29.log'),
             registros('2026-09-30.log'), registros('2026-10-01.log') ],
    length(Copias, K),
    maplist(=(Dias), Copias),
    append(Copias, Archivos).

% Ejercicio 10

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
