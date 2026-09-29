:- encoding(utf8).

% Capítulo 51 - Versión 8: autómatas de pila y máquinas de Turing.
%
% Un autómata de pila es un autómata finito con una pila. Una transición
%
%   pila(M, Q, Lee, X, Apila, Q1)
%
% se aplica en el estado Q con el símbolo X en el tope de la pila: lee la
% cadena Lee, que es [S] o [] (una transición ε), reemplaza X por la
% lista Apila, cuyo primer elemento queda en el tope, y pasa a Q1. La pila
% empieza con el símbolo fondo(M, Z), y el autómata acepta si, leída toda
% la palabra, llega a un estado final.
%
% Una máquina de Turing tiene una cinta infinita en los dos sentidos y un
% cabezal. Una transición
%
%   turing(M, Q, Leido, Escrito, Movimiento, Q1)
%
% se aplica en el estado Q con Leido bajo el cabezal: escribe Escrito,
% mueve el cabezal a izq o a der, y pasa a Q1. La máquina se detiene
% cuando no hay transición, y acepta si se detiene en un estado final. La
% cinta es c(Izquierda, Actual, Derecha), con Izquierda al revés, y las
% celdas sin escribir tienen el símbolo blanco.
%
% Las relaciones que describen las máquinas son multifile: otros archivos
% agregan máquinas.
%
%?- string_chars("(())()", W), acepta_pila(parentesis, W).
%?- acepta_pila(palindromo, [a, b, b, a]).
%?- length(W, 4), acepta_pila(palindromo, W).
%?- turing(abc, [a, a, b, b, c, c], 1000, R).

:- multifile inicial/2, final/2, fondo/2, pila/6, turing/6.
:- discontiguous inicial/2, final/2, fondo/2, pila/6, turing/6.

% inicial(M, Q0): Q0 es el estado inicial de la máquina M.
inicial(parentesis, p).
inicial(palindromo, q0).
inicial(abc, q0).

% final(M, Q): Q es un estado final de la máquina M.
final(parentesis, fin).
final(palindromo, fin).
final(abc, acepta).

% fondo(M, Z): Z es el símbolo con el que empieza la pila de M.
fondo(parentesis, z).
fondo(palindromo, z).

% pila(M, Q, Lee, X, Apila, Q1): una transición del autómata de pila M.
%
% parentesis acepta las sucesiones de paréntesis bien anidadas: apila un
% p por cada ( y lo desapila con la ) que lo cierra.
pila(parentesis, p, ['('], z, [p, z], p).
pila(parentesis, p, ['('], p, [p, p], p).
pila(parentesis, p, [')'], p, [], p).
pila(parentesis, p, [], z, [z], fin).
% palindromo acepta los palíndromos de longitud par sobre {a, b}: apila
% la primera mitad, elige con una transición ε dónde está la mitad, y
% desapila comparando la segunda.
pila(palindromo, q0, [S], X, [S, X], q0) :-
    member(S, [a, b]),
    member(X, [z, a, b]).
pila(palindromo, q0, [], X, [X], q1) :-
    member(X, [z, a, b]).
pila(palindromo, q1, [S], S, [], q1) :-
    member(S, [a, b]).
pila(palindromo, q1, [], z, [z], fin).

%!  acepta_pila(+M, ?W:list) is nondet.
%
%   El autómata de pila M acepta W. Da una respuesta por cada cómputo que
%   acepta. No termina si M puede apilar sin fin con transiciones ε.
acepta_pila(M, W) :-
    inicial(M, Q0),
    fondo(M, Z),
    configuracion(M, Q0, W, [Z]).

%!  configuracion(+M, +Q, ?W:list, +Pila:list) is nondet.
%
%   Desde el estado Q con la Pila, M lee W y llega a un estado final.
configuracion(M, Q, [], _Pila) :-
    final(M, Q).
configuracion(M, Q, W, [X|Pila]) :-
    pila(M, Q, Lee, X, Apila, Q1),
    append(Lee, W1, W),
    append(Apila, Pila, Pila1),
    configuracion(M, Q1, W1, Pila1).

