:- encoding(utf8).

% Capítulo 54 - Versión 4: un sintagma que no se genera.
%
% sn_ingenuo//2 es el sintagma nominal inglés de ingles.pl escrito de la
% manera natural para un analizador: el artículo mira la palabra que le
% sigue con el pushback del capítulo 21, y elige «a» o «an» en ese momento.
% Analiza bien; para generar, esa palabra todavía no existe cuando se
% elige el artículo, y la consulta termina en un error. sn_en//2, en
% ingles.pl, comprueba la misma condición al final del sintagma.
%
% solo-local: carga ingles.pl con ensure_loaded/1.
%
%?- phrase(sn_ingenuo(SN, N), ["an", "old", "book"]).
%?- phrase(sn_ingenuo(sn(a, [], apple, sg), sg), Ps).

:- ensure_loaded(ingles).

%!  sn_ingenuo(?SN, ?N)// is nondet.
%
%   Como sn_en//2, con la forma del artículo elegida antes de los
%   adjetivos y el nombre. Solo analiza: para generar, SN instanciado
%   produce un error de instanciación.
sn_ingenuo(sn(A, As, L, N), N) -->
    articulo_ingenuo(A, N),
    adjetivos_en(As, _, Nombre),
    nombre_en(L, N, Nombre).

%!  articulo_ingenuo(?A, ?N)// is nondet.
%
%   El artículo A en número N, con la forma que corresponde a la palabra
%   siguiente, que se examina y se devuelve a la entrada.
articulo_ingenuo(sin, pl) -->
    [].
articulo_ingenuo(A, N), [P] -->
    [F, P],
    { articulo_en(A, N, F),
      antes_de(F, P) }.
