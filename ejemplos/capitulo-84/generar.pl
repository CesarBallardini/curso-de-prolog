:- encoding(utf8).

% Capítulo 84 - El generador de los registros del capítulo.
%
% Escribe en archivos/ los registros de cuatro días del servicio de
% Inscripciones, del 28 de septiembre al 1 de octubre de 2026, de 8 a 20
% horas (hora de Buenos Aires, UTC-3), con el formato de library(http/http_log):
% un término request/3 al llegar cada pedido, un término completed/5 al
% responderlo y un término server/2 al arrancar y al detener el servidor.
% Escribe también el último día con el formato común de los servidores web,
% una línea de texto por pedido respondido.
%
% Los pedidos normales son sesiones de alumnos: algunas contraseñas mal
% escritas, el inicio de sesión y varias consultas. Los incidentes están
% descritos como hechos: intentos de adivinar contraseñas, una exploración
% de rutas inexistentes, una hora lenta y una caída del servidor. Los
% números salen de un generador congruencial lineal con semilla fija, así
% que el resultado es el mismo en cualquier máquina.
%
% solo-local: escribe archivos.
%
%?- generar.

:- module(generar,
          [ generar/0,
            dia/2,
            azar/4,
            sesiones/4,
            eventos_del_dia/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

:- multifile user:file_search_path/2.
:- prolog_load_context(directory, Aqui),
   directory_file_path(Aqui, archivos, Dir),
   asserta(user:file_search_path(registros, Dir)).

% dia(N, Fecha): el día N del registro es Fecha, date(Anio, Mes, Dia).
dia(1, date(2026, 9, 28)).
dia(2, date(2026, 9, 29)).
dia(3, date(2026, 9, 30)).
dia(4, date(2026, 10, 1)).

% Las horas son segundos desde las 8:00 del día; el servicio atiende
% 12 horas.
duracion_del_servicio(43200).

% sesiones_por_dia(N): cantidad de sesiones comunes de alumnos por día.
sesiones_por_dia(50).

% sesion_larga(Dia, Desde, Legajo, Errores, Consultas): una sesión con
% muchas contraseñas mal escritas y muchas consultas.
sesion_larga(1, 13800, 131, 5, 13).
sesion_larga(2, 22000, 144, 6, 15).
sesion_larga(3, 9000, 108, 7, 16).
sesion_larga(3, 30100, 152, 5, 12).
sesion_larga(4, 25300, 127, 6, 14).

% ataque(Dia, Ip, Desde, Intentos, Intervalo, Legajo): Intentos inicios de
% sesión rechazados, uno cada Intervalo segundos, más o menos un tercio.
ataque(2, ip(198, 51, 100, 23), 25500, 25, 120, 117).
ataque(3, ip(198, 51, 100, 40), 31000, 8, 300, 140).
ataque(4, ip(203, 0, 113, 7), 8400, 60, 4, 103).
ataque(4, ip(198, 51, 100, 61), 21700, 17, 200, 125).

% exploracion(Dia, Ip, Desde, Rutas): pedidos a rutas que no existen.
exploracion(3, ip(203, 0, 113, 50), 11100,
            [ '/admin', '/wp-login.php', '/.env', '/phpmyadmin',
              '/config.php', '/backup.zip', '/.git/config', '/login',
              '/admin.php', '/server-status' ]).

% lento(Dia, Desde, Hasta, Factor): el tiempo de CPU se multiplica por
% Factor.
lento(4, 14400, 18000, 9).

% caida(Dia, Desde, Hasta): el servidor deja de responder en Desde y
% arranca de nuevo en Hasta.
caida(4, 33000, 39900).

%!  azar(+N:integer, -X:integer, +S0:integer, -S:integer) is det.
%
%   X es un entero entre 0 y N - 1, y S el estado del generador después de
%   S0: un generador congruencial lineal con los parámetros de la
%   biblioteca de C.
azar(N, X, S0, S) :-
    S is (1103515245 * S0 + 12345) mod 2147483648,
    X is (S >> 8) mod N.

%!  generar is det.
%
%   Escribe los cuatro registros y la copia en formato común del último.
generar :-
    forall(dia(N, _), escribir_dia(N)),
    escribir_comun(4).

%!  sesiones(+Dia:integer, -Eventos:list, +S0:integer, -S:integer) is det.
%
%   Eventos son los pedidos de las sesiones comunes del Dia, como términos
%   ev(Hora, Ip, Metodo, Ruta, Codigo, Bytes, Cpu).
sesiones(Dia, Eventos, S0, S) :-
    sesiones_por_dia(K),
    numlist(1, K, Is),
    foldl(sesion_comun(Dia), Is, Listas, S0, S),
    append(Listas, Eventos).

% sesion_comun(Dia, I, Eventos, S0, S): la sesión I del Dia. Las sesiones
% se reparten en tramos iguales del día, una por tramo, en un momento
% elegido al azar dentro del tramo.
sesion_comun(_, I, Eventos, S0, S) :-
    duracion_del_servicio(D),
    sesiones_por_dia(K),
    Tramo is (D - 1200) // K,
    azar(Tramo, X, S0, S1),
    Desde is (I - 1) * Tramo + X,
    azar(60, L, S1, S2),
    Legajo is 101 + L,
    azar(100, R, S2, S3),
    errores(R, Errores),
    azar(9, M, S3, S4),
    Consultas is M + 2,
    sesion(Desde, Legajo, Errores, Consultas, Eventos, S4, S).

% errores(R, E): con R entre 0 y 99, E contraseñas mal escritas.
errores(R, 0) :- R < 55, !.
errores(R, 1) :- R < 80, !.
errores(R, 2) :- R < 92, !.
errores(R, 3) :- R < 97, !.
errores(_, 4).

%!  sesion(+Desde, +Legajo, +Errores, +Consultas, -Eventos, +S0, -S) is det.
%
%   Eventos son los pedidos de una sesión del alumno Legajo desde la hora
%   Desde: Errores inicios de sesión rechazados, uno aceptado y Consultas
%   consultas.
sesion(Desde, Legajo, Errores, Consultas, Eventos, S0, S) :-
    Cuarto is Legajo - 100,
    Ip = ip(10, 1, 0, Cuarto),
    rechazos(Errores, Desde, Ip, Hora1, Rechazos, S0, S1),
    azar(1000, Ms, S1, S2),
    H1 is Hora1 + Ms / 1000,
    cpu(sesion, Cpu1, S2, S3),
    Aceptado = ev(H1, Ip, post, '/sesion', 200, 98, Cpu1),
    consultas(Consultas, H1, Ip, Legajo, Resto, S3, S),
    append(Rechazos, [Aceptado|Resto], Eventos).

% rechazos(N, Hora0, Ip, Hora, Eventos, S0, S): N inicios de sesión
% rechazados desde Hora0; Hora es la hora del pedido siguiente.
rechazos(0, Hora, _, Hora, [], S, S) :- !.
rechazos(N, Hora0, Ip, Hora, [ev(H, Ip, post, '/sesion', 401, 36, Cpu)|Es],
         S0, S) :-
    azar(1000, Ms, S0, S1),
    H is Hora0 + Ms / 1000,
    cpu(sesion, Cpu, S1, S2),
    azar(12, Pausa, S2, S3),
    Hora1 is Hora0 + 4 + Pausa,
    N1 is N - 1,
    rechazos(N1, Hora1, Ip, Hora, Es, S3, S).

% consultas(N, Hora0, Ip, Legajo, Eventos, S0, S): N consultas después de
% la hora Hora0.
consultas(0, _, _, _, [], S, S) :- !.
consultas(N, Hora0, Ip, Legajo,
          [ev(H, Ip, Metodo, Ruta, Codigo, Bytes, Cpu)|Es], S0, S) :-
    azar(38, Pausa, S0, S1),
    azar(1000, Ms, S1, S2),
    H is truncate(Hora0) + 3 + Pausa + Ms / 1000,
    azar(10, Tipo, S2, S3),
    consulta(Tipo, Legajo, Metodo, Ruta, Codigo, Bytes, S3, S4),
    cpu(consulta, Cpu, S4, S5),
    N1 is N - 1,
    consultas(N1, H, Ip, Legajo, Es, S5, S).

% consulta(Tipo, Legajo, Metodo, Ruta, Codigo, Bytes, S0, S): una consulta
% de la clase Tipo, entre 0 y 9.
consulta(T, _, get, '/materias', 200, 412, S, S) :-
    T < 3, !.
consulta(T, Legajo, get, Ruta, 200, Bytes, S0, S) :-
    T < 5, !,
    format(atom(Ruta), "/alumnos/~d", [Legajo]),
    azar(80, B, S0, S),
    Bytes is 180 + B.
consulta(T, _, get, Ruta, 200, Bytes, S0, S) :-
    T < 7, !,
    azar(5, K, S0, S1),
    nth0(K, [algebra, analisis, fisica, logica, sistemas], Materia),
    format(atom(Ruta), "/materias/~w/promedio", [Materia]),
    azar(20, B, S1, S),
    Bytes is 40 + B.
consulta(7, _, get, '/ranking', 200, Bytes, S0, S) :-
    !,
    azar(200, B, S0, S),
    Bytes is 900 + B.
consulta(_, _, post, '/mis-inscripciones', Codigo, Bytes, S0, S) :-
    azar(5, K, S0, S),
    (   K =:= 0
    ->  Codigo = 409,
        Bytes = 41
    ;   Codigo = 200,
        Bytes = 17
    ).

% cpu(Clase, Cpu, S0, S): el tiempo de CPU de un pedido, en segundos. El
% inicio de sesión calcula el resumen de la contraseña, y es más caro.
cpu(sesion, Cpu, S0, S) :-
    azar(8000, X, S0, S),
    Cpu is (42000 + X) / 1000000.
cpu(consulta, Cpu, S0, S) :-
    azar(2500, X, S0, S),
    Cpu is (800 + X) / 1000000.

%!  incidentes(+Dia:integer, -Eventos:list, +S0:integer, -S:integer) is det.
%
%   Eventos son los pedidos de los ataques, las exploraciones y las
%   sesiones largas del Dia.
incidentes(Dia, Eventos, S0, S) :-
    findall(ataque(Ip, Desde, N, Int, Leg),
            ataque(Dia, Ip, Desde, N, Int, Leg), As),
    foldl(incidente, As, L1, S0, S1),
    findall(exploracion(Ip, Desde, Rs),
            exploracion(Dia, Ip, Desde, Rs), Xs),
    foldl(incidente, Xs, L2, S1, S2),
    findall(larga(Desde, Leg, E, C),
            sesion_larga(Dia, Desde, Leg, E, C), Ls),
    foldl(incidente, Ls, L3, S2, S),
    append([L1, L2, L3], Listas),
    append(Listas, Eventos).

% incidente(Descripcion, Eventos, S0, S): los pedidos de un incidente.
incidente(ataque(Ip, Desde, N, Int, _), Eventos, S0, S) :-
    intentos(N, Desde, Ip, Int, Eventos, S0, S).
incidente(exploracion(Ip, Desde, Rutas), Eventos, S0, S) :-
    foldl(explorar(Ip), Rutas, Eventos, Desde-S0, _-S).
incidente(larga(Desde, Legajo, Errores, Consultas), Eventos, S0, S) :-
    sesion(Desde, Legajo, Errores, Consultas, Eventos, S0, S).

% intentos(N, Hora, Ip, Intervalo, Eventos, S0, S): N inicios de sesión
% rechazados, separados por Intervalo segundos, más o menos un tercio.
intentos(0, _, _, _, [], S, S) :- !.
intentos(N, Hora0, Ip, Int,
         [ev(H, Ip, post, '/sesion', 401, 36, Cpu)|Es], S0, S) :-
    azar(1000, Ms, S0, S1),
    H is Hora0 + Ms / 1000,
    cpu(sesion, Cpu, S1, S2),
    Tercio is max(1, Int * 2 // 3),
    azar(Tercio, J, S2, S3),
    Hora1 is Hora0 + Int - Int // 3 + J,
    N1 is N - 1,
    intentos(N1, Hora1, Ip, Int, Es, S3, S).

% explorar(Ip, Ruta, Evento, Hora0-S0, Hora-S): un pedido a una ruta que
% no existe.
explorar(Ip, Ruta, ev(H, Ip, get, Ruta, 404, 361, Cpu), Hora0-S0, Hora-S) :-
    azar(1000, Ms, S0, S1),
    H is Hora0 + Ms / 1000,
    cpu(consulta, Cpu, S1, S2),
    azar(3, P, S2, S),
    Hora is Hora0 + 1 + P.

%!  eventos_del_dia(+Dia:integer, -Eventos:list) is det.
%
%   Eventos son los pedidos del Dia, ordenados por hora, con el tiempo de
%   CPU de la hora lenta multiplicado y sin los de la caída.
eventos_del_dia(Dia, Eventos) :-
    S0 is 20261000 + Dia,
    sesiones(Dia, E1, S0, S1),
    incidentes(Dia, E2, S1, _),
    append(E1, E2, E3),
    duracion_del_servicio(D),
    include(dentro(D), E3, E4),
    maplist(lentitud(Dia), E4, E5),
    msort(E5, Eventos).

% dentro(D, E): el evento E ocurre antes de D segundos desde las 8:00.
dentro(D, ev(H, _, _, _, _, _, _)) :-
    H < D.

% lentitud(Dia, E0, E): E es E0 con el tiempo de CPU de la hora lenta.
lentitud(Dia, ev(H, Ip, M, R, C, B, Cpu0), ev(H, Ip, M, R, C, B, Cpu)) :-
    (   lento(Dia, Desde, Hasta, F),
        H >= Desde,
        H < Hasta
    ->  Cpu is Cpu0 * F
    ;   Cpu = Cpu0
    ).

% base(Dia, T): T es el instante de las 8:00 del Dia, hora de Buenos Aires.
base(Dia, T) :-
    dia(Dia, date(A, M, D)),
    date_time_stamp(date(A, M, D, 8, 0, 0, 10800, -, -), T).

% escribir_dia(Dia): escribe el registro del Dia en formato de http_log.
escribir_dia(Dia) :-
    eventos_del_dia(Dia, Eventos),
    registros_del_dia(Dia, Eventos, Lineas),
    dia(Dia, date(A, M, D)),
    format(atom(Nombre), "~d-~|~`0t~d~2+-~|~`0t~d~2+.log", [A, M, D]),
    absolute_file_name(registros(Nombre), Ruta),
    setup_call_cleanup(open(Ruta, write, Out, [encoding(utf8)]),
                       forall(member(_-L, Lineas), format(Out, "~w~n", [L])),
                       close(Out)).

% registros_del_dia(Dia, Eventos, Lineas): Lineas son pares Instante-Texto
% de los términos del registro, en orden de escritura.
registros_del_dia(Dia, Eventos, Ordenadas) :-
    base(Dia, T0),
    Arranque is T0 - 30,
    linea_server(started, Arranque, L0),
    (   caida(Dia, Desde, Hasta)
    ->  partition(antes_de(Desde), Eventos, Antes, Despues0),
        exclude(antes_de(Hasta), Despues0, Despues),
        corrida(Antes, T0, pendiente, Ls1),
        Rearranque is T0 + Hasta,
        linea_server(started, Rearranque, L1),
        corrida(Despues, T0, completa, Ls2),
        append([[Arranque-L0], Ls1, [Rearranque-L1], Ls2], Ls)
    ;   corrida(Eventos, T0, completa, Ls1),
        Ls = [Arranque-L0|Ls1]
    ),
    duracion_del_servicio(Dur),
    Fin is T0 + Dur + 300,
    linea_server(stopped, Fin, Lf),
    append(Ls, [Fin-Lf], Todas),
    msort(Todas, Ordenadas).

% antes_de(Hora, E): el evento E ocurre antes de Hora.
antes_de(Hora, ev(H, _, _, _, _, _, _)) :-
    H < Hora.

% corrida(Eventos, T0, Final, Lineas): las líneas de una corrida del
% servidor, con los pedidos numerados desde 1. Si Final es pendiente, el
% último pedido queda sin completed/5: el servidor se detuvo antes de
% responderlo.
corrida(Eventos, T0, Final, Lineas) :-
    length(Eventos, N),
    numlist(1, N, Ids),
    maplist(lineas_pedido(T0, N, Final), Ids, Eventos, Listas),
    append(Listas, Lineas).

% lineas_pedido(T0, N, Final, Id, Evento, Lineas): las líneas de request/3
% y de completed/5 del pedido Id.
lineas_pedido(T0, N, Final, Id, ev(H, Ip, M, R, C, B, Cpu), Lineas) :-
    T is round((T0 + H) * 1000) / 1000,
    stamp_date_time(T, Fecha, 10800),
    comentario(Fecha, Coment),
    Ip = ip(A, B1, C1, D1),
    format(atom(Req),
           "~w request(~d, ~3f, [peer(ip(~d,~d,~d,~d)),method(~w),\c
            request_uri(~q),path(~q),http_version(1-1),host(localhost),\c
            port(8083)]).",
           [Coment, Id, T, A, B1, C1, D1, M, R, R]),
    (   Final == pendiente,
        Id =:= N
    ->  Lineas = [T-Req]
    ;   estado(C, R, Estado),
        Tc is T + Cpu + 0.0005,
        format(atom(Comp), "completed(~d, ~6f, ~d, ~d, ~q).",
               [Id, Cpu, B, C, Estado]),
        Lineas = [T-Req, Tc-Comp]
    ).

% estado(Codigo, Ruta, Estado): el último argumento de completed/5.
estado(404, Ruta, error(404, Ruta)) :- !.
estado(_, _, ok).

% linea_server(Motivo, T, Linea): el término server/2 del instante T.
linea_server(Motivo, T, Linea) :-
    format(atom(Linea), "server(~w, ~0f).", [Motivo, T]).

% comentario(Fecha, C): la fecha como la escribe http_log, entre /* y */.
comentario(date(A, M, D, H, Mi, S, _, _, _), C) :-
    Seg is truncate(S),
    day_of_the_week(date(A, M, D), DS),
    nth1(DS, ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'], ND),
    nth1(M, ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug',
             'Sep', 'Oct', 'Nov', 'Dec'], NM),
    format(atom(C), "/*~w ~w ~|~`0t~d~2+ ~|~`0t~d~2+:~|~`0t~d~2+:\c
                     ~|~`0t~d~2+ ~d*/",
           [ND, NM, D, H, Mi, Seg, A]).

% escribir_comun(Dia): escribe los pedidos respondidos del Dia en el
% formato común, con dos líneas defectuosas: un pedido que no es HTTP, y la
% última línea antes de la caída, cortada a la mitad.
escribir_comun(Dia) :-
    eventos_del_dia(Dia, Eventos),
    base(Dia, T0),
    caida(Dia, Desde, Hasta),
    partition(antes_de(Desde), Eventos, Antes, Despues0),
    append(Respondidos0, [_Pendiente], Antes),
    exclude(antes_de(Hasta), Despues0, Despues),
    maplist(linea_comun(T0), Respondidos0, Lineas1),
    append(Lineas2, [Ultima], Lineas1),
    sub_atom(Ultima, 0, 38, _, Cortada),
    maplist(linea_comun(T0), Despues, Lineas3),
    append([Lineas2, [Cortada], Lineas3], Lineas4),
    tls(Tls),
    insertar_por_minuto(Tls, Lineas4, Lineas),
    dia(Dia, date(A, M, D)),
    format(atom(Nombre), "~d-~|~`0t~d~2+-~|~`0t~d~2+-comun.log", [A, M, D]),
    absolute_file_name(registros(Nombre), Ruta),
    setup_call_cleanup(open(Ruta, write, Out, [encoding(utf8)]),
                       forall(member(L, Lineas), format(Out, "~w~n", [L])),
                       close(Out)).

% linea_comun(T0, E, Linea): el evento E en el formato común.
linea_comun(T0, ev(H, ip(A, B, C, D), M, R, Cod, Bytes, _), Linea) :-
    T is truncate(T0 + H),
    stamp_date_time(T, date(Y, Mo, Di, Ho, Mi, S, _, _, _), 10800),
    Seg is truncate(S),
    nth1(Mo, ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug',
              'Sep', 'Oct', 'Nov', 'Dec'], NM),
    upcase_atom(M, Metodo),
    format(atom(Linea),
           "~d.~d.~d.~d - - [~|~`0t~d~2+/~w/~d:~|~`0t~d~2+:~|~`0t~d~2+:\c
            ~|~`0t~d~2+ -0300] \"~w ~w HTTP/1.1\" ~d ~d",
           [A, B, C, D, Di, NM, Y, Ho, Mi, Seg, Metodo, R, Cod, Bytes]).

% tls(L): la línea de un cliente que habla TLS con el puerto HTTP.
tls('203.0.113.50 - - [01/Oct/2026:08:41:07 -0300] "\\x16\\x03\\x01" 400 0').

% insertar_por_minuto(L, Lineas0, Lineas): Lineas es Lineas0 con L después
% de las líneas de su mismo minuto.
insertar_por_minuto(L, Lineas0, Lineas) :-
    minuto(L, M),
    partition(no_despues(M), Lineas0, Antes, Despues),
    append(Antes, [L|Despues], Lineas).

% no_despues(M, L): el minuto de la línea L no es posterior a M.
no_despues(M, L) :-
    minuto(L, ML),
    ML @=< M.

% minuto(L, M): M es el texto del día, la hora y el minuto de la línea L.
minuto(L, M) :-
    sub_atom(L, B, _, _, '['),
    !,
    B1 is B + 1,
    sub_atom(L, B1, 17, _, M).
