:- encoding(utf8).

% Capítulo 14 - Estabilidad: el argumento de salida se liga después del
% compromiso.
%
% mal_maximo/3 compromete la respuesta en la cabeza, antes del corte: con el
% tercer argumento ligado, la primera cláusula no se elige, el corte no se
% ejecuta, y la segunda responde algo falso. maximo/3 liga la salida después
% del corte, y responde igual con el tercer argumento ligado o libre.
%
%?- maximo(3, 1, M).
%?- maximo(3, 1, 1).

%!  mal_maximo(+X, +Y, -M) is det.
%
%   M pretende ser el mayor de X e Y. Es incorrecta: mal_maximo(3, 1, 1) se
%   cumple, porque la salida se unifica en la cabeza, antes del corte.
mal_maximo(X, Y, X) :-
    X >= Y,
    !.
mal_maximo(_, Y, Y).

%!  maximo(+X, +Y, -M) is det.
%!  maximo(+X, +Y, +M) is semidet.
%
%   M es el mayor de X e Y. La salida se liga después del corte, de modo que
%   el resultado es el mismo con M ligado o libre.
maximo(X, Y, M) :-
    X >= Y,
    !,
    M = X.
maximo(_, Y, Y).
