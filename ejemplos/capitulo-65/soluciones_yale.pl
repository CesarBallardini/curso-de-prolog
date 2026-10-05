:- encoding(utf8).

% Capítulo 65 - Solución del ejercicio 12: la descarga del arma.
%
% El disparo de Yale con un evento más, la descarga del arma. La regla
% causal de la descarga tiene el mismo cuerpo que la persistencia, así que
% la especificidad no decide entre las dos; la superioridad declarada, sí.
% La base repite la de yale.pl y agrega la descarga y la persistencia de
% lo que no vale.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- historia([especificidad], [descarga, espera, disparo], H).
%?- historia([declarada], [descarga, espera, disparo], H).

:- use_module(rebatible).

% vale(F, S): el fluente F vale en la situación S.
vale(vivo, s0).
vale(cargada, s0).

% Persistencia: lo que vale normalmente sigue valiendo después de un
% evento.
vale(F, result(_, S)) :~ vale(F, S).

% Lo que no vale normalmente sigue sin valer: sin esta regla, la descarga
% no persiste.
neg vale(F, result(_, S)) :~ neg vale(F, S).

% Nadie está vivo y muerto en la misma situación.
incompatible(vale(vivo, S), vale(muerto, S)).

% Un disparo con el arma cargada normalmente mata a quien está vivo.
vale(muerto, result(disparo, S)) :~ vale(cargada, S), vale(vivo, S).

% Después de una descarga, el arma normalmente no está cargada.
neg vale(cargada, result(descarga, S)) :~ vale(cargada, S).

% La regla de la descarga prevalece sobre la persistencia.
superior((neg vale(cargada, result(descarga, S)) :~ vale(cargada, S)),
         (vale(F, result(_, S)) :~ vale(F, S))).

%!  historia(+Criterio:list, +Eventos:list, -Historia:list) is det.
%
%   Historia tiene, para la situación inicial y cada prefijo de los
%   Eventos, un término Evento-Cargada-Vivo con las respuestas sobre los
%   fluentes cargada y vivo; el primer Evento es inicio.
historia(Criterio, Eventos, Historia) :-
    findall(Pre, append(Pre, _, Eventos), Prefijos),
    findall(E-C-V,
            ( member(P, Prefijos),
              (   last(P, E)
              ->  true
              ;   E = inicio
              ),
              foldl(despues, P, s0, S),
              respuesta(Criterio, vale(cargada, S), C),
              respuesta(Criterio, vale(vivo, S), V) ),
            Historia).

%!  despues(+E, +S0, -S) is det.
%
%   S es la situación que resulta del evento E en S0.
despues(E, S0, result(E, S0)).
