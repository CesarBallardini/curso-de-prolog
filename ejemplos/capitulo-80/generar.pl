:- encoding(utf8).

% Capítulo 80 - Versión 2: generar y probar.
%
% Una interpretación del dibujo da una etiqueta a cada línea. La versión
% más directa genera todas las combinaciones de etiquetas, una por línea, y
% se queda con las que dan a cada unión una de las combinaciones del
% catálogo. Es correcta y completa, pero con n líneas genera 4 elevado a n
% combinaciones.
%
% solo-local: carga dibujo.pl.
%
%?- etiquetar_gyp(cubo, borde, Lineas).
%?- interpretaciones_gyp(cubo, sin_borde, N).

:- ensure_loaded(dibujo).

%!  etiquetar_gyp(+F, +Modo, -Lineas:list) is nondet.
%
%   Lineas es una interpretación del dibujo F, como pares Linea-Etiqueta:
%   primero se da una etiqueta a cada línea, después se prueba cada unión.
etiquetar_gyp(F, Modo, Lineas) :-
    problema(F, Modo, Lineas, Uniones),
    pairs_values(Lineas, Es),
    maplist(etiqueta, Es),
    maplist(union_valida, Uniones).

%!  union_valida(+U) is semidet.
%
%   Las etiquetas de las líneas de U, vistas desde la unión, forman una de
%   las uniones posibles de su tipo.
union_valida(u(_, Tipo, Vistas)) :-
    maplist(vista, Vistas, Locales),
    union_posible(Tipo, Locales),
    !.

%!  interpretaciones_gyp(+F, +Modo, -N:integer) is det.
%
%   N es la cantidad de interpretaciones del dibujo F.
interpretaciones_gyp(F, Modo, N) :-
    aggregate_all(count, etiquetar_gyp(F, Modo, _), N).
