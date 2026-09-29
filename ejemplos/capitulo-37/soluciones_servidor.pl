:- encoding(utf8).

% Capítulo 37 - Solución del ejercicio 13: visitas contadas por hilo.
%
% Agrega a servidor.pl la ruta /contar_por_hilo, que cuenta las visitas en
% un predicado thread_local: cada trabajador tiene su propia cuenta, que
% sigue creciendo de un pedido al siguiente, sea del cliente que sea.
%
% solo-local: SWISH no permite abrir puertos ni crear hilos.
%
%?- iniciar(P, 3), visitas_por_hilo(P, 30, Cuentas), detener(P).

:- ensure_loaded(servidor).

:- thread_local visitas_del_hilo/1.

:- http_handler(root(contar_por_hilo), contar_por_hilo, []).

%!  contar_por_hilo(+Pedido) is det.
%
%   Suma una visita a la cuenta del trabajador que atiende el pedido, y
%   responde con su nombre y su cuenta.
contar_por_hilo(_Pedido) :-
    (   retract(visitas_del_hilo(N0))
    ->  true
    ;   N0 = 0
    ),
    N is N0 + 1,
    assertz(visitas_del_hilo(N)),
    thread_self(Yo),
    reply_json_dict(_{hilo: Yo, visitas: N}).

%!  visitas_por_hilo(+Puerto:integer, +N:integer, -Cuentas:list) is det.
%
%   Hace N pedidos simultáneos de /contar_por_hilo. Cuentas son los pares
%   Hilo-Maximo: la mayor cuenta que respondió cada trabajador.
visitas_por_hilo(Puerto, N, Cuentas) :-
    numlist(1, N, Is),
    concurrent_maplist(visita(Puerto), Is, Pares),
    msort(Pares, Ordenados),
    findall(H-Max, aggregate(max(V), member(H-V, Ordenados), Max), Cuentas).

%!  visita(+Puerto:integer, +I, -Par) is det.
%
%   Par es Hilo-Visitas, la respuesta de un pedido de /contar_por_hilo.
visita(Puerto, _, Hilo-Visitas) :-
    pedir(Puerto, contar_por_hilo, 200, Respuesta),
    get_dict(hilo, Respuesta, Hilo),
    get_dict(visitas, Respuesta, Visitas).
