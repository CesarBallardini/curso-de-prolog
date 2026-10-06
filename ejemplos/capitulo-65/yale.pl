:- encoding(utf8).

% Capítulo 65 - Ampliación: la persistencia y el disparo de Yale.
%
% El cálculo de situaciones: s0 es la situación inicial y result(E, S),
% la que resulta de que ocurra el evento E en la situación S. vale(F, S)
% dice que el fluente F vale en S. Un solo principio de persistencia,
% rebatible, dice que lo que vale en S normalmente sigue valiendo después
% de cualquier evento: es el único axioma de marco. La versión de
% Covington del problema de Hanks y McDermott: Johnnie está vivo y el arma
% está cargada; ocurre una espera y después un disparo. La regla causal del
% disparo pide, además del arma cargada, que Johnnie esté vivo: por eso es
% más específica que la persistencia de vivo, y la derrota.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- respuesta([especificidad], vale(vivo, result(disparo, result(espera, s0))), R).
%?- historia([especificidad], [espera, disparo], H).

:- use_module(rebatible).

% vale(F, S): el fluente F vale en la situación S.
vale(vivo, s0).
vale(cargada, s0).

% Persistencia: lo que vale normalmente sigue valiendo después de un
% evento.
vale(F, result(_, S)) :~ vale(F, S).

% Nadie está vivo y muerto en la misma situación.
incompatible(vale(vivo, S), vale(muerto, S)).

% Un disparo con el arma cargada normalmente mata a quien está vivo.
vale(muerto, result(disparo, S)) :~ vale(cargada, S), vale(vivo, S).

%!  situacion(+Eventos:list, -S) is det.
%
%   S es la situación que resulta de los Eventos, en orden, desde s0.
situacion(Eventos, S) :-
    foldl(despues, Eventos, s0, S).

%!  despues(+E, +S0, -S) is det.
%
%   S es la situación que resulta del evento E en S0.
despues(E, S0, result(E, S0)).

%!  historia(+Criterio:list, +Eventos:list, -Historia:list) is det.
%
%   Historia tiene, para la situación inicial y cada prefijo de los
%   Eventos, un término Evento-Vivo-Muerto con las respuestas sobre los
%   fluentes vivo y muerto; el primer Evento es inicio.
historia(Criterio, Eventos, Historia) :-
    findall(Pre, append(Pre, _, Eventos), Prefijos),
    findall(E-V-M,
            ( member(P, Prefijos),
              (   last(P, E)
              ->  true
              ;   E = inicio
              ),
              situacion(P, S),
              respuesta(Criterio, vale(vivo, S), V),
              respuesta(Criterio, vale(muerto, S), M) ),
            Historia).
