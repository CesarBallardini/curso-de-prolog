:- encoding(utf8).

% Capítulo 37 - Hilos: crear un hilo, esperar a que termine y ver qué
% comparte con el hilo que lo creó.
%
% ejecutar/2 corre una meta en un hilo nuevo y devuelve cómo terminó: el
% hilo recibe una copia de la meta, y sus ligaduras no vuelven. Los hilos
% comparten la base de datos (anotar/1, visto/1) y no comparten las
% variables globales (global_en_hilo/1).
%
% solo-local: SWISH no permite crear hilos.
%
%?- ejecutar(X = 1, Estado).
%?- en_paralelo([true, fail, X is 1 / 0], Estados).

:- dynamic visto/1.

%!  ejecutar(:Meta, -Estado) is det.
%
%   Corre Meta en un hilo nuevo y espera a que termine. Estado es true si
%   Meta tuvo éxito, false si falló, o exception(E) si lanzó E. Las
%   ligaduras que Meta haga en el otro hilo no llegan a este.
ejecutar(Meta, Estado) :-
    thread_create(Meta, Id),
    thread_join(Id, Estado).

%!  en_paralelo(:Metas:list, -Estados:list) is det.
%
%   Corre cada una de Metas en su propio hilo, todos a la vez, y espera a
%   que terminen. Estados tiene el estado de cada una, en el orden de Metas.
en_paralelo(Metas, Estados) :-
    maplist(crear, Metas, Ids),
    maplist(thread_join, Ids, Estados).

%!  crear(:Meta, -Id) is det.
%
%   Id es un hilo nuevo que corre Meta.
crear(Meta, Id) :-
    thread_create(Meta, Id).

%!  nombres(-Principal, -Otro) is det.
%
%   Principal es el nombre del hilo que llama, y Otro el que da
%   thread_self/1 dentro de un hilo creado con el alias trabajador, que lo
%   anota en visto/1.
nombres(Principal, Otro) :-
    thread_self(Principal),
    retractall(visto(_)),
    thread_create(anotar_nombre, Id, [alias(trabajador)]),
    thread_join(Id, true),
    visto(Otro).

%!  anotar_nombre is det.
%
%   Agrega a la base de datos el nombre del hilo que lo ejecuta.
anotar_nombre :-
    thread_self(Yo),
    assertz(visto(Yo)).

%!  global_en_hilo(-Estado) is det.
%
%   Asigna la variable global clave en este hilo y la lee en otro. Estado
%   es el de ese otro hilo: la clave no existe allí.
global_en_hilo(Estado) :-
    nb_setval(clave, principal),
    ejecutar(nb_getval(clave, _), Estado).
