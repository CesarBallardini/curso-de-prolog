:- encoding(utf8).

% Capítulo 84 - Versión 3: métricas por hora, umbrales fijos e informes.
%
% Los pedidos de un día se agrupan por hora, de 8 a 19, hora de Buenos
% Aires, y cada hora se resume en cuatro métricas: los pedidos, los inicios
% de sesión rechazados, los pedidos a rutas inexistentes y el tiempo de CPU.
% Una hora sin pedidos está en la lista, con todas sus métricas en cero.
% Las anomalías son las horas en las que una métrica pasa un límite, y las
% reglas de causa/3 buscan, para cada una, el cliente o la ruta que la
% explica. Los límites son un argumento: aquí, los de umbrales_fijos/1,
% escritos a mano.
%
% solo-local: lee archivos y carga registro.pl.
%
%?- leer_registro(registros('2026-10-01.log'), Ps), metricas(Ps, Hs).

:- module(informes,
          [ hora/2,
            metricas/2,
            medir/2,
            metrica/3,
            escribir_metricas/1,
            umbrales_fijos/1,
            anomalia/3,
            causa/3,
            anomalias/3,
            escribir_anomalias/1,
            hora_del_dia/3,
            informe/1,
            informe_anomalias/2
          ]).

:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(library(aggregate)).
:- reexport(registro).

%!  hora(+Instante:number, -Hora:integer) is det.
%
%   Hora es la hora del Instante en Buenos Aires, UTC-3: el último
%   argumento de stamp_date_time/3 son los segundos al oeste de UTC.
hora(Instante, Hora) :-
    stamp_date_time(Instante, date(_, _, _, Hora, _, _, _, _, _), 10800).

% horas_de_servicio(Desde, Hasta): el servicio atiende de Desde a Hasta,
% hasta el final de esa hora.
horas_de_servicio(8, 19).

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

% hora_del_pedido(Pedido, H): el Pedido llegó en la hora H.
hora_del_pedido(pedido(Instante, _, _, _, _, _), H) :-
    hora(Instante, H).

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

%!  escribir_metricas(+Horas:list) is det.
%
%   Escribe una tabla con las métricas de cada hora.
escribir_metricas(Horas) :-
    format("hora  pedidos  fallos  404    cpu~n"),
    forall(member(hora(H, m(N, F, X, C)), Horas),
           format("~t~d~2| h~t~d~13|~t~d~21|~t~d~26|~t~2f~33|~n",
                  [H, N, F, X, C])).

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

% sumar_grupo(R-Cs, R-S): S es la suma de Cs.
sumar_grupo(R-Cs, R-S) :-
    sum_list(Cs, S).

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

%!  escribir_anomalias(+Registros:list) is det.
%
%   Escribe una línea por anomalía, con su causa.
escribir_anomalias(Registros) :-
    forall(member(anomalia(H, M, V, L)-Causa, Registros),
           ( texto_valor(V, TV),
             texto_limite(L, TL),
             texto_causa(Causa, TC),
             format("~t~d~2| h  ~w ~w ~w~t~30|~w~n", [H, M, TV, TL, TC]) )).

% texto_valor(V, T): el valor V con dos decimales si no es entero.
texto_valor(V, T) :-
    (   integer(V)
    ->  format(atom(T), "~d", [V])
    ;   format(atom(T), "~2f", [V])
    ).

% texto_limite(L, T): el límite como texto.
texto_limite(mayor(X), T) :-
    texto_valor(X, TX),
    format(atom(T), "> ~w", [TX]).
texto_limite(menor(X), T) :-
    texto_valor(X, TX),
    format(atom(T), "< ~w", [TX]).

% texto_causa(C, T): la causa como texto.
texto_causa(cliente(ip(A, B, C, D), K), T) :-
    format(atom(T), "~d.~d.~d.~d, ~d pedidos", [A, B, C, D, K]).
texto_causa(ruta(R, S), T) :-
    format(atom(T), "~w, ~2f s", [R, S]).
texto_causa(sin_trafico, 'sin tráfico').
texto_causa(desconocida, 'causa desconocida').

%!  hora_del_dia(+Archivo, +H:integer, -Metricas) is semidet.
%
%   Metricas son las de la hora H del registro Archivo. Falla si H no es
%   una hora de servicio.
hora_del_dia(Archivo, H, Metricas) :-
    leer_registro(Archivo, Pedidos),
    metricas(Pedidos, Horas),
    memberchk(hora(H, Metricas), Horas).

%!  informe(+Archivo) is det.
%
%   Escribe la tabla de las métricas por hora del registro Archivo.
informe(Archivo) :-
    leer_registro(Archivo, Pedidos),
    metricas(Pedidos, Horas),
    escribir_metricas(Horas).

%!  informe_anomalias(+Archivo, +Umbrales:list) is det.
%
%   Escribe las anomalías del registro Archivo con los Umbrales, con sus
%   causas.
informe_anomalias(Archivo, Umbrales) :-
    leer_registro(Archivo, Pedidos),
    anomalias(Pedidos, Umbrales, Registros),
    escribir_anomalias(Registros).