% turing(M, Q, Leido, Escrito, Movimiento, Q1): una transición de la
% máquina de Turing M.
%
% abc acepta a^n b^n c^n: marca una a con x, la primera b con y y la
% primera c con z, vuelve hasta la x y repite; cuando no quedan a,
% verifica que solo quedan y y z.
turing(abc, q0, a, x, der, q1).
turing(abc, q0, y, y, der, q4).
turing(abc, q0, blanco, blanco, der, acepta).
turing(abc, q1, a, a, der, q1).
turing(abc, q1, y, y, der, q1).
turing(abc, q1, b, y, der, q2).
turing(abc, q2, b, b, der, q2).
turing(abc, q2, z, z, der, q2).
turing(abc, q2, c, z, izq, q3).
turing(abc, q3, S, S, izq, q3) :-
    member(S, [a, b, y, z]).
turing(abc, q3, x, x, der, q0).
turing(abc, q4, S, S, der, q4) :-
    member(S, [y, z]).
turing(abc, q4, blanco, blanco, der, acepta).

%!  turing(+M, +Entrada:list, +Limite:integer, -R) is det.
%
%   R es el resultado de ejecutar la máquina de Turing M con la Entrada
%   en la cinta y el cabezal en su primer símbolo, con a lo sumo Limite
%   pasos: acepta(Cinta) o rechaza(Cinta) si se detiene, en un estado
%   final o en otro, y limite(Q, Cinta) si no se detuvo. Cinta es el
%   contenido de la cinta, sin los blancos de los extremos.
turing(M, Entrada, Limite, R) :-
    inicial(M, Q0),
    (   Entrada = [S|Derecha]
    ->  true
    ;   S = blanco,
        Derecha = []
    ),
    ejecutar(M, Q0, c([], S, Derecha), Limite, R).

%!  ejecutar(+M, +Q, +Cinta, +Limite:integer, -R) is det.
%
%   R es el resultado de continuar desde el estado Q con la Cinta, con
%   a lo sumo Limite pasos más.
ejecutar(M, Q, Cinta, Limite, R) :-
    Cinta = c(_, S, _),
    (   turing(M, Q, S, E, Mov, Q1)
    ->  (   Limite =:= 0
        ->  contenido(Cinta, Contenido),
            R = limite(Q, Contenido)
        ;   mover_cabezal(Mov, E, Cinta, Cinta1),
            Limite1 is Limite - 1,
            ejecutar(M, Q1, Cinta1, Limite1, R)
        )
    ;   contenido(Cinta, Contenido),
        (   final(M, Q)
        ->  R = acepta(Contenido)
        ;   R = rechaza(Contenido)
        )
    ).

%!  mover_cabezal(+Mov, +E, +Cinta0, -Cinta) is det.
%
%   Cinta es Cinta0 con E escrito bajo el cabezal y el cabezal movido una
%   celda en el sentido Mov. Más allá del último símbolo hay un blanco.
mover_cabezal(izq, E, c(I, _, D), Cinta) :-
    izquierda(I, [E|D], Cinta).
mover_cabezal(der, E, c(I, _, D), Cinta) :-
    derecha(D, [E|I], Cinta).

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
%   Simbolos es el contenido de la Cinta de izquierda a derecha, sin los
%   blancos de los extremos.
contenido(c(I, S, D), Simbolos) :-
    reverse(I, I1),
    append(I1, [S|D], Todos),
    sin_blancos(Todos, Sin),
    reverse(Sin, Sin1),
    sin_blancos(Sin1, Sin2),
    reverse(Sin2, Simbolos).

%!  sin_blancos(+Simbolos:list, -Resto:list) is det.
%
%   Resto es Simbolos sin los blancos del comienzo.
sin_blancos([blanco|Ss], Resto) :-
    !,
    sin_blancos(Ss, Resto).
sin_blancos(Ss, Ss).
