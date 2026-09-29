:- encoding(utf8).

% Capítulo 40 - Solución del ejercicio 11: invertir una torre de cuatro
% bloques con medios y fines.
%
% El archivo incluye strips.pl y le agrega el bloque d. torre/1 es el
% estado con d sobre c, c sobre b y b sobre a, y a sobre la mesa.
%
% solo-local: incluye strips.pl con include/1, y SWISH no permite cargar
% otro archivo.
%
%?- torre(E), once(planificar(E, [sobre(a, b), sobre(b, c), sobre(c, d)], P)).

:- discontiguous bloque/1.

:- include(strips).

% bloque(B): B es un bloque; d se agrega a los tres de strips.pl.
bloque(d).

%!  torre(-Estado:list) is det.
%
%   Estado es la torre de d sobre c sobre b sobre a, con a sobre la mesa.
torre(Estado) :-
    list_to_ord_set([sobre(d, c), sobre(c, b), sobre(b, a), sobre(a, mesa),
                     libre(d), mano_vacia],
                    Estado).
