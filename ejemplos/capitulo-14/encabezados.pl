:- encoding(utf8).

% Capítulo 14 - El encabezado completo, y cómo se verifica lo que promete.
%
% Cada predicado usa un signo de modo que la parte I no necesitaba: ++ (el
% argumento debe llegar completamente instanciado), -- (debe llegar libre) y
% @ (no se instancia más de lo que llega). suma_lista/2 declara además su
% determinación con det/1, que SWI-Prolog verifica en cada llamada.
%
%?- suma_lista([3, 1, 4], S).
%?- primer_multiplo(7, 50, N).

:- det(suma_lista/2).

%!  suma_lista(++L:list(number), -S:number) is det.
%
%   S es la suma de los números de L. L debe llegar completa: la lista y
%   todos sus elementos, porque is/2 no puede sumar una variable.
suma_lista([], 0).
suma_lista([X|Resto], S) :-
    suma_lista(Resto, Faltan),
    S is Faltan + X.

%!  primer_multiplo(+De:integer, +Desde:integer, --N:integer) is semidet.
%
%   N es el primer múltiplo de De a partir de Desde; falla si no hay ninguno
%   hasta 200. N debe llegar libre: con N ligado, el corte no tiene nada que
%   podar, y el predicado aceptaría un múltiplo que no es el primero.
primer_multiplo(De, Desde, N) :-
    between(Desde, 200, N),
    0 =:= N mod De,
    !.

%!  mismo_termino(@A, @B) is semidet.
%
%   A y B son el mismo término, sin ligar ninguna variable de ninguno de los
%   dos.
mismo_termino(A, B) :-
    A == B.
