:- encoding(utf8).

% Capítulo 37 - Soluciones de los ejercicios 2, 4, 6, 7, 10, 11 y 12.
%
% solo-local: SWISH no permite crear hilos, colas, mutex, transacciones ni
% motores.
%
%?- respuestas_en_hilo(X, member(X, [a, b, c]), L).
%?- tuberia([1, 2, 3], S).
%?- emparejar(3, multiplo(2), multiplo(5), P).

:- dynamic contador/1, saldo/2.

% contador(N): el valor del contador del ejercicio 6.
contador(0).

% saldo(Cuenta, Monto): el saldo de cada cuenta del ejercicio 7.
saldo(a, 1000).
saldo(b, 1000).
saldo(c, 1000).
saldo(d, 1000).

% --- Ejercicio 2 -----------------------------------------------------------

%!  respuestas_en_hilo(?Plantilla, :Meta, -Lista:list) is det.
%
%   Lista es findall(Plantilla, Meta, Lista), calculada en un hilo nuevo y
%   recibida por la cola del hilo que llama. Si Meta lanza una excepción,
%   se lanza también aquí.
respuestas_en_hilo(Plantilla, Meta, Lista) :-
    thread_self(Yo),
    thread_create(responder(Yo, Plantilla, Meta), Id),
    thread_get_message(respuestas(Id, R)),
    thread_join(Id, _),
    (   R = ok(Lista0)
    ->  Lista = Lista0
    ;   R = error(E),
        throw(E)
    ).

%!  responder(+Destino, ?Plantilla, :Meta) is det.
%
%   Envía a Destino respuestas(Yo, ok(Lista)), con Lista las respuestas de
%   Meta, o respuestas(Yo, error(E)) si Meta lanza E. Yo es este hilo.
responder(Destino, Plantilla, Meta) :-
    thread_self(Yo),
    catch(( findall(Plantilla, Meta, Lista),
            R = ok(Lista) ),
          E,
          R = error(E)),
    thread_send_message(Destino, respuestas(Yo, R)).

% --- Ejercicio 4 -----------------------------------------------------------

%!  tuberia(+Xs:list(number), -Suma:number) is det.
%
%   Suma es la suma de los cuadrados de Xs. Un hilo eleva al cuadrado y
%   otro suma; los une una cola, y el hilo que llama pone los números en
%   otra.
tuberia(Xs, Suma) :-
    thread_self(Yo),
    message_queue_create(Numeros),
    message_queue_create(Cuadrados),
    thread_create(cuadrar(Numeros, Cuadrados), Id1),
    thread_create(sumar_cola(Cuadrados, 0, Yo), Id2),
    forall(member(X, Xs), thread_send_message(Numeros, dato(X))),
    thread_send_message(Numeros, fin),
    thread_get_message(suma(Suma)),
    thread_join(Id1, _),
    thread_join(Id2, _),
    message_queue_destroy(Numeros),
    message_queue_destroy(Cuadrados).

%!  cuadrar(+Entrada, +Salida) is det.
%
%   Por cada dato(X) de Entrada envía dato(Y), con Y el cuadrado de X, a
%   Salida; al recibir fin, envía fin y termina.
cuadrar(Entrada, Salida) :-
    thread_get_message(Entrada, M),
    (   M = dato(X)
    ->  Y is X * X,
        thread_send_message(Salida, dato(Y)),
        cuadrar(Entrada, Salida)
    ;   thread_send_message(Salida, fin)
    ).

%!  sumar_cola(+Entrada, +S0:number, +Destino) is det.
%
%   Suma los dato(X) de Entrada a S0; al recibir fin, envía suma(S) a
%   Destino y termina.
sumar_cola(Entrada, S0, Destino) :-
    thread_get_message(Entrada, M),
    (   M = dato(X)
    ->  S1 is S0 + X,
        sumar_cola(Entrada, S1, Destino)
    ;   thread_send_message(Destino, suma(S0))
    ).

% --- Ejercicio 6 -----------------------------------------------------------

