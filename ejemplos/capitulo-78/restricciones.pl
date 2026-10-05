:- encoding(utf8).

% Capítulo 78 - Mastermind, versión 3: la jugada consistente con
% restricciones.
%
% La versión 1 genera los códigos y prueba cada uno contra las respuestas.
% Aquí las respuestas son restricciones de library(clpfd) sobre los cuatro
% dígitos del intento, como en el capítulo 23: cada dígito entre 0 y 9,
% todos distintos, y por cada respuesta r(I, T, V), T igualdades con I en
% la misma posición y T + V dígitos comunes con I, contados con
% reificación. Etiquetar de menor a mayor da el primer código consistente
% en el orden de los códigos: el mismo intento de las versiones 1 y 2.
%
% solo-local: es un módulo que carga otro.
%
%?- siguiente_clp([r([0, 1, 2, 3], 0, 1)], I).
%?- adivinar_clp([3, 8, 1, 6], Intentos).

:- module(restricciones,
          [ siguiente_clp/2,
            adivinar_clp/2
          ]).

:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- reexport(mastermind).

%!  siguiente_clp(+Respuestas:list, -Intento:list) is semidet.
%
%   Intento es el primer código consistente con Respuestas, hallado
%   restringiendo y etiquetando. Falla si ninguno es consistente. Intento
%   debe llegar libre.
siguiente_clp(Respuestas, Intento) :-
    Intento = [_, _, _, _],
    Intento ins 0..9,
    all_different(Intento),
    maplist(restringir(Intento), Respuestas),
    once(label(Intento)).

%!  restringir(+Intento:list, +Respuesta) is semidet.
%
%   Impone que Intento, de ser el código, habría recibido Respuesta,
%   r(I, T, V): T posiciones iguales a las de I, y T + V dígitos en común.
restringir(Intento, r(I, T, V)) :-
    maplist(igual, Intento, I, Toros),
    sum(Toros, #=, T),
    foldl(comun(I), Intento, Comunes, []),
    sum(Comunes, #=, T + V).

%!  igual(?X, +Y:integer, -B) is det.
%
%   B es 1 si X es igual a Y, y 0 si no: la reificación de X #= Y.
igual(X, Y, B) :-
    B #<==> (X #= Y).

%!  comun(+I:list, ?X, -Bs0:list, +Bs:list) is det.
%
%   Bs0 son las variables booleanas de X #= Y para cada dígito Y de I,
%   seguidas de Bs: su suma es 1 si X es uno de los dígitos de I.
comun(I, X, Bs0, Bs) :-
    foldl(igual_a(X), I, Bs0, Bs).

%!  igual_a(?X, +Y:integer, -Bs0:list, +Bs:list) is det.
%
%   Bs0 es [B|Bs], con B la reificación de X #= Y.
igual_a(X, Y, [B|Bs], Bs) :-
    igual(X, Y, B).

%!  adivinar_clp(+Secreto:list, -Intentos:list) is det.
%
%   Intentos son los intentos contra Secreto con siguiente_clp/2, hasta el
%   que lo acierta: los mismos que da adivinar/2.
adivinar_clp(Secreto, Intentos) :-
    adivinar_clp(Secreto, [], Intentos).

%!  adivinar_clp(+Secreto:list, +Respuestas:list, -Intentos:list) is det.
%
%   Como adivinar_clp/2, con las Respuestas ya recibidas.
adivinar_clp(Secreto, Respuestas, [Intento|Intentos]) :-
    siguiente_clp(Respuestas, Intento),
    respuesta(Secreto, Intento, T, V),
    (   T =:= 4
    ->  Intentos = []
    ;   adivinar_clp(Secreto, [r(Intento, T, V)|Respuestas], Intentos)
    ).
