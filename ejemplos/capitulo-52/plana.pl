:- encoding(utf8).

% Capítulo 52 - Versión 1: las tablas de Turing como hechos.
%
% Una fila de la tabla de una máquina, en la notación de Turing (1936, §3),
%
%   fila(M, Q, Condicion, Operaciones, Q1)
%
% se aplica en la configuración m Q cuando el símbolo leído cumple la
% Condicion: ejecuta las Operaciones en orden y pasa a Q1. Las condiciones
% son blanco (la casilla está vacía, «None»), simbolo(S) (la casilla tiene
% el símbolo S; con S libre, cualquier símbolo, «Any»), no(S) (un símbolo
% distinto de S, «not S») y siempre (la columna vacía de Turing). Las
% operaciones son p(S) (imprimir S), e (borrar), l y r (mover el cabezal
% una casilla a la izquierda o a la derecha). Se aplica la primera fila
% cuya condición se cumple.
%
% La cinta es c(Izquierda, Actual, Derecha), con Izquierda al revés, como
% en el capítulo 51; las casillas sin escribir tienen el símbolo blanco.
% El símbolo ə de Turing, que marca el comienzo de la cinta, es el átomo
% schwa. Las figuras 0 y 1 son números; la sucesión que la máquina calcula
% es la de las figuras que imprime, en orden.
%
% fila/5 es multifile: las versiones siguientes agregan tablas.
%
% solo-local: es un módulo, y SWISH no admite módulos propios.
%
%?- figuras(i, b, 10, Fs).
%?- figuras(ii, b, 15, Fs).

:- module(plana, [fila/5, cumple/2, cinta_vacia/1, leer/2, operar/5,
                  contenido/2, paso/6, figuras/4]).

:- multifile fila/5.
:- discontiguous fila/5.

% fila(M, Q, Condicion, Operaciones, Q1): una fila de la tabla de M.

% La máquina I de Turing (§3): calcula 0101...
fila(i, b, blanco, [p(0), r], c).
fila(i, c, blanco, [r], e).
fila(i, e, blanco, [p(1), r], k).
fila(i, k, blanco, [r], b).

% La misma sucesión con una sola configuración m, que lee lo que imprimió.
fila(i_bis, b, blanco, [p(0)], b).
fila(i_bis, b, simbolo(0), [r, r, p(1)], b).
fila(i_bis, b, simbolo(1), [r, r, p(0)], b).

% La máquina II de Turing (§3): calcula 001011011101111...
fila(ii, b, siempre, [p(schwa), r, p(schwa), r, p(0), r, r, p(0), l, l], o).
fila(ii, o, simbolo(1), [r, p(x), l, l, l], o).
fila(ii, o, simbolo(0), [], q).
fila(ii, q, simbolo(_), [r, r], q).
fila(ii, q, blanco, [p(1), l], p).
fila(ii, p, simbolo(x), [e, r], q).
fila(ii, p, simbolo(schwa), [r], f).
fila(ii, p, blanco, [l, l], p).
fila(ii, f, simbolo(_), [r, r], f).
fila(ii, f, blanco, [p(0), l, l], o).

%!  cumple(?Condicion, +S) is semidet.
%
%   El símbolo leído S cumple la Condicion de una fila. Con
%   simbolo(X) y X libre, X queda ligada al símbolo leído.
cumple(blanco, blanco).
cumple(simbolo(X), S) :-
    S \== blanco,
    X = S.
cumple(no(X), S) :-
    S \== blanco,
    S \== X.
cumple(siempre, _).

%!  cinta_vacia(-Cinta) is det.
%
%   Cinta es una cinta en blanco, con el cabezal en la primera casilla.
cinta_vacia(c([], blanco, [])).

%!  leer(+Cinta, -S) is det.
%
%   S es el símbolo que está bajo el cabezal.
leer(c(_, S, _), S).

%!  operar(+Operaciones:list, +Cinta0, -Cinta, -Fs:list, ?Fs0:list) is det.
%
%   Cinta es Cinta0 después de las Operaciones; Fs es la lista de las
%   figuras impresas, seguida de Fs0.
operar([], Cinta, Cinta, Fs, Fs).
operar([Op|Ops], Cinta0, Cinta, Fs, Fs0) :-
    operacion(Op, Cinta0, Cinta1, Fs, Fs1),
    operar(Ops, Cinta1, Cinta, Fs1, Fs0).