%!  sumar_cas(-N:integer) is det.
%
%   Suma uno a contador/1 con transaction/3: lee el valor fuera del mutex y
%   lo reemplaza solo si sigue siendo el que leyó; si no, repite. N es el
%   valor nuevo.
sumar_cas(N) :-
    repeat,
    transaction(( contador(N0),
                  N is N0 + 1 ),
                ( retract(contador(N0)),
                  assertz(contador(N)) ),
                contador),
    !.

%!  sumar_en_hilos(+Hilos:integer, +Veces:integer, -Final:integer) is det.
%
%   Pone el contador en cero, corre Hilos hilos que llaman Veces veces a
%   sumar_cas/1, y Final es el valor que queda.
sumar_en_hilos(Hilos, Veces, Final) :-
    retractall(contador(_)),
    assertz(contador(0)),
    length(Ids, Hilos),
    maplist(hilo_sumador(Veces), Ids),
    maplist(thread_join, Ids, _),
    contador(Final).

%!  hilo_sumador(+Veces:integer, -Id) is det.
%
%   Id es un hilo que llama Veces veces a sumar_cas/1.
hilo_sumador(Veces, Id) :-
    thread_create(forall(between(1, Veces, _), sumar_cas(_)), Id).

% --- Ejercicio 7 -----------------------------------------------------------

%!  mover(+Desde:atom, +Hacia:atom, +Monto:integer) is det.
%
%   Resta Monto del saldo de Desde y lo suma al de Hacia, sin protección.
mover(Desde, Hacia, Monto) :-
    retract(saldo(Desde, S0)),
    S is S0 - Monto,
    assertz(saldo(Desde, S)),
    retract(saldo(Hacia, T0)),
    T is T0 + Monto,
    assertz(saldo(Hacia, T)).

%!  transferir_ingenuo(+Desde:atom, +Hacia:atom, +Monto:integer) is det.
%
%   Toma el mutex de Desde y después el de Hacia. Dos hilos que transfieren
%   en sentidos opuestos pueden esperarse para siempre.
transferir_ingenuo(Desde, Hacia, Monto) :-
    with_mutex(Desde,
               with_mutex(Hacia, mover(Desde, Hacia, Monto))).

%!  transferir(+Desde:atom, +Hacia:atom, +Monto:integer) is det.
%
%   Toma los dos mutex siempre en el orden de sus nombres: ningún hilo
%   espera un mutex que tiene otro hilo que a su vez espera el suyo.
transferir(Desde, Hacia, Monto) :-
    msort([Desde, Hacia], [Primero, Segundo]),
    with_mutex(Primero,
               with_mutex(Segundo, mover(Desde, Hacia, Monto))).

%!  opuestas(:Transferir, +Veces:integer, -Resultado) is det.
%
%   Un hilo transfiere Veces veces de a a b, y otro de b a a, con
%   Transferir. Resultado es terminaron si los dos terminan en 5 segundos,
%   o detenidos si no; en ese caso los hilos quedan esperando.
opuestas(Transferir, Veces, Resultado) :-
    thread_self(Yo),
    thread_create(repetir(Transferir, a, b, Veces, Yo), _, [detached(true)]),
    thread_create(repetir(Transferir, b, a, Veces, Yo), _, [detached(true)]),
    (   thread_get_message(Yo, listo, [timeout(5)]),
        thread_get_message(Yo, listo, [timeout(5)])
    ->  Resultado = terminaron
    ;   Resultado = detenidos
    ).

%!  repetir(:Transferir, +Desde, +Hacia, +Veces:integer, +Destino) is det.
%
%   Transfiere 1 de Desde a Hacia Veces veces y envía listo a Destino.
repetir(Transferir, Desde, Hacia, Veces, Destino) :-
    forall(between(1, Veces, _), call(Transferir, Desde, Hacia, 1)),
    thread_send_message(Destino, listo).

%!  al_azar(+Hilos:integer, +Veces:integer, -Total:integer, -Hechos:integer)
%!      is det.
%
%   Hilos hilos hacen Veces transferencias cada uno con transferir/3, entre
%   cuentas y montos al azar. Total es la suma de los saldos al terminar, y
%   Hechos la cantidad de hechos saldo/2.
al_azar(Hilos, Veces, Total, Hechos) :-
    length(Ids, Hilos),
    maplist(hilo_al_azar(Veces), Ids),
    maplist(thread_join, Ids, _),
    aggregate_all(sum(S), saldo(_, S), Total),
    aggregate_all(count, saldo(_, _), Hechos).

