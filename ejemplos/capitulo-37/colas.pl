:- encoding(utf8).

% Capítulo 37 - Colas de mensajes: un productor y varios consumidores.
%
% uno_por_trabajo/3 crea un hilo por cada elemento de una lista: crear un
% hilo cuesta más que un trabajo pequeño. con_trabajadores/4 crea N hilos
% trabajadores, que toman los trabajos de una cola y dejan los resultados
% en otra; el hilo que llama es el productor: pone los trabajos y recoge
% los resultados.
%
% solo-local: SWISH no permite crear hilos ni colas de mensajes.
%
%?- con_trabajadores(cuadrado, 4, [1, 2, 3, 4, 5], Pares).
%?- con_trabajadores(raiz_exacta, 2, [16, a, 15], Pares).

%!  cuadrado(+X:number, -Y:number) is det.
%
%   Y es el cuadrado de X.
cuadrado(X, Y) :-
    Y is X * X.

%!  raiz_exacta(+X:integer, -R:integer) is semidet.
%
%   R es la raíz cuadrada de X, si X es un cuadrado perfecto; si no lo es,
%   falla.
raiz_exacta(X, R) :-
    R is truncate(sqrt(X)),
    R * R =:= X.

%!  uno_por_trabajo(:Trabajo, +Xs:list, -Estados:list) is det.
%
%   Corre call(Trabajo, X, _) en un hilo propio para cada X de Xs, todos a
%   la vez. Estados es el estado final de cada hilo, en el orden de Xs.
uno_por_trabajo(Trabajo, Xs, Estados) :-
    maplist(hilo_para(Trabajo), Xs, Ids),
    maplist(thread_join, Ids, Estados).

%!  hilo_para(:Trabajo, +X, -Id) is det.
%
%   Id es un hilo nuevo que corre call(Trabajo, X, _).
hilo_para(Trabajo, X, Id) :-
    thread_create(call(Trabajo, X, _), Id).

%!  con_trabajadores(:Trabajo, +N:integer, +Xs:list, -Pares:list) is det.
%
%   Pares tiene un par X-R por cada X de Xs, ordenados por X: R es
%   resultado(Y) si call(Trabajo, X, Y) tuvo éxito, fallo si falló o
%   error(E) si lanzó E. Los calculan N hilos trabajadores, que toman los
%   trabajos de una cola de a uno.
con_trabajadores(Trabajo, N, Xs, Pares) :-
    message_queue_create(Pendientes, [max_size(100)]),
    message_queue_create(Hechos),
    length(Ids, N),
    maplist(trabajador(Trabajo, Pendientes, Hechos), Ids),
    forall(member(X, Xs), thread_send_message(Pendientes, trabajo(X))),
    forall(member(_, Ids), thread_send_message(Pendientes, fin)),
    length(Xs, Cantidad),
    length(Recibidos, Cantidad),
    maplist(thread_get_message(Hechos), Recibidos),
    maplist(thread_join, Ids, _),
    message_queue_destroy(Pendientes),
    message_queue_destroy(Hechos),
    msort(Recibidos, Pares).

%!  trabajador(:Trabajo, +Pendientes, +Hechos, -Id) is det.
%
%   Id es un hilo nuevo que atiende la cola Pendientes con trabajar/3.
trabajador(Trabajo, Pendientes, Hechos, Id) :-
    thread_create(trabajar(Trabajo, Pendientes, Hechos), Id).

%!  trabajar(:Trabajo, +Pendientes, +Hechos) is det.
%
%   Toma mensajes de Pendientes hasta recibir fin. Por cada trabajo(X),
%   deja en Hechos el par X-R con el resultado de call(Trabajo, X, Y).
trabajar(Trabajo, Pendientes, Hechos) :-
    thread_get_message(Pendientes, Mensaje),
    (   Mensaje = trabajo(X)
    ->  resultado(Trabajo, X, R),
        thread_send_message(Hechos, X-R),
        trabajar(Trabajo, Pendientes, Hechos)
    ;   true
    ).

%!  resultado(:Trabajo, +X, -R) is det.
%
%   R es resultado(Y) si call(Trabajo, X, Y) tiene éxito, fallo si falla y
%   error(E) si lanza la excepción E.
resultado(Trabajo, X, R) :-
    catch(( call(Trabajo, X, Y)
          ->  R = resultado(Y)
          ;   R = fallo
          ),
          E,
          R = error(E)).