%!  operacion(+Op, +Cinta0, -Cinta, -Fs:list, ?Fs0:list) is det.
%
%   Cinta es Cinta0 después de la operación Op; Fs tiene la figura
%   impresa, si Op imprime un 0 o un 1, seguida de Fs0.
operacion(p(S), c(I, _, D), c(I, S, D), Fs, Fs0) :-
    (   figura(S)
    ->  Fs = [S|Fs0]
    ;   Fs = Fs0
    ).
operacion(e, c(I, _, D), c(I, blanco, D), Fs, Fs).
operacion(l, c(I, S, D), Cinta, Fs, Fs) :-
    izquierda(I, [S|D], Cinta).
operacion(r, c(I, S, D), Cinta, Fs, Fs) :-
    derecha(D, [S|I], Cinta).

% figura(S): S es una figura, un símbolo de la primera clase de Turing.
figura(0).
figura(1).

%!  izquierda(+I:list, +D:list, -Cinta) is det.
%
%   Cinta tiene bajo el cabezal el último símbolo de la parte izquierda
%   I, o un blanco si I está vacía, y D a la derecha.
izquierda([], D, c([], blanco, D)).
izquierda([S|I], D, c(I, S, D)).

%!  derecha(+D:list, +I:list, -Cinta) is det.
%
%   Cinta tiene bajo el cabezal el primer símbolo de la parte derecha D,
%   o un blanco si D está vacía, e I a la izquierda.
derecha([], I, c(I, blanco, [])).
derecha([S|D], I, c(I, S, D)).

%!  contenido(+Cinta, -Simbolos:list) is det.
%
%   Simbolos son los símbolos de la cinta de izquierda a derecha, sin
%   los blancos de los extremos.
contenido(c(I, S, D), Simbolos) :-
    reverse(I, I1),
    append(I1, [S|D], Todos),
    sin_blancos(Todos, Simbolos0),
    reverse(Simbolos0, Invertidos),
    sin_blancos(Invertidos, Simbolos1),
    reverse(Simbolos1, Simbolos).

%!  sin_blancos(+Simbolos0:list, -Simbolos:list) is det.
%
%   Simbolos es Simbolos0 sin los blancos del comienzo.
sin_blancos([], []).
sin_blancos([S|Ss0], Ss) :-
    (   S == blanco
    ->  sin_blancos(Ss0, Ss)
    ;   Ss = [S|Ss0]
    ).

%!  paso(+M, +Q, +Cinta0, -Q1, -Cinta, -Fs:list) is semidet.
%
%   La máquina M, en la configuración m Q con la Cinta0, da un paso:
%   aplica la primera fila cuya condición cumple el símbolo leído, deja
%   la Cinta y pasa a Q1. Fs son las figuras impresas. Falla si ninguna
%   fila se aplica.
paso(M, Q, Cinta0, Q1, Cinta, Fs) :-
    leer(Cinta0, S),
    once(( fila(M, Q, Condicion, Ops, Q1),
           cumple(Condicion, S)
         )),
    operar(Ops, Cinta0, Cinta, Fs, []).

%!  figuras(+M, +Q0, +N:integer, -Fs:list) is semidet.
%
%   Fs son las primeras N figuras que imprime la máquina M desde la
%   configuración m Q0 con la cinta en blanco. Falla si la máquina se
%   detiene antes.
figuras(M, Q0, N, Fs) :-
    cinta_vacia(Cinta),
    ejecutar(M, Q0, Cinta, N, Fs0),
    length(Fs, N),
    append(Fs, _, Fs0).

%!  ejecutar(+M, +Q, +Cinta, +N:integer, -Fs:list) is semidet.
%
%   Fs son las figuras que imprime M desde Q con la Cinta hasta haber
%   impreso por lo menos N.
ejecutar(M, Q, Cinta, N, Fs) :-
    (   N =< 0
    ->  Fs = []
    ;   paso(M, Q, Cinta, Q1, Cinta1, Fs1),
        length(Fs1, K),
        N1 is N - K,
        append(Fs1, Fs2, Fs),
        ejecutar(M, Q1, Cinta1, N1, Fs2)
    ).
