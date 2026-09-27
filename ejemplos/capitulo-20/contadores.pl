:- encoding(utf8).

% Capítulo 20 - Contadores y estado global: un hecho dinámico, flag/3,
% b_setval/2 y nb_setval/2.
%
% solo-local: el sandbox de SWISH no permite flag/3 ni las variables globales.
%
%?- siguiente_numero(A), siguiente_numero(B).
%?- global_con_retroceso(X), global_sin_retroceso(Y).

:- dynamic contador/1.

% contador(N): el último número entregado por siguiente_con_hecho/1.
contador(0).

%!  siguiente_con_hecho(-N:integer) is det.
%
%   N es el número siguiente al último entregado. El estado es un hecho
%   dinámico: se retira el valor anterior y se agrega el nuevo.
siguiente_con_hecho(N) :-
    retract(contador(N0)),
    N is N0 + 1,
    assertz(contador(N)).

%!  siguiente_numero(-N:integer) is det.
%
%   N es el número siguiente al último entregado. El estado es la bandera
%   numero, que flag/3 lee y reemplaza en un solo paso.
siguiente_numero(N) :-
    flag(numero, N0, N0 + 1),
    N is N0 + 1.

%!  global_con_retroceso(-X) is det.
%
%   X es el valor de la variable global v después de un intento fallido de
%   cambiarlo: b_setval/2 se deshace al retroceder, y X es 1.
global_con_retroceso(X) :-
    b_setval(v, 1),
    (   b_setval(v, 2),
        fail
    ;   b_getval(v, X)
    ).

%!  global_sin_retroceso(-X) is det.
%
%   Lo mismo con nb_setval/2, que no se deshace al retroceder: X es 2.
global_sin_retroceso(X) :-
    nb_setval(v, 1),
    (   nb_setval(v, 2),
        fail
    ;   nb_getval(v, X)
    ).

%!  contar_respuestas(:Objetivo, -N:integer) is det.
%
%   N es la cantidad de respuestas de Objetivo, contadas con una variable
%   global en un bucle por falla. aggregate_all(count, Objetivo, N) hace lo
%   mismo sin estado.
contar_respuestas(Objetivo, N) :-
    nb_setval(cuenta, 0),
    forall(call(Objetivo),
           ( nb_getval(cuenta, C0),
             C is C0 + 1,
             nb_setval(cuenta, C) )),
    nb_getval(cuenta, N).
