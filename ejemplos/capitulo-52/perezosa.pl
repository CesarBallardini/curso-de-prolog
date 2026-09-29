:- encoding(utf8).

% Capítulo 52 - Versión 2: estados que son términos; alias y tablas.
%
% Una configuración m es un término: un átomo, como b, o una función de
% configuración m aplicada a argumentos, como f(fin, falta, x). Hay dos
% clases de reglas:
%
%   fila(M, Q, Condicion, Operaciones, Q1)   una fila de una tabla, como
%                                            en la versión 1;
%   alias(M, Q, Q1)                          Q se reescribe como Q1, sin
%                                            leer ni tocar la cinta.
%
% Los parámetros de una regla son variables de Prolog: la unificación de
% la cabeza con la configuración actual los liga, y cada uso de la regla
% tiene variables nuevas. Un paso reescribe la configuración con los alias
% hasta llegar a una que tiene tabla, elige la fila y pasa a su
% configuración siguiente, que es otro término. Nada se expande de
% antemano: se construyen solo los términos por los que pasa el cómputo.
%
% Una regla con una variable anónima en el lugar de M vale para todas las
% máquinas: así se escribe la biblioteca de la versión 3.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- sucesion(alterna, a, 10, S).
%?- resolver(alterna, a, Q, N).

:- module(perezosa, [alias/3, resolver/4, seleccionar/7, paso/6,
                     figuras/4, sucesion/4, ejecutar/5, cinta_de/3]).

:- use_module(plana, [fila/5, cumple/2, cinta_vacia/1, leer/2, operar/5]).

:- multifile alias/3.
:- discontiguous alias/3.

% alias(M, Q, Q1): en la máquina M, la configuración Q se reescribe Q1.

% La sucesión 0101... con dos funciones de configuración y cuatro alias.
plana:fila(alterna, emite(C, B), siempre, [p(B), r], C).
plana:fila(alterna, salta(C), siempre, [r], C).
alias(alterna, a, emite(b, 0)).
alias(alterna, b, salta(c)).
alias(alterna, c, emite(d, 1)).
alias(alterna, d, salta(a)).

%!  resolver(+M, +Q0, -Q, -N:integer) is det.
%
%   Q es la configuración a la que se llega desde Q0 reescribiendo con
%   los alias de M hasta una configuración que no es un alias, en N
%   reescrituras. No termina si los alias forman un ciclo.
resolver(M, Q0, Q, N) :-
    resolver(M, Q0, Q, 0, N).

%!  resolver(+M, +Q0, -Q, +N0:integer, -N:integer) is det.
%
%   Como resolver/4, con N0 reescrituras hechas antes.
resolver(M, Q0, Q, N0, N) :-
    (   alias(M, Q0, Q1)
    ->  N1 is N0 + 1,
        resolver(M, Q1, Q, N1, N)
    ;   Q = Q0,
        N = N0
    ).

%!  seleccionar(+M, +Q, +S, -Qr, -N:integer, -Ops:list, -Q1) is semidet.
%
%   Desde la configuración Q, leyendo S, la máquina M llega en N
%   reescrituras a la configuración Qr, que tiene tabla, y su primera
%   fila que se aplica a S tiene las operaciones Ops y la configuración
%   siguiente Q1. Falla si ninguna fila se aplica.
seleccionar(M, Q, S, Qr, N, Ops, Q1) :-
    resolver(M, Q, Qr, N),
    once(( fila(M, Qr, Condicion, Ops, Q1),
           cumple(Condicion, S)
         )).

%!  paso(+M, +Q, +Cinta0, -Q1, -Cinta, -Fs:list) is semidet.
%
%   La máquina M, en la configuración Q con la Cinta0, da un paso y
%   pasa a Q1 con la Cinta; Fs son las figuras impresas. Falla si
%   ninguna fila se aplica.
paso(M, Q, Cinta0, Q1, Cinta, Fs) :-
    leer(Cinta0, S),
    seleccionar(M, Q, S, _, _, Ops, Q1),
    operar(Ops, Cinta0, Cinta, Fs, []).

%!  figuras(+M, +Q0, +N:integer, -Fs:list) is semidet.
%
%   Fs son las primeras N figuras que imprime M desde Q0 con la cinta en
%   blanco. Falla si la máquina se detiene antes.
figuras(M, Q0, N, Fs) :-
    cinta_vacia(Cinta),
    figuras(M, Q0, Cinta, N, Fs0),
    length(Fs, N),
    append(Fs, _, Fs0).

%!  sucesion(+M, +Q0, +N:integer, -S:atom) is semidet.
%
%   S es el átomo que escribe en orden las primeras N figuras que
%   imprime M desde Q0 con la cinta en blanco.
sucesion(M, Q0, N, S) :-
    figuras(M, Q0, N, Fs),
    atomic_list_concat(Fs, S).

%!  figuras(+M, +Q, +Cinta, +N:integer, -Fs:list) is semidet.
%
%   Fs son las figuras que imprime M desde Q con la Cinta hasta haber
%   impreso por lo menos N.
figuras(M, Q, Cinta, N, Fs) :-
    (   N =< 0
    ->  Fs = []
    ;   paso(M, Q, Cinta, Q1, Cinta1, Fs1),
        length(Fs1, K),
        N1 is N - K,
        append(Fs1, Fs2, Fs),
        figuras(M, Q1, Cinta1, N1, Fs2)
    ).

%!  ejecutar(+M, +Q0, +Cinta0, +Limite:integer, -R) is det.
%
%   R es el resultado de ejecutar M desde Q0 con la Cinta0, con a lo
%   sumo Limite pasos: detenida(Q, Cinta) si llega a la configuración Q
%   y ninguna fila se aplica, o limite(Q, Cinta) si no se detuvo. Q es
%   la configuración después de resolver los alias.
ejecutar(M, Q0, Cinta0, Limite, R) :-
    leer(Cinta0, S),
    (   seleccionar(M, Q0, S, _, _, Ops, Q1)
    ->  (   Limite =:= 0
        ->  resolver(M, Q0, Q, _),
            R = limite(Q, Cinta0)
        ;   operar(Ops, Cinta0, Cinta1, _, []),
            Limite1 is Limite - 1,
            ejecutar(M, Q1, Cinta1, Limite1, R)
        )
    ;   resolver(M, Q0, Q, _),
        R = detenida(Q, Cinta0)
    ).

%!  cinta_de(+Simbolos:list, +Posicion:integer, -Cinta) is semidet.
%
%   Cinta tiene los Simbolos desde la casilla 0 y el cabezal en la
%   casilla Posicion, que es 0 o más. Falla si Posicion pasa del largo
%   de la lista.
cinta_de(Simbolos, Posicion, c(I, S, D)) :-
    length(Antes, Posicion),
    append(Antes, Resto, Simbolos),
    reverse(Antes, I),
    (   Resto = [S|D]
    ->  true
    ;   S = blanco,
        D = []
    ).
