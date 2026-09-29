:- encoding(utf8).

% Capítulo 48 - Versión 1: compuertas como tablas, circuitos como cláusulas.
%
% Cada compuerta es su tabla de verdad, escrita como hechos, con las
% entradas antes de la salida. Un circuito es una regla cuyo cuerpo tiene
% una meta por compuerta y una variable por cable: los cables internos son
% las variables que no aparecen en la cabeza. La misma regla calcula las
% salidas a partir de las entradas y las entradas que producen una salida.
%
%?- sumador(1, 1, 0, S, C).
%?- sumador(A, B, Ci, 1, 1).
%?- inv(X, X).
%?- biestable(1, 1, Q, Qn).

% inv(A, S): S es la salida de un inversor con entrada A.
inv(0, 1).
inv(1, 0).

% and(A, B, S): S es la salida de una compuerta AND con entradas A y B.
and(0, 0, 0).
and(0, 1, 0).
and(1, 0, 0).
and(1, 1, 1).

% or(A, B, S): S es la salida de una compuerta OR con entradas A y B.
or(0, 0, 0).
or(0, 1, 1).
or(1, 0, 1).
or(1, 1, 1).

% xor(A, B, S): S es la salida de una compuerta XOR con entradas A y B.
xor(0, 0, 0).
xor(0, 1, 1).
xor(1, 0, 1).
xor(1, 1, 0).

% nand(A, B, S): S es la salida de una compuerta NAND con entradas A y B.
nand(0, 0, 1).
nand(0, 1, 1).
nand(1, 0, 1).
nand(1, 1, 0).

% nor(A, B, S): S es la salida de una compuerta NOR con entradas A y B.
nor(0, 0, 1).
nor(0, 1, 0).
nor(1, 0, 0).
nor(1, 1, 0).

%!  semisumador(?A, ?B, ?S, ?C) is nondet.
%
%   S es el bit de suma y C el acarreo de sumar los bits A y B.
semisumador(A, B, S, C) :-
    xor(A, B, S),
    and(A, B, C).

%!  sumador(?A, ?B, ?Ci, ?S, ?Co) is nondet.
%
%   S es el bit de suma y Co el acarreo de salida de sumar los bits A y B
%   con el acarreo de entrada Ci: dos semisumadores y una compuerta OR.
sumador(A, B, Ci, S, Co) :-
    semisumador(A, B, T, C1),
    semisumador(T, Ci, S, C2),
    or(C1, C2, Co).

%!  sumar_bits(?As:list, ?Bs:list, ?Ss:list, ?C) is nondet.
%
%   Ss es la suma de los números binarios As y Bs, de la misma longitud y
%   con el bit menos significativo primero, y C el acarreo final: un
%   sumador por bit, encadenados por el acarreo.
sumar_bits(As, Bs, Ss, C) :-
    sumar_bits(As, Bs, 0, Ss, C).

%!  sumar_bits(?As:list, ?Bs:list, ?Ci, ?Ss:list, ?C) is nondet.
%
%   Como sumar_bits/4, con el acarreo de entrada Ci.
sumar_bits([], [], C, [], C).
sumar_bits([A|As], [B|Bs], Ci, [S|Ss], C) :-
    sumador(A, B, Ci, S, C1),
    sumar_bits(As, Bs, C1, Ss, C).

%!  biestable(?S, ?R, ?Q, ?Qn) is nondet.
%
%   Q y Qn son las salidas estables de dos compuertas NAND conectadas en
%   anillo, con las entradas S y R: cada salida es una entrada de la otra.
biestable(S, R, Q, Qn) :-
    nand(S, Qn, Q),
    nand(R, Q, Qn).
