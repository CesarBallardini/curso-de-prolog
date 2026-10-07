:- encoding(utf8).

% Capítulo 9 - Generar y probar.
%
% Cuando la respuesta no se puede calcular de manera directa, se generan
% candidatos y se verifica cada uno. El corte detiene la búsqueda en el primero
% que cumple la condición.
%
%?- primer_multiplo(7, 20, N).
%?- dos_que_suman(49, A, B).

% edad(P, A): P tiene A años.
edad(juan, 68).
edad(ana, 41).
edad(pedro, 45).
edad(luis, 12).
edad(eva, 8).

%!  multiplo(+De, +Desde, ?N) is nondet.
%
%   N es un múltiplo de De, mayor o igual que Desde. between/3 genera los
%   candidatos y la condición con mod los verifica.
multiplo(De, Desde, N) :-
    between(Desde, 200, N),
    0 =:= N mod De.

%!  primer_multiplo(+De, +Desde, -N) is semidet.
%
%   N es el primero de esos múltiplos, y solo él; falla si no hay ninguno
%   entre Desde y 200. N debe llegar libre: con N ya ligado, el corte no
%   tiene nada que podar.
primer_multiplo(De, Desde, N) :-
    multiplo(De, Desde, N),
    !.

%!  dos_que_suman(+Total, ?A, ?B) is nondet.
%
%   A y B son dos personas distintas cuyas edades suman Total.
dos_que_suman(Total, A, B) :-
    edad(A, EdadA),
    edad(B, EdadB),
    A \== B,
    Total =:= EdadA + EdadB.

%!  un_par_que_suma(+Total, -A, -B) is semidet.
%
%   A y B son el primer par que se encuentra, y solo ese. A y B deben
%   llegar libres: con ambos ligados, el corte no tiene nada que podar.
un_par_que_suma(Total, A, B) :-
    dos_que_suman(Total, A, B),
    !.
