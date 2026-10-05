:- encoding(utf8).

% Capítulo 65 - Ampliación: conclusiones incompatibles.
%
% Dos literales pueden excluirse sin ser uno la negación del otro: nadie es
% a la vez capitalista y marxista. incompatible/2 lo declara, y contrario/2
% del motor devuelve, además del complemento, los literales incompatibles.
% Ping nació en China y tiene un restaurante: cada hecho apoya una de dos
% conclusiones incompatibles. Sin superioridad, las dos reglas se derrotan;
% con la superioridad declarada, prevalece la del restaurante. Lucas tiene
% un restaurante y nació en Uruguay: nada se opone a la primera regla.
%
% solo-local: carga el módulo rebatible, y SWISH no admite módulos propios.
%
%?- respuesta([], capitalista(ping), R).
%?- respuesta([declarada], capitalista(ping), R).

:- use_module(rebatible).

% duena(X, Negocio): X es dueña o dueño de un Negocio.
duena(ping, restaurante).
duena(lucas, restaurante).

% nacio_en(X, Pais): X nació en el Pais.
nacio_en(ping, china).
nacio_en(lucas, uruguay).

% Quien tiene un negocio normalmente es capitalista; quien nació en China,
% normalmente marxista.
capitalista(X) :~ duena(X, restaurante).
marxista(X) :~ nacio_en(X, china).

% incompatible(A, B): A y B no pueden valer a la vez.
incompatible(capitalista(X), marxista(X)).

% Tener un negocio es mejor evidencia que el lugar de nacimiento.
superior((capitalista(X) :~ duena(X, restaurante)),
         (marxista(X) :~ nacio_en(X, china))).
