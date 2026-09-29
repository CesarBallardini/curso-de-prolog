:- encoding(utf8).

% Capítulo 47 - El programa terminado.
%
% Carga las versiones finales del proyecto: la inversa exacta, el
% producto de matrices con símbolos y el planificador de rutas con
% combustible. Cada archivo carga a su vez lo que necesita: matriz.pl, el
% simplificador del capítulo 32 y rutas.pl.
%
% solo-local: carga otros archivos, y SWISH no lo admite.
%
%?- hilbert(4, racional, H), inversa(H, I).
%?- desvio_hilbert(12, flotante, E).
%?- rotacion(y, t, A), rotacion(x, f, B), producto_simbolico(A, B, P).
%?- horario_con_carga(pradera_alta, ermita_vieja, 60, 8:00, H).

:- ensure_loaded(inversa).
:- ensure_loaded(matriz_simbolica).
:- ensure_loaded(rutas_combustible).
