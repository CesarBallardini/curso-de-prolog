:- encoding(utf8).

% Capítulo 48 - Versión 7: compuertas hechas con transistores.
%
% Spivey (An Introduction to Logic Programming through Prolog, capítulo
% 12) describe un transistor CMOS por sus estados estables. Un transistor
% p conecta la fuente con el drenador cuando su compuerta está en 0, y
% entonces los dos tienen el mismo valor; con la compuerta en 1 no los
% conecta, y cada uno tiene cualquier valor. Un transistor n se comporta
% al revés. Un circuito es la conjunción de sus transistores, con una
% variable por cable, y sus respuestas son sus estados estables: ninguna
% si el circuito no tiene un estado estable.
%
%?- inversor_cmos(A, Z).
%?- xor_cmos(A, B, Z).
%?- cortocircuito(X).

% pwr(X): el cable X está conectado a la alimentación, el 1 lógico.
pwr(1).

% gnd(X): el cable X está conectado a tierra, el 0 lógico.
gnd(0).

% ptran(F, G, D): estado estable de un transistor p con fuente F,
% compuerta G y drenador D.
ptran(X, 0, X).
ptran(_, 1, _).

% ntran(F, G, D): estado estable de un transistor n con fuente F,
% compuerta G y drenador D.
ntran(X, 1, X).
ntran(_, 0, _).

%!  inversor_cmos(?A, ?Z) is nondet.
%
%   Z es la salida del inversor CMOS con entrada A: un transistor p entre
%   la alimentación y la salida, y uno n entre la salida y tierra.
inversor_cmos(A, Z) :-
    pwr(P),
    gnd(T),
    ptran(P, A, Z),
    ntran(Z, A, T).

%!  cortocircuito(?X) is semidet.
%
%   El cable X está conectado a la alimentación y a tierra a la vez. No
%   tiene estados estables, y la consulta falla siempre.
cortocircuito(X) :-
    pwr(X),
    gnd(X).

%!  xor_cmos(?A, ?B, ?Z) is nondet.
%
%   Z es la salida de una compuerta XOR de seis transistores con entradas
%   A y B. Un inversor da NA, la negación de A. El par en paralelo, un
%   transistor n y uno p, conecta B con la salida cuando A es 0. Los otros
%   dos forman un inversor de B alimentado por A y por NA, que solo puede
%   llevar la salida a un valor distinto del de B cuando A es 1.
xor_cmos(A, B, Z) :-
    inversor_cmos(A, NA),
    ntran(B, NA, Z),
    ptran(B, A, Z),
    ptran(A, B, Z),
    ntran(NA, B, Z).
