:- encoding(utf8).

% Capítulo 65 - Ampliación: la incompatibilidad con reglas estrictas.
%
% La misma Ping de incompatibles.pl, con la incompatibilidad escrita como
% dos reglas estrictas, una para cada sentido. Para aplicar la regla del
% restaurante hay que verificar que nada derrota la conclusión
% capitalista(ping); la regla estricta neg capitalista(X) :- marxista(X)
% podría hacerlo, así que hay que derivar marxista(ping), y para eso
% verificar que nada derrota esa conclusión, lo que lleva a derivar
% capitalista(ping) de nuevo. La consulta no termina.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- call_with_inference_limit(respuesta([], capitalista(ping), R), 200000, L).

:- use_module(rebatible).

% duena(X, Negocio): X es dueña o dueño de un Negocio.
duena(ping, restaurante).

% nacio_en(X, Pais): X nació en el Pais.
nacio_en(ping, china).

% Quien tiene un negocio normalmente es capitalista; quien nació en China,
% normalmente marxista.
capitalista(X) :~ duena(X, restaurante).
marxista(X) :~ nacio_en(X, china).

% La incompatibilidad, en los dos sentidos: un marxista no es capitalista,
% y un capitalista no es marxista.
neg capitalista(X) :-
    marxista(X).
neg marxista(X) :-
    capitalista(X).
