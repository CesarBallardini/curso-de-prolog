:- encoding(utf8).

% Capítulo 84 - Versión 5: un umbral aprendido con el perceptrón.
%
% Las métricas de la versión 4 suman todos los clientes de una hora, y un
% atacante que prueba pocas contraseñas por hora queda escondido entre los
% errores de los alumnos. Aquí la métrica es por cliente y por hora: el
% perfil perfil(Ip, H, Pedidos, Fallos). Un alumno que escribe mal su
% contraseña hace después otras consultas; un atacante solo prueba
% contraseñas. Ningún límite sobre los fallos solos separa los dos casos
% en los días de referencia, pero una recta en el plano de los pedidos y
% los fallos, sí: el perceptrón del capítulo 69 la busca, entrenado con
% los perfiles de los días de referencia, marcados con los incidentes que
% ya se investigaron.
%
% solo-local: lee archivos y carga los programas de los capítulos 69, 46, 32.
%
%?- ejemplos_de_referencia(Es), entrenar(1, Es, [0, 0, 0], Pesos, Curva).

:- module(aprendido,
          [ atacante/2,
            perfiles/2,
            ejemplos/2,
            ejemplos_de_referencia/1,
            separa_con_fallos/1,
            pesos_aprendidos/1,
            sospechosos/3,
            aprendizaje/2,
            extremos_de_fallos/2,
            sospechosos_del_dia/3,
            entrenar/5,
            salida/3
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- reexport(umbrales).
:- ensure_loaded('../capitulo-69/epocas').

% atacante(Archivo, Ip): en el registro Archivo, los pedidos del cliente Ip
% fueron un intento de adivinar contraseñas, ya investigado.
atacante(registros('2026-09-29.log'), ip(198, 51, 100, 23)).
atacante(registros('2026-09-30.log'), ip(198, 51, 100, 40)).

%!  perfiles(+Pedidos:list, -Perfiles:list) is det.
%
%   Perfiles tiene un perfil(Ip, H, N, F) por cada cliente Ip y hora H en
%   la que el cliente hizo pedidos: N pedidos, F de ellos inicios de sesión
%   rechazados. Están ordenados por cliente y por hora.
perfiles(Pedidos, Perfiles) :-
    maplist(clave_fallo, Pedidos, Pares),
    keysort(Pares, Ordenados),
    group_pairs_by_key(Ordenados, Grupos),
    maplist(perfil, Grupos, Perfiles).

% clave_fallo(Pedido, (Ip-H)-F): el cliente y la hora del Pedido, y F, 1 si
% es un inicio de sesión rechazado y 0 si no.
clave_fallo(pedido(Instante, Ip, M, R, C, _), (Ip-H)-F) :-
    hora(Instante, H),
    (   M == post,
        R == '/sesion',
        C =:= 401
    ->  F = 1
    ;   F = 0
    ).

% perfil(Grupo, Perfil): el perfil de un cliente en una hora.
perfil((Ip-H)-Fs, perfil(Ip, H, N, F)) :-
    length(Fs, N),
    sum_list(Fs, F).

%!  ejemplos(+Archivo, -Ejemplos:list) is det.
%
%   Ejemplos son los perfiles del registro Archivo como ejemplos del
%   capítulo 69, ej([N, F], Clase): Clase es 1 si el cliente es un
%   atacante de ese día, y -1 si no.
ejemplos(Archivo, Ejemplos) :-
    leer_registro(Archivo, Pedidos),
    perfiles(Pedidos, Perfiles),
    maplist(ejemplo(Archivo), Perfiles, Ejemplos).

% ejemplo(Archivo, Perfil, Ejemplo): el Perfil como ejemplo marcado.
ejemplo(Archivo, perfil(Ip, _, N, F), ej([N, F], Clase)) :-
    (   atacante(Archivo, Ip)
    ->  Clase = 1
    ;   Clase = -1
    ).

%!  ejemplos_de_referencia(-Ejemplos:list) is det.
%
%   Ejemplos son los de todos los días de referencia.
ejemplos_de_referencia(Ejemplos) :-
    dias_de_referencia(Archivos),
    maplist(ejemplos, Archivos, Listas),
    append(Listas, Ejemplos).

%!  separa_con_fallos(+Ejemplos:list) is semidet.
%
%   Algún límite sobre los fallos solos deja de un lado los ejemplos de
%   clase 1 y del otro los de clase -1: el menor fallo de un atacante es
%   mayor que el mayor fallo de los demás.
separa_con_fallos(Ejemplos) :-
    aggregate_all(min(F), member(ej([_, F], 1), Ejemplos), MinAtaque),
    aggregate_all(max(F), member(ej([_, F], -1), Ejemplos), MaxNormal),
    MinAtaque > MaxNormal.

%!  pesos_aprendidos(-Pesos:list(integer)) is semidet.
%
%   Pesos son los del perceptrón entrenado con tasa 1, desde pesos nulos,
%   con los ejemplos de referencia. Falla si el entrenamiento no termina en
%   el máximo de épocas del capítulo 69.
pesos_aprendidos(Pesos) :-
    ejemplos_de_referencia(Ejemplos),
    entrenar(1, Ejemplos, [0, 0, 0], Pesos, _).

%!  sospechosos(+Pesos:list, +Pedidos:list, -Sospechosos:list) is det.
%
%   Sospechosos son los perfiles de los Pedidos a los que el perceptrón con
%   Pesos da la clase 1.
sospechosos(Pesos, Pedidos, Sospechosos) :-
    perfiles(Pedidos, Perfiles),
    include(sospechoso(Pesos), Perfiles, Sospechosos).

% sospechoso(Pesos, Perfil): el perceptrón da al Perfil la clase 1.
sospechoso(Pesos, perfil(_, _, N, F)) :-
    salida(Pesos, [N, F], 1).

%!  aprendizaje(-Pesos:list(integer), -Curva:list(integer)) is semidet.
%
%   Pesos y Curva son los del entrenamiento de pesos_aprendidos/1: los
%   pesos finales y los errores de cada época.
aprendizaje(Pesos, Curva) :-
    ejemplos_de_referencia(Ejemplos),
    entrenar(1, Ejemplos, [0, 0, 0], Pesos, Curva).

%!  extremos_de_fallos(-MinAtaque:integer, -MaxNormal:integer) is det.
%
%   En los ejemplos de referencia, MinAtaque es la menor cantidad de fallos
%   de un perfil de atacante y MaxNormal la mayor de un perfil normal.
extremos_de_fallos(MinAtaque, MaxNormal) :-
    ejemplos_de_referencia(Ejemplos),
    aggregate_all(min(F), member(ej([_, F], 1), Ejemplos), MinAtaque),
    aggregate_all(max(F), member(ej([_, F], -1), Ejemplos), MaxNormal).

%!  sospechosos_del_dia(+Pesos:list, +Archivo, -Sospechosos:list) is det.
%
%   sospechosos/3 con los pedidos del registro Archivo.
sospechosos_del_dia(Pesos, Archivo, Sospechosos) :-
    leer_registro(Archivo, Pedidos),
    sospechosos(Pesos, Pedidos, Sospechosos).