%!  hilo_al_azar(+Veces:integer, -Id) is det.
%
%   Id es un hilo que hace Veces transferencias al azar entre cuentas
%   distintas.
hilo_al_azar(Veces, Id) :-
    thread_create(forall(between(1, Veces, _),
                         ( random_member(D, [a, b, c, d]),
                           random_member(H, [a, b, c, d]),
                           D \== H
                         ->  random_between(1, 10, M),
                             transferir(D, H, M)
                         ;   true )),
                  Id).

% --- Ejercicio 10 ----------------------------------------------------------

%!  posicion_extremos(+Lista:list, :Condicion, -Pos:integer) is semidet.
%
%   Pos es la posición, desde 1, de un elemento de Lista que cumple
%   Condicion: el primero desde el principio o el primero desde el final,
%   según qué búsqueda termine antes. Falla si ninguno la cumple.
posicion_extremos(Lista, Condicion, Pos) :-
    first_solution(Pos, [ desde_el_principio(Lista, Condicion, Pos),
                          desde_el_final(Lista, Condicion, Pos) ],
                   []).

%!  desde_el_principio(+Lista:list, :Condicion, -Pos:integer) is semidet.
%
%   Pos es la posición del primer elemento de Lista que cumple Condicion.
desde_el_principio(Lista, Condicion, Pos) :-
    nth1(Pos, Lista, X),
    call(Condicion, X),
    !.

%!  desde_el_final(+Lista:list, :Condicion, -Pos:integer) is semidet.
%
%   Pos es la posición del último elemento de Lista que cumple Condicion.
desde_el_final(Lista, Condicion, Pos) :-
    reverse(Lista, Invertida),
    length(Lista, N),
    nth1(I, Invertida, X),
    call(Condicion, X),
    !,
    Pos is N + 1 - I.

% --- Ejercicio 11 ----------------------------------------------------------

%!  multiplo(+K:integer, -M:integer) is multi.
%
%   M es un múltiplo positivo de K, en orden creciente, sin fin.
multiplo(K, M) :-
    between(1, inf, N),
    M is K * N.

%!  emparejar(+N:integer, :Gen1, :Gen2, -Pares:list) is det.
%
%   Pares son los primeros N pares X-Y, con X la i-ésima respuesta de
%   call(Gen1, X) e Y la i-ésima de call(Gen2, Y); menos, si alguno de los
%   dos generadores se termina antes.
emparejar(N, Gen1, Gen2, Pares) :-
    setup_call_cleanup(( engine_create(X, call(Gen1, X), M1),
                         engine_create(Y, call(Gen2, Y), M2) ),
                       pares(N, M1, M2, Pares),
                       ( engine_destroy(M1),
                         engine_destroy(M2) )).

%!  pares(+N:integer, +M1, +M2, -Pares:list) is det.
%
%   Pares son los N pares siguientes de las respuestas de M1 y M2.
pares(N, M1, M2, Pares) :-
    (   N > 0,
        engine_next(M1, X),
        engine_next(M2, Y)
    ->  Pares = [X-Y|Resto],
        N1 is N - 1,
        pares(N1, M1, M2, Resto)
    ;   Pares = []
    ).

% --- Ejercicio 12 ----------------------------------------------------------

%!  nuevo_generador(-Motor) is det.
%
%   Motor da los identificadores id(1), id(2), ... de a uno.
nuevo_generador(Motor) :-
    engine_create(Id, identificador(1, Id), Motor).

%!  identificador(+N:integer, -Id) is multi.
%
%   Id es id(N), id(N + 1), ..., en ese orden, sin fin.
identificador(N, id(N)).
identificador(N, Id) :-
    N1 is N + 1,
    identificador(N1, Id).

%!  siguiente_id(+Motor, -Id) is det.
%
%   Id es el identificador siguiente de Motor.
siguiente_id(Motor, Id) :-
    engine_next(Motor, Id).
